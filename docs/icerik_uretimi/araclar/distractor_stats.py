"""How often each quiz distractor repeats inside a stream. Run: python -I distractor_stats.py <kisisel_v1 dir>"""
import json
import sys
from collections import Counter
from pathlib import Path

root = Path(sys.argv[1])
for stream in sorted(p for p in root.iterdir() if p.is_dir()):
    counts: Counter = Counter()
    cards = 0
    for f in sorted(stream.glob("part_*.json")):
        for e in json.loads(f.read_text(encoding="utf-8"))["entries"]:
            quiz = e.get("quiz")
            if quiz:
                cards += 1
                counts.update(d.lower() for d in quiz["distractors"])
    top = ", ".join(f"{d}×{n}" for d, n in counts.most_common(6))
    print(f"{stream.name}: {cards} quizzes, {len(counts)} distinct distractors; top: {top}")
