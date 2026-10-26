"""Doğrulanmış kartlardan uygulamanın okuyacağı content.sqlite ve widget seed_words.json üretir.

Sözleşme: docs/contract/content-db.md. Şemayı burada değiştirirsen önce sözleşmeyi güncelle.

Örnek:
    python -m vocabpipe.build_db ../veri/ornek_kelime_seti_25.json \
        --include-status sample --out build/content.sqlite --seed-out build/seed_words.json
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sqlite3
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

from . import DB_SCHEMA_VERSION
from .schema import Card
from .taxonomy import DATA_DIR, Taxonomy, load_taxonomy
from .textutil import fold
from .validate import load_raw_cards, validate_cards

REGISTRY_PATH = DATA_DIR / "id_registry.json"
ATTRIBUTION_PATH = DATA_DIR / "attribution.txt"
# Kart kimliği → SF Symbol adı (docs/ozellik_planlari/kelime_gorselleri.md). Yalnız yüksek güvenli,
# somut ve hassas olmayan kartlar; adlar iOS 17 SF Symbols'ta olmalı (macOS WidgetSnapshots testi).
SYMBOLS_PATH = DATA_DIR / "card_symbols.json"
SYMBOL_NAME_RE = re.compile(r"^[a-z0-9]+(\.[a-z0-9]+)*$")
SEED_LEVELS = ("A1", "A2", "B1", "B2", "C1")
SEED_MAX_BYTES = 300_000

SCHEMA_SQL = """
CREATE TABLE content_meta (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
CREATE TABLE category (
  id          TEXT PRIMARY KEY,
  grp         TEXT NOT NULL,
  name_en     TEXT NOT NULL,
  name_tr     TEXT NOT NULL,
  access      TEXT NOT NULL,
  free_count  INTEGER NOT NULL,
  hero        INTEGER NOT NULL,
  sort        INTEGER NOT NULL
);
CREATE TABLE card (
  rowid           INTEGER PRIMARY KEY,
  card_id         TEXT NOT NULL UNIQUE,
  lemma           TEXT NOT NULL,
  type            TEXT NOT NULL,
  pos             TEXT NOT NULL,
  sense_no        INTEGER NOT NULL,
  sense_note      TEXT,
  level           TEXT NOT NULL,
  level_rank      INTEGER NOT NULL,
  freq_rank       INTEGER,
  zipf            REAL,
  ipa_us          TEXT,
  ipa_uk          TEXT,
  def_micro       TEXT NOT NULL,
  def_short       TEXT NOT NULL,
  def_long        TEXT NOT NULL,
  example_en      TEXT NOT NULL,
  primary_topic   TEXT NOT NULL REFERENCES category(id),
  register        TEXT NOT NULL,
  sensitivity     INTEGER NOT NULL,
  is_free         INTEGER NOT NULL,
  json            TEXT NOT NULL,
  symbol          TEXT
);
CREATE INDEX idx_card_level ON card(level_rank, is_free);
CREATE INDEX idx_card_topic ON card(primary_topic);
-- ContentStore.topics(): ücretsiz ve hassas olmayan kartları büyük `card` satırlarına inmeden
-- bulur (kapsayan dizin). is5-performans ölçümü: 8,4 ms -> 3,5 ms; freeCards ve arama değişmez.
CREATE INDEX idx_card_free ON card(is_free, sensitivity, level_rank);
CREATE TABLE card_l1 (
  card_rowid   INTEGER NOT NULL REFERENCES card(rowid),
  lang         TEXT NOT NULL,
  gloss        TEXT NOT NULL,
  equivalence  TEXT NOT NULL,
  example_tr   TEXT,
  gloss_short  TEXT,
  PRIMARY KEY (card_rowid, lang)
);
CREATE TABLE card_confusable (
  card_rowid   INTEGER NOT NULL REFERENCES card(rowid),
  other_rowid  INTEGER NOT NULL REFERENCES card(rowid),
  PRIMARY KEY (card_rowid, other_rowid)
);
CREATE TABLE card_category (
  card_rowid   INTEGER NOT NULL REFERENCES card(rowid),
  category_id  TEXT NOT NULL REFERENCES category(id),
  is_primary   INTEGER NOT NULL,
  rank         INTEGER NOT NULL,
  PRIMARY KEY (card_rowid, category_id)
);
CREATE INDEX idx_cc_cat ON card_category(category_id, rank);
CREATE VIRTUAL TABLE card_fts USING fts5(
  lemma_fold, gloss_fold,
  content='', tokenize='unicode61 remove_diacritics 2'
);
"""


class BuildError(Exception):
    pass


# ---------------------------------------------------------------- kalıcı ID kaydı

def load_registry(path: Path) -> dict:
    if not path.exists():
        return {"version": 1, "next_id": 1, "ids": {}, "retired": []}
    reg = json.loads(path.read_text(encoding="utf-8"))
    used = set(reg["ids"].values())
    if len(used) != len(reg["ids"]):
        raise BuildError(f"{path}: aynı ID birden fazla karta verilmiş, kayıt bozuk")
    if used and max(used) >= reg["next_id"]:
        raise BuildError(f"{path}: next_id ({reg['next_id']}) kullanılmış ID'lerden büyük olmalı")
    return reg


def assign_ids(
    cards: list[Card], registry: dict, *, input_order: bool = False
) -> tuple[dict[str, int], list[str]]:
    """Kartlara kalıcı tam sayı ID atar. Var olan ID'ler asla değişmez, yenileri sona eklenir.

    Yeni ID'ler varsayılan olarak kart kimliği sırasıyla verilir. `input_order` ile girdi sırası
    kullanılır: frekans verisi olmayan kartlarda akış sırasını (ID'ye göre) belirlemenin yolu budur.
    """
    ids = registry["ids"]
    new: list[str] = []
    ordered = cards if input_order else sorted(cards, key=lambda c: c.id)  # belirleyici sıra
    for card in ordered:
        if card.id not in ids:
            ids[card.id] = registry["next_id"]
            registry["next_id"] += 1
            new.append(card.id)
    return {c.id: ids[c.id] for c in cards}, new


def write_json_atomic(path: Path, data: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix=path.name, suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as f:
            json.dump(data, f, ensure_ascii=False, indent=1, sort_keys=False)
            f.write("\n")
        os.replace(tmp, path)
    except BaseException:
        Path(tmp).unlink(missing_ok=True)
        raise


# ---------------------------------------------------------------- kelime görselleri

def load_symbols(path: Path | None) -> dict[str, str]:
    """`card_symbols.json`: düz {kart kimliği: SF Symbol adı}. Dosya yoksa boş eşleme."""
    if path is None or not path.exists():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise BuildError(f"{path}: düz bir JSON nesnesi olmalı")
    for card_id, name in data.items():
        if not isinstance(name, str) or not SYMBOL_NAME_RE.match(name):
            raise BuildError(f"{path}: {card_id} için geçersiz SF Symbol adı: {name!r}")
    return data


def card_symbols(cards: list[Card], symbols: dict[str, str]) -> dict[str, str]:
    """Bu derlemedeki kartların görselleri. Destede olmayan anahtarlar atlanır (örnek derlemeler
    yalnız birkaç kart içerir); hassas bir karta görsel verilmişse derleme durur."""
    result: dict[str, str] = {}
    for card in cards:
        name = symbols.get(card.id)
        if name is None:
            continue
        if card.tags.sensitivity != 0:
            raise BuildError(f"{card.id}: hassas karta görsel verilemez (card_symbols.json)")
        result[card.id] = name
    return result


# ---------------------------------------------------------------- sıralama ve ücretsiz katman

def _rank_key(card: Card) -> tuple:
    freq = card.freq.rank if card.freq and card.freq.rank is not None else 10**9
    return (card.level_rank, freq, card.id)


def category_ranks(cards: list[Card], tax: Taxonomy) -> dict[str, list[Card]]:
    by_cat: dict[str, list[Card]] = {cid: [] for cid in tax.categories}
    for card in cards:
        for topic in card.tags.topics:
            by_cat[topic].append(card)
    for members in by_cat.values():
        members.sort(key=_rank_key)
    return by_cat


def free_ids(by_cat: dict[str, list[Card]], tax: Taxonomy) -> set[str]:
    """Kart, BİRİNCİL kategorisinin ücretsiz dilimindeyse ücretsizdir."""
    free: set[str] = set()
    for cid, members in by_cat.items():
        n_free = tax.categories[cid].free_count(len(members))
        for card in members[:n_free]:
            if card.tags.primary_topic == cid:
                free.add(card.id)
    return free


# ---------------------------------------------------------------- karışan kelimeler

def confusable_pairs(cards: list[Card], id_map: dict[str, int]) -> set[tuple[int, int]]:
    """Karışan kelime lemma'larını kart ID çiftlerine bağlar; ilişki iki yönlüdür.

    Lemma büyük/küçük harf duyarsız eşlenir ve o lemma'nın bütün kartlarına bağlanır (ör. "change"
    hem isim hem fiil). Destede kartı olmayan kelime yalnızca kartın JSON'unda kalır.
    """
    by_lemma: dict[str, list[int]] = {}
    for card in cards:
        by_lemma.setdefault(card.lemma.lower(), []).append(id_map[card.id])
    pairs: set[tuple[int, int]] = set()
    for card in cards:
        rid = id_map[card.id]
        for lemma in card.confusable_lemmas():
            for other in by_lemma.get(lemma.lower(), []):
                if other != rid:
                    pairs.add((rid, other))
                    pairs.add((other, rid))
    return pairs


# ---------------------------------------------------------------- veritabanı

def build_database(
    cards: list[Card],
    id_map: dict[str, int],
    out_path: Path,
    *,
    content_version: str,
    tax: Taxonomy,
    l1_langs: tuple[str, ...] = ("tr",),
    all_free: bool = False,
    symbols: dict[str, str] | None = None,
) -> dict:
    symbols = symbols or {}
    by_cat = category_ranks(cards, tax)
    free = {c.id for c in cards} if all_free else free_ids(by_cat, tax)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    tmp_path = out_path.with_suffix(out_path.suffix + ".building")
    tmp_path.unlink(missing_ok=True)
    con = sqlite3.connect(tmp_path)
    try:
        con.executescript(SCHEMA_SQL)
        con.executemany(
            "INSERT INTO category VALUES (?,?,?,?,?,?,?,?)",
            [
                (
                    c.id, c.grp, c.name_en, c.name_tr, c.access,
                    len(by_cat[c.id]) if all_free else c.free_count(len(by_cat[c.id])),
                    int(c.hero), c.sort,
                )
                for c in tax.categories.values()
            ],
        )
        for card in cards:
            rid = id_map[card.id]
            tr = card.l1.get("tr")
            con.execute(
                "INSERT INTO card VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                (
                    rid, card.id, card.lemma, card.type, card.pos, card.sense_no, card.sense_note,
                    card.level, card.level_rank,
                    card.freq.rank if card.freq else None,
                    card.freq.zipf if card.freq else None,
                    card.ipa.us if card.ipa else None,
                    card.ipa.uk if card.ipa else None,
                    card.def_.micro, card.def_.short, card.def_.long,
                    card.examples[0].en,
                    card.tags.primary_topic, card.tags.register_, card.tags.sensitivity,
                    int(card.id in free),
                    json.dumps(card.to_json_dict(), ensure_ascii=False, separators=(",", ":")),
                    symbols.get(card.id),
                ),
            )
            for lang in l1_langs:
                layer = card.l1[lang]
                con.execute(
                    "INSERT INTO card_l1 (card_rowid, lang, gloss, equivalence, example_tr, gloss_short)"
                    " VALUES (?,?,?,?,?,?)",
                    (
                        rid, lang, layer.gloss, layer.equivalence,
                        card.examples[0].tr if lang == "tr" else None, layer.gloss_short,
                    ),
                )
            gloss_text = " ".join([tr.gloss, *([tr.gloss_short] if tr.gloss_short else []), *tr.alt]) if tr else ""
            con.execute(
                "INSERT INTO card_fts(rowid, lemma_fold, gloss_fold) VALUES (?,?,?)",
                (rid, fold(card.lemma), fold(gloss_text)),
            )
        for cid, members in by_cat.items():
            con.executemany(
                "INSERT INTO card_category VALUES (?,?,?,?)",
                [(id_map[c.id], cid, int(c.tags.primary_topic == cid), rank) for rank, c in enumerate(members)],
            )
        con.executemany("INSERT INTO card_confusable VALUES (?,?)", sorted(confusable_pairs(cards, id_map)))
        attribution = ATTRIBUTION_PATH.read_text(encoding="utf-8").strip() if ATTRIBUTION_PATH.exists() else ""
        meta = {
            "schema_version": str(DB_SCHEMA_VERSION),
            "content_version": content_version,
            "built_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
            "card_count": str(len(cards)),
            "l1_langs": ",".join(l1_langs),
            "attribution": attribution,
        }
        con.executemany("INSERT INTO content_meta VALUES (?,?)", list(meta.items()))
        con.execute(f"PRAGMA user_version = {DB_SCHEMA_VERSION}")
        con.commit()
        # Uygulama dosyayı paketten salt okunur açar; WAL modunda bu başarısız olabilir.
        mode = con.execute("PRAGMA journal_mode = DELETE").fetchone()[0]
        if mode.lower() != "delete":
            raise BuildError(f"journal_mode DELETE yapılamadı: {mode}")
        con.execute("VACUUM")
        ok = con.execute("PRAGMA integrity_check").fetchone()[0]
        if ok != "ok":
            raise BuildError(f"integrity_check başarısız: {ok}")
    finally:
        con.close()
    os.replace(tmp_path, out_path)
    return {"cards": len(cards), "free": len(free), "path": str(out_path)}


# ---------------------------------------------------------------- widget seed

def build_seed(
    cards: list[Card],
    id_map: dict[str, int],
    free: set[str],
    *,
    size: int,
    content_version: str,
    symbols: dict[str, str] | None = None,
) -> dict:
    symbols = symbols or {}
    pools = {
        lv: sorted(
            (c for c in cards if c.level == lv and c.id in free and c.tags.sensitivity == 0),
            key=_rank_key,
        )
        for lv in SEED_LEVELS
    }
    words: list[dict] = []
    while len(words) < size and any(pools.values()):
        for lv in SEED_LEVELS:  # seviyeler dönüşümlü: widget ilk gün tek seviyeye sıkışmasın
            if pools[lv] and len(words) < size:
                c = pools[lv].pop(0)
                tr = c.l1.get("tr")
                word = {
                    "id": id_map[c.id],
                    "lemma": c.lemma,
                    "pos": c.pos,
                    "level": c.level,
                    "ipa_us": c.ipa.us if c.ipa else None,
                    "def_micro": c.def_.micro,
                    "def_short": c.def_.short,
                    "example_en": c.examples[0].en,
                    "gloss_tr": tr.gloss if tr else None,
                    "gloss_short_tr": tr.gloss_short if tr else None,
                }
                if c.id in symbols:  # yalnız görseli olan kelimede: eski seed biçimi aynen kalır
                    word["symbol"] = symbols[c.id]
                words.append(word)
    return {"schema_version": DB_SCHEMA_VERSION, "content_version": content_version, "words": words}


# ---------------------------------------------------------------- giriş noktası

def run(
    inputs: list[Path],
    *,
    out: Path,
    seed_out: Path | None,
    registry_path: Path,
    include_status: set[str],
    content_version: str,
    seed_size: int = 400,
    write_registry: bool = True,
    all_free: bool = False,
    ids_in_input_order: bool = False,
    symbols_path: Path | None = SYMBOLS_PATH,
) -> dict:
    """`all_free` ve `ids_in_input_order` yalnızca kişisel derleme içindir (vocabpipe.personal).
    `symbols_path`: kelime görselleri eşlemesi (None: görsel yok)."""
    raws: list[dict] = []
    for p in inputs:
        r, _ = load_raw_cards(p)
        raws.extend(r)
    raws = [r for r in raws if r.get("meta", {}).get("status") in include_status]
    if not raws:
        raise BuildError(f"durumu {sorted(include_status)} olan kart yok")

    cards, issues = validate_cards(raws)
    errors = [i for i in issues if i.severity == "error"]
    if errors:
        details = "\n".join(str(e) for e in errors[:50])
        raise BuildError(f"{len(errors)} doğrulama hatası; veritabanı üretilmedi:\n{details}")

    tax = load_taxonomy()
    registry = load_registry(registry_path)
    id_map, new_ids = assign_ids(cards, registry, input_order=ids_in_input_order)
    symbols = card_symbols(cards, load_symbols(symbols_path))
    result = build_database(
        cards, id_map, out, content_version=content_version, tax=tax, all_free=all_free, symbols=symbols
    )
    result["symbols"] = len(symbols)

    if seed_out is not None:
        free = {c.id for c in cards} if all_free else free_ids(category_ranks(cards, tax), tax)
        seed = build_seed(cards, id_map, free, size=seed_size, content_version=content_version, symbols=symbols)
        write_json_atomic(seed_out, seed)
        size_bytes = seed_out.stat().st_size
        if size_bytes > SEED_MAX_BYTES:
            raise BuildError(f"seed_words.json {size_bytes} bayt > {SEED_MAX_BYTES}: --seed-size'ı düşürün")
        result["seed_words"] = len(seed["words"])

    # Kayıt en son yazılır: veritabanı üretimi başarısız olursa ID'ler boşa harcanmaz.
    if write_registry and new_ids:
        write_json_atomic(registry_path, registry)
    result["new_ids"] = len(new_ids)
    result["warnings"] = sum(1 for i in issues if i.severity == "warning")
    return result


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="content.sqlite ve seed_words.json üretir.")
    ap.add_argument("inputs", nargs="+", type=Path, help="veri seti JSON dosyaları ya da kart klasörleri")
    ap.add_argument("--out", type=Path, default=Path("build/content.sqlite"))
    ap.add_argument("--seed-out", type=Path, default=Path("build/seed_words.json"))
    ap.add_argument("--seed-size", type=int, default=400)
    ap.add_argument("--registry", type=Path, default=REGISTRY_PATH)
    ap.add_argument("--no-registry-write", action="store_true", help="ID kaydını diske yazma (deneme amaçlı)")
    ap.add_argument(
        "--include-status",
        default="reviewed,approved",
        help="veritabanına alınacak kart durumları (virgülle). Üretim: reviewed,approved",
    )
    ap.add_argument(
        "--content-version",
        default=datetime.now(timezone.utc).strftime("%Y.%m.%d-1"),
        help="ör. 2026.10.11-1",
    )
    args = ap.parse_args(argv)
    try:
        result = run(
            args.inputs,
            out=args.out,
            seed_out=args.seed_out,
            registry_path=args.registry,
            include_status={s.strip() for s in args.include_status.split(",") if s.strip()},
            content_version=args.content_version,
            seed_size=args.seed_size,
            write_registry=not args.no_registry_write,
        )
    except BuildError as e:
        print(f"HATA: {e}", file=sys.stderr)
        return 1
    print(json.dumps(result, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
