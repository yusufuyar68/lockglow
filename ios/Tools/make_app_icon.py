"""Lockglow app icon: a padlock with a glowing keyhole on an indigo gradient. Shapes only, no fonts."""
# Usage (Pillow required): python ios/Tools/make_app_icon.py ios/App/Assets.xcassets/AppIcon.appiconset/AppIcon.png
import sys
from PIL import Image, ImageDraw, ImageFilter

S = 2048  # supersampled; downscaled to 1024 at the end
out = sys.argv[1]

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

top, bottom = (24, 22, 64), (67, 56, 202)
bg = Image.new("RGB", (S, S))
px = bg.load()
for y in range(S):
    c = lerp(top, bottom, y / (S - 1))
    for x in range(S):
        px[x, y] = c

# Warm glow behind the lock.
glow = Image.new("L", (S, S), 0)
ImageDraw.Draw(glow).ellipse((S * 0.18, S * 0.24, S * 0.82, S * 0.88), fill=150)
glow = glow.filter(ImageFilter.GaussianBlur(S * 0.09))
amber = Image.new("RGB", (S, S), (251, 191, 36))
bg = Image.composite(amber, bg, glow)

d = ImageDraw.Draw(bg)
cream = (255, 247, 230)
# Shackle: thick arc above the body.
sw = int(S * 0.075)
d.arc((S * 0.32, S * 0.18, S * 0.68, S * 0.56), start=180, end=360, fill=cream, width=sw)
d.rectangle((S * 0.32, S * 0.37, S * 0.32 + sw, S * 0.50), fill=cream)
d.rectangle((S * 0.68 - sw, S * 0.37, S * 0.68, S * 0.50), fill=cream)
# Body.
d.rounded_rectangle((S * 0.24, S * 0.46, S * 0.76, S * 0.82), radius=int(S * 0.07), fill=cream)

# Keyhole with its own glow.
kh = Image.new("L", (S, S), 0)
kd = ImageDraw.Draw(kh)
cx, cy, r = S * 0.5, S * 0.60, S * 0.055
kd.ellipse((cx - r, cy - r, cx + r, cy + r), fill=255)
kd.polygon([(cx - r * 0.55, cy + r * 0.3), (cx + r * 0.55, cy + r * 0.3), (cx + r * 0.95, S * 0.74), (cx - r * 0.95, S * 0.74)], fill=255)
halo = kh.filter(ImageFilter.GaussianBlur(S * 0.02))
bg = Image.composite(Image.new("RGB", (S, S), (253, 224, 71)), bg, halo.point(lambda v: int(v * 0.6)))
bg = Image.composite(Image.new("RGB", (S, S), (245, 158, 11)), bg, kh)

icon = bg.resize((1024, 1024), Image.LANCZOS).convert("RGB")  # opaque: App Store icons may not have alpha
icon.save(out, "PNG", optimize=True)
print(out, icon.size, icon.mode)
