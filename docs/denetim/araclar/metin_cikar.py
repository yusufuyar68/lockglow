"""Lockglow arayüz metinlerini çıkarır ve basit metin kurallarını işaretler.

Swift dosyalarındaki dize sabitlerini okur (yorumları atlar, `\\(…)` aradeğerlerini
olduğu gibi bırakır), her dizenin hangi çağrının içinde durduğunu bulur ve
kullanıcıya görünenleri listeler. `ios/project.yml` içindeki izin metinleri de
(Info.plist) eklenir.

Kullanım (depo kökünden):
    python -X utf8 docs/denetim/araclar/metin_cikar.py              # Markdown tablo
    python -X utf8 docs/denetim/araclar/metin_cikar.py --isaret     # yalnız kurala takılanlar
    python -X utf8 docs/denetim/araclar/metin_cikar.py --terim      # terim sayımı
    python -X utf8 docs/denetim/araclar/metin_cikar.py --json > metinler.json
    python -X utf8 docs/denetim/araclar/metin_cikar.py --onizleme   # #Preview içindekiler de

Türler:
- görünür: Text, Label, Button, Toggle, Section, navigationTitle …
- sesli: accessibilityLabel / Hint / Value / InputLabels ve VoiceOver duyuruları
- iletişim: alert, confirmationDialog
- bildirim: ReminderPlanner (ReminderText) ve bildirim içeriği
- değer: `return "…"`, `case …: "…"`, değişkene atanan metin (görünür olduğu bağlamdan anlaşılır)
- izin: Info.plist izin açıklamaları (project.yml)

Kural işaretleri (`--isaret`) yalnız ipucudur; her biri elle okunmalı:
- ek: değişkenden ya da saatten sonra Türkçe ek (`\\(x)'i`, `20:00'de`, `\\(n)'u`);
- siz: "siz" hitabı (-iniz, -sınız, "dokunun", "seçin" …);
- ünlem: ünlem işareti;
- övgü: "Harika", "Güzel iş", "Aferin", "Süper", "Mükemmel", "Bravo";
- baskı: "kaçırma", "kaybetme", "birikti", "özledik", "seri", "hemen";
- uzun: 12 kelimeden uzun cümle;
- yabancı: A2 kullanıcısına yabancı gelebilecek terimler (widget dışında);
- büyük-harf: aynı satırda locale vermeden `.uppercased()`;
- karışık-ad: aynı kavrama terimler.md dışı bir ad ("Biliyordum", "tekrar turu" …).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DEFAULT_PATHS = (
    "ios/App",
    "ios/Widgets",
    "ios/Shared",
    "ios/Packages/VocabKit/Sources/Learning/ReminderPlanner.swift",
    # Kullanıcıya görünen metni olan paket dosyaları (görev kapsamının dışında ama ekranda çıkıyor).
    "ios/Packages/VocabKit/Sources/Pronunciation/PronunciationCheck.swift",
    # İlerleme ekranının not cümleleri ve kendi kelime formunun sorun metinleri.
    "ios/Packages/VocabKit/Sources/Learning/ProgressSummary.swift",
    "ios/Packages/VocabKit/Sources/Learning/CustomWords.swift",
    "ios/project.yml",
)

TURKISH_LETTERS = set("çğıöşüÇĞİÖŞÜ")
VISIBLE_CALLS = {
    "Text", "Label", "Button", "Toggle", "Picker", "Section", "TextField", "SecureField", "Link",
    "NavigationLink", "Stepper", "LabeledContent", "ContentUnavailableView", "ShareLink", "Menu",
    "navigationTitle", "help", "searchable", "badge", "LocalizedStringKey", "LocalizedStringResource",
    "AttributedString", "configurationDisplayName", "description", "IntentDescription", "Tab",
    "tabItem", "prompt", "placeholder",
}
SPOKEN_CALLS = {
    "accessibilityLabel", "accessibilityHint", "accessibilityValue", "accessibilityInputLabels",
    "accessibilityAction", "Announcement", "post", "announce", "accessibilityCustomContent",
}
DIALOG_CALLS = {"alert", "confirmationDialog"}
# Kullanıcıya hiç görünmeyen bağlamlar.
HIDDEN_CALLS = {
    "accessibilityIdentifier", "Image", "systemName", "forKey", "string", "bool", "integer",
    "object", "set", "removeObject", "Logger", "print", "fatalError", "assert", "precondition",
    "assertionFailure", "preconditionFailure", "debugPrint", "NSLog", "URL", "Color", "font",
    "custom", "UserDefaults", "identifier", "named", "Bundle", "forResource", "appendingPathComponent",
    "suiteName", "kind", "subsystem", "category", "UNNotificationRequest", "withIdentifier",
    "DateFormatter", "dateFormat", "Locale", "Calendar", "TimeZone", "AVSpeechSynthesisVoice",
    "SFSpeechRecognizer", "language", "matching", "localeIdentifier", "UIImage", "id",
    "accessibilitySpeechLanguage", "onOpenURL", "contains", "hasPrefix", "hasSuffix",
    "replacingOccurrences", "split", "components", "range", "firstRange", "NSRegularExpression",
    "Regex", "path", "query", "queryItems", "URLQueryItem", "scheme", "host", "decode", "encode",
    "CodingKeys", "rawValue", "Preview", "previewDisplayName",
}
HIDDEN_LABELS = {"systemImage", "systemName", "forKey", "identifier", "id", "named", "image", "kind",
                 "subsystem", "category", "suiteName", "withIdentifier", "dateFormat", "language"}

PRAISE = re.compile(r"\b(harika|güzel iş|aferin|süper|mükemmel|bravo|muhteşem|çok iyi|tebrik)", re.I)
PRESSURE = re.compile(r"(kaçırma|kaybetme|birikti|özledik|\bseri|hemen şimdi|son şans|unutma!)", re.I)
SIZ = re.compile(
    r"\b\w+(iniz|ınız|unuz|ünüz|siniz|sınız|sunuz|sünüz|yiniz|yınız)\b"
    r"|\b(dokunun|seçin|ekleyin|açın|kapatın|deneyin|bakın|söyleyin|dinleyin|gidin|basın|yazın|"
    r"kullanın|demeyin|bekleyin|tıklayın|girin|silin|ayarlayın|unutmayın)\b",
    re.I,
)
# Türkçe sözcükler uzun: 12 sözcükten uzun cümle A2 okur için uzun sayılır.
LONG_SENTENCE = 12
# Değişkenden ya da sayıdan/saatten sonra kesme işaretli ek.
SUFFIX = re.compile(r"(\\\([^)]*\)|\d)['’](?=[a-zçğıöşüA-ZÇĞİÖŞÜ])")
FOREIGN = re.compile(
    r"\b(cloze|quiz|IPA|feed|deck|streak|timeline|slot|app intent|intent|tap|swipe|"
    r"leitner|kutu \d|lemma|gloss|onboarding|snapshot|cache|sync|refresh|tanılama|"
    r"yenileme bütçesi|bütçe|app group|debug|simülatör|zaman çizelge\w*|testing effect|"
    r"content\.sqlite|seed_words)\b",
    re.I,
)

# Terimler: kavram → (önerilen ad deseni, kaçınılacak desenler). docs/tasarim/terimler.md ile
# aynı karar; sözlük değişirse burası da değişir.
TERMS: dict[str, tuple[str, list[str]]] = {
    "Tekrar (sekme)": (r"\bTekrar\b", [r"tekrar turu", r"\bpratik\b"]),
    "Bildim (cevap)": (r"\bBildim\b", [r"\bBiliyordum\b", r"\bDoğru bildim\b"]),
    "Zor / Kolay (cevap)": (r"\b(Zor|Kolay)\b", [r"\bZordu\b", r"\bKolaydı\b", r"Zor ama bildim"]),
    "Biliyorum (işaret)": (r"\bBiliyorum\b", [r"\bBildiklerim\b", r"Bu kelimeyi biliyorum"]),
    "bildiğin kelimeler": (r"\b[Bb]ildiğin kelime", [r"\b[Bb]ildiğim kelime", r"\bBiliyorsun\b"]),
    "Bilemedim (cevap)": (r"\bBilemedim\b", [r"\bBilmiyorum\b", r"\bUnuttum\b", r"\bTekrar et\b"]),
    "kelime": (r"\bkelime", [r"\bsözcük"]),
    "kart (yalnız ekrandaki kutu)": (r"\bkart", [r"\d+ kart\b", r"\\\([^)]*\) kart\b"]),
    "Sözlük": (r"\bSözlük", [r"\bArama\b"]),
    "Akış": (r"\bAkış", [r"\bAna ?sayfa\b"]),
    "Dinle": (r"\bDinle\b", [r"seslendir", r"hoparlör düğmesi"]),
    "dokun": (r"\bdokun", [r"\bbas\b", r"\bbasma\b", r"['’]ye bas\b", r"\btıkla"]),
    "seviye": (r"\bseviye", [r"\bdüzey"]),
    "konu": (r"\bkonu", [r"\bdeste", r"\bkategori", r"\bpaket\b"]),
    "kilitli ekran": (r"kilitli ekran", [r"kilit ekran"]),
    "hatırlatma": (r"hatırlatma", [r"^Bildirim$", r"bildirim gelir", r"hatırlatma olarak", r"kısa hatırlatma"]),
    "günlük hedef": (r"günlük (hedef|yeni kelime)", [r"bugünkü hedef"]),
    # "Dikkat kutusu" ayrı bir kavram (terimler §4), işaretlenmez.
    "basamak": (r"\bbasamak", [r"\b[Rr]af", r"(?<!Dikkat )(?<!Dikkat\*\* )\bkutu"]),
}


@dataclass
class Literal:
    path: str
    line: int
    text: str
    call: str = ""
    label: str = ""
    kind: str = ""
    preview: bool = False
    code_line: str = ""
    flags: list[str] = field(default_factory=list)

    @property
    def where(self) -> str:
        return f"{self.path}:{self.line}"


# --- Swift dize okuyucu ---------------------------------------------------------------------

def _scan(src: str):
    """Kodu karakter karakter gezer. (başlangıç, bitiş, metin, satır) üretir; yorumları atlar.

    Ayrıca kod içindeki (dize ya da yorum olmayan) süslü parantezlerin yerlerini döndürür.
    """
    literals: list[tuple[int, int, str, int]] = []
    braces: list[tuple[int, str]] = []
    i, n = 0, len(src)

    def line_of(pos: int) -> int:
        return src.count("\n", 0, pos) + 1

    def read_string(pos: int) -> tuple[int, str]:
        """`pos` dizenin ilk `#` ya da `"` karakteri. (bitiş, içerik) döner."""
        hashes = 0
        while src[pos] == "#":
            hashes += 1
            pos += 1
        multi = src.startswith('"""', pos)
        pos += 3 if multi else 1
        close = ('"""' if multi else '"') + "#" * hashes
        escape = "\\" + "#" * hashes
        out: list[str] = []
        while pos < n:
            if src.startswith(close, pos):
                return pos + len(close), "".join(out)
            if src.startswith(escape, pos):
                after = pos + len(escape)
                if after < n and src[after] == "(":
                    # Aradeğer: parantez dengesini, içteki dizeleri atlayarak bul.
                    depth, j = 1, after + 1
                    while j < n and depth:
                        c = src[j]
                        if c == '"' or (c == "#" and src.startswith('"', j + 1)):
                            j, _ = read_string(j)
                            continue
                        depth += {"(": 1, ")": -1}.get(c, 0)
                        j += 1
                    out.append("\\(" + src[after + 1 : j - 1] + ")")
                    pos = j
                    continue
                nxt = src[after] if after < n else ""
                out.append({"n": "\n", "t": "\t", '"': '"', "\\": "\\", "'": "'"}.get(nxt, "\\" + nxt))
                pos = after + 1
                continue
            if not multi and src[pos] == "\n":
                break
            out.append(src[pos])
            pos += 1
        return pos, "".join(out)

    while i < n:
        c = src[i]
        if src.startswith("//", i):
            j = src.find("\n", i)
            i = n if j < 0 else j
            continue
        if src.startswith("/*", i):
            depth, j = 1, i + 2
            while j < n and depth:
                if src.startswith("/*", j):
                    depth, j = depth + 1, j + 2
                elif src.startswith("*/", j):
                    depth, j = depth - 1, j + 2
                else:
                    j += 1
            i = j
            continue
        if c == '"' or (c == "#" and re.match(r'#+"', src[i:i + 8])):
            end, text = read_string(i)
            literals.append((i, end, text, line_of(i)))
            i = end
            continue
        if c in "{}":
            braces.append((i, c))
        i += 1
    return literals, braces


def _preview_ranges(src: str, braces: list[tuple[int, str]]) -> list[tuple[int, int]]:
    """`#Preview { … }` ve `PreviewProvider` gövdelerinin aralıkları."""
    ranges = []
    for m in re.finditer(r"#Preview\b|:\s*PreviewProvider\b", src):
        opens = [p for p, c in braces if c == "{" and p > m.end()]
        if not opens:
            continue
        start, depth = opens[0], 0
        for p, c in braces:
            if p < start:
                continue
            depth += 1 if c == "{" else -1
            if depth == 0:
                ranges.append((start, p))
                break
    return ranges


def _context(src: str, start: int) -> tuple[str, str]:
    """Dizenin içinde durduğu çağrının adı ve dizeden hemen önceki argüman etiketi."""
    before = src[max(0, start - 800) : start]
    label = ""
    m = re.search(r"(\w+)\s*:\s*$", before)
    if m:
        label = m.group(1)
    if re.search(r"\breturn\s*$", before):
        return "return", label
    # Geriye doğru, kapanmamış ilk "(" ya da "[" ya da "{" bulunur.
    depth = 0
    for k in range(len(before) - 1, -1, -1):
        c = before[k]
        if c in ")]}":
            depth += 1
        elif c in "([{":
            if depth:
                depth -= 1
                continue
            if c == "(":
                name = re.search(r"([A-Za-z_][\w.]*)\s*$", before[:k])
                call = name.group(1).split(".")[-1] if name else ""
                return call, label
            if c == "[":
                return "[dizi]", label
            # "{" : kapanış bloğu ya da değişken gövdesi.
            line_start = before.rfind("\n", 0, start) + 1
            line = before[line_start:]
            if re.search(r"(=|\?|:)\s*$", line) or "case " in line:
                return "değer", label
            return "blok", label
    return "", label


def _kind(lit: Literal) -> str:
    call, label = lit.call, lit.label
    if lit.path.endswith("project.yml"):
        return "izin"
    if label in HIDDEN_LABELS or call in HIDDEN_CALLS:
        return ""
    if "ReminderPlanner" in lit.path:
        return "bildirim"
    if call in SPOKEN_CALLS or label in {"accessibilityLabel", "accessibilityHint", "accessibilityValue"}:
        return "sesli"
    if re.search(r"\.accessibility(Label|Hint|Value)\(", lit.code_line):
        return "sesli"
    if "AccessibilityNotification" in lit.code_line or "UIAccessibility.post" in lit.code_line:
        return "sesli"
    if call in DIALOG_CALLS:
        return "iletişim"
    if call in VISIBLE_CALLS or call[:1].isupper():
        return "görünür"
    return "değer"


# Türkçe harfi olmayan metinler için sözcük dağarcığı: Türkçe harfli metinlerden toplanır (collect).
# Bu sözcükler İngilizcede de geçtiği için sayılmaz.
NOT_TURKISH = {
    "widget", "lockglow", "the", "app", "group", "debug", "and", "of", "for", "to", "in", "on", "is",
    "it", "at", "be", "with", "can", "may", "word", "words", "first", "meal", "day", "content",
    "sqlite", "seed_words", "json", "iphone", "dikte",
}
_VOCAB: set[str] = set()


def _words(text: str) -> list[str]:
    return re.findall(r"[a-zçğıöşüâîû]+", re.sub(r"\\\([^)]*\)", " ", text).lower())


def _looks_turkish(text: str) -> bool:
    """Türkçe harf, kesme işaretli Türkçe ek ya da sözcüklerin en az yarısı Türkçe metinlerde geçiyor."""
    if any(ch in TURKISH_LETTERS for ch in text):
        return True
    if re.search(r"\w\**['’](y?[aeıiuü]|d[ae]n?|t[ae]n?|n[ıiuü]n|l[ae]r|[ıiuü]n)\b", text):
        return True
    words = [w for w in _words(text) if w not in NOT_TURKISH]
    known = [w for w in words if w in _VOCAB and len(w) >= 3]
    return bool(words) and len(known) * 2 >= len(words)


def _is_ui_text(lit: Literal) -> bool:
    t = lit.text.strip()
    if not t or not re.search(r"[A-Za-zÇĞİÖŞÜçğıöşü]", t):
        return False
    if re.fullmatch(r"[a-z0-9]+(_[a-z0-9]+)+", t):
        return False  # konu kimliği gibi anahtarlar ("music_film")
    if _looks_turkish(t):
        return True
    # Türkçe değil gibi: görünür ya da sesli bağlamda ve tanımlayıcıya benzemiyorsa yine al
    # (ör. ekranda duran İngilizce örnek cümle).
    if lit.kind in {"görünür", "sesli", "iletişim", "bildirim", "izin"}:
        return not (re.fullmatch(r"[\w.\-/:]+", t) and not t[:1].isupper())
    return False


def extract_swift(path: Path, include_preview: bool) -> list[Literal]:
    src = path.read_text(encoding="utf-8")
    lines = src.splitlines()
    literals, braces = _scan(src)
    previews = _preview_ranges(src, braces)
    out = []
    rel = path.relative_to(ROOT).as_posix()
    for start, _end, text, line in literals:
        in_preview = any(a <= start <= b for a, b in previews)
        if in_preview and not include_preview:
            continue
        call, label = _context(src, start)
        lit = Literal(rel, line, text, call, label, preview=in_preview, code_line=lines[line - 1].strip())
        lit.kind = _kind(lit)
        if lit.kind and _is_ui_text(lit):
            out.append(lit)
    return out


def extract_yaml(path: Path) -> list[Literal]:
    out = []
    rel = path.relative_to(ROOT).as_posix()
    for no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        m = re.match(r'\s*(NS\w+Description|CFBundleDisplayName)\s*:\s*"?(.*?)"?\s*$', line)
        if m:
            out.append(Literal(rel, no, m.group(2), m.group(1), "", "izin", code_line=line.strip()))
    return out


# --- Kurallar --------------------------------------------------------------------------------

def check(lit: Literal) -> list[str]:
    t, flags = lit.text, []
    if SUFFIX.search(t):
        flags.append("ek")
    if SIZ.search(t):
        flags.append("siz")
    if "!" in t:
        flags.append("ünlem")
    if PRAISE.search(t):
        flags.append("övgü")
    if PRESSURE.search(t):
        flags.append("baskı")
    for sentence in re.split(r"(?<=[.!?])\s+", t):
        if len(re.findall(r"[\wçğıöşüÇĞİÖŞÜ'’]+", re.sub(r"\\\([^)]*\)", "X", sentence))) > LONG_SENTENCE:
            flags.append("uzun")
            break
    if FOREIGN.search(re.sub(r"\\\([^)]*\)", "", t)):
        flags.append("yabancı")
    if ".uppercased()" in lit.code_line or ".capitalized" in lit.code_line:
        flags.append("büyük-harf")
    for _concept, (_ok, avoid) in TERMS.items():
        if any(re.search(a, t) for a in avoid):
            flags.append("karışık-ad")
            break
    return flags


def term_counts(lits: list[Literal]) -> list[tuple[str, str, int, list[str]]]:
    rows = []
    for concept, (ok, avoid) in TERMS.items():
        for pattern in [ok, *avoid]:
            hits = [l.where for l in lits if re.search(pattern, l.text)]
            rows.append((concept, pattern, len(hits), hits))
    return rows


def uppercased_calls(paths: list[Path]) -> list[str]:
    """Locale vermeden büyük harfe çeviren satırlar (Türkçede i → I olur, İ değil)."""
    out = []
    for p in paths:
        if p.suffix != ".swift":
            continue
        for no, line in enumerate(p.read_text(encoding="utf-8").splitlines(), 1):
            if re.search(r"\.uppercased\(\)|\.capitalized\b|textCase\(\.uppercase\)", line) and "//" not in line.split(".uppercased")[0][-3:]:
                out.append(f"{p.relative_to(ROOT).as_posix()}:{no}  {line.strip()}")
    return out


def collect(paths: list[str], include_preview: bool) -> tuple[list[Literal], list[Path]]:
    files: list[Path] = []
    for p in paths:
        full = ROOT / p
        if full.is_dir():
            files.extend(sorted(full.rglob("*.swift")))
        elif full.exists():
            files.append(full)
    # İlk geçiş: Türkçe harfli metinlerden sözcük dağarcığı.
    for f in files:
        if f.suffix == ".swift":
            for _start, _end, text, _line in _scan(f.read_text(encoding="utf-8"))[0]:
                if any(ch in TURKISH_LETTERS for ch in text):
                    _VOCAB.update(w for w in _words(text) if w not in NOT_TURKISH)
    lits: list[Literal] = []
    for f in files:
        lits.extend(extract_yaml(f) if f.suffix in {".yml", ".yaml"} else extract_swift(f, include_preview))
    for lit in lits:
        lit.flags = check(lit)
    return lits, files


def _md(text: str) -> str:
    return text.replace("|", "\\|").replace("\n", "⏎")


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("yollar", nargs="*", default=list(DEFAULT_PATHS), help="depo köküne göre dosya ya da klasör")
    ap.add_argument("--isaret", action="store_true", help="yalnız bir kurala takılan metinler")
    ap.add_argument("--terim", action="store_true", help="terim sayımı ve büyük harf çağrıları")
    ap.add_argument("--json", action="store_true", help="JSON çıktı")
    ap.add_argument("--onizleme", action="store_true", help="#Preview içindeki metinleri de al")
    args = ap.parse_args(argv)

    lits, files = collect(args.yollar, args.onizleme)
    if args.json:
        json.dump([asdict(l) for l in lits], sys.stdout, ensure_ascii=False, indent=1)
        return 0
    if args.terim:
        print("| Kavram | Desen | Sayı | Yerler |\n|---|---|---|---|")
        for concept, pattern, count, hits in term_counts(lits):
            print(f"| {concept} | `{pattern}` | {count} | {', '.join(hits[:6])}{' …' if len(hits) > 6 else ''} |")
        print("\nLocale vermeden büyük harf:\n")
        for row in uppercased_calls(files):
            print("- " + row)
        return 0
    shown = [l for l in lits if l.flags] if args.isaret else lits
    print(f"{len(lits)} metin, {len(files)} dosya. Gösterilen: {len(shown)}.\n")
    print("| Yer | Tür | Bağlam | Metin | İşaret |\n|---|---|---|---|---|")
    for l in shown:
        ctx = l.call + (f" {l.label}:" if l.label and l.label != l.call else "")
        print(f"| {l.where} | {l.kind} | {_md(ctx)} | {_md(l.text)} | {', '.join(l.flags)} |")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (BrokenPipeError, OSError):
        # Çıktı `head` gibi bir komuta verilip erken kapandı.
        raise SystemExit(0)
