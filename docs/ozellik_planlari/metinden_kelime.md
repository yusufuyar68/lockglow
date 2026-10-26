# Metinden kelime bul (2026-10-26)

Kullanıcı okuduğu İngilizce bir metni getirir. Lockglow metindeki kelimeleri üç gruba ayırır: kartlarda olanlar, kullanıcının kendi kelimeleri ve yeni kelimeler. Yeni bir kelimeye dokununca "Kelime ekle" formu açılır; Türkçe anlamı kullanıcı yazar. Toplu ve sessiz ekleme yok.

Kaynak: `docs/magaza/rakip_eksik_analizi.md` ("Okuduğun metinden kelime ekleme" satırı ve paylaşım menüsü, kamera önerisi), `kendi_kelime.md` (yeni kelimeler oraya eklenir), `docs/tasarim/ogrenme_ilkeleri.md` madde 11 ve 12 (sakin, puansız).

> **Durum:** dal `rakip-ozellikler`. Linux'ta derlenmesi ve testleri, macOS'ta uygulamanın derlenmesi ve ekran görüntüleri henüz koşmadı. Cihazda denenmedi.

## Nereden açılır

- **Sözlük:** arama alanı boşken başlangıç sayfasında "Metinden kelime bul" satırı (son aramaların altında, konuların üstünde). Sayfa Sözlük'ün yığınına itilir.
- **Ayarlar > İlerleme:** "Kendi kelimelerin" satırının altında "Metinden kelime bul".
- **Siri ve Kestirmeler:** "Metinden kelime bul" eylemi (`FindWordsInTextIntent`). "Metin" alanı doluysa sayfa o metinle açılır; kullanıcı "Kelimeleri bul"a dokunur. Kestirmeler'de "Paylaşım Sayfası'nda göster" açık bir kestirme, Safari'de seçilen metni bu eyleme verebilir. Ayrı bir Paylaşım uzantısı (Share Extension) yok.

## Ekran (`ios/App/TextHarvestView.swift`)

- **Başlık:** "Metinden kelime bul", satır içi başlık (büyük başlık iPhone SE'nin genişliğine sığmıyor).
- **Metin alanı:** İngilizce metin serif yazıyla. ASCII klavye, otomatik düzeltme kapalı (kullanıcının bilmediği kelimeyi "düzeltmesin").
- **Kaynaklar** (kapsül düğmeler, büyük yazıda satır kayar):
  - "Yapıştır": diğerleri gibi kapsül düğme, panodaki metni alır (`UIPasteboard`). iOS ilk seferde "Yapıştırmaya izin ver" diye sorar. Panoda metin yoksa: "Panoda metin yok. Önce bir metni kopyala." Sistemin `PasteButton`'u kullanılmadı: rengi tint'ten gelir, koyu modda beyaz üstüne beyaz olur ve kapsül düğmelere benzemez.
  - "Kamerayla tara": VisionKit `DataScannerViewController`, yalnız İngilizce (`en-US`), satırlar işaretli. Yalnız `isSupported` ve kamera izni varsa (ya da henüz sorulmadıysa) görünür. Simülatörde görünmez. "Bu metni al" ekrandaki satırları yukarıdan aşağı alır.
  - "Fotoğraftan al": `PhotosPicker` ve Vision `VNRecognizeTextRequest` (`en-US`, cihaz içinde). Fotoğraf seçici uygulamanın dışında çalışır; fotoğraf izni gerekmez.
  - "Temizle": metin varken.
  - Gelen metin alandakinin altına eklenir. Alan en çok 20.000 karakter tutar.
- **Ana düğme:** "Kelimeleri bul", altta, klavyenin üstünde durur. Metin boşken pasif.
- **Sonuç:**
  - "Kartlarda var": Sözlük'ün satırları (Türkçe anlam, durum). Metin kelimeyi başka biçimde yazdıysa altında "Metinde: went". Dokununca kelime sayfası (`WordDetailView`) açılır.
  - "Kendi kelimelerin": aynı satırlar.
  - "Yeni kelimeler": İngilizce kelime ve artı işareti. Dokununca `CustomWordEditor(mode: .add(lemma:))`. Kelime eklenince liste hemen yenilenir: kelime "Kendi kelimelerin"e geçer.
  - "Bildiklerimi gizle": metinde bilinen kelime varsa görünür. Gizlenen sayı bir satırda yazar. Seçim telefonda hatırlanır (`lockglow.textHarvest.hidesKnown`).
  - Boş durumlar: metinde İngilizce kelime yoksa "İngilizce kelime yok"; yalnız küçük kelimeler ve adlar varsa "Gösterecek kelime yok".
  - Metin sınırı aştıysa: "Metin uzun; yalnız ilk bölümüne baktık."
- **Alt satır:** "Metin ve fotoğraf telefondan çıkmaz."
- **Durum rozeti:** uygulamanın her yerdeki adları ve simgeleri (`SozlukStatus`): "Öğreniyorsun", "Bildiğin kelime". Yeni kelimede rozet yok (Sözlük kuralı: çoğu kelime yeni, her satırda rozet bir şey söylemez).
- Puan, yüzde, "kaç kelime biliyorsun" yok. VoiceOver bulunanları sayılarla bir kez söyler.

## Kurallar (`Learning/TextHarvest.swift`, saf, Linux'ta test edilir)

- **Okuma:** en çok 20.000 karakter (`inputLimit`) ve 300 farklı kelime (`wordLimit`). Daha fazlası kesilir, `wasCut` doğru olur.
- **Kelime:** harfler; iki harf arasındaki `'` ve `-` kelimenin içindedir ("o'clock", "well-known"). Kıvrık kesme işaretleri düz sayılır. Küçük harfe çevrilir. Sayılar, sayıya yapışık kelimeler ("3rd", "mp3"), bağlantılar, e-posta ve alan adları atlanır. a–z dışında harf taşıyan kelime (Türkçe, başka alfabe) kelime sayılmaz. Tek harf sayılmaz.
- **Ekler:** "n't" biçimleri ("don't") kelime değildir. "'s", "'m", "'re", "'ve", "'ll", "'d" düşer ("mother's" → "mother").
- **Eşleşme sırası:** önce kullanıcının kendi kelimesi, sonra kart. Önce yazıldığı gibi, sonra tahmin edilen kök:
  - düzensiz biçimler tablosu ("went" → "go", "children" → "child", "better" → "good");
  - çoğul ve -s ("boxes" → "box", "studies" → "study");
  - -ing ("running" → "run", "making" → "make");
  - -ed ("stopped" → "stop", "tried" → "try", "liked" → "like");
  - -er ve -est ("bigger" → "big", "happiest" → "happy"); yalnız sıfat ya da zarf kartında (`pos` "adj"/"adv"). "teacher" ve "driver" fiil kartı "teach" ve "drive" sayılmaz; kendi kelimelerinde tür yok, onlarda bu tahmin yapılmaz.
  Yanlış tahmin çoğunlukla zararsızdır: yalnız bir kart ya da metindeki başka bir kelime o köke sahipse sayılır.
- **Kalıplar** (phrasal verb, deyim): 2–7 kelime yan yana, ilk kelime çekimli olabilir ("woke up" → "wake up", "looking forward to"). "my/his/her…" kartın "your"u yerine geçer ("changed her mind" → "change your mind"). "be" ile başlayan kalıp "I'm", "you're", "she's"ten sonra da bulunur ("I'm fed up with"). Noktalama, sayı ya da bağlantı kalıbı böler. En uzun kalıp kazanır. İki kalıp üst üste binerse bir kelime iki kez kullanılmaz: kartın yazdığı gibi geçen kalır ("We went on foot": "on foot", "go on" değil); ikisi de öyleyse ya da ikisi de değilse önce gelen. Bir kalıbın içindeki kelimeler ayrıca listelenmez. `CoreModels/LemmaMatch` kullanılmadı: her kartın kalıbını metnin üstünde düzenli ifadeyle aramak gerekirdi; burada metnin her yerinde aday anahtar sözlükte aranıyor.
- **Ayrılabilen kalıplar** ("picked it up") bulunmaz; "picked" yeni kelime olarak çıkar.
- **Yeni kelimeler:** küçük işlev kelimeleri (`stopwords`: the, and, would…) çıkmaz. Bunlardan biri kartlardaysa ("have", "only") "Kartlarda var"da görünür. Olası adlar çıkmaz: yalnız cümle ortasında büyük harfle yazılan, hiç küçük harfle ya da cümle başında görülmeyen kelime ("Mehmet", "London"). Başlık satırı ("Scientists Discover New Planet") ve tamamı büyük harfle yazılan kelime ("the NEW PARK") ad kanıtı sayılmaz; yalnız büyük harfle görülen kısaltma ("BBC") bu yüzden yeni kelime olarak çıkar. Bir kelimenin iki biçimi de yeniyse kökte birleşir ("cats" ve "cat" → "cat"); -er/-est ile birleşmez ("teach" ve "teacher" ayrı kalır). En çok 28 harf ve form kuralına uyan kelime (`CustomWordText.isSpeakable`).
- **Kartlar:** yalnız yüklü ücretsiz kartlar (`AppModel.card(lemma:)`, `wordsByLemma`). Kilitli kartlar "Yeni kelimeler"de çıkar.

## Kısayol ve yönlendirme

- `ShortcutRoute.findWords(text:)`. `ShortcutRoute.findingWords(in:)` metni kırpar ve 20.000 karakterde keser.
- `ShortcutRouter.textHarvest` (`TextHarvestRequest`) sayfayı bir sheet'te, kendi `NavigationStack`'iyle ve "Kapat" ile açar. Ekleme formu ya da başka bir sheet açıkken bekler; uygulama arka plana geçince bekleyen istek düşer (diğer yollar gibi).
- İfadeler: kodda İngilizce, `tr.lproj` ve `en.lproj` `AppShortcuts.strings` içinde aynı anahtarlar. Her ifadede uygulama adı var.

## Gizlilik

- `NSCameraUsageDescription` eklendi (`ios/project.yml`): "Kamera yalnız İngilizce yazıyı okumak için kullanılır (Kamerayla tara). Görüntü kaydedilmez, telefondan çıkmaz."
- Fotoğraf seçici izin istemez. Vision ve VisionKit metni cihazda tanır. Metin, fotoğraf ve sonuç hiçbir yere yazılmaz; sayfa kapanınca gider.
- Gizlilik manifestinde yeni "required reason" API yok.
- `docs/legal/gizlilik_politikasi_tr.md` §3.6 kamerayı "toplanmayan" diye sayıyor; bu doğru kalıyor. Kamera ve seçilen fotoğrafın yalnız bu özellikte, cihaz içinde kullanıldığını söyleyen bir cümle eklenmeli (hukuk metni, ayrı iş).

## Testler

- `Tests/LearningTests/TextHarvestTests.swift`: çekim tablosu, yazıldığı gibi önce, kalıplar (çekimli ilk kelime, "be" kısaltması, iyelik, en uzun kalıp, noktalama), üst üste binen kalıplar, -er yalnız sıfat/zarf kartında, kendi kelimesi önce, durum, adlar, başlık satırı ve büyük harfle vurgu, tekrar ve sıra, sayı/bağlantı, Türkçe ve anlamsız girdi, boş metin, iki sınır, fotoğraf satırlarının birleşmesi.
- `Tests/LearningTests/ShortcutLogicTests.swift`: yeni yol, kırpma ve 20.000 sınırı.
- `ios/UITests/TextHarvestScreenshotTests.swift`: Sözlük > Metinden kelime bul, paragraf, sonuç, yeni kelimeler, ekleme formu (`18a`–`18f`). "Mehmet" ve "Saturday" yeni kelime olarak çıkmamalı.
- `ios/UITests/SchedulerFSRSScreenshotTests.swift`: FSRS açıkken Ayarlar, İlerleme ve "Nasıl öğrenirim?" (`19a`–`19f`).

## Cihazda denenecekler

1. Safari'de bir haber paragrafını kopyala, Sözlük > Metinden kelime bul > "Yapıştır" > "Kelimeleri bul". Kartlardaki kelimeler anlamlarıyla, yeni kelimeler altta.
2. Yeni bir kelimeye dokun, Türkçe anlam yaz, ekle: kelime "Kendi kelimelerin"e geçer; widget'ta ve Tekrar'da gelir.
3. "Kamerayla tara": ilk dokunuşta izin sorusu Türkçe metinle çıkar. Bir kitap sayfası: satırlar işaretlenir, "Bu metni al" alanı doldurur.
4. "Fotoğraftan al": ekran görüntüsü ve yan çekilmiş bir fotoğraf; metin doğru sırayla gelir.
5. Kestirmeler'de "Metinden kelime bul" eylemiyle Paylaşım Sayfası'nda görünen bir kestirme kur; Safari'de seçili metni paylaş: sayfa metinle açılır.
6. iPhone SE ve AX5: kaynak düğmeleri satır kayar, "Kelimeleri bul" klavyenin üstünde, hiçbir metin "…" ile kesilmez. Koyu mod.
7. VoiceOver: yeni kelime satırında İngilizce kelime İngilizce sesle, ipucu Türkçe sesle.
