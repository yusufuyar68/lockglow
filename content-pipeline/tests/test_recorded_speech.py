import json
import sqlite3

from vocabpipe.recorded_speech import Voice, clip_key, collect_texts, main, write_voices_manifest


def make_db(path, cards):
    con = sqlite3.connect(path)
    con.execute("CREATE TABLE card (rowid INTEGER PRIMARY KEY, json TEXT NOT NULL)")
    for card in cards:
        con.execute("INSERT INTO card (json) VALUES (?)", (json.dumps(card),))
    con.commit()
    con.close()


CARDS = [
    {
        "lemma": "breakfast",
        "examples": [{"en": "I usually have breakfast at seven."}, {"en": " Ayşe made breakfast. "}],
        "collocations": ["have breakfast", "skip breakfast"],
        "l1": {"tr": {"mistakes": [{"right": "I had breakfast at eight."}]}},
    },
    # The same phrase on another card is recorded once.
    {"lemma": "skip", "examples": [], "collocations": ["skip breakfast"], "l1": None},
]


def test_clip_key_matches_the_swift_side():
    # RecordedSpeechKeyTests (Swift) checks the same three values.
    assert clip_key("breakfast") == "9e3a8225470fb3b9"
    assert clip_key("  I usually have breakfast at seven. ") == "bb790f10e2d68902"
    assert clip_key("Ayşe") == "fddca89b15ddb988"


def test_collect_texts_once_in_order(tmp_path):
    db = tmp_path / "content.sqlite"
    make_db(db, CARDS)
    pairs = tmp_path / "pairs.json"
    pairs.write_text(json.dumps({"groups": [{"pairs": [{"a": {"word": "ship"}, "b": {"word": "sheep"}}]}]}))
    assert collect_texts(db, pairs) == [
        "breakfast",
        "I usually have breakfast at seven.",
        "Ayşe made breakfast.",
        "have breakfast",
        "skip breakfast",
        "I had breakfast at eight.",
        "skip",
        "ship",
        "sheep",
    ]
    assert collect_texts(db, None, ("lemma",)) == ["breakfast", "skip"]


def test_dry_run_needs_no_key(tmp_path, monkeypatch, capsys):
    monkeypatch.delenv("OPENAI_API_KEY", raising=False)
    db = tmp_path / "content.sqlite"
    make_db(db, CARDS)
    out = tmp_path / "out"
    assert main(["--db", str(db), "--pairs", str(tmp_path / "none.json"), "--out", str(out), "--dry-run", "--no-compress"]) == 0
    assert "4 metin x 2 ses" in capsys.readouterr().out
    assert not out.exists()


def test_openai_has_no_british_voice(tmp_path):
    db = tmp_path / "content.sqlite"
    make_db(db, CARDS)
    assert main(["--db", str(db), "--accents", "uk", "--dry-run", "--no-compress"]) == 2


def test_voices_manifest_counts_clips_and_keeps_other_voices(tmp_path):
    (tmp_path / "us-female").mkdir()
    (tmp_path / "us-female" / "a.mp3").write_bytes(b"x")
    (tmp_path / "us-female" / "b.mp3").write_bytes(b"x")
    write_voices_manifest(tmp_path, "google", [Voice("uk", "male", "en-GB-Chirp3-HD-Charon")], "mp3")
    write_voices_manifest(tmp_path, "openai", [Voice("us", "female", "nova")], "mp3")
    manifest = json.loads((tmp_path / "voices.json").read_text(encoding="utf-8"))
    assert list(manifest["voices"]) == ["uk-male", "us-female"]
    assert manifest["voices"]["us-female"] == {"provider": "openai", "name": "nova", "ext": "mp3", "clips": 2}
    assert manifest["voices"]["uk-male"]["clips"] == 0
