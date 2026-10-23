# Lockglow widget dilleri: üç görsel dil ve öneri (23 Ekim 2026)

[`widget_dilleri.html`](widget_dilleri.html) tarayıcıda açılan bir taslak. Artifact (özel): https://claude.ai/artifact/Jx9AQmR4ZesRbdQog894aB. Bu yalnız bir öneri:
- Swift kodu değişmedi.
- Cihazda ya da Xcode'da denenmedi. Tarayıcıda New York yerine Source Serif 4, SF Pro yerine Inter görünür; ölçüler yaklaşıktır.
- Karşılaştırma 23 Ekim `main`'ine (aa7ef5d) göre: `ios/Widgets/`, `ios/Shared/LockglowTheme.swift`, [`../README.md`](../README.md), [`../ogrenme_ilkeleri.md`](../ogrenme_ilkeleri.md) 2.1, [`widget_galerisi.md`](widget_galerisi.md).

**Bu belgedeki terimler:**
- **görsel dil:** widget'ların renk, yazı, çizgi ve düğme kuralları. İçerik (hangi bilgi) değil, görünüş.
- **token:** tasarımdaki bir rengin ya da ölçünün adı (ör. `ink` = ana yazı rengi).
- **vibrant:** iOS'un kilitli ekran widget'larını tek renkte çizme biçimi.
- **accented:** iOS'un renklendirilmiş ve cam ana ekranda widget'ı tek renge çevirme biçimi.
- **katman:** widget'ta ayrı okunan bir yazı satırı türü (kelime, anlam, tanım, örnek, saat…).

## Sayfa nasıl gezilir

- **Görünüm:**
  - *Telefonda:* her dil için ana ekran ve kilitli ekran, gerçek boyutun yaklaşık üçte ikisi;
  - *Yan yana:* her widget ailesi bir satırda, gerçek boyutta (1 pt = 1 px);
  - *Mod tablosu:* seçili widget beş modda.
- **Mod:** Gündüz, Koyu, Gece (StandBy gece modu ve Her zaman açık ekran), Renklendirilmiş (iOS 18), Cam (iOS 26).
- **Kelime:** `ios/WidgetSnapshots/SnapshotWords.swift` içindeki 17 kelime, iki "kendi kelimen" dahil. En zorları: `misunderstanding` (en uzun tek kelime), `Could you tell me the way to` (en uzun kalıp), `actually` (en uzun örnek).
- **Ölçüm şeridi:** sahnenin altında, seçili kelimede her dilin küçük widget'ta seçtiği boy, anlamın tam mı kısa mı göründüğü, katman sayısı ve sarı alan.
- **Adres parametreleri (yerelde ekran görüntüsü için):** `?view=side&mode=dark&word=9&fam=rect&bare=1`. `bare=1` yalnız sahneyi gösterir.
- Sığdırma Swift'teki `ViewThatFits` basamaklarının yaklaşık bir kopyası: kelime ve anlam hiçbir zaman "…" ile kesilmez, anlam kelimeden büyük yazılmaz, önce İngilizce tanım ve örnek düşer.

## Özet

1. **Öneri: "Sakin şerit".** Yeni bir dil değil, bugünkü fosfor dilinin sakinleşmiş hali. A'dan örnekteki sarı işaret ve büyük kelime; C'den az katman ve adlı düğmeler; B'den yalnız tür etiketi. Renk tokenı değişmez. Sayfada en altta beş modda görünür.
   - Dört puanlayıcının ortalaması (30 üzerinden): **A 24**, **C 22,25**, **B 19,5**. İki hakem A'yı, biri C'yi temel seçti; üçü de A'nın kenardan gelen ağır şeridini ve C'nin imlecini istemedi. B'yi kimse seçmedi.
2. Üç dil de yazıda kontrast hedefini (7:1) rahat geçiyor; asıl farklar okunurluk, katman sayısı, sarı alan ve iOS modlarında ne kaldığı.
3. **Yeni bulgular (bugünkü kodda):**
   - Widget düğme dairesinin sınırı zeminle yalnız 1,20:1 (gündüz) ve 1,15:1 (koyu). Temanın kendi kuralı "elle yapılan kapsüle 1 pt `lineStrong` kenar" diyor; widget'ta bu kenar yok. Üç dilde de kenar var (3,5:1 ve üstü).
   - Gündüz şeridi 0,8 em yüksek (taban − 0,56 em'den başlar): küçük widget'ta sarı alan: %8,4 (breakfast); iki satırlık kalıpta: %12,4. README "kelimenin alt yarısı" diyor; çizim bundan büyük. İki satırda şeritler bant gibi görünüyor (hakem 1 ve 2).
4. Renklendirilmiş ve cam ana ekranda iOS bütün içeriği beyaza (sonra kişinin tonuna) boyar. A'nın cesur şeridi ve B'nin kâğıdı orada kaybolur; geriye ince bir çizgi kalır. Bu yüzden markayı renge değil, **yazının biçimine ve çizginin yerine** bağlamak gerekir.

---

## 1. Araştırma

### Apple'ın kuralları (iOS 17–26)

Etiketler: **(belgede)** Apple belgesi, HIG ya da WWDC; **(dış)** Apple dışı kaynak; **(doğrulanmadı)** belgede bulunamadı, cihazda bakılmalı. Apple sayfaları 23 Ekim 2026'da okundu.

**Renklendirilmiş ve cam (Liquid Glass):**
- Renklendirilmiş ya da cam ana ekranda sistem widget'ı `accented` modda çizer. iPhone'da birincil ve vurgu grubunun **ikisini de beyaza** boyar; vurgu rengi yalnız watchOS'ta kalır. Opak resimler tek beyaz olur, saydam içerik saydamlığını korur ama beyazlanır. Zemin kalkar, yerine "temalı cam ya da renk tonu" gelir. (belgede)
- HIG: cam "widget'ın rengini alır, saydamlık, parlama ve Liquid Glass malzemesi ekler"; renklendirilmiş "widget'ı ve içeriğini griye çevirir, sonra kişinin seçtiği tonu uygular". (belgede)
- Öneri: `widgetRenderingMode`'u oku; tam renk resim, degrade ve yarı saydam içeriği yalnız `.fullColor`'da göster. `.accented`'ta düzeni değiştirebilirsin. Resimler için çoğu widget'a `.desaturated` ya da `.accentedDesaturated`. (belgede)
- Renk bu modlarda güvenilir değil: anlamı yazı ve simgeyle taşı. Degrade + beyaz ton "yazıyı okumayı zorlaştırır". (belgede)
- Widget'a özel yeni bir cam API'si yok; `containerBackground(for: .widget)` yine kaldırılabilen zemin. (belgede) Widget içinde `.glassEffect` kullanılabilir mi, belgede yok. (doğrulanmadı)
- Camın ve renklendirilmişin ayrı açık/koyu biçimleri belgede anlatılmıyor. (doğrulanmadı)

**Kilitli ekran:**
- Aksesuar widget'ları hep `vibrant`: renk yok, kullanıcının kilitli ekran tonu. Hiyerarşi saydamlıkla değil **opak gri** tonlarla. (belgede)
- iOS 26'da saat büyütülebiliyor ve "daha saydam" görünüme geçebiliyor. (belgede) Widget'ların ekranın altına inebildiğini Apple dışı kaynaklar yazıyor. (dış)
- Kilitliyken widget düğmeleri çalışmaz. (belgede, galeri belgesinde)

**StandBy ve Her zaman açık ekran:**
- StandBy yalnız küçük widget'ı büyütür ve zeminini kaldırır. "Zengin resim ve rengi az kullan", "uzaktan okunacak büyük yazı". Gece modunda widget `vibrant` ve kırmızı tek renk. (belgede)
- Her zaman açık ekranda `isLuminanceReduced`: genel parlaklığı düşür, büyük dolu şekilleri çizgiye çevir; düzeni değiştirme, öğe silme. (belgede)

**Yazı ve marka (HIG Widgets):**
- Marka öğeleri "düşünülerek" kullanılır; içeriği bastırmaz. Logo nadiren gerekir. Uygulama ikonunu tekrar etmek değer katmaz. (belgede)
- Sistem yazı tipleri tercih edilir; özel yazı tipi ölçülü, çoğunlukla büyük yazıda; küçük yazı SF Pro. Yazı en az 11 pt. (belgede) New York (`.serif`) sistem yazı tipidir; widget'ta seriften yana ya da karşı bir kural yok. (doğrulanmadı)
- Widget'lar Dinamik Tür'ü Large'dan AX5'e kadar destekler; yazı Large'ın altına inmez. (belgede)
- Boyutlar (6,1"): küçük 158, orta 338 × 158, büyük 338 × 354, daire 72, dikdörtgen 160 × 72, satır içi 234 × 26 pt. 6,9 inç ekranda dikdörtgen 172 × 76, SE'de 153 × 68. (belgede)
- Sıkı gruplarda 11 pt kenar boşluğu da olur; zemin kalkınca kenar boşlukları kendiliğinden küçülür. (belgede)

### Kelime uygulamalarından örnekler

| Uygulama | Widget | Ne öğretiyor |
|---|---|---|
| Vocabulary (Monkey Taps) | kilitli ve ana ekran; kelime, tür, tanım; kâğıt zemin, pastel vurgu | "Kitap okur gibi" övülüyor. Şikâyet: widget günlerce güncellenmiyor, kelime tekrar ediyor. (dış) |
| Duolingo | kelime yok; seri sayısı ve gece yarısına doğru "üzülen" baykuş | Etkili ama suçluluk ve kaygı yarattığı için tepki aldı. **Kaçınılacak örnek.** (dış) |
| Babbel, Drops | yalnız seri hatırlatıcısı | İçerik yok, baskı var. (dış) |
| LookUp · Word of the Day | kilitli ekran, ana ekran, StandBy; renklendirilmiş desteği | Her yüzeyi desteklemek güven veriyor. (dış) |
| Word of the Day: Widget (iOS 26) | CEFR seviyeli kelime; orta boyda uygulamayı açmadan okuyan hoparlör | Lockglow'un "Dinle" düğmesine en yakın örnek. Kullanıcı yorumu yok. (dış) |
| Lingo Widget | S, M, L; "sade" açık/koyu stiller; kullanıcı yenileme aralığını seçiyor | Tahmin edilebilir değişim. (dış) |
| Readwise, Apple Günlük | yalnız yazı, sakin zemin, tek kart | Yalın dile en yakın örnekler. (dış) |

**Çıkan dersler:**
- Tek kahraman kelime; kelime anlamdan belirgin büyük.
- Kilitli ekranda iki katman, ana ekranda en çok üç (orta ve büyükte örnek dahil).
- Tek vurgu rengi; o da vurgu grubunda, çünkü renklendirilmiş ve camda renk gider.
- Fotoğraf zemin yok (renklendirilmiş, cam ve kilitli ekranda zaten kalkıyor).
- Seri, geri sayım, kırmızı rozet, üzgün maskot yok.
- Widget'ın güncellenmemesi en sık şikâyet: görünüş kadar güvenilirlik de önemli.

---

## 2. Üç dil

Üç dilin içeriği aynı kurallara uyar (ilkeler 2.1): küçük widget yalnız kelime ve Türkçe anlam ve iki düğme; kilitli ekran iki satır; anlam hiçbir zaman kesilmez. Fark görünüşte ve orta/büyük widget'ın yoğunluğunda.

### A · Işıklı şerit

Bugünkü fosfor dilinin cesur hali.

| | Gündüz | Koyu |
|---|---|---|
| Zemin | `#FFFFFF` | `#000000` (piksel kapalı) |
| Kelime, anlam | `#15181B` | `#F3F4F0` |
| İkincil | `#474E54` | `#B7BDC2` |
| Şerit | `#F5E829`, harflerin alt yarısı (0,40–0,90 em), **widget'ın sol kenarından başlar** | `#E9E040`, kuyrukların altında 0,16 em çizgi, kenardan başlar, %18 ışıma |
| Düğmeler | Dinle: `#EBEBE4` daire + %54 kenar; Sonraki: dolu mürekkep | Sonraki: %12 mürekkep + 2 pt kenar |

- **Yazı:** kelime New York **Black** (900); küçükte 30 → 26 → 22 pt (kalıp 2 satır), anlam SF **Heavy** (800) 19 pt. Orta: kelime 26, anlam 18. Büyük: kelime 44, anlam 26.
- **Orta:** seviye çerçeveli rozet, anlam, İngilizce tanım, örnek (kelime sarı işaretli), "Yeni kelime: 11:00"; sağda düğme sütunu.
- **Büyük:** seviye + söyleniş, kelime, anlam, tanım (2 satır), örnek (2 satır, işaretli); altta adlı üç düğme.
- **Kilitli ekran:** kelime 18 pt Black, altında kenardan gelen 2 pt çizgi; anlam SF kalın.
- **Daire:** 6 pt kalın halka, SF Heavy sayı.

### B · Sözlük sayfası

Kâğıt ve serif.

| | Gündüz | Koyu |
|---|---|---|
| Zemin | `#FBFAF6` (kâğıt) | `#1A1814` (koyu kâğıt) |
| Yazı | `#1D1B17` | `#EFEADF` |
| İkincil | `#4A463E` | `#BFB8A9` |
| Çizgi | yazının %20'si | yazının %20'si |
| Şerit | `#F5E829`, alçak kalem çizgisi (0,68–0,93 em) | `#E9E040`, kuyrukların altında ince çizgi, ışıma yok |
| Düğmeler | dolgusuz daire, 1,5 pt %54 kenar | aynı, %45 kenar |

- **Yazı:** kelime New York Bold; **Türkçe anlam da serif** (New York Semibold); etiketler SF büyük harf, 10,5 pt, aralıklı.
- **Küçük:** kelime, ince çizgi, anlam.
- **Orta:** kelime + söyleniş + seviye, tür ("KALIP FİİL"), anlam, tanım, "▸" ile örnek, "YENİ KELİME: 11:00".
- **Büyük:** kılavuz kelimeler (sayfanın ilk ve son girdisi), tam girdi, çizgi, "AZ ÖNCE" ve iki eski kelime; altta adlı üç düğme.
- **Kilitli ekran:** kelime, kısa çizgi, serif anlam. **Daire:** ince halka, serif sayı.

### C · Yalın

Yalnız kelime ve anlamı.

| | Gündüz | Koyu |
|---|---|---|
| Zemin | `#FFFFFF` | `#000000` |
| Yazı | `#111214` | `#ECEDEA` |
| İkincil | `#4B5056` | `#A3A9AF` |
| Şerit | kelimenin solunda 3 pt × 0,72 em sarı **imleç** | aynı, `#E9E040` |
| Düğmeler | küçükte yalnız simge; orta ve büyükte adlı kapsüller, 1 pt %50 kenar; Sonraki dolu | Sonraki: %12 mürekkep + 2 pt kenar |

- **Yazı:** kelime New York Bold, hafif sıkı aralık; anlam SF **Regular** 18 pt (ağırlık farkıyla ayrılır).
- **Küçük:** kelime ve anlam. **Orta:** kelime, anlam, örnek; altta "Biliyorum · Dinle · Sonraki". Söyleniş, seviye, İngilizce tanım ve saat yok.
- **Büyük:** kelime 48, anlam 28, örnek (3 satıra kadar), dikeyde ortada; altta adlı düğmeler.
- **Kilitli ekran:** imleç + kelime, anlam düz. **Daire:** halka yok, büyük sayı ve "tekrar".

---

## 3. Karşılaştırma

### Kontrast (WCAG 2.2)

Betik: `python -X utf8 docs/denetim/araclar/widget_dilleri_kontrast.py` (renkleri sayfanın `TOK` bloğundan okur; sayfadaki tablo aynı bloktan hesaplanır, yalnız "Bugün" sütunları sayfada yok). Hedefler: yazı 7:1 (Lockglow'un küçük yazı hedefi), şerit üstündeki harf 4,5:1, düğme sınırı 3:1 (WCAG 1.4.11).

| Çift | A gündüz | A koyu | B gündüz | B koyu | C gündüz | C koyu | Öneri gündüz | Öneri koyu | Bugün gündüz | Bugün koyu |
|---|---|---|---|---|---|---|---|---|---|---|
| Kelime ve anlam / zemin | 17,82 ✓ | 19,01 ✓ | 16,46 ✓ | 14,78 ✓ | 18,74 ✓ | 17,87 ✓ | 17,82 ✓ | 15,48 ✓ | 17,82 ✓ | 15,48 ✓ |
| İkincil yazı / zemin | 8,45 ✓ | 11,07 ✓ | 8,99 ✓ | 8,99 ✓ | 8,14 ✓ | 8,85 ✓ | 8,45 ✓ | 9,01 ✓ | 8,45 ✓ | 9,01 ✓ |
| Gündüz: harf / şerit | 13,97 ✓ | — | 13,47 ✓ | — | — | — | 13,97 ✓ | — | 13,97 ✓ | — |
| Şerit / zemin (süs) | 1,28 | 15,20 | 1,22 | 12,83 | 1,28 | 15,20 | 1,28 | 12,38 | 1,28 | 12,38 |
| Düğme sınırı / zemin | 3,84 ✓ | 3,66 ✓ | 3,70 ✓ | 3,94 ✓ | 3,52 ✓ | 3,91 ✓ | 3,84 ✓ | 3,80 ✓ | 1,20 ✗ | 1,15 ✗ |
| Düğme simgesi / düğme içi | 14,88 ✓ | 13,42 ✓ | 16,46 ✓ | 14,78 ✓ | 18,74 ✓ | 17,87 ✓ | 14,88 ✓ | 13,42 ✓ | 14,88 ✓ | 13,42 ✓ |

Gece zemininin parlaklığı (Y): A %0, B %0,92, C %0, Öneri ve bugün %1,14. Saf siyaha geçmenin kazancı çok küçük; Apple'ın kendi widget'ları da koyu gri.

- **Şerit / zemin** bir süs; yazı kuralı uygulanmaz. Gündüz 1,2–1,3:1: sarı açıklıkla değil renk tonuyla seçilir. Bu yüzden marka yalnız sarıya dayanamaz.
- **StandBy gecesi** (üç dil aynı, sistem çizer): kırmızı / siyah 5,03:1; %62 ikincil 2,44:1. Gece StandBy'da anlam **birincil** renkte kalmalı (bugün öyle: küçük widget anlamı `colors.ink` ile çizer).
- **Kilitli ekran:** zemini duvar kâğıdı belirler, sayıyla ölçülemez. Üç dil de kelimede beyaz, anlamda %75 gri kullanır (HIG: opak gri).

### Okunurluk ve yük

Sayılar sayfanın ölçüm şeridinden (küçük widget, gündüz, 6,1").

| | A · Işıklı şerit | B · Sözlük sayfası | C · Yalın | Öneri · Sakin şerit | Bugün (main) |
|---|---|---|---|---|---|
| Küçük: kelime / anlam, breakfast | 26 / 19 pt | 24 / 17 pt | 26 / 18 pt | 28 / 17 pt | 24 / 17 pt |
| Küçük: kelime / anlam, actually | 30 / 19 pt | 24 / 17 pt | 30 / 18 pt | 28 / 17 pt | 24 / 17 pt |
| Küçük: look forward to | 22 pt, 2 satır | 17 pt, 1 satır | 22 pt, 2 satır | 20 pt, 2 satır | 17 pt, 1 satır |
| Anlamın yazısı | SF Heavy | New York Semibold | SF Regular | SF Semibold | SF Bold |
| Yazı katmanı: orta / büyük | 6 / 5 | 8 / 12 | 3 / 3 | 4 / 6 | en çok 7 / — |
| En küçük yazı | 11 pt | 11 pt (büyük harf etiket) | 13 pt | 11,5 pt (tür etiketi) | 11 pt |
| Sarı alan, küçük: breakfast / look forward to / Could you tell me the way to | %7,0 / %11,2 / %10,7 | %2,6 / %2,2 / %3,8 | %0,2 / %0,2 / %0,2 | %5,6 / %6,4 / %6,2 | %8,4 / %7,0 / %12,4 |
| Gece zemini (parlaklık Y) | %0,00 | %0,92 | %0,00 | %1,14 | %1,14 |
| Renklendirilmiş ve camda kalan marka | kenardan gelen ince çizgi | ince çizgi; kâğıt ve çizgiler kaybolur | imleç | ince çizgi | ince çizgi |

- `misunderstanding` küçük widget'ta üç dilde de 13 pt olur (anlam da 13 pt, kelimeden büyük yazılmaz). Bugünkü kodda son çare en çok %75 küçülme; sonuç benzer.
- B'nin büyük widget'ı 12 katman: tam bir sözlük girdisi + iki eski kelime. Güzel ama bir bakışta okunmaz.

### Puanlar

Bu oturum ve üç bağımsız hakem (Opus, orta çaba) aynı ekran görüntülerine baktı. Hakemlerin bakış açıları: **1** A2 öğrenci ve erişilebilirlik, **2** marka ve görsel işçilik, **3** iOS uyumu ve uygulanabilirlik. Hakemler birbirlerinin ve bu oturumun puanını görmedi; bu oturumun önerisi onlara söylenmedi. Bu oturumun puanları hakem raporlarından sonra düzeltildi: C kontrast 5 → 4 ve marka 3 → 2 (imleç ve kapsülsüz düğmeler), B kontrast 5 → 4 (küçük etiketler).

| Ölçüt (5 üzerinden, 4 puanlayıcının ortalaması) | A | B | C |
|---|---|---|---|
| Okunurluk | **4,75** | 3 | 4,5 |
| Kontrast ve erişilebilirlik | **4,5** | 3,25 | 3,75 |
| Öğreticilik | 4 | **4,25** | 3 |
| Yormama | 2,5 | 3 | **5** |
| Marka, tanınırlık | **5** | 3 | 2 |
| iOS uyumu | 3,25 | 3 | **4** |

| Puanlayıcı | A | B | C | Temel seçimi |
|---|---|---|---|---|
| Bu oturum | 24 | 20 | 24 | Öneri (A'nın şeridi, C'nin sadeliği) |
| Hakem 1 · A2 öğrenci, erişilebilirlik | 24 | 20 | 21 | A, sakinleştirilmiş |
| Hakem 2 · marka, görsel | 23 | 19 | 23 | C, şerit geri konmuş |
| Hakem 3 · iOS, uygulanabilirlik | 25 | 19 | 21 | A, C'nin ölçülülüğüyle |
| **Ortalama** | **24** | **19,5** | **22,25** | |

**Hakemlerin ortak bulguları:**
- **C'nin imleci** kilitli ekranda ve StandBy'da "I breakfast" ya da "l disagree" gibi okunuyor. Dil öğrenen için bu bir yanlış okuma riski (üç hakem).
- **A'nın şeridi** iki satırlık kalıpta üst üste iki bant olur, üstü çizili gibi görünür (hakem 1 ve 2). Kenardan gelmesi kenar boşluğu hesabına bağlı: StandBy'da, camda ve iPad'de boşluklar farklı; sabit −16 pt olmaz (hakem 3).
- **A ağır:** kalın Türkçe, kalın şerit ve dolu siyah Sonraki düğmesi; widget başına üç yüksek ses (hakem 2).
- **B** Türkçeyi de serif yazınca kural 3 bozuluyor; etiketler küçük ve Türkçe büyük harf (`İSİM`) için `uppercased(with: Locale(identifier: "tr_TR"))` gerekir; `.smallCaps()` Türkçe kurala uymaz (hakem 3).
- **C'nin küçük widget düğmeleri** kapsülsüz: kural 2 ("dokunulan her şey kapsül") ve bugünkü 1,2:1 sorunu tekrar ediyor (hakem 1 ve 2).
- **"Az önce" listesi** (B'nin büyük widget'ı) eski kelimeleri gösterir; "görmek tekrar değildir" ilkesini zorlar (hakem 1). Hakem 2 isteğe bağlı olabileceğini söyledi; öneriye alınmadı.
- **Adlı üç düğme** orta widget'ta en büyük yazı boylarında sığmaz; `.dynamicTypeSize(...xxLarge)` ile sınırlanmalı ve sığmazsa simge sütununa dönmeli (hakem 3).
- Aynı kartta büyük widget bazen tam anlamı, bazen kısa anlamı gösteriyor (B'de "kendini pek iyi hissetmemek", A ve C'de "biraz rahatsız"). Bu bugünkü kuralın sonucu: tam biçim sığarsa o, sığmazsa editörün kısası (hakem 1 bunu karışıklık saydı; cihazda bakılmalı).

---

## 4. Öneri

### 4.1 Karar: "Sakin şerit"

Bugünkü fosfor dili kalır, ama sakinleşir. Neden yeni bir dil değil:
- A okunurlukta ve markada önde, ama yorucu ve iOS'un tek renk modlarında cesareti kaybolur.
- C sakin ve her modda aynı, ama markasız; imleci yanlış okunuyor.
- Bugünkü dil zaten ikisinin ortasında. Eksikleri küçük ve ölçülebilir: şerit fazla büyük, düğmelerin sınırı yok, orta widget kalabalık, anlam fazla kalın.

**Aldıklarımız:**
- **A'dan:** şerit (marka), örnekteki kelimenin sarı işareti (kelimeyi cümleye bağlar; hakem 1 ve 2), daha büyük kelime.
- **C'den:** az katman (orta 4, büyük 6), adlı düğmeler (A2 için simgeden açık; hakem 1), daha hafif anlam ağırlığı. Regular yerine **semibold**: regular renklendirilmiş ve camda zayıf kalıyor (hakem 3).
- **B'den:** yalnız tür etiketi ("isim · A1"), SF, 11,5 pt, normal harf (hakem 1 ve 2).

**Almadıklarımız:**
- A'nın kenardan gelen şeridi, en kalın ağırlıkları, gece ışımasının güçlenmesi, dolu siyah Sonraki düğmesi.
- B'nin serif Türkçesi, büyük harf etiketleri, kılavuz kelimeleri, "Az önce" listesi.
- C'nin imleci, küçük widget'taki kapsülsüz simgeleri, saf siyah gece kâğıdı (kazanç %1,14 → %0 parlaklık; Apple'ın widget'ları da koyu gri).

### 4.2 Dosya ve token düzeyinde değişiklikler

Swift kodu bu oturumda değişmedi. Aşağıdakiler uygulayacak oturum için.

| # | Dosya ve yer | Bugün | Öneri |
|---|---|---|---|
| 1 | `ios/Shared/LockglowTheme.swift` · `PhosphorBandDrawing`, `case .highlighter` | `.app` ve `.widget` için aynı çizim: `y: baseline - 0.56 * em`, `height: 0.8 * em` (yerleşim dalı yalnız `.underline`'da var) | Yeni `isWidget` dalı; `.widget` için `y: baseline - 0.27 * em`, `height: 0.40 * em`. Sarı alan %8,4 → %5,6 (breakfast), %12,4 → %6,2 (iki satır). Uygulama (`.app`) değişmez. `WidgetGuideView` önizlemesi de `.widget` kullandığı için kendiliğinden uyar. |
| 2 | `ios/Shared/LockglowTheme.swift` · `Theme.Fonts` | — | Yeni: `static let widgetMeaning = Font.body.weight(.semibold)` |
| 3 | `ios/Widgets/HomeWordViews.swift` · `WidgetWordStep.smallWidget` | `[24, 20, 17]` | `[28, 24, 20, 17]` (SE'de ve uzun kelimede basamaklar zaten küçültür) |
| 4 | `ios/Widgets/HomeWordViews.swift` · `SmallWordView.body` | anlam `.body.weight(.bold)`, `.subheadline.weight(.bold)`, `.footnote.weight(.bold)` | `Theme.Fonts.widgetMeaning`, `.subheadline.weight(.semibold)`, `.footnote.weight(.semibold)` |
| 5 | `ios/Widgets/HomeWordViews.swift` · `MediumWordView` | sağda simge sütunu; kelime + söyleniş + seviye, anlam, İngilizce tanım, örnek, "Yeni kelime: 11:00" | Metin tam genişlikte; altta adlı kapsül satırı "Biliyorum · Dinle · Sonraki" (görünen kısa ad; VoiceOver adları bugünkü gibi "Kelimeyi dinle", "Sonraki kelime"). Geçiş açıkça seçilir: `@Environment(\.dynamicTypeSize)` `isAccessibilitySize` ise bugünkü simge sütunu, değilse adlı satır (`ViewThatFits` yalnız taşmaya bakar; `.dynamicTypeSize(...xxLarge)` satırı küçültür, atlamaz). Katmanlar: kelime + "tür · seviye", anlam, örnek. `WidgetIPA`, `WidgetDefinition` ve sonraki değişim satırı orta widget'tan çıkar. Anlam `.callout.weight(.semibold)`; yedekleri `.subheadline.weight(.bold)` → `.subheadline.weight(.semibold)` (bugün satır 199, 204, 209, 215). Adlı satır 44 pt yer alır, metne yaklaşık 82 pt kalır: kalıplarda örnek çoğu zaman düşer. |
| 6 | `ios/Widgets/HomeWordViews.swift` · `WidgetLevel` | "A1" | Yeni `WidgetMeta(pos:level:)`: "isim · A1", `.caption.weight(.semibold)`, `ink2`. VoiceOver: "isim, seviye A1". Kendi kelimede (tür ve seviye yok) gösterilmez. |
| 7 | `ios/Widgets/HomeWordViews.swift` · `WidgetExampleLine.styled` | `highlighted: false` | `WidgetExampleLine`'a yeni `highlighted: Bool` parametresi; değeri üst görünüm verir: `WidgetColors`'a `marksExample` (yalnız `tokens`'ta true). Ortamdan okunmaz: `MediumWordView`'ın görüntü testi için aldığı `renderingMode` / `showsBackground` değerleri de geçerli kalsın. Renklendirilmiş, cam ve StandBy'da yalnız kalın. Ekranda en çok iki sarı: şerit + örnek (kural 1). Eşleme bugünkü gibi `LemmaMatch` ile; düzensiz biçimler (teeth/tooth) işaretlenmez (ilkeler `examples[].focus` istiyor, ayrı iş). |
| 8 | `ios/Widgets/HomeWordViews.swift` · `WidgetColors` | `ink`, `ink2`, `buttonFill` | Yeni `buttonEdge`: `tokens` → `Theme.lineStrong`; `system` ve `lockScreen` → `Color.clear`. Yeni `marksExample`: yalnız `tokens`'ta true. |
| 9 | `ios/Widgets/WidgetButtons.swift` · `WidgetButtonFace` | dolgu var, kenar yok (sınır 1,20:1 / 1,15:1) | `.overlay(Circle().strokeBorder(colors.buttonEdge, lineWidth: 1))` → 3,84:1 / 3,80:1. Yeni `WidgetLabeledButtonFace`: simge + ad, `.footnote.weight(.semibold)`, 32 pt kapsül (`buttonFill` + 1 pt `buttonEdge`), 44 pt dokunma alanı. `NextWordButton`, `KnowWordButton`, `SpeakWordButton` bir `labeled` seçeneği alır. |
| 10 | `ios/App/CardDetailViews.swift` · `CardPartOfSpeech` | yalnız uygulamada | Yeni `ios/Shared/PartOfSpeech.swift` dosyasına taşınır (Shared üç hedefe de derlenir); uygulama aynı adı kullanmaya devam eder. |
| 11 | `ios/WidgetSnapshots/WidgetSnapshotTests.swift` | — | Küçük ve orta görüntüler yeniden alınır. Ek durumlar: orta AX3 (simge sütununa dönüş), orta renklendirilmiş (sarı işaret yok), küçük StandBy, iki satırlık kalıp (şerit bant gibi değil). |

**Değişmeyenler:**
- Bütün renk tokenları.
- Gece kâğıdı `Theme.surface` (#191C20).
- Kilitli ekran dikdörtgeni ve satır içi widget.
- Renklendirilmiş, cam, StandBy ve kilitli ekrandaki ince çizgi; Her zaman açık ekranda 1 pt çizgi.
- Gece şeridi (kuyrukların altında çizgi, hafif ışıma).

### 4.3 Diğer widget oturumlarına

- **A1 · büyük widget (is5-w-buyuk):**
  - Sıra: üst satırda "tür · seviye" ve söyleniş (`ink2`); kelime 40 → 34 → 28 pt (kalıp 28 ya da 24 pt, iki satır); anlam 24 → 22 → 20 pt semibold; İngilizce tanım (serif, 2 satıra kadar, `ink`); örnek (serif, 2 satıra kadar, `ink2`, kelime sarı işaretli); altta adlı üç düğme.
  - "Az önce" listesi önerilmiyor (görmek tekrar değildir; hakem 1).
- **A2 · kilitli ekran ve daire (is5-w-kilit):**
  - `Gauge` + `.accessoryCircularCapacity` (kendi halkamızı çizmeyelim); ortada sayı SF semibold, altında "tekrar" (11 pt).
  - Bitince ✓. Renk yok, kırmızı yok.
  - İmleç ya da ek işaret yok. Dikdörtgen ve satır içi bugünkü gibi.
- **A3 · quiz widget'ı (is5-w-quiz):**
  - Şıklar `WidgetLabeledButtonFace` gibi: ton kapsül + 1 pt `buttonEdge`.
  - Seçilen şıkta sarı yok; doğru ve yanlış simge ve kelimeyle (✓ Doğru / ✗ Doğrusu: …).
  - Boşluktaki kelime cevaptan sonra şeritle.
- **B2 · Widget'ı Düzenle (is5-w-ayar):**
  - Bütün seçenekler aynı dili kullanır.
  - Tema ya da renk seçeneği eklenmesin: görünüm sistemi izler (ilkeler 2.1).
- **B3 · cila (is5-w-cila):**
  - Örnekteki sarı işaret yalnız tam renkte.
  - StandBy'da (`showsWidgetContainerBackground == false`) düğmeler gizlenebilir: galeri fikri 5. StandBy'da telefon çoğu zaman kilitli; kilitliyken düğmeler zaten çalışmaz.
  - Her zaman açık ekranda çizgi 1 pt (ilkeler 2.1 ŞART; is4-widget notu bugün `max(0.1 em, 1.5)` diyor).

### 4.4 Riskler ve cihazda bakılacaklar

1. **Adlı düğme satırı:** iPhone SE'de orta widget 321 pt: üç kapsül yaklaşık 95 pt. "Biliyorum" 13 pt ile sığıyor mu, xxLarge ile? Görünen ad "Sonraki" mi "Sonraki kelime" mi (terimler §3 "Sonraki kelime" diyor; sığarsa uzun ad, sığmazsa terimlere "Sonraki" kısa biçimi eklenir)?
2. **Alçak şerit:** New York'un gerçek ölçüleriyle (`SerifMetrics`) kuyruklu harfler (g, y, p) şeridin altından taşıyor mu; iki satırlık kalıpta bant görüntüsü gitti mi?
3. **28 pt kelime:** küçük widget'ta kaç kelime 28 pt kalıyor, kaçı 24 pt oluyor (görüntü testleri).
4. **Semibold anlam:** renklendirilmiş ve camda yeterince kalın mı?
5. **Örnekteki işaret:** şerit ve işaret, orta widget'ta iki sarı; göze fazla geliyor mu?
6. **Tür etiketi:** "kalıp fiil · B1" uzun kalıplarda kelimenin yerini daraltıyor; sığmazsa önce etiket düşmeli.

### 4.5 Belgelere önerilen metin (koordinatör için; bu oturum değiştirmedi)

- **`docs/tasarim/README.md`, "Widget'lar":** "Orta widget: kelime, 'tür · seviye', anlam ve örnek; örnekteki kelime sarı işaretli (yalnız tam renkte). Düğmeler altta adlarıyla: Biliyorum · Dinle · Sonraki; en büyük yazı boylarında simge sütunu. Widget'ta gündüz şeridi kelimenin alt kısmında, 0,4 em yüksek."
- **`docs/tasarim/ogrenme_ilkeleri.md` 2.1, orta widget:** "[ÖNERİ] 3 düğme, adlarıyla" maddesi uygulanmış sayılır; İngilizce tanım ve söyleniş orta widget'tan büyük widget'a taşınır."
- **`docs/tasarim/ogrenme_ilkeleri.md` 2.1, küçük widget:** "Kelime serif kalın 24 pt ile" ve "24 → 20 → 17 pt" → "28 pt ile" ve "28 → 24 → 20 → 17 pt"; anlam "SF kalın 17 pt" → "SF yarı kalın 17 pt". `HomeWordViews.swift:374` yorumu da aynı.
- **`docs/tasarim/README.md` madde 13 ve `docs/tasarim/terimler.md` §5:** "Yeni kelime: 09:00" orta widget'tan çıkarsa bu iki yer güncellenir (büyük widget'ta ya da Widget sağlığı'nda kalabilir).
- **`docs/tasarim/terimler.md` §3:** düğme satırında "Sonraki" görünen kısa ad olarak kullanılacaksa eklenir (Sesli Denetim adı zaten "Sonraki").
- **`ios/README.md`:** "Widget düğmelerinin dairesinde 1 pt `lineStrong` kenar (sınır 3:1, WCAG 1.4.11)." 

---

## 5. Kaynaklar

- HIG Widgets: https://developer.apple.com/design/human-interface-guidelines/widgets
- Optimizing your widget for accented rendering mode and Liquid Glass: https://developer.apple.com/documentation/widgetkit/optimizing-your-widget-for-accented-rendering-mode-and-liquid-glass
- Preparing widgets for additional contexts and appearances: https://developer.apple.com/documentation/widgetkit/preparing-widgets-for-additional-contexts-and-appearances
- Displaying the right widget background: https://developer.apple.com/documentation/widgetkit/displaying-the-right-widget-background
- Adding StandBy and CarPlay support: https://developer.apple.com/documentation/widgetkit/adding-standby-and-carplay-support-to-your-widget
- WidgetKit güncellemeleri: https://developer.apple.com/documentation/updates/widgetkit
- isLuminanceReduced: https://developer.apple.com/documentation/swiftui/environmentvalues/isluminancereduced
- HIG Always On: https://developer.apple.com/design/human-interface-guidelines/always-on
- HIG Typography: https://developer.apple.com/design/human-interface-guidelines/typography
- HIG Accessibility: https://developer.apple.com/design/human-interface-guidelines/accessibility
- WWDC25 What's new in widgets (278): https://developer.apple.com/videos/play/wwdc2025/278/
- WWDC23 Bring widgets to new places (10027): https://developer.apple.com/videos/play/wwdc2023/10027/
- iPhone Kullanma Kılavuzu, iOS 26 kilitli ekran: https://support.apple.com/guide/iphone/create-a-custom-lock-screen-iph4d0e6c351/26.0/ios/26.0
- (dış) MacRumors iOS 26 kilitli ekran: https://www.macrumors.com/guide/ios-26-lock-screen/
- (dış) Vocabulary (Monkey Taps): https://apps.apple.com/app/id1084540807 , https://fueled.com/blog/vocabulary-helps-expand-well-know/
- (dış) Duolingo widget: https://blog.duolingo.com/widget-feature , tepki: https://cursor.tue.nl/en/opinion/alain-starke/guilt-tripped-by-an-owl
- (dış) Babbel widget: https://support.babbel.com/hc/en-gb/articles/36299516418962-Babbel-widget
- (dış) Drops widget: https://kahoot.com/kahoot-news/never-lose-your-streak-with-the-drops-widget-2/
- (dış) LookUp Word of the Day: https://apps.apple.com/app/id6504736649
- (dış) Word of the Day: Widget: https://apps.apple.com/app/id6781111581
- (dış) Readwise widget: https://readwise.io/changelog/ios-widget
- (dış) Apple Günlük (iOS 18): https://9to5mac.com/heres-everything-new-in-the-journal-app-for-ios-18/
