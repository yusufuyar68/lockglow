# Lockglow arayüz önerisi (birleşik tasarım, 21 Ekim 2026)

[`lockglow_ui_mockup.html`](lockglow_ui_mockup.html) tarayıcıda açılan, tıklanabilir bir tasarım önerisi. Swift kodu değişmedi. Karşılaştırma 21 Ekim main'ine göre yapıldı; o tarihte açılış akışı, Söyle ve widget hoparlörü main'de.

## Nasıl gezilir

- **Üst çubuk:**
  - görünümler: *Açılış*, *Uygulama*, *Widget'lar*, *Marka ve sistem*;
  - tema: *Açık / Koyu*;
  - sürüm: *iOS 26 (cam) / iOS 17–25*. Sekme çubuğu ve üst düğmeler cam ya da materyal görünür.
- **Sağ panel:**
  - cihaz (390 × 844 ya da iPhone SE 375 × 667);
  - yazı boyutu (Dinamik Tür, 5 kademe);
  - 44 pt alanlarını gösterme ve otomatik denetim;
  - her ekranın durumları (ör. "Quiz · yanlış cevap", "Widget güncellemiyor", "Bildirim izni yok");
  - o ekranın tasarım notu ve Swift notu.
  - Widget görünümünde ayrıca: tam renk, renklendirilmiş, cam ve kilitli ekranda "Her zaman açık".
- **Doğrudan bağlantılar:** `#acilis`, `#akis`, `#tekrar`, `#sozluk`, `#ayarlar`, `#widgetlar`, `#marka`.
- **Yerelde ekran görüntüsü için adres parametreleri:** örneğin `?bare=1&state=quiz-wrong&theme=dark&device=se&dt=3`.
- **İçerik:** kartlar `content/drafts/kisisel_v1` içinden olduğu gibi alındı. Seviye ve konu sayıları 21 Ekim main taslaklarından (933 kart). "124 bildiğim kelime" gibi sayılar örnektir.
- **Bağımlılık:** dış kod yok. Mac dışında New York ve SF Pro'ya benzesin diye yalnız Google Fonts'tan Source Serif 4 ve Inter yüklenir.

## Bu tasarım nasıl seçildi?

Üç tasarımcı aynı brief'le, birbirinden habersiz çalıştı:
- **A:** okunabilirlik önce;
- **B:** marka ve kimlik önce;
- **C:** iOS 26 yerel görünüm önce.

20 Ekim'deki ilk taslakla (v1) birlikte dört aday, isimsiz olarak üç hakeme gitti. Puanlar 10 üzerinden, ağırlıklı: okunabilirlik %25, erişilebilirlik %20, marka %20, iOS uyumu %20, widget %15.

| Aday | J1 · A2 ve erişilebilirlik | J2 · marka | J3 · iOS ve widget | Ortalama |
|---|---|---|---|---|
| **A · Okunabilirlik önce** | 8,25 | 8,51 | 8,53 | **8,43** |
| C · iOS 26 yerel | 8,09 | 7,82 | 8,40 | 8,10 |
| B · Marka önce | 8,10 | 8,12 | 7,98 | 8,07 |
| İlk taslak (v1) | 5,66 | 5,37 | 5,75 | 5,59 |

İki hakem A'yı temel önerdi. Birleşik tasarım her adaydan şunları aldı:
- **A'dan:**
  - okuma düzeni;
  - "İngilizce serif, Türkçe SF";
  - italik ve soluk gri çevirinin kalkması;
  - "kart sondan kısalır";
  - etiketli "Dinle" düğmesi;
  - "Senin seçtiğin: lend = ödünç vermek";
  - kelime kelime tur özeti.
- **B'den:**
  - **fosfor şeridi**, tek marka işareti olarak;
  - Dikkat'te farkın gösterilmesi;
  - "Neden?" kutusu;
  - "Zor da bilinmiş sayılır" ve "Kilitli ekranın yeni kelimeleri…" metinleri.
- **C'den:**
  - cam yalnız kontrollerde;
  - tur sırasında sekme çubuğu gizli;
  - widget düğme sırası;
  - satır içi widget'ın kısalma basamakları.
- **v1'den:**
  - seviye noktaları;
  - "Dene" örnekleri;
  - Ayarlar'ın soru biçimli başlıkları;
  - anahtar deliği ikonu.

**Son eleştirmen turu** "henüz değil" dedi; bulduklarının hepsi bu sürümde düzeltildi:
- quiz geri bildirimi ekranın altında kalıyordu;
- koyu temada şerit kuyruklu harflere biniyordu;
- koyu temada fazla sarı vardı;
- Dikkat farkı ve "Neden?" mantığı bazı kartlarda yanlıştı;
- kart, yer varken örneği atıyordu;
- açılış metinleri main'den farklıydı.

## Kimlik: fosfor şeridi

Lockglow "kilit ekranında parlayan kelime" demek. Türkçede "fosforlu kalem" zaten ışıyan kalemdir. Sarı yalnız **öğrenilecek İngilizce kelimede** durur; geri kalan her şey Apple'ın sistem renkleri: gri sayfa, beyaz kart, siyah yazı (gece siyah sayfa, beyaz yazı).

- **Gündüz:** şerit kelimenin alt yarısının arkasındadır (fosforlu kalem çizgisi). Ana düğme mürekkeptir.
- **Gece:** şerit harflerin arkasından çıkar ve kuyruklu harflerin (y, p, g) de altından geçen, eğik uçlu, hafif ışıyan kalın bir çizgi olur. Hiçbir harf sarının üstüne binmez. Ana düğme sarı değildir: soluk beyaz dolgu, 2 pt beyaz kenar, kalın yazı (gece_oled.md, C).
- **Seçili öğeler:** sekme, adım çubuğu, ilerleme, seçili seçenek gece de mürekkep (açık renk) kalır, sarı olmaz.

| Ad | Token | Açık | Koyu | Kullanım | Kontrast (açık / koyu) |
|---|---|---|---|---|---|
| Fosfor şeridi | `band` | `#F5E829` | `#E9E040` (alt çizgi) | Yalnız İngilizce kelime ve örnekteki aynı kelime | mürekkep 16,5:1 |
| Mürekkep (label) | `ink` | `#000000` | `#FFFFFF` | Ana yazı | 16,7 / 13,9 |
| İkincil / üçüncül yazı (secondaryLabel / tertiaryLabel) | `ink2` / `ink3` | `#3C3C43` / `#636366` | `#C7C7CC` / `#98989D` | Çeviri, IPA, açıklama / yardımcı | 8,7 / 8,3 ; 4,8 / 4,9 |
| Ana düğme | `primary` / `onPrimary` | `#000000` / `#FFFFFF` | beyaz %12 + 2 pt beyaz kenar / `#FFFFFF` | Ekranın tek ana düğmesi | 21 / 11,9 |
| Seçili, ilerleme (tek vurgu rengi) | `tint` / `tintSoft` | `#000000` / siyah %8 | `#FFFFFF` / beyaz %10 | Seçili sekme ve seçenek, adım çubuğu, ilerleme | — |
| Zemin | `bg`, `surface`, `surface2`, `surface3` | `#F2F2F7` (systemGroupedBackground), `#FFFFFF`, `#E5E5EA` (systemGray5), `#D1D1D6` (systemGray4) | `#000000`, `#1C1C1E`, `#2C2C2E`, `#3A3A3C` | Sayfa, kart ve gruplu liste, kapsül, iz | — |
| Çizgi | `line` / `lineStrong` | separator (`#3C3C43` %29) / siyah %52 | separator (`#545458` %65) / beyaz %42 | Ayırıcı, kenar | kenar 3,4 / 3,3 |
| Doğru | `good` / `goodTint` | `#1E7433` / `#E4EEE7` | `#30D158` / %16 | Doğru şık, "Çalışıyor" | 4,6 / 6,2 |
| Yanlış | `bad` / `badTint` | `#CE0014` / `#F9E0E3` | `#FF6961` / %16 | Yanlış şık, sıfırla | 4,6 / 4,8 |
| Uyarı | `caution` / `cautionTint` | `#BE3100` / `#F6E2DB` | `#FF9F0A` / `#3C2E1B` | Yalnız Dikkat üçgeni, "Neredeyse!" | 4,6 / 6,4 |

- **2026-10-24:** renkler Apple'ın anlamsal renklerine geçti (sistem gruplu zemin, label kademesi, separator, tek vurgu rengi). Eski değerler (`#F3F3EE` kâğıt, `#15181B` mürekkep…) ve hesap: [`../denetim/kontrast_tema_2026-10-22.md`](../denetim/kontrast_tema_2026-10-22.md) (en üstteki bölüm).
- **Kontrast sütunu:** yazının `bg`, `surface` ve `surface2` üstündeki en düşük oranı (Doğru, Yanlış, Uyarı için kendi panelleri de dahil); çizgide kenarın en kötü dolgu ve komşu eşleşmesi. Yüksek Kontrast değerleri `LockglowTheme.swift`'te.
- Doğru, Yanlış ve Uyarı gündüz Apple'ın erişilebilir yeşil, kırmızı ve turuncusunun 4,5:1'i tutan en yakın koyusudur.

**Yazı** (ikisi de iOS'ta hazır, lisans gerekmez):

| Rol | Boyut | SwiftUI |
|---|---|---|
| Kelime (İngilizce) | 34 pt bold, serif (Large Title) | `englishWordStyle()`: `.system(size: 34, weight: .bold, design: .serif)` + `@ScaledMetric(relativeTo: .largeTitle)`, `.lineLimit(1)` + `.minimumScaleFactor(0.6)` (2026-10-24'e kadar 40 pt) |
| Türkçe anlam | 28 pt bold | `.title.weight(.bold)` |
| Tanım (İngilizce) | 20 pt | `.title3` + `.fontDesign(.serif)` |
| Örnek (İngilizce) / Türkçesi | 17 / 16 pt | `.body` serif, italik yok / `.callout` + ink2 |
| Widget kelimesi | 20 pt bold, serif | `.title3.bold()` + `.fontDesign(.serif)`, `.widgetAccentable()` |
| Satır içi widget | sistem yazısı | yazı tipi ayarı uygulanmaz |
| En küçük | 11 pt | `.caption2` |

**İkon:** fosfor şeridinden oyulmuş bir anahtar deliği; kilit ve ışık tek şekilde.
- iOS 26 Icon Composer katmanları: zemin, şerit, anahtar deliği.
- Varyantlar: varsayılan, koyu, renklendirilmiş, cam.
- Yedek: şeritte serif "l".
- Mağazadan önce TÜRKPATENT ve marka vekili görüşü bekleniyor (DEVIR.md).

## Altı kural

1. **Şerit = öğrenilecek kelime.** Sarı yalnız kelimenin şeridinde ve örnekteki aynı kelimede olur. Gece ana düğme de sarı değildir. Arama eşleşmesi ve Dikkat farkı sarı değil, kalın ve çizgilidir. Seçili öğeler mürekkeptir.
2. **Kapsül = dokunulur.** Dokunulan her şey dolu ya da kenarlı bir kapsüldür. Mavi bağlantı rengi yoktur.
3. **Yazı tipi dili gösterir.** İngilizce serif, Türkçe ve arayüz SF Pro. Üçüncü bir aile (ör. SF Rounded) yok.
4. **Renk tek başına anlam taşımaz.** Doğru ve yanlış hep simge ve kelimeyle gösterilir; seviye rozetinde nokta sayısı vardır.
5. **Kart sondan kısalır.** Sıra şöyle:
   1. yazı küçülür, etiket ve "Ayrıca" gizlenir;
   2. Dikkat açıklaması gizlenir;
   3. Dikkat tek satıra iner;
   4. örnek de tek satıra iner.

   Erişilebilirlik boyutlarında sayfalama kapanır ve kart akışla birlikte kayar. Kart içinde ayrıca kaydırma yoktur.
6. **Cam yalnız kontrol katmanında.** Sekme çubuğu ve Bitir, geri, Kapat düğmeleri camdır. Kartlar, şıklar, cevap düğmeleri, Devam ve Başla opaktır.

## Ekran ekran (21 Ekim main'ine göre)

Etiketler: **main** = main'de aynısı var; **değişiklik** = main'de farklı; **yeni** = main'de yok.

**Açılış.** Metinler main'deki `OnboardingView`, `TopicPickerView.intro`, `displayName` ve `WidgetGuideContent` ile birebir aynı.
- *Değişiklik:* yalnız görünüm.
- *Yeni:* rehberde widget'ın yerini gösteren küçük önizleme.
- Konular sayfasında main'deki `DeckSummaryLine` var ("Seçili: N kelime", yeni kelime sayısı, küçük destede uyarı).
- İlk kelime kartında Söyle gizli (main'deki `showsSay: false`).

**Akış**
- *Main:*
  - okuma sırası; Söyle (mikrofon) düğmesi;
  - Söyle sayfasının durumları: Dinliyorum → Kontrol ediliyor → Doğru! / Neredeyse! / Bir daha dene / Seni duyamadım. İzin kapalıysa "Söyle şu an çalışmıyor" ve "Ayarları aç". Metinler `PronunciationPracticeView` ve `PronunciationFeedback`'ten.
- *Değişiklik:*
  - kelimenin sesi için hoparlör simgesi yerine "Dinle" kapsülü. Kapsül ve mikrofon aynı satırdadır;
  - Söyle sonucunda yeşil, turuncu ve kırmızı yerine tema renkleri (`good`, `caution`, `bad`) ve aynı tonda açık zemin.
- *Yeni:*
  - sondan kısalma basamakları;
  - kart altında "Biliyorum" (bildiğin kelimede "Bildiğin kelime ✓" ve "Geri al");
  - ilk kartta "Şu an kilitli ekranda". Bu etiket yalnız kilitli ekranda widget varsa çıkar (`WidgetCenter.getCurrentConfigurations`).
- Sayaç ve sayfa noktası yok.

**Tekrar**
- *Main:* 2×2 cevaplar; quiz'de doğruda "Devam" + "Zordu / Kolaydı", yanlışta yalnız "Devam".
- *Değişiklik:* yeni kelime turunun alt yazısı "sonra bildin mi işaretle." yerine "sonra ne kadar bildiğini seç." Artık dört cevap var.
- *Yeni:*
  - cevap düğmelerinde süre ("10 dakika sonra", "12 saat sonra", "yarın", "2 gün sonra");
  - tur sırasında sekme çubuğu gizli;
  - quiz'de cevaptan sonra yalnız doğru şık ve yanlış seçim kalır ve geri bildirim görünür alana kayar;
  - yanlışta "Senin seçtiğin: lend = ödünç vermek" (kart yoksa yalnız kelime), seçilen kelime kartın Dikkat cümlelerinde geçiyorsa "Neden?" ve "Bu kelime 10 dakika sonra yine gelir";
  - kelime kelime tur özeti;
  - bugünlük tamam ekranında sıradaki tekrar (en erken `dueAt`, ör. "bugün 21:40"), "Hatırlatma: 20:00" ve kilitli ekran notu.
- Başlangıçta halka yalnız yeni kelime turunda görünür.

**Sözlük**
- *Main:* arama ve Söyle.
- *Yeni:*
  - boş kutuda "Dene" örnekleri;
  - eşleşen kısım kalın ve çizgili;
  - "Türkçe harfleri yazmasan da bulur" ipucu.
- Ayrıntı ekranında Durum en sonda: ayrı bir satır ve kenarlı düğme ("Biliyorum olarak işaretle" / "Öğrenmeye geri al").

**Ayarlar**
- *Main:* "Öğrenme" ve "Yardım" bölümleri; hatırlatma saati (`DatePicker`, kompakt). İzin reddedilince anahtar kapalı kalır ve "Bildirim iznini aç" çıkar.
- *Yeni:*
  - Widget bölümünde "Widget sağlığı ✓ Çalışıyor" satırı; bozuksa "⚠ Güncellemiyor";
  - soru biçimli başlıklar;
  - 46 pt seçenek düğmeleri;
  - "bir ayda yaklaşık 300 kelime" açıklaması.

**Widget'lar**
- *Main:* hoparlör (`SpeakWordButton`) ve 8 pt taşan düğme grubu; sıra **Sonraki · hoparlör · Biliyorum**.
- *Değişiklik:* sıra **Biliyorum · Dinle · Sonraki**. Böylece "Sonraki" kolay köşede (küçükte sağ alt, ortada en alt) olur ve "Biliyorum" yanlışlıkla basılmaz (ios/README madde 34). Orta boyda "Sonraki 10:00" yerine "Yeni kelime: 10:00".
- *Yeni:*
  - orta boyda örnek, kelimeyi içeren en kısa cümle (kelimeden önce kesilmez);
  - renklendirilmiş, cam ve kilitli ekranda şerit, harflerin altından geçen ince tek renk çizgi; yalnız kelime ve çizgisi renk alır;
  - satır içi widget kısalır: "actually · aslında, gerçekte" → "actually · aslında" → "actually".

## Swift'e geçirirken dikkat

1. **Renkler:** yukarıdaki tablonun hepsi Asset Catalog'a "Any / Dark" (ve "Yüksek kontrast") olarak girer, widget hedefi dahil.
2. **`GlowStyle.swift` (main) eşlemesi:**

   | Şimdi | Yeni |
   |---|---|
   | `Palette.glow` (dolgu) | `primary` |
   | `onGlow` | `onPrimary` |
   | `glowInk` | `tint` |
   | `glowTint` | kaldırılır; Türkçe anlam kutusuz |
   | diğerleri | tablodaki yeni değerler |

   Bileşenlerde:
   - `GlowButtonStyle` → `Capsule()`.
   - `ChoiceRow` seçili hâli: dolgu `surface`, 2 pt `tint` çerçeve, simge `tint`.
   - `SegmentButtons` seçili düğme: dolgu `surface`, yazı `ink`, 1,5 pt `tint` iç çerçeve. Adı değiştirmekle bırakılırsa yeni beyaz dolgu üstünde beyaz yazı çıkar.
3. **Yuvarlak yazıyı kaldır:**
   - `.fontDesign(.rounded)`: `OnboardingView.swift:293`, `:315`, `WidgetGuideView.swift:88`.
   - `.italic()`: `CardDetailViews.swift:17`, `ReviewView.swift:125`, `HomeWordViews.swift:167`, `PronunciationPracticeView.swift:131`.
4. **Şerit:**
   - Açık temada `Text` arkasında eğik kenarlı bir `Path` (alt %60).
   - Koyu temada ve `widgetRenderingMode` `.accented` / `.vibrant` iken: kalınlık 0,13 em (widget'ta 0,1 em). Üst kenar `font.descender` + 2 pt aşağıda, uçlar eğik. Koyu temada arkasında bulanık sarı ışıma.
   - Kelime ve şerit `.widgetAccentable()`.
5. **Dikkat farkı:** doğru cümle " / " ile bölünür; yanlış cümle ilk seçenekle kelime kelime karşılaştırılır (en uzun ortak dizi). Farklı kelime yanlışta `.underline(pattern: .dot, color: bad)`, doğruda `.underline()` + bold.
6. **Quiz:**
   - Seçilen kelimenin anlamı için yeni bir `model.lookup(lemma:)` gerekir (main'de yok).
   - "Neden?" yalnız seçilen kelime Dikkat'in yanlış ya da doğru cümlesinde **tam kelime olarak** geçiyorsa gösterilir.
   - Cevaptan sonra `ScrollViewReader.scrollTo(…, anchor: .bottom)`.
7. **Kart sondan kısalır:** `ViewThatFits(in: .vertical)` ile 5 basamak (kural 5). `dynamicTypeSize.isAccessibilitySize` iken sayfalama (`.scrollTargetBehavior(.paging)`) kapanır.
8. **Cevap süreleri:** `Leitner.review(progress, grade:, at: now).dueAt` ile hesaplanır, elle yazılmaz. Zamanı gelmiş kelimede değerler kutuya göre değişir (kutu 1: Bildim 2 gün, Kolay 4 gün). `ReviewView.hint(for:)` bugün yalnız kutu değişimini söylüyor; ipucu da `dueAt`'ten kurulmalı. AX boyutlarında süre görünmez, ipucunda kalır.
9. **Tur sırasında:** `.toolbar(.hidden, for: .tabBar)`. Cevaplar ve Devam `.safeAreaInset(edge: .bottom)` içinde, opak (`.borderedProminent` / `.bordered`).
10. **Cam:** tek yardımcı yalnız Bitir, geri ve Kapat için. `if #available(iOS 26, *) { .glass } else { .bordered }`.
11. **Widget:**
    - `HomeWordViews.swift`'te küçük ve orta overlay'lerde `NextWordButton` ile `KnowWordButton` yer değiştirir.
    - ios/README madde 45 ve `WidgetSnapshotTests` referansları güncellenir.
    - `widgetURL` gövde dokunuşunda kalır; kelimenin kendisi düğme değildir.
12. **Arama vurgusu:** `TextFold.fold` NFKD kullanır ve boşlukları birleştirir, yani konumlar kayar. Harf harf katlayıp bir konum eşlemesi tutulmalı.
13. **Saat yazımı:** Türkçe ek gerektiren "20:00'de" yerine "Hatırlatma: 20:00", "Yeni kelime: 10:00".
14. **Erişilebilirlik:**
    - İngilizce metinde `accessibilitySpeechLanguage = "en-US"`, IPA `.accessibilityHidden(true)`.
    - Anlam "Türkçesi: …" diye okunur; bölüm başlıklarına `.isHeader`; `Section` başlıklarında `.textCase(nil)`.
    - `accessibilityReduceMotion` açıkken nabız ve geçişler kapanır.
15. **Söyle sonucu:** `FeedbackPanel`'de `.green` / `.orange` / `.red` yerine `good` / `caution` / `bad`. Panelin zemini `goodTint`, %14 `caution` ya da `badTint`. Başlık ve simge kalır; renk tek başına anlam taşımaz (kural 4).

## Açık sorular

- Akış'a "Biliyorum" düğmesi eklensin mi? Widget'taki gibi, sınamadan "bilinen" yapar.
- Tur özeti ayrı ekran mı olsun, yoksa bugünkü gibi başlangıç ekranında kutu mu kalsın?
- İkon: anahtar deliği mi, şeritte "l" mi?
- "Dinle" kapsülü alınırsa açılıştaki "Hoparlöre dokunup dinleyebilirsin" cümlesi "Dinle'ye dokunup…" olmalı.
- Cihazda denenmeli:
  - gece şeridinin ve kilitli ekrandaki çizginin okunması;
  - widget sesinin uygulama açılmadan çalması;
  - yeni düğme sırasının alışkanlığa etkisi;
  - kenar boşluğu hesabı.
