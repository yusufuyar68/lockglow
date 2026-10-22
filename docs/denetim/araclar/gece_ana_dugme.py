"""Gece ana düğmesi: A, B, C seçeneklerinin kontrastı (WCAG 2.2).

`ios/Shared/LockglowTheme.swift` içindeki tokenları `kontrast.py` ile okur. Uygulanan düğme
(C) tokenlardan gelir: dolgu `primary`, yazı ve gece kenarı `onPrimary`. Kenar kalınlıkları
koddaki `CapsuleButtonBody` ile aynı tutulmalı (aşağıdaki sabitler).

Kullanım (depo kökünden):
    python -X utf8 docs/denetim/araclar/gece_ana_dugme.py
    python -X utf8 docs/denetim/araclar/gece_ana_dugme.py --tema <başka LockglowTheme.swift>

Ölçülenler (her görünümde, düğmenin durduğu komşu zeminde):
- yazı / dolgu: dolgu komşunun üstüne karışır, yazı opak (hedef 7:1);
- kenar / komşu: kenar dolgunun üstüne çizilir (`strokeBorder`), komşu düğmenin dışıdır
  (hedef 3:1, WCAG 1.4.11). Gündüz kenar yok; sınırı dolgu verir;
- ikincil düğmeden ayrışma: ana kenar ile ikincil kenarın oranı (gündüz: iki dolgunun oranı).
  Hedef 3:1 (yalnız parlaklıkla ayrılan iki öğe için WCAG G183'teki eşik); ayrıca kenar
  kalınlığı ve yazı kalınlığı (renk dışı ipuçları, WCAG 1.4.1);
- Ort. L: 358 x 54 pt kapsülün ortalama bağıl parlaklığı (dolgu + kenar, yazı hariç).
"""

from __future__ import annotations

import argparse
import importlib.util
import math
import sys
from pathlib import Path

_spec = importlib.util.spec_from_file_location("kontrast", Path(__file__).with_name("kontrast.py"))
k = importlib.util.module_from_spec(_spec)
sys.modules["kontrast"] = k
_spec.loader.exec_module(k)
RGBA, ratio, luminance = k.RGBA, k.ratio, k.luminance

# CapsuleButtonBody (LockglowTheme.swift) ile aynı.
NIGHT_EDGE = 2.0          # gece ana düğme kenarı
NIGHT_EDGE_EMPHASIS = 3.0  # Kontrastı Artır ya da Düğme Şekilleri açıkken
BORDERED_EDGE = 1.5        # kenarlı ikincil (her zaman)
TONAL_EDGE = 1.0           # kenarsız ikincil, çip
TONAL_EDGE_EMPHASIS = 1.5

WIDTH, HEIGHT = 358.0, 54.0
TARGET_TEXT, TARGET_EDGE, TARGET_APART = 7.0, 3.0, 3.0

NEIGHBORS = (
    ("bg", "sayfa"),
    ("surface", "sayfa (sheet) `surface`"),
    ("surface2", "Dikkat kutusu `surface2`"),
)


def stack(*layers: RGBA) -> RGBA:
    """Alttan üste katmanlar; en alttaki opak."""
    color = layers[0]
    for layer in layers[1:]:
        color = layer.over(color)
    return color


def capsule_area(width: float, height: float) -> float:
    if width <= 0 or height <= 0:
        return 0.0
    return (width - height) * height + math.pi * (height / 2) ** 2


def mean_luminance(fill: RGBA, edge: RGBA | None, edge_width: float) -> float:
    total = capsule_area(WIDTH, HEIGHT)
    if edge is None or edge_width <= 0:
        return luminance(fill)
    inner = capsule_area(WIDTH - 2 * edge_width, HEIGHT - 2 * edge_width)
    return ((total - inner) * luminance(edge) + inner * luminance(fill)) / total


class Look:
    def __init__(self, tokens, mode: str, emphasis: bool):
        self.t = tokens
        self.mode = mode
        self.dark = mode.startswith("koyu")
        self.high = mode.endswith("YK")
        # Kontrastı Artır her zaman kalın kenar demek; Düğme Şekilleri ayrıca açılabilir.
        self.emphasis = emphasis or self.high

    def tok(self, name: str, alpha: float = 1.0) -> RGBA:
        c = self.t[name][self.mode]
        return RGBA(c.r, c.g, c.b, c.a * alpha)

    def secondary(self, kind: str, neighbor: RGBA):
        if kind == "kenarlı":
            fill = self.tok("surface")
            width = BORDERED_EDGE
        else:
            fill = self.tok("surface2")
            width = TONAL_EDGE_EMPHASIS if self.emphasis else TONAL_EDGE
        return dict(fill=fill, edge=stack(fill, self.tok("lineStrong")), width=width)

    def primary(self, option: str, neighbor: RGBA):
        if not self.dark:
            # Gündüz bütün seçeneklerde aynı: dolu mürekkep, beyaz yazı, kenar yok.
            fill = stack(neighbor, self.tok("primary"))
            return dict(fill=fill, text=self.tok("onPrimary"), edge=None, width=0.0, weight="yarı kalın")
        if option == "C":
            fill = stack(neighbor, self.tok("primary"))
            width = NIGHT_EDGE_EMPHASIS if self.emphasis else NIGHT_EDGE
            return dict(fill=fill, text=stack(fill, self.tok("onPrimary")),
                        edge=stack(fill, self.tok("onPrimary")), width=width, weight="kalın")
        if option == "A":  # is3-tema cfdd806
            fill = stack(neighbor, self.tok("band", 0.16))
            edge = stack(fill, self.tok("band", 0.7 if self.high else 0.45))
            return dict(fill=fill, text=self.tok("band"), edge=edge, width=1.5, weight="yarı kalın")
        if option == "B":  # alt-gece d255a64
            fill = stack(neighbor, self.tok("ink", 0.12))
            return dict(fill=fill, text=self.tok("ink"), edge=stack(fill, self.tok("ink", 0.45)),
                        width=1.5, weight="yarı kalın")
        if option == "H1":  # Yüksek Kontrast'ta dolu açık mürekkep (denenmiş, uygulanmadı)
            if self.high:
                fill = stack(neighbor, self.tok("ink"))
                return dict(fill=fill, text=self.tok("bg"), edge=None, width=0.0, weight="kalın")
            return self.primary("C", neighbor)
        raise ValueError(option)

    def measure(self, option: str, neighbor_name: str):
        neighbor = self.tok(neighbor_name)
        p = self.primary(option, neighbor)
        row = dict(text=ratio(p["text"], p["fill"]), p=p)
        outline = p["edge"] if p["edge"] is not None else p["fill"]
        row["edge"] = ratio(outline, neighbor)
        row["mean"] = mean_luminance(p["fill"], p["edge"], p["width"])
        for kind in ("kenarlı", "kenarsız"):
            s = self.secondary(kind, neighbor)
            if p["edge"] is None:
                apart = ratio(p["fill"], s["fill"])  # dolu düğme: dolgu farkı
            else:
                apart = ratio(p["edge"], s["edge"])
            row[kind] = dict(apart=apart, s=s, fill=ratio(p["fill"], s["fill"]),
                             mean=mean_luminance(s["fill"], s["edge"], s["width"]))
        return row


def fmt(value: float, target: float | None = None) -> str:
    text = f"{value:.2f}"
    if target is not None and value < target:
        if round(value, 2) >= target:
            text = f"{value:.4f}"  # 2,9997 "3,00" görünmesin
        text += " ❌"
    return text.replace(".", ",")


def pt(value: float) -> str:
    return f"{value:g}".replace(".", ",")


def pct(value: float) -> str:
    return f"%{value * 100:.1f}".replace(".", ",")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--tema", type=Path, default=k.THEME, help="LockglowTheme.swift yolu")
    args = parser.parse_args()
    tokens = k.read_tokens(args.tema)

    looks = [
        ("açık", False, ("bg", "surface", "surface2")),
        ("açık", True, ("bg",)),
        ("açık+YK", False, ("bg", "surface", "surface2")),
        ("koyu", False, ("bg", "surface", "surface2")),
        ("koyu", True, ("bg",)),
        ("koyu+YK", False, ("bg", "surface", "surface2")),
    ]
    names = dict(NEIGHBORS)

    print("## C (uygulanan): dört görünüm\n")
    print("| Görünüm | Komşu | Dolgu | Kenar | Yazı / dolgu (≥7) | Kenar / komşu (≥3) "
          "| Kenarlı ikincilden (≥3) | Kenarsız ikincilden (≥3) | Kenar pt (ana / kenarlı / kenarsız) "
          "| Ort. L (ana / kenarlı) |")
    print("|---|---|---|---|---|---|---|---|---|---|")
    for mode, buttons, neighbors in looks:
        look = Look(tokens, mode, buttons)
        label = mode + (" + Düğme Şekilleri" if buttons else "")
        for n in neighbors:
            r = look.measure("C", n)
            p = r["p"]
            edge_hex = p["edge"].css() if p["edge"] is not None else "yok (dolgu)"
            widths = " / ".join(pt(w) for w in (p["width"], r["kenarlı"]["s"]["width"], r["kenarsız"]["s"]["width"]))
            print(f"| {label} | {names[n]} | {p['fill'].css()} | {edge_hex} | {fmt(r['text'], TARGET_TEXT)} "
                  f"| {fmt(r['edge'], TARGET_EDGE)} | {fmt(r['kenarlı']['apart'], TARGET_APART)} "
                  f"| {fmt(r['kenarsız']['apart'], TARGET_APART)} | {widths} "
                  f"| {pct(r['mean'])} / {pct(r['kenarlı']['mean'])} |")
    print("\nGündüz satırlarında ana düğmenin kenarı yok: \"Kenar / komşu\" dolgunun sayfaya oranı, "
          "\"ikincilden\" iki dolgunun oranı.\n")

    print("## A, B, C: siyah sayfada (koyu ve koyu+YK)\n")
    print("| Seçenek | Görünüm | Dolgu | Kenar | Yazı / dolgu | Kenar / sayfa | Kenarlı ikincilden "
          "| Kenarsız ikincilden | Dolgu farkı (kenarlı) | Ort. L | Sarı odak |")
    print("|---|---|---|---|---|---|---|---|---|---|---|")
    for option, title, yellow in (("A", "A: tonal sarı", 2), ("B", "B: tonal mürekkep", 1),
                                  ("C", "C: B + 2 pt tam kenar + kalın", 1)):
        for mode in ("koyu", "koyu+YK"):
            r = Look(tokens, mode, False).measure(option, "bg")
            p = r["p"]
            print(f"| {title} | {mode} | {p['fill'].css()} | {p['edge'].css()}, {pt(p['width'])} pt "
                  f"| {fmt(r['text'], TARGET_TEXT)} | {fmt(r['edge'], TARGET_EDGE)} "
                  f"| {fmt(r['kenarlı']['apart'], TARGET_APART)} | {fmt(r['kenarsız']['apart'], TARGET_APART)} "
                  f"| {fmt(r['kenarlı']['fill'])} | {pct(r['mean'])} | {yellow} |")
    print()

    print("## Koyu+YK: ayrışma için denenenler (siyah sayfa)\n")
    look = Look(tokens, "koyu+YK", False)
    c = look.measure("C", "bg")
    h1 = look.measure("H1", "bg")
    print("| Yol | Kenarlı ikincilden | Kenarsız ikincilden | Bedeli |")
    print("|---|---|---|---|")
    print(f"| C, 2 pt | {fmt(c['kenarlı']['apart'], 3)} | {fmt(c['kenarsız']['apart'], 3)} | — |")
    print(f"| **C, 3 pt (uygulanan)** | {fmt(c['kenarlı']['apart'], 3)} + kenar 2 kat kalın + kalın yazı "
          f"| {fmt(c['kenarsız']['apart'], 3)} + kenar 2 kat kalın + kalın yazı | Ort. L {pct(c['mean'])} |")
    print(f"| Dolu açık mürekkep (yalnız YK) | {fmt(h1['kenarlı']['apart'], 3)} (dolgu) "
          f"| {fmt(h1['kenarsız']['apart'], 3)} (dolgu) | Ort. L {pct(h1['mean'])}: gece ekranda parlak alan |")
    white = look.tok("ink")
    print("\n`lineStrong` koyu+YK saydamlığı (bugün %56) düşürülürse:\n")
    def line_strong(alpha: float):
        line = RGBA(1, 1, 1, alpha)
        edges = (stack(look.tok("surface"), line), stack(look.tok("surface2"), line))
        weakest = min(ratio(e, look.tok(n)) for e in edges for n in ("bg", "surface", "surface2"))
        return weakest, min(ratio(white, e) for e in edges)

    print("| Saydamlık | En zayıf kontrol kenarı (bg, surface, surface2; YK hedefi 4,5) | Ana kenardan ayrışma (≥3) |")
    print("|---|---|---|")
    for alpha in (0.48, 0.50, 0.502, 0.505, 0.507, 0.51, 0.52, 0.54, 0.56):
        weakest, apart = line_strong(alpha)
        print(f"| %{pt(alpha * 100)} | {fmt(weakest, 4.5)} | {fmt(apart, 3)} |")
    window = [a / 1000 for a in range(400, 700) if line_strong(a / 1000)[0] >= 4.5 and line_strong(a / 1000)[1] >= 3]
    if window:
        low, high = (pt(a * 100) for a in (window[0], window[-1]))
        print(f"\nİkisini birlikte tutan aralık (binde bir adımla): %{low}–%{high}.")
    else:
        print("\nİkisini birlikte tutan saydamlık yok.")
    print()

    print("## Basılıyken (görünüm %85 opak) ve devre dışı (%40), koyu, siyah sayfa\n")
    print("Her katman ayrı ayrı saydamlaşır (yaklaşık). İkincil düğme basılı değil.\n")
    print("| Durum | Yazı / dolgu | Kenar / sayfa | Kenarlı ikincilden | Kenarsız ikincilden |")
    print("|---|---|---|---|---|")
    for state, alpha, exempt in (("basılı", 0.85, False), ("devre dışı (WCAG'de muaf)", 0.4, True)):
        look = Look(tokens, "koyu", False)
        neighbor = look.tok("bg")
        fill = stack(neighbor, look.tok("primary", alpha))
        on = look.tok("onPrimary", alpha)
        text, edge = stack(fill, on), stack(fill, on)
        goal = (lambda t: None) if exempt else (lambda t: t)
        apart = [ratio(edge, look.secondary(kind, neighbor)["edge"]) for kind in ("kenarlı", "kenarsız")]
        print(f"| {state} | {fmt(ratio(text, fill), goal(TARGET_TEXT))} | {fmt(ratio(edge, neighbor), goal(TARGET_EDGE))} "
              f"| {fmt(apart[0], goal(TARGET_APART))} | {fmt(apart[1], goal(TARGET_APART))} |")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
