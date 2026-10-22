# İlerleme ekranı: bağlama notu (22 Ekim 2026)

Kaynak: [`docs/tasarim/alternatifler/sakin_ilerleme.md`](../tasarim/alternatifler/sakin_ilerleme.md) (Kitaplık, Bu hafta, Konular) ve [`ogrenme_ilkeleri.md`](../tasarim/ogrenme_ilkeleri.md) §1 madde 11, §2.5.

**Amaç:** Kullanıcı ne öğrendiğini görsün ve motive olsun. Ama:
- seri (art arda gün) sayacı yok;
- suçlama yok, "kaçırdın" yok;
- yüzde, puan, sıralama yok;
- ekranda hiçbir yerde "0" yok. Boş bir parça ya gizlenir ya "boş" yazar.

## Durum

- **Dal:** `ilerleme-ekrani` (taban `origin/main` 29797b4). Yalnız yeni dosyalar; hiçbir var olan dosya değişmedi.
- **Dosyalar:**

  | Dosya | Ne |
  |---|---|
  | `ios/Packages/VocabKit/Sources/Learning/ProgressSummary.swift` | Hesaplama. Saf Swift, yalnız Foundation ve CoreModels. |
  | `ios/Packages/VocabKit/Tests/LearningTests/ProgressSummaryTests.swift` | 19 test. Linux CI'da geçti. |
  | `ios/App/ProgressOverviewView.swift` | Ekran. `AppModel`'e bağlı değil; veriyi dışarıdan alır. Üç önizleme var. |
  | `docs/ozellik_planlari/ilerleme_ekrani.md` | Bu not. |

- **Bağlandı** (dal `ilerleme-bagla`, taban `entegrasyon-3`). Ayrıntı aşağıdaki "Bağlama: yapılanlar" bölümünde. Onun altındaki "Bağlama adımları" ilk öneriydi; kod biraz farklı yere kondu.

## Bağlama: yapılanlar

- **`ios/App/AppModel+Progress.swift` (yeni):**
  - `extension AppModel`: `hasLibrary`, `wordsByID`, `progressSummary(now:)`, `markProgressRecapShown(weekStart:)`, `progressTopicLimit = 8`;
  - `extension AppPreferences`: `progressRecapWeek` (anahtar `lockglow.progressRecapWeek`).

  Yalnız Foundation kullanır. Linux denetimine eklendi (`linux_check_prepare.py` → `APP_LOGIC_FILES`).
- **`AppModel.swift`:** tek satır. `topicsOf` artık `private(set)`, çünkü uzantı başka dosyada.
- **`ProgressOverviewView.swift`:** `ProgressScreen` eklendi. Ekranı `AppModel`'den (ortam nesnesi) besler ve yalnız açılınca hesaplanır. `ProgressOverviewView` yine düz veri alır.
- **`ReviewView.swift`:** "Kitaplığın" bağlantısı (tonal kapsül) iki yerde var:
  - tur önerisi varken "Bugün…" satırının altında;
  - "Bugünlük tamam" kartının altında.

  Kitaplık boşken (`hasLibrary == false`) görünmez.
- **`SettingsView.swift`:** İlerleme bölümünde, "Bildiğim kelimeler"in üstünde "Kitaplığın ve bu hafta" satırı.
- **Konular:**
  - konu seçiliyse seçilen konular gösterilir;
  - "Tümü" seçiliyse başlanmış konular gösterilir, en çok 8;
  - ikisinde de içerik sırası kullanılır, ilerlemeye göre sıralama yok.
- **Leitner kontrolü (entegrasyon-3):**
  - FSRS henüz bağlı değil, zamanlamayı Leitner yapıyor;
  - Tanış + Hatırla her yeni kelimeyi tek `recordReview` ile yazar: ilk denemede Bildim, ikinci denemede Zor, kaçarsa Bilemedim;
  - Bilemedim iki raf indirir, 10 dakika sonra yine gelir;
  - "Biliyorum" 3 gün sonra bir kez sorulur.

  Hepsi `ProgressSummary.lastAnswer`'ın tanıdığı süreleri yazar. "Biliyorum" kelimeleri `knownOverride` ile ayrı kalır. Kontrolü geçen kelime "Yerleşti"ye, geçemeyen "yeni"ye döner.

## Hesaplama: `ProgressSummary` (Learning)

```swift
let summary = ProgressSummary.make(
    progress: model.progress,            // [Int: WordProgress]
    now: Date(),
    calendar: .current,                  // hafta her zaman pazartesi başlar
    wordIDs: Set(model.words.map(\.id)), // içerikten çıkan kartlar sayılmaz
    topics: groups,                      // [ProgressSummary.WordGroup], gösterim sırasıyla
    history: .none,                      // kesin tarihler (aşağıda)
    recapShownForWeek: savedMonday       // pazartesi özeti bir kez
)
```

Çıktılar:

| Alan | Ne |
|---|---|
| `shelves` | 7 raf: `box1`…`box5`, `settled` ("Yerleşti"), `selfMarked` ("Kendin işaretlediklerin"). Her rafın kelime numaraları. `words(on:)` kısayolu. |
| `libraryCount` | Kitaplıktaki kelime: en az bir kez cevaplanan ya da "Biliyorum" denen. |
| `longTermWordIDs` | "Uzun süreli hafızaya geçen": Raf 4, Raf 5 ve Yerleşti. "Biliyorum" denen ama sınanmamış kelimeler sayılmaz. Ekran bunlara "üst raflardaki kelime" der, "kalıcı" demez (gerekçe `sakin_ilerleme.md`'de). |
| `thisWeek`, `lastWeek` | `Week`: `studyDays` (çalışılan gün), `metWordIDs` (ilk kez cevaplanan, bu hafta tanışılan), `movedUpWordIDs` (bir üst rafa çıkan), `recalledAfterLongGapWordIDs` (iki hafta ya da daha uzun aradan sonra hatırlanan: Yerleşti'ye çıkış ya da tazeleme). |
| `topics` | `GroupProgress`: `total`, `known`, `learning`, `notStarted`, `everyWordMet`. |
| `note` | `WeeklyNote`: `kind` (`lastWeek`, `thisWeek`, `quiet`, `emptyLibrary`), `weekStart`, `text`. |

**Haftalık cümle örnekleri:**
- "Bu hafta 2 gün çalıştın. 2 yeni kelimeyle tanıştın ve 1 kelime bir üst rafa çıktı."
- Pazartesi, bir kez: "Geçen hafta 2 gün çalıştın. 2 yeni kelimeyle tanıştın."
- Sessiz hafta: "Kitaplığındaki 86 kelime yerinde duruyor."
- Boş kitaplık: "Kitaplığın henüz boş. İlk tekrar turunda tanıştığın kelimeler en alt rafa gelir."

**Kurallar:**
- Sayısı 0 olan parça cümleye girmez. "0 gün" hiç yazılmaz (test var).
- Pazartesi, geçen hafta boş değilse ve özet daha gösterilmediyse `kind == .lastWeek` olur. Gösterilince `note.weekStart` kaydedilir ve `recapShownForWeek` olarak geri verilir. Salı ve sonrasında özet çıkmaz.

**Veri nereden geliyor?** `progress.json`'da geçmiş yok. Bu yüzden:
- **Son cevap kesin bulunur:** `Leitner.review`, `lastSeenAt` ile `dueAt`'i aynı andan yazar. Aradaki fark bir Leitner süresine eşitse (10 dakika, rafın aralığı, yarısı, 30 ya da 15 gün) cevap zamanı ve türü bellidir (`lastAnswer(of:)`). Sonradan widget dokunuşu `lastSeenAt`'i değiştirirse bulunamaz; o kelime gün sayısına girmez.
- **İlk cevap tahmin edilir** (`estimatedFirstAnswer(of:)`): bir kez cevaplanan kelimede kesindir. Daha çok cevapta, kelimenin rafına her gün zamanında "Bildim" ile çıktığı varsayılır. Gecikmeli cevaplarda kelime biraz yeni görünebilir. Çok kez düşüp çıkmış eski kelimeler "yeni" sayılmaz.
- **Gün sayısı** yalnız iz bırakan günleri sayar. Bir günü eksik sayabilir, olmayan bir günü saymaz.
- Kesin tarihler gelirse (`history`), tahminin önüne geçer. Aşağıda adım 4.

## Ekran: `ProgressOverviewView`

```swift
ProgressOverviewView(
    summary: summary,
    words: model.wordsByID,                                     // [Int: WidgetWord]
    onRecapShown: { model.markProgressRecapShown(weekStart: $0) },
    onStartReview: nil                                          // boş kitaplıkta "Tekrar'a git"
)
```

Yukarıdan aşağı:
1. **Haftalık cümle kartı:** "Bu hafta · 26 Ekim – 1 Kasım" ve cümle.
2. **İki sayı:** "86 kelime kitaplığında" ve "22 kelime üst raflarda". İkincisi 0 iken gizli.
3. **"Bu hafta tanıştığın N kelime":** yana kayan kartlar. Ön yüz: kelime, anlam, 5 çizgilik raf göstergesi. Dokununca kart döner ve örnek cümle görünür. Hareketi Azalt açıksa dönmez, yumuşakça geçer. En büyük yazı boylarında kartlar alt alta dizilir.
4. **Kitaplığın:**
   - Yerleşti, Raf 5 … Raf 1. Her satırda ad, ne sıklıkla sorulduğu ("4 günde bir"), sayı ve kitap sırtları.
   - Satıra dokununca kelimeler kapsül olarak açılır. Kelimeye dokununca alt sayfa açılır: kelime (fosfor şeritli), anlam, seviye, raf, örnek.
   - Boş raf "boş" yazar.
   - "Kendin işaretlediklerin" kesik çizgili ayrı bir kutuda durur.
5. **"Raflar nasıl çalışır?":** cevapların kuralları. Aralıklar `Leitner`'dan okunur. Ayrıca "Neden kalıcı demiyoruz?" notu.
6. **Konuların:** üç parçalı çubuk ve "7 bildiğin · 11 öğreniliyor · 40 yeni". Bütün kelimeleriyle tanışılan konuda tek bir sakin cümle çıkar.

**Tasarım ve erişilebilirlik:**
- Yalnız `LockglowTheme.swift` kullanıldı; o dosya değişmedi. Bu yüzden açık ve koyu tema ile Yüksek Kontrast kendiliğinden gelir.
- Sarı şerit yalnız alt sayfadaki tek kelimede var. Kartlardaki örneklerde kelime yalnız kalın.
- iPhone SE: kart genişliği ekranın %80'ini geçmez; en çok 20 kitap sırtı ve "+N".
- Büyük yazı: sayılar ve kartlar alt alta dizilir; erişilebilirlik boylarında kitap sırtları gizlenir.
- VoiceOver:
  - başlıklar `.isHeader`;
  - raf satırı "Raf 3, Güçleniyor: 14 kelime. 4 günde bir sorulur.";
  - süs öğeleri (sırtlar, çubuklar, göstergeler) gizli;
  - İngilizce metinler `englishVoice()` ile okunur.

## Bağlama adımları (koordinatör)

### 1. `AppPreferences.swift`: pazartesi özeti anahtarı

```swift
private static let progressRecapWeekKey = "lockglow.progressRecapWeek"

/// Monday of the last week whose recap "İlerleme" showed (ogrenme_ilkeleri 2.5: only once).
static var progressRecapWeek: Date? {
    get {
        let stored = UserDefaults.standard.double(forKey: progressRecapWeekKey)
        return stored > 0 ? Date(timeIntervalSince1970: stored) : nil
    }
    set {
        if let newValue {
            UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: progressRecapWeekKey)
        } else {
            UserDefaults.standard.removeObject(forKey: progressRecapWeekKey)
        }
    }
}
```

Gizlilik manifesti değişmez: UserDefaults (CA92.1) zaten bildirili.

### 2. `AppModel.swift`: üç üye

```swift
// MARK: Progress overview

/// Loaded words by id ("İlerleme" lists headwords by id).
var wordsByID: [Int: WidgetWord] {
    return Dictionary(words.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
}

/// What "İlerleme" shows now (`ProgressSummary`, Learning). Topics: the chosen ones; with
/// "Tümü", the started ones, at most eight, in content order.
func progressSummary(now: Date = Date()) -> ProgressSummary {
    let chosen = deckChoice.topicIDs
    let shown = choosableTopics
        .filter { chosen.isEmpty || chosen.contains($0.id) }
        .sorted { $0.sort < $1.sort }
    var groups = ProgressSummary.WordGroup.topics(shown, topicsOf: topicsOf, words: words)
    if chosen.isEmpty {
        groups = Array(groups.filter { group in
            group.wordIDs.contains { (progress[$0]?.state ?? .new) != .new }
        }.prefix(8))
    }
    return ProgressSummary.make(
        progress: progress,
        now: now,
        wordIDs: Set(words.map { $0.id }),
        topics: groups,
        recapShownForWeek: AppPreferences.progressRecapWeek
    )
}

/// Monday's recap of last week has been on screen: it does not come again.
func markProgressRecapShown(weekStart: Date) {
    AppPreferences.progressRecapWeek = weekStart
}
```

- `topicsOf` `private`, ama bu üyeler `AppModel`'in içinde olduğu için sorun yok.
- `AppModel.swift` Linux'ta da derleniyor (`linux_check.sh` → `AppLogic`). Bu satırlar orada da denetlenir.
- `resetProgress()`'e bir şey eklemek gerekmez: sıfırlanan kitaplıkta geçen hafta boş görünür, özet çıkmaz.

### 3. Ekranın açıldığı yer

**Öneri 1 (ana yol, tasarımdaki gibi): Tekrar başlangıç ekranı.**
- `ReviewView.swift` (main'de 737. satır): `todayLine(withKnown: true)`'nun hemen altı.
- `ReviewView` zaten bir `NavigationStack` içinde. ui2-tekrar ve is3-tekrar bu dosyayı değiştiriyor; satır numarası değişebilir, yer aynı: başlangıç ekranında "Bugün: … yeni kelime, … tekrar." satırının altı.

```swift
NavigationLink {
    ProgressOverviewView(
        summary: model.progressSummary(),
        words: model.wordsByID,
        onRecapShown: { model.markProgressRecapShown(weekStart: $0) }
    )
} label: {
    Label("Kitaplığın", systemImage: "books.vertical")
}
.buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
```

Başlangıç ekranında dolu düğme "Başla" olarak kalır. Bu düğme tonal kalır, çünkü bir ekranda tek dolu düğme olur.

**Öneri 2 (ikinci yol): Ayarlar > İlerleme.**
- `SettingsView.progressSection` içinde, "Bildiğim kelimeler" satırının üstüne bir satır eklenir.
- is3-ayarlar bu dosyayı değiştiriyor; birleştikten sonra ekle.

```swift
NavigationLink {
    ProgressOverviewView(
        summary: model.progressSummary(),
        words: model.wordsByID,
        onRecapShown: { model.markProgressRecapShown(weekStart: $0) }
    )
} label: {
    SettingsRow("Kitaplığın ve bu hafta")
}
.buttonStyle(SettingsRowButtonStyle())
SettingsDivider()
```

**Not:** `NavigationLink { … }` hedefi her çizimde kurulur, yani özet her çizimde yeniden hesaplanır. 1.000 kelimede bu çok ucuz, ama istenirse `navigationDestination(isPresented:)` ile yalnız açılınca hesaplanır.

### 4. (İsteğe bağlı, önerilir) Kesin tarihler

Tahmin yerine kesin veri, sayıları tam doğru yapar:
- **`WordProgress.firstReviewedAt` eklenirse** (alt-ilerleme önerisi; FSRS de isteyebilir) şunu ver:
  ```swift
  history: ProgressSummary.StudyHistory(firstAnswers: progress.compactMapValues { $0.firstReviewedAt })
  ```
  Eski kelimelerde alan `nil` kalır; onlar için tahmin sürer.
- **Çalışılan günler:** `recordReview` her cevapta bugünü `AppPreferences`'a yazar (son 21 gün yeter). Sonra `StudyHistory(studyDays: AppPreferences.studyDays)` ile verilir. Böylece "Bu hafta N gün" o günden sonra kesin olur.

## Birleştirirken dikkat

- **is3-tekrar (Leitner değişikliği):**
  - Bilemedim artık iki raf iner; "Biliyorum" 3 gün sonra bir kez sorulur.
  - Testler iki Leitner sürümüyle de geçecek biçimde kuruldu (elle kontrol edildi). Birleştikten sonra Linux CI'ı bir kez izle.
  - "Kendin işaretlediklerin" kutusundaki metin ("Bir kez sorulurlar; bilirsen Yerleşti rafına geçerler") is3-tekrar'ın davranışını anlatır. main'deki eski Leitner'da bayrak hiç kalkmıyor, yani o kutu boşalmaz.
- **FSRS:** Leitner'ın yerini alınca `lastAnswer(of:)` aralıkları tanımaz.
  - Sonuç güvenli: sayılar düşer ama yanlış sayı çıkmaz.
  - FSRS ile birlikte `history` beslenmeli. `WordProgress`'e `lastReviewedAt` gelirse `lastAnswer` onu kullanacak biçimde güncellenmeli.
  - is3-widgetsira'daki `QueueComposer.lastAnswer` aynı çıkarımı yapıyor. İkisi ileride tek yerde toplanabilir.
- **is3-tema (`LockglowTheme.swift`):** Ekran şunları kullanır:
  - renkler: `Theme.ink`, `ink2`, `ink3`, `tint`, `bg`, `surface`, `surface2`, `surface3`, `line`, `lineStrong`;
  - ölçüler: `Theme.Radius.card`, `Radius.box`, `Theme.Fonts.englishWord`, `minHitSize`;
  - görünüm değiştiricileri: `englishWordStyle`, `phosphorBand`, `englishVoice`, `meaningStyle`, `exampleStyle`, `definitionStyle`, `cardSurface`;
  - bileşenler: `ExampleMark`, `PrimaryCapsuleButtonStyle`, `SecondaryCapsuleButtonStyle(tonal:)`, `ChipButtonStyle`, `LevelBadge`.

  Biri yeniden adlandırılırsa yalnız bu dosya düzeltilir.
- **ui2-tekrar:** Bitiş ekranındaki "Bugün tanıştığın kelimeler" şimdilik `lockglow.reviewNewWordsToday` günlüğünü kullanıyor. Burada da aynı soru var: kesin tarih gelince ikisi aynı veriyi kullanmalı.
- **Ad çakışması:** `sakin_ilerleme.md`, kilit ekranı widget'ı için SharedState'te de `ProgressSummary` adlı bir tür öneriyor. `AppModel` iki modülü birlikte içe aktardığı için o tür başka bir ad almalı (ör. `ProgressSnapshot`).
- **`docs/ozellik_planlari/README.md`:** Dizine bu notu ekle ("İlerleme ekranı: bağlama notu").

## Cihazda bakılacaklar

- iPhone SE:
  - kitap sırtları ve "+N" bir satıra sığıyor mu?
  - kartın genişliği uygun mu?
- AX5 yazı boyu:
  - kartlar alt alta dizildi mi?
  - kapsüller satır kaydırıyor mu?
  - hiçbir metin "…" ile kesilmiyor mu?
- VoiceOver:
  - kart dönünce örnek cümle İngilizce sesle okunuyor mu?
  - raf satırları doğru okunuyor mu?
  - boş raf "boş" diye okunuyor mu?
- Koyu tema: kitap sırtlarının tonları ayırt ediliyor mu?
- Pazartesi:
  - geçen haftanın özeti bir kez çıkıyor mu?
  - ekrandan çıkıp girince bu haftanın cümlesi geliyor mu?

## Açık sorular

1. Ekran yalnız Tekrar'dan mı açılsın, yoksa Ayarlar'dan da mı (öneri: ikisi)?
2. Pazartesi özeti yalnız pazartesi mi çıksın (bu sürüm, `ogrenme_ilkeleri` §2.5), yoksa tasarımdaki gibi pazartesiden çarşambaya kadar Tekrar'da bir kart olarak mı?
3. Konular: "Tümü" seçiliyken başlanan en çok 8 konu mu gösterilsin (öneri), yoksa hepsi mi?
4. Tasarımın kalan parçaları ayrı işler:
   - tur sonunda "Raf 2 → 3";
   - "Yerleşti" anı;
   - kalibrasyon kartı;
   - kilit ekranı ilerleme widget'ı;
   - haftalık bildirim.

   Bunların sırası `sakin_ilerleme.md` → "Öncelik sırası" bölümünde.
