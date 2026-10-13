"""Ağa çıkmadan üretim akışının testi: plan → istek → sahte batch sonuçları → taslak → eleştirmen."""

import csv
import json
import re
from types import SimpleNamespace

import pytest

from vocabpipe import generate as g
from vocabpipe.llm_schemas import CRITERIA
from vocabpipe.validate import validate_cards

PLAN_FIELDS = ["lemma", "pos", "type", "sense_no", "sense_hint", "target_level", "level_source", "primary_topic",
               "topics", "exams", "zipf", "freq_rank", "ipa_us_ref", "ipa_uk_ref", "confusables", "notes"]


@pytest.fixture
def gold(sample_entries):
    by_id = {e["id"]: e for e in sample_entries}
    return [by_id["en.mitigate.v.1"], by_id["en.look_up_to.phv.1"]]


@pytest.fixture
def run(tmp_path, gold):
    plan = tmp_path / "plan.csv"
    with open(plan, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=PLAN_FIELDS)
        w.writeheader()
        for c in gold:
            w.writerow({
                "lemma": c["lemma"], "pos": c["pos"], "type": c["type"], "sense_no": 1,
                "sense_hint": c.get("sense_note") or "", "target_level": c["level"], "level_source": "editorial_estimate",
                "primary_topic": c["tags"]["primary_topic"], "topics": "|".join(c["tags"]["topics"][1:]),
                "exams": "|".join(c["tags"]["exams"]), "zipf": (c["freq"] or {}).get("zipf") or "",
                "freq_rank": (c["freq"] or {}).get("rank") or "", "ipa_us_ref": c["ipa"]["us"],
                "ipa_uk_ref": c["ipa"]["uk"], "confusables": "", "notes": "",
            })
    return g.prepare(plan, "t1", root=tmp_path / "runs")


def _stage_a_output(c):
    return {
        "skip_reason": None, "sense_note": c["sense_note"], "level": c["level"], "level_confidence": "high",
        "ipa": c["ipa"], "def": c["def"], "grammar_pattern": (c.get("grammar") or {}).get("pattern"),
        "examples": [{"en": e["en"], "register": e["register"], "focus": e["focus"]} for e in c["examples"]],
        "synonyms": c["synonyms"], "antonyms": c["antonyms"], "collocations": c["collocations"],
        "word_family": c["word_family"], "etymology": c["etymology"], "extra_topics": [],
        "register": c["tags"]["register"], "vibes": c["tags"]["vibes"], "flags": c["tags"]["flags"],
        "sensitivity": c["tags"]["sensitivity"], "quiz": c["quiz"], "uncertain_fields": [],
    }


def _stage_b_output(c):
    tr = c["l1"]["tr"]
    return {**{k: tr[k] for k in ("gloss", "alt", "equivalence", "false_friend", "note", "mistakes", "mnemonic")},
            "examples_tr": [e["tr"] for e in c["examples"]], "backtranslation": [], "uncertain_fields": []}


def _stage_c_output(score=2, verdict="PASS"):
    return {"scores": {k: {"score": score, "reason": "ok"} for k in CRITERIA}, "verdict": verdict, "issues": []}


def _msg(data=None, stop_reason="end_turn"):
    content = [] if data is None else [SimpleNamespace(type="text", text=json.dumps(data, ensure_ascii=False))]
    return SimpleNamespace(stop_reason=stop_reason, content=content, stop_details=None)


def _result(custom_id, message=None, rtype="succeeded"):
    return SimpleNamespace(custom_id=custom_id, result=SimpleNamespace(type=rtype, message=message, error=None))


def _fake_submit(run, stage):
    """Ağa çıkmadan 'gönderildi' durumuna getirir; custom_id eşlemesini gerçek koddan alır."""
    reqs = g.build_requests(run, stage, g.DEFAULT_MODEL, g.DEFAULT_EFFORT)
    state = run.load_state()
    state["stages"][stage] = {"open_batches": ["fake"], "custom_ids": {cu: cid for cu, cid, _ in reqs},
                              "model": g.DEFAULT_MODEL, "effort": g.DEFAULT_EFFORT}
    run.save_state(state)
    return reqs


def test_dry_run_requests_are_well_formed(run):
    result = g.submit(run, "a", model=g.DEFAULT_MODEL, effort="medium", dry_run=True)
    assert result["requests"] == 2 and result["approx_cost_usd_upper_bound"] is not None
    lines = [json.loads(x) for x in (run.dir / "requests_a.jsonl").read_text(encoding="utf-8").splitlines()]
    for line in lines:
        assert re.fullmatch(r"[A-Za-z0-9_-]{1,64}", line["custom_id"])
        p = line["params"]
        assert p["model"] == "claude-opus-5-5"
        assert p["system"][0]["cache_control"] == {"type": "ephemeral"}
        assert p["output_config"]["format"]["type"] == "json_schema"
        assert p["output_config"]["effort"] == "medium"
        assert "thinking" not in p  # Opus 5.5'te düşünme kapatılamaz; parametre gönderilmez
    # Sistem metni tüm isteklerde bayt bayt aynı olmalı (prompt cache).
    assert len({json.dumps(line["params"]["system"]) for line in lines}) == 1


def test_full_pipeline_with_fake_batches(run, gold):
    by_lemma = {c["lemma"]: c for c in gold}

    reqs = _fake_submit(run, "a")
    g.process_results(run, "a", [_result(cu, _msg(_stage_a_output(by_lemma[cid.split(".")[1].replace("_", " ")])))
                                 for cu, cid, _ in reqs])
    reqs = _fake_submit(run, "b")
    assert len(reqs) == 2
    counts = g.process_results(run, "b", [_result(cu, _msg(_stage_b_output(by_lemma[cid.split(".")[1].replace("_", " ")])))
                                          for cu, cid, _ in reqs])
    assert counts["validation"]["with_errors"] == 0

    drafts = [json.loads(p.read_text(encoding="utf-8")) for p in sorted((run.dir / "drafts").glob("*.json"))]
    cards, issues = validate_cards(drafts)
    assert len(cards) == 2 and not [i for i in issues if i.severity == "error"]
    assert all(d["meta"]["status"] == "draft" for d in drafts)

    reqs = _fake_submit(run, "c")
    g.process_results(run, "c", [_result(reqs[0][0], _msg(_stage_c_output())),
                                 _result(reqs[1][0], _msg(_stage_c_output(score=1, verdict="PASS")))])
    statuses = {json.loads(p.read_text(encoding="utf-8"))["id"]: json.loads(p.read_text(encoding="utf-8"))["meta"]
                for p in (run.dir / "drafts").glob("*.json")}
    first, second = reqs[0][1], reqs[1][1]
    assert statuses[first]["status"] == "validated"
    # Model PASS dese de toplam 11/22 < 18 → kural FIX der; katı olan uygulanır.
    assert statuses[second]["status"] == "draft" and "critic_fix" in statuses[second]["qa_flags"]
    assert statuses[second]["critic"]["model_verdict"] == "PASS" and statuses[second]["critic"]["verdict"] == "FIX"


def test_refusal_and_truncation_are_logged_not_crashing(run, gold):
    reqs = _fake_submit(run, "a")
    g.process_results(run, "a", [_result(reqs[0][0], _msg(None, stop_reason="refusal")),
                                 _result(reqs[1][0], _msg(None, stop_reason="max_tokens"))])
    fails = [json.loads(x) for x in (run.dir / "failures.jsonl").read_text(encoding="utf-8").splitlines()]
    assert {f["reason"] for f in fails} == {"refusal", "max_tokens"}
    assert g.build_requests(run, "b", g.DEFAULT_MODEL, "medium") == []  # A başarısızsa B'ye gitmez


def test_completed_cards_are_not_resubmitted(run, gold):
    by_lemma = {c["lemma"]: c for c in gold}
    reqs = _fake_submit(run, "a")
    cu, cid, _ = reqs[0]
    g.process_results(run, "a", [_result(cu, _msg(_stage_a_output(by_lemma[cid.split(".")[1].replace("_", " ")])))])
    again = g.build_requests(run, "a", g.DEFAULT_MODEL, "medium")
    assert [c for _, c, _ in again] == [reqs[1][1]]


def test_plan_errors_are_reported(tmp_path):
    plan = tmp_path / "bad.csv"
    plan.write_text("lemma,pos,target_level,primary_topic\nfoo,zz,Q1,nope\n", encoding="utf-8")
    with pytest.raises(SystemExit) as e:
        g.prepare(plan, "bad", root=tmp_path / "runs")
    msg = str(e.value)
    assert "geçersiz pos" in msg and "geçersiz seviye" in msg and "bilinmeyen kategori" in msg
