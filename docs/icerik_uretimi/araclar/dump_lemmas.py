import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
out = Path(sys.argv[2])
lines = []
total = 0
for stream in sorted(p for p in root.iterdir() if p.is_dir()):
    items = []
    for f in sorted(stream.glob("part_*.json")):
        for e in json.loads(f.read_text(encoding="utf-8"))["entries"]:
            items.append(f"{e['lemma']} ({e['pos']}, {e['level']})")
    total += len(items)
    lines.append(f"## {stream.name} ({len(items)})")
    lines.append(", ".join(items))
    lines.append("")
lines.insert(0, f"# Existing kisisel_v1 headwords: {total}\n")
out.write_text("\n".join(lines), encoding="utf-8")
print(total)
