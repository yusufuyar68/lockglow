"""Hazır ses kayıtları: içerikteki İngilizce metinleri bir yapay zekâ ses servisiyle bir kez seslendirir.

Uygulama "Dinle"de önce bu kayıtlara bakar (`ios/Shared/RecordedSpeech.swift`); kaydı olmayan metni
(kullanıcının kendi kelimeleri, yeni kartlar) telefonun kendi sesi okur. Kayıtlar uygulamanın içine
girer, uygulama internetsiz çalışır; servis yalnız bu betik çalışırken kullanılır.

Ne seslendirilir: `content.sqlite`'taki her kartın kelimesi ve örnek cümleleri,
`minimal_pairs.json`'daki kelimeler; `--kinds` ile kalıplar (collocation) ve "doğrusu" cümleleri
(mistake) de. Aynı metin bir kez.

Çıktı: `ios/App/Resources/RecordedSpeech/`
- `voices.json`: hangi sesler var (`us-female`, `us-male`; aksan + karakter) ve dosya uzantısı;
- `<ses>/<anahtar>.<uzantı>`: anahtar, metnin (baştaki ve sondaki boşluklar atılmış) UTF-8
  SHA-1'inin ilk 16 hanesi. Swift aynı anahtarı hesaplar (`RecordedSpeech.key`).
Var olan dosya yeniden üretilmez: yarıda kalan bir çalıştırma kaldığı yerden sürer.

Anahtar ortam değişkeninden okunur, hiçbir dosyaya yazılmaz:
- OpenAI: `OPENAI_API_KEY` (yalnız ABD aksanı; model `gpt-4o-mini-tts`);
- Google Cloud Text-to-Speech: `GOOGLE_TTS_API_KEY` (ABD ve İngiltere; Chirp 3 HD sesleri).

Örnekler (content-pipeline klasöründe):
    python -X utf8 -m vocabpipe.recorded_speech --dry-run
    python -X utf8 -m vocabpipe.recorded_speech --provider openai --limit 20
    python -X utf8 -m vocabpipe.recorded_speech --provider google --accents us uk
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTENT_DB = ROOT / "ios" / "App" / "Resources" / "content.sqlite"
MINIMAL_PAIRS = ROOT / "ios" / "App" / "Resources" / "minimal_pairs.json"
OUT_DIR = ROOT / "ios" / "App" / "Resources" / "RecordedSpeech"

KINDS = ("lemma", "example", "collocation", "mistake", "pair")
# Varsayılan: en çok dinlenenler (kelime, örnek cümle, kulak alıştırması). Kalıplar ve "doğrusu"
# cümleleri uygulamayı ~40 MB daha büyütür; istenirse `--kinds` ile eklenir.
DEFAULT_KINDS = ("lemma", "example", "pair")

# Öğrenciye net ama doğal: gpt-4o-mini-tts konuşma tarzını bu yönergeyle alır.
OPENAI_INSTRUCTIONS = (
    "You are recording audio for an English vocabulary app for Turkish learners at A2 level. "
    "Speak in natural, fluent General American English with clear pronunciation, "
    "at a relaxed conversational pace. Read the text exactly as written, with natural sentence "
    "stress and intonation. A single word or phrase is read as a dictionary entry, not as a question."
)

# Karakter başına ses adı. OpenAI: kadın nova, erkek onyx. Google Chirp 3 HD: kadın Aoede,
# erkek Charon (en-US ve en-GB'de aynı adlar).
VOICES = {
    "openai": {("us", "female"): "nova", ("us", "male"): "onyx"},
    "google": {
        ("us", "female"): "en-US-Chirp3-HD-Aoede",
        ("us", "male"): "en-US-Chirp3-HD-Charon",
        ("uk", "female"): "en-GB-Chirp3-HD-Aoede",
        ("uk", "male"): "en-GB-Chirp3-HD-Charon",
    },
}

# Liste fiyatı, 1 milyon karakter başına ABD doları (2026 başı; yalnız tahmin için).
PRICE_PER_MILLION = {"openai": 16.0, "google": 30.0}


def clip_key(text: str) -> str:
    """Metnin kayıt anahtarı: baştaki/sondaki boşluk atılmış UTF-8'in SHA-1'inin ilk 16 hanesi."""
    return hashlib.sha1(text.strip().encode("utf-8")).hexdigest()[:16]


def collect_texts(db_path: Path, pairs_path: Path | None, kinds: tuple[str, ...] = KINDS) -> list[str]:
    """Seslendirilecek metinler, ilk görülme sırasıyla, her biri bir kez."""
    seen: set[str] = set()
    texts: list[str] = []

    def add(text: str | None) -> None:
        if not isinstance(text, str):
            return
        spoken = text.strip()
        if spoken and spoken not in seen:
            seen.add(spoken)
            texts.append(spoken)

    con = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    try:
        rows = con.execute("SELECT json FROM card ORDER BY rowid").fetchall()
    finally:
        con.close()
    for (raw,) in rows:
        card = json.loads(raw)
        if "lemma" in kinds:
            add(card.get("lemma"))
        if "example" in kinds:
            for example in card.get("examples") or []:
                add(example.get("en"))
        if "collocation" in kinds:
            for phrase in card.get("collocations") or []:
                add(phrase)
        if "mistake" in kinds:
            tr = (card.get("l1") or {}).get("tr") or {}
            for mistake in tr.get("mistakes") or []:
                add(mistake.get("right"))
    if "pair" in kinds and pairs_path and pairs_path.exists():
        data = json.loads(pairs_path.read_text(encoding="utf-8"))
        for group in data.get("groups") or []:
            for pair in group.get("pairs") or []:
                for side in ("a", "b"):
                    add((pair.get(side) or {}).get("word"))
    return texts


# ---------------------------------------------------------------- servisler


@dataclass
class Voice:
    accent: str  # "us", "uk"
    gender: str  # "female", "male"
    name: str

    @property
    def key(self) -> str:
        return f"{self.accent}-{self.gender}"


def _post(url: str, body: dict, headers: dict[str, str]) -> bytes:
    request = urllib.request.Request(url, data=json.dumps(body).encode("utf-8"), method="POST")
    request.add_header("Content-Type", "application/json")
    for name, value in headers.items():
        request.add_header(name, value)
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read()


def synthesize_openai(text: str, voice: Voice, api_key: str) -> bytes:
    body = {
        "model": "gpt-4o-mini-tts",
        "voice": voice.name,
        "input": text,
        "instructions": OPENAI_INSTRUCTIONS,
        "response_format": "mp3",
    }
    return _post("https://api.openai.com/v1/audio/speech", body, {"Authorization": f"Bearer {api_key}"})


def synthesize_google(text: str, voice: Voice, api_key: str) -> bytes:
    language = "en-US" if voice.accent == "us" else "en-GB"
    body = {
        "input": {"text": text},
        "voice": {"languageCode": language, "name": voice.name},
        "audioConfig": {"audioEncoding": "MP3", "sampleRateHertz": 24000},
    }
    raw = _post(
        "https://texttospeech.googleapis.com/v1/text:synthesize", body, {"X-Goog-Api-Key": api_key}
    )
    return base64.b64decode(json.loads(raw)["audioContent"])


SYNTHESIZERS = {"openai": synthesize_openai, "google": synthesize_google}
KEY_ENV = {"openai": "OPENAI_API_KEY", "google": "GOOGLE_TTS_API_KEY"}


def synthesize_with_retry(provider: str, text: str, voice: Voice, api_key: str, attempts: int = 5) -> bytes:
    delay = 2.0
    for attempt in range(1, attempts + 1):
        try:
            return SYNTHESIZERS[provider](text, voice, api_key)
        except urllib.error.HTTPError as error:
            # 429 (hız sınırı) ve 5xx geçicidir; 4xx (anahtar, kota, yanlış ses) değildir.
            if error.code != 429 and error.code < 500 or attempt == attempts:
                detail = error.read().decode("utf-8", "replace")[:300]
                raise RuntimeError(f"{provider} {error.code}: {detail}") from None
        except (urllib.error.URLError, TimeoutError):
            if attempt == attempts:
                raise
        time.sleep(delay)
        delay *= 2
    raise AssertionError("unreachable")


# ---------------------------------------------------------------- sıkıştırma


def compress(mp3: bytes, ffmpeg: str, bitrate: str) -> bytes:
    """mp3 → m4a (AAC, tek kanal, 24 kHz): konuşma için yeterli, dosya küçük."""
    with tempfile.TemporaryDirectory() as tmp:
        source = Path(tmp) / "in.mp3"
        target = Path(tmp) / "out.m4a"
        source.write_bytes(mp3)
        subprocess.run(
            [ffmpeg, "-loglevel", "error", "-y", "-i", str(source), "-ac", "1", "-ar", "24000",
             "-c:a", "aac", "-b:a", bitrate, "-movflags", "+faststart", str(target)],
            check=True,
        )
        return target.read_bytes()


# ---------------------------------------------------------------- çalıştırma


def write_voices_manifest(out_dir: Path, provider: str, voices: list[Voice], ext: str) -> None:
    """`voices.json`: bu çalıştırmanın sesleri, önceden üretilmiş başka seslerle birlikte."""
    path = out_dir / "voices.json"
    manifest = {"format": 1, "voices": {}}
    if path.exists():
        manifest = json.loads(path.read_text(encoding="utf-8"))
    for voice in voices:
        folder = out_dir / voice.key
        manifest["voices"][voice.key] = {
            "provider": provider,
            "name": voice.name,
            "ext": ext,
            "clips": sum(1 for _ in folder.glob(f"*.{ext}")) if folder.exists() else 0,
        }
    manifest["voices"] = dict(sorted(manifest["voices"].items()))
    path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="İçerikteki İngilizce metinleri hazır ses kaydına çevirir.")
    parser.add_argument("--provider", choices=sorted(SYNTHESIZERS), default="openai")
    parser.add_argument("--accents", nargs="+", choices=("us", "uk"), default=["us"])
    parser.add_argument("--genders", nargs="+", choices=("female", "male"), default=["female", "male"])
    parser.add_argument("--kinds", nargs="+", choices=KINDS, default=list(DEFAULT_KINDS))
    parser.add_argument("--limit", type=int, help="yalnız ilk N metin (deneme için)")
    parser.add_argument("--db", type=Path, default=CONTENT_DB)
    parser.add_argument("--pairs", type=Path, default=MINIMAL_PAIRS)
    parser.add_argument("--out", type=Path, default=OUT_DIR)
    parser.add_argument("--dry-run", action="store_true", help="servise gitmeden sayıyı ve tahmini ücreti yaz")
    parser.add_argument("--no-compress", action="store_true", help="ffmpeg olsa da mp3 bırak")
    parser.add_argument("--bitrate", default="24k", help="m4a bit hızı (ffmpeg ile; varsayılan 24k)")
    args = parser.parse_args(argv)

    texts = collect_texts(args.db, args.pairs, tuple(args.kinds))
    if args.limit:
        texts = texts[: args.limit]
    voices = []
    for accent in args.accents:
        for gender in args.genders:
            name = VOICES[args.provider].get((accent, gender))
            if name is None:
                print(f"{args.provider} için {accent} aksanında ses yok; Google'ı dene.", file=sys.stderr)
                return 2
            voices.append(Voice(accent, gender, name))

    ffmpeg = None if args.no_compress else shutil.which("ffmpeg")
    ext = "m4a" if ffmpeg else "mp3"
    todo = [(voice, text) for voice in voices for text in texts
            if not (args.out / voice.key / f"{clip_key(text)}.{ext}").exists()]
    chars = sum(len(text) for _, text in todo)
    cost = chars / 1_000_000 * PRICE_PER_MILLION[args.provider]
    # Konuşma saniyede ~15 karakter; mp3 servislerden ~64 kbit/s gelir.
    kbits = int(args.bitrate.rstrip("k")) if ffmpeg else 64
    megabytes = chars / 15 * kbits / 8 / 1000
    print(f"{len(texts)} metin x {len(voices)} ses; yapılacak {len(todo)} kayıt, {chars} karakter, "
          f"tahmini ücret ~{cost:.2f} $ ({args.provider}), uygulamaya ~{megabytes:.0f} MB. Dosya türü: {ext}.")
    if not ffmpeg and not args.no_compress:
        print("ffmpeg bulunamadı: kayıtlar mp3 kalır, uygulama daha büyük olur.", file=sys.stderr)
    if args.dry_run or not todo:
        return 0

    api_key = os.environ.get(KEY_ENV[args.provider])
    if not api_key:
        print(f"{KEY_ENV[args.provider]} ortam değişkeni boş.", file=sys.stderr)
        return 2

    for index, (voice, text) in enumerate(todo, 1):
        target = args.out / voice.key / f"{clip_key(text)}.{ext}"
        target.parent.mkdir(parents=True, exist_ok=True)
        audio = synthesize_with_retry(args.provider, text, voice, api_key)
        if ffmpeg:
            audio = compress(audio, ffmpeg, args.bitrate)
        partial = target.with_suffix(target.suffix + ".part")
        partial.write_bytes(audio)
        partial.replace(target)
        if index % 50 == 0 or index == len(todo):
            print(f"{index}/{len(todo)}", flush=True)
            write_voices_manifest(args.out, args.provider, voices, ext)
    write_voices_manifest(args.out, args.provider, voices, ext)
    return 0


if __name__ == "__main__":
    sys.exit(main())
