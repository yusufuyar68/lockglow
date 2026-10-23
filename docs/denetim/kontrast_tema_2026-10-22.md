# Tema kontrastı: K1 düzeltmesi, yazı tonları, gece 1. adım (22 Ekim 2026)

## Güncel: Apple'ın anlamsal renkleri (24 Ekim 2026, `is6-hig`)

**Ne değişti:** Tokenlar Apple'ın renk mantığına geçti (CLAUDE.md, "Tasarım kuralları: Apple dili"). Adlar ve API aynı. Şerit sarısı (`band`, `bandLight`, `bandDark`, `mark…`) değişmedi.
- Sayfa `bg` = systemGroupedBackground; kart `surface` = secondarySystemGroupedBackground; `surface2`, `surface3` = systemGray5, systemGray4.
- Yazı kademesi: `ink` = label, `ink2` = secondaryLabel, `ink3` = tertiaryLabel (opak gri; yazı taşıyabilsin diye 4,5:1'e koyulaştırıldı).
- `line` = separator. Tek vurgu rengi `tint` = mürekkep (gündüz siyah, gece beyaz).
- `good`, `bad`, `caution`: gündüz Apple'ın erişilebilir yeşil, kırmızı, turuncusunun, kendi paneli dahil her zeminde 4,5:1'i (payla 4,6:1) tutan en yakın koyusu; gece Apple'ın koyu mod renkleri.

**Yeni değerler** (YK = Yüksek Kontrast):

| Token | açık | koyu | açık+YK | koyu+YK |
|---|---|---|---|---|
| `ink`, `tint` | #000000 | #FFFFFF | #000000 | #FFFFFF |
| `ink2` | #3C3C43 | #C7C7CC | #2C2C30 | #E5E5EA |
| `ink3` | #636366 | #98989D | #3C3C43 | #C7C7CC |
| `primary` / `onPrimary` | #000000 / #FFFFFF | #FFFFFF %12 / #FFFFFF | aynı | aynı |
| `tintSoft` | #000000 %8 | #FFFFFF %10 | #000000 %12 | #FFFFFF %16 |
| `bg` | #F2F2F7 | #000000 | aynı | aynı |
| `surface` | #FFFFFF | #1C1C1E | aynı | aynı |
| `surface2` | #E5E5EA | #2C2C2E | aynı | aynı |
| `surface3` | #D1D1D6 | #3A3A3C | aynı | aynı |
| `line` | #3C3C43 %29 | #545458 %65 | #3C3C43 %45 | #545458 |
| `lineStrong` | #000000 %52 | #FFFFFF %42 | #000000 %64 | #FFFFFF %56 |
| `good` / `goodTint` | #1E7433 / #E4EEE7 | #30D158 / %16 | #165526 / #E4EEE7 | #58DA78 / %16 |
| `bad` / `badTint` | #CE0014 / #F9E0E3 | #FF6961 / %16 | #9A000F / #F9E0E3 | #FFA29D / %16 |
| `caution` / `cautionTint` | #BE3100 / #F6E2DB | #FF9F0A / #3C2E1B | #8D2400 / #F6E2DB | #FFAD2D / #3C2E1B |
| `shadowNear`, `shadowFar` | #000000 %5, %12 | (gece gölge yok) | | |

**Oranlar** (her satırda en düşük değer; eşik yazıda 4,5, kenarda 3, YK'de kenar 4,5):

| Çift | açık | koyu | açık+YK | koyu+YK |
|---|---|---|---|---|
| `ink` / bg, surface, surface2 | 16,73 | 13,94 | 16,73 | 13,94 |
| `ink2` / bg, surface, surface2 (hedef 7) | 8,71 | 8,28 | 11,08 | 11,10 |
| `ink3` / bg, surface, surface2 | 4,77 | 4,85 | 8,71 | 8,28 |
| `ink3` / surface3 (yasak çift) | 3,94 | 3,95 | 7,19 | 6,74 |
| `good` / zeminler ve `goodTint` | 4,65 | 6,21 | 7,08 | 7,00 |
| `bad` / zeminler ve `badTint` | 4,60 | 4,79 | 7,03 | 7,02 |
| `caution` / zeminler ve `cautionTint` | 4,61 | 6,39 | 7,01 | 7,05 |
| `ink2` / üç panel | 8,75 | 7,45 | 11,13 | 10,00 |
| `lineStrong` kenarı (en kötü dolgu × komşu) | 3,42 | 3,30 | 5,33 | 5,02 |
| Ana düğme yazısı / dolgu | 21,00 | 11,88 (kartta; sayfada 16,48) | 21,00 | 11,88 |
| Gece ana düğme kenarı / ikincil düğme kenarı | — | 3,69–4,23 | — | 2,55–2,78 |
| `bg` / `ink` (Geri alındı bildirimi) | 18,82 | 21,00 | 18,82 | 21,00 |
| `ink` / gündüz şeridi (`surface>band`) | 16,46 | — | 16,46 | — |
| `line` / surface (süs) | 1,70 | 1,66 | 2,39 | 2,26 |
| `surface2` / bg (dolgu tek başına; sınırı kenar verir) | 1,13 | 1,51 | 1,13 | 1,51 |

- Bütün yazı çiftleri dört görünümde eşiğin üstünde. `kontrast.py`'de ❌ kalan 7 satır eskisiyle aynı türden: dolgu ya da süs (`surface2`, `surface`, `surface3` zeminlerde; gece ana düğme dolgusu; artık çizilmeyen eski rozet noktası `bg>ink3@0.35`).
- `ink3` / `surface3` 3,9:1: kural aynı, `surface3` üstünde `ink3` yazı yok.
- **Widget vurgu renkleri** (`WidgetAccent.tones`, testi `WidgetConfigurationTests`): gündüz yeni mürekkeple (#000000) sarı 16,46, yeşil 15,98, pembe 14,07 (eşik 7); gece #1C1C1E üstünde 12,32 / 11,06 / 8,98, siyahta 15,20 / 13,65 / 11,08 (eşik 3). Hepsi geçiyor.
- **Nasıl hesaplandı:** `python -X utf8 docs/denetim/araclar/kontrast.py --tokenlar` (yazı çiftleri) ve aşağıdaki [Ek](#ek-kenar-hesabı)'teki yöntemle kenarlar; kenar hesabında dolgular `surface`, `surface2` ya da dolgusuz, komşular `bg`, `surface`, `surface2`. Karışımlar 8 bit'e yuvarlandı; bu yüzden bazı değerler betikten 0,01–0,03 farklı. En büyük fark gece `bad` / `badTint` panelinde: betik 4,77 (koyu) ve 6,99 (koyu+YK) veriyor, ikisi de 4,5 eşiğinin üstünde.
- **Not:** `kontrast.py --oneri` hâlâ eski mürekkebi (#15181B) kullanıyor; bu dalda dokunulmadı.

Aşağısı 22 Ekim'in kaydı; değerleri eski temaya aittir.

---

> **Sonradan değişti (`is4-tema`):** Gece ana düğmesi artık **C** (mürekkep %12 dolgu, kalın mürekkep yazı, 2 pt tam mürekkep kenar; YK ya da Düğme Şekilleri açıkken 3 pt). Aşağıda ana düğmeyi anlatan satırlar (bölüm 1, 2'nin son satırı, 4, 5) bu dalın uyguladığı **A**'yı (tonal sarı) anlatıyor. Güncel ölçüm: [`kontrast_gece_c_2026-10-22.md`](kontrast_gece_c_2026-10-22.md). Tekrar'daki cevap düğmelerinde artık dolu varsayılan düğme yok (`is3-tekrar`); 5. bölümdeki `isDefault` notu geçersiz.

**Ne:** Ortak tasarım sisteminin renk değerleri ve iç çizimi değişti. Adlar ve imzalar (API) aynı.
- Dal: `is3-tema`.
- Dosyalar: `ios/Shared/LockglowTheme.swift`, `ios/App/GlowStyle.swift`.
- Kaynaklar:
  - [`erisilebilirlik_2026-10-22.md`](erisilebilirlik_2026-10-22.md): K1, K2, V5, V6;
  - [`../tasarim/ogrenme_ilkeleri.md`](../tasarim/ogrenme_ilkeleri.md): ink2 ve surface3 kuralı;
  - [`../tasarim/alternatifler/gece_oled.md`](../tasarim/alternatifler/gece_oled.md): uygulama planı, 1. adım.

**Nasıl hesaplandı:**
- Raporun betiği iki kez çalıştırıldı: eski tema (`origin/main` 29797b4) ve yeni tema.
  ```
  python -X utf8 docs/denetim/araclar/kontrast.py --tokenlar
  python -X utf8 docs/denetim/araclar/kontrast.py --tema <eski LockglowTheme.swift> --tokenlar
  ```
- Betik kenarı "zeminin üstünde" ölçer. Gerçekte kenar düğmenin kendi dolgusunun üstüne çizilir (`strokeBorder`). Dışındaki komşu sayfa, kart ya da Dikkat kutusudur. Bu yüzden kenarlar ayrıca hesaplandı. Betik en altta, [Ek](#ek-kenar-hesabı).
- Formül WCAG 2.2: saydam renkler alttaki zeminle sRGB'de karıştırılır. Eşikler: yazı 4,5:1, yazı dışı öğe 3:1 (1.4.11).
- **Kısaltmalar:** YK = Yüksek Kontrast (Kontrastı Artır). ❌ = eşiğin altında.

---

## 1. Değişen tokenlar

| Token | Görünüm | Eski | Yeni | Neden |
|---|---|---|---|---|
| `ink2` | açık | #4E555B | **#474E54** | Küçük yazıda 7:1 hedefi (ogrenme_ilkeleri) |
| `ink3` | açık+YK | #4E555B | **#474E54** | YK'de ink3 = ink2 kuralı (eski ink2'ye eşitti) |
| `lineStrong` | açık / koyu | #15181B %22 / #FFFFFF %18 | **%54 / %40** | K1: her kenar en az 3:1 |
| `lineStrong` | açık+YK / koyu+YK | %45 / %40 | **%70 / %56** | K1: YK'de 4,5:1'in üstü |
| `bg` | koyu | #0D0F11 | **#000000** | Gece 1. adım: OLED siyahı |
| `line` | koyu | #FFFFFF %9 | **%12** | Kart dolgusu gidince tek kenarı bu |
| `primary` | koyu | #E9E040 (dolu sarı) | **#E9E040 %16** | Gece 1. adım: dolu sarı alan yok |
| `onPrimary` | koyu | #15181B | **#E9E040** | Tonal düğmede sarı yazı |
| `bandGlow` | hepsi | #E9E040 %38 | **%18** | Işıma en çok %15–20 (ogrenme_ilkeleri) |
| `primaryGlow` | hepsi | #E9E040 %35 | **%0** (saydam) | Gece 1. adım: düğme ışıması yok |

**İç çizimde değişenler:**
- **Kenarsız kapsül** (`SecondaryCapsuleButtonStyle(tonal: true)`), **seçilmemiş çip** (`ChipButtonStyle`) ve **segment kuyusu** (`SegmentButtons`):
  - 1 pt `lineStrong` kenar aldı;
  - YK ya da Düğme Şekilleri açıkken kenar 1,5 pt.
- **Ana düğme** (`PrimaryCapsuleButtonStyle`, `GlowButtonStyle`):
  - koyu modda 1,5 pt sarı kenar: bant %45, YK'de %70;
  - gölge ışıması kalktı.
- **Kart** (`cardSurface`): koyu modda dolgu sayfa siyahı (`bg`), yalnız `line` kenarı görünür. Dolgu opak kaldı, bu yüzden dokunma alanı ve üst üste binen içerik gündüzle aynı davranır.
- **Fosfor şeridi:**
  - gece çizgisi aynı (renk, kalınlık, eğim);
  - altındaki ışıma %18;
  - YK, Saydamlığı Azalt ve kısık Her zaman açık ekranda (`isLuminanceReduced`) ışıma hiç çizilmez.
- **Seviye rozeti:** boş nokta soluk dolgu (`ink3` %35) yerine 1 pt `ink3` halka (K2).

---

## 2. Kenarlar (K1): eski ve yeni

Kenar pikseli = düğmenin dolgusu + üstündeki kenar rengi. Komşu = düğmenin dışındaki renk.

| Kenar | Komşu | Eski açık | Eski koyu | Eski açık+YK | Eski koyu+YK | **Yeni açık** | **Yeni koyu** | **Yeni açık+YK** | **Yeni koyu+YK** |
|---|---|---|---|---|---|---|---|---|---|
| Kenarlı kapsül | sayfa `bg` | 1,44 ❌ | 1,99 ❌ | 2,63 ❌ | 4,26 | **3,45** | **4,66** | **5,91** | **7,55** |
| Kenarlı kapsül | kart `surface` | 1,60 ❌ | 1,77 ❌ | 2,93 ❌ | 3,80 | **3,84** | **3,80** | **6,58** | **6,15** |
| Kenarlı kapsül | Dikkat kutusu `surface2` | 1,34 ❌ | 1,54 ❌ | 2,44 ❌ | 3,29 | **3,21** | **3,29** | **5,50** | **5,33** |
| Kenarsız kapsül, çip | sayfa `bg` | 1,08 ❌ (kenar yok) | 1,30 ❌ | 1,08 ❌ | 1,30 ❌ | **3,93** | **5,15** | **6,51** | **8,05** |
| Kenarsız kapsül, çip | kart `surface` | 1,20 ❌ (kenar yok) | 1,15 ❌ | 1,20 ❌ | 1,15 ❌ | **4,38** | **4,19** | **7,24** | **6,55** |
| Kenarsız kapsül, çip | Dikkat kutusu `surface2` | 1,00 ❌ (kenar yok) | 1,00 ❌ | 1,00 ❌ | 1,00 ❌ | **3,66** | **3,64** | **6,05** | **5,68** |
| Segment kuyusu | sayfa `bg` | 1,08 ❌ (kenar yok) | 1,30 ❌ | 1,08 ❌ | 1,30 ❌ | **3,93** | **5,15** | **6,51** | **8,05** |
| Seçenek satırı (`ChoiceRow`, quiz şıkkı) | sayfa `bg` | 1,44 ❌ | 1,99 ❌ | 2,63 ❌ | 4,26 | **3,45** | **4,66** | **5,91** | **7,55** |
| Rozet kenarı (dolgusuz) | sayfa `bg` | 1,59 ❌ | 1,69 ❌ | 2,87 ❌ | 3,81 | **3,73** | **3,66** | **6,26** | **6,48** |
| Rozet kenarı (dolgusuz) | kart `surface` | 1,60 ❌ | 1,77 ❌ | 2,93 ❌ | 3,80 | **3,84** | **3,80** | **6,58** | **6,15** |
| Seviye rozeti boş nokta | sayfa `bg` | 1,59 ❌ | 1,78 ❌ | 1,72 ❌ | 2,22 ❌ | **4,94** | **6,92** | **7,59** | **11,07** |
| Ana düğme, gece | sayfa `bg` | — | 13,90 (dolu sarı) | — | 13,90 | — | **4,61** (sarı kenar) | — | **8,42** |

- **Sonuç:** Uygulamanın kendi stilleriyle çizilen her dokunulur kapsül, dört görünümde de en az **3,21:1**. Yüksek Kontrast'ta en az **5,33:1**.
- **En az saydamlık:** 3:1 için `lineStrong` açıkta en az %52, koyuda en az %38 olmalı (dolgu ve komşunun bütün gerçek eşleşmeleri). Seçilen %54 ve %40 küçük bir pay bırakıyor.
- **Gri dolgu tek başına:** `surface2` sayfada 1,08–1,42:1, kartta 1,15–1,20:1. Kenarsız kapsülün sınırını dolgu değil kenar veriyor. 3:1 veren bir gri dolgu açıkta #8C8C8C civarında olur; mürekkep yazıyı ve "sakin ekran" ilkesini bozar. Gölge karanlıkta görünmez. Bu yüzden kenar seçildi.

## 3. Yazı tonları

| Yazı | Zemin | Eski açık | **Yeni açık** | Koyu | açık+YK (eski → yeni) | koyu+YK |
|---|---|---|---|---|---|---|
| `ink2` | `bg` | 6,80 | **7,59** | 10,12 → 11,07 | 9,42 | 13,37 → 14,63 |
| `ink2` | `surface` | 7,57 | **8,45** | 9,01 | 10,49 | 11,91 |
| `ink2` | `surface2` | 6,32 | **7,05** | 7,82 | 8,76 | 10,33 |
| `ink2` | `surface3` | 5,60 | **6,25** | 6,52 | 7,76 | 8,61 |
| `ink3` | `bg` | 4,94 | 4,94 | 6,33 → 6,92 | 6,80 → **7,59** | 10,12 → 11,07 |
| `ink3` | `surface2` | 4,59 | 4,59 | 4,89 | 6,32 → **7,05** | 7,82 |
| `ink3` | `surface3` | **4,06 ❌** | **4,06 ❌** | **4,08 ❌** | 5,60 → 6,25 | 6,52 |

- `ink2` artık açıkta da her zeminde 7:1'in üstünde; `surface3`'te 6,25:1.
- **Kural:** `surface3` üstünde `ink3` yazı yok (iki görünümde de 4,1:1). Kural `LockglowTheme.swift`'in başındaki API rehberine ("Contrast rules") ve `ink3`, `surface3` tokenlarının açıklamasına yazıldı.
- Kodda bugün `surface3` üstünde `ink3` yazı yok. Aranan yerler: tema dışında `surface3` kullanan 6 satır (izler, adım çubuğu, seviye noktaları, Bildiklerim kaydırma rengi).
- Bütün yazı çiftleri (raporun 50 çiftinden yazı olanlar) dört görünümde eşiğin üstünde kaldı.

## 4. Gece: daha az ışık (gece_oled.md 1. adım)

> Ana düğme satırları A içindir. C'nin değerleri (yazı / dolgu 15,22, kenar / sayfa 19,01, ikincil kenardan 4,08): [`kontrast_gece_c_2026-10-22.md`](kontrast_gece_c_2026-10-22.md).

| Öğe | Eski | Yeni |
|---|---|---|
| Sayfa | #0D0F11 (parlaklık L %0,47) | **#000000** (L %0, piksel kapalı) |
| Kart dolgusu | `surface` #191C20 (L %1,14) | **sayfa siyahı** (L %0); kenar `line` %12, siyahta 1,27:1 |
| Ana düğme dolgusu | dolu sarı #E9E040 (**L %71**) | sarı %16 (**L %1,7**) |
| Ana düğme yazısı / dolgu | #15181B / sarı: 12,90:1 | sarı / tonal: **11,39:1** (sayfa), 8,25:1 (`surface` sayfa) |
| Ana düğme sınırı / sayfa | 13,90:1 (dolgu) | dolgu 1,33:1; **sarı kenar 4,61:1** (YK 8,42:1) |
| Ana düğme ışıması | %35 sarı gölge, 10 pt | yok |
| Şerit ışıması | %38 (L %8,7) | %18 (L %2,1); YK, Saydamlığı Azalt, Her zaman açık: yok |
| Şerit çizgisi / sayfa | 13,90:1 | 15,20:1 (renk ve biçim aynı) |
| Ana yazı `ink` / sayfa | 17,38:1 | 19,01:1 |

- **Kabul ölçütleri** (gece_oled.md):
  - koyu modda dolu sarı alan yok: tema stilleriyle çizilen her şeyde sağlandı;
  - ana düğme yazısı zemininde en az 9:1: 11,39:1, sağlandı.
- **Neden ışıma tamamen kalkmadı:** Görev "fosfor şeridinin gece görünümü korunsun" diyor. Ana kaynak (ogrenme_ilkeleri, "Sarı yalnız öğrenilecek kelimede") ışımaya en çok %15–20 izin veriyor. Tamamen kaldırmak tek satır: `bandGlow` → `fixed(0xE9E040, 0)`.
- **İki kaynak arasındaki fark (karar koordinatörün):**
  - ogrenme_ilkeleri koyu ana düğmeyi açık mürekkep (#F3F4F0) istiyor ve koyu ekranda iki sarı odağı yasaklıyor;
  - main'deki gece_oled.md 1. adım tonal sarı (A) istiyor. Bu dal A'yı uyguladı.
  - Açık mürekkep dolgu (L %90) eski sarıdan da parlak olurdu; gece hedefine ters.
  - `alt-gece` dalı (d255a64, main'de değil) öneriyi **tonal mürekkebe (B)** çevirdi: dolgu `ink` %12, yazı `ink`, kenar `ink` %45. B sarıyı yalnız kelimede bırakır. Ölçüm (siyah sayfada):

    | | Dolgu | Kenar | Yazı / dolgu | Kenar / sayfa |
    |---|---|---|---|---|
    | A: tonal sarı (bu dal) | #25240A | #7D7922 | 11,39 | 4,61 |
    | B: tonal mürekkep | #1D1D1D | #7D7E7C | 15,22 | 5,15 |
    | Kenarlı ikincil düğme (karşılaştırma) | #191C20 | #757779 | 15,48 | 4,66 |

  - **B'nin bedeli:** gece ana düğme kenarlı ikincil düğmeyle neredeyse aynı görünür. Dolgu farkı 1,02:1, kenar farkı 1,10:1. "Ekranın tek dolu düğmesi" gece ayırt edilemez. B seçilirse ana düğmeye bir ayırt edici daha gerekir (ör. kalın yazı ve daha açık dolgu).
  - **C** (`alt-gece` 0ca246d, onların hesabı): B + 2 pt **tam** `ink` kenar + kalın yazı. Kenar siyahta 19:1, ikincil düğmenin kenarından 4,07:1 ayrılır. Düğmenin ortalama ışığı L %8,6 (A %2,4). Tek sarı odak korunur. B'ye ek olarak kenar opaklığı 1, kalınlık 2 pt ve `.fontWeight(.bold)`.
  - **B'ye geçmek** iki satır: `primary` koyu `Tone(0xF3F4F0, 0.12)`, `onPrimary` koyu `Tone(0xF3F4F0)`; `CapsuleButtonBody` içinde kenar `Theme.band` yerine `Theme.ink`. Seçilen hâle göre ogrenme_ilkeleri.md 204. satır güncellenmeli.

## 5. Eşiğin altında kalanlar ve diğer dosyalara notlar

Raporun betiğinde hâlâ ❌ görünen satırlar ve nedeni:

| Satır | Değer | Durum |
|---|---|---|
| `surface2` / `bg`, `surface2` / `surface` | 1,08–1,42 | Dolgunun kendisi. Tema stillerinde sınırı artık kenar veriyor (bölüm 2). Elle çizilen gri kapsüllerde hâlâ sorun (aşağıda). |
| `surface` / `bg` | 1,11–1,23 | Kart dolgusu; süs. Kart dokunulur bir öğe değil, kenarı `line`. |
| `surface3` / `surface`, `surface3` / `bg` | 1,22–1,70 | İlerleme izleri ve adım çubuğu (K2). Bu dosyaların dışında: `OnboardingView`, `PronunciationPracticeView`, `ReviewView` (ReviewView YK'de kenar ekliyor). |
| `bg>ink3@0.35` / `bg` | 1,59–2,08 | Betikteki eski çizim. Rozet artık halka çiziyor: 4,94–11,07 (bölüm 2). |
| `primary` / `bg` (koyu) | 1,33 | Tonal düğmenin dolgusu. Tema stilinde sınırı sarı kenar veriyor (4,61). Elle çizilen varsayılan cevap düğmesinde kenar yok (aşağıda). |

**Başka oturumların dosyaları** (bu dalda dokunulmadı):
- **`ios/App/ReviewView.swift` → `GradeButtonBody`:**
  - Cevap düğmeleri `surface2` dolgulu. Kenar yalnız YK ya da Düğme Şekilleri açıkken çiziliyor. Tema kapsülleriyle aynı olsun diye kenar her zaman 1 pt `lineStrong` olmalı; YK'de 1,5 pt.
  - Varsayılan cevap düğmesi (`isDefault`) gece artık tonal sarı. Sınırı için koyu modda 1,5 pt `Theme.band.opacity(0.45)` kenar eklenmeli, `PrimaryCapsuleButtonStyle` gibi. `primaryGlow` gölgesi artık saydam; satır kalabilir ya da silinebilir.
- **`ios/App/ReviewView.swift` → `MoreBelowCue`:** Yazı `Theme.surface`'a doğru soluyor. Gece kart artık siyah, bu yüzden "Devamı" bölgesinde gri (#191C20) bir şerit görünür. Düzeltme:
  - gradyan rengi `colorScheme == .dark ? Theme.bg : Theme.surface` olmalı;
  - ya da daha iyisi, kaydırılan metne `mask` uygulanmalı (her kart rengiyle çalışır).
- **`ios/App/ReviewView.swift` → `DoneMark`:** `Theme.bandGlow` kullanıyor; kendiliğinden %18'e indi. YK ve Saydamlığı Azalt'ta da çiziliyor; isterse aynı koşulu ekleyebilir.
- **Elle çizilen başka gri kapsüller:** `surface2` dolgu + kenarsız çizen her yer 1 pt `lineStrong` kenar almalı (API rehberindeki "Contrast rules").

## 6. `englishVoice()` (V5, V6)

**Kod okuması:**
- `englishVoice()`, `cardEnglishVoice()` (CardDetailViews) ve `widgetEnglishVoice()` (HomeWordViews) aynı: `.environment(\.locale, Locale(identifier: "en_US"))`.
- Kodda 34 kullanım var (tema dışında). Hepsi şunlardan birinin üstünde:
  - `Text(verbatim:)`;
  - String değişkenli `Text`;
  - `AttributedString`;
  - bunları çizen bir widget görünümü.
- Sabit dizgili `Text("…")` + İngilizce ses yok.

**Simülatörde ölçüm:**
- Atılacak `is3-tema-ekran` dalında bir test (`EnglishVoiceProbeTests`) yazıldı. Test SwiftUI görünümlerini bir pencerede çizer.
- Erişilebilirlik süreç içinde açıldı (`_AXSSetAutomationEnabled`, KIF yöntemi). Sonra her öğenin VoiceOver'a giden dili okundu:
  - `accessibilityLanguage`;
  - etiketin `UIAccessibilitySpeechAttributeLanguage` özniteliği.
- iOS 26.2 simülatörü, Xcode 26. [Çalıştırma](https://github.com/yusufuyar68/lockglow/actions/runs/39791851304).
- İlk denemede erişilebilirlik kapalıydı, öğe bulunamadı. Bu yüzden ikinci tur yalnız bu test için çalıştı.

| Durum | VoiceOver'a giden dil | Sonuç |
|---|---|---|
| `Text(verbatim: "breakfast").englishVoice()` | en-Latn-US (öğe + etiket) | ✓ |
| `Text(lemma).englishVoice()` (String) | en-Latn-US | ✓ |
| `Text("breakfast").englishVoice()` (yerelleştirme anahtarı) | en-Latn-US | ✓ (iOS 26.2'de; eski sürümlerde çalışmadığı bildirilmiş) |
| `Text(AttributedString).englishVoice()` (örnek cümle) | en-Latn-US | ✓ |
| `.accessibilityElement(children: .ignore)` + `accessibilityLabel(Text(verbatim:))` + başlık + `.englishVoice()` (kart başlığı) | en-Latn-US | ✓ |
| Düğme + `.englishVoice()` | en-Latn-US, "button" niteliğiyle | ✓, ama "düğme" İngilizce okunur |
| Düğme (yalnız içindeki `Text`'te `.englishVoice()`) + Türkçe `accessibilityHint` | etiket **ve ipucu** en-Latn-US | ⚠️ Türkçe ipucu İngilizce sesle okunur |
| `HStack { Text("Doğrusu:"); Text("borrow").englishVoice() }` + `.combine` | dil yok; İngilizce parçada da öznitelik yok | ❌ "borrow" cihazın (Türkçe) sesiyle okunur |
| Değiştiricisiz `Text(verbatim:)` | yok (cihaz dili) | denetim |
| `Text(verbatim:)` + `tr_TR` | tr-Latn-TR | denetim |

**Sonuç:**
- **Yöntem doğru kurulmuş.** Tek başına duran İngilizce öğede VoiceOver'a İngilizce dil gidiyor. UIKit'teki `accessibilitySpeechLanguage` ile aynı öznitelik bu. README madde 14'ün istediği de bu.
- **İki açık:**
  1. **`.combine` dili siliyor.** Birleşen öğelerdeki İngilizce kelime Türkçe sesle okunur. Denetimdeki şu yerler bu yüzden gerçekten bozuk:
     - V5: Söyle "Duyulan:" paneli, Tekrar özeti satırı;
     - V3: quiz geri bildirimi.
     - Sözlük'teki `NavigationLink` satırı da büyük olasılıkla aynı (ölçülmedi).
     - Çözüm: İngilizce parçayı ayrı öğe bırakmak.
  2. **İngilizce etiketli düğme bütün öğeyi İngilizce yapar.** Türkçe ipucu ve "düğme" sözcüğü de İngilizce sesle okunur. Bu tür düğmelere Türkçe ipucu verilmemeli.
- **Kalan:** Bu, VoiceOver'ın okuduğu veriyi gösteriyor, sesi değil. Cihazda bir kez dinlemek yine iyi olur (denetim V6, 1. madde). iOS 17'de ayrıca bakılmadı.
- Bu bilgiler `englishVoice()`'un açıklamasına yazıldı.

## 7. Ekran görüntüleri

- **Kaynak:** [screenshots çalıştırması](https://github.com/yusufuyar68/lockglow/actions/runs/39776808101), Intel. Atılacak `is3-tema-ekran` dalında, bu dalın teması + iş akışına eklenen koyu tur:
  - iPhone SE açık;
  - iPhone SE koyu;
  - Pro Max açık.
- **Yan yana açık/koyu çiftler:** oturumların ortak not klasöründe, `is3-tema-ekran/`. Depoya konmadı.
- **Açık:**
  - Kenarlı ve kenarsız kapsüller, çipler ve segmentler artık zeminden ayrılıyor;
  - kenarlar ince ve sakin;
  - seviye rozetinin boş noktası halka;
  - ink2 farkı gözle zor seçiliyor (bilerek küçük).
- **Koyu:**
  - sayfa siyah, kartlar yalnız çizgiyle;
  - "Başla" ve "1 konuyla devam" tonal sarı, kenarlı;
  - şerit çizgisi aynı, ışıması belli belirsiz;
  - widget'larda (koyu, StandBy) şerit gece görünümünü koruyor.
- **Görülen sorunlar (başka dosyalarda, bölüm 5):**
  - Tekrar kartının arka yüzünde "Devamı" bölgesi gri soluyor (`MoreBelowCue`);
  - Tekrar'daki "Bildim" gece kenarsız;
  - cevap düğmeleri varsayılan görünümde kenarsız.
- **Söyle sayfası:** görüntü, sayfa açılırken çekilmiş (karartılmış). İki modda da aynı; tema sorunu değil.
- **Konular sayfası, koyu:** "Seçili: 67" sayısı geçiş animasyonunun ortasında yakalanmış. Tema sorunu değil.

---

## Ek: kenar hesabı

`kontrast.py`'nin işlevleriyle (depo kökünden, Python 3.12):

```python
import importlib.util, sys
spec = importlib.util.spec_from_file_location("kontrast", "docs/denetim/araclar/kontrast.py")
k = importlib.util.module_from_spec(spec); sys.modules["kontrast"] = k; spec.loader.exec_module(k)
tokens = k.read_tokens(k.THEME)

def edge(stack, outside, mode):
    """stack: kenar pikseli (alttan üste), outside: düğmenin dışındaki komşu."""
    out = k.resolve(outside, mode, tokens)
    return k.ratio(k.resolve(stack, mode, tokens), out)

for mode in k.MODES:
    print(mode,
          round(edge("surface>lineStrong", "bg", mode), 2),        # kenarlı kapsül, sayfada
          round(edge("surface2>lineStrong", "surface2", mode), 2),  # çip, Dikkat kutusunda
          round(edge("bg>primary>band@0.45", "bg", mode), 2))       # gece ana düğme kenarı (yalnız koyu)
```
