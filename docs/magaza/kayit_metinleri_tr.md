# App Store kayıt metinleri: Türkçe (tr)

> **TASLAK (23 Ekim 2026).** App Store Connect'e girilmedi. Girmek ve göndermek kullanıcının işidir (Apple hesabında her değişiklik için açık izin, `DEVIR.md`).
>
> **Marka uyarısı:** "Lockglow" adı için **TÜRKPATENT araması ve marka vekili görüşü yapılmadı.** Ad kesin değil. Ad değişirse "Ad" alanı ve açıklamadaki "Lockglow" geçen yerler değişir; anahtar kelimeler aynı kalır.
>
> **Neye göre yazıldı:** `origin/main` aa7ef5d, içerik `2026.10.23-kisisel-10` (1.203 kelime). Metinler yalnız **bugünkü uygulamada olan** özellikleri anlatır. Her iddianın kaynağı "İddia → kaynak" tablosunda. Paralel is5 oturumları birleşince değişecek satırlar en altta.

Kurallar ve sınırlar: [`README.md`](README.md) → "Apple sınırları ve kuralları". Uzunluklar Python'la sayıldı (`len()`, satır sonu 1 karakter); anahtar kelimeler UTF-8 bayt (ç, ğ, ı, İ, ö, ş, ü 2 bayt). Sayımı yineleyen betik: [`araclar/metin_say.py`](araclar/metin_say.py).

## Özet

| Alan | Sınır | Öneri | Uzunluk |
|---|---|---|---|
| Ad | 30 karakter | `Lockglow: İngilizce Kelime` | 26 |
| Alt başlık | 30 karakter | `Kilit Ekranında Ezberle, Öğren` | 30 |
| Tanıtım metni | 170 karakter | aşağıda | 152 |
| Açıklama | 4000 karakter | aşağıda | 3813 |
| Anahtar kelimeler | 100 bayt | aşağıda | 91 karakter, 98 bayt |
| Yenilikler (What's New) | 4000 karakter | 1.0'da alan yok; kalıp aşağıda | — |

## Ad

```text
Lockglow: İngilizce Kelime
```

26 karakter. "ingilizce kelime" Türkiye'de en çok aranan küme. Rekabeti çok güçlü (Kolay İngilizce ~37 bin puan), ama uzun vadede değer burada (`rakip_analizi.md` §3). Ada girdiği için anahtar kelime alanında tekrar edilmez.

**Marka değişirse:** `<Ad>: İngilizce Kelime` kalıbı; marka en çok 12 karakter olursa 30'a sığar. "Ücretsiz", "en iyi", "#1" ve başka uygulama adları yazılmaz (Kural 2.3.7).

## Alt başlık

```text
Kilit Ekranında Ezberle, Öğren
```

30 karakter (sınırda). Ürünün çekirdeğini (kilitli ekran) ve iki arama kelimesini taşır. Addaki kelimelerle "kilit ekranı ingilizce kelime" (Google önerisi var; App Store'da rekabet düşük, en iyi rakip ~20 puan), "kelime ezberle" ve "ingilizce öğren" birleşimleri oluşur.

- **Terim notu:** uygulamanın içinde Apple'ın Türkçe adı **"kilitli ekran"** kullanılır (`docs/tasarim/terimler.md` §5). Alt başlıkta insanların aradığı biçim ("kilit ekranı") seçildi; açıklama ve ekran görüntüleri yine "kilitli ekran" der.
- **Risk:** 15 Ekim'de çıkan yeni bir rakibin (Lugat) alt başlığı aynı fikri taşıyor; kelime kelime aynı değil. Fark ekran görüntülerinde gösterilir (Dikkat, widget'tan ses, Söyle).
- **Tuzak:** App Store'da tek başına "kilit ekranı" araması dua ve ayet uygulamalarını getiriyor. Bu yüzden "kilit" anahtar kelime alanında değil, alt başlıkta "ingilizce kelime" ile birlikte duruyor.

**Yedekler:**

| Metin | Uzunluk | Ne zaman |
|---|---|---|
| `Widget, Telaffuz ve Tekrar` | 26 | Söyle ve widget sesi vitrinin önüne alınacaksa. O zaman anahtar kelimeler "B seti" olur (aşağıda). Zayıf yanı: fayda cümlesi değil, özellik listesi. |
| `Kilit Ekranında Kelime Ezberle` | 30 | Daha doğal; ama "kelime" addakini tekrar eder, "öğren" kaybolur. |

## Tanıtım metni (Promotional Text)

```text
Telefonuna her bakışta bir İngilizce kelime: Türkçe anlamı, örneği ve sesiyle. Önce tanış, sonra hatırla. Kendi kelimeni de ekle. Reklam yok, hesap yok.
```

152 karakter. Aramayı etkilemez; yeni sürüm göndermeden istenildiği zaman değişir. Yeni içerik ya da özellik gelince burası güncellenir (ör. "Yeni: duygular ve kişilik konuları").

## Açıklama

Önce fayda, sonra özellikler, en sonda sınırlar. Sayılar aşağı yuvarlandı ("1.200'den çok"): içerik eklendikçe doğru kalır, azalırsa düzeltilmeli. "Ücretsiz" kelimesi bilerek yok: ileride abonelik gelirse metin yanlış kalmasın; fiyat mağazada zaten görünür.

```text
Günde onlarca kez telefonuna bakıyorsun. Lockglow her bakışı küçük bir İngilizce dersine çevirir: kilitli ekranında ve ana ekranında, Türkçe anlamıyla bir İngilizce kelime durur. Uygulamayı açmadan okursun, dinlersin.

Lockglow, günlük İngilizce öğrenen Türkçe konuşanlar için yapıldı. Kelimeler A1, A2 ve B1 seviyesinde: evde, işte, yolda ve alışverişte kullanacağın İngilizce.

NEDEN İŞE YARAR
• Her gün biraz: Kelime, sen başka bir iş yaparken gözünün önüne gelir.
• Görmek yetmez, hatırlamak gerekir: Yeni kelimeyle önce tanışırsın, sonra hemen bir kez hatırlarsın.
• Unutmadan önce yine gelir: Zorlandığın kelime sık, iyi bildiğin kelime seyrek sorulur.
• Türkçe açıklama: Her kelimede Türkçe anlam, örnek cümle ve cümlenin Türkçesi var.
• Hatayı baştan gör: 600'den çok kelimede Türkçe konuşanların sık yaptığı bir hata ve doğrusu var. Örneğin "I did breakfast" değil, "I had breakfast".

WIDGET'LAR
• Ana ekranda küçük ve orta widget; kilitli ekranda dikdörtgen ve tek satırlık widget.
• Kilitli ekranda ve ana ekranda aynı kelime görünür.
• Ana ekran widget'ındaki Dinle düğmesi kelimeyi uygulamayı açmadan sesli okur.
• Orta widget'ta Biliyorum, Dinle ve Sonraki; küçük widget'ta Dinle ve Sonraki düğmeleri var.
• Kelimenin ne sıklıkla değişeceğini sen seçersin: 30 dakika, 1, 2 ya da 4 saat.
• Widget sağlığı sayfası, widget'ın çalışıp çalışmadığını gösterir.

TANIŞ, HATIRLA, TEKRAR ET
• Yeni kelimeler 5'li turlarda gelir. Önce anlamını tahmin edersin, sonra dört şık arasından hatırlarsın.
• Yeni kelimede puanı sen vermezsin, cevabın verir.
• Zamanı gelen kelimede dört şıklı boşluk doldurma; iyi bildiğin kelimede İngilizcesini akıldan bulma.
• Bir tur en çok 10 soru. Günlük yeni kelime hedefi: 5, 10, 15 ya da 20.

SÖYLE: TELAFFUZ ALIŞTIRMASI
• Kelimeyi ya da örnek cümleyi sesli söyle. Telefon dinler ve Türkçe cevap verir: "Anlaşıldı!", "Neredeyse!" ya da neye dikkat etmen gerektiği.
• Tanıma yalnız iPhone'unda yapılır. Sesin kaydedilmez ve telefondan çıkmaz.

KENDİ KELİMELERİN
• Dizide duyduğun, işte gördüğün bir kelimeyi kendin ekle: İngilizcesi, Türkçe anlamı ve istersen bir örnek cümle.
• Eklediğin kelime de widget'ta, Akış'ta ve Tekrar'da karşına çıkar.

İLERLEMEN
• Kitaplığın: kaç kelimeyle tanıştın, hangileri yerleşti, bu hafta neler öğrendin.
• Yüzde yok, sıralama yok, seri sayacı yok. Unuttuğun kelime aşağı basamağa iner; bu bir ceza değil.

SÖZLÜK
• Bütün kelimelerde İngilizce ya da Türkçe ara. Türkçe harfleri yazmasan da bulur: "odunc" yazınca "ödünç" çıkar.
• Konuya göre göz at, son aramalarına dön.
• Her kelimede örnek cümleler, birlikte kullanılan kelimeler ve ses; birçoğunda Dikkat kutusu.

1.200'DEN ÇOK KELİME
• Tek kelimeler, kalıp fiiller (phrasal verbs), kalıplar ve kelime ikilileri.
• Okunuş, Türkçe anlam, kısa İngilizce tanım; 3.600'den çok örnek cümle ve Türkçesi.
• 30 konu: yemek, ev, aile, alışveriş, sağlık, şehir, seyahat, okul, iş yeri, teknoloji, duygular, sohbet ve daha fazlası.

SANA GÖRE BAŞLA
• İlk açılışta seviyeni ve konularını seçersin; widget'ı nasıl ekleyeceğini adım adım gösteririz.
• İstersen günlük hatırlatma: seçtiğin saatte günde en çok bir bildirim. Bildirim bir kelimeyi anlamıyla gösterir. O günün işini bitirdiysen gelmez.

GİZLİLİK
• Hesap yok, reklam yok, takip yok.
• İlerlemen ve kendi kelimelerin telefonunda durur; biz göremeyiz.
• Lockglow verini hiçbir sunucuya göndermez.

BİLMEN GEREKENLER
• Uygulamanın dili Türkçe. iPhone'da, iOS 17 ve sonrasında çalışır.
• Söyle: iOS 26 ve sonrasında İngilizce konuşma modeli ilk kullanımda bir kez iner. iOS 17–25'te telefonunda cihaz içi İngilizce (ABD) tanıma olmalı.
• Kilitli ekrandaki widget'ta düğme yok; iPhone kilitliyken widget düğmeleri çalışmaz.
• Widget'ın ne zaman yenileneceğine son kararı iOS verir; bazen birkaç dakika gecikebilir.

Gizlilik politikası: [GİZLİLİK POLİTİKASI ADRESİ]
```

3813 karakter (sınır 4000). Apple'ın standart kullanım koşulları (EULA) kendiliğinden geçerli; abonelik olmadığı için açıklamaya bağlantı gerekmez. Abonelik gelirse Kural 3.1.2 gereği kullanım koşulları bağlantısı eklenir.

**Yazım notları:** Bölüm başlıkları BÜYÜK harfle, çünkü açıklama düz metin (kalın yazı yok). "Sen" dili, ünlem yalnız Söyle'nin kendi sonuç adlarında ("Anlaşıldı!", "Neredeyse!"). "kalıp fiiller (phrasal verbs)": uygulamada parantez içinde İngilizce terim yok (`terimler.md` §1), ama mağazada insanlar "phrasal verb" diye arıyor.

### İddia → kaynak

Her satır `origin/main` aa7ef5d'de kontrol edildi (yollar `ios/` altına göre).

| İddia | Kaynak |
|---|---|
| Kilitli ekranda ve ana ekranda Türkçe anlamıyla kelime; uygulamayı açmadan okunur | `Widgets/WordWidget.swift:15–20`; `Widgets/AccessoryWordViews.swift:5–13` |
| A1, A2, B1 | `content.sqlite` `card.level`: A1 179, A2 537, B1 487 |
| Önce tanış, sonra hemen bir kez hatırla; 5'li turlar | `App/AppModel.swift:20–22` (`introRoundLimit = 5`); `App/ReviewView.swift:12–18` |
| Zorlandığın kelime sık, iyi bildiğin seyrek gelir | `Packages/VocabKit/Sources/Learning/Leitner.swift:39–55` (1, 2, 4, 8, 16 gün; sonra 30, 60, 120 gün) |
| Her kelimede Türkçe anlam, örnek cümle ve Türkçesi | `content.sqlite`: 1.203 kartın hepsinde Türkçe anlam; 3.607 örnek cümlenin hepsinde Türkçe çeviri |
| 600'den çok kelimede Dikkat; "I did breakfast" → "I had breakfast" | `content.sqlite`: 630 kartta `l1.tr.mistakes`; breakfast kartı (ekran görüntüsü `1-akis`) |
| Küçük ve orta ana ekran, dikdörtgen ve tek satırlık kilitli ekran widget'ı | `Widgets/WordWidget.swift:15–20` |
| Kilitli ekranda ve ana ekranda aynı kelime | `Widgets/WordProvider.swift:95–96` |
| Dinle kelimeyi uygulamayı açmadan okur | `Shared/SpeakWordIntent.swift` (`AudioPlaybackIntent`); `ios/project.yml:72–73` (`audio`). **Cihazda doğrulanmadı** (`ios/README.md:254`); göndermeden önce denenmeli |
| Orta widget'ta Biliyorum, Dinle, Sonraki; küçükte Dinle, Sonraki | `Widgets/HomeWordViews.swift:121–127, 296–306`; `Widgets/WidgetButtons.swift` |
| 30 dakika, 1, 2 ya da 4 saat | `Packages/VocabKit/Sources/Learning/SettingsRules.swift:8–15` |
| Widget sağlığı sayfası | `App/WidgetHealthView.swift` |
| Önce anlamını tahmin, sonra dört şık | Tanış'ta "Anlamını göster" (`ReviewView.swift:559–572`); Hatırla 4 şık (`ReviewPlanner.swift:198–211`) |
| Yeni kelimede puanı cevabın verir | `ReviewPlanner.swift:236–246` (ilk denemede Bildim, ikincide Zor, olmadıysa Bilemedim) |
| Dört şıklı boşluk doldurma; iyi bildiğinde İngilizcesini akıldan bulma | Kutu 1–3 `QuizCardView.swift:175`; kutu 4–5 "İngilizcesini hatırla", Bulamadım / Buldum (`ReviewView.swift:937–1027`) |
| Tur en çok 10 soru; hedef 5, 10, 15, 20 | `AppModel.swift:16–18`; `SettingsRules.swift:17–18` |
| Söyle: kelime ya da örnek cümle; "Anlaşıldı!", "Neredeyse!" ya da ipucu | `App/PronunciationPracticeView.swift:97–98`; `Packages/VocabKit/Sources/Pronunciation/PronunciationCheck.swift:505–528` |
| Tanıma yalnız iPhone'da; ses kaydedilmez, telefondan çıkmaz | `App/PronunciationRecognizer.swift:12, 470` (`requiresOnDeviceRecognition`); `PronunciationPracticeView.swift:143` |
| Kendi kelimen: İngilizcesi, Türkçe anlamı, isteğe bağlı örnek; widget, Akış, Tekrar | `App/CustomWordsView.swift:79, 368–481`; `App/AppModel+CustomWords.swift:6–12` |
| Kitaplığın; bu hafta; yüzde, sıralama, seri yok; aşağı basamak ceza değil (kod iki basamak indirir: `Leitner.swift:51`) | `App/ProgressOverviewView.swift:5–9, 93–121, 857` |
| Sözlük: İngilizce ya da Türkçe; "odunc" → "ödünç"; konu; son aramalar | `App/SearchView.swift:1–7, 54, 167, 202`; `App/SozlukRecentSearches.swift` |
| Örnekler, Dikkat, birlikte kullanılanlar, ses (Sözlük) | `SearchView.swift:630–741` |
| Kalıp fiiller, kalıplar, kelime ikilileri | `content.sqlite` `card.type`: 824 kelime, 159 kalıp fiil, 114 kalıp, 97 eşdizim, 9 deyim |
| Okunuş, kısa İngilizce tanım; 3.600'den çok örnek | `content.sqlite`: 1.203 kartta okunuş (IPA); 3.607 örnek |
| 30 konu | Konu seçicide ve Sözlük'te en az 5 kelimeli 30 konu (`AppModel.swift:24, 234–236`) |
| Açılışta seviye, konu, widget rehberi | `App/OnboardingView.swift`; `App/WidgetGuideView.swift` |
| Hatırlatma: isteğe bağlı, günde en çok bir, kelime gösterir, iş bittiyse gelmez | `App/AppPreferences.swift:83–91` (varsayılan kapalı); `Learning/ReminderPlanner.swift`; `App/SettingsView.swift:413` |
| Hesap, reklam, takip yok; veri sunucuya gitmez | Ağ kodu yok; tek dış paket GRDB; `App/PrivacyInfo.xcprivacy` (`NSPrivacyTracking false`) |
| iPhone, iOS 17 | `ios/project.yml:4–5, 19` |
| Söyle: iOS 26'da model bir kez iner; iOS 17–25'te cihaz içi tanıma | `PronunciationRecognizer.swift:434–478`; `PronunciationPracticeView.swift:113, 899` |
| Kilitli ekran widget'ında düğme yok | `Widgets/WidgetButtons.swift:6–8` |

### Bilerek yazılmayanlar

- **Bugün yok:** iPad, Apple Watch, iCloud yedeği ya da eşitleme, büyük widget, yuvarlak kilitli ekran widget'ı, Denetim Merkezi, Canlı Etkinlik, Siri ve Kısayollar, İngilizce arayüz, Türkçe sesli okuma, FSRS ("akıllı" zamanlama), uygulama içinde tema seçimi, StandBy'a özel düzen (iOS küçük widget'ı kendisi gösterir).
- **Yanıltıcı olur:** YDS, YÖKDİL, IELTS, TOEFL; C1–C2; "10.000+ kelime"; "yapay zekâ"; "en iyi", "#1"; "tek uygulama", "ilk" gibi doğrulanamayan üstünlük (rakiplerde benzer widget'lar var, `rakip_analizi.md`).
- **22 Ekim taslağında olup artık yanlış olanlar:** "933 kart", "5 dakikadan 2 saate kadar", "Bilemedim, Zor, Bildim, Kolay: dört cevap" (yeni kelimede artık puanı cevap veriyor), "Leitner kutu sistemi" (uygulamada "basamak"), Söyle'de "Doğru!" (artık "Anlaşıldı!"), "Kelimeyi dinle" (düğmenin adı **Dinle**).

## Anahtar kelimeler

```text
widget,telaffuz,kartları,ekranı,günlük,ezberleme,öğrenme,kelimeler,tekrar,testi,okunuş,ders
```

91 karakter, **98 bayt** (sınır 100 bayt). Virgülden sonra boşluk yok. Her kelime 2 karakterden uzun (Apple şartı; bu yüzden "a2", "b1" yazılamaz). Ad ve alt başlıktaki kelimeler tekrar edilmedi.

| Kelime | Ad/alt başlıkla birleşince | Kanıt (23 Ekim) |
|---|---|---|
| widget | "ingilizce kelime widget" | Rakiplerin adında. Tek başına "widget" önerileri tema uygulamaları; bu yüzden alt başlıkta değil |
| telaffuz | "ingilizce telaffuz" | App Store önerisi; Söyle |
| kartları | "ingilizce kelime kartları" | App Store önerisi |
| ekranı | "kilit ekranı ingilizce kelime" (alt başlıktaki "Kilit" ile) | Google önerisi; düşük rekabet |
| günlük | "günlük ingilizce", "ingilizce günlük kelimeler" | Google ve App Store önerisi |
| ezberleme | "ingilizce kelime ezberleme" | App Store önerisi; alt başlıktaki "ezberle"den ayrı kelime |
| öğrenme | "ingilizce kelime öğrenme" | App Store önerisi |
| kelimeler | "ingilizce kelimeler öğren" | App Store önerisi |
| tekrar | "kelime tekrar" | Aralıklı tekrar |
| testi | "ingilizce kelime testi" | App Store önerisi |
| okunuş | "ingilizce kelimeler ve okunuşları" | Google önerisi; her kartta okunuş |
| ders | "ingilizce ders" | Genel talep |

**B seti** (alt başlık `Widget, Telaffuz ve Tekrar` seçilirse):

```text
kilit,ekranı,ezberle,ezberleme,öğren,öğrenme,kartları,günlük,kelimeler,testi,okunuş,ders
```

88 karakter, 97 bayt.

**Bilerek konmayanlar:**
- `ingilizce`, `kelime`, `kilit`, `ezberle`, `öğren`, `lockglow`: ad ve alt başlıkta.
- `eğitim`: kategori adı, zaten aranır.
- `sözlük`: "ingilizce sözlük" aramasını büyük sözlük uygulamaları tutuyor; bayt pahalı.
- `yds`, `yökdil`, `ielts`, `toefl`: içerik A1–B1; yanıltıcı olur (Kural 2.3.7).
- Rakip adları: yasak (Kural 2.3.7, 4.1).
- `a1`, `a2`, `b1`: Apple her kelimenin 2 karakterden uzun olmasını istiyor ([Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), 23 Ekim 2026).
- Aksansız yazımlar (`telafuz`, `sozluk`): Apple aksan eşleşmesini belgelemiyor; bayt harcamaya değmez.
- Sonraki sürümlerde denenebilecek adaylar: `dağarcığı`, `tekrarlayıcı`, `reklamsız` (`rakip_analizi.md` §3.3).

**Kanıt düzeyi:** Ücretli ASO aracı kullanılmadı. Talep yalnız App Store ve Google öneri listelerinden, rekabet ilk sonuçların puan sayısından tahmin edildi (`rakip_analizi.md` §3.1). Yayından 2–4 hafta sonra App Store Connect'teki arama terimleriyle zayıf kelimeleri değiştirin. Her sürümde 2–3 kelimeden fazlasını değiştirmeyin ki etkisi görülsün.

**İkinci alan:** Türkiye mağazasında İngilizce (U.K.) yerelleştirmesi de aranır; İngilizce terimler oraya: [`kayit_metinleri_en.md`](kayit_metinleri_en.md).

## Yenilikler (What's New)

**1.0 (ilk sürüm):** App Store Connect bu alanı ilk sürümde göstermez.

**TestFlight "Test Edilecekler" (What to Test)** için bir sonraki derlemeye kısa metin:

```text
Bu derlemede dene: Tanış + Hatırla turları, kendi kelimeni ekleme, Kitaplığın (ilerleme), Söyle'de örnek cümle, widget'ta Dinle düğmesi ve yeni konular.
```

152 karakter.

**1.1 ve sonrası için kalıp** (Kural 2.3.12: değişiklikleri açıkça yaz; en önemlisi en üstte; ton uygulamayla aynı, ünlem yok):

```text
Yeni
• [Özellik]: [kullanıcıya faydası, tek cümle].
• Yeni kelimeler: [konu adları].

Düzeltmeler
• [Sorun] düzeltildi.
```

"Puan ver" çağrısı yazılmaz: uygulama baskı yapmıyor (`docs/tasarim/ogrenme_ilkeleri.md` §1 madde 11).

**is5 işleri bir sürüme girerse örnek satırlar** (yalnız gerçekten birleşenler yazılır; her biri birleşen koda göre yeniden kontrol edilir):

| Oturum | Örnek satır |
|---|---|
| is5-w-buyuk | • Büyük widget: kelime, anlamı ve örnek cümlesi ana ekranda tek bakışta. |
| is5-w-quiz | • Widget'tan cevapla: soruya uygulamayı açmadan cevap ver. |
| is5-kontrol | • Denetim Merkezi: sonraki kelimeye tek dokunuşla geç (iOS 18 ve sonrası). |
| is5-icloud | • iCloud: ilerlemen ve kendi kelimelerin kendi iCloud hesabında da durur. |
| is5-dinle-yaz | • Yeni alıştırmalar: dinleyip seç ve yazarak hatırla. |
| is5-icerik-s20/s21/s22 | • Yeni kelimeler: günlük konuşma kalıpları, duygular ve kişilik, deyimler. |

## Paralel işler birleşince değişecek satırlar

Ayrıntılı tablo: [`app_review_kontrol_listesi.md`](app_review_kontrol_listesi.md) §10. En önemlileri:

- **is5-icloud:** "İlerlemen ve kendi kelimelerin telefonunda durur; biz göremeyiz." → iCloud'u da söyle ("telefonunda ve kendi iCloud hesabında durur; biz göremeyiz"). App Privacy cevabını ve gizlilik politikasını yeniden kontrol et.
- **is5-ipad, is5-watch:** "iPhone'da, iOS 17 ve sonrasında çalışır." satırı; iPad ve Watch ekran görüntüleri zorunlu olur.
- **is5-w-buyuk, is5-w-kilit, is5-kontrol, is5-canli:** "WIDGET'LAR" bölümündeki widget listesi.
- **is5-fsrs:** "Unutmadan önce yine gelir" doğru kalır; "yapay zekâ" ya da "akıllı algoritma" yazılmaz.
- **is5-ses:** yalnız gerçekten gelirse "İngiliz ve Amerikan aksanı" yazılabilir.
- **is5-akilli-bildirim:** "seçtiğin saatte" cümlesi kendiliğinden değişen saate göre düzeltilir.
- **İçerik (s20–s22):** yuvarlak sayılar doğru kalır; konu sayısı (30) değişebilir, kontrol et.

## Bağımsız denetim (23 Ekim 2026)

Ayrı bir denetçi ajan, yazarın kaynak tablosuna bakmadan her iddiayı koda ve `content.sqlite`'a karşı kontrol etti (6 dosya). Bütün sayılar ve sınırlar doğru çıktı (1.203 kart, yalnız A1/A2/B1, 3.607 örnek, 630 Dikkat, 30 konu, widget düğmeleri, sıklık, hedef, Söyle metinleri, ağ kodu yok). Uygulanan düzeltmeler:

- "Unuttuğun kelime bir alt basamağa iner" yanlıştı (kod iki basamak indirir) → "aşağı basamağa iner".
- "Her kelimede … Dikkat kutuları" abartılıydı (630 / 1.203) → "birçoğunda Dikkat kutusu".
- "Puanı cevabın verir" yalnız yeni kelimede doğru → "Yeni kelimede puanı …".
- Video 2. sahnedeki widget "Tamam" onayı uygulamada yok → sahne Sonraki ile.
- İnceleme notundan "content is original" cümlesi çıkarıldı (kartlar Claude ile yazıldı, insan denetimi yok; lisans atfı eksik).
- 1. karenin başlığı "yeni kelime" → "bir kelime" (kelime 30 dk–4 saatte bir değişiyor).
- SSS: Biliyorum yalnız orta widget'ta; iOS 26'da yalnız mikrofon izni.
- Video kendi kelime örneği binge-watch → doomscroll (binge-watch kartlarda var).

Koda bağlı açık maddeler (gizlilik bağlantısı, Tanılama, dil klasörü, lisans ekranı, widget sesinin cihazda denenmesi): `app_review_kontrol_listesi.md` "Özet".
