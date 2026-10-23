# Lockglow iOS (widget spike)

Kelime widget'ı uygulamasının ilk, bilerek küçük tutulmuş iskeleti. Amaç: widget zaman çizelgesi, interaktif butonlar, App Group dosya sözleşmesi ve içerik veritabanı okumasının gerçek cihazda çalıştığını kanıtlamak.

> **Bu kod Windows'ta yazıldı ve hiç derlenmedi.** İlk derlemede küçük hatalar çıkabilir. Aşağıdaki "Bilinen belirsizlikler" bölümü, derleyicinin veya cihazın itiraz edebileceği yerleri listeler.

Veri sözleşmesi: [`../docs/contract/content-db.md`](../docs/contract/content-db.md). Mimari: [`../raporlar/04_teknik_mimari.md`](../raporlar/04_teknik_mimari.md).

## Klasör yapısı

```
ios/
├─ project.yml                 XcodeGen tanımı (.xcodeproj elle yazılmaz)
├─ Config/Base.xcconfig        BUNDLE_ID_PREFIX, DEVELOPMENT_TEAM, APP_GROUP_ID, sürüm
├─ App/                        Lockglow (SwiftUI uygulaması): ilk açılışta açılış akışı (OnboardingView); sekmeler Akış, Tekrar, Sözlük, Ayarlar (Widget Sağlığı: Ayarlar > Tanılama)
│  ├─ Resources/               content.sqlite buraya (isteğe bağlı)
│  ├─ Assets.xcassets/         AppIcon (1024 px, opak, yalnızca şekil; geçici ikon)
│  └─ PrivacyInfo.xcprivacy
├─ Widgets/                    LockglowWidgets (WidgetKit extension)
│  ├─ Resources/seed_words.json   widget paketine gömülü tohum kelimeler
│  └─ PrivacyInfo.xcprivacy
├─ Tools/                      linux_check.sh (Mac olmadan derleme + test), make_app_icon.py
└─ Packages/VocabKit/          yerel Swift paketi (swift test Mac'te çalışır)
   ├─ CoreModels               WidgetWord, Level, WidgetEventType, SeedWords, DeepLink, CardDetail (kartın tam JSON'undan örnekler + Türkçe notlar), ContentTopic (seçilebilir konu), CustomWordID (kendi kelime kimlikleri)
   ├─ TextFold                 fold() (sözleşme §4)
   ├─ SharedState              AppGroupStore, EventMailbox, WidgetPlan/State/Event
   ├─ Scheduler                TimelinePlanner, RotationInput, RotationCursor, QueueBuilder (saf fonksiyonlar)
   ├─ ContentStore             GRDB ile salt okunur content.sqlite (yalnızca uygulama)
   ├─ Learning                 Leitner (5 kutu, tazeleme 30/60/120 gün), QueueComposer (her 10 slotta 3 yeni : 5 öğrenme : 1 tazeleme : 1 serbest; Tekrar'ın 6 saat içinde soracağı kelime gizli), DeckFilter (konu ve seviye seçimi), ProgressIngest (widget olayları → ilerleme), ReviewPlanner (tekrar turu, Tanış + Hatırla, sayılar), ReviewLog (cevap günlüğü), CustomWords (kendi kelimelerin), ProgressSummary (Kitaplığın), SystemCards (tek sistem kartı), LocalMetrics (yerel ölçüm), ProgressStore (yalnızca uygulama)
   └─ Pronunciation            PronunciationCheck: "Söyle" alıştırmasında duyulanı kartla karşılaştırır, Türkçe geri bildirim; RecognitionFailures (iOS 17–25 hata eşlemesi) (saf, yalnızca uygulama)
```

Kural: widget yalnızca `CoreModels`, `SharedState`, `Scheduler` bağlar. SQLite açmaz, `ContentStore`/`TextFold`/`Learning`/`Pronunciation`/GRDB bağlamaz. `Learning` ve `Pronunciation` yalnızca uygulama hedefindedir.

## Mac'te kurulum

1. **Xcode 26 veya 27** (iOS 26 cihaz). Proje iOS 17.0 hedefler, Swift dil modu 5'tir. Ücretli program olmadan yalnızca kendi iPhone'una kurmak istiyorsan aşağıdaki [Kişisel kurulum](#kişisel-kurulum-ücretsiz-apple-id) bölümünü izle (adım 4 gerekmez).
2. `brew install xcodegen`
3. `Config/Base.xcconfig` dosyasında şunları düzenle:
   - `BUNDLE_ID_PREFIX`: kendi ters alan adın (örn. `com.yusuf`). Bundle id'ler `<prefix>.vocabwidget` ve `<prefix>.vocabwidget.widgets` olur.
   - `APP_ID_SLUG` (`vocabwidget`): bundle id'lerin ve App Group'un markadan bağımsız parçası. Bundle id ilk App Store yüklemesinden sonra **asla değişmez**, bu yüzden marka adı taşımaz. Değiştireceksen App ID'yi Developer portalında kaydetmeden önce değiştir.
   - `APP_DISPLAY_NAME`: ana ekranda ikonun altında ve widget galerisinde görünen ad: `Lockglow` (plan §4.4). Ad değişirse yalnızca bu satır değişir.
   - `DEVELOPMENT_TEAM`: 10 haneli Team ID (boş bırakırsan Xcode'da takımı elle seçersin).
   - `APP_GROUP_ID` otomatik `group.<prefix>.vocabwidget` olur. Kod bu değeri Info.plist'teki `WGAppGroupID` anahtarından okur; koda gömülü değildir.
4. **App Group'u kaydet** (developer.apple.com > Certificates, Identifiers & Profiles > Identifiers > App Groups): `group.<prefix>.vocabwidget`. Otomatik imzalama çoğu zaman bunu kendisi yapar; yapmazsa elle ekle ve iki App ID'ye (uygulama + `.widgets`) App Groups yeteneğini bağla.
5. `cd ios && xcodegen generate`
6. `open Lockglow.xcodeproj`. İlk açılışta Xcode SPM paketlerini çözer (GRDB internetten iner).
7. Her iki hedefte (Lockglow, LockglowWidgets) Signing & Capabilities sekmesinde takımı ve App Groups'ta grubun işaretli olduğunu kontrol et.
8. Scheme `Lockglow`, hedef: gerçek iPhone. Çalıştır. (Widget'lar simülatörde de görünür ama bütçe ve kilit ekranı davranışı için gerçek cihaz şart.)
9. Paket testleri: `cd Packages/VocabKit && swift test` (Mac'te, simülatör gerekmez, ağ gerekir: GRDB indirilir).

`project.yml` değiştikçe (yeni dosya klasörü, `content.sqlite` ekleme) `xcodegen generate` yeniden çalıştırılır. Üretilen `*.xcodeproj`, `Info.plist` ve `.entitlements` dosyaları `.gitignore`'dadır.

### İçerik dosyalarını kopyalama (`content-pipeline` çıktısı)

| Dosya | Nereye | Notlar |
|---|---|---|
| `content.sqlite` | `ios/App/Resources/content.sqlite` | İsteğe bağlı. Yoksa uygulama `seed_words.json`'a düşer. Ekledikten sonra `xcodegen generate`. |
| `seed_words.json` | `ios/Widgets/Resources/seed_words.json` (var olanın üzerine yaz) | 300 KB altında olmalı. Uygulama da aynı dosyayı yedek olarak paketler. |

`content.sqlite` için: `PRAGMA user_version = 1` ve **`journal_mode=DELETE`** (WAL değil) olmalı. Uygulama dosyayı **doğrudan uygulama paketinden** salt okunur açar (App Group'a kopyalanmaz: widget SQLite açmadığı için gerek yok). `?immutable=1` bilerek kullanılmadı (aşağıya bak).

### Tasarım notları

- **Tek yazar kuralı:** `widget_plan.json` yalnızca uygulama, `widget_state.json` ve `events/*.json` yalnızca widget yazar. Hepsi atomik yazılır, koruma `.completeUntilFirstUserAuthentication`.
- **Dönüşüm sürekli (tekrar yok):** kelime, zamanın ve iki küçük dosyanın saf bir fonksiyonudur; zaman çizelgesi yeniden üretilince, uygulama arka plana geçince ya da plan yeniden yazılınca kuyruk başa sarmaz.
  1. Taban: `widget_state.json` aynı `plan_id`'ye aitse `b = cursor_offset`, `d = cursor_anchor`; değilse `b = 0`, `d = plan.updated_at`. Plan yoksa tohum kelimeler: `b = 0` (ya da `plan_id = "seed"` olan state), `d = 2026-01-01T00:00:00Z`.
  2. `R` = kuyruğun `b` sırasından başlayan bir turu, bilinenler çıkarılmış.
  3. Aralık **global**: `plan.interval_seconds` (tohumda 3600), en az 300 sn. Sınır dizini `floor((unixZamanı + hizalamaOfseti) / aralık)`. Yerel saat ofseti tek yerden gelir: `TimelinePlanner.localAlignmentOffset(for:)`.
  4. `t` anında gösterilen kelime `R[max(0, sınır(t) - sınır(d)) mod R.count]`. Zaman çizelgesi `[şimdi, sonraki sınırlar...]`; her girişin kelimesi `wordAt(girişTarihi)` ile aynıdır. Ana ekran ve kilit ekranı widget'ları aynı kelimeyi aynı anda gösterir.
  5. Dokunuşlar: "Sonraki" ekrandaki kelime W için `cursor_offset = sıra(W) + 1`, `cursor_anchor = t`. "Biliyorum" için W bilinenlere eklenir, `cursor_offset = sıra(W)`, `cursor_anchor = t`. W kuyrukta yoksa o an `wordAt(şimdi)` ile gösterilen kelimenin sırası kullanılır.
- **Plan yeniden yazma (uygulama):** olaylar ilerlemeye işlendikten sonra eski plan + state ile `wordAt(şimdi)` hesaplanır, yeni kuyruk **o kelimeyle başlar** (`QueueComposer.compose(deck:fallbackFeed:progress:now:horizon:maxNew:limit:pinFirst:patternOffset:)`, `pinFirst` = şu an görünen kelime), yeni `plan_id` ve `updated_at = şimdi` yazılır. Böylece yeniden yazma anında görünen kelime aynı kalır ve oradan devam eder. Kuyruk en çok 96 kelime, ufuk 48 saat, yeni kelime sınırı `günlük yeni kelime × 2`. İçerik henüz yüklenmediyse (açılışta arka plana geçme) plan değiştirilmez. Aralık değişirse de görünen kelime korunur.
- **Olay işleme:** widget olayları uygulama açılırken, öne gelirken (`scenePhase == .active`) ve plan yazarken `ProgressIngest` ile ilerlemeye işlenir (eskiden yeniye): `known` → `markKnown`, `next`/`reveal` → `markExposure`, `unknown` → `review(.again)`. Sıra: ilerleme dosyasını kaydet, **sonra** olay dosyalarını sil; kayıt başarısız olursa dosyalar kalır ve bir sonraki sefer yeniden işlenir. Bozuk dosyalar silinir, okunamayanlar (kilitli cihaz) bırakılır.
- **İlerleme dosyası:** `Application Support/progress.json` (`ProgressStore`, uygulamaya özel, tek yazar: `AppModel`). Eski `UserDefaults` anahtarındaki (`lockglow.knownWordIDs`) bilinen kelimeler ilk açılışta bir kez `markKnown` ile bu dosyaya taşınır, sonra anahtar silinir.
  - `progress.json` kelime başına `last_reviewed_at`, `last_grade`, `first_reviewed_at`, `refresher_step` da tutar (isteğe bağlı).
  - Her cevap ayrıca `review_log.jsonl`'a bir satır yazar (`ReviewLog`; FSRS için; uygulamaya özel; "İlerlemeyi sıfırla" siler).
- **Ayarlar (UserDefaults):** değişim sıklığı (30, 60, 120, 240 dk; varsayılan 60) ve günlük yeni kelime (5, 10, 15, 20; varsayılan seviyeden: A1–A2 5, B1 10; kendi seçimi korunur). Eski 5 ve 15 dk 30 dk'ya taşınır. İkisi de değişince plan hemen yeniden yazılır. Widget aralığı en az 300 sn'ye sıkıştırır.
- Tarihler (anchor, `updated_at`) JSON'a tam saniye olarak yazılır. Sınırlar tam saniyeye düştüğü için (tam sayı aralık ve ofset) saniyeye aşağı yuvarlamak hangi sınıra düştüğünü değiştirmez.
- **Zaman çizelgesi:** en çok 48 saat ve 96 giriş, politika `.atEnd`, widget ağa çıkmaz. Tüm kelimeler bilinense widget boş kalmasın diye bilinenler yok sayılır.
- **Aralık ayarı:** "Ayarlar" sekmesinden. "5 dakika" hızlı deneme artık yok; en kısa aralık 30 dk. Widget'ı düzenleme (yapılandırma) ekranı yok (`StaticConfiguration`).
- **Gösterim sırası (A2 öğrenen):** orta widget'ta ve akış kartında kelime, sonra Türkçe karşılık (bir kademe iri ve kalın), sonra kısa İngilizce tanım, sonra örnek.
  - Küçük widget: kelime + Türkçe anlam, iki düğme (Dinle, Sonraki).
  - Kilit ekranı dikdörtgen: iki satır (kelime, Türkçe anlam), opak griler, zemin sistemin.
  - Türkçe anlam hiç kesilmez: tam → kısa biçim (editörün `gloss_short`'u, yoksa ilk anlam) → gizli.
- **Sözlük:** İngilizce ya da Türkçe önekle arama (`ContentStore.search`, Türkçe harfler katlanır: "kahv" → breakfast); sonuca dokununca kartın tamamı (`WordDetailView`): tüm örnekler ve Türkçeleri, yaygın hatalar, not, ipucu, eşdizimler. UI testi aramayı ve kart açılışını da çeker.
  - Son aramalar (`lockglow.recentSearches`, en çok 8, satırda Sil ve "Temizle"; "İlerlemeyi sıfırla" da siler).
  - Konuya göre göz atma (`SozlukTopicView`, `AppModel.words(inTopic:)`, seviyeye göre).
  - Süzgeç: Tümü ve üç durum adı (`SozlukFilter`, `SozlukStatus`).
  - VoiceOver'da İngilizce kelime İngilizce sesle okunur (`SozlukSpeech`). Sözlük ve Bildiğin kelimeler satırlarında İngilizce kelime ayrı VoiceOver öğesidir (`englishVoice()`); Türkçe kısım ayrı öğedir; ikisi de kartı açar (`SozlukRowSpeech`).
  - Arama kullanıcının kendi kelimelerini de bulur; sonuç yoksa "… kelimesini kendin ekle".
- **Tekrar sorusu:** zamanı gelen kelime kutusuna göre sorulur (`ReviewPlanner.questionKind`):
  - **Kutu 1–3:** kartın boşluk doldurma sorusu, cümle + 4 şık (`QuizCardView`). Şık sırası kelimeye özel; her denemede doğru şık başka yere geçer. Henüz oturmamış karışan eş çeldirici olmaz (`AppModel.clozeQuiz`).
  - **Kutu 4–5, tazeleme, "Biliyorum" kontrolü ve sorusu olmayan kart:** hatırlama ekranı. Türkçe anlam, "Göster", sonra eşit iki düğme: "Bulamadım" (`.again`) ve "Buldum" (`.good`).
  - Quiz'de yanlış → `review(.again)`; doğru → `review(.good)` ("Devam"). Doğru cevaptan sonra "Zor muydu, kolay mı?" sorusu ve "Zor" (`.hard`) / "Kolay" (`.easy`) düğmeleri çıkar; yanlışta çıkmaz. Cevaptan sonra doğru şık ve Türkçe anlam gösterilir.
  - `QuizCardView` sonucu kendi `QuizOutcome` türüyle bildirir, `ReviewView` bunu `ReviewGrade`'e çevirir (dosya `LockglowWidgetSnapshots`'a da derlendiği ve orada `Learning` bağlı olmadığı için). Görünüm `QuizSnapshotTests` ile çizilip bakıldı.
- **Tekrar sekmesi:** önce zamanı gelen kelimeler (en çok 10 kelime/tur, en çok gecikmiş önce).
  - Zamanı gelen yoksa yeni kelimeler 5'li **Tanış + Hatırla** turlarında gelir (`IntroRound`, `AppModel.introRoundLimit`), günlük hedefin kalanı kadar. Sıra: önce "Biliyorum" kontrolünü geçemeyen kelimeler, sonra akış sırası; bugün zaten çalışılanlar hedeften düşülür.
  - **Tanış:** kelime, anlam gizli; alttaki düğme yerinde kalır, "Anlamını göster"den "Sonraki"ye döner. Üstünde "Bunu zaten biliyorum".
  - **Hatırla:** her kelime bir kez, dört şık ("Anlamını seç" ya da "İngilizcesini seç"). Yanlışta 3 kart sonra ikinci deneme, en çok 2.
  - Not cevaplardan gelir, kendini puanlama yok: ilk denemede doğru `good`, ikinci denemede doğru `hard`, iki yanlış `again`. Günlük hedef yalnız geçen kelimeyi sayar.
  - Yanlış cevap (`again`) kelimeyi iki kutu indirir: kutu k → max(1, k−2) (`Leitner.lapseDrop`). Kelime 10 dakika sonra yeniden "zamanı gelmiş" olur, sonraki turda yine sorulur (aynı turda sorulmaz). Kutu geçişleri aşağıda, "Zor ve Kolay notları".
  - Her cevapta ilerleme kaydedilir, tur bitince (ya da "Bitir"e dokununca) plan yeniden yazılır. Erken "Bitir"de özet "Kalanlar burada seni bekliyor." der.
  - Hedef dolunca "Bugünlük tamam" ekranı çıkar; isteyen "N yeni kelime daha öğren" ile devam eder.
  - 20'den fazla kelime bekliyorsa başlangıç kartı "Ara verdin, sorun değil." der, "Başla (10 kelime)" en çok gecikmiş 10 kelimeyle başlar. Büyük birikmiş sayı hiçbir yerde yok. Bu bir sistem kartıdır (`.breakStart`, madde 43); o açılışta başka kart çıktıysa sade "Tekrar zamanı" kartı görünür.
- **Akış:** Günlük yeni kelime hedefine gelinince Akış'a "Bugünlük N yeni kelime yeter." kartı sıradaki sayfa olarak eklenir; günde bir kez, bir açılışta tek sistem kartı kuralıyla (`SystemCardQueue`, `.dayEnd`; madde 43). Bu karttan sonra görülen kartlar o gün yeni kelime sayılmaz.
- **İmleç anlamı (sözleşmeden sapma, §6'ya işlenmeli):** `widget_state.json`'a `cursor_anchor` (ISO 8601) eklendi; `cursor_offset` artık "`cursor_anchor` anında dönüşümün bulunduğu kuyruk sırası" demek, saf bir "+1" sayacı değil.
- **Hizalama:** yerel saat dilimi ofseti kullanıldığı için "günlük" sınır yerel gece yarısına düşer (yoksa UTC gece yarısı = Türkiye'de 03:00 olurdu).
- **Açılış akışı (`OnboardingView`):** ilk açılışta bir kez, tam ekran. Ödeme duvarı yok. Dört sayfa:
  1. **Seviye:** A1 "Yeni başlıyorum", A2 "Temel konuşabiliyorum", B1 "Günlük konuşmayı anlıyorum". Her seçenekte o seviyenin kelime sayısı yazar. Seçmeden "Devam" basılmaz.
  2. **Konular:** "Tümü" ve gruplar altında konular, her birinde kelime sayısı. Hiç seçilmezse hepsi.
  3. **Widget nasıl eklenir:** "Kilitli ekran" ve "Ana ekran" adımları (`WidgetGuideContent`). Düğme adları Apple'ın iOS 26 Türkçe iPhone kılavuzundan: iPhone'da widget'ın adı "araç takımı"; "Düzenle", "Araç Takımı Ekle", "Özelleştir", "Bitti".
  4. **İlk kelime:** destenin ilk yeni kelimesi, Akış kartıyla (`WordCardView`). Tekrar sekmesinin ilk yeni kelimesi de bu.

  Her sayfada "Atla" var: akışı bitirir, o ana kadar seçilenleri uygular (seçilmeyen seviye yazılmaz). Konular yüklenirken 2. sayfanın düğmesi pasif ("Konular hazırlanıyor…"), çünkü o an seçim uygulanırsa plan yazılmazdı. İçerik hiç yüklenemediyse 4. sayfa hata metni gösterir. Bitince `lockglow.onboardingCompleted` yazılır, akış bir daha kendiliğinden açılmaz. Ayarlar > Yardım > "Açılış ekranlarını yeniden göster" yeniden açar; orada şimdiki seçim seçili gelir. UI testleri `-lockglow.onboardingCompleted YES` ya da `NO` başlatma argümanıyla akışı atlar ya da zorla açar.
- **Güncelleyen kullanıcıya açılış akışı yok (`OnboardingGate`, saf ve testli):** karar `AppModel` oluşurken bir kez verilir (`shouldShowOnboardingAtLaunch`).
  - `lockglow.onboardingCompleted` yazılmışsa o karar verir.
  - Yazılmamışsa ve eski bir kurulumun izi varsa (`widget_plan.json`, `progress.json` ya da eski sürümün `UserDefaults`'taki bilinen kelimeleri) akış açılmaz, bayrak "bitti" yazılır. Sahibin TestFlight güncellemesinde akış görünmez.
  - Hiç iz yoksa (yeni kurulum) akış açılır ve bayrak hemen "bitmedi" yazılır. Böylece akış yarıda bırakılıp uygulamadan çıkılınca yazılan plan, sonraki açılışta "eski kurulum" sayılmaz; akış yeniden açılır.
  - App Group erişilemiyorsa plan izi yok sayılır; `progress.json` yine bakılır.
- **İlk plan ve açılış akışı:** yeni kurulumda (akış bitmemiş ve `widget_plan.json` yok) `AppModel.start` planı yazmaz. İlk planı akıştaki seçim yazar (konular sayfasından çıkınca ya da "Atla"da). O an eski plan olmadığı için sabitlenecek kelime yok; kuyruk destenin ilk kelimesiyle başlar. Böylece 3. sayfada eklenen widget hemen seçilen kelimeleri gösterir. Kullanıcı akış bitmeden uygulamadan çıkarsa plan yine yazılır (`sceneDidEnterBackground`). Planı olan kullanıcıda (güncelleme) her şey eskisi gibi: plan açılışta yazılır, seçim değişince görünen kelime sabitlenir.
- **Deste (konu) seçimi:** konu, kartın üyesi olduğu kategorilerdir (`card_category`, ana konu olsun olmasın; sözleşme §3 "Konu (deste) süzgeci"). Bir kart birden çok konuda olabilir; seçilen konulardan birinde olması yeter, deste her kartı bir kez alır. Akışlar (s1–s13) veritabanında yok ve bir akışta birden çok konu var (ör. s11'de seyahat, şehir ve phrasal verb); bu yüzden seçim akışa göre değil, konuya göre. Ana konuya göre sayınca Seyahat 93 değil 52 kelime olurdu (`2026.10.21-kisisel-5`).
  - `ContentStore.topics()`: en az bir ücretsiz ve hassas olmayan üye kartı olan kategoriler, `category.sort` sırasıyla, üye sayısıyla. `topicsByCard()`: kart kimliği → konular kümesi.
  - 5'ten az kartı olan konu seçim listesinde yok (`AppModel.minimumTopicCards`); kartları "Tümü"nde var. Seçilecek konu sayısında alt sınır yok: küçük deste için özet satırı uyarır (aşağıda).
  - Konular `category.grp` harfine göre Türkçe başlıklar altında: A Günlük hayat, B Seyahat ve kültür, C İnsanlar ve duygular, D İş hayatı, E Bilim ve teknoloji, F Sanat ve eğlence, G Dil kalıpları, H Zengin kelimeler, I Sınavlar.
  - Görünen ad (`ContentTopic.displayName`, uygulamada): "Phrasal Verb'ler" → "Kalıp fiiller" (terimler §4), "Karıştırılan Kelimeler & Tuzak Kelimeler" → "Karıştırılan kelimeler". Veritabanındaki `name_tr` değişmedi.
  - Saklama: `UserDefaults` `lockglow.selectedTopicIDs` (boş = hepsi) ve `lockglow.startLevel`. "İlerlemeyi sıfırla" bunlara dokunmaz.
  - Ayarlar > Öğrenme: "Başlangıç seviyesi" ve "Konular" (`TopicPickerView`). Konu seçimi ekran kapanınca ya da uygulama etkin olmaktan çıkınca (`scenePhase`) uygulanır, her dokunuşta plan yazılmaz. Aynı seçimi iki kez uygulamak bir şey yapmaz.
  - **Özet satırı (`DeckSummaryLine`, tek hesap `DeckFilter.summary`):** Konular ekranında altta sabit çubuk (en büyük yazı boyutlarında listenin üstünde), açılış akışının 2. sayfasında konu seçiliyken düğmenin üstünde. "Seçili: N kelime" (seçim yoksa "Tüm konular: N kelime"), altında yeni kelime sayısı ("Bu konularda X yeni kelime var" / günlük hedeften azsa "kaldı" / "yeni kelime kalmadı"). Seçili deste 30 kelimeden azsa: "Kelime az olduğu için widget aynı kelimeleri sık gösterir." Gün tahmini yok.
- **Deste neyi etkiler (`DeckFilter`, saf ve testli):**
  - `AppModel.words` bütün kelimeler, `feedWords` deste. `DeckFilter.feed` önce konuya göre süzer, sonra seviyeye göre sıralar.
  - Süzgeç: seçilen konuların kelimeleri, eski sırasıyla. Seçim boşsa ya da hiçbir kelimeye uymuyorsa (içerikten kalkmış konu, tohum kelimeler) bütün kelimeler gelir. Seçim desteyi hiç boşaltmaz.
  - Seviye sırası (kararlı): önce seçilen seviye, sonra üstündekiler (kolaydan zora), sonra altındakiler (yakından uzağa), en sonda seviyesi bilinmeyenler. A2 seçen kullanıcı A2, B1, sonra A1 görür. Hiçbir kelime düşmez. Seviye seçilmemişse sıra değişmez (A1 önce).
  - Desteyi kullananlar: Akış sekmesi, widget kuyruğu, Tekrar'ın yeni kelimeleri, günlük hatırlatmanın yeni kelimeleri (`ReminderPlanner.plan(newWordFeed:)`).
  - **Deste bitince:** seçilen konuların yeni kelimesi kalmayınca Tekrar'ın ve hatırlatmanın yeni kelimeleri bütün konulardan gelir (`DeckFilter.newWordFeed`, aynı seviye sırasıyla `AppModel.allTopicsFeed`). Ayarlar > Öğrenme altbilgisi bunu söyler (`newWordsComeFromAllTopics`). Akış seçilen konuları göstermeye devam eder. Ayrı bir "başka konulardan devam et" düğmesi yok.
  - Bütün kelimeleri kullananlar: zamanı gelen tekrarlar (öğrenmeye başlanan kelimenin tekrarı konu değişince kesilmez), Ayarlar'daki sayılar, Bildiğin kelimeler, Sözlük.
- **Kuyruk ve süreklilik:** plan `QueueComposer.compose(deck:fallbackFeed:...)` ile kurulur. Seçim değişince plan, her ayar değişikliğindeki gibi hemen yeniden yazılır.
  - `pinFirst` (şu an görünen kelime) desteden olmasa bile ilk sırada kalır. Görünen kelime sınıra kadar değişmez; sonraki sınırdan itibaren destenin kelimeleri döner.
  - Destenin kendi kelimesi kalmamışsa (hepsi biliniyor ve zamanı gelmemiş) kuyruk bütün konulardan, aynı seviye sırasıyla kurulur. Widget boş kalmaz.
  - Destede yalnızca zamanı gelmemiş öğrenilen kelimeler varsa onlar döner, yedeğe geçilmez.
  - Tekrar'da 6 saat içinde sorulacak, bugün cevaplanmamış kelime widget'ta gösterilmez (`QueueComposer.hiddenBeforeDue`); destenin bütün kelimeleri böyle gizliyse bütün konulardan yeni kelime gelir. Günlük hatırlatma da aynı süreyi kullanır (`ReminderPlanner.quietWindow`).
  - Slot düzeni (her 10 slotta 3 yeni, 5 öğrenme, 1 tazeleme, 1 serbest) saate bağlı: `patternOffset` = 1970'ten bu yana geçen sınır sayısı + 1 (`AppModel.refreshWidgetPlan`). Plan her arka plana geçişte yeniden yazılsa da düzen baştan başlamaz.
- Derin bağlantı: widget'a dokunmak `vocabwidget://word/<id>` açar; uygulama akışta o karta kaydırır. Kelime destede yoksa (konu değişiminden hemen sonra sabitlenen kelime ya da bütün konulardan gelen yedek kelime) kartın tamamı (`WordDetailView`) bir sayfada (sheet) açılır, "Kapat" ile kapanır. Açılış akışı ekrandayken sayfa açılmaz (iki sunum çakışır); içerik yüklenirken gelen bağlantı yüklenince açılır. Şema `CoreModels/DeepLink.swift` ve `project.yml` (`CFBundleURLSchemes`) içinde; ikisi aynı kalmalı. Markadan bağımsızdır, ad değişince bağlantılar bozulmaz.
- **Kendi kelimelerin:** Ayarlar > Kendi kelimelerin (`CustomWordsView`, `CustomWordLibrary`).
  - Kelime, Türkçe anlam, isteğe bağlı örnek ve not.
  - Kimlikler 1.000.000'dan başlar (`CustomWordID`) ve hiç yeniden kullanılmaz.
  - Kelimeler her destenin en önüne girer (`DeckFilter.prepending`). Boşluk doldurma sorusu yok: yeniyken Tanış + Hatırla'da, sonra hatırlama ekranıyla sorulur.
  - Dosya `Application Support/custom_words.json`, günlük yedek `custom_words.backup.json`. Bozuk dosya kenara alınır (`ProgressStore` ile aynı kural).
  - Ayrıntı: `docs/ozellik_planlari/kendi_kelime.md`.
- **Kitaplığın (ilerleme ekranı):** Tekrar başlangıcında "Bugün…" satırının ve "Bugünlük tamam" kartının altında "Kitaplığın". Ayarlar > İlerleme'de "Kitaplığın ve bu hafta" (`ProgressScreen` / `ProgressOverviewView`; hesap `Learning/ProgressSummary`).
  - Seri, yüzde, puan ve "0" yok.
  - Pazartesi geçen haftanın özeti bir kez gösterilir (`lockglow.progressRecapWeek`).
  - "Tümü" seçiliyken en çok 8 başlanmış konu.
  - Kitaplık boşken Tekrar'daki "Kitaplığın" bağlantısı görünmez. Ayarlar'dan açılan boş kitaplıkta "Tekrar'a git" düğmesi Tekrar sekmesini açar.
  - Ayrıntı: `docs/ozellik_planlari/ilerleme_ekrani.md`.
- **VoiceOver'da İngilizce ses (`englishVoice()`, `docs/tasarim/README.md` madde 14):**
  - `englishVoice()` simülatörde doğrulandı: tek öğede dil en-Latn-US. `.combine` ile birleşen satırlarda çalışmaz (dil silinir). Bu yüzden İngilizce kelime ayrı öğe olur.
  - Tekrar: tur özeti satırında, Hatırla geri bildiriminde ve quiz geri bildirim kutusunda İngilizce kelime ayrı öğe.
  - Sözlük ve Bildiğin kelimeler: yukarıda "Sözlük". Söyle: aşağıda "VoiceOver duyuruları". Widget'lar: madde 18.
  - Cihazda dinlenecek (erişilebilirlik denetimi V6).
- **Yerel ölçüm (`Learning/LocalMetrics`):** uygulama kendi kullanımını yalnız telefonda ölçer.
  - Ayarlar > Widget sağlığı > Tanılama > "Yerel ölçüm": son 28 gün, `ogrenme_ilkeleri.md` §2.13 kabul hedefleri, her biri "tuttu / tutmadı / az veri".
  - Gizlilik: `local_metrics.json` Application Support'ta, yedekten hariç (`isExcludedFromBackup`), ağa gitmez. App Privacy etiketi değişmez (toplanmıyor).

## Kişisel kurulum (ücretsiz Apple ID)

Yalnızca kendi iPhone'unda kullanmak için ücretli Apple Developer Program gerekmez: ücretsiz Apple hesabınla Xcode'dan cihazına kurabilirsin. Apple'ın "Supported capabilities (iOS)" tablosunda **App Groups** ücretsiz "Apple Developer" seviyesi için de açık (2026-10-11'de kontrol edildi), yani widget ile uygulamanın paylaştığı App Group çalışmalıdır. Bunun gerçek cihazda ücretsiz hesapla çalıştığı henüz denenmedi (belirsizlik 24 ve 39).

Gerekenler: Mac, Xcode 26 veya 27, iPhone (iOS 26), USB kablosu, Apple ID.

1. **Apple ID'yi Xcode'a ekle.** Xcode > Settings > Accounts > "+" > Apple Account ile giriş yap. Hesap bir geliştirici programına bağlı değilse Xcode takımı **Personal Team** olarak gösterir.
2. **Benzersiz önek seç.** `Config/Base.xcconfig` içinde `BUNDLE_ID_PREFIX = com.<benzersiz-bir-ad>` yaz (örn. `com.yusufk`; `com.example` kalırsa imza büyük olasılıkla başarısız olur). Bundle id'ler `<önek>.vocabwidget` ve `<önek>.vocabwidget.widgets`, App Group `group.<önek>.vocabwidget` olur. `DEVELOPMENT_TEAM` boş kalabilir, takımı Xcode'da seçeceksin. **Öneki sık değiştirme:** her yeni önek yeni App ID'ler demektir ve ücretsiz hesapta App ID sınırı var (aşağıda).
3. **Projeyi üret.** `brew install xcodegen`, sonra `cd ios && xcodegen generate` ve `open Lockglow.xcodeproj`. Xcode paketleri çözer (GRDB internetten iner).
4. **Takımı iki hedefte de seç.** Proje > hedef `Lockglow` > Signing & Capabilities: "Automatically manage signing" açık, Team: adının yanında "(Personal Team)" yazan takım. Aynısını hedef `LockglowWidgets` için yap. İki hedefte de App Groups altında `group.<önek>.vocabwidget` işaretli olmalı. Grup kimliğini Xcode'un otomatik imzalamasının kendisi kaydetmesi gerekir; kaydedemezse bu sekmede kırmızı hata görürsün (davranış ücretsiz hesapta doğrulanmadı). Ücretli hesap olmadığı için Mac'te "Kurulum" adım 4'teki portal kaydı yapılmaz.
5. **iPhone'u hazırla.** Kabloyla bağla, "Bu Bilgisayara Güven"i onayla. **Developer Mode:** Apple'ın belgesine göre bu anahtar, cihazı Mac'le eşleştirmeye başlayana ya da daha önce eşleştirene kadar Ayarlar'da görünmez. Görünce Ayarlar > Gizlilik ve Güvenlik içinde Güvenlik bölümündeki **Developer Mode**'u aç (Türkçe arayüzdeki adı doğrulanmadı), uyarıda "Yeniden Başlat"a bas; telefon açılınca çıkan onay penceresinde etkinleştirmeyi onayla ve parolanı gir.
6. **Çalıştır.** Scheme: `Lockglow-Release` (kendi kullanımın için bu; widget yenileme bütçesi gerçekçi olur), hedef: iPhone'un, ⌘R. İlk kurulum birkaç dakika sürebilir.
7. **Geliştiriciye güven.** İlk açılışta "Untrusted Developer" uyarısı çıkarsa: Ayarlar > Genel > VPN ve Aygıt Yönetimi > Apple ID'ni seç > güven. Apple bu yolu kurumsal uygulamalar sayfasında anlatıyor (iOS 18 ve sonrasında düğme "Allow & Restart"); Xcode'la imzalanmış kişisel uygulama için başlığın adı ve iOS 26'daki akış doğrulanmadı (geliştirici forumlarında aynı yolun işe yaradığı bildiriliyor). Apple, güven kurarken cihazın internete bağlı olması gerektiğini yazıyor.
8. **Kontrol.** Uygulamayı aç (ilk plan yazılır), "Ayarlar > Widget sağlığı" ekranında App Group "Erişilebilir" olmalı. Ana ekrana uzun bas > "+" > Lockglow. Ardından yukarıdaki test kontrol listesini kullan.

**Ücretsiz hesabın sınırları** (Apple'ın "Compare memberships" sayfası, 2026-10-11'de okundu):
- Cihaza kurulumu sağlayan provisioning profile, verildiği günden **7 gün sonra** bitiyor; Apple: süre dolunca uygulamayı yeniden derleyip cihaza yeniden kurman gerekiyor ve uygulamaları cihaza zaman zaman yeniden provision etmen gerekecek. Pratikte: **haftada bir** iPhone'u Mac'e bağla ve Xcode'dan yeniden çalıştır (Apple ID Xcode'da girili olmalı).
- En çok **10 App ID** (7 gün sonra bitiyor). Bu proje 2 tanesini kullanır (uygulama + widget).
- En çok **3 cihaz** (7 gün sonra bitiyor).
- Cihaz başına en çok **3 uygulama**.

**Doğrulanmadı** (Apple'ın okuduğum sayfalarında yazmıyor):
- Süre dolunca uygulamanın tam olarak ne yaptığı (açılmaması mı, widget'ın boşalması mı) ve widget'ın süre dolana kadar normal çalıştığı.
- Widget uzantısının "cihaz başına 3 uygulama" sınırında ayrı sayılıp sayılmadığı ve App Group kaydının bir sınıra dahil olup olmadığı.
- Yeniden kurulumda verinin korunması. Xcode'dan üzerine kurmanın uygulama verisini koruması beklenir, ama bu denenmedi. Uygulamayı **silmek** (iOS'un olağan davranışı) `progress.json` dosyasını da siler: ilerleme gider. Yeniden kurarken silme.
- Ücretsiz hesapta ilk açılışta internet gerekip gerekmediği (Apple, 6 Haziran 2021'den sonra açılan Developer Program üyelikleri için bunu yazıyor; ücretsiz hesap için yazmıyor).

Kaynaklar: developer.apple.com/support/compare-memberships, developer.apple.com/help/account/provisioning-profiles/provisioning-profile-updates, developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device, support.apple.com/en-us/118254.

## Ücretli Apple Developer hesabıyla kurulum ve TestFlight

Ücretli üyelikte 7 günlük sınır yoktur. Xcode'dan kurulan uygulamanın geliştirme profili en çok bir yıl geçerlidir ve üyeliğinin kalan süresini aşamaz. Otomatik imzalama süresi dolan profili kendisi yeniler.

**Xcode'dan kendi iPhone'una (en hızlısı):**
1. `Config/Base.xcconfig`:
   - `DEVELOPMENT_TEAM` = 10 haneli Team ID (developer.apple.com > Account > Membership details).
   - `BUNDLE_ID_PREFIX` = **kalıcı** önekin (örn. sahip olduğun bir alan adının tersi). App Store Connect'te uygulama kaydı açıldıktan sonra bundle id değişmez, bu yüzden şimdi doğru seç.
2. `xcodegen generate`, `open Lockglow.xcodeproj`. İki hedefte de takım olarak **ücretli takımın** seçili olsun (Personal Team değil). App Groups'ta `group.<önek>.vocabwidget` işaretli olmalı; otomatik imzalama App ID'leri ve grubu portala kendisi kaydeder.
3. iPhone'da Developer Mode açık olmalı (yukarıdaki bölüm, adım 5). Scheme `Lockglow-Release`, hedef iPhone, ⌘R.

**TestFlight (kablosuz güncelleme, isteğe bağlı):**
1. App Store Connect > Uygulamalar > "+" > Yeni Uygulama: platform iOS, ad `Lockglow` (adın App Store'da benzersiz olması gerekir ve bu kayıt adı senin için ayırır; yayından önce değiştirilebilir), ana dil Türkçe, bundle id listeden `<önek>.vocabwidget` (Xcode bir kez imzaladıktan sonra listede çıkar), SKU örn. `lockglow-ios`.
2. Xcode'da hedef olarak "Any iOS Device (arm64)" seç, **Product > Archive**.
3. Organizer > **Distribute App** > App Store Connect > Upload. Her yeni yüklemede `CURRENT_PROJECT_VERSION`'ı (Base.xcconfig) 1 artır; aynı numarayla ikinci yükleme reddedilir.
4. App Store Connect > TestFlight: dahili test grubu oluştur, kendini ekle. Build işlenince iPhone'daki TestFlight uygulamasından kur. Bir TestFlight build'i yüklendiği günden itibaren **90 gün** test edilebilir.

Yükleme için hazır olanlar: uygulama ikonu (`App/Assets.xcassets`, opak 1024 px PNG), gizlilik dosyaları (`PrivacyInfo.xcprivacy`; uygulama UserDefaults'u yalnızca kendi ayarları için kullanır, neden kodu `CA92.1`), `ITSAppUsesNonExemptEncryption = false` (şifreleme sorusu çıkmaz). Doğrulanmadı: XcodeGen'in `.xcprivacy` dosyalarını kaynak olarak pakete koyması (Xcode'da dosyanın hedefin "Copy Bundle Resources" adımında olduğunu kontrol et) ve ilk yüklemede App Store Connect'in başka bir uyarı verip vermediği.

Kaynaklar: developer.apple.com/support/compare-memberships, developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview.

## Mac olmadan kontrol (Linux, Docker)

`ios/Tools/linux_check.sh`, VocabKit paketini ve uygulamanın arayüz dışı dosyalarını (`AppModel` ve uzantıları `AppModel+Progress`, `AppModel+CustomWords`, `AppModel+Sozluk`; `CustomWordLibrary`, `AppPreferences`, `ContentLoader`, `ReviewSession`, `WidgetHealth`; liste `linux_check_prepare.py` → `APP_LOGIC_FILES`) Docker'daki resmi `swift:6.2` imajında derler ve paketin birim testlerini çalıştırır. Windows'ta Git Bash'te, Linux'ta ve Mac'te çalışır, Docker'ın açık olması yeter.

```bash
bash ios/Tools/linux_check.sh
```

- Kopya üzerinde çalışır, projedeki dosyalara dokunmaz (`linux_check_prepare.py`).
- Apple'a özel modüller (`Combine`, `os`, `WidgetKit`) ve GRDB'li `ContentStore` için `Tools/linux-stubs/` altındaki sahte modüller kullanılır. `ContentStore` sahtesinin genel imzaları gerçeğiyle aynı tutulmalı.
  - `linux_check_prepare.py` gerçek `Sources/ContentStore/*.swift` ile `linux-stubs/ContentStore/*.swift` içindeki `public`/`open` bildirimlerini karşılaştırır. Farklıysa farkı yazıp durur ("only in the real module: …").
  - ContentStore'a genel fonksiyon ekleyen, sahteyi de aynı imzayla günceller (gövde `{ [] }` ya da `{ nil }` yeter).
- **Derlenmeyenler:** SwiftUI görünümleri, widget'lar, App Intents ve gerçek `ContentStore` (GRDB). Bunlar yine Xcode'da derlenir.
- Son sonuç (2026-10-12, Swift 6.2.4): derleme hatasız, **97 test geçti**. Kasıtlı yanlış bir argüman etiketiyle denendi: kontrol hatayı yakalıyor.
- Ayrıca gerçek `content.sqlite`'taki 479 kartın tam JSON'u Swift'teki `CardDetail` ile çözüldü: 479/479 başarılı.

## GitHub Actions (Mac olmadan tam derleme)

Depo: `github.com/yusufuyar68/lockglow` (2026-10-22'den beri herkese açık: depoya gizli bilgi yazma). İş akışları:

- **`build.yml`** (her dalda her push'ta; yalnız belge değişen push'ta çalışmaz): Python testleri ve taslak kartların katı doğrulaması (Linux); VocabKit ve uygulamanın arayüz dışı dosyaları Linux'ta (`swift:6.2`) derlenir ve test edilir. macOS işi yalnız elle başlar (`gh workflow run build.yml --ref <dal> -f runner=macos-15-intel`): VocabKit testleri (GRDB'li `ContentStore` dahil) ve uygulama + widget'ın **imzasız simülatör derlemesi**. Derleme günlüğü `ios-build-log` adıyla saklanır.
- **`screenshots.yml`** (elle): `LockglowUITests` ana ekranları gezip ekran görüntüsü alır. Widget'ları ana ekrana ekleyemez, onlar cihazda bakılır.
  - Ekran görüntüleri: `gh workflow run screenshots.yml -R yusufuyar68/lockglow --ref <dal> -f runner=macos-15-intel` (SE, 6.3" Pro, Pro koyu; ~75 dk).
  - Görüntüler `screenshots` artifact'inde `ios/named/<geçiş>/`.
- **`testflight.yml`**, **`testflight_group.yml`**, **`asc_check.yml`** (elle): TestFlight yüklemesi, test grubu ve App Store Connect anahtarlarının kontrolü (`docs/testflight_kurulum.md`).

Depo açık olduğu için Actions dakikaları ücretsiz; macOS makine sırası sınırlı. Aynı dala push, o dalda koşan `build.yml` işini iptal eder (`concurrency`). `build.yml`'in macOS işi ~2 dakika sürer. İlk sonuç (2026-10-13, Xcode 26.3): derleme hatasız ve uyarısız, 107 paket testi geçti.

## Widget spike test kontrol listesi

Hazırlık: uygulamayı en az bir kez aç (plan yazılsın). "Ayarlar > Widget sağlığı" ekranında App Group "Erişilebilir", kuyruk boyutu > 0 olmalı.

- [ ] **Ekleme:** Ana ekrana küçük ve orta widget, kilit ekranına dikdörtgen ve satır içi widget ekle. Hepsinde kelime görünüyor, hiçbiri boş değil.
- [ ] **Uygulama açılmadan ekleme:** Uygulamayı sil, yeniden kur, **açmadan** widget ekle. Tohum kelimeler (breakfast, borrow, actually...) görünmeli.
- [ ] **Galeri:** Widget galerisinde önizleme anında ve anlamlı (örnek kelime).
- [ ] **Sınırlarda değişim:** Kelime her saat başında değişmeli (14:00, 15:00...), 14:23 gibi bir dakikada değil. Ana ekran ve kilit ekranı widget'ları aynı anda aynı kelimeye geçmeli (en kısa aralık 30 dk: Ayarlar > Kelime değişim sıklığı > 30 dk; kelime 14:00, 14:30... sınırlarında değişir).
- [ ] **Süreklilik (en önemli):** Birkaç sınır geçtikten sonra uygulamayı aç ve ana ekrana dön (plan yeniden yazılır): widget'taki kelime **değişmemeli**, sonraki sınırda sıradaki kelimeye geçmeli. Aynısını widget'ı yeniden yükleyerek (Widget Sağlığı > "Yalnızca zaman çizelgelerini yenile") dene. Kelimeler başa sarmamalı, tekrar etmemeli.
- [ ] **Orta widget etiketi:** "Yeni kelime: HH:mm" doğru saati gösteriyor (sığmazsa gizlenmesi normal).
- [ ] **Sonraki:** Küçük ve orta widget'ta "sonraki" okuna dokun. Kelime hemen değişir, geri atlamaz; sonraki sınırda bir sonrakine geçer. "Widget Sağlığı"nda widget imleci değişir, bekleyen olay sayısı artar. Düğmeler rahat basılıyor (44 pt).
- [ ] **Biliyorum:** Orta widget'ta onay işaretine dokun (küçük widget'ta Biliyorum yok). Kelime widget'tan çıkar, sıra bozulmaz. 3 gün sonra Tekrar'da bir kez sorulur. Bekleyen olay artar.
- [ ] **Seslendirme (widget):** Küçük ve orta widget'ta hoparlöre (küçükte sol alttaki, ortada ortadaki düğme) dokun: uygulama **açılmaz**, kelime ABD İngilizcesiyle okunur. Üç durumda dene: uygulama açıkken, uygulama arka plandayken, uygulama kapatıldıktan sonra (görev değiştiriciden kaydır; ilk dokunuş birkaç saniye geç kalabilir). Sessiz modda da duyulmalı; çalan müzik kısılıp sonra geri gelmeli; kelimenin sonu kesilmemeli. Xcode > Console'da `speech` kategorisinde `widget speech in com.yusufuyar.vocabwidget, app audio session: true` görünmeli (`.widgets` ya da `false` görünürse, ya da `audio session not activated` / `widget speech timed out` çıkarsa madde 45'teki sıraya bak). Düğmeler (küçükte iki, ortada üç) SE'de ve büyük ekranda rahat basılıyor mu (uçtaki düğmelerin dış kenarına da dokun)? Kilit ekranı widget'ları ve StandBy eskisi gibi görünüyor mu (kenar boşlukları artık elle uygulanıyor)?
- [ ] **Kilit ekranı:** Dikdörtgen/satır içi widget'ta buton yok. Cihaz kilitliyken küçük widget butonları çalışmaz (beklenen).
- [ ] **Arka plana alma:** Birkaç "sonraki/biliyorum" sonrası uygulamayı aç, sonra ana ekrana dön. Konsolda (Xcode > Console, `widget event` ara) olaylar loglanır, bekleyen olay 0 olur (uygulama öne gelince de 0 olur), yeni plan_id yazılır, widget güncellenir, "biliyorum" denen kelimeler artık yok. Görünen kelime aynı kalır ve dönüşüm oradan devam eder.
- [ ] **Dokunma:** Widget gövdesine dokun: uygulama açılır ve akışta o kelimeye kayar (soğuk açılışta da).
- [ ] **Release yapılandırması:** `Lockglow-Release` scheme'i ile çalıştır (Debug'da widget yenileme bütçesi uygulanmaz). Birkaç saat bırak, zaman çizelgesi girişlerinin kaçırılmadan değiştiğini doğrula. Ayrıca TestFlight derlemesiyle bir gün dene.
- [ ] **Düşük Güç Modu:** Aç, widget'ın bayat kalıp kalmadığını ve uygulama arka plana geçince yenilenip yenilenmediğini izle.
- [ ] **Yeniden başlatma:** Cihazı yeniden başlat, **ilk kilit açmadan önce** kilit ekranı widget'ına bak: yer tutucu/tohum kelime görünebilir, çökme olmamalı. Açtıktan sonra kendini toparlamalı.
- [ ] **Görünüm modları:** Tinted/clear ana ekran (iOS 18/26), kilit ekranı vurgulu modu, StandBy: metin okunuyor, kelime vurgulu, anlam renge bağlı değil. Her Zaman Açık ekranda kelimenin çizgisi 1 pt ve ışımasız.
- [ ] **Yazı boyutu:** Dinamik Tür'ü en büyük ve en küçük yap: küçük widget'ta buton satırı kesilmiyor mu?
- [ ] **VoiceOver (widget, V6):** satır içi widget dahil, kelime İngilizce, "Türkçesi: …" Türkçe sesle mi okunuyor? WidgetKit satır içi ailede `accessibilityRepresentation`'ı yok sayarsa satır Türkçe sesle okunur.
- [ ] **Bellek/çökme:** Console'da widget extension'ın jetsam/0xDEAD10CC çökmesi yok.
- [ ] **Tekrar sekmesi:** İlk açılışta "Bugünün yeni kelimeleri" önerilir. Tanış kartında "Anlamını göster"e dokun: Türkçe karşılık iri, altında tanım ve örnek; düğme yerinde kalır, "Sonraki" olur. Hatırla'da dört şıktan birini seç; yanlışta kelime birkaç kart sonra yine gelir. Tur sonunda özet çıkar. iPhone SE'de Tanış arka yüzünde Dinle + mikrofon + IPA/tür/seviye satırı sığıyor mu (sığmazsa alta iner)? Hatırla'da bir kelimeyi iki kez yanlış ver: 10 dk sonra Tekrar'da boşluk doldurma sorusu olarak gelir. Doğru yanıtla: "Devam" altında "Zor muydu, kolay mı?" sorusu ve "Zor" / "Kolay" çıkmalı, yanlışta çıkmamalı. Uygulamayı kapat-aç: cevapladığın kelimeler yeni kelime listesinde yok. Widget'ta "Biliyorum" dediğin kelime Tekrar'da yeni olarak çıkmaz.
- [ ] **Ara verdin:** 20'den fazla bekleyen tekrarla aç: "Ara verdin, sorun değil.", büyük sayı yok.
- [ ] **Hatırlatma sorusu:** İlk turun "Tamam"ından sonra hatırlatma sorusu bir kez gelir. Sayfa iPhone SE'de ve büyük yazıda sığıyor mu? iOS izin penceresi sayfa kapanırken düzgün çıkıyor mu?
- [ ] **Tekrar ve VoiceOver:** Tur özetinde, Hatırla geri bildiriminde ve quiz geri bildirim kutusunda İngilizce kelime İngilizce sesle mi (V6)? Quiz'de bir satır artık 2–3 kaydırma sürüyor. Cevaptan önce şık çift dokunuşla seçiliyor mu?
- [ ] **Akış kartı:** SE'de ilk karşılaşma kartı tek sayfaya sığıyor mu; "Neden?" çipi çoğu zaman ikinci satıra iner (beklenen). Yarım sayfa "Neden?" açılıp kapanınca Akış konumu korunuyor mu? VoiceOver: Biliyorum → duyuru + "seçili"; alt bildirim 10 sn; "Geri al" sonrası odak. Dikkat kutusunda VoiceOver başlıkta "Fark: … yerine …" okuyor mu?
- [ ] **Günün sonu kartı (Akış):** Günlük hedef 5 iken 5. yeni karttan sonra sıradaki sayfa "Bugünlük 5 yeni kelime yeter." kartı. "Devam et" sonraki kelimeye kayıyor, "Tekrar'a geç" Tekrar'ı açıyor. Aynı açılışta widget ipucu çıktıysa kart gelmiyor, sonraki açılışta geliyor.
- [ ] **Sözlük (V6):** VoiceOver açıkken satırlarda, konu sayfasında ve "Durum"da İngilizce kelime İngilizce sesle, Türkçe kısım Türkçe sesle okunuyor (`SozlukSpeech`). Sözlük ve Bildiğin kelimeler satırında iki VoiceOver durağı var; İngilizce kelimede çift dokunma kartı açıyor; "Türkçesi: …" Türkçe sesle. "Geri al: breakfast", "Dinle: have breakfast" ve duyurularda İngilizce parça İngilizce sesle mi? Son aramalar: kart açınca ya da klavyeden gönderince kaydediliyor, en çok 8. Satırdaki Sil ve "Temizle" çalışıyor. "İlerlemeyi sıfırla" listeyi de siliyor. Konu sayfasındaki süzgeç doğru kelimeleri gösteriyor.
- [ ] **Bildiğin kelimeler:** Bir kelimede "Geri al", sonra "Vazgeç": kelime listedeki eski yerine dönüyor.
- [ ] **Kendi kelimen:** Ayarlar > Kendi kelimelerin > "İlk kelimeni ekle": "awkward" / "garip". Bildirim çıkar, liste güncellenir. Tekrar'da yeni kelimeler turunun ilk kartı "awkward". Arka yüzde "Senin kelimen" etiketi var, boş satır ya da boş rozet yok. Widget: plan yeniden yazılınca kelime bir sonraki yeni kelime yuvasında görünür. Orta widget'ta boş seviye, tanım ya da örnek satırı yok. Dinle kelimeyi okur, Biliyorum çalışır.
- [ ] **Kendi kelimen formu:** Türkçe klavyede "şarj", "sb/sth" ve 29 harflik bir kelime dene: alanın altında Türkçe mesaj çıkar. Kelimeyi kaydır > Sil > "Vazgeç": kelime aynı yere geri gelir. iPhone SE'de ve en büyük yazı boyutunda (AX5) form kayar, "Kelimeyi ekle" klavyenin üstünde durur.
- [ ] **Kitaplığın:** Tekrar başlangıcındaki "Kitaplığın" ve Ayarlar > "Kitaplığın ve bu hafta" aynı ekranı açar. Kitaplık boşken Tekrar'daki bağlantı görünmez; Ayarlar'dan açılan boş kitaplıkta "Tekrar'a git" Tekrar'ı açıyor. iPhone SE'de kitap sırtları ve "+N" tek satıra sığıyor, kart genişliği uygun. AX5'te kartlar alt alta diziliyor, kapsüller satır kaydırıyor, hiçbir metin "…" ile kesilmiyor. Koyu temada sırt tonları ayırt ediliyor.
- [ ] **Kitaplığın, VoiceOver ve pazartesi:** Kart dönünce örnek cümle İngilizce sesle okunuyor. Basamak satırları doğru okunuyor, boş basamak "boş" diye okunuyor. Pazartesi geçen haftanın özeti bir kez çıkıyor; ekrandan çıkıp girince bu haftanın cümlesi geliyor.
- [ ] **Ayarlar sekmesi:** Sıklığı 30 dakikaya çek: widget'taki kelime değişmez, sonraki sınırda yeni aralıkla ilerler. Günlük yeni kelimeyi değiştir: widget kuyruğu yeniden yazılır. Sayılar ("bildiğin kelime" / "öğrenme listende" / "bugün tekrar edilecek") Tekrar sekmesiyle tutarlı. "İlerlemeyi sıfırla" onay sorar, sonra sayılar 0 olur.
- [ ] **VoiceOver ve "·":** Ayarlar'daki seviye satırı ("A2 · …"), Widget sağlığı satırları ve satır içi widget okunurken "·" işareti sesli okunuyor mu? Okunuyorsa erişilebilirlik adında virgül kullan.
- [ ] **Yerel ölçüm:** Ayarlar > Widget sağlığı > Tanılama > "Yerel ölçüm" açılıyor (yukarıda "Yerel ölçüm"). Yeterli veri gelince (en az 3 çalışma günü, 5 yeni kelime, 4 tur, 5 "Biliyorum" kontrolü; `LocalMetricsTargets`) o hedefte "az veri" yerine "tuttu" ya da "tutmadı" yazıyor.
- [ ] **Gece, Kontrastı Artır ve Düğme Şekilleri:** Gece ana düğme sarı değil, beyaz kenarlı ve kalın yazılı. Kontrastı Artır ya da Düğme Şekilleri açıkken kenar 3 pt, ince kapsül kenarları 1,5 pt: kapsül kenarları kalınlaşıyor mu? Koyu modda dolu sarı alan yok; Tekrar bitti işaretinin altında da yalnız ince bir çizgi var (`DoneMark`).
- [ ] **Güncellemede açılış akışı yok:** Eski sürümün üstüne TestFlight güncellemesi kur ve aç: açılış akışı görünmez, Akış sırası aynı. Ayarlar > Yardım > "Açılış ekranlarını yeniden göster" çalışır.
- [ ] **Açılış akışı:** Uygulamayı sil, yeniden kur, aç. Dört sayfa görünmeli: seviye, konular, widget rehberi, ilk kelime. Seviye seçmeden "Devam" pasif. 1. sayfada uygulamayı kapat-aç: akış yeniden açılır. Rehberdeki adımlarla kilitli ekrana ve ana ekrana widget ekle; düğme adları (Özelleştir, Araç Takımı Ekle, Düzenle, Bitti) iPhone'dakilerle aynı mı, bak. Widget seçilen konunun kelimesini göstermeli. "Başla"dan sonra uygulamayı kapat-aç: akış bir daha açılmaz. Ayarlar > Yardım'dan yeniden açılır, şimdiki seçim seçili gelir. "Atla" her sayfada çalışır. "Geri" ve "Atla" düğmelerinin 44 pt olduğunu cihazda ölç (T1).
- [ ] **Konu seçimi:** Ayarlar > Öğrenme > Konular'da özet satırı seçime göre değişir; yalnız "Hava & Mevsimler" seçilince "Kelime az olduğu için..." uyarısı çıkar. Yalnız "Seyahat & Turizm"i seç, geri dön. Widget'taki kelime sınıra kadar aynı kalır, sonra yalnız seyahat kelimeleri döner. Akış yalnız seyahat kartlarını gösterir. Tekrar'da başka konudan öğrenmeye başladığın kelimelerin tekrarı yine gelir, yeni kelimeler seyahatten gelir. "Tümü"ne dönünce her şey geri gelir. Seviyeyi B1 yap: Akış B1 kartlarıyla başlar. Konu değişiminden hemen sonra widget'taki (destede olmayan) kelimeye dokun: kartı bir sayfada açılır, "Kapat" çalışır.
- [ ] **Yüzlerce kart:** `content.sqlite` ~550 kartla paketlenince Akış'ta A1 kartları önce gelir, sonra A2, B1... Akış sekmesi hızlı kayar.
- [ ] **Mağaza çekimleri (gerçek cihaz):** kilitli ekran widget'ı (1. kare), Söyle'nin "Anlaşıldı!" sonucu (5. kare), Ayarlar'da widget sağlığı "Çalışıyor" (10. kare). Simülatörde çekilemiyorlar (`docs/magaza/ekran_goruntusu_basliklari.md`).
- [ ] **Söyle (telaffuz alıştırması):** dosyanın sonundaki "Söyle: cihazda denenecekler" listesi.

## Bilinen belirsizlikler (derleyici veya cihaz itiraz edebilir)

Derleyici olmadan doğrulanamayanlar. Birincil şüpheliler en üstte.

**Proje üretimi (XcodeGen / Xcode)**
1. `project.yml`: `sources.excludes` içindeki `"*.entitlements"` glob'u ve iki açık scheme (`Lockglow`, `Lockglow-Release`). `xcodegen generate` reddederse önce bunları sadeleştir. GRDB yalnızca `VocabKit/Package.swift`'te tanımlı (`project.yml`'de değil).
2. `info:` bloklarında temel Info.plist anahtarlarını (CFBundleExecutable vb.) açıkça yazdım; XcodeGen sürümüne göre gereksiz olabilir ama zararsızdır. Widget'ın `NSExtension` anahtarı ve `CFBundlePackageType: XPC!` üretilen plist'te gerçekten çıkıyor mu, bak.
3. `.entitlements` içindeki `$(APP_GROUP_ID)` değişkeninin imza sırasında xcconfig'den açılacağını varsayıyorum. Signing & Capabilities'te grup kimliği düz metin olarak görünmeli.
4. Paket ürünleri `type: .static` ilan edildi (uygulama ve widget kendi kopyasını bağlasın, gömülecek framework olmasın). Xcode çift kopya/gömme uyarısı verirse `type:` kaldırılır. `Scheduler` artık `SharedState`'e bağlı; widget ikisini de zaten bağlıyor, ama statik kütüphane zincirinin sorunsuz bağlandığı doğrulanmadı.
5. `seed_words.json` iki hedefin kaynağı (aynı dosya referansı). Beklenen çalışır, ama XcodeGen'in tek dosyayı iki hedefe vermesi doğrulanmadı.
6. Xcode 26/27 "önerilen ayarlara güncelle" derse (Swift 6 modu, varsayılan MainActor yalıtımı) ilk başarılı derlemeden önce kabul etme.

**Swift derleme riskleri**
7. Modül adı ile tür adı aynı: `TextFold` ve `ContentStore`. `TextFold.fold(...)` ifadesinin tür olarak çözülmesini bekliyorum. Çıkarsa modül veya tür adını değiştir.
8. Sözleşmedeki `WidgetPlan/WidgetState/WidgetEvent` adları ve `Scheduler` modülü (Combine'ın `Scheduler` protokolüyle aynı ad), WidgetKit/Combine import eden dosyalarda (`AppModel.swift`, `WordProvider.swift`) belirsizlik hatası verirse `SharedState.WidgetState` gibi nitelendir ya da yeniden adlandır. Bildiğim kadarıyla çakışma yok.
9. Widget: klasik `TimelineProvider` + `StaticConfiguration` (imzalar Apple belgesiyle eşleşiyor; `completion` kapanışının `@Sendable` olup olmadığı SDK'ya göre değişebilir, Swift 5 modunda en fazla uyarı). `NextWordIntent`/`KnowWordIntent` için: değeri olmayan `@Parameter(title:)` (Int ve String) + elle `init()`, `title` Apple'ın belgelerindeki gibi hesaplanan `static var`. Metadata çıkarıcıdan uyarı gelebilir.
10. GRDB: açık tipli `let`'lerle `Row` alt simgesi, `arguments:` içinde Int/String/Optional karışık dizi, `GRDB.Configuration().readonly`, `read { db -> T in }`. `readonly` ve `read` imzaları GRDB kaynağından kontrol edildi; geri kalanı belleğe dayanıyor. GRDB'nin güncel sürümü Swift araç sürümü 6.1 ister (Xcode 16.3+; sende sorun olmamalı).
11. SwiftUI: `.containerBackground(for: .widget) { … }` (ana ekranda `Theme.surface`, dikdörtgende `AccessoryWidgetBackground()`), widget içinde `ViewThatFits`, `ContentUnavailableView`, `.scrollPosition(id:)`, iki parametreli `.onChange(of:_:)`, `.frame(minWidth:minHeight:)` + `.contentShape` ile 44 pt düğmeler.
12. `@MainActor AppModel` ve `@StateObject` ilk değer ataması: Swift 5 modunda en fazla uyarı vermeli.
13. Birim testleri: `ContentStoreTests` sistem SQLite'ında FTS5 ister (macOS ve iOS'ta var). Başarısız olursa uygulamayı değil yalnızca testi etkiler. Yeni `RotationContinuityTests` sayıları elle hesaplandı (örn. 22:10 UTC'de başlayan plan, 3,5 saat sonra 3 sınır geçmiş); testler kırmızı çıkarsa önce beklenen sayıyı, sonra algoritmayı kontrol et.

**Davranış / cihaz**
14. `?immutable=1` kullanılmadı: GRDB kaynağında `sqlite3_open_v2` bayrakları arasında `SQLITE_OPEN_URI` yok. Sözleşme v1.1 de `readonly` + `journal_mode=DELETE` diyor; içerik hattı (`build_db`) DELETE modunu zorunlu tutar ve testle doğrular. DB artık doğrudan **uygulama paketinden** (salt okunur konum) açılıyor: WAL modundaki bir DB açılmayabilir; boru hattı `journal_mode=DELETE` üretiyor. Paketten açmanın SQLite için sorun çıkarmadığı cihazda görülmeli.
15. Süreklilik doğruluğu cihazda ölçülmeli (kontrol listesindeki "Süreklilik" maddesi). Algoritma saf ve testli, ama gerçek sistemde zaman çizelgesi yeniden üretme anları, `.atEnd` ve `reloadAllTimelines()` zamanlaması doğrulanmadı.
16. Dokunuştan sonra yalnızca dokunulan widget'ın zaman çizelgesi hemen yenilenir. Kilit ekranı gibi diğer örnekler yeni imleci kendi yeniden yüklemelerinde (en geç uygulama arka plana geçince) görür; o zamana kadar eski girişlerini gösterebilir. `reloadTimelines(ofKind:)` çağrısı bütçeyi yer mi bilmiyorum, eklemedim.
17. Saat dilimi / yaz saati / cihaz saati değişince sınırlar kayar (ofset her hesapta o anki saat diliminden alınır). Dönüşüm tutarlı kalır ama kelime beklenmedik bir anda değişebilir. Cihaz saati 2026-01-01'den önceyse tohum dönüşümü ilk kelimede kalır. 120 dakikalık aralıkta yaz saati geçişinde bir kelime bir kez daha görünebilir (`TimelineEdgeCaseTests` belgeliyor). Saate tam bölünen aralıklar (30 ve 60 dk) etkilenmez.
18. **Widget düzeni (2026-10-21 tasarımı, `docs/tasarim/README.md` "Widget'lar"; derlenmedi, `WidgetSnapshotTests` çizimleri bir sonraki `screenshots.yml` turunda):**
    - **Görünüm:** kâğıt ve mürekkep. Zemin `surface` (gündüz beyaz, gece #1C1C1E), yazılar `ink` ve `ink2`. Kelime serif kalın (20 pt), altında fosfor şeridi (`phosphorBand(.widget)`, `Shared/LockglowTheme.swift`): gündüz harflerin arkasında sarı, gece harflerin altından geçen ışıyan sarı çizgi, renklendirilmiş, cam ve kilit ekranında ince tek renk çizgi. Yalnız kelime ve çizgisi `.widgetAccentable()`. Renklendirilmiş modda yazılar sistemin birincil ve ikincil stillerine geçer: sistem bu modda yalnız saydamlığı korur, iki mürekkep tonu aynı görünürdü. İtalik ve yuvarlak yazı yok.
    - **Metin bloğu** `ViewThatFits` ile sığan en dolu düzeni seçiyor. Her satır ya bütün görünür ya hiç: "…" ile kesilmez, kelime ortasından bölünmez; son düzen yalnız kelime. Küçük: yalnız kelime + Türkçe anlam (kelime 24 → 20 → 17 pt, anlam kalın), iki düğme (Dinle, Sonraki). Orta: kelime + IPA (yer yoksa önce IPA düşer, kelime küçülmez) + seviye, karşılık, tanım (2 satır), örnek (1 satır, kelime kalın), sığarsa "Yeni kelime: HH:mm" (saatten sonra ek yok); önce tanım, örnek ve saat düşer, sonra anlam kısalır. Büyük yazıda kelime ve anlam xxxLarge'da durur, anlam düşmeden önce.
    - **Örnek kelimeden önce kesilmez:** cümle sığmazsa sonundan kesilir, kelime bütün kalırsa ("Please take a seat. The doctor will see you s…"). Kelime sonda kalıyorsa cümle kelimeden dört ya da iki sözcük önce "…" ile başlar, en geç kelimenin kendisinde ("… so I called the lost and found."). Gerçek kartlarda (934) yaklaşık hesapla kelime hiç kesilmiyor; 51 uzun örnekten 46'sı baştan gösteriliyor. Düzensiz biçimler (tooth → teeth) bulunamaz; o cümle baştan gösterilip sonundan kesilir. Örnek, kartın kelimeyi içeren en kısa örneği (tasarımdaki gibi): uygulama planı yazarken onu seçip plandaki `example_en` alanına koyar (`CardDetail.shortestExample`, `LemmaMatch`; eşit uzunlukta önce gelen kazanır). Kelimeyi içeren örnek yoksa ya da kelime tohum kelimesiyse (ayrıntı yok) kartın ilk örneği kalır. Akış kartı yine ilk örneği gösterir.
    - **Kilit ekranı:** dikdörtgen iki satır: kelime (serif kalın 17 → 15 pt, ince çizgi) ve Türkçe anlam (15 pt yarı kalın); tanım satırı yok. Opak griler (`WidgetColors.lockScreen`), saydamlık yok; zemini sistem çizer (`AccessoryWidgetBackground` plakası kalktı). Türkçe anlam hiç kesilmez: tam → kısa biçim (editörün `gloss_short`'u, yoksa ilk anlam) → gizli. xLarge–xxxLarge'da anlam sığmazsa varsayılan boyda gösterilir; AX boylarında sığarsa anlam da görünür, sığmazsa yalnız kelime, hiç taşmadan. Satır içi kısalır: "actually · aslında, gerçekte" → "actually · aslında" → "actually".
    - **VoiceOver:** Widget'larda Türkçe metin tr_TR, İngilizce metin en_US yerel ayarıyla; VoiceOver dili `WidgetVoiceOverTests` ile ölçülüyor. IPA gizli, anlam "Türkçesi: …", seviye "Seviye A2". Satır içi widget VoiceOver'a iki öğe verir (`accessibilityRepresentation`): kelime ve "Türkçesi: …".
    - **Çizimler:** `small-<kelime>` (gündüz), `-koyu` (gece), `-renkli` (renklendirilmiş taklidi: koyu zemin, ince çizgi); `-se` boyutları yalnız gündüz; `rect-` ve `inline-` kilit ekranı gibi koyu zeminde. Yaklaşık çizimler: WidgetKit'in kendi kenar boşlukları, renklendirmesi ve kilit ekranı canlılığı (vibrancy) cihazda ayrıca bakılmalı. Eski düzende (2026-10-13 çizimleri) en uzun kelime, karşılık, tanım ve örnek kartlarıyla SE ve 6.1" boyutlarında kesilme yoktu; yeni deneme kelimeleri: "Could you tell me the way to", "lost and found", "under the weather". Sonraki `screenshots.yml` turunda `rect-se-*-xxxl` görüntülerinde "date", "disagree", "stop" anlamla görünmeli. Düğmeler: madde 45.
19. Renklendirilmiş (tinted) ve cam (clear) modlarda okunabilirlik, ince şerit çizgisi ve düğme daireleri iOS 26 Liquid Glass'ta gerçek cihazda görülmeli. Arka plan artık `.fill.tertiary` değil, `surface`; sistem bu modlarda kendi zeminini koyar.
20. Gizlilik manifestleri: uygulama `UserDefaults` için `CA92.1` bildirir, widget hiçbir gerekçeli API bildirmez. Archive > Privacy Report ile doğrula; widget `FileManager`/`Data` üzerinden bir "dosya zaman damgası" API'sine dokunduğu çıkarsa `C617.1` ekle.
21. `getCurrentConfigurations` simülatörde/Debug'da boş dönebilir; "Widget Sağlığı" sayısı yalnızca bilgilendiricidir.
22. Widget kilit açılmadan önce plan dosyasını okuyamazsa tohum kelimelere düşer (beklenen); bunun çökme olmadan çalıştığı yeniden başlatma testinde görülmeli.
23. Soğuk açılışta widget dokunuşuyla gelen derin bağlantıda `scrollPosition(id:)` + `LazyVStack` birleşiminin o karta gerçekten kaydırdığı doğrulanmadı.
24. Otomatik imzalamanın App Group'u portala kendi başına kaydedeceği garanti değil (kurulum adım 4).
25. Ücretsiz katmanın "günlük" kısıtı uygulanmadı. İlk açılışta tohum kelimelerden gerçek içeriğe geçiş görünür bir kelime atlaması yapar (beklenen, süreklilik yalnızca eski bir plan varken uygulanır).
26. Gerçek yenileme sıklığı ve düğme gecikmesi yalnızca Release/TestFlight'ta ölçülebilir (Debug'da bütçe uygulanmaz).

**Öğrenme modülü bağlantısı, Tekrar ve Ayarlar (bu turda eklendi, hiç derlenmedi)**
27. `Learning` ürünü ilk kez uygulamaya bağlandı (`project.yml`). Statik kütüphane zinciri (`Learning` → `CoreModels`) doğrulanmadı; widget'a Learning eklenmedi, derlemede widget tarafında `Learning` sembolü aranırsa bir yerde yanlış import vardır.
28. `ReviewView`/`SettingsView`: `Binding(get:set:)` kapanışları `@MainActor` `AppModel` metotlarını çağırıyor (Swift 5 modunda en fazla uyarı beklenir; SDK bu kapanışları `@Sendable` işaretlediyse hata çıkabilir, çözüm: `AppModel` yerine yerel `@State` + `.onChange`). Ayrıca `@ViewBuilder` içinde `let`, `.toolbar { ToolbarItem(placement: .topBarTrailing) }`, `confirmationDialog(..., message:)`, `Section(content:header:footer:)`, `ProgressView(value:total:)` kullanıldı; hepsi iOS 17 API'si ama derlenmedi.
29. `AppModel`'in `@Published` başlangıç değerleri `AppPreferences` statik özelliklerinden geliyor (`@MainActor` sınıfta mülk başlatıcısı). Swift 5 modunda sorun beklenmiyor.
30. **Veri kaybı (2026-10-17'de giderildi, testli):** `ProgressStore.load()` artık üç durumu ayırır. Dosya var ama okunamıyorsa (ör. kilitli cihaz) hata fırlatır; uygulama o zaman deposuz kalır, hiçbir şey kaydetmez, olaylar posta kutusunda bekler, bir sonraki öne gelişte yeniden dener. Dosya çözülemiyorsa (bozuk ya da bu sürümün bilmediği biçim) silinmez, `progress-unreadable-<saniye>.json` adıyla kenara alınır ve `progress.backup.json` kullanılır. `save()` her gün ilk kayıttan önce diskteki (çözülebilen) dosyayı yedeğe kopyalar, yani bozulma en fazla o günün değişikliklerine mal olur. Kurtarma olduysa Ayarlar'ın üstünde bir uyarı çıkar, sekmede rozet görünür. Kenara alınan dosyayı geri yükleyen bir arayüz yok.
31. İlerleme dosyası ve "bugün çalışılan yeni kelime sayısı" ayrı yerlerde (JSON dosyası ve `UserDefaults`); sayaç yerel takvim gününe bağlı, saat dilimi değişirse gün kayar. İlerlemeyi sıfırlamak ikisini de siler.
32. Widget olayları artık uygulama öne gelince de işleniyor (`scenePhase == .active`); sözleşme (§6) "ön plana gelince" diyordu, bu onunla uyumlu. Plan yine yalnızca açılışta, arka plana geçerken, ayar değişince ve tur bitince yazılır. Ön plandaki bir "Bildim" cevabı widget kuyruğuna ancak tur bitince ya da arka plana geçince yansır.
33. Kuyruk 48 saatlik ufukla kuruluyor: bugün "Bildim" dediğin kelime yarın zamanı gelecekse bugünden widget kuyruğuna girer (öğrenilen kelimeler widget'ta hemen görünür). Beklenen davranış bu, ama kullanıcı için fazla erken tekrar gibi hissedilebilir; gerekirse `AppModel.queueHorizon` kısaltılır.
34. Widget'ta "Biliyorum" kelimeyi sınamadan `known` yapar (3 gün sonra Tekrar'da bir kez sorulur; bilirse sonra 30, 60, 120 günde bir; bilemezse yeni kelimeye döner, sıradaki Tanış'ta ilk gelir). Akış'taki "Biliyorum"dan sonra alt bildirimde "Geri al" var (5 sn; VoiceOver ya da Switch Control açıkken 10 sn). Yanlışlıkla basıldıysa Ayarlar'daki Bildiğin kelimeler listesinden (satırı kaydır ya da kelimeyi açıp "Öğrenmeye geri al") geri alınır: `Leitner.undoKnown` (hiç cevaplanmamışsa yeni, kutusu varsa hemen tekrar). Sözlük kartında da durum ve "Biliyorum"/"Öğrenmeye geri al" düğmesi var. Değişiklikten önce bekleyen widget olayları işlenir, sonra kuyruk yeniden yazılır (yeni plan_id, widget'ın bilinenler listesi sıfırlanır).
35. "5 dakika" hızlı deneme artık yok; en kısa aralık 30 dk. 30 dakikalık aralıkta 96 girişlik zaman çizelgesi 48 saati tam kapsar (eski 5 dk yalnızca 8 saati kapsıyordu). WidgetKit'in `.atEnd` ile yenilemeyi ne kadar hızlı verdiği (ve bütçesi) yine ölçülmedi (madde 26).
36. `ContentStore.freeCards` sırası SQL'de `level_rank ASC` ile başlıyor (A1 → A2 → B1...), yeni test bunu kanıtlıyor. `level_rank` ile `level` metninin tutarlı olması içerik hattının işi; hat bunu doğrulamıyorsa bozuk kart sırayı bozar.
37. Akış 5000 karta kadar yükleniyor (`AppModel.feedLimit`). ~550 kartta `LazyVStack` + `.scrollPosition(id:)` performansı ve derin bağlantıyla uzak karta kayma ölçülmedi (madde 23).
38. Tekrar sekmesinde `body` her değerlendirmede `nextReviewSession()` çağırıyor (tüm kelime listesini tarar). 550 kartta ucuz; 5000'de ölçülmedi.
39. Kişisel kurulum bölümündeki ücretsiz hesap sınırları Apple'ın sayfasından alındı, ama gerçek cihazda denenmedi; "doğrulanmadı" işaretli maddeler gerçekten bilinmiyor.
40. Akış ve Tekrar kartına örneğin Türkçesi ve "Dikkat" kutusu (ilk yaygın hata) eklendi (`CardDetailViews.swift`). **Simülatörde bakıldı (2026-10-13, iPhone SE 3 ve 16 Pro Max):** akış kartı ikisinde de sığıyor. Tekrar kartı SE'de taşıyordu (butonlar sekme çubuğunun altında kalıyordu); kart artık kendi içinde kayıyor, butonlar sabit. Daha uzun kartlar akışta denenmedi: akış sayfası kaymaz, `MistakeBox` açıklaması 3 satırla sınırlı.
41. Kart ayrıntısı (`AppModel.detail(for:)`) ana iş parçacığında, görünüm çizilirken veritabanından tek satır okur ve önbelleğe alır. Satır başına çok kısa sürmesi beklenir, ölçülmedi.
42. **Sesli telaffuz (`Speaker.swift`):** kelimenin ve örnek cümlelerin yanındaki hoparlör, cihazın kendi ABD İngilizcesi sesiyle (çevrimdışı) okur; yüklüyse geliştirilmiş/premium ses seçilir (Ayarlar > Erişilebilirlik > Sözlü İçerik > Sesler'den indirilebilir). Hız varsayılanın 0,9 katı. Ses oturumu `.playback`: sessiz modda da duyulur, diğer sesleri kısar. Tekrar kartında hoparlör kartın üstünde (kartın içindeki düğme kartı da açardı). Quiz sorusunda yok, cevabı söylerdi. Cihazda ses kalitesi ve gecikme denenmedi; CI simülatöründe yalnızca dokunuşta çökmediği sınanıyor. **Hazır kayıt ve ses karakteri (2026-10-24):** hoparlör önce `App/Resources/RecordedSpeech/`'teki yapay zekâ kaydını çalar (`WordSpeech.recordedPlayer`, `AVAudioPlayer`, hız `rate` ile); kayıt yoksa telefon sesi okur. Ayarlar'da "Ses karakteri" Kadın/Erkek: kaydın klasörünü (`us-female`, `us-male`) ve telefon sesinin cinsiyetini seçer. Kayıtları üretmek: [`docs/ses_kaydi.md`](../docs/ses_kaydi.md). Cihazda denenmedi.
43. **Günlük hatırlatma (`ReminderScheduler.swift`, `Learning/ReminderPlanner`):** Gerçek cihazda bildirim zamanlaması ve dokunuşla açılış denenmedi.
    - **Açma:** Ayarlar > Hatırlatma (varsayılan kapalı, 20:00). Açınca bildirim izni istenir; reddedilirse anahtar kapalı kalır ve iPhone Ayarları'na giden düğme çıkar. İlk turun özetinde "Tamam"dan sonra bir kez de sorulur ("Her gün 1 hatırlatma gönderelim mi?", `ReminderOfferSheet`); iOS izni yalnız "Evet, gönder"de istenir.
    - **Kurulum:** yerel bildirim, yedi gün ileriye tek tek (tekrarlanmayan) kurulur ve uygulama her arka plana geçişinde baştan yazılır. O günün tekrarı ve yeni kelime hedefi bittiyse o günün bildirimi kurulmaz. Uygulama 7 gün hiç açılmazsa bildirimler biter (bilerek: kullanılmayan uygulama rahatsız etmesin).
    - **İçerik:** Bildirim sayı ya da görev değil, bir kelime taşır ("borrow = ödünç almak"). 7 şablon günden güne döner; aynı şablon ve aynı kelime 5 gün içinde gelmez. Kelime, Tekrar'da 6 saat içinde sorulacak bir kelime olamaz. Düğme ve rozet yoktur. Dokununca Tekrar açılır, Tekrar boşsa kelimenin kartı açılır.
    - **Görmezden gelme:** Hatırlatma 3 gün görmezden gelinirse açılışta saat sorulur. 7 gün görmezden gelinirse hatırlatma durur ve bu söylenir.
    - **Tek sistem kartı:** Bir açılışta en çok bir sistem kartı çıkar (`SystemCardQueue`). Öncelik: kurtarma uyarısı, duraklatma notu, saat sorusu, widget ipucu, "Ara verdin" (Tekrar), günün sonu kartı (Akış). Kural `Learning/SystemCards.swift`'te (`SystemCardSlot`, Linux'ta test edilir). Arka plana gidilirken gelen geç karar düşer.
44. **Zor/Kolay düğmeleri:** quiz'de doğru cevaptan sonra "Zor muydu, kolay mı?" ve "Zor"/"Kolay" satırı (`QuizCardView.actions(isRight:)`; büyük yazıda alt alta). Tekrar kartındaki eski 2×2 düğme alanı kalktı: not cevaplardan gelir (Tanış + Hatırla, hatırlama ekranı). `tortoise` ve `hare` SF Symbols simgeleri (iOS 14+) kullanıldı; görünmezse yalnızca simge kaybolur, metin kalır. Aralıklar (zor = yarısı, kolay = iki kutu) sezgiyle seçildi, gerçek kullanımla ayarlanmalı (`Leitner.hardFactor`).
45. **Widget'ta hoparlör düğmesi (2026-10-21; CI'da derlendi, cihazda denenmedi):** Küçük ve orta ana ekran widget'ında hoparlör, kelimeyi (başlık sözcüğü) **uygulamayı açmadan** okur. Kilit ekranı widget'larına eklenmedi (cihaz kilitliyken düğmeler çalışmaz). Derleme: `build.yml` yeşil, Xcode 26.3, uyarısız (https://github.com/yusufuyar68/lockglow/actions/runs/39517676248, `macos-15-intel`). `WidgetSnapshotTests` çizimleri bu düzenle henüz üretilmedi: bir sonraki `screenshots.yml` turunda bak.
    - **Nasıl çalışıyor:** `Shared/SpeakWordIntent.swift` bir `AudioPlaybackIntent`. Apple'ın "Adding interactivity to widgets and Live Activities" belgesi: bu protokolü uygulayan intent widget eklentisinde değil **uygulamanın sürecinde** çalışır, intent uygulama hedefine de eklenmelidir (`NextWordIntent` gibi sıradan bir `AppIntent` widget eklentisinde çalışır). Bu yüzden `Shared/` klasörü uygulamaya, widget'a ve çizim testi paketine birlikte giriyor: widget `Button(intent:)` için tipi bilmeli, uygulama `perform()`'ü çalıştırıyor. Uygulama kapalıysa sistem onu arka planda başlatır (bunu `AudioPlaybackIntent` için Apple belgesi değil, geliştirici forumunda bir Apple mühendisi söylüyor). `perform()` konuşma bitene kadar (en çok 8 sn) bekler, 0,25 sn sonra ses oturumunu kapatır, sonra döner; dönünce uygulama yeniden askıya alınır. Apple, arka plandaki işlere 30 sn tanındığını yazıyor; bu yetiyor. `isDiscoverable = false`: Kestirmeler, Spotlight ve Siri'de "her metni oku" eylemi olarak görünmez, widget'tan çalışır (Apple belgesi).
    - **Ayar:** uygulamaya `UIBackgroundModes: audio` eklendi (`project.yml`). Apple: `.playback` kategorisi arka planda çalmak için bu modu ister; mod yoksa etkinleştirme `cannotStartPlaying` (561015905) ile düşer. Yalnızca Info.plist anahtarı; yetki (entitlement), profil ya da izin metni gerekmez. Eklentiye eklenmez.
    - **Ses:** `Shared/WordSpeech.swift`, `Speaker.swift`'in eski mantığıyla aynı: en-US, kurulu en iyi kalite (geliştirilmiş/premium varsa o), hız 0,9, oturum `.playback` + `.spokenAudio` + diğer sesleri kıs. `Speaker.swift` artık bunu kullanıyor, uygulamadaki davranış aynı. Widget tarafında `WordSpeechPlayer` konuşmayı bekler; ikinci dokunuş birincinin yerine geçer. Uygulamanın kendi ses oturumu etkinleşmezse yedek yol: `usesApplicationAudioSession = false` (oturumu sistem yönetir; WWDC20 10022). Bu yolun arka planda ses çıkarıp çıkarmadığı belgelenmemiş. İleride düşünülebilir: Apple'ın metin okuma için önerdiği `.voicePrompt` modu (podcast'i üstüne konuşmak yerine duraklatır); şimdilik uygulamayla aynı kalsın diye değiştirilmedi.
    - **Günlükler (cihaz denemesi için):** Xcode > Console, kategori `speech`. `widget speech in com.yusufuyar.vocabwidget, app audio session: true` = intent uygulamada çalıştı, normal yol. Paket adı `...widgets` ise intent eklentide çalışmıştır (beklenmez, ses çıkmaz). `app audio session: false` = yedek yol. Ayrıca `audio session not activated`, `widget speech timed out`, `audio session deactivation: ...` satırları sorunu gösterir.
    - **Düzen:** üç düğme 3 x 44 = 132 pt. Küçük widget'ın içerik genişliği SE'de 116, 6,1" telefonda 126 pt; bu yüzden küçük widget'ta yalnız iki düğme var: Dinle (sol alt) ve Sonraki (sağ alt). Biliyorum yalnız orta widget'ta ve uygulamada. Orta widget'ın içerik yüksekliği 126 pt (SE'de 116). Bu yüzden widget'ın sistem kenar boşlukları kapatıldı (`WordWidget`: `contentMarginsDisabled()`); görünümler boşlukları `widgetContentMargins` ile kendileri uyguluyor. Apple boşlukları seçerek uygulamak için bu yolu belgeliyor. Düğmeler bir katmanda (`overlay`) çiziliyor ve widget'ın dış kenarlarında 8 pt boşluğa uzanıyor (`buttonGroupOverflow`; küçükte sol, sağ ve alt, ortada üst, sağ ve alt). Görünen daire 34 pt (gündüz `surface2`, renklendirilmiş modda soluk bir iz), dokunma alanı 44 x 44 pt; daireler kenarlardan 13 pt içeride ve dokunma alanları widget'ın kök görünümünün içinde. Düğmelerin boşluk içinde kalan kısmı kadar (36 pt) bir yer tutucu var, metin düğmelerin altına girmez. **Sıra (orta widget, sağ sütun):** Biliyorum, Dinle, Sonraki. Sonraki kolay köşede (sütunun altı; küçükte sağ alt), Biliyorum ondan en uzakta (madde 34: sınamadan bilinen yapar), aradaki zararsız hoparlör durum değiştiren iki düğmeyi ayırıyor. Önceki sıra Sonraki, hoparlör, Biliyorum'du. Küçükte iki düğme alt satırda. Simgeler xxLarge'dan sonra büyümüyor (`dynamicTypeSize(...xxLarge)`; Sonraki simgesi yazı boyunun ~1,4 katı, AX1'de 34 pt daireden taşıyordu); grup büyümüyor, metni itmiyor. Hoparlörde `startsMediaSession` özelliği var: VoiceOver okuma sırasında susar. Satır içi aile kapatılan boşlukları düz `padding` olarak geri alıyor; dikdörtgen onları en az 5 x 12 pt'lik iç boşluk olarak kullanıyor. Cihazda bak. Bir düğmenin dışına dokunmak eskisi gibi uygulamayı açar.
    - **Gizlilik manifestleri değişmedi:** `AVSpeechSynthesizer` ve `AVAudioSession` Apple'ın "gerekçe istenen API" kategorilerinde (dosya zaman damgası, sistem açılış zamanı, disk alanı, etkin klavyeler, `UserDefaults`) yok; yeni veri toplanmıyor. Uygulamanın mevcut `CA92.1` bildirimi yeterli.
    - **Mağazaya gönderirken (TestFlight için gerekmez):** `audio` arka plan modu inceleme yönergesi 2.5.4 açısından sorulabilir (arka plan hizmetleri amacına uygun kullanılmalı). Burada kullanıcının dokunuşuyla kısa bir telaffuz için kullanılıyor. Forumda, inceleyen kişi sesi tetikleyemediği için reddedilen bir uygulama bildirildi; App Review notlarına widget adımlarını ve kısa bir ekran kaydını ekle.
    - **iOS 27 (ileride):** Apple'ın iOS 27 belgelerinde `allowedExecutionTargets` var; aynı belgeler sistemin arka plan intent'lerini uygulama eklentisinden çalıştırmayı tercih ettiğini yazıyor. CI Xcode 27'ye geçince bu intent'in yalnızca uygulamada çalışmasını açıkça seç ve günlükteki paket adına bak.
    - **Apple'ın belgelemediği, cihazda görülecekler:** (a) `AVSpeechSynthesizer`'ın `AudioPlaybackIntent` ile arka planda başlatılan uygulamada gerçekten ses çıkarması (Apple bu birleşimi anlatmıyor; navigasyon uygulamaları arka planda sesli komutu aynı API'yle, `audio` moduyla veriyor), (b) uygulama kapalıyken ilk dokunuşun gecikmesi (forumda "birkaç saniye" bildirildi; uygulamanın açılış hızına bağlı), (c) okurken ekran kilitlenirse konuşmanın yarıda kesilmesi (forumda uzun cümlelerde bildirildi), (d) sessiz modda duyulma, (e) çalan müziğin kısılıp geri gelmesi, (f) kilit ekranı, StandBy ve renklendirilmiş ana ekranda kenar boşlukları. **Sessiz kalırsa sırayla:** `AVSpeechSynthesizer.write` ile arabelleğe yazıp `AVAudioPlayer` ile çalmak; kelime sesini önceden kaydedip pakete koymak; son çare düğmeyi `openAppWhenRun` yapıp uygulamayı açarak okutmak.
46. **Açılış akışı ve deste seçimi (2026-10-20/21, Windows'ta yazıldı):** İlk sürüm CI'da (`build.yml`, 2026-10-20, Xcode 26.3) 151 paket testiyle yeşil. 21 Ekim'de üyelik süzgeci, özet satırı, `OnboardingGate`, yedek yeni kelime akışı ve detay sayfası eklendi. CI (21 Ekim, `build.yml`, macos-15-intel, Xcode 26.3): 159 paket testi geçti, uygulama ve widget derlemesi hatasız ve uyarısız; Linux işi (`linux_check.sh`) 147 testle yeşil. Ekranlara simülatörde bakılmadı; `screenshots.yml` açılış sayfalarını `0a`–`0e` adlarıyla çeker. Bakılacaklar:
    - SE'de ve en büyük yazıda seviye ve konu satırları sığıyor mu;
    - "Kilitli ekran / Ana ekran" düğmeleri `ViewThatFits` ile yan yana ya da alt alta doğru geçiyor mu;
    - tam ekran akış sekmelerin üstünde doğru açılıyor mu.

    Renkler tasarım taslağındaki değerlerle kodda (`GlowStyle.swift`, `Palette`). Taslak Swift'e geçirilince Asset Catalog renkleriyle değiştirilmeli. iOS 26'da kilitli ekranda "Özelleştir"den sonra "Kilitli Ekran / Ana Ekran" seçimi sorulup sorulmadığı Apple'ın kılavuzunda yazmıyor; rehber "seçmeni isterse" diyor. Cihazda bakılmalı.

## Learning modülü (uygulamaya bağlı)

`Packages/VocabKit/Sources/Learning` saf Swift'tir; `swift test` ile `LearningTests` çalışır (yeni testler `ProgressIngestTests`, `ReviewPlannerTests`, `LeitnerHardEasyTests`; beklenen değerler elle hesaplandı, hiç çalıştırılmadı). Kuyruk algoritmasının test beklentileri ayrıca bir Python kopyasıyla doğrulanmıştı.

Uygulamaya bağlandı (yalnızca uygulama hedefi, widget'a eklenmedi):
1. `project.yml`: uygulama hedefine `package: VocabKit, product: Learning`.
2. `AppModel.refreshWidgetPlan`: widget olayları `LearningEvent`'e çevrilip `ProgressIngest.apply` ile işlenir (`known` → `Leitner.markKnown`, `next`/`reveal` → `markExposure`, `unknown` → `review(.again)`), `ProgressStore` ile kaydedilir, olay dosyaları silinir; kuyruk `QueueComposer.compose(deck:fallbackFeed:progress:now:horizon: 48 saat, maxNew: günlük hedef × 2, limit: 96, pinFirst: şu an gösterilen kelime, patternOffset: saate bağlı slot sırası)` ile kurulur. `QueueBuilder` artık uygulamada kullanılmıyor (Scheduler testleri hâlâ onu kapsıyor).
3. Tekrar sekmesi cevapları `Leitner.review(.again / .hard / .good / .easy)` ile işler; `ReviewPlanner` tur kelimelerini, soru türünü, Tanış + Hatırla turunu ve Ayarlar'daki sayıları hesaplar.
4. Tek seferlik geçiş: `AppPreferences.knownWordIDs` içindekiler `markKnown` ile ilerleme dosyasına taşınır, sonra eski anahtar silinir.

### Zor ve Kolay notları (`Leitner.review`)

| Not | Düğme ya da cevap | Yeni kelime (kutu 0) | Kutudaki kelime | Biten (`known`) kelime |
|---|---|---|---|---|
| `again` | yanlış şık, "Bulamadım", Hatırla'da iki yanlış (özette "Bilemedim") | kutu 1, 10 dk sonra | iki kutu iner (`Leitner.lapseDrop` = 2, en az kutu 1), sonraki turda yine sorulur (yanlış sayılır) | kutu 3, 10 dk |
| `hard` | "Zor"; Hatırla'da ikinci denemede doğru | kutu 1, **12 saat** sonra | kutu **aynı**, o kutunun aralığının yarısı (kutu 1: 12 sa, 2: 1 g, 3: 2 g, 4: 4 g, 5: 8 g) | `known` kalır, adım aynı, o adımın yarısı (15/30/60 gün) |
| `good` | "Devam", "Buldum"; Hatırla'da ilk denemede doğru (özette "Bildim") | kutu 1, 1 gün | bir kutu ileri, yeni kutunun aralığı (1, 2, 4, 8, 16 gün) | `known` kalır, tazeleme bir adım uzar: 30 → 60 → 120 gün |
| `easy` | "Kolay" | kutu 2, 2 gün | **iki** kutu ileri, 5'i aşmaz (kutu 4 → 5, 16 gün) | `known` kalır, tazeleme bir adım uzar: 30 → 60 → 120 gün |

Gerekçeler ve seçimler:
- Sıra hep `again` < `hard` < `good` < `easy` (testle doğrulanır, her kutu için).
- `hard` ve `easy` yanlış sayılmaz (`lapses` artmaz); `reviews` her cevapta artar.
- Son kutuda (5) `good` ya da `easy` kelimeyi bitirir (`known`, ilk tazeleme 30 gün sonra). `hard` bitirmez: kutu 5'te 8 gün sonra yeniden sorulur.
- Kutu 4'te `easy` bitirmez, kutu 5'e geçirir: "en üst kutuyu aşmaz". Bitirmek için son kutuda bir doğru cevap daha gerekir.
- `known` kelimede (bitmiş ya da "Biliyorum" denmiş) `easy` ile `good` aynıdır: ikisi de tazelemeyi bir adım uzatır (`Leitner.refresherDays`, 120'de kalır). `hard` adımı korur, beklemeyi yarıya indirir ve kelime `known` kalır, yani Ayarlar'daki "bildiğin" sayısı değişmez.
- "Biliyorum" 3 gün sonra bir kez kontrol edilir (`Leitner.knownCheckDelay`). Kontrol doğruysa kelime `known` olur (adım korunur; hiç bilinmemiş kelimede 30 gün). Yanlışsa yeni kelimeye döner, sıradaki Tanış'ta ilk gelir.
- Yeni kelimeye `hard` kutu 1'e sokar (aksi hâlde kelime yeni kalır ve "yeni kelime" listesinde sonsuza dek çıkardı). 12 saatlik aralık sabah çalışılan kelimeyi aynı akşam "zamanı gelmiş" yapabilir; Ayarlar'daki "bugün tekrar" sayısı ve günlük hatırlatma bunu zaten `dueAt`'ten okuyor, ayrı bir ayar gerekmedi (`LeitnerHardEasyTests.testPlannersSeeAHardAnswerTwelveHoursLater`).
- `progress.json`'a yalnız isteğe bağlı alanlar eklendi (`last_reviewed_at`, `last_grade`, `first_reviewed_at`, `refresher_step`; yukarıda "İlerleme dosyası"). Eski bir dosya olduğu gibi açılır, yükseltmede hiçbir `dueAt` değişmez (testli).
- Widget "Bilemedim" (`unknown`) hâlâ yalnızca `again` üretir; widget'ta zor/kolay düğmesi yok.

(`undoKnown` artık Bildiğin kelimeler listesinde ve Sözlük kartında kullanılıyor.)


## Söyle: sesli telaffuz alıştırması (2026-10-20/21; CI'da derlendi ve testler geçti, cihazda denenmedi)

Akış kartında ve Sözlük ayrıntısında kelimenin yanında bir **mikrofon simgesi** var (`mic.circle`, 44 pt; VoiceOver: "Söyle: telaffuzunu dene"; `PronunciationPracticeView.swift`). Dokununca "Söyle" sayfası açılır:
1. Kelimeyi (ya da "Örnek cümle" seçilirse kartın örneğini) dinle.
2. Alttaki Söyle'ye dokun (sayfa orta yükseklikteyken de kaydırmadan görünür) ve söyle.
3. Telefon söyleneni cihazda tanır ve Türkçe geri bildirim verir: "Anlaşıldı!", "Neredeyse!", "Bir daha dene" ya da "Seni duyamadım".

**v1 kararları (2026-10-21, `docs/ozellik_planlari/soyle_telaffuz.md`):**
- Söyle, Leitner'ı ve ilerlemeyi etkilemez.
- Kalıcı Söyle sayısı yok: dosya, UserDefaults ve App Group'a yazım yok.
- Tekrar sekmesinde tur yok; yalnız bu sayfa.
- Öncelik iOS 26+. iOS 17–25 yolu yalnız derlenir.
- `WordCardView(word:detail:showsSay:)`: izin penceresi çıkmaması gereken bir yerde (açılış turunun "İlk kelime" sayfası) `showsSay: false` mikrofonu gizler.

**Tanıma (`PronunciationRecognizer.swift`).** Yalnız cihazda çalışır, sunucu yok:
- **iOS 26+:** `SpeechAnalyzer` + `DictationTranscriber`.
  - Hazır ayar `.phrase` (kısa söz, noktalamasız). Alternatifler ve güven puanı açık.
  - Apple'ın "Asking Permission to Use Speech Recognition" sayfası: `SpeechAnalyzer` modülleri sesi Apple sunucularına göndermez.
  - İngilizce (ABD) modelini uygulama ilk kullanımda `AssetInventory` ile kendisi indirir: bir kez; sistem saklar, uygulama boyutu büyümez. Böylece Türkçe klavyeli telefonda da İngilizce dikte kurmak gerekmez.
  - Mikrofon sesi `AVAudioEngine` ile alınır, `AVAudioConverter` ile analizcinin biçimine çevrilir. Hazır `AnalyzerInputConverter` ve `CaptureInputSequenceProvider` iOS 27 API'si, Xcode 26.3'te yok.
- **iOS 17–25:** `SFSpeechRecognizer` (en-US) ve `requiresOnDeviceRecognition = true`.
  - `supportsOnDeviceRecognition` false ise özellik çalışmaz, sunucuya düşülmez.
  - Üst üste 2 tanıma hatasında kullanıcıya İngilizce (ABD) klavye ekleyip Dikte'yi açması söylenir (`RecognitionFailures`, belirsizlik 8). Bu bilgi bir geliştirici forumundan (thread 731230), Apple belgesi değil.
- Ses yalnız deneme sürerken bellekte tutulur; dosyaya yazılmaz.
- Kayıt şu durumlarda iptal edilir:
  - sayfa kapanınca ya da mod değişince;
  - uygulama arka plana geçince;
  - ses oturumu kesilince (arama, Siri, alarm; `AVAudioSession.interruptionNotification`);
  - medya servisleri sıfırlanınca.
- **Ses oturumu:** dinlemeden önce `Speaker.stopAll()`, okuyan her şeyi susturur ve oturumu bırakır:
  - uygulamanın hoparlör düğmeleri (`Speaker`);
  - widget'ın hoparlör düğmesi (`WordSpeechPlayer.stop()`; `SpeakWordIntent` uygulama sürecinde çalışır).
  - Dinlerken oturum `.playAndRecord` + `.measurement` olur ve denemeden sonra kapatılır. Sonraki "Dinle" kendi `.playback` oturumunu kurar.

**VoiceOver duyuruları.**
- **Etiketler:** hedef kelime/cümle, Duyulan ve Doğrusu satırları `englishVoice()` + `accessibilitySpeechLanguage = "en-US"` etiketiyle. Sonuç paneli `.contain` (İngilizce satırlar ayrı öğe), başlık ve mesaj birlikte okunur. Cihazda dinlenecek (V6).
- VoiceOver şunları kendiliğinden duyurur:
  - model inerken: "İngilizce konuşma modeli iniyor.";
  - sonuç gelince: başlık + satır + varsa ipucu;
  - Söyle çalışamayınca: panelin başlığı ve mesajı (izin yok, tanıma çalışmadı, model inmedi, mikrofon başlamadı…);
  - izin iPhone Ayarları'ndan açılıp dönülünce: "İzin açık. Söyle artık çalışır."
- Kurallar:
  - dinleme başlarken duyuru yok (mikrofon duyardı; hafif titreşim var);
  - her biten deneme duyurulur, aynı sonuç art arda gelse de;
  - duyuru 0,3 sn sonra gider; o arada durum değiştiyse gitmez;
  - öncelik normal, `.high` değil: kesilemeyen duyuru "Bir daha söyle"ye dokununca sürer ve mikrofon onu duyar.

**İzinler (ilk "Söyle"ye dokununca, o anda).**
- **Mikrofon** (`NSMicrophoneUsageDescription`): her sürümde.
- **Konuşma tanıma** (`NSSpeechRecognitionUsageDescription`): yalnız iOS 17–25'te istenir. iOS 26'da Apple'ın belgesine göre `SpeechAnalyzer` için gerekmiyor; Apple'ın örnekleri de yalnız mikrofon izni istiyor.
- İki anahtar da Info.plist'te. Apple: Speech çerçevesini kullanan her uygulama eklemeli; anahtar yoksa `requestAuthorization` çöker. Metinler Türkçe (`project.yml`).

**İzin reddedilirse.**
- Mikrofon izni yoksa sistem yalnız sessizlik verir (`AVAudioApplication.requestRecordPermission` belgesi). Bu yüzden kayıttan önce izin kontrol edilir; Türkçe mesaj ve "Mikrofon iznini aç" düğmesi (iOS 17–25'te konuşma tanıma için "Tanıma iznini aç") çıkar. Düğme iPhone Ayarları'nda Lockglow sayfasını açar.
- Konuşma tanıma reddinde de aynısı olur.
- Ekran Süresi kısıtında yalnız bilgi mesajı çıkar.
- Her durumda Dinle (hoparlör), kartlar ve widget'lar izinsiz de çalışır.

**Kaydın bitişi (`TakeMonitor`).** Kayıt şu durumlardan biri olunca biter:
- konuştuktan sonra yaklaşık 0,9 sn sessizlik;
- hiç konuşma yoksa 5 sn;
- en çok 5 sn (kelime) / 10 sn (cümle);
- "Bitti" düğmesi.

Ses eşiği (0,02 RMS) bir tahmin; cihazda ayarlanmalı.

**Değerlendirme (`Packages/VocabKit/Sources/Pronunciation`).** Saf Swift; testleri `PronunciationTests`.
- **Fark etmeyenler:**
  - büyük-küçük harf, noktalama, aksan;
  - kesme işareti, tire ve boşluk ("second-hand" = "secondhand", "log in" = "login");
  - 0–99 arası rakam ya da yazı ("platform 4" = "platform four");
  - Genel Amerikan İngilizcesinde aynı okunan eş sesliler (`PronunciationCheck.homophoneGroups`: write/right, for/four, do/due, board/bored, need/knead...). Her grupta en az bir kelime destede var.
  - hedefin çevresindeki fazla kelimeler ("a spoon").
- **Sonuçlar:**
  - **Anlaşıldı:** en iyi sonuç hedefi içeriyor. Güven puanı 0,5'ten düşükse "Neredeyse" (`PronunciationCheck.lowConfidence`).
  - **Neredeyse:** şu üç durumdan biri; kaçan kelimeler yazılır:
    - hedef yalnız alternatiflerde;
    - birden çok kelimeli hedefin tek bir kelimesi duyulmadı ve yanlış duyulan kelime yok ("get up" yerine "get", "look forward to" yerine "forward to"). Yanlış edat "Bir daha dene" kalır ("turn on" yerine "turn off", "check in" yerine "check out");
    - en az 3 kelimelik cümlenin en az %75'i duyuldu.
  - **Bir daha dene:** diğer her şey.
  - **Seni duyamadım:** hiçbir şey tanınmadı.
- **İpuçları:** yalnız fark tek bir kalıba tam uyunca verilir. Kelimede kartın IPA'sıyla, cümlede yazımla bakılır.
  - **th** t/d/s/z/f/v gibi söylendi: think → sink, three → tree, birthday → bird day. IPA'da θ/ð yoksa ipucu yok ("Thomas").
  - **w ↔ v:** wine → vine, vest → west. IPA'da o ses yoksa ipucu yok ("write"taki sessiz w).
  - **Sondaki sesli ünsüz sertleşti:** bad → bat, dog → dock, bridge → britch ("'c' sesini 'ç' gibi"), rise → rice. IPA'nın son sesi ötümlü olmalı.
  - **Son ses yutuldu:** asked → ask, card → car.
  - Farklı kalıplar karışırsa ya da hiçbiri uymazsa genel mesaj çıkar: "Telefon farklı bir şey anladı. Önce Dinle'ye dokunup dinle, sonra yavaş ve net söyle." Duyulan, kendi "Duyulan" satırında İngilizce yazılır. Yanlış teşhis koymaktansa genel mesaj tercih edildi.
- **Test beklentileri:** önce aynı mantığın Python kopyasıyla doğrulandı. Buna planın 16 satırlık tablosu da dahil: edatlar, eş sesliler, eksik kelime. Sonra CI'da Swift'te geçti.
- **Sınır:** konuşma tanıyıcı bir telaffuz puanlayıcısı değil, en olası kelimeyi yazar.
  - Aksanlı ama anlaşılır bir söyleyişi doğru sayabilir.
  - Nadir bir kelimeyi doğru söylesen de başka kelime yazabilir.
  - Hedef kelime bilerek `contextualStrings`'e verilmedi: tanıyıcıyı hedefe çeker ve kontrolü anlamsızlaştırır.

**Gizlilik.**
- Veri toplanmıyor. Apple'ın App Privacy tanımına göre cihazdan çıkmayan veri "toplanmış" sayılmaz; App Store etiketinde Audio Data "No".
- Gizlilik manifestleri değişmedi: mikrofon ve konuşma tanıma "gerekçe istenen API" değil.
- "Söyle tanılama" (son 20 deneme) yalnız bellekte; söylenen metin tutulmaz.
- `docs/legal/` gizlilik politikalarına (TR/EN) "Söyle" bölümü eklendi.

### Söyle: cihazda denenecekler

- [ ] **İzin (iOS 26):** İlk "Söyle"de yalnız mikrofon izni sorulmalı. Konuşma tanıma izni de sorulursa ya da tanıma hep "Konuşma tanıma bu sefer çalışmadı" diyorsa, hata kodunu Söyle tanılama'dan not al: Apple'ın belgesine göre bu izin gerekmiyor.
- [ ] **Model indirme:**
  - İlk kullanımda "İngilizce konuşma modeli iniyor" görünür mü, ne kadar sürer?
  - İkinci seferde hemen başlamalı.
  - İlk kullanım uçak modundaysa "indirilemedi" mesajı çıkmalı.
  - Model indikten sonra uçak modunda da çalışmalı (cihaz içi).
- [ ] **Doğru söyleyiş:** "think", "three", "breakfast", "turn on", "o'clock" ve bir örnek cümle → "Anlaşıldı!".
- [ ] **Bilerek yanlış:**
  - "think" yerine "sink", "wine" yerine "vine", "bad" yerine "bat", "asked" yerine "ask" de: ilgili Türkçe ipucu çıkıyor mu?
  - Tanıyıcı bu yanlış kelimeleri gerçekten yazıyor mu? Yazmıyorsa ipucu yerine genel mesaj çıkar. Hangisinin çıktığını not al.
- [ ] **Örnek cümle:** bir kelimeyi atla → "Neredeyse!" ve kaçan kelime.
- [ ] **Kaydın bitişi:**
  - Sessiz kal → 5 sn sonra "Seni duyamadım".
  - Konuşup sus → yaklaşık 1 sn içinde kendiliğinden kontrol.
  - Gürültülü odada kendiliğinden durmuyorsa ya da konuşurken kesiyorsa eşiği (`TakeMonitor.speechLevel`) not al.
  - "Bitti" her zaman çalışmalı.
- [ ] **Güven puanı:** doğru söylenen kelimelerde sık sık "Neredeyse" çıkıyorsa `PronunciationCheck.lowConfidence` (0,5) düşürülmeli.
- [ ] **İzin reddi:** iPhone Ayarları'nda Lockglow, sonra Mikrofon'u kapat. Söyle'de Türkçe mesaj ve "Mikrofon iznini aç" çıkmalı; VoiceOver açıkken neden ve ne yapılacağı duyurulmalı. İzni açıp dönünce "İzin açık. Söyle artık çalışır." duyulmalı. İlk kez sorulan izne "İzin Verme" denince tek duyuru olmalı. Dinle çalışmaya devam etmeli.
- [ ] **Sesler birbirini bozmuyor:**
  - Söyle'den sonra hoparlör (Dinle) normal seviyede ve sessiz modda duyuluyor (ses oturumu `.playAndRecord`'dan `.playback`'e dönüyor).
  - Müzik çalarken Söyle → müzik kısılıp geri gelmeli.
  - Akış'ta "Dinle"ye dokunup hemen mikrofona dokun: okuma kesilmeli, kayıt başlamalı.
- [ ] **Widget hoparlörü + Söyle (bulgu 5):** ana ekran widget'ında uzun bir kelimenin hoparlörüne dokun, hemen uygulamayı açıp Söyle'ye dokun. Widget'ın sesi kesilmeli, kayıt başlamalı, "Mikrofon başlatılamadı" çıkmamalı.
- [ ] **Arka plan ve kesinti:** kayıt sırasında uygulamayı arka plana al, ayrıca kayıt sırasında Siri'yi çağır ya da kendini aratır. İkisinde de kayıt durmalı ve durum çubuğundaki turuncu mikrofon noktası kaybolmalı.
- [ ] **Kulaklık:** Bluetooth kulaklıkla telefon mikrofonu mu kulaklık mikrofonu mu kullanılıyor, tanıma çalışıyor mu? Bluetooth seçeneği bilerek eklenmedi.
- [ ] **Düzen:** iPhone SE'de uzun kelimede ("look forward to") başlık satırı (kelime, hoparlör, mikrofon) taşmıyor. Sayfa orta yükseklikte açılınca alttaki Söyle düğmesi kaydırmadan görünüyor.
- [ ] **VoiceOver:** mikrofon simgesi "Söyle: telaffuzunu dene" diye okunuyor. Söyle'ye dokununca hafif titreşim hissediliyor. Sonuç başlığı ve mesajı birlikte okunuyor. Sonuç, model inişi ve Söyle'nin çalışmaması kendiliğinden duyuruluyor (dinleme başlarken duyuru yok). Duyulan ve Doğrusu satırları İngilizce sesle. Duyurudaki İngilizce kelime İngilizce sesle mi?
- [ ] **Edatlar:** "get up" de ama "up"ı yut → "Neredeyse! Şunlar duyulmadı: up. Bir daha dene." "turn on" yerine "turn off" de → "Bir daha dene".
- [ ] **iOS 17–25 (cihaz varsa):** Dikte'yi kapat → ilk denemede "Konuşma tanıma bu sefer çalışmadı", ikincisinde kurulum anlatımı; tanılamadaki hata kodunu not al.

### Söyle: bilinen belirsizlikler

1. **Derlendi ama çalışırken görülmedi.** iOS 26 API imzaları Apple belgesinden alındı ve CI'da Xcode 26.3 ile derlendi (2026-10-20, uyarısız). Şunlar cihazda görülecek:
   - güven niteliğinin (`ConfidenceAttribute`) gerçekten dolu gelip gelmediği;
   - alternatiflerin sayısı;
   - modelin indirme süresi.
   - `cancelAndFinishNow()` belgede bir yerde `async`, bir yerde `throws` görünüyor; bu yüzden hiç çağrılmıyor. Girdi akışını bitirmek yetiyor.
   - Cihazda Ayarlar > Widget sağlığı > Tanılama > "Söyle tanılama"da son 20 deneme görünür (motor, aday sayısı, güven, güven aralığı, hata kodu, dinleme ve model indirme süresi). Söylenen metin tutulmaz; yalnız bellekte.
2. **`AVAudioConverter` giriş bloğu:** kapandı. Blok Apple'ın WWDC25 örneğindeki gibi yakalanan bir `var`'ı değiştiriyor; macOS CI (Xcode 26.3) uyarı vermiyor. SDK değişince yeniden bakılır.
3. **`installTap` bloğu** `nonisolated static` bir fonksiyonda kuruluyor. Ana aktörde kurulan kapanış ses iş parçacığında çağrılınca Swift 6 modunda çöker. Proje Swift 5 modunda; yine de ayrı tutuldu.
4. **Tanıma kalitesi:** `.phrase` hazır ayarının tek kelimede ne kadar iyi tanıdığı, güven puanının ölçeği ve kaç alternatif geldiği bilinmiyor. Cihazda Ayarlar > Widget sağlığı > Tanılama > "Söyle tanılama"da görülür (güven, aday sayısı, indirme süresi, hata kodu).
5. **Simülatör:** mikrofon ve model güvenilir değil (Apple'ın örneği simülatörde çalışmıyor). Gerçek deneme yalnız telefonda.
6. **Tekrar sekmesinde telaffuz turu yok** (2026-10-21 kararı; plan Aşama 2). `QuizCardView` çizim testi hedefine de derlendiği için, oraya düğme eklemek `project.yml`'de o hedefe de bu dosyaları eklemeyi gerektirir.
7. **Renkler:** kapandı. Ana düğme tema stilinde (`PrimaryCapsuleButtonStyle`).
8. **iOS 17–25 hata eşlemesi (G1) yapıldı.** 1110 (konuşma yok) ve iptal (216, 301) dışındaki hatalar ve 4 sn cevapsızlık "Konuşma tanıma bu sefer çalışmadı" olur; üst üste 2'sinde İngilizce (ABD) klavye ve Dikte kurulumu anlatılır (`RecognitionFailures`). Hata kodu Söyle tanılamada görünür; 4 sn içinde sonuç gelmezse "timeout" yazılır. 216 ve 301'in iptal olduğu geliştirici raporlarından; cihazda tanılamada doğrulanmalı. iOS 17–25 yolu hâlâ cihazda denenmedi.
9. **`stopAll` ile widget sesi:** kapandı. `WordSpeechPlayer.stop()` oturumu hemen bırakır ve sayacı (`generation`) artırır. `end`'in 250 ms sonraki oturum kapatması yalnız sayaç değişmediyse çalışır. Böylece `stop()`'tan hemen önce biten widget konuşması yeni başlayan kaydın oturumunu kapatmaz; bekleyen intent `stop()` ile hemen döner. Cihazda denenmedi (yukarıda "Widget hoparlörü + Söyle").
10. **UI testi:** kapandı. `LockglowScreenshotTests` "8b-soyle-sayfasi" ve "11-sozluk-uzun-lemma" görüntülerini alıyor.
11. **Model inerken duyuru:** VoiceOver açıkken dinleme, indirme başladıktan en az 4 sn sonra başlar (`PronunciationRecognizer.downloadAnnouncementSeconds`), duyurunun sonu kayda girmesin. Yavaş VoiceOver hızında yetmeyebilir; cihazda bakılacak.
12. **Duyuru zamanlaması:** duyurular 0,3 sn sonra, normal öncelikle gider. VoiceOver'ın kendi okuması bir duyuruyu kesiyorsa süre artırılmalı; `.high` kullanılmamalı (kesilemez, yeni kayıtla çakışır).
