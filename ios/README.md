# Lockglow iOS (widget spike)

Kelime widget'ı uygulamasının ilk, bilerek küçük tutulmuş iskeleti. Amaç: widget zaman çizelgesi, interaktif butonlar, App Group dosya sözleşmesi ve içerik veritabanı okumasının gerçek cihazda çalıştığını kanıtlamak.

> **Bu kod Windows'ta yazıldı ve hiç derlenmedi.** İlk derlemede küçük hatalar çıkabilir. Aşağıdaki "Bilinen belirsizlikler" bölümü, derleyicinin veya cihazın itiraz edebileceği yerleri listeler.

Veri sözleşmesi: [`../docs/contract/content-db.md`](../docs/contract/content-db.md). Mimari: [`../raporlar/04_teknik_mimari.md`](../raporlar/04_teknik_mimari.md).

## Klasör yapısı

```
ios/
├─ project.yml                 XcodeGen tanımı (.xcodeproj elle yazılmaz)
├─ Config/Base.xcconfig        BUNDLE_ID_PREFIX, DEVELOPMENT_TEAM, APP_GROUP_ID, sürüm
├─ App/                        Lockglow (SwiftUI uygulaması): sekmeler Akış, Tekrar, Ayarlar, Widget Sağlığı
│  ├─ Resources/               content.sqlite buraya (isteğe bağlı)
│  ├─ Assets.xcassets/         AppIcon (1024 px, opak, yalnızca şekil; geçici ikon)
│  └─ PrivacyInfo.xcprivacy
├─ Widgets/                    LockglowWidgets (WidgetKit extension)
│  ├─ Resources/seed_words.json   widget paketine gömülü tohum kelimeler
│  └─ PrivacyInfo.xcprivacy
├─ Tools/                      linux_check.sh (Mac olmadan derleme + test), make_app_icon.py
└─ Packages/VocabKit/          yerel Swift paketi (swift test Mac'te çalışır)
   ├─ CoreModels               WidgetWord, Level, WidgetEventType, SeedWords, DeepLink, CardDetail (kartın tam JSON'undan örnekler + Türkçe notlar)
   ├─ TextFold                 fold() (sözleşme §4)
   ├─ SharedState              AppGroupStore, EventMailbox, WidgetPlan/State/Event
   ├─ Scheduler                TimelinePlanner, RotationInput, RotationCursor, QueueBuilder (saf fonksiyonlar)
   ├─ ContentStore             GRDB ile salt okunur content.sqlite (yalnızca uygulama)
   └─ Learning                 Leitner (5 kutu), QueueComposer (6 tekrar : 3 yeni : 1 hatırlatma), ProgressIngest (widget olayları → ilerleme), ReviewPlanner (tekrar turu, sayılar), ProgressStore (yalnızca uygulama)
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
- **Tekrar sekmesi:** önce zamanı gelen kelimeler (en çok 20 kart/tur, en çok gecikmiş önce), yoksa günlük hedef kadar yeni kelime (akış sırasıyla; bugün zaten çalışılanlar hedeften düşülür). "Bildim" → `review(.good)`, "Bilemedim" → `review(.again)`; her cevapta ilerleme kaydedilir, tur bitince (ya da "Bitir"e basılınca) plan yeniden yazılır. Bilemedim denen kelime 10 dakika sonra yeniden "zamanı gelmiş" olur (aynı turda tekrar sorulmaz). Hedef dolunca "bugünlük tamam" ekranı çıkar; isteyen "N yeni kelime daha" ile devam eder.
- **İmleç anlamı (sözleşmeden sapma, §6'ya işlenmeli):** `widget_state.json`'a `cursor_anchor` (ISO 8601) eklendi; `cursor_offset` artık "`cursor_anchor` anında dönüşümün bulunduğu kuyruk sırası" demek, saf bir "+1" sayacı değil.
- **Hizalama:** yerel saat dilimi ofseti kullanıldığı için "günlük" sınır yerel gece yarısına düşer (yoksa UTC gece yarısı = Türkiye'de 03:00 olurdu).
- Derin bağlantı: widget'a dokunmak `vocabwidget://word/<id>` açar; uygulama akışta o karta kaydırır. Şema `CoreModels/DeepLink.swift` ve `project.yml` (`CFBundleURLSchemes`) içinde; ikisi aynı kalmalı. Markadan bağımsızdır, ad değişince bağlantılar bozulmaz.

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
8. **Kontrol.** Uygulamayı aç (ilk plan yazılır), "Widget Sağlığı" sekmesinde App Group "Erişilebilir" olmalı. Ana ekrana uzun bas > "+" > Lockglow. Ardından yukarıdaki test kontrol listesini kullan.

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

## Widget spike test kontrol listesi

Hazırlık: uygulamayı en az bir kez aç (plan yazılsın). "Widget Sağlığı" sekmesinde App Group "Erişilebilir", kuyruk boyutu > 0 olmalı.

- [ ] **Ekleme:** Ana ekrana küçük ve orta widget, kilit ekranına dikdörtgen ve satır içi widget ekle. Hepsinde kelime görünüyor, hiçbiri boş değil.
- [ ] **Uygulama açılmadan ekleme:** Uygulamayı sil, yeniden kur, **açmadan** widget ekle. Tohum kelimeler (breakfast, borrow, actually...) görünmeli.
- [ ] **Galeri:** Widget galerisinde önizleme anında ve anlamlı (örnek kelime).
- [ ] **Sınırlarda değişim:** Kelime her saat başında değişmeli (14:00, 15:00...), 14:23 gibi bir dakikada değil. Ana ekran ve kilit ekranı widget'ları aynı anda aynı kelimeye geçmeli (hızlı test için Ayarlar > Kelime değişim sıklığı > 5 dakika).
- [ ] **Süreklilik (en önemli):** Birkaç sınır geçtikten sonra uygulamayı aç ve ana ekrana dön (plan yeniden yazılır): widget'taki kelime **değişmemeli**, sonraki sınırda sıradaki kelimeye geçmeli. Aynısını widget'ı yeniden yükleyerek (Widget Sağlığı > "Yalnızca zaman çizelgelerini yenile") dene. Kelimeler başa sarmamalı, tekrar etmemeli.
- [ ] **Orta widget etiketi:** "Sonraki HH:mm" doğru saati gösteriyor (sığmazsa gizlenmesi normal).
- [ ] **Sonraki:** Küçük ve orta widget'ta "sonraki" okuna dokun. Kelime hemen değişir, geri atlamaz; sonraki sınırda bir sonrakine geçer. "Widget Sağlığı"nda widget imleci değişir, bekleyen olay sayısı artar. Düğmeler rahat basılıyor (44 pt).
- [ ] **Biliyorum:** Onay işaretine dokun. Kelime kaybolur ve bir daha çıkmaz, sıra bozulmaz. Bekleyen olay artar.
- [ ] **Kilit ekranı:** Dikdörtgen/satır içi widget'ta buton yok. Cihaz kilitliyken küçük widget butonları çalışmaz (beklenen).
- [ ] **Arka plana alma:** Birkaç "sonraki/biliyorum" sonrası uygulamayı aç, sonra ana ekrana dön. Konsolda (Xcode > Console, `widget event` ara) olaylar loglanır, bekleyen olay 0 olur (uygulama öne gelince de 0 olur), yeni plan_id yazılır, widget güncellenir, "biliyorum" denen kelimeler artık yok. Görünen kelime aynı kalır ve dönüşüm oradan devam eder.
- [ ] **Dokunma:** Widget gövdesine dokun: uygulama açılır ve akışta o kelimeye kayar (soğuk açılışta da).
- [ ] **Release yapılandırması:** `Lockglow-Release` scheme'i ile çalıştır (Debug'da widget yenileme bütçesi uygulanmaz). Birkaç saat bırak, zaman çizelgesi girişlerinin kaçırılmadan değiştiğini doğrula. Ayrıca TestFlight derlemesiyle bir gün dene.
- [ ] **Düşük Güç Modu:** Aç, widget'ın bayat kalıp kalmadığını ve uygulama arka plana geçince yenilenip yenilenmediğini izle.
- [ ] **Yeniden başlatma:** Cihazı yeniden başlat, **ilk kilit açmadan önce** kilit ekranı widget'ına bak: yer tutucu/tohum kelime görünebilir, çökme olmamalı. Açtıktan sonra kendini toparlamalı.
- [ ] **Görünüm modları:** Tinted/clear ana ekran (iOS 18/26), kilit ekranı vurgulu modu, StandBy: metin okunuyor, kelime vurgulu, anlam renge bağlı değil.
- [ ] **Yazı boyutu:** Dinamik Tür'ü en büyük ve en küçük yap: küçük widget'ta buton satırı kesilmiyor mu?
- [ ] **Bellek/çökme:** Console'da widget extension'ın jetsam/0xDEAD10CC çökmesi yok.
- [ ] **Tekrar sekmesi:** İlk açılışta "Bugünün yeni kelimeleri" önerilir. Karta dokun: Türkçe karşılık iri, altında tanım ve örnek. "Bildim"/"Bilemedim" ile ilerle, tur sonunda özet çıkar. Uygulamayı kapat-aç: cevapladığın kelimeler yeni kelime listesinde yok. Widget'ta "Biliyorum" dediğin kelime Tekrar'da yeni olarak çıkmaz.
- [ ] **Ayarlar sekmesi:** Sıklığı 5 dakikaya çek: widget'taki kelime değişmez, sonraki sınırda yeni aralıkla ilerler. Günlük yeni kelimeyi değiştir: widget kuyruğu yeniden yazılır. Sayılar (bildiğim / öğrenmekte / bugün tekrar) Tekrar sekmesiyle tutarlı. "İlerlemeyi sıfırla" onay sorar, sonra sayılar 0 olur.
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
18. Küçük widget'ta (≈126×126 pt içerik) kelime + Türkçe karşılık (en çok 2 satır, `.subheadline` kalın) + 2 satır tanım + 44 pt düğme satırı sığmayabilir (iki satırlık karşılıkta ≈144 pt gerekir). Kelime ve karşılığa `layoutPriority(1)` verildi, tanım önce kısılmalı; SwiftUI'nin bunu gerçekten böyle yaptığı (ve düğmelerin kesilmediği) cihazda görülmeli. Orta widget'ta düğmeler sağda dikey dizildi; sol sütun (kelime, karşılık, tanım, örnek, tür/seviye satırı) ≈123 pt; kesilme olursa örnek cümleyi kaldır. En küçük iPhone'da kontrol et. "Sonraki HH:mm" etiketi artık sütunun en altında, `ViewThatFits` ile sığmazsa gizlenir, hangisinin seçildiği doğrulanmadı.
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
30. **Veri kaybı riski:** `ProgressStore.load()` okunamayan ya da bozuk dosyada boş ilerleme döndürür; sonraki kayıt dosyanın üzerine yazar (yedek yok). Uygulama yalnızca ön plandayken okuduğu için kilit koruması sorun çıkarmamalı, ama bozuk dosya tüm ilerlemeyi sessizce sıfırlar. Gerekirse `load()` hata ayrımı yapacak şekilde değiştirilir.
31. İlerleme dosyası ve "bugün çalışılan yeni kelime sayısı" ayrı yerlerde (JSON dosyası ve `UserDefaults`); sayaç yerel takvim gününe bağlı, saat dilimi değişirse gün kayar. İlerlemeyi sıfırlamak ikisini de siler.
32. Widget olayları artık uygulama öne gelince de işleniyor (`scenePhase == .active`); sözleşme (§6) "ön plana gelince" diyordu, bu onunla uyumlu. Plan yine yalnızca açılışta, arka plana geçerken, ayar değişince ve tur bitince yazılır. Ön plandaki bir "Bildim" cevabı widget kuyruğuna ancak tur bitince ya da arka plana geçince yansır.
33. Kuyruk 48 saatlik ufukla kuruluyor: bugün "Bildim" dediğin kelime yarın zamanı gelecekse bugünden widget kuyruğuna girer (öğrenilen kelimeler widget'ta hemen görünür). Beklenen davranış bu, ama kullanıcı için fazla erken tekrar gibi hissedilebilir; gerekirse `AppModel.queueHorizon` kısaltılır.
34. Widget'ta "Biliyorum" kelimeyi sınamadan `known` yapar (30 gün sonra hatırlatıcı olarak döner). A2 seviyesinde yanlışlıkla basma, bilinen sayısını şişirir; geri alma arayüzü yok (`Leitner.undoKnown` var, kullanılmıyor).
35. 5 dakikalık aralıkta 96 girişlik zaman çizelgesi yalnızca 8 saati kapsar; WidgetKit'in `.atEnd` ile yenilemeyi ne kadar hızlı verdiği (ve bütçesi) ölçülmedi (madde 26 ile aynı sorun, ama artık kullanıcı seçebiliyor).
36. `ContentStore.freeCards` sırası SQL'de `level_rank ASC` ile başlıyor (A1 → A2 → B1...), yeni test bunu kanıtlıyor. `level_rank` ile `level` metninin tutarlı olması içerik hattının işi; hat bunu doğrulamıyorsa bozuk kart sırayı bozar.
37. Akış 5000 karta kadar yükleniyor (`AppModel.feedLimit`). ~550 kartta `LazyVStack` + `.scrollPosition(id:)` performansı ve derin bağlantıyla uzak karta kayma ölçülmedi (madde 23).
38. Tekrar sekmesinde `body` her değerlendirmede `nextReviewSession()` çağırıyor (tüm kelime listesini tarar). 550 kartta ucuz; 5000'de ölçülmedi.
39. Kişisel kurulum bölümündeki ücretsiz hesap sınırları Apple'ın sayfasından alındı, ama gerçek cihazda denenmedi; "doğrulanmadı" işaretli maddeler gerçekten bilinmiyor.
40. Akış ve Tekrar kartına örneğin Türkçesi ve "Dikkat" kutusu (ilk yaygın hata) eklendi (`CardDetailViews.swift`). Uzun bir tanım + örnek + hata kutusu küçük ekranlı iPhone'larda (SE) sayfaya sığmayabilir; sayfa kendi içinde kaydırılmıyor. Gerçek cihazda bakılmadı.
41. Kart ayrıntısı (`AppModel.detail(for:)`) ana iş parçacığında, görünüm çizilirken veritabanından tek satır okur ve önbelleğe alır. Satır başına çok kısa sürmesi beklenir, ölçülmedi.


## Learning modülü (uygulamaya bağlı)

`Packages/VocabKit/Sources/Learning` saf Swift'tir; `swift test` ile `LearningTests` çalışır (yeni testler `ProgressIngestTests`, `ReviewPlannerTests`; beklenen değerler elle hesaplandı, hiç çalıştırılmadı). Kuyruk algoritmasının test beklentileri ayrıca bir Python kopyasıyla doğrulanmıştı.

Uygulamaya bağlandı (yalnızca uygulama hedefi, widget'a eklenmedi):
1. `project.yml`: uygulama hedefine `package: VocabKit, product: Learning`.
2. `AppModel.refreshWidgetPlan`: widget olayları `LearningEvent`'e çevrilip `ProgressIngest.apply` ile işlenir (`known` → `Leitner.markKnown`, `next`/`reveal` → `markExposure`, `unknown` → `review(.again)`), `ProgressStore` ile kaydedilir, olay dosyaları silinir; kuyruk `QueueComposer.compose(feed:progress:now:horizon: 48 saat, maxNew: günlük hedef × 2, limit: 96, pinFirst: şu an gösterilen kelime)` ile kurulur. `QueueBuilder` artık uygulamada kullanılmıyor (Scheduler testleri hâlâ onu kapsıyor).
3. Tekrar sekmesi cevapları `Leitner.review(.again / .good)` ile işler; `ReviewPlanner` tur kelimelerini ve Ayarlar'daki sayıları hesaplar.
4. Tek seferlik geçiş: `AppPreferences.knownWordIDs` içindekiler `markKnown` ile ilerleme dosyasına taşınır, sonra eski anahtar silinir.

Sırada: FSRS (v1.2, aynı çağrıların arkasında), `undoKnown` için geri alma düğmesi, `hard`/`easy` notları.
