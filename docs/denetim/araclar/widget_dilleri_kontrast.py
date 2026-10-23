"""Widget dilleri (A, B, C) için kontrast tablosu (WCAG 2.2).

Renkleri `docs/tasarim/alternatifler/widget_dilleri.html` içindeki `const TOK = {...}`
bloğundan okur; sayfadaki tablo da aynı bloktan hesaplanır, iki sonuç aynı olmalı.

Kullanım (depo kökünden):
    python -X utf8 docs/denetim/araclar/widget_dilleri_kontrast.py

Kurallar (kontrast.py ile aynı):
- Oran: WCAG 2.2 "relative luminance" (sRGB, eşik 0.04045).
- Saydam renkler altındaki zeminle sRGB değerleri üzerinde karıştırılır.
- Eşikler: Lockglow'un küçük yazı hedefi 7:1 (ogrenme_ilkeleri.md), şerit üstündeki
  harf 4.5:1, kontrolün sınırı 3:1 (1.4.11), simge 4.5:1 (bizim hedefimiz).
"""

from __future__ import annotations

import json
import re
from pathlib import Path

PAGE = Path(__file__).resolve().parents[2] / "tasarim" / "alternatifler" / "widget_dilleri.html"


def parse(color: str) -> tuple[float, float, float, float]:
    color = color.strip()
    if color.startswith("#"):
        n = int(color[1:], 16)
        return ((n >> 16) & 255, (n >> 8) & 255, n & 255, 1.0)
    parts = [float(p) for p in re.search(r"rgba?\(([^)]+)\)", color).group(1).split(",")]
    return (parts[0], parts[1], parts[2], parts[3] if len(parts) > 3 else 1.0)


def over(top, below):
    a = top[3]
    return tuple(top[i] * a + below[i] * (1 - a) for i in range(3)) + (1.0,)


def luminance(c) -> float:
    def f(v: float) -> float:
        v /= 255
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
    return 0.2126 * f(c[0]) + 0.7152 * f(c[1]) + 0.0722 * f(c[2])


def flat(color: str, bg: str) -> str:
    r, g, b, _ = over(parse(color), parse(bg))
    return "#{:02X}{:02X}{:02X}".format(round(r), round(g), round(b))


def ratio(fg: str, bg: str) -> float:
    below = parse(bg)
    a, b = luminance(over(parse(fg), below)), luminance(below)
    return (max(a, b) + 0.05) / (min(a, b) + 0.05)


def tokens() -> dict:
    text = PAGE.read_text(encoding="utf-8")
    block = re.search(r"const TOK = (\{.*?\n\});", text, re.S).group(1)
    as_json = re.sub(r"([{,]\s*)(\w+):", r'\1"\2":', block)
    return json.loads(as_json)


def main() -> None:
    tok = tokens()
    langs = ["a", "b", "c", "o", "now"]
    rows = [
        ("Kelime ve anlam / zemin", 7, lambda t, l, m: ratio(t["ink"], t["bg"])),
        ("İkincil yazı / zemin", 7, lambda t, l, m: ratio(t["ink2"], t["bg"])),
        ("Gündüz: harf / şerit", 4.5, lambda t, l, m: ratio(t["ink"], t["band"]) if m == "day" and l != "c" else None),
        ("Şerit / zemin (süs)", None, lambda t, l, m: ratio(t["band"], t["bg"])),
        # Bugünkü kodda kenar yok: sınır, dairenin dolgusu (surface2) ile zemin arasıdır.
        ("Düğme sınırı / zemin", 3, lambda t, l, m: ratio(t["edge"], t["bg"]) if "edge" in t else ratio(t["btn"], t["bg"])),
        ("Düğme simgesi / düğme içi", 4.5, lambda t, l, m: (
            min(ratio(t["ink"], flat(t["btn"], t["bg"])), ratio(t["nextInk"], flat(t["next"], t["bg"])))
            if "next" in t else ratio(t["ink"], flat(t["btn"], t["bg"])) if "btn" in t else ratio(t["ink"], t["bg"]))),
    ]
    names = {"a": "A", "b": "B", "c": "C", "o": "Öneri", "now": "Bugün"}
    head = "| Çift | " + " | ".join(f"{names[l]} {m}" for l in langs for m in ("gündüz", "koyu")) + " |"
    print(head)
    print("|" + "---|" * (1 + 2 * len(langs)))
    for name, minimum, fn in rows:
        cells = []
        for l in langs:
            for m in ("day", "dark"):
                v = fn(tok[l][m], l, m)
                if v is None:
                    cells.append("—")
                else:
                    mark = "" if minimum is None else (" ✓" if v >= minimum else " ✗")
                    cells.append(f"{v:.2f}".replace(".", ",") + mark)
        print(f"| {name} | " + " | ".join(cells) + " |")
    print()
    print(f"StandBy gecesi: kırmızı / siyah {ratio('#E8382B', '#000000'):.2f}, ikincil %62 {ratio('rgba(232,56,43,.62)', '#000000'):.2f}")
    print("Gece zemininin parlaklığı (Y, %):", ", ".join(
        f"{names[l]} {luminance(parse(tok[l]['dark']['bg'])) * 100:.2f}" for l in langs))


if __name__ == "__main__":
    main()
