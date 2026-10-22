"""Lockglow renk kontrastı denetimi (WCAG 2.2).

`ios/Shared/LockglowTheme.swift` içindeki renk tokenlarını okur, dört görünümde
(açık, koyu, açık + yüksek kontrast, koyu + yüksek kontrast) kodda kullanılan
yazı/zemin ve çizgi/zemin çiftlerinin kontrast oranını hesaplar.

Kullanım (depo kökünden):
    python -X utf8 docs/denetim/araclar/kontrast.py            # Markdown tablo
    python -X utf8 docs/denetim/araclar/kontrast.py --sadece-dusuk

Kurallar:
- Oran: WCAG 2.2 "relative luminance" (sRGB, eşik 0.04045).
- Saydam renkler, altındaki zeminle sRGB değerleri üzerinde karıştırılır
  (iOS çiziminin yaptığı gibi).
- Eşikler: normal yazı 4.5:1 (1.4.3), büyük yazı 3:1 (24 pt düz ya da
  18.66 pt kalın), yazı dışı öğeler 3:1 (1.4.11).
- Apple HIG eşiği biraz farklı: 17 pt'ye kadar 4.5:1, 18 pt ve üstü ya da
  her boyutta kalın yazı 3:1. Tabloda iki sonuç da gösterilir.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

THEME = Path(__file__).resolve().parents[3] / "ios" / "Shared" / "LockglowTheme.swift"
MODES = ("açık", "koyu", "açık+YK", "koyu+YK")


@dataclass(frozen=True)
class RGBA:
    r: float
    g: float
    b: float
    a: float = 1.0

    @staticmethod
    def hex(value: str, alpha: float = 1.0) -> "RGBA":
        n = int(value, 16)
        return RGBA(((n >> 16) & 0xFF) / 255, ((n >> 8) & 0xFF) / 255, (n & 0xFF) / 255, alpha)

    def over(self, below: "RGBA") -> "RGBA":
        """Bu rengi opak bir zeminin üstüne koyar."""
        a = self.a
        return RGBA(
            self.r * a + below.r * (1 - a),
            self.g * a + below.g * (1 - a),
            self.b * a + below.b * (1 - a),
            1.0,
        )

    def with_alpha(self, factor: float) -> "RGBA":
        return RGBA(self.r, self.g, self.b, self.a * factor)

    def css(self) -> str:
        return "#{:02X}{:02X}{:02X}".format(round(self.r * 255), round(self.g * 255), round(self.b * 255))


def luminance(c: RGBA) -> float:
    def lin(v: float) -> float:
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4

    return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b)


def ratio(a: RGBA, b: RGBA) -> float:
    la, lb = luminance(a), luminance(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


# --- Tokenları Swift dosyasından oku -------------------------------------------------------

TONE = re.compile(r"(\w+):\s*Tone\(0x([0-9A-Fa-f]{6})(?:,\s*([0-9.]+))?\)")
FIXED = re.compile(r"static let (\w+) = fixed\(0x([0-9A-Fa-f]{6})(?:,\s*([0-9.]+))?\)")


def balanced(text: str, start: int) -> str:
    """`start` konumundaki '(' ile eşleşen ')' arasındaki metin."""
    depth = 0
    for i in range(start, len(text)):
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
            if depth == 0:
                return text[start + 1 : i]
    raise ValueError("kapanmayan parantez")


def read_tokens(path: Path) -> dict[str, dict[str, RGBA]]:
    source = path.read_text(encoding="utf-8")
    tokens: dict[str, dict[str, RGBA]] = {}
    for match in re.finditer(r"static let (\w+) = dynamic\(", source):
        body = balanced(source, match.end() - 1)
        tones = {key: RGBA.hex(hx, float(al) if al else 1.0) for key, hx, al in TONE.findall(body)}
        light, dark = tones["light"], tones["dark"]
        tokens[match.group(1)] = {
            "açık": light,
            "koyu": dark,
            "açık+YK": tones.get("lightHigh", light),
            "koyu+YK": tones.get("darkHigh", dark),
        }
    for name, hx, al in FIXED.findall(source):
        color = RGBA.hex(hx, float(al) if al else 1.0)
        tokens[name] = {mode: color for mode in MODES}
    return tokens


# --- Kodda kullanılan çiftler --------------------------------------------------------------
# Renk yazımı: "ink", saydamlık eklemek için "ink@0.92". Zemin bir yığın: soldan sağa
# alttan üste ("surface>goodTint": surface üstünde goodTint).
# tür: "yazı" (4.5), "büyük" (3, büyük ya da 18.66 pt+ kalın), "kalın" (WCAG 4.5, HIG 3),
#      "öğe" (yazı dışı, 3), "bilgi" (eşik yok, yalnız bilgi için).


@dataclass(frozen=True)
class Pair:
    fg: str
    bg: str
    kind: str
    where: str
    # Çiftin gerçekten oluştuğu görünümler (ör. gündüz şeridi yalnız açık temada).
    modes: tuple[str, ...] = MODES


LIGHT = ("açık", "açık+YK")
DARK = ("koyu", "koyu+YK")


PAIRS = [
    # Ana metin
    Pair("ink", "bg", "yazı", "Sayfa başlıkları, açıklamalar (her ekran)"),
    Pair("ink", "surface", "yazı", "Kelime kartı, Türkçe anlam, örnek cümle, widget"),
    Pair("ink", "surface2", "yazı", "Dikkat kutusu, kapsül ve çip yazısı"),
    Pair("ink", "surface>band", "büyük", "Gündüz fosfor şeridi: kelimenin alt yarısı sarının üstünde (LockglowTheme.swift:401)", LIGHT),
    Pair("ink", "surface>markLight", "kalın", "Örnek cümlede sarı işaretli kelime, gündüz (ExampleMark, LockglowTheme.swift:484)", LIGHT),
    Pair("ink", "surface>goodTint", "yazı", "Söyle sonucu mesajı, quiz doğru şık (PronunciationPracticeView.swift:280)"),
    Pair("ink", "surface>badTint", "yazı", "Söyle sonucu mesajı, quiz yanlış şık"),
    Pair("ink", "surface>cautionTint", "yazı", "Söyle 'Neredeyse!' mesajı"),
    Pair("ink", "bg>tintSoft", "yazı", "Ayarlar satırına basılıyken (SettingsView.swift:692)"),
    # İkincil ve üçüncül
    Pair("ink2", "bg", "yazı", "Bölüm açıklamaları, alt yazılar"),
    Pair("ink2", "surface", "yazı", "Çeviri, IPA, açıklama (kart)"),
    Pair("ink2", "surface2", "yazı", "Dikkat açıklaması, seçilmemiş segment (GlowStyle.swift:108, CardDetailViews.swift:82)"),
    Pair("ink2", "surface>goodTint", "yazı", "Söyle 'Duyulan:' satırı (PronunciationPracticeView.swift:286)"),
    Pair("ink2", "surface>badTint", "yazı", "Söyle 'Duyulan:' satırı"),
    Pair("ink2", "surface>cautionTint", "yazı", "Söyle 'Duyulan:' satırı"),
    Pair("ink3", "bg", "yazı", "Yardımcı yazı (ReviewView.swift:1013)"),
    Pair("ink3", "surface", "yazı", "Yer tutucu, yardımcı yazı (SearchView.swift:201, SettingsView.swift:652)"),
    Pair("ink3", "surface2", "öğe", "Ok simgesi (chevron) kapsülde (FeedView.swift:413)"),
    # Anlam renkleri
    Pair("good", "surface", "kalın", "'Bildiğin kelime ✓' (FeedView.swift:451), Sözlük durum"),
    Pair("good", "bg", "kalın", "Durum yazısı sayfa zemininde"),
    Pair("good", "surface2", "kalın", "Dikkat kutusunda '✓ Doğru' etiketi (CardDetailViews.swift:114)"),
    Pair("good", "surface>goodTint", "büyük", "Quiz 'Doğru cevap', Söyle 'Doğru!' başlığı (title3 kalın)"),
    Pair("bad", "surface", "kalın", "Sıfırla düğmesi (SettingsView.swift:382)"),
    Pair("bad", "surface2", "kalın", "Dikkat kutusunda '✕ Yanlış' etiketi (CardDetailViews.swift:114)"),
    Pair("bad", "surface>badTint", "büyük", "Quiz 'Yanlış', Söyle 'Bir daha dene' başlığı"),
    Pair("caution", "surface2", "öğe", "Dikkat üçgeni (CardDetailViews.swift:96)"),
    Pair("caution", "surface", "yazı", "Az kelime uyarısı (DeckSummaryLine.swift:30), Ayarlar uyarısı"),
    Pair("caution", "surface>cautionTint", "büyük", "Söyle 'Neredeyse!' başlığı"),
    # Dolu düğmeler
    Pair("onPrimary", "primary", "kalın", "Ana düğme yazısı (PrimaryCapsuleButtonStyle)"),
    Pair("onPrimary@0.92", "primary", "yazı", "Varsayılan cevap düğmesinin süre alt yazısı (ReviewView.swift:919)"),
    Pair("bg", "ink", "kalın", "Geri alındı bildirimi (KnownWordsView.swift:207)"),
    Pair("surface", "good", "öğe", "Widget sağlığı ✓ simgesi yeşil daire içinde (WidgetHealthView.swift:300)"),
    Pair("surface", "bad", "öğe", "Widget sağlığı ⚠ simgesi kırmızı daire içinde"),
    # Yazı dışı öğeler (1.4.11)
    Pair("lineStrong", "surface", "öğe", "Kenarlı kapsül ve seçenek kenarı kart üstünde"),
    Pair("lineStrong", "bg", "öğe", "Kenarlı kapsül kenarı sayfa zemininde (SecondaryCapsuleButtonStyle)"),
    Pair("surface2", "bg", "öğe", "Kenarsız (tonal) kapsül ve cevap düğmesi sayfa zemininde"),
    Pair("surface2", "surface", "öğe", "Kenarsız kapsül, çip ve Dikkat kutusu kart üstünde"),
    Pair("surface", "bg", "öğe", "Kart ve kenarlı kapsül dolgusu sayfa zemininde (kenar çizgisi ayrıca var)"),
    Pair("tint", "surface", "öğe", "Seçili seçenek ve segment çerçevesi"),
    Pair("tint", "surface3", "öğe", "İlerleme çubuğu dolgusu izin üstünde (ReviewView.swift:871)"),
    Pair("surface3", "surface", "öğe", "Açılış seviye noktası (boş) ve adım çubuğu (OnboardingView.swift:93, :342)"),
    Pair("surface3", "bg", "öğe", "İlerleme izi sayfa zemininde"),
    Pair("bg>ink3@0.35", "bg", "öğe", "Seviye rozetinde boş nokta (LevelBadge, LockglowTheme.swift:694)"),
    Pair("ink3", "surface", "öğe", "Seçilmemiş daire simgesi (GlowStyle.swift:48)"),
    Pair("line", "surface", "bilgi", "Ayırıcı çizgi (yalnız süs)"),
    Pair("primary", "bg", "öğe", "Ana düğmenin şekli sayfa zemininde"),
    Pair("good", "surface", "öğe", "Ayarlar anahtarı açıkken iz rengi (SettingsView.swift:252)"),
    # Marka
    Pair("bandLight", "surface", "bilgi", "Gündüz fosfor şeridi kart üstünde", LIGHT),
    Pair("bandDark", "surface", "bilgi", "Gece şerit çizgisi kart üstünde", DARK),
    # Devre dışı düğme (görünüm %40 saydam; WCAG devre dışı öğeleri eşikten muaf tutar)
    Pair("bg>onPrimary@0.4", "bg>primary@0.4", "bilgi", "Devre dışı ana düğme, ör. seviye seçilmeden 'Devam', 'Konular hazırlanıyor…' (OnboardingView.swift:117, LockglowTheme.swift:554)"),
    Pair("bg>ink@0.4", "bg>surface@0.4", "bilgi", "Devre dışı kenarlı kapsül"),
]

THRESHOLD = {"yazı": 4.5, "büyük": 3.0, "kalın": 4.5, "öğe": 3.0, "bilgi": 0.0}
HIG_THRESHOLD = {"yazı": 4.5, "büyük": 3.0, "kalın": 3.0, "öğe": 3.0, "bilgi": 0.0}


def resolve(spec: str, mode: str, tokens: dict[str, dict[str, RGBA]], base: RGBA | None = None) -> RGBA:
    """Bir renk yığınını ("surface>goodTint", "ink@0.92") opak bir renge çevirir."""
    color = base
    for part in spec.split(">"):
        name, _, extra = part.partition("@")
        layer = tokens[name][mode]
        if extra:
            layer = layer.with_alpha(float(extra))
        if color is None:
            # En alttaki katman saydamsa, görünümün sayfa zeminine oturur.
            color = layer if layer.a >= 1 else layer.over(tokens["bg"][mode])
        else:
            color = layer.over(color)
    assert color is not None
    return color


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--tema", type=Path, default=THEME, help="LockglowTheme.swift yolu")
    parser.add_argument("--sadece-dusuk", action="store_true", help="yalnız eşiğin altındaki satırlar")
    parser.add_argument("--tokenlar", action="store_true", help="token değerlerini de yaz")
    parser.add_argument("--oneri", action="store_true", help="kenar çizgisi için gereken saydamlığı hesapla")
    args = parser.parse_args()

    tokens = read_tokens(args.tema)

    if args.tokenlar:
        print("| Token | " + " | ".join(MODES) + " |")
        print("|---|" + "---|" * len(MODES))
        for name, values in tokens.items():
            cells = []
            for mode in MODES:
                c = values[mode]
                cells.append(c.css() + ("" if c.a >= 1 else f" %{round(c.a * 100)}"))
            print(f"| `{name}` | " + " | ".join(cells) + " |")
        print()

    print("| Yazı / öğe | Zemin | Tür | " + " | ".join(MODES) + " | Nerede |")
    print("|---|---|---|" + "---|" * len(MODES) + "---|")
    failures = 0
    for pair in PAIRS:
        cells = []
        low = False
        for mode in MODES:
            if mode not in pair.modes:
                cells.append("—")
                continue
            bg = resolve(pair.bg, mode, tokens)
            # Yazı ya da öğe zeminin üstüne çizilir (saydamsa zeminle karışır).
            fg = resolve(pair.fg, mode, tokens, base=bg)
            r = ratio(fg, bg)
            need = THRESHOLD[pair.kind]
            hig = HIG_THRESHOLD[pair.kind]
            mark = ""
            if need and r < need:
                mark = " ❌" if r < hig else " ⚠️"
                low = True
            cells.append(f"{r:.2f}{mark}")
        if args.sadece_dusuk and not low:
            continue
        failures += low
        print(f"| `{pair.fg}` | `{pair.bg}` | {pair.kind} | " + " | ".join(cells) + f" | {pair.where} |")
    print()
    print("❌ WCAG ve Apple HIG eşiğinin altında. ⚠️ WCAG eşiğinin altında, HIG'in kalın yazı eşiğinin (3:1) üstünde.")
    print(f"Eşiğin altında en az bir görünümde kalan çift: {failures}")

    if args.oneri:
        print()
        print("Öneri: kenar çizgisinin 3:1 için gereken en az saydamlığı (sayfa ve kart zemininde)")
        for mode, ink_hex in (("açık", "15181B"), ("koyu", "FFFFFF")):
            need = 0.0
            for base_name in ("bg", "surface"):
                base = tokens[base_name][mode]
                for step in range(0, 101):
                    alpha = step / 100
                    if ratio(RGBA.hex(ink_hex, alpha).over(base), base) >= 3.0:
                        need = max(need, alpha)
                        break
            print(f"- {mode}: #{ink_hex} %{round(need * 100)} (şimdi lineStrong {tokens['lineStrong'][mode].a:.2f}, YK {tokens['lineStrong'][mode + '+YK'].a:.2f})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
