"""Lockglow app icon, iOS 26 icon layers and launch-screen mark, all from one geometry. Shapes only:
no letters and no name (the name is not final), fonts are used just for the preview labels.

Design "satir" (chosen 2026-10-23, is5-ikon; comparison of three candidates in the is5-ikon note):
a glowing line of text. Two dim lines of text with the phosphor band between them: the one word
that lights up, as the band does behind the English word in the app (docs/tasarim/README.md,
"Kimlik: fosfor şeridi"). The lines are ragged and left-aligned so the mark reads as text, not as
a menu. Design "anahtar" (the TestFlight icon until build 30: a keyhole carved out of the band)
can still be drawn with --design anahtar.

Drawn on a 1024 x 1024 canvas, the Icon Composer canvas; the PNGs are supersampled 4x. Writes, for
the app folder given (ios/App):
  Assets.xcassets/AppIcon.appiconset/
    AppIcon.png         default: the mark on an ink gradient. Opaque, no alpha (App Store icon).
    AppIcon-Dark.png    iOS 18 dark: night band with a faint, tight glow on a transparent
                        background, so the system's dark background shows around it.
    AppIcon-Tinted.png  iOS 18 tinted: gray shapes on a transparent background (R = G = B); the
                        system maps their luminance to the tint colour.
  AppIcon.icon/         iOS 26 Liquid Glass icon (Icon Composer bundle): icon.json and one SVG per
                        layer in Assets/. Xcode 26 builds the iOS 26 icon from it and generates the
                        icons for older iOS from it too; the appiconset above is the fallback when
                        the bundle is absent (and the reference for what the older icons show).
  Assets.xcassets/LaunchMark.imageset/
                        the mark without background for the launch screen (UILaunchScreen
                        UIImageName), 96 pt wide, @2x and @3x, light and dark.
Apple, "Configuring your app icon using an asset catalog": "Provide your tinted app icon as a
grayscale image. Provide your dark app icon with a transparent background so the system-provided
background can show through." Apple, "Creating your app icon using Icon Composer": layers on a
1024 x 1024 px canvas, SVG preferred, no background or mask in the layers (the fill is in
icon.json), text converted to outlines.
With --preview it also writes a contact sheet: each variant large and at 60, 40 and 29 pt (@3x),
the iOS 26 layers and the launch screen.
"""
# Usage (Pillow required):
#   python -X utf8 ios/Tools/make_app_icon.py ios/App [--preview docs/tasarim/ikon_onizleme.png] [--design anahtar]
import argparse
import json
import math
import os
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps

OUT = 1024
SS = 4  # supersampling factor
S = OUT * SS

# Tokens from LockglowTheme (docs/tasarim/README.md).
INK_TOP, INK_BOTTOM = (0x1F, 0x23, 0x28), (0x0B, 0x0D, 0x0F)  # ink, with the mockup's gentle gradient
BAND_DAY, BAND_NIGHT = (0xF5, 0xE8, 0x29), (0xE9, 0xE0, 0x40)
INK = (0x15, 0x18, 0x1B)
PAPER = (0xF3, 0xF4, 0xF0)  # ink at night
PAGE_DAY, PAGE_NIGHT = (0xF3, 0xF3, 0xEE), (0x00, 0x00, 0x00)  # Theme.bg: the launch screen's colour

LAUNCH_WIDTH_PT = 96


# ---------- geometry (1024-px canvas) ----------

def arc(cx, cy, r, a0, a1, steps_per_turn=256):
    """Points on a circle from angle a0 to a1 in degrees (0 = +x, y grows downward)."""
    n = max(2, int(abs(a1 - a0) / 360 * steps_per_turn) + 1)
    return [(cx + r * math.cos(math.radians(a0 + (a1 - a0) * i / (n - 1))),
             cy + r * math.sin(math.radians(a0 + (a1 - a0) * i / (n - 1)))) for i in range(n)]


def band(cx, top, bottom, width, slant):
    """The phosphor band: a parallelogram whose top edge starts `slant` in from the left and whose
    bottom edge ends `slant` before the right (PhosphorBandShape)."""
    left, right = cx - width / 2, cx + width / 2
    return [(left + slant, top), (right, top), (right - slant, bottom), (left, bottom)]


def capsule(x0, y0, x1, y1):
    r = (y1 - y0) / 2
    return arc(x1 - r, y0 + r, r, -90, 90) + arc(x0 + r, y0 + r, r, 90, 270)


def keyhole(cx, cy, r, top_half, bottom, bottom_half):
    """One outline: the head's major arc, then the slot that flares downward."""
    a = math.degrees(math.asin(top_half / r))  # half-angle of the slot's joint, from straight down
    return arc(cx, cy, r, 90 + a, 450 - a) + [(cx + bottom_half, bottom), (cx - bottom_half, bottom)]


class Layer:
    """One Icon Composer layer: outlines filled with the even-odd rule (an outline inside another
    is a hole), and its colour per appearance. `tinted` is a gray level; `glows` adds the faint
    night glow of the band (iOS 18 dark PNG only: Icon Composer adds its own light)."""

    def __init__(self, name, outlines, day, night, tinted, opacity=1.0, glows=False):
        self.name, self.outlines = name, outlines
        self.day, self.night, self.tinted = day, night, tinted
        self.opacity, self.glows = opacity, glows


def design_satir():
    # Ragged, left-aligned lines (600 and 380 px) a third of the band's height; 64 px gaps; the
    # group is centred on the canvas (x 180-844, y 257-767), clear of the edges.
    lines = Layer("lines", [capsule(200, 257, 800, 333), capsule(200, 691, 580, 767)],
                  day=PAPER, night=PAPER, tinted=0x8C, opacity=0.55)
    word = Layer("band", [band(512, 397, 627, 664, 49)], day=BAND_DAY, night=BAND_NIGHT, tinted=0xE6, glows=True)
    return [lines, word]


def design_anahtar():
    # The ui2-ikon geometry (mockup 120-unit grid x 8.533): the keyhole is a hole in the band.
    carved = Layer("band", [band(512, 307, 717, 760, 60), keyhole(512, 448, 102.4, 55.5, 670, 82)],
                   day=BAND_DAY, night=BAND_NIGHT, tinted=0xE6, glows=True)
    return [carved]


DESIGNS = {"satir": design_satir, "anahtar": design_anahtar}


# ---------- PNG ----------

def mask(outlines):
    m = Image.new("1", (S, S), 0)
    for outline in outlines:
        one = Image.new("1", (S, S), 0)
        ImageDraw.Draw(one).polygon([(x * SS, y * SS) for x, y in outline], fill=1)
        m = ImageChops.logical_xor(m, one)
    return m.convert("L")


def vertical_gradient(top, bottom, size=S):
    t = Image.linear_gradient("L").resize((size, size), Image.BICUBIC)
    return Image.composite(Image.new("RGB", (size, size), bottom), Image.new("RGB", (size, size), top), t)


def paint(img, colour, alpha):
    layer = Image.new("RGBA", img.size, colour + (0,))
    layer.putalpha(alpha)
    return Image.alpha_composite(img, layer)


def draw(layers, kind, background=None):
    """kind: "day", "night" or "tinted". background: an RGB image, or None for transparent."""
    img = background.convert("RGBA") if background else Image.new("RGBA", (S, S), (0, 0, 0, 0))
    for layer in layers:
        alpha = mask(layer.outlines)
        if layer.opacity < 1:
            alpha = alpha.point(lambda v, o=layer.opacity: round(v * o))
        if kind == "night" and layer.glows:
            # Faint, tight glow that follows the band ("Gece: şerit hafif ışır"). Kept small: the
            # HIG discourages custom glows and feathered edges.
            glow = alpha.filter(ImageFilter.GaussianBlur(17 * SS)).point(lambda v: round(v * 0.30))
            alpha = ImageChops.lighter(glow, alpha)
        colour = {"day": layer.day, "night": layer.night, "tinted": (layer.tinted,) * 3}[kind]
        img = paint(img, colour, alpha)
    return img


def shrink(img, size=OUT):
    return img.resize((size, size), Image.LANCZOS)


def make_default(layers):
    return shrink(draw(layers, "day", vertical_gradient(INK_TOP, INK_BOTTOM))).convert("RGB")  # opaque


def make_dark(layers):
    return shrink(draw(layers, "night"))


def make_tinted(layers):
    # Lines are drawn opaque in gray here: their dimness is the gray level, not transparency.
    opaque = [Layer(l.name, l.outlines, l.day, l.night, l.tinted) for l in layers]
    return shrink(draw(opaque, "tinted"))


def bounds(layers):
    xs = [x for l in layers for o in l.outlines for x, _ in o]
    ys = [y for l in layers for o in l.outlines for _, y in o]
    return min(xs), min(ys), max(xs), max(ys)


def make_launch(layers, scale, night):
    """The mark alone, cropped to its outlines, LAUNCH_WIDTH_PT wide at `scale`, without glow. The
    band keeps its colour; the lines take the page's ink, dim (the icon's lines are paper on ink)."""
    marked = [Layer(l.name, l.outlines, l.day, l.night, l.tinted, l.opacity) if l.glows
              else Layer(l.name, l.outlines, INK, PAPER, l.tinted, 0.40 if night else 0.30)
              for l in layers]
    big = draw(marked, "night" if night else "day")
    x0, y0, x1, y1 = bounds(layers)
    crop = big.crop((math.floor(x0 * SS), math.floor(y0 * SS), math.ceil(x1 * SS), math.ceil(y1 * SS)))
    width = LAUNCH_WIDTH_PT * scale
    return crop.resize((width, round(crop.height * width / crop.width)), Image.LANCZOS)


# ---------- Icon Composer ----------

def svg(layer):
    path = " ".join("M" + " L".join(f"{x:.2f} {y:.2f}" for x, y in o) + " Z" for o in layer.outlines)
    # The colour here only shows in Icon Composer's editor until the fill in icon.json applies.
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">\n'
            f'<path fill="#{"%02X%02X%02X" % layer.day}" fill-rule="evenodd" d="{path}"/>\n</svg>\n')


def colour(rgb):
    return "srgb:" + ",".join(f"{c / 255:.5f}" for c in rgb) + ",1.00000"


def icon_json(layers):
    """Only keys seen in files saved by Icon Composer (Signal-iOS, FeedKit, XcodeGen's test
    fixture). The first group is the front one. No blur: blur near the canvas edge can give the
    App Store "alpha channel" rejection (ITMS-90717)."""
    groups = []
    for layer in reversed(layers):
        groups.append({
            "layers": [{
                "fill-specializations": [
                    {"value": {"solid": colour(layer.day)}},
                    {"appearance": "dark", "value": {"solid": colour(layer.night)}},
                    {"appearance": "tinted", "value": {"solid": f"gray:{layer.tinted / 255:.5f},1.00000"}},
                ],
                "glass": True,
                "image-name": f"{layer.name}.svg",
                "name": layer.name,
                "opacity": layer.opacity,
                "position": {"scale": 1, "translation-in-points": [0, 0]},
            }],
            "lighting": "individual",
            "name": layer.name,
            "shadow": {"kind": "neutral", "opacity": 0.5},
            "specular": True,
            # Opaque glass keeps the band the brand's yellow; the lines are already dim.
            "translucency": {"enabled": False, "value": 0.5},
        })
    return {
        "fill-specializations": [
            {"value": {"linear-gradient": [colour(INK_TOP), colour(INK_BOTTOM)]}},
            {"appearance": "dark", "value": "system-dark"},
        ],
        "groups": groups,
        "supported-platforms": {"squares": "shared"},
    }


def write_text(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def write_icon_bundle(layers, folder):
    assets = os.path.join(folder, "Assets")
    if os.path.isdir(assets):
        for old in os.listdir(assets):
            os.remove(os.path.join(assets, old))  # e.g. a layer of the other design
    for layer in layers:
        write_text(os.path.join(folder, "Assets", f"{layer.name}.svg"), svg(layer))
    write_text(os.path.join(folder, "icon.json"), json.dumps(icon_json(layers), indent=2, ensure_ascii=False) + "\n")


LAUNCH_CONTENTS = {
    "images": [
        {"idiom": "universal", "scale": "1x"},
        {"appearances": [{"appearance": "luminosity", "value": "dark"}], "idiom": "universal", "scale": "1x"},
        {"filename": "LaunchMark@2x.png", "idiom": "universal", "scale": "2x"},
        {"appearances": [{"appearance": "luminosity", "value": "dark"}], "filename": "LaunchMark-Dark@2x.png",
         "idiom": "universal", "scale": "2x"},
        {"filename": "LaunchMark@3x.png", "idiom": "universal", "scale": "3x"},
        {"appearances": [{"appearance": "luminosity", "value": "dark"}], "filename": "LaunchMark-Dark@3x.png",
         "idiom": "universal", "scale": "3x"},
    ],
    "info": {"author": "xcode", "version": 1},
}


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


def rounded(img, radius=0.2237):
    """Rounded corners, the radius a fraction of the width (0.2237: the icon mask, approximately)."""
    w, h = img.size
    m = Image.new("L", (w * 4, h * 4), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, w * 4 - 1, h * 4 - 1), radius=int(w * 4 * radius), fill=255)
    out = img.convert("RGBA")
    out.putalpha(ImageChops.multiply(out.getchannel("A"), m.resize((w, h), Image.LANCZOS)))
    return out


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
    return rounded(small)


def layer_tile(layer, size=180):
    """One Icon Composer layer on a checkerboard (its own colour, its opacity)."""
    check = Image.new("RGB", (size, size), (0x2A, 0x2D, 0x31))
    d = ImageDraw.Draw(check)
    for y in range(0, size, 15):
        for x in range(0, size, 15):
            if (x // 15 + y // 15) % 2:
                d.rectangle((x, y, x + 14, y + 14), fill=(0x36, 0x3A, 0x3F))
    art = shrink(draw([layer], "day"), size)
    check.paste(art, (0, 0), art)
    return rounded(check, 0.08)


def launch_screen(mark, night, width=180):
    """A 390 x 844 pt screen at @3x with the @3x mark in the middle, shrunk to `width` px."""
    page = Image.new("RGB", (390 * 3, 844 * 3), PAGE_NIGHT if night else PAGE_DAY)
    page.paste(mark, ((page.width - mark.width) // 2, (page.height - mark.height) // 2), mark)
    ImageDraw.Draw(page).rounded_rectangle((0, 0, page.width - 1, page.height - 1), radius=int(page.width * 0.14),
                                           outline=(0x30, 0x35, 0x3B) if night else (0xDE, 0xDE, 0xD6), width=9)
    return rounded(page.resize((width, round(width * 844 / 390)), Image.LANCZOS), 0.14)


def make_preview(layers, icons, launch, path):
    light, dark = (0xF3, 0xF3, 0xEE), (0x0D, 0x0F, 0x11)
    on_light, on_dark = INK, (0xF3, 0xF4, 0xF0)

    def sizes(kind, tint=None):
        return [(on_home_screen(icons[kind], kind, px, tint), f"{name} · {px} px")
                for px, name in ((300, "büyük"), (180, "60 pt"), (120, "40 pt"), (87, "29 pt"))]

    def gray(tile):
        return Image.merge("RGBA", [*[ImageOps.grayscale(tile)] * 3, tile.getchannel("A")])

    rows = [
        ("Varsayılan", light, on_light, sizes("default") + [(gray(on_home_screen(icons["default"], "default", 87)), "gri tonda")]),
        ("Koyu (iOS 18), sistem zemini yaklaşık", dark, on_dark, sizes("dark")),
        ("Renklendirilmiş (iOS 18), örnek renkle, yaklaşık", dark, on_dark, sizes("tinted", (0xFF, 0xB3, 0x40))),
        ("iOS 26 katmanları (Icon Composer): zemin dolgusu icon.json'da", dark, on_dark,
         [(layer_tile(l), f"{l.name}.svg") for l in layers]),
        ("Açılış ekranı (gündüz, gece), işaret 96 pt", light, on_light,
         [(launch_screen(launch["day"], False), "gündüz"), (launch_screen(launch["night"], True), "gece")]),
    ]
    pad, gap, head, foot = 48, 48, 64, 44
    f_title, f_label = font(30, bold=True), font(22)
    measure = ImageDraw.Draw(Image.new("L", (1, 1)))
    step = lambda tile, label: max(tile.width, int(measure.textlength(label, font=f_label)))
    tall = [max(tile.height for tile, _ in tiles) for *_, tiles in rows]
    width = pad * 2 + max(sum(step(*t) for t in tiles) + gap * (len(tiles) - 1) for *_, tiles in rows)
    width = max(width, pad * 2 + max(int(measure.textlength(r[0], font=f_title)) for r in rows))
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
    ap.add_argument("app", help="the app folder (ios/App): writes into its Assets.xcassets and AppIcon.icon")
    ap.add_argument("--design", choices=sorted(DESIGNS), default="satir")
    ap.add_argument("--preview", help="also write a contact sheet PNG here")
    args = ap.parse_args()
    layers = DESIGNS[args.design]()
    assets = os.path.join(args.app, "Assets.xcassets")

    icons = {"default": make_default(layers), "dark": make_dark(layers), "tinted": make_tinted(layers)}
    for kind, suffix in (("default", ""), ("dark", "-Dark"), ("tinted", "-Tinted")):
        path = os.path.join(assets, "AppIcon.appiconset", f"AppIcon{suffix}.png")
        icons[kind].save(path, "PNG", optimize=True)
        print(path, icons[kind].size, icons[kind].mode)

    bundle = os.path.join(args.app, "AppIcon.icon")
    write_icon_bundle(layers, bundle)
    print(bundle, [l.name for l in layers])

    launch_folder = os.path.join(assets, "LaunchMark.imageset")
    launch = {}
    for night, suffix in ((False, ""), (True, "-Dark")):
        for scale in (2, 3):
            mark = make_launch(layers, scale, night)
            path = os.path.join(launch_folder, f"LaunchMark{suffix}@{scale}x.png")
            os.makedirs(launch_folder, exist_ok=True)
            mark.save(path, "PNG", optimize=True)
            print(path, mark.size)
        launch["night" if night else "day"] = mark
    write_text(os.path.join(launch_folder, "Contents.json"), json.dumps(LAUNCH_CONTENTS, indent=2) + "\n")

    if args.preview:
        make_preview(layers, icons, launch, args.preview)


if __name__ == "__main__":
    main()
