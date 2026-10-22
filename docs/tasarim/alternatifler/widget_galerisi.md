# Lockglow widget galerisi: yeni widget ve kilit ekranı fikirleri (22 Ekim 2026)

- **Galeri:** [`widget_galerisi.html`](widget_galerisi.html). Tek dosya; çift tıklayınca tarayıcıda açılır.
- **Artifact:** https://claude.ai/artifact/FAcCCToqRfFQdV7otbXC5Q (özel; paylaşmak için sayfanın Paylaş menüsü).
- **Ne var:** on fikir. Her fikir gerçek iPhone ana ekranı, kilit ekranı, Denetim Merkezi, StandBy ya da saat çerçevesinde. Görünüm: açık, koyu, renklendirilmiş, cam.
- **Kartlar:** `content/drafts/kisisel_v1` içinden olduğu gibi (34 kart, tohum kelimeler dahil). Örnek, kelimeyi içeren en kısa örnek (`CardDetail.shortestExample` gibi).
- **Swift koduna dokunulmadı.** Aşağıdaki Swift parçaları yalnız taslak: derlenmedi, cihazda denenmedi.
- **Kaynak olarak okunanlar:** `docs/tasarim/README.md` (widget bölümü), `ios/Widgets/`, `ios/README.md` (süreklilik kuralları, madde 18, 26, 30, 34, 45).

Apple bilgileri 22 Ekim 2026'da Apple belgelerinden, HIG'den ve WWDC sayfalarından kontrol edildi. Etiketler:
- **(belgede):** Apple belgesinde, HIG'de ya da WWDC'de okundu.
- **(forum):** Apple geliştirici forumunda bir yanıt.
- **(doğrulanmadı):** belgede yok; cihazda bakılmalı.

## Önerilen sıra

| Sıra | Fikir | Sürüm | Fayda (5) | Maliyet | Risk | Yeni hedef / izin |
|---|---|---|---|---|---|---|
| **1** | Kilit ekranı: önce hatırla (+ tekrar sayacı) | iOS 17+ | 4 | 1–2 gün | Düşük | Yok |
| **2** | Mini quiz widget'ı | iOS 17+ | 5 | 3–5 gün | Orta | Yok (yeni intent, plan alanı) |
| **3** | Kelimeyi dinle düğmesi (Denetim Merkezi, kilit ekranı, Eylem düğmesi) | iOS 18+ | 4 | 1–2 gün | Orta | Yok (aynı eklentide kontrol) |
| 4 | Günün cümlesi | iOS 17+ | 4 | 2–3 gün | Düşük | Yok (yeni widget türü) |
| 5 | StandBy: gece kelimesi | iOS 17+ | 3 | 1 gün | Düşük | Yok |
| 6 | Büyük widget: günün 3 kelimesi | iOS 17+ | 3 | 2–3 gün | Düşük | Yok |
| 7 | iOS 26 cam ve renklendirme (denetim listesi) | iOS 18 / 26 | 3 | 1 gün | Düşük | Yok |
| 8 | Widget'ı düzenle (yapılandırma) | iOS 17+ | 3 | 3–4 gün | Orta | Yeni widget türü önerilir |
| 9 | Canlı Etkinlik: tekrar turu | iOS 17+ | 4 | 5–8 gün | Yüksek | ActivityKit, Info.plist anahtarı |
| 10 | Apple Watch komplikasyonu (yalnız not) | watchOS 10+ | 2 | 10+ gün | Yüksek | watchOS uygulaması |

"Gün" kabaca bir oturum işi ve bir CI turu demek. Cihaz denemesi bu sürelere dahil değil.

**Neden bu üçü önce?**

1. **Önce hatırla.** Lockglow'un adı ve gücü kilit ekranı. Düğme gerekmez, yeni hedef gerekmez. Bugünkü zaman çizelgesine ikinci bir giriş eklenir. Telefona her bakış küçük bir hatırlama denemesine döner. En ucuz ve en çok görülen fikir bu.
2. **Mini quiz.** Öğrenmeye en çok katkı yapan fikir: okumak yerine seçmek. Cevap mevcut olay türleriyle (`unknown`, `reveal`) Tekrar planına girer. Yeni olay türü, yeni hedef ya da izin yok.
3. **Kelimeyi dinle.** Var olan `SpeakWordIntent` ve ses oynatıcısı yeniden kullanılır. Eylem düğmesi ve kilit ekranının alt köşesi, telaffuzu tek dokunuşa indirir. Yalnız iOS 18+.

Sonra: Günün cümlesi (aralıklı tekrar), StandBy ve büyük widget (ucuz ama daha az kullanıcı görür). Canlı Etkinlik değerli ama en pahalı ve HIG açısından en riskli iPhone fikri. Saat ayrı bir platform, şimdilik yalnız not.

## Bütün fikirler için Apple kuralları

**Yenilenme bütçesi** ([Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date), belgede):
- Bütçe 24 saatlik. Sık bakılan bir widget günde genellikle 40–70 yenileme alır, yani 15–60 dakikada bir. Her widget örneğinin kendi bütçesi var.
- Bütçeden sayılmayanlar:
  - uygulama öndeyken;
  - uygulamanın etkin ses ya da navigasyon oturumu varken;
  - widget bir App Intent çalıştırınca (düğme, anahtar);
  - widget animasyon yapınca;
  - dil, Dinamik Tür ya da Erişilebilirlik ayarı değişince;
  - StandBy'da sistem kendi ekran yenilemesini yapınca.
- Çok girişli zaman çizelgesi bir kez istenir. Sıradaki girişe geçmek yeniden yükleme değildir; bütçeyi yalnız yeni çizelge isteği harcar. Apple girişlerin en az yaklaşık 5 dakika arayla olmasını öneriyor.
- **Not:** ios/README "Debug'da bütçe uygulanmaz" diyor. Bu cümle Apple'ın sayfasında yok. Apple'ın belgelediği yol Ayarlar'daki "WidgetKit Developer Mode": bütçeleri kapatır (WWDC25 oturum 278). Gerçek ölçüm yine Release ya da TestFlight'ta.

**Etkileşim** ([Adding interactivity to widgets and Live Activities](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities), belgede):
- `Button(intent:)` ve `Toggle(isOn:intent:)` iOS 17'den beri. Destekleyen aileler:
  - `systemSmall`, `systemMedium`, `systemLarge`;
  - iPhone'da `accessoryCircular` ve `accessoryRectangular`.
- `accessoryInline` düğme almaz.
- **Kilitli cihazda düğmeler ve anahtarlar pasif.** Kişi Face ID ile kilidi açana kadar sistem hiçbir şey yapmaz. Bu, widget'lar ve Canlı Etkinlikler için geçerli.
- `perform()` dönünce sistem çizelgeyi yeniden yükler; bu yükleme bütçeden sayılmaz. Veri, `perform()` dönmeden diske yazılmalı.
- Intent'ler varsayılan olarak widget eklentisinde çalışır. `AudioPlaybackIntent` ve `LiveActivityIntent` ise uygulamanın sürecinde çalışır.
- Widget parametre sormaz: her parametre düğmede dolu verilir.

**HIG: Widgets** ([HIG: Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets), belgede):
- Bir bakışta okunur bilgi göster; uygulama gibi düzen kurma.
- Basit işlev; karmaşık iş uygulamada.
- Kenar boşluğu 16 pt, yazı en az 11 pt.
- Yanlış dokunuşu önleyecek hedef boyutu iste. HIG bir sayı vermiyor; bizim kuralımız 44 pt.

**App Review** ([App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), belgede):
- 2.5.16: widget uygulamanın içeriğiyle ilgili olmalı.
- 2.5.18: widget'ta reklam yok.
- 4.5.3: Canlı Etkinlik ile rahatsız etmek yok.

**Lockglow'un kendi kuralları (yeni widget'larda da):**
- **Aynı anda her yerde aynı kelime.** Yeni widget'lar ve kontroller aynı dönüşümü okur (`TimelinePlanner.wordAt`). "Sıradaki" her yerde aynı imleci ilerletir (ios/README, "Dönüşüm sürekli").
- **Widget SQLite açmaz.** Yeni veriyi (quiz, cümle, tekrar saatleri) uygulama plana yazar. Plan tek yazarlı kalır.
- **Sarı yalnız kelimede.** Şerit öğrenilecek kelimede ve örnekteki aynı kelimede. Doğru/yanlış, ilerleme ve seçim mürekkep rengi.
- **Renk tek başına anlam taşımaz.** Renklendirilmiş, cam ve kilit ekranında yeşil ve kırmızı kaybolur: her zaman ✓ ✗ ve bir kelime.
- **Yormayan.** Seri yok, puan yok, kırmızı rozet yok, hareket yok. Bir widget, bir soru. Küçük widget'ta en çok üç düğme.

---

## 1. Kilit ekranı: önce hatırla (+ tekrar sayacı)

**Ne:** Kilit ekranı önce yalnız kelimeyi gösterir: "Ne demekti?". 5 dakika sonra anlam ve kısa tanım kendiliğinden çıkar. Yanında bir daire, zamanı gelmiş tekrar sayısını gösterir.

**Apple ne izin veriyor:**
- Kilit ekranı aileleri, iOS 16+ ([Creating accessory widgets](https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications), belgede):
  - dikdörtgen: 6,1" ekranda yaklaşık 160 × 72 pt;
  - daire: 72 × 72 pt (6,9" ekranda 76, SE'de 68);
  - satır içi.
- Hepsi "vibrant" çizilir: renk yok, yalnız parlaklık.
- Dikdörtgen ve daire düğme alabilir. Ama kilitliyken düğmeler pasif (belgede). Bu fikir bu yüzden düğme değil, **zaman** kullanır.
- Daire için `Gauge` + `.accessoryCircularCapacity`: dolan kapalı halka ([GaugeStyle](https://developer.apple.com/documentation/swiftui/gaugestyle)).

**Bütçe:**
- Girişler önceden hesaplanır; ek yükleme yok.
- Her aralık iki giriş olur (soru + cevap). 60 dakikalık aralıkta 48 saat 96 giriş eder; bugünkü 96 giriş sınırı korunur.
- Aralık 10 dakikadan kısaysa (5 dakika seçeneği) bölme yapılmaz, anlam hemen görünür. Girişler 5 dakikadan sık olmasın.

**Uygulanabilirlik:** Yüksek. Değişen yerler:
- `WordEntry`'ye `phase` ve `dueCount`;
- `WordProvider.makeEntries`'te giriş bölme;
- `RectangularWordView` ve `InlineWordView`'da soru evresi;
- yeni `accessoryCircular` görünümü;
- planda iki yeni alan: `lock_reveal_delay` ve `due_dates`;
- Ayarlar'da bir satır.

Saf hesap (`Scheduler`) Linux'ta sınanabilir.

**Maliyet:** 1–2 gün.

**Fayda:**
- Hatırlamaya çalışmak, yalnız okumaktan daha iyi öğretir (geri çağırma alıştırması).
- Telefona her bakış küçük bir deneme olur.
- Bildirim metniyle aynı dil: "Hatırlıyor musun: …?" (ui2-bildirim).
- Dokunmak gerekmez.

**Dikkat:**
- Anlamı hemen görmek isteyen için ayar şart: "Kilit ekranında anlam: Hemen / 5 dakika sonra". Varsayılan "5 dakika sonra".
- Sayaç baskı yapmasın: kırmızı yok, rozet yok. 0 olunca ✓.
- Çizelgenin ilk girişi "şimdi"dir, sınır değil. Şimdi, sınır + 5 dakikayı geçtiyse ilk giriş doğrudan cevap evresidir.
- Saat yazımı: "Cevap: 10:05" (ek yok, tasarım README madde 13).
- Daireye dokununca Tekrar sekmesi açılmalı. Bunun için yeni bir derin bağlantı gerekir (`vocabwidget://review`). Bildirim bugün Tekrar'ı derin bağlantıyla değil, bildirim yanıtıyla açıyor.
- İleride: Face ID ile kilit açıkken çalışan bir "Göster" düğmesi. Zamanla açılma daha sakin olduğu için önce o.

```swift
// WordEntry.swift (taslak)
enum RecallPhase { case ask, answer }

struct WordEntry: TimelineEntry {
    let date: Date
    let word: WidgetWord
    let nextChange: Date?
    /// Lock Screen only: `.ask` hides the meaning until the answer entry.
    var phase: RecallPhase = .answer
    /// Reviews due at `date` (circular family).
    var dueCount: Int = 0
}

// WordProvider.makeEntries (taslak): every boundary gets an ask entry and, 5 minutes later,
// an answer entry. Intervals under 10 minutes are not split (entries stay >= 5 min apart).
static func makeEntries(input: RotationInput, now: Date, revealDelay: TimeInterval?,
                        dueDates: [Date]) -> [WordEntry] {
    let planned = /* bugünkü TimelinePlanner.plan(...) çağrısı, aynı */
    let splits = revealDelay.map { input.interval >= 2 * $0 } ?? false
    var entries: [WordEntry] = []
    for (index, item) in planned.enumerated() {
        let following = index + 1 < planned.count ? planned[index + 1].date : nil
        let due = { (date: Date) in dueDates.filter { $0 <= date }.count }
        guard splits, let delay = revealDelay else {
            entries.append(WordEntry(date: item.date, word: item.word, nextChange: following,
                                     phase: .answer, dueCount: due(item.date)))
            continue
        }
        // The first item starts at `now`, not at a boundary.
        let boundary = index == 0 ? boundaryStart(containing: now, input: input) : item.date
        let reveal = boundary.addingTimeInterval(delay)
        if reveal > item.date {
            entries.append(WordEntry(date: item.date, word: item.word, nextChange: following,
                                     phase: .ask, dueCount: due(item.date)))
        }
        entries.append(WordEntry(date: max(reveal, item.date), word: item.word, nextChange: following,
                                 phase: .answer, dueCount: due(max(reveal, item.date))))
    }
    return Array(entries.prefix(96))
}

// RectangularWordView (taslak): the ask phase replaces the meaning rows.
if entry.phase == .ask {
    Text("Ne demekti?")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(colors.ink2)
    // "Cevap: 10:05" (no Turkish suffix after the time)
    (Text("Cevap: ") + Text(entry.date.addingTimeInterval(revealDelay), style: .time))
        .font(.caption)
        .foregroundStyle(colors.ink2)
}

// The circular family (taslak).
struct DueCircleView: View {
    let count: Int

    var body: some View {
        if count == 0 {
            Image(systemName: "checkmark")
                .font(.title2.weight(.semibold))
                .accessibilityLabel(Text("Bugünlük tekrar bitti"))
        } else {
            Gauge(value: Double(min(count, 12)), in: 0...12) {
                Text("tekrar")
            } currentValueLabel: {
                Text("\(count)")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .accessibilityLabel(Text("\(count) kelime tekrar bekliyor"))
        }
    }
}
```

Plan alanları:
- `lock_reveal_delay` (saniye; `null` = hemen);
- `due_dates`: öğrenilen kelimelerin 48 saatlik tekrar saatleri, sıralı, yalnız sayı için. Şu an zamanı gelmiş olanlar `due_now` sayısıyla.

İkisi de isteğe bağlı: eski planlar çözülür, widget eskisi gibi davranır.

---

## 2. Mini quiz widget'ı

**Ne:**
- **Küçük:** "Anlamı hangisi?" Kelime ve iki Türkçe anlam ("ödünç vermek" / "ödünç almak").
- **Orta:** boşluk doldurma. Kartın quiz cümlesi ve iki şık ("lend" / "borrow").

Cevaptan sonra ✓ ya da ✗ çıkar ve boşlukta kelime şeritle durur. "Sıradaki" kelimeyi değiştirir.

**Apple ne izin veriyor:**
- `Button(intent:)`, iOS 17+ (belgede).
- Yazı yazma, kaydırma, sürükleme yok. Bu yüzden iki şık.
- `invalidatableContent()`: basılan şık yeni çizim gelene kadar soluk görünür. Apple "ölçülü kullan" diyor.
- İsteğe bağlı: `TimelineEntryRelevance(score:duration:)` (iOS 14+, belgede). Hatırlatma saatinde (20:00) quiz Akıllı Yığın'da öne çıkabilir; ama bu yalnız bir etken.

**Bütçe:** Dokunuştan sonraki yükleme bütçeden sayılmaz (belgede). Soru kelimeyle birlikte değişir; ek giriş yok.

**Uygulanabilirlik:** Yüksek, ama dokunduğu yer çok:
- `WidgetWord`'e isteğe bağlı `quiz` alanı;
- uygulama planı yazarken quiz'i karttan doldurur (`quiz.cloze`, `quiz.answer`, ilk çeldirici, çeldiricinin Türkçesi);
- `WidgetState`'e `last_answer`;
- yeni `AnswerQuizIntent`, `WordActions.answer`;
- yeni widget türü `QuizWidget` (küçük ve orta);
- çizim testleri.

**Maliyet:** 3–5 gün.

**Fayda:**
- Aktif hatırlama: okumak yerine seçmek.
- Uygulamayı açmadan günde birkaç soru.
- Yanlış bilinen kelime 10 dakika sonra Tekrar'da yine gelir.
- Süre yok, puan yok.

**Dikkat:**
- **Olay türleri:**
  - Yanlış → `unknown`: uygulama `review(.again)` yapar.
  - Doğru → `reveal`: yalnız "görüldü", kutu değişmez.
  - Böylece yanlışlıkla doğru şıka basmak zarar vermez. Yanlışlıkla yanlış şık kelimeyi erken getirir; kabul edilebilir.
  - Yeni olay türü gerekmez (`ProgressIngest` aynı).
- **Şık sırası** kelime kimliğine göre sabit (uygulamadaki quiz gibi).
- **Küçük boydaki çeldirici:**
  - Önce quiz çeldiricisi bir kartsa onun Türkçesi (lend → borrow = "ödünç almak").
  - Değilse kuyruktaki başka bir kelimenin anlamı.
  - Anlam aynıysa (eş anlamlı) atlanır.
- **Çekimli cevaplar** (*forgot*, *came up with*, *looks up to*): boşluğa cevap yazılır, şerit yine kelimede.
- **Eski cevap:** Son cevap kelime kimliği ve saatle saklanır. Aynı kelime bir sonraki turda gelince eski cevap gösterilmez (cevap saati, girişin sınırından önceyse yok sayılır).
- **Renk:** Renklendirilmiş ve cam modda yeşil ve kırmızı kaybolur: ✓ ✗ ve "Doğru / Doğrusu" yazısı şart.
- **Gecikme:** Dokunuştan sonraki çizim gecikmesi yalnız Release'te ölçülür (ios/README madde 26).

```swift
// CoreModels (taslak): optional, so old plans still decode.
public struct WidgetQuiz: Codable, Hashable, Sendable {
    /// "Could you ______ me your umbrella? It's raining."
    public let cloze: String
    /// The answer as it fits the blank ("lend", "came up with").
    public let answer: String
    /// One distractor from the card's quiz.
    public let distractor: String
    /// The distractor's Turkish meaning for the small family; nil when unknown.
    public let distractorGlossTR: String?

    enum CodingKeys: String, CodingKey {
        case cloze, answer, distractor
        case distractorGlossTR = "distractor_gloss_tr"
    }
}
// WidgetWord: `public let quiz: WidgetQuiz?` (CodingKeys: `case quiz`)

// SharedState (taslak): written by the widget only, like the rest of widget_state.json.
public struct QuizAnswer: Codable, Equatable, Sendable {
    public var wordID: Int
    public var choice: String
    public var isCorrect: Bool
    public var at: Date
}
// WidgetState: `public var lastAnswer: QuizAnswer?` (key "last_answer")

// Widgets/WordIntents.swift (taslak)
struct AnswerQuizIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Quiz cevabı"
    }

    static var isDiscoverable: Bool {
        false
    }

    @Parameter(title: "Kelime kimliği")
    var wordID: Int

    @Parameter(title: "Seçilen")
    var choice: String

    @Parameter(title: "Kaynak")
    var source: String

    init() {}

    init(wordID: Int, choice: String, source: String) {
        self.wordID = wordID
        self.choice = choice
        self.source = source
    }

    func perform() async throws -> some IntentResult {
        // Writes last_answer and one event: `.unknown` when wrong, `.reveal` when right.
        WordActions.answer(wordID: wordID, choice: choice, source: source)
        return .result()
    }
}

// The medium family's options (taslak). Next stays the existing NextWordIntent.
HStack(spacing: 8) {
    ForEach(options, id: \.self) { option in
        Button(intent: AnswerQuizIntent(wordID: word.id, choice: option,
                                        source: WidgetEventSource.systemMedium.rawValue)) {
            Text(option)
                .font(.system(.callout, design: .serif).weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: Theme.minHitSize)
                .background(colors.buttonFill, in: Capsule())
                .widgetEnglishVoice()
        }
        .buttonStyle(.plain)
        .invalidatableContent()
    }
}
```

---

## 3. Kelimeyi dinle düğmesi (Denetim Merkezi, kilit ekranı, Eylem düğmesi)

**Ne:** Bir iOS 18 kontrolü: "Kelimeyi dinle". Kullanıcı onu şu yerlere koyabilir:
- Denetim Merkezi'ne;
- kilit ekranının alt köşesine (fener yerine);
- Eylem düğmesine (iPhone 15 Pro ve sonrası).

Dokununca şu anki kelime İngilizce okunur.

**Apple ne izin veriyor** ([Creating controls](https://developer.apple.com/documentation/widgetkit/creating-controls-to-perform-actions-across-the-system), [WWDC24 10157](https://developer.apple.com/videos/play/wwdc2024/10157/), [HIG: Controls](https://developer.apple.com/design/human-interface-guidelines/controls); belgede):
- **Türler:** `ControlWidgetButton` (AppIntent ya da OpenIntent) ve `ControlWidgetToggle`. Yapılandırma `StaticControlConfiguration` ya da `AppIntentControlConfiguration`.
- **Değer:** `ControlValueProvider` verir (`previewValue` + `currentValue()`).
- **Görünüm:**
  - Denetim Merkezi'nde simge; büyük boylarda başlık ve değer.
  - Kilit ekranında **yalnız simge**.
  - Eylem düğmesinde simge ve değer Dynamic Island'da.
- **Kilitli cihaz:** sistem başlığı ve değeri gizler.
- **Yenilenme:** `perform()` dönünce, uygulama `ControlCenter.shared.reloadControls(ofKind:)` çağırınca ya da push ile. Saat başı kendiliğinden yenilenmez.

**Belgede olmayanlar (doğrulanmadı):**
- `AudioPlaybackIntent`'in kontrolden uygulama açılmadan ses çalması;
- kontrol intent'inin kilitliyken çalışması.

Forumda bir geliştirici, kilitliyken çalıştığını gördüğü tek intent'lerin ses intent'leri olduğunu yazıyor; bu Apple'ın sözü değil.

**Bütçe:**
- Kontrollerin zaman çizelgesi yok.
- **Değer satırına kelime yazılmaz:** saat başı değişen kelime kontrolde eski kalırdı. Başlık "Kelimeyi dinle", değer "Şu anki kelime". Okunan kelime dokunma anında hesaplanır.

**Uygulanabilirlik:** Yüksek:
- yeni parametresiz `SpeakCurrentWordIntent` (`AudioPlaybackIntent`);
- yeni `SpeakWordControl`;
- bundle'da `if #available(iOS 18, *)`.

`WordDataSource` bugün yalnız widget hedefinde. Intent uygulamanın sürecinde çalıştığı için okuma kodu `Shared/`'a taşınır; uygulama `SharedState` ve `Scheduler`'ı zaten bağlıyor.

**Maliyet:** 1–2 gün. "Sonraki kelime" kontrolü ikinci adım (aşağıda).

**Fayda:**
- Telaffuz tek dokunuşla.
- Eylem düğmesinde telefona bakmadan.
- Kilit ekranındaki kelimeyi duymak için uygulamayı açmak gerekmez (Face ID ile).

**Dikkat:**
- Kilitliyken ve uygulama kapalıyken sesin çıkması cihazda denenmeli. Bu, widget hoparlörüyle aynı yol: ios/README madde 45, günlükte `widget speech in …`.
- **"Sonraki kelime" kontrolü:** kontrolden basılınca widget'lar kendiliğinden yenilenmez. Intent `WidgetCenter.shared.reloadAllTimelines()` çağırmalı. Arka plandaki bu çağrının bütçeden sayılıp sayılmadığı belgede yok.
- iOS 17 kullanıcıları kontrolü görmez; ana ekran widget'ındaki hoparlör onlarda kalır.
- watchOS 26'da iPhone uygulamasının kontrolleri saatte de çıkabilir (WWDC25, belgede). Ayrı saat uygulaması olmadan "Kelimeyi dinle" saatte olabilir; denenmedi.

```swift
// Shared/SpeakCurrentWordIntent.swift (taslak): runs in the app's process like SpeakWordIntent.
struct SpeakCurrentWordIntent: AudioPlaybackIntent {
    static var title: LocalizedStringResource {
        "Kelimeyi dinle"
    }

    static var isDiscoverable: Bool {
        false
    }

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        // The same word every widget shows right now (README "Dönüşüm sürekli").
        let now = Date()
        let input = WordDataSource.load(store: WordDataSource.makeStore())
        let offset = TimelinePlanner.localAlignmentOffset(for: now)
        let word = TimelinePlanner.wordAt(now, queue: input.queue, knownIDs: input.knownIDs,
                                          cursorOffset: input.cursorOffset, cursorAnchor: input.cursorAnchor,
                                          interval: input.interval, alignmentOffset: offset)
            // Every queued word known: the widget ignores the known set, so does this.
            ?? TimelinePlanner.wordAt(now, queue: input.queue, knownIDs: [],
                                      cursorOffset: input.cursorOffset, cursorAnchor: input.cursorAnchor,
                                      interval: input.interval, alignmentOffset: offset)
        if let word {
            await WordSpeechPlayer.shared.speakAndWait(word.lemma)
        }
        return .result()
    }
}

// Widgets/SpeakWordControl.swift (taslak)
@available(iOS 18.0, *)
struct SpeakWordControl: ControlWidget {
    static let kind = "SpeakWordControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: SpeakCurrentWordIntent()) {
                // No word in the label: controls do not refresh at the rotation's boundaries.
                Label("Kelimeyi dinle", systemImage: "speaker.wave.2")
            }
        }
        .displayName("Kelimeyi dinle")
        .description("Kilit ekranındaki kelimeyi İngilizce okur.")
    }
}

// LockglowWidgetsBundle (taslak)
@main
struct LockglowWidgetsBundle: WidgetBundle {
    var body: some Widget {
        WordWidget()
        if #available(iOS 18.0, *) {
            SpeakWordControl()
        }
    }
}
```

Derlemede bakılacaklar:
- değer satırı ("Şu anki kelime") için doğru `ControlWidgetButton` imzası;
- `WidgetBundleBuilder` içinde `if #available`.

---

## 4. Günün cümlesi

**Ne:** Orta boy widget. Dün gördüğün bir kelime, kartın başka bir örneğinde. Önce İngilizce oku, sonra "Türkçesi"ne dokun. Hoparlör cümleyi okur. Günde bir kez değişir.

**Apple ne izin veriyor:** `systemMedium`, `Toggle(isOn:intent:)` ve `Button(intent:)` (iOS 17+, belgede).

**Bütçe:** Gece yarısında bir giriş; ek yükleme yok. "Türkçesi" ve "Dinle" etkileşimdir, bütçeden sayılmaz.

**Uygulanabilirlik:** Yüksek:
- Plana iki günlük `daily_sentences` listesi: tarih, kelime kimliği, kelime, İngilizce, Türkçe.
- Uygulama kelimeyi seçer: dün ilk kez gördüğün ya da dün tekrar ettiğin bir kelime. Cümle, akışta gösterilmeyen başka bir örneği.
- "Türkçesi" durumu `widget_state.json`'da (o gün için).

**Maliyet:** 2–3 gün.

**Fayda:**
- 1 gün sonra yeniden görmek, aralıklı tekrar için iyi bir zaman.
- Yeni bağlam anlamı derinleştirir.
- Önce İngilizce okumak bir kendini sınama.

**Dikkat:**
- Uzun cümle 3 satıra sığmaz: seçerken 90 karakterden kısa örnek tercih edilir.
- Tohum kelimelerde (plan yok) dünkü kelime yok: o zaman şu anki kelimenin örneği görünür.
- `WordSpeechPlayer.speakAndWait` en çok 8 saniye bekliyor; uzun cümlede 12 saniye gerekebilir. Apple arka plan işine 30 saniye tanıyor (madde 45).
- Cümle "aynı anda her yerde aynı kelime" kuralının dışında: bilerek dünkü kelime. Galeride widget'ın üstünde "dünden: …" yazar, kullanıcı karıştırmaz.

```swift
// SharedState (taslak)
public struct DailySentence: Codable, Equatable, Sendable {
    public var day: String          // "2026-10-22", yerel takvim günü
    public var wordID: Int
    public var lemma: String
    public var sentenceEN: String
    public var sentenceTR: String
}
// WidgetPlan: `public var dailySentences: [DailySentence]?` (key "daily_sentences")

// Provider (taslak): today and tomorrow, one entry each, reload at the end.
let today = Calendar.current.startOfDay(for: now)
let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
let entries = [now, tomorrow].compactMap { date in sentence(for: date).map { SentenceEntry(date: date, sentence: $0) } }
completion(Timeline(entries: entries, policy: .atEnd))
```

---

## 5. StandBy: gece kelimesi

**Ne:** Telefon yatay şarjdayken küçük widget büyür: kelime iri, altında Türkçe anlam ve kısa tanım. Düğme yok. Karanlık odada sistem kırmızıya çevirir.

**Apple ne izin veriyor** ([Adding StandBy and CarPlay support](https://developer.apple.com/documentation/widgetkit/adding-standby-and-carplay-support-to-your-widget), [Displaying the right widget background](https://developer.apple.com/documentation/widgetkit/displaying-the-right-widget-background), [WWDC23 10027](https://developer.apple.com/videos/play/wwdc2023/10027/); belgede):
- Yalnız `systemSmall`. İki yığın yan yana; her widget ekranın yarısına büyütülür.
- Arka plan `containerBackground(for: .widget)` içindeyse sistem onu kaldırır. Bizde öyle.
- `containerBackgroundRemovable(false)` dersen widget StandBy galerisinde görünmez.
- `@Environment(\.showsWidgetContainerBackground)` düzeni değiştirmek için.
- Gece: "vibrant" mod, kırmızı.
- HIG: iri yazı, az renk ve resim.
- Uygulamaya ait ayrı bir tam ekran StandBy görünümü için API yok (doğrulanmadı: bulunamadı).

**Bütçe:** Aynı çizelge. StandBy'daki sistem yenilemesi bütçeden sayılmaz (belgede).

**Uygulanabilirlik:** Yüksek: `SmallWordView`'a bir dal.

**Maliyet:** 1 gün.

**Fayda:**
- Uyumadan önce ve uyanınca bir kelime.
- Komodindeki telefon sessiz bir kelime kartı olur.

**Dikkat:**
- StandBy'da düğmelerin çalışıp çalışmadığı belgede yok (doğrulanmadı). Komodindeki telefon çoğu zaman kilitli, kilitliyken düğmeler pasif. Bu yüzden StandBy düzeni düğmesiz.
- Gece ışıma eklenmez.
- `showsWidgetContainerBackground` başka yerlerde de false olabilir (iPad kilit ekranı). Cihazda bak.
- Kenar boşlukları elle uygulanıyor (madde 45).

```swift
// HomeWordViews.swift (taslak)
@Environment(\.showsWidgetContainerBackground) private var showsBackground

var body: some View {
    if showsBackground {
        regularLayout          // bugünkü düzen, düğmelerle
    } else {
        // StandBy: no buttons, the word as large as it fits, then the meaning and the micro definition.
        VStack(alignment: .leading, spacing: 4) {
            WidgetLevel(code: word.level, color: colors.ink2)
            WidgetHeadword(lemma: word.lemma, typeface: .system(.largeTitle, design: .serif).weight(.bold),
                           color: colors.ink, renderingMode: renderingMode)
                .padding(.bottom, 6)
            WidgetMeaning(gloss: word.glossTR ?? word.defMicro, typeface: .title3.weight(.bold),
                          maxLines: 2, color: colors.ink)
            Text(word.defMicro)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(colors.ink2)
                .lineLimit(1)
                .widgetEnglishVoice()
        }
        .padding(margins)
    }
}
```

---

## 6. Büyük widget: günün 3 kelimesi

**Ne:** `systemLarge`. Üstte şu anki kelime (bütün widget'larla aynı): kelime, IPA, anlam, kısa tanım, örnek. Altında dönüşümde bir ve iki önceki kelime. "Gizle" ile alttaki iki kelimenin anlamı kapanır.

**Apple ne izin veriyor:**
- 6,1" ekranda 338 × 354 pt, 6,9" ekranda 364 × 382 pt (HIG, belgede).
- `systemExtraLarge` iPhone'da yok.
- Orta ve büyük boyda birden çok `Link`: her satır kendi kelimesini açar.

**Bütçe:** Aynı çizelge; girişte 3 kelime.

**Uygulanabilirlik:** Yüksek:
- `WordEntry`'ye `recent: [WidgetWord]`: aynı turda bir ve iki önceki kelime, `TimelinePlanner`'ın aynı hesabıyla.
- Gizle anahtarı `Toggle(isOn:intent:)`, durum App Group'ta.

**Maliyet:** 2–3 gün.

**Fayda:**
- Her kelime 3 saat görünür: daha çok tekrar.
- Ana ekranda tek bakışta küçük bir ders sayfası.

**Dikkat:**
- Ana ekranda çok yer kaplar; az kullanıcı seçer.
- Metin yoğun: örnek yalnız üst satırda.
- Dört düğme (üç hoparlör, bir anahtar) sınırda; HIG basit işlev istiyor. Gerekirse hoparlör yalnız üst satırda kalır.

```swift
// Büyük widget satırı (taslak)
Link(destination: DeepLink.wordURL(id: word.id)!) {
    HStack(alignment: .top, spacing: 6) {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                WidgetHeadword(lemma: word.lemma, color: colors.ink, renderingMode: renderingMode)
                Text(when).font(.caption2.weight(.semibold)).foregroundStyle(colors.ink2)
                Spacer(minLength: 0)
                WidgetLevel(code: word.level, color: colors.ink2)
            }
            if hidesMeaning {
                Capsule().fill(colors.buttonFill).frame(width: 90, height: 12)
                    .accessibilityLabel(Text("Anlam gizli"))
            } else if let gloss = word.glossTR {
                WidgetMeaning(gloss: gloss, typeface: .subheadline.weight(.bold), maxLines: 1, color: colors.ink)
            }
        }
        SpeakWordButton(text: word.lemma, colors: colors)
    }
}
```

---

## 7. iOS 26 cam ve renklendirme (denetim listesi)

**Ne:** Yeni widget değil. Bütün widget'lar koyu, renklendirilmiş (iOS 18) ve cam (iOS 26) ana ekranda okunur ve tanınır olsun.

**Apple ne izin veriyor** ([Optimizing for accented rendering mode and Liquid Glass](https://developer.apple.com/documentation/widgetkit/optimizing-your-widget-for-accented-rendering-mode-and-liquid-glass), [WWDC25 278](https://developer.apple.com/videos/play/wwdc2025/278/); belgede):
- Renklendirilmiş ve cam `.accented` mod üretir. Sistem içeriği birincil ve vurgu gruplarına ayırır, renkleri kendisi atar, arka planı kaldırıp cam ya da renk koyar.
- `.widgetAccentable()` bir görünümü vurgu grubuna koyar.
- Resimler için `widgetAccentedRenderingMode(_:)`: `nil`, `.accented`, `.desaturated`, `.accentedDesaturated`, `.fullColor`.

**Bugünkü kod doğru yolda:**
- `WidgetColors.system`;
- ince şerit çizgisi;
- kelime ve şerit `widgetAccentable`.

**Yeni widget'lar için liste:**
1. Doğru/yanlış rengine güvenme: ✓ ✗ ve kelime.
2. Quiz şıkları ve "Türkçesi" kapsülü `buttonFill` (`quaternary`); camda görünüyor mu, cihazda bak.
3. Büyük widget'ın ayırıcı çizgileri: `.separator` yerine `quaternary` bir çizgi; renklendirilmiş modda kaybolmasın.
4. Resim yok (yalnız SF Symbols): `widgetAccentedRenderingMode` gerekmez.
5. Canlı Etkinlik kendi zeminini çizer: kâğıt ya da mürekkep.

**Maliyet:** 1 gün (çoğu yapıldı).

**Not:** ui2-widget oturumu şu an widget'ları cilalıyor. Bu liste onların cihaz denetimine eklenebilir.

**Diğer iOS 26 widget yenilikleri (WWDC25 278, bizim için şimdilik değil):**
- CarPlay widget'ları: küçük boy, tam renk.
- Push ile widget güncelleme (`WidgetPushHandler`): sunucu ister, bizde yok.
- visionOS doku ve ayrıntı düzeyi.
- watchOS Akıllı Yığın ilgisi.

Kilit ekranı widget'larının iOS 26'da ekranın altına taşınabildiğini Apple dışı kaynaklar yazıyor (doğrulanmadı).

---

## 8. Widget'ı düzenle (yapılandırma)

**Ne:** Widget'a uzun basıp "Widget'ı Düzenle". İki soru:
- "Ne gösterilsin?": Kelime / Cümle / Quiz;
- "Türkçe anlam": Hemen / 5 dakika sonra.

**Apple ne izin veriyor** ([Making a configurable widget](https://developer.apple.com/documentation/widgetkit/making-a-configurable-widget), belgede):
- `AppIntentConfiguration` + `WidgetConfigurationIntent` (iOS 17).
- Düzenleme ekranı parametrelerden kendiliğinden kurulur, yazıldıkları sırayla.
- `AppEnum` sabit listeler için, `AppEntity` dinamik listeler için.
- Zorunlu parametrenin varsayılanı olmalı.

**Uygulanabilirlik:** Orta. İki yol var:
- **(A) Ayrı widget türleri:** Kelime, Quiz, Cümle. Galeride üç kart. Basit.
- **(B) Tek widget ve seçenek.**

**Öneri: önce A.** Bugünkü `WordWidget` `StaticConfiguration` ile. Aynı `kind` ile `AppIntentConfiguration`'a geçmek, kullanıcının ekranındaki widget'ları etkileyebilir. Belgede bu geçiş anlatılmıyor; cihazda denenmeden yapılmamalı. Güvenli yol: yeni `kind`.

"Konu" seçeneği pahalı. Widget planı tek kuyruk; konuya göre ayrı kuyruk gerekir. İlk sürümde yok.

**Maliyet:** 3–4 gün.

**Fayda:** Kullanıcı kendi tarzını seçer; aynı ekranda iki widget iki ayrı şey gösterir.

**Dikkat:** En çok iki soru; Türkçe metinler kısa.

```swift
// Taslak
enum WidgetShowMode: String, AppEnum {
    case word, sentence, quiz
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Gösterim" }
    static var caseDisplayRepresentations: [WidgetShowMode: DisplayRepresentation] {
        [.word: "Kelime", .sentence: "Cümle", .quiz: "Quiz"]
    }
}

struct LockglowWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Lockglow" }

    @Parameter(title: "Ne gösterilsin?", default: .word)
    var show: WidgetShowMode
}

struct LearnWidget: Widget {
    static let kind = "LearnWidget"   // yeni kind: bugünkü WordWidget'a dokunmaz

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: LockglowWidgetIntent.self, provider: LearnProvider()) { entry in
            LearnWidgetView(entry: entry)
        }
        .configurationDisplayName("Öğren")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}
```

---

## 9. Canlı Etkinlik: tekrar turu

**Ne:** Tekrar ekranında "Kilit ekranında devam et". Tur kilit ekranında sürer:
- soru evresi: kelime ve tek düğme "Göster";
- cevap evresi: anlam, "Bildim" ve "Bilemedim".

Dynamic Island'da "3/6" ve kelime görünür. 6 kartta biter.

**Apple ne izin veriyor** ([Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities), [HIG: Live Activities](https://developer.apple.com/design/human-interface-guidelines/live-activities), [LiveActivityIntent](https://developer.apple.com/documentation/appintents/liveactivityintent); belgede):
- **Süre:** en çok 8 saat etkin, sonra kilit ekranında 4 saat daha (toplam 12).
- **Boyut:** içerik en çok 4 KB. Kilit ekranı görünümü yaklaşık 371 × 84–160 pt; 160 pt'yi aşan kesilebilir.
- **Düğmeler:** `LiveActivityIntent` (iOS 17) uygulamanın sürecinde çalışır ve `Activity.update` yapabilir.
- **Kilitli cihaz:** düğmeler pasif. Face ID ile kilit açılınca çalışır.
- **Başlatma:** çoğunlukla uygulama önde olmalı. Bir `LiveActivityIntent` arka planda da başlatabilir, ör. bir kontrolden. Push-to-start iOS 17.2+ ve sunucu ister.
- **HIG:**
  - başı ve sonu belli işler için;
  - reklam ve tanıtım yok;
  - tercihen tek etkileşimli öğe;
  - animasyon en çok 2 saniye.
- **Dynamic Island:** kompakt, minimal ve geniş hâller.
- **Forum (Apple yanıtı):** `LiveActivityIntent` uygulamayı açamaz; açmak için `Link` ya da URL.

**Bütçe:** Push güncellemelerinin saatlik bütçesi var; bizde push yok. Uygulama içinden yerel güncellemeler için belgede sayı yok. Burada güncelleme yalnız dokununca olur.

**Uygulanabilirlik:** Orta-düşük:
- ActivityKit;
- `ActivityConfiguration`: kilit ekranı ve üç Dynamic Island hâli;
- üç intent;
- kilitli cihazda ilerleme dosyası: `progress.json` kilitliyken okunamayabilir (ios/README madde 30). Cevaplar önce App Group olay kutusuna yazılır, uygulama sonra işler;
- Info.plist'te `NSSupportsLiveActivities`;
- testler.

**Maliyet:** 5–8 gün.

**Fayda:**
- Uygulamayı açmadan kısa bir tur.
- Telefona her bakışta bir kart.

**Dikkat:**
- **HIG:** tek etkileşimli öğe öneriyor; cevap evresinde iki düğme var.
- **App Review 4.5.3:** tur yalnız kullanıcı isteyince başlar; her gün kendiliğinden başlatılmaz.
- **Cihazda denenecek:** intent'in kapalı uygulamayı arka planda uyandırıp etkinliği güncellemesi.

```swift
// Taslak
struct ReviewRoundAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var index: Int            // 0-based
        var total: Int
        var wordID: Int
        var lemma: String
        var ipa: String?
        var gloss: String?        // nil in the ask phase
        var isDone: Bool
        var known: Int
        var again: Int
    }
}

struct RevealCardIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Cevabı göster" }
    static var isDiscoverable: Bool { false }
    init() {}

    func perform() async throws -> some IntentResult {
        await ReviewRoundController.shared.reveal()     // uygulamada: activity.update(...)
        return .result()
    }
}

struct GradeCardIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Cevap" }
    static var isDiscoverable: Bool { false }

    @Parameter(title: "Kelime kimliği") var wordID: Int
    @Parameter(title: "Bildim") var knewIt: Bool

    init() {}
    init(wordID: Int, knewIt: Bool) { self.wordID = wordID; self.knewIt = knewIt }

    func perform() async throws -> some IntentResult {
        // Locked device: progress.json may be unreadable, so the answer goes to the App Group
        // mailbox first (`.unknown` / `.reveal`, the same mapping as the quiz).
        await ReviewRoundController.shared.grade(wordID: wordID, knewIt: knewIt)
        return .result()
    }
}
```

---

## 10. Apple Watch komplikasyonu (yalnız not)

**Ne:** Saat yüzünde dikdörtgen komplikasyon (kelime, anlam, kısa tanım) ve iki daire (tekrar sayısı, seviye).

**Apple:**
- Komplikasyonlar WidgetKit aksesuar aileleriyle yapılır: daire, dikdörtgen, satır içi, köşe (yalnız watchOS). Belgede.
- watchOS 26: Akıllı Yığın'da öne çıkmak için `RelevanceConfiguration`. Belgede.
- watchOS 11 ve öncesinde düzenleme ekranı yok; `recommendations()` gerekir. Belgede.
- App Group iPhone ile saat arasında paylaşılmaz. Plan `WatchConnectivity`, `NSUbiquitousKeyValueStore` ya da CloudKit ile gider ve saatin kendi App Group'una yazılır. Forum, Apple DTS yanıtı.

**Maliyet:** 10+ gün:
- yeni watchOS uygulaması ve eklentisi;
- veri aktarımı;
- test ve TestFlight;
- macOS dakikaları (10 kat sayılıyor).

**Fayda:** Bileğe bakış en kısa etkileşim.

**Öneri:** Şimdilik yapılmaz. Önce 3 numaralı kontrolün watchOS 26'da saatte kendiliğinden çıkıp çıkmadığına bakılır; çıkıyorsa "Kelimeyi dinle" saatte bedavaya gelir.

---

## Cihazda bakılacaklar (hepsi için)

1. **Kilitli cihaz:** kilit ekranı kontrolü ve Canlı Etkinlik düğmeleri ancak Face ID'den sonra mı çalışıyor?
2. **Kontrolden ses:** "Kelimeyi dinle" kontrolü uygulama kapalıyken ses çıkarıyor mu? Kilitliyken çıkarıyor mu?
3. **Önce hatırla:** cevap girişi 5 dakikada mı geliyor? Gecikme ne kadar (Release)?
4. **Quiz:** dokunuştan sonra çizim ne kadar sürüyor? Soluk şık (`invalidatableContent`) görünüyor mu?
5. **StandBy:** düzen ve kenar boşlukları; gece kırmızısında ince şerit okunuyor mu?
6. **Cam ve renklendirilmiş:** kapsüller ve ✓ ✗ okunuyor mu?

## Kaynaklar

- Keeping a widget up to date: https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date
- Adding interactivity to widgets and Live Activities: https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities
- Creating accessory widgets and watch complications: https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications
- Adding StandBy and CarPlay support to your widget: https://developer.apple.com/documentation/widgetkit/adding-standby-and-carplay-support-to-your-widget
- Displaying the right widget background: https://developer.apple.com/documentation/widgetkit/displaying-the-right-widget-background
- Optimizing your widget for accented rendering mode and Liquid Glass: https://developer.apple.com/documentation/widgetkit/optimizing-your-widget-for-accented-rendering-mode-and-liquid-glass
- Creating controls to perform actions across the system: https://developer.apple.com/documentation/widgetkit/creating-controls-to-perform-actions-across-the-system
- Making a configurable widget: https://developer.apple.com/documentation/widgetkit/making-a-configurable-widget
- TimelineEntryRelevance: https://developer.apple.com/documentation/widgetkit/timelineentryrelevance
- GaugeStyle: https://developer.apple.com/documentation/swiftui/gaugestyle
- Displaying live data with Live Activities: https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities
- Starting and updating Live Activities with ActivityKit push notifications: https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications
- LiveActivityIntent: https://developer.apple.com/documentation/appintents/liveactivityintent
- AudioPlaybackIntent: https://developer.apple.com/documentation/appintents/audioplaybackintent
- HIG Widgets: https://developer.apple.com/design/human-interface-guidelines/widgets
- HIG Controls: https://developer.apple.com/design/human-interface-guidelines/controls
- HIG Live Activities: https://developer.apple.com/design/human-interface-guidelines/live-activities
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- WWDC23 Bring widgets to new places: https://developer.apple.com/videos/play/wwdc2023/10027/
- WWDC23 Bring widgets to life: https://developer.apple.com/videos/play/wwdc2023/10028/
- WWDC24 Extend your app's controls across the system: https://developer.apple.com/videos/play/wwdc2024/10157/
- WWDC25 What's new in widgets: https://developer.apple.com/videos/play/wwdc2025/278/
- Forum, LiveActivityIntent uygulamayı açamaz: https://developer.apple.com/forums/thread/812949
- Forum, iPhone ve saat arasında veri: https://developer.apple.com/forums/thread/739235
