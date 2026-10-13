"""Plan CSV'lerini birleştirir: doğrular, tekrarları ve zaten planlanmış kelimeleri ayıklar, rapor verir.

    python -m vocabpipe.plan merge taslak1.csv taslak2.csv \
        --exclude plans/pilot_50.csv --exclude-dataset ../veri/ornek_kelime_seti_25.json \
        --out plans/batch1_hero.csv

Hatalı satırlar birleşik dosyaya alınmaz, raporda listelenir. Aynı kart (lemma+pos+anlam no)
birden fazla taslakta varsa ilk görülen tutulur.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from collections import Counter
from dataclasses import asdict
from pathlib import Path

from .generate import PlanRow, parse_plan, parse_plan_records
from .taxonomy import load_taxonomy
from .validate import load_raw_cards

COLUMNS = ["lemma", "pos", "type", "sense_no", "sense_hint", "target_level", "level_source", "primary_topic",
           "topics", "exams", "zipf", "freq_rank", "ipa_us_ref", "ipa_uk_ref", "confusables", "notes"]
LEVEL_ORDER = ["A1", "A2", "B1", "B2", "C1", "C2", "S"]


def existing_ids(plan_paths: list[Path], dataset_paths: list[Path]) -> set[str]:
    ids: set[str] = set()
    for p in plan_paths:
        rows, _ = parse_plan(p)
        ids.update(r.card_id for r in rows)
    for p in dataset_paths:
        raws, _ = load_raw_cards(p)
        ids.update(r["id"] for r in raws if "id" in r)
    return ids


MAX_EXTRA_TOPICS = 3  # birincil + 3 = kartta en fazla 4 kategori (validate.COUNT_LIMITS["topics"])


def _absorb(kept: PlanRow, dup: PlanRow) -> list[str]:
    """Tekrar eden satırın kategori ve sınav etiketlerini tutulan satıra ekler; eklenen kategorileri döndürür."""
    added: list[str] = []
    for t in [dup.primary_topic, *dup.topics]:
        if t != kept.primary_topic and t not in kept.topics and len(kept.topics) < MAX_EXTRA_TOPICS:
            kept.topics.append(t)
            added.append(t)
    for e in dup.exams:
        if e not in kept.exams:
            kept.exams.append(e)
    return added


def merge(inputs: list[Path], *, exclude_plans: list[Path], exclude_datasets: list[Path]) -> tuple[list[PlanRow], dict]:
    taken = existing_ids(exclude_plans, exclude_datasets)
    merged: list[PlanRow] = []
    by_id: dict[str, PlanRow] = {}
    report: dict = {"inputs": {}, "rejected": [], "duplicates": [], "already_planned": []}
    for path in inputs:
        numbered, by_line, general = parse_plan_records(path)
        kept = 0
        for line, row in numbered:
            if line in by_line:
                report["rejected"].append({"file": path.name, "line": line, "lemma": row.lemma, "problems": by_line[line]})
                continue
            if row.card_id in taken:
                report["already_planned"].append(f"{path.name}:{line} {row.card_id}")
                continue
            if row.card_id in by_id:
                # Aynı kart (tek anlam) iki taslakta: ilki tutulur, ikincisinin kategorisi ve sınav
                # etiketleri ona eklenir. Kart böylece iki kategoride de görünür.
                added = _absorb(by_id[row.card_id], row)
                report["duplicates"].append(f"{path.name}:{line} {row.card_id}" + (f" (+{','.join(added)})" if added else ""))
                continue
            by_id[row.card_id] = row
            merged.append(row)
            kept += 1
        report["inputs"][path.name] = {"rows": len(numbered), "kept": kept, "general_problems": general}

    tax = load_taxonomy()
    by_topic = Counter(r.primary_topic for r in merged)
    membership = Counter(t for r in merged for t in {r.primary_topic, *r.topics})
    report["by_topic"] = {
        t: {"planned": n, "members": membership[t], "mvp_target": tax.categories[t].mvp}
        for t, n in sorted(by_topic.items())
    }
    report["by_level"] = {lv: n for lv, n in sorted(Counter(r.target_level for r in merged).items(),
                                                   key=lambda kv: LEVEL_ORDER.index(kv[0]))}
    report["by_type"] = dict(Counter(r.type for r in merged))
    report["total"] = len(merged)
    return merged, report


def write_plan(rows: list[PlanRow], out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNS)
        w.writeheader()
        for r in rows:
            d = asdict(r)
            d["topics"] = "|".join(d["topics"])
            d["exams"] = "|".join(d["exams"])
            d["confusables"] = "|".join(d["confusables"])
            for k in ("zipf", "freq_rank", "ipa_us_ref", "ipa_uk_ref"):
                d[k] = "" if d[k] is None else d[k]
            w.writerow({k: d[k] for k in COLUMNS})


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Plan CSV'lerini birleştir ve doğrula")
    sub = ap.add_subparsers(dest="cmd", required=True)
    m = sub.add_parser("merge")
    m.add_argument("inputs", nargs="+", type=Path)
    m.add_argument("--exclude", action="append", type=Path, default=[], help="zaten planlanmış plan CSV'leri")
    m.add_argument("--exclude-dataset", action="append", type=Path, default=[], help="zaten üretilmiş kart dosyaları/klasörleri")
    m.add_argument("--out", type=Path, required=True)
    m.add_argument("--report", type=Path, help="raporu JSON olarak da yaz")
    args = ap.parse_args(argv)

    rows, report = merge(args.inputs, exclude_plans=args.exclude, exclude_datasets=args.exclude_dataset)
    write_plan(rows, args.out)
    # Yazılan dosya, üretimin kullanacağı okuyucudan hatasız geçmeli.
    _, problems = parse_plan(args.out)
    report["output_problems"] = problems
    text = json.dumps(report, ensure_ascii=False, indent=1)
    if args.report:
        args.report.write_text(text + "\n", encoding="utf-8")
    print(text)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
