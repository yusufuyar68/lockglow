"""Prepare App Store provisioning profiles for manual signing (CI only, used by testflight.yml).

Xcode's automatic signing with an App Store Connect API key cannot read App Groups
(`/xcbuild/v1/appGroups` answers 401), so the app and widget are signed manually:

1. read the distribution certificate from the .p12 (serial number and SHA-1, never printed in full);
2. find that certificate in App Store Connect;
3. for each bundle id reuse an active IOS_APP_STORE profile that contains it, or create one;
4. install the profiles and write `profiles.json` ({"sha1": ..., "profiles": {bundle_id: name}}).

Environment: ASC_KEY_ID, ASC_ISSUER_ID, KEY_PATH (.p8), P12_PATH, P12_PASSWORD.
Usage: python asc_profiles.py <out.json> <bundle_id> [<bundle_id> ...]
"""

from __future__ import annotations

import base64
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

import jwt
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.serialization import pkcs12

API = "https://api.appstoreconnect.apple.com"


def token() -> str:
    now = int(time.time())
    return jwt.encode(
        {"iss": os.environ["ASC_ISSUER_ID"].strip(), "iat": now, "exp": now + 900, "aud": "appstoreconnect-v1"},
        Path(os.environ["KEY_PATH"]).read_text(),
        algorithm="ES256",
        headers={"kid": os.environ["ASC_KEY_ID"].strip(), "typ": "JWT"},
    )


def call(method: str, path: str, body: dict | None = None) -> dict:
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(API + path, data=data, method=method,
                                 headers={"Authorization": "Bearer " + token(), "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        errors = json.loads(e.read() or b"{}").get("errors", [])
        sys.exit(f"HTTP {e.code} {method} {path.split('?')[0]}: " + "; ".join(f"{x.get('code')}: {x.get('detail')}" for x in errors))


def main() -> None:
    out, bundle_ids = Path(sys.argv[1]), sys.argv[2:]
    _, cert, _ = pkcs12.load_key_and_certificates(
        Path(os.environ["P12_PATH"]).read_bytes(), os.environ["P12_PASSWORD"].strip().encode())
    serial = cert.serial_number
    sha1 = cert.fingerprint(hashes.SHA1()).hex().upper()
    print("p12 sertifikası:", cert.subject.rfc4514_string().split(",")[0], "| geçerlilik sonu:", cert.not_valid_after_utc.date())

    certs = call("GET", "/v1/certificates?limit=200&fields[certificates]=serialNumber,certificateType,displayName")["data"]
    match = [c for c in certs if int(c["attributes"]["serialNumber"], 16) == serial]
    if not match:
        sys.exit("Bu .p12 sertifikası App Store Connect'te yok (iptal edilmiş ya da başka bir ekibe ait).")
    cert_id = match[0]["id"]
    print("App Store Connect sertifikası:", match[0]["attributes"]["certificateType"], cert_id)

    profiles_dir = Path.home() / "Library/MobileDevice/Provisioning Profiles"
    profiles_dir.mkdir(parents=True, exist_ok=True)
    chosen: dict[str, str] = {}
    for bid in bundle_ids:
        found = call("GET", f"/v1/bundleIds?filter[identifier]={bid}&fields[bundleIds]=identifier")["data"]
        found = [b for b in found if b["attributes"]["identifier"] == bid]
        if not found:
            sys.exit(f"Uygulama kimliği kayıtlı değil: {bid}")
        bundle_res = found[0]["id"]
        profile = None
        listed = call("GET", f"/v1/bundleIds/{bundle_res}/profiles?limit=200")["data"]
        for p in listed:
            a = p["attributes"]
            if a["profileType"] != "IOS_APP_STORE" or a["profileState"] != "ACTIVE":
                continue
            ids = {c["id"] for c in call("GET", f"/v1/profiles/{p['id']}/certificates?limit=50")["data"]}
            if cert_id in ids:
                profile = p
                break
        if profile is None:
            name = f"Lockglow AppStore {bid} {time.strftime('%Y%m%d%H%M')}"
            profile = call("POST", "/v1/profiles", {"data": {
                "type": "profiles",
                "attributes": {"name": name, "profileType": "IOS_APP_STORE"},
                "relationships": {
                    "bundleId": {"data": {"type": "bundleIds", "id": bundle_res}},
                    "certificates": {"data": [{"type": "certificates", "id": cert_id}]},
                },
            }})["data"]
            print("Yeni profil oluşturuldu:", name)
        else:
            print("Var olan profil kullanılıyor:", profile["attributes"]["name"])
        a = profile["attributes"]
        (profiles_dir / f"{a['uuid']}.mobileprovision").write_bytes(base64.b64decode(a["profileContent"]))
        chosen[bid] = a["name"]

    out.write_text(json.dumps({"sha1": sha1, "profiles": chosen}, indent=2))


if __name__ == "__main__":
    main()
