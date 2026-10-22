# Gece ana düğmesi: C seçeneği (22 Ekim 2026)

**Ne:** Koyu modda (uygulamanın gece teması) ekranın tek ana düğmesi artık sarı değil.
- **Önce (A):** %16 sarı dolgu, sarı yazı, 1,5 pt sarı kenar (%45; Yüksek Kontrast'ta %70).
- **Şimdi (C):** %12 mürekkep dolgu, mürekkep yazı **kalın**, **2 pt tam mürekkep kenar**. Kontrastı Artır ya da Düğme Şekilleri açıkken kenar **3 pt**.
- Sarı artık yalnız kelimede (şerit ve örnek cümledeki işaret).
- Gündüz hiçbir şey değişmedi: ana düğme dolu mürekkep, beyaz yazı.
- Dal: `is4-tema`. Dosyalar: `ios/Shared/LockglowTheme.swift`, `ios/App/GlowStyle.swift`. API (adlar, imzalar) aynı.
- Kaynaklar:
  - [`../tasarim/alternatifler/gece_oled.md`](../tasarim/alternatifler/gece_oled.md), "Mevcut koyu temaya" 2. madde (A, B, C tablosu);
  - [`kontrast_tema_2026-10-22.md`](kontrast_tema_2026-10-22.md), bölüm 4 (A'nın ölçümü, B'ye geçiş satırları).

**Nasıl hesaplandı:**
- Betik: [`araclar/gece_ana_dugme.py`](araclar/gece_ana_dugme.py). Tokenları `LockglowTheme.swift`'ten `kontrast.py` ile okur. Bu sayfadaki tabloların hepsi onun çıktısı.
  ```
  python -X utf8 docs/denetim/araclar/gece_ana_dugme.py
  ```
- **Bağımsız denetim:** ayrı bir Opus denetçi değerleri kendi betiğiyle, tokenları Swift dosyasından elle okuyarak yeniden hesapladı. Bütün sayılar ±0,01 içinde aynı. Bulduğu iki eksik (basılı satırı 2,9997'yi "3,00" gösteriyordu; `lineStrong` taraması dar aralığı atlıyordu) düzeltildi.
- Formül WCAG 2.2. Saydam renkler alttakiyle sRGB'de karıştırılır (iOS'un yaptığı gibi).
- Çizim sırası koddaki gibi: komşu zemin → düğme dolgusu → kenar (`strokeBorder` dolgunun üstüne, şeklin içine) → yazı.
- Düğmenin durabileceği üç komşu:
  - sayfa `bg` (gece #000);
  - sheet `surface` (#191C20; ör. Söyle sayfası, `presentationBackground(Theme.surface)`);
  - Dikkat kutusu `surface2` (yalnız bilgi için; orada ana düğme yok).
- **Hedefler** (görev):
  - yazı / dolgu en az **7:1**;
  - kenar / komşu en az **3:1** (WCAG 1.4.11);
  - ana ve ikincil düğme **açıkça ayrışmalı**. Görev sayı vermiyor. Ölçü olarak: ana kenarın ikincil düğme kenarına oranı en az **3:1**. Bu bir WCAG zorunluluğu değil, bir tasarım ölçüsü. Eşik WCAG G183'ten uyarlandı (orada: yalnız parlaklıkla ayrılan bağlantı ile metin arasında 3:1). Ayrıca renk dışı ipuçları sayıldı: kenar kalınlığı, yazı kalınlığı (WCAG 1.4.1).
- **İkincil düğmeler:**
  - kenarlı: `surface` dolgu + 1,5 pt `lineStrong`;
  - kenarsız (tonal): `surface2` dolgu + 1 pt `lineStrong` (YK ya da Düğme Şekilleri: 1,5 pt).
- **Ort. L:** 358 × 54 pt kapsülün ortalama bağıl parlaklığı (dolgu + kenar, yazı hariç). Gece ne kadar ışık verdiğini gösterir.
- **Kısaltmalar:** YK = Yüksek Kontrast (Kontrastı Artır), DŞ = Düğme Şekilleri. ❌ = hedefin altında.

---

## 1. Sonuç

| Görünüm | Yazı ≥ 7 | Kenar ≥ 3 | İkincilden ayrışma | Karar |
|---|---|---|---|---|
| Açık | 17,82 ✓ | 16,01 ✓ (dolgu) | dolgu 14,88–17,82 ✓ | Değişmedi |
| Açık + YK | 19,57 ✓ | 17,58 ✓ (dolgu) | dolgu 16,34–19,57 ✓ | Değişmedi |
| Koyu (gece) | 9,38–15,22 ✓ | 13,42–19,01 ✓ | **3,69–4,08 ✓** + kenar 2 pt (ikincil 1–1,5) + kalın yazı | **C uygulandı** |
| Koyu + DŞ | 15,22 ✓ | 19,01 ✓ | 3,69–4,08 ✓ + kenar 3 pt (ikincil 1,5) | C, kalın kenar |
| Koyu + YK | 10,14–16,56 ✓ | 14,83–21,00 ✓ | **2,61–2,78** (3'ün altı) + kenar **3 pt** (ikincil 1,5: iki kat) + kalın yazı | **En yakın düzeltme** (bölüm 4) |

- C dört görünümün üçünde bütün hedefleri tutuyor.
- **Koyu + YK'de ayrışma 3:1'e ulaşamıyor.** Neden: YK'de ikincil düğmenin kenarı da parlıyor (`lineStrong` %56). Ana kenar zaten tam beyaz; hiçbir kenar rengi 2,78'i geçemez.
- **En yakın düzeltme:** YK ya da DŞ açıkken ana kenar 2 pt yerine 3 pt. Ana düğme o zaman ikincil düğmeden parlaklık (2,6–2,8:1), kenar kalınlığı (iki kat) ve yazı kalınlığı ile ayrılıyor. Renk dışı iki ipucu var; WCAG 1.4.1'e göre ayrışma yalnız renge (parlaklığa) dayanmıyor.
- **A'da kalmak daha kötü olurdu:** A'nın ikincil düğmeden parlaklık farkı her modda 1,01–1,12:1 (bölüm 3). A yalnız renk tonuyla (sarı / gri) ayrılıyor; kenar kalınlığı da aynı (1,5 pt).

## 2. C: dört görünüm

| Görünüm | Komşu | Dolgu | Kenar | Yazı / dolgu (≥7) | Kenar / komşu (≥3) | Kenarlı ikincilden (≥3) | Kenarsız ikincilden (≥3) | Kenar pt (ana / kenarlı / kenarsız) | Ort. L (ana / kenarlı) |
|---|---|---|---|---|---|---|---|---|---|
| açık | sayfa | #15181B | yok (dolgu) | 17,82 | 16,01 | 17,82 | 14,88 | 0 / 1,5 / 1 | %0,9 / %95,2 |
| açık | sayfa (sheet) `surface` | #15181B | yok (dolgu) | 17,82 | 17,82 | 17,82 | 14,88 | 0 / 1,5 / 1 | %0,9 / %95,2 |
| açık | Dikkat kutusu `surface2` | #15181B | yok (dolgu) | 17,82 | 14,88 | 17,82 | 14,88 | 0 / 1,5 / 1 | %0,9 / %95,2 |
| açık + Düğme Şekilleri | sayfa | #15181B | yok (dolgu) | 17,82 | 16,01 | 17,82 | 14,88 | 0 / 1,5 / 1,5 | %0,9 / %95,2 |
| açık+YK | sayfa | #0B0C0E | yok (dolgu) | 19,57 | 17,58 | 19,57 | 16,34 | 0 / 1,5 / 1,5 | %0,4 / %94,5 |
| açık+YK | sayfa (sheet) `surface` | #0B0C0E | yok (dolgu) | 19,57 | 19,57 | 19,57 | 16,34 | 0 / 1,5 / 1,5 | %0,4 / %94,5 |
| açık+YK | Dikkat kutusu `surface2` | #0B0C0E | yok (dolgu) | 19,57 | 16,34 | 19,57 | 16,34 | 0 / 1,5 / 1,5 | %0,4 / %94,5 |
| koyu | sayfa | #1D1D1D | #F3F4F0 | 15,22 | 19,01 | 4,08 | 3,69 | 2 / 1,5 / 1 | %8,6 / %2,2 |
| koyu | sayfa (sheet) `surface` | #333639 | #F3F4F0 | 11,01 | 15,48 | 4,08 | 3,69 | 2 / 1,5 / 1 | %10,8 / %2,2 |
| koyu | Dikkat kutusu `surface2` | #3D4044 | #F3F4F0 | 9,38 | 13,42 | 4,08 | 3,69 | 2 / 1,5 / 1 | %12,1 / %2,2 |
| koyu + Düğme Şekilleri | sayfa | #1D1D1D | #F3F4F0 | 15,22 | 19,01 | 4,08 | 3,69 | 3 / 1,5 / 1,5 | %12,2 / %2,2 |
| koyu+YK | sayfa | #1F1F1F | #FFFFFF | 16,56 | 21,00 | 2,78 ❌ | 2,61 ❌ | 3 / 1,5 / 1,5 | %13,5 / %3,1 |
| koyu+YK | sayfa (sheet) `surface` | #35373B | #FFFFFF | 11,91 | 17,10 | 2,78 ❌ | 2,61 ❌ | 3 / 1,5 / 1,5 | %15,7 / %3,1 |
| koyu+YK | Dikkat kutusu `surface2` | #3E4246 | #FFFFFF | 10,14 | 14,83 | 2,78 ❌ | 2,61 ❌ | 3 / 1,5 / 1,5 | %17,0 / %3,1 |

- Gündüz ana düğmenin kenarı yok. Bu satırlarda "Kenar / komşu" dolgunun sayfaya oranı, "ikincilden" iki dolgunun oranı.
- İkincil düğmenin kenarı kendi dolgusunun üstünde. Bu yüzden ayrışma komşudan bağımsız.
- Gece kabul ölçütü (gece_oled.md, 1. adım): ana düğme yazısı zemininde en az 9:1. En kötü yer (Dikkat kutusu, orada ana düğme yok) 9,38.

## 3. A, B, C: siyah sayfada

| Seçenek | Görünüm | Dolgu | Kenar | Yazı / dolgu | Kenar / sayfa | Kenarlı ikincilden | Kenarsız ikincilden | Dolgu farkı (kenarlı) | Ort. L | Sarı odak |
|---|---|---|---|---|---|---|---|---|---|---|
| A: tonal sarı | koyu | #25240A | #7D7922, 1,5 pt | 11,39 | 4,61 | 1,01 ❌ | 1,12 ❌ | 1,09 | %2,7 | 2 |
| A: tonal sarı | koyu+YK | #25240A | #AEA830, 1,5 pt | 11,39 | 8,42 | 1,11 ❌ | 1,05 ❌ | 1,09 | %3,9 | 2 |
| B: tonal mürekkep | koyu | #1D1D1D | #7D7E7C, 1,5 pt | 15,22 | 5,15 | 1,10 ❌ | 1,00 ❌ | 1,02 | %2,5 | 1 |
| B: tonal mürekkep | koyu+YK | #1F1F1F | #848484, 1,5 pt | 16,56 | 5,58 | 1,35 ❌ | 1,44 ❌ | 1,03 | %2,7 | 1 |
| C: B + 2 pt tam kenar + kalın | koyu | #1D1D1D | #F3F4F0, 2 pt | 15,22 | 19,01 | 4,08 | 3,69 | 1,02 | %8,6 | 1 |
| C: B + 2 pt tam kenar + kalın | koyu+YK | #1F1F1F | #FFFFFF, 3 pt | 16,56 | 21,00 | 2,78 ❌ | 2,61 ❌ | 1,03 | %13,5 | 1 |

- `kontrast_tema` bölüm 4 ve `alt-gece` (0ca246d) ile aynı: C kenar–kenarlı ikincil 4,08 (onlarda 4,07), Ort. L %8,6. A'nın Ort. L'si burada %2,7 (alt-gece %2,4: kenarı dolgunun üstünde değil, siyahın üstünde saymış olabilir).
- **Işık:** C gece A'dan yaklaşık 3 kat fazla ışık veriyor (%8,6 / %2,7), ama eski dolu sarı düğmenin (%71) sekizde biri. YK'de %13,5.
- **A neden elendi:** ikincil düğmeden parlaklıkla hiç ayrılmıyor (1,01–1,12), yalnız sarı tonla. Koyu ekranda ikinci sarı odak (ogrenme_ilkeleri.md, "Sarı yalnız öğrenilecek kelimede").
- **B neden elendi:** ikincil düğmeyle neredeyse aynı (1,00–1,44).

## 4. Koyu + YK: ayrışma için denenenler

| Yol | Kenarlı ikincilden | Kenarsız ikincilden | Bedeli |
|---|---|---|---|
| C, 2 pt | 2,78 ❌ | 2,61 ❌ | — |
| **C, 3 pt (uygulanan)** | 2,78 ❌ + kenar 2 kat kalın + kalın yazı | 2,61 ❌ + kenar 2 kat kalın + kalın yazı | Ort. L %13,5 |
| Dolu açık mürekkep (yalnız YK) | 17,10 (dolgu) | 14,83 (dolgu) | Ort. L %100,0: gece ekranda parlak alan |

`lineStrong` koyu+YK saydamlığı (bugün %56) düşürülürse:

| Saydamlık | En zayıf kontrol kenarı (bg, surface, surface2; YK hedefi 4,5) | Ana kenardan ayrışma (≥3) |
|---|---|---|
| %48 | 4,23 ❌ | 3,24 |
| %50 | 4,49 ❌ | 3,06 |
| %50,2 | 4,51 | 3,05 |
| %50,5 | 4,55 | 3,02 |
| %50,7 | 4,58 | 3,00 |
| %51 | 4,62 | 2,98 ❌ |
| %52 | 4,76 | 2,90 ❌ |
| %54 | 5,04 | 2,75 ❌ |
| %56 | 5,33 | 2,61 ❌ |

İkisini birlikte tutan aralık (binde bir adımla): %50,2–%50,7.

- **3:1 için iki yol var, ikisi de iyi değil:**
  1. **YK'de ana düğmeyi dolu açık mürekkep yapmak** (ogrenme_ilkeleri.md'nin ilk önerisi): ayrışma 14,8–17,1. Ama gece ekranda düğme kadar parlak bir alan (Ort. L %100). Gece tasarımının amacına ters.
  2. **`lineStrong`'u YK'de soldurmak:** iki hedefi birlikte tutan aralık çok dar: %50,2–%50,7. Örneğin %50,5'te kontrol kenarları en az 4,55 (bugün 5,33), ayrışma 3,02. Pay yok denecek kadar az: 8 bit renk yuvarlaması tek başına sınırı geçirebilir. Bedeli de büyük: tek bir düğme için uygulamadaki **bütün** kontrollerin YK kenarı %15 zayıflar. YK'yi açan kişi daha güçlü kenar ister, daha zayıfını değil.
- **Seçilen:** C'nin kendisi, YK'de 3 pt kenarla. Kenar parlaklığı en yüksekte (beyaz). Fark kalınlıkla büyütüldü: ana 3 pt, ikincil 1,5 pt.
- **Koordinatör sayısal 3:1 isterse:** 1. yol birkaç satır: `CapsuleButtonBody` içinde `isNightPrimary && contrast == .increased` iken dolgu `Theme.ink`, yazı `Theme.bg`, kenar yok.

## 5. Basılı ve devre dışı (koyu, siyah sayfa)

Her katman ayrı ayrı saydamlaşır (yaklaşık). İkincil düğme basılı değil.

| Durum | Yazı / dolgu | Kenar / sayfa | Kenarlı ikincilden | Kenarsız ikincilden |
|---|---|---|---|---|
| basılı | 11,73 | 13,99 | 2,9997 ❌ | 2,71 ❌ |
| devre dışı (WCAG'de muaf) | 3,54 | 3,79 | 1,23 | 1,36 |

- **Basılı:** yazı ve kenar rahat geçiyor. İkincilden ayrışma parmak dokunduğu sürece 2,7–3,0'a iniyor. Geçici bir durum; kullanıcı zaten düğmeye dokunuyor. Kabul edildi.
- **Devre dışı:** WCAG'de muaf. Gece devre dışı ana düğme etkin bir ikincil düğmeden biraz soluk görünür (A'da da böyleydi). Yazı / dolgu 3,54 (A'da 3,0, `erisilebilirlik_2026-10-22.md` K3). K3'ün sorunu ("Konular hazırlanıyor…" durumu devre dışı düğmenin içinde) `OnboardingView`'da çözülmeli: durum yazısı düğmenin dışında olmalı.

## 6. Kontrastı Artır ve Düğme Şekilleri: kenar kalınlıkları

Kod okuması (`contrast == .increased || showsButtonShapes`). Ekranda piksel ölçümüyle doğrulandı: bölüm 8.

| Öğe | Dosya | Normal | YK ya da DŞ | Kalınlaşıyor mu |
|---|---|---|---|---|
| Ana düğme, gece | `LockglowTheme.swift` → `CapsuleButtonBody` | 2 pt `onPrimary` | **3 pt** | ✓ (yeni) |
| Ana düğme, gündüz | aynı | kenar yok (dolu) | kenar yok | — (dolgunun kendisi şekil) |
| Kenarlı ikincil (`SecondaryCapsuleButtonStyle()`) | aynı | 1,5 pt `lineStrong` | 1,5 pt | ✗: zaten kalın hâlde; YK'de rengi koyulaşıyor (%40 → %56, 4,66 → 7,55:1) |
| Kenarsız ikincil (`tonal: true`) | aynı | 1 pt | 1,5 pt | ✓ |
| Çip, seçilmemiş | `ChipBody` | 1 pt | 1,5 pt | ✓ |
| Çip, seçili | `ChipBody` | 1,5 pt `tint` | 1,5 pt | ✗ (seçim kenarı) |
| Segment kuyusu | `GlowStyle.swift` → `SegmentButtons` | 1 pt | 1,5 pt | ✓ |
| Seçili segment | aynı | 1,5 pt `tint` | 1,5 pt | ✗ (seçim kenarı) |
| Seçenek satırı | `GlowStyle.swift` → `ChoiceRow` | 1,5 pt / seçili 2 pt | aynı | ✗ (satır, kapsül değil) |
| Cevap düğmesi (Tekrar) | `ReviewView.swift` → `GradeButtonBody` | 1 pt | 1,5 pt | ✓ |
| Seviye rozeti | `LevelBadge` | 1,5 pt | 1,5 pt | ✗ (dokunulmaz) |
| `glassControl()` | sistem | sistem | sistem | sistemin işi |

- **Sonuç:** İnce (1 pt) kapsül kenarlarının hepsi ve gece ana düğmesi kalınlaşıyor. Hiyerarşi her modda korunuyor: gece ana düğme kenarı her zaman en kalın kenar (2 > 1,5 > 1; YK/DŞ'de 3 > 1,5).
- Kenarlı ikincil ve seçim kenarları zaten 1,5 pt. Kalınlaşmıyorlar; YK'de renkleri koyulaşıyor.

## 7. Koyu modda dolu sarı alan

`ios/` altında sarı çizen her yer (`band`, `bandDark`, `bandLight`, `markDark`, `markLight`, `bandGlow`) arandı.

| Yer | Gece ne çiziyor | Dolu sarı alan mı |
|---|---|---|
| Ana düğme (`CapsuleButtonBody`) | sarı yok | Hayır (bu dal) |
| Fosfor şeridi (`PhosphorBandDrawing`, `.underline`) | harflerin altında 1,5 pt'den kalın, kelime boyuna göre en çok ~8 pt eğik çizgi; %18 ışıma | Hayır: çizgi (marka işareti, kural 1) |
| Örnek cümle (`ExampleMark`) | sarı alt çizgi | Hayır |
| Widget'lar (`phosphorBand(.widget)`) | ince çizgi; vurgulu ve canlı modda sarı yok | Hayır |
| **Tekrar bitti işareti (`ReviewView.swift` → `DoneMark`)** | **104 × 12 pt dolu `bandDark` çubuk** + koşulsuz %18 ışıma | **Sınırda.** Başka oturumun dosyası; bölüm 9 |

## 8. Ekran görüntüleri

- **Kaynak:** [screenshots çalıştırması](https://github.com/yusufuyar68/lockglow/actions/runs/39803205312), Intel, iPhone SE (3. nesil), 98b2ba5'in teması. Atılacak `is4-tema-ekran` dalında; iş akışı küçük iPhone'u üç kez koyu modda çalıştırdı:
  - düz;
  - Düğme Şekilleri açık (`defaults write com.apple.Accessibility ButtonShapesEnabled`; sistem geri düğmesi ve sekme çubuğu da şekil aldı, yani ayar tuttu);
  - Kontrastı Artır açık (`simctl ui … increase_contrast enabled`).
- **Önce / sonra:** oturumların ortak not klasöründe, `is4-tema-ekran/`. Her görüntüde dört sütun: önce (A, `is3-tema` turu), C, C + Düğme Şekilleri, C + Kontrastı Artır. Depoya konmadı.
- **Piksel ölçümü** (`0b-acilis-konular`, 2x görüntü, kenarın tam ortasından dikey kesit; 1 pt = 2 piksel):

  | Tur | Çip kenarı (kalınlık, gri değeri) | Ana düğme kenarı | Ana düğme dolgusu |
  |---|---|---|---|
  | Koyu | 2 px (1 pt), 126 | 4 px (2 pt), 243 (#F3) | 29 (#1D) |
  | Koyu + Düğme Şekilleri | **3 px (1,5 pt)**, 126 | **6 px (3 pt)**, 243 | 29 |
  | Koyu + Kontrastı Artır | **3 px (1,5 pt)**, 160 (`lineStrong` %56) | **6 px (3 pt)**, 255 (#FF) | 31 (#1F) |

  - Kenarlar iki ayarda da kalınlaşıyor. Değerler hesapla aynı: dolgu #1D1D1D / #1F1F1F, çip kenarı beyaz %40 / %56 `surface2` üstünde.
  - Ekrandaki piksellerden ana kenar ile çip kenarı arası 3,65:1 (hesap: kenarsız ikincilden 3,69).
- **Görülen:**
  - "1 konuyla devam", "Başla (5 kelime)", ilk kelimedeki "Başla": sarı yok, beyaz kenarlı koyu kapsül. Aynı ekrandaki kenarlı ikincil düğmeden ("Anlamını göster") açıkça ayrılıyor: kenar daha parlak ve daha kalın.
  - Kelimenin sarı şeridi ekrandaki tek sarı.
  - **Yazı kalın değildi.** `.headline.bold()` hiçbir şey değiştirmedi: harflerin genişliği ve mürekkep miktarı gündüzdeki yarı kalın yazıyla aynı çıktı (123–251 px, 375 pt ölçeğinde). Neden: `.headline` zaten yarı kalın ve sistem onu "kalın" sayıyor; `.bold()` yeni bir şey eklemiyor. Düzeltme: `.headline.weight(.bold)` (sonraki commit). Bu düzeltme ekranda görülmedi (tur sınırı 1); `Theme.Fonts.meaning` aynı yolu (`.title.weight(.bold)`) kullanıyor ve orada kalın çıkıyor.
  - Söyle sayfası yine açılırken (karartılmış) çekilmiş; ana düğme görünmüyor. Tema sorunu değil.

## 9. Başka dosyalara notlar (bu dalda dokunulmadı)

- **`docs/tasarim/ogrenme_ilkeleri.md` 204. satır:** "Koyu temada ana düğme sarı değil açık mürekkep olur (`#F3F4F0`, yazı `#15181B`)" cümlesi C'ye göre değişmeli. Önerilen metin: "Koyu temada ana düğme sarı değil ve dolu değil: %12 mürekkep zemin, kalın mürekkep yazı, 2 pt tam mürekkep kenar (Kontrastı Artır ya da Düğme Şekilleri açıkken 3 pt)."
- **`ios/App/ReviewView.swift` → `DoneMark`:** gece 104 × 12 pt dolu sarı çubuk ve koşulsuz ışıma. Öneri:
  - çubuk şerit kadar ince olsun (~4–5 pt);
  - ışıma şerit gibi YK, Saydamlığı Azalt ve `isLuminanceReduced` açıkken çizilmesin.
- **`ios/README.md` kontrol listesi** (koordinatör): "Gece: ana düğme sarı değil, beyaz kenarlı; Kontrastı Artır ya da Düğme Şekilleri açıkken kenar kalınlaşıyor (3 pt), ince kapsül kenarları 1,5 pt oluyor; koyu modda dolu sarı alan yok."
