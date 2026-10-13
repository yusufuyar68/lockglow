"""İnsan denetimi: taslakları CSV'ye çıkar, kararları uygula, onaylananları content/cards/'a al.

    python -m vocabpipe.review export --run pilot1 --out review/pilot1.csv
    (CSV'yi Google Sheets/Excel'de aç; decision sütununa approve | reject | fix yaz)
    python -m vocabpipe.review apply  --run pilot1 --csv review/pilot1.csv --reviewer "Ayşe K."

Metin düzeltmeleri doğrudan runs/<run>/drafts/<id>.json üzerinde yapılır; 'apply' kartı yeniden
doğrular ve hatası varsa onaylamaz. Onaylanan kartlar content/cards/ altına kopyalanır; o klasör
içeriğin kalıcı kaynağıdır ve build_db oradan derler.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

from .build_db import write_json_atomic
from .generate import Run
from .validate import validate_cards

CARDS_DIR = Path(__file__).resolve().parents[2] / "content" / "cards"
EXPORT_STATUSES = {"validated", "draft"}
COLUMNS = [
    "id", "lemma", "level", "primary_topic", "def_micro", "def_short", "def_long",
    "example_en", "example_tr", "gloss_tr", "equivalence", "critic_verdict", "critic_total",
    "critic_issues", "qa_flags", "decision", "reviewer_note",
]


def export(run: Run, out: Path) -> int:
    rows = []
    for p in sorted((run.dir / "drafts").glob("*.json")):
        card = json.loads(p.read_text(encoding="utf-8"))
        meta = card["meta"]
        if meta["status"] not in EXPORT_STATUSES or "det_errors" in meta["qa_flags"]:
            continue
        critic = meta.get("critic") or {}
        tr = card["l1"]["tr"]
        rows.append({
            "id": card["id"], "lemma": card["lemma"], "level": card["level"],
            "primary_topic": card["tags"]["primary_topic"],
            "def_micro": card["def"]["micro"], "def_short": card["def"]["short"], "def_long": card["def"]["long"],
            "example_en": card["examples"][0]["en"], "example_tr": card["examples"][0]["tr"],
            "gloss_tr": tr["gloss"], "equivalence": tr["equivalence"],
            "critic_verdict": critic.get("verdict", ""), "critic_total": critic.get("total", ""),
            "critic_issues": " | ".join(f"{i['field']}: {i['problem']}" for i in critic.get("issues", [])),
            "qa_flags": " ".join(meta["qa_flags"]), "decision": "", "reviewer_note": "",
        })
    # Önce eleştirmenin geçirdikleri, sonra düzeltme isteyenler; böylece editör hızlı başlar.
    rows.sort(key=lambda r: (r["critic_verdict"] != "PASS", r["level"], r["id"]))
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w", encoding="utf-8-sig", newline="") as f:  # BOM: Excel Türkçe karakterleri doğru açsın
        w = csv.DictWriter(f, fieldnames=COLUMNS)
        w.writeheader()
        w.writerows(rows)
    return len(rows)


def apply(run: Run, csv_path: Path, reviewer: str, cards_dir: Path = CARDS_DIR) -> dict:
    decisions: dict[str, tuple[str, str]] = {}
    with open(csv_path, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f):
            d = (r.get("decision") or "").strip().lower()
            if d:
                decisions[r["id"]] = (d, (r.get("reviewer_note") or "").strip())
    bad = {k: v[0] for k, v in decisions.items() if v[0] not in {"approve", "reject", "fix"}}
    if bad:
        raise SystemExit(f"Geçersiz karar(lar): {bad}. Kullanılabilir: approve | reject | fix")

    now = datetime.now(timezone.utc).replace(microsecond=0).isoformat()
    result = {"approved": 0, "rejected": 0, "fix": 0, "blocked": []}
    for cid, (decision, note) in decisions.items():
        path = run.dir / "drafts" / f"{cid}.json"
        if not path.exists():
            result["blocked"].append(f"{cid}: taslak bulunamadı")
            continue
        card = json.loads(path.read_text(encoding="utf-8"))
        if note:
            card["meta"].setdefault("qa_flags", []).append(f"reviewer_note:{note}")
        if decision == "approve":
            _, issues = validate_cards([card])  # editör JSON'u elle düzeltmiş olabilir: tekrar doğrula
            errors = [i for i in issues if i.severity == "error"]
            if errors:
                result["blocked"].append(f"{cid}: {len(errors)} doğrulama hatası (ilk: {errors[0]})")
                continue
            card["meta"].update(status="reviewed", reviewer=reviewer, reviewed_at=now)
            write_json_atomic(cards_dir / f"{cid}.json", card)
            result["approved"] += 1
        elif decision == "reject":
            card["meta"]["status"] = "rejected"
            result["rejected"] += 1
        else:
            card["meta"]["qa_flags"].append("reviewer_fix")
            result["fix"] += 1
        write_json_atomic(path, card)
    return result


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="İnsan denetimi: CSV dışa aktar / kararları uygula")
    sub = ap.add_subparsers(dest="cmd", required=True)
    e = sub.add_parser("export")
    e.add_argument("--run", required=True)
    e.add_argument("--out", type=Path, required=True)
    a = sub.add_parser("apply")
    a.add_argument("--run", required=True)
    a.add_argument("--csv", type=Path, required=True)
    a.add_argument("--reviewer", required=True)
    args = ap.parse_args(argv)
    run = Run(args.run)
    if args.cmd == "export":
        print(json.dumps({"exported": export(run, args.out), "file": str(args.out)}, ensure_ascii=False))
    else:
        print(json.dumps(apply(run, args.csv, args.reviewer), ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
