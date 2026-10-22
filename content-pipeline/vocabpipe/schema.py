"""Kart şeması v1.0 (bkz. raporlar/07_icerik_stratejisi.md §4).

Pydantic yalnızca yapı ve tür kontrolü yapar. Uzunluk sınırları, içerik kuralları ve
taksonomi kontrolleri validate.py'dedir; böylece tek bir kartta tüm sorunlar birlikte raporlanır.
"""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

Level = Literal["A1", "A2", "B1", "B2", "C1", "C2", "S"]
LEVEL_RANK: dict[str, int] = {"A1": 1, "A2": 2, "B1": 3, "B2": 4, "C1": 5, "C2": 6, "S": 7}

CardType = Literal["word", "phrasal_verb", "idiom", "collocation", "proverb", "phrase"]
Pos = Literal["n", "v", "adj", "adv", "prep", "conj", "pron", "det", "interj", "phv", "idm", "phr"]
LevelSource = Literal["list", "editorial_estimate", "editor_verified"]
Register = Literal["neutral", "formal", "informal", "literary", "slang", "technical"]
Equivalence = Literal["full", "partial", "cognate", "false_friend", "none"]
Confidence = Literal["high", "medium", "low"]
Status = Literal["draft", "validated", "reviewed", "approved", "sample", "rejected"]

# Eski biçim: karışan kelime tags.flags içinde "confusable:<kelime>" olarak yazılırdı. Yeni kartlar
# `confusables` alanını kullanır; derleyici ikisini birleştirir (Card.confusable_lemmas).
CONFUSABLE_FLAG = "confusable:"

# Hangi kart türünün hangi sözcük türüyle gelmesi gerektiği.
TYPE_POS: dict[str, set[str]] = {
    "phrasal_verb": {"phv"},
    "idiom": {"idm"},
    "proverb": {"phr", "idm"},
    "collocation": {"phr"},
    "phrase": {"phr"},
}


class _Strict(BaseModel):
    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class Freq(_Strict):
    rank: int | None = None
    zipf: float | None = None


class Ipa(_Strict):
    us: str | None = None
    uk: str | None = None


class Definitions(_Strict):
    micro: str
    short: str
    long: str


class Grammar(_Strict):
    pattern: str


class Example(_Strict):
    en: str
    tr: str | None = None
    # "register" BaseModel'in ABCMeta.register metodunu gölgelemesin diye Python adı register_.
    register_: Register = Field("neutral", alias="register")
    focus: str


class WordFamilyItem(_Strict):
    lemma: str
    pos: str


class Etymology(_Strict):
    text: str
    origin: str | None = None
    confidence: Confidence


class FalseFriend(_Strict):
    tr_word: str
    tr_means: str
    en_for_that: str


class Mistake(_Strict):
    wrong: str
    right: str
    why: str


class L1Layer(_Strict):
    gloss: str
    # Widget'ta "…" ile kesilmeyecek kısa anlam (≤16 grafem). Yalnızca gloss 16 grafemi geçince yazılır.
    gloss_short: str | None = None
    alt: list[str] = Field(default_factory=list)
    equivalence: Equivalence
    false_friend: FalseFriend | None = None
    note: str | None = None
    mistakes: list[Mistake] = Field(default_factory=list)
    mnemonic: str | None = None


class Tags(_Strict):
    primary_topic: str
    topics: list[str]
    exams: list[str] = Field(default_factory=list)
    register_: Register = Field("neutral", alias="register")
    vibes: list[str] = Field(default_factory=list)
    flags: list[str] = Field(default_factory=list)
    sensitivity: int = Field(ge=0, le=2)


class Quiz(_Strict):
    cloze: str
    answer: str
    distractors: list[str]


class Meta(_Strict):
    status: Status
    qa_flags: list[str] = Field(default_factory=list)
    prompt_ver: str | None = None
    model: str | None = None
    reviewer: str | None = None
    reviewed_at: str | None = None
    content_ver: str | None = None
    source: str | None = None
    critic: dict | None = None


class Card(_Strict):
    id: str
    lemma: str
    type: CardType
    pos: Pos
    sense_no: int = Field(ge=1)
    sense_note: str | None = None
    level: Level
    level_source: LevelSource
    freq: Freq | None = None
    ipa: Ipa | None = None
    def_: Definitions = Field(alias="def")
    grammar: Grammar | None = None
    examples: list[Example]
    synonyms: list[str] = Field(default_factory=list)
    antonyms: list[str] = Field(default_factory=list)
    # Öğrencinin bu kelimeyle karıştırdığı İngilizce kelimeler (borrow → lend). Başka kartın
    # lemma'sı olabilir ya da destede olmayan bir kelime.
    confusables: list[str] = Field(default_factory=list)
    collocations: list[str] = Field(default_factory=list)
    word_family: list[WordFamilyItem] = Field(default_factory=list)
    etymology: Etymology | None = None
    l1: dict[str, L1Layer]
    tags: Tags
    quiz: Quiz | None = None
    meta: Meta

    @property
    def level_rank(self) -> int:
        return LEVEL_RANK[self.level]

    def confusable_lemmas(self) -> list[str]:
        """`confusables` ve eski biçimdeki `confusable:<kelime>` bayrakları, sırası korunarak, tekrarsız."""
        legacy = [f.split(":", 1)[1].strip() for f in self.tags.flags if f.startswith(CONFUSABLE_FLAG)]
        seen: set[str] = set()
        out: list[str] = []
        for lemma in [*self.confusables, *legacy]:
            if lemma and lemma.lower() not in seen:
                seen.add(lemma.lower())
                out.append(lemma)
        return out

    def to_json_dict(self) -> dict:
        """Diske/veritabanına yazılacak hali: 'def' takma adıyla, boş varsayılanlar dahil."""
        return self.model_dump(by_alias=True, mode="json")


class Dataset(_Strict):
    schema_version: str
    l1_langs: list[str]
    generated_on: str | None = None
    entries: list[Card]
