# Kendi cümleni yaz (2026-10-26)

Öğrenci bir kelimeyle kendi İngilizce cümlesini yazar, "Kontrol et"e dokunur ve kısa, sakin bir Türkçe geri bildirim alır. Önce sabit kurallar hemen cevap verir. Telefonda Apple Intelligence varsa altına ikinci bir kutu gelir: "Öneri · cihazda".

Kaynak: `docs/magaza/rakip_eksik_analizi.md` (rakiplerde "cümle kur, yapay zekâ kontrol etsin" var, bizde yoktu).

> **Durum:** dal `rakip-ozellikler`. Linux'ta Swift testleri, macOS'ta derleme ve ekran görüntüleri henüz koşmadı. Cihazda (Apple Intelligence açık bir iPhone'da) denenmedi.

## Nereden açılır

| Yer | Düğme | Not |
|---|---|---|
| Sözlük kelime sayfası (`WordDetailView`) | "Cümle yaz" kapsülü (kalem simgesi), "Dinle" ve "Söyle"nin yanında | Anlam bu sayfada zaten görünüyor; ipucu sorunu yok |
| Cümle kur özeti (`SentencePracticeView`) | "Kendi cümleni yaz" (çerçeveli ikincil düğme; "Tamam"dan ayrı görünsün diye), "Bir tur daha" ile "Tamam" arasında | Turdaki kelimelerden biri (`seed` ile her tur başka). Bu kelimeler `SentencePractice.wordIDs`'ten gelir: Tekrar'da yakında sorulacak kelime hiç gelmez |

Sayfa tam boy bir sheet (`OwnSentenceView`); başlığı "Kendi cümleni yaz", solda "Kapat".

## Sayfa

1. Kelime (serif, kalın) ve Türkçe anlamı, altında "Bu kelimeyle İngilizce bir cümle yaz."
2. Çok satırlı yazı alanı: serif, ASCII klavye (Türkçe harf yok), otomatik düzeltme kapalı (öğrencinin kendi yazımı kontrol edilir), cümle başı büyük harf açık. En çok 200 harf. Return "Kontrol et" ile aynı işi yapar.
3. "Kontrol et": altta, klavyenin üstünde de görünen ana düğme.
4. Kural kutusu: hüküm simge, kelime ve renkle birlikte (kural 4; Söyle'nin sonuç kutusu gibi). İyi ise yeşil "Kelimeyi kullandın"; not varsa turuncu "Bir not var" / "Birkaç not var" ve her not ayrı bir kutuda (başlık + ne yapmalı).
5. Öneri kutusu (yalnız model varken): beklerken küçük bir dönen gösterge ve "Öneri hazırlanıyor"; sonra türün Türkçe satırı, varsa "Düzeltilmiş hâli" ve "Daha doğal" İngilizce cümleleri (serif, seçilebilir, VoiceOver İngilizce sesle okur) ve "Öneriyi telefondaki yapay zekâ yazar. Yanılabilir." Renk nötr: öneri bir hüküm değil.
6. Altta: "Cümlen telefondan çıkmaz."

Dokunsal geri bildirim Söyle gibi: iyi cümlede `.success`, notta `.warning`, asla `.error`. VoiceOver hükmü ve notların başlıklarını duyurur; öneri gelince "Öneri: …" diye bir kez daha. Duyuru yarım saniye sonra gider (klavye inince; Söyle gibi) ve yalnız o kontrol hâlâ sonuncuysa.

## Kurallar (`OwnSentenceCheck`, saf, Linux'ta test edilir)

Sıra sabit:

| Not | Ne zaman | Başlık / mesaj |
|---|---|---|
| `empty` | Hiç kelime yok | "Cümle yok" / "Bu kelimeyle İngilizce bir cümle yaz." (tek not; üst satır "Yazınca Kontrol et'e dokun.") |
| `tooShort` | 3 kelimeden az | "Cümle çok kısa" / "En az üç kelimelik bir cümle yaz." |
| `missingWord` | Kelime yok | "Kelime cümlede yok" / "Yukarıdaki kelimeyi cümlende kullan." |
| `turkishLetters` | ç ğ ı ö ş ü (büyükleri de) | "Türkçe harf var" / "Cümlede ç, ğ, ı, İ, ö, ş ya da ü var. Cümleyi İngilizce harflerle yaz." |
| `noCapital` | İlk harf küçük | "Büyük harfle başla" / "İngilizce cümle büyük harfle başlar." |
| `noEndPunctuation` | Sonda . ! ? … yok (kapanan tırnak ve parantez sayılmaz) | "Sonuna nokta koy" / "Cümlenin sonuna nokta, soru işareti ya da ünlem koy." |

- Çok kısa cümlede büyük harf ve nokta notu verilmez: bir iki kelime henüz cümle değil.
- Kelime bulma: `LemmaMatch` (her ek: borrow → borrowed, look forward to → looking forward to; "be" ile başlayan kalıp onsuz da), `TextHarvest.irregularForms` (forgot → forget, teeth → tooth, gave up → give up) ve ayrılabilen kalıp: ilk kelimeden sonra en çok 3 kelime arayla gerisi (ask her out, pick it up). Kalıptaki yer tutucular uygun kelimeyi kabul eder: "your" → my/his/her…, "yourself" → myself/himself…, "someone"/"something" → herhangi bir kelime ("change your mind" → "I changed my mind", "give someone a hand" → "She gave me a hand"). Yalnız kalıp içinde: tek başına "something" yine kendisi aranır. Klavyenin akıllı tırnakları (’ “ ”) düz tırnağa çevrilir.
- Bilinen gevşeklik: ek kuralı her eki kabul ettiği için kısa kelimeler yanlışlıkla bulunabilir ("go" → "good"). Kontrol nazik olsun diye bu kabul edildi; tersi (yanlış "kelime yok") daha kötü.

## Öneri (`OwnSentenceAdvice` saf; `App/OwnSentenceAI.swift` modele bağlanır)

- Model: Apple'ın cihaz içi dil modeli (FoundationModels, iOS 26). Yalnız `SystemLanguageModel.default.availability` `.available` iken çalışır. Değilse (eski iPhone ya da iOS, Apple Intelligence kapalı, model iniyor, eski SDK) öneri kutusu hiç çıkmaz; kurallar her zaman çalışır.
- Model yalnız kurallar "boş, kısa, kelime yok, Türkçe harf" demediğinde sorulur: önce İngilizce ve kelimeli bir cümle gerekir.
- Talimat (İngilizce, kısa): A2 seviyesinde Türk öğrenciye sabırlı İngilizce öğretmeni; yalnız şunlara bak: kelime verilen anlamda mı kullanılmış, dilbilgisi, kelimenin biçimi, yazım; içeriğin doğru, kibar ya da ilginç olup olmadığına bakma; öğrencinin fikrini ve kelimeyi koru, yeni içerik ekleme; büyük harf ve noktayı yok say; yalnız İngilizce yaz. İstemde kelime, sözcük türü, kartın Türkçe anlamı ve İngilizce kısa tanımı var, böylece model hangi anlamın kastedildiğini bilir.
- Çıktı yönlendirilmiş üretimle (`@Generable`) gelir: `kind` (fine, wordMeaning, grammar, wordForm, spelling, unnatural), `correctedSentence`, `naturalAlternative` (boş olabilir).
- Türkçe metinler sabit ve temkinli ("olabilir"); modelin Türkçe yazdığı hiçbir şey gösterilmez. "Yanlış" ya da "hata" denmez. Örnek: wordMeaning → "Anlam farklı olabilir" / "Kelimeyi burada başka bir anlamda kullanmış olabilirsin. Yukarıdaki anlama bir daha bak."; grammar → "Cümlenin dilbilgisine bir daha bak."
- Temizlik: yalnız büyük harf ya da noktalamayı değiştiren "düzeltme" atılır (kurallar onu zaten söylüyor) ve tür grammar/wordForm/spelling ise "fine" olur (bakacak bir şey olmayan bir "hata" notu gösterilmez); kelimeyi içermeyen düzeltme ya da alternatif atılır (öğrencinin cümlesi değil artık; "The sentence is correct." gibi); "fine" düzeltme taşımaz; düzeltmeyi tekrarlayan "daha doğal" atılır; yazdırılabilir ASCII dışı karakter (Türkçe, başka alfabe, kontrol karakteri), 200 harften uzun, iki kelimeden kısa ya da "None", "N/A" gibi yanıtlar atılır. Tırnak, tire ve üç nokta düzleştirilir.
- Hata yolu: her hata (guardrail, bağlam penceresi, desteklenmeyen dil, iptal, model hazır değil) sessizce "öneri yok" demektir. 15 saniyede cevap gelmezse de öneri yok: sayfa asla sonsuza kadar dönmez. Yeni bir kontrol eskisinin isteğini iptal eder; sayfa kapanınca da istek iptal edilir (`withTaskCancellationHandler` modele giden görevi iptal eder; model iptali duymazsa 15 saniyelik sınır yine biter).

## Öğrenme ilkeleri

- Yalnız pratik (`ogrenme_ilkeleri.md` §3): `recordReview` çağrılmaz; kutu, vade, puan, seri, yıldız yok. Tek kayıt Cümle kur'un pratik sayacı: sayfada kelimeyi içeren her yeni İngilizce cümle bir kez sayılır (`AppModel.countSentencePractice`; aynı cümleye ikinci dokunuş sayılmaz; boş alan, bir iki kelime, kelimesiz ya da Türkçe harfli cümle sayılmaz). Sayaç "Bugün: N cümle" satırını besler; "cümle çalıştın" anlamına uyar.
- Hiçbir şeyi engellemez: geri sayım yok, "Kapat" her zaman var, not ne olursa olsun sayfa açık kalır.
- Ton sakin: "yanlış" denmez, "not" denir; öneri "Öneri · cihazda" diye açıkça öneri olarak etiketlenir ve yanılabileceği yazar (rakip yorumlarında yapay zekâ içeriğine güvensizlik: `raporlar/02_review_mining.md`).

## Gizlilik

- Cümle telefondan çıkmaz: model cihazın içinde çalışır, ağ isteği yok. Cümle hiçbir yere kaydedilmez; sayfa kapanınca gider.
- `ios/App/PrivacyInfo.xcprivacy` değişmedi ve değişmesi gerekmiyor: toplanan veri yok (`NSPrivacyCollectedDataTypes` boş), izleme yok, yeni bir "required reason" API'si kullanılmıyor. Sayaç zaten bildirilen `UserDefaults`'a (CA92.1) yazılır. FoundationModels için Info.plist anahtarı ya da izin penceresi yok.

## Derleme

- `OwnSentenceCheck.swift` `Learning` paketinde (yalnız Foundation + CoreModels), Linux'ta derlenir ve test edilir.
- `App/OwnSentenceAI.swift` yalnız uygulama hedefinde; `APP_LOGIC_FILES`'ta değil. Bütün model kodu `#if canImport(FoundationModels)` ve `@available(iOS 26.0, *)` içinde; dağıtım hedefi iOS 17. Eski bir Xcode'da (FoundationModels yok) dosya yalnız `OwnSentenceAssistant`'ı derler ve öneri hiç çıkmaz.
- iOS 17-25'te çerçeve yüklenmez: kullanılan bütün sembolleri iOS 26'dan olduğu için bağlayıcı FoundationModels'i zayıf bağlar. Bu, macOS derlemesinde ve iOS 17 cihazda ilk açılışta doğrulanmalı (bkz. riskler).

## Nasıl test edildi

- `ios/Packages/VocabKit/Tests/LearningTests/OwnSentenceCheckTests.swift` (Linux CI işi `swift-linux`): kural sırası, boş/kısa cümle, büyük harf ve nokta, kelime yok, Türkçe harf, ekler ve kalıplar, düzensiz biçimler, ayrılabilen kalıp (ve fazla uzak olanın bulunmadığı), akıllı tırnaklar, sayıyla başlayan cümle, 200 harf sınırı, metinlerin kısalığı; kalıptaki yer tutucular (your, yourself, someone); öneride her türün ayrı Türkçe metni, yalnız büyük harf/nokta değiştiren düzeltmenin atılması ve türün "fine" olması, kelimesiz önerinin atılması, gerçek düzeltmenin kalması, "fine"ın düzeltme taşımaması, tekrar eden alternatifin atılması, Türkçe/başka alfabe/kontrol karakteri/uzun/"None"/"N/A"/tek kelime yanıtların atılması, tırnak ve tirelerin düzleşmesi.
- `ios/UITests/OwnSentenceScreenshotTests.swift` (`screenshots.yml`): Sözlük → "umbrella" → "Cümle yaz".
  - `21a-kendi-cumlen-notlar`: "i forgot my umbrella at home" → turuncu hüküm, nokta notu; büyük harf notu (klavye ilk harfi kendisi büyütmediyse). Metin önce düzenleme menüsünden yapıştırılır, olmazsa yazılır.
  - `21b-kendi-cumlen-iyi`: "I forgot my umbrella at home." → yeşil hüküm.
  - `21c-kendi-cumlen-buyuk-yazi`: aynı ilk cümle, erişilebilir yazı boyu L.
  - Üçünde de öneri kutusunun **olmadığı** doğrulanır: CI simülatörlerinde Apple Intelligence yok. Bir gün bir koşucuda varsa test bunu söyler.

## Riskler

- FoundationModels API adları Xcode 26 için hafızadan yazıldı, derlenmedi: `LanguageModelSession(instructions:)`, `respond(to:generating:)`, `response.content`, `@Generable`, `@Guide(description:)`, `SystemLanguageModel.default.availability` / `.available`. Hata türlerinin adları bilinçli olarak kullanılmadı (tek `catch`). Sıcaklık gibi `GenerationOptions` verilmedi.
- Zayıf bağlama: iOS 17 cihazda açılışta çökme olmamalı; olursa `project.yml`'a `-weak_framework FoundationModels` eklenir (bu bayrak eski SDK'da bağlamayı bozar, o yüzden şimdilik eklenmedi).
- Model kalitesi cihazda görülmedi: yanlış "wordMeaning" ya da gereksiz düzeltme verebilir. Metinler bu yüzden "olabilir" diye yazıldı ve kurallar önce gösterilir.
- UI testinde yapıştırma menüsü bulunamazsa metin yazılır ve klavye ilk harfi büyütebilir; o zaman büyük harf notu beklenmez (test bunu kaydeder).
