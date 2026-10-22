"""Deterministik kart doğrulayıcı.

Kullanım:
    python -m vocabpipe.validate ../veri/ornek_kelime_seti_25.json
    python -m vocabpipe.validate drafts/ --strict      # uyarılar da başarısız sayılır

Seviyeler:
    error   → kart veritabanına giremez
    warning → kart girebilir ama insan denetiminde bakılmalı (meta.qa_flags'e eklenir)
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

from pydantic import ValidationError

from .schema import TYPE_POS, Card
from .taxonomy import Taxonomy, load_taxonomy
from .textutil import contains_phrase, contains_stem, glen, is_nfc, slugify_lemma

SPEAKABLE_LEMMA = re.compile(r"[A-Za-z]+(?:[ '\-][A-Za-z]+)*")

# Grafem sınırları (raporlar/07_icerik_stratejisi.md §4). Widget yerleşimleri bunlara göre tasarlandı.
LIMITS = {
    "lemma": 28,
    "sense_note": 40,
    "ipa": 26,
    "def.micro": 28,
    "def.short": 80,
    "def.long": 220,
    "grammar.pattern": 50,
    "example.en.first": 80,
    "example.en": 110,
    "example.tr.first": 100,
    "example.tr": 130,
    "synonym": 16,
    "antonym": 16,
    "collocation": 28,
    "etymology": 200,
    "tr.gloss": 28,
    "tr.gloss_short": 16,
    "tr.alt": 24,
    "tr.note": 220,
    "tr.mistake.wrong": 80,
    "tr.mistake.right": 80,
    "tr.mistake.why": 200,
    "tr.mnemonic": 160,
    "quiz.cloze": 100,
    "quiz.distractor": 16,
}
COUNT_LIMITS = {
    "examples": (2, 3),
    "synonyms": (0, 5),
    "antonyms": (0, 3),
    "confusables": (0, 3),
    "collocations": (0, 5),
    "word_family": (0, 4),
    "tr.alt": (0, 3),
    "tr.mistakes": (0, 2),
    "topics": (1, 4),
}

# Kilit ekranında görünebilecek ilk örnekte asla olmaması gereken kelimeler (kısa, bilinçli liste).
LOCK_SCREEN_UNSAFE = {
    "sex", "sexual", "sexy", "porn", "naked", "nude", "kill", "killed", "murder", "suicide",
    "drug", "drugs", "cocaine", "heroin", "gun", "rape", "drunk", "bomb", "terrorist",
}
# LLM'lerin sık uydurduğu halk etimolojileri: bu kelimelerde etimoloji insan onayı ister.
FOLK_ETYMOLOGY_LEMMAS = {"posh", "golf", "tip", "ok", "okay", "sincere", "news", "shit", "fuck", "rule of thumb", "sos"}
CLOZE_BLANK = re.compile(r"_{3,}")
IPA_RE = re.compile(r"^/[^/]+/$")
# Ünlü harf dizileri ≈ hece çekirdekleri (ikili ünlüler tek dizi sayılır). Yalnızca vurgu uyarısı için kaba bir tahmin.
IPA_VOWEL_RUN_RE = re.compile(r"[aeiouæɑɒɔəɛɜɪʊʌɐɚɝ][aeiouæɑɒɔəɛɜɪʊʌɐɚɝː]*")
IPA_SYLLABIC_RE = re.compile(r"\u0329")  # n̩, l̩: hece oluşturan ünsüz (birleşen işaret U+0329)
ID_RE = re.compile(r"^en\.[a-z0-9_]+\.[a-z]+\.\d+$")
VALID_STATUSES_FOR_BUILD = {"validated", "reviewed", "approved"}


def _ipa_syllables(ipa: str) -> int:
    return len(IPA_VOWEL_RUN_RE.findall(ipa)) + len(IPA_SYLLABIC_RE.findall(ipa))


@dataclass(frozen=True)
class Issue:
    card_id: str
    severity: str  # error | warning
    code: str
    field: str
    message: str

    def __str__(self) -> str:
        return f"[{self.severity.upper():7}] {self.card_id} · {self.code} · {self.field}: {self.message}"


class _Collector:
    def __init__(self, card_id: str):
        self.card_id = card_id
        self.issues: list[Issue] = []

    def err(self, code: str, field: str, msg: str) -> None:
        self.issues.append(Issue(self.card_id, "error", code, field, msg))

    def warn(self, code: str, field: str, msg: str) -> None:
        self.issues.append(Issue(self.card_id, "warning", code, field, msg))

    def length(self, field: str, value: str | None, limit_key: str, *, severity: str = "error") -> None:
        if value is None:
            return
        n = glen(value)
        limit = LIMITS[limit_key]
        if n > limit:
            (self.err if severity == "error" else self.warn)("LEN", field, f"{n} > {limit} grafem: {value!r}")
        if value != value.strip() or not value.strip():
            self.err("BLANK", field, "boş ya da baş/son boşluklu metin")

    def count(self, field: str, items: list, key: str) -> None:
        lo, hi = COUNT_LIMITS[key]
        if not lo <= len(items) <= hi:
            self.err("COUNT", field, f"{len(items)} öğe; izin verilen {lo}–{hi}")


def parse_card(raw: dict) -> tuple[Card | None, list[Issue]]:
    card_id = str(raw.get("id", "<id yok>"))
    try:
        return Card.model_validate(raw), []
    except ValidationError as e:
        issues = [
            Issue(card_id, "error", "SCHEMA", ".".join(str(p) for p in err["loc"]), err["msg"])
            for err in e.errors()
        ]
        return None, issues


def validate_card(card: Card, tax: Taxonomy | None = None, l1_langs: tuple[str, ...] = ("tr",)) -> list[Issue]:
    tax = tax or load_taxonomy()
    c = _Collector(card.id)
    d = card.def_

    # --- Kimlik ve tür tutarlılığı
    if not ID_RE.match(card.id):
        c.err("ID_FORMAT", "id", "beklenen biçim en.<slug>.<pos>.<n>")
    else:
        _, slug, pos, sense = card.id.split(".")
        if slug != slugify_lemma(card.lemma):
            c.err("ID_SLUG", "id", f"slug {slug!r} ≠ lemma slug {slugify_lemma(card.lemma)!r}")
        if pos != card.pos:
            c.err("ID_POS", "id", f"id'deki pos {pos!r} ≠ {card.pos!r}")
        if int(sense) != card.sense_no:
            c.err("ID_SENSE", "id", f"id'deki anlam no {sense} ≠ {card.sense_no}")
    expected_pos = TYPE_POS.get(card.type)
    if expected_pos and card.pos not in expected_pos:
        c.err("TYPE_POS", "pos", f"{card.type} türü için pos {sorted(expected_pos)} olmalı")
    if card.type == "word" and card.pos in {"phv", "idm", "phr"}:
        c.err("TYPE_POS", "pos", f"tek kelime kartı pos={card.pos} olamaz")

    c.length("lemma", card.lemma, "lemma")
    # The app's "Söyle" practice compares speech recognition output with the lemma, so the lemma
    # must be plain speakable words: no "sb/sth", digits or slashes.
    if not SPEAKABLE_LEMMA.fullmatch(card.lemma):
        c.err("LEMMA_SPEAKABLE", "lemma", "lemma yalnız harf, boşluk, kesme ve tire içermeli (sb/sth, rakam, / yok)")
    c.length("sense_note", card.sense_note, "sense_note")

    # --- Telaffuz
    if card.type == "word":
        if card.ipa is None or not card.ipa.us:
            c.err("IPA_MISSING", "ipa.us", "tek kelime kartında US IPA zorunlu")
    if card.ipa:
        for side in ("us", "uk"):
            v = getattr(card.ipa, side)
            if v is None:
                continue
            c.length(f"ipa.{side}", v, "ipa")
            if not IPA_RE.match(v):
                c.err("IPA_FORMAT", f"ipa.{side}", "IPA /…/ arasında olmalı")
            elif "ˈ" not in v and " " not in card.lemma and _ipa_syllables(v) > 1:
                c.warn("IPA_STRESS", f"ipa.{side}", "vurgu işareti (ˈ) yok; tek heceli değilse ekleyin")

    # --- Tanımlar
    c.length("def.micro", d.micro, "def.micro")
    c.length("def.short", d.short, "def.short")
    c.length("def.long", d.long, "def.long")
    for name, text in (("def.micro", d.micro), ("def.short", d.short)):
        if contains_phrase(text, card.lemma):
            c.err("DEF_CIRCULAR", name, "tanım başlık kelimeyi içeriyor")
        elif contains_stem(text, card.lemma):
            c.warn("DEF_DERIVATIVE", name, "tanım başlık kelimenin bir türevini içeriyor olabilir")
        if text.rstrip().endswith("."):
            c.warn("DEF_PERIOD", name, "micro/short tanım nokta ile bitmemeli")
    if "(" in d.micro or ")" in d.micro:
        c.err("DEF_PARENS", "def.micro", "micro tanımda parantez kullanılmaz")
    # Uzun tanımın 2. cümlesi kullanım notu olabilir ("mitigate the risk…"); döngüsellik yalnızca ilk cümlede aranır.
    first_sentence = re.split(r"(?<=[.!?])\s", d.long.strip(), maxsplit=1)[0]
    if contains_phrase(first_sentence, card.lemma):
        c.warn("DEF_LONG_CIRCULAR", "def.long", "uzun tanımın ilk cümlesi başlık kelimeyi içeriyor")
    if card.grammar:
        c.length("grammar.pattern", card.grammar.pattern, "grammar.pattern")

    # --- Örnekler
    c.count("examples", card.examples, "examples")
    seen_en: set[str] = set()
    for i, ex in enumerate(card.examples):
        f = f"examples[{i}]"
        c.length(f"{f}.en", ex.en, "example.en.first" if i == 0 else "example.en")
        if not contains_phrase(ex.en, ex.focus):
            c.err("EX_FOCUS", f"{f}.focus", f"focus {ex.focus!r} cümlede birebir geçmiyor")
        if ex.en in seen_en:
            c.err("EX_DUP", f"{f}.en", "aynı örnek iki kez")
        seen_en.add(ex.en)
        if not ex.en.rstrip().endswith((".", "!", "?", "\"", "”")):
            c.warn("EX_PUNCT", f"{f}.en", "cümle noktalama ile bitmiyor")
        if "tr" in l1_langs:
            if not ex.tr:
                c.err("EX_TR_MISSING", f"{f}.tr", "Türkçe çeviri zorunlu (TR katmanı %100)")
            else:
                c.length(f"{f}.tr", ex.tr, "example.tr.first" if i == 0 else "example.tr")
                if not is_nfc(ex.tr):
                    c.err("TR_NFC", f"{f}.tr", "metin NFC normalize değil")
    if card.examples:
        first_words = set(re.findall(r"[a-z]+", card.examples[0].en.lower()))
        unsafe = first_words & LOCK_SCREEN_UNSAFE
        if unsafe:
            c.err("LOCK_UNSAFE", "examples[0].en", f"kilit ekranında görünebilecek örnekte uygunsuz kelime: {sorted(unsafe)}")

    # --- İlişkili kelimeler
    c.count("synonyms", card.synonyms, "synonyms")
    c.count("antonyms", card.antonyms, "antonyms")
    c.count("collocations", card.collocations, "collocations")
    c.count("word_family", card.word_family, "word_family")
    for i, s in enumerate(card.synonyms):
        c.length(f"synonyms[{i}]", s, "synonym", severity="warning")
    for i, s in enumerate(card.antonyms):
        c.length(f"antonyms[{i}]", s, "antonym", severity="warning")
    for i, s in enumerate(card.collocations):
        c.length(f"collocations[{i}]", s, "collocation", severity="warning")
    if card.lemma.lower() in {s.lower() for s in card.synonyms}:
        c.err("SYN_SELF", "synonyms", "eş anlamlılar başlık kelimeyi içeriyor")

    # --- Karışan kelimeler: uygulama bunları aynı gün yeni kelime olarak vermez ve eşi henüz
    # bilinmiyorsa çeldirici yapmaz. Derleyici lemma'yı başka kartlara bağlar (card_confusable).
    c.count("confusables", card.confusables, "confusables")
    seen_conf: set[str] = set()
    for i, s in enumerate(card.confusables):
        c.length(f"confusables[{i}]", s, "lemma")
        if not SPEAKABLE_LEMMA.fullmatch(s):
            c.err("CONF_FORMAT", f"confusables[{i}]", f"İngilizce kelime ya da öbek olmalı: {s!r}")
        if s.lower() == card.lemma.lower():
            c.err("CONF_SELF", f"confusables[{i}]", "kart kendisiyle karışan kelime olamaz")
        if s.lower() in seen_conf:
            c.err("CONF_DUP", f"confusables[{i}]", f"tekrar eden kelime: {s!r}")
        seen_conf.add(s.lower())

    # --- Etimoloji
    if card.etymology:
        c.length("etymology.text", card.etymology.text, "etymology")
        if card.etymology.confidence == "low":
            c.warn("ETYM_LOW", "etymology", "düşük güvenli etimoloji: doğrulayın ya da null yapın")
        if card.lemma.lower() in FOLK_ETYMOLOGY_LEMMAS and "etym_reviewed" not in card.meta.qa_flags:
            c.err("ETYM_FOLK_RISK", "etymology", "halk etimolojisi riski olan kelime: insan onayı (qa_flags: etym_reviewed) gerekli")

    # --- Ana dil katmanları
    for lang in l1_langs:
        layer = card.l1.get(lang)
        if layer is None:
            c.err("L1_MISSING", f"l1.{lang}", "ana dil katmanı yok")
            continue
        p = f"l1.{lang}"
        c.length(f"{p}.gloss", layer.gloss, "tr.gloss")
        # Widget anlamı "…" ile kesmez: tam anlam sığmazsa kısa biçimi gösterir (ogrenme_ilkeleri.md §2.1).
        if layer.gloss_short is None:
            if glen(layer.gloss) > LIMITS["tr.gloss_short"]:
                c.warn("GLOSS_SHORT_MISSING", f"{p}.gloss_short",
                       f"anlam {glen(layer.gloss)} grafem; widget için ≤{LIMITS['tr.gloss_short']} grafemlik kısa anlam yazın")
        else:
            c.length(f"{p}.gloss_short", layer.gloss_short, "tr.gloss_short")
            if glen(layer.gloss) <= LIMITS["tr.gloss_short"]:
                c.warn("GLOSS_SHORT_UNNEEDED", f"{p}.gloss_short", "anlam zaten kısa; gloss_short yalnızca uzun anlamda yazılır")
            if re.search(r"(…|\.\.\.)$", layer.gloss_short.strip()):
                c.err("GLOSS_SHORT_CUT", f"{p}.gloss_short", "kısa anlam kesilmiş olamaz; tam bir ifade yazın")
        c.count(f"{p}.alt", layer.alt, "tr.alt")
        for i, a in enumerate(layer.alt):
            c.length(f"{p}.alt[{i}]", a, "tr.alt")
        c.length(f"{p}.note", layer.note, "tr.note")
        c.length(f"{p}.mnemonic", layer.mnemonic, "tr.mnemonic")
        c.count(f"{p}.mistakes", layer.mistakes, "tr.mistakes")
        for i, m in enumerate(layer.mistakes):
            c.length(f"{p}.mistakes[{i}].wrong", m.wrong, "tr.mistake.wrong")
            c.length(f"{p}.mistakes[{i}].right", m.right, "tr.mistake.right")
            c.length(f"{p}.mistakes[{i}].why", m.why, "tr.mistake.why")
            if m.wrong.strip() == m.right.strip():
                c.err("MISTAKE_SAME", f"{p}.mistakes[{i}]", "yanlış ve doğru cümle aynı")
        texts = [layer.gloss, layer.gloss_short or "", *layer.alt, layer.note or "", layer.mnemonic or ""]
        if any(not is_nfc(t) for t in texts):
            c.err("TR_NFC", p, "metin NFC normalize değil")
        if layer.equivalence == "false_friend" and layer.false_friend is None:
            c.err("FF_MISSING", f"{p}.false_friend", "equivalence=false_friend ama false_friend nesnesi yok")
        if layer.false_friend is not None and layer.equivalence != "false_friend":
            c.warn("FF_EQUIV", f"{p}.equivalence", "false_friend dolu ama equivalence false_friend değil")
        if lang == "tr" and card.pos in {"v", "phv"}:
            head = layer.gloss.split(",")[0].strip()
            if not re.search(r"(mek|mak)$", head):
                c.warn("TR_VERB_FORM", f"{p}.gloss", f"fiil karşılığı -mek/-mak ile bitmeli: {head!r}")
            if layer.gloss_short and not re.search(r"(mek|mak)$", layer.gloss_short.strip()):
                c.warn("TR_VERB_FORM", f"{p}.gloss_short", f"fiil karşılığı -mek/-mak ile bitmeli: {layer.gloss_short!r}")
        if layer.gloss.strip().lower() == card.lemma.lower() and layer.equivalence != "cognate":
            c.warn("TR_GLOSS_SAME", f"{p}.gloss", "Türkçe karşılık İngilizce ile aynı (alıntı kelime değilse düzeltin)")

    # --- Etiketler ve taksonomi
    t = card.tags
    if t.primary_topic not in tax.categories:
        c.err("TOPIC_UNKNOWN", "tags.primary_topic", f"bilinmeyen kategori {t.primary_topic!r}")
    if t.primary_topic not in t.topics:
        c.err("TOPIC_PRIMARY", "tags.topics", "primary_topic, topics listesinde olmalı")
    c.count("tags.topics", t.topics, "topics")
    for tp in t.topics:
        if tp not in tax.categories:
            c.err("TOPIC_UNKNOWN", "tags.topics", f"bilinmeyen kategori {tp!r}")
    if len(set(t.topics)) != len(t.topics):
        c.err("TOPIC_DUP", "tags.topics", "tekrar eden kategori")
    for ex in t.exams:
        if ex not in tax.exam_tags:
            c.err("EXAM_UNKNOWN", "tags.exams", f"bilinmeyen sınav etiketi {ex!r}")
    # Hassasiyet 1 her kategoride olabilir: kişisel konu (ilişki, ayrılık, beden, alkol) ya da hafif
    # kaba kelime. Uygulama bu kartları kilit ekranında ve orta widget'ta varsayılan olarak göstermez.
    if t.sensitivity == 2:
        c.err("SENSITIVE_2", "tags.sensitivity", "hassasiyet 2 içerik MVP'de yayınlanmaz")
    cat = tax.categories.get(t.primary_topic)
    if cat is not None:
        lo, hi = tax.level_rank[cat.level_min], tax.level_rank[cat.level_max]
        if not lo <= card.level_rank <= hi:
            c.warn("LEVEL_RANGE", "level", f"{card.level} seviyesi {cat.id} kategorisinin aralığı dışında ({cat.level_min}–{cat.level_max})")
    if "coined" in t.flags:
        if t.exams:
            c.err("COINED_EXAM", "tags.exams", "uydurma/yeni türetilmiş kelime sınav paketine giremez")
        if "not_for_exams" not in t.flags:
            c.warn("COINED_FLAG", "tags.flags", "coined kelimelerde not_for_exams bayrağı beklenir")

    # --- Quiz
    if card.quiz:
        q = card.quiz
        c.length("quiz.cloze", q.cloze, "quiz.cloze")
        blanks = CLOZE_BLANK.findall(q.cloze)
        if len(blanks) != 1:
            c.err("QUIZ_BLANK", "quiz.cloze", f"tam olarak bir boşluk (___) olmalı, {len(blanks)} bulundu")
        if contains_phrase(q.cloze, q.answer):
            c.err("QUIZ_LEAK", "quiz.cloze", "cevap cümlenin içinde görünüyor")
        if len(q.distractors) != 3:
            c.err("QUIZ_DISTRACTORS", "quiz.distractors", f"3 çeldirici olmalı, {len(q.distractors)} var")
        lowered = [x.strip().lower() for x in q.distractors]
        if q.answer.strip().lower() in lowered:
            c.err("QUIZ_ANSWER_IN_DISTRACTORS", "quiz.distractors", "cevap çeldiriciler arasında")
        if len(set(lowered)) != len(lowered):
            c.err("QUIZ_DISTRACTOR_DUP", "quiz.distractors", "tekrar eden çeldirici")
        for i, x in enumerate(q.distractors):
            c.length(f"quiz.distractors[{i}]", x, "quiz.distractor")
    else:
        c.warn("QUIZ_MISSING", "quiz", "quiz yok: etkileşimli widget sorusunda kullanılamaz")

    return c.issues


def validate_cards(raw_cards: list[dict], *, l1_langs: tuple[str, ...] = ("tr",)) -> tuple[list[Card], list[Issue]]:
    """Kartları ayrıştırır ve doğrular; ayrıca veri seti genelinde tekrarları kontrol eder."""
    tax = load_taxonomy()
    cards: list[Card] = []
    issues: list[Issue] = []
    for raw in raw_cards:
        card, parse_issues = parse_card(raw)
        issues.extend(parse_issues)
        if card is not None:
            cards.append(card)
            issues.extend(validate_card(card, tax, l1_langs))

    id_counts = Counter(c.id for c in cards)
    for cid, n in id_counts.items():
        if n > 1:
            issues.append(Issue(cid, "error", "DUP_ID", "id", f"{n} kez tekrar ediyor"))
    short_owner: dict[str, str] = {}
    example_owner: dict[str, str] = {}
    for card in cards:
        key = card.def_.short.strip().lower()
        if key in short_owner:
            issues.append(Issue(card.id, "warning", "DUP_DEF", "def.short", f"{short_owner[key]} ile aynı tanım"))
        else:
            short_owner[key] = card.id
        for ex in card.examples:
            k = ex.en.strip().lower()
            if k in example_owner and example_owner[k] != card.id:
                issues.append(Issue(card.id, "warning", "DUP_EXAMPLE", "examples", f"{example_owner[k]} ile aynı örnek"))
            else:
                example_owner[k] = card.id
    issues.extend(distractor_repeat_issues(cards))
    return cards, issues


# Bir çeldirici veri setindeki soruların en fazla bu kadarında geçebilir: max(4, %5). Daha sık
# tekrar eden bir şıkkın cevap olmadığını öğrenci ezberler ve soru bir şey sınamaz.
DISTRACTOR_REPEAT_MIN = 4
DISTRACTOR_REPEAT_SHARE = 0.05


def distractor_repeat_issues(cards: list[Card]) -> list[Issue]:
    users: dict[str, list[str]] = {}
    quiz_count = 0
    for card in cards:
        if card.quiz is None:
            continue
        quiz_count += 1
        for d in {d.strip().lower() for d in card.quiz.distractors}:
            users.setdefault(d, []).append(card.id)
    limit = max(DISTRACTOR_REPEAT_MIN, math.ceil(quiz_count * DISTRACTOR_REPEAT_SHARE))
    issues: list[Issue] = []
    for d, ids in sorted(users.items()):
        if len(ids) > limit:
            sample = ", ".join(ids[:3])
            issues.append(Issue(
                ids[0], "warning", "QUIZ_DISTRACTOR_REPEAT", "quiz.distractors",
                f"'{d}' {len(ids)} soruda çeldirici (sınır {limit}; ör. {sample})",
            ))
    return issues


def load_raw_cards(path: Path) -> tuple[list[dict], tuple[str, ...]]:
    """Bir veri seti dosyasını (entries listesi) ya da kart JSON'larından oluşan bir klasörü okur."""
    path = Path(path)
    if path.is_dir():
        files = sorted(path.glob("*.json"))
        raws: list[dict] = []
        for f in files:
            data = json.loads(f.read_text(encoding="utf-8"))
            raws.extend(data["entries"] if isinstance(data, dict) and "entries" in data else [data])
        return raws, ("tr",)
    data = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(data, list):
        return data, ("tr",)
    return data["entries"], tuple(data.get("l1_langs", ["tr"]))


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Kartları deterministik kurallarla doğrular.")
    ap.add_argument("path", type=Path, help="veri seti JSON dosyası ya da kart JSON klasörü")
    ap.add_argument("--strict", action="store_true", help="uyarıları da başarısızlık say")
    ap.add_argument("--json", action="store_true", help="sorunları JSON olarak yaz")
    args = ap.parse_args(argv)

    raws, langs = load_raw_cards(args.path)
    cards, issues = validate_cards(raws, l1_langs=langs)
    errors = [i for i in issues if i.severity == "error"]
    warnings = [i for i in issues if i.severity == "warning"]
    if args.json:
        print(json.dumps([i.__dict__ for i in issues], ensure_ascii=False, indent=1))
    else:
        for i in issues:
            print(i)
        print(f"\n{len(raws)} kart · {len(cards)} şemadan geçti · {len(errors)} hata · {len(warnings)} uyarı")
    if errors or (args.strict and warnings):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
