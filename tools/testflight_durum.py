"""GET-only availability check for an existing internal TestFlight build."""
import argparse, json, re, sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlsplit

BUNDLE = "com.yusufuyar.vocabwidget"
READY = {"READY_FOR_BETA_TESTING", "IN_BETA_TESTING"}

def need(value):
    if not value: raise RuntimeError("Availability not verified")

def records(path, get):
    rows, seen = [], set()
    while path:
        url = urlsplit(path)
        need(not url.fragment and (not url.scheme and not url.netloc or
             url.scheme == "https" and url.netloc == "api.appstoreconnect.apple.com"))
        path = url.path + ("?" + url.query if url.query else "")
        need(path.startswith("/v1/") and path not in seen and len(seen) < 20)
        seen.add(path)
        page = get(path)
        rows.extend(page["data"])
        path = page.get("links", {}).get("next")
    return rows

def verify(number, get, q, status):
    need(re.fullmatch(r"[1-9][0-9]*", number))
    apps = [a for a in records("/v1/apps?filter[bundleId]=" + q(BUNDLE) +
            "&fields[apps]=bundleId&limit=200", get) if a["attributes"]["bundleId"] == BUNDLE]
    need(len(apps) == 1)
    app = q(apps[0]["id"])
    status["app_found"] = True
    builds = [b for b in records("/v1/builds?filter[app]=" + app + "&filter[version]=" + q(number) +
              "&fields[builds]=version,processingState,expired,uploadedDate&limit=200", get)
              if b["attributes"]["version"] == number]
    builds = [b for b in builds if b.get("type") == "builds" and
              get("/v1/builds/" + q(b["id"]) + "/preReleaseVersion")["data"]["attributes"].get("version") == "0.1.0"]
    need(len(builds) == 1)
    build, attrs = builds[0]["id"], builds[0]["attributes"]
    status.update(build_found=True, build_id=build, marketing_version="0.1.0", uploaded_at=attrs.get("uploadedDate", ""))
    processing = attrs.get("processingState")
    status["processing_state"] = processing if processing in {"VALID", "PROCESSING", "FAILED", "INVALID"} else "UNKNOWN"
    status["build_valid"], status["not_expired"] = processing == "VALID", attrs.get("expired") is False
    need(status["build_valid"] and status["not_expired"])
    detail = get("/v1/builds/" + q(build) + "/buildBetaDetail")["data"]["attributes"]
    internal = detail.get("internalBuildState")
    status["internal_build_state"] = internal if internal in READY | {"PROCESSING", "MISSING_EXPORT_COMPLIANCE"} else "UNKNOWN"
    status["internal_ready"] = internal in READY
    need(status["internal_ready"])
    groups = [g for g in records("/v1/apps/" + app + "/betaGroups?limit=200" +
              "&fields[betaGroups]=name,isInternalGroup,hasAccessToAllBuilds", get)
              if g["attributes"]["name"] == "Ben" and g["attributes"].get("isInternalGroup") is True]
    need(len(groups) == 1)
    group = groups[0]
    status["group_internal"] = True
    status["all_builds_access"] = group["attributes"].get("hasAccessToAllBuilds") is True
    status["group_build_listed"] = any(b["id"] == build for b in
        records("/v1/betaGroups/" + q(group["id"]) + "/builds?limit=200&fields[builds]=version", get))
    # Verify the requested build is actually in this group's list, including when the
    # group normally inherits all builds; propagation may still be in progress.
    status["group_access"] = status["group_build_listed"]
    need(status["group_access"])
    holders = [u for u in records("/v1/users?filter[roles]=ACCOUNT_HOLDER&limit=200" +
               "&fields[users]=username,roles", get) if "ACCOUNT_HOLDER" in u["attributes"].get("roles", [])]
    need(len(holders) == 1)
    email = holders[0]["attributes"]["username"].strip().casefold()
    need(email)
    status["member_present"] = any((t["attributes"].get("email") or "").strip().casefold() == email for t in
        records("/v1/betaGroups/" + q(group["id"]) + "/betaTesters?limit=200&fields[betaTesters]=email", get))
    need(status["member_present"])
    status["verified"] = True

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--build-number", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    status = dict.fromkeys(["verified", "app_found", "build_found", "build_valid", "not_expired",
                           "internal_ready", "group_internal", "all_builds_access", "group_build_listed", "group_access", "member_present"], False)
    status.update(app_bundle_id=BUNDLE, group_name="Ben", build_number=args.build_number
                  if re.fullmatch(r"[1-9][0-9]*", args.build_number) else "",
                  checked_at=datetime.now(timezone.utc).isoformat())
    result = 1
    try:
        sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "ios" / "Tools"))
        from asc_signing import call, q
        verify(args.build_number, lambda path: call("GET", path), q, status)
        result = 0
    except Exception as error:
        status["error_type"] = type(error).__name__
        http_status = getattr(error, "status", None)
        if isinstance(http_status, int) and 0 <= http_status <= 599:
            status["http_status"] = http_status
        print("TestFlight availability was not verified.", file=sys.stderr)
    finally:
        Path(args.output).write_text(json.dumps(status, indent=2) + "\n", encoding="utf-8")
    return result

if __name__ == "__main__":
    sys.exit(main())
