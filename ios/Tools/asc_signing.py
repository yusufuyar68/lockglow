"""Temporary App Store signing for CI (used by .github/workflows/testflight.yml).

Xcode's automatic signing with an App Store Connect API key cannot read App Groups
(`/xcbuild/v1/appGroups` answers 401, 2026-10-20), and the team already has the maximum
number of distribution certificates in long-term use elsewhere (Expo). So every TestFlight
run signs with throwaway credentials that exist only on the CI runner:

  setup    new RSA key + CSR -> distribution certificate -> IOS_APP_STORE profile per bundle id
           named 'Lockglow CI <run tag> <bundle id>'; writes the .p12, its password, the export
           options input and a state file (ids only)
  cleanup  generation rotation, see cleanup(): the certificate that signed the newest upload is
           kept (Apple may mark builds signed with a revoked certificate Invalid Binary); older
           'Lockglow CI' generations are retired once the new build is VALID

The user allowed temporary certificates and profiles on 2026-10-20. Certificates used by any
profile outside the 'Lockglow CI' generations (Expo, other apps) are never revoked.

Environment: ASC_KEY_ID, ASC_ISSUER_ID, KEY_PATH (path of the .p8 file).
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import plistlib
import secrets
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

import jwt
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import pkcs12
from cryptography.x509.oid import NameOID

API = "https://api.appstoreconnect.apple.com"
PROFILE_PREFIX = "Lockglow CI "


class ApiError(Exception):
    def __init__(self, status: int, text: str):
        super().__init__(f"HTTP {status}: {text}")
        self.status = status


def token() -> str:
    now = int(time.time())
    return jwt.encode(
        {"iss": os.environ["ASC_ISSUER_ID"].strip(), "iat": now, "exp": now + 900, "aud": "appstoreconnect-v1"},
        Path(os.environ["KEY_PATH"]).read_text(),
        algorithm="ES256",
        headers={"kid": os.environ["ASC_KEY_ID"].strip(), "typ": "JWT"},
    )


def call(method: str, path: str, body: dict | None = None, attempts: int = 5) -> dict:
    """One API request. Network errors, 429 and 5xx are retried with backoff; other HTTP errors raise ApiError.

    POST is retried only on 429: after a network error or a 5xx it may already have been applied, and a
    retried POST could create a second certificate that the state file would not know about.
    """
    data = json.dumps(body).encode() if body is not None else None
    for attempt in range(1, attempts + 1):
        req = urllib.request.Request(API + path, data=data, method=method,
                                     headers={"Authorization": "Bearer " + token(), "Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                raw = r.read()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as e:
            try:
                errors = json.loads(e.read() or b"{}").get("errors", [])
            except ValueError:
                errors = []
            err = ApiError(e.code, "; ".join(f"{x.get('code')}: {x.get('detail')}" for x in errors) or str(e.reason))
            retryable = e.code == 429 or (e.code >= 500 and method != "POST")
            if not retryable or attempt == attempts:
                raise err from None
        except (urllib.error.URLError, TimeoutError, ConnectionError, ValueError) as e:
            if method == "POST" or attempt == attempts:
                raise ApiError(0, f"ağ hatası: {e}") from None
        time.sleep(min(60, 5 * 2 ** (attempt - 1)))
    raise AssertionError("unreachable")


def q(value: str) -> str:
    return urllib.parse.quote(value, safe="")


def profile_entitlements(content: bytes) -> dict:
    """Entitlements of a .mobileprovision (CMS-signed XML plist), without the macOS `security` tool."""
    start, end = content.find(b"<?xml"), content.find(b"</plist>")
    if start < 0 or end < 0:
        return {}
    return plistlib.loads(content[start:end + len(b"</plist>")]).get("Entitlements", {})


def bundle_resource(identifier: str) -> str:
    found = call("GET", f"/v1/bundleIds?filter[identifier]={q(identifier)}&fields[bundleIds]=identifier&limit=200")["data"]
    exact = [b for b in found if b["attributes"]["identifier"] == identifier]
    if not exact:
        sys.exit(f"Uygulama kimliği kayıtlı değil: {identifier}")
    return exact[0]["id"]


def setup(a: argparse.Namespace) -> None:
    state_path = Path(a.state)
    state: dict = {"certificate": None, "profiles": []}

    def save() -> None:
        state_path.write_text(json.dumps(state))

    save()

    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    csr = (x509.CertificateSigningRequestBuilder()
           .subject_name(x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, "Lockglow CI"),
                                    x509.NameAttribute(NameOID.COUNTRY_NAME, "TR")]))
           .sign(key, hashes.SHA256()))
    csr_pem = csr.public_bytes(serialization.Encoding.PEM).decode()

    cert_res = None
    failures = []
    for ctype in ("DISTRIBUTION", "IOS_DISTRIBUTION"):
        try:
            cert_res = call("POST", "/v1/certificates", {"data": {
                "type": "certificates", "attributes": {"certificateType": ctype, "csrContent": csr_pem}}})["data"]
            break
        except ApiError as e:
            failures.append(f"{ctype}: {e}")
            if not 400 <= e.status < 500:
                break  # unknown outcome (network/5xx): do not risk creating a second certificate
    if cert_res is None:
        sys.exit("Geçici dağıtım sertifikası oluşturulamadı (Apple'ın sertifika sınırı dolu olabilir):\n  "
                 + "\n  ".join(failures))
    state["certificate"] = cert_res["id"]
    save()
    print("Geçici sertifika oluşturuldu:", cert_res["attributes"]["certificateType"], cert_res["id"])

    cert = x509.load_der_x509_certificate(base64.b64decode(cert_res["attributes"]["certificateContent"]))
    password = secrets.token_hex(16)
    # Legacy PKCS#12 algorithms: `security import` on macOS rejects the OpenSSL 3 defaults.
    encryption = (serialization.PrivateFormat.PKCS12.encryption_builder()
                  .kdf_rounds(50000)
                  .key_cert_algorithm(pkcs12.PBES.PBESv1SHA1And3KeyTripleDESCBC)
                  .hmac_hash(hashes.SHA1())
                  .build(password.encode()))
    Path(a.p12).write_bytes(pkcs12.serialize_key_and_certificates(b"Lockglow CI", key, cert, None, encryption))
    Path(a.p12_password).write_text(password)
    os.chmod(a.p12, 0o600)
    os.chmod(a.p12_password, 0o600)

    # Xcode 16+ reads UserData/Provisioning Profiles; older tools the MobileDevice folder. Write both.
    profile_dirs = [Path.home() / "Library/MobileDevice/Provisioning Profiles",
                    Path.home() / "Library/Developer/Xcode/UserData/Provisioning Profiles"]
    for d in profile_dirs:
        d.mkdir(parents=True, exist_ok=True)
    chosen: dict[str, str] = {}
    missing_group = []
    for bid in a.bundle_ids:
        name = f"{PROFILE_PREFIX}{a.run_tag} {bid}"
        prof = call("POST", "/v1/profiles", {"data": {
            "type": "profiles",
            "attributes": {"name": name, "profileType": "IOS_APP_STORE"},
            "relationships": {
                "bundleId": {"data": {"type": "bundleIds", "id": bundle_resource(bid)}},
                "certificates": {"data": [{"type": "certificates", "id": cert_res["id"]}]},
            },
        }})["data"]
        state["profiles"].append(prof["id"])
        save()
        attrs = prof["attributes"]
        content = base64.b64decode(attrs["profileContent"])
        for d in profile_dirs:
            (d / f"{attrs['uuid']}.mobileprovision").write_bytes(content)
        chosen[bid] = attrs["uuid"]
        groups = profile_entitlements(content).get("com.apple.security.application-groups", [])
        print("Geçici profil oluşturuldu:", name, "| App Groups:", groups)
        if a.app_group and a.app_group not in groups:
            missing_group.append(bid)

    if missing_group:
        sys.exit(f"Profil(ler) App Group '{a.app_group}' içermiyor: {', '.join(missing_group)}. "
                 "Developer portalında (Identifiers > App ID > App Groups > Configure) grubu bu App ID'lere ata.")

    Path(a.export_info).write_text(json.dumps(
        {"sha1": cert.fingerprint(hashes.SHA1()).hex().upper(), "profiles": chosen}, indent=2))


def wait_for_processing(a: argparse.Namespace) -> str:
    """Poll this run's build until App Store Connect finishes processing it. Returns the last state."""
    apps = call("GET", f"/v1/apps?filter[bundleId]={q(a.app_bundle_id)}&fields[apps]=bundleId")["data"]
    apps = [x for x in apps if x["attributes"]["bundleId"] == a.app_bundle_id]
    if not apps:
        return "UYGULAMA KAYDI YOK"
    app_id = apps[0]["id"]
    deadline = time.time() + a.wait_minutes * 60
    state = "HENÜZ YOK"
    while time.time() < deadline:
        builds = call("GET", f"/v1/builds?filter[app]={app_id}&filter[version]={q(a.build_number)}"
                             "&sort=-uploadedDate&fields[builds]=version,processingState,uploadedDate&limit=5")["data"]
        state = builds[0]["attributes"]["processingState"] if builds else "HENÜZ YOK"
        print(time.strftime("%H:%M:%S"), "build", a.build_number, "durum:", state, flush=True)
        if state in ("VALID", "FAILED", "INVALID"):
            break
        time.sleep(60)
    return state


def all_profiles() -> list[dict]:
    """Every profile of the team with its certificate ids (follows pagination)."""
    out: list[dict] = []
    path = "/v1/profiles?limit=200&fields[profiles]=name,certificates&include=certificates&limit[certificates]=50"
    while path:
        r = call("GET", path)
        out += r.get("data", [])
        nxt = (r.get("links") or {}).get("next")
        path = nxt[len(API):] if nxt and nxt.startswith(API) else None
    return out


def cert_ids(profile: dict) -> set[str]:
    return {c["id"] for c in ((profile.get("relationships") or {}).get("certificates") or {}).get("data") or []}


def delete(kind: str, rid: str, done: str) -> bool:
    try:
        call("DELETE", f"/v1/{kind}/{rid}")
        print(f"{done}: {rid}")
    except ApiError as e:
        if e.status != 404:
            print(f"::error::{kind}/{rid} silinemedi: {e}")
            return False
        print(f"{done} (zaten yoktu): {rid}")
    except Exception as e:
        print(f"::error::{kind}/{rid} silinemedi: {e}")
        return False
    return True


def retire(profiles: list[dict], certs: set[str]) -> bool:
    """Revoke certificates first, then delete profiles: if a revoke fails, its profiles stay
    behind and keep pointing at it, so the next run finds and retries it."""
    ok = all([delete("certificates", c, "Eski geçici sertifika iptal edildi") for c in sorted(certs)])
    if ok:
        ok = all([delete("profiles", p["id"], "Eski geçici profil silindi") for p in profiles])
    return ok


def cleanup(a: argparse.Namespace) -> None:
    """Generation rotation (Apple: builds signed with a revoked distribution certificate may be
    marked Invalid Binary, so the certificate that signed the newest upload is never revoked):

      uploaded, build VALID     -> retire every OLDER 'Lockglow CI' generation, keep this one
      upload never attempted    -> nothing was signed with this run's certificate: retire this run
      anything else             -> touch nothing; the next successful run retires it

    A certificate is retired only if no profile outside the retired 'Lockglow CI' generations
    uses it, so Expo's and other apps' certificates are never revoked.
    """
    try:
        state = json.loads(a.state_json or "{}")
    except ValueError:
        state = {}
    current_cert = state.get("certificate")
    current_profiles = set(state.get("profiles") or [])
    current_prefix = f"{PROFILE_PREFIX}{a.run_tag} "

    if a.uploaded == "true":
        try:
            processing = wait_for_processing(a)
        except Exception as e:
            processing = f"beklenemedi ({e})"
        if processing != "VALID":
            print(f"::warning::Build {a.build_number} durumu: {processing}. Hiçbir sertifika/profil silinmedi; "
                  "bir sonraki başarılı çalıştırma eskileri temizler.")
            return
        print(f"Build {a.build_number} işlendi (VALID). Bu çalıştırmanın sertifikası korunuyor: {current_cert}")
        profiles = all_profiles()
        old = [p for p in profiles if p["attributes"]["name"].startswith(PROFILE_PREFIX)
               and not p["attributes"]["name"].startswith(current_prefix) and p["id"] not in current_profiles]
    elif a.export_attempted != "true":
        if not current_cert and not current_profiles:
            print("Bu çalıştırma geçici sertifika/profil oluşturmamış; silinecek bir şey yok.")
            return
        print("Yükleme hiç denenmedi; bu çalıştırmanın geçici sertifikası ve profilleri siliniyor.")
        profiles = all_profiles()
        old = [p for p in profiles if p["id"] in current_profiles or p["attributes"]["name"].startswith(current_prefix)]
        if current_cert:
            # Profiles of this run may be missing from the listing if setup stopped halfway.
            old_certs = {current_cert}
            others = set().union(*[cert_ids(p) for p in profiles if p not in old]) if profiles else set()
            if current_cert in others:
                print(f"::warning::Sertifika {current_cert} başka bir profilde de kullanılıyor; iptal edilmedi.")
                old_certs = set()
            if not retire(old, old_certs):
                sys.exit(1)
            return
    else:
        print("::warning::Yükleme denendi ama başarısız ya da yarım kaldı; bu çalıştırmanın sertifikası korunuyor "
              "(yüklenmiş olabilir). Bir sonraki başarılı çalıştırma temizler.")
        return

    keep = set().union(*[cert_ids(p) for p in profiles if p not in old]) if profiles else set()
    if current_cert:
        keep.add(current_cert)
    old_certs = set().union(*[cert_ids(p) for p in old]) - keep if old else set()
    if not old:
        print("Temizlenecek eski 'Lockglow CI' profili yok.")
        return
    print(f"Eski nesil: {len(old)} profil, {len(old_certs)} sertifika.")
    if not retire(old, old_certs):
        sys.exit(1)


def main() -> None:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("setup")
    s.add_argument("--state", required=True)
    s.add_argument("--p12", required=True)
    s.add_argument("--p12-password", required=True)
    s.add_argument("--export-info", required=True)
    s.add_argument("--run-tag", required=True, help="unique per run attempt, e.g. <run_id>-<run_attempt>")
    s.add_argument("--app-group", default="", help="profiles must contain this App Group, else stop early")
    s.add_argument("bundle_ids", nargs="+")
    c = sub.add_parser("cleanup")
    c.add_argument("--state-json", default="")
    c.add_argument("--run-tag", required=True)
    c.add_argument("--uploaded", default="false")
    c.add_argument("--export-attempted", default="false")
    c.add_argument("--app-bundle-id", required=True)
    c.add_argument("--build-number", required=True)
    c.add_argument("--wait-minutes", type=int, default=60)
    a = ap.parse_args()
    setup(a) if a.cmd == "setup" else cleanup(a)


if __name__ == "__main__":
    main()
