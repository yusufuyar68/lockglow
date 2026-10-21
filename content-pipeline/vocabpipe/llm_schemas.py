"""Claude yapılandırılmış çıktı (output_config.format) şemaları ve yanıt modelleri.

API, JSON Schema'da minLength/maxLength/minimum gibi kısıtları desteklemez; uzunluk sınırları
yanıt geldikten sonra validate.py'de uygulanır. Her nesnede additionalProperties=false ve tüm
alanlar required olmalı; boş bırakılabilen alanlar anyOf [..., null] ile ifade edilir.
"""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

LEVELS = ["A1", "A2", "B1", "B2", "C1", "C2", "S"]
REGISTERS = ["neutral", "formal", "informal", "literary", "slang", "technical"]
CRITERIA = [
    "sense_accuracy",
    "definition_clarity",
    "widget_fit",
    "example_naturalness",
    "example_safety",
    "tr_gloss",
    "tr_example",
    "learner_value",
    "etymology",
    "level_tags",
    "pronunciation",
    "quiz_validity",
]
# quiz_validity kritik: kritik olmasaydı tek başına 0 alan bir quiz 22/24 ile PASS olurdu.
CRITICAL_CRITERIA = {"sense_accuracy", "example_safety", "tr_gloss", "etymology", "quiz_validity"}
MAX_TOTAL = 2 * len(CRITERIA)
PASS_THRESHOLD = MAX_TOTAL - 4  # 20/24; eski 18/22 ile aynı pay: en fazla 4 puan kayıp


def _obj(props: dict) -> dict:
    return {"type": "object", "properties": props, "required": list(props), "additionalProperties": False}


def _nullable(schema: dict) -> dict:
    return {"anyOf": [schema, {"type": "null"}]}


_STR = {"type": "string"}
_STR_LIST = {"type": "array", "items": _STR}

STAGE_A_SCHEMA = _obj(
    {
        "skip_reason": _nullable(_STR),
        "sense_note": _nullable(_STR),
        "level": {"type": "string", "enum": LEVELS},
        "level_confidence": {"type": "string", "enum": ["high", "medium", "low"]},
        "ipa": _obj({"us": _nullable(_STR), "uk": _nullable(_STR)}),
        "def": _obj({"micro": _STR, "short": _STR, "long": _STR}),
        "grammar_pattern": _nullable(_STR),
        "examples": {
            "type": "array",
            "items": _obj(
                {"en": _STR, "register": {"type": "string", "enum": REGISTERS}, "focus": _STR}
            ),
        },
        "synonyms": _STR_LIST,
        "antonyms": _STR_LIST,
        "collocations": _STR_LIST,
        "word_family": {"type": "array", "items": _obj({"lemma": _STR, "pos": _STR})},
        "etymology": _nullable(
            _obj({"text": _STR, "origin": _nullable(_STR), "confidence": {"type": "string", "enum": ["high", "medium", "low"]}})
        ),
        "extra_topics": _STR_LIST,
        "register": {"type": "string", "enum": REGISTERS},
        "vibes": _STR_LIST,
        "flags": _STR_LIST,
        "sensitivity": {"type": "integer", "enum": [0, 1, 2]},
        "quiz": _obj({"cloze": _STR, "answer": _STR, "distractors": _STR_LIST}),
        "uncertain_fields": _STR_LIST,
    }
)

STAGE_B_SCHEMA = _obj(
    {
        "gloss": _STR,
        "alt": _STR_LIST,
        "equivalence": {"type": "string", "enum": ["full", "partial", "cognate", "false_friend", "none"]},
        "false_friend": _nullable(_obj({"tr_word": _STR, "tr_means": _STR, "en_for_that": _STR})),
        "examples_tr": _STR_LIST,
        "note": _nullable(_STR),
        "mistakes": {"type": "array", "items": _obj({"wrong": _STR, "right": _STR, "why": _STR})},
        "mnemonic": _nullable(_STR),
        "backtranslation": _STR_LIST,
        "uncertain_fields": _STR_LIST,
    }
)

_SCORE = _obj({"score": {"type": "integer", "enum": [0, 1, 2]}, "reason": _STR})
STAGE_C_SCHEMA = _obj(
    {
        "scores": _obj({name: _SCORE for name in CRITERIA}),
        "verdict": {"type": "string", "enum": ["PASS", "FIX", "REJECT"]},
        "issues": {
            "type": "array",
            "items": _obj(
                {
                    "field": _STR,
                    "severity": {"type": "string", "enum": ["critical", "major", "minor"]},
                    "problem": _STR,
                    "suggested_fix": _STR,
                }
            ),
        },
    }
)


# ---- Yanıtların Python tarafında doğrulanması (şema API'de garanti, burada tür güvenliği için)

class _M(BaseModel):
    model_config = ConfigDict(extra="forbid")


class _Ipa(_M):
    us: str | None
    uk: str | None


class _Def(_M):
    micro: str
    short: str
    long: str


class _ExA(_M):
    en: str
    register_: str = Field(alias="register")
    focus: str

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class _WF(_M):
    lemma: str
    pos: str


class _Etym(_M):
    text: str
    origin: str | None
    confidence: Literal["high", "medium", "low"]


class _Quiz(_M):
    cloze: str
    answer: str
    distractors: list[str]


class StageAOut(_M):
    skip_reason: str | None
    sense_note: str | None
    level: str
    level_confidence: Literal["high", "medium", "low"]
    ipa: _Ipa
    def_: _Def
    grammar_pattern: str | None
    examples: list[_ExA]
    synonyms: list[str]
    antonyms: list[str]
    collocations: list[str]
    word_family: list[_WF]
    etymology: _Etym | None
    extra_topics: list[str]
    register_: str = Field(alias="register")
    vibes: list[str]
    flags: list[str]
    sensitivity: int
    quiz: _Quiz
    uncertain_fields: list[str]

    model_config = ConfigDict(extra="forbid", populate_by_name=True)

    @classmethod
    def parse_json(cls, data: dict) -> "StageAOut":
        data = dict(data)
        data["def_"] = data.pop("def")
        return cls.model_validate(data)


class _FF(_M):
    tr_word: str
    tr_means: str
    en_for_that: str


class _Mistake(_M):
    wrong: str
    right: str
    why: str


class StageBOut(_M):
    gloss: str
    alt: list[str]
    equivalence: Literal["full", "partial", "cognate", "false_friend", "none"]
    false_friend: _FF | None
    examples_tr: list[str]
    note: str | None
    mistakes: list[_Mistake]
    mnemonic: str | None
    backtranslation: list[str]
    uncertain_fields: list[str]


class _Score(_M):
    score: int
    reason: str


class _CIssue(_M):
    field: str
    severity: Literal["critical", "major", "minor"]
    problem: str
    suggested_fix: str


class StageCOut(_M):
    scores: dict[str, _Score]
    verdict: Literal["PASS", "FIX", "REJECT"]
    issues: list[_CIssue]

    def total(self) -> int:
        return sum(s.score for s in self.scores.values())

    def computed_verdict(self) -> str:
        """Modelin kararından bağımsız, kurala dayalı karar. İkisinden katı olanı uygulanır."""
        if any(self.scores[name].score == 0 for name in CRITICAL_CRITERIA if name in self.scores):
            return "REJECT" if any(i.severity == "critical" for i in self.issues) else "FIX"
        if self.total() >= PASS_THRESHOLD and not any(i.severity == "critical" for i in self.issues):
            return "PASS"
        return "FIX"

    def final_verdict(self) -> str:
        order = {"PASS": 0, "FIX": 1, "REJECT": 2}
        return max(self.verdict, self.computed_verdict(), key=order.__getitem__)
