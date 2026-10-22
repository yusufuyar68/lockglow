"""Metin yardımcıları: grafem uzunluğu, Türkçe güvenli fold(), kelime sınırı araması.

fold() algoritması docs/contract/content-db.md §4 ile birebir aynıdır; Swift tarafı
(VocabKit/TextFold) aynı test vektörlerini kullanır. Değiştirirsen ikisini birlikte değiştir.
"""

from __future__ import annotations

import re
import unicodedata

# Büyük/küçük harf dönüşümünden ÖNCE uygulanır; böylece cihaz yerel ayarından bağımsızdır.
_TR_FOLD = str.maketrans(
    {
        "ı": "i", "İ": "i", "I": "i",
        "ç": "c", "Ç": "c",
        "ğ": "g", "Ğ": "g",
        "ö": "o", "Ö": "o",
        "ş": "s", "Ş": "s",
        "ü": "u", "Ü": "u",
        "â": "a", "Â": "a",
        "î": "i", "Î": "i",
        "û": "u", "Û": "u",
    }
)

_WS = re.compile(r"\s+")

# fold() için boşluk: Unicode White_Space özelliği (Swift'in `isWhitespace`'i). Python'un `\s`'i ve
# `str.strip()`'i U+001C–U+001F'yi de boşluk sayar, Swift saymaz; bu yüzden küme açıkça yazıldı.
FOLD_WHITESPACE = (
    "\t\n\v\f\r \x85\xa0 "
    "           "
    "    　"
)
_FOLD_WS = re.compile("[" + re.escape(FOLD_WHITESPACE) + "]+")


def fold(text: str) -> str:
    s = unicodedata.normalize("NFC", text).translate(_TR_FOLD).lower()
    s = "".join(ch for ch in unicodedata.normalize("NFKD", s) if not unicodedata.combining(ch))
    # Son sigma: Python'un lower()'ı sözcük sonundaki Σ'yı ς yapar, Swift σ; NFKD de ϲ'yi ς yapar.
    # Arama için hepsi σ.
    s = s.replace("ς", "σ")
    return _FOLD_WS.sub(" ", s).strip(" ")


def glen(text: str) -> int:
    """Yaklaşık grafem sayısı: birleşik işaretleri ve ZWJ/VS16'yı saymaz.

    Kart metinleri Latin/Türkçe/IPA olduğu için bu yaklaşım yeterli; emoji kullanılmıyor.
    """
    s = unicodedata.normalize("NFC", text)
    return sum(1 for ch in s if not unicodedata.combining(ch) and ch not in "‍️")


def contains_phrase(text: str, phrase: str) -> bool:
    """Kelime sınırlarına saygı göstererek, büyük/küçük harf duyarsız arama."""
    if not phrase.strip():
        return False
    pattern = r"(?<!\w)" + re.escape(phrase.strip()) + r"(?!\w)"
    return re.search(pattern, text, flags=re.IGNORECASE) is not None


def stem_prefix(lemma: str) -> str | None:
    """Türev kontrolü için kaba kök: tek kelimelik ve ≥6 harfli lemmalarda son 2 harfi at."""
    if " " in lemma or len(lemma) < 6:
        return None
    return lemma[:-2].lower()


def contains_stem(text: str, lemma: str) -> bool:
    stem = stem_prefix(lemma)
    if stem is None:
        return False
    return re.search(r"(?<!\w)" + re.escape(stem), text, flags=re.IGNORECASE) is not None


def is_nfc(text: str) -> bool:
    return unicodedata.is_normalized("NFC", text)


def slugify_lemma(lemma: str) -> str:
    s = lemma.lower().replace("-", " ").replace("'", "")
    s = _WS.sub("_", s.strip())
    return re.sub(r"[^a-z0-9_]", "", s)
