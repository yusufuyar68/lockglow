"""Every part-of-speech code the schema allows has a Turkish name in the app.

The app shows `WidgetWord.pos` through `CardPartOfSpeech.turkish` (ios/App/CardDetailViews.swift);
a code without a case is shown as the English code ("conj" on the albeit page, 2026-10-26).
"""

import re
import typing
from pathlib import Path

from vocabpipe.schema import Pos

SWIFT = Path(__file__).resolve().parents[2] / "ios" / "App" / "CardDetailViews.swift"


def _swift_cases() -> set[str]:
    text = SWIFT.read_text(encoding="utf-8")
    start = text.index("enum CardPartOfSpeech")
    body = text[start:text.index("default:", start)]
    return set(re.findall(r'case "([a-z]+)":', body))


def test_every_schema_pos_has_a_turkish_name():
    missing = set(typing.get_args(Pos)) - _swift_cases()
    assert not missing, f"CardPartOfSpeech has no Turkish name for: {sorted(missing)}"
