"""Turns a copy of VocabKit into a package that builds on Linux (used by linux_check.sh).

- drops the GRDB-backed ContentStore target and its tests (GRDB needs SQLite headers);
- adds stub modules for Apple-only frameworks (Combine, os, WidgetKit) and a ContentStore stub
  with the same public signatures (checked: the run stops if the stub's public declarations differ
  from the real module's, because the app logic is type-checked against the stub);
- adds an `AppLogic` target with the app's non-UI files, so their calls into the package
  are type-checked against the real APIs;
- guards the one Apple-only call in SharedState (App Group container lookup).

Usage: python linux_check_prepare.py <copy of VocabKit> <ios/App> <ios/Tools/linux-stubs>
"""

import re
import shutil
import sys
from pathlib import Path

APP_LOGIC_FILES = ["AppModel.swift", "AppModel+Progress.swift", "AppModel+CustomWords.swift", "AppModel+Sozluk.swift", "WeeklyRecapModel.swift", "CustomWordLibrary.swift", "AppPreferences.swift", "ContentLoader.swift", "ReviewSession.swift", "WidgetHealth.swift"]
STUBS = ["Combine", "os", "WidgetKit", "ContentStore"]

# A declaration that starts with `public` or `open`, after optional attributes such as @discardableResult.
PUBLIC_DECL = re.compile(r"^(?:@\w+(?:\([^)]*\))?\s+)*(?:public|open)\b")


def public_api(folder: Path) -> list[str]:
    """The `public`/`open` declarations of the Swift files in `folder`, sorted: comments and bodies
    removed, multi-line signatures joined, whitespace collapsed."""
    decls = []
    for path in sorted(folder.glob("*.swift")):
        current = None
        for raw in path.read_text(encoding="utf-8").splitlines():
            line = re.sub(r"(^|\s)//.*$", "", raw).strip()
            if current is None:
                if not PUBLIC_DECL.match(line):
                    continue
                current = line
            else:
                current += " " + line
            balanced = current.count("(") == current.count(")")
            if "{" in current or (balanced and not current.endswith((",", "(", "->"))):
                decls.append(" ".join(current.split("{", 1)[0].split()))
                current = None
    return sorted(decls)


def check_stub_api(real: Path, stub: Path) -> None:
    real_api, stub_api = public_api(real), public_api(stub)
    if not real_api:
        raise SystemExit(f"no public declarations found in {real}: update linux_check_prepare.py")
    if real_api != stub_api:
        lines = [f"{stub} does not match the public API of {real}; update the stub:"]
        lines += [f"  only in the real module: {d}" for d in real_api if d not in stub_api]
        lines += [f"  only in the stub:        {d}" for d in stub_api if d not in real_api]
        raise SystemExit("\n".join(lines))


def main() -> int:
    pkg, app, stubs = (Path(a) for a in sys.argv[1:4])

    check_stub_api(pkg / "Sources" / "ContentStore", stubs / "ContentStore")
    shutil.rmtree(pkg / "Sources" / "ContentStore", ignore_errors=True)
    shutil.rmtree(pkg / "Tests" / "ContentStoreTests", ignore_errors=True)

    manifest = pkg / "Package.swift"
    s = manifest.read_text(encoding="utf-8")
    s = s.replace('        .library(name: "ContentStore", type: .static, targets: ["ContentStore"]),\n', "")
    s = re.sub(r"    dependencies: \[\n        \.package\(url: \"https://github\.com/groue/GRDB\.swift\.git\".*?\n    \],\n", "", s, flags=re.S)
    s = re.sub(r'        \.target\(\n            name: "ContentStore",.*?\n        \),\n', "", s, flags=re.S)
    s = re.sub(r'        \.testTarget\(\n            name: "ContentStoreTests",.*?\n        \),\n', "", s, flags=re.S)
    if "GRDB" in s or "ContentStore" in s:
        raise SystemExit("Package.swift changed shape: update linux_check_prepare.py")
    anchor = '        .testTarget(name: "CoreModelsTests"'
    extra = (
        '        .target(name: "Combine"),\n'
        '        .target(name: "os"),\n'
        '        .target(name: "WidgetKit"),\n'
        '        .target(name: "ContentStore", dependencies: ["CoreModels"]),\n'
        '        .target(name: "AppLogic", dependencies: ["Combine", "os", "WidgetKit", "ContentStore", '
        '"CoreModels", "SharedState", "Scheduler", "Learning", "TextFold"]),\n'
    )
    if s.count(anchor) != 1:
        raise SystemExit("CoreModelsTests target not found in Package.swift")
    manifest.write_text(s.replace(anchor, extra + anchor), encoding="utf-8")

    for name in STUBS:
        target = pkg / "Sources" / name
        target.mkdir(parents=True, exist_ok=True)
        for f in (stubs / name).glob("*.swift"):
            shutil.copy(f, target / f.name)
    logic = pkg / "Sources" / "AppLogic"
    logic.mkdir(parents=True, exist_ok=True)
    for name in APP_LOGIC_FILES:
        shutil.copy(app / name, logic / name)

    locator = pkg / "Sources" / "SharedState" / "AppGroupLocator.swift"
    t = locator.read_text(encoding="utf-8")
    call = "        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)\n"
    if t.count(call) != 1:
        raise SystemExit("AppGroupLocator changed shape: update linux_check_prepare.py")
    locator.write_text(t.replace(call, "        #if os(Linux)\n        _ = identifier\n        return nil\n        #else\n" + call + "        #endif\n"), encoding="utf-8")
    print(f"prepared {pkg}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
