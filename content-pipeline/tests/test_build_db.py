import copy
import json
import sqlite3

import pytest

from vocabpipe.build_db import BuildError, run
from vocabpipe.textutil import fold


def _write_dataset(path, entries):
    path.write_text(json.dumps({"schema_version": "1.0", "l1_langs": ["tr"], "entries": entries}, ensure_ascii=False), encoding="utf-8")
    return path


def _build(tmp_path, entries, *, registry=None, name="ds.json"):
    ds = _write_dataset(tmp_path / name, entries)
    registry = registry or tmp_path / "id_registry.json"
    return run(
        [ds],
        out=tmp_path / "content.sqlite",
        seed_out=tmp_path / "seed_words.json",
        registry_path=registry,
        include_status={"sample"},
        content_version="test-1",
    )


def _search(con, query):
    match = " ".join(f'"{t}"*' for t in fold(query).split())
    sql = "SELECT card.lemma FROM card_fts JOIN card ON card.rowid = card_fts.rowid WHERE card_fts MATCH ?"
    return [r[0] for r in con.execute(sql, (match,))]


def test_build_sample(tmp_path, sample_entries):
    result = _build(tmp_path, sample_entries)
    assert result["cards"] == 25 and result["new_ids"] == 25
    db_path = tmp_path / "content.sqlite"
    # Uygulamanın yaptığı gibi salt okunur aç: WAL yan dosyası olmamalı, açılış başarılı olmalı.
    ro = sqlite3.connect(f"file:{db_path.as_posix()}?mode=ro", uri=True)
    assert ro.execute("PRAGMA journal_mode").fetchone()[0] == "delete"
    assert ro.execute("SELECT count(*) FROM card").fetchone()[0] == 25
    ro.close()
    assert not db_path.with_name("content.sqlite-wal").exists()
    con = sqlite3.connect(db_path)
    assert con.execute("PRAGMA user_version").fetchone()[0] == 2
    assert con.execute("SELECT count(*) FROM card").fetchone()[0] == 25
    assert con.execute("SELECT count(*) FROM category").fetchone()[0] == 60
    assert con.execute("SELECT count(*) FROM card_l1 WHERE lang='tr'").fetchone()[0] == 25
    # Her kartın tam JSON'u şemayla geri okunabilir olmalı.
    from vocabpipe.schema import Card

    for (blob,) in con.execute("SELECT json FROM card"):
        Card.model_validate(json.loads(blob))
    meta = dict(con.execute("SELECT key, value FROM content_meta"))
    assert meta["content_version"] == "test-1" and meta["card_count"] == "25"


@pytest.mark.parametrize(
    "query,lemma",
    [("DİRENÇLİ", "resilient"), ("direncli", "resilient"), ("hâlsiz", "enervate"), ("kahvalti", "breakfast"),
     ("Look Up", "look up to"), ("resil", "resilient")],
)
def test_turkish_and_prefix_search(tmp_path, sample_entries, query, lemma):
    _build(tmp_path, sample_entries)
    con = sqlite3.connect(tmp_path / "content.sqlite")
    assert lemma in _search(con, query)


def test_ids_are_stable_across_builds(tmp_path, sample_entries):
    _build(tmp_path, sample_entries[:10])
    first = json.loads((tmp_path / "id_registry.json").read_text(encoding="utf-8"))["ids"]
    _build(tmp_path, sample_entries)  # 15 yeni kart eklendi
    second = json.loads((tmp_path / "id_registry.json").read_text(encoding="utf-8"))["ids"]
    assert {k: second[k] for k in first} == first
    assert len(set(second.values())) == 25
    # Kart çıkarılsa da kayıt korunur, ID başkasına verilmez.
    _build(tmp_path, sample_entries[5:])
    third = json.loads((tmp_path / "id_registry.json").read_text(encoding="utf-8"))
    assert third["ids"] == second and third["next_id"] == 26


def test_registry_not_touched_when_validation_fails(tmp_path, sample_entries):
    bad = copy.deepcopy(sample_entries[0])
    bad["def"]["short"] = bad["lemma"] + " in the morning"
    with pytest.raises(BuildError):
        _build(tmp_path, [bad])
    assert not (tmp_path / "id_registry.json").exists()
    assert not (tmp_path / "content.sqlite").exists()


def _clone(base, n, topic, level):
    out = []
    for i in range(n):
        c = copy.deepcopy(base)
        lemma = f"testword{chr(97 + i // 26)}{chr(97 + i % 26)}"
        c["id"], c["lemma"], c["level"] = f"en.{lemma}.adj.1", lemma, level
        c["tags"]["primary_topic"], c["tags"]["topics"], c["tags"]["exams"] = topic, [topic], []
        c["freq"] = {"rank": 1000 + i, "zipf": None}
        c["examples"] = [
            {"en": f"It was a {lemma} morning.", "tr": "Güzel bir sabahtı.", "register": "neutral", "focus": lemma},
            {"en": f"She gave a {lemma} answer.", "tr": "Güzel bir cevap verdi.", "register": "neutral", "focus": lemma},
        ]
        c["quiz"] = {"cloze": "It was a ______ day.", "answer": lemma, "distractors": ["red", "big", "old"]}
        c["synonyms"], c["antonyms"], c["collocations"] = [], [], []
        c["def"] = {"micro": "very nice", "short": f"very nice in a calm way {i}", "long": "Very nice and pleasant."}
        out.append(c)
    return out


def test_free_tier_rules(tmp_path, sample_entries):
    base = {e["id"]: e for e in sample_entries}["en.meticulous.adj.1"]
    cards = _clone(base, 40, "rare_beautiful", "C2") + _clone(base, 15, "gre", "C2")
    for c in cards[40:]:  # gre kartları için farklı lemma'lar
        c["lemma"] = c["lemma"].replace("testword", "grexword")
        c["id"] = f"en.{c['lemma']}.adj.1"
        c["examples"] = [{**ex, "en": ex["en"].replace("testword", "grexword"), "focus": c["lemma"]} for ex in c["examples"]]
        c["quiz"]["answer"] = c["lemma"]
    _build(tmp_path, cards)
    con = sqlite3.connect(tmp_path / "content.sqlite")
    free = dict(con.execute("SELECT primary_topic, sum(is_free) FROM card GROUP BY 1"))
    assert free["rare_beautiful"] == 20  # S: max(20, %30 × 40 = 12) → 20
    assert free["gre"] == 10  # P: 10 kartlık tadımlık
    # Ücretsiz olanlar kategori içinde en sık (freq_rank küçük) kartlar olmalı.
    ranks = [r for (r,) in con.execute("SELECT freq_rank FROM card WHERE primary_topic='gre' AND is_free=1 ORDER BY freq_rank")]
    assert ranks == list(range(1000, 1010))


def test_seed_rotates_levels_and_is_small(tmp_path, sample_entries):
    _build(tmp_path, sample_entries)
    seed = json.loads((tmp_path / "seed_words.json").read_text(encoding="utf-8"))
    levels = [w["level"] for w in seed["words"]]
    assert levels[:5] == ["A1", "A2", "B1", "B2", "C1"]
    assert "C2" not in levels and "S" not in levels
    assert set(seed["words"][0]) == {
        "id", "lemma", "pos", "level", "ipa_us", "def_micro", "def_short", "example_en", "gloss_tr", "gloss_short_tr",
    }


def test_gloss_short_reaches_card_l1_seed_and_search(tmp_path, sample_entries):
    entries = copy.deepcopy(sample_entries)
    by_lemma = {e["lemma"]: e for e in entries}
    by_lemma["resilient"]["l1"]["tr"]["gloss_short"] = "yılmaz"
    _build(tmp_path, entries)
    con = sqlite3.connect(tmp_path / "content.sqlite")
    shorts = dict(con.execute("SELECT card.lemma, card_l1.gloss_short FROM card_l1 JOIN card ON card.rowid = card_l1.card_rowid"))
    assert shorts["resilient"] == "yılmaz"
    assert shorts["breakfast"] is None
    assert "resilient" in _search(con, "yilmaz")
    seed = json.loads((tmp_path / "seed_words.json").read_text(encoding="utf-8"))
    seed_shorts = {w["lemma"]: w["gloss_short_tr"] for w in seed["words"]}
    assert seed_shorts["resilient"] == "yılmaz"
    assert seed_shorts["breakfast"] is None


def test_confusables_link_cards_both_ways(tmp_path, sample_entries):
    entries = copy.deepcopy(sample_entries)
    by_lemma = {e["lemma"]: e for e in entries}
    by_lemma["resilient"]["confusables"] = ["Ubiquitous", "elastic"]  # "elastic" destede yok
    by_lemma["borrow"]["tags"]["flags"].append("confusable:actually")  # eski bayrak biçimi
    _build(tmp_path, entries)
    con = sqlite3.connect(tmp_path / "content.sqlite")
    sql = """SELECT a.lemma, b.lemma FROM card_confusable AS cc
             JOIN card AS a ON a.rowid = cc.card_rowid JOIN card AS b ON b.rowid = cc.other_rowid"""
    assert set(con.execute(sql)) == {
        ("resilient", "ubiquitous"), ("ubiquitous", "resilient"), ("borrow", "actually"), ("actually", "borrow"),
    }
    blob = con.execute("SELECT json FROM card WHERE lemma = 'resilient'").fetchone()[0]
    assert json.loads(blob)["confusables"] == ["Ubiquitous", "elastic"]
