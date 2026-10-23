"""Kulak alıştırması içeriği: content/kulak/ kaynakları geçerli ve uygulamadaki dosya güncel."""

import importlib.util
import json
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("kulak_derle", REPO / "content" / "kulak" / "derle.py")
derle = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(derle)


def test_kaynak_gecerli_ve_uygulama_dosyasi_guncel():
    content, _ = derle.build()
    assert derle.OUTPUT.read_text(encoding="utf-8") == derle.render(content), (
        "ios/App/Resources/minimal_pairs.json güncel değil: python -X utf8 content/kulak/derle.py"
    )


def test_yaklasik_on_bes_grup_ve_her_grupta_dort_sekiz_cift():
    content, _ = derle.build()
    groups = content["groups"]
    assert 14 <= len(groups) <= 17
    for group in groups:
        assert 4 <= len(group["pairs"]) <= 8, group["id"]
        assert len(group["sounds"]) == 2, group["id"]


def test_b2_kelime_az_ve_hep_bilinen_bir_esle():
    content, warnings = derle.build()
    assert len(warnings) <= derle.MAX_B2_TOTAL
    for group in content["groups"]:
        for pair in group["pairs"]:
            levels = [pair["a"]["level"], pair["b"]["level"]]
            assert levels.count("B2") <= 1, (group["id"], pair["a"]["word"], pair["b"]["word"])


def test_iki_b2_kelimeli_cift_reddedilir(tmp_path):
    path = _group(tmp_path)
    raw = json.loads(path.read_text(encoding="utf-8"))
    raw["pairs"][0]["a"]["level"] = "B2"
    raw["pairs"][0]["b"]["level"] = "B2"
    path.write_text(json.dumps(raw, ensure_ascii=False), encoding="utf-8")
    with pytest.raises(derle.ContentError, match="eşi A1–B1"):
        derle.load_group(path, [])


def _group(tmp_path: Path, name: str = "01_ih-ee.json", **changes) -> Path:
    word = lambda w, ipa, tr, level="A1": {"word": w, "ipa": {"us": ipa, "uk": ipa}, "tr": tr, "level": level}
    pairs = [
        {"a": word("ship", "/ʃɪp/", "gemi"), "b": word("sheep", "/ʃiːp/", "koyun")},
        {"a": word("sit", "/sɪt/", "oturmak"), "b": word("seat", "/siːt/", "koltuk")},
        {"a": word("fill", "/fɪl/", "doldurmak"), "b": word("feel", "/fiːl/", "hissetmek")},
        {"a": word("hit", "/hɪt/", "vurmak"), "b": word("heat", "/hiːt/", "ısı")},
    ]
    raw = {
        "id": "ih-ee",
        "title": "ship / sheep",
        "name_tr": "Kısa i ve uzun i",
        "sounds": [
            {"ipa": "ɪ", "name_tr": "kısa i", "how_tr": "Kısa ve gevşek."},
            {"ipa": "iː", "name_tr": "uzun i", "how_tr": "Uzun ses."},
        ],
        "pairs": pairs,
    }
    raw.update(changes)
    path = tmp_path / name
    path.write_text(json.dumps(raw, ensure_ascii=False), encoding="utf-8")
    return path


def test_gecerli_grup_okunur(tmp_path):
    group = derle.load_group(_group(tmp_path), [])
    assert group["id"] == "ih-ee"
    assert [p["a"]["word"] for p in group["pairs"]] == ["ship", "sit", "fill", "hit"]


@pytest.mark.parametrize(
    "changes, message",
    [
        ({"id": "baska"}, "dosya adıyla"),
        ({"title": "cat / cut"}, "çiftlerden biri"),
        ({"sounds": [{"ipa": "ɪ", "name_tr": "kısa i", "how_tr": "Kısa."}]}, "iki ses"),
        ({"name_tr": "Kısa i!"}, "ünlem"),
    ],
)
def test_hatali_grup_reddedilir(tmp_path, changes, message):
    with pytest.raises(derle.ContentError, match=message):
        derle.load_group(_group(tmp_path, **changes), [])


def test_iki_turlu_okunan_kelime_reddedilir(tmp_path):
    path = _group(tmp_path)
    raw = json.loads(path.read_text(encoding="utf-8"))
    raw["pairs"][1]["a"]["word"] = "live"
    path.write_text(json.dumps(raw, ensure_ascii=False), encoding="utf-8")
    with pytest.raises(derle.ContentError, match="iki türlü"):
        derle.load_group(path, [])


def test_seviye_disi_kelime_reddedilir(tmp_path):
    path = _group(tmp_path)
    raw = json.loads(path.read_text(encoding="utf-8"))
    raw["pairs"][0]["b"]["level"] = "C1"
    path.write_text(json.dumps(raw, ensure_ascii=False), encoding="utf-8")
    with pytest.raises(derle.ContentError, match="seviye"):
        derle.load_group(path, [])


def test_az_cift_reddedilir(tmp_path):
    path = _group(tmp_path)
    raw = json.loads(path.read_text(encoding="utf-8"))
    raw["pairs"] = raw["pairs"][:3]
    path.write_text(json.dumps(raw, ensure_ascii=False), encoding="utf-8")
    with pytest.raises(derle.ContentError, match="çift olmalı"):
        derle.load_group(path, [])
