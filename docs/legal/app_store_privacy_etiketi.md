# App Store Connect "App Privacy" Cevap Kâğıdı ve PrivacyInfo.xcprivacy Kontrol Listesi

**Lockglow** · iOS 17+ · App + Widget Extension · Sürüm: taslak-1 · Tarih: [TARİH]

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
| V7 | Widget uzantısında **ağ erişimi ve üçüncü taraf SDK yoktur**; yalnızca App Group'taki yerel veriyi okur. | Kod incelemesi |
| V8 | Arka uç yok. İçerik uygulama paketinde gelir (CDN/CloudKit **sonraki sürümlerde**; bkz. Bölüm 5, "yeniden kontrol tetikleyicileri"). | — |

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
| **User Content**: Audio Data | **No** | – | – | – | Seslendirme cihazdaki sentezle (AVSpeechSynthesizer). Mikrofon yalnızca "Söyle" telaffuz alıştırmasında, ilk kullanımda (just-in-time) istenir. Ses cihazda tanınır: iOS 26+ `SpeechAnalyzer` (Apple: sesi sunucuya göndermez), iOS 17–25 `SFSpeechRecognizer` + `requiresOnDeviceRecognition`. Dosyaya yazılmaz, cihazdan çıkmaz, analitiğe gitmez. Apple: "Data that is processed only on device is not 'collected'". **Ses ya da tanınan metin bir gün sunucuya giderse Yes.** |
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

## 6. Yeniden kontrol kuralı

**Her SDK değişikliğinden sonra bu kâğıt, manifestler, App Store etiketi ve gizlilik politikası yeniden kontrol edilir.** SDK'nın yeni bir sürümü (küçük sürüm dahil) varsayılan olarak yeni veri toplamaya başlayabilir. Aşağıdaki durumlarda **yayın öncesi** yeniden kontrol zorunludur:

- SDK eklendi/çıkarıldı/yükseltildi (RevenueCat, PostHog, Sentry, GRDB, yeni analitik/atıf aracı),
- Analitiğe yeni olay veya özellik eklendi; PostHog/Sentry ayarı (GeoIP, replay, autocapture, tracing) değişti,
- **Yeni özellik:** CloudKit senkronu (v1.2), içerik güncellemeleri için CDN (IP adresi sunucu günlüğüne düşer), Söyle'de ses ya da tanınan metnin cihazdan çıkması (sunucuya giderse Audio Data = Yes), hesap/giriş, uzaktan push (bildirim anahtarı), Apple Ads AdServices atıfı, uygulama içi destek formu, yapay zekâ özellikleri (5.1.2(i): üçüncü taraf yapay zekâya veri gönderme için açık izin),
- RevenueCat entegrasyonları veya paywall deneyleri değişti.

### SDK değişiklik kaydı (doldurulacak)

| Tarih | SDK / sürüm | Değişiklik | Etiket etkisi | Politika etkisi | Kontrol eden |
|---|---|---|---|---|---|
| [TARİH] | | | | | |

---

*Son güncelleme: [TARİH] · Sürüm: taslak-1*
