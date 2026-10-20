# Lockglow arayüz önerisi (20 Ekim 2026)

[`lockglow_ui_mockup.html`](lockglow_ui_mockup.html) tarayıcıda açılan, tıklanabilir bir tasarım önerisi. Swift kodu değişmedi; bu dosya uygulamaya geçirmeden önce bakılacak bir taslak.

- **Gezinme:** üstte *Uygulama*, *Widget'lar*, *Marka ve sistem*; *Açık/Koyu* tema; *Düz/Cam (iOS 26)*. Telefonun içinde sekme çubuğu çalışır.
- **Sağ panel:**
  - cihaz (390 × 844 ya da iPhone SE 375 × 667);
  - yazı boyutu (Dinamik Tür, 5 kademe);
  - 44 pt alanlarını gösterme ve otomatik denetim;
  - her sekmenin ekran durumları;
  - o ekranın tasarım notu.
- **Doğrudan bağlantılar:** `#akis`, `#tekrar`, `#sozluk`, `#ayarlar`, `#widgetlar`, `#marka`.
- **İçerik:** kartlar `content/drafts/kisisel_v1` içinden olduğu gibi alındı (breakfast, borrow, lend, actually, date, appointment, spoon, bread, break, break down, break up, lunch, dinner, currently).
- **Örnek sayılar:** 124 bildiğim kelime, 48 öğreniyorum gibi sayılar örnektir.
- **Bağımlılık:** dış kod yok. Mac dışında SF Pro'ya benzesin diye yalnız Google Fonts'tan Inter ve Nunito yükleniyor; internet yoksa sistem yazısına düşer.

## Kimlik: "kilit ekranında parlayan kelime"

Karanlık ekranda ışık yayan bir kelime. Gece için mor-siyah mürekkep, ışık için amber. Amber yalnız önemli yerde yanar:
- Türkçe karşılığın kutusu;
- ekrandaki tek ana düğme;
- seçili öğe;
- ilerleme.

| Ad | Token | Açık | Koyu | Kullanım |
|---|---|---|---|---|
| Işık | `glow` | `#FFB321` | `#FFBD3F` | Dolgu: ana düğme, seçili düğme, ilerleme. Üstünde yazı **her zaman** `onGlow` (`#1B1200`), 10:1 üstü |
| Işık yazısı | `glowInk` | `#955000` | `#FFC862` | Bağlantı, seçili sekme, hoparlör, simge. Zeminde 5,6:1 / 12,8:1 |
| Işık kutusu | `glowTint` | `#FFF1D2` | amber %14 | Türkçe karşılık kutusu, arama vurgusu |
| Mürekkep | `ink` | `#15131F` | `#F6F3FC` | Ana yazı |
| İkincil yazı | `ink2` | `#4F4A63` | `#BDB7CF` | Okunuş, çeviri, açıklama (7,7:1 / 10,2:1) |
| Zemin / yüzey | `bg` / `surface` | `#F5F4F9` / `#FFFFFF` | `#0C0A12` / `#171420` | Hafif mor gri; saf beyaz-siyah değil |
| Bilemedim | `bad` | `#B42318` | `#FF9D94` | Yanlış şık, Bilemedim |
| Zor | `hard` | `#9A4A00` | `#FFB27A` | Zor |
| Doğru | `good` | `#0C6B49` | `#63E3B0` | Doğru şık, "Widget'lar çalışıyor" |
| Kolay | `easy` | `#1D55C9` | `#93BFFF` | Kolay |

Bütün yazı/zemin çiftleri WCAG AA'yı (4,5:1) geçiyor; oranlar *Marka ve sistem* sayfasında. **Amber'in iki tonu var:** parlak amber yalnız dolgu içindir, açık temada yazı olarak okunmaz. Yazı ve simgede `glowInk` kullanılır.

**Yazı:**
- Kelime ve başlıklar: SF Pro Rounded, Heavy.
- Diğer her şey: SF Pro.
- Lisans gerekmez, Dinamik Tür ile büyür.

| Rol | Boyut | SwiftUI |
|---|---|---|
| Kelime | 44 pt | `.system(size: 44, weight: .heavy, design: .rounded)` + `@ScaledMetric(relativeTo: .largeTitle)` |
| Türkçe karşılık | 28 pt bold | `.title.weight(.bold)` |
| Tanım | 20 pt | `.title3` |
| Örnek / Türkçesi | 17 italik / 16 | `.body.italic()` / `.callout` + `.secondary` |
| Widget kelimesi | 21 pt | `.title3.weight(.heavy)` + `.fontDesign(.rounded)` |
| En küçük | 11 pt | `.caption2` (widget alt sınırı) |

**İkon:** A önerisi "anahtar deliğinden sızan ışık": harfsiz, 29 pt'de de seçiliyor. iOS 26 için dört görünüm çizildi: varsayılan, koyu, renklendirilmiş, cam. Icon Composer'da üç katman olur: zemin, hale, anahtar deliği. B önerisi ("Aa" kilidi) yedek. Mağazadan önce TÜRKPATENT ve marka vekili görüşü bekleniyor (DEVIR.md).

## Ekran ekran kararlar

"Yeni öneri" yazanlar bugünkü kodda yok.

**Akış**
- Okuma sırası değişmedi: kelime → Türkçe karşılık → kısa tanım → örnek ve Türkçesi → Dikkat. Türkçe karşılık amber kutuda.
- Seviye rozetinde nokta sayısı da var (A1 bir, A2 iki, B1 üç).
- Dikkat kutusunda "Yanlış/Doğru" etiketi, simge ve üstü çizili yazı birlikte; anlam renge bağlı değil.
- Uzun kart kendi içinde kayar, sayfa geçişi bozulmaz.
- *Yeni öneri:* kart altında "Biliyorum" düğmesi.

**Tekrar**
- Başlangıç: günlük hedef halkası (6/10), tek amber "Başla" düğmesi. Seri ve puan yok.
- Yeni kelime: ön yüzde yalnız kelime ve okunuş; kartın tamamı ve "Anlamı göster" anlamı açar.
- Cevaplar 2×2: Bilemedim, Zor, Bildim, Kolay. Bu düzen, simgeler (tortoise, hare) ve sıra Zor/Kolay oturumunun koduyla aynı. Bildim amber ve varsayılan.
- *Yeni öneri:* her cevap düğmesinin altında ne olacağı ("10 dk sonra", "1 gün sonra"). Mockup'taki süreler örnek; gerçek değer `Leitner.review` ile önceden hesaplanmalı.
- Boşluk doldurma:
  - boşluk amber çizgi;
  - cevaptan sonra kelime cümlenin içinde vurgulu yazılır ve cümle dinlenir;
  - doğru şık yeşil + "Doğru cevap" + ✓, yanlış seçim kırmızı + "Yanlış" + ✕;
  - doğru cevapta "Devam" ve isteğe bağlı "Zordu / Kolaydı".
- *Yeni öneri:* yanlış cevapta kartın Dikkat kutusu çıkar.
- *Yeni öneri:* tur sonunda ayrı özet ekranı: bildiğin/toplam halkası, dört cevabın sayısı, "Yakında yeniden gelecek" listesi.
- Bugünlük tamam: ışıklı mühür, bugünün üç sayısı, ikincil "5 yeni kelime daha". *Yeni öneri:* yarının kısa özeti ve hedefe giden bağlantı.

**Sözlük**
- Arama kutusu hep görünür (52 pt). Boş ekranda "Dene" örnekleri var: kahv, odunc, randevu, break.
- Türkçe harfsiz yazınca da bulur: "odunc" → ödünç.
- Eşleşen kısım vurgulanır. Türkçeden bulunan satırda "Türkçe eşleşme" yazar.
- *Öneri:* "Ayrıca" karşılıkları da aransın ("randevu" → date). Şimdiki `ContentStore.search` bunu yapıyor mu, bakılmalı.
- Kart ayrıntısı:
  - tüm örnekler, her birinde hoparlör;
  - tüm Dikkat kutuları, not, hafıza ipucu, birlikte kullanılanlar;
  - durum satırı ve tek düğme ("Biliyorum" / "Öğrenmeye geri al").

**Ayarlar**
- En üstte widget durumu: "Widget'ların çalışıyor". Teknik ekran (Widget sağlığı) bir dokunuş ötede.
- Sıklık (5 dk – 2 saat) ve günlük hedef: açılır menü yerine hepsi görünen düğmeler. En büyük yazıda alt alta dizilir.
- Hatırlatma: anahtar ve saat. İzin reddedildiyse açıklama ve "Bildirim iznini aç".
- İlerleme: üç sayı. *Yeni öneri:* seviye çubukları (kart sayıları A1 179, A2 348, B1 227).
- Bildiğim kelimeler: her satırda görünür "Geri al" düğmesi; kaydırma da çalışır. Geri alınca alt bildirim çıkar, "Vazgeç" ile geri döner.
- Widget sağlığı: terimler sade Türkçe ("Veri paylaşımı açık", "Sıradaki kelime sayısı"). Eski etiketler "Teknik bilgiler" altında.
- "İlerlemeyi sıfırla" en altta ve ayrı; onay sayfası sorar.
- Yedekten kurtarma uyarısı da çizildi.

**Widget'lar**
- **Okuma sırası:** sıra aynı. Sığmazsa önce tanım kısalır: `ViewThatFits` sırası `HomeWordViews.swift` ile aynı. Mockup sığan düzeni gerçekten ölçerek seçiyor; SE'deki 141 pt widget'ta da deneyebilirsin.
- **Ses önerisi:** kelime satırının tamamı düğme (yükseklik 44 pt, görünen hoparlör 16 pt).
  - Küçük widget'ta üçüncü bir düğmeye yer yok: 3 × 44 = 132 pt, içerik alanı 126 pt; SE'de 109 pt.
  - Bu yerleşim yeni yer istemiyor.
  - Riski var: kelimeye dokunup uygulamayı açmak isteyen sesi çalabilir. Cihazda denenmeli.
- **Renklendirilmiş / Cam modları:** arka plan gider. Kimliği yuvarlak kalın kelime ve `.widgetAccentable()` taşır. Renkli modda sağ üst köşede hafif amber ışık var.
- **Kilit ekranı:** renk yok (vibrant). Hiyerarşi kalınlıkla kurulur.
- **Satır içi widget:** *yeni öneri:* yalnız ilk karşılık gösterilsin. "actually · aslında, gerçekte" sığmaz; "actually · aslında" sığar.

**Cam (iOS 26).** Önerim: yalnız yüzen parçalar cam olsun (sekme çubuğu, üst düğmeler, sabit alt düğme). İçerik kartı düz kalsın; uzun metin camın üstünde zor okunur. "Cam" düğmesi her şeyi camlaştırıp farkı gösteriyor.

## Swift'e geçirirken dikkat

1. **Renkler:** Asset Catalog'da "Any / Dark" görünümleriyle: `Glow`, `GlowInk`, `GlowTint`, `OnGlow`, `Ink2`, `Bad`, `Hard`, `Good`, `Easy`. Widget hedefi de aynı renkleri görmeli: katalog iki hedefe de eklenmeli.
2. **Amber düğme:** `.borderedProminent` + `.tint(Color("Glow"))` etiketi beyaz yapar ve okunmaz. `.foregroundStyle(Color("OnGlow"))` ekle.
3. **Seçili sekme:** `TabView` için `.tint(Color("GlowInk"))`. Parlak amber açık temada sekme yazısında okunmaz.
4. **Kelime boyutu:** `@ScaledMetric(relativeTo: .largeTitle) var headword: CGFloat = 44`, `.lineLimit(1)` + `.minimumScaleFactor(0.7)`. Mockup'ta kelime 58 pt'de duruyor; çok uzun kelimeler en büyük boyutta kart dışına taşmasın.
5. **Dinamik Tür:** `@Environment(\.dynamicTypeSize)`.
   - `isAccessibilitySize` iken seçim düğmeleri `VStack`'e geçer, cevap simgeleri ve alt yazıları gizlenir.
   - Basit yol: `ViewThatFits { HStack {…}; VStack {…} }`.
6. **44 pt:** `.frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())`.
   - Widget kelime satırını düğme yaparken yükseklik 44 pt olmalı ama düzeni itmemeli.
   - Yöntem: `.padding(.vertical, 9)` + `.padding(.vertical, -9)` ya da `overlay` içinde şeffaf düğme.
7. **Büyük harf:** Türkçe metni büyük harfe çevirme. "i" → "I" olur, "İ" olmaz. `Section` başlıklarına güvence için `.textCase(nil)` ver.
8. **Cam:** `if #available(iOS 26, *) { .glassEffect(…) } else { .background(.thinMaterial) }`. Proje iOS 17'yi hedefliyor.
9. **Widget görünüm modları:**
   - `@Environment(\.widgetRenderingMode)` `.accented` iken yalnız metin.
   - `containerBackground` zorunlu.
   - Kilit ekranı dikdörtgeninde `AccessoryWidgetBackground()`.
   - Satır içi için `glossTR.split(separator: ",").first`.
10. **Hareket:** `@Environment(\.accessibilityReduceMotion)` açıkken halka, nabız ve kart geçişi animasyonsuz. Cevapta `.sensoryFeedback(.success / .error, trigger:)`.
11. **Diğer oturumlarla uyum:**
    - Cevap düğmeleri ve quiz sonrası "Ya da bu soru nasıl geldi?" Zor/Kolay oturumunun yaptığıyla aynı. Bu tasarım yalnız renk, alt yazı ve yerleşim ayrıntısı ekliyor.
    - Widget ses düğmesinin yeri yalnız öneri. Widget oturumunun kararı geçerli.

## Açık sorular

- Yeni kelimede "Zor" ne yapacak, alt yazıda ne yazmalı? (Mockup "yakında" diyor.)
- Akış'a "Biliyorum" düğmesi eklensin mi? Widget'taki gibi sınamadan "bilinen" yapar.
- Tur özeti ayrı ekran mı olsun, yoksa bugünkü gibi başlangıç ekranının üstünde kutu mu kalsın?
- İkon A mı, B mi?
- Hepsi cihazda denenmeli. Özellikle widget kelime satırının ses düğmesi olması ve kilit ekranında okunabilirlik.
