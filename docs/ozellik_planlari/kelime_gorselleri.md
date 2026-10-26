# Kelime görselleri (2026-10-26)

Somut bir kelimenin yanında küçük bir SF Symbol görünür: "luggage" yanında tekerlekli bavul, "fridge" yanında buzdolabı, "listen" yanında kulak. Görsel kelimeyi öğretmez, yalnızca hatırlamaya yardım eder. Bu yüzden yalnız anlamın zaten göründüğü yerlerde çıkar.

Kaynak: `docs/magaza/rakip_eksik_analizi.md` (rakiplerde kelime resmi var, bizde yoktu). Görsel olarak yalnız SF Symbols kullanılır: ücretsizdir, telefonda zaten vardır, açık ve koyu modda, renkli ve tek renkli widget'ta kendiliğinden doğru çizilir. Fotoğraf ya da çizim eklenmez.

> **Durum:** dal `rakip-ozellikler`. Hat testleri (pytest) ve `validate --strict` Windows'ta geçti. Linux'ta Swift testleri, macOS'ta uygulamanın derlenmesi ve `LockglowWidgetSnapshots` henüz koşmadı. Cihazda denenmedi.

## Ne gösterilir, nerede

| Yüzey | Görsel | Kural |
|---|---|---|
| Akış kartı (`FeedCardView`) | Başlıktaki kelimenin sağında | `.title2`, `Theme.ink2`. Kısaltma adımlarında (`FitStep.smaller` ve sonrası: iPhone SE, en büyük yazılar) hiç yok. Kelimeyle aynı satıra kelimenin kendi boyunda sığmazsa da yok |
| Sözlük kelime sayfası (`WordDetailView`) | Başlıktaki kelimenin sağında | Aynı kural: kelime küçülmez, görsel düşer |
| Büyük widget (`LargeWordView`) | Kelime satırında, seviyeden önce | Yalnız en dolu düzende ve kişinin yazı boyutunda; kelime en büyük adımında (28 pt) sığmalı. Yer daralınca ilk giden odur ("Yeni kelime"den de önce). "Anlamı gizle" açıkken ve "Göster"e dokunulmadan yok: o sırada Türkçe anlamın yerinde de "Göster" düğmesi durur (küçük ve orta widget'taki gibi). "Göster"den sonra anlam ve görsel birlikte gelir. StandBy'da anlam hiç gizlenmez |
| Küçük, orta, kilitli ekran widget'ları | Yok | Yer yok |
| Apple Watch | Yok | Plan sembolü taşır ama saat çizmez |

Görsel her yerde süs: VoiceOver okumaz (`accessibilityHidden`), kelime zaten okunur. Sarı asla değildir; sarı yalnız kelimenin bandıdır. Widget'ta `WidgetColors.ink2` kullanılır, böylece renkli (accented) ve titreşimli (vibrant) çizimde sistem stiline uyar.

Sistem sembolü çizemiyorsa (`UIImage(systemName:)` nil) hiçbir şey gösterilmez; boşluk da kalmaz (`Shared/WordSymbol.swift`).

Büyük widget'ta "Anlamı gizle" (2026-10-26 düzeltmesi): önceden büyük widget bu seçeneği yok sayıyor, Türkçe anlamı hep gösteriyordu; görsel ise gizleniyordu, yani anlam görünürken görsel yoktu. Artık büyük widget küçük ve ortanın aynısını yapar: anlamın yerinde "Göster" (`widgetMeaningReveal`, aynı dosya ve zaman çizelgesi mantığı), dokununca anlam ve görsel. Yalnız Türkçe anlam gizlenir; İngilizce tanım, örnekler ve uyarı satırı kalır (uyarıdaki Türkçe kelime sahte dosttur, anlam değil: "aktüel ≠ actually").

## Asla soru yüzeyinde değil

Görsel cevabı verir. Şu yerlerde **hiç** görünmez:

- Tekrar'ın soru kartları, cevap açılmadan önce (`ReviewView`, `QuizCardView`)
- Quiz widget'ı (`QuizWidgetViews`: `WidgetQuizItem` sembol alanı taşımaz)
- Dinle ve yaz soruları (`ListenQuestionView`, `TypeQuestionView`)
- Seviye testi (`PlacementTestView`)
- Cümle alıştırması (`SentencePracticeCards`)
- "Hatırla" seçenekleri (`AppModel.introCandidates` kelimeyi yeniden kurar, sembol düşer)

Görseli çizen yalnız üç yer var: `HeadlineWithSymbol` (yalnız `FeedCardView` ve `WordDetailView` kullanır) ve `LargeWordView`'un `WidgetWordRow(symbol:)` çağrısı. `WidgetWordRow`'un `symbol` parametresi varsayılan olarak nil; orta widget ve quiz widget'ı onu vermez. Yeni bir yere eklemeden önce o yerin bir soru olmadığından emin ol.

## Veri yolu

1. `content-pipeline/data/card_symbols.json`: düz, anahtara göre sıralı `{kart kimliği: SF Symbol adı}` nesnesi, LF satır sonu.
2. `vocabpipe.build_db` (ve `vocabpipe.personal`): `card.symbol` sütununa yazar (çoğu kartta NULL); seed'de yalnız görseli olan kelimeye `"symbol"` alanı ekler. Hassas bir karta görsel verilmişse ya da ad biçimi bozuksa derleme durur. Destede olmayan anahtar atlanır.
3. `ContentStore`: sütun varsa `c.symbol` okur. Sütunsuz eski bir veritabanında `NULL AS symbol` seçer, sorgu bozulmaz (`pragma_table_info` açılışta bir kez).
4. `WidgetWord.symbol` (JSON `"symbol"`, opsiyonel): plan, seed ve saat planı onu taşır. Planı yeniden kuran yardımcılar (`withShortestExample`, `addingLargeWidgetDetails`, `WatchSync.watchPlan`) korur.

Sözleşme: `docs/contract/content-db.md` (§3 `card.symbol`, §5 seed, §6 `WidgetWord`, §7 sürüm geçmişi). `schema_version` artırılmadı: uygulama onu okumaz ve değişiklik yalnız eklemedir.

## Eşleme kuralları

- **Yalnız yüksek güven.** Sembol kelimenin o kartın anlamını tek başına, tartışmasız göstermeli. Orta güvenli ya da başka anlamı çağıran eşlemeler eklenmez (ör. "bag", "fork", "idea", "weather", "sleep", "share").
- **Kart anlamına göre.** Anahtar kart kimliğidir, lemma değil: aynı lemmanın birden çok kartı olabilir ("tablet" burada `en.tablet.n.1`, hap anlamında: `pills`). Anlamı `def_micro` ve Türkçe karşılıkla kontrol et.
- **Yalnız isim ve fiil**, somut olanlar. Sıfat, zarf, deyim yok.
- **Hassas kart yok** (`sensitivity` 0 olmalı).
- **iOS 17.0'da olan adlar.** Uygulamanın en düşük sürümü iOS 17. Adı yeni adla değişmiş semboller (ör. `thermometer`) eklenmez.
- **Apple'a ayrılmış semboller yok.** SF Symbols'ta yalnız Apple'ın kendi ürün ya da hizmetini göstermek için kullanılabilen aileler (`icloud.*`, `message`, `facetime`, `applelogo`, cihaz glifleri: `iphone`, `ipad`, `applewatch`, `airpods`, `macbook` vb.) genel bir anlam için kullanılmaz. "download"/"upload" `arrow.down.circle`/`arrow.up.circle`, "text" (mesaj atmak) `text.bubble` kullanır. `tests/test_card_symbols.py` bu aileleri reddeder.
- Aynı sembol birden çok kartta olabilir (`banknote`: cash, money).

## Yeni eşleme nasıl eklenir

1. Kart kimliğini bul (`content.sqlite`'ta `card.card_id`, ya da taslak kartın `id`'si). `id_registry.json` elle düzenlenmez.
2. SF Symbols uygulamasında adı, "Availability" satırını (iOS 17.0 ya da öncesi) ve kullanım kısıtı notunu kontrol et: Apple'a ayrılmış sembol eklenmez.
3. `card_symbols.json`'a satırı alfabetik yerine ekle.
4. `content-pipeline/` içinde: `python -X utf8 -m pytest -q` (`tests/test_card_symbols.py`: kart kayıtta ve destede, ad biçimi, Apple'a ayrılmış aile değil, hassas değil, isim ya da fiil, dosya düz ve sıralı).
5. İçeriği yeniden derle (`ios/App/Resources/README.md`'deki `vocabpipe.personal` komutu, yeni `--content-version` ile).
6. macOS'ta `LockglowWidgetSnapshots/CardSymbolTests` her adın sistemde çizildiğini (`UIImage(systemName:)`) ve, sistemin `name_availability.plist`'i okunabiliyorsa, iOS 17.0'dan yeni olmadığını denetler. Dosya bulunamazsa test not düşer ve geçer. Her iki durumda da CI günlüğüne `SEMBOLSURUM` ile başlayan bir satır yazar: dosya bulundu mu, yolu ne, kaç sembol denetlendi.

## Testler

| Test | Ne denetler |
|---|---|
| `content-pipeline/tests/test_card_symbols.py` | Dosya düz, sıralı, tekrarsız, LF; her anahtar `id_registry.json`'da ve taslak destede; adlar `[a-z0-9.]+` biçiminde; hassas kart yok; yalnız `n` ve `v` |
| `tests/test_build_db.py` (sembol testleri) | Sembol `card` tablosuna ve seed'e ulaşır; görselsiz kelimede seed alanı yok; destede olmayan anahtar atlanır; hassas karta görsel ya da bozuk ad derlemeyi durdurur |
| `CoreModelsTests/WidgetWordTests` | `symbol` varken, yokken ve `null` iken çözülür; nil iken JSON'a yazılmaz; seed'de yalnız verilen kelimede; `addingLargeWidgetDetails` korur |
| `LearningTests/WidgetPlanBuilderTests` | Planın yeniden kurduğu kelime (en kısa örnek) sembolü korur |
| `SharedStateTests/WatchSyncTests` | Saat planı sembolü korur |
| `ContentStoreTests` (yalnız macOS) | Sütunsuz eski veritabanı okunur, sembol nil; sütun varsa okunur, boş ad nil; gömülü içerikte semboller var |
| `WidgetSnapshots/CardSymbolTests` (macOS) | Her ad sistemde çizilir; iOS 17.0 sınırı (günlükte `SEMBOLSURUM` satırı); büyük widget anlam açıkken görseli çizer, "Anlamı gizle"de çizmez (görüntü karşılaştırması); inceleme görüntüleri `large-symbol-listen*` |
| `WidgetSnapshots/WidgetConfigurationTests` (macOS) | Büyük widget "Anlamı gizle"de Türkçe anlamı çizmez (anlamı farklı iki kelime aynı görüntüyü verir), görüntüsü anlam açıkkinden farklıdır; "Göster"den sonra seçeneksiz widget'ın birebir aynısıdır (anlam ve görsel); StandBy'da gizlemez. İnceleme görüntüleri `large-anlam-gizli-*` (393 pt, SE, SE AX3, gece, renkli, açılmış) |
| `WidgetSnapshots/LargeWidgetSnapshotTests` (macOS) | "Anlamı gizle"de VoiceOver "Anlamını göster" düğmesini bulur, "Türkçesi: …" yoktur, İngilizce tanım kalır; "Göster"den sonra anlam gelir, düğme gider |
