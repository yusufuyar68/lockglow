import copy
import json
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

SAMPLE = ROOT.parent / "veri" / "ornek_kelime_seti_25.json"


@pytest.fixture(scope="session")
def sample_entries() -> list[dict]:
    return json.loads(SAMPLE.read_text(encoding="utf-8"))["entries"]


@pytest.fixture
def card(sample_entries) -> dict:
    """Değiştirilebilir bir kopya: en.mitigate.v.1"""
    by_id = {e["id"]: e for e in sample_entries}
    return copy.deepcopy(by_id["en.mitigate.v.1"])
