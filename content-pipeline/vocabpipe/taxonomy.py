"""data/taxonomy.json yükleyicisi ve kategori bazında ücretsiz kart kuralı."""

from __future__ import annotations

import json
import math
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
TAXONOMY_PATH = DATA_DIR / "taxonomy.json"


@dataclass(frozen=True)
class Category:
    id: str
    grp: str
    name_en: str
    name_tr: str
    level_min: str
    level_max: str
    mvp: int
    full: int
    access: str  # F | S | P
    hero: bool
    explicit_free_count: int | None
    allows_sensitivity_1: bool
    sort: int

    def free_count(self, total_cards: int) -> int:
        """Bu kategoride kaç kartın ücretsiz olduğu (kategori içi sıraya göre ilk N)."""
        if self.access == "F":
            return total_cards
        if self.explicit_free_count is not None:
            return min(self.explicit_free_count, total_cards)
        if self.access == "S":
            return min(total_cards, max(20, math.ceil(total_cards * 0.30)))
        return min(10, total_cards)  # P: 10 kartlık tadımlık


@dataclass(frozen=True)
class Taxonomy:
    categories: dict[str, Category]
    exam_tags: frozenset[str]
    level_rank: dict[str, int]


@lru_cache(maxsize=4)
def load_taxonomy(path: Path = TAXONOMY_PATH) -> Taxonomy:
    raw = json.loads(Path(path).read_text(encoding="utf-8"))
    cats: dict[str, Category] = {}
    for i, c in enumerate(raw["categories"]):
        if c["id"] in cats:
            raise ValueError(f"taxonomy: tekrar eden kategori id: {c['id']}")
        if c["access"] not in {"F", "S", "P"}:
            raise ValueError(f"taxonomy: geçersiz access {c['access']} ({c['id']})")
        cats[c["id"]] = Category(
            id=c["id"],
            grp=c["grp"],
            name_en=c["name_en"],
            name_tr=c["name_tr"],
            level_min=c["levels"][0],
            level_max=c["levels"][1],
            mvp=c["mvp"],
            full=c["full"],
            access=c["access"],
            hero=bool(c.get("hero", False)),
            explicit_free_count=c.get("free_count"),
            allows_sensitivity_1=bool(c.get("allows_sensitivity_1", False)),
            sort=i,
        )
    level_rank = {lv["id"]: lv["rank"] for lv in raw["levels"]}
    return Taxonomy(categories=cats, exam_tags=frozenset(raw["exam_tags"]), level_rank=level_rank)
