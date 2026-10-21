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
   ├─ CoreModels               WidgetWord, Level, WidgetEventType, SeedWords, DeepLink, CardDetail (kartın tam JSON'undan örnekler + Türkçe notlar), ContentTopic (seçilebilir konu)
   ├─ TextFold                 fold() (sözleşme §4)
   ├─ SharedState              AppGroupStore, EventMailbox, WidgetPlan/State/Event
   ├─ Scheduler                TimelinePlanner, RotationInput, RotationCursor, QueueBuilder (saf fonksiyonlar)
   ├─ ContentStore             GRDB ile salt okunur content.sqlite (yalnızca uygulama)
   └─ Learning                 Leitner (5 kutu), QueueComposer (6 tekrar : 3 yeni : 1 hatırlatma), DeckFilter (konu ve seviye seçimi), ProgressIngest (widget olayları → ilerleme), ReviewPlanner (tekrar turu, sayılar), ProgressStore (yalnızca uygulama)
```

Kural: widget yalnızca `CoreModels`, `SharedState`, `Scheduler` bağlar. SQLite açmaz, `ContentStore`/`TextFold`/`Learning`/GRDB bağlamaz. `Learning` yalnızca uygulama hedefindedir.

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
- **Plan yeniden yazma (uygulama):** olaylar ilerlemeye işlendikten sonra eski plan + state ile `wordAt(şimdi)` hesaplanır, yeni kuyruk **o kelimeyle başlar** (`QueueComposer.compose(feed:progress:now:horizon:maxNew:limit:pinFirst:)`, `pinFirst` = şu an görünen kelime), yeni `plan_id` ve `updated_at = şimdi` yazılır. Böylece yeniden yazma anında görünen kelime aynı kalır ve oradan devam eder. Kuyruk en çok 96 kelime, ufuk 48 saat, yeni kelime sınırı `günlük yeni kelime × 2`. İçerik henüz yüklenmediyse (açılışta arka plana geçme) plan değiştirilmez. Aralık değişirse de görünen kelime korunur.
- **Olay işleme:** widget olayları uygulama açılırken, öne gelirken (`scenePhase == .active`) ve plan yazarken `ProgressIngest` ile ilerlemeye işlenir (eskiden yeniye): `known` → `markKnown`, `next`/`reveal` → `markExposure`, `unknown` → `review(.again)`. Sıra: ilerleme dosyasını kaydet, **sonra** olay dosyalarını sil; kayıt başarısız olursa dosyalar kalır ve bir sonraki sefer yeniden işlenir. Bozuk dosyalar silinir, okunamayanlar (kilitli cihaz) bırakılır.
- **İlerleme dosyası:** `Application Support/progress.json` (`ProgressStore`, uygulamaya özel, tek yazar: `AppModel`). Eski `UserDefaults` anahtarındaki (`lockglow.knownWordIDs`) bilinen kelimeler ilk açılışta bir kez `markKnown` ile bu dosyaya taşınır, sonra anahtar silinir.
- **Ayarlar (UserDefaults):** değişim sıklığı (5, 15, 30, 60, 120 dk; varsayılan 60) ve günlük yeni kelime (5, 10, 15, 20; varsayılan 10). İkisi de değişince plan hemen yeniden yazılır. Widget aralığı en az 300 sn'ye sıkıştırır.
- Tarihler (anchor, `updated_at`) JSON'a tam saniye olarak yazılır. Sınırlar tam saniyeye düştüğü için (tam sayı aralık ve ofset) saniyeye aşağı yuvarlamak hangi sınıra düştüğünü değiştirmez.
- **Zaman çizelgesi:** en çok 48 saat ve 96 giriş, politika `.atEnd`, widget ağa çıkmaz. Tüm kelimeler bilinense widget boş kalmasın diye bilinenler yok sayılır.
- **Aralık ayarı:** "Ayarlar" sekmesinden (5 dakika hızlı deneme içindir). Widget'ı düzenleme (yapılandırma) ekranı yok (`StaticConfiguration`).
- **Gösterim sırası (A2 öğrenen):** widget'ta ve akış kartında kelime, sonra Türkçe karşılık (bir kademe iri ve kalın), sonra kısa İngilizce tanım, sonra örnek. Kilit ekranı dikdörtgeni: kelime, karşılık, `def_micro`.
- **Sözlük:** İngilizce ya da Türkçe önekle arama (`ContentStore.search`, Türkçe harfler katlanır: "kahv" → breakfast); sonuca dokununca kartın tamamı (`WordDetailView`): tüm örnekler ve Türkçeleri, yaygın hatalar, not, ipucu, eşdizimler. UI testi aramayı ve kart açılışını da çeker.
- **Tekrar sorusu:** zamanı gelen (daha önce çalışılmış) kelime kartla değil, kartın boşluk doldurma sorusuyla sorulur: cümle + 4 şık (`QuizCardView`, şık sırası kelime kimliğine göre sabit karışık). Yanlış → `review(.again)`; doğru → `review(.good)` ("Devam"). Doğru cevaptan sonra "Zordu" (`.hard`) ve "Kolaydı" (`.easy`) düğmeleri de çıkar; yanlışta çıkmaz. Böylece ilk çalışmadan sonraki tekrarlar da zor/kolay notu alabilir (ilk çalışma kartla yapıldığı için yalnızca orada 4 düğme vardı). Cevaptan sonra doğru şık ve Türkçe anlam gösterilir. `QuizCardView` sonucu kendi `QuizOutcome` türüyle bildirir, `ReviewView` bunu `ReviewGrade`'e çevirir (dosya `LockglowWidgetSnapshots`'a da derlendiği ve orada `Learning` bağlı olmadığı için). Yeni kelime önce kart olarak öğrenilir. Görünüm `QuizSnapshotTests` ile çizilip bakıldı.
- **Tekrar sekmesi:** önce zamanı gelen kelimeler (en çok 20 kart/tur, en çok gecikmiş önce), yoksa günlük hedef kadar yeni kelime (akış sırasıyla; bugün zaten çalışılanlar hedeften düşülür). Kart cevabı dört düğmeyle (2×2, iPhone SE'de büyük yazıda da sığsın diye): "Bilemedim" → `review(.again)`, "Zor" → `.hard`, "Bildim" → `.good`, "Kolay" → `.easy` (kutu geçişleri aşağıda, "Zor ve Kolay notları"); her cevapta ilerleme kaydedilir, tur bitince (ya da "Bitir"e basılınca) plan yeniden yazılır. Bilemedim denen kelime 10 dakika sonra yeniden "zamanı gelmiş" olur (aynı turda tekrar sorulmaz). Hedef dolunca "bugünlük tamam" ekranı çıkar; isteyen "N yeni kelime daha" ile devam eder.
- **İmleç anlamı (sözleşmeden sapma, §6'ya işlenmeli):** `widget_state.json`'a `cursor_anchor` (ISO 8601) eklendi; `cursor_offset` artık "`cursor_anchor` anında dönüşümün bulunduğu kuyruk sırası" demek, saf bir "+1" sayacı değil.
- **Hizalama:** yerel saat dilimi ofseti kullanıldığı için "günlük" sınır yerel gece yarısına düşer (yoksa UTC gece yarısı = Türkiye'de 03:00 olurdu).
- **Açılış akışı (`OnboardingView`):** ilk açılışta bir kez, tam ekran. Ödeme duvarı yok. Dört sayfa:
  1. **Seviye:** A1 "Yeni başlıyorum", A2 "Temel konuşabiliyorum", B1 "Günlük konuşmayı anlıyorum". Her seçenekte o seviyenin kelime sayısı yazar. Seçmeden "Devam" basılmaz.
  2. **Konular:** "Tümü" ve gruplar altında konular, her birinde kelime sayısı. Hiç seçilmezse hepsi.
  3. **Widget nasıl eklenir:** "Kilitli ekran" ve "Ana ekran" adımları (`WidgetGuideContent`). Düğme adları Apple'ın iOS 26 Türkçe iPhone kılavuzundan: iPhone'da widget'ın adı "araç takımı"; "Düzenle", "Araç Takımı Ekle", "Özelleştir", "Bitti".
  4. **İlk kelime:** destenin ilk yeni kelimesi, Akış kartıyla (`WordCardView`). Tekrar sekmesinin ilk yeni kelimesi de bu.

  Her sayfada "Atla" var: akışı bitirir, o ana kadar seçilenleri uygular. Bitince `lockglow.onboardingCompleted` yazılır, akış bir daha kendiliğinden açılmaz. Ayarlar > Yardım > "Açılış ekranlarını yeniden göster" yeniden açar; orada şimdiki seçim seçili gelir. UI testleri `-lockglow.onboardingCompleted YES` ya da `NO` başlatma argümanıyla akışı atlar ya da zorla açar.
- **İlk plan ve açılış akışı:** yeni kurulumda (akış bitmemiş ve `widget_plan.json` yok) `AppModel.start` planı yazmaz. İlk planı akıştaki seçim yazar (konular sayfasından çıkınca ya da "Atla"da). O an eski plan olmadığı için sabitlenecek kelime yok; kuyruk destenin ilk kelimesiyle başlar. Böylece 3. sayfada eklenen widget hemen seçilen kelimeleri gösterir. Kullanıcı akış bitmeden uygulamadan çıkarsa plan yine yazılır (`sceneDidEnterBackground`). Planı olan kullanıcıda (güncelleme) her şey eskisi gibi: plan açılışta yazılır, seçim değişince görünen kelime sabitlenir.
- **Deste (konu) seçimi:** konu, kartın `primary_topic`'i (`category` tablosu, sözleşme §3). Akışlar (s1–s13) veritabanında yok ve bir akışta birden çok konu var (ör. s11'de seyahat, şehir ve phrasal verb). Bu yüzden seçim akışa göre değil, konuya göre.
  - `ContentStore.topics()`: en az bir ücretsiz ve hassas olmayan kartın birincil konusu olan kategoriler. Sıra `category.sort`, yanında kart sayısı. `primaryTopicByCard()`: kart kimliği → konu.
  - 5'ten az kartı olan konu seçim listesinde yok (`AppModel.minimumTopicCards`). Tek başına seçilse widget aynı birkaç kelimeyi döndürürdü. O kartlar "Tümü"nde var.
  - Konular `category.grp` harfine göre Türkçe başlıklar altında: A Günlük hayat, B Seyahat ve kültür, C İnsanlar ve duygular, D İş hayatı, E Bilim ve teknoloji, F Sanat ve eğlence, G Dil kalıpları, H Zengin kelimeler, I Sınavlar.
  - Saklama: `UserDefaults` `lockglow.selectedTopicIDs` (boş = hepsi) ve `lockglow.startLevel`. "İlerlemeyi sıfırla" bunlara dokunmaz.
  - Ayarlar > Öğrenme: "Başlangıç seviyesi" ve "Konular" (`TopicPickerView`). Konu seçimi ekran kapanınca bir kez uygulanır, her dokunuşta plan yazılmaz. Alt yazıda destedeki kelime sayısı görünür.
- **Deste neyi etkiler (`DeckFilter`, saf ve testli):**
  - `AppModel.words` bütün kelimeler, `feedWords` deste. `DeckFilter.feed` önce konuya göre süzer, sonra seviyeye göre sıralar.
  - Süzgeç: seçilen konuların kelimeleri, eski sırasıyla. Seçim boşsa ya da hiçbir kelimeye uymuyorsa (içerikten kalkmış konu, tohum kelimeler) bütün kelimeler gelir. Seçim desteyi hiç boşaltmaz.
  - Seviye sırası (kararlı): önce seçilen seviye, sonra üstündekiler (kolaydan zora), sonra altındakiler (yakından uzağa), en sonda seviyesi bilinmeyenler. A2 seçen kullanıcı A2, B1, sonra A1 görür. Hiçbir kelime düşmez. Seviye seçilmemişse sıra değişmez (A1 önce).
  - Desteyi kullananlar: Akış sekmesi, widget kuyruğu, Tekrar'ın yeni kelimeleri, günlük hatırlatmadaki yeni kelime sayısı (`ReminderPlanner.plan(newWordFeed:)`).
  - Bütün kelimeleri kullananlar: zamanı gelen tekrarlar (öğrenmeye başlanan kelimenin tekrarı konu değişince kesilmez), Ayarlar'daki sayılar, bildiğim kelimeler, Sözlük.
- **Kuyruk ve süreklilik:** plan `QueueComposer.compose(deck:fallbackFeed:...)` ile kurulur. Seçim değişince plan, her ayar değişikliğindeki gibi hemen yeniden yazılır.
  - `pinFirst` (şu an görünen kelime) desteden olmasa bile ilk sırada kalır. Görünen kelime sınıra kadar değişmez; sonraki sınırdan itibaren destenin kelimeleri döner.
  - Destenin kendi kelimesi kalmamışsa (hepsi biliniyor ve zamanı gelmemiş) kuyruk bütün konulardan, aynı seviye sırasıyla kurulur. Widget boş kalmaz.
  - Destede yalnızca zamanı gelmemiş öğrenilen kelimeler varsa onlar döner, yedeğe geçilmez.
- Derin bağlantı: widget'a dokunmak `vocabwidget://word/<id>` açar; uygulama akışta o karta kaydırır. Kelime destede yoksa (konu değişiminden hemen sonra sabitlenen kelime) Akış olduğu yerde açılır. Şema `CoreModels/DeepLink.swift` ve `project.yml` (`CFBundleURLSchemes`) içinde; ikisi aynı kalmalı. Markadan bağımsızdır, ad değişince bağlantılar bozulmaz.

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

`ios/Tools/linux_check.sh`, VocabKit paketini ve uygulamanın arayüz dışı dosyalarını (`AppModel`, `AppPreferences`, `ContentLoader`, `ReviewSession`, `WidgetHealth`) Docker'daki resmi `swift:6.2` imajında derler ve paketin birim testlerini çalıştırır. Windows'ta Git Bash'te, Linux'ta ve Mac'te çalışır, Docker'ın açık olması yeter.

```bash
bash ios/Tools/linux_check.sh
```

- Kopya üzerinde çalışır, projedeki dosyalara dokunmaz (`linux_check_prepare.py`).
- Apple'a özel modüller (`Combine`, `os`, `WidgetKit`) ve GRDB'li `ContentStore` için `Tools/linux-stubs/` altındaki sahte modüller kullanılır. `ContentStore` sahtesinin genel imzaları gerçeğiyle aynı tutulmalı.
- **Derlenmeyenler:** SwiftUI görünümleri, widget'lar, App Intents ve gerçek `ContentStore` (GRDB). Bunlar yine Xcode'da derlenir.
- Son sonuç (2026-10-12, Swift 6.2.4): derleme hatasız, **97 test geçti**. Kasıtlı yanlış bir argüman etiketiyle denendi: kontrol hatayı yakalıyor.
- Ayrıca gerçek `content.sqlite`'taki 479 kartın tam JSON'u Swift'teki `CardDetail` ile çözüldü: 479/479 başarılı.

## GitHub Actions (Mac olmadan tam derleme)

Depo: `github.com/yusufuyar68/lockglow` (özel). İki iş akışı var:

- **`build.yml`** (`main`'e her push'ta): Python testleri ve taslak kartların katı doğrulaması (Linux); VocabKit testleri (GRDB'li `ContentStore` dahil) ve uygulama + widget'ın **imzasız simülatör derlemesi** (macOS, en yeni Xcode). Derleme günlüğü `ios-build-log` adıyla saklanır.
- **`screenshots.yml`** (elle: `gh workflow run screenshots.yml`): `LockglowUITests` ana ekranları gezip ekran görüntüsü alır; iPhone SE ve Pro Max simülatöründe çalışır, görüntüler `screenshots` adıyla yüklenir. Widget'ları ana ekrana ekleyemez, onlar cihazda bakılır.

macOS dakikaları özel depoda 10 kat sayılır; `build.yml` ~2, `screenshots.yml` ~6 dakika sürer. İlk sonuç (2026-10-13, Xcode 26.3): derleme hatasız ve uyarısız, 107 paket testi geçti.

## Widget spike test kontrol listesi

Hazırlık: uygulamayı en az bir kez aç (plan yazılsın). "Ayarlar > Widget sağlığı" ekranında App Group "Erişilebilir", kuyruk boyutu > 0 olmalı.

- [ ] **Ekleme:** Ana ekrana küçük ve orta widget, kilit ekranına dikdörtgen ve satır içi widget ekle. Hepsinde kelime görünüyor, hiçbiri boş değil.
- [ ] **Uygulama açılmadan ekleme:** Uygulamayı sil, yeniden kur, **açmadan** widget ekle. Tohum kelimeler (breakfast, borrow, actually...) görünmeli.
- [ ] **Galeri:** Widget galerisinde önizleme anında ve anlamlı (örnek kelime).
- [ ] **Sınırlarda değişim:** Kelime her saat başında değişmeli (14:00, 15:00...), 14:23 gibi bir dakikada değil. Ana ekran ve kilit ekranı widget'ları aynı anda aynı kelimeye geçmeli (hızlı test için Ayarlar > Kelime değişim sıklığı > 5 dakika).
- [ ] **Süreklilik (en önemli):** Birkaç sınır geçtikten sonra uygulamayı aç ve ana ekrana dön (plan yeniden yazılır): widget'taki kelime **değişmemeli**, sonraki sınırda sıradaki kelimeye geçmeli. Aynısını widget'ı yeniden yükleyerek (Widget Sağlığı > "Yalnızca zaman çizelgelerini yenile") dene. Kelimeler başa sarmamalı, tekrar etmemeli.
- [ ] **Orta widget etiketi:** "Sonraki HH:mm" doğru saati gösteriyor (sığmazsa gizlenmesi normal).
- [ ] **Sonraki:** Küçük ve orta widget'ta "sonraki" okuna dokun. Kelime hemen değişir, geri atlamaz; sonraki sınırda bir sonrakine geçer. "Widget Sağlığı"nda widget imleci değişir, bekleyen olay sayısı artar. Düğmeler rahat basılıyor (44 pt).
- [ ] **Biliyorum:** Onay işaretine dokun. Kelime kaybolur ve bir daha çıkmaz, sıra bozulmaz. Bekleyen olay artar.
- [ ] **Seslendirme (widget):** Küçük ve orta widget'ta hoparlöre (ortadaki düğme) dokun: uygulama **açılmaz**, kelime ABD İngilizcesiyle okunur. Üç durumda dene: uygulama açıkken, uygulama arka plandayken, uygulama kapatıldıktan sonra (görev değiştiriciden kaydır; ilk dokunuş birkaç saniye geç kalabilir). Sessiz modda da duyulmalı; çalan müzik kısılıp sonra geri gelmeli; kelimenin sonu kesilmemeli. Xcode > Console'da `speech` kategorisinde `widget speech in com.yusufuyar.vocabwidget, app audio session: true` görünmeli (`.widgets` ya da `false` görünürse, ya da `audio session not activated` / `widget speech timed out` çıkarsa madde 45'teki sıraya bak). Üç düğme SE'de ve büyük ekranda rahat basılıyor mu (uçtaki düğmelerin dış kenarına da dokun)? Kilit ekranı widget'ları ve StandBy eskisi gibi görünüyor mu (kenar boşlukları artık elle uygulanıyor)?
- [ ] **Kilit ekranı:** Dikdörtgen/satır içi widget'ta buton yok. Cihaz kilitliyken küçük widget butonları çalışmaz (beklenen).
- [ ] **Arka plana alma:** Birkaç "sonraki/biliyorum" sonrası uygulamayı aç, sonra ana ekrana dön. Konsolda (Xcode > Console, `widget event` ara) olaylar loglanır, bekleyen olay 0 olur (uygulama öne gelince de 0 olur), yeni plan_id yazılır, widget güncellenir, "biliyorum" denen kelimeler artık yok. Görünen kelime aynı kalır ve dönüşüm oradan devam eder.
- [ ] **Dokunma:** Widget gövdesine dokun: uygulama açılır ve akışta o kelimeye kayar (soğuk açılışta da).
- [ ] **Release yapılandırması:** `Lockglow-Release` scheme'i ile çalıştır (Debug'da widget yenileme bütçesi uygulanmaz). Birkaç saat bırak, zaman çizelgesi girişlerinin kaçırılmadan değiştiğini doğrula. Ayrıca TestFlight derlemesiyle bir gün dene.
- [ ] **Düşük Güç Modu:** Aç, widget'ın bayat kalıp kalmadığını ve uygulama arka plana geçince yenilenip yenilenmediğini izle.
- [ ] **Yeniden başlatma:** Cihazı yeniden başlat, **ilk kilit açmadan önce** kilit ekranı widget'ına bak: yer tutucu/tohum kelime görünebilir, çökme olmamalı. Açtıktan sonra kendini toparlamalı.
- [ ] **Görünüm modları:** Tinted/clear ana ekran (iOS 18/26), kilit ekranı vurgulu modu, StandBy: metin okunuyor, kelime vurgulu, anlam renge bağlı değil.
- [ ] **Yazı boyutu:** Dinamik Tür'ü en büyük ve en küçük yap: küçük widget'ta buton satırı kesilmiyor mu?
- [ ] **Bellek/çökme:** Console'da widget extension'ın jetsam/0xDEAD10CC çökmesi yok.
- [ ] **Tekrar sekmesi:** İlk açılışta "Bugünün yeni kelimeleri" önerilir. Karta dokun: Türkçe karşılık iri, altında tanım ve örnek. "Bilemedim"/"Zor"/"Bildim"/"Kolay" ile ilerle (SE'de dört düğme de kartın altında, sekme çubuğuna taşmadan görünmeli), tur sonunda özet çıkar ("bildin" = Bilemedim dışındaki cevaplar). İkinci turda quiz sorusunu doğru yanıtla: "Devam" altında "Zordu" ve "Kolaydı" çıkmalı, yanlışta çıkmamalı. Uygulamayı kapat-aç: cevapladığın kelimeler yeni kelime listesinde yok. Widget'ta "Biliyorum" dediğin kelime Tekrar'da yeni olarak çıkmaz.
- [ ] **Ayarlar sekmesi:** Sıklığı 5 dakikaya çek: widget'taki kelime değişmez, sonraki sınırda yeni aralıkla ilerler. Günlük yeni kelimeyi değiştir: widget kuyruğu yeniden yazılır. Sayılar (bildiğim / öğrenmekte / bugün tekrar) Tekrar sekmesiyle tutarlı. "İlerlemeyi sıfırla" onay sorar, sonra sayılar 0 olur.
- [ ] **Açılış akışı:** Uygulamayı sil, yeniden kur, aç. Dört sayfa görünmeli: seviye, konular, widget rehberi, ilk kelime. Seviye seçmeden "Devam" pasif. Rehberdeki adımlarla kilitli ekrana ve ana ekrana widget ekle; düğme adları (Özelleştir, Araç Takımı Ekle, Düzenle, Bitti) iPhone'dakilerle aynı mı, bak. Widget seçilen konunun kelimesini göstermeli. "Başla"dan sonra uygulamayı kapat-aç: akış bir daha açılmaz. Ayarlar > Yardım'dan yeniden açılır, şimdiki seçim seçili gelir. "Atla" her sayfada çalışır.
- [ ] **Konu seçimi:** Ayarlar > Öğrenme > Konular'da yalnız "Seyahat & Turizm"i seç, geri dön. Widget'taki kelime sınıra kadar aynı kalır, sonra yalnız seyahat kelimeleri döner. Akış yalnız seyahat kartlarını gösterir. Tekrar'da başka konudan öğrenmeye başladığın kelimelerin tekrarı yine gelir, yeni kelimeler seyahatten gelir. "Tümü"ne dönünce her şey geri gelir. Seviyeyi B1 yap: Akış B1 kartlarıyla başlar.
- [ ] **Yüzlerce kart:** `content.sqlite` ~550 kartla paketlenince Akış'ta A1 kartları önce gelir, sonra A2, B1... Akış sekmesi hızlı kayar.

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
11. SwiftUI: `.containerBackground(.fill.tertiary, for: .widget)`, widget içinde `ViewThatFits`, `ContentUnavailableView`, `.scrollPosition(id:)`, iki parametreli `.onChange(of:_:)`, `.frame(minWidth:minHeight:)` + `.contentShape` ile 44 pt düğmeler.
12. `@MainActor AppModel` ve `@StateObject` ilk değer ataması: Swift 5 modunda en fazla uyarı vermeli.
13. Birim testleri: `ContentStoreTests` sistem SQLite'ında FTS5 ister (macOS ve iOS'ta var). Başarısız olursa uygulamayı değil yalnızca testi etkiler. Yeni `RotationContinuityTests` sayıları elle hesaplandı (örn. 22:10 UTC'de başlayan plan, 3,5 saat sonra 3 sınır geçmiş); testler kırmızı çıkarsa önce beklenen sayıyı, sonra algoritmayı kontrol et.

**Davranış / cihaz**
14. `?immutable=1` kullanılmadı: GRDB kaynağında `sqlite3_open_v2` bayrakları arasında `SQLITE_OPEN_URI` yok. Sözleşme v1.1 de `readonly` + `journal_mode=DELETE` diyor; içerik hattı (`build_db`) DELETE modunu zorunlu tutar ve testle doğrular. DB artık doğrudan **uygulama paketinden** (salt okunur konum) açılıyor: WAL modundaki bir DB açılmayabilir; boru hattı `journal_mode=DELETE` üretiyor. Paketten açmanın SQLite için sorun çıkarmadığı cihazda görülmeli.
15. Süreklilik doğruluğu cihazda ölçülmeli (kontrol listesindeki "Süreklilik" maddesi). Algoritma saf ve testli, ama gerçek sistemde zaman çizelgesi yeniden üretme anları, `.atEnd` ve `reloadAllTimelines()` zamanlaması doğrulanmadı.
16. Dokunuştan sonra yalnızca dokunulan widget'ın zaman çizelgesi hemen yenilenir. Kilit ekranı gibi diğer örnekler yeni imleci kendi yeniden yüklemelerinde (en geç uygulama arka plana geçince) görür; o zamana kadar eski girişlerini gösterebilir. `reloadTimelines(ofKind:)` çağrısı bütçeyi yer mi bilmiyorum, eklemedim.
17. Saat dilimi / yaz saati / cihaz saati değişince sınırlar kayar (ofset her hesapta o anki saat diliminden alınır). Dönüşüm tutarlı kalır ama kelime beklenmedik bir anda değişebilir. Cihaz saati 2026-01-01'den önceyse tohum dönüşümü ilk kelimede kalır.
18. **Widget düzeni (2026-10-13, `WidgetSnapshotTests` çizimleriyle bakıldı):** metin bloğu `ViewThatFits` ile sığan en dolu düzeni seçiyor. Küçük: kelime + seviye, Türkçe karşılık (2 satır), sığarsa `def_micro` (1–2 satır); orta: kelime + IPA + seviye, karşılık, tanım (2 satır), örnek (1 satır), sığarsa "Sonraki HH:mm". En uzun kelime/karşılık/tanım/örnek kartlarıyla SE ve 6.1" boyutlarında kesilme yok, düğmeler yerinde. Çizimler yaklaşık: WidgetKit'in kendi kenar boşlukları, kilit ekranı canlılığı (vibrancy) ve renklendirme cihazda ayrıca bakılmalı. Hoparlör düğmesi eklenince (2026-10-21) metin düzeni değişmedi; düğmeler bir katmanda, kenar boşluğuna uzanıyor: madde 45.
19. Vurgulu/tinted/clear modlarda okunabilirlik ve `.fill.tertiary` arka planı iOS 26 Liquid Glass'ta gerçek cihazda görülmeli.
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
34. Widget'ta "Biliyorum" kelimeyi sınamadan `known` yapar (30 gün sonra hatırlatıcı olarak döner). Yanlışlıkla basıldıysa Ayarlar > Bildiğim kelime listesinden (satırı kaydır ya da kelimeyi açıp "Öğrenmeye geri al") geri alınır: `Leitner.undoKnown` (hiç cevaplanmamışsa yeni, kutusu varsa hemen tekrar). Sözlük kartında da durum ve "Biliyorum"/"Öğrenmeye geri al" düğmesi var. Değişiklikten önce bekleyen widget olayları işlenir, sonra kuyruk yeniden yazılır (yeni plan_id, widget'ın bilinenler listesi sıfırlanır).
35. 5 dakikalık aralıkta 96 girişlik zaman çizelgesi yalnızca 8 saati kapsar; WidgetKit'in `.atEnd` ile yenilemeyi ne kadar hızlı verdiği (ve bütçesi) ölçülmedi (madde 26 ile aynı sorun, ama artık kullanıcı seçebiliyor).
36. `ContentStore.freeCards` sırası SQL'de `level_rank ASC` ile başlıyor (A1 → A2 → B1...), yeni test bunu kanıtlıyor. `level_rank` ile `level` metninin tutarlı olması içerik hattının işi; hat bunu doğrulamıyorsa bozuk kart sırayı bozar.
37. Akış 5000 karta kadar yükleniyor (`AppModel.feedLimit`). ~550 kartta `LazyVStack` + `.scrollPosition(id:)` performansı ve derin bağlantıyla uzak karta kayma ölçülmedi (madde 23).
38. Tekrar sekmesinde `body` her değerlendirmede `nextReviewSession()` çağırıyor (tüm kelime listesini tarar). 550 kartta ucuz; 5000'de ölçülmedi.
39. Kişisel kurulum bölümündeki ücretsiz hesap sınırları Apple'ın sayfasından alındı, ama gerçek cihazda denenmedi; "doğrulanmadı" işaretli maddeler gerçekten bilinmiyor.
40. Akış ve Tekrar kartına örneğin Türkçesi ve "Dikkat" kutusu (ilk yaygın hata) eklendi (`CardDetailViews.swift`). **Simülatörde bakıldı (2026-10-13, iPhone SE 3 ve 16 Pro Max):** akış kartı ikisinde de sığıyor. Tekrar kartı SE'de taşıyordu (butonlar sekme çubuğunun altında kalıyordu); kart artık kendi içinde kayıyor, butonlar sabit. Daha uzun kartlar akışta denenmedi: akış sayfası kaymaz, `MistakeBox` açıklaması 3 satırla sınırlı.
41. Kart ayrıntısı (`AppModel.detail(for:)`) ana iş parçacığında, görünüm çizilirken veritabanından tek satır okur ve önbelleğe alır. Satır başına çok kısa sürmesi beklenir, ölçülmedi.
42. **Sesli telaffuz (`Speaker.swift`):** kelimenin ve örnek cümlelerin yanındaki hoparlör, cihazın kendi ABD İngilizcesi sesiyle (çevrimdışı) okur; yüklüyse geliştirilmiş/premium ses seçilir (Ayarlar > Erişilebilirlik > Sözlü İçerik > Sesler'den indirilebilir). Hız varsayılanın 0,9 katı. Ses oturumu `.playback`: sessiz modda da duyulur, diğer sesleri kısar. Tekrar kartında hoparlör kartın üstünde (kartın içindeki düğme kartı da açardı). Quiz sorusunda yok, cevabı söylerdi. Cihazda ses kalitesi ve gecikme denenmedi; CI simülatöründe yalnızca dokunuşta çökmediği sınanıyor.
43. **Günlük hatırlatma (`ReminderScheduler.swift`, `Learning/ReminderPlanner`):** Ayarlar > Hatırlatma'dan açılır (varsayılan kapalı, 20:00). Açınca bildirim izni istenir; reddedilirse anahtar kapalı kalır ve iPhone Ayarları'na giden düğme çıkar. Yerel bildirim, yedi gün ileriye tek tek (tekrarlanmayan) kurulur ve uygulama her arka plana geçişinde baştan yazılır: metindeki sayı o anki ilerlemeden hesaplanır ("12 kelime tekrar, 5 yeni kelime..."). O günün tekrarı ve yeni kelime hedefi bittiyse o günün bildirimi kurulmaz. Uygulama 7 gün hiç açılmazsa bildirimler biter (bilerek: kullanılmayan uygulama rahatsız etmesin). Bildirime dokununca Tekrar sekmesi açılır. Gerçek cihazda bildirim zamanlaması ve dokunuşla açılış denenmedi.
44. **Zor/Kolay düğmeleri (hiç derlenmedi, simülatörde bakılmadı):** Tekrar kartında 2×2 düğme alanı (`ReviewView.answerArea`) ve quiz'de "Zordu"/"Kolaydı" satırı (`QuizCardView.difficultyButtons`). SE'de kartın küçülen alanı ve düğmelerin sekme çubuğuna taşmaması ekran görüntüsünden (`screenshots.yml`) kontrol edilmeli. `tortoise` ve `hare` SF Symbols simgeleri (iOS 14+) kullanıldı; görünmezse yalnızca simge kaybolur, metin kalır. Aralıklar (zor = yarısı, kolay = iki kutu) sezgiyle seçildi, gerçek kullanımla ayarlanmalı (`Leitner.hardFactor`).
45. **Widget'ta hoparlör düğmesi (2026-10-21; CI'da derlendi, cihazda denenmedi):** Küçük ve orta ana ekran widget'ında hoparlör, kelimeyi (başlık sözcüğü) **uygulamayı açmadan** okur. Kilit ekranı widget'larına eklenmedi (cihaz kilitliyken düğmeler çalışmaz). Derleme: `build.yml` yeşil, Xcode 26.3, uyarısız (https://github.com/yusufuyar68/lockglow/actions/runs/39517676248, `macos-15-intel`). `WidgetSnapshotTests` çizimleri bu düzenle henüz üretilmedi: bir sonraki `screenshots.yml` turunda bak.
    - **Nasıl çalışıyor:** `Shared/SpeakWordIntent.swift` bir `AudioPlaybackIntent`. Apple'ın "Adding interactivity to widgets and Live Activities" belgesi: bu protokolü uygulayan intent widget eklentisinde değil **uygulamanın sürecinde** çalışır, intent uygulama hedefine de eklenmelidir (`NextWordIntent` gibi sıradan bir `AppIntent` widget eklentisinde çalışır). Bu yüzden `Shared/` klasörü uygulamaya, widget'a ve çizim testi paketine birlikte giriyor: widget `Button(intent:)` için tipi bilmeli, uygulama `perform()`'ü çalıştırıyor. Uygulama kapalıysa sistem onu arka planda başlatır (bunu `AudioPlaybackIntent` için Apple belgesi değil, geliştirici forumunda bir Apple mühendisi söylüyor). `perform()` konuşma bitene kadar (en çok 8 sn) bekler, 0,25 sn sonra ses oturumunu kapatır, sonra döner; dönünce uygulama yeniden askıya alınır. Apple, arka plandaki işlere 30 sn tanındığını yazıyor; bu yetiyor. `isDiscoverable = false`: Kestirmeler, Spotlight ve Siri'de "her metni oku" eylemi olarak görünmez, widget'tan çalışır (Apple belgesi).
    - **Ayar:** uygulamaya `UIBackgroundModes: audio` eklendi (`project.yml`). Apple: `.playback` kategorisi arka planda çalmak için bu modu ister; mod yoksa etkinleştirme `cannotStartPlaying` (561015905) ile düşer. Yalnızca Info.plist anahtarı; yetki (entitlement), profil ya da izin metni gerekmez. Eklentiye eklenmez.
    - **Ses:** `Shared/WordSpeech.swift`, `Speaker.swift`'in eski mantığıyla aynı: en-US, kurulu en iyi kalite (geliştirilmiş/premium varsa o), hız 0,9, oturum `.playback` + `.spokenAudio` + diğer sesleri kıs. `Speaker.swift` artık bunu kullanıyor, uygulamadaki davranış aynı. Widget tarafında `WordSpeechPlayer` konuşmayı bekler; ikinci dokunuş birincinin yerine geçer. Uygulamanın kendi ses oturumu etkinleşmezse yedek yol: `usesApplicationAudioSession = false` (oturumu sistem yönetir; WWDC20 10022). Bu yolun arka planda ses çıkarıp çıkarmadığı belgelenmemiş. İleride düşünülebilir: Apple'ın metin okuma için önerdiği `.voicePrompt` modu (podcast'i üstüne konuşmak yerine duraklatır); şimdilik uygulamayla aynı kalsın diye değiştirilmedi.
    - **Günlükler (cihaz denemesi için):** Xcode > Console, kategori `speech`. `widget speech in com.yusufuyar.vocabwidget, app audio session: true` = intent uygulamada çalıştı, normal yol. Paket adı `...widgets` ise intent eklentide çalışmıştır (beklenmez, ses çıkmaz). `app audio session: false` = yedek yol. Ayrıca `audio session not activated`, `widget speech timed out`, `audio session deactivation: ...` satırları sorunu gösterir.
    - **Düzen:** üç düğme 3 x 44 = 132 pt. Küçük widget'ın içerik genişliği SE'de 116, 6,1" telefonda 126 pt; orta widget'ın içerik yüksekliği 126 pt (SE'de 116). Bu yüzden widget'ın sistem kenar boşlukları kapatıldı (`WordWidget`: `contentMarginsDisabled()`); görünümler boşlukları `widgetContentMargins` ile kendileri uyguluyor. Apple boşlukları seçerek uygulamak için bu yolu belgeliyor. Düğmeler bir katmanda (`overlay`) çiziliyor ve her yandan en çok 8 pt boşluğa uzanıyor (`buttonGroupOverflow`). Böylece dokunma alanları 44 x 44 pt kalıyor ve widget'ın kök görünümünün içinde. Metin eski yerini koruyor (düğmelerin yerinde 44 pt'lik boş bir yer tutucu var), madde 18'deki bulgular geçerli. Sıra iki widget'ta da Sonraki, hoparlör, Biliyorum: durum değiştiren iki düğmenin arasında zararsız hoparlör var. Küçükte alt satırda, ortada sağ sütunda. Simgeler ilk erişilebilirlik yazı boyutundan sonra büyümüyor (`dynamicTypeSize(...accessibility1)`); grup 132 pt kalıyor, metni itmiyor. Hoparlörde `startsMediaSession` özelliği var: VoiceOver okuma sırasında susar. Kilit ekranı aileleri kapatılan boşlukları düz `padding` olarak geri alıyor; görünüşleri değişmemeli (cihazda bak). Bir düğmenin dışına dokunmak eskisi gibi uygulamayı açar.
    - **Gizlilik manifestleri değişmedi:** `AVSpeechSynthesizer` ve `AVAudioSession` Apple'ın "gerekçe istenen API" kategorilerinde (dosya zaman damgası, sistem açılış zamanı, disk alanı, etkin klavyeler, `UserDefaults`) yok; yeni veri toplanmıyor. Uygulamanın mevcut `CA92.1` bildirimi yeterli.
    - **Mağazaya gönderirken (TestFlight için gerekmez):** `audio` arka plan modu inceleme yönergesi 2.5.4 açısından sorulabilir (arka plan hizmetleri amacına uygun kullanılmalı). Burada kullanıcının dokunuşuyla kısa bir telaffuz için kullanılıyor. Forumda, inceleyen kişi sesi tetikleyemediği için reddedilen bir uygulama bildirildi; App Review notlarına widget adımlarını ve kısa bir ekran kaydını ekle.
    - **iOS 27 (ileride):** Apple'ın iOS 27 belgelerinde `allowedExecutionTargets` var; aynı belgeler sistemin arka plan intent'lerini uygulama eklentisinden çalıştırmayı tercih ettiğini yazıyor. CI Xcode 27'ye geçince bu intent'in yalnızca uygulamada çalışmasını açıkça seç ve günlükteki paket adına bak.
    - **Apple'ın belgelemediği, cihazda görülecekler:** (a) `AVSpeechSynthesizer`'ın `AudioPlaybackIntent` ile arka planda başlatılan uygulamada gerçekten ses çıkarması (Apple bu birleşimi anlatmıyor; navigasyon uygulamaları arka planda sesli komutu aynı API'yle, `audio` moduyla veriyor), (b) uygulama kapalıyken ilk dokunuşun gecikmesi (forumda "birkaç saniye" bildirildi; uygulamanın açılış hızına bağlı), (c) okurken ekran kilitlenirse konuşmanın yarıda kesilmesi (forumda uzun cümlelerde bildirildi), (d) sessiz modda duyulma, (e) çalan müziğin kısılıp geri gelmesi, (f) kilit ekranı, StandBy ve renklendirilmiş ana ekranda kenar boşlukları. **Sessiz kalırsa sırayla:** `AVSpeechSynthesizer.write` ile arabelleğe yazıp `AVAudioPlayer` ile çalmak; kelime sesini önceden kaydedip pakete koymak; son çare düğmeyi `openAppWhenRun` yapıp uygulamayı açarak okutmak.
46. **Açılış akışı ve deste seçimi (2026-10-20, Windows'ta yazıldı):** CI (`build.yml`, 2026-10-20, Xcode 26.3): 151 paket testi geçti, uygulama ve widget derlemesi hatasız ve uyarısız. Ekranlara simülatörde bakılmadı; `screenshots.yml` açılış sayfalarını `0a`–`0e` adlarıyla çeker. Bakılacaklar:
    - SE'de ve en büyük yazıda seviye ve konu satırları sığıyor mu;
    - "Kilitli ekran / Ana ekran" düğmeleri `ViewThatFits` ile yan yana ya da alt alta doğru geçiyor mu;
    - tam ekran akış sekmelerin üstünde doğru açılıyor mu.

    Renkler tasarım taslağındaki değerlerle kodda (`GlowStyle.swift`, `Palette`). Taslak Swift'e geçirilince Asset Catalog renkleriyle değiştirilmeli. iOS 26'da kilitli ekranda "Özelleştir"den sonra "Kilitli Ekran / Ana Ekran" seçimi sorulup sorulmadığı Apple'ın kılavuzunda yazmıyor; rehber "seçmeni isterse" diyor. Cihazda bakılmalı.

## Learning modülü (uygulamaya bağlı)

`Packages/VocabKit/Sources/Learning` saf Swift'tir; `swift test` ile `LearningTests` çalışır (yeni testler `ProgressIngestTests`, `ReviewPlannerTests`, `LeitnerHardEasyTests`; beklenen değerler elle hesaplandı, hiç çalıştırılmadı). Kuyruk algoritmasının test beklentileri ayrıca bir Python kopyasıyla doğrulanmıştı.

Uygulamaya bağlandı (yalnızca uygulama hedefi, widget'a eklenmedi):
1. `project.yml`: uygulama hedefine `package: VocabKit, product: Learning`.
2. `AppModel.refreshWidgetPlan`: widget olayları `LearningEvent`'e çevrilip `ProgressIngest.apply` ile işlenir (`known` → `Leitner.markKnown`, `next`/`reveal` → `markExposure`, `unknown` → `review(.again)`), `ProgressStore` ile kaydedilir, olay dosyaları silinir; kuyruk `QueueComposer.compose(feed:progress:now:horizon: 48 saat, maxNew: günlük hedef × 2, limit: 96, pinFirst: şu an gösterilen kelime)` ile kurulur. `QueueBuilder` artık uygulamada kullanılmıyor (Scheduler testleri hâlâ onu kapsıyor).
3. Tekrar sekmesi cevapları `Leitner.review(.again / .hard / .good / .easy)` ile işler; `ReviewPlanner` tur kelimelerini ve Ayarlar'daki sayıları hesaplar.
4. Tek seferlik geçiş: `AppPreferences.knownWordIDs` içindekiler `markKnown` ile ilerleme dosyasına taşınır, sonra eski anahtar silinir.

### Zor ve Kolay notları (`Leitner.review`)

| Not | Düğme | Yeni kelime (kutu 0) | Kutudaki kelime | Biten (`known`) kelime |
|---|---|---|---|---|
| `again` | Bilemedim | kutu 1, 10 dk sonra | kutu 1, 10 dk sonra (yanlış sayılır) | öğrenmeye döner, kutu 1, 10 dk |
| `hard` | Zor / Zordu | kutu 1, **12 saat** sonra | kutu **aynı**, o kutunun aralığının yarısı (kutu 1: 12 sa, 2: 1 g, 3: 2 g, 4: 4 g, 5: 8 g) | `known` kalır, hatırlatma 15 gün sonra |
| `good` | Bildim / Devam | kutu 1, 1 gün | bir kutu ileri, yeni kutunun aralığı (1, 2, 4, 8, 16 gün) | `known` kalır, hatırlatma 30 gün sonra |
| `easy` | Kolay / Kolaydı | kutu 2, 2 gün | **iki** kutu ileri, 5'i aşmaz (kutu 4 → 5, 16 gün) | `known` kalır, hatırlatma 30 gün sonra |

Gerekçeler ve seçimler:
- Sıra hep `again` < `hard` < `good` < `easy` (testle doğrulanır, her kutu için).
- `hard` ve `easy` yanlış sayılmaz (`lapses` artmaz); `reviews` her cevapta artar.
- Son kutuda (5) `good` ya da `easy` kelimeyi bitirir (`known`). `hard` bitirmez: kutu 5'te 8 gün sonra yeniden sorulur.
- Kutu 4'te `easy` bitirmez, kutu 5'e geçirir: "en üst kutuyu aşmaz". Bitirmek için son kutuda bir doğru cevap daha gerekir.
- `known` kelimede (bitmiş ya da "Biliyorum" denmiş) `easy` ile `good` aynıdır, çünkü hatırlatmanın üstünde kutu yok. `hard` hatırlatmayı yarıya (15 güne) indirir ve kelime `known` kalır, yani Ayarlar'daki "bildiğim" sayısı değişmez.
- Yeni kelimeye `hard` kutu 1'e sokar (aksi hâlde kelime yeni kalır ve "yeni kelime" listesinde sonsuza dek çıkardı). 12 saatlik aralık sabah çalışılan kelimeyi aynı akşam "zamanı gelmiş" yapabilir; Ayarlar'daki "bugün tekrar" sayısı ve günlük hatırlatma bunu zaten `dueAt`'ten okuyor, ayrı bir ayar gerekmedi (`LeitnerHardEasyTests.testPlannersSeeAHardAnswerTwelveHoursLater`).
- `progress.json` biçimi değişmedi: `ReviewGrade` dosyaya yazılmaz, `WordProgress` alanları aynı. Eski bir dosya olduğu gibi açılır (testli).
- Widget "Bilemedim" (`unknown`) hâlâ yalnızca `again` üretir; widget'ta zor/kolay düğmesi yok.

(`undoKnown` artık Bildiğim kelimeler listesinde ve Sözlük kartında kullanılıyor.)
