# iPhone cihaz uyum planı

26 Ekim 2026. **Bu belge bir doğrulama planıdır; bütün iPhone modellerinin geçtiğini söylemez.** Üretim veya test kodu bu belgeyle değiştirilmez. Gerçek koşu sonuçları [KONTROL.md](KONTROL.md), fiziksel cihaz hazırlığı [CIHAZ-KONTROLU.md](CIHAZ-KONTROLU.md) içinde tutulur.

## Mevcut destek politikası

[ios/project.yml](../../../ios/project.yml) kaynak incelemesi şu durumu doğruluyor:

- En düşük iOS hedefi **17.0**; Swift dil modu 5.0.
- iPhone yönü **yalnız dikey**: `UISupportedInterfaceOrientations` altında `UIInterfaceOrientationPortrait` var. Bu plan iPhone'a yatay ekran desteği eklemez.
- Depoda ayrıca iPad desteği bulunuyor: `TARGETED_DEVICE_FAMILY: "1,2"`; iPad için dört yön ayrı tanımlı. Apple silicon Mac'te “Designed for iPad” ayarı da mevcut. Bu belge bu destekleri kaldırmaz veya doğrulanmış saymaz; kapsamı iPhone uyum kapısıdır.

Ekran düzeni model adına göre ayrılmayacak. Kullanılabilir genişlik/yükseklik, sistemin güvenli alanı, yazı boyutu ve içerik uzunluğu belirleyici olacak. Mevcut iPad/Mac geniş ekran düzeni [WideLayout.swift](../../../ios/App/WideLayout.swift) içinde ayrıca korunur.

Güncel ana dalın `5cd59ec` içeriği `3890b55` ile çalışma dalına birleşti. Aşağıdaki metin yakalama, kendi cümleni yazma ve B2 test kapsamı mevcut kaynak özellikleridir; bu belgeyle yeni özellik eklenmez. Bu ek hazırlanırken `14b8bd3` için [Intel CI 40353937504](https://github.com/yusufuyar68/lockglow/actions/runs/40353937504) çalışıyor; Faz 3 kapısı hâlâ açık. Sonraki üretim fazının başladığı veya bu ek özelliklerin bütün cihazlarda geçtiği sonucu çıkarılmaz.

## Apple yaklaşımı

Apple, arayüzün bulunduğu ortama uyarlanmasını ve sistemin safe area, kenar boşluğu ve yerleşim kılavuzlarına uymasını önerir. Model adına göre bir çentik yüksekliği seçmek yerine sistemin verdiği kullanılabilir alan izlenir. Kaynak: [Layout](https://developer.apple.com/design/human-interface-guidelines/layout).

Yazı hiyerarşisi sistem metin stillerinden gelir. Dynamic Type büyüdüğünde satırlar yükselebilir, yan yana öğeler alt alta geçebilir ve içerik kayabilir. Kullanıcının okumak istediği metin keyfî küçültmeyle saklanmaz. Kaynaklar: [Typography](https://developer.apple.com/design/human-interface-guidelines/typography), [Dynamic Type başlangıcı](https://developer.apple.com/videos/play/wwdc2024/10074/).

Görsel durum renk dışında simge/metinle de anlaşılmalı; odak, etiket, okuma sırası ve alternatif etkileşimler kontrol edilmeli. Kaynak: [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility). Uygulamanın dokunma hedefi ölçütü en az 44×44 pt'dir: [Apple UI tasarım ipuçları](https://developer.apple.com/design/tips/).

## Bugünkü kanıtın sınırı

| Kanıt | Gerçekte kapsadığı alan | Kapsamadığı alan |
|---|---|---|
| SE ve Pro native UI profilleri | Belirli simülatör/iOS ve test senaryolarında gerçek uygulama etkileşimi; SE normal ve Pro koyu/büyük yazı kanıtları | Bütün SE/Pro nesilleri, bütün iOS sürümleri, tüm uygulama ekranları ve fiziksel donanım |
| Faz 3 SE kabulü ve sekiz özgün PNG | Günlük seçim, bilinenler, rehber, ilk kelime, Akış, yeniden açma ve Atla'nın testte izlenen yolu; görünen alanların incelemesi | Aynı fazın Pro sonucu veya diğer ekran boyutlarının tamamı; güncel durum KONTROL kaydına eklenir |
| Faz 3 Pro'da saptanan başlangıç konumu | İlk eleme sonrasında kalan uzun kartın altından açılma bulgusu var; üst hizalama düzeltmesi `6e37e86` ile eklendi | Birleşik `14b8bd3` kabulü bekliyor; ilk açılış ve yeniden açılışta kelime başlığı ayrıca görünür olmalı |
| Hosted Akış testleri | [FeedTransferSnapshotTests.swift](../../../ios/NativeTransferSnapshots/FeedTransferSnapshotTests.swift) içinde **375 ve 390 pt genişlik, 500 pt host yüksekliği**; seçili açık/koyu, yüksek kontrast ve AX5 örnekleri | Tam telefon kabuğu, gerçek safe area, sistem klavyesi, parmak hareketinin yönlendirilmesi, bütün kart verisi |
| Aşağıdaki genişletilmiş matris | Henüz **plan** | Çalıştırılmadan başarı işareti verilmez |
| Fiziksel iPhone | Bu aktarım için kontrol listesi hazır | Display Zoom, gerçek widget yenilenmesi, ses/mikrofon ve duyulan VoiceOver sonucu bekliyor |

Ekran görüntüsü, test assertion'ı, paket testi ve fiziksel gözlem ayrı kanıt türleridir. Kaydırılmış listenin üstte kalan satırı kırpma hatası sayılmaz; içeriğin sonuna ve eylemlere gerçekten ulaşılması ayrıca ölçülür.

## 1. Önce gerçek CI envanteri

Bir sonraki uygun macOS CI işinde Xcode sürümü, kurulu runtime'lar ve kullanılabilir simülatörler salt okunur kaydedilecek:

```sh
xcodebuild -version
xcrun simctl list runtimes --json
xcrun simctl list devicetypes --json
xcrun simctl list devices available --json
```

Her seçili çalıştırmada profil adının yanında gerçek cihaz adı, UDID, runtime/iOS, kod SHA'sı, pencere `bounds`, safe area insets, yazı kategorisi ve görünüm saklanacak. `se` veya `pro-dark-ax` gibi profil adı tek başına model/sürüm kanıtı değildir.

Kısa SE, dar mini, standart ve büyük ekran grupları envanterden eşlenecek. Mini ailesinin gerçek uygulamaya verdiği mantıksal boyut ayrıca ölçülecek; piksel çözünürlüğünden bölerek viewport varsayılmayacak. Eski cihaz/runtime kurulu değilse mevcutmuş gibi seçilmeyecek.

Tanımlı bir cihaz tipi, o tipin kurulu iOS runtime'ında gerçekten çalıştırıldığı anlamına gelmez. Çalışabilir cihaz/runtime eşleri bu hazırlık kapısında seçilip kayda bağlanır; yeni model envanteri kaynak kodundaki elle yazılmış bir model listesinden üretilmez.

Eski runtime bulunamazsa ilgili **yerleşim sınırı**, kurulu runtime üzerinde hosted görünümle ölçülebilir. Bu, eksik iOS sürümünde uygulama çalıştırıldığı veya o donanımın doğrulandığı anlamına gelmez. iOS 17 hedefiyle derlenebilmek de tek başına iOS 17 çalışma zamanı testi değildir; eksik runtime/cihaz kontrolü açık kalır. Birleşik kabul için envanterde çalışabilir **en az bir iOS 26 öncesi runtime'da gerçek UI koşusu** gereklidir. Şu an 18.6 Pro koşusu sürüyor; sonucu alınmadan bu kapı geçti sayılmaz.

## 2. Temsilî viewport matrisi

Ölçüler portrait **pt** cinsindedir; cihaz model listesi veya piksel tablosu değildir. Yükseklikler hosted test için önerilen sınırlar; gerçek UI işinde envanterden ölçülen değer kullanılır.

| Temsilî viewport | Amaç | Durum |
|---|---|---|
| **320×568** | Display Zoom benzeri dar/kısa kullanılabilir alan stresi | Sentetik plan; gerçek cihazın zoom moduyla aynı olduğu veya bu boyutta bir modelin desteklendiği iddiası değil |
| **375×667** | Kısa SE koşulu; sınırlı kullanılabilir dikey alan | SE kanıtı var; genişletilmiş ekran/ayar taraması plan |
| **375×812** | Dar mini sınıfı; aynı genişlikte SE'den farklı yükseklik ve safe area | Temsilî plan; gerçek mini eşlemesi envanterden doğrulanacak |
| **390×844** | Standart genişlikte satır sarma | 390 pt hosted Akış kanıtı var; bu tam viewport taraması plan |
| **393×852** | Yakın genişlikte metin ve denetim kırılma sınırı | Plan |
| **402×874** | Daha geniş standart yüzey | Mevcut Pro profili sınırlı kanıttır; bu ölçüde tüm ekran taraması plan |
| **414×896** | Geniş yüzeyde satır ve alt çubuk düzeni | Plan |
| **420×912** | Ara genişlikte akış ve form düzeni | Plan |
| **428×926** | Büyük ekran sınırı | Plan |
| **430×932** | Yakın büyük ekran genişliğinde satır değişimi | Plan |
| **440×956** | En geniş temsilî portrait yüzey | Plan |

Aynı genişlikte farklı yükseklik ve safe area koşulları da sınanacak. Home düğmeli kısa alan, home indicator'lı alan, çentik ve Dynamic Island çevresi gerçek sistemden alınır. Hosted testte taklit edilen inset varsa **sentetik** diye etiketlenir; gerçek cihaz sonucu sayılmaz. Yeni bir model adına özel `if` veya sabit çentik/sekme yüksekliği eklemek bu planın yöntemi değildir.

## 3. Yazı, görünüm ve sistem koşulları

Tam çarpımda binlerce görüntü üretmek yerine kontroller aşamalı genişletilecek:

1. Yukarıdaki bütün viewport'larda **varsayılan (`.large`), XXXL (`.xxxLarge`), AX1 (`.accessibility1`), AX5 (`.accessibility5`)** yerleşim sınırı. Açık görünüm temel taraması; koyu görünüm en az varsayılan ve AX5 ile tekrar.
2. Kısa/dar ve en geniş sınırda açık/koyu **Yüksek Kontrast**; metin, ayraç, pasif/seçili denetim ve yeşil vurgunun ayrışması. Mevcut açık normal temadaki hafif degrade, koyu/yüksek kontrastta düz yüzey sözleşmesini korumalı.
3. Envanterde bulunan kısa, dar ve büyük temsilcilerde gerçek uygulama UI akışı. Aynı profilde yazı boyutunun gerçekten uygulanmış olduğu ölçülmeli; yalnız launch argument yazılması yeterli değil.
4. **Display Zoom:** destekleyen gerçek sistem ayarında etkili pencere ölçüleri kaydedilerek tekrar. Görüntüyü büyütmek veya yalnız host genişliğini azaltmak gerçek Display Zoom kanıtı değildir. Simülatörde sunulmayan ayar fiziksel kontrol olarak bekler.
5. **Reduce Motion:** açık/kapalı durumda aynı eylem ve sonuçlar; sayfa/geri alma durumu animasyon süresine bağlı kalmamalı. Kararlı kareler geçiş karelerinden ayrı alınmalı.
6. **VoiceOver:** otomasyonda ad/rol/seçili durum ve odak hedefleri; fiziksel cihazda duyulan İngilizce/Türkçe, sıralama, duyurular ve son denetime ulaşma.
7. **Klavye:** Türkçe arama, uzun kelime/ifade ve çok satırlı form; klavye açık/kapalı, odak değişimi ve sistem sheet'i. Alan, hata mesajı ve kaydet/kapat eylemi klavye altında kalmamalı.

Öncelik kısa ekran + AX5/klavye ve home indicator + sabit alt düğme birleşimidir. Mevcut başlık/denetim boyut sınırları kaynakta ayrıca değerlendirilir; ekranı sığdırmak için gövde metni keyfî küçültülmez. Statik telefon/widget çiziminin kendi yazı ölçeği, uygulama gövdesinin Dynamic Type uyumundan ayrı ölçülür.

### Donanım yeteneği ekran boyutundan ayrıdır

Genişlik, kamera taraması veya yapay zekâ desteğini belirlemez. Envanter kaydında iOS sürümü, kamera izni, DataScanner destek/kullanılabilirlik sonucu ve cihaz içi modelin o anda kullanılabilirliği ayrı alanlar olmalı. Bir simülatörün veya aynı genişlikte başka bir telefonun sonucu bu yetenekleri kanıtlamaz. Aşağıdaki kontroller **plan / henüz bu uyum matrisinde test edilmedi** durumundadır.

**Metinden kelime bul.** Kaynaklar: [TextHarvestView.swift](../../../ios/App/TextHarvestView.swift), [TextHarvestSources.swift](../../../ios/App/TextHarvestSources.swift).

- **Yazma/yapıştırma:** İngilizce metin alanı ve `Kelimeleri bul` klavye açıkken erişilmeli. Boş girişte ana eylem pasif kalır. Panoda metin yoksa mevcut “Panoda metin yok” notu okunmalı; iOS'un yapıştırma izin penceresi ayrıca denenmeli. Metin değişince önceki sonucun temizlenmesi, yeni paragraf ekleme ve uzun metnin ilk bölümünün alınmasına ilişkin mevcut bilgi notu kontrol edilmeli.
- **Canlı kamera:** `TextScannerSheet.canScan`, önce `DataScannerViewController.isSupported` kontrol ediyor; destek varsa `isAvailable` veya kamera izninin henüz sorulmamış olması gerekiyor. Bu koşul sağlanmazsa **Kamerayla tara düğmesi gösterilmiyor**; yazma/yapıştırma ve fotoğraf yolu kalıyor. Desteksiz/kullanılamaz cihazda var olmayan tarayıcı veya açıklama ekranı beklenmemeli.
- **İzin/tarama durumu:** İlk kullanımda kamera izni sorulur. İzin alınamazsa mevcut kamera izni notu görünmeli, giriş kaybolmamalı. Tarayıcı açıldıktan sonra `startScanning()` çalışamazsa kaynak hata paneli üretmiyor: `Yazı aranıyor` ve pasif alma eylemi kalabilir; **Vazgeç** ile çıkılabilmeli. Bu durum başarılı tarama sayılmamalı. Yazı bulunduğunda `Bu metni al` safe area içinde erişilmeli; satırlar okuma sırasıyla alana gelmeli.
- **Fotoğraf:** Sistem `PhotosPicker` yalnız seçilen fotoğrafı verir; kaynak tüm fotoğraf arşivi izni istemiyor. Seçimden vazgeçme, “Fotoğraf okunuyor”, açılamayan fotoğraf ve okunacak metin bulunamaması ayrı denenmeli. Son iki durumda mevcut kısa not görünmeli ve fotoğraf düğmesi yeniden kullanılabilir olmalı. OCR cihaz üzerinde İngilizce satırları okur; simülatör/fixture OCR sonucu gerçek kameranın doğruluğu sayılmaz.
- **Sonuçlar:** Kartlarda olanlar, kendi kelimeleri ve yeni kelimeler; uzun satır, boş sonuç ve bilinenleri gizleme durumları dar/AX/klavyeli düzenlerde incelenmeli. Yeni kelime formu Türkçe anlam alınmadan kendiliğinden kayıt üretmemeli. Kamera/fotoğraf akışı için fiziksel gözlem ayrıca bekler.

**Kendi cümleni yaz.** Kaynaklar: [OwnSentenceView.swift](../../../ios/App/OwnSentenceView.swift), [OwnSentenceAI.swift](../../../ios/App/OwnSentenceAI.swift), [OwnSentenceCheck.swift](../../../ios/Packages/VocabKit/Sources/Learning/OwnSentenceCheck.swift).

- **Her cihazdaki temel yol:** Kelime varlığı, cümle uzunluğu, Türkçe harfler, büyük harf ve son işaret için sabit kurallar hemen çalışır. Bu panel tam gramer doğrulaması değildir. Büyüyen giriş, 200 karakter sınırının notu, sonuç ve `Kontrol et`/`Kapat` klavye ve AX5'te erişilmeli. Cümle alıştırması kutu/vade/öğrenme puanı değiştirmemeli; aynı cümlenin tekrar kontrolü aynı sayfada ikinci alıştırma sayılmamalı.
- **Koşullu öneri:** Cihaz içi öneri yalnız derlemede `FoundationModels` bulunuyorsa, iOS **26+** ise ve `SystemLanguageModel.default.availability` **available** döndürüyorsa istenir. Uygulamanın iOS 17+ desteği, her telefonda Apple Intelligence bulunduğu anlamına gelmez. Ekran genişliğinden uygun cihaz sonucu çıkarılmaz.
- **Mevcut fallback:** Eski iOS/SDK, uygun olmayan cihaz, Apple Intelligence'ın kapalı olması veya modelin henüz hazır olmaması öneriyi kullanılamaz yapar. Mevcut UI bunlar için ayrı hata metni göstermiyor: **öneri paneli gizli kalıyor, temel kural sonucu kullanılabiliyor**. Cümle boş/çok kısa, hedef kelime yok veya Türkçe harf içeriyorsa da model isteği yapılmaz.
- **İstek sonrası:** Uygun durumda bekleme ve ayrı cihaz içi öneri paneli denenmeli. Hata, yanıt vermeme, ret, dil/bağlam sorunu veya 15 saniyelik zaman aşımında öneri gelmeyebilir; panel gizlenir ve kural sonucu kalır. Sonraki kontrol önceki isteği, sayfadan çıkma bekleyen isteği iptal eder; eski yanıt yeni cümlenin üstüne gelmemeli. Kaynakta uzak servise yönelen bir fallback yoktur. Gerçek model üretimi uygun fiziksel cihazda ayrıca bekler; önerinin olmadığı cihazda bu temel yolun çalışması kabulün parçasıdır.

**B2 seviye testi.** Kaynaklar: [PlacementTestView.swift](../../../ios/App/PlacementTestView.swift), [PlacementTestModel.swift](../../../ios/App/PlacementTestModel.swift), [Placement.swift](../../../ios/Packages/VocabKit/Sources/Learning/Placement.swift).

Mevcut native testin başlangıç sonuçları A1/A2/B1/B2'dir; B2, bankada en az 15 ayrı uygun B2 kelime olduğunda teste katılır. Azsa mevcut A1–B1 yolu kullanılır. Bu, donanım/AI şartı değil içerik bankası koşuludur. Veri yükleniyor, yetersiz banka ve kullanılabilir soru üretilemeyen kelime durumları ayrıca incelenmeli.

Uzun dört anlam şıkkı, `Emin değilim`, ilerleme, `Kapat` ve sonuç düğmesi dar/XXXL/AX5'te erişilmeli. B2 sonucu, açıklaması ve dört noktalı `LevelDots` çakışmamalı. Test bitmeden kapatma seçim/ilerleme değiştirmemeli; sonuç açılışta düzey taslağına, Ayarlar'da mevcut `applyPlacementResult` yoluna aktarılmalı. Test kelimeleri bilinenlere eklenmez. Açık günlük hedef korunur; hiç seçilmemiş hedefin mevcut varsayılanı A1/A2 için 5, B1/B2 için 10'dur.

## 4. Ekranlara göre kabul ölçütleri

| Alan | Kabul ölçütü |
|---|---|
| **Açılış** | Seviye → konular → günlük → bilinenler → widget → ilk kelime sırası korunur. 5/10/15/20 satırları, Geri/Atla/Devam/Başla erişilir. Düzey varsayılanı ile açık hedef seçimi ayrılır; geri/yeniden açma eski seçimi korur. Bilinenlerin seçimi renk dışında işaretle anlaşılır; kaydetme hatasında sayfa ve seçimler kalır. Boş isteğe bağlı adım ana öğrenmeyi kilitlemez. |
| **Seviye testi / B2** | Intro, soru, Emin değilim ve sonuç dar/AX ölçülerinde okunur. B2 banka koşulu ve dört noktalı işaret; sonuç sonrası düzey/hedef uyumu sınanır. Testteki cevaplar kalıcı bilinen kelime veya öğrenme cevabı sayılmaz. |
| **Akış** | İlk açılışta, başlangıç elemesi sonrasında ve yeniden açılışta ilk kalan kartın **kelime başlığı üstte görünür** olmalı; uzun kartın altından açılmamalı. Kelime → Türkçe → tanım birlikte okunur; meta ve ses grubu sonra, Biliyorum ayrı karar olarak kalır. Örnek ve Türkçesi kartta bulunur. Uzun içerik sonuna kaydırılır; ardından normal hareketle sonraki karta geçilir. AX doğal akışı, Neden?/Kapat ve geri dönen odak çalışır. Normal Biliyorum mevcut kartı kaçırmaz; başlangıç elemesi ayrı davranır. |
| **Tekrar** | Tanış/çevirme, Hatırla, **Yaz**, **Dinle ve seç**, uzun cevap şıkları, doğru/yanlış/sonuç ve tur sonu düğmeleri çakışmaz. Yaz yolunda klavye, Dinle ve seç yolunda tekrar dinleme erişilir. Bütün şık metni ve son eylem okunur/erişilir. Görünüm değişimi ikinci cevap kaydı üretmez; native Leitner/FSRS, sayaç ve vade sözleşmesi korunur. |
| **Sözlük** | Arama alanı, Türkçe giriş, sonuç/boş durum, filtre ve uzun kelime detayında yatay kayma gerekmez. Klavye ve sekme çubuğu son sonucu/eylemi erişilmez yapmaz. Sheet kapatılıp aynı arama bağlamına dönülür. |
| **Metinden kelime bul** | Giriş, kaynak düğmeleri, sistem izin/seçim penceresi, OCR notları ve üç sonuç grubu klavye/AX düzeninde erişilir. Kamera destek/kullanılabilirlik koşulu ekran boyutundan ayrı sınanır; kamera yokken yazma/yapıştırma/fotoğraf yolları kalır. |
| **Kendi cümleni yaz** | Klavye üzerindeki Kontrol et ve Kapat erişilir; kural sonucu her uygun iOS yolunda kalır. AI bekleme/öneri ve gizli fallback durumları ayrı sınanır; model desteği olmayan cihazda temel alıştırma engellenmez. |
| **Ayarlar** | Uzun satır adı/değeri ve seçili günlük hedef kesilmez; büyüyen denetimler gerekirse alt alta geçer. Seviye/konu/hedef değişimi ve Yardım'dan açılışı yeniden açma erişilir. Yazı/görünüm değişimi kayıtlı tercihi değiştirmez. |
| **Veriler** | Yedek paylaşma, içe aktarma önizlemesi ve hata/sonuç metni büyük yazıda okunur; iptal/onay düğmeleri erişilir. Geçici test verisinde archive round-trip alanları korur; kişisel ilerlemeyi silerek uyum testi yapılmaz. Sistem dosya/paylaşım penceresi ayrıca kontrol edilir. |
| **Söyle / ses** | Uzun kelime, Dinle, mikrofon durumu, izin/model bekleme/hata, sonuç ve Kapat aynı sayfada ulaşılabilir kalır. Sheet'in küçük/büyük hâli denenir. Gerçek mikrofon, cihaz içi model, ses kesintisi ve arka plan sesi fiziksel cihazda ayrıca bekler. |
| **Sheet / uyarı / form** | Mevcut orta/büyük sunumlar, uzun içerik ve klavyede Kapat/Vazgeç/onay erişilir. Arka plan düğmesi yanlışlıkla etkinleşmez; kapanışta odak ve bağlam geri gelir. Safe area ve home indicator eylemi örtmez. |
| **Widget ve sistem yüzeyleri** | Kelime widget'ının küçük/orta/**büyük** ve kilit ekranı aileleri, **quiz**, **ilerleme**, **Live Activity / Dynamic Island** ve **iOS 18+ denetimleri** ayrı rotalardır. Kendi gerçek WidgetKit boyutlarında kısa/uzun kelime, Türkçe anlam ve açık/koyu/tint görünümü incelenir. Mevcut içerik basamakları ve ailede gerçekten sunulan eylemler korunur; hassas içerik dışarı çıkmaz. Rehberdeki çizim gerçek widget kanıtı değildir. Sistem ailesi ve marjları model adına göre kopyalanmaz. Yenilenme için kesin dakika sözü verilmez. |

Genel Ayarlar/form kontrolüne ek olarak şu mevcut rotalar ayrı sonuç satırları alır; hepsi bu genişletilmiş matriste **plan** durumundadır:

| Rota | Ayrı sınanacak durumlar |
|---|---|
| Kendi kelimelerin | Liste, boş durum, ekle/düzenle, uzun kelime/anlam ve klavye; kaydet/iptal ve silme onayı. |
| Kulak alıştırması | Dinleme, şıklar, yanlış/doğru ve bitiş; ses kullanılamazken çıkış ve tekrar deneme. |
| Cümle kur | Uzun parçalar/şıklar, cevap, açıklama ve tur özeti; son eylem alt çubuğun üstünde erişilir. |
| Kitaplığın / Yol haritası | Uzun liste, boş içerik, seçim ve detaydan dönüş; AX yazıda son satıra ulaşma. |
| Haftalık özet | Veri var/yok, uzun sayı ve etiketler; bilgi yalnız renkle aktarılmaz. |
| Ses ve aksan | Ses listesi, önizleme, seçili aksan ve kullanılamayan ses; kaydırma seçimi değiştirmez. |
| Zamanlama | Saat/pencere, uzun açıklama ve sistem izin durumu; dar alanda onay/iptal erişilir. |
| Eşitleme | Mevcut destek/hesap durumu, kapalı/hata/bekleme ve veri çakışması bilgisi; gerçek iCloud sonucu fiziksel/hesaplı kontrol bekler. |

Söyle için [PronunciationRecognizer.swift](../../../ios/App/PronunciationRecognizer.swift) iki farklı yolu kullanır: iOS **17–25** cihazda bulunan İngilizce `SFSpeechRecognizer`, iOS **26+** indirilebilir `SpeechAnalyzer` modeli. Her iki yolda izin verilmemesi, desteklenmeyen cihaz/model, modelin bulunmaması/indirilememesi ve Vazgeç/Kapat ayrı denenir. 26 öncesi UI koşusu bu eski yolu ekranda kontrol eder; gerçek ses tanıma, izin sonrası cihaz modeli ve duyulan sonuç fiziksel cihazda ayrıca bekler.

Ortak ölçüt: eylemler safe area içinde erişilebilir, metin/denetimler üst üste binmeden okunur olmalı. Bir ekran görüntüsünde alt satır görünmemesi tek başına hata değildir; kalıcı kesilme, ulaşılamayan son satır/eylem veya yanlış kaydırma yönlendirmesi hatadır. Yükleniyor/boş/hata durumları da normal içerik kadar denenir.

## 5. Mevcut fazlara bağlama

Bu matris [FAZLAR.md](FAZLAR.md) içindeki aktarım kapılarını genişletir; geçmiş bir fazın dar kapsamlı başarısını tüm cihaz onayı olarak yeniden adlandırmaz.

| Mevcut faz | Eklenecek cihaz uyum kontrolü |
|---|---|
| **Uyum hazırlığı — envanter** | Kurulu Xcode/runtime/cihaz tipleri ve kullanılabilir cihaz eşleri çıkarılır; kısa SE, mini/dar, standart ve büyük temsilciler ölçülür. Eksik runtime/model açıkça işaretlenir. Bu hazırlık üretim özelliği değildir. |
| **Faz 1 — A kartı** | Tüm temsilî genişliklerde kısa/uzun Akış, dört yazı kategorisi; kısa/dar gerçek UI'da okuma sonundan sonraki karta geçiş. Mevcut 375/390 hosted ve SE/Pro kanıtı başlangıç noktasıdır. |
| **Faz 2 — Öğrenme eşdeğerliği** | Mevcut gerçek AppModel ve paket testleri korunur. Yeni ölçü/görünüm, Biliyorum/geri alma veya cevap kaydını değiştirmemeli; yerleşim testi algoritma kanıtı yerine geçmez. |
| **Faz 3 — Açılış** | Altı adımın dar/kısa ve AX5 turu; varsayılan/açık hedef, isteğe bağlı sıfır seçim, geri düzenleme, yeniden açma ve kayıt hatasında açık kalma. B2 düzey/test sonucu ve açık günlük hedefin korunması eklenir. İlk başlangıç/eleme/yeniden açılış sonrası ilk kalan kartın başlığı görünür olmalı. Her profilin kendi sonucu ve özgün görüntüsü saklanır. |
| **Faz 4 — Widget, ses, veri** | Widget ailesi/uzun metin ve hassasiyet, Söyle/izin sheet'i, Veriler ve archive round-trip; ayrıca mevcut kamera/OCR ve cihaz içi önerinin yetenek/fallback yolları. Bunlar uyum denetimi planıdır; fazın üretim uygulamasına geçildiği anlamına gelmez. Cihaz bağımlı sonuçlar fiziksel listede bekler. |
| **Faz 5 — Birleşik kabul** | Açılış/Akış/Tekrar/Sözlük/Ayarlar/Veriler/Söyle, Metinden kelime bul ve Kendi cümleni yaz geçişleri; envanterdeki temsilcilerde gerçek UI, genişlik matrisinde hosted geometri, görsel inceleme ve fiziksel kayıtlar birlikte raporlanır. Geometri ile donanım yeteneği sonuçları ayrı, eksik profiller açıkça listelenir. |

## Sonuç nasıl kaydedilecek?

Her kontrol için **plan / çalışmadı / geçti / başarısız / fiziksel kontrol bekliyor** durumu; SHA, koşu bağlantısı, gerçek runtime/viewport, yazı kategorisi, görünüm ve ilgili PNG/log birlikte tutulur. Başarısız/başlayamayan UI işi geçti sayılmaz. Hosted ölçüm gerçek cihaz, AX ağacı duyulan VoiceOver, simülatör sesi gerçek mikrofon sonucu yerine geçmez.

Bu planın tamamlanma ifadesi “listelenen temsilî sınırlar ve mevcut runtime'larda kontroller geçti” olabilir. “Bütün iPhone modelleri doğrulandı” ifadesi bu kanıttan çıkarılmaz. Bu belge yeni TestFlight yüklemesi veya fiziksel testin tamamlandığı anlamına gelmez.
