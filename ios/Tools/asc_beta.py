"""Internal TestFlight group for the account holder (CI only, used by .github/workflows/testflight_group.yml).

Idempotent:
  1. find the app by bundle id;
  2. find the internal beta group named GROUP_NAME, or create it with access to all builds
     (every later upload reaches the group without another step);
  3. add the team's account holder (an App Store Connect user, so an internal tester) unless
     already in the group.

The account holder's e-mail is masked in the log (::add-mask::) and never printed. The user
allowed creating the group and adding themself on 2026-10-21.

Environment: ASC_KEY_ID, ASC_ISSUER_ID, KEY_PATH. Reuses call() from asc_signing.py.
Usage: python asc_beta.py <bundle id> [<group name>]
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from asc_signing import ApiError, call, q  # noqa: E402


def main() -> None:
    bundle_id = sys.argv[1]
    group_name = sys.argv[2] if len(sys.argv) > 2 else "Ben"

    apps = [a for a in call("GET", f"/v1/apps?filter[bundleId]={q(bundle_id)}&fields[apps]=bundleId")["data"]
            if a["attributes"]["bundleId"] == bundle_id]
    if not apps:
        sys.exit(f"Uygulama kaydı yok: {bundle_id}")
    app_id = apps[0]["id"]

    groups = call("GET", f"/v1/apps/{app_id}/betaGroups?limit=200"
                         "&fields[betaGroups]=name,isInternalGroup,hasAccessToAllBuilds")["data"]
    group = next((g for g in groups if g["attributes"]["name"] == group_name
                  and g["attributes"].get("isInternalGroup")), None)
    if group is None:
        group = call("POST", "/v1/betaGroups", {"data": {
            "type": "betaGroups",
            "attributes": {"name": group_name, "isInternalGroup": True, "hasAccessToAllBuilds": True},
            "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
        }})["data"]
        print(f"Dahili test grubu oluşturuldu: {group_name} (bütün derlemeler)")
    else:
        print(f"Dahili test grubu zaten var: {group_name} | bütün derlemeler: "
              f"{group['attributes'].get('hasAccessToAllBuilds')}")

    holders = call("GET", "/v1/users?filter[roles]=ACCOUNT_HOLDER&limit=10"
                          "&fields[users]=username,firstName,lastName,roles")["data"]
    if not holders:
        sys.exit("Hesap sahibi bulunamadı.")
    holder = holders[0]["attributes"]
    email = holder["username"]
    print(f"::add-mask::{email}")

    testers = call("GET", f"/v1/betaGroups/{group['id']}/betaTesters?limit=200&fields[betaTesters]=email")["data"]
    if any((t["attributes"].get("email") or "").lower() == email.lower() for t in testers):
        print("Hesap sahibi zaten bu grupta test eden.")
    else:
        try:
            call("POST", "/v1/betaTesters", {"data": {
                "type": "betaTesters",
                "attributes": {"email": email, "firstName": holder.get("firstName") or "",
                               "lastName": holder.get("lastName") or ""},
                "relationships": {"betaGroups": {"data": [{"type": "betaGroups", "id": group["id"]}]}},
            }})
            print("Hesap sahibi gruba test eden olarak eklendi.")
        except ApiError as e:
            sys.exit(f"Test eden eklenemedi: {e}")

    builds = call("GET", f"/v1/builds?filter[app]={app_id}&sort=-uploadedDate&limit=3"
                         "&fields[builds]=version,processingState,expired")["data"]
    for b in builds:
        a = b["attributes"]
        print(f"build {a['version']}: {a['processingState']}{' (süresi dolmuş)' if a.get('expired') else ''}")


if __name__ == "__main__":
    main()
