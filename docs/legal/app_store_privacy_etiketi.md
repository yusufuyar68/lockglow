# App Store Connect "App Privacy" Cevap Kâğıdı ve PrivacyInfo.xcprivacy Kontrol Listesi

**Lockglow** · iOS 17+ · App + Widget Extension · Sürüm: taslak-2 (22 Ekim 2026: Söyle, widget sesi, şimdiki derleme için Bölüm 2A ve 5.6) · Tarih: [TARİH]

> **TASLAK:** Hukuki/uyum görüşü değildir; avukat ve gerçek ağ trafiği doğrulaması gerekir. Bu kâğıt, planlanan SDK'lara göre **muhafazakâr** (daha çok beyan eden) yorumla hazırlandı. Apple'ın veri türü adları ve soru akışı İngilizce bırakıldı; App Store Connect'te aynen görünür. Apple'ın güncel soru listesi değişmiş olabilir **[TEYİT]**.

---

## 0. Varsayımlar (bunlardan biri değişirse kâğıt güncellenir)

| # | Varsayım | Doğrulama |
|---|---|---|
| V1 | **RevenueCat** (purchases-ios) uygulama açılışında başlatılır; anonim "App User ID" kullanılır; **hesap/giriş yoktur**; özel kullanıcı kimliği, e-posta veya ad RevenueCat'e gönderilmez. | Kod incelemesi |
| V2 | **PostHog** (AB bulutu) **yalnızca "Kabul ediyorum" sonrası** başlatılır; rastgele kimlik rıza anında üretilir; autocapture ve **session replay kapalı**; **GeoIP kapalı, IP verisi atılır**; olaylarda kelime içeriği, arama metni, ad/e-posta yoktur. | Proxy ile trafik analizi |
| V3 | **Çökme raporu:** Seçenek A: yalnızca Apple'ın mekanizmaları (MetricKit/Xcode Organizer; Apple'ın topladığı veri geliştirici beyanı kapsamında değildir **[TEYİT]**). Seçenek B: **Sentry** (rıza ile; `sendDefaultPii = false`, ağ izleri ve performans izleme kapalı). Bu kâğıt **B senaryosunu** (en çok beyan eden) gösterir; A seçilirse Diagnostics satırları "No" olur. | Karar |
| V4 | **ATT yok, IDFA yok**, reklam SDK'sı yok. RevenueCat'te reklam/atıf entegrasyonları (Meta, AppsFlyer, Adjust vb.) **kapalıdır**; `collectDeviceIdentifiers()` çağrılmaz. Apple Ads AdServices atıf jetonu **MVP'de kullanılmaz**. | Kod + RevenueCat paneli |
| V5 | **RevenueCat → PostHog entegrasyonu kapalıdır** veya yalnızca rıza veren kullanıcılar için ve rıza sonrası kimlik eşlemesiyle çalışır. | Panel + kod |
| V6 | "Hata bildir" düğmesi **e-posta oluşturma ekranı** (mailto) açar; uygulama içi form/sunucu yoktur. | Karar |
| V7 | Widget uzantısında **ağ erişimi ve üçüncü taraf SDK yoktur**; yalnızca App Group'taki yerel veriyi okur. Hoparlör düğmesi (`SpeakWordIntent`, bir `AudioPlaybackIntent`) iOS tarafından **uygulamanın sürecinde** çalıştırılır ve kelimeyi cihaz içi sesle okur; o da ağa çıkmaz. **[TEYİT: taslak-2]** | Kod incelemesi (2026-10-22: `ios/Shared/SpeakWordIntent.swift`) |
| V8 | Arka uç yok. İçerik uygulama paketinde gelir (CDN/CloudKit **sonraki sürümlerde**; bkz. Bölüm 5, "yeniden kontrol tetikleyicileri"). | — |
| V9 | **Söyle (telaffuz):** mikrofon yalnızca kullanıcı Söyle'ye dokununca ve izinle açılır. iOS 26+: `SpeechAnalyzer` + `DictationTranscriber` (Apple: bu modüller sesi Apple sunucularına göndermez); iOS 17–25: `SFSpeechRecognizer` + `requiresOnDeviceRecognition = true`, cihaz içi tanıma yoksa özellik çalışmaz (sunucuya düşmez). Ses yalnızca bellekte, dosyaya yazılmaz; tanınan metin ve sonuç ilerleme dosyasına kaydedilmez; arka plana geçişte ve ses kesintisinde dinleme iptal. **[TEYİT: taslak-2]** | Kod (2026-10-22): `PronunciationRecognizer.swift:139–178` (izin, arka uç), `:470` (`requiresOnDeviceRecognition`), `:192–213` (yalnız bellek tamponu); `PronunciationPracticeView.swift:144–160` (arka plan/kesinti iptali) |
| V10 | **Şimdiki derleme** (2026-10-22) RevenueCat, PostHog ve Sentry **içermez**; ağ kodu yok. Bölüm 2 ileriki ticari sürüm içindir; şimdiki derlemenin cevabı **Bölüm 2A**'dadır. **[TEYİT: taslak-2]** | Kod araması (Bölüm 2A) |

## 1. Apple'ın tanımları (kısaca)

- **Collect (toplama):** Veriyi cihazdan çıkarıp siz ve/veya üçüncü taraf ortaklarınız erişebilecek şekilde, gerçek zamanlı isteği karşılamak için gerekenden uzun süre tutmak. **Yalnızca cihazda işlenen veri toplanmış sayılmaz** (öğrenme ilerlemesi, kaydedilen kelimeler, ayarlar).
- **Linked to the user (kullanıcıya bağlı):** Veri; hesap, cihaz veya başka ayrıntılarla (kalıcı bir kimlik dahil) kullanıcıya bağlanıyorsa "bağlıdır". "Bağlı değil" demek için, toplama öncesinde kullanıcı/cihaz kimliğinin çıkarılmış olması gerekir. Rastgele **ama kalıcı** bir kimlik taşıdığımız için **muhafazakâr yorumla "Linked: Yes"** işaretlenir. (RevenueCat'in kendi rehberi anonim kimlikte "No" diyor; biz Apple'ın tanımına göre daha temkinli yorum seçtik **[TEYİT]**.)
- **Tracking (izleme):** Verinin, reklam/ölçüm amacıyla üçüncü tarafların topladığı verilerle eşleştirilmesi veya veri komisyoncularıyla paylaşılması. Bizde **yok**.
- **İsteğe bağlı toplama yine beyan edilir:** Analitik yalnızca rızayla çalışsa da uygulama bu veriyi toplayabildiği için beyan edilir. Apple'ın "isteğe bağlı beyan" istisnası yalnızca seyrek, kullanıcının her seferinde elle girdiği veri için geçerlidir; analitik buna girmez **[TEYİT]**.

## 2. Cevap tablosu (veri türü başına)

**App Store Connect > App Privacy > "Do you or your third-party partners collect data from this app?" → Yes.**
("Data Not Collected" seçeneği **kullanılamaz**; RevenueCat zaten veri topluyor.)

| Apple veri grubu / türü | Collected | Linked to user | Used for tracking | Purposes | Gerekçe ve sebep olan SDK |
|---|---|---|---|---|---|
| **Contact Info**: Name, Email Address, Phone Number, Physical Address, Other User Contact Info | **No** | – | – | – | Hesap/form yok. Kullanıcı bize kendi e-posta uygulamasından yazarsa bu, uygulamanın topladığı veri sayılmaz (V6). **Uygulama içi form eklenirse: Email Address = Yes, Linked, App Functionality.** |
| **Health & Fitness**: Health, Fitness | **No** | – | – | – | HealthKit vb. yok. |
| **Financial Info**: Payment Info, Credit Info, Other Financial Info | **No** | – | – | – | Ödemeyi Apple alır; kart/banka bilgisi bize ve SDK'lara gelmez. (Satın alma tutarı/ürün bilgisi "Purchases" altında beyan edilir.) |
| **Location**: Precise Location | **No** | – | – | – | Konum izni istenmez. |
| **Location**: Coarse Location | **No** *(koşullu)* | – | – | – | PostHog **GeoIP kapalı ve IP atılıyorsa** No. **GeoIP açık kalırsa (varsayılan) şehir düzeyi konum çıkarılır → Yes / Linked / Analytics.** RevenueCat yalnızca yerel ayar ve para birimi toplar (RevenueCat rehberi); App Store ülkesi konum değildir. **[TEYİT: trafik doğrulaması]** |
| **Sensitive Info** | **No** | – | – | – | Irk, din, cinsel yönelim, biyometri vb. yok. Seviye/hedef (ör. YDS) hassas veri değildir. |
| **Contacts** | **No** | – | – | – | Rehber erişimi yok. |
| **User Content**: Emails or Text Messages | **No** | – | – | – | Yok. |
| **User Content**: Photos or Videos | **No** | – | – | – | Fotoğraf erişimi yok (paylaşım kartı yalnızca dışa verilir). |
| **User Content**: Audio Data | **No** | – | – | – | Seslendirme cihazdaki sentezle (AVSpeechSynthesizer); widget hoparlörü de aynı cihaz içi sesi kullanır, ağa çıkmaz (V7). Mikrofon yalnızca "Söyle" telaffuz alıştırmasında, ilk kullanımda (just-in-time) istenir. Ses cihazda tanınır: iOS 26+ `SpeechAnalyzer` (Apple: sesi sunucuya göndermez), iOS 17–25 `SFSpeechRecognizer` + `requiresOnDeviceRecognition`. Dosyaya yazılmaz, cihazdan çıkmaz, analitiğe gitmez; tanınan metin ve sonuç da kaydedilmez (V9, kodda doğrulandı 2026-10-22). Apple: "Data that is processed only on device is not 'collected'". **Ses ya da tanınan metin bir gün sunucuya giderse Yes.** **[TEYİT: taslak-2]** |
| **User Content**: Gameplay Content | **No** | – | – | – | Yok. |
| **User Content**: Customer Support | **No** | – | – | – | Mailto (V6). Uygulama içi destek formu eklenirse Yes / Linked / App Functionality. |
| **User Content**: Other User Content | **No** | – | – | – | Özel listeler cihazda kalır, analitiğe içeriği gönderilmez. (CloudKit v1.2'de verinin kullanıcının özel iCloud alanında olması ve geliştiricinin erişememesi nedeniyle "toplama" sayılmaması beklenir **[TEYİT]**.) |
| **Browsing History** | **No** | – | – | – | Yok. |
| **Search History** | **No** | – | – | – | Sözlük/arama sorguları cihazda kalır. **Analitik olaylarına arama metni eklenmemeli**; eklenirse Yes / Linked / Analytics. |
| **Identifiers**: User ID | **Yes** | **Yes** | **No** | **App Functionality**, **Analytics** | **RevenueCat anonim App User ID** (rastgele, kalıcı). Hesap olmasa da "atanmış kullanıcı kimliği" sayılır (muhafazakâr). Analitik rızası gerekmez; abonelik işlevi için gerekli. |
| **Identifiers**: Device ID | **Yes** *(yalnızca analitik rızasıyla)* | **Yes** | **No** | **Analytics** | **PostHog** rastgele analitik kimliği (distinct ID); SDK varsayılan olarak cihaz kimliği (IDFV) de ekliyor olabilir **[TEYİT: yük doğrulaması]**. **Sentry** kuruluma özgü kimlik. **IDFA toplanmaz.** |
| **Purchases**: Purchase History | **Yes** | **Yes** | **No** | **App Functionality**, **Analytics** | **RevenueCat** (StoreKit işlemleri: ürün, tarih, bitiş, deneme/yenileme/iade durumu). RevenueCat rehberi bu iki amacı seçmeyi öneriyor. |
| **Usage Data**: Product Interaction | **Yes** *(yalnızca rızayla)* | **Yes** | **No** | **Analytics** | **PostHog** olayları: ekranlar, onboarding adımları, widget dokunuşları, öğrenme eylemi sayıları, quiz tamamlama, paywall görüntüleme. |
| **Usage Data**: Advertising Data | **No** | – | – | – | Reklam yok; AdServices atıf jetonu MVP'de kullanılmıyor. **Kullanılırsa yeniden değerlendirin [TEYİT].** |
| **Usage Data**: Other Usage Data | **Yes** *(yalnızca rızayla)* | **Yes** | **No** | **Analytics** | **PostHog:** widget kurulu mu/kaç adet, widget yenileme raporu, seviye/hedef, abonelik durumu, deney grubu, cihaz/OS/uygulama sürümü ve dil özellikleri. |
| **Diagnostics**: Crash Data | **Yes** *(yalnızca Sentry ve rıza ile; V3-B)* | **Yes** *(muhafazakâr; Sentry kuruluma özgü kimlik gönderir. Kimlik/IP gönderilmediği doğrulanırsa "No" düşünülebilir)* | **No** | **App Functionality** | **Sentry:** çökme izi, sürüm ve cihaz modeli. Yalnızca Apple mekanizması kullanılırsa **No**. |
| **Diagnostics**: Performance Data | **No** *(MVP)* | – | – | – | Sentry performans/izleme **kapalı** tutulur. Açılırsa Yes / Linked / App Functionality. Apple MetricKit verisi yalnızca cihazda kalıyorsa toplama sayılmaz. |
| **Diagnostics**: Other Diagnostic Data | **Yes** *(yalnızca Sentry ve rıza ile)* | **Yes** | **No** | **App Functionality** | **Sentry:** cihaz modeli, iOS/uygulama sürümü, bellek/pil gibi olay ekleri. |
| **Other Data**: Other Data Types | **No** | – | – | – | Başka veri türü toplanmaz. (Apple'ın yeni "Surroundings" ve "Body" türleri de uygulanamaz: kamera/derinlik/el-baş izleme yok **[TEYİT: güncel liste]**.) |

**"Tracking" ekranı:** *"Do you or your third-party partners use data from this app for tracking?"* → **No**. ATT istemi gösterilmez, `NSUserTrackingUsageDescription` **eklenmez**.

## 2A. Şimdiki derleme için cevap: "Data Not Collected"

**[TEYİT: Bu bölüm taslak-2'de (22 Ekim 2026) eklendi.]**

Bölüm 2, RevenueCat, PostHog ve isteğe bağlı Sentry içeren **ileriki ticari sürüm** içindir. 22 Ekim 2026'daki kodda (dal `ios/arayuz-sik`) bunların hiçbiri yok. İlk mağaza sürümü ücretsiz ve satın almasız çıkarsa doğru cevap şudur:

**"Do you or your third-party partners collect data from this app?" → No** (etikette "Data Not Collected").

Kodda doğrulananlar (2026-10-22):

| Kontrol | Sonuç | Yer |
|---|---|---|
| Ağ kodu (`URLSession`, `URLRequest`, `NWConnection`) | Yok. Tek istisna: iOS 26+'da Söyle ilk kullanıldığında uygulama, Apple'ın cihaz içi İngilizce konuşma modelini iOS'a indirtir (`AssetInventory`, `PronunciationRecognizer.swift:343`); indirmeyi sistem yapar, kullanıcı verisi gitmez | `ios/App`, `ios/Widgets`, `ios/Shared`, `ios/Packages/VocabKit/Sources` içinde arama |
| Üçüncü taraf SDK | Yalnızca GRDB (yerel SQLite kütüphanesi; ağa çıkmaz) | `ios/Packages/VocabKit/Package.swift:23` |
| RevenueCat / PostHog / Sentry / Firebase | Yok | aynı arama |
| Uygulama manifesti | `NSPrivacyTracking` false, `NSPrivacyCollectedDataTypes` boş; UserDefaults `CA92.1`, FileTimestamp `C617.1` | `ios/App/PrivacyInfo.xcprivacy` |
| Widget manifesti | `NSPrivacyTracking` false; toplanan veri ve required-reason API listesi boş | `ios/Widgets/PrivacyInfo.xcprivacy` |
| Söyle (mikrofon) | Ses cihazda tanınır, dosyaya yazılmaz, cihazdan çıkmaz (V9) | `ios/App/PronunciationRecognizer.swift` |
| Widget hoparlörü | Cihaz içi ses, ağ yok (V7) | `ios/Shared/SpeakWordIntent.swift`, `ios/Shared/WordSpeech.swift` |
| Yerel bildirim | Sunucu ve bildirim anahtarı yok | `ios/App/ReminderScheduler.swift` |

**Tracking → No.** ATT istemi yok, `NSUserTrackingUsageDescription` yok.

Bu cevap verilirse gizlilik politikası ve aydınlatma metni de buna göre sadeleştirilmelidir (`README.md` §4.1); aksi hâlde politika, etikette olmayan bir veri toplamayı (RevenueCat) anlatmış olur. SDK eklendiği gün Bölüm 2'ye geçilir.

**Doğrulama (yayından önce):** temiz kurulumla uygulamayı ve Söyle'yi **uçak modunda** deneyin (cihaz içi çalıştığının pratik kanıtı); bir trafik aracıyla (Proxyman vb.) Apple dışında hiçbir sunucuya istek gitmediğini görün **[TEYİT]**.

## 3. App Store Connect'te nasıl görünür (beklenen etiket)

- **Data Used to Track You:** *(boş)*
- **Data Linked to You:** Purchases (Purchase History), Identifiers (User ID, Device ID), Usage Data (Product Interaction, Other Usage Data), Diagnostics (Crash Data, Other Diagnostic Data) *(son ikisi Sentry kullanılırsa)*
- **Data Not Collected / Not Linked:** *(boş)*

**Ek alanlar:**
- **Privacy Policy URL (zorunlu):** [GİZLİLİK POLİTİKASI WEB ADRESİ] (TR ve EN yerelleştirmeleri için ayrı adres tanımlanabilir **[TEYİT]**).
- **User Privacy Choices URL (isteğe bağlı):** [GİZLİLİK TERCİHLERİ SAYFASI ADRESİ] — analitiği kapatma/silme talebi nasıl yapılır anlatan sayfa **[TEYİT: alan adı ve kullanımı]**.
- **App Review Information > Notes:** Gizlilik/izin ekranının nerede olduğunu ve widget'ın nasıl ekleneceğini yazın; "Analitik ekranı onboarding'in 2. adımında; 'Şimdi değil' seçildiğinde hiçbir özellik kısıtlanmaz."

## 4. SDK × veri matrisi (hangi SDK neden beyan gerektirir)

| SDK / bileşen | Ne zaman çalışır | Beyan gerektiren veri | Notlar |
|---|---|---|---|
| **RevenueCat** (purchases-ios) | Her kullanıcı, uygulama açılışında *(V1)* | User ID, Purchase History | Reklam/atıf entegrasyonları kapalı kalmalı. IP adresi sunucuda görünür; RevenueCat'in IP/IDFV saklama ve toplama listesi **[TEYİT]** |
| **PostHog** (posthog-ios, AB) | Yalnızca analitik rızasıyla | Device ID, Product Interaction, Other Usage Data (+ GeoIP açıksa Coarse Location) | `optOut` varsayılan; IP/GeoIP kapat; autocapture/replay kapat; kimlik rıza anında |
| **Sentry** (sentry-cocoa) — *seçenekli* | Yalnızca ayrı rızayla | Crash Data, Other Diagnostic Data (+ Device ID) | `sendDefaultPii=false`, tracing kapalı, ağ breadcrumb kapalı |
| **Apple çerçeveleri** (StoreKit, WidgetKit, UserNotifications, AVFoundation, App Intents) | Her zaman | Beyan gerekmez | Veri geliştiriciye gelmez; yerel bildirimde sunucuya bildirim anahtarı gönderilmez |
| **Speech** (`SpeechAnalyzer`/`DictationTranscriber` iOS 26+, `SFSpeechRecognizer` iOS 17–25) + mikrofon (`AVAudioEngine`) | Yalnızca Söyle'de, kullanıcı dokununca | Beyan gerekmez (cihazda işlenir, V9) | iOS 26+'da İngilizce modeli `AssetInventory` ile Apple'dan bir kez iner; kullanıcı verisi gitmez. Mikrofon ve konuşma tanıma *required reason API* değildir; manifest değişmez **[TEYİT: taslak-2]** |
| **AVSpeechSynthesizer** (sesli okuma, widget hoparlörü) | Kullanıcı hoparlöre dokununca | Beyan gerekmez | En-US cihaz sesi; Personal Voice ve "novelty" sesler hariç (`Shared/WordSpeech.swift:52–59`); `UIBackgroundModes: audio` yalnızca widget'tan gelen okuma için **[TEYİT: taslak-2]** |
| **GRDB** ve yerel paketler | Her zaman | Beyan gerekmez | Yalnızca *required reason API* beyanı gerekebilir (Bölüm 5) |

## 5. PrivacyInfo.xcprivacy kontrol listesi

### 5.1 Hedefler (her biri kendi manifestini taşır)

- [ ] **Ana uygulama hedefi**: `PrivacyInfo.xcprivacy`
- [ ] **Widget uzantısı (.appex)**: ayrı `PrivacyInfo.xcprivacy` (planlanan klasörde `WidgetExtension/PrivacyInfo.xcprivacy`)
- [ ] **App Intents uzantısı** (ayrı hedef olarak eklendiyse): ayrı manifest
- [ ] **Yerel Swift paketleri** (CoreModels, ContentStore, SharedState, Scheduler, Analytics…): kullandıkları *required reason API*'ler ana uygulama (ve gerekiyorsa widget) manifestinde beyan edilir; paket kendi manifestini taşıyorsa pakete eklenir

### 5.2 Ana uygulama manifesti (içerik)

- [ ] `NSPrivacyTracking` = **false**
- [ ] `NSPrivacyTrackingDomains` = **boş dizi**
- [ ] `NSPrivacyCollectedDataTypes`: Bölüm 2 tablosuyla **birebir aynı** (her biri için `…Linked`, `…Tracking`, `…Purposes`):
  - [ ] `NSPrivacyCollectedDataTypeUserID` → Linked **true**, Tracking **false**, Purposes: `…PurposeAppFunctionality`, `…PurposeAnalytics`
  - [ ] `NSPrivacyCollectedDataTypeDeviceID` → Linked **true**, Tracking **false**, Purposes: `…PurposeAnalytics`
  - [ ] `NSPrivacyCollectedDataTypePurchaseHistory` → Linked **true**, Tracking **false**, Purposes: `…PurposeAppFunctionality`, `…PurposeAnalytics`
  - [ ] `NSPrivacyCollectedDataTypeProductInteraction` → Linked **true**, Tracking **false**, Purposes: `…PurposeAnalytics`
  - [ ] `NSPrivacyCollectedDataTypeOtherUsageData` → Linked **true**, Tracking **false**, Purposes: `…PurposeAnalytics`
  - [ ] *(Sentry varsa)* `NSPrivacyCollectedDataTypeCrashData`, `NSPrivacyCollectedDataTypeOtherDiagnosticData` → Linked **true**, Tracking **false**, Purposes: `…PurposeAppFunctionality`
- [ ] `NSPrivacyAccessedAPITypes`: kodda ve paketlerde **gerçekten** kullanılan *required reason API* kategorileri, doğru neden kodlarıyla. Olası kategoriler (kodu Apple'ın resmi tablosundan **doğrulayın [TEYİT]**):
  - UserDefaults (`NSPrivacyAccessedAPICategoryUserDefaults`): yalnızca uygulamanın kendi verisi için `CA92.1`; **App Group paylaşımı için `1C8F.1`** (planda teyitli)
  - File timestamp (`…FileTimestamp`): ör. kendi kap/App Group dosyaları için `C617.1`
  - Disk space (`…DiskSpace`): ör. yazmadan önce alan kontrolü için `E174.1`
  - System boot time (`…SystemBootTime`): ör. geçen süre ölçümü için `35F9.1`
  - Yalnızca gerçekten kullandıklarınızı yazın; listeden "olabilir" diye eklemeyin.

### 5.3 Widget uzantısı manifesti

- [ ] `NSPrivacyTracking` = **false**, `NSPrivacyTrackingDomains` boş, `NSPrivacyCollectedDataTypes` **boş** (widget veri toplamaz, ağa çıkmaz)
- [ ] `NSPrivacyAccessedAPITypes`: App Group'taki JSON/UserDefaults okuması için gerekli kategoriler (UserDefaults `1C8F.1`; dosya zaman damgası okunuyorsa ilgili kod)

### 5.4 Üçüncü taraf SDK'ların kendi manifestleri

- [ ] **RevenueCat purchases-ios** — sabitlenen sürümde `PrivacyInfo.xcprivacy` pakette var ve pakete dahil mi? **[TEYİT]**
- [ ] **PostHog iOS** — aynı kontrol
- [ ] **Sentry Cocoa** (kullanılıyorsa) — aynı kontrol
- [ ] **GRDB** ve diğer SPM bağımlılıkları (ör. v1.2'de `swift-fsrs`) — aynı kontrol
- [ ] Apple'ın "yaygın kullanılan üçüncü taraf SDK" listesindeki SDK'lar için **manifest ve imza** şartı kontrol edildi mi? **[TEYİT]**
- [ ] SDK'ların manifestindeki veri beyanları, bizim App Store etiketimizle çelişmiyor (SDK daha çok veri beyan ediyorsa etiketi veya SDK ayarını düzeltin)

### 5.4a Şimdiki manifestler (2026-10-22, kodda) **[TEYİT: taslak-2]**

- Uygulama: UserDefaults `CA92.1` (yalnız `UserDefaults.standard`; App Group'ta UserDefaults kullanılmıyor, paylaşım dosyayla), FileTimestamp `C617.1` (günlük ilerleme yedeği). Yukarıdaki `1C8F.1` maddesi App Group UserDefaults kullanılırsa gerekir; şu an gerekmez.
- Widget: required-reason API listesi boş. Uzantı dosya zaman damgası, disk alanı veya açılış süresi API'si kullanmıyorsa doğru **[TEYİT: Xcode Privacy Report ile]**.

### 5.5 Doğrulama adımları (her gönderimden önce)

1. [ ] **Xcode > Product > Archive**, sonra arşiv üzerinde **Generate Privacy Report** (tüm manifestleri birleştiren PDF). Rapordaki veri türleri Bölüm 2 ile aynı mı?
2. [ ] **Trafik testi (Proxyman / Charles / mitmproxy):**
   - Rıza **verilmemiş** hâlde uygulamayı temiz kurulumla çalıştırın: PostHog ve Sentry sunucularına **hiç istek gitmemeli**; yalnızca RevenueCat ve Apple trafiği görünmeli.
   - Rıza **verilmiş** hâlde yükleri inceleyin: IP/GeoIP, IDFV, cihaz adı, kelime içeriği, arama metni var mı? Yoksa Bölüm 2'ye aynen uyun.
   - "Rıza geri alma" sonrası yeni istek gitmediğini doğrulayın.
3. [ ] RevenueCat panelinde **Integrations** altında hiçbir reklam/atıf/analitik entegrasyonunun açık olmadığını, `collectDeviceIdentifiers()`'ın çağrılmadığını doğrulayın.
4. [ ] App Store Connect'e yükleme sonrası gelen e-postalardaki **gizlilik manifesti/required reason API uyarılarını** (ITMS-91053, ITMS-91061 gibi) kontrol edin **[TEYİT: güncel kodlar]**.
5. [ ] App Store Connect cevaplarını bu kâğıtla karşılaştırıp **kaydedin** (ekran görüntüsü + tarih).
6. [ ] Gizlilik politikasının (TR/EN) aynı sürümde yayında olduğunu ve App Store Connect URL'sinin çalıştığını doğrulayın.

### 5.6 İzin metinleri (Info.plist) tutarlılık kontrolü **[TEYİT: taslak-2]**

Kaynak: `ios/project.yml` (XcodeGen, `targets.Lockglow.info.properties`). Bu belgede yalnızca kontrol edildi; `project.yml` değiştirilmedi.

| Anahtar | Şimdiki metin (`project.yml` satırı) | Belgelerle tutarlı mı? | Not |
|---|---|---|---|
| `NSMicrophoneUsageDescription` | "Söyle alıştırmasında söylediğin kelimeyi dinlemek için mikrofon kullanılır. Ses kaydedilmez ve telefondan çıkmaz." (64) | **Evet** (kayıt yok, cihazdan çıkmıyor) | **Küçük uyumsuzluk:** Söyle'de örnek cümle modu da var (`PronunciationPracticeView.swift:52`); metin yalnızca "kelimeyi" diyor. Öneri: "…söylediğin kelimeyi ya da cümleyi dinlemek için…" |
| `NSSpeechRecognitionUsageDescription` | "Kelimeyi doğru söyleyip söylemediğini anlamak için konuşma tanıma yalnızca telefonda çalışır. Sesin Apple'a ya da başka bir sunucuya gönderilmez." (65) | **Evet** (`requiresOnDeviceRecognition = true`) | Bu izin yalnızca iOS 17–25'te sorulur; iOS 26+'da kod sormaz (`PronunciationRecognizer.swift:153–162`). Politika §3.7 de böyle diyor. Aynı "kelime/cümle" notu geçerli. |
| `UIBackgroundModes: audio` | Widget hoparlörü için (70–73) | **Evet** (politika §3.8) | App Review 2.5.4: arka plan modu yalnızca amacına uygun kullanılmalı. İnceleme notuna yazın: "Arka plan ses modu yalnızca ana ekran widget'ındaki 'Kelimeyi dinle' düğmesinin okuması için; mikrofon arka planda açılmaz." |
| `NSUserTrackingUsageDescription` | Yok | **Evet** (izleme yok) | — |
| `ITSAppUsesNonExemptEncryption` | `false` | — | Gizlilikle ilgisi yok; ihracat beyanı. |
| Bildirim izni | Info.plist anahtarı gerekmez | **Evet** (yerel bildirim) | — |

**Bulunan uyumsuzluklar:**

1. **Dil:** İzin metinleri yalnızca Türkçe; `developmentLanguage: en`, `InfoPlist.strings`/`.xcstrings` yok. İngilizce mağaza yerelleştirmesi açılırsa İngilizce kullanıcı Türkçe izin penceresi görür. Mağazadan önce İngilizce karşılık eklenmeli (taslak: "Söyle listens to the word or sentence you say. Nothing is recorded, and your voice never leaves your iPhone." / "Speech recognition runs only on your iPhone to check how you said it. Your voice is not sent to Apple or any server.").
2. **"Kelime" / "cümle":** yukarıdaki not; metin dar, yanıltıcı değil.
3. **Hitap:** İzin metinleri "sen" diliyle (uygulama arayüzüyle aynı), yasal metinler "siz" diliyle. Bu bilinçli bir seçim (README §8); çelişki sayılmaz.

## 6. Yeniden kontrol kuralı

**Her SDK değişikliğinden sonra bu kâğıt, manifestler, App Store etiketi ve gizlilik politikası yeniden kontrol edilir.** SDK'nın yeni bir sürümü (küçük sürüm dahil) varsayılan olarak yeni veri toplamaya başlayabilir. Aşağıdaki durumlarda **yayın öncesi** yeniden kontrol zorunludur:

- SDK eklendi/çıkarıldı/yükseltildi (RevenueCat, PostHog, Sentry, GRDB, yeni analitik/atıf aracı),
- Analitiğe yeni olay veya özellik eklendi; PostHog/Sentry ayarı (GeoIP, replay, autocapture, tracing) değişti,
- **Yeni özellik:** CloudKit senkronu (v1.2), içerik güncellemeleri için CDN (IP adresi sunucu günlüğüne düşer), Söyle'de ses ya da tanınan metnin cihazdan çıkması (sunucuya giderse Audio Data = Yes), Söyle sonuçlarının analitiğe gönderilmesi (Product Interaction; tanınan metin giderse ayrıca Audio Data / Other User Content), sesli okumada bulut seslendirme (TTS) kullanılması (okunan metin ve IP sunucuya gider) **[TEYİT: taslak-2]**, hesap/giriş, uzaktan push (bildirim anahtarı), Apple Ads AdServices atıfı, uygulama içi destek formu, yapay zekâ özellikleri (5.1.2(i): üçüncü taraf yapay zekâya veri gönderme için açık izin),
- RevenueCat entegrasyonları veya paywall deneyleri değişti.

### SDK değişiklik kaydı (doldurulacak)

| Tarih | SDK / sürüm | Değişiklik | Etiket etkisi | Politika etkisi | Kontrol eden |
|---|---|---|---|---|---|
| [TARİH] | | | | | |

---

*Son güncelleme: [TARİH] · Sürüm: taslak-2*
