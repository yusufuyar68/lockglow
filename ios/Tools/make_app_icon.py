"""Lockglow app icon: a keyhole carved out of the highlighter band. The icons are shapes only (fonts are
used just for the preview labels).

Concept and colours: docs/tasarim/README.md ("Kimlik: fosfor şeridi", "İkon") and appIcon() in
docs/tasarim/lockglow_ui_mockup.html. Drawn on the mockup's 120-unit grid; the band is taller and the
keyhole about 20 % larger than in the mockup so the keyhole still reads at 29 pt.

The keyhole is a hole: wherever it is, you see what is behind the band. Writes three 1024 x 1024 PNGs
next to the given AppIcon.png:
  AppIcon.png         default: yellow band on an ink background. Opaque, no alpha (App Store icon).
                      Ink rather than paper: yellow on paper differs by hue only (about 1.1:1 in
                      luminance) and the band all but disappears in grayscale; on ink it is 14:1.
  AppIcon-Dark.png    iOS 18+ dark: night-yellow band with a faint glow on a transparent background,
                      so the system's dark background shows around it and through the keyhole.
  AppIcon-Tinted.png  iOS 18+ tinted: light-gray band on a transparent background; the system tints it.
                      Gray pixels stored as RGBA (R = G = B), the format Xcode's own icons use.
Apple, "Configuring your app icon using an asset catalog": "Provide your tinted app icon as a grayscale
image. Provide your dark app icon with a transparent background so the system-provided background can
show through."
With --preview it also writes a contact sheet: each variant large and at 60, 40 and 29 pt (@3x).
"""
# Usage (Pillow required):
#   python -X utf8 ios/Tools/make_app_icon.py ios/App/Assets.xcassets/AppIcon.appiconset/AppIcon.png [--preview docs/tasarim/ikon_onizleme.png]
import argparse
import math
import os
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps

OUT = 1024
S = OUT * 4  # supersampled; downscaled at the end
U = S / 120  # one unit of the mockup's 120 x 120 grid

# Band: slanted highlighter stroke, centred on the canvas (mockup: M22 44 H104 L98 86 H16 Z).
BAND = [(22.5, 36), (104.5, 36), (97.5, 84), (15.5, 84)]
# Keyhole: round head over a slot that flares downward (mockup: head r 10, slot to y 80).
HEAD_X, HEAD_Y, HEAD_R = 60, 52.5, 12
SLOT_TOP_HALF, SLOT_BOTTOM, SLOT_BOTTOM_HALF = 6.5, 78.5, 9.6

# Tokens from LockglowTheme (docs/tasarim/README.md).
INK_TOP, INK_BOTTOM = (0x1F, 0x23, 0x28), (0x0B, 0x0D, 0x0F)  # ink, with the mockup's gentle gradient
PAPER_TOP, PAPER_BOTTOM = (0xFB, 0xFB, 0xF7), (0xE9, 0xE9, 0xE1)
BAND_DAY, BAND_NIGHT = (0xF5, 0xE8, 0x29), (0xE9, 0xE0, 0x40)
INK = (0x15, 0x18, 0x1B)
TINT_BAND = 0xE6  # tinted variant: light gray; the system maps luminance to the tint colour


def pt(x, y):
    return (x * U, y * U)


def band_mask():
    m = Image.new("L", (S, S), 0)
    ImageDraw.Draw(m).polygon([pt(x, y) for x, y in BAND], fill=255)
    return m


def keyhole_mask():
    m = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(m)
    d.ellipse((*pt(HEAD_X - HEAD_R, HEAD_Y - HEAD_R), *pt(HEAD_X + HEAD_R, HEAD_Y + HEAD_R)), fill=255)
    chord_y = HEAD_Y + math.sqrt(HEAD_R ** 2 - SLOT_TOP_HALF ** 2)  # slot starts where it meets the circle
    d.polygon([pt(HEAD_X - SLOT_TOP_HALF, chord_y), pt(HEAD_X + SLOT_TOP_HALF, chord_y),
               pt(HEAD_X + SLOT_BOTTOM_HALF, SLOT_BOTTOM), pt(HEAD_X - SLOT_BOTTOM_HALF, SLOT_BOTTOM)], fill=255)
    return m


def carved_band():
    return ImageChops.subtract(band_mask(), keyhole_mask())


def vertical_gradient(top, bottom, size=S):
    t = Image.linear_gradient("L").resize((size, size), Image.BICUBIC)
    return Image.composite(Image.new("RGB", (size, size), bottom), Image.new("RGB", (size, size), top), t)


def shrink(img):
    return img.resize((OUT, OUT), Image.LANCZOS)


def make_default(paper=False):
    """Ink background (chosen). paper=True draws the rejected paper version, for the preview only."""
    if paper:
        img = vertical_gradient(PAPER_TOP, PAPER_BOTTOM)
        img.paste(BAND_DAY, (0, 0, S, S), band_mask())
        img.paste(INK, (0, 0, S, S), keyhole_mask())
    else:
        img = vertical_gradient(INK_TOP, INK_BOTTOM)
        img.paste(BAND_DAY, (0, 0, S, S), carved_band())
    return shrink(img).convert("RGB")  # opaque: App Store icons may not have alpha


def make_dark():
    band = carved_band()
    # Faint, tight glow that follows the band ("Gece: şerit hafif ışır"); it never fills the keyhole.
    # Kept small: the HIG discourages custom glows and feathered edges.
    glow = band_mask().filter(ImageFilter.GaussianBlur(2 * U)).point(lambda v: int(v * 0.30))
    img = Image.new("RGBA", (S, S), BAND_NIGHT + (0,))
    img.putalpha(ImageChops.subtract(ImageChops.lighter(glow, band), keyhole_mask()))
    return shrink(img)


def make_tinted():
    img = Image.new("RGBA", (S, S), (TINT_BAND, TINT_BAND, TINT_BAND, 0))
    img.putalpha(carved_band())
    return shrink(img)


# ---------- preview ----------

def font(size, bold=False):
    names = ["segoeuib.ttf", "Arial Bold.ttf", "DejaVuSans-Bold.ttf"] if bold else ["segoeui.ttf", "Arial.ttf", "DejaVuSans.ttf"]
    for name in names:
        for folder in ("C:/Windows/Fonts", "/System/Library/Fonts/Supplemental", "/usr/share/fonts/truetype/dejavu"):
            try:
                return ImageFont.truetype(os.path.join(folder, name), size)
            except OSError:
                pass
    return ImageFont.load_default(size)


def on_home_screen(icon, kind, size, tint=None):
    """Roughly how iOS draws the icon at `size` px: a stand-in system background, then a rounded mask.
    Approximate: iOS uses a continuous corner, its own dark backdrop and its own tint mapping."""
    small = icon.resize((size, size), Image.LANCZOS)
    if kind == "dark":
        bg = vertical_gradient(INK_TOP, INK_BOTTOM, size)
        bg.paste(small.convert("RGB"), (0, 0), small.getchannel("A"))
        small = bg
    elif kind == "tinted":
        lum, a = small.convert("L"), small.getchannel("A")
        bg = Image.new("RGB", (size, size), tuple(int(c * 0.14) for c in tint))
        fg = Image.merge("RGB", [lum.point(lambda v, c=c: v * c // 255) for c in tint])
        bg.paste(fg, (0, 0), a)
        small = bg
    mask = Image.new("L", (size * 4, size * 4), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size * 4 - 1, size * 4 - 1), radius=int(size * 4 * 0.2237), fill=255)
    out = small.convert("RGBA")
    out.putalpha(mask.resize((size, size), Image.LANCZOS))
    return out


def make_preview(icons, path):
    light, dark = (0xF3, 0xF3, 0xEE), (0x0D, 0x0F, 0x11)
    on_light, on_dark = INK, (0xF3, 0xF4, 0xF0)
    paper = make_default(paper=True)

    def sizes(kind, tint=None):
        return [(on_home_screen(icons[kind], kind, px, tint), f"{name} · {px} px")
                for px, name in ((300, "büyük"), (180, "60 pt"), (120, "40 pt"), (87, "29 pt"))]

    def gray(tile):
        return Image.merge("RGBA", [*[ImageOps.grayscale(tile)] * 3, tile.getchannel("A")])

    rows = [
        ("Varsayılan", light, on_light, sizes("default")),
        ("Koyu (iOS 18+), sistem zemini yaklaşık", dark, on_dark, sizes("dark")),
        ("Renklendirilmiş (iOS 18+), örnek renkle, yaklaşık", dark, on_dark, sizes("tinted", (0xFF, 0xB3, 0x40))),
        ("Neden mürekkep zemin: 29 pt, renkli ve gri tonda", light, on_light, [
            (on_home_screen(icons["default"], "default", 87), "seçilen"),
            (gray(on_home_screen(icons["default"], "default", 87)), "seçilen, gri"),
            (on_home_screen(paper, "default", 87), "kâğıt zemin"),
            (gray(on_home_screen(paper, "default", 87)), "kâğıt, gri")]),
    ]
    pad, gap, head, foot = 48, 48, 64, 44
    f_title, f_label = font(30, bold=True), font(22)
    measure = ImageDraw.Draw(Image.new("L", (1, 1)))
    step = lambda tile, label: max(tile.width, int(measure.textlength(label, font=f_label)))
    tall = [max(tile.height for tile, _ in tiles) for *_, tiles in rows]
    width = pad * 2 + max(sum(step(*t) for t in tiles) + gap * (len(tiles) - 1) for *_, tiles in rows)
    sheet = Image.new("RGB", (width, sum(head + h + foot + pad for h in tall)), (255, 255, 255))
    d = ImageDraw.Draw(sheet)
    y0 = 0
    for (title, bg, fg, tiles), h in zip(rows, tall):
        d.rectangle((0, y0, width, y0 + head + h + foot + pad), fill=bg)
        d.text((pad, y0 + pad - 8), title, font=f_title, fill=fg)
        x = pad
        for tile, label in tiles:
            sheet.paste(tile, (x, y0 + head + pad + h - tile.height), tile)  # bottom-aligned
            d.text((x, y0 + head + pad + h + 10), label, font=f_label, fill=fg)
            x += step(tile, label) + gap
        y0 += head + h + foot + pad
    sheet.save(path, "PNG", optimize=True)
    print(path, sheet.size)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", help="path to AppIcon.png; the dark and tinted variants are written beside it")
    ap.add_argument("--preview", help="also write a contact sheet PNG here")
    args = ap.parse_args()
    stem, ext = os.path.splitext(args.out)
    icons = {"default": make_default(), "dark": make_dark(), "tinted": make_tinted()}
    for kind, suffix in (("default", ""), ("dark", "-Dark"), ("tinted", "-Tinted")):
        path = stem + suffix + ext
        icons[kind].save(path, "PNG", optimize=True)
        print(path, icons[kind].size, icons[kind].mode)
    if args.preview:
        make_preview(icons, args.preview)


if __name__ == "__main__":
    main()
