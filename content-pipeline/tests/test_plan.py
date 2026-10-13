import csv

from vocabpipe import plan as P
from vocabpipe.generate import parse_plan

HEADER = P.COLUMNS


def _csv(path, rows):
    with open(path, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=HEADER)
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, "") for k in HEADER})
    return path


def _row(lemma, pos="adj", typ="word", level="B2", topic="emotions_feelings", **kw):
    return {"lemma": lemma, "pos": pos, "type": typ, "sense_no": 1, "sense_hint": "x", "target_level": level,
            "level_source": "editorial_estimate", "primary_topic": topic, **kw}


def test_merge_dedupes_excludes_and_rejects(tmp_path, sample_entries):
    a = _csv(tmp_path / "a.csv", [
        _row("wistful"), _row("elated"),
        _row("resilient", level="C1", topic="personality"),       # örnek sette var → zaten üretilmiş
        _row("broken", pos="zz"),                                 # geçersiz pos → reddedilir
        _row("pick up", pos="phv", typ="phrasal_verb", topic="phrasal_verbs", topics="workplace_office|nope"),  # bilinmeyen kategori
    ])
    b = _csv(tmp_path / "b.csv", [_row("elated"), _row("get by", pos="phv", typ="phrasal_verb", topic="phrasal_verbs")])
    pilot = _csv(tmp_path / "pilot.csv", [_row("wistful")])  # zaten planlanmış
    dataset = tmp_path.parent / "ds.json"
    import json
    dataset.write_text(json.dumps({"schema_version": "1.0", "l1_langs": ["tr"], "entries": sample_entries}), encoding="utf-8")

    rows, report = P.merge([a, b], exclude_plans=[pilot], exclude_datasets=[dataset])
    ids = [r.card_id for r in rows]
    assert ids == ["en.elated.adj.1", "en.get_by.phv.1"]
    assert {x["lemma"] for x in report["rejected"]} == {"broken", "pick up"}
    assert any("en.elated.adj.1" in d for d in report["duplicates"])
    assert {x.split()[-1] for x in report["already_planned"]} == {"en.wistful.adj.1", "en.resilient.adj.1"}
    assert report["by_topic"]["phrasal_verbs"] == {"planned": 1, "members": 1, "mvp_target": 200}
    # Tekrar eden 'elated' atılmadı: ikinci taslağın kategorisi aynı olduğu için bir şey eklenmedi.
    assert any(d.endswith("en.elated.adj.1") for d in report["duplicates"])

    out = tmp_path / "merged.csv"
    P.write_plan(rows, out)
    reread, problems = parse_plan(out)
    assert problems == [] and [r.card_id for r in reread] == ids


def test_unreadable_row_does_not_shift_later_rows(tmp_path):
    # 2. satır okunamıyor (sense_no sayı değil) ve parse_plan onu hiç döndürmüyor;
    # sonraki satırların sorunları yanlış kelimeye yazılmamalı. 'calm' alanında satır sonu da var.
    a = _csv(tmp_path / "a.csv", [
        _row("wistful"),
        {**_row("gloomy"), "sense_no": "abc"},
        _row("calm", sense_hint="peaceful\nand quiet"),
        _row("broken", pos="zz"),
        _row("elated"),
    ])
    rows, report = P.merge([a], exclude_plans=[], exclude_datasets=[])
    assert [r.lemma for r in rows] == ["wistful", "calm", "elated"]
    assert [x["lemma"] for x in report["rejected"]] == ["broken"]
    assert any("okunamadı" in p for p in report["inputs"]["a.csv"]["general_problems"])


def test_duplicate_contributes_its_category(tmp_path):
    a = _csv(tmp_path / "a.csv", [_row("pivotal", level="C1", topic="yds_yokdil_core", exams="yds|yokdil")])
    b = _csv(tmp_path / "b.csv", [_row("pivotal", level="C1", topic="sound_smarter", exams="gre")])
    rows, report = P.merge([a, b], exclude_plans=[], exclude_datasets=[])
    assert len(rows) == 1
    r = rows[0]
    assert r.primary_topic == "yds_yokdil_core" and r.topics == ["sound_smarter"]
    assert r.exams == ["yds", "yokdil", "gre"]
    assert report["by_topic"]["yds_yokdil_core"] == {"planned": 1, "members": 1, "mvp_target": 300}
    assert report["duplicates"] == ["b.csv:2 en.pivotal.adj.1 (+sound_smarter)"]
