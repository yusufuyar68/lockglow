# Deste (konu) seçimi: teknik plan

Durum (2026-10-21): Bu belge yalnızca okuma yoluyla hazırlandı. Kod ve git durumu değişmedi. Swift bu PC'de derlenip çalıştırılamadı (Docker ve `swift` yok), yani aşağıdaki Swift parçaları derlenmedi. "YENİ" yazan her ad benim önerimdir, depoda yoktur. "(dal)" yazan ad `origin/ios/acilis-deste` içinde (`ea3e8ce`) vardır.

**En önemli düzeltme:** Önceki taslak, deste (konu) seçiminin henüz yazılmadığını varsayıyordu. Yanlıştı. `ios/acilis-deste` dalında bu özellik zaten uygulanmış, CI'da geçmiş (151 paket testi, temiz derleme, `ios/README.md` madde 46) ve `origin`'e itilmiş durumda. Bu belge artık o dalı **temel alır** ve yalnızca dalın üstüne eklenecek farkları anlatır. Dalın yaptığı işi tekrar yazmaz.

Git ve veritabanından doğrulanan gerçek durum (2026-10-21):
- `main` = `d99180e` (s13 içerik taslakları birleşti). `ios/zor-kolay` birleşti (`git log main..ios/zor-kolay` boş).
- `ios/acilis-deste`: 3 commit (`5308534` deste seçimi, `c4d90a3` açılış akışı, `ea3e8ce` README). 22 dosya.
- `ios/telaffuz`: 2 commit. `FeedView.swift` ve `SearchView.swift` içinde birer satır, `project.yml`, `Package.swift`, `docs/legal` (3 dosya). `AppModel`, `AppPreferences`, `SettingsView`, `ReviewView` dosyalarına dokunmaz.
- `ios/widget-ses`: 5 commit (`Speaker.swift`, `Shared/*`, `Widgets/*`, `project.yml`, `ios/README.md`).
- İçerik: `icerik/s10-is-ofis` 2 commit, `icerik/s11-seyahat` 1 commit, `icerik/s12-saglik` commit yok, s13 `main`'de. `content.sqlite` hâlâ 753 kart; "dört akış bitince tek seferde derlenecek" (`d99180e` mesajı).
- `content.sqlite`: 60 kategori (61 değil). 34 kategorinin kartı üyelik olarak var, yalnızca 25'i bir kartın `primary_topic`'i. Üye kartı 5 ve üstü olan 24 kategori var. 1-4 kartlı 10 kategori var (9 değil): `opinions_debate` 4, `business_management` 2, `careers_interviews` 2, `finance_economics` 2, `art_design_architecture`, `collocations`, `compliments_insults`, `environment_climate`, `slang_informal`, `society_media` birer kart.
- Arayüz taslağında (`lockglow_ui_mockup.html`) konu seçici ekranı var (satır 1205, 1225, 1411: "TopicPickerView (açılış dalında var)").

## 1. Amaç ve kapsam

**Neden.** Kullanıcı (A2 seviyesinde Türk) kendine yakın konulardan ("İş yeri", "Seyahat", "Yeme & İçme") başlamak istiyor. Seçim yalnız Akış'ı değil kilit ekranı widget'ını da belirliyor. Dal bunu `primary_topic` ile yapıyor. Bu belge dalı üç noktada iyileştirir: konu sayıları ve süzgeci `card_category` üyeliğine geçer, seçimin kaç kelime ve kaç yeni kelime verdiği görünür olur, widget'tan açılan ama destede olmayan kelime görünmez olmaktan çıkar.

**Rakip bağlamı.** Ekim 2026: Kolay İngilizce widget kurulum rehberi ekledi (dalda `WidgetGuideView` var). Orbit, Lingo, Wordismo söyleme alıştırması ekledi (`ios/telaffuz`). Konu seçimi onlardan gelen bir haber değil. Farkımız: seçim kilit ekranı widget'ını da belirler ve öğrenilen kelime hiç kaybolmaz.

**Dalda zaten olanlar (bu belge dokunmaz):** `DeckChoice`, `DeckFilter` (süzgeç + seviye sıralaması), `ContentTopic`, `ContentStore.topics()`, `AppModel.words` (hepsi) ve `feedWords` (deste), `AppModel.setDeckChoice`, `choosableTopics` (5 kartın altı gizli), `TopicPickerView`/`TopicChoiceList`, Ayarlar > Öğrenme bölümü, `QueueComposer.compose(deck:fallbackFeed:...)`, `ReminderPlanner.plan(newWordFeed:)`, `RootView` derin bağlantı düzeltmesi, `OnboardingView`.

**Kararlar (özet)**

| Soru | Karar | Kaynak / gerekçe |
|---|---|---|
| Süzgeç kaynağı | `card_category` **üyeliği**, birleşim, tekrarsız (bu belgenin değişikliği) | Dal `primary_topic` kullanıyor. Üyelikte sayılar çok daha büyük: `travel_tourism` 20 yerine 55, `workplace_office` 12 yerine 22, `health_body` 35 yerine 60, `social_skills` 48 yerine 108, `food_drink` 40 yerine 57. `success_productivity` dalda hiç görünmez (0 ana konu), üyelikte 10 kart. 379 kart (%50,3) birden çok kategoride. `food_drink` ∪ `home_household` = 156 satır ama 142 kart. KULLANICIYA SOR 1. |
| Seviye | Süzgeç değil **sıralama** (dal: `DeckChoice.startLevel`, `DeckFilter.ordered`) | Hiçbir kelime düşmez. Önceki taslağın seviye süzgeci kaldırıldı. |
| Boş seçim | = Tümü (dal: `Set<String>`, boş = hepsi) | Seçim akışı hiç boşaltmaz (`DeckFilter.filtered` hiçbir kelime uymazsa hepsini döndürür). |
| Minimum seçim | **Yok.** Sert 50 kelime kapısı kaldırıldı. Yerine yumuşak özet ve uyarı (§3.2) | Kapı, A2+ ile 24 konudan yalnız 7'sinin tek başına geçmesine, `workplace_office`'in (22 kelime) her seviyede reddedilmesine yol açıyordu. Geçersiz taslağı sessizce atıyordu. UX raporu O6 "en az 3 konu" diyor, dal 1 konuya izin veriyor. KULLANICIYA SOR 4. |
| Gizlenen kategori | Üye sayısı 5'ten az olanlar seçicide yok (dal: `AppModel.minimumTopicCards`), sayı artık üyelikten | 24 kategori görünür, 10 gizli. Kartlar "Tümü"nde durur. |
| Seçilmeyen konunun öğrenilen kelimesi | Tekrar, hatırlatma ve sayılarda her zaman var (dal). Widget'ta yalnız deste (dal) | Önceki taslağın "widget'ta da kalır" kuralı bırakıldı: widget'ta konu dışı kelime görünmesi dalın metniyle çelişiyordu. |
| Widget'taki görünen kelime | Seçim değişince **sabitlenir**, sınıra kadar aynı kalır (dal: `pinFirst`) | `ios/README.md` "Süreklilik (en önemli)" maddesi (satır 167) ve `SettingsView` "Değiştirince şu an görünen kelime aynı kalır". Önceki taslağın `FeedScope.pinCandidate` kuralı kaldırıldı. KULLANICIYA SOR 2. |
| Widget yedeği | Yalnız deste **sıfır** kelime verirse bütün konulardan (dal). "Minimum 20 kuyruk" taşması kaldırıldı | 20 eşiği eagerdi: 50 kelimelik seçimde 31 kelime bilinince tetikleniyordu ve metinle çelişiyordu. |
| Kaydetme zamanı | Ekran kapanınca (dal: `.onDisappear`) **ve** uygulama etkin olmaktan çıkınca (bu belge) | Debounce yok. Arka plana giden seçici kaybolmasın. |
| Widget'tan açılan, destede olmayan kelime | Kelime detay sayfası (sheet) açılır (bu belgenin değişikliği) | Dal bu durumda Akış'ı olduğu yerde açar: kullanıcı dokunduğu kelimeyi görmez. |

**Bu sürümde olmayanlar:** `FeedScope` ve `pinCandidate`, 50 kelime kapısı ve seviye süzgeci, "kaç gün yeter" tahmini, grup başına "Grubu seç" düğmeleri, `CategoryAccess`/`isLocked` altyapısı (StoreKit gelince), 800 ms debounce, widget başına konu (`AppIntentConfiguration`), Sözlük süzgeci, yeni kategori rozeti, ilk açılışa özel kapı.

## 2. Kullanıcı akışı

**A. Mevcut kullanıcı (TestFlight, kişisel sürüm).** Güncellemeden sonra dalın akışı: `lockglow.onboardingCompleted` anahtarı yoksa açılış akışı bir kez görünür (dalda geçiş kodu yok). "Atla" her sayfada var. Konu anahtarı yoksa Tümü demektir, Akış sırası değişmez. Bu belge bunu değiştirmez; açık soru: KULLANICIYA SOR 6.

**B. Konu seçmek (Ayarlar).**
1. Ayarlar > Öğrenme > "Konular" satırı. Değer `Tümü` ya da `6 konu`.
2. Konular ekranı açılır. Üstte kısa açıklama, altta (ya da büyük yazıda üstte) canlı özet: `Seçili: 74 kelime`.
3. Kullanıcı konulara dokunur. Hiç seçmezse "Tümü" seçili görünür. Özet her dokunuşta güncellenir.
4. Seçim **geçersiz olamaz**: boş = Tümü. Ekrandan çıkınca ya da uygulama arka plana gidince seçim bir kez uygulanır ve widget planı yeniden yazılır.
5. Widget'taki kelime sınıra kadar aynı kalır, sonra seçilen konulardan kelimeler gelir. Akış ve Tekrar'ın yeni kelimeleri hemen seçilen konulardan gelir.

**C. Kelimeler bitince.** Seçili konuların yeni kelimeleri tükenirse Tekrar sekmesi "Seçtiğin konuların yeni kelimeleri bitti" der ve "Konuları düzenle" sunar (§3.4). Bütün seçili kelimeler bilinirse (öğrenilen ve zamanı gelen de yoksa) widget kendiliğinden başka konulardan devam eder (dalın yedeği).

**D. Widget'a dokunma.** `vocabwidget://word/<id>`: kelime destede varsa Akış o karta kayar (dal). Yoksa (yedek kuyruktan ya da konu değişiminde sabitlenmiş kelime) kelime detay sayfası bir sheet olarak açılır.

**E. Açılış akışı.** Dalda aynı `TopicChoiceList` kullanılıyor; değişiklik yok. İstenirse özet satırı sonra oraya da eklenir.

**Kelime durumu kuralları (dalın davranışı, doğrulandı)**

| Kelime durumu | Deste/seviye ne yapar |
|---|---|
| Yeni (`state == .new`) | Destede değilse Akış'ta, Tekrar'ın yeni kelimelerinde, hatırlatma sayısında ve widget kuyruğunda yok (yedek kuyruk hariç) |
| Öğrenmekte (`.learning`) | Tekrar'da (`words` üzerinden) ve hatırlatmada her zaman; widget'ta yalnız destedeyse |
| Bilinen (`.known`) | Sayılarda, "Bildiğim kelimeler"de, Sözlük'te her zaman; widget'ta yalnız destedeyse ve zamanı gelmişse |

## 3. Ekranlar ve metinler

Renk ve tipografi dalın `Palette`/`GlowStyle.swift` değerleridir (önceki taslağın `.orange` kararı geçersiz). Anlam yalnız renkle verilmez: `ChoiceRow` seçili satıra `.isSelected` özelliği verir.

**3.1 Ayarlar > Öğrenme (dal; yalnız altbilgi metni değişir)**
- Başlık `Öğrenme`. `Başlangıç seviyesi` seçici (A1/A2/B1). `Konular` satırı (`NavigationLink` + `LabeledContent`), değer `Tümü` ya da `N konu`. Konu listesi yoksa satır gizli (dal).
- Altbilgi, YENİ metin: `Yeni kelimeler bu seviyeden başlar. Değiştirince widget'taki kelime bir sonraki değişime kadar aynı kalır.` (Dalın uzun metni konu iddiasını içeriyordu; o iddia seçici ekranına taşındı.)

**3.2 Konular ekranı (`TopicPickerView`, dal + YENİ parçalar)**
- Başlık `Konular` (inline).
- Giriş metni (YENİ, 3 kısa cümle): `Widget'ta, Akış'ta ve Tekrar'ın yeni kelimelerinde yalnız seçtiğin konular döner. Öğrenmeye başladığın kelimelerin tekrarı her konuda sürer. Seçtiğin konulardaki bütün kelimeleri bilirsen widget başka konulardan devam eder.`
- `Tümü` satırı ve gruplar (dal): satır başlığı `name_tr`, altında `57 kelime`. Sayı artık üyelikten gelir. Grup başlıkları dalın seti: Günlük hayat, Seyahat ve kültür, İnsanlar ve duygular, İş hayatı, Bilim ve teknoloji, Sanat ve eğlence, Dil kalıpları, Zengin kelimeler, Sınavlar (başka bir set yok; `taxonomy.json` `groups` adları uygulamada kullanılmaz).
- **Özet çubuğu (YENİ, `DeckSummaryLine`).** Normal yazıda altta (`safeAreaInset(edge: .bottom)`, `.thinMaterial`). Erişilebilirlik yazı boyutlarında (`dynamicTypeSize.isAccessibilitySize`) yapışık çubuk yok; aynı satırlar listenin en üstünde. `.accessibilityAddTraits(.updatesFrequently)`.

| Durum | 1. satır | 2. satır |
|---|---|---|
| Seçim yok (Tümü) | `Tüm konular: 753 kelime` | yeni >= günlük hedef: `Tüm konularda 612 yeni kelime var.` · yeni < hedef: `Tüm konularda 4 yeni kelime kaldı.` · yeni = 0: `Yeni kelime kalmadı.` |
| Konu seçili | `Seçili: 74 kelime` | yeni >= hedef: `Bu konularda 61 yeni kelime var.` · yeni < hedef: `Bu konularda 4 yeni kelime kaldı.` · yeni = 0: `Bu konularda yeni kelime kalmadı.` |
| Kelime sayısı < 30 (ek 3. satır) | | `Kelime az olduğu için widget aynı kelimeleri sık gösterir.` |

Sayılar örnektir; hepsi veritabanından ve ilerlemeden hesaplanır. "Hedef" = `AppModel.dailyNewWords` (5/10/15/20). "Yeni" = hiç çalışılmamış kelime (`state == .new`, widget'ta yalnız görülenler dahil). Bölme yok, "kaç gün" tahmini yok.
- Liste sonu dipnotu (YENİ): `Bir kelime birden çok konuda yer alabilir. Toplam her kelimeyi bir kez sayar.`

**3.3 Boş ve hata durumları**
- İçerik veritabanı yok / konu listesi boş: dalın metinleri (`Konu listesi yok (içerik veritabanı yüklenmedi). Bütün kelimeler gösteriliyor.`). Ayarlar'da satır gizli.
- Akış boş kapsam ekranı gerekmez: dal garanti eder ki `feedWords` yalnız `words` boşsa boştur. (Önceki taslağın "Bu seçimde kelime yok" ekranı kaldırıldı.)

**3.4 Tekrar: seçili konuların yeni kelimeleri bitti (YENİ, isteğe bağlı, `ReviewView.doneCard`)**
Yalnız `AppModel.deckIsFinished` (YENİ) doğruysa, mevcut "Harikasın, bugünlük tamam!" yerine:
- Başlık: `Seçtiğin konuların yeni kelimeleri bitti.`
- Metin: `Yeni kelime için konu ekleyebilirsin. Öğrendiklerin zamanı gelince burada tekrar edilir.`
- Düğme: `Konuları düzenle` (`sheet` içinde `NavigationStack { TopicPickerView() }`, kapatınca seçim uygulanır).
Neden: bugün deste bitince, günlük hedef dolmuş gibi "bugünlük tamam" yazıyor; oysa kullanıcı konuyu bitirmiştir.

**3.5 Widget'tan açılan kelime sayfası (YENİ)**
`WordDetailView(word:)` bir `NavigationStack` içinde sheet olarak; gezinti çubuğunda `Kapat` (iptal) düğmesi. `WordDetailView` bugün `SearchView.swift:74`'te, yalnız push için kurulu (`navigationDestination`); bu yüzden sarmalayıcı gerekir.

**3.6 Açılış akışı:** değişmez. Dalın metinleri: `Hangi konuları öğrenmek istersin?` benzeri başlık, `Tümü` / `N konuyla devam`, `Atla` her sayfada.

## 4. Veri ve durum

Yeni UserDefaults anahtarı **yok**. Hepsi dalda tanımlı:

| Anahtar (dal) | Tür | Varsayılan | Not |
|---|---|---|---|
| `lockglow.selectedTopicIDs` (`AppPreferences.selectedTopicIDs: Set<String>`) | sıralı `[String]` | yok ya da boş = Tümü | "İlerlemeyi sıfırla" dokunmaz. Kategori kimlikleri `taxonomy.json`/`category.id` metnidir. Bilinmeyen kimlikler `AppModel.activeTopicIDs` ile elenir. |
| `lockglow.startLevel` (`AppPreferences.startLevel: Level?`) | `"A1"`... | yok = A1 önce | Süzgeç değil, sıralama |
| `lockglow.onboardingCompleted` | `Bool` | `false` | Geçiş kodu yok (bkz. §2-A) |

- **Geçiş:** Konu kimlikleri aynı kaldığı için eski seçimler geçerlidir. Üyelik hesabına geçince seçilen konunun kelime sayısı genişler (kişisel sürümde sorun değil). Önceki taslağın `Set<String>?` türü ve `lockglow.minLevelRank` bırakıldı.
- **App Group:** hiçbir yeni dosya yazılmaz. `widget_plan.json`/`widget_state.json` biçimi değişmez. Seçim widget'a yalnız kuyruk içeriğiyle yansır.
- **Bellekte:** dalın `words` (hepsi, yayınlı), `feedWords` (deste), `topics`, `deckChoice`. Değişen: `AppModel.topicOf: [Int: String]` yerine `topicsOf: [Int: Set<String>]` (YENİ ad).
- **Gizlilik:** kategori kimlikleri kişisel veri değildir, cihazdan çıkmaz.

## 5. Kod değişiklikleri

Yol kökü `ios/`. Temel: `origin/ios/acilis-deste` ucu. Saf mantık VocabKit'te. `linux_check_prepare.py` `APP_LOGIC_FILES` listesindeki `AppModel.swift`, `AppPreferences.swift`, `ContentLoader.swift` Linux'ta stub'larla derlenir: bu dosyalara SwiftUI girmez, stub aynı commit'te güncellenir.

**Packages/VocabKit/Sources/ContentStore/ContentStore.swift** (dalda `topics()` ve `primaryTopicByCard()` var)
- `topics()` (değişir): sayım üyelikten. SQL: `SELECT cat.id, cat.grp, cat.name_en, cat.name_tr, cat.sort, COUNT(c.rowid) AS card_count FROM category AS cat JOIN card_category AS cc ON cc.category_id = cat.id JOIN card AS c ON c.rowid = cc.card_rowid WHERE c.is_free = 1 AND c.sensitivity = 0 GROUP BY cat.id ORDER BY cat.sort ASC, cat.id ASC`. `card_category` birincil anahtarı `(card_rowid, category_id)`, tekrar yok.
- `topicsByCard() throws -> [Int: Set<String>]` (YENİ, `primaryTopicByCard()`'in yerine): `SELECT card_rowid, category_id FROM card_category`. Süzgeç yalnız yüklenen kelimelere uygulandığı için `is_free` süzgeci gerekmez.
- Besleme sorgusuna (`freeCards`) `card_category` JOIN EDİLMEZ (kartlar tekrarlanır, `ForEach` kimlik çakışması).
- **Tools/linux-stubs/ContentStore/ContentStore.swift**: `primaryTopicByCard()` yerine `public func topicsByCard() throws -> [Int: Set<String>] { [:] }`.

**Packages/VocabKit/Sources/CoreModels/ContentTopic.swift** (dal): `cardCount` açıklaması "üyelik sayısı" olur (alan adı kalır).

**Packages/VocabKit/Sources/Learning/DeckFilter.swift** (dal)
- `feed(_:topicsOf:choice:)` ve `filtered(_:topicsOf:topicIDs:)` (imza değişir): bir kelime, kategorilerinden biri seçiliyse kalır. Boş seçim ve "hiçbiri uymuyor" davranışı aynı (hepsini döndürür). `ordered(_:startingAt:)` değişmez.
- `struct DeckSummary: Equatable, Sendable { wordCount: Int; newCount: Int }` (YENİ).
- `static func summary(_ words: [WidgetWord], topicsOf: [Int: Set<String>], topicIDs: Set<String>, progress: [Int: WordProgress]) -> DeckSummary` (YENİ): önce `filtered`, sonra sayım. `newCount` = `(progress[id]?.state ?? .new) == .new` olanlar. Özet, Akış'ın gerçekte alacağı kelimeleri sayar (boş/uymayan seçimde hepsi).
- `QueueComposer`, `ReminderPlanner`, `ReviewPlanner` imzaları DEĞİŞMEZ.

**App/ContentLoader.swift** (dal): `LoadedContent.topicOf` → `topicsOf`; `loadTopics(from:)` `store.topicsByCard()` çağırır. Hata kelimeleri düşürmez (dalın davranışı).

**App/AppModel.swift** (dal): `topicOf` → `topicsOf`; `rebuildFeed()` `DeckFilter.feed(words, topicsOf:..., choice:)`. YENİ üyeler:
- `func deckSummary(for topicIDs: Set<String>) -> DeckSummary`: `topicIDs` önce `topics` kimlikleriyle kesilir, sonra `DeckFilter.summary(words, topicsOf:, topicIDs:, progress:)`.
- `func word(id: Int) -> WidgetWord?` (`words` içinde arar; detay sheet'i için).
- `var deckIsFinished: Bool`: `!deckChoice.topicIDs.isEmpty` ve `ReviewPlanner.newWords(feed: feedWords, progress: progress, limit: 1).isEmpty` ve `ReviewPlanner.newWords(feed: words, progress: progress, limit: 1)` boş değil.
- Dalın `refreshWidgetPlan()`, `setDeckChoice`, `pinFirst: currentWord` ve yedek kuyruğu aynen kalır.

**App/TopicPickerView.swift** (dal; değişir): `@Environment(\.scenePhase)` ve `.onChange(of: scenePhase) { _, phase in if phase != .active { apply() } }`; `.onDisappear` aynı `apply()`'ı çağırır (`hasLoaded` ise `model.setSelectedTopics(selection)`; `setDeckChoice` değişmediyse hiçbir şey yapmaz, yani tekrar çağrılması zararsız). Giriş metni (§3.2) ve dipnot eklenir. `DeckSummaryLine` yerleşimi (§3.2).

**App/DeckSummaryLine.swift** (YENİ, yalnız görünüm): girdi `DeckSummary`, `dailyGoal: Int`, `isEverything: Bool`. Metin seçimi §3.2 tablosu. `APP_LOGIC_FILES`'a girmez.

**App/RootView.swift** (dal; değişir): `@State private var detailWord: WidgetWord?`. `handle(_:)`: destedeyse `scrolledWordID`; `contentSource == .loading` ise `pendingWordID`; değilse `model.word(id:)` ile `detailWord`. `applyPendingWord(in:)` de aynı yolu izler (dal zaten sonsuz beklemeyi bitirdi). `.sheet(item: $detailWord)` içinde `NavigationStack { WordDetailView(word:) }` + `Kapat` + `.environmentObject(model)`. Açılış akışı (`fullScreenCover`) açıkken sheet açılmaz (iki sunum çakışır): `model.showsOnboarding` ise yok sayılır.

**App/SettingsView.swift** (dal): `deckSection` altbilgisi (§3.1). Başka satıra dokunulmaz.

**App/ReviewView.swift** (isteğe bağlı): `doneCard` §3.4. `ios/telaffuz` bu dosyaya dokunmaz (doğrulandı).

**UITests/LockglowScreenshotTests.swift** (dal): `6-ayarlar` görüntüsünden sonra Konular satırına gir, `6b-konular` al, geri dön (ayrıntı §8).

**Belgeler (kod adımından ÖNCE, adım 0):** `docs/contract/content-db.md` "Uygulama tarafı kuralları" bölümüne madde: konu süzgeci `card_category` üyeliğini okur (`is_primary` ne olursa olsun; bir kart birden çok konuda sayılır); yalnız `is_free = 1 AND sensitivity = 0` kartlar sayılır; grup başlıkları (`category.grp` harfi) veritabanında yoktur, uygulamada durur (`TopicGroup.title(of:)`; `taxonomy.json` `groups` adlarından bilerek farklıdır). Şema değişmez, `schema_version` artmaz. Sonra `ios/README.md`'de dalın "Deste (konu) seçimi" maddesi (`primary_topic` yerine üyelik, özet satırı, detay sheet'i), `DEVIR.md` durum satırı. Yeni numaralı madde eklenmez (zor-kolay 44, widget-ses 45, dal 46 aldı).

## 6. Widget etkisi

- **Widget kodu değişmez.** `WidgetWord`, `WidgetPlan`, `WordProvider`, `WordIntents` aynı kalır. Seçim yalnız kuyruğun içeriğini belirler (`widget_plan.json`).
- **Kuyruk (dalın davranışı, doğrulandı):** `QueueComposer.compose(deck: feedWords, fallbackFeed: DeckFilter.ordered(words, ...), pinFirst: currentWord)`. Destenin kelimesi varsa yalnız deste; destede yalnız zamanı gelmemiş öğrenilen kelimeler varsa onlar döner, yedeğe geçilmez; deste **sıfır** kelime verirse bütün konulardan. `QueueComposer` ilk geçişte desteden her bilinmeyen kelimeyi alır (vadesi gelen, vadesi gelmemiş, günlük sınırı aşan yeni). Üyelik süzgeci desteyi büyüttüğü için kuyruk daha uzun olur.
- **Görünen kelime:** `pinFirst` kuralı sayesinde seçim değişince, sıradan yeniden yazımda, ayar değişince değişmez. Konu değişiminden sonra destede olmayan sabitli kelime sınıra kadar kalır ve dokunulunca detay sheet'i açılır (§3.5).
- **Yeniden yazma tetikleri:** seçici kapanınca, uygulama etkin olmaktan çıkınca (YENİ), uygulama arka plana giderken (`sceneDidEnterBackground`), açılışta. Debounce yok; çift yazım zararsız çünkü ikinci yazımda görünen kelime yine sabitlenir.
- **Seed (`seed_words.json`):** değişmez; konu alanı yok. İlk plan yazımına kadar widget'ta döner. Veritabanı yoksa konu seçimi kapalıdır.
- **Yenileme bütçesi:** yeniden yazım ön plandayken olur; Apple'ın "Keeping a widget up to date" bütçesini tüketmez. Yeni `plan_id` imleci sıfırlar (mevcut davranış).
- **Widget başına konu (sonra):** `AppIntentConfiguration` gerekir. Taslak: yeni bir `kind` ekle (eskisi bozulmasın); `WidgetPlan` v2'de `queues: [String: [WidgetWord]]`; `widget_state.json`'da örnek başına imleç; yalnız kullanımdaki konfigürasyonlar için kuyruk. `WidgetWord`'e konu alanı eklenmez. Bugünkü tek kuyruk ve tek imleç varsayımı `WordProvider.swift` içinde `getTimeline` (satır 21-36) ve `makeEntries` (satır 38-68) ile `WordDataSource.swift` (24 satır) arasında dağılmıştır. Küçük iş değildir.

## 7. İzinler, gizlilik ve yasal metinler

- **Info.plist ve `project.yml`:** bu özellik için değişmez, yeni izin yok. (`ios/telaffuz` mikrofon ve konuşma tanıma anahtarlarını `project.yml`'ye ekliyor; ayrı iş.)
- **`App/PrivacyInfo.xcprivacy`:** bu özellik yeni bir gerekçeli API kullanmaz (UserDefaults zaten `CA92.1` ile bildirili). **Ancak denetimde mevcut bir eksik bulundu ve doğrulandı** (bu özelliğin sebebi değil): `Learning/ProgressStore.swift` (satır 115, 124, 162-164) `FileManager.default.attributesOfItem(atPath:)[.modificationDate]` okur ve `setAttributes([.modificationDate: ...])` yazar; `Learning` uygulamaya bağlıdır. Manifestte yalnız `NSPrivacyAccessedAPICategoryUserDefaults` var. Apple'ın `NSPrivacyAccessedAPIType` başvuru sayfası `FileAttributeKey.modificationDate` (`NSFileModificationDate`) simgesini File timestamp kategorisinde sayar ve `C617.1` gerekçesini "uygulama ya da App Group kapsayıcısındaki dosyaların zaman damgası" diye tanımlar. Düzeltme **ayrı küçük commit**: `NSPrivacyAccessedAPICategoryFileTimestamp` + `C617.1`. Widget manifesti değişmez (widget `Learning` bağlamaz; `modificationDate` yalnız `ProgressStore`'da kullanılıyor). Aksi halde App Store Connect uyarısı/reddi riski var. `docs/legal/app_store_privacy_etiketi.md:115` aynı kontrolü açık madde olarak listeliyor; bu işle kapatılır.
- **App Store gizlilik etiketi:** değişmez. Konu tercihi cihazdan çıkmaz, "toplanan veri" değildir. `docs/legal/gizlilik_politikasi_tr.md:41-45` "seçtiğiniz seviye, hedef ve ayarlar"ı zaten yerel veri sayıyor; konu tercihi bir ayardır.
- **`docs/legal/*` (bu özellik için değişmez), ama sürümün bütünü çelişir:** `ios/telaffuz` mikrofon kullanımı ekliyor ve yalnız 3 yasal dosyayı güncelliyor. `docs/legal/kvkk_aydinlatma_uygulama_tr.md:37` hâlâ "mikrofon ... toplanmaz" diyor, `docs/legal/README.md:72` hâlâ "Yok: ... mikrofon (MVP)" diyor (`main` ve `ios/telaffuz` ikisinde de aynı). Telaffuz oturumu ya da sürüm sahibi bir sonraki App Store gönderiminden önce ikisini düzeltmeli (adım 9).
- **Ücretli kategoriler (sonra):** 22 kategori `access = 'P'`. Bugün 6 tanesinin ücretsiz kartları var ama hepsi 5'ten az (seçicide görünmez). Üyelik sayımıyla s10+ içerik bunları 5'in üstüne çıkarırsa seçicide ücretli kategori görünür. App Store sürümünden önce `access` kuralı (kilit rozeti ya da gizleme) kararlaştırılmalı. Bu sürümde altyapı yok.

## 8. Testler

**Linux'ta çalışan VocabKit testleri** (beklenen değerler elle hesaplandı; bu PC'de çalıştırılamadı)
- `Tests/LearningTests/DeckFilterTests.swift` (dal, `topicsOf`'a uyarlanır). Sabit örnek: kelime 1..6; `topicsOf`: 1:{a}, 2:{a,b}, 3:{b}, 4:{c}, 5: (yok), 6:{a,c}.
  - seçim {a,b} → [1,2,3,6] (eski sıra, 2 yalnız bir kez);
  - seçim {c} → [4,6];
  - seçim {z} (hiçbiri uymuyor) → 6 kelimenin hepsi; seçim {} → hepsi;
  - konusu olmayan kelime (5) seçili destede yok (dalın testi korunur);
  - `summary({a,b})`, ilerleme: 1 `.known`, 2 `.learning`, 3 ve 6 kaydı yok → `wordCount == 4`, `newCount == 2`;
  - `summary({}) .wordCount == 6`; `summary(seçim).wordCount == feed(...).count` (Akış ile özet tutarlı);
  - dalın seviye testleri aynen geçer.
- `Tests/LearningTests/QueueComposerTests.swift` (dal): hiçbir değişiklik gerekmez. `testDeckQueueEqualsThePlainQueueWhenTheDeckIsEverything` Tümü regresyonunu korur.
- `Tests/ContentStoreTests/ContentStoreTests.swift` (yalnız macOS: `build.yml` `ios` işi; Linux kontrolü ContentStore'u kaldırır). Fixture `buildDatabase`'e `card_category` tablosu eklenir (dalın fixture'ında yok): kart 1 ana konu `food`, kart 2 ana konu `home` ve ayrıca `food` üyesi, kart 3 `is_free = 0`, kart 4 `sensitivity = 1`. Beklenen: `topics()`'ta `food` 2, `home` 1; yalnız ücretsiz olmayan kartı olan kategori yok; `topicsByCard()[2] == ["home","food"]`; ana konusu olmayıp üyesi olan kategori (`success_productivity` gibi) listede görünür. Mevcut `testTopicsCountFreeNonSensitiveCardsByPrimaryTopic` ve `testPrimaryTopicByCardCoversEveryCard` üyelik karşılıklarıyla yeniden yazılır.

**Snapshot ve UI testleri**
- `LockglowWidgetSnapshots` etkilenmez (widget görünümü değişmiyor).
- `LockglowScreenshotTests`: dalda onboarding `-lockglow.onboardingCompleted YES` ile atlanıyor, "Bildiğim kelime" satırı için `app.swipeUp()` koruması var (`Öğrenme` bölümü satırı aşağı itiyor). Yeni adım, `6-ayarlar`'dan sonra:
  `let topicsRow = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Konular")).firstMatch` (`app.buttons["Konular"]` eşleşmez: `NavigationLink` içindeki `LabeledContent` "Konular, Tümü" etiketi verir); gerekirse önce `swipeUp()`; `tap()`; `app.buttons["topics.all"]` bekle; `6b-konular` ekran görüntüsü; **`app.navigationBars.buttons.element(boundBy: 0).tap()` ile Ayarlar'a dön**, çünkü sonraki adım Ayarlar > "Bildiğim kelime" satırını arıyor. Konu seçilmez (kalıcı `UserDefaults` bozulmasın).
- `screenshots.yml` `workflow_dispatch`'tir, küçük (iPhone SE) ve büyük iPhone çalıştırır; bu iş bitince bir kez çalıştırılır (macOS dakikası 10 kat). SE'de özet çubuğu ve en büyük yazı boyutunda satır akışı `6b-konular` görüntüsünden kontrol edilir.

**Telefonda elle kontrol listesi** (sayılar üyeliğe göre, seviyeden bağımsız çünkü seviye sıralamadır)
- [ ] Güncelleme sonrası Ayarlar > Öğrenme > Konular "Tümü" diyor; Akış'ın ilk kartı değişmedi (yeni seviye seçilmediyse).
- [ ] Konular'da yalnız `Yeme & İçme`: özet `Seçili: 57 kelime`. `Hava & Mevsimler` tek başına: `Seçili: 18 kelime` ve "Kelime az olduğu için ..." satırı görünür. Kaydetme engeli yok.
- [ ] `Yeme & İçme` + `Ev & Ev İşleri`: özet `142 kelime` (156 değil). `İş Yeri & Ofis İngilizcesi` + `Teknoloji & İnternet`: `74 kelime`.
- [ ] Seç, geri dön: Akış yalnız o konuların kelimelerini gösteriyor; widget'taki kelime sınıra kadar aynı, sonra seçilen konudan.
- [ ] Seçici açıkken ana ekrana dön, uygulamayı kapat-aç: seçim korunmuş.
- [ ] Konusu kapatılmış, öğrenmekte olan kelime Tekrar'da hâlâ geliyor.
- [ ] Widget'taki sabitli (destede olmayan) kelimeye dokun: detay sheet'i açılıyor, `Kapat` çalışıyor.
- [ ] Seçili konuların yeni kelimeleri bitince Tekrar mesajı ve `Konuları düzenle` çıkıyor (adım 5 yapıldıysa).
- [ ] En büyük yazı boyutunda özet listenin üstünde, satırlar okunuyor. VoiceOver: satır "seçili / seçili değil", özet değişince okunuyor.
- [ ] Uçak modu ve yeniden başlatma sonrası seçim korunuyor.

## 9. Diğer dallarla çakışma ve uygulama sırası

| Dal | Durum | Çakışma |
|---|---|---|
| `ios/acilis-deste` | 3 commit, `origin`'de, CI yeşil | Bu belgenin temeli. Aynı dosyalar: `AppModel`, `ContentLoader`, `TopicPickerView`, `SettingsView`, `RootView`, `ContentStore` (+ stub), `DeckFilter`, `README`. Önce bu dal `main`'e girer. |
| `ios/zor-kolay` | `main`'e birleşti | Çakışma yok |
| `ios/widget-ses` | 5 commit | Çakışma yok (`Speaker.swift`, `Shared/*`, `Widgets/*`, `project.yml`). Yalnız `ios/README.md` ve `project.yml` birleşmede dikkat. |
| `ios/telaffuz` | 2 commit | `SearchView.swift`'te 1 satır: `WordDetailView`'in bulunduğu dosya. Detay sheet'i o görünümü sarar, çatışma çıkmaz ama telaffuz düğmesi eklenirse sheet'te de görünür (kabul). `project.yml`, `docs/legal`: bu özellik dokunmaz. |
| `tasarim/arayuz-mockup` | 2 commit + taslak | Konu seçici ekranı taslakta var (Ayarlar > Konular, onboarding 2. sayfa). Grup adları ("Günlük hayat, Seyahat ve kültür...") dalla aynı. |
| `icerik/s10..s13` | s10: 2, s11: 1, s12: 0, s13: `main` | Kod değişmez. Yeni kartlar DB'nin sonraki tek seferlik derlemesiyle gelir; kategori kimlikleriyle tutulan seçim etkilenmez. |

**Sıra:** adım 0 (belge) bağımsızdır, hemen yapılır. Kod adımları `ios/acilis-deste` `main`'e birleştikten sonra `main`'den dal açılarak yapılır. Acele varsa dal `origin/ios/acilis-deste` ucundan açılır ve o dalın arkasından birleşir; Açılış oturumuna önceden haber verilir (`DeckFilter` imzası değişir).

**Ortak parçalar (gerçek dal API'si)**

| Parça | Sahibi | Not |
|---|---|---|
| `AppModel.words` (hepsi), `feedWords` (deste), `topics`, `choosableTopics`, `deckChoice`, `activeTopicIDs`, `setDeckChoice`, `setSelectedTopics`, `setStartLevel`, `showsOnboarding` | Açılış oturumu | Adlandırma ve anlam korunur. Bu belge yalnız `deckSummary(for:)`, `word(id:)`, `deckIsFinished` ekler. |
| `AppPreferences.selectedTopicIDs: Set<String>` (boş = Tümü), `startLevel`, `onboardingCompleted` | Açılış oturumu | Tür ve anlam korunur. |
| `TopicPickerView()` (argümansız), `TopicChoiceList(topics:totalWordCount:selection:)` | Açılış oturumu | İmza korunur; yalnız içine `scenePhase` ve özet eklenir. |
| `DeckFilter.feed/filtered/ordered`, `DeckChoice` | Açılış oturumu | **İmza değişir:** `topicOf` → `topicsOf: [Int: Set<String>]`. |
| `ContentStore.topics()`, `primaryTopicByCard()` | Açılış oturumu | `topics()` SQL'i değişir, `primaryTopicByCard()` → `topicsByCard()`. |
| Ayarlar > Öğrenme bölümü | Açılış oturumu | İkinci "Öğrenme" bölümü eklenmez; yalnız altbilgi metni değişir. |
| `RootView.handle` / `applyPendingWord` | Açılış oturumu | Bu belge yalnız son dala detay sheet'i ekler. |

## 10. Riskler ve açık sorular

**Kullanıcıya sorulacaklar**
1. KULLANICIYA SOR: Konu sayıları ve süzgeç üyelik mi (öneri), ana konu mu (dalın bugünkü hâli)? Üyelikte `Seyahat & Turizm` 55 kelime, ana konuda 20. Üyelikte `Sosyal Beceriler & Sohbet` 108 gösterir ama 60'ı asıl başka konuya ait. Geri dönüş tek fonksiyon (`topicsByCard()`).
2. KULLANICIYA SOR: Konu değiştirince widget'taki kelime hemen mi değişsin, sınıra (varsayılan 60 dk) kadar mı kalsın? (Öneri: kalsın; README "Süreklilik" kuralı ve dalın davranışı.) Hemen değişsin istenirse yalnız konu değişimi yazımında `pinFirst` verilmez, ama o zaman destede olmayan kelime bir daha görünmez.
3. KULLANICIYA SOR: Deste bitince Tekrar'da "Başka konulardan devam et" düğmesi olsun mu? (Öneri: yok; widget zaten devam eder, Tekrar'da mesaj ve "Konuları düzenle" var.)
4. KULLANICIYA SOR: En az konu sayısı? UX raporu O6 "en az 3 konu" öneriyor, dal 1 konuya izin veriyor. (Öneri: serbest, yumuşak özet uyarısı yeter.)
5. KULLANICIYA SOR: Bazı konu adları A2 için ağır: `Phrasal Verb'ler`, `Karıştırılan Kelimeler & Tuzak Kelimeler` (`content-pipeline/data/taxonomy.json:76` ve DB `name_tr`). Daha sade ad ister misin ("İki kelimeli fiiller")? Değişiklik içerik hattında, DB'nin bir sonraki derlemesinde yapılır, bu özellikte değil.
6. KULLANICIYA SOR (Açılış oturumunun kararı): Güncelleyen mevcut kullanıcıya açılış akışı bir kez gösterilsin mi? Dalda geçiş kodu yok. Gösterilmesin isteniyorsa "ilerleme dosyası varsa tamamlandı say" gibi bir kural o dalda eklenmeli.

**Riskler**
- **Linux kontrolü bu PC'de çalışmaz** (Docker yok), `swift` de yok. Stub aynı commit'te güncellenmezse `ContentLoader` Linux derlemesi kırılır. `linux_check.sh` Docker'lı makinede ya da `build.yml` ile bir kez çalıştırılır.
- **`DeckFilter` imzasının değişmesi** Açılış oturumunun kodunu etkiler. Önlem: dal `main`'e girdikten sonra yapmak ya da o oturumla anlaşmak.
- **Üyelik süzgeci desteyi büyütür:** daha önce ana konuyla seçilmiş eski seçim sessizce genişler (kişisel sürümde kabul).
- **Kısa deste:** dal yalnız sıfır kelimede yedeğe geçer. Destede 1-4 bilinmeyen kelime kalırsa kuyruk kısadır ve widget aynı kelimeleri döndürür. `minimumTopicCards = 5` yalnız seçim anında korur. Özetteki "Kelime az ..." satırı bunu önceden söyler. Kısa kuyruğun `TimelinePlanner`'daki davranışı bu okumada doğrulanmadı.
- **Sheet ve tam ekran akış çakışması:** açılış akışı açıkken widget bağlantısı gelirse iki sunum çakışır; bu yüzden sheet yok sayılır (§5).
- **`scenePhase` uygulaması iki kez yazabilir** (`.inactive` + `.background`). İkinci yazımda görünen kelime sabitlenir; zararsız.
- **Ücretli kategori görünmesi:** bkz. §7.
- **Gizlenen kategoriler:** alt küme modunda 1-4 kartlık kategorilerin kartları dışarıda kalır (Tümü'nde içeride). Kabul edilen değişim.
- **Sayılar kaymış olabilir:** hiçbir yerde 753 gibi sabit yok, hepsi veritabanından hesaplanır. Örnek sayılar bu belgede yalnız `content.sqlite` (`2026.10.20-kisisel-4`) için doğru.
- **Doğrulanamayanlar:** Swift derlemesi, tüm testler, SwiftUI düzeni (`safeAreaInset`, büyük yazı), `app.navigationBars.buttons.element(boundBy: 0)` ile geri dönüş.

## 11. İş adımları

Her adım ayrı commit (Türkçe mesaj, `git commit -F`). Önce belge, sonra çekirdek, sonra bağlantı, en son arayüz.

- [ ] **0. Belge ve gizlilik ön işi.** (a) `docs/contract/content-db.md` "Konu süzgeci" maddesi (§5). (b) Ayrı commit: `App/PrivacyInfo.xcprivacy`'ye `NSPrivacyAccessedAPICategoryFileTimestamp` + `C617.1`. Doğrulama: plist biçimi geçerli (`plutil -lint` Mac'te ya da CI derlemesi); sözleşme metni `ios/README.md` ile çelişmiyor.
- [ ] **1. Saf çekirdek:** `ContentStore.topics()` (üyelik), `topicsByCard()`, Linux stub; `DeckFilter` (`topicsOf`, `summary`, `DeckSummary`); `DeckFilterTests` ve `ContentStoreTests` fixture. Doğrulama: §8'deki beklenen değerleri elle denetle; `bash ios/Tools/linux_check.sh` (Docker'lı makinede) yeşil; `build.yml` `ios` işi bir kez çalışınca `ContentStoreTests` yeşil.
- [ ] **2. Uygulama bağlantısı:** `ContentLoader` (`topicsOf`), `AppModel` (`topicsOf`, `deckSummary(for:)`, `word(id:)`, `deckIsFinished`). Doğrulama: `linux_check.sh` `AppLogic` derlemesi; Tümü'nde `feedWords == words` (`DeckFilterTests` + dalın `QueueComposerTests` regresyonu).
- [ ] **3. Konular ekranı:** `DeckSummaryLine`, `TopicPickerView` (giriş metni, özet, dipnot, `scenePhase`), `SettingsView` altbilgisi. Doğrulama: simülatörde Ayarlar > Konular; özet metinleri §3.2 ile aynı; seçici açıkken arka plana gidince seçim korunuyor.
- [ ] **4. Detay sheet'i:** `RootView.detailWord` ve sarmalayıcı. Doğrulama: `xcrun simctl openurl booted vocabwidget://word/<id>` ile destede olmayan kimlik sheet açar; destedeki Akış'ta kayar.
- [ ] **5. (İsteğe bağlı) Tekrar mesajı:** `ReviewView.doneCard` §3.4. Doğrulama: tek konu seç, o konunun yeni kelimelerini bitir (ya da simülatörde ilerleme dosyasıyla), mesaj ve düğme görünür.
- [ ] **6. UI testi:** `Konular` adımı ve geri dönüş (§8). Doğrulama: `screenshots.yml` bir kez; `6b-konular` iPhone SE'de taşmıyor, sonraki "Bildiğim kelime" adımı hâlâ geçiyor.
- [ ] **7. Belgeler:** `ios/README.md` (dalın "Deste (konu) seçimi" maddesi ve elle kontrol listesi), `DEVIR.md`. Doğrulama: metinlerde `61 kategori` ve "9 gizli kategori" gibi yanlış sayı kalmadı (doğrusu 60 ve 10); `docs/` yolu `build.yml` `paths-ignore`'da, macOS işi tetiklenmez.
- [ ] **8. Telefonda elle kontrol listesi** (§8) ve gelen geri bildirimle düzeltmeler.
- [ ] **9. Diğer oturumlara el verme:** Telaffuz oturumuna/sürüm sahibine: `docs/legal/kvkk_aydinlatma_uygulama_tr.md:37` ve `docs/legal/README.md:72` mikrofon ifadelerini App Store gönderiminden önce güncellemeli. Açılış oturumuna: `DeckFilter` imza değişikliği, KULLANICIYA SOR 6.

## 12. Denetim notları

Her madde, koddan ve belgelerden kendim doğrulandıktan sonra işlendi (git geçmişi, `content.sqlite` sorguları, dalın dosyaları, Apple başvuru sayfası).

1. **[kod, blocker] Eski öncül: dallar boş değil, özellik zaten dalda.** Doğrulandı (`ios/acilis-deste` 3 commit, `main` = `d99180e`, s10 2 commit): düzeltildi. Belge dalın üzerine yeniden kuruldu, çoğaltılan adımlar silindi.
2. **[kod, major] Arayüz sözleşmesi dalla çelişiyor (7 alt madde).** Hepsi doğrulandı: `words` anlamı, `selectedTopicIDs` türü, `TopicPickerView` imzası, `startLevel` sıralaması, açılış göçü yok, çift "Öğrenme" bölümü, ContentStore/stub: düzeltildi. §9 tablosu dalın gerçek API'siyle yeniden yazıldı, dalın adlandırması korundu.
3. **[kod, major] `pinCandidate` taşma kelimesini sabitlemez, süreklilik bozulur.** Doğrulandı (tasarım gereği): düzeltildi. `FeedScope`, `pinCandidate` ve "20 kuyruk" taşması kaldırıldı; dalın `pinFirst: currentWord` kuralı ve yalnız sıfırda yedek kullanılıyor (§6).
4. **[kod, minor] UI testi: `app.buttons["Konular"]` eşleşmez, ek bölüm satırı aşağı iter.** Doğrulandı (test dosyasında aynı kalıp için `BEGINSWITH` var, dal `swipeUp` ekledi): düzeltildi (§8: ön ek koşulu, kaydırma, geri dönüş).
5. **[kod, minor] Debounce görevi yalnız kendi çağrısında iptal oluyor.** Doğrulandı (`sceneDidEnterBackground` doğrudan `refreshWidgetPlan()` çağırıyor): düzeltildi, debounce kaldırıldı. Aynı incelemede dalın `.onDisappear`-yalnız uygulamasında arka plana giden seçicinin kaybolabileceği bulundu; `scenePhase` ile kapatıldı (§5).
6. **[kod, minor] 9 değil 10 gizli kategori; `WordProvider.swift:114-143` yok.** Doğrulandı (10 kategori, dosya 69 satır): düzeltildi (Durum bölümü, §6: `getTimeline` 21-36, `makeEntries` 38-68, `WordDataSource.swift` 24 satır).
7. **[kod, minor] Sözleşme düzenlemesi kod adımından sonra.** Doğrulandı (`content-db.md` satır 3): düzeltildi. Adım 0'a taşındı; `schema_version` artmaz (şema değişmiyor).
8. **[ürün, blocker] Eski öncül ve §9 sözleşmeleri.** Madde 1 ve 2 ile aynı; ek olarak taslakta konu seçici ekranının olmadığı iddiası da yanlıştı (taslakta var, satır 1205/1225/1411): düzeltildi.
9. **[ürün, major] 50 kelime kapısı seviye süzgeciyle birleşince tutarsız.** Sayılar doğrulandı (tüm seviyede 13/24, A2+ ile 7/24, yalnız B1 ile 1/24 konu tek başına 50'yi geçiyor; `workplace_office` her seviyede 22): düzeltildi. Kapı ve seviye süzgeci kaldırıldı, seviye sıralama (dal), manuel liste sayıları yeniden hesaplandı.
10. **[ürün, major] Geçersiz taslak sessizce atılıyor.** Doğrulandı (taslağın kendi akışı): düzeltildi. Geçersiz seçim durumu kalmadı (boş = Tümü); ekranda görünen seçim her zaman uygulanacak olandır, onboarding'de "Atla" var (dal).
11. **[ürün, major] Kapı ve özet ilerlemeyi yok sayıyor, "0 gün", sabit "10".** Doğrulandı (tamsayı bölme, hedef 5/10/15/20): düzeltildi. Gün tahmini silindi; özet yeni kelime sayısını gösteriyor, `newCount == 0` ve `< hedef` için ayrı metin var (§3.2).
12. **[ürün, major] Arayüz metni widget'ın yaptığıyla çelişiyor, 20 eşiği aceleci.** Doğrulandı (`QueueComposer` ilk geçişte desteden tüm bilinmeyenleri alır): düzeltildi. Karışık kuyruk kaldırıldı, dalın "yalnız sıfırda yedek" kuralı alındı, metin bunu doğru söylüyor (§3.2 giriş metni).
13. **[ürün, major] `PrivacyInfo.xcprivacy` dosya zaman damgası kategorisini bildirmiyor.** Doğrulandı (`ProgressStore.swift` satır 115/124/162-164; Apple başvuru sayfası `modificationDate` simgesini File timestamp altında listeliyor, `C617.1` kapsayıcı dosyaları için): düzeltildi (kısmen: bu özelliğin sebebi değil, önceden var olan eksik; ayrı küçük commit olarak adım 0b'ye ve §7'ye alındı).
14. **[ürün, minor] Dynamic Type, VoiceOver, küçük ekran tasarımı yok.** Doğrulandı: düzeltildi. Yapışık çubuk büyük yazıda listenin üstüne iner, "Grubu seç" düğmeleri kaldırıldı (grup başlığı sorunu da bitti), özet `updatesFrequently`, SE ve büyük yazı kontrolü adım 6'da.
15. **[ürün, minor] Sade olmayan Türkçe, dil türü kümeler konu satırı gibi.** Kısmen doğrulandı (`Phrasal Verb'ler`, `Karıştırılan Kelimeler & Tuzak Kelimeler` gerçekten DB adı, iki ayrı grup başlığı seti vardı): düzeltildi (tek başlık seti = dalın seti, altbilgiler kısaltıldı). Önerilen "24 satır için elle yazılmış görünen ad" bu özelliğe alınmadı: `name_tr` içerik sözleşmesidir ve kaynağı `taxonomy.json`; ad değişikliği içerik hattında yapılır (KULLANICIYA SOR 5).
16. **[ürün, minor] Kişisel v1 için fazla kapsam.** Doğrulandı: düzeltildi. `CategoryAccess`/`isLocked`, gün tahmini, grup düğmeleri, `FeedScope`, debounce, "Kullanılamıyor" satırı çıkarıldı. Detay sheet'i kaldı (dalın gerçek eksiği) ve `WordDetailView`'in push için kurulu olduğu (`SearchView.swift:74`) için sarmalayıcı eklendi; sonsuz `pendingWordID` beklemesini dal zaten düzeltmişti.
17. **[ürün, minor] Mikrofon ifadesi yasal belgelerde çelişecek.** Doğrulandı (`kvkk_aydinlatma_uygulama_tr.md:37`, `docs/legal/README.md:72`, ikisi de `ios/telaffuz`'da değişmemiş): düzeltildi (§7 ve adım 9'a el verme notu).
18. **[ürün, minor] `app.buttons["Konular"]` eşleşmez.** Madde 4 ile aynı: düzeltildi.

Özet: 18 madde, 18'i işlendi (13 ve 15 kısmen, nedenleri yukarıda), 0 reddedildi.
