# Erişilebilirlik ve okunabilirlik denetimi: yeni tasarım (22 Ekim 2026)

**Ne denetlendi:** `origin/ios/arayuz-sik`, commit `1e4b4e6` ("Ekran görüntüleri: yeni tasarım"). Bütün satır numaraları bu commit'e göre. Aynı dosyaları cilalayan `ui2-*` oturumları birleşince satırlar kayabilir; bazı bulgular o dallarda zaten değişmiş olabilir (aşağıda "Hangi oturum" sütunu).

**Nasıl denetlendi:**
- **Renk:** `ios/Shared/LockglowTheme.swift` içindeki bütün tokenlar bir betikle okundu. Kodda gerçekten kullanılan 50 yazı/zemin ve çizgi/zemin çifti dört görünümde hesaplandı: açık, koyu, açık + yüksek kontrast, koyu + yüksek kontrast. Betik: [`araclar/kontrast.py`](araclar/kontrast.py).
- **Kod:** 30 Swift dosyası dört bağımsız alt ajan tarafından satır satır okundu (Akış/kart/Söyle, Tekrar/quiz, Sözlük/Ayarlar, Açılış/widget'lar). Öne çıkan her bulgunun kodunu ben ayrıca açıp doğruladım; doğrulanamayanlar "olası" diye işaretli.
- **Ekran görüntüleri:** `docs/ekran-goruntuleri/yeni-tasarim-2026-10-22/` içindeki 10 görüntüye tek tek bakıldı, gerektiğinde piksel ölçüldü.

**Sınırlar:**
- Bu PC'de Swift ve iPhone yok. Hiçbir şey cihazda ya da VoiceOver ile denenmedi.
- Ekran görüntüleri yalnız varsayılan yazı boyutunda. Büyük yazı (AX) ve koyu SE görüntüsü yok.
- "Olası" bulgular cihazda doğrulanmalı.

**Öncelikler:**
- **Şart:** Ana akışta (kart, Tekrar, quiz, Söyle) VoiceOver ya da büyük yazı kullanan birini ciddi biçimde engelliyor.
- **Önerilir:** Fark edilir bir sorun, ama bir çıkış yolu var.
- **İyi olur:** Cila.

**Genel tablo:**
- Tasarım sistemi erişilebilirliği baştan düşünmüş:
  - bütün yazı renkleri eşiği geçiyor;
  - Hareketi Azalt her yerde uygulanmış;
  - doğru/yanlış hiçbir yerde yalnız renkle gösterilmiyor;
  - dokunma alanları 44 pt.
- Asıl açıklar üç yerde:
  1. VoiceOver'da **odak ve duyurular** (bir şey değişince söylenmiyor);
  2. **iki dilli metinlerde İngilizce sesin** kaybolması;
  3. kenarsız kapsüllerin **zeminden ayrılmaması**.

---

## En önemli 10 bulgu

| # | Bulgu | Yer | Öncelik | Hangi oturum (tahmini) |
|---|---|---|---|---|
| 1 | Tekrar kartı çevrilince VoiceOver odağı kayboluyor; anlam ve sonraki kart söylenmiyor ([V1](#v1)) | `ios/App/ReviewView.swift:211-237`, `:493-510` | **Şart** | ui2-tekrar |
| 2 | Söyle ekranında söylenecek kelime/cümle Türkçe sesle okunuyor ([V2](#v2)) | `ios/App/PronunciationPracticeView.swift:176-179` | **Şart** | ui2-soyle |
| 3 | Quiz geri bildiriminde İngilizce kelimeler ("Doğrusu: borrow", "Senin seçtiğin: lend") Türkçe sesle ([V3](#v3)) | `ios/App/QuizCardView.swift:294`, `:333`, `:351`, `:368-372`, `:386` | **Şart** | ui2-quiz |
| 4 | Başka iki dilli yerler (kilit ekranı satır widget'ı, Sözlük satırı, "Duyulan:") ve `englishVoice()` yönteminin kendisi cihazda doğrulanmadı ([V5](#v5), [V6](#v6)) | `ios/Widgets/AccessoryWordViews.swift:81-85`, `ios/Shared/LockglowTheme.swift:282-287` | Önerilir | ui2-widget, ui2-sozluk, ortak |
| 5 | Kenarlı ve kenarsız kapsüller zeminden ayrılmıyor (1,1–1,8:1); Yüksek Kontrast açıkken bile açık temada 2,9:1 ([K1](#k1)) | `ios/Shared/LockglowTheme.swift:111-124`, `:566-573`, `:602` | Önerilir | ortak (tema) |
| 6 | Durum değişiklikleri duyurulmuyor: "Biliyorum", açılışta sayfa geçişi, Söyle'nin çalışmaması ([V7](#v7)) | `ios/App/FeedView.swift:92-106`, `ios/App/OnboardingView.swift:30-41`, `ios/App/PronunciationPracticeView.swift:123-126` | Önerilir | ui2-akis, ui2-acilis, ui2-soyle |
| 7 | Cevap düğmelerinin dönüş süresi büyük yazıda ekrandan kalkıyor, VoiceOver'da yalnız ipucunda ([D2](#d2)) | `ios/App/ReviewView.swift:448-450`, `:908-912` | Önerilir | ui2-tekrar |
| 8 | iPhone SE'de "Devamı ↓" Dikkat kutusunun yazısının üstüne biniyor ([G1](#g1)) | `ios/App/ReviewView.swift:181-193` | Önerilir | ui2-tekrar |
| 9 | Tekrar kartında uzun kalıplar tek satırda kalıyor, büyük yazıda "…" ile kesilebilir; Akış ve Sözlük'teki iki satır çözümü burada yok ([D1](#d1)) | `ios/App/ReviewView.swift:841-860` | Önerilir | ui2-tekrar |
| 10 | Küçük ve orta widget'ta büyük yazıda Türkçe anlam düğmelerin altına girebilir ([D5](#d5)) | `ios/Widgets/HomeWordViews.swift:56-66`, `:124-130` | Önerilir | ui2-widget |

---

## 1. Renk kontrastı

Betik: `python -X utf8 docs/denetim/araclar/kontrast.py` (tam tablo [Ek A](#ek-a-kontrast-tablosu)'da).

**Ölçüt:**
- WCAG 2.2 1.4.3: normal yazı 4,5:1, büyük yazı 3:1.
- WCAG 2.2 1.4.11: yazı dışı öğeler (kenar, simge, ilerleme) 3:1.
- Apple HIG tablosu (17 pt'ye kadar 4,5:1; 18 pt ve üstü ya da kalın yazı 3:1) ayrıca işaretlendi.

**Sonuç:**
- **Bütün yazı çiftleri dört görünümde de 4,5:1'in üstünde.**
  - En düşük yazı: `ink3` sayfa zemininde (açık temada 4,94:1).
  - En düşük anlam rengi: `caution` "Neredeyse!" panelinde (4,89:1); bu başlık zaten büyük ve kalın.
- Gündüz şeridinin üstündeki kelime 13,97:1. Gece şeridi harflerin altında; hiçbir yazı sarının üstünde değil.
- Renklendirilmiş (tinted) widget görüntüsünde ikincil yazı ölçüldü: 6,0:1 (`07-widget-orta-renklendirilmis.png`).
- Sorunlar yazıda değil, **kenarlarda ve izlerde.**

<a id="k1"></a>
### K1. Kapsüller ve seçenek kenarları zeminden ayrılmıyor
- **Yer:**
  - `ios/Shared/LockglowTheme.swift:111-124` (`surface2`, `surface3`, `line`, `lineStrong` tokenları);
  - `:566-573` (kenarlı ve kenarsız düğme dolgusu);
  - `:602` (çip);
  - `ios/App/ReviewView.swift:923-955` (cevap düğmeleri, `surface2`).
- **Sorun:**
  - Kenarlı kapsülün çizgisi (`lineStrong`) zeminde 1,59–1,77:1.
  - Kenarsız (tonal) kapsül (`surface2`) sayfada 1,08:1, kartta 1,20:1. Bunlar: "Dinle", "Biliyorum", "Geri al", çipler, Bilemedim/Zor/Kolay.
  - Yüksek Kontrast açıkken `lineStrong` açık temada yalnız 2,87–2,93:1 olur (koyuda 3,8:1, yeterli).
  - `bg`, `surface`, `surface2`, `surface3` tokenlarının yüksek kontrast değeri hiç yok.
- **Etki:**
  - Az gören biri "Dinle"nin, "Biliyorum"un, cevap kutularının düğme olduğunu ve nerede bittiğini göremez. Kural 2 ("kapsül = dokunulur") bu kişiler için çalışmaz.
  - Yazı etiketi olduğu için WCAG 1.4.11 teknik olarak geçilebilir. Ama Apple HIG şöyle diyor: varsayılan renkler yetmiyorsa, **Increase Contrast açıkken daha yüksek kontrastlı renk** sun.
- **Düzeltme:**
  1. `lineStrong` için `lightHigh` saydamlığını %45'ten **%50'ye** çıkarın. Betik %47'nin 3:1 için en az değer olduğunu hesapladı.
  2. `@Environment(\.colorSchemeContrast) == .increased` ya da `@Environment(\.accessibilityShowButtonShapes)` (iOS "Düğme Şekilleri") açıkken şunlara 1,5 pt `lineStrong` kenar ekleyin: kenarsız kapsül (`CapsuleButtonBody` `.tonal`), çip (`ChipBody`), cevap düğmesi (`GradeButtonStyle`).
  3. İsterseniz `surface2`/`surface3` için biraz daha koyu `lightHigh`/`darkHigh` değerleri tanımlayın.
- **Öncelik:** Önerilir
- **Güven:** kesin (hesap)

### K2. Boş noktalar ve ilerleme izleri çok soluk
- **Yer:**
  - `ios/Shared/LockglowTheme.swift:694` (seviye rozetinde boş nokta, `ink3` %35): 1,59–2,22:1.
  - `ios/App/OnboardingView.swift:93` (adım çubuğunun boş parçası, `surface3`) ve `:342` (seviye noktası): sayfada 1,22–1,55:1.
  - `ios/App/ReviewView.swift:871` (tur ilerleme izi) ve `:1000` (günlük hedef halkası izi).
- **Sorun:** Boş parçalar zeminden 3:1 ayrılmıyor.
- **Etki:**
  - Az gören biri toplam adım sayısını ya da çubuğun nerede bittiğini göremez.
  - Anlam kaybolmuyor: seviye kodu ("A2"), "Kart 3 / 10" ve "0/10" yazıyla da var. Bu yüzden önceliği düşük.
- **Düzeltme:** Boş parçalara 1 pt `lineStrong` kenar verin, ya da yalnız Yüksek Kontrast'ta `surface3` yerine `ink3` kullanın.
- **Öncelik:** İyi olur
- **Güven:** kesin

### K3. Devre dışı ana düğme bir durum mesajı taşıyor ama okunmuyor
- **Yer:** `ios/App/OnboardingView.swift:117`, `:148-150` ("Konular hazırlanıyor…"); `ios/Shared/LockglowTheme.swift:554` (devre dışı opaklık 0,4).
- **Sorun:** Devre dışı düğmede yazı ile dolgu arası 2,6:1 (açık), 3,0:1 (koyu). WCAG devre dışı öğeleri muaf tutar. Ama bu düğme "Konular hazırlanıyor…" diye bir **durum** söylüyor.
- **Etki:** Az gören biri neden beklediğini okuyamaz.
- **Düzeltme:** Hazırlanma durumunu düğmenin üstünde `ink2` metin ve `ProgressView` olarak gösterin; düğme yalnız "Devam" desin.
- **Öncelik:** İyi olur
- **Güven:** kesin

---

## 2. Dinamik Tür (büyük yazı)

**Sabit boyutlu yazılar** (`.system(size:)`). Hepsi tek tek kontrol edildi:

| Yer | Durum |
|---|---|
| `ios/Shared/LockglowTheme.swift:185` (kelime) | Sorun yok: `EnglishWordStyle` `@ScaledMetric(relativeTo: .largeTitle)` ile büyütüyor (`:291-296`). |
| `ios/App/ReviewView.swift:967`, `:973` (bekleyen sayısı) | Sorun yok: `@ScaledMetric(relativeTo: .title)` ile büyüyor; VoiceOver'dan gizli, başlık aynı sayıyı söylüyor. |
| `ios/App/ReviewView.swift:1015`, `:1018` (günlük hedef halkası) | Sorunlu, bkz. [D7](#d7). |
| `ios/App/ReviewView.swift:1056` (bitti işareti) | Sorun yok: süs, VoiceOver'dan gizli. |
| `ios/App/SearchView.swift:366` (boş durum simgesi) | Sorun yok: `@ScaledMetric(relativeTo: .title2)` ile büyüyor, süs. |
| `ios/App/SettingsView.swift:482` (ilerleme sayısı) | Sorunlu, bkz. [D10](#d10). |
| `ios/App/WidgetGuideView.swift:151-199` (rehberdeki widget çizimi) | Kabul edilebilir: resim gibi, VoiceOver'dan gizli ve tek cümleyle anlatılıyor. |

<a id="d1"></a>
### D1. Tekrar kartında uzun kalıplar tek satırda, kesilebilir
- **Yer:**
  - `ios/App/ReviewView.swift:841-860` (`WordHeadline`): ön yüz `:244` 46/60 pt, arka yüz `:266` 40/56 pt;
  - `ios/Shared/LockglowTheme.swift:299-305` (`lineLimit(1)` + `minimumScaleFactor(0.6)`).
- **Sorun:**
  - İçerikte 15 harften uzun 20 kalıp var. En uzunu "Could you tell me the way to" (28 harf).
  - Akış (`ios/App/FeedView.swift:479-525`) ve Sözlük (`ios/App/SearchView.swift:553-575`) böyle kalıpları **iki dengeli satıra** bölüyor.
  - Tekrar kartı yalnız boyutu %70'e indirip sonra %60'a kadar küçültüyor, hep tek satır.
  - Tahmin: AX boyutlarında SE'de (kart içi ~300 pt) kalıp en az ~25 pt'de kalır, ~350 pt ister ve "…" ile kesilir.
- **Etki:** Kullanıcının hatırlaması gereken kelimenin kendisi yarım görünür.
- **Düzeltme:** `WordCardHeadline.balancedLines` mantığını `WordHeadline`'a da ekleyin (üçüncü `ViewThatFits` seçeneği). Bu, `ios/WidgetSnapshots/SnapshotWords.swift`'teki uzun kalıpla SE + AX3 ekran görüntüsü testine bağlansın.
- **Not:** Küçük widget'ta (`ios/Widgets/HomeWordViews.swift:241-257`, tek satır, 20 pt'den 12 pt'ye) ~20 harften uzun kalıplar da kesilir. Bunun için zaten bir anlık görüntü testi var (`ios/WidgetSnapshots/SnapshotWords.swift:43`); sonucuna bakılmalı.
- **Öncelik:** Önerilir
- **Güven:** olası (genişlik tahmini)

<a id="d2"></a>
### D2. Cevap düğmelerinin dönüş süresi büyük yazıda görünmüyor
- **Yer:** `ios/App/ReviewView.swift:908-912` (`GradeLabel`), `:155-163` ve `:402-414` (AX'te tek sütun).
- **Sorun:**
  - AX boyutlarında "10 dakika sonra" satırı hiç çizilmiyor.
  - Oysa o boyutlarda düğmeler tam genişlik ve kartla birlikte kayıyor, yani yer var.
  - VoiceOver'da süre yalnız ipucunda (`:448-450`); bkz. [V9](#v9).
- **Etki:** Büyük yazı kullanan, VoiceOver kullanmayan biri kelimenin ne zaman döneceğini hiç görmez.
- **Düzeltme:** `GradeLabel`'a `showsTime` parametresi verin, `gradeColumn` içinde `true` geçin. README madde 8'deki "AX boyutlarında süre görünmez" kararını güncelleyin.
- **Öncelik:** Önerilir
- **Güven:** kesin

### D3. Tur başlığı "Kart 3 / 10" büyük yazıda kesilebilir
- **Yer:** `ios/App/ReviewView.swift:104-124` (`.lineLimit(1)` `:113`).
- **Sorun:** Mod etiketi, "Kart 3 / 10" ve "Bitir" her boyutta tek `HStack`. AX3 ve üstünde "Bitir" kapsülü genişler, sayaç "Kart 3…" olur.
- **Etki:** Kaçıncı kartta olduğunu göremez.
- **Düzeltme:** AX'te `VStack` ya da `ViewThatFits`; `lineLimit(1)` kalksın.
- **Öncelik:** Önerilir
- **Güven:** olası

### D4. Açılışın konu sayfasında alt çubuk büyük yazıda ekranı kaplıyor
- **Yer:** `ios/App/OnboardingView.swift:103-113`. Karşılaştırma: `ios/App/TopicPickerView.swift:28`, `:52`.
- **Sorun:** Alt çubukta 2–4 satırlık özet ve 54 pt düğme var, kaymıyor. Ayarlar > Konular ekranı AX'te özeti listenin üstüne alıyor; açılış almıyor.
- **Etki:** SE'de en büyük yazıda konu listesine çok az yer kalır.
- **Düzeltme:** `TopicPickerView`'daki kuralın aynısı: `isAccessibilitySize` iken `DeckSummaryLine` listenin başına.
- **Öncelik:** Önerilir
- **Güven:** olası

<a id="d5"></a>
### D5. Widget'ta büyük yazıda anlam kesilebilir
- **Yer:** `ios/Widgets/HomeWordViews.swift:56-66`, `:85-99` (küçük), `:124-130` (orta).
- **Sorun:**
  - `ViewThatFits` hiçbir seçenek sığmazsa son seçeneği yine kullanır.
  - Küçük widget'ın son seçeneği hâlâ 2 satır anlam taşıyor ve `.fixedSize(vertical: true)`.
  - Düğme yeri sabit (`:65-66`).
  - Orta widget'ın son seçeneğinde tanım hep var.
- **Etki:** Büyük yazıda uzun anlam ("sonunda kendini ... bulmak") düğmelerin altına girer ya da alttan kesilir. Anlam, widget'ın en önemli bilgisi.
- **Düzeltme:**
  - Küçük widget'a sona `maxLines: 1` ve `fixedSize`'sız bir seçenek ekleyin.
  - Orta widget'a tanımsız, yalnız anlamlı bir son seçenek ekleyin.
  - `WidgetSnapshotTests`'e xxxLarge ve AX1 testi ekleyin.
- **Öncelik:** Önerilir
- **Güven:** olası (widget'ların ne kadar büyüdüğü iOS'a bağlı)

### D6. Tekrar özeti satırı büyük yazıda taşabilir
- **Yer:** `ios/App/ReviewView.swift:1113-1134`.
- **Sorun:** Sağ sütun AX'te de `.fixedSize(horizontal: true)`; "10 dakika sonra" sarılamaz.
- **Etki:** Süre metni kartın kenarından taşabilir.
- **Düzeltme:** `.fixedSize(horizontal: !isLarge, vertical: false)`.
- **Öncelik:** İyi olur
- **Güven:** olası

<a id="d7"></a>
### D7. Günlük hedef halkasındaki yazı büyümüyor, küçülebiliyor
- **Yer:** `ios/App/ReviewView.swift:991-1022`.
- **Sorun:**
  - Halka en çok 172 pt.
  - "bugünkü hedef" yazısı halkanın %10'u (13–17 pt), üstelik `minimumScaleFactor(0.7)` ile ~9 pt'ye inebilir.
- **Etki:** Büyük yazı kullanan biri hedefi küçük görür. VoiceOver etiketi doğru (`:1027`).
- **Düzeltme:** AX'te halkanın altına normal yazıyla "Bugünkü hedef: 3 / 10 yeni kelime" satırı ekleyin.
- **Öncelik:** İyi olur
- **Güven:** kesin

### D8. "Bilemedim" xxLarge'da kelime ortasından bölünebilir
- **Yer:** `ios/App/ReviewView.swift:421-434`, `:898-907`.
- **Sorun:** 2×2 ızgarada simge xxLarge'a kadar görünüyor. Başlığa ~105 pt kalıyor.
- **Etki:** "Bilemedi / m" gibi kırık başlık.
- **Düzeltme:** Simgeyi `.xLarge`'dan sonra gizleyin ya da `ViewThatFits` ile simgeli/simgesiz iki sürüm kullanın.
- **Öncelik:** İyi olur
- **Güven:** olası

### D9. Diğer küçük Dinamik Tür noktaları (hepsi İyi olur)
- **Söyle sayfası yarım yükseklikte açılıyor** (`ios/App/PronunciationPracticeView.swift:27-31`). AX'te mikrofon çubuğu yarım sayfanın çoğunu alır.
  - Düzeltme: AX'te yalnız `.large`.
  - Güven: olası.
- **Sözlük sonuç satırı AX'te yan yana kalıyor** (`ios/App/SearchView.swift:160-177`). Kelime, seviye rozeti ve onay simgesi tek `HStack`.
  - Düzeltme: AX'te `VStack`.
  - Güven: olası.
- **"Dene" çip satırı yana kayıyor, kaydırma göstergesi gizli** (`ios/App/SearchView.swift:73-89`).
  - Düzeltme: AX'te alt alta.
  - Güven: kesin.
- **Ayarlar'da seviye çubuğu satırı AX'te yan yana kalıyor** (`ios/App/SettingsView.swift:506-526`).
  - Güven: olası.
- **Widget sağlığı simge dairesi sabit 44 pt** (`ios/App/WidgetHealthView.swift:229-231`). Simge `.title3` ile büyüyüp daireden taşar.
  - Düzeltme: `@ScaledMetric(relativeTo: .title3)`.
  - Güven: kesin.
- **"Teknik bilgiler" satırı AX'te alt alta geçmiyor** (`ios/App/WidgetHealthView.swift:360-364`).
  - Güven: kesin.

<a id="d10"></a>
### D10. Ayarlar'daki ilerleme sayısı 34 pt'de duruyor
- **Yer:** `ios/App/SettingsView.swift:476-486` (`:482`), `:290-292`.
- **Sorun:** Sınırın nedeni "üç kutu tek satırda" (`:481`). Ama AX'te kutular zaten alt alta diziliyor; sınır yine de kalıyor.
- **Etki:** Sayı, altındaki açıklamadan küçük görünebilir.
- **Düzeltme:** Alt alta dizilince sınırı kaldırın (`isStacked` parametresi).
- **Öncelik:** İyi olur
- **Güven:** kesin

---

## 3. VoiceOver

<a id="v1"></a>
### V1. Tekrar kartı çevrilince odak kayboluyor; sonraki kart söylenmiyor
- **Yer:** `ios/App/ReviewView.swift:211-237` (ön yüz bir `Button`), `:371-379` ("Anlamı göster"), `:493-497` (`reveal()`), `:499-510` (`answer`).
- **Sorun:**
  - Kartın ön yüzüne ya da "Anlamı göster"e çift dokununca o düğme ekrandan kalkar, yerine arka yüz gelir.
  - Kodda `AccessibilityFocusState` yok, `.layoutChanged`/`.screenChanged` bildirimi yok. Odak sahipsiz kalır.
  - Cevaptan sonra yeni kart (`index += 1`, `.id(word.id)`) da söylenmez.
- **Etki:**
  - VoiceOver kullanıcısı her kartta çift dokunur ve ya sessizlik duyar ya da "Bitir" gibi ilgisiz bir şey.
  - Türkçe anlamı bulmak için ekranı baştan taramak zorunda kalır. Bu, uygulamanın ana akışı.
- **Düzeltme:**
  - `@AccessibilityFocusState private var focus: Field?` ekleyin.
  - Arka yüzdeki Türkçe anlama `.accessibilityFocused($focus, equals: .meaning)` verin.
  - `reveal()` içinde `isRevealed = true`'dan sonra odağı oraya taşıyın.
  - `answer` sonrasında odağı yeni kartın kelimesine taşıyın, ya da `AccessibilityNotification.ScreenChanged(nil).post()` gönderin.
- **Öncelik:** Şart
- **Güven:** kesin (kodda odak yönetimi yok); odağın tam nereye düştüğü olası

<a id="v2"></a>
### V2. Söyle ekranında söylenecek metin Türkçe sesle okunuyor
- **Yer:** `ios/App/PronunciationPracticeView.swift:176-179`.
- **Sorun:** `Text(target.text)` için `.cardEnglishVoice()` yok. Kartta aynı kelime İngilizce sesle okunuyor (`ios/App/FeedView.swift:496`).
- **Etki:** Telaffuz alıştırması ekranında kullanıcı kelimeyi yanlış telaffuzla duyar. En kötü yerde yanlış örnek.
- **Düzeltme:** `.cardEnglishVoice()` ekleyin. Kelime kipinde `.accessibilityAddTraits(.isHeader)` da eklenebilir.
- **Öncelik:** Şart
- **Güven:** kesin

<a id="v3"></a>
### V3. Quiz geri bildiriminde İngilizce kelimeler Türkçe sesle okunuyor
- **Yer:** `ios/App/QuizCardView.swift`:
  - `:294`: anında duyuru "Doğrusu: borrow";
  - `:333`: kutu `.accessibilityElement(children: .combine)`;
  - `:351`: "Doğrusu: **borrow**";
  - `:365-372`: "borrow = ödünç almak", etiketi `word.lemma + ", Türkçesi: " + gloss`;
  - `:380-393`: "Senin seçtiğin: **lend** = ödünç vermek".
- **Sorun:** İngilizce kelime hep Türkçe bir cümlenin içinde, tek `Text` ya da tek birleşik öğe. Hiçbirinde İngilizce ses yok. README madde 14 karşılanmıyor.
- **Etki:** Öğrenci tam sınandığı anda doğru cevabı ve kendi seçtiği kelimeyi yanlış telaffuzla duyar.
- **Düzeltme:**
  - Kutuyu `.contain` yapın.
  - Kelimeyi ayrı bir öğe olarak verin: `HStack { Text("Doğrusu:"); Text(verbatim: quiz.answer).englishVoice() }`. Satır kırma için `ViewThatFits` ya da akış düzeni kullanın.
  - Ya da görünümü değiştirmeden yalnız erişilebilirlik ağacını `.accessibilityRepresentation { … }` ile iki parçalı kurun.
  - Duyuru için bkz. [V8](#v8).
- **Not:** ui2-quiz bu dosyayı yeniden yazdı; birleştirmeden sonra aynı satırlara yeniden bakılmalı.
- **Öncelik:** Şart
- **Güven:** kesin

### V4. Quiz boşluğu "boşluk" diye okunuyor ama İngilizce sesle
- **Yer:** `ios/App/QuizCardView.swift:184-185`, `:197`, `:216-219`.
- **Sorun:**
  - Alt çizgilerin yerine "boşluk" konması iyi.
  - Ama bu etiket `.englishVoice()` alan `Group`'un içinde. "I want to boşluk your pen" cümlesi baştan sona İngilizce sesle okunur; "boşluk" bozulur.
- **Etki:** Boşluğun nerede olduğu anlaşılmayabilir.
- **Düzeltme:** İngilizce bir yer tutucu kullanın: `"blank"` (A2 için bilinen kelime). İpucu olarak `.accessibilityHint("Boşluğa hangisi gelir?")` ekleyin.
- **Öncelik:** Önerilir
- **Güven:** olası

<a id="v5"></a>
### V5. Başka iki dilli yerler
- **Yer ve durum:**
  - **Kilit ekranı satır widget'ı**
    - Yer: `ios/Widgets/AccessoryWordViews.swift:81-85`.
    - Durum: `"\(lemma) · \(meaning)"` tek `Text`; tek kelimelik son seçenekte (`:84`) bile İngilizce ses yok.
    - Güven: **kesin.**
  - **Sözlük sonuç satırı**
    - Yer: `ios/App/SearchView.swift:108-111`, `:161-168`, `:192-195`.
    - Durum: `NavigationLink` içindeki her şey tek etikete birleşir: kelime, seviye, anlam, İngilizce tanım. Parçalardaki `.cardEnglishVoice()` birleşmede kaybolabilir.
    - Güven: olası.
  - **Bildiğim kelimeler satırı**
    - Yer: `ios/App/KnownWordsView.swift:152-166`.
    - Durum: Kelime ve Türkçe anlam tek düğmede.
    - Güven: olası.
  - **Söyle "Duyulan:" satırı**
    - Yer: `ios/App/PronunciationPracticeView.swift:283-287`, `:294`.
    - Durum: Türkçe etiket ile duyulan İngilizce tek `Text`; panel `.combine`.
    - Güven: kesin.
  - **Tekrar özeti satırı**
    - Yer: `ios/App/ReviewView.swift:1101-1105`.
    - Durum: `.combine`. Ayrıca not ve saat simgeleri gizli değil, "kaplumbağa", "tavşan", "saat" diye okunabilir (`:1115-1137`).
    - Güven: olası.
  - **"breakfast geri alındı" bildirimi ve duyurusu**
    - Yer: `ios/App/KnownWordsView.swift:101-111`, `:194`.
    - Güven: kesin.
  - **Sözlük "Dene" çipi "break"; boş ekran cümlesindeki "breakfast"**
    - Yer: `ios/App/SearchView.swift:15`, `:51`, `:82`.
    - Güven: kesin.
  - **Widget rehberindeki İngilizce düğme adları ("Customize", "Add Widgets", "Done", "Edit")**
    - Yer: `ios/App/WidgetGuideView.swift:60-71`, `:109`.
    - Durum: Not: ui2-acilis bu adları ayrı satıra, İngilizce sesle almış.
    - Güven: kesin.
- **Etki:** Kelimeler yanlış telaffuzla duyulur. Kilit ekranı widget'ı uygulamanın en çok görülen yeri.
- **Düzeltme:**
  - Kilit ekranı: tek kelimelik seçeneğe hemen `.widgetEnglishVoice()`. İki dilli satırlar için [V6](#v6)'daki deneme.
  - Birleşik satırlar: açık bir etiket kurun ya da `.contain` + ayrı öğeler.
  - Özet satırı simgeleri: `.accessibilityHidden(true)`.
- **Öncelik:**
  - Önerilir: kilit ekranı, Sözlük, "Duyulan:".
  - İyi olur: diğerleri.

<a id="v6"></a>
### V6. `englishVoice()` yöntemi cihazda doğrulanmalı
- **Yer:**
  - `ios/Shared/LockglowTheme.swift:282-287` (`englishVoice`);
  - `ios/App/CardDetailViews.swift:252-254` (`cardEnglishVoice`);
  - `ios/Widgets/HomeWordViews.swift:379-381` (`widgetEnglishVoice`).
- **Sorun:**
  - Üçü de aynı şeyi yapıyor: `.environment(\.locale, en_US)`. README madde 14 `accessibilitySpeechLanguage = "en-US"` istiyor; SwiftUI'da bunun doğrudan bir karşılığı yok.
  - Bir geliştirici yazısına göre locale ortamı ayrı bir `Text(verbatim:)` ya da düğmenin kendisine verilince VoiceOver dilini değiştiriyor.
  - Aynı yazara göre `AttributedString`'in `accessibilitySpeechLanguage` özniteliği SwiftUI `Text`'te çalışmadı. Apple forumunda da yalnız "bazı durumlarda" çalıştığı söyleniyor.
  - Yani tek `Text` içinde iki dil ve `.combine` ile birleşen öğeler için güvenilir bir yol henüz yok.
- **Etki:** Kartlardaki İngilizce sesin gerçekten çalıştığı bilinmiyor. Çalışmıyorsa V2, V3 ve V5 bütün uygulamaya yayılır.
- **Düzeltme:**
  1. Cihazda VoiceOver (Türkçe) ile şu beşini dinleyin:
     - Akış kartı başlığı;
     - Tekrar ön yüzü (`:227-230`, etiket + `.englishVoice()` düğmede);
     - quiz cümlesi;
     - Sözlük sonuç satırı;
     - kilit ekranı dikdörtgen widget'ı.
  2. Çalışanı tek yardımcıda toplayın: üç kopyayı `Shared`'daki `englishVoice()`'ta birleştirin; tema widget hedefinde de derleniyor.
  3. İki dilli yerler için `AttributedString` + `accessibilitySpeechLanguage` ve `.accessibilityRepresentation` seçeneklerini cihazda karşılaştırın; sonucu README madde 14'e yazın.
- **Öncelik:** Önerilir
- **Güven:** olası

<a id="v7"></a>
### V7. Durum değişiklikleri duyurulmuyor (WCAG 4.1.3)
- **Sorun:** Bir işlemden sonra ekran değişiyor ama VoiceOver bir şey söylemiyor. Çoğunda basılan düğme de kayboluyor, odak sahipsiz kalıyor.
- **Etki:** Kullanıcı işlemin olup olmadığını bilmez; ekranı yeniden taramak zorunda kalır.
- **Düzeltme:** Her birinde `AccessibilityNotification.Announcement("…").post()`. Düğme kayboluyorsa odağı `AccessibilityFocusState` ile yeni düğmeye taşıyın.

| Yer | Ne söylenmiyor | Öncelik | Güven |
|---|---|---|---|
| `ios/App/FeedView.swift:92-106`, `:446-461` | Akış'ta "Biliyorum" / "Geri al": düğme kayboluyor, yerine "Bildiğin kelime" geliyor (Bildiğim kelimeler ekranı bunu duyuruyor: `ios/App/KnownWordsView.swift:111`) | Önerilir | kesin |
| `ios/App/SearchView.swift:724-755` | Sözlük ayrıntıda "Biliyorum olarak işaretle" / "Öğrenmeye geri al" | Önerilir | kesin |
| `ios/App/OnboardingView.swift:30-41`, `:113-118` | Açılışta "Devam" sonrası yeni sayfa: odak alttaki düğmede kalıyor, yeni başlık söylenmiyor; kullanıcı tekrar basıp sayfa atlayabilir | Önerilir | kesin |
| `ios/App/PronunciationPracticeView.swift:123-126`, `:206-232` | Söyle'de yalnız sonuç başlığı duyuruluyor; "Söyle şu an çalışmıyor" ve "model iniyor" durumları duyurulmuyor | Önerilir | kesin |
| `ios/App/SearchView.swift:56-101` | Yazarken sonuç sayısı / "bulunamadı" (yarım saniye gecikmeyle duyurun) | Önerilir | kesin |
| `ios/App/SettingsView.swift:197-206`, `:232-241` | Bildirim izni reddedilince anahtar sessizce kapalı kalıyor | Önerilir | olası |
| `ios/App/SettingsView.swift:41-52` | "İlerleme sıfırlandı" | Önerilir | kesin |
| `ios/App/WidgetHealthView.swift:115-118` | "Widget'ları yenile" sonrası yeni durum | İyi olur | kesin |
| `ios/App/DeckSummaryLine.swift:41-42` | Konu seçince "Kelime az" uyarısının çıkması | İyi olur | kesin |

<a id="v8"></a>
### V8. Quiz sonucu duyurusu kesilebilir; odak geri bildirime gitmiyor
- **Yer:** `ios/App/QuizCardView.swift:286-295`.
- **Sorun:**
  - Duyuru dokunulduğu anda gidiyor. Aynı anda seçenekler azalıyor, etiketleri değişiyor, ekran kayıyor; VoiceOver duyuruyu yarıda kesebilir.
  - Anlam ve "Neden?" söylenmiyor.
- **Etki:** Kullanıcı bazen doğru mu yanlış mı bildiğini duymaz.
- **Düzeltme:** Odağı `AccessibilityFocusState` ile geri bildirim kutusuna taşıyın; o zaman ayrı duyuruya gerek kalmaz. Duyuru kalacaksa kısa bir gecikme ve `accessibilitySpeechAnnouncementPriority = .high` kullanın.
- **Öncelik:** Önerilir
- **Güven:** olası

<a id="v9"></a>
### V9. Dönüş süresi VoiceOver'da yalnız ipucunda
- **Yer:** `ios/App/ReviewView.swift:448-450`; `ios/App/QuizCardView.swift:422`, `:435`, `:442`.
- **Sorun:** "Kelime yarın yeniden gelir" `accessibilityHint` içinde. İpuçları gecikmeli okunur ve birçok kullanıcı onları kapatır.
- **Etki:** İpucu kapalıysa kullanıcı süreyi hiç duymaz.
- **Düzeltme:** `.accessibilityValue("yarın yeniden gelir")`. VoiceOver şöyle okur: "Bildim, yarın yeniden gelir, düğme".
- **Öncelik:** Önerilir
- **Güven:** kesin

### V10. Tur ekranında başlık yok
- **Yer:** `ios/App/ReviewView.swift:47` (gezinme çubuğu gizli), `:103-124`.
- **Sorun:** Tur sırasında "Tekrar" başlığı kalkıyor; yerine `.isHeader` olan hiçbir öğe yok. AX'te mod etiketi de kalkıyor (`:105`).
- **Etki:** VoiceOver'ın "başlıklar" rotoruyla ekranda yer bulunamaz.
- **Düzeltme:** "Kart 3 / 10" metnine `.accessibilityAddTraits(.isHeader)` ve `.accessibilityLabel("Kart 3, toplam 10")` verin.
- **Öncelik:** Önerilir
- **Güven:** kesin

### V11. Bildiğim kelimelerde bütün düğmeler yalnız "Geri al"
- **Yer:** `ios/App/KnownWordsView.swift:169-173`.
- **Sorun:** Hangi kelimeye ait olduğu söylenmiyor. Rotor listesi "Geri al, Geri al, Geri al…" olur.
- **Etki:** Yanlış kelimeyi geri alma riski.
- **Düzeltme:** `.accessibilityLabel("\(lemma) kelimesini geri al")` ve `.accessibilityInputLabels(["Geri al"])`.
- **Öncelik:** Önerilir
- **Güven:** kesin

### V12. Küçük VoiceOver noktaları (hepsi İyi olur)
- **Ayarlar'da iki seçenek grubunun adı yok** (`ios/App/SettingsView.swift:100-118`, `:137-143`).
  - Sorun: Düğme yalnız "5 dk, seçili" diye okunur. "dk" kısaltması da düzgün okunmayabilir.
  - Düzeltme: Günlük hedefteki gibi kapsayıcı etiket (`:187-188`); seçenekler için VoiceOver adı "5 dakika".
- **"2 / 4" ve "3 / 10" "bölü" diye okunabilir** (`ios/App/OnboardingView.swift:99`; `ios/App/ReviewView.swift:109`).
  - Ayrıca tur çubuğu `done: index` söylüyor, metin `index + 1` (`:125`, `:881-883`); iki sayı farklı.
  - Düzeltme: "2. adım, toplam 4".
- **Quizde cevaptan sonra seçenekler hâlâ "düğme"** (`ios/App/QuizCardView.swift:261-263`).
  - Düzeltme: `.accessibilityRemoveTraits(.isButton)`.
- **Tekrar ön yüzünde tür ve seviye okunmuyor** (`ios/App/ReviewView.swift:227`).
  - Düzeltme: `.accessibilityValue("isim, Seviye A1")`.
- **Dikkat kutusunda hangi kelimenin farklı olduğu söylenmiyor** (`ios/App/CardDetailViews.swift:118-134`).
  - Düzeltme: `accessibilityCustomContent("Fark", "did → had")`.
- **"Dinle" kapsülünde görünen ad "Dinle", VoiceOver adı "Kelimeyi dinle"** (`ios/App/CardDetailViews.swift:151-158`).
  - Sorun: Voice Control "Dinle'ye dokun" komutunu tanımayabilir (WCAG 2.5.3).
  - Düzeltme: `.accessibilityInputLabels(["Dinle"])`.
- **"Dene" çiplerinin ne yaptığı söylenmiyor** (`ios/App/SearchView.swift:73-89`).
  - Düzeltme: `.accessibilityHint("Aramaya yazar")`.
- **"Vazgeç" bildirimi 4 sn sonra kendiliğinden kapanıyor** (`ios/App/KnownWordsView.swift:124-136`).
  - VoiceOver'da 10 sn; Switch Control ve Voice Control için uzatılmıyor (WCAG 2.2.1).
  - Düzeltme: odak bildirimdeyken kapatmayın.

---

## 4. Dokunma alanları (44 pt)

**Genel durum iyi.**
- `Theme.minHitSize = 44` her stilde kullanılıyor: ana düğme 50/54 pt, kenarlı ve kenarsız kapsül 44 pt.
- Çip görünüşte 36 pt; şeffaf dolguyla 44 pt dokunma alanı alıyor (`ios/Shared/LockglowTheme.swift:601-609`).
- Diğerleri: seçenek satırı 56 pt, segment 46 pt, cevap düğmesi 60 pt, quiz seçeneği 56 pt, hoparlör ve mikrofon 44 pt.
- Widget düğmeleri 44 × 44 pt (`ios/Widgets/WidgetButtons.swift:76-77`).

### T1. "Geri", "Atla" ve "Bitir" 44 pt'ye yalnız sistem dolgusuyla ulaşıyor
- **Yer:** `ios/App/OnboardingView.swift:61-65`, `:76-80`; `ios/App/ReviewView.swift:117-122`.
- **Sorun:** Etiket `minHeight: 30` (Geri'de `minWidth: 20`). 44 pt'yi `.glass` / `.bordered` stilinin kendi dolgusu tamamlıyor; bu iOS sürümüne göre değişebilir.
- **Etki:** Bazı sürümlerde hedef küçük kalabilir.
- **Düzeltme:** Etikete doğrudan `.frame(minWidth: 44, minHeight: 44)`. iOS 17 ve iOS 26'da ölçün.
- **Öncelik:** İyi olur
- **Güven:** olası

---

## 5. Hareket (Hareketi Azalt)

**Sorun bulunmadı.** Projedeki bütün `withAnimation`, `.animation`, `.transition`, `.symbolEffect`, `scaleEffect` ve `scrollTo` çağrıları tarandı. Hepsi `accessibilityReduceMotion`'a bakıyor ya da yalnız saydamlık geçişi:
- kart açılması (`ios/App/ReviewView.swift:494`);
- ilerleme (`:880`);
- düğme basma (`ios/Shared/LockglowTheme.swift:555-556`, `:611-612`);
- hoparlör dalgası (`ios/App/CardDetailViews.swift:153`, `:207`; `ios/App/QuizCardView.swift:521`);
- Söyle (`ios/App/PronunciationPracticeView.swift:116`, `:219`);
- quiz kaydırma (`ios/App/QuizCardView.swift:126`, `:290`);
- açılış sayfası (`ios/App/OnboardingView.swift:38-41`);
- bildirim geçişi (`ios/App/KnownWordsView.swift:91-97`);
- şerit (`ios/Shared/LockglowTheme.swift:367-373`).

Kart çevirme 3B dönüş değil, yalnız yumuşak geçiş. Akış'taki sayfalı kaydırma kullanıcının kendi hareketi ve AX boyutlarında kapanıyor.

Tek not:
- **Yer:** `ios/App/Speaker.swift:84-103`.
- **Durum:** `SpeakButton` hoparlör efektini Hareketi Azalt'a bakmadan çalıştırıyor. Ama hiçbir yerde kullanılmıyor.
- **Ne yapılmalı:** Silinebilir; yeniden kullanılırsa `!reduceMotion` eklensin.
- **Öncelik:** İyi olur.

---

## 6. Renk tek başına anlam taşıyor mu?

**Sorun bulunmadı.** Kural 4 her yerde uygulanmış:

| Gösterim | Renkten başka ne var | Yer |
|---|---|---|
| Quiz doğru/yanlış şık | ✓/✕ simgesi + "Doğru cevap"/"Yanlış" + kalın çerçeve | `ios/App/QuizCardView.swift:273-284` |
| Quiz sonucu | "Doğru!" / "Doğrusu: …" + simge | `ios/App/QuizCardView.swift:339-359` |
| Dikkat kutusu | ✓/✕ + "Doğru"/"Yanlış"; fark noktalı ya da düz alt çizgi + kalın | `ios/App/CardDetailViews.swift:106-134` |
| Söyle sonucu | simge + başlık ("Doğru!", "Neredeyse!", …) | `ios/App/PronunciationPracticeView.swift:275-308` |
| Seviye | "A2" yazısı + nokta sayısı; "Seviye A2" diye okunuyor | `ios/Shared/LockglowTheme.swift:670-706` |
| Seçili seçenek/segment/çip | kalın `tint` çerçeve + onay simgesi + `.isSelected` | `ios/App/GlowStyle.swift:46-63`, `:119-131` |
| Widget sağlığı | ✓ / ⚠ simgesi + "Çalışıyor"/"Güncellemiyor" | `ios/App/SettingsView.swift:698-723`, `ios/App/WidgetHealthView.swift:235-242` |
| Bildiğin kelime | onay simgesi + "Bildiğin kelime" | `ios/App/FeedView.swift:449` |

---

## 7. Ekran görüntüleri (iPhone SE ve diğerleri)

<a id="g1"></a>
### G1. SE'de "Devamı ↓" Dikkat kutusunun yazısının üstüne biniyor
- **Görüntü:** `02-tekrar-dort-cevap-se.png`
- **Yer:** `ios/App/ReviewView.swift:181-193`.
- **Sorun:**
  - İpucu kaydırma alanının altına, kartın içeriğinin **üstüne** çiziliyor.
  - Kapsülün zemini (`surface2`) Dikkat kutusuyla aynı renk; kapsül görünmüyor.
  - "Devamı ↓" "Dikkat" başlığı ile "✕ Yanlış I did breakfast…" satırının arasına düşüyor; kartın bir parçası gibi okunuyor.
- **Etki:** SE'de kartın en önemli uyarısı karışık görünür. Kullanıcı "Devamı"nın kutunun içeriği olduğunu sanabilir.
- **Düzeltme:**
  - İpucuna kendi zeminini verin: `surface` + `lineStrong` kenar, ya da `ink` dolgu ve `bg` yazı.
  - Altına bir solma (gradient) koyun.
  - Ya da ipucunu kaydırma alanının dışına, "Bu kelimeyi ne kadar bildin?" satırının hemen üstüne taşıyın.
- **Öncelik:** Önerilir
- **Güven:** kesin (görüntüde görülüyor)

### G2. Akış'ta sonraki kartın sarı şeridi sekme çubuğunun altından görünüyor
- **Görüntü:** `01-akis-kelime-karti.png`
- **Yer:** `ios/App/FeedView.swift`. Bu commit'te sekme çubuğu altında örtü yok.
- **Sorun:** Seçili "Akış" sekmesinin arkasında bulanık bir sarı şerit var.
- **Etki:**
  - Kontrast sorunu değil: mürekkep sarının üstünde 14:1.
  - Ama kural 1'e (sarı yalnız öğrenilecek kelimede) aykırı ve göz için gürültü.
- **Düzeltme:** ui2-akis dalı `tabBarVeil` ekliyor (devir notu). Birleştirmeden sonra iOS 17 ve iOS 26'da yeniden görüntü alın.
- **Öncelik:** İyi olur

### G3. Tekrar'daki "Yeni kelime" etiketi kapsül ama dokunulmuyor
- **Görüntü:** `02-tekrar-dort-cevap-se.png`
- **Yer:** `ios/App/ReviewView.swift:130-147`.
- **Sorun:** Kural 2 "kapsül = dokunulur" diyor. Bu etiket `surface2` kapsül ama bir düğme değil.
- **Etki:** Kullanıcı dokunmayı deneyebilir; bilişsel olarak tutarsız. ui2-akis de aynı gerekçeyle "Şu an kilitli ekranda"yı düz satıra çevirdi.
- **Düzeltme:** Kapsülsüz, simgeli düz metin.
- **Öncelik:** İyi olur

### G4. Diğer görüntüler
Varsayılan yazı boyutunda kesilme ya da çakışma yok:
- `03` (quiz yanlış cevap);
- `04` (Tekrar başlangıç, SE): "Bugünün yeni kelimeleri: 10" iki satıra düzgün iniyor;
- `05–07` (widget'lar): koyu ve renklendirilmiş widget'ta ikincil yazı 9,0:1 ve 6,0:1;
- `08` (açılış, SE): üç seviye ve "Devam" tek ekranda;
- `09` (Sözlük kartı, SE);
- `10` (Ayarlar, SE): "Widget sağlığı" iki satıra iniyor ama okunuyor; beş segment sığıyor.

Sekme çubuğunun altında kalan içerik (09, 10) kaydırılınca görünüyor; bu normal.

**Eksik görüntüler (öneri):** Şu durumlarda görüntü yok; `screenshots.yml` bir sonraki çalıştığında eklenmeli:
- SE'de AX3 yazı boyutu: Akış, Tekrar arka yüzü, quiz yanlış cevap, açılış konu sayfası;
- SE'de koyu tema;
- uzun kalıp "Could you tell me the way to": Tekrar ön yüzü ve küçük widget.

---

## Cihazda yapılacak kısa deneme listesi

1. **VoiceOver (Türkçe), İngilizce ses:**
   - Akış kartı;
   - Tekrar ön ve arka yüzü;
   - quiz cümlesi ve geri bildirimi;
   - Söyle;
   - Sözlük satırı;
   - kilit ekranı widget'ları.

   Her birinde İngilizce kelime İngilizce sesle mi okunuyor? ([V6](#v6))
2. **VoiceOver, odak:** Tekrar'da "Anlamı göster" → odak nereye gidiyor? Cevaptan sonra? Açılışta "Devam" sonrası? ([V1](#v1), [V7](#v7))
3. **Ayarlar > Erişilebilirlik > Ekran ve Metin Boyutu > Daha Büyük Metin, en büyük, iPhone SE:**
   - Tekrar başlığı ve cevaplar;
   - açılış konu sayfası;
   - küçük ve orta widget;
   - uzun kalıp.
4. **Kontrastı Artır + Düğme Şekilleri:** kenarsız kapsüller ve cevap düğmeleri zeminden ayrılıyor mu? ([K1](#k1))
5. **Hareketi Azalt:** kart açılması, quiz kaydırma, hoparlör dalgası duruyor mu?
6. **Kalın Metin:** kelime şeridi kalın serif ile hâlâ doğru yerde mi? (`SerifMetrics` kalın yazıyı ölçüyor.)
7. **Sesle Denetim:** "Dinle'ye dokun", "Biliyorum'a dokun", "Bitir'e dokun" komutları çalışıyor mu?

---

## İyi yapılmış olanlar (değiştirmeyin)

- **Yazı renkleri:** Bütün yazı renkleri dört görünümde eşiğin üstünde; yüksek kontrast varyantları yazıyı daha da güçlendiriyor.
- **İngilizce ses:** Kelime, tanım, örnek, quiz cümlesi ve seçenekleri, Dikkat cümleleri, widget kelimesi ve tanımında var.
- **IPA:** IPA her yerde VoiceOver'dan gizli.
- **Anlam:** "Türkçesi: …" diye okunuyor.
- **Başlıklar:** "Akış", "Örnek", "Dikkat", "Bu kelimeyi ne kadar bildin?", "Boşluğa hangisi gelir?", Ayarlar bölümleri ve kelime başlığı `.isHeader`. Ayarlar başlıklarında `.textCase(nil)`.
- **Büyük yazı:**
  - Akış'ta sayfalama kapanıyor, kart kısalmıyor;
  - Tekrar cevapları tek sütun olup kartla kayıyor;
  - quiz düğmeleri içeriğe giriyor;
  - segmentler, ayar satırları, Dikkat etiketleri ve Bildiğim kelimeler satırı alt alta diziliyor;
  - Akış ve Sözlük'te uzun kalıp iki satıra bölünüyor;
  - kilit ekranı widget'ı satırları sondan bırakıyor.
- **Hareketi Azalt:** her animasyonda uygulanmış.
- **Renk:** Doğru/yanlış, seviye ve seçim hiçbir yerde yalnız renkle gösterilmiyor.
- **Dokunma alanları:** her yerde en az 44 pt; widget düğmeleri de.
- **Süsler:** Süs öğeleri (şerit, kaydırma ipucu, rehber çizimi, "Devamı ↓") VoiceOver'dan gizli.
- **Sonuç duyuruları:** Söyle ve quiz sonucu duyuruluyor.
- **Bildiğim kelimeler:** VoiceOver açıkken bildirim daha uzun kalıyor.

---

## Kaynaklar

**Apple Human Interface Guidelines:**
- Accessibility: <https://developer.apple.com/design/human-interface-guidelines/accessibility>
  - Kontrast tablosu: 17 pt'ye kadar 4,5:1; 18 pt 3:1; kalın 3:1.
  - "Increase Contrast açıkken daha yüksek kontrast" önerisi.
  - iOS en küçük kontrol 44×44 pt (alt sınır 28×28).
  - "Convey information with more than color alone."
- Typography (Dinamik Tür): <https://developer.apple.com/design/human-interface-guidelines/typography>
- VoiceOver: <https://developer.apple.com/design/human-interface-guidelines/voiceover>
- Color: <https://developer.apple.com/design/human-interface-guidelines/color>
- Motion: <https://developer.apple.com/design/human-interface-guidelines/motion>
- Widgets: <https://developer.apple.com/design/human-interface-guidelines/widgets>

**WCAG 2.2:**
- 1.4.3 Contrast (Minimum): <https://www.w3.org/TR/WCAG22/#contrast-minimum>. Göreli parlaklık formülü: <https://www.w3.org/TR/WCAG22/#dfn-relative-luminance>
- 1.4.11 Non-text Contrast: <https://www.w3.org/TR/WCAG22/#non-text-contrast>. Açıklama: <https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html>
- 1.4.1 Use of Color: <https://www.w3.org/TR/WCAG22/#use-of-color>
- 1.4.4 Resize Text: <https://www.w3.org/TR/WCAG22/#resize-text>
- 2.2.1 Timing Adjustable: <https://www.w3.org/TR/WCAG22/#timing-adjustable>
- 2.3.3 Animation from Interactions: <https://www.w3.org/TR/WCAG22/#animation-from-interactions>
- 2.4.3 Focus Order: <https://www.w3.org/TR/WCAG22/#focus-order>
- 2.4.6 Headings and Labels: <https://www.w3.org/TR/WCAG22/#headings-and-labels>
- 2.5.3 Label in Name: <https://www.w3.org/TR/WCAG22/#label-in-name>
- 2.5.8 Target Size (Minimum): <https://www.w3.org/TR/WCAG22/#target-size-minimum>
- 3.1.2 Language of Parts: <https://www.w3.org/TR/WCAG22/#language-of-parts>
- 4.1.3 Status Messages: <https://www.w3.org/TR/WCAG22/#status-messages>

**SwiftUI ve VoiceOver dili:**
- `AccessibilityFocusState`: <https://developer.apple.com/documentation/swiftui/accessibilityfocusstate>
- `AccessibilityNotification.Announcement`: <https://developer.apple.com/documentation/accessibility/accessibilitynotification/announcement>
- `AttributeScopes.AccessibilityAttributes`: <https://developer.apple.com/documentation/foundation/attributescopes/accessibilityattributes>
- Use Your Loaf, "SwiftUI Accessibility Language": <https://useyourloaf.com/blog/swiftui-accessibility-language/>
- Apple Developer Forums, çok dilli VoiceOver metni: <https://developer.apple.com/forums/thread/831760>

---

## Ek A: Kontrast tablosu

Üretmek için: `python -X utf8 docs/denetim/araclar/kontrast.py --tokenlar --oneri`

- **Kısaltmalar:** YK = Yüksek Kontrast (Kontrastı Artır).
- **Tür:**
  - "yazı": 4,5:1;
  - "büyük": büyük ya da kalın başlık, 3:1;
  - "kalın": kalın küçük yazı; WCAG 4,5:1, HIG 3:1;
  - "öğe": yazı dışı öğe, 3:1;
  - "bilgi": eşik yok.
- **Saydam renkler** altındaki zeminle karıştırılarak hesaplandı; ör. `surface>goodTint` = kart üstünde `goodTint`.

### Token değerleri

| Token | açık | koyu | açık+YK | koyu+YK |
|---|---|---|---|---|
| `band` | #F5E829 | #E9E040 | #F5E829 | #E9E040 |
| `ink` | #15181B | #F3F4F0 | #0B0C0E | #FFFFFF |
| `ink2` | #4E555B | #B7BDC2 | #3A4046 | #D3D8DC |
| `ink3` | #626A71 | #8E959B | #4E555B | #B7BDC2 |
| `primary` | #15181B | #E9E040 | #0B0C0E | #E9E040 |
| `onPrimary` | #FFFFFF | #15181B | #FFFFFF | #15181B |
| `tint` | #15181B | #F3F4F0 | #0B0C0E | #FFFFFF |
| `tintSoft` | #15181B %8 | #FFFFFF %10 | #15181B %12 | #FFFFFF %16 |
| `bg` | #F3F3EE | #0D0F11 | #F3F3EE | #0D0F11 |
| `surface` | #FFFFFF | #191C20 | #FFFFFF | #191C20 |
| `surface2` | #EBEBE4 | #24282D | #EBEBE4 | #24282D |
| `surface3` | #DEDED6 | #30353B | #DEDED6 | #30353B |
| `line` | #15181B %10 | #FFFFFF %9 | #15181B %22 | #FFFFFF %22 |
| `lineStrong` | #15181B %22 | #FFFFFF %18 | #15181B %45 | #FFFFFF %40 |
| `good` | #17703F | #5BD08F | #0F5A31 | #85E3AF |
| `goodTint` | #DFF2E6 | #5BD08F %16 | #DFF2E6 | #5BD08F %16 |
| `bad` | #B3261E | #FF8C80 | #8E1B15 | #FFB0A8 |
| `badTint` | #FBE5E2 | #FF8C80 %16 | #FBE5E2 | #FF8C80 %16 |
| `caution` | #8F5600 | #FF9E5A | #6E4200 | #FFBC8C |
| `cautionTint` | #EFE7DB | #392E28 | #EFE7DB | #392E28 |
| `bandLight` | #F5E829 | #F5E829 | #F5E829 | #F5E829 |
| `bandDark` | #E9E040 | #E9E040 | #E9E040 | #E9E040 |
| `bandGlow` | #E9E040 %38 | #E9E040 %38 | #E9E040 %38 | #E9E040 %38 |
| `markLight` | #F5E829 %80 | #F5E829 %80 | #F5E829 %80 | #F5E829 %80 |
| `markDark` | #E9E040 %95 | #E9E040 %95 | #E9E040 %95 | #E9E040 %95 |
| `primaryGlow` | #E9E040 %35 | #E9E040 %35 | #E9E040 %35 | #E9E040 %35 |
| `shadowNear` | #15181B %5 | #15181B %5 | #15181B %5 | #15181B %5 |
| `shadowFar` | #15181B %12 | #15181B %12 | #15181B %12 | #15181B %12 |

### Çiftler

| Yazı / öğe | Zemin | Tür | açık | koyu | açık+YK | koyu+YK | Nerede |
|---|---|---|---|---|---|---|---|
| `ink` | `bg` | yazı | 16.01 | 17.38 | 17.58 | 19.20 | Sayfa başlıkları, açıklamalar (her ekran) |
| `ink` | `surface` | yazı | 17.82 | 15.48 | 19.57 | 17.10 | Kelime kartı, Türkçe anlam, örnek cümle, widget |
| `ink` | `surface2` | yazı | 14.88 | 13.42 | 16.34 | 14.83 | Dikkat kutusu, kapsül ve çip yazısı |
| `ink` | `surface>band` | büyük | 13.97 | — | 15.34 | — | Gündüz fosfor şeridi: kelimenin alt yarısı sarının üstünde (LockglowTheme.swift:401) |
| `ink` | `surface>markLight` | kalın | 14.55 | — | 15.98 | — | Örnek cümlede sarı işaretli kelime, gündüz (ExampleMark, LockglowTheme.swift:484) |
| `ink` | `surface>goodTint` | yazı | 15.26 | 11.18 | 16.76 | 12.35 | Söyle sonucu mesajı, quiz doğru şık (PronunciationPracticeView.swift:280) |
| `ink` | `surface>badTint` | yazı | 14.77 | 11.63 | 16.22 | 12.85 | Söyle sonucu mesajı, quiz yanlış şık |
| `ink` | `surface>cautionTint` | yazı | 14.53 | 11.92 | 15.96 | 13.16 | Söyle 'Neredeyse!' mesajı |
| `ink` | `bg>tintSoft` | yazı | 13.64 | 13.57 | 13.78 | 12.23 | Ayarlar satırına basılıyken (SettingsView.swift:692) |
| `ink2` | `bg` | yazı | 6.80 | 10.12 | 9.42 | 13.37 | Bölüm açıklamaları, alt yazılar |
| `ink2` | `surface` | yazı | 7.57 | 9.01 | 10.49 | 11.91 | Çeviri, IPA, açıklama (kart) |
| `ink2` | `surface2` | yazı | 6.32 | 7.82 | 8.76 | 10.33 | Dikkat açıklaması, seçilmemiş segment (GlowStyle.swift:108, CardDetailViews.swift:82) |
| `ink2` | `surface>goodTint` | yazı | 6.48 | 6.51 | 8.98 | 8.60 | Söyle 'Duyulan:' satırı (PronunciationPracticeView.swift:286) |
| `ink2` | `surface>badTint` | yazı | 6.27 | 6.77 | 8.70 | 8.95 | Söyle 'Duyulan:' satırı |
| `ink2` | `surface>cautionTint` | yazı | 6.17 | 6.94 | 8.55 | 9.17 | Söyle 'Duyulan:' satırı |
| `ink3` | `bg` | yazı | 4.94 | 6.33 | 6.80 | 10.12 | Yardımcı yazı (ReviewView.swift:1013) |
| `ink3` | `surface` | yazı | 5.50 | 5.64 | 7.57 | 9.01 | Yer tutucu, yardımcı yazı (SearchView.swift:201, SettingsView.swift:652) |
| `ink3` | `surface2` | öğe | 4.59 | 4.89 | 6.32 | 7.82 | Ok simgesi (chevron) kapsülde (FeedView.swift:413) |
| `good` | `surface` | kalın | 6.13 | 8.84 | 8.31 | 11.08 | 'Bildiğin kelime ✓' (FeedView.swift:451), Sözlük durum |
| `good` | `bg` | kalın | 5.51 | 9.93 | 7.47 | 12.44 | Durum yazısı sayfa zemininde |
| `good` | `surface2` | kalın | 5.12 | 7.67 | 6.94 | 9.60 | Dikkat kutusunda '✓ Doğru' etiketi (CardDetailViews.swift:114) |
| `good` | `surface>goodTint` | büyük | 5.25 | 6.39 | 7.12 | 8.00 | Quiz 'Doğru cevap', Söyle 'Doğru!' başlığı (title3 kalın) |
| `bad` | `surface` | kalın | 6.54 | 7.58 | 9.06 | 9.79 | Sıfırla düğmesi (SettingsView.swift:382) |
| `bad` | `surface2` | kalın | 5.46 | 6.58 | 7.57 | 8.49 | Dikkat kutusunda '✕ Yanlış' etiketi (CardDetailViews.swift:114) |
| `bad` | `surface>badTint` | büyük | 5.42 | 5.70 | 7.51 | 7.36 | Quiz 'Yanlış', Söyle 'Bir daha dene' başlığı |
| `caution` | `surface2` | öğe | 5.01 | 7.27 | 7.18 | 9.05 | Dikkat üçgeni (CardDetailViews.swift:96) |
| `caution` | `surface` | yazı | 6.00 | 8.38 | 8.60 | 10.44 | Az kelime uyarısı (DeckSummaryLine.swift:30), Ayarlar uyarısı |
| `caution` | `surface>cautionTint` | büyük | 4.89 | 6.45 | 7.01 | 8.04 | Söyle 'Neredeyse!' başlığı |
| `onPrimary` | `primary` | kalın | 17.82 | 12.90 | 19.57 | 12.90 | Ana düğme yazısı (PrimaryCapsuleButtonStyle) |
| `onPrimary@0.92` | `primary` | yazı | 15.15 | 10.82 | 16.50 | 10.82 | Varsayılan cevap düğmesinin süre alt yazısı (ReviewView.swift:919) |
| `bg` | `ink` | kalın | 16.01 | 17.38 | 17.58 | 19.20 | Geri alındı bildirimi (KnownWordsView.swift:207) |
| `surface` | `good` | öğe | 6.13 | 8.84 | 8.31 | 11.08 | Widget sağlığı ✓ simgesi yeşil daire içinde (WidgetHealthView.swift:300) |
| `surface` | `bad` | öğe | 6.54 | 7.58 | 9.06 | 9.79 | Widget sağlığı ⚠ simgesi kırmızı daire içinde |
| `lineStrong` | `surface` | öğe | 1.60 ❌ | 1.77 ❌ | 2.93 ❌ | 3.80 | Kenarlı kapsül ve seçenek kenarı kart üstünde |
| `lineStrong` | `bg` | öğe | 1.59 ❌ | 1.69 ❌ | 2.87 ❌ | 3.81 | Kenarlı kapsül kenarı sayfa zemininde (SecondaryCapsuleButtonStyle) |
| `surface2` | `bg` | öğe | 1.08 ❌ | 1.30 ❌ | 1.08 ❌ | 1.30 ❌ | Kenarsız (tonal) kapsül ve cevap düğmesi sayfa zemininde |
| `surface2` | `surface` | öğe | 1.20 ❌ | 1.15 ❌ | 1.20 ❌ | 1.15 ❌ | Kenarsız kapsül, çip ve Dikkat kutusu kart üstünde |
| `surface` | `bg` | öğe | 1.11 ❌ | 1.12 ❌ | 1.11 ❌ | 1.12 ❌ | Kart ve kenarlı kapsül dolgusu sayfa zemininde (kenar çizgisi ayrıca var) |
| `tint` | `surface` | öğe | 17.82 | 15.48 | 19.57 | 17.10 | Seçili seçenek ve segment çerçevesi |
| `tint` | `surface3` | öğe | 13.18 | 11.19 | 14.47 | 12.37 | İlerleme çubuğu dolgusu izin üstünde (ReviewView.swift:871) |
| `surface3` | `surface` | öğe | 1.35 ❌ | 1.38 ❌ | 1.35 ❌ | 1.38 ❌ | Açılış seviye noktası (boş) ve adım çubuğu (OnboardingView.swift:93, :342) |
| `surface3` | `bg` | öğe | 1.22 ❌ | 1.55 ❌ | 1.22 ❌ | 1.55 ❌ | İlerleme izi sayfa zemininde |
| `bg>ink3@0.35` | `bg` | öğe | 1.59 ❌ | 1.78 ❌ | 1.72 ❌ | 2.22 ❌ | Seviye rozetinde boş nokta (LevelBadge, LockglowTheme.swift:694) |
| `ink3` | `surface` | öğe | 5.50 | 5.64 | 7.57 | 9.01 | Seçilmemiş daire simgesi (GlowStyle.swift:48) |
| `line` | `surface` | bilgi | 1.23 | 1.30 | 1.60 | 2.04 | Ayırıcı çizgi (yalnız süs) |
| `primary` | `bg` | öğe | 16.01 | 13.90 | 17.58 | 13.90 | Ana düğmenin şekli sayfa zemininde |
| `good` | `surface` | öğe | 6.13 | 8.84 | 8.31 | 11.08 | Ayarlar anahtarı açıkken iz rengi (SettingsView.swift:252) |
| `bandLight` | `surface` | bilgi | 1.28 | — | 1.28 | — | Gündüz fosfor şeridi kart üstünde |
| `bandDark` | `surface` | bilgi | — | 12.38 | — | 12.38 | Gece şerit çizgisi kart üstünde |
| `bg>onPrimary@0.4` | `bg>primary@0.4` | bilgi | 2.61 | 2.98 | 2.76 | 2.98 | Devre dışı ana düğme, ör. seviye seçilmeden 'Devam', 'Konular hazırlanıyor…' (OnboardingView.swift:117, LockglowTheme.swift:554) |
| `bg>ink@0.4` | `bg>surface@0.4` | bilgi | 2.61 | 3.42 | 2.76 | 3.66 | Devre dışı kenarlı kapsül |

❌ WCAG ve Apple HIG eşiğinin altında. ⚠️ WCAG eşiğinin altında, HIG'in kalın yazı eşiğinin (3:1) üstünde.
Eşiğin altında en az bir görünümde kalan çift: 8

Öneri: kenar çizgisinin 3:1 için gereken en az saydamlığı (sayfa ve kart zemininde)
- açık: #15181B %47 (şimdi lineStrong 0.22, YK 0.45)
- koyu: #FFFFFF %34 (şimdi lineStrong 0.18, YK 0.40)
