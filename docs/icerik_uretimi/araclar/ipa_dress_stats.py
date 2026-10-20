"""Counts how the DRESS vowel is written in UK and US IPA per stream: /e/ (not part of eɪ or eə) vs /ɛ/.
Run: python -I ipa_dress_stats.py <kisisel_v1 dir> [--fix STREAM...]"""
import json
import re
import sys
from pathlib import Path

PLAIN_E = re.compile(r"e(?![ɪəʊ])")

root = Path(sys.argv[1])
fix = set(sys.argv[3:]) if len(sys.argv) > 2 and sys.argv[2] == "--fix" else set()
for stream in sorted(p for p in root.iterdir() if p.is_dir()):
    counts = {"uk_e": 0, "uk_ɛ": 0, "us_e": 0, "us_ɛ": 0}
    examples = []
    for f in sorted(stream.glob("part_*.json")):
        data = json.loads(f.read_text(encoding="utf-8"))
        changed = False
        for e in data["entries"]:
            for side in ("uk", "us"):
                ipa = (e.get("ipa") or {}).get(side)
                if not ipa:
                    continue
                if PLAIN_E.search(ipa):
                    counts[f"{side}_e"] += 1
                    if len(examples) < 6:
                        examples.append(f"{e['lemma']} {side} {ipa}")
                    if stream.name in fix:
                        e["ipa"][side] = PLAIN_E.sub("ɛ", ipa)
                        flags = e["meta"]["qa_flags"]
                        if "ipa_dress_normalized" not in flags:
                            flags.append("ipa_dress_normalized")
                        changed = True
                if "ɛ" in ipa:
                    counts[f"{side}_ɛ"] += 1
        if changed:
            f.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(stream.name, counts, "; ".join(examples))
