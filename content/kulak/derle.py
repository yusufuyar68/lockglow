"""Kulak alıştırması: content/kulak/gruplar/*.json -> ios/App/Resources/minimal_pairs.json

Kaynak dosyaları denetler ve uygulamanın okuduğu tek dosyayı yazar. content.sqlite'a dokunmaz.

    python -X utf8 content/kulak/derle.py            # denetle ve yaz
    python -X utf8 content/kulak/derle.py --kontrol  # denetle; çıktı güncel değilse hata ver

Yalnız standart kütüphane. Kurallar aşağıdaki denetimlerde (load_group, build).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
SOURCE = HERE / "gruplar"
META = HERE / "meta.json"
OUTPUT = REPO / "ios" / "App" / "Resources" / "minimal_pairs.json"

FORMAT = 1
LEVELS = {"A1", "A2", "B1"}
# A1–B1 içinde yeterli çift yoksa (v / w) bir grupta en çok iki B2 kelime; bütün dosyada en çok dört.
MAX_B2_PER_GROUP, MAX_B2_TOTAL = 2, 4
MIN_PAIRS, MAX_PAIRS = 4, 8
MAX_HOW = 140
MAX_TIP = 120
FILE_NAME = re.compile(r"^(\d{2})_([a-z0-9-]+)\.json$")
WORD = re.compile(r"^[a-z]+(?:'[a-z]+)?$")
IPA = re.compile(r"^/[^/\s][^/]*/$")
# Bir kelimenin iki yaygın okunuşu varsa telefonun sesi hangisini okuyacağını bilemeyiz.
HETERONYMS = {
    "bass", "bow", "close", "content", "desert", "dove", "excuse", "lead", "live", "minute",
    "object", "polish", "present", "produce", "read", "record", "refuse", "row", "sow", "tear",
    "use", "wind", "wound", "house", "does", "lives", "reads", "leads", "tears", "winds",
    "bows", "rows", "uses", "closes", "excuses",
}


class ContentError(Exception):
    pass


def _text(value: object, where: str, limit: int | None = None) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ContentError(f"{where}: boş ya da metin değil")
    if value != value.strip() or "  " in value:
        raise ContentError(f"{where}: baş/son boşluk ya da çift boşluk")
    if limit is not None and len(value) > limit:
        raise ContentError(f"{where}: {len(value)} karakter (en çok {limit})")
    if "!" in value or "..." in value:
        raise ContentError(f"{where}: ünlem ya da '...' var (terimler.md: ünlem yok, üç nokta '…')")
    return value


def _word(raw: object, where: str, warnings: list[str]) -> dict:
    if not isinstance(raw, dict):
        raise ContentError(f"{where}: nesne değil")
    word = raw.get("word")
    if not isinstance(word, str) or not WORD.match(word):
        raise ContentError(f"{where}: kelime küçük harfli tek İngilizce kelime olmalı: {word!r}")
    if word in HETERONYMS:
        raise ContentError(f"{where}: '{word}' iki türlü okunabilir; ses yanlış okuyabilir")
    ipa = raw.get("ipa")
    if not isinstance(ipa, dict) or not isinstance(ipa.get("us"), str) or not IPA.match(ipa["us"]):
        raise ContentError(f"{where}: ipa.us '/…/' biçiminde olmalı")
    uk = ipa.get("uk")
    if uk is not None and (not isinstance(uk, str) or not IPA.match(uk)):
        raise ContentError(f"{where}: ipa.uk '/…/' biçiminde olmalı")
    tr = _text(raw.get("tr"), f"{where}.tr", 40)
    level = raw.get("level")
    if level == "B2":
        warnings.append(f"{where}: '{word}' B2")
    elif level not in LEVELS:
        raise ContentError(f"{where}: seviye A1, A2 ya da B1 olmalı: {level!r}")
    out = {"word": word, "ipa": {"us": ipa["us"]}, "tr": tr, "level": level}
    if uk is not None:
        out["ipa"]["uk"] = uk
    return out


def load_group(path: Path, warnings: list[str]) -> dict:
    match = FILE_NAME.match(path.name)
    if not match:
        raise ContentError(f"{path.name}: dosya adı 'NN_<id>.json' olmalı")
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise ContentError(f"{path.name}: JSON okunamadı: {error}") from error
    where = path.name
    if not isinstance(raw, dict):
        raise ContentError(f"{where}: en üstte bir nesne olmalı")
    group_id = raw.get("id")
    if group_id != match.group(2):
        raise ContentError(f"{where}: id {group_id!r} dosya adıyla aynı olmalı ({match.group(2)})")

    sounds = raw.get("sounds")
    if not isinstance(sounds, list) or len(sounds) != 2:
        raise ContentError(f"{where}: tam iki ses (sounds) olmalı")
    out_sounds = []
    for index, sound in enumerate(sounds):
        at = f"{where}.sounds[{index}]"
        if not isinstance(sound, dict):
            raise ContentError(f"{at}: nesne değil")
        ipa = sound.get("ipa")
        if ipa is not None and (not isinstance(ipa, str) or not ipa.strip()):
            raise ContentError(f"{at}.ipa: boş olamaz (yoksa null)")
        out_sounds.append({
            "ipa": ipa,
            "name_tr": _text(sound.get("name_tr"), f"{at}.name_tr", 40),
            "how_tr": _text(sound.get("how_tr"), f"{at}.how_tr", MAX_HOW),
        })

    pairs = raw.get("pairs")
    if not isinstance(pairs, list) or not MIN_PAIRS <= len(pairs) <= MAX_PAIRS:
        raise ContentError(f"{where}: {MIN_PAIRS}–{MAX_PAIRS} çift olmalı")
    out_pairs = []
    seen: set[str] = set()
    b2 = 0
    for index, pair in enumerate(pairs):
        at = f"{where}.pairs[{index}]"
        if not isinstance(pair, dict):
            raise ContentError(f"{at}: nesne değil")
        a = _word(pair.get("a"), f"{at}.a", warnings)
        b = _word(pair.get("b"), f"{at}.b", warnings)
        levels = (a["level"], b["level"])
        if "B2" in levels:
            b2 += levels.count("B2")
            # Az bilinen kelime ancak bilinen bir eşle gelir (wine / vine).
            if levels.count("B2") == 2:
                raise ContentError(f"{at}: B2 kelimenin eşi A1–B1 olmalı")
        if a["word"] == b["word"]:
            raise ContentError(f"{at}: iki kelime aynı")
        if a["ipa"]["us"] == b["ipa"]["us"]:
            raise ContentError(f"{at}: iki kelimenin ABD okunuşu aynı")
        if a["tr"] == b["tr"]:
            raise ContentError(f"{at}: iki kelimenin Türkçesi aynı")
        for word in (a["word"], b["word"]):
            if word in seen:
                raise ContentError(f"{at}: '{word}' bu grupta iki kez")
            seen.add(word)
        out_pairs.append({"a": a, "b": b})
    if b2 > MAX_B2_PER_GROUP:
        raise ContentError(f"{where}: grupta en çok {MAX_B2_PER_GROUP} B2 kelime olabilir ({b2})")

    title = _text(raw.get("title"), f"{where}.title", 40)
    if title not in {f"{p['a']['word']} / {p['b']['word']}" for p in out_pairs}:
        raise ContentError(f"{where}: title '{title}' çiftlerden biri olmalı ('a / b')")

    group = {
        "id": group_id,
        "title": title,
        "name_tr": _text(raw.get("name_tr"), f"{where}.name_tr", 40),
        "sounds": out_sounds,
    }
    tip = raw.get("tip_tr")
    if tip is not None:
        group["tip_tr"] = _text(tip, f"{where}.tip_tr", MAX_TIP)
    group["pairs"] = out_pairs
    return group


def build() -> tuple[dict, list[str]]:
    """Bütün grupları denetler; uygulama dosyasının içeriğini ve uyarıları döndürür."""
    warnings: list[str] = []
    meta = json.loads(META.read_text(encoding="utf-8"))
    version = meta.get("version")
    if not isinstance(version, str) or not re.match(r"^\d{4}\.\d{2}\.\d{2}-kulak-\d+$", version):
        raise ContentError("meta.json: version '2026.10.23-kulak-1' biçiminde olmalı")
    files = sorted(SOURCE.glob("*.json"))
    if not files:
        raise ContentError(f"{SOURCE}: grup dosyası yok")
    groups = [load_group(path, warnings) for path in files]

    numbers = [FILE_NAME.match(p.name).group(1) for p in files]
    if len(set(numbers)) != len(numbers):
        raise ContentError("iki dosyanın sıra numarası aynı")
    ids = [g["id"] for g in groups]
    if len(set(ids)) != len(ids):
        raise ContentError("iki grubun id'si aynı")
    if len(warnings) > MAX_B2_TOTAL:
        raise ContentError(f"{len(warnings)} B2 kelime var; en çok {MAX_B2_TOTAL}")

    # Bir kelime en çok iki grupta: bir turda aynı kelime az tekrar etsin.
    where: dict[str, list[str]] = {}
    for group in groups:
        for pair in group["pairs"]:
            for side in ("a", "b"):
                where.setdefault(pair[side]["word"], []).append(group["id"])
    for word, owners in sorted(where.items()):
        if len(owners) > 2:
            raise ContentError(f"'{word}' {len(owners)} grupta ({', '.join(owners)}); en çok 2")

    return {"format": FORMAT, "version": version, "groups": groups}, warnings


def render(content: dict) -> str:
    return json.dumps(content, ensure_ascii=False, indent=2) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--kontrol", action="store_true", help="yazma; çıktı güncel değilse hata ver")
    args = parser.parse_args(argv)
    try:
        content, warnings = build()
    except ContentError as error:
        print(f"HATA: {error}", file=sys.stderr)
        return 1
    for warning in warnings:
        print(f"uyarı: {warning}")
    text = render(content)
    pairs = sum(len(g["pairs"]) for g in content["groups"])
    if args.kontrol:
        current = OUTPUT.read_text(encoding="utf-8") if OUTPUT.exists() else ""
        if current != text:
            print(f"HATA: {OUTPUT.relative_to(REPO)} güncel değil; derle.py'yi çalıştır", file=sys.stderr)
            return 1
        print(f"güncel: {len(content['groups'])} grup, {pairs} çift")
        return 0
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)
    print(f"yazıldı: {OUTPUT.relative_to(REPO)} ({len(content['groups'])} grup, {pairs} çift)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
