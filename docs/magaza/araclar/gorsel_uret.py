"""App Store tanıtım görsellerini üretir (TASLAK).

Kâğıt rengi zemin, üstte kısa Türkçe başlık, başlıktaki İngilizce kelimede fosfor şeridi,
altta yuvarlatılmış ve gölgeli bir telefon. Telefonun içi uygulamanın gerçek ekran
görüntüsüdür; 1. ve 4. karede gerçek widget çıktıları bir kilit / ana ekran üstüne
yerleştirilir (montaj).

Kaynak: `screenshots.yml` çalıştırmasının "screenshots" artifact'i (Pro Max, 1320 x 2868).

    gh run download <id> -R yusufuyar68/lockglow -n screenshots -D <klasör>
    python -X utf8 docs/magaza/araclar/gorsel_uret.py --kaynak <klasör>/shots/large

Yazı tipleri (ikisi de serbest lisanslı; depoya eklenmedi, bilgisayarda aranır):
    Türkçe ve arayüz: Inter (değişken, SIL OFL 1.1). SF Pro'ya en yakın serbest yazı.
    İngilizce kelime: KaTeX_Main Bold (MIT, Khan Academy; Computer Modern tabanlı serif).
Bulunamazsa `--sans` ve `--serif` ile dosya yolu verilir (ya da LOCKGLOW_SANS / LOCKGLOW_SERIF).
SF Pro ve New York kullanılmaz: Apple lisansı yalnız Apple platformlarında arayüz taslağına izin verir.
"""

import argparse
import glob
import json
import os
import re
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

# MARK: - Renkler (ios/Shared/LockglowTheme.swift, açık tema)

BG = (0xF3, 0xF3, 0xEE)
INK = (0x15, 0x18, 0x1B)
INK2 = (0x4E, 0x55, 0x5B)
BAND = (0xF5, 0xE8, 0x29)
BAND_DARK = (0xE9, 0xE0, 0x40)
NIGHT = (0x0D, 0x0F, 0x11)

# Apple "Screenshot specifications" (22 Ekim 2026):
# zorunlu = iPhone with Dynamic Island (medium display); 6.9" en büyük ekran.
BOYUTLAR = {
    "6.9": (1320, 2868),   # iPhone with Dynamic Island (large display)
    "6.3": (1206, 2622),   # iPhone with Dynamic Island (medium display), zorunlu
    "6.5": (1284, 2778),   # iPhone with Face ID (large display), yedek
}

# MARK: - Kareler
# Başlıkta {…} = İngilizce kelime (serif + fosfor şeridi). Her başlıkta yalnız bir tane.
# ekran: "kaynak" (gerçek ekran görüntüsü), "kilit" / "ana" (widget montajı).
# tasma: telefon daha büyük çizilir, alt kısmı görselin dışına taşar (kırpılır).
# yakin: ekranın bir bölümü büyütülüp telefonun üstüne konur (yakın çekim).
#   kutu: ekran pikseli (1320 genişlikte), r: köşe yarıçapı (ekran pikseli),
#   genislik: görsel genişliğine oranı, merkez_y: görsel yüksekliğine oranı
#   (yoksa bölümün telefondaki yerine konur), kaydir: o yerden aşağı kayma (yükseklik oranı).

KARELER = [
    {
        "dosya": "01-kilit-ekrani-widget",
        "baslik": "Telefona her bakışta\nyeni kelime: {actually}",
        "alt": "Kilit ekranında, Türkçe anlamıyla",
        "ekran": "kilit",
        "tasma": True,
        "yakin": {"kutu": (345, 648, 975, 950), "r": 60, "genislik": 0.64, "merkez_y": 0.66},
    },
    {
        "dosya": "02-kelime-karti",
        "baslik": "{breakfast}\nne demek?",
        "alt": "Türkçesi, örneği ve sesi tek kartta",
        "ekran": "kaynak",
        "kaynak": "1-akis",
    },
    {
        "dosya": "03-tekrar",
        "baslik": "Unutmadan önce\n{breakfast} yine gelir",
        "alt": "Bildiğine göre tekrar zamanı ayarlanır",
        "ekran": "kaynak",
        "kaynak": "5-tekrar-kart-arka",
        "yakin": {"kutu": (24, 2290, 1296, 2762), "r": 60, "genislik": 0.90},
    },
    {
        "dosya": "04-widget-dinle",
        "baslik": "{misunderstanding}\nnasıl okunur?",
        "alt": "Uygulamayı açmadan, widget'tan dinle",
        "ekran": "ana",
        "tasma": True,
    },
    {
        "dosya": "05-dikkat",
        "baslik": "{spoon} derken\nhata nerede?",
        "alt": "Türkçeden gelen hatayı doğrusuyla gösterir",
        "ekran": "kaynak",
        "kaynak": "2-akis-ikinci-kart",
        "yakin": {"kutu": (102, 1560, 1218, 2045), "r": 48, "genislik": 0.86, "kaydir": 0.012},
    },
    {
        "dosya": "06-soyle",
        "baslik": "Sesli söyle:\n{look forward to}",
        "alt": "Sesin kaydedilmez, hiçbir yere gönderilmez",
        "ekran": "kaynak",
        "kaynak": "8b-soyle-sayfasi",
    },
    {
        "dosya": "07-sozluk",
        "baslik": "Türkçesini yaz,\n{breakfast} çıksın",
        "alt": "Birkaç harf yazman yeter",
        "ekran": "kaynak",
        "kaynak": "7-sozluk-arama",
    },
]

# MARK: - Yazı tipleri

SANS_ARAMA = [
    "%APPDATA%/D5/*/assets/Inter-V*.ttf",
    "%LOCALAPPDATA%/Microsoft/Windows/Fonts/Inter*Variable*.ttf",
    "C:/Windows/Fonts/Inter*Variable*.ttf",
    "%LOCALAPPDATA%/Microsoft/Windows/Fonts/Inter-V*.ttf",
]
SERIF_ARAMA = [
    "%LOCALAPPDATA%/Google/Chrome/User Data/*/Extensions/*/*/assets/KaTeX_Main-Bold-*.ttf",
    "%LOCALAPPDATA%/Microsoft/Windows/Fonts/KaTeX_Main-Bold*.ttf",
    "C:/Windows/Fonts/KaTeX_Main-Bold*.ttf",
]


def bul(ad, ortam, desenler):
    yol = os.environ.get(ortam)
    if yol and Path(yol).exists():
        return yol
    for desen in desenler:
        adaylar = sorted(glob.glob(os.path.expandvars(desen)))
        if adaylar:
            return adaylar[-1]
    sys.exit(f"{ad} yazı tipi bulunamadı. --{ad} ile yol ver ya da {ortam} ayarla.")


class Yazi:
    def __init__(self, sans, serif):
        self.sans_yol, self.serif_yol = sans, serif
        self._onbellek = {}

    def sans(self, boyut, agirlik=700):
        anahtar = ("sans", int(boyut), agirlik)
        if anahtar not in self._onbellek:
            f = ImageFont.truetype(self.sans_yol, int(boyut))
            eksen = f.get_variation_axes()
            f.set_variation_by_axes([agirlik] + [0] * (len(eksen) - 1))
            self._onbellek[anahtar] = f
        return self._onbellek[anahtar]

    def serif(self, boyut):
        anahtar = ("serif", int(boyut))
        if anahtar not in self._onbellek:
            self._onbellek[anahtar] = ImageFont.truetype(self.serif_yol, int(boyut))
        return self._onbellek[anahtar]


# MARK: - Yardımcılar


def yuvarlak_maske(boyut, yaricap, ss=3):
    """Kenarı yumuşatılmış yuvarlak dikdörtgen maskesi."""
    w, h = boyut
    m = Image.new("L", (w * ss, h * ss), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, w * ss - 1, h * ss - 1), yaricap * ss, fill=255)
    return m.resize((w, h), Image.LANCZOS)


def golge_ekle(zemin, katman, konum, bulaniklik, kayma, opaklik):
    """`katman`ın alfa şeklinden yumuşak bir gölge çizer."""
    a = katman.getchannel("A")
    pad = bulaniklik * 3
    g = Image.new("L", (a.width + 2 * pad, a.height + 2 * pad), 0)
    g.paste(a, (pad, pad))
    g = g.filter(ImageFilter.GaussianBlur(bulaniklik))
    g = g.point(lambda v: int(v * opaklik))
    renk = Image.new("RGBA", g.size, INK + (0,))
    renk.putalpha(g)
    zemin.alpha_composite(renk, (konum[0] - pad, konum[1] - pad + kayma))


def kaynak_yukle(klasor, ad):
    """manifest.json ile insan okunur adı (ör. "1-akis") gerçek dosyaya eşler."""
    klasor = Path(klasor)
    dogrudan = klasor / f"{ad}.png"
    if dogrudan.exists():
        return Image.open(dogrudan).convert("RGBA")
    manifest = klasor / "manifest.json"
    if manifest.exists():
        for test in json.loads(manifest.read_text(encoding="utf-8")):
            for ek in test["attachments"]:
                insan = re.sub(r"_\d+_[0-9A-F-]+\.png$", "", ek["suggestedHumanReadableName"])
                if insan == ad and (klasor / ek["exportedFileName"]).exists():
                    return Image.open(klasor / ek["exportedFileName"]).convert("RGBA")
    sys.exit(f"Kaynak bulunamadı: {ad} ({klasor})")


# MARK: - Başlık


def parcalara_ayir(satir):
    """"Unutmadan önce {breakfast}" → [("Unutmadan önce ", "tr"), ("breakfast", "en")]."""
    parcalar = []
    for i, p in enumerate(re.split(r"\{([^}]*)\}", satir)):
        if p:
            parcalar.append((p, "en" if i % 2 else "tr"))
    return parcalar


def serit_ciz(katman, x0, x1, taban, xyukseklik, em, ss=4):
    """Uygulamadaki gündüz şeridi: harflerin alt kısmının arkasında, eğik uçlu."""
    ust = taban - xyukseklik - 0.04 * em
    alt = taban + 0.07 * em
    k = 0.11 * em                      # eğim: üst kenar sağa kayık
    sol, sag = x0 - 0.05 * em, x1 + 0.03 * em
    nokta = [(sol + k, ust), (sag + k, ust), (sag, alt), (sol, alt)]
    kx0, ky0 = int(sol) - 4, int(ust) - 4
    kw, kh = int(sag + k - sol) + 10, int(alt - ust) + 10
    m = Image.new("L", (kw * ss, kh * ss), 0)
    ImageDraw.Draw(m).polygon([((x - kx0) * ss, (y - ky0) * ss) for x, y in nokta], fill=255)
    m = m.resize((kw, kh), Image.LANCZOS)
    renk = Image.new("RGBA", (kw, kh), BAND + (255,))
    renk.putalpha(m)
    katman.alpha_composite(renk, (kx0, ky0))


def baslik_sigdir(yazi, metin, W, boyut, kenar=0.07):
    """En uzun satır iki yanda %7 boşluk bırakacak kadar küçülür."""
    def en_uzun(b):
        s, e = yazi.sans(b, 800), yazi.serif(b * 1.16)
        return max(sum((e if dil == "en" else s).getlength(p) for p, dil in parcalara_ayir(satir))
                   for satir in metin.split("\n"))

    while en_uzun(boyut) > W * (1 - 2 * kenar) and boyut > 40:
        boyut -= 2
    return boyut


def baslik_ciz(tuval, yazi, metin, ust, boyut, satir_araligi=1.16):
    """Ortalanmış, çok satırlı başlık. Döner: son satırın alt kenarı."""
    d = ImageDraw.Draw(tuval)
    W = tuval.width
    sans = yazi.sans(boyut, 800)
    serif = yazi.serif(boyut * 1.16)
    yukselen = sans.getbbox("Ü", anchor="ls")[1] * -1   # büyük harf + nokta
    taban = ust + yukselen
    for satir in metin.split("\n"):
        parcalar = parcalara_ayir(satir)
        olcu = []
        for p, dil in parcalar:
            f = serif if dil == "en" else sans
            olcu.append((p, dil, f, f.getlength(p)))
        genislik = sum(o[3] for o in olcu)
        x = (W - genislik) / 2
        for p, dil, f, g in olcu:
            if dil == "en":
                xh = -f.getbbox("x", anchor="ls")[1]
                bb = f.getbbox(p, anchor="ls")
                serit_ciz(tuval, x + bb[0], x + bb[2], taban, xh, f.size)
            x += g
        x = (W - genislik) / 2
        for p, dil, f, g in olcu:
            d.text((x, taban), p, font=f, fill=INK, anchor="ls")
            x += g
        taban += boyut * satir_araligi
    return taban - boyut * satir_araligi + 0.22 * boyut


def alt_satir_ciz(tuval, yazi, metin, ust, boyut):
    d = ImageDraw.Draw(tuval)
    f = yazi.sans(boyut, 500)
    d.text((tuval.width / 2, ust), metin, font=f, fill=INK2, anchor="ma")
    return ust + boyut * 1.2


# MARK: - Telefon


def cerceve_kalinligi(w):
    return round(w * 0.032)


def telefon(ekran):
    """Ekran görüntüsünü (1320 x 2868) ince bir çerçeve ve Dynamic Island ile sarar."""
    w, h = ekran.size
    b = cerceve_kalinligi(w)
    r = round(w * 0.125)                 # ekran köşe yarıçapı
    W, H = w + 2 * b, h + 2 * b
    govde = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    dis = yuvarlak_maske((W, H), r + b)
    kenar = Image.new("RGBA", (W, H), (0x3A, 0x3F, 0x45, 255))
    kenar.putalpha(dis)
    govde.alpha_composite(kenar)
    ic = Image.new("RGBA", (W - 6, H - 6), (0x0B, 0x0C, 0x0E, 255))
    ic.putalpha(yuvarlak_maske((W - 6, H - 6), r + b - 3))
    govde.alpha_composite(ic, (3, 3))
    e = ekran.convert("RGBA")
    e.putalpha(yuvarlak_maske((w, h), r))
    govde.alpha_composite(e, (b, b))
    # Dynamic Island: 126 x 37 pt, üstten 11 pt (440 pt genişlikte)
    iw, ih = round(w * 126 / 440), round(w * 37 / 440)
    ix, iy = b + (w - iw) // 2, b + round(w * 11 / 440)
    ada = Image.new("RGBA", (iw, ih), (0, 0, 0, 255))
    ada.putalpha(yuvarlak_maske((iw, ih), ih // 2))
    govde.alpha_composite(ada, (ix, iy))
    return govde


# MARK: - Widget montajları


def canli_beyaz(render, zemin_l):
    """Kilit ekranı widget çıktısını (gri plaka, beyaz yazı) iOS'un 'vibrant' görünümüne
    çevirir: plaka yarı saydam beyaz, yazı tam beyaz."""
    r = render.convert("RGBA")
    l = r.convert("L")
    a = l.point(lambda v: int(255 * (0.20 + 0.80 * max(0.0, min(1.0, (v - zemin_l) / (255 - zemin_l))))))
    a = ImageChops.multiply(a, r.getchannel("A"))
    out = Image.new("RGBA", r.size, (255, 255, 255, 0))
    out.putalpha(a)
    return out


def dikey_gradyan(boyut, ust, alt):
    w, h = boyut
    serit = Image.new("RGB", (1, h))
    for y in range(h):
        t = y / (h - 1)
        serit.putpixel((0, y), tuple(round(ust[i] + (alt[i] - ust[i]) * t) for i in range(3)))
    return serit.resize((w, h)).convert("RGBA")


def durum_simgeleri(kaynak_ekran, beyaz):
    """Sağ üstteki Wi-Fi ve pil simgelerini gerçek ekran görüntüsünden alır
    (soldaki gri "operatör yok" noktaları alınmaz)."""
    w = kaynak_ekran.width
    kutu = (round(w * 0.77), round(w * 0.025), round(w * 0.975), round(w * 0.085))
    parca = kaynak_ekran.crop(kutu).convert("L")
    maske = parca.point(lambda v: 255 if v < 120 else int(max(0, 200 - v) * 255 / 80) if v < 200 else 0)
    renk = (255, 255, 255) if beyaz else INK
    s = Image.new("RGBA", parca.size, renk + (0,))
    s.putalpha(maske)
    return s, kutu


def yumusak_isik(tuval, merkez, yaricap, renk, opaklik):
    """Duvar kâğıdına bulanık, açık bir leke (düz gradyan yapay durmasın diye)."""
    m = Image.new("L", tuval.size, 0)
    cx, cy = merkez
    ImageDraw.Draw(m).ellipse((cx - yaricap, cy - yaricap, cx + yaricap, cy + yaricap), fill=int(255 * opaklik))
    m = m.filter(ImageFilter.GaussianBlur(yaricap * 0.5))
    k = Image.new("RGBA", tuval.size, renk + (0,))
    k.putalpha(m)
    tuval.alpha_composite(k)


# Montajlardaki saat, gerçek çekimlerin durum çubuğuyla aynı.
SAAT = "9:45"


def kilit_ekrani(kaynak, yazi):
    """Saat, tarih ve gerçek kilit ekranı widget'ı (actually) koyu bir duvar kâğıdında."""
    ref = kaynak_yukle(kaynak, "1-akis")
    w, h = ref.size
    pt = w / 440
    e = dikey_gradyan((w, h), (0x2C, 0x31, 0x37), NIGHT)
    yumusak_isik(e, (w * 0.15, h * 0.10), w * 0.75, (0x6B, 0x74, 0x7C), 0.55)
    yumusak_isik(e, (w * 0.95, h * 0.78), w * 0.55, (0x4E, 0x55, 0x5B), 0.45)
    d = ImageDraw.Draw(e)
    simge, kutu = durum_simgeleri(ref, beyaz=True)
    e.alpha_composite(simge, kutu[:2])
    d.text((w / 2, 74 * pt), "22 Ekim Perşembe", font=yazi.sans(21 * pt, 600), fill=(255, 255, 255, 235), anchor="mt")
    d.text((w / 2, 210 * pt), SAAT, font=yazi.sans(116 * pt, 600), fill=(255, 255, 255, 245), anchor="ms")
    rect = canli_beyaz(kaynak_yukle(kaynak, "rect-actually"), 71)
    rw = round(170 * pt)               # accessoryRectangular, Pro Max ~170 x 76 pt
    rect = rect.resize((rw, round(rect.height * rw / rect.width)), Image.LANCZOS)
    e.alpha_composite(rect, ((w - rw) // 2, round(228 * pt)))
    return e


def ana_ekran(kaynak, yazi):
    """Gerçek orta ve küçük widget çıktıları bir ana ekran düzeninde."""
    ref = kaynak_yukle(kaynak, "1-akis")
    w, h = ref.size
    pt = w / 440
    e = dikey_gradyan((w, h), (0x7A, 0x82, 0x88), (0x2B, 0x30, 0x36))
    yumusak_isik(e, (w * 0.85, h * 0.12), w * 0.7, (0xA9, 0xB0, 0xB5), 0.45)
    simge, kutu = durum_simgeleri(ref, beyaz=True)
    e.alpha_composite(simge, kutu[:2])
    ImageDraw.Draw(e).text((52 * pt, 34 * pt), SAAT, font=yazi.sans(17 * pt, 600), fill=(255, 255, 255, 255), anchor="lm")
    kenar, bosluk = 38 * pt, 24 * pt   # Pro Max: orta 364 x 170 pt, küçük 170 x 170 pt
    orta = kaynak_yukle(kaynak, "medium-misunderstanding")
    ow = round(364 * pt)
    orta = orta.resize((ow, round(orta.height * ow / orta.width)), Image.LANCZOS)
    y = round(78 * pt)
    e.alpha_composite(orta, (round(kenar), y))
    y += orta.height + round(bosluk)
    sw = round(170 * pt)
    for i, ad in enumerate(["small-fridge-koyu", "small-actually"]):
        k = kaynak_yukle(kaynak, ad).resize((sw, sw), Image.LANCZOS)
        e.alpha_composite(k, (round(kenar + i * (sw + 24 * pt)), y))
    y += sw + round(bosluk)
    koyu = kaynak_yukle(kaynak, "medium-under the weather-koyu")
    koyu = koyu.resize((ow, round(koyu.height * ow / koyu.width)), Image.LANCZOS)
    e.alpha_composite(koyu, (round(kenar), y))
    # iOS ana ekranının altındaki "Ara" kapsülü
    kw, kh = round(84 * pt), round(30 * pt)
    kx, ky = (w - kw) // 2, h - round(118 * pt)
    kapsul = Image.new("RGBA", (kw, kh), (255, 255, 255, 64))
    kapsul.putalpha(ImageChops.multiply(yuvarlak_maske((kw, kh), kh // 2), Image.new("L", (kw, kh), 64)))
    e.alpha_composite(kapsul, (kx, ky))
    d = ImageDraw.Draw(e)
    cx, cy, rr = kx + 24 * pt, ky + kh / 2 - 1 * pt, 5 * pt
    d.ellipse((cx - rr, cy - rr, cx + rr, cy + rr), outline=(255, 255, 255, 255), width=round(1.6 * pt))
    d.line((cx + rr * 0.7, cy + rr * 0.7, cx + rr * 1.6, cy + rr * 1.6), fill=(255, 255, 255, 255), width=round(1.8 * pt))
    d.text((cx + 12 * pt, ky + kh / 2), "Ara", font=yazi.sans(15 * pt, 600), fill=(255, 255, 255, 255), anchor="lm")
    return e


# MARK: - Kare


def kare_uret(kare, kaynak, yazi, W, H, baslik_boyutu):
    tuval = Image.new("RGBA", (W, H), BG + (255,))
    s = W / 1320
    alt = baslik_ciz(tuval, yazi, kare["baslik"], round(150 * s), baslik_boyutu)
    alt = alt_satir_ciz(tuval, yazi, kare["alt"], alt + 28 * s, round(46 * s))

    if kare["ekran"] == "kilit":
        ekran = kilit_ekrani(kaynak, yazi)
    elif kare["ekran"] == "ana":
        ekran = ana_ekran(kaynak, yazi)
    else:
        ekran = kaynak_yukle(kaynak, kare["kaynak"])
    t = telefon(ekran)

    ust = round(alt + 70 * s)
    if kare.get("tasma"):
        tw = round(W * 0.88)
    else:
        bos = H - ust - round(90 * s)
        tw = min(round(bos * t.width / t.height), round(W * 0.80))
    olcek = tw / t.width
    t = t.resize((tw, round(t.height * olcek)), Image.LANCZOS)
    x = (W - tw) // 2
    golge_ekle(tuval, t, (x, ust), round(60 * s), round(36 * s), 0.22)
    golge_ekle(tuval, t, (x, ust), round(10 * s), round(6 * s), 0.10)
    tuval.alpha_composite(t, (x, ust))

    if "yakin" in kare:
        y = kare["yakin"]
        x0, y0, x1, y1 = y["kutu"]
        b = cerceve_kalinligi(ekran.width)
        if "merkez_y" in y:
            merkez = y["merkez_y"] * H
        else:                                   # bölümün telefondaki yeri
            merkez = ust + (b + (y0 + y1) / 2) * olcek + y.get("kaydir", 0) * H
        yakin_ekle(tuval, ekran.crop((x0, y0, x1, y1)), y["r"], round(W * y["genislik"]), merkez, s)
    return tuval.convert("RGB")   # App Store: alfa kanalı olmamalı


def yakin_ekle(tuval, parca, r, genislik, merkez_y, s):
    """Ekranın bir bölümünü büyütür; beyaz kenarlı, gölgeli bir kart olarak koyar."""
    f = genislik / parca.width
    p = parca.resize((genislik, round(parca.height * f)), Image.LANCZOS).convert("RGBA")
    kenar = round(7 * s)
    kart = Image.new("RGBA", (p.width + 2 * kenar, p.height + 2 * kenar), (255, 255, 255, 255))
    kart.putalpha(yuvarlak_maske(kart.size, round(r * f) + kenar))
    p.putalpha(yuvarlak_maske(p.size, round(r * f)))
    kart.alpha_composite(p, (kenar, kenar))
    x = (tuval.width - kart.width) // 2
    y = round(merkez_y - kart.height / 2)
    golge_ekle(tuval, kart, (x, y), round(50 * s), round(30 * s), 0.30)
    tuval.alpha_composite(kart, (x, y))


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--kaynak", required=True, help="artifact içindeki shots/large klasörü")
    ap.add_argument("--cikti", default=str(Path(__file__).resolve().parents[1] / "gorseller"))
    ap.add_argument("--boyut", nargs="*", default=["6.9", "6.3"], choices=list(BOYUTLAR))
    ap.add_argument("--sadece", nargs="*", help="yalnız bu numaralı kareler (ör. 01 03)")
    ap.add_argument("--sans")
    ap.add_argument("--serif")
    a = ap.parse_args()

    yazi = Yazi(a.sans or bul("sans", "LOCKGLOW_SANS", SANS_ARAMA),
                a.serif or bul("serif", "LOCKGLOW_SERIF", SERIF_ARAMA))
    print("sans :", yazi.sans_yol)
    print("serif:", yazi.serif_yol)
    for ad in a.boyut:
        W, H = BOYUTLAR[ad]
        klasor = Path(a.cikti) / f"{ad}-{W}x{H}"
        klasor.mkdir(parents=True, exist_ok=True)
        # bütün karelerde aynı başlık boyutu: en uzun başlığa göre
        boyut = min(baslik_sigdir(yazi, k["baslik"], W, round(112 * W / 1320)) for k in KARELER)
        for kare in KARELER:
            if a.sadece and kare["dosya"][:2] not in a.sadece:
                continue
            yol = klasor / f"{kare['dosya']}.png"
            kare_uret(kare, a.kaynak, yazi, W, H, boyut).save(yol, optimize=True)
            print(yol)


if __name__ == "__main__":
    main()
