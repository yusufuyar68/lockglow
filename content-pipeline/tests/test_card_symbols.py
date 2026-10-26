"""data/card_symbols.json: kelime görselleri eşlemesi (docs/ozellik_planlari/kelime_gorselleri.md).

Adların iOS 17'de gerçekten var olduğunu bu test bilemez (Linux/Windows'ta SF Symbols yok); onu
macOS'taki LockglowWidgetSnapshots/CardSymbolTests denetler.
"""

import json
import re
from pathlib import Path

import pytest

from vocabpipe.build_db import REGISTRY_PATH, SYMBOL_NAME_RE, SYMBOLS_PATH
from vocabpipe.personal import interleave, load_streams

DRAFTS = Path(__file__).resolve().parents[2] / "content" / "drafts" / "kisisel_v1"


@pytest.fixture(scope="module")
def raw_text() -> str:
    return SYMBOLS_PATH.read_text(encoding="utf-8")


@pytest.fixture(scope="module")
def symbols(raw_text) -> dict:
    return json.loads(raw_text)


@pytest.fixture(scope="module")
def deck() -> dict[str, dict]:
    ordered, _ = interleave(load_streams(DRAFTS))
    return {raw["id"]: raw for raw in ordered}


def test_file_is_a_flat_sorted_object_without_duplicates(raw_text, symbols):
    assert isinstance(symbols, dict) and symbols
    assert all(isinstance(v, str) for v in symbols.values()), "düz {kart: ad} olmalı"
    keys = re.findall(r'^\s*"([^"]+)"\s*:', raw_text, flags=re.M)
    assert len(keys) == len(set(keys)) == len(symbols), "aynı kart iki kez yazılmış"
    assert keys == sorted(keys), "anahtarlar sıralı olmalı"
    assert "\r" not in raw_text, "LF satır sonu"
    assert "_comment" not in symbols


def test_every_key_is_a_registered_card_in_the_deck(symbols, deck):
    registry = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))["ids"]
    missing = [k for k in symbols if k not in registry]
    assert not missing, f"id_registry.json'da yok: {missing}"
    not_in_deck = [k for k in symbols if k not in deck]
    assert not not_in_deck, f"taslak destede yok: {not_in_deck}"


def test_values_look_like_sf_symbol_names(symbols):
    bad = {k: v for k, v in symbols.items() if not SYMBOL_NAME_RE.match(v)}
    assert not bad
    # Kendi adlandırma kuralımızla da tutarlı: [a-z0-9.]+
    assert all(re.fullmatch(r"[a-z0-9.]+", v) for v in symbols.values())


def test_no_sensitive_card_gets_a_symbol(symbols, deck):
    sensitive = [k for k in symbols if deck[k].get("tags", {}).get("sensitivity", 0) != 0]
    assert not sensitive, f"hassas kartlara görsel verilmez: {sensitive}"


def test_only_concrete_nouns_and_verbs(symbols, deck):
    other = {k: deck[k]["pos"] for k in symbols if deck[k]["pos"] not in ("n", "v")}
    assert not other, f"yalnız isim ve fiil kartları: {other}"


# Apple'ın yalnız kendi ürün ve hizmetleri için ayırdığı sembol aileleri (SF Symbols'taki
# kullanım kısıtı notları): genel bir anlamı göstermek için kullanılamazlar.
RESTRICTED_FAMILIES = (
    "icloud",
    "message",
    "facetime",
    "applelogo",
    "airpods",
    "airpod",
    "homepod",
    "iphone",
    "ipad",
    "ipod",
    "applewatch",
    "macbook",
    "appletv",
    "airplay",
    "airtag",
    "visionpro",
    "faceid",
    "touchid",
)


def test_no_restricted_apple_symbols(symbols):
    restricted = {k: v for k, v in symbols.items() if v.split(".")[0] in RESTRICTED_FAMILIES}
    assert not restricted, f"Apple'a ayrılmış semboller kullanılmaz: {restricted}"
