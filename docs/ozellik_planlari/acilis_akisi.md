# Açılış akışı (onboarding): teknik plan

Durum: taslak, 2. sürüm (2026-10-21, denetim sonrası). Bu plan kod değişikliği içermez.
Dayanak: `main` d99180e (Zor/Kolay 315787f ile birleşti). **Taban: `origin/ios/acilis-deste` (ea3e8ce; 3 commit: 5308534 "Deste seçimi", c4d90a3 "Açılış akışı", ea3e8ce README; henüz main'de değil).** Bu dal seviye, konular, widget rehberi ve ilk kelime sayfalarını, deste (konu + seviye) seçimini ve UI testini zaten uyguluyor; README madde 46'ya göre CI'da derlendi (151 paket testi). İlk taslak bu işi sıfırdan tarif ediyordu. Bu sürüm yalnızca dalın **üstüne eklenecek farkları** anlatır. Dalın sembolleri gerçek adlarıyla yazılır, yeni olanların yanında **(yeni)** yazar, doğrulanmamış bilgiler ayrıca işaretlidir.

## 1. Amaç ve kapsam

**Neden.** Dal olmadan uygulama doğrudan Akış'ı açıyordu. Üç eksik vardı.
- Seviye bilinmiyor. `ContentStore.freeCards` sonucu `ORDER BY c.level_rank ASC ...` sıralı (`ContentStore.swift:121`), A2'deki kullanıcı önce 179 A1 kelimesini görür.
- Widget nasıl eklenir hiçbir yerde anlatılmıyor. iOS'ta uygulamadan widget ekletmek için API yok, yalnızca adım adım anlatılabilir.
- İlk dakikada kelime görülmüyor.

**Rakip bağlamı (Ekim 2026).** Kolay İngilizce widget ve adım adım kurulum rehberi ekledi. Orbit, Lingo ve Wordismo telaffuz pratiği ekledi. Telaffuz ayrı iştir (`ios/telaffuz`) ve turda yoktur.

**Dalda zaten var (bu plan yeniden yazmaz).**
- 4 sayfalı tur (`OnboardingView`), her sayfada "Atla", Ayarlar > Yardım'dan yeniden açma.
- Konu seçimi (`ContentStore.topics()`, `TopicChoiceList`, `TopicPickerView`), seviye sırası (`DeckFilter.ordered`), `AppModel.feedWords`.
- Widget rehberi (`WidgetGuideContent`, Apple'ın Türkçe kılavuzundaki adlarla).
- Taze kurulumda ilk planın seçime kadar ertelenmesi, kuyruğun `QueueComposer.compose(deck:fallbackFeed:...)` ile kurulması.
- UI testi `testCaptureOnboarding` (ekran görüntüleri `0a`-`0e`).

**Bu plan ne ekler (dalın boşlukları).**
1. Mevcut kullanıcı tespiti (`OnboardingGate`, tek kanıt: plan dosyası).
2. Konular sayfası: yükleme sırasında düğme pasif, seçimin kelime ve gün özeti, yumuşatılmış vaat metni.
3. Seçilen konuların yeni kelimeleri bitince Tekrar ve hatırlatma da tüm konulara düşer (widget zaten düşüyor): `DeckFilter.newWordFeed`.
4. Rehber metinleri: İngilizce karşılıklar, kilitli ekranda dikdörtgen ve tek satır ayrımı.
5. İlk kelime sayfasında hata durumu. Telaffuz birleşince "Söyle" düğmesi turda gizli.
6. Gizlilik manifestinde eksik `FileTimestamp` bildirimi (açılıştan bağımsız, mevcut açık, ayrı commit).
7. Test ve doğrulama yolu (CI), belgeler.
8. Koşullu: alt seviye serpiştirme ([U1]).

**Kararlar (özet).**

| Konu | Karar | Gerekçe |
|---|---|---|
| Taban | `ios/acilis-deste` | Aynı iş iki kez yazılmaz ([U0]) |
| Sayfa sayısı | 4 sabit sayfa: Seviye, Konular, Widget rehberi, İlk kelime | Sayaç hep "x / 4"; içerik yüklemesi sayfa listesini değiştirmez |
| Seviye etkisi | Sert filtre değil, yeni kelime **sırası** (`DeckFilter.ordered`) | Akış hiç boşalmaz, hiçbir kelime silinmez |
| Konu etkisi | `DeckFilter.filtered`; seçim boşsa ya da eşleşme yoksa hepsi | Seçim desteyi boşaltmaz |
| Atla | Turu bitirir, o ana kadar seçilenleri uygular, olmayan seçimi uydurmaz | Seçilmemiş seviye `nil` kalır (A1 sırasıyla aynı) |
| Mevcut kullanıcı | Plan dosyası varsa tur kendiliğinden açılmaz | Tek kanıt, tek bayrak |
| Bildirim isteği | Turda ve bu planda yok | Bölüm 10, R8 |
| Sunum | `.fullScreenCover` (dal) | `RootView.task { start() }` TabView'da çalışmaya devam eder |
| UI test | `-lockglow.onboardingCompleted YES` ya da `NO` (dal) | Uygulamada ek argüman kodu gerekmez |

**Bu sürümde olmayanlar.** Paywall, hesap, analitik rızası, ana dil seçimi (içerik yalnızca `tr`), "neden öğreniyorsun" sorusu, kalibrasyon testi, günlük hedef ve hatırlatma saati seçimi, TipKit, "Emin değilim" seçeneği, kalıcı adım numarası, widget'ın eklendiğini algılama ve animasyonlu çizim (`getCurrentConfigurations` Simülatör ve Debug'da boş dönebilir, `ios/README.md` madde 21), bildirim isteği, telaffuz ve mikrofon izni.

## 2. Kullanıcı akışı

1. **İlk açılış (taze kurulum).** `AppModel.showsOnboarding` true. `RootView` TabView'in üstüne `.fullScreenCover` açar. Altta `model.start()` çalışır: içerik yüklenir ama `widget_plan.json` **yazılmaz** (taze kurulumda ilk planı seçim yazar).
2. **Sayfa 1, Seviye.** Kullanıcı A1, A2 veya B1 seçer, **Devam**. Seçmeden Devam pasif.
3. **Sayfa 2, Konular.** İstediği konuları seçer ya da hiçbirini seçmez (= hepsi). Sayfadan çıkınca `applyChoice()` çalışır ve ilk widget planı yazılır. Böylece 3. sayfada eklenen widget seçilen kelimelerle başlar.
4. **Sayfa 3, Widget rehberi.** "Kilitli ekran" ve "Ana ekran" adım listeleri. Kullanıcı uygulamadan çıkıp widget ekleyebilir. Uygulama arka plana gidince `sceneDidEnterBackground` planı yeniden yazar. Geri dönünce uygulama bellekte kaldıysa aynı sayfadadır.
5. **Sayfa 4, İlk kelime.** `model.firstDeckWord()` tam kartla gösterilir. **Başla** turu bitirir.
6. **Bitiş.** `lockglow.onboardingCompleted = true`, plan yeniden yazılır, cover kapanır, Akış'ın ilk kartı o kelimedir. Tur bir daha kendiliğinden açılmaz.
7. **Atla.** Üst çubukta (sayfa 4 hariç) her sayfada vardır. Turu bitirir, o ana kadar seçilenleri uygular. Seviye hiç seçilmediyse `startLevel` yazılmaz.
8. **Mevcut kullanıcı (TestFlight güncellemesi).** `lockglow.onboardingCompleted` anahtarı yoksa ama `widget_plan.json` varsa tur açılmaz, bayrak sessizce `true` yazılır (bölüm 4). Rehber ve tur Ayarlar > Yardım'dan açılır.
9. **Tur sırasında uygulama öldürülürse.** Adım numarası saklanmaz (bilerek). Tur baştan açılır. 2. sayfadan çıkıldıysa seviye ve konu seçimi önceden seçili gelir (`OnboardingView.loadChoice`).

**Seviye nasıl etki eder.** Yalnızca yeni kelimelerin sırası değişir. `DeckFilter.ordered`: seçilen seviye önce, sonra üstündekiler (kolaydan zora), sonra altındakiler (yakından uzağa), seviyesi bilinmeyenler en sonda.

| Seçim | Sıra | İlk 100 yeni kelime (753 kart: A1 179, A2 348, B1 226) |
|---|---|---|
| Seçilmedi ya da A1 | A1, A2, B1 (bugünkü sıra) | 100 A1 |
| A2 | A2, B1, en sonda A1 | 100 A2; A1'e 574 kelimeden sonra gelinir |
| B1 | B1, A2, A1 | 100 B1 |

`nil` ile A1 aynı sırayı verir (`DeckFilterTests.testStartLevelFirstThenHarderThenEasier`). Neden sert filtre değil: A1 ve `workplace_office` kesişimi 0 kart (content.sqlite, salt okunur sorgu), seviye ve konu sert filtre olsaydı akış boşalırdı. A2 kullanıcısının A1 boşlukları sona kaldığı için [U1] karışık sıra seçeneğini sorar (bölüm 5.1, Faz 2).

## 3. Ekranlar ve metinler

### 3.0 Ortak çerçeve (dalda)
- `OnboardingView`: üstte `topBar` (Geri okçuğu, 4 parçalı `progressBar`, **Atla** `onboarding.skip`), ortada `ScrollView`, altta `bottomBar` (`GlowButtonStyle`, kimlik `onboarding.next`, son sayfada `onboarding.start`). `Page` enum: `level, topics, widget, firstWord`. Sayaç erişilebilirlik etiketi "Adım 1 / 4".
- Renkler `GlowStyle.swift` içindeki `Palette` (mockup değerleri kodda). Düğme etiketi `onGlow` (#1B1200), amber üstünde beyaz AA kontrastını geçmez.
- Erişilebilirlik: başlıklar `.isHeader`, seçili satır `.isSelected`. Reduce Motion açıkken geçiş animasyonu yok.
- İlk taslaktaki "Başla ile başlayan etiket kullanma" kuralı kalktı: UI testi Tekrar'da `BEGINSWITH "Başla"` arar (`LockglowScreenshotTests.swift:32`), ama o sırada tur kapalıdır (cover yok ya da bitmiş), çakışma olmaz.

### 3.1 Sayfa 1: Seviye (dalda, değişmez)
- Başlık: **İngilizcen ne düzeyde?**
- Alt metin: **Yeni kelimeler bu seviyeden başlar. Daha kolay kelimeler sona kalır, hiçbiri kaybolmaz.**
- Satırlar (`LevelOptionLabel`, kimlik `onboarding.level.A1` ...): **Yeni başlıyorum** (A1, "Ev, yemek, aile gibi en temel kelimeler. 179 kelime."), **Temel konuşabiliyorum** (A2, "Alışveriş, yol, randevu: günlük hayat. 348 kelime."), **Günlük konuşmayı anlıyorum** (B1, "İş, seyahat, duygular; daha uzun cümleler. 226 kelime."). Kelime sayıları `model.words` içinden hesaplanır, içerik yüklenmediyse yazılmaz.
- Alt not: "İstediğin zaman Ayarlar'dan değiştirebilirsin."
- Düğme: **Devam** (seviye seçilene kadar pasif).

### 3.2 Sayfa 2: Konular (değişir)
- Başlık (dalda): **Hangi konuları öğrenmek istersin?**
- Alt metin (değişir): **Widget'ta ve Akış'ta seçtiğin konuların kelimeleri döner. Hiç seçmezsen hepsi gelir. Seçtiğin konuların yeni kelimeleri bitince widget ve Tekrar diğer konulardan devam eder.** (Dalın "yalnız seçtiğin konuların" vaadi mutlaktı, yedek kuralla çelişiyordu.)
- Liste (dalda): `TopicChoiceList`. "Tümü" satırı ("Bütün konular, N kelime", `topics.all`), altında `category.grp` başlıkları (Günlük hayat, Seyahat ve kültür, İnsanlar ve duygular, İş hayatı, Bilim ve teknoloji, Sanat ve eğlence, Dil kalıpları, Zengin kelimeler, Sınavlar) ve satırlar (`topics.<id>`, "nameTR" + "N kelime"). Sayı `card.primary_topic` ve ücretsiz, hassas olmayan kartlardan gelir. Boş ve 5 karttan küçük konular listelenmez (`AppModel.minimumTopicCards`).
- Seçim özeti **(yeni)**, düğmenin üstünde, yalnız en az bir konu seçiliyken: **Seçtiğin konularda 92 kelime var. Günde 10 yeni kelimeyle yaklaşık 10 günde biter, sonra diğer konulardan devam edilir.** Kelime sayısı seçilen konuların `cardCount` toplamı, gün sayısı `DeckFilter.estimatedDays`.
- Düğme (dalda): seçim yoksa **Tüm konularla devam**, varsa **3 konuyla devam**.
- Yükleniyor (`contentSource == .loading`): ortada `ProgressView` (dalda); düğme **pasif**, etiketi **Konular hazırlanıyor…** **(yeni)**. Sebep: dalda bu sırada basılan "Tüm konularla devam" `refreshWidgetPlan()`'ı içerik yüklenmeden çağırır, plan yazılmaz, `start()` de sonradan yazmaz (taze kurulumda ertelendiği için). "Atla" yükleme sırasında da çalışır.
- Veri yok (`.seed`, `.empty` ya da kategori listesi boş): **Konu listesi yok. Şimdilik bütün kelimeler gösterilecek.** (dalda). Düğme **Tüm konularla devam**, etkin. Sayfa gizlenmez, sayaç 4'lü kalır.

### 3.3 Sayfa 3: Widget rehberi (metinler değişir)
- Başlık (dalda): **Widget'ı ekle**
- Alt metin (dalda): **Kelimeler kilitli ekranda ve ana ekranda kendiliğinden değişir. Uygulamayı açmana gerek yok.**
- Seçici (dalda): `SegmentButtons` ile **Kilitli ekran** | **Ana ekran** (özel düğmeler, segmentli `Picker` değil; varsayılan Kilitli ekran).
- Kilitli ekran adımları (3, 4, 5, 6 değişir):
  1. "Yan düğmeye bas ve kilitli ekranı aç. Telefonun kilidi Face ID ya da parolayla açılmış olmalı."
  2. "Kilitli ekranda boş bir yeri basılı tut. Parola sorarsa gir."
  3. "Alttaki **Özelleştir**'e (Customize) dokun. Seçmeni isterse kilitli ekranı seç."
  4. "Saatin altındaki **Araç Takımı Ekle**'ye (Add Widgets) dokun."
  5. "Listede **Lockglow**'u bul ve dikdörtgen widget'a dokun. Tek satırlık widget için bunun yerine saatin üstündeki tarih satırına dokun."
  6. "**Bitti**'ye (Done) dokun."
- Ana ekran adımları (2, 4, 5 değişir):
  1. "Ana ekranda boş bir yeri basılı tut. Uygulamalar titremeye başlar."
  2. "Ekranın üstündeki **Düzenle**'ye (Edit), sonra **Araç Takımı Ekle**'ye (Add Widget) dokun."
  3. "Arama kutusuna **Lockglow** yaz ve ona dokun."
  4. "Boyutlar arasında kaydır (küçük ya da orta). İstediğin boyutta **Araç Takımı Ekle**'ye dokun."
  5. "Widget'ı istediğin yere taşı, sonra **Bitti**'ye (Done) dokun."
- Not (dalda, genişler): "iPhone'da widget'ın adı \"araç takımı\". Telefonun dili İngilizceyse parantezdeki adlara bak." Kilitli ekran: "Kilitli ekrandaki widget'ta düğme yok; kelime kendiliğinden değişir." Ana ekran: "Küçük ve orta boyda **Sonraki** ve **Biliyorum** düğmeleri var." (`ios/widget-ses` birleşince "ve hoparlör düğmesi".)
- Alt not (dalda): "Ekledikten sonra buraya dönebilirsin. Bu rehber Ayarlar > Yardım'da da var."
- Etiketlerin doğruluğu: Apple'ın Türkçe iPhone kılavuzu widget'a "araç takımı", düğmeye "Araç Takımı Ekle" der (kılavuzun iOS 15 sayfası ve arama özeti; kilitli ekran için İngilizce sayfada "Add Widgets"). Önceki taslaktaki "Widget Ekle" ve "Kilit Ekranı" bu yüzden bırakıldı. iOS 26'daki birebir yazım ve kilitli ekranda "Özelleştir"den sonra ekran seçtirilip seçtirilmediği telefonda **doğrulanmadı** (bölüm 8.4).

### 3.4 Sayfa 4: İlk kelime (hata durumu değişir)
- Başlık (dalda): **İlk kelimen**
- Alt metin (dalda): **Öğrenmeye bu kelimeyle başlıyorsun. Hoparlöre dokunup dinleyebilirsin.**
- İçerik: `WordCardView(word:detail:)`, kelime `model.firstDeckWord()`. Telaffuz birleşince `showsPractice: false` ile çağrılır (bölüm 5.5).
- Düğme: **Başla**.
- Yükleniyor (`.loading`): "Kelimeler yükleniyor..." (dalda).
- Hata **(yeni)**: yükleme bitti ve kelime yok (`.empty`): **Kelimeler yüklenemedi. Uygulamayı kapatıp yeniden aç. Sorun sürerse Ayarlar > Tanılama'ya bak.** Dalda bu durumda "yükleniyor" yazısı sonsuza kadar kalıyordu. **Başla** etkin kalır.

### 3.5 Ayarlar (dalda, küçük değişiklik)
- `deckSection`, başlık **Öğrenme**: `Picker("Başlangıç seviyesi")` (A1, A2, B1; `startLevel` yoksa A1 görünür, sıra aynı olduğu için kabul), `NavigationLink` **Konular** (`TopicPickerView`, değer "Tümü" ya da "3 konu"). Altbilgi (dalda, "yalnız" kaldırılır): "Yeni kelimeler bu seviyeden başlar. Widget'ta, Akış'ta ve yeni kelimelerde seçtiğin konular döner (şu an N kelime). Değiştirince widget'taki kelime bir sonraki değişime kadar aynı kalır." Eklenir **(yeni)**, yalnız `newWordsComeFromAllTopics` iken: "Seçtiğin konuların yeni kelimeleri bitti; yeni kelimeler diğer konulardan geliyor."
- `helpSection`, başlık **Yardım**: **Widget nasıl eklenir?** (`WidgetGuideScreen`) ve **Açılış ekranlarını yeniden göster** (`model.showOnboarding()`).
- `TopicPickerView` açıklaması ve seçim özeti aynı metinlerle (bölüm 3.2).

### 3.6 Durum tablosu

| Durum | Davranış |
|---|---|
| İçerik yükleniyor | Sayfa 1 ve 3 çalışır; sayfa 2'de spinner ve pasif düğme; sayfa 4 "Kelimeler yükleniyor..." |
| Seed ya da boş içerik | Sayfa 2 "Konu listesi yok" ile geçilir; seviye sırası seed'de de çalışır (`levelValue`); `.empty` ise sayfa 4 hata metni |
| Tur açıkken deep link | `RootView.handle(_:)` `selectedTab = .feed` ayarlar, tur kalır, bitince kullanıcı Akış'ta o karttadır |
| Eski kullanıcı | Tur açılmaz, bayrak yazılır |
| Seçilen konular bitti | Widget, Tekrar ve hatırlatma tüm konulara düşer; Akış seçilen konuları göstermeye devam eder, Ayarlar altbilgisi söyler |

## 4. Veri ve durum

Anahtarlar (`AppPreferences`, `UserDefaults.standard`, `lockglow.` öneki, **dalda tanımlı**):

| Anahtar | Tür | Değerler | Varsayılan / okuma kuralı |
|---|---|---|---|
| `lockglow.onboardingCompleted` | Bool | `true`: bitti ya da atlandı | Yok = tur gösterilir; ama bkz. aşağıdaki çözümleme |
| `lockglow.selectedTopicIDs` | [String] | `category.id` listesi | Boş = tüm konular |
| `lockglow.startLevel` | String | `Level.rawValue`: "A1", "A2", "B1" (büyük harf) | Yok ya da geçersiz = `nil` = A1 sırası |

Anahtar adı ve değer biçimi tek yerde sabittir: yukarıdaki tablo. İlk taslaktaki `onboardingState`, `onboardingStep`, küçük harfli `a1` ve `unsure` **kaldırıldı**.

**Durum çözümleme (yeni, `AppModel` oluşurken, ilk karenin önünde, senkron).**
1. `stored` = `AppPreferences.onboardingCompletedStored` **(yeni, `Bool?`)**: `object(forKey:) == nil ? nil : bool(forKey:)`. `as? Bool` kullanılmaz, çünkü başlatma argümanıyla gelen değer metin ("YES") olarak gelir.
2. `stored` varsa karar `!stored`.
3. Yoksa: `AppGroupStore(containerURL:).readPlan() != nil` ise tur açılmaz ve `onboardingCompleted = true` hemen yazılır; plan yoksa tur açılır.
4. Karar `OnboardingGate.shouldShow(storedCompleted:hasWidgetPlan:)` içindedir (bölüm 5.1).

Neden tek kanıt, plan dosyası: önceki her sürüm `start()` içinde plan yazıyor, taze kurulumda ise o anda plan yok (ilk planı artık seçim yazıyor). Ayar anahtarı ve `progress.json` kanıtları bilerek kaldırıldı: plan yazılmadan bunlar tek başına oluşmaz. App Group erişilemiyorsa (`store == nil`) kanıt yoktur, tur açılır; widget zaten çalışmayacağı için sorun değil.

**Geçiş.** Sahibin TestFlight güncellemesi: plan var, tur açılmaz, seviye `nil` (akış sırası aynı), konu boş. `resetProgress()` bu anahtarlara dokunmaz (ilerleme değil tercih).

**App Group'a yazılan.** Yeni dosya yok. `widget_plan.json` zaten yazılıyor; taze kurulumda ilk yazım zamanı ve içindeki sıra seçime göre değişir. `WidgetWord`, `WidgetPlan`, `seed_words.json` sözleşmesi değişmez.

## 5. Kod değişiklikleri

### 5.0 Dalda hazır olanlar (dokunulmaz)
- VocabKit: `CoreModels/ContentTopic.swift`, `Learning/DeckFilter.swift` (`DeckChoice`, `DeckFilter.feed`, `filtered`, `ordered`), `QueueComposer.compose(deck:fallbackFeed:...pinFirst:)`, `ReminderPlanner.plan(feed:newWordFeed:...)`, `ContentStore.topics()` ve `primaryTopicByCard()`, testler (`DeckFilterTests`, `QueueComposerTests`, `ReminderPlannerTests`, `ContentStoreTests`), `Tools/linux-stubs/ContentStore/ContentStore.swift`.
- App: `AppModel` (`words` = tüm kelimeler, `feedWords` = deste, `topics`, `deckChoice`, `showsOnboarding`, `minimumTopicCards`, `choosableTopics`, `activeTopicIDs`, `setDeckChoice`, `setSelectedTopics`, `setStartLevel`, `rebuildFeed()`, `showOnboarding()`, `finishOnboarding()`, `firstDeckWord()`), `AppPreferences` (`startLevelChoices`, `onboardingCompleted`, `selectedTopicIDs`, `startLevel`), `ContentLoader` (`LoadedContent.topics`, `topicOf`), `RootView`, `FeedView` (`model.feedWords`), `SettingsView` (`deckSection`, `helpSection`), `OnboardingView`, `TopicPickerView` (`TopicChoiceList`, `TopicGroup`), `WidgetGuideView` (`WidgetGuideContent`, `WidgetGuideScreen`), `GlowStyle` (`Palette`, `GlowButtonStyle`, `ChoiceRow`, `SegmentButtons`).
- `words` tüm kelimeleri tutar (Sözlük, sayımlar, bildiğim kelimeler, zamanı gelen tekrarlar). Konu süzgeci ve seviye sırası yalnızca `feedWords`tedir. İlk taslağın "`words` süzülür ve sıralanır" varsayımı bu yüzden **geçersizdir**.

### 5.1 VocabKit (Linux'ta test edilir, Apple çerçevesi yok)
- `Learning/OnboardingGate.swift` **(yeni)**:
  ```swift
  public enum OnboardingGate {
      /// stored: the saved flag (nil = never written). Without a flag, a widget plan means an existing install.
      public static func shouldShow(storedCompleted: Bool?, hasWidgetPlan: Bool) -> Bool
  }
  ```
  Kural: `stored` varsa `!stored`; yoksa `!hasWidgetPlan`.
- `Learning/DeckFilter.swift` (dalda var, üç ekleme, hepsi **yeni**):
  - `static func hasNewWords(_ deck: [WidgetWord], progress: [Int: WordProgress]) -> Bool`: desteden en az biri hiç çalışılmamış (`progress[id]?.state ?? .new == .new`).
  - `static func newWordFeed(deck: [WidgetWord], fallback: [WidgetWord], progress: [Int: WordProgress]) -> [WidgetWord]`: `hasNewWords` ise `deck`, değilse `fallback`.
  - `static func estimatedDays(wordCount: Int, dailyNewWords: Int) -> Int`: `ceil(wordCount / dailyNewWords)`, girdiler 0 ya da eksiyse 0.
- **Faz 2, koşullu ([U1] "evet" derse):** `DeckFilter.ordered(_:startingAt:lowerEvery: Int? = nil)` **(yeni parametre, varsayılan `nil` = bugünkü davranış)**. Doluysa: başlangıç seviyesi ve üstü akımından `lowerEvery` kelime, sonra alt akımdan (yakından uzağa) 1 kelime; biri bitince diğeri boşaltılır; sonuç girdinin permütasyonudur, seviye içi sıra korunur. Ayrı `LevelPath` türü **açılmaz**, ikinci bir sıralama yolu olmasın.

### 5.2 `ios/App/AppPreferences.swift` (Linux AppLogic dosyası)
`static var onboardingCompletedStored: Bool?` **(yeni)**, salt okunur. Diğer erişimciler dalda.

### 5.3 `ios/App/AppModel.swift`
- `static func shouldShowOnboardingAtLaunch() -> Bool` **(yeni)**: `AppGroupLocator.containerURL()` ile `AppGroupStore.readPlan()`, `OnboardingGate.shouldShow`; sonuç false ve bayrak yoksa `AppPreferences.onboardingCompleted = true` yazar. `showsOnboarding` başlangıç değeri `!AppPreferences.onboardingCompleted` yerine bunu kullanır. Bu çağrı `start()`'tan önce çalışır, böylece `start()`'ın yazacağı plan kararı bozmaz.
- `private(set) var allTopicsFeed: [WidgetWord]` **(yeni)**: `DeckFilter.ordered(words, startingAt: deckChoice.startLevel)`. `rebuildFeed()` bunu da kurar. `refreshWidgetPlan()` içindeki `fallbackFeed:` argümanı bunu kullanır (her plan yazımında yeniden sıralamaz).
- `private var newWordFeed: [WidgetWord]` **(yeni)**: `DeckFilter.newWordFeed(deck: feedWords, fallback: allTopicsFeed, progress: progress)`. `nextReviewSession(extraNew:now:)` (`ReviewPlanner.newWords(feed: newWordFeed, ...)`) ve `reminderPlan` (`newWordFeed:` argümanı) bunu kullanır. `firstDeckWord()` değişmez.
- `var newWordsComeFromAllTopics: Bool` **(yeni)**: `!DeckFilter.hasNewWords(feedWords, progress: progress) && feedWords.count < allTopicsFeed.count`.
- `refreshWidgetPlan()`: `pinFirst: currentWord` **değişmez**. Süreklilik değişmezi korunur (`ios/README.md` "Dönüşüm sürekli", satır 65, ve "Plan yeniden yazma", satır 71).
- `start()` değişmez (ilk planı erteleme mantığı dalda).

### 5.4 `ios/App/RootView.swift`
Değişmez. Dal `.fullScreenCover(isPresented: onboardingBinding)` kullanıyor; ilk taslağın `ZStack` katmanı **uygulanmaz**.

### 5.5 Görünümler
- `OnboardingView.swift`: (a) `bottomBar` `.disabled(...)`: `page == .level && level == nil` **veya** `page == .topics && model.contentSource == .loading`; `primaryTitle` bu durumda "Konular hazırlanıyor…". (b) `topicsPage` alt metni (bölüm 3.2) ve `bottomBar` üstüne seçim özeti. (c) `firstWordPage` else dalı: `contentSource == .loading` ise "Kelimeler yükleniyor...", değilse hata metni. (d) `WordCardView(word:detail:showsPractice: false)`.
- `TopicPickerView.swift`: açıklama metni, `TopicSelectionSummary(topics:selection:dailyNewWords:)` **(yeni küçük görünüm)**; turda ve Ayarlar'da aynı özet.
- `WidgetGuideView.swift`: `steps` ve `note` metinleri bölüm 3.3'e göre.
- `FeedView.swift`, `WordCardView`: `var showsPractice = true` **(yeni)**. `ios/telaffuz` birleşince `SayButton(word:example:)` bu koşula bağlanır (bölüm 9).
- `SettingsView.swift`: `deckSection` altbilgisi (bölüm 3.5).

### 5.6 `ios/App/PrivacyInfo.xcprivacy`
Ayrı commit, bölüm 7.

### 5.7 `ios/UITests/LockglowScreenshotTests.swift`
Bölüm 8.2.

### 5.8 Dokunulmayanlar
`project.yml`, `Info.plist`, `Speaker.swift`, `ReviewView.swift`, `QuizCardView.swift`, `Leitner.swift`, `Widgets/*`, `screenshots.yml`. `Tools/linux_check_prepare.py` içindeki `APP_LOGIC_FILES` (`AppModel.swift`, `AppPreferences.swift`, `ContentLoader.swift`, `ReviewSession.swift`, `WidgetHealth.swift`) değişmez: yeni görünüm dosyası yok, yeni mantık `Learning` içinde.

## 6. Widget etkisi
- Widget kodu, `WidgetWord`, `WidgetPlan`, `seed_words.json`, kind (`WordWidget.kind = "WordWidget"`, galeri adı "Kelime") değişmez.
- Taze kurulumda `start()` planı yazmaz; ilk planı sayfa 2'den çıkış (`applyChoice` → `setDeckChoice` → `refreshWidgetPlan`) ya da Atla/bitiş yazar. O an eski plan olmadığı için `pinFirst` yoktur, kuyruk destenin ilk kelimesiyle başlar. Planın ilk kelimesi, Akış'ın ilk kartı ve 4. sayfadaki kelime aynıdır (taze kullanıcıda ilerleme yok; `QueueComposer.swift:104-106`: sıra 0 yuvası review, liste boşsa new).
- Kullanıcı sayfa 1'de uygulamadan çıkarsa `sceneDidEnterBackground` planı seçimsiz yazar. Seçim sonra gelince `pinFirst` görünen kelimeyi korur, yeni kelimeler bir sonraki sınırdan itibaren seçime göre gelir. Dal bunu bilerek kabul ediyor, süreklilik değişmezi bozulmaz. İlk taslağın "turda `pinFirst: nil`" kuralı **kaldırıldı**: değişmezi bozuyordu ve onu açıp kapatmak için ayrı bir durum alanı gerektiriyordu.
- Ayarlar'dan seviye ya da konu değişince görünen kelime aynı kalır.
- Seçim küçükse ya da bittiyse widget `fallbackFeed`'e düşer (dalda). Tekrar ve hatırlatma aynı kuralı `newWordFeed` ile izler (bu plan).
- Seed'den gerçek içeriğe sıçrama (`ios/README.md` madde 25) etkilenmez: ilk plan içerik yüklendikten sonra yazılır.
- Kilitli ekran: `accessoryRectangular` saatin altındaki alana, `accessoryInline` saatin üstündeki tarih satırına eklenir (`WordWidget.supportedFamilies`). Kilitli ekran widget'larında düğme yok. Ana ekranda düğmeler yalnızca küçük ve orta boyda (`HomeWordViews.swift:41,43,104,105`).
- README kontrol listesi "Uygulama açılmadan ekleme" tohum kelimelerin görüneceğini söylüyor; Apple'a göre galeri girişi uygulamanın bir kez açılmasına bağlı olabilir. Temiz kurulumda bakılır, rehber uygulama içinde olduğu için tur akışı etkilenmez.
- `ios/widget-ses` ana ekran widget'ına hoparlör düğmesi ekler; rehberin ana ekran notu birleşince güncellenir.

## 7. İzinler, gizlilik ve yasal metinler
- **Info.plist, project.yml:** tur yeni anahtar eklemez. Bildirim, mikrofon ve konuşma izni **istenmez**. (`ios/telaffuz` dalı mikrofon ve konuşma tanıma anahtarlarını ekler; izin yalnızca "Söyle" alıştırmasında kayıt başlayınca istenir: `PronunciationRecognizer.prepare`. Tur o düğmeyi göstermez, bölüm 5.5.)
- **PrivacyInfo.xcprivacy (düzeltme):** İlk taslak "değişmez" diyordu, yanlış. `Learning/ProgressStore.swift` dosya zaman damgası okuyor ve yazıyor (`:124` `setAttributes([.modificationDate: now]...)`, `:162-164` `attributesOfItem(atPath:)[.modificationDate]`). `Learning` uygulamaya bağlı, manifest ise yalnızca `NSPrivacyAccessedAPICategoryUserDefaults` (`CA92.1`) bildiriyor. Apple bu API'yi "file timestamp" kategorisinde sayar, eksiklik App Store Connect'te "missing API declaration" uyarısına yol açabilir. Ayrı commit: `NSPrivacyAccessedAPICategoryFileTimestamp` + `C617.1` (uygulamanın kendi konteynerindeki dosyalar) eklenir. Widget manifesti boş kalır (`modificationDate` ve `attributesOfItem` yalnızca `ProgressStore`'da, widget `Learning` bağlamaz; `ios` altında arama ile doğrulandı). Archive > Privacy Report ile teyit (`ios/README.md` madde 20). Bu açık açılış akışından bağımsızdır ve tur beklemeden yapılabilir.
- **Yeni UserDefaults anahtarları:** `CA92.1` kapsamında.
- **App Store gizlilik etiketi:** değişmez. Seviye, konu ve bayrak cihazdan çıkmaz, "toplanmıyor" sayılır (`docs/legal/app_store_privacy_etiketi.md:24`).
- **docs/legal:** bu özellik için güncelleme gerekmez. "İzin yalnızca kullanım anında" taahhüdü (`gizlilik_politikasi_tr.md:93`) tur izin istemediği için sürer. Telaffuz dalı bu dosyaları kendi işi için zaten değiştiriyor.
- **İleride:** analitik rızası eklenirse "onboarding'in başında" olmalı (`acik_riza_metni_analitik_tr.md:126`). Bu 5. ekran olur, 4 sayfa sınırı bozulur; o zaman yeniden karar ([U5]).
- **App Review:** tur atlanabilir, hesap ve ödeme yok, rehber yalnızca kendi uygulamamızı anlatır (HIG onboarding ilkeleri).

## 8. Testler

### 8.1 Linux, VocabKit birim testleri (`ios/Packages/VocabKit/Tests/LearningTests/`)
Mevcut `DeckFilterTests` (seviye sırası, konu süzgeci, bileşik durum) dalda var. Eklenecekler:
- `DeckFilterTests` **(yeni testler)**: `hasNewWords` (çalışılmamış var, hepsi bilinen ya da öğrenilen, boş deste); `newWordFeed` (yeni kelime varken deste, bitince yedek, ikisi de boşken boş); `estimatedDays` (92 kelime ve 10 hedef = 10, 5 ve 10 = 1, 0 = 0, hedef 0 = 0).
- `OnboardingGateTests.swift` **(yeni)**: bayrak `true` ise plan olsa da olmasa da false; bayrak `false` ise plan olsa bile true; bayrak yok + plan var = false; bayrak yok + plan yok = true.
- Faz 2 yapılırsa `ordered(lowerEvery:)` için: A2 ve 4 ile ilk 10 `[A2,A2,A2,A2,A1,A2,A2,A2,A2,A1]`, permütasyon özelliği, boş girdi, `nil` ile bugünkü sıra.

**Çalıştırma (düzeltme).** Bu PC'de Docker yok (`DEVIR.md`), `ios/Tools/linux_check.sh` burada çalışmaz. `build.yml` de bunu **çağırmaz**: `ios` işi yalnızca `workflow_dispatch` ile çalışır ve macOS'ta `swift test` ile tam derleme yapar (macOS dakikası 10 kat sayılır). Yol: 5.1 ve 5.3 değişikliklerini tek push'ta topla, `gh workflow run build.yml -R yusufuyar68/lockglow --ref <dal>` ile **bir kez** çalıştır. Docker'lı bir makine varsa önce orada `bash ios/Tools/linux_check.sh`.

### 8.2 UI testleri ve screenshots.yml
- `testCaptureMainScreens`: `-lockglow.onboardingCompleted YES` (dalda). `startLevel` ve `selectedTopicIDs` önceki koşudan kalsa da A1 ve hepsi seçildiği için ilk kart "breakfast" kalır.
- `testCaptureOnboarding` (dalda): `NO` ile açar, `onboarding.level.A1`, `onboarding.next`, `topics.all`, `onboarding.next`, "Ana ekran" düğmesi (**etiketle**: `app.buttons["Ana ekran"]`; `SegmentButtons` segmentli `Picker` değil, normal düğmeler), `onboarding.next`, ilk kelime "breakfast", `onboarding.start`, "Akış" sekmesi. Ekran görüntüleri `0a`-`0e`.
- Eklenecek **(yeni)**: `testSkipOnboarding`: `NO` ile aç, `onboarding.skip`, `app.tabBars.buttons["Akış"]` görünsün (seviye seçilmeden Atla).
- Eklenecek, yalnız telaffuz birleşince: ilk kelime sayfasında `app.buttons["Söyle: telaffuzunu dene"].exists == false`.
- Sistem izin penceresi çıkmaz, `addUIInterruptionMonitor` gerekmez.
- `screenshots.yml` değişmez: `-only-testing:LockglowUITests` yeni testi de alır, 40 dk sınırı içinde. El ile `gh workflow run screenshots.yml` ile tetiklenir.
- Argüman davranışı (`-lockglow.onboardingCompleted YES`) Foundation'ın argüman alanı kuralına dayanır, repoda henüz bir CI koşusuyla doğrulanmadı (R1).

### 8.3 Mevcut testlerin korunması
Atlama argümanıyla `1-akis` ... `10-geri-alindi` akışı bugünkü gibi çalışır. Dal, Ayarlar'da "Bildiğim kelime" satırı için küçük ekranda `swipeUp` ekledi (yeni "Öğrenme" bölümü yüzünden).

### 8.4 Telefonda elle kontrol listesi
- [ ] Temiz kurulum: tur açılır, 4 sayfa akıcı, Geri ve Atla doğru, seviye seçmeden Devam pasif.
- [ ] Sayfa 2'de içerik yüklenirken düğme pasif, yükleme bitince "Tüm konularla devam" olur.
- [ ] Konu seç: özet satırı kelime ve gün sayısını gösterir, sayı seçimle değişir.
- [ ] Sayfa 3'te uygulamadan çık, widget ekle, geri dön: aynı sayfada devam, widget ilk kelimeyle dolu.
- [ ] Rehberdeki Türkçe ve İngilizce etiketler iOS 26 arayüzüyle birebir mi (Özelleştir/Customize, Araç Takımı Ekle/Add Widgets ve Add Widget, Düzenle/Edit, Bitti/Done)? Kilitli ekranda "Özelleştir"den sonra ekran seçtiriyor mu? Dikdörtgen ve tek satırlık widget için dokunulacak yer doğru mu? Gerekirse metni düzelt.
- [ ] Tur ortasında uygulamayı kapat ve aç: tur baştan, 2. sayfadan çıkıldıysa seçim önceden seçili.
- [ ] TestFlight güncellemesi (mevcut sürümün üstüne): tur **görünmez**, Akış sırası aynı. Ayarlar > Yardım > "Açılış ekranlarını yeniden göster" çalışır, şimdiki seçim seçili gelir.
- [ ] Seviyeyi A2 yap: Akış A2 kartlarıyla başlar; B1 için aynı. Ayarlar'da değiştirince widget'taki görünen kelime sabit kalır.
- [ ] Küçük bir konu seç ve günlük hedefi 20 yap: yeni kelimeler bitince Tekrar ve widget diğer konulardan devam eder, Ayarlar altbilgisi bunu söyler.
- [ ] Atla her sayfada çalışır; sayfa 1'de atlayınca seviye seçilmemiş kalır, sıra A1'den.
- [ ] VoiceOver, en büyük Dynamic Type, Reduce Motion, koyu mod, iPhone SE boyutu.
- [ ] Uçak modu: tur tamamen çevrimdışı çalışır. Hiçbir izin penceresi çıkmaz.

## 9. Diğer dallarla çakışma ve uygulama sırası
- **`ios/acilis-deste` (taban):** main'den ayrıldıktan sonra main ilerledi (d99180e: s13 içeriği, CI makine seçimi, Zor/Kolay). Birleştirmeden önce `git merge main` ve `build.yml` koşusu. `ios/README.md`: dalın madde 46'sı, `ios/widget-ses` madde 45'i ve bu plan aynı bölgeye yazar; numaralar korunur (45, 46), metin çakışması el ile çözülür. Bu plan yeni numara açmaz, madde 46 altına ve "Açılış akışı" maddesine ekler. Karar bekleyen soru: [U0].
- **`ios/zor-kolay`:** main'e birleşti (315787f, README madde 44 main'de). Önkoşul yok. Zor/Kolay `ReviewView` ve `QuizCardView`'a dokunur; bu plan onlara dokunmaz. Yalnızca `nextReviewSession` içindeki `ReviewPlanner.newWords` satırı dalla ortak (bölüm 5.3).
- **`ios/widget-ses`:** `HomeWordViews.swift`, `WidgetButtons.swift`, `WordWidget.swift`, `Speaker.swift`, `Shared/*`, `project.yml`. Onboarding dosyalarıyla kod çakışması yok. Birleşince rehberin ana ekran notuna hoparlör eklenir.
- **`ios/telaffuz`:** `FeedView.swift` (`WordCardView`'e `SayButton`), `SearchView.swift`, `project.yml` (`Pronunciation` ürünü, mikrofon ve konuşma izin metinleri), `docs/legal/*`, `ios/README.md`. `FeedView.swift` acilis-deste ile de değişiyor (`model.feedWords`), metin çakışması olası. Ikinci birleşen `WordCardView.showsPractice` parametresini bağlar: turda `SayButton` yok. Çünkü tur kartında mikrofon düğmesi olursa dokunuşta mikrofon ve konuşma izni (iOS 26'da Apple'ın İngilizce konuşma modelinin indirilmesi) turun içinde yaşanır. İzin penceresi yalnızca düğmeye dokununca çıkar, yine de turun "izin istemez" garantisi için gizlenir.
- **Arayüz taslağı (`tasarim/arayuz-mockup`, `docs/tasarim`):** açılış ekranı yok. `GlowStyle.swift` mockup renklerini kodda çoğaltıyor (README madde 46: Asset Catalog'a taşınmalı). Taşırken onboarding ve konu görünümleri aynı jetonlarla güncellenir. Mockup'a açılış ekranları eklenmesi öneri olarak mockup sahibine bırakılır.
- **İçerik setleri (s10-s13):** yeni kartlar `ContentStore.topics()` sayesinde konu listesine kendiliğinden girer, 5 karttan küçük konular listelenmez. Bugünkü DB'de (753 kart, `primary_topic`'e göre) 25 kategori dolu, 35 boş; 23'ü ≥5 kartlı; 11'i 20 kartın altında (örn. `nature_animals` 8, `workplace_office` 12). Birleştikçe büyür. `content.sqlite` derlemesi ve `id_registry.json` bu planın işi değil.
- **Uygulama sırası:** bölüm 11.

## 10. Riskler ve açık sorular

**Riskler**
- **R1. Argüman alanı:** `-lockglow.onboardingCompleted YES` argümanının `UserDefaults.standard` okumasını geçersiz kılması Foundation davranışıdır, CI'da henüz doğrulanmadı (dalın README'si ekranlara simülatörde bakılmadığını söylüyor). Argümanla verilen anahtar aynı koşuda yazılsa da okuma argüman değerini döndürür; kod başlangıçta bir kez okur. Yedek: `ProcessInfo.processInfo.arguments.contains("-lockglow-skip-onboarding")`.
- **R2. Sunum:** `.fullScreenCover` ilk açılışta alttan kayar, `.task { start() }` altta çalışır. Sekmelerin üstünde doğru açıldığı simülatörde bakılmadı (README madde 46).
- **R3. Yanlış tespit:** yeni kullanıcıya turu göstermemek mümkün değil (taze kurulumda plan yok). Eski kullanıcıya göstermek: App Group erişilemezse ya da plan hiç yazılmadıysa. Kabul, etkisi bir "Atla" dokunuşu.
- **R4. Rehber doğruluğu:** Türkçe adlar Apple'ın iOS 15 sayfasından ve aramadan; iOS 26 ve İngilizce etiketler telefonda doğrulanacak. Metinler tek yerde (`WidgetGuideContent.steps`), kolay düzeltilir.
- **R5. Süreklilik:** seçimden sonra görünen widget kelimesi bir sonraki sınıra kadar eski kalır (dalın bilinçli tasarımı).
- **R6. Küçük havuz:** az kelimelik konu seçilirse havuz hızla biter. Önlemler: özet satırı, widget ve Tekrar'da yedek kural. Akış seçilen konuları göstermeye devam eder.
- **R7. Palet kodda:** `GlowStyle.swift` taslağın renklerini tekrarlıyor; asset'e taşınırken iki yerde değişiklik olmasın.
- **R8. Bildirim isteği (karar):** turda ve bu planda yok. Reddedilirse geri dönüş yalnızca iPhone Ayarları'dır, kullanıcı değer görmeden istemek ret ihtimalini artırır, ilk gün tekrar edilecek kelime yoktur, CI'da sistem penceresi UI testini bloklar. Ayarlar'daki "Günlük hatırlatma" anahtarı kalır ([U3]).
- **R9. Telaffuz birleşmesi:** `SayButton` turda görünürse izin garantisi bozulur; birleşme sırası bölüm 9'da.
- **R10. Doğrulama yolu:** `AppModel` ve `AppPreferences` değişiklikleri en riskli kod, ücretsiz Linux denetimi bu PC'de yok. Tek push ve tek `build.yml` koşusu (bölüm 8.1).

**Kullanıcıya sorulacaklar**
- **[U0] (engelleyici)** `ios/acilis-deste` bu planın tabanı olsun mu (önerim: evet, önce o dal telefonda denensin ve main'e birleşsin; bu plan onun farkıdır)? Dalı bırakıp işi sıfırdan yazmak istersen ilk taslak yeniden yazılmalı (git geçmişinde yok, bu planın §5'i geçersiz olur).
- **[U1]** Seviye sırası dalın biçiminde mi kalsın (A2 seçen A1'i en sona alır) yoksa alt seviyeden serpiştirme (A2: her 4 kelimeden sonra 1 A1) eklensin mi? Önerim: önce dalın sırası, 1-2 hafta kullanınca karar.
- **[U2]** Seviye sayfasında "Emin değilim" gerekli mi? Önerim: hayır, Atla seviyeyi yazmıyor (A1 sırası).
- **[U3]** Bildirim isteği hiç eklenmesin mi, yoksa ilk Tekrar turundan sonra tek seferlik kart olarak ayrı iş olarak mı?
- **[U4]** Sahibin cihazında turu bir kez görmek ister misin? Varsayılan: görmez (plan var). Görmek için Ayarlar > Yardım > "Açılış ekranlarını yeniden göster".
- **[U5]** Analitik rızası eklenecekse turun ilk sayfası mı, tur öncesi ayrı kapı mı? (Şimdilik kapsam dışı.)
- **[U6]** Ayarlar'daki etiket "Başlangıç seviyesi" (dal) kalsın mı?

## 11. İş adımları

Her adım ayrı commit, `ios/acilis-deste` üzerinden açılmış dalda. Başlamadan `git diff main...origin/ios/acilis-deste`, `...origin/ios/widget-ses`, `...origin/ios/telaffuz` ile uçların hareketini kontrol et.

- [ ] **0. Taban ([U0]):** dalı main'in üstüne getir (`git merge main`), `gh workflow run build.yml -R yusufuyar68/lockglow --ref ios/acilis-deste` yeşil mi bak, README madde 46 listesiyle telefonda dene. Doğrulama: CI yeşil, 151 paket testi geçti.
- [ ] **1. VocabKit:** `OnboardingGate`, `DeckFilter.hasNewWords`, `newWordFeed`, `estimatedDays` ve testleri (bölüm 8.1). Doğrulama: testler yazıldı; çalıştırma adım 4'te (bu PC'de Docker yok).
- [ ] **2. `AppPreferences.onboardingCompletedStored`, `AppModel` değişiklikleri** (`shouldShowOnboardingAtLaunch`, `allTopicsFeed`, `newWordFeed`, `newWordsComeFromAllTopics`). Doğrulama: dalın `testCaptureMainScreens` akışı etkilenmez (kod incelemesi); çalıştırma adım 4'te.
- [ ] **3. Görünümler:** `OnboardingView`, `TopicPickerView` (`TopicSelectionSummary`), `WidgetGuideView` metinleri, `WordCardView.showsPractice`, `SettingsView` altbilgisi; `testSkipOnboarding`. Doğrulama: kod incelemesi, metinler bölüm 3 ile birebir.
- [ ] **4. Doğrulama turu:** adım 1-3'ü tek push'la gönder, `gh workflow run build.yml -R yusufuyar68/lockglow --ref <dal>` bir kez, sonra `gh workflow run screenshots.yml`. Doğrulama: `swift test` yeşil, derleme uyarısız, artifact'ta `0a`-`0e` görüntüleri, SE'de metin taşmıyor.
- [ ] **5. Gizlilik manifesti (bağımsız, istenirse 1'den önce):** `ios/App/PrivacyInfo.xcprivacy`'ye `NSPrivacyAccessedAPICategoryFileTimestamp` + `C617.1`. Doğrulama: derleme geçer, Archive > Privacy Report uyarı vermez (TestFlight yüklemesinde).
- [ ] **6. Belgeler:** `ios/README.md` madde 46 ve "Açılış akışı" maddesine bölüm 4 anahtarları, tur kuralları, kontrol listesi (bölüm 8.4); numarasız yeni madde açma. `DEVIR.md`'ye kısa not. Doğrulama: README listesi bölüm 8.4 ile aynı.
- [ ] **7. Telefon kontrolü:** bölüm 8.4'ün tamamı. Bulunanlar (özellikle Türkçe ve İngilizce etiketler) metin verisine işlenir.
- [ ] **8. Birleşme sonrası (telaffuz):** `SayButton`'ı `showsPractice`'e bağla, UI testine "Söyle yok" kontrolünü ekle. **widget-ses sonrası:** rehberin ana ekran notuna hoparlör. Doğrulama: `build.yml` ve `screenshots.yml`.
- [ ] **9. Koşullu ([U1] "evet"):** `DeckFilter.ordered(lowerEvery:)`, `AppModel.rebuildFeed()` ve `allTopicsFeed` bu parametreyi geçirir, testler, Ayarlar altbilgisi. Doğrulama: A2 seçince Akış'ta 4 kelimede 1 A1.

## 12. Denetim notları

İlk taslağa gelen 17 itiraz, her biri kod, belge ya da veritabanında kendim doğrulandıktan sonra işlendi. Düzeltmelerin çoğu aynı kök nedene bağlıydı: taslak, `ios/acilis-deste` dalını bilmiyordu.

1. [blocker, kod] Aynı özellik `ios/acilis-deste` dalında zaten var: **düzeltildi.** Doğrulandı (22 dosya, 3 commit). Not: itirazdaki "commit edilmemiş" yanlış, dal commit'li ve `origin`'de (`git log main..origin/ios/acilis-deste`), işlem düzeltildi: spec dalın farkı olarak yeniden yazıldı, anahtar adları ve `startLevel` biçimi dalınkine sabitlendi, `LevelPath` düşürüldü, D1-D5 varsayımları gerçek API'lere çevrildi.
2. [major, kod] Konular adımı yüklenirken hem görünür hem gizli: **düzeltildi.** Dal sayfayı her zaman gösteriyor (4 sabit sayfa); ayrıca dalda yükleme sırasında basılan Devam planı yazdırmıyordu, düğme yükleme bitene kadar pasif yapıldı. Kalıcı adım ve `clampStep` kaldırıldı.
3. [major, kod] `pinFirst`/`pending` kuralı ile katman arasındaki sıralama hatası: **düzeltildi.** Kural ve `pending` durumu planda yok; ilk planı seçim yazıyor (dalda), UI test argümanı dalda katmanla aynı commit'te.
4. [minor, kod] Turda `pinFirst: nil` süreklilik değişmezini bozuyor: **düzeltildi.** Kural kaldırıldı, `pinFirst` aynen kalır (`ios/README.md:65,71` doğrulandı; itirazdaki 63 numarası satır kaymasıydı).
5. [minor, kod] Segmentli `Picker` segmentlerine kimlik verilemez: **düzeltildi.** Dal özel `SegmentButtons` kullanıyor; test düğmeyi etiketle seçiyor (`app.buttons["Ana ekran"]`).
6. [minor, kod] Bayat taban: **düzeltildi.** `main` d99180e, `ios/zor-kolay` birleşti (315787f, README madde 44 main'de), Faz 2 önkoşulu kalktı, README notu yalnızca `ios/widget-ses` (45) ve dal (46) için, `QueueComposer.swift` atfı 104-106 olarak düzeltildi.
7. [minor, kod] "Widget Ekle" düğme adı: **düzeltildi.** Apple'ın Türkçe kılavuzu "araç takımı" ve "Araç Takımı Ekle" diyor (arama özeti ile doğrulandı), dal zaten bunu kullanıyor. Kilitli ekranda `accessoryInline` ve `accessoryRectangular` ayrımı `WordWidget.supportedFamilies` ile doğrulanıp rehbere eklendi.
8. [minor, kod] Adım 3 doğrulaması bu PC'de ve "CI'da" çalışmıyor: **düzeltildi.** `build.yml` `linux_check.sh` çağırmıyor, `ios` işi yalnızca `workflow_dispatch` (doğrulandı); yol tek push ve tek `gh workflow run build.yml` olarak yazıldı.
9. [blocker, ürün] Dal ve bayat taban: **düzeltildi** (madde 1 ile aynı kök). Çakışma listesi doğrulandı: `lockglow.startLevel` biçimi, `onboardingCompleted` Bool, `.fullScreenCover`, `DeckFilter.ordered` sırası, `words`/`feedWords`, `0a`-`0e` ekran görüntüleri.
10. [major, ürün] `words` hem süzülmüş hem tam liste: **düzeltildi.** `words` tüm kelimeler, `feedWords` deste. Doğrulandı: `RootView.handle` ve Ayarlar sayımları `words` kullanıyor.
11. [major, ürün] Türkçe arayüz adları: **düzeltildi.** "araç takımı", "Araç Takımı Ekle", "kilitli ekran" ve İngilizce karşılıklar; kilitli ekran adım 1'de kilit açma dalda var. Kilitli ekran seçicisinde arama kutusu kaynakla doğrulanamadı, kilitli ekran adımlarında arama anılmıyor.
12. [major, ürün] Çok az kelime durumu: **düzeltildi.** Doğrulandı (DB, `primary_topic`): 25 dolu kategori, 11'i 20 kartın altında; itirazdaki "26 boş" yerine 35 boş çıktı. Dal 5 kart eşiği ve widget yedeğini zaten içeriyor; eksikler (seçim özeti ve gün tahmini, Tekrar ve hatırlatma yedeği, yumuşatılmış vaat) eklendi. Eşik yükseltilmedi, özet satırı tercih edildi.
13. [major, ürün] Telaffuz düğmesi turda izin garantisini bozar: **düzeltildi.** Doğrulandı (`git diff main...ios/telaffuz`: `SayButton` `WordCardView`'e giriyor). İncelik: izin pencereleri düğmeye dokunup kayıt başlayınca çıkıyor, kart gösterilince değil; yine de `showsPractice: false` eklendi ve birleşme sırası yazıldı.
14. [major, ürün] Görünür adım listesi ve `onboardingStep` tutarsız: **düzeltildi** (madde 2 ile aynı kök). Adım numarası saklanmıyor, 4 sabit sayfa.
15. [major, ürün] `PrivacyInfo.xcprivacy` "değişmez" yanlış: **düzeltildi.** Doğrulandı: `ProgressStore.swift:124,162-164` dosya zaman damgası kullanıyor, uygulama manifesti yalnızca UserDefaults bildiriyor. Ayrı commit olarak `FileTimestamp` + `C617.1` eklendi.
16. [minor, ürün] Kişisel v1 için aşırı kapsam: **düzeltildi.** Animasyonlu çizim ve widget algılama çıkarıldı (README madde 21 doğruladı), tespit tek kanıta (plan dosyası) indi, bildirim isteği plandan çıkarıldı.
17. [minor, ürün] "Atla" anlamı belirsiz, Ayarlar Picker'ı seçilmemişi A1 gösteriyor: **düzeltildi.** "Emin değilim" ve `unsure` kalktı; Atla turu bitirir ve olmayan seçimi yazmaz. Picker'ın `nil` için A1 göstermesi zararsız: `nil` ve A1 aynı sırayı verir (`DeckFilterTests`), ayrı "Seçilmedi" durumu eklenmedi.

Reddedilen itiraz yok. İtirazlardaki küçük olgusal sapmalar (madde 1, 4 ve 12) yukarıda belirtildi.
