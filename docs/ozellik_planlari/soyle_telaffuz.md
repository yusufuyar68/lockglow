# Söyle (sesli telaffuz alıştırması): teknik plan

> Durum: taslak, 2. sürüm (2026-10-21, denetim sonrası; ilk taslak 2026-10-20). Taban: `main` d99180e (`ios/zor-kolay` ve `icerik/s13-sosyal` birleşti; `ReviewGrade` artık again/hard/good/easy).
> **Temel: `ios/telaffuz` dalındaki mevcut uygulama.** Dal temiz bir çalışma dalı DEĞİL: merge-base `df1b3d0`, üstünde başka bir oturumun yazdığı 2 commit var (`93037d9` "Söyle: cihaz içi sesli telaffuz alıştırması", `2fccd80` "Söyle: project.yml'ye Pronunciation ürünü ve izin metinleri"; ikisi 2026-10-20 21:03; 12 dosya, +1669 satır). İçinde: Akış ve Sözlük'te `SayButton`, `PronunciationPracticeView` (Kelime / Örnek cümle), `PronunciationRecognizer` (iOS 26 `SpeechAnalyzer`, iOS 17-25 `SFSpeechRecognizer`), saf `Pronunciation` modülü (`PronunciationCheck` + 217 satırlık test), project.yml'de iki izin anahtarı, `docs/legal` gizlilik metinleri, README "Söyle" bölümü. Kendi README'sine göre hiç derlenmedi, cihazda denenmedi.
> Bu planın ilk taslağı aynı işi baştan tasarlıyordu (`SayListener`, `SpokenMatcher`, `SayCenter`, `SayAvailability`, `SayWordView`...). İki paralel uygulama aynı hunk'larda çakışacağı ve denetim motor kararlarında (SpeechAnalyzer, `contextualStrings` yok) dalı haklı çıkardığı için o tasarım BIRAKILDI. Bu plan dalı temel alır; "fark listesi + Söyle turu"dur. Karar sahibin onayına bağlı: **[KULLANICIYA SOR: Soru 1]**.
> Dal başka bir oturumun worktree'sinde açık (`.../83524679-cd2c-4d15-b447-9faa3acffce9/scratchpad/wt`); git aynı dalı ikinci worktree'de açmaz. O oturum kapatılır ya da dalın ucundan yeni ad açılır (örn. `ios/telaffuz-tur`).
> Bu plan uygulama kodu yazmaz; başka bir oturumun yeniden araştırma yapmadan uygulayabilmesi için yazıldı. `(yeni)` = bu planın uydurduğu isim. `[TEYİT]` = cihazda ya da derleyicide doğrulanmamış varsayım. **[KULLANICIYA SOR]** = sahibinin kararı gereken konu.

## 1. Amaç ve kapsam

**Neden.** Lockglow'un kullanıcısı (A2, Türk) kelimeyi widget'ta görüyor ve "Dinle" ile duyuyor (`Speaker`, `SpeakButton`), ama kendi söylediğini hiç denemiyor. Ekim 2026'da Orbit ("söyle ve kontrol et"), Lingo Widget ve Wordismo telaffuz/konuşma alıştırması ekledi; Kolay İngilizce widget kurulum rehberi ekledi (`raporlar/14_guncel_fark_raporu.md`). Lockglow'un farkı: tanıma cihaz içinde (iOS 26'da İngilizce model bir kez iner), hesap yok, Türkçe ve dürüst geri bildirim ("telefon seni anladı mı?"; yüzde, puan, yıldız yok).

**Aşamalar.** Aşama 1: dalda hazır tek kelime sayfası (Akış, Sözlük). Derlenir, cihazda denenir, küçük düzeltmeler yapılır. Aşama 2 (bu planın asıl yeni işi): Tekrar sekmesinde 8 kelimelik "Söyle turu". Aşama 3 (koşullu): kalıcı Söyle istatistiği.

**Kararlar (özet).**

| Konu | Karar | Gerekçe |
|---|---|---|
| Temel | `ios/telaffuz` devralınır; ikinci bir Söyle uygulaması yazılmaz. | Aynı dosyalar, aynı Info.plist anahtarları, aynı README/`docs/legal` bölümleri ikinci kez yazılırsa çakışır. |
| Tanıma motoru | Dalda olduğu gibi: iOS 26+ `SpeechAnalyzer` + `DictationTranscriber` (model `AssetInventory` ile ilk kullanımda iner); iOS 17-25 `SFSpeechRecognizer(locale: en-US)` + `requiresOnDeviceRecognition = true`, yalnız `supportsOnDeviceRecognition` ise. Sunucuya düşme yok. **`contextualStrings` KULLANILMAZ.** | Hedefe yatkınlık yanlış söyleyeni de "Doğru" yapar ve "telefon seni anladı" cümlesini dürüst olmaktan çıkarır (dalın README'si de bu yüzden kullanmıyor). iOS 26 yolu, Türkçe klavyeli telefonda İngilizce klavye/Dikte kurma şartını kaldırır. |
| Eşleştirme | `PronunciationCheck` (dalda, saf). İki ekleme: "yalnız eksik kelime" = Neredeyse; eş sesli tablosu desteye göre genişler (5.1). | Tanıyıcı telaffuz kalitesi ölçmez, "anlaşıldı mı"yı ölçer. |
| Leitner | **Etkilemez.** | 1.1 |
| Giriş noktaları | (1) Akış ve Sözlük: `SayButton` (dalda; ikon düğmeye çevrilir). (2) Tekrar: "Söyle alıştırması" kartı + 8 kelimelik tur (yeni). | Yeni sekme yok. |
| Ses oturumu | Dalda: dinlerken `.playAndRecord` (`.measurement`, `.duckOthers`, `.defaultToSpeaker`), her denemeden sonra kapatılır; `Speaker` oturum koduna dokunulmaz (`PronunciationRecognizer.prepare()` konuşan sesi durdurur). | `Speaker.toggle` hep `.playback` kurar; ikisi aynı anda açık olamaz. |
| İzin | İlk mikrofon dokunuşunda, o anda (iOS 26: yalnız mikrofon; iOS 17-25: mikrofon, reddedilmezse konuşma tanıma). Açıklama (primer) ekranı yok; onboarding'de izin istenmez. | `prepare()` mikrofon reddinde durur, ikinci pencere açılmaz. |
| Kullanılamıyorsa | Düğmeler ve kart gizlenmez, soluk yapılmaz; neden `ProblemPanel`'de yazılır. Kalıcı "kapalı" durumu tutulmaz. | Durum her dokunuşta yeniden okunur; bayat durum riski yok. |
| Kalıcı veri | YOK (v1): dosya, UserDefaults anahtarı, App Group yazımı yok. Tur dönüşü bellekte. | Stats yalnız 8 kelimelik sırayı etkilerdi; cihaz testi isterse Aşama 3. |

### 1.1 Neden Leitner'e bağlamıyoruz (v1)
- Yanlış-olumsuz (tanıyıcı doğru söyleneni anlamadı) sık olur. `Leitner.review(.again)` kelimeyi kutu 1'e indirir, `lapses` artırır, "Biliyorum" diyenin `knownOverride`'ını siler; telaffuz hatası için kullanıcıyı cezalandırmak yanlış.
- `.good/.easy` kutu ilerletir; aralıklar anlam hatırlama içindir. `AppModel.recordReview` günlük yeni kelime hakkını da harcar (`AppPreferences.addNewWordsStudied`).
- `WordProgress` sentezlenmiş `Codable`; yeni zorunlu alan eski `progress.json`'u çözülemez yapar.
- Sonraki sürüm seçeneği (bu planda YOK): yalnız olumlu etki ya da Söyle sonrası kullanıcının kendi Zor/Kolay seçimi.

### 1.2 Bu sürümde olmayanlar
Ses kaydı/oynatma (hiçbir ses saklanmaz), fonem puanı, yüzde/puan/yıldız, kalıcı Söyle istatistiği ve Ayarlar bölümü (Aşama 3), açıklama (primer) ekranı, `SayAvailability` durum matrisi, ikinci motor soyutlaması (`SayListener`), yazım yakınlığı ("borrows" ≈ "borrow"), kısaltma açılımı ("don't" ≡ "do not"), konuya göre tur (Deste işi), widget'ta mikrofon, yeni UserDefaults anahtarı, App Group'a yazma, `WidgetWord`/`CardDetail` şeması değişikliği.

## 2. Kullanıcı akışı

**A. Tur (yeni, Aşama 2).**
1. Tekrar sekmesinin başlangıç ekranında "Başla" kartının altında "Söyle alıştırması" kartı görünür.
2. Karta dokun: tam ekran tur açılır, ilk kelime görünür (kelime, okunuşu, Türkçe anlamı). Bu noktada izin penceresi AÇILMAZ.
3. İstersen hoparlöre dokunup doğrusunu dinlersin. Sonra "Söyle"ye dokun. İlk seferde iOS mikrofon izni sorar (iOS 17-25'te ardından konuşma tanıma izni; iOS 26'da yalnız mikrofon, ve ilk kullanımda İngilizce konuşma modeli bir kez iner).
4. Kelimeyi söyle. Sustuktan yaklaşık 0,9 sn sonra ya da "Bitti"ye dokununca dinleme biter (en çok 5 sn).
5. Telefon bakar ve gösterir: **Doğru!**, **Neredeyse!**, **Bir daha dene** ya da **Seni duyamadım**.
6. Doğru ise "Sonraki". Değilse "Bir daha söyle" (sınırsız deneme) ya da "Geç".
7. Son kelimeden sonra (ya da "Bitir"e dokununca) özet gelir. "Yeni tur" sıradaki kelimeleri getirir, "Kapat" turu kapatır.

**B. Tek kelime (dalda var, Aşama 1).** Akış kartında ya da Sözlük kartında kelimenin yanındaki mikrofon düğmesine dokun; "Söyle" sayfası alttan açılır (Kelime / Örnek cümle seçimi), "Kapat" ile kapanır.

**C. İzin reddedilmiş.** `ProblemPanel` ilgili nedeni yazar ("Mikrofon izni kapalı" / "Konuşma tanıma izni kapalı") ve "Ayarları aç" düğmesi koyar. Ayarlar'dan dönüp "Söyle"ye yeniden dokununca izin yeniden okunur (`prepare()` her denemede çalışır).

**D. Cihaz kullanamıyor.** Aynı panel nedeni yazar (model indirilemedi, cihaz içi İngilizce tanıma kurulu değil, kısıtlı). Düğmeler ve kart yine görünür.

**E. Kesinti.** Uygulama `.active` olmaktan çıkınca (arka plan, kilit, arama, Siri) ya da sayfa kapanınca dinleme iptal edilir, sonuç kaydedilmez. Ses oturumu kesintisi için ayrıca `AVAudioSession.interruptionNotification` dinlenir (5.3). Arka planda asla dinlenmez.

## 3. Ekranlar ve metinler

Stil: mevcut sistem bileşenleri (`.thinMaterial` kartlar, `.borderedProminent`); mockup renk jetonları uygulamada yok, kullanılmaz. Anlam yalnız renkle verilmez (simge + sözcük). 44 pt dokunma alanı. Dizeler `Text` içine Türkçe sabit yazılır (yerelleştirme altyapısı yok).

### 3.1 Giriş kartı `SayEntryCard` (yeni; Tekrar başlangıcı)
Kart (köşe 16, `.thinMaterial`, `roundSummary` ile aynı biçim): solda `mic.circle.fill`, ortada iki satır, sağda `chevron.right`; tüm kart tek düğme. **Etiket "Başla" ile BAŞLAMAMALI** (UI testi `BEGINSWITH "Başla"` arıyor).
- Başlık: **Söyle alıştırması**
- Alt metin: Kelimeyi yüksek sesle söyle, telefon seni dinlesin.
- Küçük satır: `Bu tur: \(n) kelime` (n = o an `PracticePlanner.pick` sonucunun gerçek sayısı; 8 yazılmaz).
- VoiceOver: etiket "Söyle alıştırması", ipucu "Mikrofonla kelime söyleme turunu açar."
- Planner boş dönerse (Akış listesi boş) kart çizilmez. Başka durumda kart hep dokunulur; sorun turda yazılır.

### 3.2 Tur ekranı `SayRoundView` (yeni; `.fullScreenCover`, NavigationStack)
- Üst: sağda "Bitir" (ReviewView ile aynı; özete götürür), `ProgressView(value: Double(index), total: Double(words.count))`, altında `\(index + 1) / \(words.count)`.
- Gövde (kaydırılır): kelime `largeTitle.bold` (çok satıra bölünebilir; `Text`'e `.layoutPriority(1)`) + `SpeakButton(text: lemma, accessibilityName: "Kelimeyi dinle")`, okunuşu `ipaUS`, `pos · level`, Türkçe anlam `title.weight(.semibold)` (`glossTR`). Birden çok sözcüklü kelimede küçük ipucu: "Kelime grubunun hepsini söyle."
- Durum satırı ve sonuç: dalda hazır `statusView` metinleri, `FeedbackPanel`, `ProblemPanel` (3.4); bu üçü `private` olmaktan çıkarılıp paylaşılır.
- **Alt çubuk (kaydırmanın DIŞINDA, `.safeAreaInset(edge: .bottom)`)**, `ReviewView.answerArea` gibi SE'de her zaman görünür:

| Durum | Birincil düğme | İkincil |
|---|---|---|
| boşta (sonuç yok) | `mic.fill` **Söyle** | Geç |
| preparing / checking | pasif **Söyle** | yok |
| listening | `stop.fill` **Bitti** | yok |
| sonuç Doğru | **Sonraki** (son kelimede **Bitir**) | Bir daha söyle |
| sonuç Doğru değil ya da hata | **Bir daha söyle** | Geç |

3. başarısız denemeden sonra küçük not: "Takıldıysan Geç'e dokun, başka zaman yine denersin." Dinlerken ekranda "Dinliyorum..." etiketi sürekli görünür (App Review 2.5.14). Düşük Hareket'te `symbolEffect` kapalı (dalda var).

### 3.3 Tur özeti (yeni; `SayRoundView` içinde)
Başlık **Tur bitti**. `a` = denenen kelime, `k` = doğru söylenen, `y` = neredeyse olan.

| Durum | Gövde |
|---|---|
| k > 0 | `\(a) kelime denedin, \(k) tanesini doğru söyledin.` (y > 0 ise ikinci satır: `\(y) tanesi neredeyse tamamdı.`) |
| k = 0, a > 0 | Bu tur zor geçti. Sorun değil, istediğin zaman yeniden deneyebilirsin. |
| a = 0 (hepsi geçildi) | Bu sefer kelimeleri geçtin. İstediğin zaman yeniden dene. |

Yalnız k > 0 iken ve doğru olmayan denenmiş kelime varsa bölüm **Biraz daha çalış** ve kelimeler ("borrow · luggage"). k = 0 iken bu başlık yok. Düğmeler: **Yeni tur** (birincil), **Kapat**. Hiçbir yerde yüzde yok; ton Tekrar'ın "Güzel iş!" özetiyle uyumlu, suçlayıcı değil.

### 3.4 Dalda hazır ekranlar (referans; kaynak kod, bu tablo `2fccd80` halidir)
`PronunciationPracticeView`: segmentli "Kelime" / "Örnek cümle", `SpeakButton`, durum satırı, `FeedbackPanel`, `ProblemPanel`, büyük mikrofon düğmesi, dipnot "Ses telefondan çıkmaz ve kaydedilmez." Sonuç metinleri (`PronunciationFeedback`):

| Sonuç | Başlık | Mesaj |
|---|---|---|
| `correct` | Doğru! | Anlaşılır söyledin. |
| `almost` | Neredeyse! | Anlaşıldı ama tam net değildi. Bir kez daha söyle. / Şunlar duyulmadı: \(kelimeler). Bir daha dene. |
| `tryAgain` | Bir daha dene | 'X' duydum. Önce hoparlör düğmesiyle dinle, sonra yavaş ve net söyle. (ya da th, w/v, son ses ipucu) |
| `notHeard` | Seni duyamadım | Mikrofona yakın, net bir sesle söyle. |

`ProblemPanel` başlığı "Söyle şu an çalışmıyor"; mesajlar `Problem` durumuna göre. **Değişen tek metin** (`onDeviceUnavailable`, iOS 17-25; Apple forum 731230'daki üç önkoşul [TEYİT]): "Bu telefonda cihaz içi İngilizce tanıma hazır değil. Ayarlar > Genel > Klavye bölümünde İngilizce (ABD) klavyeyi ekle, Dikte'yi aç ve Dikte Dilleri'nden İngilizce'yi indir. Sonra bir daha dene." Diğer mesajlar aynen kalır.

### 3.5 Mikrofon düğmesi (Akış ve Sözlük)
`SayButton(word:example:)` başlık satırında yazılı "Söyle" etiketi yerine ikon düğme olur: `mic.circle`, `.font(.title3)`, 44 pt, `.accessibilityLabel("Söyle: telaffuzunu dene")` (`SpeakButton` ile aynı biçim). Gerekçe: "look forward to" gibi uzun lemmalar SE'de (240 pt kullanılabilir genişlik) iki düğmeyle birlikte 3-4 satıra bölünürdü. Sheet başlığı "Söyle" kalır. [KULLANICIYA SOR: Soru 6]

## 4. Veri ve durum

- **UserDefaults: yeni anahtar yok.** `AppPreferences` değişmez. İzin durumunun kendisi doğruluk kaynağıdır.
- **Dosya: yok.** Ses, tampon ya da transkript diske yazılmaz, `Logger`'a düşmez.
- **App Group: hiçbir şey yazılmaz.** `widget_plan.json`, `widget_state.json`, olay dosyaları etkilenmez. Sonuçlar `WordProgress`, `AppPreferences.newWordsStudied*` ve Leitner'e dokunmaz.
- **Yalnız bellekte:** `SayMemory.practicedIDs` (yeni; bu oturumda turda geçilen ya da denenen kelime kimlikleri, tur dönüşü için; uygulama kapanınca sıfırlanır) ve `SayDiagnostics.takes` (yeni; son 20 deneme: motor, aday sayısı, güven, hata kodu, sonuç; cihaz testi içindir).
- **Mevcut kullanıcılar:** geçiş yok. **Sıfırlama:** "İlerlemeyi sıfırla" etkisiz (`AppModel.resetProgress` değişmez).
- **Aşama 3 (koşullu; yalnız cihaz testi "kalıcı sayı istiyorum" derse):** Application Support/`pronunciation.json`, ayrı dosya (`WordProgress`'e alan eklenmez). Gereksinimler: `ProgressStore` gibi iki ayrı sonuç, yani dosya var ama okunamıyorsa (kilitli cihaz) `load` hata atar, dosyaya dokunulmaz ve kaydedilmez; çözülemiyorsa `pronunciation.corrupt.json` olarak kenara alınır. Okunamadıysa `sceneDidBecomeActive`'de yeniden denenir (`AppModel.sceneDidBecomeActive` örneği). Tüm API `public`, enum'larda `Comparable` gerekirse elle `<` yazılır (`Level.swift:30` örneği; raw type'lı enum'a SE-0266 sentezlemez). Kayıt anahtarı `WidgetWord.id`. Gizlilik metnine tek cümle: Söyle sayıları cihazda kalır ve "İlerlemeyi sıfırla" ile silinir. Ayarlar'da yeni bölüm AÇILMAZ; mevcut `progressSection`'a bir satır eklenir.

## 5. Kod değişiklikleri

### 5.1 VocabKit (saf mantık, Linux'ta test edilir; Apple çerçevesi import edilmez)

**`PronunciationCheck` (dalda: `Sources/Pronunciation/PronunciationCheck.swift`), iki değişiklik:**
1. `evaluate`: `inAlternative` denetiminden sonra, `heardShare` hesabından önce yeni kural: hedefte en az 2 belirteç, hizalamada (`align`) hiç `.substitute` yok ve tam 1 `.missing` varsa → `.almost`, `missedWords` = eksik kelime. Sonuç: "get up" ← "get", "run out of" ← "run out", "look forward to" ← "forward to" için "Neredeyse! Şunlar duyulmadı: up." Kural bilerek "yalnız eksik" ister: yanlış parçacıklı çiftler (turn on/off, get in/on, put on/off, take off/out, check in/out, look for/after, go out/on) `.substitute` içerdiği için `tryAgain` kalır. (İlk taslağın "LCS n-1" kuralı bunları yanlışlıkla "Eksik kelime: on" sayardı; `content.sqlite`'ta turn on ve turn off kartları var.) Tek belirteçli hedefler etkilenmez (n ≥ 2 şartı).
2. `homophoneGroups` `private`'tan `public static let`'e çıkar (test erişimi; "hiçbir sözcük iki grupta değil" `canonicalSpelling` için değişmez kuraldır) ve desteye göre genişler. Yeni gruplar (temsilci ilk sözcük): `do due dew`, `board bored`, `key quay`, `need knead kneed`, `leak leek`, `lesson lessen`, `peel peal`, `rest wrest`, `slow sloe`, `sore soar`, `flu flew flue`, `guest guessed`, `browse brows`, `cash cache`, `check cheque`, `choose chews`, `find fined`, `hair hare`, `mind mined`, `pain pane`, `rain reign rein`, `seem seam`, `bread bred`. Kural: yalnız Genel Amerikan İngilizcesinde AYNI okunanlar; her grubun en az bir üyesi destedeki lemma (`content.sqlite`, 753 kart; 2026-10-21 sorguyla doğrulandı). `its/it's`, `your/you're` bilerek yok (apostrof atılıyor, tek belirteç olmuyor).

**`PracticePlanner` (yeni; `Sources/Learning/PracticePlanner.swift`, `Package.swift` değişmez):**
```swift
public enum PracticePlanner {
    public static let roundSize = 8
    public static func pick(feed: [WidgetWord], progress: [Int: WordProgress],
                            practiced: Set<Int>, limit: Int = roundSize) -> [WidgetWord]
}
```
Kurallar (rastgelelik yok; aynı girdi aynı çıktı; `limit <= 0` → boş):
1. Aday: `feed`'de her kimliğin ilk geçişi; lemması en az bir harf içermeli; lemma anahtarı (`lemma.lowercased()`, boşluklar kırpılmış) başına yalnız ilk kelime (content'te 11 yinelenen lemma var: break, change, check out, free, give up, pick up, put on, smell, take off, turn down, work out). Turda aynı söylenecek kelime iki kez gelmez.
2. `practiced` kimlikleri ve onlarla aynı lemma anahtarını taşıyanlar elenir. Eleme sonrası aday kalmazsa ve `practiced` boş değilse `practiced` yok sayılır (tur başa sarar).
3. Havuz A = kullanıcının karşılaştığı kelimeler (`progress[id]` var ve `state != .new` ya da `exposures > 0`), `lastSeenAt` azalan (nil sonda), eşitlikte feed sırası. Havuz B = diğerleri (yeni), feed sırası. Sonuç = A + B, ilk `limit` tane.
4. `feed` argümanı: main'de `model.words`; `ios/acilis-deste` birleşince `model.feedWords` (kullanıcının destesi). Bu tek satırdır (9).

### 5.2 Dalda hazır olanlar (değişmez; `ios/telaffuz`)
`ios/App/PronunciationRecognizer.swift` (`PronunciationRecognizer`: `Problem`, `Phase`, `start(_:maxSeconds:)`, `finish()`, `cancel()`, `isBusy`; `SpeechBackend`, `AnalyzerBackend`, `RecognizerBackend`, `TakeMonitor`), `ios/App/PronunciationPracticeView.swift` (`SayButton`, `PronunciationPracticeView`, `FeedbackPanel`, `ProblemPanel`), `Sources/Pronunciation/PronunciationCheck.swift` (+ `PronunciationTests`), `Package.swift` (ürün `Pronunciation`), `project.yml` (iki `NS*UsageDescription`, app hedefinde `Pronunciation` ürünü), `docs/legal` §3.7, README "Söyle" bölümü. Widget hedefi `Pronunciation`'ı bağlamaz (doğru). `ios/Tools/linux_check_prepare.py` `APP_LOGIC_FILES` listesine yeni SwiftUI dosyası EKLENMEZ.

### 5.3 Değişenler ve yeni dosyalar (hepsi küçük)
**Yeni (`ios/App/`; `App/` klasörü project.yml'de otomatik alınır):**
- `SayMemory.swift`: `@MainActor final class SayMemory: ObservableObject { @Published private(set) var practicedIDs: Set<Int>; func markPracticed(_ ids: [Int]) }`.
- `SayEntryCard.swift`: 3.1. Dokununca `PracticePlanner.pick(feed: model.words, progress: model.progress, practiced: memory.practicedIDs)` hesaplanır, tur `.fullScreenCover` ile açılır.
- `SayRoundView.swift`: 3.2 ve 3.3. Her kelime için `.id(word.id)` ile ayrı `@StateObject PronunciationRecognizer`; hedef `PronunciationTarget(text: word.lemma, ipa: word.ipaUS)`, `maxSeconds: 5`. `.onChange(of: recognizer.phase)` ile `.finished(feedback)` yakalanır; kelime başına en iyi sonuç tutulur (sıralama için küçük özel `rank` fonksiyonu; `Verdict` `Comparable` değil). `scenePhase != .active` ve `onDisappear` → `cancel()` (dalın örneği). "Yeni tur" `PracticePlanner.pick`'i tekrar çağırır; tur bitince denenen ve geçilen kimlikler `SayMemory.markPracticed`'e gider (yarım bırakılan kelimeler işaretlenmez).
- `SayDiagnostics.swift`: `@MainActor final class SayDiagnostics: ObservableObject { static let shared; @Published private(set) var takes: [String] }` ve küçük `SayDiagnosticsView`.

**Dalda olup değişenler:**
- `PronunciationPracticeView.swift`: `SayButton` ikon düğme (3.5); `FeedbackPanel`/`ProblemPanel` `private` kalkar; mikrofon düğmesi `.safeAreaInset(edge: .bottom)` içine alınır (`.medium` yükseklikte kaydırmadan basılabilsin); mikrofon düğmesinin eyleminde `recognizer.start` ÖNCESİNDE hafif haptik (`UIImpactFeedbackGenerator`; ses oturumu henüz etkin değil, VoiceOver kullanıcısı için başlangıç ipucu; kayıt sırasında haptik beklenmez) [TEYİT].
- `PronunciationRecognizer.swift`: (a) her deneme sonunda `SayDiagnostics.shared`'a bir satır (motor, aday sayısı, güven, varsa hata kodu); (b) `AVAudioSession.interruptionNotification` ve `.mediaServicesWereResetNotification` → `cancel()`; (c) **G1, yalnız iOS 17-25 yolu:** `RecognizerBackend.start()` hata geri çağrısı bugün her hatayı "hiçbir şey duyulmadı" sayıyor. Değişiklik: kod 1110 ("konuşma yok") boş liste kalır; başka hata `RecognizerError.recognitionFailed(Int)` (yeni) olarak üste çıkar. `PronunciationRecognizer`'da ardışık 2 böyle hata (sonuç yokken, ses alınmışken) `Problem.onDeviceUnavailable` verir, sayaç bellekte. Gerekçe: 1101 gibi hatalar `supportsOnDeviceRecognition == true` iken de gelir (Apple forum 731230, 739006; FB13235751 [TEYİT]) ve kullanıcı "Seni duyamadım" döngüsünde kalır.
- `FeedView.swift`: `WordCardView(word:detail:showsSay: Bool = true)` (yeni parametre); `SayButton` yalnız `showsSay` ise çizilir; `Text(word.lemma)` `.layoutPriority(1)`. `SearchView.swift:86` (`WordDetailView`) `SayButton` yerinde kalır.
- `OnboardingView.firstWordPage` (`ios/acilis-deste`): `WordCardView(word:detail:showsSay: false)`. Birleşirken ikinci birleşen dal yapar (9). Onboarding'de mikrofon düğmesi ve izin penceresi olmamalı.

**main'de değişenler:**
- `LockglowApp.swift`: `@StateObject private var sayMemory = SayMemory()` ve `RootView().environmentObject(model).environmentObject(sayMemory)`.
- `ReviewView.swift` (`startScreen`, satır ~272): `VStack` içinde `if let offer ... else doneCard` bloğundan sonra `SayEntryCard()`. Başka satıra dokunulmaz (Zor/Kolay alanı, `QuizOutcome` olduğu gibi).
- `SettingsView.swift` (`diagnosticsSection`, satır ~177): mevcut "Tanılama" bölümüne `NavigationLink("Söyle tanılama") { SayDiagnosticsView() }`. Yeni bölüm ya da ikinci "Tanılama" başlığı AÇILMAZ. Yalnız cihaz testi içindir; Release/TestFlight derlemesinde de görünür, sonra kaldırılabilir.
- `ios/UITests/LockglowScreenshotTests.swift`, `content-pipeline/tests/test_speakable_lemmas.py` (yeni; `content.sqlite`'taki her lemma `^[A-Za-z]+([ '\-][A-Za-z]+)*$` desenine uymalı, bugün uyuyor; s10-s12 setleri "sb/sth", rakam ya da eğik çizgi getirirse `python` işi uyarır), `docs/legal` (7).
- **Değişmeyenler:** `AppModel.swift`, `AppPreferences.swift`, `ContentLoader.swift`, `ContentStore`, `WidgetWord`, `CardDetail`, `Package.swift`, `project.yml`, `PrivacyInfo.xcprivacy`, `Speaker.swift`, `QuizCardView.swift`.

## 6. Widget etkisi
Yok. Widget kodu, `widget_plan.json` şeması, `refreshWidgetPlan`, `QueueComposer` değişmez; ilerleme değişmediği için plan yeniden yazılmaz. İki ilişki:
- `ios/widget-ses`: `SpeakWordIntent` (`AudioPlaybackIntent`) uygulama sürecinde `WordSpeechPlayer` ile `.playback` oturumu kurar. Söyle açıkken kullanıcı widget'a dokunamaz; pencere yalnız widget dokunuşundan sonraki ≤ 8 sn. `PronunciationRecognizer.startAudio` kategoriyi her denemede yeniden kurar ve `engine.start()` hatasında `.failed(.audioFailed)` gösterir. `Speaker.toggle` imzası değişmediği için `prepare()`'ın konuşan sesi durdurması etkilenmez.
- widget-ses `UIBackgroundModes: [audio]` ekliyor. Söyle bunu KULLANMAZ: arka plana geçince dinleme iptal edilir (dalın `PronunciationPracticeView` yorumu aynı şeyi söylüyor; tur için de geçerli).

## 7. İzinler, gizlilik ve yasal metinler

**Info.plist (`project.yml`, dalda hazır):** `NSMicrophoneUsageDescription` ("Söyle alıştırmasında söylediğin kelimeyi dinlemek için mikrofon kullanılır. Ses kaydedilmez ve telefondan çıkmaz.") ve `NSSpeechRecognitionUsageDescription` ("Kelimeyi doğru söyleyip söylemediğini anlamak için konuşma tanıma yalnızca telefonda çalışır. Sesin Apple'a ya da başka bir sunucuya gönderilmez."). İkinci anahtar iOS 26 yolunda sorulmasa da `Speech` çerçevesi için zorunludur (yoksa iOS 17-25'te `requestAuthorization` çöker). Metinlerin doğruluğu `requiresOnDeviceRecognition = true` kuralına bağlıdır.

**PrivacyInfo.xcprivacy:** değişmez (toplanan veri yok; Speech/AVAudio için gerekçe istenen API kategorisi yok). Arşivde Privacy Report ile doğrula.

**App Store gizlilik etiketi:** "Audio Data" = **No**; `docs/legal/app_store_privacy_etiketi.md:45` dalda zaten güncellendi. Kalan: satır 144'teki "telaffuz kaydı (mikrofon/ses)" yeniden-kontrol tetikleyicisi "tanıma ya da ses bir gün sunucuya giderse Yes" olarak yeniden yazılır.

**docs/legal, tek yaklaşım:** mikrofon "toplanmayan/işlemediğimiz veriler" listelerine EKLENMEZ; tek kaynak, dalın yazdığı "Söyle" bölümleridir (`gizlilik_politikasi_tr.md` §3.7, `privacy_policy_en.md` §3.7). Dalın yapmadığı ve halka açık sürümden ÖNCE yapılacaklar:
- `kvkk_aydinlatma_uygulama_tr.md:37`: "mikrofon" sözcüğü "toplanmaz" listesinden çıkarılır; yerine: "Mikrofon yalnızca Söyle alıştırması sırasında, izninizle ve cihaz içinde kullanılır; ses kaydedilmez, saklanmaz ve aktarılmaz." (Mevcut hâli §3.7 ile çelişiyor.) [TEYİT: avukat; `docs/legal/README.md:118` soru 20].
- `docs/legal/README.md:72`: "Yok" listesinden "mikrofon (MVP)" çıkar.
- Aşama 3 yapılırsa her iki politikaya "Söyle sayıları cihazda kalır, İlerlemeyi sıfırla ile silinir" cümlesi.
- App Store Connect inceleme notu önerisi: "Söyle alıştırması Akış/Sözlük kartlarında ve Tekrar sekmesinde. iOS 26'da SpeechAnalyzer, iOS 17-25'te requiresOnDeviceRecognition; izin ilk kullanımda istenir, ses kaydedilmez."
- Review kuralları: 5.1.1(i)-(ii) (amaç metni, ne toplanır) ve 2.5.14 (kayıt sırasında görünür gösterge, 3.2'de karşılanır).

## 8. Testler

**Linux'ta çalışan VocabKit birim testleri** (XCTest; testler `import Pronunciation` / `import Learning` kullanır, `@testable` yok; Docker bu PC'de yok, bkz. 11):
- `PronunciationCheckTests` ekleri. Verdict'ler mevcut `PronunciationCheck` mantığının Python taşımasıyla (hizalama, eş sesli, yeni kural) 2026-10-21'de doğrulandı; Swift'te çalıştırılmadı:

| Hedef | tanıyıcı n-best (`;` ayracı) | Beklenen |
|---|---|---|
| get up | get | almost, missedWords [up] |
| run out of | run out | almost, [of] |
| look forward to | forward to | almost, [look] |
| get along with | get along | almost, [with] |
| turn on | turn off | tryAgain |
| get in | get on | tryAgain |
| put on | put off | tryAgain |
| take off | take out | tryAgain |
| check in | check out | tryAgain |
| look for | look after | tryAgain |
| go out | go on | tryAgain |
| get along with | get on with | tryAgain |
| do | due | correct |
| bored | board | correct |
| need | knead | correct |
| bag | bug | tryAgain (kısa kelimede yakınlık yok) |

  Ayrıca: `homophoneGroups` içinde tekrar eden sözcük yok, hepsi küçük harf; dalın mevcut testleri aynen geçmeli (özellikle `testSentenceWithOneWordMissingIsAlmost`, `testMissedNumberIsListedOnceAsWritten`).
- `PracticePlannerTests` (yeni): havuz A, B'den önce gelir; A `lastSeenAt` azalan sıralı; havuz B feed sırasında; `limit`; yinelenen lemma ("pick up" iki kimlik) tek gelir; `practiced` ve aynı lemmalı kardeşi elenir; tüm adaylar `practiced` ise başa sarar; harfsiz lemma elenir; aynı kimlik iki kez feed'de tek sayılır; deterministiklik.
- `content-pipeline/tests/test_speakable_lemmas.py` (5.3).
- iOS 26 `AnalyzerBackend` ve `RecognizerBackend` Linux'ta derlenmez; yalnız CI (macOS) ve cihaz.

**Snapshot testleri:** `LockglowWidgetSnapshots` yalnız `QuizCardView.swift`, `Speaker.swift` ve `Widgets/` derler (widget-ses sonrası `Shared/` da). Yeni `Say*` dosyaları pakete girmez, `QuizCardView`'a mikrofon düğmesi EKLENMEZ; snapshot değişmez.

**UI testi / `screenshots.yml`** (iş akışı değişmez: SE ve Pro Max). Mikrofona hiçbir test dokunmaz; `PronunciationPracticeView` boştayken `AVAudioEngine.inputNode`'a erişmez, bu yüzden sheet'i açıp kapamak izin penceresi çıkarmaz. Düğmeler CI'da her zaman çizildiği için yerleşim doğrulaması mümkündür (önceki taslağın "durum zorlama" sorunu yok). `testCaptureMainScreens` ekleri (aynı commit'te, yeni arayüzle birlikte):
- "3-tekrar-baslangic"tan sonra: `let say = app.buttons["Söyle alıştırması"]`; `say.isHittable` değilse `app.swipeUp()`; "3b-tekrar-soyle-karti" eki; kaydırıldıysa `app.swipeDown()`; sonra mevcut `start.tap()`.
- "8-sozluk-kart"tan sonra: `app.buttons["Söyle: telaffuzunu dene"].tap()`, "8b-soyle-sayfasi" eki, `app.buttons["Kapat"].tap()`; sonra mevcut "Biliyorum" adımı.
- Yeni `testCaptureLongLemma`: Sözlük'te "look forward" ara, sonuca dokun, "11-sozluk-uzun-lemma" eki (başlık satırı SE'de taşmıyor). Akış kartındaki uzun lemma (aynı başlık düzeni) cihaz listesinde.
- `ios/acilis-deste` birleşince iki test de `-lockglow.onboardingCompleted YES` argümanını kullanır (o dalın UI testi zaten ekliyor).
- Korunan etiketler: "Kelimeyi dinle", "Başla…", "Anlamı göster", "Bitir", "Biliyorum", "Öğrenmeye geri al".

**Telefonda elle kontrol listesi** (Mac yok; TestFlight derlemesiyle). Önce dalın README'sindeki "Söyle: cihazda denenecekler" listesinin tamamı; ek olarak:
1. iPhone'un iOS sürümü ve motor: iOS 26+ ise `SpeechAnalyzer`, değilse `SFSpeechRecognizer` yolu denenir. "Söyle tanılama" satırından aday sayısı (n-best 1 mi 5 mi?) ve güven ölçeği not edilir; `PronunciationCheck.lowConfidence` (0,5) buna göre ayarlanır.
2. Uçak modu + Wi-Fi kapalı (model indikten sonra): "breakfast" Doğru çıkıyor mu?
3. 20 kelimelik deneme: tek ("breakfast", "luggage", "borrow"), kısa ("do", "key", "too"), phrasal ("get up", "run out of"), üç sözcük ("look forward to"), "by the way", tireli ("one-way"), kesmeli ("o'clock"), eş sesli ("right", "bored", "meet"). Türk aksanıyla kasıtlı yanlış söyleyince ne çıkıyor?
4. Tur: Tekrar'da kart görünüyor, 8 (ya da daha az) kelime geliyor, "pick up" gibi yinelenen lemma turda iki kez gelmiyor, "Yeni tur" başka kelimeler getiriyor, özet metinleri 3.3'le birebir, k = 0 durumu suçlayıcı değil.
5. Alt çubuk: iPhone SE + en büyük Dynamic Type'ta "Söyle/Sonraki/Geç" kaydırmadan basılabiliyor.
6. Onboarding (acilis-deste birleştikten sonra): "İlk kelimen" sayfasında mikrofon düğmesi YOK; açılışta izin sorulmuyor.
7. Dikte kapalı ya da İngilizce klavye yokken (iOS 17-25): 2 denemeden sonra 3.4'teki yönlendirme çıkıyor, "Seni duyamadım" döngüsü yok [TEYİT].
8. VoiceOver: mikrofona dokununca haptik hissediliyor, sonuç başlığı ve mesajı birlikte okunuyor. Dinlerken arama/Siri/kilit: dinleme kesiliyor, turuncu nokta kayboluyor.
9. Akış'ta "Dinle"ye dokunup hemen mikrofona dokun: ses oturumu çakışmıyor; Söyle'den sonra "Dinle" çalışıyor, arka plandaki müzik devam ediyor. widget-ses birleşince widget hoparlör düğmesi de.
10. Tur sonrası Tekrar sayıları ve Ayarlar'daki ilerleme DEĞİŞMEDİ. En büyük Dynamic Type, Koyu mod, Düşük Hareket.

## 9. Diğer dallarla çakışma ve uygulama sırası

| Dal / iş | Durum (git ile doğrulandı, 2026-10-21) | Çakışma | Ne yapılır |
|---|---|---|---|
| `ios/telaffuz` | 2 commit (`93037d9`, `2fccd80`), merge-base `df1b3d0`, 12 dosya; başka oturumun worktree'sinde | Bu planın TEMELİ. İlk taslak aynı hunk'ları (project.yml info bloğu, `FeedView`/`SearchView` başlık `HStack`'i, `docs/legal`, README, `Package.swift`) ikinci kez yazacaktı. | Devralınır (Soru 1). İkinci `NS*UsageDescription`, `SayMicButton`, ikinci README bölümü EKLENMEZ. |
| `ios/zor-kolay` | main'e birleşti (`315787f`) | Yok. `ReviewView`'a tek satır eklenir. | `ReviewGrade` 4 değerli; Söyle ona bağlanmaz. |
| `ios/widget-ses` | birleşmedi; 5 commit (`6497f39`, `d398388`, `bd08df8` main birleşimi, `e1dcaeb`, `de6a52f`); 9 dosya: `Speaker.swift` (+4/-23, `WordSpeech`'e devir), `Shared/WordSpeech.swift`, `Shared/SpeakWordIntent.swift`, `Widgets/*`, `WidgetSnapshots`, `project.yml`, README | `git merge-tree` ile telaffuz + widget-ses: metinsel çakışma yok. `project.yml` hunk'ları ayrık: telaffuz `LSRequiresIPhoneOS`'tan sonra, widget-ses `UISupportedInterfaceOrientations`'tan sonra (`UIBackgroundModes`) ve `- path: Shared` ×3. | Sıra fark etmez. `Speaker.toggle` imzası değişmez. |
| `ios/acilis-deste` | birleşmedi; 3 commit (`5308534`, `c4d90a3`, `ea3e8ce`); 22 dosya | telaffuz + acilis-deste: yalnız `ios/README.md` metinsel çakışır (`FeedView` farklı hunk'lar, çakışmaz). Anlamsal: `OnboardingView.firstWordPage` `WordCardView`'u kullanıyor → mikrofon düğmesi onboarding'de çıkar. | `showsSay: false` (5.3). README'de her iki bölüm de kalır. |
| `tasarim/arayuz-mockup` | mockup'ta Söyle ekranı YOK | Renk jetonları uygulamada yok | Sistem bileşenleri; renkler gelince tek yerden. |
| `icerik/s10..s13` | s13 main'e birleşti (`d99180e`); s10, s11, s12 dallarda | Yok | `test_speakable_lemmas.py` yeni kalıpları yakalar. |

**Deste işi için gerçek durum** (ilk taslağın varsayımı tersti): `acilis-deste`'de `AppModel.words` TÜM yüklü kelimeler, `AppModel.feedWords` kullanıcının destesidir (`DeckFilter.feed`). Yeni kelimeler ve Akış `feedWords`'ten, tekrar (due) kelimeler `words`'ten gelir. Tur için `PracticePlanner.pick(feed:)` birleşince `model.feedWords` alır (deste dışı konudan kelime sorulmaz); `progress` süzülmemiş kalır. Adlar: `words`, `feedWords`, `DeckFilter`; `allWords/scheduledWords` diye bir ad yok. `SettingsView` sırası orada: `recoverySection`, `deckSection`, `rotationSection`, `goalSection`, `reminderSection`, `progressSection`, `helpSection`, `resetSection`, `diagnosticsSection`. Söyle Ayarlar'a yeni bölüm eklemez; yalnız `diagnosticsSection`'a satır. Tercih anahtarı eklemez, onlarınkini okumaz.

**Önerilen sıra:** 1) Karar (Soru 1) ve dalı devral. 2) CI derlemesi, cihaz testi (kod yazmadan; Aşama 0). 3) VocabKit değişiklikleri (adım 3-4; çakışmasız). 4) Aşama 1 uygulama düzeltmeleri. 5) Aşama 2 tur. 6) `ios/telaffuz`'u main'e birleştir (README dışında çakışma yok), diğer dallar README'yi çözer; `showsSay` ikinci birleşende. 7) Belgeler ve yasal.

## 10. Riskler ve açık sorular

**Riskler**
1. **Tanıma ≠ telaffuz.** Eş sesliler, kısa kelimeler, hedef çevresindeki fazla kelimeler ("a spoon") "Doğru" sayılır; aksanlı ama anlaşılır söyleyiş geçer. Arayüz dürüst kalır ("telefon seni anladı"), puan yok, "Geç" her zaman var.
2. **Dal hiç derlenmedi.** iOS 26 yolunun API imzaları (`DictationTranscriber(locale:contentHints:transcriptionOptions:reportingOptions:attributeOptions:)`, `AssetInventory`, `ConfidenceAttribute`, `AnalyzerInput`) Apple belgesinden yazıldı, derleyiciyle sınanmadı (dalın README "Bilinen belirsizlikler" 1-4). `PronunciationTests` Swift'te hiç çalışmadı (README: Python kopyasıyla 36 durum).
3. **iOS 17-25 yolu kırılgan.** `supportsOnDeviceRecognition == true` iken 1101 ve "Siri and Dictation are disabled" (FB13235751) raporları var; üç önkoşul: İngilizce klavye, Dikte açık, Dikte dili inik (forum 731230) [TEYİT]. Önlem: G1 hata eşlemesi ve metin.
4. **Bilinmeyenler cihazda ölçülür:** n-best uzunluğu, güven ölçeği, `lowConfidence` 0,5, `TakeMonitor.speechLevel` 0,02. Cihaz testi (adım 2) bunun için kod yazmadan önce yapılır.
5. **Ses oturumu çakışması.** Dalda dinleme `.playAndRecord`, `Speaker` `.playback`. widget-ses intent'i ile ≤ 8 sn pencere kabul edilen kalıntı risk.
6. **Mac yok, kör kod.** Simülatörde mikrofon ve model güvenilir değil; CI yalnız derleme ve yerleşim görür. macOS dakikaları 10 kat sayılır: UI adımları biriktirilir. `#Preview` eklenebilir.
7. **Hukuk metinleri.** KVKK:37 hâlâ "mikrofon toplanmaz" diyor; halka açık sürümden önce düzeltilmeli, avukat sorusu 20.
8. **Gizlilik iddiası iki noktaya bağlı:** `requiresOnDeviceRecognition = true` (`RecognizerBackend.init`) hiçbir yerde false yapılmaz ve `SFSpeechAudioBufferRecognitionRequest` yalnız `PronunciationRecognizer.swift`'te oluşturulur (grep ile doğrulanır). iOS 26 yolunda "ses sunucuya gitmez" Apple belgesine dayanır [TEYİT].
9. **Onboarding'de izin istemi** (5.3 `showsSay`). **App Review:** amaç metinleri tam olmalı; `UIBackgroundModes: audio` (widget-ses) zaten soru doğurur, Söyle genişletmez.
10. **Erişilebilirlik:** VoiceOver sesi mikrofona karışabilir (dinleme başında duyuru yok, haptik var). Özellik tamamen isteğe bağlı, cezalandırma yok.
11. **İçerik büyümesi:** yeni lemma kalıpları ("sb/sth", rakam, eğik çizgi) eşleştiriciyi yanıltır; Python testi yakalar.

**Açık sorular (KULLANICIYA SOR)**
1. **[KULLANICIYA SOR] Temel:** `ios/telaffuz` devralınsın mı (öneri), yoksa o dal kapatılıp ilk taslağın kendi tasarımı mı uygulansın? İkincisi iki uygulamanın tamamını yeniden hizalamak demektir.
2. **[KULLANICIYA SOR] Leitner:** v1'de Söyle Leitner'ı hiç etkilemesin (öneri). Sonra yalnız olumlu etki ya da Söyle sonrası kendi Zor/Kolay seçimi mi?
3. **[KULLANICIYA SOR] Tur gerekli mi?** Cihaz testinden sonra tek kelime sayfası yetiyorsa Aşama 2 yapılmaz.
4. **[KULLANICIYA SOR] iPhone'unun iOS sürümü** ve klavyelerinde İngilizce (ABD) var mı? iOS 26+ ise iOS 17-25 yolu (G1) yalnız ileride yayın için gerekir.
5. **[KULLANICIYA SOR] Tur uzunluğu** 8 kelime uygun mu?
6. **[KULLANICIYA SOR] Mikrofon düğmesi** ikon mu (öneri; SE'de dar), yoksa dalın "Söyle" yazılı hâli mi?
7. **[KULLANICIYA SOR] `build.yml`'ye ücretsiz Linux paket testi işi** (ubuntu + `ios/Tools/linux_check.sh`, Docker runner'da var) eklensin mi? Bu PC'de Docker yok; yoksa VocabKit testleri yalnız 10 kat dakikalı macOS işinde koşar.
8. **[KULLANICIYA SOR] Kalıcı Söyle sayısı** (Aşama 3) istenir mi? Avukat teyidi (KVKK cümlesi) ve gizlilik metinleri yayın öncesi kimde?

## 11. İş adımları

Her adım ayrı commit. Dal: `ios/telaffuz` (ya da yeni ad). Doğrulaması yazılı olmayan adım bitmiş sayılmaz.
- [ ] **1. Karar ve devralma.** Soru 1 yanıtlanır; dal worktree'si boşaltılır ya da yeni ad açılır. Doğrulama: `git log main..ios/telaffuz` 2 commit gösterir; `git status` temiz.
- [ ] **2. CI derlemesi ve cihaz testi (kod yazmadan).** `gh workflow run build.yml --ref ios/telaffuz` (`-f runner=macos-15-intel` gerekirse); yeşilse `gh workflow run testflight.yml --ref ios/telaffuz` [TEYİT: iş akışı seçilen ref'i derler]. Doğrulama: `build.yml` `ios` işinde `swift test` (PronunciationTests dahil) ve simülatör derlemesi yeşil; telefonda 8. bölümdeki 1-3. maddeler yapılır, sonuçlar (motor, n-best, güven, hata kodları) README "Söyle" bölümüne yazılır. Karar kapısı: motor/doğruluk kabul edilemezse Aşama 2'ye geçilmez.
- [ ] **3. `PronunciationCheck` ekleri** (yalnız-eksik kural, `homophoneGroups` public + genişleme) ve 8. bölümdeki tablo testleri. Doğrulama: `cd ios/Packages/VocabKit && swift test --filter PronunciationTests` (Mac ya da Docker'lı makinede `ios/Tools/linux_check.sh`); tablodaki her satır bir test; dalın eski testleri yeşil.
- [ ] **4. `PracticePlanner` + `PracticePlannerTests`; `test_speakable_lemmas.py`.** Doğrulama: `swift test --filter LearningTests`; `cd content-pipeline && python -m pytest -q tests/test_speakable_lemmas.py`.
- [ ] **5. Mikrofon düğmesi ve yerleşim:** `SayButton` ikon, `WordCardView.showsSay` + `.layoutPriority(1)`, `PronunciationPracticeView` alt çubuk ve başlangıç haptiği, UI testi ekleri "8b" ve `testCaptureLongLemma`. Doğrulama: `screenshots.yml` çalıştır; SE ve Pro Max'te "8b-soyle-sayfasi" ve "11-sozluk-uzun-lemma" eklerinde başlık satırı taşmıyor, mevcut 10 görüntü bozulmadı.
- [ ] **6. Tanılama:** `SayDiagnostics` + `SayDiagnosticsView`, `PronunciationRecognizer`'dan satır yazma, `SettingsView.diagnosticsSection` satırı, `interruptionNotification` iptali. Doğrulama: CI derlemesi; `diagnosticsSection` dışında yeni bölüm yok (kod incelemesi); transkript `Logger`'a yazılmıyor (grep).
- [ ] **7. Giriş kartı:** `SayMemory`, `LockglowApp` bağlantısı, `SayEntryCard`, `ReviewView.startScreen` satırı, UI testi eki "3b-tekrar-soyle-karti" (aynı commit). Doğrulama: `screenshots.yml`; SE ve Pro Max'te "3b" eki: kart taşmıyor, "Başla" kartı ve mevcut görüntüler bozulmadı; açılışta izin penceresi çıkmıyor (UI testi yeşil).
- [ ] **8. Tur:** `SayRoundView` (kelime ekranı, alt çubuk, özet). Doğrulama: CI derlemesi; metinler 3.2-3.3 ile birebir (`grep` ile her başlık/düğme dizesi); telefonda 8. bölüm 4-5. maddeler.
- [ ] **9. (iOS 17-25 hedeflenirse) G1:** `RecognizerBackend` hata eşlemesi, `RecognizerError.recognitionFailed`, `onDeviceUnavailable` metni. Doğrulama: CI derlemesi; telefonda 8. bölüm 7. madde (Dikte kapalı) ya da simüle edilemiyorsa [TEYİT] olarak README'ye not.
- [ ] **10. Belgeler ve yasal:** README mevcut "Söyle" bölümüne tur, tanılama ve karar kapısı sonuçları eklenir (YENİ bölüm açılmaz; widget-ses/acilis-deste README'siyle çakışma son rebase'te çözülür), `DEVIR.md` durum satırı, 7. bölümdeki `docs/legal` işleri. Doğrulama: `grep -rn -i "mikrofon" docs/legal` çıktısında "toplanmaz/yok" diyen satır kalmadı; avukat teyidi sorusu açıkta.
- [ ] **11. (Koşullu) Aşama 3:** `PronunciationStore` ve istatistik, yalnız Soru 8 olumluysa; gereksinimler 4. bölümde. Doğrulama: `swift test`; "İlerlemeyi sıfırla" Söyle sayısını da siliyor; politika cümlesi eklendi.

## 12. Denetim notları

Her madde git, depo dosyaları ve (dış kaynaklarda) Apple forumu / Swift Evolution ile kontrol edildi. Doğrulanamayan dış iddialar `[TEYİT]` olarak metinde kaldı.

1. [blocker, kod] `ios/telaffuz` temiz değil, rakip uygulama içeriyor: düzeltildi. `git log main..ios/telaffuz` ve `git diff --stat main...ios/telaffuz` ile doğrulandı (2 commit, merge-base `df1b3d0`, 12 dosya). Dal temel alındı, başlık notu ve §9 yeniden yazıldı, `SayButton`/çift anahtar/çift README çakışması kalktı, SpeechAnalyzer ve `contextualStrings` çelişkisi dalın lehine karara bağlandı.
2. [major, kod] `SpokenVerdict: Comparable` raw type ile derlenmez: düzeltildi. SE-0266 metniyle doğrulandı ("No enum types with raw values would qualify"), `Level.swift:30` elle `<` yazıyor. `SpokenVerdict` ve `bestVerdict` kalktı (dalın `Verdict`'i `Comparable` değil, tur içi sıralama için özel `rank`); Aşama 3 için elle `<` kuralı §4'te.
3. [major, kod] Kural 6 aynı uzunlukta farklı parçacığı "eksik kelime" sayıyor: düzeltildi. Python taşımasıyla doğrulandı; `content.sqlite`'ta turn on/turn off kartları var. Yeni kural yalnız `.missing` ister ve `.substitute` varsa `tryAgain` bırakır; 8 yanlış-parçacık çifti §8 tablosunda.
4. [major, kod] UI testi/adım 10-12 doğrulamaları: düzeltildi. "3b" ekinin kendi commit'inde üretilmesi (7. adım), mikrofon düğmesi durum bağımlılığının kalkması (düğme hep çizilir), uzun lemma için `testCaptureLongLemma`, `swipeUp`/`swipeDown`, "6-ayarlar" doğrulamasının kalkması (Ayarlar'a bölüm eklenmiyor). Önerilen DEBUG başlatma argümanı gerekmedi.
5. [major, kod] Mikrofon düğmesi onboarding'in "İlk kelimen" sayfasında çıkıyor: düzeltildi. `ios/acilis-deste:ios/App/OnboardingView.swift` `firstWordPage` `WordCardView`'u kullanıyor (doğrulandı); `WordCardView(showsSay:)` ve onboarding'de false; §9 varsayımı somutlaştırıldı.
6. [minor, kod] `acilis-deste` durumu ve `words`/`feedWords`: düzeltildi. 3 commit, `words` = tüm kelimeler, `feedWords` = deste, `allWords/scheduledWords` yok, Ayarlar sırası ve UI testi argümanı §9'da gerçek adlarla (git ile doğrulandı).
7. [minor, kod] `widget-ses` bilgisi eski: düzeltildi. Bugün 5 commit (uç `de6a52f`; öneride 4/`e1dcaeb` yazıyordu), 9 dosya, `UIBackgroundModes` hunk'ı `UISupportedInterfaceOrientations`'tan sonra, `Speaker.swift` 27 satırlık küçük devir ("baştan yazılıyor" yanlıştı). Metinsel çakışma olmadığı `git merge-tree` ile görüldü.
8. [minor, kod] Üyeler `public` değil: düzeltildi. Mevcut `LearningTests` `@testable` kullanmıyor (doğrulandı). Yeni API (`PracticePlanner`, `homophoneGroups`) `public`, testler `import` kullanır (§8).
9. [minor, kod] `PronunciationStore.load` okunamayan/bozuk ayrımı yok: düzeltildi. `ProgressStore.swift:7,68` ve `AppModel.sceneDidBecomeActive` ile doğrulandı. Depo v1'den çıktı (kalıcı veri yok); gereksinim Aşama 3'te yazılı (§4).
10. [minor, kod] Planner yinelenen lemmayı elemiyor: düzeltildi. `content.sqlite`'ta 11 yinelenen lemma doğrulandı (öneride 10 sayılmıştı, `put on` eksikti). `PracticePlanner` lemma anahtarına göre tekilleştirir.
11. [blocker, ürün] Başlık/§9/§11 bayat: düzeltildi (madde 1, 6, 7 ile aynı kanıt). `main` d99180e, `widget-ses` 5, `acilis-deste` 3 commit.
12. [major, ürün] Cihaz içi hata yolu (1101): düzeltildi. Forum 731230 (1101, üç önkoşul) ve 739006 (`isAvailable`/`supportsOnDeviceRecognition` true iken başarısızlık, FB13235751) okundu. Dalda `RecognizerBackend` her hatayı "duyulmadı" sayıyor; G1 ve yeni `onDeviceUnavailable` metni eklendi. "2 sn sezgisi" yerine ardışık 2 hata kuralı seçildi (2 sn eşiği doğrulanamaz).
13. [major, ürün] `contextualStrings = [target]`: düzeltildi. Dalın README'si bunu bilerek kullanmıyor (doğrulandı); karar tablosunda "KULLANILMAZ", Soru 2 ("cömert/katı") kaldırıldı.
14. [major, ürün] En riskli bilinmeyenler en sonda: düzeltildi. Dalda iOS 26 `SpeechAnalyzer` ve iOS 17-25 `SFSpeechRecognizer` zaten var; adım 2 kod yazmadan CI + cihaz testi, "Söyle tanılama" satırı n-best'i gösterir, Aşama 2 karar kapısına bağlı. Atılabilir ayrı debug ekranı yerine mevcut uygulama "omurga" olarak kullanıldı.
15. [minor, ürün] Çalışma anı "kapalı" durumu didBecomeActive'de ezilir: düzeltildi. `SayAvailability`/`SayCenter` kalktı; kalıcı durum yok, her dokunuşta yeniden denenir (§1 "Kullanılamıyorsa").
16. [minor, ürün] `AppModel` varsayımı tersti: düzeltildi (madde 6; `feedWords` yeni kelimeler için, `progress` süzülmemiş).
17. [minor, ürün] §2.C ile `showsMicButtons` çelişkisi: düzeltildi. Düğme hiçbir durumda gizlenmez; reddedilince `ProblemPanel` + "Ayarları aç".
18. [minor, ürün] Mikrofon reddinden sonra ikinci izin penceresi: düzeltildi. Eski `SayCenter.requestPermissions` kalktı; dalın `PronunciationRecognizer.prepare()` mikrofon reddinde durur (kodla doğrulandı), kural §1 tablosunda yazılı.
19. [minor, ürün] Birincil eylemler kaydırmanın içinde: düzeltildi. Turda alt çubuk `safeAreaInset` (`ReviewView.answerArea` örneği), tek kelime sayfasında mikrofon düğmesi aynı yere; SE ve en büyük yazı cihaz listesinde (8. bölüm 5).
20. [minor, ürün] Kayıt sırasında haptik bastırılır: düzeltildi (kısmen doğrulandı). `allowHapticsAndSystemSoundsDuringRecording` varsayılanı false (Apple belge sayfası içeriği alınamadı, [TEYİT]). Başlangıç haptiği oturum etkinleşmeden ÖNCE, bitiş haptiği oturum kapandıktan sonra (dalın `.sensoryFeedback`'i böyle); kayıt sırasında haptik beklenmiyor; cihaz kontrolü 8. bölüm 8.
21. [minor, ürün] Planner yinelenen lemmayı elemiyor, özet "change · change" gösterir: düzeltildi (madde 10; özet kelimeleri de yinelenmez çünkü tur zaten tekil).
22. [minor, ürün] "8 kelime" sabiti ve cesaret kırıcı özet: düzeltildi. "Bu tur: n kelime" gerçek sayıyla, k = 0 ve a = 0 için nötr metin, "Biraz daha çalış" yalnız k > 0 iken (§3.1, 3.3).
23. [minor, ürün] Ayarlar'da "Tanılama" jargonu ve ikinci başlık: düzeltildi. `SettingsView.swift:178` zaten `Section("Tanılama")` taşıyor (doğrulandı); yeni bölüm açılmıyor, mevcut bölüme tek "Söyle tanılama" satırı. DEBUG'a bağlanmadı: cihaz testi TestFlight (Release) ile yapılıyor.
24. [minor, ürün] Yasal düzenlemeler tutarsız: düzeltildi. `gizlilik_politikasi_tr.md:89` listesi mikrofonu zaten içermiyor, KVKK:37 içeriyor (doğrulandı). Tek yaklaşım: mikrofon "toplanmayan" listelere eklenmez, Söyle bölümü tek kaynak (dal §3.7'yi zaten yazdı); KVKK:37, `README.md:72`, etiket:144 kalan işler (§7).
25. [minor, ürün] Aşırı kapsam: düzeltildi (kısmen). Kalıcı istatistik dosyası, 3 kovalı planner, Ayarlar bölümü, 9 durumlu `SayAvailability`, praise varyantları, açıklama ekranı, ikinci motor ve `SayListener` çıkarıldı. Aşama 2 (tur) ve basit `PracticePlanner` KALDI: tek kelime sayfasının yapmadığı şeyi (8 kelimelik sıralı alıştırma, yeni tur) yapıyor, kalıcı veri gerektirmiyor ve cihaz testi sonucuna bağlı (Soru 3). Reddedilen kısım yalnız "turu de bırak" önerisidir.
