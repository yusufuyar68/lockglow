# Kendi kelimeni ekle: bağlama notu (2026-10-22)

Kaynak: `raporlar/14_guncel_fark_raporu.md` öneri 6 ("Basit bir form: kelime, Türkçe anlam, isteğe bağlı örnek. Widget dönüşümüne katılsın") ve `docs/tasarim/ogrenme_ilkeleri.md` §2.6 ("senin kelimen" etiketi, hazır içerikle karışmaz).

Dal `kendi-kelime` yalnızca **yeni dosya** ekler. Var olan hiçbir dosya değişmedi. Özellik bağlanana kadar uygulamada görünmez. Bu not, koordinatörün hangi dosyaya hangi satırları ekleyeceğini anlatır.

> **Durum (2026-10-22): bağlandı**, dal `kendi-kelime-bagla` (taban `entegrasyon-3`). Aşağıdaki adımlar uygulandı. Plandan farklar:
> - Yardımcılar `ios/App/AppModel+CustomWords.swift` içinde (`withCustomWords`, `customWordMatches`, `introCandidates`, `pinnedWord`). AppModel.swift'te yalnız durumu değiştiren küçük satırlar var. Linux kontrolüne iki dosya ve AppLogic'e `TextFold` eklendi.
> - **Tanış + Hatırla:** seçenek havuzu kelime türüne ve seviyeye bakıyor; kullanıcı kelimesinin ikisi de yok. `introCandidates` ona bütün kelimeleri "aynı türden" verir; böylece Hatırla sorusu kartların anlamlarından ve kelimelerinden seçenek alır. Zamanı gelen tekrarda sınav (`cloze`) olmadığı için hatırlama ekranı çıkar.
> - **Sözlük:** arama kullanıcı kelimelerini de bulur (önce onlar). Sonuç çıkmazsa ve aranan şey İngilizce bir kelimeye benziyorsa "… kelimesini kendin ekle" düğmesi formu açar.
> - **İlerleme ekranı** (entegrasyon-3'te yeni): seviye rozeti yerine "Senin kelimen"; arka yüzde örnek de tanım da yoksa yine bu etiket.
> - **Düzeltme (dışarıdan gelen hata):** `refreshWidgetPlan` kısa örnek seçince `WidgetWord`'ü yeniden kurarken `glossShortTR`, `sensitivity` ve `confusableIDs` düşüyordu. Artık korunuyor.
> - Kullanıcı kelimelerinde `glossShortTR`, `sensitivity` ve `confusableIDs` nil.

> **Ek (2026-10-26):** "Metinden kelime bul" okunan bir metnin yeni kelimelerini bu forma getirir (`CustomWordEditor(mode: .add(lemma:))`, Türkçe anlam yine şart). Ayrıntı: [`metinden_kelime.md`](metinden_kelime.md).

| Dosya | Ne |
|---|---|
| `ios/Packages/VocabKit/Sources/CoreModels/CustomWordID.swift` | Kimlik aralığı, `WidgetWord.isUserAdded` (widget eklentisi de görür) |
| `ios/Packages/VocabKit/Sources/Learning/CustomWords.swift` | Model, doğrulama, liste, dosya deposu, `DeckFilter.prepending` |
| `ios/Packages/VocabKit/Tests/LearningTests/CustomWordsTests.swift` | 35 test (Linux'ta geçti) |
| `ios/App/CustomWordLibrary.swift` | Ekranların kullandığı `ObservableObject` (AppModel'i bilmez) |
| `ios/App/CustomWordsView.swift` | Liste ekranı ve ekleme/düzenleme formu |

## Kurallar (kararlar)

- **Kimlik:** kullanıcı kelimeleri `CustomWordID.first` = **1.000.000**'dan başlar. Kart numaraları 1'den sayıyor (`id_registry.json` `next_id` 1069). İlerleme, widget planı ve widget olayları tek kimlik alanını paylaşır; ikisi hiç çakışmaz.
- **Kimlik hiç yeniden kullanılmaz.** `next_id` dosyada saklanır. Silinen kelimenin ilerlemesi `progress.json`'da kalır, ama o kimlik başka kelimeye verilmez. "Vazgeç" (`restore`) kelimeyi aynı kimlikle geri getirir, ilerlemesi de geri gelir. Bu yüzden silmede ilerlemeyi temizlemeye gerek yok.
- **Doğrulama** (`CustomWordDraft.problems`, sınırlar `validate.py` `LIMITS` ile aynı, grafem sayılır):
  - kelime: boş olamaz; en çok 28; `SPEAKABLE_LEMMA` (yalnız a–z/A–Z, aralarında tek boşluk, `'` ya da `-`);
  - Türkçe harf (ç ğ ı İ ö ş ü) için ayrı, harfi gösteren mesaj;
  - aynı kelime ikinci kez eklenmez (büyük/küçük harf fark etmez);
  - Türkçe anlam: boş olamaz, en çok 28 (`tr.gloss`: widget yerleşimleri buna göre);
  - örnek en çok 110, not en çok 220; ikisi de isteğe bağlı.
- **Temizleme:** klavyenin akıllı noktalaması düzeltilir (’ → ', — → -), fazla boşluk tek boşluk olur. Büyük/küçük harf yazıldığı gibi kalır. Form kelime alanında büyük harf ve otomatik düzeltmeyi kapatır, ASCII klavye ister.
- **Hazır kartta zaten olan kelime** engellenmez. Form bilgi satırı gösterir: "Bu kelime kartlarda zaten var: …".
- **Deste:** kullanıcı kelimeleri her destede ve her seviyede vardır. Destenin **en önüne** girer (eskiden yeniye). Böylece bugün eklenen kelime Tekrar'ın ve widget'ın sıradaki yeni kelimeleri arasında olur.
- **Sınav yok:** `cardDetail.quiz` nil. Zamanı gelen tekrarda bile kart (Bilemedim / Zor / Bildim / Kolay) olarak sorulur.
- **WidgetWord dönüşümü** (`CustomWord.widgetWord`):

  | Alan | Değer |
  |---|---|
  | `lemma`, `glossTR` | kelime, Türkçe anlam |
  | `exampleEN` | örnek ya da `""` |
  | `pos`, `level`, `defMicro`, `defShort` | `""` |
  | `ipaUS` | nil |

  Boş alanlar ekranda boş satır ya da boş rozet olarak görünmesin diye aşağıdaki küçük koşullar gerekir. is3-icerik'in `WidgetWord`'e eklediği alanlar varsayılanlı olduğu için bu çağrı onlarla da derlenir.

## API özeti

```swift
// CoreModels
CustomWordID.first, CustomWordID.contains(_:)        // 1_000_000...
word.isUserAdded                                      // WidgetWord

// Learning
CustomWord(id:lemma:meaningTR:exampleEN:note:createdAt:updatedAt:)
word.widgetWord, word.cardDetail
CustomWordDraft(lemma:meaningTR:exampleEN:note:), draft.problems(existing:editing:)
CustomWordDraft.lemmaLimit / meaningLimit / exampleLimit / noteLimit
CustomWordProblem: .field, .isMissingField, .message (Türkçe)
CustomWordText.lemma(_:), .isSpeakable(_:)
CustomWordList: words, nextID, add, update, remove, restore, reserveIDs, widgetWords
DeckFilter.prepending(_ custom:, to feed:)
CustomWordStore(fileURL:), .defaultURL(), load(now:), save(_:now:calendar:)   // ProgressStore deseni

// App
@MainActor final class CustomWordLibrary: ObservableObject
    init(), init(store:)
    words, status (.notLoaded / .ready / .unavailable), recovery
    onChange: (([CustomWord]) -> Void)?
    load() -> Bool, reserveIDs(_:), widgetWords, word(id:)
    add / update / remove / restore      // atar: CustomWordList.ChangeError, CustomWordLibrary.SaveError
CustomWordsView(library:cardMeaning:)        // NavigationStack içine itilir
CustomWordEditor(library:mode:cardMeaning:onFinish:)   // kendi NavigationStack'i var, sheet olarak açılır
```

## Bağlama adımları

### 1. AppModel

```swift
// Özellikler
/// The user's own words ("Kendi kelimelerin"); first in every deck.
let customWordLibrary = CustomWordLibrary()
/// Words from content.sqlite or the seed only; `words` is the user's words + these.
private var contentWords: [WidgetWord] = []
```

`start()` içinde, `loadProgress()` satırının hemen ardından (ilk bekleme noktasından önce):

```swift
customWordLibrary.load()
customWordLibrary.reserveIDs(progress.keys)
customWordLibrary.onChange = { [weak self] _ in
    self?.customWordsDidChange()
}
```

İçerik yüklenince (`words = loaded.words` satırının yerine):

```swift
contentWords = loaded.words
words = DeckFilter.prepending(customWordLibrary.widgetWords, to: loaded.words)
wordsByLemma = AppModel.lemmaIndex(loaded.words)   // değişmez: YALNIZ kartlar
```

`wordsByLemma` yalnız kartlardan kurulmalı. Yoksa formdaki "kartlarda zaten var" satırı kullanıcının kendi kelimesini gösterir.

`rebuildFeed()`:

```swift
private func rebuildFeed() {
    let custom = customWordLibrary.widgetWords
    feedWords = DeckFilter.prepending(custom, to: DeckFilter.feed(contentWords, topicsOf: topicsOf, choice: deckChoice))
    allTopicsFeed = DeckFilter.prepending(custom, to: DeckFilter.ordered(contentWords, startingAt: deckChoice.startLevel))
}
```

Yeni fonksiyon:

```swift
/// A word was added, edited, deleted or restored: the deck and the widget queue follow at once.
private func customWordsDidChange() {
    // Before the content has loaded, `start` builds everything with the words anyway.
    guard contentSource != .loading else {
        return
    }
    words = DeckFilter.prepending(customWordLibrary.widgetWords, to: contentWords)
    rebuildFeed()
    refreshWidgetPlan()
}
```

`sceneDidBecomeActive()` içinde, `progressStore == nil` denemesinin yanına (kilitli telefonda dosya okunamadıysa yeniden dener):

```swift
if customWordLibrary.load() {
    customWordLibrary.reserveIDs(progress.keys)
    customWordsDidChange()
}
```

`detail(for:)` başına:

```swift
if word.isUserAdded {
    return customWordLibrary.word(id: word.id)?.cardDetail
}
```

`deckSummary(for:)`: `words` yerine `contentWords` ver (konu özeti yalnız kartları saysın). İstenirse ayrı satır: "+ N kendi kelimen".

`refreshWidgetPlan()` içinde, `currentWord` hesaplandıktan sonra (QueueComposer'a vermeden önce):

```swift
// The pinned word comes from the old plan: show its new text after an edit, and drop a
// user word that was just deleted (it must not stay on the widget until the next change).
let pinned = currentWord.flatMap { current -> WidgetWord? in
    if current.isUserAdded {
        return customWordLibrary.word(id: current.id)?.widgetWord
    }
    return current
}
```

Sonra `pinFirst: currentWord` yerine `pinFirst: pinned`.

Değişmeyenler: `progressCounts`, `knownWords`, `nextReviewSession`, `reminderPlan`, `word(id:)`, widget olayları. Hepsi `words` / `feedWords` üstünden çalıştığı için kullanıcı kelimelerini kendiliğinden kapsar.

### 2. Linux kontrolü

AppModel `CustomWordLibrary`'yi kullanınca `ios/Tools/linux_check_prepare.py` → `APP_LOGIC_FILES` listesine `"CustomWordLibrary.swift"` ekle. Yoksa Linux işinde AppLogic derlenmez. Dosya yalnız Foundation, Combine (stub'daki `ObservableObject` ve `Published`), os (`Logger`), CoreModels ve Learning kullanır. `$words` gibi Combine yansıtması yok; stub yeter.

### 3. Ayarlar

"Bildiğim kelimeler" satırının olduğu `SettingsGroup` içine, onun altına:

```swift
SettingsDivider()
NavigationLink {
    CustomWordsView(library: model.customWordLibrary, cardMeaning: model.lookup(lemma:))
} label: {
    SettingsRow("Kendi kelimelerin") {
        Text(verbatim: "\(model.customWordLibrary.words.count)")
            .monospacedDigit()
    }
}
.buttonStyle(SettingsRowButtonStyle())
```

Sayı, `customWordsDidChange` `words`'ü yayınladığı için yenilenir. Açılış akışına ve sekmelere bir şey eklenmez.

### 4. Kuyruk (QueueComposer)

Değişiklik gerekmez. Kullanıcı kelimeleri `feedWords`'ün başında olduğu için yeni kelime yuvalarına önce onlar girer (`maxNew` sınırı içinde). Tekrar zamanı gelince öğrenme yuvalarına, bilinince tazeleme yuvalarına kartlar gibi girer. is3-widgetsira'nın gizleme kuralı ilerlemeye baktığı için onlara da uyar. Plan `widget_plan.json`'a `WidgetWord` olarak yazılır; widget Learning'i bilmeden gösterir.

### 5. Tekrar: kart detayı olmadan nasıl görünür

`model.detail(for:)` kullanıcı kelimesi için `cardDetail` verir: `examples` (varsa tek örnek, çevirisi yok), `noteTR` (kullanıcının notu), `quiz` nil.

- **Sınav:** `ReviewView.quiz(in:detail:)` `detail?.quiz` ister → nil → hep kart turu. Değişiklik yok.
- **Ön yüz** (`cardFront`): kelime, şerit, Dinle, "Anlamını hatırlamaya çalış.", İpucu. `clue` örnek boşsa zaten gizleniyor. Değişiklik yok.
- **Arka yüz** (`cardBack`), dört küçük koşul:
  1. `metaItems`: `pos` ve `level` boş. Kelime türü yerine bir etiket, seviye rozeti yok:

     ```swift
     if word.isUserAdded {
         Label("Senin kelimen", systemImage: "person.fill")
             .font(.subheadline.weight(.medium))
             .foregroundStyle(Theme.ink2)
     } else {
         Text(verbatim: CardPartOfSpeech.turkish(word.pos)) ...
         LevelBadge(code: word.level)
     }
     ```
  2. `Text(verbatim: word.defShort)`: `if !word.defShort.isEmpty` içine al. Türkçe anlam zaten büyük yazıyla en üstte.
  3. `exampleBlock`: `if !word.exampleEN.isEmpty` içine al (boş cümle ve boş hoparlör çıkmasın).
  4. Not: `if let note = detail?.noteTR, word.isUserAdded { NoteRow(symbol: "note.text", text: note) }`, örnek bloğunun altına. Kartlarda `noteTR` başka yerde gösterildiği için koşul yalnız kullanıcı kelimesi için.
- **Erişilebilirlik odağı:** Türkçe anlam her zaman var, `.meaning` odağı çalışır. `.definition` odağı tanımsız kelimede hedefsiz kalır; zararsız.
- Cevap düğmeleri, Leitner, tur özeti (`WordMeaningRow`: kelime + anlam) olduğu gibi çalışır.

### 6. Akış, Sözlük ve widget'ta aynı koşullar

Akış (`FeedView.swift`) is3-akis'te değişiyor, satır numarası vermiyorum. İlke aynı:

- `metaRow`: `partOfSpeech` ve `LevelBadge` yerine "Senin kelimen" (`isUserAdded`);
- `Text(word.defShort)`: boşsa gösterme;
- örnek bloğu: `exampleEN` boşsa gösterme. Söyle düğmesi kelimeyle çalışır, kelime söylenebilir.

Sözlük (`SearchView.swift`):

- `WordDetailView`: `defShort` boşsa gösterme. `examplesSection` boş listede `word.exampleEN`'e düşüyor; ikisi de boşsa bölümü gösterme. `cautionSection` notu kendiliğinden gösterir (`noteTR`). `WordDetailMetaRow`: tür ve seviye yerine "Senin kelimen".
- Arama (isteğe bağlı): veritabanı araması kullanıcı kelimelerini bulmaz. `SearchView` içinde (TextFold uygulamada var) şöyle eklenebilir: `model.customWordLibrary.newestFirst.filter { TextFold.fold($0.lemma).hasPrefix(q) || TextFold.fold($0.meaningTR).hasPrefix(q) }` sonuçların başına. Sonuç yoksa `CustomWordEditor(library:mode: .add(lemma: query))` bir sheet'te açılabilir ("Bu kelimeyi kendin ekle").

Widget (`HomeWordViews.swift`, is3-kilit'te değişiyor):

- `WidgetWordLines(level:)` ve orta widget `level: word.level`: boşsa nil ver (`word.level.isEmpty ? nil : word.level`). Yoksa VoiceOver "Seviye" der ve yer kaplar.
- Orta widget tanım satırı (`defShort` / `defMicro`): boşsa o varyant boş satır bırakır. `ViewThatFits` varyantlarında tanımı yalnız `!word.defMicro.isEmpty` iken iste.
- Küçük ve kilit ekranı widget'ları kelime + Türkçe anlam gösterir; değişiklik gerekmez. Hoparlör kelimeyi okur. "Biliyorum" ve "Sonraki" kimlikle çalışır.

### 7. Yedekleme

- **Dosya:** `Application Support/custom_words.json` (uygulamaya özel; widget görmez, yalnız plandaki `WidgetWord`'ü görür). Biçim: `{"format": 1, "next_id": …, "words": [{id, lemma, meaning_tr, example_en?, note?, created_at, updated_at}]}`, tarihler 1970'ten saniye.
- **Günlük yedek:** `custom_words.backup.json`; günün ilk kaydında önceki hâl kopyalanır (`ProgressStore` ile aynı kural).
- **Bozuk dosya** silinmez; `custom_words-unreadable-<zaman>.json` adıyla kenara alınır, yedek açılır. Ekran bunu bir kez söyler ("Anladım").
- **Okunamayan dosya** (telefon kilitliyken): hiçbir şey yazılmaz, ekran "Yeniden dene" der; `sceneDidBecomeActive` yeniden dener.
- **Yedekten dönünce kimlik:** yedekten sonra eklenmiş kelimeler kaybolur ama ilerlemeleri kalır. `reserveIDs(progress.keys)` bu kimlikleri yeni kelimelere vermez.
- **Cihaz yedeği:** Application Support, iCloud ve Finder yedeklerine kendiliğinden girer (`progress.json` gibi). Ek iş yok.
- **Sonra (v1.2, iCloud):** iki cihaz aynı kimliği verebilir. Eşitlemede ya her kelimeye bir UUID eklenmeli ya da cihaz başına kimlik bloğu ayrılmalı. `format` 2 ile gelir; bu sürüm 2'yi okumaz, kenara alır.
- **Dışa/içe aktarma** (rakip yorumlarında 34 anma): dosya düz JSON; `ShareLink` ile paylaşılabilir. Ayrı iş.

### 8. Gizlilik ve mağaza metinleri

- Gizlilik manifestine yeni API yok. Dosya zaman damgası zaten `C617.1` ile bildiriliyor (`ProgressStore`).
- `docs/legal/gizlilik_politikasi_tr.md` satır 119: "Okunan metin kartın kendi kelimesidir, sizin yazdığınız bir metin değildir." Bu özellik bağlanınca yanlış olur. Hoparlör ve Söyle artık kullanıcının yazdığı kelimeyi de okur/dinler (yine telefonda). Cümle güncellenmeli: "kendi eklediğiniz kelimeler telefonda kalır, bize gönderilmez".
- `docs/magaza/kayit_metinleri_tr.md` "Kullanılmayan iddialar" listesinden "kendi kelimeni ekleme" özellik yayınlanınca çıkar.

### 9. Cihazda denenecekler

1. Ayarlar → Kendi kelimelerin → "İlk kelimeni ekle": "awkward" / "garip". Bildirim çıkar, liste güncellenir.
2. Tekrar'a git: yeni kelimeler turunda ilk kart "awkward" olmalı. Arka yüzde boş satır ve boş rozet olmamalı.
3. Widget: plan yeniden yazılınca bir sonraki yeni kelime yuvasında kelime görünür. Hoparlör okur. "Biliyorum" çalışır.
4. Türkçe klavyede "şarj", "sb/sth", 29 harf dene: alan altında mesaj çıkar.
5. Kelimeyi kaydır → Sil → "Vazgeç": aynı yere geri gelir.
6. iPhone SE ve en büyük yazı boyutu (AX5): form kayar, "Kelimeyi ekle" klavyenin üstünde durur.
