"""Read word 1's progress from a disposable simulator; never modify the app container."""
import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path


def capture(container: Path) -> dict:
    result = {"captured_at": datetime.now(timezone.utc).isoformat(), "files": {}}
    support = container / "Library" / "Application Support"
    for name in ("progress.json", "progress.backup.json"):
        path = support / name
        info = {"exists": path.is_file()}
        result["files"][name] = info
        if not info["exists"]:
            continue
        try:
            data = path.read_bytes()
            info.update(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
            if len(data) > 32 * 1024 * 1024:
                info["error"] = "progress exceeds diagnostic read limit"
                continue
            rows = json.loads(data)
            if not isinstance(rows, list):
                info["error"] = "expected the existing progress-array format"
                continue
            info["record_count"] = len(rows)
            info["word_1"] = next((row for row in rows if isinstance(row, dict) and row.get("word_id") == 1), None)
        except (OSError, ValueError) as error:
            info["error"] = str(error)
    return result


if __name__ == "__main__":
    print(json.dumps(capture(Path(sys.argv[1])), ensure_ascii=False, indent=2))
