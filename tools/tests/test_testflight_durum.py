import copy, importlib.util, json, unittest, contextlib, io, sys, tempfile, types
from unittest.mock import patch
from pathlib import Path
from urllib.parse import quote
spec = importlib.util.spec_from_file_location("durum", Path(__file__).resolve().parents[1] / "testflight_durum.py")
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

class AvailabilityTests(unittest.TestCase):
    def setUp(self):
        self.calls = []
        self.routes = {
            "/v1/apps": [{"id": "app", "attributes": {"bundleId": m.BUNDLE}}],
            "/v1/builds": [{"id": "b40", "type": "builds", "attributes":
                           {"version": "40", "processingState": "VALID", "expired": False}}],
            "/v1/builds/b40/buildBetaDetail": {"attributes": {"internalBuildState": "READY_FOR_BETA_TESTING"}},
            "/v1/builds/b40/preReleaseVersion": {"attributes": {"version": "0.1.0"}},
            "/v1/apps/app/betaGroups": [{"id": "group", "attributes":
                                      {"name": "Ben", "isInternalGroup": True, "hasAccessToAllBuilds": True}}],
            "/v1/users": [{"id": "PRIVATE_USER", "attributes": {"roles": ["ACCOUNT_HOLDER"], "username": "holder@test.invalid"}}],
            "/v1/betaGroups/group/betaTesters": [{"attributes": {"email": "HOLDER@test.invalid"}}],
            "/v1/betaGroups/group/builds": [{"id": "b40"}],
        }
    def get(self, path):
        self.calls.append(path)
        return {"data": copy.deepcopy(self.routes[path.split("?")[0]])}
    def check(self):
        status = {}
        m.verify("40", self.get, lambda x: quote(x, safe=""), status)
        return status
    def test_ready_existing_member_without_personal_output(self):
        self.routes["/v1/builds"].append({"id": "other", "type": "builds", "attributes": {"version": "40"}})
        self.routes["/v1/builds/other/preReleaseVersion"] = {"attributes": {"version": "9.9.9"}}
        status = self.check()
        self.assertTrue(status["verified"] and status["group_build_listed"])
        self.assertNotIn("holder@", json.dumps(status).lower())
        self.assertNotIn("PRIVATE_USER", json.dumps(status))
    def test_exact_build_relationship_is_required_without_all_build_access(self):
        self.routes["/v1/apps/app/betaGroups"][0]["attributes"]["hasAccessToAllBuilds"] = False
        self.assertTrue(self.check()["group_access"])
        self.routes["/v1/betaGroups/group/builds"] = [{"id": "b39"}]
        with self.assertRaises(RuntimeError): self.check()
    def test_all_builds_flag_does_not_hide_pending_group_propagation(self):
        self.routes["/v1/betaGroups/group/builds"] = [{"id": "b39"}]
        with self.assertRaises(RuntimeError): self.check()
    def test_not_ready_wrong_build_expired_and_missing_member_fail(self):
        for route, key, value in [("/v1/builds", "version", "39"), ("/v1/builds", "expired", True),
                                  ("/v1/builds/b40/preReleaseVersion", "version", "9.9.9"),
                                  ("/v1/builds", "processingState", "PROCESSING"),
                                  ("/v1/builds/b40/buildBetaDetail", "internalBuildState", "MISSING_EXPORT_COMPLIANCE")]:
            original = copy.deepcopy(self.routes)
            record = self.routes[route]
            (record[0] if isinstance(record, list) else record)["attributes"][key] = value
            with self.assertRaises(RuntimeError): self.check()
            self.routes = original
        self.routes["/v1/betaGroups/group/betaTesters"] = []
        with self.assertRaises(RuntimeError): self.check()
    def test_pagination_accepts_apple_and_rejects_foreign_host(self):
        pages = iter([{"data": [], "links": {"next": "https://api.appstoreconnect.apple.com/v1/builds?cursor=2"}}, {"data": [{"id": "b40"}]}]); self.assertEqual(m.records("/v1/builds", lambda _: next(pages)), [{"id": "b40"}])
        calls = []
        def get(path):
            calls.append(path)
            return {"data": [], "links": {"next": "https://foreign.invalid/v1/users"}}
        with self.assertRaises(RuntimeError): m.records("/v1/users", get)
        self.assertEqual(calls, ["/v1/users"])
    def test_http_failure_is_not_success(self):
        def denied(method, path):
            self.assertEqual(method, "GET")
            raise RuntimeError("HTTP 401 holder@test.invalid PRIVATE_USER")
        with tempfile.TemporaryDirectory() as folder:
            output = Path(folder) / "status.json"
            args = ["check", "--build-number", "40", "--output", str(output)]
            signing = types.SimpleNamespace(call=denied, q=quote)
            error = io.StringIO()
            with patch.dict(sys.modules, {"asc_signing": signing}), patch.object(sys, "argv", args), contextlib.redirect_stderr(error):
                self.assertEqual(m.main(), 1)
            self.assertFalse(json.loads(output.read_text())["verified"])
            self.assertNotIn("holder@", output.read_text() + error.getvalue())
            self.assertNotIn("PRIVATE_USER", output.read_text() + error.getvalue())
