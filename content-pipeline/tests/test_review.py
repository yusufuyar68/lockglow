import copy
import csv
import json

from vocabpipe import review
from vocabpipe.build_db import write_json_atomic
from vocabpipe.generate import Run


def _make_run(tmp_path, sample_entries):
    run = Run("r1", tmp_path / "runs")
    by_id = {e["id"]: e for e in sample_entries}
    for cid, status in [("en.mitigate.v.1", "validated"), ("en.pragmatic.adj.1", "validated"), ("en.borrow.v.1", "rejected")]:
        card = copy.deepcopy(by_id[cid])
        card["meta"] = {"status": status, "qa_flags": [], "critic": {"verdict": "PASS", "total": 21, "issues": []}}
        write_json_atomic(run.dir / "drafts" / f"{cid}.json", card)
    return run


def test_export_then_apply(tmp_path, sample_entries):
    run = _make_run(tmp_path, sample_entries)
    out = tmp_path / "review.csv"
    assert review.export(run, out) == 2  # reddedilen dışa aktarılmaz

    rows = list(csv.DictReader(open(out, encoding="utf-8-sig")))
    for r in rows:
        r["decision"] = "approve" if r["id"] == "en.mitigate.v.1" else "reject"
    with open(out, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=review.COLUMNS)
        w.writeheader()
        w.writerows(rows)

    cards_dir = tmp_path / "cards"
    result = review.apply(run, out, "Test Editör", cards_dir=cards_dir)
    assert result == {"approved": 1, "rejected": 1, "fix": 0, "blocked": []}
    approved = json.loads((cards_dir / "en.mitigate.v.1.json").read_text(encoding="utf-8"))
    assert approved["meta"]["status"] == "reviewed" and approved["meta"]["reviewer"] == "Test Editör"
    rejected = json.loads((run.dir / "drafts" / "en.pragmatic.adj.1.json").read_text(encoding="utf-8"))
    assert rejected["meta"]["status"] == "rejected"


def test_apply_blocks_invalid_edits(tmp_path, sample_entries):
    run = _make_run(tmp_path, sample_entries)
    path = run.dir / "drafts" / "en.mitigate.v.1.json"
    card = json.loads(path.read_text(encoding="utf-8"))
    card["def"]["short"] = "mitigate it"  # editör yanlışlıkla döngüsel tanım yazdı
    write_json_atomic(path, card)
    out = tmp_path / "review.csv"
    with open(out, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=review.COLUMNS)
        w.writeheader()
        w.writerow({c: "" for c in review.COLUMNS} | {"id": "en.mitigate.v.1", "decision": "approve"})
    result = review.apply(run, out, "Ed", cards_dir=tmp_path / "cards")
    assert result["approved"] == 0 and "DEF_CIRCULAR" in result["blocked"][0]
    assert not (tmp_path / "cards" / "en.mitigate.v.1.json").exists()
