# Lockglow: öğretici ve yormayan arayüz ilkeleri

22 Ekim 2026. Dört araştırmanın birleşimi: öğrenme bilimi, okuma yorgunluğu ve erişilebilirlik, rakipler, Türkçe konuşan öğrenci. Aynı gün bir eleştirmenin düzeltmeleriyle gözden geçirildi; neyin değiştiği en sondaki "Gözden geçirme" bölümünde.

Bu belge [`README.md`](README.md) ve [`lockglow_ui_mockup.html`](lockglow_ui_mockup.html) tasarımının üstüne yazıldı. Tasarımı baştan değiştirmez. Neyin kalacağını, neyin değişeceğini ve nedenini ekran ekran söyler. Swift kodu ve içerik dosyaları değişmedi.

**Etiketler:**
- **[ŞART]**: birincil bir kaynağa (makale) ya da bir Apple veya WCAG kuralına dayanır. Yapılmazsa öğrenme ya da okuma zarar görür. Tek istisna şık sırasının karışmasıdır (2.4): gerekçesi bizim, kaynağı yok.
- **[ÖNERİ]**: kanıt iyi ya da fayda açık, ama birincil kaynak ya da Apple/WCAG kuralı yok. Ürün seçimleri de buradadır. Sürüm planına alınmalı.
- **[BELKİ]**: iyi fikir ama kanıt zayıf ya da işi büyük. Sonraya kalabilir.
- Etiket kanıtın gücünü söyler, önceliği söylemez. Öncelik 1c'deki ilk sürüm listesindedir.

**Bu belgedeki birkaç terim** (her biri yalnız burada açıklanıyor):
- **Hatırlama:** cevabı görmeden akıldan bulmak. Bilimde "retrieval". Kartı yeniden okumak hatırlama değildir.
- **Leitner kutusu:** kelimenin basamağı (1–5). Kutu büyüdükçe tekrar arası uzar: 1, 2, 4, 8, 16 gün (`Leitner.intervalDays`). Son kutudan sonra kelime "bilinen" olur ve 30 günde bir **tazeleme** sorusu gelir.
- **Cloze:** boşluk doldurma sorusu ("I eat soup with a ___"). **Yazılmış cloze**, kartın `quiz.cloze` cümlesidir.
- **Çeldirici:** quiz'deki yanlış şık.
- **pt:** iOS ölçüsü. 44 pt yaklaşık 7 mm.
- **Dinamik Tür:** kullanıcının iPhone'da seçtiği yazı boyu. "AX boyları" en büyük erişilebilirlik boylarıdır.
- **VoiceOver:** iPhone'un ekran okuyucusu.
- **Kontrast oranı:** yazı ile zemin arasındaki açıklık farkı. WCAG'de 4,5:1 normal yazı için AA alt sınırı (1.4.3), 7:1 ise AAA düzeyi (1.4.6). 7:1 WCAG'de bir yazı boyu kuralı değil; küçük yazıda 7:1 Lockglow'un kendi hedefi.
- **Timeline:** widget'ın önceden planlanmış görüntü listesi. iPhone bunları sırayla gösterir.
- **Slot:** timeline'daki bir görüntü yeri. Her slotta bir kelime durur.
- **App Intent:** uygulamayı açmadan widget'tan çalışan düğme.
- **Alt sayfa (sheet):** ekranın altından açılan yarım sayfa.
- **Sistem kartı:** uygulama açılınca çıkan, kelime öğretmeyen bilgi kartı: hatırlatma saati sorusu, duraklatma notu, "Ara verdin" başlangıcı, günün sonu kartı.

---

## 1. Özet: "öğretici ve yormayan" ne demek?

1. **Görmek değil, hatırlamak öğretir.** Kelimeyi tekrar okumak yerine cevabı akıldan bulmaya çalışmak, bir hafta sonra çok daha iyi hatırlatır. *Neden:* Karpicke ve Roediger (2008) çalışmasında testi bırakan grup çok unuttu, yeniden okumayı bırakan grup unutmadı. Rowland'ın (2014) meta-analizinde test, yeniden okumadan açıkça daha iyi (g ≈ 0,50).
2. **Yeni kelime aynı gün bir kez hatırlanmalı.** "Tanış" adımından hemen sonra kısa bir "Hatırla" sorusu gelir. Bir doğru hatırlama yeter, çünkü ardından en az 3 aralıklı tekrar geliyor. *Neden:* Rawson ve Dunlosky (2011) kelimeleri ilk oturumda 1 ile 4 arası doğru kısa cevaba kadar çalıştırdı, sonra 1 ile 5 arası sonraki oturumda yeniden öğretti. İlk oturumdaki doğru sayısının etkisi, yeniden öğrenme oturumları arttıkça küçüldü. Yazarlar 3 doğru hatırlama ve 3 aralıklı yeniden öğrenme oturumu öneriyor. Hatırla ise 4 şıklı bir tanıma sorusu, yani o çalışmadaki kısa cevaplı hatırlamadan kolay. Bu yüzden ertesi günkü soru (kutu 1) yine bir "anlamını seç" sorusu olmaz, yazılmış cloze olur (2.4). Bugün yeni kelime yalnız gösteriliyor, ilk gerçek soru ertesi gün geliyor.
3. **Kendini puanlama yalnız bir hatırlama denemesinden sonra olur; hiç denemeden "ne kadar bildin?" diye sorulmaz.** Yeni kelimede puan cevabın kendisinden gelir. Kutu 4–5'te öğrenci önce akıldan bulmaya çalışır, "Göster"e basar, sonra "Göstermeden önce aklına geldi mi?" sorusuna "Bulamadım" ya da "Buldum" der. *Neden:* cevap gözünün önündeyken ve kelime büyük yazılmışken insan kendini olduğundan iyi sanır (Koriat ve Bjork 2005; Rhodes ve Castel 2008). Öğrenciler kısmen doğru hatırladıklarını da doğru sayıyor (Dunlosky ve Rawson 2012; bulgu bu gözden geçirmede yeniden açılmadı). Soruyu "göstermeden önce" diye sormak bunu azaltmak için; bu bizim çıkarımımız, denenmedi. Kartı erken bırakmak öğrenmeyi azaltır (Kornell ve Bjork 2008).
4. **Aynı soru aynı biçimde tekrar gelmez ve son kutulardaki soru gerçek kullanıma benzer.** Şıkların sırası her seferinde karışır. Soru türü kutuyla değişir. Son kutularda soru Türkçeden İngilizceye ve yeni bir cümlede sorulur. *Neden:* testin faydası başka soru biçimlerine de geçiyor (Pan ve Rickard 2018, d ≈ 0,40). Ama soru ile cevabın yeri değişince (İngilizce → Türkçe çalışıp Türkçe → İngilizce sorulunca) en az geçiyor ve ilk testteki başarıya çok bağlı. Gerçek kullanım Türkçeden İngilizceye olduğu için son kutularda bu yön sorulur. Şıkları karıştırmanın gerekçesi ayrı ve bizim: doğru şık hep aynı yerdeyse öğrenci kelimeyi değil yeri öğrenebilir. Bugün `Quiz.options(seed:)` her açılışta aynı sırayı veriyor.
5. **İlk karşılaşmada az şey gösterilir: en çok 8 blok ve tek bir uyarı yuvası.** Ayrıntılar ikinci karşılaşmada ya da dokununca açılır. *Neden:* aşamalı açma, en çok gereken bilgiyi önde tutar ve gerisini isteyene açar (NN/g). Apple widget için aynı ilkeyi söylüyor: iyi widget temel bilgiyi bir bakışta verir, ayrıntıyı daha uzun bakana bırakır (HIG Widgets). Konuyla ilgisiz ama ilginç eklerin öğrenmeyi düşürdüğü biliniyor (Sundararajan ve Adesope 2020, g ≈ −0,33, yalnız ikinci el özetlerden). IPA, örnek ve Dikkat ise ilgili bilgiler; bu yüzden o kaynak burada yalnız dolaylı destek. Bugünkü kartta ilk bakışta 10–13 öğe var.
6. **Türkçe anlam önce gelir, büyük yazılır ve hiç ortasından kesilmez.** *Neden:* ana dilde açıklama, İngilizce açıklamadan genelde daha iyi öğretiyor (g = 0,33), özellikle başlangıç düzeyinde. Etki en çok hemen yapılan testlerde görülüyor (Kim, Lee ve Lee 2024; okuma metinlerindeki açıklamalar üzerine bir meta-analiz). 0,33 bütün düzeylerin ortalaması, A1–A2'ye özel bir sayı değil. Türkçede olumsuzluk ve zaman eki kelimenin sonunda durur. "aynı fikirde ol…" diye kesilen bir anlam, tersini ("agree") okutur.
7. **Türkçe ile İngilizcenin farkı açıkça gösterilir: Dikkat ve sahte dost.** Yasak gibi değil, olumlu bir kural gibi yazılır. *Neden:* Türkçeyle karşılaştırarak öğretmek, karşılaştırmasız öğretimden daha iyi sonuç verdi (Laufer ve Girsai 2008). Açık karşılaştırmalı anlatım zor biçimlerde de işe yaradı (Kupferberg ve Olshtain 1996). Sahte dost bilgisi kartlarda var ama bugün hiçbir ekranda görünmüyor.
8. **Birbirine karışan kelimeler aynı gün yeni kelime olarak gelmez.** Önce biri öğrenilir, sonra ikisi yan yana sorulur. *Neden:* anlamca yakın kelimeler birlikte öğretilince birbirini bozar (Nation 2000). 60 dördüncü sınıf öğrencisiyle yapılan bir çalışma da bunu gösterdi (Erten ve Tekin 2008; kayıt sayfası ülkeyi yazmıyor). İkisi öğrenildikten sonra ise yan yana sormak ayırt etmeyi güçlendirir (benzer kategorileri karıştırma çalışması, Memory & Cognition; ayrıntısı bu gözden geçirmede açılmadı).
9. **Günlük yeni kelime sayısı, yarınki tekrar yükünü belirler. Bu yüzden bedeli seçerken görünür.** *Neden:* günde 10 yeni kelime bir süre sonra günde en az 50–60 tekrar sorusu demek. Bu bir alt sınır. Hesap kelime başına yaklaşık 5 tekrar varsayıyor ve unutmayı saymıyor. Bugün `Leitner.review(.again)` kelimeyi hangi kutuda olursa olsun, kutu 5'ten bile, kutu 1'e indiriyor. Yani tek bir kayma bütün 1-2-4-8-16 yolunu baştan başlatıyor. Sabit 30 günlük tazelemeler de geçmiş büyüdükçe her ay günde yaklaşık bir günlük hedef kadar artıyor. Bu yüzden Ayarlar'daki süreler ölçülene kadar "en az" diye yazılır (2.9) ve kayma kuralı değişir (2.3). A1–A2 için az başlamanın (günde 5) yorgunluğu ve bırakmayı azaltacağı bizim çıkarımımız. Sayılar `Leitner.swift`'ten hesaplandı, cihazda ölçülmeli (2.13).
10. **Bir bakışta okunur.** Widget'ta tek fikir olur. Her yüzeyin kendi yazı tabanı var: Akış ve Tekrar'da İngilizce okuma metni 17–18 pt, ana ekran widget'ında 15 pt. Bu iki sayı Lockglow'un kendi seçimi, Apple kuralı değil. Apple'ın tabanı 11 pt: "display text using fonts at 11 points or larger" (HIG Widgets). Dokunma alanı en az 44 pt'dir. Uygulama ve ana ekran widget'ı sistem görünümünü izler: açık modda Kâğıt, koyu modda Gece. Kilit ekranında zemini sistem çizer; bizim seçtiğimiz yalnız gri ton seviyeleri. *Neden:* loş bir laboratuvarda (yaklaşık 23 lux) açık zeminde koyu yazının kısa bakışta okunma eşiği %38,6 daha düşük çıktı; cevap süreleri ise farklı değildi (Dobres ve ark. 2016). Bu yüzden Gece temasında ikincil satırlar biraz büyür ve kalınlaşır (2.1). Apple küçük ekran için "uygulama gibi widget yapma" diyor.
11. **Sakin bir arkadaş gibi davranır.** Seri sayacı yoktur, kimse suçlanmaz, günde tek hatırlatma gelir, bir açılışta en çok bir sistem kartı çıkar, titreşim ve hareket azdır. *Neden:* bozulan seri, sonraki kullanımı azaltıyor (Silverman ve Barasch 2023). Apple aynı şey için birden fazla bildirim göndermemeyi söylüyor. Israrcı ve suçlayıcı metinler "karanlık desen" sayılıyor (Gray ve ark. 2018).
12. **Geri bildirim işe dairdir, kişiye değil.** "Doğrusu: borrow" denir, "Yanlış!" ya da "Harikasın!" denmez. *Neden:* kişiyi hedef alan geri bildirim çoğu zaman işe yaramıyor, hatta zarar veriyor (Kluger ve DeNisi 1996; Hattie ve Timperley 2007). Türkiye'deki sınav kültüründe "yanlış" puan kaybıyla eşleşiyor.

### 1b. Araştırmacıların ayrıldığı yerler ve karar

| Konu | Görüşler | Karar |
|---|---|---|
| "Bildim" düğmesi dolu mu olsun? | Rakip araştırması: dolu varsayılan olsun. Yorgunluk ve öğrenme araştırması: düğmeler eşit olsun, tasarım puanı etkilemesin. | **Eşit.** Dolu varsayılan yok. Zaten kendini puanlama yalnız bir hatırlama denemesinden sonra kalıyor (madde 3). Bugünkü mockup'ta `.grade.good` dolu; bu değişir. |
| Yeni kelimenin ilk puanı nereden gelsin? | Rakip: 1 + 3 düğme ya da "Zaten biliyordum / Yeni kelime". Öğrenme: Tanış + Hatırla, puan cevaptan gelsin. | **Tanış + Hatırla.** Ön yüzde düz bir "Bunu zaten biliyorum" düğmesi olur; bu, 3 gün sonra tek kontrol sorusu açar (kuralları 2.2'de). 1 + 3 düzeni yalnız dört düğme bir yerde kalırsa kullanılır [BELKİ]. |
| İlk karşılaşmada Dikkat kutusu | Yorgunluk: ilk görüşte tam açık. Öğrenme: yalnız tek satır. | **Tek satır** ("✕ two spoon → ✓ two spoons") ve "Neden?" dokununca açılır. Bu satır, ilk karşılaşmadaki tek uyarı yuvasına girer (2.2). Tam kutu ikinci karşılaşmada ve ilgili bir quiz yanlışından hemen sonra kendiliğinden açılır. Yanlış cümle hiçbir zaman tek başına durmaz. |
| Yanlış cevapta titreşim | Rakip: hafif uyarı titreşimi. Yorgunluk: hiç ya da çok hafif; `.error` asla. | **Titreşim yok.** Apple'a göre "error" bir hata olduğunu bildirir. Yanlış cevap hata değil, öğrenmenin parçası. |
| Bildirimde soru mu, bilgi mi? | Türkçe: "'borrow' ne demekti?", cevap uygulamada. Rakip ve yorgunluk: bildirim değer taşısın, cevabı saklamasın. | **Varsayılan bilgi taşıyan bildirim** ("borrow = ödünç almak"), ama Tekrar'da birazdan sorulacak bir kelimeyle değil (2.10). Soru biçimi yalnız cevap uzun basınca bildirimin içinde görünebiliyorsa kullanılır [BELKİ]. Cevabı geciken başarısız tahminin faydası kayboluyor (Hays, Kornell ve Bjork 2013). |
| Bildirim düğmeleri | Öğrenme: "Tekrar'ı aç" ve "Yarın". Apple: yalnız uygulamayı açan düğme koyma. | **Düğme yok.** Bildirime dokunmak zaten Tekrar'ı açar. |
| Görmezden gelinen hatırlatma | Yorgunluk: 3 gün. Rakip: 7 gün. | **İkisi birden, ama aynı anda değil.** 3 gün üst üste görmezden gelinirse saati değiştirmeyi sorarız. 7 gün olursa hatırlatmayı duraklatır ve bunu söyleriz; bu not 3 gün kartının yerine geçer. Bir açılışta tek sistem kartı çıkar (2.10). |
| Kilit ekranında hatırlama denemesi | Öğrenme: anlam önce gizli, 15 dakika sonra açılsın. Rakip ve Türkçe: kilit ekranı yalnız bilgi göstersin. | **Kilit ekranı yalnız bilgi gösterir.** Kilitliyken widget düğmesi çalışmıyor (Apple WidgetKit belgesi). Geciken cevap, yanlış tahminin faydasını yok ediyor. "Önce tahmin et" yalnız ana ekranda, düğmeyle ve cevap anında açılarak olur [BELKİ]. Bilgi gösterdiği için kilit ekranı, Tekrar'da birazdan sorulacak kelimeyi göstermez (2.1). |
| Ara sonrası kaç kelime? | Öğrenme: 10. Rakip: 20 ve günlük sınır. | **Tur en çok 10 soru.** Sonra "Bir tur daha" gelir. Pratik hiç kısıtlanmaz, ama büyük birikmiş sayı da gösterilmez. |
| Günlük yeni kelime varsayılanı | Bugünkü tasarım: 10. Öğrenme: A1–A2 için 5. | **Seviyeye göre:** A1–A2 için 5, B1 için 10. Bu varsayılan yalnız yeni kurulumlarda ve ayarı hiç değiştirmemiş kullanıcıda geçerli. Kendisi bir sayı seçmiş kullanıcının değeri korunur (2.9). Akış'ın bitiş kartı bu hedefe göre çıkar. |
| Widget ne sıklıkla değişsin? | Bugün: 5 dk – 2 saat, varsayılan 1 saat. Yorgunluk: saatte birden sık olmasın. Rakip: 2 saat, 4 saat, günde 1. | **30 dk · 1 saat · 2 saat · 4 saat. Varsayılan 1 saat kalır** (`AppPreferences.defaultRotationMinutes = 60`). Eski 5 ve 15 dk seçimleri 30 dk'ya taşınır (2.9). Yeni kelimenin widget'ta kaç kez görüneceğini slot bütçesi belirler (2.1). |
| Quiz çeldiricileri | Rakip (düşük güven): ilk kutularda ilgisiz şıklar olsun. Öğrenme: şıklar güçlü olmazsa hatırlama olmaz (Little ve ark. 2012). | **Yazılmış, aynı alandan çeldiriciler kalır.** Yalnız karışan eş (borrow için lend), o kelime henüz bilinmiyorsa (kutu 2'nin altında) çeldirici olmaz. **Tek istisna:** Hatırla'daki "Anlamını seç" sorusunun Türkçe şıkları başka kartların anlamlarından kurulur, çünkü yazılmış çeldiriciler İngilizce (2.3). |
| Widget koyu mu olsun? | `raporlar/14` ve rakipler: koyu, fotoğraflı. Yorgunluk: açık zemin daha hızlı okunur. | **Ana ekran widget'ı ve uygulama sistem görünümünü izler: açık modda Kâğıt, koyu modda Gece. Kilit ekranında zemin sistemin; bizim seçtiğimiz yalnız gri ton seviyeleri.** Fotoğraf yok. |
| Widget'ta yer yetmezse | Türkçe araştırmasında iki öneri çelişiyor: son çare anlamı gizleyip İngilizce tanımı göstermek, ama Türkçe anlam İngilizce tanımdan önce düşmemeli. | **İngilizce tanım hep önce düşer.** Türkçe anlam ancak kısa biçimi de (`gloss_short`, en çok 16 karakter) sığmazsa gizlenir. Bu neredeyse hiç olmaz. |
| Tur özetinde sayı | Öğrenme: "12 tekrar, 9'u ilk denemede". Türkçe: doğru/yanlış sayacı ve yüzde gösterme. | **"10 kelime çalıştın, 7 tanesini bildin." kalır.** Yanlış sayısı, yüzde ve net yok. Değişkenden sonra ek de yok ("9'u" yerine "7 tanesini"). |

### 1c. İlk sürüm listesi

En çok 10 iş, öncelik sırasıyla. Boy: S küçük (birkaç gün), M orta, L büyük. Sahibi: iOS ya da içerik. Etiketi [ÖNERİ] olan bir iş de burada olabilir; liste önceliği gösterir, kanıtı değil.

| # | İş | Boy | Sahibi | Bölüm |
|---|---|---|---|---|
| 1 | Şıkların sırası her denemede karışır. | S | iOS | 2.4 |
| 2 | Yeni kelime turu: Tanış + Hatırla. Puan cevaptan gelir, altta tek düğme, Hatırla'da en çok 2 deneme, Türkçe şık kuralı, "bir sonraki turda yine soracağız" metni. | L | iOS | 2.3 |
| 3 | Soru türü kutuya göre değişir. Kutu 4–5'te "Bulamadım / Buldum" hatırlama ekranı. Kayma kutu 1'e değil, iki kutu aşağı. | M | iOS | 2.4, 2.3 |
| 4 | "Biliyorum" ve "Bunu zaten biliyorum" → 3 gün sonra tek kontrol. Eski işaretlerin göçü, 5 saniyelik "Geri al". | M | iOS | 2.2 |
| 5 | Widget sırası: Tekrar'da birazdan sorulacak kelime widget'ta ve bildirimde gösterilmez. Açık slot bütçesi. 5 ve 15 dk → 30 dk göçü. | M | iOS | 2.1, 2.9, 2.10 |
| 6 | Kilit ekranı ve küçük widget: iki satır, opak gri tonlar, iki düğme, kelime sığdırma basamakları, SE görüntü testleri. | M | iOS | 2.1 |
| 7 | Türkçe anlam "…" ile kesilmez: `ViewThatFits` basamakları ve 83 kartlık `gloss_short` (önce `alt`'tan seçilir). | M | iOS + içerik | 2.1, 2.12 |
| 8 | Akış ilk karşılaşması: en çok 8 blok, tek uyarı yuvası, sahte dost tek satırı. ink2 koyulaşır, surface3 üstünde ink3 yazı yasak. | M | iOS | 2.2 |
| 9 | Bildirim görev ve sayı yerine kelime taşır. Bir açılışta tek sistem kartı. | S | iOS | 2.10 |
| 10 | Cihazda, yalnız yerel ölçüm kaydı ve kabul hedefleri. | S | iOS | 2.13 |

---

## 2. Ekran ekran öneriler

### 2.1 Widget (ana ekran ve kilit ekranı)

**Zaten doğru, koru:**
- [ŞART] Widget'a bakmak tekrar sayılmaz (`Leitner.markExposure`). Bakış, Leitner puanını hiç değiştirmez. Görmek hatırlamak değildir (madde 1).
- [ÖNERİ] Kilit ve ana ekran aynı kelimeyi gösterir. Rakip yorumlarında "kilit ekranıyla ana ekranı eşitle" isteği, widget denetimi istekleri arasında geçiyor (`raporlar/02`, istek tablosu 8. sıra, 27 anma).
- [ÖNERİ] Satır içi widget'ın kısalma basamakları ve "Yeni kelime: 10:00" yazımı (saatten sonra ek yok) kalır.
- [ÖNERİ] Widget'ın tonu hiç değişmez: kırmızı yok, geri sayım yok, "Bugün çalışmadın" yok. Duolingo'nun gece yarısına doğru "çaresizleşen" baykuşu (Duolingo blogu, widget yazısı) tam kaçınılacak örnek.
- [ÖNERİ] Renklendirilmiş, cam ve kilit ekranı modunda şerit, harflerin altından geçen ince tek renkli çizgi olur.

**Ana ekran, küçük widget:**
- [ŞART] **En çok 2 düğme: Dinle ve Sonraki.** "Biliyorum" küçük widget'tan çıkar ve orta widget ile uygulamaya taşınır. *Neden:* Apple, widget'taki düğmelere istenmeyen bir etkileşimi yanlışlıkla yapmadan dokunulabilmesini istiyor (HIG Widgets: "make sure people can tap … without accidentally performing unintended interactions"). iPhone SE'de küçük widget 148 pt, 16 pt kenar boşluğuyla 116 pt kalıyor. Üç tane 44 pt düğme 132 pt ve ara boşluk ister. İki düğme (2 × 44 + 12 = 100 pt) sığar. README'deki "Biliyorum · Dinle · Sonraki" sırası yalnız orta widget'ta kalır.
- [ŞART] **İçerik: kelime ve Türkçe anlam, başka bir şey yok.** Tür, seviye, tanım ve örnek çıkar. Mockup'ta küçük widget'ta 6 yazı katmanı ve 3 düğme var (12–12,5 pt satırlarla). Apple "bir bakışta okunur" ve "uygulama gibi düzen kurma" diyor (HIG Widgets).
- [ÖNERİ] **Kelime ve anlam sığdırma.** Kelime serif kalın 24 pt ile, anlam SF kalın 17 pt ile başlar. Yer yetmezse:
  - Kalıplar ve öbekler boşluktan ikinci satıra geçer, en çok 2 satır olur: "Could you tell me / the way to".
  - Tek kelime `ViewThatFits` ile 24 → 20 → 17 pt basamaklarından ilk sığana iner. Tire yok, "…" yok, `minimumScaleFactor` yok.
  - Türkçe anlam da aşağıdaki `gloss_short` basamaklarıyla kısalır.
  - *Neden:* İçerikte 11 ve daha çok harfli 22 tek kelime (misunderstanding, congratulate, intersection, prescription…) ve 11 ve daha çok karakterli 111 madde var (kalıplar dahil, ör. "Could you tell me the way to"). "under the weather · kendini pek iyi hissetmemek" gibi çiftler eski "toplam 6 kelime" sınırına da sığmıyordu; o sınır kalktı. Kaba hesabım: kalın serifte harf başına yaklaşık 0,5 em ile "misunderstanding" 17 pt'de bile yaklaşık 136 pt tutar, yani 116 pt'ye sığmayabilir. Görüntü testi bunu doğrularsa son basamak 15 pt olur (ana ekran tabanı). 15 pt'de de sığmayan kelime küçük widget sırasında atlanır; orta widget'ta, kilit ekranında ve uygulamada görünür. Kesilmiş kelime hiç gösterilmez.
  - SE görüntü testlerine "misunderstanding" ve "Could you tell me the way to" eklenir.
- [ÖNERİ] Düğme alanları arasında en az 8 pt boşluk olur. Her düğmenin Türkçe `accessibilityLabel`'ı olur: "Kelimeyi dinle", "Sonraki kelime".

**Ana ekran, orta widget:**
- [ÖNERİ] Kelime, Türkçe anlam, kısa İngilizce tanım (15 pt, `def.micro` ya da `def.short`) ve tek örnek. Örnek her zaman `examples[0]`, en çok 44 karakter. Toplam 25 kelimeyi geçmez. 15 pt ana ekran widget'ının tabanıdır (madde 10).
- [ÖNERİ] 3 düğme, simgelerin altında kısa yazıyla: "Biliyorum", "Dinle", "Sonraki". *Neden:* yalnız simgeden anlamı çıkarmak zor (NN/g). Geri alınamayan ✓ ile zararsız ⏭ bugün yalnız simgeyle ayrılıyor.
- [ÖNERİ] **"Biliyorum"dan sonra onay görüntüsü gelir.** Hemen yeni kelimeye geçilmez. Timeline bir sonraki kelimeye kadar şunu gösterir: "✓ Tamam", altında "3 gün sonra bir kez soracağız", yanında "Geri al" düğmesi. Monkey Taps'te beğenmeme düğmesinin hiçbir şey yapmadığı ve aynı kelimenin widget'ta tekrar ettiği şikâyeti var (`raporlar/03`). Görünür sonuç güven verir. Bu, tek bir rakip şikâyetine dayanan bir ürün seçimi.
- [ÖNERİ] Sahte dost kartında örnek satırının yerine fark gelir: "≠ aktüel (güncel)". Yanlış eşleşme en çok bir bakışlık okumada yanıltır.
- [BELKİ] Tek bir sakin bilgi satırı (ink2 rengiyle): "Tekrar: 4 kelime hazır" ya da "Yeni kelime: 10:00". Gövdeye dokununca tekrar varsa Tekrar açılır, yoksa kelimenin kartı açılır.

**Kilit ekranı (dikdörtgen ve satır içi):**
- [ŞART] **İki satır, üçüncü satır yok.** Birinci satır: kelime, 17 pt serif kalın, `.widgetAccentable()`. İkinci satır: Türkçe anlam, 15 pt SF yarı kalın, `.foregroundStyle(.secondary)`. Kilit ekranı widget'ı duvar kâğıdının üstünde, sistemin renklendirilmiş çiziminde görünür; zemini biz seçemeyiz, yalnız gri ton seviyesini seçeriz. Hiyerarşi saydamlıkla (`.opacity()`) kurulmaz: Apple "use opaque grayscale values, rather than opacities of white" diyor (HIG Widgets). Mockup'taki 12 pt serif, %80 beyaz tanım satırı kalkar. Eski önerideki 13 pt `def.micro` üçüncü satırı da kalkar: 934 karttan 329'unda `def.micro` 24 karakteri geçiyor ve SE'de bunların çoğu sığmıyordu.
- [ŞART] **Her zaman açık ekranda** (`isLuminanceReduced`) yazı tam gri tonunda kalır, şerit 1 pt çizgiye döner, ışıma olmaz. Apple bu durumda büyük dolu şekilleri çizgiye çevirmeyi öneriyor.
- [ŞART] **Kilit ekranında düğme yok ve Türkçe anlam gizlenmez.** Kilitliyken widget düğmeleri çalışmıyor; iPhone önce kilidin açılmasını istiyor (Apple WidgetKit belgesi).
- [ÖNERİ] Kilit ekranında kelime değişirken animasyon olmaz. Ana ekranda yalnız `.contentTransition(.opacity)` olur, en çok 0,35 sn.
- [ÖNERİ] AX boylarında dikdörtgen widget yalnız kelimeyi, küçük widget kelime ve anlamı gösterir.

**Türkçe anlamın widget'ta kısalması (bütün widget'lar):**
- [ÖNERİ] **Türkçe anlam hiçbir zaman "…" ile kesilmez.** Önce İngilizce tanım düşer. Sonra Türkçe anlam `ViewThatFits` ile şu sırayla kısalır: tam anlam → yalnız ilk eş anlam (virgülden sonrası düşer, "/" eşi kalır) → `gloss_short`. Türkçe anlam ancak bunların hiçbiri sığmazsa gizlenir. Örnek: disagree "aynı fikirde olmamak" sığmazsa "katılmamak" görünür, "aynı fikirde ol…" görünmez. 934 karttan 34'ünün anlamı 20 karakteri, 83'ünün anlamı 16 karakteri geçiyor; dikdörtgen widget'a 16–18 karakter sığıyor.
- [ÖNERİ] **İçerik kuralı: "/" ile "," ayrılır.** İngilizce tek kelimenin Türkçede iki ayrı karşılığı varsa " / " ile yazılır: "amca / dayı", "durmak / durdurmak", "değişmek / değiştirmek". Eş anlamlılar "," ile ayrılır. "/" sonrası hiçbir zaman düşmez, "," sonrası düşebilir. Bugün `InlineWordView.firstMeaning` (`AccessoryWordViews.swift:74-78`) ilk virgülde kesiyor. Bu yüzden widget "uncle · amca" ve "stop · durmak" gösteriyor ve kelimenin anlamını olduğundan dar öğretiyor (Degani ve Tokowicz 2010: birden çok karşılığı olan kelime daha zor öğreniliyor). İş: virgüllü 43 anlam tek tek ayıklanır; bugün yalnız 1 anlamda "/" var ("de / da"). uncle "amca, dayı" ve stop "durmak, durdurmak" bu 43'ün içinde (2.12).
- [ÖNERİ] Yeni içerik alanı: `l1.tr.gloss_short`. En çok 16 karakter olur ve editör yazar. Anlam 16 karakteri geçiyorsa doğrulayıcı bu alanı ister: bugün 83 kart. Editör önce `alt` listesine bakar; 63 kartta orada 16 karakteri geçmeyen bir aday zaten var (disagree → "katılmamak"). under the weather'ın `alt`'ındaki "biraz rahatsız olmak" kısaltılarak "biraz rahatsız" olur.
- [ÖNERİ] Görüntü testleri: SE boyutunda, varsayılan ve AX boylarında "aynı fikirde olmamak", "kendini pek iyi hissetmemek", "misunderstanding" ve "Could you tell me the way to" ile.

**Ne zaman, ne sıklıkla:**
- [ÖNERİ] **Widget cevabı Tekrar'dan önce vermez.** Bugün `QueueComposer` widget'ı 10 slotluk sabit bir düzenle dolduruyor: 6 tekrar, 3 yeni, 1 tazeleme (dosyanın başındaki açıklama). `ReviewPlanner` yalnız widget'ta görülen kelimeyi hâlâ yeni sayıyor. Yani kilit ekranı, sırası gelen kelimeyi Türkçesiyle, Tekrar sorusundan dakikalar ya da saatler önce gösteriyor. Madde 1'deki hatırlama böylece basit bir yeniden tanımaya döner. Tanış'taki "Tahmin et" de widget'ın zaten gösterdiği kelimede gerçek bir tahmin olmaz. *Neden:* hatırlamanın faydası, cevabı bulmak için harcanan emekle büyüyor (Pyc ve Rawson 2009; bu gözden geçirmede yeniden açılmadı). Kural:
  - (a) Tekrar'da önümüzdeki yaklaşık 6 saat içinde sorulacak kelime, o gün cevaplanana kadar widget'ta gösterilmez. Cevaplandıktan sonra pekiştirme olarak görünebilir. Aynı kural bildirimdeki kelime için de geçerlidir (2.10).
  - (b) Yeni kelimede sıra sabittir: önce widget, sonra Tanış. Widget'ta gösterilmiş yeni kelimenin Tanış ön yüzü "Widget'ta gördün. Hatırlıyor musun?" der ve anlam gizli kalır; bu, gerçek bir hatırlama denemesi olur. Widget'ta henüz görünmemiş kelimede ön yüz "Ne demek olabilir? Tahmin et." der. Öteki seçenek (önce Tanış, aynı gün widget tekrar eder) uygulamanın "kelime önce kilit ekranında" sözünü bozduğu için seçilmedi.
- [ÖNERİ] **Slot bütçesi.** 6/3/1 düzeni yerine açık bir bütçe kullanılır. Her 10 slotta:
  - 3 slot bugünün yeni kelimeleri (her biri günde en çok 2 ek görünüm);
  - 5 slot öğrenme kelimeleri: önce bugün Tekrar'da cevaplanmış olanlar; sabah henüz yoksa sırası en az 6 saat sonra gelenler;
  - 1 slot tazeleme;
  - 1 serbest slot: önce bugün yanlış cevaplanan kelimeler (yanlıştan sonra kelimeyi yeniden görmek sorun değil), yoksa öteki gruplardan biri.

  Uyanık 16 saat varsayımıyla günlük dağılım:

  | Değişme sıklığı | Günlük slot | Bugünün yeni kelimeleri | Öğrenme | Tazeleme | Serbest |
  |---|---|---|---|---|---|
  | 30 dk | 32 | 10 | 16 | 3 | 3 |
  | 1 saat (varsayılan) | 16 | 5 | 8 | 2 | 1 |
  | 2 saat | 8 | 2 | 4 | 1 | 1 |
  | 4 saat | 4 | 1 | 2 | gün aşırı 1 | gün aşırı 1 |

  Sonuç: 1 saatte günde 5 yeni kelimenin her biri widget'ta yaklaşık bir kez görünür. B1'in 10 yeni kelimesinin yarısı o gün widget'a hiç çıkmaz; onlar Tanış'ta "Tahmin et" ön yüzüyle gelir. Bir yeni kelimenin aynı gün iki kez görünmesi ancak 30 dk seçiminde ve günde 5 yeni kelimede olur. Eski "aynı gün 2–3 kez" sözü bu slotlara sığmıyordu: 1 saatte 5 × 3 = 15 slot, günün neredeyse hepsi.
- [BELKİ] **Yeni kelimenin aynı gün widget'ta yeniden görünmesi bir ürün seçimidir.** Yalnız görerek öğrenmede bir kelimenin kaç karşılaşmaya ihtiyaç duyduğu bu alandaki meta-analizden çıkmıyor; Uchihara, Webb ve Yanagisawa (2019) için daha önce yazılan "2 ile 20 arası", çalışmalardaki en yüksek tekrar sayılarının aralığıydı (ikinci el özetlerden).
- [ÖNERİ] **Kişisel konular kilit ekranına varsayılan olarak çıkmaz.** Ön koşul: `tags.sensitivity` etiketlemesi. Bugün 934 kartın hepsi 0, yani "1 ve üstü kartları gizle" kuralı hiçbir şey yapmıyor. İlk örnekler arasında "I saw my ex…", "I have a crush on…" ve "They got divorced…" var. İçerik ekibi bu alanı doldurur (ilişki, ayrılık, beden, alkol). 1 ve üstü kartlar kilit ekranında ve orta widget'ta varsayılan olarak gösterilmez, Akış'ta ve Tekrar'da kalır. Etiketleme bitene kadar geçici süzgeç: örnek cümlesinde ex, crush, divorce, breakup ya da drunk geçen kart 1 sayılır. Bu süzgeç bugün yalnız 4 kartı yakalıyor (ex, crush, divorce, break up); etiketlemenin neden ön koşul olduğunu bu da gösteriyor. (Kilit ekranını ailenin ya da iş arkadaşlarının görebilmesi bir çıkarım, kaynaklı bir bulgu değil.)
- [ÖNERİ] **Görünüm.** Ana ekran widget'ı ve uygulama sistem görünümünü izler: açık modda Kâğıt, koyu modda Gece. Kilit ekranında zemin sistemin; bizim seçtiğimiz yalnız gri ton seviyeleri. Widget'ı zorla koyu yapmak yok, fotoğraf zemin yok. Fotoğraflı zemin renklendirilmiş, cam ve StandBy modunda düzgün çalışmıyor ve yazının kontrastını belirsiz bırakıyor. Koyu mod bir tercih; açık modda okuma çoğu kişi için daha kolay (NN/g koyu mod).
- [BELKİ] Yalnız yazıyla kurulan 2–3 tema: Kâğıt, Gece, Yüksek kontrast. Temalar yalnız zemin ve mürekkep tonlarını değiştirir. Her biri tam renk modunda en az 4,5:1 kontrast verir. Gece temasında ikincil satırlar bir kalınlık basamağı ve 1–2 pt büyür. Bu, `raporlar/14`'teki "widget düz ve gri" eksiğine fotoğrafsız bir cevap.
- [BELKİ] **"Önce tahmin et" modu** yalnız ana ekranda, isteğe bağlı ve varsayılan olarak kapalı. Türkçe anlamın yerinde "Türkçesi?" düğmesi (App Intent) durur. Dokununca anlam o kelime değişene kadar açık kalır. Yalnız öğrenme kelimelerinde kullanılır; yeni kelimede anlam hep görünür. Yukarıdaki (a) kuralı bu modda da geçerli. Dokunmak Leitner puanı değildir, en çok zayıf bir "görüldü" işareti olur.

### 2.2 Akış kelime kartı

**Zaten doğru, koru:**
- [ŞART] Okuma sırası: kelime → Türkçe anlam (28 pt kalın) → İngilizce tanım → örnek. Hiçbir kısalma basamağı Türkçe anlamı İngilizce tanımdan önce küçültmez ya da gizlemez (madde 6, Kim, Lee ve Lee 2024).
- [ÖNERİ] Etiketli "Dinle" kapsülü, italiğin kaldırılması, "İngilizce serif, Türkçe SF" kuralı, kart içinde kaydırma olmaması, sayaç ve sayfa noktası olmaması.
- [ÖNERİ] Fotoğraf ve süs görseli yok. Bu doğru. "İkinci kod" bütçesi sese (Dinle) harcanır. Orbit'teki ruh hali fotoğrafları ve "petrichor, sonder" gibi nadir kelimeler A1–B1 öğrenciye uymaz.

**Değiştir ve ekle:**
- [ÖNERİ] **Kart, öğrenme aşamasına göre açılır.** Kural 5'in ("kart sondan kısalır") yanına yeni bir kural: kelimenin kaçıncı kez görüldüğü (`WordProgress`) neyin görüneceğini belirler.
  - *İlk karşılaşma: en çok 8 blok ve tam olarak bir uyarı yuvası.*
    1. kelime ve şerit;
    2. tek meta satırı (IPA · tür · seviye, 13–15 pt);
    3. düğme satırı: Dinle, Söyle ve Biliyorum (tek satır, tek blok; README'deki "Akış'a Biliyorum" sorusunun cevabı da burası);
    4. Türkçe anlam;
    5. kısa İngilizce tanım (A1–A2 kartında `def.micro`, B1 kartında `def.short`);
    6. tek örnek (`examples[0]`);
    7. örneğin Türkçesi;
    8. uyarı yuvası: tek satır.
  - **Uyarı yuvası öncelik sırasıyla dolar:** sahte dost > Dikkat > okunuş etiketi > iki karşılık satırı ("İngilizcede ikisi de: uncle") > kalıp fiil satırı. Yuvaya giremeyen her şey ikinci karşılaşmaya ya da Sözlük'e gider.
  - *İkinci karşılaşmadan sonra:* `def.short`, tam Dikkat kutusu, sırayla öteki örnekler ve yuvaya giremeyen satırlar.
  - "Ayrıca: …" satırı ve eşdizimler (collocations) Sözlük ayrıntısına taşınır.

  *Neden:* madde 5. Bugünkü kartta ilk bakışta 10–13 öğe var. Bu belgedeki öteki önerilerin her biri ilk görüşe bir satır eklese (sahte dost, okunuş etiketi, iki karşılık, kalıp fiil, Biliyorum) sayı yine 12–14'e çıkardı. Bu yüzden sınır blok sayısıyla konur.
- [ÖNERİ] **Dikkat iki katmanlı olur, üçüncü katman yok.** Kartta tek satır görünür: "✕ two spoon → ✓ two spoons" ve "Neden?". "Neden?"e dokununca alt sayfa açılır (`.presentationDetents([.medium, .large])`). Bu sayfada açıklama, öteki hatalar, eşdizimler ve başka örnekler durur. Sayfadan yeni bir sayfa açılmaz. Tam kutu yalnız iki durumda kendiliğinden açılır: ikinci karşılaşmada ve quiz'de bu kurala bağlı bir yanlıştan hemen sonra.
- [ŞART] **Sahte dost.** `equivalence == false_friend` olan kartlarda uyarı yuvasına ilk bu girer, tek satır olarak: "aktüel ≠ actually · aktüel = current". Üç satırlık açıklama "Neden?" sayfasına taşınır:
  - "Sahte dost: aktüel ≠ actually"
  - "aktüel = güncel → current"
  - "actually = aslında"

  Renk tek başına anlam taşımaz; "≠" işareti ve kelimeler kullanılır (kural 4; WCAG 1.4.1). `CardDetail.falseFriend` bugün okunuyor ama hiçbir ekranda gösterilmiyor. *Neden:* madde 7 (Laufer ve Girsai 2008). Ayrıca Dikkat için `mistakes.first` yerine, yanlış ya da doğru cümlesinde başlık kelimesi geçen hata seçilir. "actually" kartında bugün sıfat hatası ("The actual price…") öne çıkıyor.
- [ÖNERİ] **Eksik kelime hatası görünür olur.** Türklerin sık hatalarından biri eksik "a / the / to" (Türkçede tanımlık yok, edat yerine ek var; Yılmaz 2006). Bugünkü kelime farkı bunları işaretleyemiyor: 693 hatadan 73'ünde yanlış cümlede hiçbir işaret yok.
  - Yanlış cümlede boşluğa "‸" konur: "I listen ‸ music every day". VoiceOver bunu "eksik kelime" diye okur.
  - Doğru cümlede eklenen kelime kalın ve altı çizili olur: "I listen **to** music every day".
  - 5 ya da daha çok kelimelik yeniden yazımda kelime farkı gösterilmez; iki cümle bütün olarak durur.
  - İçerik için yeni alan: `mistakes[].kind` (article, preposition, word_order, countable, verb_choice, false_friend, tense). 693 hatanın hepsi için (2.12).
- [ÖNERİ] İngilizce cümlenin içindeki Türkçe notlar dışarı çıkar. "Actually I'm studying English. (= şu anda)" yerine İngilizce cümle tek başına durur, yanında Türkçe bir küçük etiket olur: "şu anda demek istiyorsan". Bugün bu notlar serif yazıyla ve İngilizce sesle okunuyor (8 cümle).
- [ÖNERİ] **Yazı boyu tabanı** (iPhone SE referans cihaz, varsayılan "Large" boy). Bu sayılar Lockglow'un kendi seçimi, Apple kuralı değil:

  | Ne | Bugün | Olacak |
  |---|---|---|
  | İngilizce örnek | 17 pt serif | 18 pt serif |
  | Dikkat yanlış ve doğru cümle | 16 pt serif | 18 pt serif |
  | Dikkat "Neden" (Türkçe) | 15 pt, ink2 | 16 pt, ink |
  | Örneğin Türkçesi | 16 pt | 16 pt (kalır) |
  | İngilizce tanım | 20 pt serif | 20 pt serif (kalır) |
  | 11–12 pt | çeşitli | yalnız meta: seviye noktaları, sekme yazısı, "Yeni kelime: 10:00" |

  Boylar `@ScaledMetric` ile Dinamik Tür'e bağlanır. *Neden:* telefonu ortalama 32–36 cm'den okuyoruz (Bababekova ve ark. 2011; PubMed sayfası açılamadı, doğrulanmadı). Rahat okuma için x-yüksekliği en az 0,2° olmalı (Legge ve Bigelow 2011). 34 cm'de bu yaklaşık 1,19 mm eder. İngilizce yazı New York (`.serif`) ile dizildiği için hesap onun x-yüksekliğiyle yapılmalı, eski taslaktaki SF Pro ölçüsüyle değil. x-yüksekliği 0,52 em ise eşik yaklaşık 15 pt, 0,45 em ise yaklaşık 17 pt eder (163 pt/inç ile); iki oran da varsayım. Cihazda `UIFont` serif gövde boyunda `xHeight / pointSize` ölçülür ve sonuç buraya yazılır. Daha büyük yazının ekranda okunmayı kolaylaştırdığı da ayrıca gösterildi (Rello, Pielot ve Marcos 2016; özet).
- [ÖNERİ] **Kelime asla sıkıştırılmaz ve kesilmez.** `.lineLimit(type == .word ? 1 : 2)` olur. `.minimumScaleFactor` 0,6 değil 0,75 olur. Kalıplar kelime sınırından ikinci satıra geçer, "…" olmaz ("Could you tell me the way to" bugün kesiliyor). Negatif harf aralığı (`.tracking`, `.kerning`) ve `.allowsTightening(true)` kullanılmaz; mockup'taki −0,012 em kalkar (Perea, harf aralığı; 2011 sonuçları okunmadı). AX boylarında kelimenin üst sınırı 56–60 pt olur. Widget'taki basamaklar için bkz. 2.1.
- [ÖNERİ] Satır aralığı: tanımda `.lineSpacing(5)`, örnekte, Dikkat cümlelerinde ve "Neden"de `.lineSpacing(4)`. Bu yaklaşık 1,45–1,5 satır aralığı verir. İki ve daha çok satırlık yazı sola dayalı olur; ortalanmaz, iki yana yaslanmaz (WCAG 1.4.8).
- [ŞART] **Kontrast tabanı.** Her yazı en az 4,5:1 verir (WCAG 1.4.3, AA). ink3 rengi surface3 üstünde yazı olarak kullanılmaz: açık temada ink3 #626A71 / surface3 #DEDED6 = 4,06:1, koyu temada ink3 #8E959B / surface3 #30353B = 4,08:1. İkisi de AA'nın altında (benim hesabım).
- [ÖNERİ] **Küçük yazıda 7:1.** 11–13 pt yazı için hedef 7:1 (Lockglow seçimi; WCAG 1.4.6 AAA ile aynı oran). Bugünkü ink2 #4E555B sayfa zemininde (#F3F3EE) 6,8:1, gri kapsülde (surface2 #EBEBE4) 6,3:1 veriyor; yani eski taslağın "11–13 pt ink2 sayfa zemininde durabilir" kuralı kendi hedefini tutmuyordu. ink2 #474E54'e koyulaşır: sayfa zemininde 7,6:1, surface2'de 7,05:1, surface3'te 6,25:1 (benim hesabım). ink3 yalnız simge, nokta ve 17 pt üstü yazıda kullanılır. Yüksek Kontrast açıkken ink2 → ink, ink3 → ink2, çizgi %10 → %22 olur ve her gri kapsül 1 pt kenar alır. Kullanılan bütün renk çiftleri bir birim testiyle ölçülür.
- [ÖNERİ] **Sarı yalnız öğrenilecek kelimede.** Şerit ve örnek cümledeki `examples[].focus` parçası sarı olur. Lemma eşleştirmesi yerine `focus` alanı kullanılır, böylece çekimli biçimler de doğru boyanır. Koyu temada ana düğme sarı değil açık mürekkep olur (`#F3F4F0`, yazı `#15181B`). Işıma en çok %15–20 olur ya da hiç olmaz; Yüksek Kontrast, Saydamlığı Azalt ve `isLuminanceReduced` açıkken ışıma kapanır. README'deki kural 1 ve 77. satırdaki "Gece… ana düğme fosfor sarısıdır" bu yüzden değişir. *Neden:* göze çarpan yazı, çevresindeki yazının daha az okunmasına yol açıyor (Choi 2017). Koyu ekranda iki sarı odak birbiriyle yarışıyor.
- [ÖNERİ] **Dinle'deki sonsuz nabız animasyonu kalkar.** Ses çalarken simge dolu `speaker.wave.2` olur ve yazı "Durdur" olur. Okunan yazının yanında sürekli hareket dikkati dağıtır.
- [ŞART] **"Biliyorum" artık "büyük ihtimalle biliyorum" demek.** Kelime widget sırasından çıkar, ama 3 gün sonra tek bir kontrol sorusu gelir. Dört kural:
  1. *Soru türü:* kutu 4–5'teki hatırlama sorusu (Türkçe → İngilizce, "Göster", "Bulamadım / Buldum"; 2.3). 4 şıklı soru kullanılmaz: 4 şıkta, bilinmeyen 4 kelimeden biri tahminle geçer.
  2. *Beklerken:* `knownOverride = true`, `dueAt` = şimdi + 3 gün.
  3. *Sonuç:* "Buldum" → kelime bilinenlere geçer, 30 gün sonra tazeleme. "Bulamadım" → kutu 1 ve sıradaki Tanış'a girer: "Bu kelime öğrenme listene döndü."
  4. *Göç:* eski `markKnown` ile işaretlenmiş kelimeler (30 gün saklanan, hiç sınanmamış) bir sonraki `dueAt` tarihinde bir kez bu soruyu alır.

  Uygulama içindeki onay için yeni bir bileşen yapılmaz. Bugünkü 5 saniyelik "Geri al" bildirimi (`Leitner.undoKnown`) kullanılır, metni "Tamam. 3 gün sonra bir kez soracağız." olur. *Neden:* bugün `Leitner.markKnown` hiç sınanmamış bir kelimeyi 30 gün saklıyor. Kendi seçimiyle kart bırakmak öğrenmeyi azaltıyor (Kornell ve Bjork 2008). Bir süre sonra verilen "biliyorum" kararı, hemen verilenden çok daha doğru (Nelson ve Dunlosky 1991; künye ikinci el).
- [ÖNERİ] **Günün sonu kartı.** Günlük yeni kelime hedefine (ör. 10) gelinince akışa bir kart eklenir; bu bir pencere değil, sıradaki karttır:
  - Başlık: "Bugünlük 10 yeni kelime yeter."
  - Alt satır: "Yarın kilitli ekranında yenileri olacak."
  - Düğmeler: "Tekrar'a geç (4)" (dolu) ve "Devam et" (kenarlı).

  Devam etmek her zaman serbesttir ve suçlayıcı metin yoktur. Bu karttan sonra görülen kartlar o gün yeni kelime sırasına eklenmez. Kart günde en çok bir kez çıkar. Aynı açılışta başka bir sistem kartı çıktıysa bu kart bir sonraki açılışa kalır (2.10). *Neden:* sonu olmayan akış hedefli işe uymuyor (NN/g). Duolingo'da bir oturumda çok fazla ders yapanların uygulamayı bırakma ihtimalinin daha yüksek çıktığı söyleniyor (doğrulanmadı, kaynak bulunamadı).
- [ÖNERİ] **Türkçe anlam satırı sadeleşir.** Büyük satırda ilk eş anlam ve varsa "/" eşi görünür ("amca / dayı"). İngilizce kelimenin iki Türkçe karşılığı varsa "İngilizcede ikisi de: uncle" satırı uyarı yuvasına adaydır; yuva doluysa ikinci karşılaşmada görünür. "Ayrıca: doğrusu, esasında" gibi listeler Sözlük ayrıntısına gider. Bugün "actually" kartında 4 Türkçe karşılık var.
- [ÖNERİ] **Okunuş yardımı.** Etiketler uyarı yuvasına adaydır (öncelikte sahte dost ve Dikkat'ten sonra):
  - Sessiz harfli kelimelerde küçük bir etiket olur: "okunmayan harf: l" (walk, talk, listen, know, island, receipt, honest, autumn, Wednesday).
  - Türkçeye geçmiş kelimelerde de etiket olur: "Türkçedeki balkon gibi değil: vurgu başta" (balcony, museum, hotel ve 30 benzer kart).
  - Türkçe içerik metinlerinde vurgu için BÜYÜK HARF kullanılmaz. Dil ayarı olmadan büyük harfe çevirmek "i"yi "I" yapıyor ve Türk okur bunu "ı" diye okuyor (Unicode büyük harf kuralları). Vurgu kalın yazıyla yapılır.
- [BELKİ] Türkçe harflerle okunuş alanı `l1.tr.say`. Belirsiz ünlü için "ı" kullanılır (Demirezen 2010) ve vurgulu hece kalın olur: receipt "ri-**sit**", island "**ay**-lınd". Türkçe yazı sesle neredeyse birebir olduğu için Türk okur yazıyı harf harf okur (Öney ve Durgunoğlu 1997). Akış'ta Dinle'nin yanında "Okunuşu: …" diye görünür, IPA ikinci satıra iner. th, w/v ve æ yeniden yazılmaz (Türkçe harfler bunları gösteremez); onlar için Dinle ve Söyle ipuçları kullanılır. Bugün okunuş yazımları karışık: hem "aylınd" hem "BAL-kuh-ni" var.
- [BELKİ] Aynı örnek önce, farklı örnekler sonra. `examples[0]` kelimenin ilk karşılaşmasında sabit bağlamdır (Akış, Tanış, orta widget). `examples[1]` ve `[2]` sonraki karşılaşmalarda, kutu 2–3 sorusunda (2.4'teki kurala uyarsa) ve Sözlük'te kullanılır (Hulme ve ark. 2023; bağlam çeşitliliği taraması 2025).
- [BELKİ] Kalıp fiiller: "iki kelimeli fiil" etiketi "kalıp fiil" olur (look forward to gibi 3 kelimelik 9 kart var). Şerit kalıbın tamamını kaplar. Nesnenin yeri `separable` ve `inseparable` bayraklarından gösterilir: "wake [birini] up", "look after [birini]". Karşılaştırma satırı ("Türkçede tek fiil: kalkmak → İngilizcede iki parça: get up") uyarı yuvasının son adayıdır. Türk öğrenciler kalıp fiillerden kaçınıyor ve onları ana dili İngilizce olanlardan az kullanıyor (Akbulut 2018; Badem ve Şimşek 2021).

### 2.3 Tekrar (yeni kelime turu)

**Zaten doğru, koru:**
- [ÖNERİ] **Önce kelime, sonra anlam** düzeni ("Anlamını görmek için dokun"). Tanımları ve yabancı karşılıkları sesli ya da yazılı tahmin etmek, hemen ardından geri bildirim gelince öğrenmeye yardım etti (Potts ve Shanks 2014). Kornell, Hays ve Bjork (2009) ise ilişkili ipuçları ve bilgi sorularıyla çalıştı. Biçimle anlamın ilgisiz olduğu yeni yabancı kelimelerde kanıt karışık: Grimaldi ve Karpicke (2012) ilgisiz kelime çiftlerinde fayda bulmadı. Bu yüzden geri bildirim hep hemen gelir.
- [ÖNERİ] Düğmelerdeki süreler `Leitner.review(…).dueAt` ile hesaplanır, elle yazılmaz.
- [ÖNERİ] Tur sırasında sekme çubuğu gizlenir ve "Bitir" düğmesi kalır.
- [ÖNERİ] **Yanlıştan sonraki metin değişir:** "Bu kelime 10 dakika sonra yine gelir." yerine "Bu kelimeyi bir sonraki turda yine soracağız." Uygulama günde tek bildirim gönderiyor ve tur 10 soruda bitiyor; 10 dakika sonra kullanıcıyı geri getiren bir şey yok. Tutulamayan bir zaman sözü verilmez.

**Değiştir ve ekle:**
- [ŞART] **Yeni kelime turu iki adımlı olur: Tanış ve Hatırla.** (madde 2, Rawson ve Dunlosky 2011)
  1. *Tanış* (en çok 5 kelimelik parti):
     - Ön yüz: kelime, şerit, Dinle; anlam gizli. Widget'ta görülmüş kelimede "Widget'ta gördün. Hatırlıyor musun?", görülmemişse "Ne demek olabilir? Tahmin et." (2.1, kural b).
     - Altta tek düğme, hep aynı yerde: "Anlamını göster"e dokununca yazısı "Sonraki" olur. Başparmak yer değiştirmez.
     - Arka yüz: kartın ilk karşılaşma hâli (2.2, en çok 8 blok).
     - Tanış'ta cümle yazdırma ya da kelimeyi puanlatma gibi anlam görevi yok. Biçim öğrenilirken verilen anlam görevi biçimi öğrenmeyi zayıflatıyor (Barcroft, TOPRA; yazarın web sayfası, özet).
  2. *Hatırla* (hemen ardından, karışık sırayla): her kelimeye bir tane 4 şıklı soru sorulur.
     - Üstte "Şimdi hatırla" etiketi ve şu satır olur: "Şimdi hatırlıyor musun, bakalım."
     - Soru türleri dönüşümlü gelir: "İngilizcesini seç" (ödünç almak → borrow / lend / …; şıklar yazılmış çeldiriciler) ve "Anlamını seç" (borrow → ödünç almak / …; şıklar aşağıdaki kuralla).
     - **Türkçe şık kuralı.** `quiz.distractors` İngilizce. Bunların yalnız %62'si (2.802'den 1.737'si) mevcut bir kartın lemması; yaklaşık %38'inin Türkçe karşılığı yok. Bu yüzden Türkçe şıklar başka kartların anlamlarından gelir: aynı `primary_topic` ve aynı `pos`. Bu yetmezse (bugün 59 kartta aynı konu ve türden 3 farklı anlam yok) aynı `pos` ve aynı seviye. `confusable:X` eşi, kendisi kutu 2'nin altındayken şık olmaz. Aynı anlamı taşıyan iki şık hiç birlikte gelmez. Bu, 1b'deki "Yazılmış çeldiriciler kalır" kuralının tek izinli istisnasıdır.
     - **Yanlışta en çok bir deneme daha.** Yanlış cevaplanan kelime 3–4 kart sonra, şıkları yeniden karışmış olarak bir kez daha gelir. Geride 3'ten az kart kaldıysa sona konur. İkinci yanlıştan sonra cevap kartı gösterilir ve kelime yeniden öğrenmeye gider (kutu 1, `relearnDelay`; pratikte bir sonraki tur). Döngü sonsuz değildir.
  3. Puan cevaptan gelir:
     - İlk denemede doğru = Bildim (kutu 1, yarın).
     - Yanlıştan sonra doğru = Zor (12 saat sonra).
     - İki yanlış = Bilemedim (kutu 1, bir sonraki tur).
     - "Bu kelimeyi ne kadar bildin?" sorusu ve dört düğme yeni kelimede kalkar.
  - Halka ve "bugünkü hedef" yalnız Hatırla'yı geçen kelimeleri sayar.
  - Başlangıç kartı: "Bugünün yeni kelimeleri: 5" / "Önce tanış, sonra hemen bir kez hatırla." / "Başla (5 kelime)".
  - B1'in günde 10 yeni kelimesi iki partiye bölünür. İkinci parti "Bir tur daha" ile önerilir. Öğrencinin kendi hızında ilerlediği kısa parçalar, tek uzun bölümden daha iyi öğretiyor (Mayer ve Pilegard, bölümleme).
  - Bugünkü "Her kelimeye bak, anlamını gör, sonra ne kadar bildiğini seç." metni kalkar.
- [ÖNERİ] **"Bunu zaten biliyorum"** Tanış ön yüzünde, "Anlamını göster"in üstünde düz bir düğme olur. Kelime Hatırla'ya girmez ve 3 gün sonra tek bir kontrol sorusu gelir (2.2'deki dört kural). Bu bir ürün seçimi: bilinen kelimelerde öğrencinin işini azaltır. Gecikmeli kontrol de anlık kanaatten daha doğru sonuç verir (Nelson ve Dunlosky 1991).
- [ŞART] **Kendini puanlama yalnız bir hatırlama denemesinden sonra.** (madde 3)
  - Quiz'de doğru cevaptan sonraki "Zordu / Kolaydı" kalır ve isteğe bağlıdır. Bunlara dokunmak puanı kaydeder ve bir sonraki soruya da geçer; fazladan dokunma olmaz. "Zor" artık "bilemedim" gibi okunamaz, çünkü yalnız doğru cevaptan sonra çıkar. Bu, Anki kullanıcılarının bilinen "Zor'u başarısızlık sanma" sorununu da çözer (Anki forumu). Hatırla adımında "Zordu / Kolaydı" gösterilmez.
  - Kutu 4–5 hatırlama ekranı: soru "ödünç almak → ?". "Göster"e basınca hedef kelime büyük yazılır ve yanında Dinle durur. Düğmelerin üstünde "Göstermeden önce aklına geldi mi?" satırı, altta "Bulamadım" ve "Buldum". *Neden:* öğrenciler kısmen doğru hatırlamayı da doğru sayıyor (Dunlosky ve Rawson 2012); soru, denemenin cevap görülmeden önce olduğunu hatırlatır.
- [ÖNERİ] "Bulamadım" ve "Buldum" iki eşit düğmedir. Dolu varsayılan yoktur, sıra soldan sağa başarısızdan başarılıya gider. Yükseklikleri şıklarla aynıdır (bugün 56 pt; 2.4).
- [BELKİ] Kutu 4'teki ilk hatırlama sorusunda bir kerelik not: "Kelimenin yalnız bir kısmı geldiyse 'Bulamadım' seç." Dunlosky ve Rawson'ın (2012) bulgusu yönünde; etkisi denenmedi.
- [BELKİ] Dört puan düğmesi bir yerde kalırsa düzen 2×2 değil 1 + 3 olur. Üstte tek başına "Bilemedim · bir sonraki tur" (kenarlı, ↺ simgeli), en az 12 pt boşluk, altında eşit üç düğme: "Zor ama bildim · 12 saat" | "Bildim · yarın" | "Kolay · 2 gün". Bugünkü 2×2'de "Bilemedim" ile "Zor" aynı satırda "olumsuz çift" gibi duruyor.
- [ÖNERİ] **Yeni kelimeler ve tekrarlar tek turda karışır.** Yeni kelimenin Hatırla sorusu 3–4 başka karttan sonra gelir; bu doğal bir aralık olur. Yanlış cevaplanan kelime hiçbir zaman hemen bir sonraki kart olmaz; oturum içinde bile aralık vermek, art arda tekrardan daha iyi öğretiyor (Kornell 2009). Tur en çok 10 soru sürer (Tanış kartları hariç). Sonra "Bir tur daha" ve "Bugünlük bu kadar" seçenekleri gelir. Telefon kullanımının çoğu zaten kısa oturumlardan oluşuyor (Ferreira ve ark. 2014). Tur boyunun öğrenmeyi hızlandırdığı söylenmez; bu yalnız bir rahatlık ayarıdır (Nakata ve Webb 2016).
- [ÖNERİ] **Karışan kelimeler aynı gün yeni gelmez.** `ReviewPlanner.newWords` ve `QueueComposer` için kural: bir kelime çiftinin ikincisi, birincisi kutu 2'ye ulaşınca gelir. Çiftlerin kaynağı elle yazılmış bir liste değil, `tags.flags` içindeki `confusable:X` bayraklarıdır. Bugün 136 kartta 139 bayrak var (borrow → lend, date → appointment, stop → wait…); 95'inin hedefi mevcut bir kart. İçerik ekibi eksikleri ekler: actually/currently, get up/stand up ve receipt/recipe'de bayrak yok; appointment → date karşılıklı değil; fit/suit için suit kartı yok (2.12). Aynı dar alandan (kaşık, çatal, bıçak) günde en çok 1–2 yeni kelime gelir; konu karışımı ("kahvaltı": breakfast, hungry, toast) serbesttir. İkisi de kutu 2 ve üstüne gelince art arda sorulur ve birbirinin çeldiricisi olur. Mockup'taki yeni kelime destesinde date ve appointment aynı gün geliyor; bu değişir.
- [ÖNERİ] **Kayma kuralı.** Bugün `Leitner.review(.again)` kelimeyi her kutudan kutu 1'e indiriyor. Yeni kural: kutu k'daki kelime yanlışta en çok iki kutu iner (kutu max(1, k − 2)) ve bir sonraki turda yine sorulur. Tazelemede yanlış cevaplanan bilinen kelime kutu 3'e iner. Bu bir ürün seçimi, kanıta dayanmıyor. Planlanan FSRS, kaymadan sonraki aralığı kullanıcının kendi verisinden öğrenecek. Duolingo'da veriden öğrenen bir modelin, sabit kutulardan daha iyi tahmin ettiği gösterildi (Settles ve Meeder 2016).
- [ÖNERİ] **Aradan sonra dönüş.** Bekleyen tekrar 20'yi geçiyorsa başlangıç kartı şöyle olur:
  - "Ara verdin, sorun değil."
  - "Unutulmaya en yakın 10 kelimeyle başlayalım."
  - "Başla (10 kart)"

  Büyük sayı, kırmızı ve "gecikti" sözü yok. Bu kart bir sistem kartıdır: aynı açılışta duraklatma notu ya da saat sorusu çıktıysa ilk iki satır gösterilmez, yalnız "Başla (10 kart)" kalır (2.10). Kalan kelimeler "Bir tur daha" ile ya da sonraki günlerde gelir. Birikim bir günlük işin altına inene kadar yeni kelime önerilmez, ama bunu engel gibi söylemeyiz: "Yeni kelimeler, tekrarlar azalınca geri geliyor." Tur ortasında "Bitir"e basınca bütün cevaplar kaydedilir ve kısa bir özet çıkar: "3 kelime çalıştın. Kalanlar burada seni bekliyor."
- [ÖNERİ] **Tazeleme aralığı her doğru cevapta uzar:** 30 → 60 → 120 gün. Bugün `Leitner.refresherDelay` hep 30 gün. Bu, planlanan FSRS'e kadar geçici çözümdür. Tazelemelerin her ay büyüyen yükünü de azaltır (madde 9). *Neden:* en iyi aralık, hatırlama süresi uzadıkça büyüyor (Cepeda ve ark. 2008). İkinci dil kelimelerinde de aralıklı çalışma gecikmeli testlerde daha iyi sonuç verdi (Kim ve Webb 2022).
- [ÖNERİ] **Tanış'ta sesli söyleme daveti** (yeni kelimeler ve yeni unutulanlar için): "Bir kez sesli söyle. Mikrofon isteğe bağlı." Davet 5 karttan yalnız 1'inde çıkar; Söyle düğmesi her kartta kalır. Faydayı söylemenin kendisi verir, tanıyıcının sonucu değil. Kelimelerin yalnız bir kısmı sesli söylenince fark oluşuyor (MacLeod ve ark. 2010).
- [ÖNERİ] **Dokunma bütçesi.** Her akışın bir dokunma sınırı var. Bugün yeni kelime yaklaşık 2 dokunma (göster + puan). Tanış + Hatırla bunu 4'e çıkarıyor; fazladan 2 dokunma hatırlamanın kendisi. Sınırı aşan her yeni öğe (davet, ek düğme) bir başkasını çıkarır.

  | Akış | Bugün | Yeni | Bütçe |
  |---|---|---|---|
  | Yeni kelime (Tanış + Hatırla) | ~2 | 4: "Anlamını göster", "Sonraki", şık, "Devam" | ≤ 4 |
  | 5 yeni kelimelik tur | ~10 + "Başla" | 20 + "Başla" + tur sonu = 22 | ≤ 22 |
  | Tekrar sorusu (kutu 1–3) | 2: şık + "Devam" | 2 ("Zordu / Kolaydı" da ilerletir) | 2 |
  | Kutu 4–5 ve 3 gün kontrolü | — | 2: "Göster" + "Bulamadım / Buldum" (Dinle isteğe bağlı) | 2 |
  | "Bunu zaten biliyorum" | — | 1 (geri almak için +1) | 1 |

  "Sesli söyle" daveti ve "Bunu zaten biliyorum" isteğe bağlıdır; bütçeye girmez, ama ön yüze ikiden fazla seçenek koymayız.
- [BELKİ] Tahmin satırının altına küçük bir not: "Yanlış tahmin de hatırlamana yardım eder." Yazma, puan ve kırmızı yoktur (Potts ve Shanks 2014; etki küçük ve test türüne bağlı).
- [BELKİ] **Zorluk dengesi.** İlk denemede doğru oranı %70'in altına düşerse sonraki tur daha kolay soru türleriyle gelir ve o gün yeni kelime eklenmez. Özet şöyle der: "Bugün zor kelimeler geldi; yarın kısa bir tekrar daha var." Oran birkaç gün %95'in üstündeyse kelimeler hatırlama sorusuna daha erken geçer. Oran hiçbir zaman sayı ya da yüzde olarak gösterilmez. Biraz zorlanmak öğrenmeye yarar, fazlası yarar değil (Bjork ve Bjork 2011). Eşikler FSRS'in hedef hatırlama oranı tartışmasından esinlendi (FSRS wiki, kısmen doğrulandı).

### 2.4 Quiz ve geri bildirim

**Zaten doğru, koru:**
- [ŞART] Yanlışta başlık "Doğrusu: borrow" olur, altında "Senin seçtiğin: lend = ödünç vermek" ve kural varsa "Neden?" kutusu. Bu, alanın en iyi örneklerinden. Geri bildirimsiz çoktan seçmeli soruda yanlış şıklar sonradan doğru diye hatırlanıyor (Butler ve Roediger 2008). Bilgi dolu geri bildirim en güçlü etkiyi veriyor (Wisniewski ve ark. 2020, d = 0,99). Hata metni ne olduğunu ve nasıl düzeleceğini söyler (NN/g hata mesajları).
- [ÖNERİ] Cevaptan sonra yalnız doğru şık ve öğrencinin seçtiği şık kalır, geri bildirim görünür alana kayar.
- [ŞART] Kendiliğinden ilerleme yok. "Devam" her iki sonuçta da aynı yerde, altta durur. Süreyle kendiliğinden geçen ekran WCAG 2.2.1'e (zaman ayarlanabilir) aykırı olur.
- [ÖNERİ] Doğru cevapta dolu cümle Türkçesiyle birlikte gösterilir ("Could I borrow your charger?" → "Şarj aletini ödünç alabilir miyim?"). Geri bildirim, düşük güvenle verilmiş doğru cevapların da kalıcı olmasına yardım ediyor (Butler, Karpicke ve Roediger 2008).

**Değiştir ve ekle:**
- [ŞART] **Şıkların sırası her denemede karışır.** Sıralama tohumu kelimenin numarası ve `reviews` sayısı olur. Bugün `CardDetail.Quiz.options(seed:)` "her cihazda ve her açılışta aynı sırayı" veriyor. Doğru cevabı hep aynı yerde gören öğrenci kelimeyi değil yeri öğrenebilir. Bu, etiket tanımındaki tek istisna: gerekçe bizim, kaynağı yok (madde 4).
- [ŞART] **Soru türü kutuya göre değişir** ve üst etikette yazılır:

  | Ne zaman | Soru türü | Etiket |
  |---|---|---|
  | Hatırla (aynı gün) | 4 şık: İngilizce kelime → Türkçe anlamı seç, ya da tersi (2.3) | "Anlamını seç" / "İngilizcesini seç" |
  | Kutu 1 (ertesi gün) | Yazılmış cloze, şıklar karışık | "Boşluğu doldur" |
  | Kutu 2–3 | `examples[1]` ya da `[2]`'den, `focus` boşaltılarak kurulan cloze; yalnız aşağıdaki kurala uyan örnekte. Uymayan kartta yazılmış cloze, şıklar yeniden karışık | "Boşluğu doldur" |
  | Kutu 4–5, tazeleme ve 3 gün kontrolü | Türkçe → İngilizceyi akıldan bul ("ödünç almak → ?"), "Göster", "Göstermeden önce aklına geldi mi?", "Bulamadım / Buldum" | "İngilizcesini hatırla" |

  *Neden:* hatırlama sorusu, tanıma sorusundan daha güçlü test etkisi veriyor (Rowland 2014). Yalnız tanıma alıştırması, kelimeyi kullanmayı daha az öğretiyor (Webb 2009). Son kutularda gerçek kullanımın yönü sorulur (madde 4, Pan ve Rickard 2018).
  - **Kutu 2–3 örnek kuralı.** Bir örnek ancak `focus == quiz.answer` ise ve doğrulayıcı hiçbir çeldiricinin o cümleye uymadığını onayladıysa kullanılır. Bugün `examples[1–2]`'nin 1.866'sından 512'sinde `focus` cevapla aynı değil: çekimli ya da başka bir biçim (borrow kartında "borrowed"). Çeldiriciler ise yalın biçimde. Bu durumda kelimenin biçimi cevabı ele verir ya da şıklar dilbilgisine uymaz. Yazılmış çeldiriciler yeni cümleye de uyabilir: spoon kartında "Maria stirred her coffee with a ___" cümlesine "knife" da uyar. Bu kontrol `docs/icerik_uretimi/3_celdirici_kurallari.md`'ye ve doğrulayıcıya (`content-pipeline/vocabpipe/validate.py`) eklenir (2.12).
- [ÖNERİ] Tur içinde ya da bir sonraki turda yeniden sorulan kelime başka bir türle sorulabilir. Ama yön değiştirmek (İngilizce → Türkçe yerine Türkçe → İngilizce) testin faydasının en az geçtiği durum ve hızlı yeniden denemeyi zorlaştırıyor (Pan ve Rickard 2018). Bu yüzden şart değil; Hatırla'daki ikinci deneme aynı türde, şıklar karışık gelir.
- [ÖNERİ] **Çeldirici kuralı.** Yazılmış, aynı alandan çeldiriciler kalır (Little ve ark. 2012). Ancak karışan eş (borrow için lend) yalnız o kelime de biliniyorsa (kutu 2 ve üstü) çeldirici olur. Bilinmiyorsa yerine yazılmış başka bir çeldirici gelir. Karışan eş `confusable:X` bayrağından tanınır; ayrı bir işaret gerekmez. AX boylarında 3 şık olur, böylece soru ve şıklar kaydırmadan sığar; 3 şıklı sorular 4 şıklılar kadar iyi ölçüyor (Rodriguez 2005, özet).
- [ÖNERİ] **Emin olunan yanlış.** Kelime son kez "Kolay" diye puanlandıysa ya da "Biliyorum" dendiyse ve şimdi yanlış cevaplandıysa, Dikkat / "Neden?" kutusu kendiliğinden açılır. Başlığı: "Bu ikisi sık karışır:". *Neden:* emin olunan yanlıştan sonra dikkat en yüksektedir ve düzeltme en iyi orada kalıcı olur (Butterfield ve Metcalfe 2001).
- [ÖNERİ] **Dokunma alanları.** Şıklar bugün 56 pt (yaklaşık 8,7 mm) ve tam genişlikte; bu kalabilir. Parhi, Karlson ve Bederson (2006) tek dokunuş için 9,2 mm, art arda dokunuş için 9,6 mm öneriyor. Ama özetlerine göre art arda dokunulan hedeflerde 7,7 mm ve üstünde (163 pt/inç ile yaklaşık 49 pt) hata farkı yok (özetteki "≥" işareti bozuk görünüyor). Yani 60 pt'ye çıkmak şart değil. Daha önemli olanlar: şıklar arasında 8–12 pt boşluk, "Devam" ve cevap düğmelerinin `.safeAreaInset(edge: .bottom)` içinde durması ve en alttaki düğmenin ana ekran çizgisinin en az 8 pt üstünde olması (ekran kenarında dokunma daha zor; Hoober, ikinci el).
- [ÖNERİ] **Titreşim.** Doğru cevapta `.sensoryFeedback(.success)` olur. Yanlış cevapta titreşim yok; `.error` hiçbir zaman kullanılmaz. Bir dokunuşa en çok bir titreşim düşer. Hepsi Ayarlar'daki "Titreşim" anahtarına bağlıdır. Apple "titreşimi aşırı kullanma" ve "isteğe bağlı yap" diyor.
- [ÖNERİ] Geçişler en çok 200 ms sürer. Hareketi Azalt açıkken geri bildirime kaydırma animasyonsuz olur (`withAnimation` olmadan) ve kart değişimi yalnız solma olur (WCAG 2.3.3).
- [ŞART] **Metin işe dair kalır.** Büyük "Yanlış!" başlığı yok. "Yanlış" sözü yalnız şıkın üstünde küçük bir etiket olarak, simgeyle birlikte durur. "Neden?" en çok 2 satır, A2 Türkçesi. Öğrenci hakkında ünlem yok (Kluger ve DeNisi 1996).
- [ÖNERİ] **İngilizce kelimeyi İngilizce ses okur.** "Doğrusu: borrow" duyurusunda (`QuizCardView.swift:293`) "borrow" İngilizce sesle okunur: `NSAttributedString` ve İngilizce aralığa `UIAccessibilitySpeechAttributeLanguage = "en-US"`. Bu anahtar UIKit için belgelenmiş; iOS 26'da cihazda denenmeli. "Senin seçtiğin: lend = ödünç vermek" metni Türkçe, İngilizce ve Türkçe parçalara bölünür. *Neden:* Türkçe ses İngilizce kelimeyi Türkçe harf kurallarıyla okuyor. Bu da düzeltmek istediğimiz telaffuz hatasının örneği oluyor (WCAG 3.1.2).

### 2.5 Tur sonu ve bugünlük tamam

**Zaten doğru, koru:**
- [ÖNERİ] Kelime kelime "ne zaman dönecek" listesi, "Sıradaki tekrar: bugün 21:40", "Hatırlatma: 20:00" ve kilit ekranı notu. Bunlar işe dair, sonra ne olacağını söyleyen geri bildirimler (Hattie ve Timperley 2007, özet).
- [ŞART] Seri, puan ve kırmızı sayaç yok (Silverman ve Barasch 2023). "Bugün: 6 yeni kelime, 0 tekrar. Bildiğin kelime: 124." biçimi kalır.
- [ÖNERİ] Ekranda tek dolu düğme olur.

**Değiştir ve ekle:**
- [ÖNERİ] **Tur özeti başlığı "Güzel iş!" yerine "Tur bitti" olur.** "Güzel iş!" bugün sonuç ne olursa olsun çıkıyor, 0 bilinen kelimede bile. Alt satırlar:
  - "10 kelime çalıştın, 7 tanesini bildin."
  - "Bir sonraki turda yine soracağız: borrow, date."

  Kelime listesi kalır. Bu kelimeler widget'ın serbest slotunda görünebilir (2.1); yanlıştan sonra kelimeyi yeniden görmek sorun değil.
- [ÖNERİ] **"Harikasın, bugünlük tamam!" yerine "Bugünlük tamam."** Alt satırda iş bilgisi kalır. Övgü ancak emeğe ya da sürece olur: "10 kelimeye baktın."
- [ÖNERİ] **Hiçbir zaman:** yüzde, net, "x doğru y yanlış", kırmızı tam ekran, her doğruda konfeti ya da ses. Türk sınav kültüründe yanlış puan kaybıyla eşleşiyor ("4 yanlış 1 doğruyu götürür").
- [ÖNERİ] "Bugünlük tamam" ekranında tek bir `.success` titreşim olur.
- [ÖNERİ] **Haftalık sayı:** "Bu hafta: 4 gün". Yalnız 1 ve üstündeyse gösterilir; "0 gün" hiçbir zaman yazılmaz. Pazartesi ilk açılışta bir kez geçen hafta gösterilir: "Geçen hafta: 5 gün". Arka arkaya gün sayacı yok. *Neden:* görünür bir kaydın sıfıra düşmesi, Silverman ve Barasch'ın (2023) daha az kullanımla ilişkilendirdiği türden bir kopma.
- [ÖNERİ] "Zor da bilinmiş sayılır" notu kısa olarak kalabilir. Yeni düzende "Zor" yalnız doğru cevaptan sonra çıktığı için bu not artık daha az gerekli.
- [BELKİ] Seviye çubukları (Ayarlar'da zaten var) tamam ekranında da görünür: "A2 kelimeleri: 96 / 418". Puan, rütbe, sıralama ve kilitli seviye yok (Orbit'in maskotlu seviye haritası tam kaçınılacak örnek).
- [BELKİ] "5 yeni kelime daha öğren" ikincil düğme olarak kalır. Altına sakin bir not eklenir: "Yeni kelimeler sonraki günlerde tekrar olarak döner."

### 2.6 Sözlük ve kart ayrıntısı

**Zaten doğru, koru:**
- [ÖNERİ] Aksan duyarsız arama ("Türkçe harfleri yazmasan da bulur"), boş kutuda "Dene" örnekleri, eşleşen kısmın sarı değil kalın ve çizgili olması.
- [ÖNERİ] Durum en sonda: "Biliyorum olarak işaretle" / "Öğrenmeye geri al".

**Değiştir ve ekle:**
- [ÖNERİ] **Ayrıntı ekranı derin katmandır.** Akış kartından taşınan her şey burada durur: "Ayrıca" karşılıkları, bütün örnekler, eşdizimler, bütün Dikkat hataları, uyarı yuvasına giremeyen satırlar, köken (etymology). Bu ekranda uzun sayfa ve kaydırma serbesttir; kartta değildir.
- [ÖNERİ] **Türkçe arama bütün karşılıkları bulur.** `gloss`, `alt` ve "/" eşleri aranır: "dayı" yazınca uncle, "durdurmak" yazınca stop bulunur.
- [ÖNERİ] **Sahte dost araması.** "aktüel", "sempatik", "fabrika", "apartman" ya da "mağaza" yazılınca sonucun üstünde bir şerit çıkar: "aktüel → current (actually değil)". Arama `false_friend.tr_word` alanından yapılır. İçerik ekibi eksik A1–B1 sahte dostları ekler (magazine/mağaza, college/kolej, sympathetic/sempatik, pension/pansiyon, sensible/sensitive) ve `false_friend_tr` bayrağını `equivalence` ile uyumlu tutar (bugün 7 kartta veri var, yalnız 4'ünde bayrak var).
- [ÖNERİ] **"Sonuç yok" çıkmaz sokak olmaz.** Önce en yakın kart önerilir: "Bunu mu demek istedin: borrow?".
- [BELKİ] Sonra bir satır daha: "Bu kelime henüz listede yok · Eklenmesini iste". Bu, ağ kullanmadan yerel bir istek listesine kaydeder; uygulama sahibi listeyi dışa aktarabilir. İleride bu satır "Kendi kelimeni ekle" olur (kelime, Türkçe anlam, isteğe bağlı örnek). Eklenen kart "senin kelimen" etiketiyle ayrı görünür, böylece hazır içeriğin kalitesi karışmaz. Rakip yorumlarındaki istek tablosunda "kendi kelimeni ekle, içe/dışa aktar" 4. sırada, 34 anmayla (`raporlar/02`).
- [ŞART] "Biliyorum olarak işaretle" de 3 gün sonraki tek kontrol kuralına uyar (2.2).

### 2.7 Söyle

**Zaten doğru, koru:**
- [ÖNERİ] Telaffuz kontrolü cihazın içinde yapılır. "Ses kaydedilmez" yazısı görünür kalır.
- [ŞART] Durumlar ayrıdır: "Seni duyamadım" (mikrofon ya da ses yok), "Bir daha dene" ve "Neredeyse! Şunlar duyulmadı: up". Tasarım tema renklerini, simgeyi ve kelimeyi birlikte kullanır; renk tek başına anlam taşımaz (kural 4; WCAG 1.4.1).
- [ŞART] Geri sayım yok, seri yok (WCAG 2.2.1). Orbit'in "5 saniye içinde söyle, her doğruda seri" düzeni en çok kaygı yaratan beceride bir de zaman baskısı ekliyor.
- [ÖNERİ] Söyle sonucu Leitner puanını hiç değiştirmez ve "Devam"ı hiçbir zaman engellemez.
- [ÖNERİ] "Geç" boşta durumdan beri görünür; üçüncü başarısız denemeden sonra yalnız küçük bir not eklenir ("Takıldıysan Geç'e dokun…"). Sayfada her zaman "Kapat" var (`docs/ozellik_planlari/soyle_telaffuz.md`).
- [ÖNERİ] "Bir daha dene" durumunda ne duyulduğu zaten gösteriliyor: "'\(heard)' duydum…" (`PronunciationCheck.swift:496`; mockup 1214. satır). "Neredeyse!" durumunda duyulmayan kelimeler listeleniyor.

**Değiştir ve ekle:**
- [ÖNERİ] **"Doğru!" yerine "Anlaşıldı!"** Mesajı: 'Telefon "think" diye duydu.' *Neden:* tanıyıcı telaffuzun kalitesini değil, anlaşılıp anlaşılmadığını ölçüyor (`docs/ozellik_planlari/soyle_telaffuz.md`). "Doğru!" bundan fazlasını vaat ediyor. Tanıyıcıya dayalı telaffuz geri bildiriminin sınırlarını söylemek gerekiyor (Neri, Cucchiarini ve Strik 2002).
- [ÖNERİ] Genel ipucu metni güncellenir: "Önce hoparlör düğmesiyle dinle" (`PronunciationCheck.swift:496`) → "Önce Dinle'ye dokunup dinle." Bu bölümdeki tek yeni metin işi budur.
- [ÖNERİ] Puan, yıldız ve paylaş düğmesi yok. Söyle özel bir alıştırma alanıdır. Türk öğrencilerde olumsuz değerlendirilme korkusu güçlü ve dil kaygısının önemli bir kaynağı (Aydın, Asian EFL Journal cilt 31; yıl doğrulanmadı). Dil kaygısı ölçeği için bkz. Horwitz, Horwitz ve Cope 1986 (açılmadı).
- [BELKİ] Yeni ipucu türü `.clusterVowel`: hedef kelime s + p/k/t/m/n/l ile başlıyor ve tanıyıcı başına ünlü eklenmiş bir biçim duyduysa (sport → support) şu öneri çıkar: "Başa ses ekleme: s ile p'yi birleştir (sıpor değil)." Türklerin "spor"u [sɯpor] okuduğu biliniyor (Yavaş ve Altan 2016). Tanıyıcının bunu "support" diye duyacağı ise bizim tahminimiz, denenmedi.
- [BELKİ] Kartta `l1.tr.say` varsa okunuş Söyle sayfasında büyük gösterilir.

### 2.8 Açılış

**Zaten doğru, koru:**
- [ÖNERİ] 4 sayfa (Seviye, Konular, Widget rehberi, İlk kelime) ve her sayfada "Atla". Hesap, anket ve ödeme ekranı yok. Rakip örneği: Monkey Taps'in açılışı kaynağa göre 13 ile 22 adım arası (`raporlar/06` §0.2, `raporlar/05` §1.1). Bir yorumda "yaklaşık 5 dakikalık kurulumdan sonra ödeme duvarı" şikâyeti var (`raporlar/03`). Düşük puanlı yorumların en büyük konusu para: Monkey Taps'in 1–2 yıldızlı yorumlarının %52'si (`raporlar/02`).
- [ŞART] Açılışta bildirim izni istenmez. Apple izni, özellik ilk kullanılırken istemeyi söylüyor (HIG Açılış).
- [ÖNERİ] Konular sayfasındaki "Seçili: N kelime" satırı ve ilk kartta Söyle'nin gizli olması.

**Değiştir ve ekle:**
- [ÖNERİ] **4. sayfa etkileşimli olur.** Kart anlamı gizli başlar: "Anlamını tahmin et, sonra dokun." Dinle çalışır. Böylece Tekrar'daki hareket daha Tekrar'ı görmeden öğrenilir. Apple "yaparak öğret" diyor ("Teach through interactivity").
- [ÖNERİ] Widget rehberindeki önizleme, kullanıcının seviyesine ve konularına göre seçilen gerçek ilk kelimeyi gösterir.
- [ÖNERİ] **Günlük hedef, yeni sayfa eklemeden seviyeden gelir:** A1–A2 seçilirse 5, B1 seçilirse 10. Ayarlar'dan değişir. Böylece açılış uzamaz.
- [ÖNERİ] **Bildirim izni ilk Tekrar turu bitince istenir,** önce bir uygulama içi soru gelir:
  - Başlık: "Her gün 1 hatırlatma gönderelim mi?"
  - Soru: "Ne zaman bakarsın?" Seçenekler: "Sabah kahvesiyle (08:00)", "İşe giderken (08:30)", "Akşam (20:00)", "Yatmadan önce (22:30)". Seçilen saat önden doldurulur ve değiştirilebilir.
  - Düğmeler: "Evet, gönder" ve "Şimdi değil". İkisi aynı boyda olur. "Şimdi değil" küçültülmez, suçlayıcı metin yoktur ("Hayır, öğrenmek istemiyorum" gibi; NN/g aldatıcı desenler).

  *Neden:* "ne zaman, nerede" planı yapmak hedefe ulaşmayı artırıyor (Gollwitzer ve Sheeran 2006, d ≈ 0,65). Alışkanlık sabit bir ipucuna bağlanınca oluşuyor (Lally ve ark. 2010). Kısa dil çalışması için uygun anlar günün belli zamanlarında toplanıyor (Dingler ve ark. 2017). Apple izni "özellik ilk kullanıldığında" istemeyi öneriyor. "20:00'de" gibi saatten sonra ek alan yazımlar kullanılmaz (README madde 13).
- [ÖNERİ] "Hoparlöre dokunup dinleyebilirsin" cümlesi "Dinle'ye dokunup dinleyebilirsin" olur (README'deki açık soru).
- [ÖNERİ] Açılışta ve mağaza görsellerinde günlük A2 kelimeleri kullanılır (borrow, breakfast, date), "petrichor" ya da "sonder" gibi nadir kelimeler kullanılmaz. Sık kelimeler günlük metnin çok büyük kısmını karşılıyor (Nation 2006). Seviye uyuşmazlığı rakip yorumlarında geçiyor: hedef uygulamada "kelimeler çok zor" diyen 3 yorumun hepsi 1 yıldız; Dogan'ın yorumlarının %49'u ise "çok basit" diyor (`raporlar/02`).

### 2.9 Ayarlar

**Zaten doğru, koru:**
- [ÖNERİ] Soru biçimli başlıklar, "Widget sağlığı ✓ Çalışıyor / ⚠ Güncellemiyor" satırı, seviye çubukları (A1/A2/B1) ve "Bildiğim kelimeler" listesindeki "Geri al".
- [ÖNERİ] "Değiştirince şu an görünen kelime aynı kalır. iPhone, pili korumak için yenilemeyi biraz geciktirebilir." Bu dürüst bir not.
- [ŞART] Hatırlatma için tek saat seçilir. "O günün işini bitirdiysen gelmez" kuralı kalır (HIG Bildirimler: aynı şey için birden fazla bildirim gönderme).

**Değiştir ve ekle:**
- [ÖNERİ] **Günlük hedef bedeliyle birlikte gösterilir.** Bugün yalnız "bir ayda yaklaşık 300 kelime" yazıyor; bu kazancı söylüyor, bedeli söylemiyor. Yeni alt satır seçime göre değişir:
  - 5: "Günde en az 7 dakika, tekrarlar dahil. Bir ayda yaklaşık 150 kelime."
  - 10: "Günde en az 13 dakika…"
  - 15: "Günde en az 19 dakika…"
  - 20: "Günde en az 25 dakika…"

  Bu süreler bir alt sınır: soru başına 8–10 saniye, kelime başına yaklaşık 5 tekrar ve hiç kayma olmadığı varsayıldı. Unutulan kelimeler ve her ay büyüyen tazelemeler eklenmedi (madde 9). `ProgressStore`'daki gerçek sürelerle ölçülünce (2.13) "en az" yerine ölçülen ortanca yazılır.
- [ÖNERİ] **Günlük hedefin göçü.** `dailyNewWordChoices` [5, 10, 15, 20] kalır. Kendisi bir sayı seçmiş mevcut kullanıcının değeri korunur. Seviyeye göre varsayılan (A1–A2: 5, B1: 10) yalnız yeni kurulumlarda ve ayarı hiç değiştirmemiş kullanıcıda geçerli olur.
- [ÖNERİ] **"Kelime ne sıklıkla değişsin?"** seçenekleri 30 dk · 1 saat · 2 saat · 4 saat olur; 5 dk ve 15 dk kalkar, 240 eklenir. Varsayılan 1 saat kalır. Çok sık değişen kelime her kelimeye tek bakış bırakır ve göz ucundaki hareket dikkati çeker. **Göç:** `AppPreferences.rotationMinutes`, kayıtlı değer `rotationMinuteChoices` içinde değilse sessizce varsayılana (60) düşüyor. 5 ve 15 listeden çıkarılınca bu kullanıcılar habersizce 60 dakikaya geçerdi. Bu yüzden ilk açılışta kayıtlı 5 ve 15 değerleri 30'a yazılır.
- [ÖNERİ] **Widget sağlığı bozuksa** sadece uyarı değil, üç adım gösterilir:
  1. "Widget'ı kaldırıp yeniden ekle."
  2. "Düşük Güç Modu açıksa kapat."
  3. "Lockglow'u bir kez aç."

  Güncellenmeyen widget, rakip yorumlarında tekrar eden bir şikâyet: 13 yorum, yaklaşık %1 (`raporlar/02`). 1–2 yıldızın en büyük nedeni ise para.
- [ÖNERİ] **"Görünüm: Sistem · Açık · Koyu"** (varsayılan Sistem). Uygulamada ve widget'ta zorla `.preferredColorScheme(.dark)` kullanılmaz. Kilit ekranında bu ayar etkisizdir; zemini sistem çizer.
- [ÖNERİ] **"Titreşim"** anahtarı (varsayılan açık). Her `.sensoryFeedback` buna bağlıdır.
- [ÖNERİ] **"Kilitli ekranda özel konuları da göster"** anahtarı (varsayılan kapalı; bkz. 2.1). `tags.sensitivity` etiketlenmeden etkisi geçici süzgeçle sınırlı.
- [ÖNERİ] Hatırlatma duraklatıldıysa satırda bu görünür: "Hatırlatmalar duraklatıldı · Aç" (bkz. 2.10).
- [BELKİ] **"İngilizce yazı tipi: Serif · Düz".** Uygulamadaki ve widget'taki bütün İngilizce yazıyı SF'ye çevirir (App Group ayarıyla); üçüncü bir yazı ailesi eklenmez. Kalın Yazı ayarı serifte de uygulanır. *Neden:* serifin okunmaya etkisi çok küçük, ama kişiden kişiye en hızlı okunan yazı tipi değişiyor (Wallace ve ark. 2022: kişinin en hızlı yazı tipi en yavaşından %35 hızlı).
- [BELKİ] "Widget'ta önce tahmin et" anahtarı (varsayılan kapalı; bkz. 2.1).
- [BELKİ] "Bildiğim kelimeler" içinde ayrı bir grup: "Biliyorum dedin, kontrol bekliyor".

### 2.10 Bildirimler

**Zaten doğru, koru:**
- [ŞART] Günde tek hatırlatma, kullanıcının seçtiği saatte gelir. O günün işi bittiyse gelmez. İzin reddedilince anahtar kapalı kalır ve "Bildirim iznini aç" çıkar. Bildirimler dikkati dağıtıyor ve topluca gelmeleri iyi hissettiriyor (Kushlev ve ark. 2016; Fitz ve ark. 2019, ayrıntı özetten).

**Değiştir ve ekle:**
- [ŞART] **Bildirim bir kelime taşır, görev ya da sayı değil.** Bugünkü metin (`ReminderScheduler.swift:48-66`): "Tekrar zamanı / Bugünün N yeni kelimesi hazır. İki dakikanı ayır." Bu, Apple'ın kuralına aykırı: "Avoid sending a notification that tells people to perform specific tasks within your app" (HIG Bildirimler). Hiçbir şey de öğretmiyor. Yerine en az 6 şablon dönüşümlü kullanılır. Aynı şablon 5 gün içinde tekrar gelmez; aynı şablonu sık göndermek etkisini düşürüyor (Yancey ve Settles 2020).

  | Başlık | Gövde |
  |---|---|
  | borrow = ödünç almak | Could I borrow your charger? |
  | Bugünün kelimesi: break | mola · take a break = mola vermek |
  | Dikkat: listen to music | Türkçede müzik dinlemek deriz; İngilizcede listen to music. |
  | Sahte dost: actually | aslında demek. "Şu anda" için currently. |
  | Yeni kelime: spoon | kaşık · Can I have a spoon, please? |
  | date ve appointment | date: buluşma, randevu (kişisel). appointment: doktor, iş randevusu. |

  - **Kelime seçimi:** bildirimdeki kelime, Tekrar'da önümüzdeki yaklaşık 6 saat içinde sorulacak bir kelime olamaz (2.1, kural a). Bugün cevaplanmış kelimelerden, kutu 2 ve üstündeki öğrenme kelimelerinden ya da widget'ta görülmüş yeni kelimelerden seçilir.
  - **Karışan çift şablonu** ("date ve appointment") yalnız iki kelime de kutu 2 ve üstündeyse kullanılır. Yoksa iki karışan kelimeyi birlikte öğretmiş oluruz (madde 8).
  - Gövdede tekrar sayısı ya da görev olmaz (eski "· Tekrar'da 6 kelime hazır." kalktı).
  - Yazım kuralı: değişkenden sonra Türkçe ek yok ("borrow'u" değil), suçlama yok, emir kipi yok (Microsoft Türkçe yazım kılavuzu).
- [ŞART] **Rozet ve aciliyet yok.** Uygulama simgesinde tekrar sayısı rozeti olmaz; Apple rozeti yalnız okunmamış bildirim sayısı için ayırıyor. `interruptionLevel = .active` olur ve özel ses olmaz. `.timeSensitive` hiçbir zaman kullanılmaz; Apple onu yalnız şu an olan şeyler için ayırıyor (HIG Bildirimleri yönetme). `relevanceScore` yaklaşık 0,3, `threadIdentifier` "gunluk" olur.
- [ŞART] **Aynı gün ikinci bildirim yok.** "Seni özledik", "Serini kaybetme!" ve "X kelime birikti" gibi metinler yok. Apple: "aynı şey için birden fazla bildirim gönderme… insanlar uygulamanın bütün bildirimlerini kapatabilir."
- [ÖNERİ] **Geri çekilme.** Hatırlatma 3 gün üst üste görmezden gelinirse (uygulama açılmadı ve widget'a dokunulmadı), uygulama bir sonraki açılışta tek bir kart gösterir: "Hatırlatma saatini değiştirelim mi?" Düğmeler: "Saati değiştir" ve "Böyle kalsın". 7 gün üst üste görmezden gelinirse hatırlatma durur ve açılışta şu not çıkar: "Hatırlatmaları duraklattık. İstersen Ayarlar'dan açabilirsin." Bu not 3 gün kartının yerine geçer; ikisi birlikte çıkmaz. Geri kazanma bildirimi gönderilmez. Kelimeyle temas için widget yeterli.
- [ÖNERİ] **Bir açılışta en çok bir sistem kartı.** Uzun bir aradan sonra tek açılışta dört kart üst üste binebilirdi: 3 gün saat sorusu, 7 gün duraklatma notu, Tekrar'ın "Ara verdin, sorun değil" başlangıcı ve Akış'ın günün sonu kartı. Öncelik sırası: duraklatma notu > saat sorusu > "Ara verdin" satırları > günün sonu kartı. Seçilmeyenler o açılışta çıkmaz; "Ara verdin" kartı yalnız "Başla (10 kart)" olarak kalır, günün sonu kartı bir sonraki açılışa kalır.
- [ÖNERİ] **Bildirimde düğme yok.** Bildirime dokunmak Tekrar'ı (tekrar yoksa kelimenin kartını) açar. Apple "yalnız uygulamayı açan bir düğme koyma" diyor.
- [BELKİ] Soru biçimli şablon ("borrow ne demek?") yalnız bir bildirim içerik uzantısı (Notification Content Extension) cevabı uzun basınca bildirimin içinde gösterebiliyorsa kullanılır. Cevap uygulamanın içine saklanmaz. Orbit'in "'Solivagant' ne demek biliyor musun?" bildirimi cevabı saklıyor; bu kaçınılacak bir örnek.

### 2.11 README'deki açık sorulara kısa cevaplar

- **"Akış'a Biliyorum düğmesi eklensin mi?"** Evet (kodda `FeedView` altında zaten var). İlk karşılaşmada Dinle ve Söyle ile aynı düğme satırında durur, ayrı bir blok olmaz (2.2). Anlamı "büyük ihtimalle biliyorum": 3 gün sonra tek kontrol sorusu sorulur ve "Geri al" her yerde vardır.
- **"Tur özeti ayrı ekran mı olsun?"** Kısa, ayrı bir ekran olabilir. Önemli olan içerik: "Tur bitti", ne kadar çalışıldığı ve kelimelerin ne zaman döneceği (2.5).
- **"Dinle" kapsülü:** Evet. Açılıştaki ve Söyle'deki "hoparlör" geçen metinler "Dinle" olarak güncellenir (2.7, 2.8).
- **Cihazda denenecekler listesine eklenecekler:** kilit ekranında `isLuminanceReduced` görünümü; `UIAccessibilitySpeechAttributeLanguage` ile karışık dilli duyuru; SE'de iki düğmeli küçük widget; `ViewThatFits` ile Türkçe anlamın ve uzun kelimenin ("misunderstanding") kısalması; New York serifin gövde boyunda x-yüksekliği (2.2).

### 2.12 İçerik işi

Bu belgedeki içerik önerilerinin iş yükü. Sayılar `content/drafts/kisisel_v1` içindeki 934 karttan (`s0_ornek`'teki 5 örnek kart dahil). Her iş üç yere yazılır: `docs/icerik_uretimi/1_yazar_kurallari.md` (yazar ne yapar), `2_denetci_kurallari.md` (denetçi neye bakar) ve doğrulayıcı (`content-pipeline/vocabpipe/validate.py`). Bu gözden geçirmede o dosyalar değişmedi.

| İş | Kaç kart ya da öğe | Not |
|---|---|---|
| `gloss_short` yaz | 83 kart (anlam 16 karakteri geçiyor) | 63'ünde `alt` içinde 16 karakteri geçmeyen bir aday var; editör önce oradan seçer. |
| "/" ile "," ayrımı | 43 virgüllü anlam | Bugün yalnız 1 anlamda "/" var ("de / da"). uncle ve stop bu 43'ün içinde. |
| `mistakes[].kind` | 693 hata | Eksik kelime işareti için de gerekli (2.2). |
| `tags.sensitivity` | 934 kart (hepsi bugün 0) | Kilit ekranı süzgecinin ön koşulu (2.1). |
| `confusable:X` eksiklerini ekle | 136 kartta 139 bayrak var | Elle liste yerine bu bayraklar kullanılır. Eksik: actually/currently, get up/stand up, receipt/recipe, appointment → date. |
| Kutu 2–3 örnek kontrolü | 1.866 örnek; 512'sinde `focus` cevaptan farklı | `focus == quiz.answer` ve "hiçbir çeldirici uymaz" onayı. `3_celdirici_kurallari.md`'ye de eklenir (2.4). |
| Sahte dost verisi | 7 kartta veri, 4'ünde bayrak | Eksik sahte dostlar eklenir (2.6). |

### 2.13 Ölçüm ve kabul hedefleri

"Yormayan" bugün ölçülmüyor. `ProgressStore`'a yalnız cihazda kalan bir kayıt eklenir: ağa gitmez, dışa aktarılmaz, "İlerlemeyi sıfırla" ile silinir.

- **Kaydedilecekler:**
  - soru başına süre (saniye); 2.9'daki 7/13/19/25 dakika etiketlerinin dayandığı 8–10 saniye varsayımının yerine geçer;
  - yeni kelime başına dokunma sayısı;
  - "Bitir" ile biten turlar;
  - "Biliyorum" ya da "Bunu zaten biliyorum" denip 3 gün kontrolünü geçemeyen kelimeler;
  - görmezden gelinen hatırlatmalar.
- **Kabul hedefleri** (ilk eşikler; kanıta değil, bizim seçimimize dayanır ve ilk ölçümden sonra ayarlanır):
  - günlük süre ortancası, Ayarlar'da gösterilen sürenin altında ya da ona eşit;
  - yeni kelime başına dokunma ortancası en çok 4;
  - "Bitir" ile biten tur oranı %25'in altında;
  - 3 gün kontrolünü geçemeyen "Biliyorum" oranı %30'u geçerse düğmenin yeri ve metni yeniden düşünülür.

---

## 3. Kaçınılacaklar

**Öğrenme:**
- Hiç hatırlama denemesi olmadan "Bu kelimeyi ne kadar bildin?" diye sormak ve tekrar aralığını buna göre kurmak.
- Hiç sınanmamış bir kelimeyi tek dokunuşla ("Biliyorum") 30 gün saklamak. Ya da hiçbir görünür sonucu olmayan bir düğme koymak.
- Her tekrarda aynı cloze cümlesini, doğru şık aynı yerdeyken sormak.
- Widget'a bakmayı ya da Akış'ta kart görmeyi tekrar saymak. Kilit ekranında yalnız bakmayı "öğrenme" diye pazarlamak.
- Tekrar'da birazdan sorulacak kelimeyi widget'ta ya da bildirimde Türkçesiyle göstermek.
- Yanlış cevaplanan kelimeyi hemen bir sonraki kartta sormak. Hatırla'da kelimeyi doğru cevaplanana kadar sınırsız yeniden sormak.
- Tutulamayan bir zaman sözü vermek ("10 dakika sonra yine gelir").
- Aynı dar alandan (kaşık, çatal, bıçak) ya da karışan çiftlerden (borrow/lend, date/appointment) kelimeleri aynı gün yeni olarak vermek. Henüz bilinmeyen eşi çeldirici yapmak.
- Çeldiricinin uyduğu ya da odak kelimesi çekimli olan bir örnekten cloze kurmak.
- İlk karşılaşmada kartın bütün katmanlarını açmak ya da 8 bloğu aşmak: İngilizce tanım, tam Dikkat, "Ayrıca", eşdizimler, 3 örnek, birden fazla uyarı satırı.
- Günlük hedefi tekrar bedelini göstermeden 15–20'ye çıkarmak. Ölçülmemiş süreyi kesin gibi yazmak. Aradan sonra "87 kelime bekliyor" gibi büyük bir sayı göstermek.
- Puan, XP, maskotlu seviye haritası ve kilitli seviyeler. Bunlar zamanında yapılan hatırlamayı değil, dokunma sayısını ödüllendiriyor.

**Okuma ve yorgunluk:**
- Uygulamayı ya da widget'ı sistem görünümünden bağımsız olarak zorla koyu ya da "yıldızlı gece" yapmak. Fotoğraf, resim ya da hareketli duvar kâğıdı üstüne yazı koymak.
- Kilit ekranında üçüncü satır. Saydamlıkla (%80 beyaz) kurulan hiyerarşi.
- Küçük widget'ta 3 ya da daha çok düğme, tür, seviye ve tanım. Uygulama gibi görünen widget düzeni. Yalnız simgeli ve birbirine benzeyen, biri geri alınamaz düğme dizisi.
- Öğrenilen kelimede negatif harf aralığı, `.allowsTightening(true)`, Akış'ta 0,75'in altında `minimumScaleFactor`, widget'ta herhangi bir `minimumScaleFactor`. Kelimenin ya da kalıbın "…" ile ya da tireyle kesilmesi.
- Akış ve Tekrar'da 17 pt'nin, ana ekran widget'ında 15 pt'nin altında okuma metni. 4,5:1'in altında kalan herhangi bir yazı; surface3 üstünde ink3 yazı. Yüksek Kontrast varyantı olmayan renkler.
- Okunan yazının yanında sonsuz nabız ya da döngü animasyonu. Her kaydırmada ya da puan dokunuşunda animasyon. Hareketi Azalt açıkken yumuşak kaydırma.
- Yanlış cevapta `.error` titreşimi, her dokunuşta titreşim, kapatılamayan titreşim.
- Koyu temada iki sarı odak: şerit, sarı ana düğme ve bulanık ışıma bir arada.
- Kendini puanlama düğmelerinden birini (ör. "Buldum") dolu ya da renkli yapmak. Bir ekranda birden fazla dolu düğme.
- Üçüncü açılma katmanı (sayfadan sayfa açmak) ya da kart içinde kaydırma.
- Bir akışta dokunma bütçesini aşmak; her yeni öğe için başka bir öğeyi çıkarmamak.
- Monospace, dar ya da el yazısı yazı tiplerini okuma metninde kullanmak. Her karta ayrı vurgu rengi vermek.

**Türkçe:**
- Türkçe anlamı sonundan "…" ile kesmek. "/" ile yazılması gereken iki karşılığı virgülden kesip tek birini göstermek ("uncle · amca").
- Bir karta 4–5 Türkçe karşılık yığmak.
- Yanlış cümleyi tek başına ya da hatanın yeri işaretlenmeden göstermek.
- İngilizce cümlenin içine "(= şu anda)" gibi Türkçe not koymak.
- İngilizce kelimeleri Türkçe sese okutmak.
- Kartlarda "siz" ("dersiniz", "kullanın", "demeyin"), arayüzde "sen" kullanmak. Bir kartın içinde hitabı değiştirmek. Seçim: her yerde "sen"; dil açıklamalarında kapsayıcı "biz" ("Türkçede iki ekmek deriz").
- Dikkat'i yalnız yasakla yazmak ("demeyin", "yanlıştır", "kullanılmaz") ve olumlu kural vermemek.
- "8 doğru 2 yanlış", yüzde ya da net gibi sayaçlar. Büyük "Yanlış!" başlığı.
- Sonuca bakmayan övgü: 0 bilinen kelimede bile "Güzel iş!", her turda "Harikasın!".
- Söyle'de anlaşılırlık kontrolüne "Doğru!" demek. Telaffuz puanı, yıldız ya da paylaş düğmesi.
- A2 öğrenciye tek telaffuz yardımı olarak IPA vermek. İngilizce harflerle okunuş yazmak ("ZEE", "kuh"). Türkçe metinlerde vurgu için BÜYÜK HARF kullanmak.
- Değişkenlere ve saatlere Türkçe ek eklemek ("\(word)'ü", "20:00'de"). Cümleyi ek gerekmeyecek biçimde kurmak.
- Sahte dost verisini okuyup hiç göstermemek.
- Kilit ekranında varsayılan olarak ilişki, ayrılık ya da "ex" örnekleri göstermek.
- Kilit ekranı widget'ında anlamı bir düğmenin arkasına saklamak. Kilitliyken düğme çalışmıyor.

**Ton ve alışkanlık:**
- Arka arkaya gün serisi, alev simgesi, "serin bozuldu" durumu, ücretli ya da kazanılan "seri tamiri". Haftalık sayıyı "0 gün" olarak göstermek.
- Kaçırılan pratikle tonu değişen widget ya da maskot.
- Pratiği sınırlayan enerji ya da can sistemi (Duolingo'nun enerji sistemine tepki, ikinci el).
- Bir açılışta birden fazla sistem kartı.
- Geri bildirimi seçilen şıktan uzakta, bir anlık bildirim balonuyla göstermek. Yanlış cevaptan sonra kendiliğinden ilerlemek. Doğru/yanlışı yalnız renkle göstermek.
- Quiz'de ya da Söyle'de geri sayım. Tanıyıcı kabul edene kadar "Devam"ı kilitlemek.
- İngilizce kelimenin, şıkların ya da cevap düğmelerinin arkasında cam ya da yarı saydam yüzey. Cam yalnız kontrol katmanında olur (NN/g Liquid Glass).
- İlk kelimeden önce ödeme ekranı, ödemeli widget, ücretsiz bir özelliği sonradan ücretli yapmak. Uzun anketli açılış ve değer görülmeden istenen izinler.

**Bildirim:**
- Günde birden fazla hatırlatma ya da cevaplanmayan güne ikinci bildirim.
- Time Sensitive (acil) düzeyi. Tekrar sayısı rozeti.
- "Seni özledik", "Serini kaybetme!" ve "X kelime birikti" gibi suçlu hissettiren ya da baskı kuran metinler. Gövdede tekrar sayısı ya da görev ("Tekrar'da 6 kelime hazır").
- Her gün aynı şablon. Görmezden gelen kullanıcıya daha çok bildirim göndermek (geri çekilmek yerine).
- Cevabı saklayıp uygulamayı açtırmaya çalışan merak bildirimi. "Hayır, öğrenmek istemiyorum" gibi utandırıcı izin soruları.

---

## 4. Kaynaklar

Kaynakların çoğunu dört araştırmacı okudu. Bu sentezde Apple'ın Bildirimler, Bildirimleri yönetme, Titreşim, Widget'lar ve Açılış sayfalarındaki alıntılar ile WidgetKit "kilitliyken düğmeler çalışmaz" ve `isLuminanceReduced` belgeleri yeniden açılıp doğrulandı (22 Ekim 2026). Gözden geçirmede eleştirmen HIG Widgets'taki 11 pt, "unintended interactions", "opaque grayscale values" ve "at a glance… longer look" alıntılarını, Dobres 2016'yı, Rawson ve Dunlosky 2011'in, Pan ve Rickard 2018'in, Potts ve Shanks 2014'ün ve Kim, Lee ve Lee 2024'ün özetlerini ayrıca doğruladı. "(özet)" yalnız özetin ya da ikinci el bir kaynağın okunduğunu, "(doğrulanmadı)" ise bilginin kontrol edilemediğini gösterir. Gövdede kullanılmayan kaynaklar en sondaki "Okuma listesi"nde.

**Hatırlama, aralık, geri bildirim**
- Karpicke ve Roediger 2008, Science: https://doi.org/10.1126/science.1152408 · ek: https://learninglab.psych.purdue.edu/downloads/2008/2008_Karpicke_Roediger_ScienceSupportingMaterial.pdf · https://www.brucehayes.org/Teaching/papers/2008_Roediger_Karpicke_Science.pdf · https://profiles.wustl.edu/en/publications/the-critical-importance-of-retrieval-for-learning/ (madde 1)
- Rawson ve Dunlosky 2011, Journal of Experimental Psychology: General 140(3):283–302 (özet doğrulandı): https://doi.org/10.1037/a0023956 · ardışık yeniden öğrenme özeti: https://www.unh.edu/teaching-learning-resource-hub/sites/default/files/media/2023-06/itow-successive-relearning-dunlosky-greve-badali-wissman-rawson.pdf (madde 2, 2.3)
- Rowland 2014 meta-analiz: https://doi.org/10.1037/a0037559 (madde 1, 2.4)
- Koriat ve Bjork 2005: https://newiipdm.haifa.ac.il/wp-content/uploads/2015/05/2005-Koriat-Bjork-JEPLMC-KBA.pdf (madde 3)
- Rhodes ve Castel 2008: https://castel.psych.ucla.edu/wp-content/uploads/sites/111/2016/11/RhodesCastelJEPG2008.pdf (madde 3)
- Kornell ve Bjork 2008: https://bjorklab.psych.ucla.edu/wp-content/uploads/sites/13/2016/07/Kornell_Bjork_2008_Memory.pdf · https://doi.org/10.1080/09658210701763899 (madde 3, 2.2)
- Dunlosky ve Rawson 2012 (bulgu bu gözden geçirmede yeniden açılmadı): https://doi.org/10.1016/j.learninstruc.2011.08.003 (madde 3, 2.3 kutu 4–5)
- Nelson ve Dunlosky 1991, Psychological Science 2(4):267-270 (künye ikinci el kaynaktan) (2.2, 2.3 gecikmeli kontrol)
- Pan ve Rickard 2018, Psychological Bulletin 144(7):710–756 (özet doğrulandı): https://doi.org/10.1037/bul0000151 · not: https://notes.andymatuschak.org/zC1oBp6yE72b7YHzaJZmjXf (madde 4, 2.4)
- Little ve ark. 2012: https://doi.org/10.1177/0956797612443370 (1b, 2.4 çeldiriciler)
- Webb 2009, "The effects of receptive and productive learning of word pairs on vocabulary knowledge", RELC Journal 40(3), s. 360'tan başlıyor (makale açılmadı, bağlantı bulunamadı; künye ikinci el listeden). Aynı konudaki tez kaydı yalnız arka plan için: https://ir.wgtn.ac.nz/handle/123456789/23701 (2.4)
- Butler ve Roediger 2008: https://doi.org/10.3758/MC.36.3.604 (2.4)
- Butler, Karpicke ve Roediger 2008: https://profiles.wustl.edu/en/publications/correcting-a-metacognitive-error-feedback-increases-retention-of-/ (2.4 doğru cevapta geri bildirim)
- Butterfield ve Metcalfe 2001: https://dukespace.lib.duke.edu/items/d6ab09ca-f55c-4efb-9d32-2788bc5838b2 (2.4)
- Kluger ve DeNisi 1996: https://doi.org/10.1037/0033-2909.119.2.254 (madde 12, 2.4)
- Hattie ve Timperley 2007 (özet): https://doi.org/10.3102/003465430298487 · https://www.bera.ac.uk/blog/how-to-optimise-the-use-of-hattie-and-timperleys-feedback-levels-for-student-learning · https://assess.ucr.edu/media/746/download (madde 12, 2.5)
- Wisniewski, Zierer ve Hattie 2020: https://pmc.ncbi.nlm.nih.gov/articles/PMC6987456 (2.4)
- Nakata ve Webb 2016 (küçük setler): https://www.cambridge.org/core/journals/studies-in-second-language-acquisition/article/does-studying-vocabulary-in-smaller-sets-increase-learning/E17B75ABAE1300734AF014C363D59FBC (2.3)
- Kornell 2009: https://cir.nii.ac.jp/crid/1361699994055985152 (2.3 oturum içi aralık)
- Pyc ve Rawson 2009 (bu gözden geçirmede yeniden açılmadı): https://doi.org/10.1016/j.jml.2009.01.004 (2.1 widget kuralı)
- Cepeda ve ark. 2008: https://www.evullab.org/pdf/CepedaVulRohrerWixtedPashler-PS-2008.pdf (2.3)
- Kim ve Webb 2022: https://doi.org/10.1111/lang.12479 (2.3 tazeleme)
- Settles ve Meeder 2016: https://preview.aclanthology.org/fix_video/P16-1174.pdf (2.3 kayma kuralı)
- Bjork ve Bjork 2011: https://bjorklab.psych.ucla.edu/wp-content/uploads/sites/13/2016/04/EBjork_RBjork_2011.pdf (2.3 zorluk dengesi)
- FSRS hedef hatırlama oranı (kısmen doğrulandı): https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention (2.3 zorluk dengesi)
- Kornell, Hays ve Bjork 2009: https://pubmed.ncbi.nlm.nih.gov/19586265/ (2.3; ilişkili ipuçlarıyla)
- Hays, Kornell ve Bjork 2013, Journal of Experimental Psychology: Learning, Memory, and Cognition 39:290–296 (çevrimiçi 2012): https://sites.lifesci.ucla.edu/psych-bjorklab/wp-content/uploads/sites/13/2016/07/Hays_Kornell_RBjork_inpress.pdf (1b)
- Grimaldi ve Karpicke 2012, Memory & Cognition 40:505–513: https://learninglab.psych.purdue.edu/downloads/2012/2012_Grimaldi_Karpicke_MC.pdf (2.3; ilgisiz çiftlerde fayda yok)
- Potts ve Shanks 2014 (özet doğrulandı): https://doi.org/10.1037/a0033194 · https://discovery-pp.ucl.ac.uk/id/eprint/1399515 (2.3)
- MacLeod ve ark. 2010, üretim etkisi: https://doi.org/10.1037/a0018785 · https://uwaterloo.ca/memory-attention-cognition-lab/sites/default/files/uploads/files/jep10.pdf (2.3)

**Kelime öğrenimi ve kart içeriği**
- Kim, Lee ve Lee 2024, Language Teaching Research 28(1):7–28, ana dilde ve İngilizce açıklama (özet doğrulandı): https://todoele.net/bibliografia/relative-effects-l1-and-l2-glosses-l2-learning-meta-analysis (madde 6, 2.2)
- Barcroft, TOPRA (yazarın web sayfası, makale değil): https://sites.wustl.edu/barcroft/?p=461 (2.3 Tanış'ta anlam görevi yok)
- Sundararajan ve Adesope 2020, Educational Psychology Review 32:707–734 (dolaylı; g = −0,33 yalnız ikinci el özetlerde görüldü): https://doi.org/10.1007/s10648-020-09522-4 · özet: https://www.learningscientists.org/blog/2019/6/20-1 (madde 5)
- Hulme ve ark. 2023: https://researchportal.hw.ac.uk/en/publications/diversity-of-narrative-context-disrupts-the-early-stage-of-learni/ (2.2)
- Bağlam çeşitliliği taraması 2025: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12627139/ (2.2)
- Uchihara, Webb ve Yanagisawa 2019, Language Learning 69(3):559-599 (bağlantı yok; "2–20" ikinci el özetlerden) (2.1)
- Erten ve Tekin 2008, System 36(3):407–422 (60 dördüncü sınıf öğrencisi; kayıt sayfası ülkeyi yazmıyor): https://avesis.comu.edu.tr/yayin/4a84e8a3-294d-457c-9e11-65cbf94493a0/effects-on-vocabulary-acquisition-of-presenting-new-words-in-semantic-sets-versus-semantically-unrelated-sets (madde 8)
- Benzer kategorileri aralıklı karıştırma, Memory & Cognition (ayrıntısı açılmadı): https://www.springermedizin.de/article/10.3758/s13421-012-0272-7 (madde 8)
- Nation 2000, anlam setleri (özet): https://skyteach.ru/2020/01/03/learning-vocabulary-in-lexical-sets-by-paul-nation/ (madde 8)
- Üç şıklı soru (Rodriguez 2005, özet): https://tipsforteachers.substack.com/p/research-bite-20-three-options-are (2.4 AX boylarında 3 şık)
- Nation 2006, kelime kapsamı: https://www.wgtn.ac.nz/__data/assets/pdf_file/0018/1626120/2006-How-large-a-vocab.pdf (2.8)

**Türkçe konuşan öğrenci**
- Degani ve Tokowicz 2010: https://www.cambridge.org/core/journals/bilingualism-language-and-cognition/article/abs/ambiguous-words-are-harder-to-learn/C967BF447E791A76C1989EC2D92EB39A (2.1)
- Türkçe dilbilgisi (ekler): https://en.wikipedia.org/wiki/Turkish_grammar (madde 6)
- Laufer ve Girsai 2008: https://cris.haifa.ac.il/en/publications/form-focused-instruction-in-second-language-vocabulary-learning-a/ (madde 7, 2.2)
- Kupferberg ve Olshtain 1996: https://cris.huji.ac.il/en/publications/explicit-contrastive-instruction-facilitates-the-acquisition-of-d/ (madde 7)
- Yılmaz 2006, tanımlık hataları: https://digitalarchive.library.bogazici.edu.tr/handle/123456789/16545 (2.2)
- Aydın, Türk öğrencilerde kaygı (Asian EFL Journal cilt 31; yıl doğrulanmadı, sayfa bu gözden geçirmede açılamadı): https://www.asian-efl-journal.com/monthly-editions-new/an-investigation-on-the-language-anxiety-and-fear-of-negative-evaluation-among-turkish-efl-learners/ (2.7)
- Horwitz, Horwitz ve Cope 1986 (açılmadı): https://doi.org/10.1111/j.1540-4781.1986.tb05256.x (2.7)
- Microsoft Türkçe yazım kılavuzu: https://download.microsoft.com/download/c/7/e/c7e1f405-1a5a-418d-a56d-3a8c183cabd9/tur-tur-StyleGuide.pdf (2.10, 3)
- YKS net hesabı (haber, ÖSYM kılavuzu açılmadı): https://www.cnnturk.com/egitim/yksde-kac-yanlis-bir-dogruyu-goturur-yksde-3-yanlis-mi-4-yanlis-mi-bir-dogruyu-siler-2026-yks-net-hesaplama-yontemi-3433065 (2.5)
- Yavaş ve Altan 2016: https://www.jbe-platform.com/content/books/9789027266965-slcs.175.01yav · https://assta.org/proceedings/ICPhS2019Microsite/pdf/full-paper_922.pdf (2.7)
- Öney ve Durgunoğlu 1997: https://experts.umn.edu/en/publications/beginning-to-read-in-turkish-a-phonologically-transparent-orthogr/ (2.2 okunuş)
- Demirezen 2010, belirsiz ünlü: https://avesis.hacettepe.edu.tr/yayin/a3a2199c-0d38-4c37-abff-cf9bcf55bfcc/the-causes-of-the-schwa-phoneme-as-a-fossilized-pronunciation-problem-for-turks (2.2 okunuş)
- Unicode büyük harf kuralları (i/İ): https://www.unicode.org/Public/UCD/latest/ucd/SpecialCasing.txt (2.2)
- Akbulut 2018, kalıp fiillerden kaçınma: https://acikerisim.ibu.edu.tr/items/a5e3f94a-dc12-4a07-b6f0-e896a73af7b7/full (2.2)
- Badem ve Şimşek 2021: https://avesis.cu.edu.tr/yayin/034e46d4-0561-4312-b125-92fdf6e609c1/a-comparative-corpus-based-study-on-the-use-of-phrasal-verbs-by-turkish-efl-learners-and-l1-english-speakers (2.2)
- Neri, Cucchiarini ve Strik 2002: https://www.isca-archive.org/icslp_2002/neri02_icslp.html (2.7)

**Okuma, görme, dokunma**
- Legge ve Bigelow 2011: https://pmc.ncbi.nlm.nih.gov/articles/PMC3428264 (2.2)
- Bababekova ve ark. 2011, telefon okuma uzaklığı (PubMed sayfası açılamadı, doğrulanmadı): https://pubmed.ncbi.nlm.nih.gov/21499163/ (2.2)
- Rello, Pielot ve Marcos 2016 (özet): https://editingresearch.byu.edu/tag/make-it-big-the-effect-of-font-size-and-line-spacing-on-online-readability/ (2.2)
- Dobres ve ark. 2016, Ergonomics 59(10):1377–1391, açık ve koyu zemin: https://pmc.ncbi.nlm.nih.gov/articles/PMC5213401 (madde 10)
- Ferreira ve ark. 2014, kısa kullanım: https://doi.org/10.1145/2628363.2628367 (2.3)
- Parhi, Karlson ve Bederson 2006 (özet arama yoluyla görüldü): https://dx.doi.org/10.1145/1152215.1152260 (2.4)
- Hoober, ekran kenarında dokunma (ikinci el): https://www.uxmatters.com/mt/archives/2017/07/design-for-fingers-touch-and-people-part-3.php (2.4)
- Choi 2017, vurgulanan yazı: https://research.knu.ac.kr/en/publications/processing-and-learning-of-enhanced-english-collocations-an-eye-m/ (2.2)
- Perea, harf aralığı (2011 sonuçları okunmadı): https://www.uv.es/~mperea/spacing_AP.pdf (2.2)
- Wallace ve ark. 2022: https://jeffhuang.com/papers/Readability_TOCHI22.pdf (2.9)
- Mayer ve Pilegard, bölümleme: https://www.cambridge.org/core/books/cambridge-handbook-of-multimedia-learning/principles-for-managing-essential-processing-in-multimedia-learning-segmenting-pretraining-and-modality-principles/DD24C2F48B9B1277CE59F78276110258 (2.3 Tanış partileri)

**Alışkanlık, bildirim, mikro öğrenme**
- Silverman ve Barasch 2023, Journal of Consumer Research 49(6):1095–1117, seriler (özet doğrulandı): https://udspace.udel.edu/handle/19716/34160 · https://www.colorado.edu/business/faculty-research/2023/04/19/or-track-how-broken-streaks-affect-consumer-decisions (madde 11, 2.5)
- Lally ve ark. 2010: https://doi.org/10.1002/ejsp.674 (2.8)
- Gollwitzer ve Sheeran 2006: https://doi.org/10.1016/S0065-2601(06)38002-1 (2.8)
- Gray ve ark. 2018, karanlık desenler: https://doi.org/10.1145/3173574.3174108 (madde 11)
- Yancey ve Settles 2020, Duolingo hatırlatma şablonları: https://research.duolingo.com/papers/yancey.kdd20.pdf (2.10)
- Dingler ve ark. 2017: https://doi.org/10.1145/3098279.3098565 (2.8)
- Kushlev ve ark. 2016: https://www.interruptions.net/literature/Kushlev-CHI16.pdf (2.10)
- Fitz ve ark. 2019 (ayrıntı özetten): https://doi.org/10.1016/j.chb.2019.07.016 (2.10)

**Apple, WCAG, NN/g**
- HIG Widget'lar: https://developer.apple.com/design/human-interface-guidelines/widgets
- HIG Bildirimler: https://developer.apple.com/design/human-interface-guidelines/notifications
- HIG Bildirimleri yönetme: https://developer.apple.com/design/human-interface-guidelines/managing-notifications
- HIG Titreşim: https://developer.apple.com/design/human-interface-guidelines/playing-haptics
- HIG Açılış: https://developer.apple.com/design/human-interface-guidelines/onboarding
- HIG Yazı: https://developer.apple.com/design/human-interface-guidelines/typography
- HIG Erişilebilirlik: https://developer.apple.com/design/human-interface-guidelines/accessibility
- HIG Düğmeler: https://developer.apple.com/design/human-interface-guidelines/buttons
- HIG Koyu mod: https://developer.apple.com/design/human-interface-guidelines/dark-mode
- HIG Hareket: https://developer.apple.com/design/human-interface-guidelines/motion
- HIG Geri bildirim: https://developer.apple.com/design/human-interface-guidelines/feedback
- HIG Yazım: https://developer.apple.com/design/human-interface-guidelines/writing
- `isLuminanceReduced`: https://developer.apple.com/documentation/swiftui/environmentvalues/isluminancereduced
- WidgetKit etkileşim (kilitliyken düğmeler): https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities
- `relevanceScore`: https://developer.apple.com/documentation/usernotifications/unmutablenotificationcontent/relevancescore
- `UIAccessibilitySpeechAttributeLanguage`: https://developer.apple.com/documentation/uikit/uiaccessibilityspeechattributelanguage
- SwiftUI'de erişilebilirlik dili: https://useyourloaf.com/blog/swiftui-accessibility-language/
- Kilit ekranı düğmeleri ve kilit açma (forum, iOS 26'da doğrulanmadı): https://developer.apple.com/forums/thread/738252
- WCAG 1.4.3 kontrast (en az, AA): https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- WCAG 1.4.6 kontrast (geliştirilmiş, AAA): https://www.w3.org/WAI/WCAG22/Understanding/contrast-enhanced.html
- WCAG 2.2.1 zaman ayarlanabilir (bu gözden geçirmede açılmadı): https://www.w3.org/WAI/WCAG22/Understanding/timing-adjustable.html
- WCAG 2.5.8 hedef boyutu: https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html
- WCAG 2.3.3 etkileşimden doğan animasyon: https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html
- WCAG 1.4.8 görsel sunum: https://www.w3.org/WAI/WCAG22/Understanding/visual-presentation.html
- WCAG 1.4.1 rengin kullanımı: https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html
- WCAG 3.1.2 parçaların dili: https://www.w3.org/WAI/WCAG22/Understanding/language-of-parts.html
- NN/g koyu mod: https://www.nngroup.com/articles/dark-mode/ (2.1)
- NN/g aşamalı açma: https://www.nngroup.com/articles/progressive-disclosure/ (madde 5)
- NN/g simge kullanılabilirliği: https://www.nngroup.com/articles/icon-usability/ (2.1)
- NN/g aldatıcı desenler: https://www.nngroup.com/articles/deceptive-patterns/ (2.8)
- NN/g hata mesajları: https://www.nngroup.com/articles/error-message-guidelines/ (2.4)
- NN/g Liquid Glass: https://www.nngroup.com/articles/liquid-glass/ (3)
- NN/g sonsuz kaydırma: https://www.nngroup.com/videos/infinite-scrolling-when/ (2.2)

**Rakipler ve ürün kaynakları**
- Anki kılavuzu: https://docs.ankiweb.net/studying.html · https://docs.ankiweb.net/stats.html · https://docs.ankiweb.net/deck-options.html
- Anki forumu, "Zor" düğmesinin yanlış kullanımı: https://forums.ankiweb.net/t/how-to-prevent-users-from-misusing-hard-ideas-are-welcome/49092 · https://forums.ankiweb.net/t/pass-fail-grading-as-default/34147 (2.3)
- Duolingo blogu: https://blog.duolingo.com/widget-feature · https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals (2.1)
- Duolingo enerji sistemi tepkisi (ikinci el): https://www.androidauthority.com/quitting-duolingo-energy-system-3599842/ (3)
- App Store sayfaları: Lingo Widget https://apps.apple.com/us/app/id6740177041 · Monkey Taps https://apps.apple.com/us/app/id1084540807 · Kolay İngilizce https://apps.apple.com/tr/app/id1195424864 · WordUp https://apps.apple.com/us/app/id1365078730 · AnkiMobile https://apps.apple.com/us/app/id373493387 · Orbit https://apps.apple.com/tr/app/id6775767149

**Depo içi**
- `docs/tasarim/README.md`, `docs/tasarim/lockglow_ui_mockup.html` (renkler: 16–18. satırlar; Tekrar ve quiz: yaklaşık 1050–1141. satırlar; Söyle metinleri: 1210–1216; Ayarlar: 1260–1285; puan düğmeleri CSS: 301–306; nabız animasyonu: 190, 611)
- `ios/Packages/VocabKit/Sources/Learning/Leitner.swift` (`intervalDays [1,2,4,8,16]`, `relearnDelay` 10 dk, `refresherDelay` 30 gün, `hardFactor` 0,5, `review(.again)` → kutu 1, `markKnown`, `undoKnown`)
- `ios/Packages/VocabKit/Sources/Learning/QueueComposer.swift` (10 slotluk düzen: 6 tekrar, 3 yeni, 1 tazeleme), `ReviewPlanner.swift` (`newWords`: yalnız widget'ta görülen kelime yeni sayılır), `ProgressStore.swift`
- `ios/Packages/VocabKit/Sources/CoreModels/CardDetail.swift` (`Quiz.options(seed:)`, `falseFriend`)
- `ios/Packages/VocabKit/Sources/Pronunciation/PronunciationCheck.swift:496`
- `ios/App/AppPreferences.swift` (`rotationMinuteChoices = [5, 15, 30, 60, 120]`, `defaultRotationMinutes = 60`, `dailyNewWordChoices = [5, 10, 15, 20]`, `defaultDailyNewWords = 10`; listede olmayan değer varsayılana düşer), `ios/App/ReminderScheduler.swift:48-66`, `ios/App/FeedView.swift` (Akış'taki "Biliyorum")
- `ios/Widgets/AccessoryWordViews.swift:74-78` (`InlineWordView.firstMeaning`)
- `content/drafts/kisisel_v1/*/part_*.json` (934 kart: `def.micro`, `examples[].focus`, `l1.tr.mistakes`, `l1.tr.alt`, `tags.sensitivity`, `tags.flags`, `quiz.distractors`)
- `content-pipeline/vocabpipe/validate.py`, `docs/icerik_uretimi/1_yazar_kurallari.md`, `2_denetci_kurallari.md`, `3_celdirici_kurallari.md`
- `referans/orbit_widget_vocabulary_ekranlar/phone_1.jpg`, `phone_2.jpg`, `phone_4.jpg`, `phone_5.jpg`
- `raporlar/02_review_mining.md` (tema ve istek tabloları), `raporlar/03_rekabet_haritasi.md` (Monkey Taps şikâyetleri), `raporlar/05_buyume_gelir_modeli.md` §1.1 ve `raporlar/06_ux_ui_widget_tasarim.md` §0.2 (Monkey Taps açılış adımları), `raporlar/14_guncel_fark_raporu.md`, `docs/ozellik_planlari/soyle_telaffuz.md`, `docs/ozellik_planlari/acilis_akisi.md`

**Okuma listesi** (gövdede bir iddiaya bağlanmadı; ileride okunacak)
- Nakata ve Suzuki 2019: https://www.cambridge.org/core/product/F58BA8D70385603B9C42E408BFCB8A10
- Nakata 2015 (özet): https://callej.org/index.php/journal/article/download/87/396
- Nakata 2017, oturum içi tekrar sayısı: https://resolve.cambridge.org/core/journals/studies-in-second-language-acquisition/article/does-repeated-practice-make-perfect-the-effects-of-withinsession-repeated-retrieval-on-second-language-vocabulary-learning/F14BA8A576CD2563D14CEA46E35D842E (Hatırla'daki deneme sınırı için okunmalı)
- Soderstrom ve ark. 2015: https://sites.lifesci.ucla.edu/psych-bjorklab/wp-content/uploads/sites/13/2016/11/soderstorm_kerr.pdf
- Yanagisawa, Webb ve Uchihara 2020: https://www.cambridge.org/core/product/38124150D59DF3039EE1FF5AE88FE922
- Webb 2007, Language Teaching Research 11(1):63-81 (ayrıntı doğrulanmadı)
- Bracken ve ark. 2017: https://www.cambridge.org/core/journals/bilingualism-language-and-cognition/article/abs/translation-semantic-variability-how-semantic-relatedness-affects-learning-of-translationambiguous-words/6B10059E0691BC47483C486994F34518 ("/" kuralı için okunmalı)
- Chondrogianni ve Marinis 2016: https://centaur.reading.ac.uk/68298
- Levis ve Uzun 2025 (özet): https://www.iastatedigitalpress.com/psllt/article/id/21224/
- Bayraktaroğlu 2011: https://dergipark.org.tr/tr/download/article-cite-file/122921/type/2
- Erten ve Razı 2009: https://scholarspace.manoa.hawaii.edu/handle/10125/66632 · tekrar çalışması: https://forrt.org/flora-replication-atlas/doi/10.64152/10125/66632/
- Schneegass ve ark. 2021/22: https://arxiv.org/abs/2109.07944 · https://www.degruyterbrill.com/document/doi/10.1515/icom-2021-0037/html
- Dearman ve Truong 2012, duvar kâğıdından kelime öğrenme (sonuçlar doğrulanmadı; kilit ekranı için doğrudan ilgili, önce bu okunmalı): https://doi.org/10.1145/2207676.2208598
- SF Pro x-yüksekliği (üçüncü taraf, artık kullanılmıyor; yerine cihaz ölçümü): https://lists.w3.org/Archives/Public/public-css-archive/2022Sep/0987.html
- Ardışık yeniden öğrenme üzerine APS yazısı: https://www.psychologicalscience.org/observer/teaching-current-directions-studying-psychopathology

---

## Gözden geçirme

22 Ekim 2026'da bir eleştirmenin 35 düzeltmesi ve bir doğrulama notu işlendi; doğru bulunanlar uygulandı, ayrıldığım yerler en altta. Belgenin yapısı korundu; üç bölüm eklendi: 1c (ilk sürüm listesi), 2.12 (içerik işi) ve 2.13 (ölçüm). Kod ve içerik dosyaları değişmedi. Depo içi iddialar kodda ve içerikte yeniden kontrol edildi.

**Çelişkiler giderildi**
- Madde 3 yeniden yazıldı: kendini puanlama yalnız bir hatırlama denemesinden sonra. Kutu 4–5 ekranı "Göstermeden önce aklına geldi mi?" satırı, "Bulamadım / Buldum" düğmeleri ve büyük hedef kelime + Dinle ile tanımlandı; Dunlosky ve Rawson 2012 bu kurala bağlandı.
- Yazı tabanları yüzey yüzey verildi: Akış/Tekrar İngilizce okuma metni 17–18 pt, ana ekran widget'ı 15 pt; ikisinin de Lockglow seçimi olduğu, Apple'ın tabanının 11 pt olduğu yazıldı. Kilit ekranındaki 13 pt üçüncü satır kalktı.
- Açık zemin kararı düzeltildi: uygulama ve ana ekran widget'ı sistem görünümünü izler; kilit ekranında zemin sistemin. Dobres 2016 "kısa bakışta okunma eşiği %38,6 daha düşük (loş laboratuvar)" olarak yeniden yazıldı.
- İlk karşılaşmaya en çok 8 blok ve tek uyarı yuvası kuralı kondu (sahte dost > Dikkat > okunuş > iki karşılık > kalıp fiil). Sahte dost ilk görüşte tek satır; üç satırlık hâli "Neden?" sayfasında. Akış'taki "Biliyorum" Dinle ve Söyle ile aynı satıra kondu ki ayrı blok olmasın (bu yerleşim benim kararım).

**Eksikler eklendi**
- Widget cevabı Tekrar'dan önce vermez: 6 saat kuralı (a) ve "önce widget, sonra Tanış" sırası (b). (b)'de eleştirmenin önerdiği iki seçenekten "önce widget" seçildi, çünkü uygulamanın temel sözü kilit ekranı. Aynı kural bildirimdeki kelimeye de uygulandı; bu eleştirmenin listesinde yoktu, aynı sorun orada da vardı.
- 6/3/1 düzeni yerine açık slot bütçesi ve 30 dk, 1, 2, 4 saat için günlük tablo.
- Hatırla'nın Türkçe şıkları için kural (aynı konu ve tür; karışan eş kutu 2 altındayken yok; aynı anlamdan iki şık yok). Bugün 59 kartta aynı konu ve türden 3 farklı anlam bulunmadığı için "aynı tür ve seviye" yedeği eklendi.
- Hatırla'da en çok iki deneme. Eleştirmen "2 retries" dedi ama "ikinci yanlıştan sonra" bitirmeyi istedi; ikincisine uyuldu (toplam iki deneme). B1 için 5'erli iki parti.
- "Biliyorum" 3 gün kontrolünün dört kuralı (soru türü, `knownOverride` ve +3 gün, sonuç, eski işaretlerin göçü) ve 5 saniyelik "Geri al"ın yeniden kullanımı.
- Mevcut kullanıcı göçü: 5 ve 15 dk → 30 dk, 240 eklenir; seçilmiş günlük hedef korunur.
- Dokunma bütçesi tablosu, tek ve yer değiştirmeyen alt düğme, "sesli söyle" daveti 5 kartta 1.
- Yerel ölçüm ve kabul hedefleri (2.13), bir açılışta tek sistem kartı kuralı, haftalık sayının "0 gün" göstermemesi.
- Kayma kuralı kararı: iki kutu aşağı (ürün seçimi, FSRS'e kadar). Süreler "en az" diye yazıldı.
- Hassas içerik etiketlemesi ön koşul yapıldı; geçici süzgeç eklendi (bugün yalnız 4 kartı yakalıyor).
- Kutu 2–3 örnek cloze kuralı (`focus == quiz.answer` ve çeldirici uymama onayı) ve 3_celdirici_kurallari.md / doğrulayıcı işi.
- Küçük widget'ta kelime sığdırma basamakları ve SE testleri. Benim kaba hesabıma göre "misunderstanding" 17 pt'de de sığmayabilir; bunun için 15 pt son basamağı ve "sığmazsa küçük widget'ta atla" kuralı eklendi (eleştirmenin listesinde yoktu).

**Sözler ve etiketler**
- "10 dakika sonra yine gelir" sözü kalktı; "Bir sonraki turda yine soracağız" oldu.
- Etiket tanımı değişti: ŞART yalnız birincil kaynak ya da Apple/WCAG kuralı (tek istisna şık karıştırma). Kaynağı olmayan ŞART'lar ÖNERİ'ye indi; kalanlardan bazıları WCAG 2.2.1 ve 1.4.1'e bağlandı. Etiketli madde sayısı: önce 47 ŞART, 73 ÖNERİ, 18 BELKİ; şimdi 27 ŞART, 99 ÖNERİ, 20 BELKİ (eleştirmenin 48/74/22'si tanım satırlarını ve tablo içi anmaları da sayıyordu). İnenler arasında "/" kuralı, `gloss_short`, kilit ekranında animasyon yok, widget "Biliyorum" onayı, "Bunu zaten biliyorum", "kelime asla sıkıştırılmaz" ve 60 pt şık kuralı var (Parhi 2006: 7,7 mm üstünde hata farkı yok).
- Kontrast: sözlükteki "7:1 küçük yazı için" düzeltildi; ink2 #474E54'e koyulaşıyor; surface3 üstünde ink3 yasak (koyu temada da 4,08:1, eleştirmen yalnız açık temayı söylemişti).
- 17 pt gerekçesi New York seriften yeniden kuruldu ve cihaz ölçümüne bağlandı.
- Söyle'de zaten var olan "Geç" ve "duyduğum" önerileri yeni işten çıkarıldı, "Zaten doğru, koru"ya taşındı.
- Bildirim şablonlarından sayı ve görev çıktı; karışan çift şablonuna kutu 2 koşulu kondu.

**Kaynaklar**
- Eklendi: Rawson ve Dunlosky 2011 (birincil), Sundararajan ve Adesope 2020 (dolaylı), Grimaldi ve Karpicke 2012, WCAG 1.4.3, 1.4.6 ve 2.2.1. Webb 2009 tez kaydı yerine RELC Journal makalesi (DOI bulunamadı). Hays, Kornell ve Bjork'un yılı 2013 oldu.
- Yeniden yazıldı: madde 2 (Rawson ve Dunlosky), madde 4 (Pan ve Rickard), madde 5 (NN/g ve HIG; TOPRA Tanış'a taşındı), madde 6 (Kim, Lee ve Lee), Uchihara (sayı silindi, [BELKİ]), "Önce kelime, sonra anlam" (Potts ve Shanks, [ÖNERİ]).
- Kullanılmayan kaynakların çoğu bir iddiaya bağlandı (ör. Rodriguez → AX'te 3 şık, Pyc ve Rawson → widget kuralı, Settles ve Meeder → kayma kuralı, Yancey ve Settles → şablon dönüşümü, Kushlev ve Fitz → günde tek bildirim). Bağlanamayan 15 kaynak "Okuma listesi"ne taşındı.
- Kaynaksız iddialar: Duolingo iddiası "(doğrulanmadı)" oldu. "Kendi kelimeni ekle" ve Monkey Taps düğmesi `raporlar/02` ve `raporlar/03`'e bağlandı. Widget güncellenmeme iddiası "tekrar eden bir şikâyet (yaklaşık %1)" oldu. Aydın'ın yılı bulunamadı. Benim de bulduğum iki kaynaksız iddia düzeltildi: kilit/ana ekran eşitleme (`raporlar/02` istek 8) ve seviye uyuşmazlığı (`raporlar/02`).

**Eleştirmenle ayrıldığım yerler**
- "13 adımlık anket" için eleştirmen "raporlarda karşılığı yok" dedi. Karşılığı var: `raporlar/06` §0.2 Monkey Taps açılışını "about 13 steps" diye anlatıyor, `raporlar/05` §1.1 kaynağa göre 13–22 adım diyor. Silinmedi; bu iki rapora bağlandı. Yalnız "en düşük puanlı yorumları topluyor" kısmı kaynaksızdı; yerine `raporlar/02`'nin para teması ve `raporlar/03`'teki ödeme duvarı yorumu kondu.
- Eleştirmenin içerik sayıları (81, 42, 684, 135, 1.699 / 2.787, 526 / 1.856) `s0_ornek`'teki 5 örnek kart olmadan, yani 929 kart üzerinden. Belgenin geri kalanı 934 kartı saydığı için sayılar 934 üzerinden yeniden hesaplandı: 83, 43, 693, 136 (139 bayrak), 1.737 / 2.802, 512 / 1.866 (`focus ≠ quiz.answer`; `focus ≠ lemma` 527).
- Kayma kuralında eleştirmen "karar ver ya da FSRS'e bırak" dedi. Karar verildi (iki kutu aşağı), ama kanıtı olmadığı açıkça yazıldı.
- Eleştirmenin önerdiği bazı kabul eşikleri (Bitir oranı, "Biliyorum" başarısızlık oranı) için sayı verildi, ama bunların kanıta değil bizim seçimimize dayandığı yazıldı.
