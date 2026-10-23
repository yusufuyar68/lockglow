"""Mağaza metinlerinin uzunluğunu ve anahtar kelime kurallarını denetler.

`kayit_metinleri_tr.md` ve `kayit_metinleri_en.md` içindeki alanları (her başlığın altındaki ilk
```text bloğu) okur; Apple sınırlarıyla karşılaştırır:

    python -X utf8 docs/magaza/araclar/metin_say.py

Sınırlar (App Store Connect, 23 Ekim 2026): ad ve alt başlık 30 karakter, tanıtım metni 170,
açıklama 4000 karakter, anahtar kelimeler 100 bayt (UTF-8), her anahtar kelime 2 karakterden uzun.
"""

import re
import sys
from pathlib import Path

KLASOR = Path(__file__).resolve().parents[1]

# başlık → (alan, sınır, birim)
ALANLAR = {
    "kayit_metinleri_tr.md": {
        "Ad": ("ad", 30, "karakter"),
        "Alt başlık": ("alt", 30, "karakter"),
        "Tanıtım metni (Promotional Text)": ("tanitim", 170, "karakter"),
        "Açıklama": ("aciklama", 4000, "karakter"),
        "Anahtar kelimeler": ("anahtar", 100, "bayt"),
    },
    "kayit_metinleri_en.md": {
        "Name": ("ad", 30, "karakter"),
        "Subtitle": ("alt", 30, "karakter"),
        "Promotional Text": ("tanitim", 170, "karakter"),
        "Description": ("aciklama", 4000, "karakter"),
        "Keywords": ("anahtar", 100, "bayt"),
    },
}


def bloklar(metin):
    """"## Başlık" → altındaki ilk ```text bloğu."""
    sonuc = {}
    for parca in re.split(r"^## ", metin, flags=re.M)[1:]:
        baslik, _, govde = parca.partition("\n")
        m = re.search(r"^```text\n(.*?)\n```", govde, flags=re.M | re.S)
        if m:
            sonuc[baslik.strip()] = m.group(1)
    return sonuc


def kucult(s):
    return s.replace("I", "ı").replace("İ", "i").lower()


def main():
    hata = 0
    for dosya, alanlar in ALANLAR.items():
        metin = (KLASOR / dosya).read_text(encoding="utf-8")
        b = bloklar(metin)
        degerler = {}
        print(f"== {dosya}")
        for baslik, (alan, sinir, birim) in alanlar.items():
            if baslik not in b:
                print(f"  {baslik}: blok bulunamadı")
                hata += 1
                continue
            deger = b[baslik]
            degerler[alan] = deger
            boy = len(deger.encode("utf-8")) if birim == "bayt" else len(deger)
            durum = "tamam" if boy <= sinir else "SINIRI AŞIYOR"
            hata += boy > sinir
            print(f"  {baslik}: {boy} / {sinir} {birim} · {durum}")
        if "anahtar" in degerler:
            kelimeler = degerler["anahtar"].split(",")
            kisa = [k for k in kelimeler if len(k) <= 2]
            bosluk = [k for k in kelimeler if k != k.strip()]
            ad_alt = set(re.findall(r"\w+", kucult(degerler.get("ad", "") + " " + degerler.get("alt", ""))))
            tekrar = [k for k in kelimeler if kucult(k) in ad_alt]
            cift = sorted({k for k in kelimeler if kelimeler.count(k) > 1})
            for ad, liste in [("2 karakter ya da kısa", kisa), ("boşluklu", bosluk),
                              ("ad/alt başlıkta da var", tekrar), ("iki kez", cift)]:
                if liste:
                    print(f"  anahtar kelime {ad}: {', '.join(liste)}")
                    hata += 1
    sys.exit(1 if hata else 0)


if __name__ == "__main__":
    main()
