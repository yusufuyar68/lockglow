import copy
import json
import sqlite3

from vocabpipe.personal import build, interleave


def _card(cid, level):
    return {"id": cid, "level": level}


def test_interleave_groups_by_level_and_alternates_streams():
    streams = {
        "s1": [_card("a", "A2"), _card("b", "A1"), _card("c", "A2"), _card("d", "B1")],
        "s2": [_card("e", "A2"), _card("f", "A1")],
        "s3": [_card("b", "A1"), _card("g", "A2")],  # "b" s1'de zaten var
    }
    ordered, duplicates = interleave(streams)
    assert [c["id"] for c in ordered] == ["b", "f", "a", "e", "g", "c", "d"]
    assert len(duplicates) == 1 and duplicates[0].startswith("b:")


def _write_streams(root, sample_entries):
    drafts = []
    for e in sample_entries:
        d = copy.deepcopy(e)
        d["meta"]["status"] = "draft"
        drafts.append(d)
    for name, part in (("s1", drafts[:12]), ("s2", drafts[12:])):
        folder = root / name
        folder.mkdir(parents=True)
        (folder / "part_01.json").write_text(
            json.dumps({"schema_version": "1.0", "l1_langs": ["tr"], "entries": part}, ensure_ascii=False),
            encoding="utf-8",
        )
    return drafts


def test_build_makes_everything_free_and_ids_follow_the_interleaved_order(tmp_path, sample_entries):
    root = tmp_path / "drafts"
    drafts = _write_streams(root, sample_entries)
    registry = tmp_path / "id_registry.json"
    result = build(root, out=tmp_path / "content.sqlite", seed_out=tmp_path / "seed.json",
                   registry_path=registry, content_version="test-kisisel")
    assert result["cards"] == 25 and result["free"] == 25 and result["duplicates"] == []
    assert result["streams"] == {"s1": 12, "s2": 13}

    con = sqlite3.connect(tmp_path / "content.sqlite")
    assert con.execute("SELECT count(*) FROM card WHERE is_free = 0").fetchone()[0] == 0
    by_rowid = [cid for (cid,) in con.execute("SELECT card_id FROM card ORDER BY rowid")]
    expected, _ = interleave({"s1": drafts[:12], "s2": drafts[12:]})
    assert by_rowid == [c["id"] for c in expected]
    levels = [lv for (lv,) in con.execute("SELECT level_rank FROM card ORDER BY rowid")]
    assert levels == sorted(levels)

    # Yeniden derleme ID'leri değiştirmez (ilerleme ID'ye bağlı).
    first = json.loads(registry.read_text(encoding="utf-8"))["ids"]
    build(root, out=tmp_path / "content2.sqlite", seed_out=None, registry_path=registry, content_version="test-2")
    assert json.loads(registry.read_text(encoding="utf-8"))["ids"] == first
