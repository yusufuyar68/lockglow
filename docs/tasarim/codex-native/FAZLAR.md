# A yönünün gerçek iOS uygulamasına aktarımı

25 Ekim 2026. Kaynak: `yusufuyar68/lockglow`, başlangıç `ac3cbed`.

## Çalışma kuralı

Her fazda kaynak değişikliği, ilgili otomatik test ve native simülatör kanıtı ayrı kaydedilir. Başarısız kapı düzeltilmeden sonraki fazın uygulamasına geçilmez. Windows'ta kaynak incelemesi ve içerik denetimi yapılır; Swift ve iOS testleri GitHub Actions'ın Linux/macOS makinelerinde çalışır. HTML testleri iOS testi yerine geçmez.

26 Ekim ek isteği: desteklenen iPhone ekranları için [cihaz uyum planı](CIHAZ-UYUM-PLANI.md) hazırlandı. Küçük/standart/büyük viewport, güvenli alan, Dynamic Type, Display Zoom, klavye ve fiziksel kontrol matrisi bu fazların genişletilmiş kabul planıdır; henüz çalıştırılmamış profiller geçti sayılmaz.

Mevcut Leitner/FSRS, gerçek kart kimlikleri, ses ve veri sözleşmeleri esastır. Prototipin A/B/C kimlikleri, sabit 3/1/2/5 gün politikası ve 3/5/8 günlük seçenekleri taşınmaz. Native uygulamada gerçek konu seçimi ve 5/10/15/20 günlük hedefler vardır. Başlangıçtaki 1.383 kart, 26 Ekim güncel main birleşmesinde 2.223 kartlık B2/C1 içeriğiyle güncellenir; geçmiş koşular kendi içerik sürümlerinin kanıtıdır. Yeni kurulumda FSRS varsayılanı ve mevcut kullanıcının zamanlama seçimi korunur. A1–A2 için seçilmemiş hedef 5, B1–B2 için 10'dur; C1 başlangıç seçeneği değildir.

## Prototipten native karşılığa

Bu eşleme kaynak koduna dayanır; test başarısı veya faz onayı değildir. Tarayıcı motoru native motorun yerine geçirilmez. Yeni aktarım kartın görünümü ile açılıştaki günlük seçim ve isteğe bağlı bilinen elemedir; mevcut native davranışlar kendi API ve veri sözleşmeleriyle doğrulanır.

| Faz | Prototipteki amaç | Gerçek native dosya ve ana API | Mevcut özellik / bu aktarım |
|---|---|---|---|
| 1 | A kartının okuma sırası, satır içi örnek ve çeviri | [ios/App/FeedCardView.swift](../../../ios/App/FeedCardView.swift): `FeedCardView`; [ios/App/CardDetailViews.swift](../../../ios/App/CardDetailViews.swift): `ExampleRow` | Mevcut native kart üzerinde yeni görsel aktarım; gerçek kart ve callback'ler korunur. |
| 1 | Yeşil yerel vurgu ve hafif degrade | [ios/App/FeedCardView.swift](../../../ios/App/FeedCardView.swift): `highlightColors`; [ios/Shared/LockglowTheme.swift](../../../ios/Shared/LockglowTheme.swift): `cardSurface(appearance: .quietPaper)` | Bu aktarımda yeni; yeşil Akış kartına özeldir. Degrade yalnız açık ve normal kontrastta; widget'ın varsayılan paleti değişmez. |
| 2 | Biliyorum ve geri alma | [ios/App/AppModel.swift](../../../ios/App/AppModel.swift): `markKnown`, `undoKnown`, `KnownUndo` | Zaten var; kısa penceredeki önceki ilerlemeyi tam geri yükleme ve araya giren cevabı koruma doğrulanır. Prototipin undo kaydı taşınmaz. |
| 2 | Tekrar ve vade hesaplama | [ios/App/AppModel+Scheduler.swift](../../../ios/App/AppModel+Scheduler.swift): `reviewScheduler`; [ios/App/AppModel.swift](../../../ios/App/AppModel.swift): `recordReview`; [ios/Packages/VocabKit/Sources/Learning/ReviewScheduler.swift](../../../ios/Packages/VocabKit/Sources/Learning/ReviewScheduler.swift): `LeitnerScheduler` | Leitner ve isteğe bağlı FSRS zaten var; gerçek algoritma korunur. Prototipin örnek sabit gün politikası uygulanmaz. |
| 3 | Açılış, seviye ve konu seçimi | [ios/App/OnboardingView.swift](../../../ios/App/OnboardingView.swift): `applyChoice`, `finish`; [ios/App/AppModel.swift](../../../ios/App/AppModel.swift): `setDeckChoice`, `finishOnboarding` | Dört sayfalı native temel zaten var; açılış, yeni günlük seçim ve isteğe bağlı eleme adımlarıyla tamamlanacak. Gerçek konu seçimi prototipteki hedef tercihinin karşılığıdır. Widget rehberi ve ilk kelime korunur. |
| 3 | Günlük hedef ve gün sonu | [ios/Packages/VocabKit/Sources/Learning/SettingsRules.swift](../../../ios/Packages/VocabKit/Sources/Learning/SettingsRules.swift): `dailyNewWordChoices`; [ios/App/AppPreferences.swift](../../../ios/App/AppPreferences.swift): `chooseDailyNewWords`; [ios/App/FeedView.swift](../../../ios/App/FeedView.swift): `considerDayEnd` | 5/10/15/20 hedefleri ve gün sonu kartı zaten var. İlk açılışta açık miktar seçimi eklenecek; önceden seçilmiş miktar ve A1/A2=5, B1=10 varsayılanları korunur. Görülme sayımı doğru tekrar cevabı değildir. |
| 3 | İsteğe bağlı başlangıç bilinen eleme | Mevcut temel: [ios/App/AppModel.swift](../../../ios/App/AppModel.swift) `markKnown`, `undoKnown`; [ios/App/FeedView.swift](../../../ios/App/FeedView.swift) `items` | Açılış arayüzü henüz yok; aktarılacak. Gerçek desteden seçim/çıkarma/atlama, üç günlük native kontrol planı, geçmişi koruma ve başlangıç Akış'ından eleme birlikte sınanır. Akış'taki normal Biliyorum dokunuşundan sonra mevcut kartın yerinde kalması korunur. |
| 4 | Sözlükten yeniden bulma | [ios/App/SearchView.swift](../../../ios/App/SearchView.swift): `SearchView`; [ios/App/SozlukWordPage.swift](../../../ios/App/SozlukWordPage.swift): `WordDetailView`; [ios/App/SozlukParts.swift](../../../ios/App/SozlukParts.swift): `SozlukFilter` | Sözlük araması ve öğrenme durumu süzgeçleri zaten var; kelimeye ve gerçek ilerleme durumuna yeniden ulaşma doğrulanır. |
| 4 | Kelime ve örnek sesi | [ios/App/CardDetailViews.swift](../../../ios/App/CardDetailViews.swift): `CardListenCapsule`, `CardSentenceSpeaker`; [ios/App/Speaker.swift](../../../ios/App/Speaker.swift): `Speaker.toggle`; [ios/Shared/WordSpeech.swift](../../../ios/Shared/WordSpeech.swift): `WordSpeech` | Ortak native ses altyapısı zaten var; mevcut ses seçimi ve kayıt/TTS yolu doğrulanır. Tarayıcıdaki ses oynatıcı taşınmaz. |
| 4 | Yedek, önizleme ve içe aktarma | [ios/App/AppModel+DataControls.swift](../../../ios/App/AppModel+DataControls.swift): `writeExportFiles`, `readBackup`, `importSummary`, `importData`; [ios/Packages/VocabKit/Sources/Learning/DataExport.swift](../../../ios/Packages/VocabKit/Sources/Learning/DataExport.swift): `DataArchive`; [ios/Packages/VocabKit/Sources/Learning/DataImport.swift](../../../ios/Packages/VocabKit/Sources/Learning/DataImport.swift): `DataImport.plan` | Native yedek ve birleştirme zaten var. Gerçek `lockglow-yedek` biçimi korunur; içe aktarma mevcut yerel ayarları korur. Prototip JSON'u doğrudan native yedeği sayılmaz. |
| 4 | Widget ve hassas içerik | [ios/Widgets/WordProvider.swift](../../../ios/Widgets/WordProvider.swift): `makeEntries`; [ios/Widgets/WordActions.swift](../../../ios/Widgets/WordActions.swift): `next`, `know`; [ios/Packages/VocabKit/Sources/Learning/QueueComposer.swift](../../../ios/Packages/VocabKit/Sources/Learning/QueueComposer.swift): `compose` | Gerçek WidgetKit zaman çizelgesi, eylemler ve hassas kart dışlama zaten var; görünüm/hata durumları doğrulanır. Tarayıcı widget benzetimi bunların yerine geçmez. |

## Fazlar

| Faz | İş ve kabul kapısı | Durum |
|---|---|---|
| 0 | Kaynak, talimatlar, temiz ayrı dal; mevcut kodun başarılı temel derlemesini doğrulama | Tamamlandı |
| 1 | A kartının okuma sırası, satır içi örnek/çeviri, ayrı Biliyorum, yeşil yerel palet ve hafif açık yüzey; native derleme, SE/Pro, AX ve gerçek kaydırma görüntüleri | Tamamlandı: SE 40298913915, Pro AX 40295455163; kararlı görüntüler incelendi |
| 2 | Mevcut öğrenme ve geri almanın işlevsel eşdeğerliği; gerçek AppModel ile tam snapshot geri yükleme ve yeni cevabı koruma testleri | Tamamlandı: 40316588542 iki gerçek AppModel testi geçti |
| 3 | Açılışa native günlük miktar ve isteğe bağlı bilinen eleme aktarımı; düzey/konu, rehber, ilk kelime ve kalıcılığı gerçek veriyle doğrulama | Tamamlandı: 40373300406, SE ve Pro/iOS 26.1; iki UI + altı model testi/profil, toplam 18 özgün PNG incelendi |
| 4 | Widget görünüm/hata durumları, içerik hassasiyeti, gerçek yedek/birleştirme ve ses kontrolleri | Uygulandı; CI ve 12 widget görüntüsünün kabulü bekleniyor |
| 5 | Tüm yeni kodda paket testleri, native derleme ve son SE/Pro/koyu/AX görsel incelemesi | Sırada |

## Başlangıç kanıtı

- Masaüstündeki kaynak depoda değişiklik yoktu; `is6-hig`, `ac3cbed`.
- Çalışma ayrı `codex/ios-a-transfer` dalındadır. Asıl klasörde dal değiştirilmez.
- Önceki uygulama kodu `f13b15c` için [Linux/Python build 40188851249](https://github.com/yusufuyar68/lockglow/actions/runs/40188851249) ve [native görüntü koşusu 40184027401](https://github.com/yusufuyar68/lockglow/actions/runs/40184027401) başarılıdır. `ac3cbed` ile fark yalnız üç Markdown dosyasıdır; native kod aynıdır. Eski yeşil yeni değişikliğin kanıtı sayılmaz.

## İlk kod incelemesinde bulunanlar

Native uygulama prototipten daha ayrıntılıdır: kalıcı gerçek kart numaraları, seçilebilir Leitner/FSRS, kısa pencerede tam geri alma, günlük atomik yedek, bozuk dosyayı koruma, kendi kelimeleri ve birleştirmeli veri içe aktarma vardır. Bunların yerine örnek tarayıcı motoru konmaz.

Olay işleme incelemesi, ilerleme kaydından sonra widget olay dosyasını silmenin başarısız olması hâlinde aynı olayın yeniden uygulanması riskini gösterdi. Bu kaynak incelemesi bulgusudur; cihazda gözlemlenmiş bir hata gibi sunulmaz.

26 Ekim kapsam düzeltmesi: bu eski riskin kalıcı çözümü atomik ilerleme + işlenmiş olay kimlikleri, bütün kayıt yolları, yedek kurtarma ve eski sürüme dönüşü birlikte ele alan bir veri geçişi gerektiriyor. Tasarım aktarımının öğrenme eşdeğerliği kapısı mevcut dosya biçimiyle sınanır; veri geçişi ayrı dayanıklılık işidir. Risk çözülmüş gibi işaretlenmez. Böylece görsel aktarım kendi başına kullanıcının kayıt biçimini değiştirmez.

Gerçek koşuların başarıları, hataları ve kanıt sınırları [KONTROL.md](KONTROL.md) dosyasındadır.

## Cihazda ayrıca doğrulanacaklar

Simülatör derlemesi fiziksel iPhone doğrulaması değildir. Widget bütçesi, kilitli ekranda gerçek yenileme, ses oturumu, mikrofon/konuşma modeli ve VoiceOver'ın gerçek okuması telefonda ayrıca denenir. TestFlight yüklemesi bu test iş akışının parçası değildir.
