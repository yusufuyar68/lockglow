"""Kişisel derleme: taslak kart akışlarını tek bir content.sqlite + seed_words.json'da birleştirir.

Girdi: `content/drafts/<set>/<akış>/part_*.json` (her akış bir klasör, her dosya bir veri seti).
Yayın derlemesi DEĞİLDİR:
- taslaklar (`draft`) ve örnek kartlar (`sample`) da girer, çünkü editör denetimi henüz yapılmadı;
- tüm kartlar ücretsizdir (abonelik yok);
- yeni ID'ler önce seviyeye (A1 → C2), seviye içinde akışlar arasında dönüşümlü sırayla verilir.
  Kartlarda frekans verisi olmadığı için uygulama akışı ID sırasıyla ilerler; böylece akış
  alfabetik değil, konular karışık ilerler.
ID'ler kayda (data/id_registry.json) yazılır ve sonraki derlemelerde değişmez: uygulamadaki
ilerleme kelime ID'sine bağlıdır.

Örnek:
    python -m vocabpipe.personal ../content/drafts/kisisel_v1 \
        --out ../ios/App/Resources/content.sqlite --seed-out ../ios/Widgets/Resources/seed_words.json
"""

from __future__ import annotations

import argparse
import json
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

from .build_db import REGISTRY_PATH, BuildError, run, write_json_atomic
from .schema import LEVEL_RANK
from .validate import load_raw_cards

PERSONAL_STATUSES = {"sample", "draft", "validated", "reviewed", "approved"}


def load_streams(root: Path) -> dict[str, list[dict]]:
    """Akış klasörü adı → kartlar (dosya adı sırasıyla, dosya içi sıra korunur)."""
    streams: dict[str, list[dict]] = {}
    for folder in sorted(p for p in Path(root).iterdir() if p.is_dir()):
        raws, _ = load_raw_cards(folder)
        if raws:
            streams[folder.name] = raws
    return streams


def interleave(streams: dict[str, list[dict]]) -> tuple[list[dict], list[str]]:
    """Kartları seviyeye göre gruplar, seviye içinde akışları dönüşümlü sıralar.

    Aynı `id` birden fazla akışta varsa ilk akıştaki kalır. Dönüş: (sıralı kartlar, atılan
    tekrarların açıklamaları).
    """
    seen: dict[str, str] = {}
    duplicates: list[str] = []
    by_level: dict[int, dict[str, list[dict]]] = {}
    for name, raws in streams.items():
        for raw in raws:
            cid = raw.get("id", "")
            if cid in seen:
                duplicates.append(f"{cid}: {name} akışındaki tekrar atıldı ({seen[cid]} tutuldu)")
                continue
            seen[cid] = name
            rank = LEVEL_RANK.get(raw.get("level", ""), len(LEVEL_RANK) + 1)
            by_level.setdefault(rank, {}).setdefault(name, []).append(raw)

    ordered: list[dict] = []
    for rank in sorted(by_level):
        queues = [list(q) for q in by_level[rank].values()]
        while any(queues):
            for q in queues:
                if q:
                    ordered.append(q.pop(0))
    return ordered, duplicates


def build(
    root: Path,
    *,
    out: Path,
    seed_out: Path | None,
    registry_path: Path = REGISTRY_PATH,
    content_version: str,
    write_registry: bool = True,
    seed_size: int = 400,
) -> dict:
    streams = load_streams(root)
    if not streams:
        raise BuildError(f"{root}: akış klasörü bulunamadı")
    ordered, duplicates = interleave(streams)
    with tempfile.TemporaryDirectory(prefix="vocabpipe-personal-") as tmp:
        combined = Path(tmp) / "kisisel_kaynak.json"
        write_json_atomic(combined, {"schema_version": "1.0", "l1_langs": ["tr"], "entries": ordered})
        result = run(
            [combined],
            out=out,
            seed_out=seed_out,
            registry_path=registry_path,
            include_status=PERSONAL_STATUSES,
            content_version=content_version,
            seed_size=seed_size,
            write_registry=write_registry,
            all_free=True,
            ids_in_input_order=True,
        )
    result["streams"] = {name: len(raws) for name, raws in streams.items()}
    result["duplicates"] = duplicates
    return result


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Taslak akışlarından kişisel content.sqlite ve seed_words.json üretir.")
    ap.add_argument("root", type=Path, help="akış klasörlerini içeren klasör (ör. ../content/drafts/kisisel_v1)")
    ap.add_argument("--out", type=Path, default=Path("build/content.sqlite"))
    ap.add_argument("--seed-out", type=Path, default=Path("build/seed_words.json"))
    ap.add_argument("--seed-size", type=int, default=400)
    ap.add_argument("--registry", type=Path, default=REGISTRY_PATH)
    ap.add_argument("--no-registry-write", action="store_true", help="ID kaydını diske yazma (deneme amaçlı)")
    ap.add_argument(
        "--content-version",
        default=datetime.now(timezone.utc).strftime("%Y.%m.%d-kisisel"),
        help="ör. 2026.10.11-kisisel",
    )
    args = ap.parse_args(argv)
    try:
        result = build(
            args.root,
            out=args.out,
            seed_out=args.seed_out,
            registry_path=args.registry,
            content_version=args.content_version,
            write_registry=not args.no_registry_write,
            seed_size=args.seed_size,
        )
    except BuildError as e:
        print(f"HATA: {e}", file=sys.stderr)
        return 1
    print(json.dumps(result, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
