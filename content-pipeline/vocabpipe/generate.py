"""Claude Message Batches ile kart üretimi: A (İngilizce çekirdek) → B (Türkçe katman) → C (eleştirmen).

    python -m vocabpipe.generate prepare plans/pilot_50.csv --run pilot1
    python -m vocabpipe.generate submit  --run pilot1 --stage a --dry-run   # API'ye gitmez, istekleri yazar
    python -m vocabpipe.generate submit  --run pilot1 --stage a
    python -m vocabpipe.generate collect --run pilot1 --stage a --wait
    ... aynısı b ve c için
    python -m vocabpipe.generate status  --run pilot1

Notlar:
- Batch API yanıtları %50 indirimli ve asenkron (çoğu 1 saat içinde, en fazla 24 saat).
- Sunucu taraflı "fallbacks" parametresi Batch API'de reddedilir. Bu yüzden reddedilen (refusal)
  kartlar failures.jsonl'a yazılır; editör bakar, gerekirse planı düzeltip yeniden çalıştırır.
- Sonuçlar herhangi bir sırayla gelebilir; her şey custom_id ile eşlenir.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
import time
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

from pydantic import ValidationError

from .build_db import write_json_atomic
from .llm_schemas import STAGE_A_SCHEMA, STAGE_B_SCHEMA, STAGE_C_SCHEMA, StageAOut, StageBOut, StageCOut
from .prompts import PROMPT_VERSION, USER_A, USER_B, USER_C, system_a, system_b, system_c
from .schema import LEVEL_RANK, TYPE_POS
from .taxonomy import load_taxonomy
from .textutil import slugify_lemma
from .validate import validate_cards

RUNS_DIR = Path(__file__).resolve().parent.parent / "runs"
DEFAULT_MODEL = "claude-opus-5-5"
DEFAULT_EFFORT = "medium"
MAX_TOKENS = 16000  # Opus 5.5'te düşünme her zaman açık ve max_tokens'a sayılır
BATCH_CHUNK = 5000
POLL_SECONDS = 60
VALID_POS = {"n", "v", "adj", "adv", "prep", "conj", "pron", "det", "interj", "phv", "idm", "phr"}
VALID_TYPES = {"word", "phrasal_verb", "idiom", "collocation", "proverb", "phrase"}

# Kaba maliyet tahmini için Batch fiyatları ($/MTok, giriş/çıkış). Kesin fiyat: platform.claude.com/docs/en/about-claude/pricing
BATCH_PRICES = {
    "claude-opus-5-5": (2.00, 10.00),
    "claude-sonnet-5-5": (1.00, 5.00),
    "claude-haiku-5-5": (0.05, 0.25),
}
# Aşama başına tahmini çıkış token'ı (düşünme dahil).
EST_OUTPUT_TOKENS = {"a": 1800, "b": 1100, "c": 900}


# ------------------------------------------------------------------ plan

@dataclass
class PlanRow:
    lemma: str
    pos: str
    type: str
    sense_no: int
    sense_hint: str
    target_level: str
    level_source: str
    primary_topic: str
    topics: list[str]
    exams: list[str]
    zipf: float | None = None
    freq_rank: int | None = None
    ipa_us_ref: str | None = None
    ipa_uk_ref: str | None = None
    confusables: list[str] = field(default_factory=list)
    notes: str = ""

    @property
    def card_id(self) -> str:
        return f"en.{slugify_lemma(self.lemma)}.{self.pos}.{self.sense_no}"


def _split(v: str | None) -> list[str]:
    return [x.strip() for x in (v or "").split("|") if x.strip()]


def _opt(v: str | None) -> str | None:
    v = (v or "").strip()
    return v or None


def read_plan(path: Path) -> list[PlanRow]:
    """Plan CSV'si (UTF-8). Liste alanları '|' ile ayrılır. Sütunlar: README'deki tabloya bakın."""
    rows, problems = parse_plan(path)
    if problems:
        raise SystemExit("Plan hataları:\n  " + "\n  ".join(problems))
    return rows


def parse_plan(path: Path) -> tuple[list[PlanRow], list[str]]:
    """read_plan'ın hata fırlatmayan hali: (satırlar, sorunlar). Sorunlu satırlar da döner."""
    numbered, by_record, general = parse_plan_records(path)
    problems = [p for n, _ in numbered for p in by_record.get(n, [])]
    return [row for _, row in numbered], general + problems


def parse_plan_records(path: Path) -> tuple[list[tuple[int, PlanRow]], dict[int, list[str]], list[str]]:
    """(kayıt_no, satır) çiftleri, kayıt numarasına göre sorunlar ve genel sorunlar.

    Kayıt numarası, başlık 1 olmak üzere CSV kaydının sırasıdır (fiziksel satır değil; tırnak içinde
    satır sonu olan alanlar sırayı bozmaz). Okunamayan kayıtlar listede yer almaz, genel sorunlara yazılır;
    numara her satırla birlikte taşındığı için sonraki satırlar kaymaz.
    """
    tax = load_taxonomy()
    numbered: list[tuple[int, PlanRow]] = []
    by_record: dict[int, list[str]] = {}
    general: list[str] = []
    with open(path, encoding="utf-8-sig", newline="") as f:
        for n, r in enumerate(csv.DictReader(f), start=2):
            problems = by_record.setdefault(n, [])
            try:
                row = PlanRow(
                    lemma=r["lemma"].strip(),
                    pos=r["pos"].strip(),
                    type=(r.get("type") or "word").strip(),
                    sense_no=int(r.get("sense_no") or 1),
                    sense_hint=(r.get("sense_hint") or "").strip(),
                    target_level=r["target_level"].strip(),
                    level_source=(r.get("level_source") or "editorial_estimate").strip(),
                    primary_topic=r["primary_topic"].strip(),
                    topics=_split(r.get("topics")),
                    exams=_split(r.get("exams")),
                    zipf=float(r["zipf"]) if _opt(r.get("zipf")) else None,
                    freq_rank=int(r["freq_rank"]) if _opt(r.get("freq_rank")) else None,
                    ipa_us_ref=_opt(r.get("ipa_us_ref")),
                    ipa_uk_ref=_opt(r.get("ipa_uk_ref")),
                    confusables=_split(r.get("confusables")),
                    notes=(r.get("notes") or "").strip(),
                )
            except (KeyError, ValueError) as e:
                general.append(f"satır {n}: okunamadı ({e})")
                continue
            if not row.lemma:
                problems.append(f"satır {n}: lemma boş")
            if row.pos not in VALID_POS:
                problems.append(f"satır {n}: geçersiz pos {row.pos!r}")
            if row.type not in VALID_TYPES:
                problems.append(f"satır {n}: geçersiz type {row.type!r}")
            elif row.type in TYPE_POS and row.pos not in TYPE_POS[row.type]:
                problems.append(f"satır {n}: {row.type} için pos {sorted(TYPE_POS[row.type])} olmalı")
            if row.target_level not in LEVEL_RANK:
                problems.append(f"satır {n}: geçersiz seviye {row.target_level!r}")
            if row.level_source not in {"list", "editorial_estimate", "editor_verified"}:
                problems.append(f"satır {n}: geçersiz level_source {row.level_source!r}")
            for t in [row.primary_topic, *row.topics]:
                if t not in tax.categories:
                    problems.append(f"satır {n}: bilinmeyen kategori {t!r}")
            for e in row.exams:
                if e not in tax.exam_tags:
                    problems.append(f"satır {n}: bilinmeyen sınav etiketi {e!r}")
            numbered.append((n, row))
    seen: set[str] = set()
    for _, row in numbered:
        if row.card_id in seen:
            general.append(f"tekrar eden kart: {row.card_id}")
        seen.add(row.card_id)
    return numbered, {n: ps for n, ps in by_record.items() if ps}, general


# ------------------------------------------------------------------ çalışma klasörü

class Run:
    def __init__(self, name: str, root: Path = RUNS_DIR):
        self.dir = root / name
        self.name = name

    @property
    def state_path(self) -> Path:
        return self.dir / "state.json"

    def load_state(self) -> dict:
        if not self.state_path.exists():
            raise SystemExit(f"Çalışma bulunamadı: {self.dir}. Önce 'prepare' çalıştırın.")
        return json.loads(self.state_path.read_text(encoding="utf-8"))

    def save_state(self, state: dict) -> None:
        write_json_atomic(self.state_path, state)

    def plan(self) -> list[PlanRow]:
        return [PlanRow(**r) for r in json.loads((self.dir / "plan.json").read_text(encoding="utf-8"))]

    def stage_dir(self, stage: str) -> Path:
        d = self.dir / stage
        d.mkdir(parents=True, exist_ok=True)
        return d

    def read_output(self, stage: str, card_id: str) -> dict | None:
        p = self.dir / stage / f"{card_id}.json"
        return json.loads(p.read_text(encoding="utf-8")) if p.exists() else None

    def write_output(self, stage: str, card_id: str, data: dict) -> None:
        write_json_atomic(self.stage_dir(stage) / f"{card_id}.json", data)

    def log_failure(self, stage: str, card_id: str, reason: str, detail: str = "") -> None:
        self.dir.mkdir(parents=True, exist_ok=True)
        with open(self.dir / "failures.jsonl", "a", encoding="utf-8", newline="\n") as f:
            f.write(json.dumps({"stage": stage, "card_id": card_id, "reason": reason, "detail": detail,
                                "at": _now()}, ensure_ascii=False) + "\n")


def _now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def prepare(plan_csv: Path, run_name: str, root: Path = RUNS_DIR) -> Run:
    rows = read_plan(plan_csv)
    run = Run(run_name, root)
    if run.state_path.exists():
        raise SystemExit(f"{run.dir} zaten var; farklı bir --run adı verin.")
    run.dir.mkdir(parents=True)
    write_json_atomic(run.dir / "plan.json", [asdict(r) for r in rows])
    run.save_state({"run": run_name, "created_at": _now(), "prompt_ver": PROMPT_VERSION, "stages": {}})
    return run


# ------------------------------------------------------------------ istekler

def _system_block(text: str) -> list[dict]:
    return [{"type": "text", "text": text, "cache_control": {"type": "ephemeral"}}]


def _params(model: str, effort: str, system_text: str, user_text: str, schema: dict) -> dict:
    return {
        "model": model,
        "max_tokens": MAX_TOKENS,
        "system": _system_block(system_text),
        "messages": [{"role": "user", "content": user_text}],
        "output_config": {"effort": effort, "format": {"type": "json_schema", "schema": schema}},
    }


def user_a(row: PlanRow) -> str:
    return USER_A.format(
        lemma=row.lemma,
        pos=row.pos,
        type=row.type,
        sense_hint=row.sense_hint or "(most common sense)",
        target_level=row.target_level,
        primary_topic=row.primary_topic,
        zipf=row.zipf if row.zipf is not None else "unknown",
        confusables=", ".join(row.confusables) or "none",
        ipa_us_ref=row.ipa_us_ref or "none",
        ipa_uk_ref=row.ipa_uk_ref or "none",
        notes=row.notes or "none",
    )


def build_requests(run: Run, stage: str, model: str, effort: str) -> list[tuple[str, str, dict]]:
    """(custom_id, card_id, params) listesi. Önceki aşaması başarılı olan ve bu aşaması eksik kartlar."""
    reqs: list[tuple[str, str, dict]] = []
    for i, row in enumerate(run.plan()):
        cid = row.card_id
        if run.read_output(stage, cid) is not None:
            continue  # zaten tamamlanmış: yeniden çalıştırmada para harcama
        if stage == "a":
            params = _params(model, effort, system_a(), user_a(row), STAGE_A_SCHEMA)
        elif stage == "b":
            draft = run.read_output("a", cid)
            if draft is None or draft.get("skip_reason") or draft.get("sensitivity") == 2:
                continue
            entry = english_entry(row, draft)
            params = _params(model, effort, system_b(),
                             USER_B.format(entry_json=json.dumps(entry, ensure_ascii=False, indent=1)), STAGE_B_SCHEMA)
        elif stage == "c":
            card = _read_draft(run, cid)
            if card is None or card.get("meta", {}).get("status") != "draft" or "det_errors" in card["meta"].get("qa_flags", []):
                continue
            params = _params(model, effort, system_c(),
                             USER_C.format(ipa_us_ref=row.ipa_us_ref or "none", ipa_uk_ref=row.ipa_uk_ref or "none",
                                           entry_json=json.dumps(card, ensure_ascii=False, indent=1)), STAGE_C_SCHEMA)
        else:
            raise ValueError(stage)
        # custom_id yalnızca [A-Za-z0-9_-] ve ≤64 karakter olabilir; kart ID'sinde nokta var.
        reqs.append((f"{stage}-{i:05d}", cid, params))
    return reqs


def estimate_cost(reqs: list[tuple[str, str, dict]], stage: str) -> dict:
    """Önbelleksiz üst sınır tahmini (karakter/4 ≈ token). Gerçek maliyet genelde daha düşük olur."""
    if not reqs:
        return {"requests": 0}
    model = reqs[0][2]["model"]
    chars = sum(len(p["system"][0]["text"]) + len(p["messages"][0]["content"]) for _, _, p in reqs)
    in_tok = chars / 4
    out_tok = EST_OUTPUT_TOKENS[stage] * len(reqs)
    price = BATCH_PRICES.get(model)
    est = None if price is None else round(in_tok / 1e6 * price[0] + out_tok / 1e6 * price[1], 2)
    return {"requests": len(reqs), "model": model, "approx_input_tokens": int(in_tok),
            "approx_output_tokens": out_tok, "approx_cost_usd_upper_bound": est}


def submit(run: Run, stage: str, *, model: str, effort: str, dry_run: bool, client: Any = None) -> dict:
    state = run.load_state()
    if not dry_run and state["stages"].get(stage, {}).get("open_batches"):
        raise SystemExit(f"{stage} aşamasında toplanmamış batch var; önce 'collect' çalıştırın.")
    reqs = build_requests(run, stage, model, effort)
    est = estimate_cost(reqs, stage)
    if dry_run:
        out = run.dir / f"requests_{stage}.jsonl"
        with open(out, "w", encoding="utf-8", newline="\n") as f:
            for custom_id, cid, params in reqs:
                f.write(json.dumps({"custom_id": custom_id, "card_id": cid, "params": params}, ensure_ascii=False) + "\n")
        return {"dry_run": True, "file": str(out), **est}
    if not reqs:
        return {"submitted": 0, "note": "gönderilecek istek yok"}

    from anthropic.types.message_create_params import MessageCreateParamsNonStreaming
    from anthropic.types.messages.batch_create_params import Request

    if client is None:
        import anthropic

        client = anthropic.Anthropic()
    batch_ids: list[str] = []
    for start in range(0, len(reqs), BATCH_CHUNK):
        chunk = reqs[start:start + BATCH_CHUNK]
        batch = client.messages.batches.create(
            requests=[Request(custom_id=cu, params=MessageCreateParamsNonStreaming(**p)) for cu, _, p in chunk]
        )
        batch_ids.append(batch.id)
    st = state["stages"].setdefault(stage, {})
    st["open_batches"] = batch_ids
    st["custom_ids"] = {**st.get("custom_ids", {}), **{cu: cid for cu, cid, _ in reqs}}
    st["model"], st["effort"], st["submitted_at"] = model, effort, _now()
    run.save_state(state)
    return {"submitted": len(reqs), "batches": batch_ids, **est}


# ------------------------------------------------------------------ yanıtlar

def message_json(message: Any) -> tuple[dict | None, str | None, str]:
    """(veri, hata_nedeni, ayrıntı). Önce stop_reason kontrol edilir; içerik asla körlemesine okunmaz."""
    stop = getattr(message, "stop_reason", None)
    if stop == "refusal":
        details = getattr(message, "stop_details", None)
        category = getattr(details, "category", None) if details is not None else None
        return None, "refusal", str(category)
    if stop == "max_tokens":
        return None, "max_tokens", "çıktı kesildi; MAX_TOKENS'ı artırın"
    text = next((b.text for b in message.content if getattr(b, "type", None) == "text"), None)
    if text is None:
        return None, "no_text", f"stop_reason={stop}"
    try:
        return json.loads(text), None, ""
    except json.JSONDecodeError as e:
        return None, "invalid_json", str(e)


def english_entry(row: PlanRow, a: dict) -> dict:
    """B aşamasına gönderilen İngilizce kart (Türkçe katmanı henüz yok)."""
    return {
        "lemma": row.lemma, "pos": row.pos, "type": row.type, "level": row.target_level,
        "sense_note": a["sense_note"], "def": a["def"],
        "examples": [{"en": e["en"], "focus": e["focus"]} for e in a["examples"]],
        "synonyms": a["synonyms"], "collocations": a["collocations"],
    }


def assemble_card(row: PlanRow, a: dict, b: dict, *, run_name: str, models: str) -> dict:
    tax = load_taxonomy()
    qa: list[str] = [f"uncertain:{f}" for f in a.get("uncertain_fields", []) + b.get("uncertain_fields", [])]
    if a["level"] != row.target_level:
        qa.append(f"llm_level:{a['level']}")
    ipa_us = row.ipa_us_ref or a["ipa"]["us"]
    ipa_uk = row.ipa_uk_ref or a["ipa"]["uk"]
    if row.ipa_us_ref and a["ipa"]["us"] and a["ipa"]["us"] != row.ipa_us_ref:
        qa.append("ipa_llm_differs")
    if len(b["examples_tr"]) != len(a["examples"]):
        qa.append("tr_example_count_mismatch")
    topics = [row.primary_topic]
    for t in [*row.topics, *a.get("extra_topics", [])]:
        if t in tax.categories and t not in topics:
            topics.append(t)
    return {
        "id": row.card_id,
        "lemma": row.lemma,
        "type": row.type,
        "pos": row.pos,
        "sense_no": row.sense_no,
        "sense_note": a["sense_note"],
        "level": row.target_level,
        "level_source": row.level_source,
        "freq": {"rank": row.freq_rank, "zipf": row.zipf} if (row.freq_rank or row.zipf) else None,
        "ipa": {"us": ipa_us, "uk": ipa_uk},
        "def": a["def"],
        "grammar": {"pattern": a["grammar_pattern"]} if a.get("grammar_pattern") else None,
        "examples": [
            {"en": e["en"], "tr": b["examples_tr"][i] if i < len(b["examples_tr"]) else None,
             "register": e["register"], "focus": e["focus"]}
            for i, e in enumerate(a["examples"])
        ],
        "synonyms": a["synonyms"],
        "antonyms": a["antonyms"],
        "collocations": a["collocations"],
        "word_family": a["word_family"],
        "etymology": a["etymology"],
        "l1": {"tr": {k: b[k] for k in ("gloss", "alt", "equivalence", "false_friend", "note", "mistakes", "mnemonic")}},
        "tags": {
            "primary_topic": row.primary_topic,
            "topics": topics[:4],
            "exams": row.exams,
            "register": a["register"],
            "vibes": a["vibes"],
            "flags": a["flags"],
            "sensitivity": a["sensitivity"],
        },
        "quiz": a["quiz"],
        "meta": {"status": "draft", "qa_flags": qa, "prompt_ver": PROMPT_VERSION, "model": models,
                 "source": f"run:{run_name}"},
    }


def _read_draft(run: Run, cid: str) -> dict | None:
    p = run.dir / "drafts" / f"{cid}.json"
    return json.loads(p.read_text(encoding="utf-8")) if p.exists() else None


def _write_draft(run: Run, card: dict) -> None:
    write_json_atomic(run.stage_dir("drafts") / f"{card['id']}.json", card)


def process_results(run: Run, stage: str, results: Iterable[Any]) -> dict:
    """Batch sonuçlarını işler. Ağdan bağımsızdır; testler sahte sonuç nesneleriyle çağırır."""
    state = run.load_state()
    custom_ids: dict[str, str] = state["stages"][stage]["custom_ids"]
    rows = {r.card_id: r for r in run.plan()}
    counts = {"succeeded": 0, "failed": 0}
    for res in results:
        cid = custom_ids.get(res.custom_id)
        if cid is None:
            continue
        rtype = res.result.type
        if rtype != "succeeded":
            detail = getattr(getattr(res.result, "error", None), "type", "") if rtype == "errored" else ""
            run.log_failure(stage, cid, f"batch_{rtype}", str(detail))
            counts["failed"] += 1
            continue
        data, reason, detail = message_json(res.result.message)
        if data is None:
            run.log_failure(stage, cid, reason or "unknown", detail)
            counts["failed"] += 1
            continue
        try:
            if stage == "a":
                StageAOut.parse_json(data)
            elif stage == "b":
                StageBOut.model_validate(data)
            else:
                StageCOut.model_validate(data)
        except ValidationError as e:
            run.log_failure(stage, cid, "schema_mismatch", str(e)[:500])
            counts["failed"] += 1
            continue
        run.write_output(stage, cid, data)
        counts["succeeded"] += 1

        if stage == "a" and (data.get("skip_reason") or data.get("sensitivity") == 2):
            run.log_failure("a", cid, "skipped_sensitive", data.get("skip_reason") or "sensitivity=2")
        elif stage == "b":
            a = run.read_output("a", cid)
            model_a = state["stages"]["a"]["model"]
            card = assemble_card(rows[cid], a, data, run_name=run.name, models=f"a={model_a};b={state['stages']['b']['model']}")
            _write_draft(run, card)
        elif stage == "c":
            _apply_critic(run, cid, StageCOut.model_validate(data), state["stages"]["c"]["model"])

    if stage == "b":
        counts["validation"] = validate_drafts(run)
    return counts


def validate_drafts(run: Run) -> dict:
    """Taslakları deterministik doğrular; hatası olanlar C aşamasına gönderilmez."""
    drafts_dir = run.dir / "drafts"
    paths = sorted(drafts_dir.glob("*.json")) if drafts_dir.exists() else []
    raws = [json.loads(p.read_text(encoding="utf-8")) for p in paths]
    _, issues = validate_cards(raws)
    by_card: dict[str, list] = {}
    for i in issues:
        by_card.setdefault(i.card_id, []).append(i)
    n_err = 0
    for raw in raws:
        found = by_card.get(raw["id"], [])
        # Önceki doğrulamanın bayraklarını temizle; yeniden çalıştırmada birikmesinler.
        flags = [f for f in raw["meta"]["qa_flags"] if not f.startswith(("det_", "warning:", "error:"))]
        errs = [i for i in found if i.severity == "error"]
        if errs:
            n_err += 1
            flags.append("det_errors")
        flags += [f"{i.severity}:{i.code}:{i.field}" for i in found]
        raw["meta"]["qa_flags"] = flags
        _write_draft(run, raw)
    write_json_atomic(run.dir / "validation_report.json", [i.__dict__ for i in issues])
    return {"drafts": len(raws), "with_errors": n_err, "issues": len(issues)}


def _apply_critic(run: Run, cid: str, review: StageCOut, model: str) -> None:
    card = _read_draft(run, cid)
    if card is None:
        return
    verdict = review.final_verdict()
    card["meta"]["critic"] = {
        "model": model,
        "verdict": verdict,
        "model_verdict": review.verdict,
        "total": review.total(),
        "low_scores": {k: v.reason for k, v in review.scores.items() if v.score < 2},
        "issues": [i.model_dump() for i in review.issues],
    }
    if verdict == "PASS":
        card["meta"]["status"] = "validated"  # sırada insan denetimi var → "reviewed"
    elif verdict == "REJECT":
        card["meta"]["status"] = "rejected"
    else:
        card["meta"]["qa_flags"].append("critic_fix")
    _write_draft(run, card)


def collect(run: Run, stage: str, *, wait: bool, client: Any = None) -> dict:
    state = run.load_state()
    st = state["stages"].get(stage) or {}
    open_batches: list[str] = st.get("open_batches", [])
    if not open_batches:
        return {"note": f"{stage} aşamasında açık batch yok"}
    if client is None:
        import anthropic

        client = anthropic.Anthropic()
    summary: dict[str, Any] = {"batches": {}}
    still_open: list[str] = []
    for bid in open_batches:
        while True:
            batch = client.messages.batches.retrieve(bid)
            if batch.processing_status == "ended" or not wait:
                break
            print(f"{bid}: {batch.processing_status}, işleniyor={batch.request_counts.processing}", file=sys.stderr)
            time.sleep(POLL_SECONDS)
        if batch.processing_status != "ended":
            still_open.append(bid)
            summary["batches"][bid] = batch.processing_status
            continue
        summary["batches"][bid] = process_results(run, stage, client.messages.batches.results(bid))
    state = run.load_state()  # process_results durumu okudu; üzerine yazmadan önce tazele
    state["stages"][stage]["open_batches"] = still_open
    if not still_open:
        state["stages"][stage]["collected_at"] = _now()
    run.save_state(state)
    return summary


def status(run: Run) -> dict:
    state = run.load_state()
    plan = run.plan()
    out = {"run": run.name, "cards": len(plan), "stages": {}}
    for stage in ("a", "b", "c"):
        done = sum(1 for r in plan if run.read_output(stage, r.card_id) is not None)
        out["stages"][stage] = {"done": done, "open_batches": state["stages"].get(stage, {}).get("open_batches", [])}
    drafts_dir = run.dir / "drafts"
    statuses: dict[str, int] = {}
    for p in (drafts_dir.glob("*.json") if drafts_dir.exists() else []):
        s = json.loads(p.read_text(encoding="utf-8"))["meta"]["status"]
        statuses[s] = statuses.get(s, 0) + 1
    out["draft_statuses"] = statuses
    fails = run.dir / "failures.jsonl"
    out["failures"] = sum(1 for _ in open(fails, encoding="utf-8")) if fails.exists() else 0
    return out


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Claude Batch API ile kart üretimi")
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("prepare")
    p.add_argument("plan_csv", type=Path)
    p.add_argument("--run", required=True)
    for name in ("submit", "collect", "status"):
        sp = sub.add_parser(name)
        sp.add_argument("--run", required=True)
        if name != "status":
            sp.add_argument("--stage", choices=["a", "b", "c"], required=True)
        if name == "submit":
            sp.add_argument("--model", default=DEFAULT_MODEL)
            sp.add_argument("--effort", default=DEFAULT_EFFORT, choices=["low", "medium", "high", "xhigh", "max"])
            sp.add_argument("--dry-run", action="store_true")
        if name == "collect":
            sp.add_argument("--wait", action="store_true", help="batch bitene kadar bekle")
    args = ap.parse_args(argv)

    if args.cmd == "prepare":
        run = prepare(args.plan_csv, args.run)
        print(json.dumps({"run": run.name, "dir": str(run.dir), "cards": len(run.plan())}, ensure_ascii=False))
        return 0
    run = Run(args.run)
    if args.cmd == "submit":
        result = submit(run, args.stage, model=args.model, effort=args.effort, dry_run=args.dry_run)
    elif args.cmd == "collect":
        result = collect(run, args.stage, wait=args.wait)
    else:
        result = status(run)
    print(json.dumps(result, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
