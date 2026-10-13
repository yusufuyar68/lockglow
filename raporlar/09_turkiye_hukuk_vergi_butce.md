# Türkiye'den abonelikli iOS uygulaması (kelime widget'ı) için hukuk, vergi, hesap ve bütçe raporu

Rapor tarihi: 10 Ekim 2026. Kur varsayımı: 1 USD ≈ 49,2 TL, 1 EUR ≈ 55,3 TL (8 Ekim 2026 serbest piyasa kuru, [Türkgün](https://www.turkgun.com/ekonomi/dolar-bugun-ne-kadar-7-ekim-2026-dolar-euro-kuru-kac-tl/405055)). Bütçede 1 USD = 49 TL aldım.

Etiketler:
- **[R]** resmi/birincil kaynak (Apple, GİB, IRS, KVKK, Anthropic vb. sayfalarını doğrudan okudum)
- **[İ]** ikincil kaynak (hukuk/muhasebe blogu, haber, forum)
- **[T]** benim tahminim, kaynağı yok
- **[TEYİT]** mali müşavir (SMMM/YMM) veya avukat onayı şart

Bu bir hukuki/vergi tavsiyesi değildir.

---

## 0. Yönetici özeti

1. **Düzeltme:** "GVK 20/B" Genç Girişimci istisnası değildir. Genç girişimci istisnası **GVK Mükerrer 20**'dir. **GVK Mükerrer 20/B**, "sosyal içerik üreticiliği ve mobil cihazlar için uygulama geliştiriciliği" istisnasıdır. Bu istisna senin durumun için en kritik rejimdir.
2. **Mükerrer 20/B nedir?** GİB broşürü (Aralık 2024) uygulama mağazalarından gelen "ücretli uygulama satışı, reklam, uygulama içi satış, sponsorluk ve ücretli abonelik" gelirlerinin kapsamda olduğunu açıkça yazıyor [R] ([GİB broşürü PDF](https://www.alomaliye.com/wp-content/uploads/2024/12/2024-icerik-kazanc-istisna.pdf)).
   - Banka, Türkiye'deki özel hesaba yatan hasılattan **%15 nihai stopaj** keser.
   - KDV hesaplanmaz.
   - Yıllık sınır 2026 için **5.300.000 TL**'dir (≈ 108 bin USD) [İ].
   - Şirket (kurumlar vergisi mükellefi) kullanamaz.
3. **"Yazılım ihracatı" kazanç indirimi (GVK 89/13, KVK 10/1-ğ):**
   - 30.04.2026 tarihli **11257 sayılı Cumhurbaşkanı Kararı** ile oran %80'den **%100**'e çıktı. 1.1.2026'dan itibaren başlayan dönemlere uygulanır ([KPMG](https://kpmgvergi.com/yayinlar/mali-bultenler/vergi/bazi-hizmet-ihracati-ve-yurt-disi-istirak-kazanclarina-uygulanan-istisna-ve-indirim-oranlari-artiran-cumhurbaskani-karari-yayimlandi/4481), [Resmî Gazete PDF](https://www.resmigazete.gov.tr/eskiler/2026/04/20260430-1.pdf)) [İ].
   - App Store geliri için bu indirimin geçerliliği **tartışmalı**: GİB'in 30.01.2026 özelgesi "münhasıran yurt dışı" şartı yüzünden karşı çıkıyor. Danıştay 3. Daire'nin 21.10.2025 tarihli bir kararı ise (Google Play, KDV) lehte [İ]. Detay §2.3.
4. **Apple başvurusu:** Şahıs şirketi = Apple'a göre **bireysel** kayıt. Ltd./A.Ş. = kurumsal kayıt (D-U-N-S, kurumsal domain e-postası ve site gerekir).
5. **AB DSA tuzağı:** Bireysel hesapta adresin, telefonun ve e-postanın AB mağaza sayfalarında **herkese açık** gösterilmesi gerekiyor. Kurumsal hesapta D-U-N-S adresi otomatik gösterilir [R].
6. **ABD vergi formu:** W-8BEN (bireysel) veya W-8BEN-E (şirket). Apple ile ilgili rehberler anlaşma maddesi olarak Madde 7 (ticari kazanç), oran %0 öneriyor. ABD–Türkiye anlaşmasındaki telif (royalty) üst oranı %10'dur [R] ([IRS metni](https://www.irs.gov/pub/irs-trty/turkey.pdf)).
7. **Türkiye'ye özgü pratik risk:** Apple Developer forumlarında Mayıs–Ağustos 2026'da Türkiye'den üyelik ödemesinin reddedilmesi ve kimlik doğrulamanın başarısız olması şikayetleri var. Takvime 2–4 hafta tampon koy [İ].
8. **Bağ-Kur sürprizi:** 2026'da asgari 4/b primi aylık yaklaşık 11.400–11.800 TL (≈ 235–240 USD). Genç girişimci prim desteği 1.1.2026'da kaldırıldı. 20/B ile de 4/b doğup doğmadığı konusunda kaynaklar çelişiyor [TEYİT].
9. **Bütçe (tek seferlik + %15–20 kontenjan):** düşük ≈ **1.400 USD (≈ 69 bin TL)**, orta ≈ **5.900 USD (≈ 289 bin TL)**, yüksek ≈ **24.100 USD (≈ 1,18 milyon TL)**. Detay §6.
10. **Nakit akışı:** Apple, mali ay sonundan sonra **45 gün içinde** ödeme yapar. İlk para lansmandan yaklaşık 6–10 hafta sonra gelir [R].

**Benim ön eğilimim [T, TEYİT]:** Başlangıçta tek kurucu için şahıs + Apple bireysel hesap + Mükerrer 20/B en az sürtünmeli yol görünüyor. Şu durumlarda Ltd.'ye geçişi değerlendir:
- ortak veya yatırımcı gelirse,
- gelir limite yaklaşırsa,
- sorumluluk ayrımı ve kurumsal satıcı adı istersen.

Aşağıdaki tablolar karar için gereken bilgileri veriyor. SMMM ile 1 saatlik ücretli görüşme yap (§8'deki soru listesiyle).

---

## 1. Apple Developer hesabı, bankacılık, vergi formları

### 1.1 Bireysel vs kurumsal

| | Bireysel (şahıs şirketi dahil) | Kurumsal (Ltd./A.Ş.) |
|---|---|---|
| Satıcı adı (mağazada görünen) | Yasal adın (takma ad/şirket adı olmaz) | Tüzel kişi unvanı (DBA, ticari ad, şube olmaz) |
| D-U-N-S | Gerekmez | Zorunlu. Ücretsiz. D&B'nin vermesi **≤ 5 iş günü**, Apple'a yansıması **≤ 2 iş günü** |
| Ücret | 99 USD/yıl, "yerel para birimiyle, bölgeye göre değişir" | Aynı |
| Ek koşullar | Kendi kartınla ödeme; fotoğraflı kimlik istenebilir | Bağlayıcı yetki; kurumsal domain e-postası; çalışan, kurumsal domaine bağlı genel erişime açık site (sosyal medya/yer tutucu site kabul edilmez); gerekirse noter onaylı belge |
| Yayın zamanı | Ödeme hemen yapılabilir | Apple doğrulaması sonrası ödeme; süre belirtilmemiş |

Kaynaklar: [Apple – Program enrollment](https://developer.apple.com/help/account/membership/program-enrollment/), [Apple – D-U-N-S](https://developer.apple.com/support/D-U-N-S/) [R]. Apple D-U-N-S sayfası "tek kişilik işletmeler bireysel kayıt olmalı" diyor.

**Türkiye'de gözlenen sorunlar (hepsi [İ], forum, tek tek kişi beyanı):**
- Bireysel kayıtta ödemenin tekrar tekrar reddedilmesi. Mayıs 2026'da açılan başlıkta Temmuz–Ağustos'ta başka kullanıcılar da aynı sorunu bildirmiş ([thread 827387](https://developer.apple.com/forums/thread/827387)). Ağustos 2026'da başka bir kurum (organization) kaydı da aynı sorunu yaşamış; Apple "Developer app'ten yeniden başvurun, destekle yazışın" demiş ([thread 842043](https://developer.apple.com/forums/thread/842043)).
- Ödemeden sonra üyeliğin aktif olmaması: Aralık 2025'te 1.029 TL ödenmiş ([thread 809589](https://developer.apple.com/forums/thread/809589)). Bu, TR'de üyelik bedelinin 1.029 TL olarak bildirildiğini gösteriyor. Resmî güncel TL fiyatı doğrulayamadım; ödeme ekranında kontrol et.
- Kimlik doğrulama: "Ömer" gibi Türkçe karakterli isimde doğrulama art arda başarısız, 2+ ay çözülememiş ([thread 841615](https://developer.apple.com/forums/thread/841615)).
- Kurumsal kayıtta Apple'ın Türkçe belgeleri kabul etmeyip noter/yeminli çeviri istediği bir vaka var (sonuç bilinmiyor); D-U-N-S ile unvan uyuşmazlığı vakaları ve unvanında Apple markası geçtiği için iptal edilen kayıt (arama sonuçları, güncel kaynak linki yok).

**Öneri [T]:** Kurumsal kayıtta unvanı "Ltd. Şti." eki ve Türkçe karakterler dahil birebir aynı yaz. D-U-N-S profili uyuşmazsa D&B destek formunu kullan. Bireysel kayıtta pasaport/kimlikteki isim yazımıyla birebir uyumlu ol; ilk denemede başarısız olursa çok sayıda yeni Apple ID açma.

### 1.2 AB DSA "trader" durumu

[R, Apple Help](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-compliance-information):
- AB'de dağıtılan uygulamalarda "trader" beyanı gerekir. Gelir elde ediyorsan trader sayılma ihtimalin yüksek. Apple senin yerine karar vermez.
- **Bireysel:** adres (veya P.O. Box, belgeyle), telefon, e-posta verilir. Adres belgeyle doğrulanır. Üçü de **27 AB ülkesindeki ürün sayfalarında herkese açık** yayınlanır.
- **Kurumsal:** D-U-N-S adresi otomatik gösterilir. Sen telefon ve e-posta girersin.
- Telefon ve e-posta 2FA ile doğrulanır. Beyan sadece AB dağıtımı için; Apple "TestFlight veya AB dışı dağıtımda trader değilsin" diyor.
- Trader bilgisi eksikse uygulama AB'den kaldırılabilir [İ: heise, SD Times özeti].

**Mahremiyet notu [T]:** Evden çalışan bir şahıs için ev adresi AB'de açık yayınlanır. Çözüm: ofis/coworking adresi ve belgeler, ya da şirket kurmak.

### 1.3 Paid Applications Agreement ve bankacılık

- Paid Apps Agreement'ı **Account Holder** kabul eder. Bankacılık bilgisi ve vergi formu tamamlanmadan sözleşme yürürlüğe girmez; abonelik satamazsın [R].
- Ödeme koşulları: ödeme, bankacılık bilgisinde belirttiğin **para biriminde** yapılır. Apple'ın bankası gerekirse çevirir (genelde ödeme günü spot kur). Mali ay sonundan sonra **45 gün içinde**, her para birimi için ayda tek ödeme. Bölge başına asgari aylık eşik var; tutar bulduğum sayfalarda yok. Bir forum yorumu 150 USD diyor [İ, tarihsiz]. Ara/muhabir banka kesintileri olabilir [R] ([payments overview](https://www.developer.apple.com/help/app-store-connect/getting-paid/overview-of-receiving-payments), [payment information](https://developer.apple.com/help/app-store-connect/reference/reporting/payment-information)).
- Hesap sahibi adı bankadaki kayıtla birebir aynı olmalı ve **İngilizce karakterlerle** yazılmalı. IBAN'ı hesap numarası alanına yazma. Girdiğin bilgi senin bankana ait olmalı (ara bankaya değil). Para birimi hesabın para birimiyle uyumlu olmalı. Admin/Finance değişikliklerini Account Holder onaylar [İ, Apple help özetleri].

**USD mi TRY mi?**
- Apple "ödeme, belirttiğin para biriminde" diyor. Apple'ın TL ödemesi yaptığına dair bir kaynak bulmadım. Pratik yol, bankadan USD hesap ve IBAN/SWIFT/şube kodu almaktır.
- Mükerrer 20/B için hasılatın tamamının Türkiye'de kurulu bir bankadaki özel hesaba gelmesi şart [R, GİB broşürü]. Döviz yatarsa banka, aktarım tarihindeki döviz alış kuruyla %15 stopajı keser [İ].
- **Hangi banka?** Apple'ın resmî bir Türk bankası listesi yok. Garanti/İş Bankası/Akbank için Apple ödemesi alındığını doğrulayan kaynak bulamadım. Banka şubesinden yazılı olarak USD hesabın IBAN/SWIFT ve Apple için gereken "routing/şube kodu" formatını al. Eski bir forum yorumu 16 haneli hesap no. ve şube kodu istendiğini anlatıyor [İ].

### 1.4 Vergi formları (W-8BEN / W-8BEN-E) ve anlaşma oranı

- Türkiye dahil ABD dışı geliştiriciler W-8BEN (bireysel), W-8BEN-E (şirket) veya W-8ECI doldurur. App Store Connect > Business > Agreements > Tax Forms'tan yapılır. Rol: Account Holder/Admin/Finance. Form, Paid Apps Agreement yürürlüğe girmeden tamamlanmalı [R, Apple help].
- Türkiye için alan talimatı [İ, [Kerem Erkan rehberi](https://keremerkan.dev/posts/w-8ben-e-instructions-apple-google/)]:
  - Bireysel hesapta vergi kimlik no. alanına T.C. kimlik numarası, şirkette 10 haneli vergi kimlik numarası yazılır.
  - Madde 15'te Apple'ın yönergesi: **Madde 7, paragraf 1, oran 0, "income from the sale of applications"**. Anlaşmanın aynı yapıya sahip olduğunu IRS PDF'inden teyit et.
- Apple Finance'in forum yanıtlarına göre App Store sözleşmeleri telif değil satış/komisyon ilişkisi sayılıyor. ABD dışı geliştirici satışları için ABD stopajı yok, ama ABD mağazası satışları için imzalı W-8 ödemeden önce gerekli [İ, forum özeti].
- IRS metni: Madde 12'de telifler (copyright, patent, marka vb.) için kaynak devlet vergisi en fazla **%10**, ekipman kirası için **%5** [R, [US–Turkey treaty](https://www.irs.gov/pub/irs-trty/turkey.pdf)]. Form eksik/geçersizse genel kural %30'dur [İ]. Madde 7 mi Madde 12 mi sorusu için **[TEYİT]**.
- Apple Developer Support vergi formu konusunda tavsiye vermiyor; Finance iletişim formuna yönlendiriyor [İ, forum].
- Bazı Türk bireysel geliştiricilerde W-9 veya W-8BEN-E yanlış formun gösterildiği forum vakaları var [İ].

**Kimin satıcı olduğu:** Apple'ın Schedule 2 eklerinin çevirilerinde Türkiye, "Apple Distribution International Ltd." (Cork, İrlanda) komisyoncu listesinde görünüyor (İtalyanca/Slovakça/İsveççe çeviriler, [örnek PDF](https://developer.apple.com/support/downloads/terms/exhibits/Exhibits-to-Schedule-2-and-3-Italian.pdf)). İngilizce güncel metni doğrula [TEYİT].

### 1.5 Apple Small Business Program (%15 komisyon)

[R, [Apple SBP](https://developer.apple.com/app-store/small-business-program/)]:
- Uygun: önceki takvim yılında (12 mali ay) tüm uygulamaların **proceeds**'u (komisyon ve bazı vergiler düşüldükten sonra) ≤ 1 milyon USD. Yeni geliştiriciler de uygun. Yıl içinde 1 milyon USD'yi aşarsan o andan sonra standart oran uygulanır; sonraki yıl şartı yeniden sağlarsan %15'e dönersin.
- Başvuru: Account Holder olmak, en güncel Paid Apps Agreement'ı kabul etmek, varsa **Associated Developer Accounts**'ları bildirmek. Aynı sahibi olan şahıs ve Ltd. hesapların proceeds'u toplanır.
- Oran, onay tarihini içeren mali ay sonundan 15 gün sonra geçerli olur.
- Adapty "yeni geliştiriciler otomatik" diyor, Apple sayfası başvuru adımlarını listeliyor. İlk hesap açılışında App Store Connect'te durumu kontrol et.

---

## 2. Türkiye: şirket türü, vergi, KDV, fatura, Bağ-Kur

### 2.1 Seçenek karşılaştırması

Tutarlar 2026. [TEYİT] tüm satırlar için geçerli.

| | A) Şahıs + **Mükerrer 20/B** | B) Şahıs (gerçek usul) + GVK 89/13 %100 + KDV ihracat | C) Ltd./A.Ş. + KVK 10/1-ğ | D) Teknokent şirketi |
|---|---|---|---|---|
| Apple kaydı | Bireysel | Bireysel | Kurumsal | Kurumsal (veya şahıs) |
| Vergi | Hasılatın **%15'i nihai stopaj** (gider düşülmez) | Normal tarife (%15–40), 89/13 kabul edilirse indirim | KV %25 (münhasıran ihracatta 5 puan indirim), asgari KV %10, kâr payı stopajı %15 | 4691 geçici md. 2: bölgedeki yazılım/Ar-Ge kazancı 31.12.2028'e kadar vergi dışı |
| Belge/KDV | Fatura yok, KDV hesaplanmaz (KDV 17/4-a) | Apple adına e-arşiv, KDV %0 (kod 302) | Aynı | Bölgede üretilen yazılım KDV'den istisna |
| Defter/SMMM | Asgari | Gerçek usul defter | Bilanço | Bilanço + bölge raporlaması |
| Ana risk | Bağ-Kur; 5,3 M TL limiti; gider yok | GİB karşıtı özelge; münhasıran yurt dışı | Asgari KV, kâr payı stopajı, sermaye 50.000 TL | Kira, fiziki faaliyet/PDKS, proje onayı |

### 2.2 Mükerrer 20/B ayrıntıları

[R: GİB broşürü + [fatiharas özeti](https://www.fatiharas.com/gvk-mukerrer-madde-20-b-sosyal-icerik-ureticiligi-istisnasi/) [İ]]
- Yasal dayanak: 7338 sayılı Kanun (1.1.2022), 7491 ile genişletilmiş (27.12.2023). Uygulama: 318 ve 325 No'lu GVK Genel Tebliğleri.
- Kapsam: "akıllı telefon veya tablet gibi mobil cihazlar için uygulama geliştirenlerin elektronik uygulama paylaşım ve satış platformları üzerinden elde ettikleri kazançlar". **Platform dışı** kazançlar (ör. kendi web sitenden Stripe ile satış) kapsam dışı.
- Şartlar: vergi dairesinden istisna belgesi, Türkiye'de kurulu bankada hesap, tüm hasılatın **yalnızca bu hesaba** tahsili, banka/şube/IBAN bilgisinin **1 ay içinde** vergi dairesine bildirilmesi. Kurumlar vergisi mükellefleri yararlanamaz. Adi ortaklık içinde yararlanılamaz.
- Yıllık sınır: 4. gelir dilimi. 2024: 3.000.000; 2025: 4.300.000; **2026: 5.300.000 TL**. Aşılırsa o yılın kazancının tamamı beyan edilir (banka stopajı mahsup edilir). Banka sınırı izlemez, kesmeye devam eder.
- Stopaj matrahı hasılattır (gider düşülmez), nihai vergidir.
- Cumhurbaşkanı oranı 0'a kadar indirebilir, bir katına kadar artırabilir.
- Danıştay 3. Daire (E:2023/3085, K:2024/1262): istisnadan yararlansan bile mükellefiyet tesisi hukuka uygun [İ].
- Banka 2024 örneğinde hesap dışı nakit tahsilat tespit edilirse tüm yılın beyanı gerekir (GİB örnek 7) [R].

**Basit örnek (benim aritmetiğim, [TEYİT]):** Yıllık Apple ödemesi 60.000 USD (≈ 2,94 M TL).
- 20/B vergisi: 441.000 TL.
- Gerçek usulde gider oranı ~%25 ise (matrah ≈ 2,2 M TL) normal tarife vergisi ≈ 652.500 TL (2026 ücret dışı tarife: 190 bin/%15, 400 bin/%20, 1 M/%27, 5,3 M/%35 üzeri %40; kaynaklar üçüncü dilim sınırında kısmen çelişiyor).
- Gider oranı ~%46'nın üzerine çıkarsa normal tarife 20/B'den ucuzlar.
- Genç girişimci istisnası (aşağıda) normal tarifede 3 yıl ek avantaj sağlar.

### 2.3 "Yazılım ihracatı" kazanç indirimi ve KDV: App Store'da neden tartışmalı?

- 11257 sayılı Karar (RG 30.04.2026, sayı 33239): GVK 89/1-13 ve KVK 10/1-ğ indirimi %80 → **%100**, 1.1.2026 sonrası dönemler [İ, KPMG]. Şartlar sürüyor: hizmet yurt dışında yerleşik müşteriye verilecek, **münhasıran yurt dışında yararlanılacak**, fatura **yurt dışı müşteri adına** düzenlenecek, bedel yıllık beyanname tarihine kadar **tamamen Türkiye'ye getirilecek** (şahıs için 31 Mart) [İ].
- **GİB özelgesi (30.01.2026, 62030549-125-143061):** Google Play ve App Store'da yayınlanan, hem yurt içi hem yurt dışı kullanıcıya açık AI/mobil oyun uygulaması için:
  - uygulama yalnızca yurt dışı müşteriler tarafından kullanılıyorsa hizmet ihracı sayılır, KDV hesaplanmaz;
  - yurt içi kullanım varsa **hizmet ihracı sayılmaz**, KDV hesaplanır;
  - KVK 10/1-ğ indirimi ve KVK 32/7 beş puan indirimi uygulanamaz.
  - Özelge "muhtelif müşteri adına toplu fatura" sorusunu Maliye Bakanlığı'na (VUK mükerrer 257) havale ediyor.
  - Özelge yalnızca kurumlar tarafını ele alıyor; gerçek kişilere (GVK) dair bir şey söylemiyor.
  - Kaynaklar: [Alomaliye](https://www.alomaliye.com/2026/02/18/app-store-ve-google-playden-elde-edilen-gelirler-nasil-vergilendirilir/), [Muhasebenews](https://www.muhasebenews.com/app-store-ve-google-play-gelirlerinin-vergilendirilmesi-2026-mobil-uygulama-abonelik-ve-uygulama-ici-satin-alma-gelirlerinde-kdv-ve-kurumlar-vergisi/).
- **Danıştay 3. Daire, E:2022/3559, K:2025/4071 (21.10.2025, oybirliği):** Google Play'den uygulama satışı ve reklam geliri; platformu işleten yurt dışı şirket hizmetten doğrudan faydalanıyor, Türk kullanıcıların erişimi "yurt dışında faydalanma" şartını bozmaz, bozma kararı. Konu **KDV**. Apple'dan söz etmiyor [İ, [fatiharas](https://www.fatiharas.com/hizmet-ihraci-kdv-danistay-karari/)]. GİB özelgesi karşıtı görüştedir.
- Özelge yalnızca başvurana bağlayıcı; kendi durumun için GİB'e özelge talebi yapılabilir [TEYİT].
- Savunma seçeneği olarak bazı kaynaklar Türkiye mağazasını kapatmayı öneriyor [İ]. Bu Türkiye gelirini keser.
- Fatura brüt mü net mi? Bir kaynak brüt tutarı fatura edip komisyonu gider yazmayı, net tutarı fatura etmenin "eksik hasılat" olduğunu söylüyor [İ, [İstanbul Mali Müşavirlik](https://www.istanbulmalimusavirlik.net/mobil-oyun-studyosu-sirket-kurulusu-ve-vergi-istisnasi/)]; başka bir kaynak net üzerinden örnek veriyor [İ, [Paraşüt](https://www.parasut.com/blog/mobil-uygulama-satislarinin-vergilendirilmesi)]. **[TEYİT]**
- Asgari kurumlar vergisi (KVK 32/C, 7524): KV, indirim/istisna öncesi kazancın %10'undan az olamaz. 10/1-ğ indirimi bu matrahtan **düşülemiyor**, yani %100 indirimle bile ~%10 vergi çıkabilir; yeni kurulan kurumlar için 3 hesap dönemi muafiyet var [İ, [Alomaliye 17.05.2026](https://www.alomaliye.com/2026/05/17/hizmet-ihracati-kazanc-ve-kurumlar-vergisi-indirimi-asgari-kurumlar-vergisi-ve-kdv-istisnasi/)] [TEYİT]. Çelişki ve 5 puan indirimin asgari vergiye uygulanıp uygulanmayacağı "şimdilik bilinmiyor" deniyor.

### 2.4 Genç girişimci kazanç istisnası (GVK mükerrer 20)

[İ, [Habertürk](https://www.haberturk.com/2026-yilinda-genc-girisimci-tesviki-ne-kadar-3856269-ekonomi)]
- 2026 kazançlarının **400.000 TL**'ye kadarı vergiden istisna (2025: 330.000 TL), faaliyete başlanan yıl dahil **3 takvim yılı**.
- Şartlar: ilk kez gelir vergisi mükellefiyeti, mükellefiyet başlarken 18–29 yaş (29'u doldurmamış), işin başında bizzat çalışma. Mevcut işletmeye sonradan ortak olanlar yararlanamaz.
- Bağ-Kur genç girişimci prim desteği (5510 md. 81/k) 31.12.2025'te kaldırıldı. 2026'da 4/b primini kendin ödersin.
- Gelir vergisi istisnası sürüyor. Üç yıl yerine beş yıl önerisi (TBMM teklifi) yasalaştı mı teyit edilemedi.
- Bu istisna normal gerçek usul kazançta işe yarar; 20/B'nin final stopajıyla birleşimi için SMMM'ye sor [TEYİT].

### 2.5 e-Arşiv / e-Fatura, KDV, DST

- Yurt dışı müşteriye hizmet ihracı faturası: e-Arşiv, KDV %0, istisna kodu **302** (301 mal ihracı); alıcı VKN alanına "2222222222"; döviz tutarı ve TCMB kuru faturada yazılır [İ: [İdeasoft](https://www.ideasoft.com.tr/istisna-faturasi/), [Paraşüt](https://www.parasut.com/blog/e-fatura-ve-e-arsiv-de-dovizli-fatura-nasil-kesilir)]. Apple'a hangi Apple tüzel kişisine fatura kesileceği (Apple Distribution International Ltd., Hollyhill Industrial Estate, Cork) [İ, [remotevergi](https://remotevergi.com/app-store-play-store-vergi/)]. Apple kendi yardım sayfasında geliştiricilerden fatura beklediğine dair genel bir kural yazmıyor (yalnızca İrlandalı KDV'liler için) [R, [Apple invoices](https://developer.apple.com/help/app-store-connect/manage-tax-information/manage-invoices-and-other-tax-documents)]. **Apple'a fatura kesme zorunluluğu ve içeriği [TEYİT]** (Mükerrer 20/B yolunda fatura gerekmez).
- VUK 231/5: fatura teslimden itibaren azami 7 gün içinde düzenlenir; geç düzenlenen fatura hiç düzenlenmemiş sayılır [İ]. Aylık Apple ödeme raporu yayınlanma tarihi ile fatura tarihi uyumu için SMMM'ye sor.
- e-Arşiv zorunluluğu: 2026'dan itibaren tutar sınırı olmadan e-Arşiv'e geçildiğini yazan kaynaklar var, e-Fatura sınırı 3 milyon TL brüt satış (kaynaklar çelişkili; tebliğ numaraları karışık) [İ, [Paraşüt](https://www.parasut.com/blog/e-fatura-ve-e-arsiv-zorunlulugu)] [TEYİT].
- Türkiye'deki son kullanıcı satışları: Apple KDV'yi (%20) toplayıp kendisi beyan eder [İ, remotevergi]. **DST:** 1.1.2026'dan itibaren %7,5'ten **%5**'e düştü; Apple bunu 30.01.2026'da geliştirici proceeds'larına yansıttı [İ, [CNBC-e](https://www.cnbce.com/teknoloji/apple-app-store-gelirlerinde-turkiye-icin-vergi-guncellemesine-gitti-h24067)].
- Yurt dışı SaaS/API ödemeleri (Figma, API'ler): KDV sorumlu sıfatıyla beyanı ve gider belgeleme için SMMM'ye sor [T, doğrulanmadı].

### 2.6 Stopaj ve döviz

- 20/B: banka %15 nihai stopaj (yukarıda).
- Kâr payı stopajı **%15** (9286 sayılı Karar, 22.12.2024) [İ, [KPMG](https://kpmgvergi.com/yayinlar/mali-bultenler/vergi/9286-sayili-cumhurbaskani-karari-ile-kar-payi-stopaj-orani-15-e-cikarildi/2893)]. 2026'da değiştiğine dair kaynak bulamadım.
- Serbest meslek erbabına ödeme (ör. serbest tasarımcı): %20 stopaj genel kuraldır [T, doğrulanmadı].
- Hizmet ihracatı bedelinin TL'ye çevrilmesi zorunlu değil (mal ihracatındaki %35 kuralı hizmet ihracatına uygulanmıyor) [İ, İSMMMO/[TCMB Q&A](https://immib.org.tr/files/kio/TCMB%20İhracat%20Bedelleri%20Uygulaması%20Soru-Cevap.pdf)]. Ancak kazanç indiriminde bedelin Türkiye'ye getirilmesi gerekli. Parayı yurt dışı ödeme kuruluşlarında tutmak indirim hakkını riske sokabilir [İ].
- TCMB'nin yurt dışı kaynaklı döviz dönüşüm desteği (%3) 31.01.2027'ye kadar sürüyor [İ].

### 2.7 Bağ-Kur (4/b)

- 2026 prime esas kazanç alt sınırı: brüt asgari ücret 33.030 TL. Asgari aylık prim yaklaşık **11.400–11.800 TL** (kaynaklar %34,5 mi %35,75 mi diye çelişiyor; Habertürk 11.791,71 diyor). Zamanında ödeyenlere 5 puan indirim: ≈ 10.150 TL [İ, [Habertürk](https://www.haberturk.com/2026-yilinda-genc-girisimci-tesviki-ne-kadar-3856269-ekonomi), arama özetleri]. SGK'dan teyit et.
- 20/B belgesi vergiyi kaldırır, mükellefiyet 4/b sigortalılığını kendiliğinden ortadan kaldırmaz. Çoğu kaynak mükellefiyet başlayınca 4/b'nin doğduğunu söylüyor. GİB broşürü SGK'yı hiç anmıyor [İ] **[TEYİT: SGK/SMMM]**. Zaten SSK'lı çalışıyorsan özel kurallar olabilir.

### 2.8 Şirket kuruluşu ve muhasebe maliyetleri

- **Min. sermaye:** Ltd. 50.000 TL, A.Ş. 250.000 TL (7511 sayılı Kanun, 29.05.2024). 2024 öncesi kurulanların uyum süresi **31.12.2026**; uyum yoksa infisah [İ, [Cott](https://cottgroup.com/tr/mevzuat/item/asgari-sermaye-uyum-surecinde-son-tarih-31-aralik-2026)].
- **Kuruluş (SMMM+noter+tescil) tahmini [İ, [Faturaport](https://www.faturaport.com/blog/crm/2026-sirket-kurma-maliyetleri-nelerdir-sahis-limited-anonim-karsilastirmasi)]:** şahıs 8.000–13.500 TL; Ltd. 24.000–32.000 TL (mali mühür 3 yıllık 1.740 TL dahil); A.Ş. 33.000–42.000 TL.
- **SMMM aylık ücret:** 2026 asgari tarife RG 17.12.2025 (33110), 1.1.2026'dan geçerli, KDV dahil; ilk kez gerçek usule geçenlere ilk 2 yıl %50 indirim. Bir tarife özetine göre şahıs işletmesi (işletme hesabı, hizmet, çalışansız) 1.145 TL, bilanço esaslı şahıs 3.091 TL, Ltd. 3.606 TL, serbest meslek 4.492 TL'den başlıyor; gelir vergisi beyannamesi 3.864 TL [İ, [Faturaport](https://faturaport.com/blog/on-muhasebe/2026-yilinda-sm-smmm-ymm-asgari-ucret-tarifeleri-kapsamli-rehber)]. Piyasa rehberleri şahıs için **2.000–4.000 TL/ay**, Ltd. için **3.000–6.000 TL/ay** diyor [İ]. Başlangıç için güvenli planlama aralığı: şahıs 2.000–4.000 TL, Ltd. 3.000–8.000 TL [T].

### 2.9 Teknokent / Teknopark

[İ, [Faturaport 2026](https://faturaport.com/blog/e-donusum/teknoloji-gelistirme-bolgesi-teknopark-tesvikleri-2026), [KPMG](https://kpmgvergi.com/blog/teknokentlerde-kazanc-ve-kdv-istisnasinda-bildirim-zorunlulugu-ile-vergi-yargisinin-konuya-bakisi/1388), arama özeti]
- 4691 sayılı Kanun geçici md. 2: bölgedeki yazılım/tasarım/Ar-Ge kazancı **31.12.2028**'e kadar gelir ve kurumlar vergisinden istisna. Bölge dışı faaliyet kazancı kapsam dışı; kur farkı gelirleri istisna dışı; ayrı kayıt şart; bildirim yükümlülüğü var.
- Bölgede üretilen yazılım KDV'den istisna. Ar-Ge/tasarım personelinin ücretinde gelir vergisi stopaj teşviki; SGK işveren payının %50'sini Hazine karşılar (yalnızca 4/a; ortak/4/b dışı).
- Hizmet ihracatı tartışmasındaki "münhasıran yurt dışı" şartı Teknokent istisnasında yok (kaynaklardan birine göre yurt içi satışlar da kapsanıyor) [İ, TEYİT].
- Kanun metnine göre Teknokent istisnası asgari KV matrahından düşülebiliyor, ama bir haber bunun tersini söylüyor [İ] [TEYİT].
- Kira bedeli ve başvuru koşulları için 2026 rakamı bulamadım. Teknokent yönetimine sor. Fiziksel faaliyet, PDKS ve aylık raporlama gerekiyor.

### 2.10 2025–2026 değişiklik takvimi

| Tarih | Değişiklik | Güven |
|---|---|---|
| 29.05.2024 | Ltd. asgari sermaye 50.000 TL (uyum 31.12.2026) | İ |
| Ağustos 2024 | Asgari KV %10 (KVK 32/C, 7524) | İ |
| 22.12.2024 | Kâr payı stopajı %10 → %15 | İ |
| Dec 2024/Feb 2025 | GİB 20/B broşürü; limit 2025: 4,3 M TL | R |
| 04.09.2025 / 25.12.2025 | VERBİS kararları (bkz. §3) | İ |
| 21.10.2025 | Danıştay 3. D. 2025/4071 (KDV, hizmet ihracı) | İ |
| 31.12.2025 | Yeniden değerleme; 2026 tarifesi (yeniden değerleme oranı %25,49); 20/B limiti 5,3 M TL; genç girişimci 400 bin TL | İ |
| 1.1.2026 | DST %7,5 → %5; genç girişimci Bağ-Kur desteği kalktı | İ |
| 30.01.2026 | GİB özelgesi (App Store/Google Play); Apple, DST güncellemesini yansıttı | İ |
| 30.04.2026 | 11257 sayılı Karar: hizmet ihracatı indirimi %100 | İ |
| 31.12.2026 | Ltd. sermaye uyum son günü | İ |
| 31.12.2028 | Teknokent kazanç istisnası bitişi (yasa metni) | İ |

---

## 3. KVKK, GDPR, Apple gizlilik gereklilikleri

### 3.1 KVKK (Türkiye)

- **Aydınlatma (KVKK md. 10, 2018 Tebliği, RG 10.03.2018, sayı 30356):** Aydınlatma, açık rıza dışındaki işleme şartlarında da gereklidir. Aydınlatmanın yapıldığını ispat yükü veri sorumlusunda. Açık rızaya dayalıysa aydınlatma ve açık rıza ayrı yapılır [İ, [Alomaliye](https://www.alomaliye.com/2018/03/10/aydinlatma-yukumlulugu/)].
- **Kurul İlke Kararı 18.02.2026, 2026/347:** Açık rıza metni ve aydınlatma metni ayrı düzenlenmeli; açık rızada her beyan ayrı; "okudum ve kabul ediyorum" yerine "okudum ve anladım" beyanı; ispat yükü veri sorumlusunda [R/İ: [Lexpera kaydı](https://www.lexpera.com.tr/mevzuat/kurul-kararlari/kisisel-verileri-koruma-kurulunun-18-02-2026-tarihli-ve-2026-347-sayili-karari-2026-347-1), [Alomaliye özeti](https://www.alomaliye.com/2026/03/24/kvkkdan-yeni-ilke-karari-acik-riza-metni-ile-aydinlatma-metni-artik-ayri-duzenlenmeli/)]. Metnin tamamını ben okumadım; özet kaynaklara dayanıyor.
- **Analitik için açık rıza:** KVKK'nın çerez rehberi, analitik/reklam/kişiselleştirme çerezleri için açık rızayı öne çıkarıyor. Rehber web/çerez odaklı; yerel mobil SDK'lar için doğrudan karşılığı yok, ilkeleri kıyasen uygulamak gerekir [İ, [Erdem & Erdem](https://www.erdem-erdem.av.tr/bilgi-bankasi/kisisel-verileri-koruma-kurumu-cerez-uygulamalari-hakkinda-rehberi-guncelledi)] [TEYİT]. Pratik tasarım: analitik SDK'larını ayrı onay sonrası başlat, onayı uygulama kullanımına şart koşma (Apple 5.1.1(ii) da paid işlevin veri iznine bağlanmasını yasaklıyor), onay kaydını (tarih, sürüm) tut.
- **Yurt dışı aktarım (md. 9, 7499 sayılı Kanun, yürürlük 1.6.2024):** Kademeli sistem: yeterlilik kararı, uygun güvenceler (standart sözleşme, bağlayıcı şirket kuralları, taahhütname vb.), istisnai haller. Standart sözleşme imzadan itibaren **5 iş günü** içinde KVKK'ya bildirilir (Standart Sözleşme Bildirim Modülü; Kurul Kararı 17.10.2024, 2024/1793) [R, [KVKK duyurusu 25.10.2024](https://www.kvkk.gov.tr/Icerik/8043/Standart-Sozlesme-Bildirim-Modulu-Hakkinda-Kamuoyu-Duyurusu)]. Yönetmelik RG 10.07.2024 (32598), Rehber 02.01.2025 [İ]. Yeterlilik kararı verilmiş ülke listesinin yayınlanmadığı yazılıyor [İ].
- **Pratik sıkıntı [TEYİT]:** RevenueCat, Firebase/Google, PostHog, Supabase gibi yurt dışı hizmetler sürekli aktarım demektir. Açık rıza dayanağı genelde "tekrarlanmayan/istisnai" aktarım için; sürekli analitikte dayanak olarak sorunlu. Vendor'ın Türk standart sözleşmesini imzalaması/uyum belgeleri ve minimum veri (pseudonim kimlik) stratejisini KVKK avukatıyla belirle. Google'a 2023'te bir taahhütname izni verildi ([haber, 01.09.2023](https://www.benguturk.com/gundem/kvkk-googlein-yurt-disina-kisisel-veri-aktarimi-yapmasina-izin-verdi-120071h)); kapsamı üçüncü taraf geliştiriciyi içerdiği belirsiz, buna güvenme.
- **VERBİS (Kurul Kararları 04.09.2025 no. 2025/1572, RG 01.10.2025; 25.12.2025 no. 2025/2393):** Özel nitelikli veri işlemeyenler için istisna: yıllık çalışan < 50 **ve** yıllık mali bilanço < 100 milyon TL. Ana faaliyeti özel nitelikli veri işlemek olanlar için mikro istisna: < 10 çalışan ve < 10 milyon TL. Bilanço esasına göre defter tutmayanlara yalnızca çalışan sayısı kriteri uygulanır [İ, [Cott](https://cottgroup.com/tr/blog/kvkk-gdpr/item/verbise-kayit-yukumlulugu-istisnasina-iliskin-uygulama-esaslari-netlestirildi)]. Kelime öğrenme uygulaması için büyük olasılıkla muaf ama **[TEYİT]**.
- **2026 idari para cezaları (+%25,49, RG 27.11.2025 no. 33090):** aydınlatma 85.437–1.709.200 TL; veri güvenliği 256.357–17.092.242 TL; VERBİS 341.809–17.092.242 TL; standart sözleşme bildirimi 90.308–1.806.377 TL (kaynaklar arasında 200 TL'lik fark var) [İ, [Cott](https://cottgroup.com/tr/mevzuat/item/yeniden-degerleme-oranina-gore-2026-yili-kvkk-idari-para-cezalari)].
- **İYS (6563):** Pazarlama amaçlı e-posta/SMS/push gönderiyorsan İYS kaydı ve izin yönetimi gerekebilir; push'un kapsamı belirsiz [İ] [TEYİT]. **ETBİS:** Kendi mobil uygulamanda tüketiciye doğrudan satış yapan hizmet sağlayıcılar kayıt olmak zorunda; Apple üzerinden satışın nasıl değerlendirileceği belirsiz [İ, [Ticaret Bakanlığı](https://ticaret.gov.tr/duyurular/elektronik-ticaret-bilgi-sistemine-etbis-kayit-ve-bildirim-esaslari)] [TEYİT].
- **Tüketici mevzuatı (mesafeli sözleşme, cayma, abonelik ön bilgilendirme):** Bu raporda araştırmadım [TEYİT].

### 3.2 GDPR temelleri (AB kullanıcıları)

[Büyük kısmı genel bilgi, avukat teyidi şart]
- Hedef AB kullanıcısı varsa GDPR m.3(2) kapsamı muhtemel. Sürekli analitik toplayan abonelik uygulaması için GDPR m.27 AB temsilcisi yükümlülüğü büyük olasılıkla doğar; "ara sıra işleme" istisnası dar [İ, [GDPRLocal](https://gdprlocal.com/gdpr-article-27-gdpr-exemptions/)]. Temsilci hizmet fiyatları yılda birkaç yüz ila birkaç bin Euro (örn. GDPRLocal aylık £99–350, Prighter yıllık listede €420–4.752 arası) [İ] [TEYİT].
- Analitik/izleme için onay (ePrivacy), işleyicilerle DPA, haklar (erişim/silme), ihlalde 72 saat bildirimi, çocuklar için yaş eşiği: avukat kontrol listesi olarak kullan.
- Türkiye için AB yeterlilik kararı olmadığı bilgisi genel bilgi, doğrulanmadı [T]. Backend AB bölgesinde barınıyorsa bile, Türk geliştirici GDPR kapsamında ayrı değerlendirilmeli.

### 3.3 Apple gizlilik ve abonelik gereklilikleri

[R, [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)]
- **5.1.1(i):** Gizlilik politikası URL'si App Store Connect'te **ve** uygulama içinde kolay erişilebilir olmalı; toplanan veri, kullanım, üçüncü taraflar (analitik SDK'lar dahil), saklama ve silme/rıza geri çekme anlatılmalı. **5.1.1(ii):** Kullanım verisi toplamadan önce izin al, ücretli işlev bu izne bağlı olamaz. **5.1.1(v):** Hesap açtırıyorsan uygulama içi hesap silme zorunlu. **5.1.2(i):** Kişisel veriyi üçüncü taraf AI dahil paylaşmadan önce açık izin; izleme için ATT.
- **App Privacy ("Nutrition") Labels:** Zorunlu, güncel tutulmalı. **Üçüncü taraf SDK'ların** (analitik, RevenueCat vb.) topladığı veriyi de beyan edersin; Apple RevenueCat'i adıyla anmıyor, SDK'nın veri uygulamalarına bak. Privacy Policy URL zorunlu.
- **3.1.2 Abonelik:** Abonelik dönemi en az 7 gün; tüm cihazlarda çalışmalı; fiyat/süre/yenileme net gösterilmeli; restore mekanizması (3.1.1). Forum bildirimlerine göre ret nedenleri: paywall'da başlık/süre/fiyat ve **gizlilik politikası + Kullanım Şartları (EULA) bağlantısı** eksikliği; EULA bağlantısı App Description veya EULA alanında olmalı; yenilenen bedelin en belirgin öğe olması [İ, [thread 794124](https://developer.apple.com/forums/thread/794124), [thread 807082](https://developer.apple.com/forums/thread/807082)].
- **Kids Category (1.3):** Üçüncü taraf analitik/reklam yasak; kelime uygulaması için çocuk kategorisi seçme.
- Apple'ın Standart EULA'sını kullanabilirsin (App Store Connect'te açıklamaya bağlantı eklenir) [İ, forum].

### 3.4 Gizlilik politikası ve EULA üreticileri

Fiyatlar [İ, [Capterra/diğer](https://www.capterra.com/p/156938/iubenda/pricing/)], teyit et:
- **Termageddon:** ≈ 119 USD/yıl (bir lisans = 1 site veya uygulama) [İ]. Türkçe politika yok.
- **Termly:** ücretsiz plan sınırlı; ücretli ≈ 10–20 USD/ay (site başına) [İ].
- **iubenda:** Essentials €4,99–5,99/ay, Advanced €19,99–24,99/ay; mobil uygulamada "embed" yerine doğrudan bağlantı kullanılıyor [İ].
- **KVKK aydınlatma/açık rıza ve m.9 aktarım belgeleri:** Türk hukuku odaklı olduğu için bir Türk avukata yazdır (tahmini 8.000–20.000 TL, kaynak yok [T]).

---

## 4. Marka (TÜRKPATENT, EUIPO, USPTO)

- **Sınıflar:** 9 (indirilebilir yazılım/mobil uygulama), 41 (eğitim, dil öğretimi), gerekirse 42 (SaaS) [T, genel Nice sınıflaması].
- **TÜRKPATENT ücretleri (2026/1 Tebliği, RG 31.12.2025 sayı 33124 5. mükerrer):** Ücretler KDV ve harç hariç. e-Devlet başvurusunda marka tescil başvuru ücreti **2.027,17 TL** (Eleman.net/haberler). Başka bir rehber tek sınıf için 2.820 TL, 3. ve sonraki sınıf 3.150 TL, tescil harcı 7.010 TL yazıyor; iki kaynak çelişiyor, resmî cetveli (Tebliğ'in 1–6 sayılı cetvelleri) kontrol et [İ, [Eleman.net](https://www.eleman.net/is-rehberi/maaslar-ve-ucretler/patent-ucretleri-2026-ne-kadar-h18087), [Kobitime](https://kobitime.com/marka-tescili-nasil-yapilir-2026/)]. Resmî tarife PDF'ini okuyamadım (yazı tipi kodlaması). Vekil (marka vekili) ücreti için kaynak bulamadım [T: tek marka, iki sınıf için 5.000–15.000 TL].
- **Süre:** Şekli inceleme, mutlak ret incelemesi, bültende yayın ve **2 aylık itiraz süresi**, tescil kararı ve tescil harcı. İtirazsız ortalama **6–12 ay** (kaynaklara göre 5–7 ay ila 10–18 ay); itiraz olursa 1 yıldan uzun [İ, [FFK Hukuk](https://www.ffkpartnerhukuk.com.tr/marka-tescili-kac-gunde-alinir-2026-guncel-rehber-marka-basvuru-ve-tescil-suresi/)]. Koruma 10 yıl, yenilenebilir.
- **Çakışma taraması:** Başvurudan önce TÜRKPATENT marka sorgusu, EUIPO TMview, USPTO TESS/arama, App Store'da ad (benzersiz olmak zorunda), alan adı ve sosyal medya kullanıcı adı. Benzer marka taraması yapmamak aylar süren bir sürecin sonunda ret riskidir [İ].
- **EUIPO:** İnternet başvurusunda 1. sınıf **850 €**, 2. sınıf **50 €**, 3. ve sonrası **150 €** (üç sınıf = 1.050 €) [İ, [firma.de örneği](https://www.firma.de/en/eu-trademark-registration/), EUIPO hesaplayıcısıyla teyit].
- **USPTO:** 18.01.2025'ten itibaren sınıf başına 350 USD taban; ID Manual dışı ifade +200 USD/sınıf, eksik bilgi +100 USD/sınıf. Yabancı yerleşikler için **ABD'de lisanslı avukat** zorunlu (2019'dan beri); ilk başvuruyu avukatsız yapabilirsin ama ofis işlemlerine avukatsız yanıt veremezsin [İ, [Mondaq](https://mondaq.com/unitedstates/trademark/1557134/uspto-trademark-fees-changes-for-2025), [AIPLA](https://www.aipla.org/detail/news/2019/07/03/uspto-rule-requires-us-attorney-for-foreign-trademark-applicants)].
- Türkiye'de başvuru sonrası Paris öncelik hakkı ve Madrid Protokolü uzantısı seçenekleri var [T, genel bilgi, doğrulanmadı]; uluslararası planı marka vekiliyle yap.

---

## 5. İçerik ve fikri mülkiyet

**Telifli sözlükler/kelime listeleri (kısa):**
- Oxford/Cambridge/Merriam-Webster gibi sözlüklerin tanımları ve örnek cümleleri telifli. Oxford 3000/5000 listelerinin ticari kullanımı için OUP lisanslama yapıyor (OUP–uygulama geliştirici anlaşması örnekleri var); lisans şartı bulamadım. Ticari uygulamada kullanmadan önce OUP ile yaz [İ].
- **NGSL:** Yan listeleri (Graded Reader, Spoken) CC BY-SA 4.0. Çekirdek NGSL 1.2 lisansı sayfada net değildi; yazara sor ya da CC BY-SA şartlarına uy [İ, [NGSL](https://www.newgeneralservicelist.com/new-general-service-list)].
- **Wiktionary/kaikki.org verisi:** CC BY-SA (ve GFDL). Ticari kullanım serbest ama atıf ve türev veri setinin aynı lisansla yayınlanması gerekir; kapalı kaynak üründe çatışabilir [İ].
- **WordNet:** Princeton lisansı ticari kullanıma açık, paylaşım koşulu yok [İ, [Princeton](https://wordnet.princeton.edu/node/10)].
- Sözlük sitelerinden (TDK, Tureng vb.) kazıma yapma; kullanım şartları ve telif/veritabanı riskleri var [T].
- **Öneri [T]:** Başlık kelime listesini açık lisanslı kaynaktan al; tanım, örnek cümle ve çeviriyi kendi LLM pipeline'ınla üret; kaynak/lisans kaydı tut; LLM'e belirli bir sözlüğü kopyalatma.

**AI üretimi içerik:**
- ABD Telif Bürosu (29.01.2025, Part 2): tamamen AI üretimi çıktı telif korumasında değil; prompt tek başına yeterli yazarlık sayılmıyor. İnsan seçimi/düzenlemesi/derlemesi korunabilir [İ, [Copyright Alliance özeti](https://copyrightalliance.org/ai-report-part-2-copyrightability/)]. Türkiye'de FSEK'in gerçek kişi eser sahibi aradığı genel bilgi, doğrulanmadı [T]. Sonuç: AI içeriğini rakipler kopyalayabilir; insan editörlüğü ekle.
- API sağlayıcınızın çıktı mülkiyeti ve kullanım şartlarını oku [T].
- AB AI Act m.50: sohbet botu bildirimi ve içerik işaretleme yükümlülükleri 02.08.2026'da yürürlüğe girdi; Digital Omnibus bu maddeyi ertelememiş görünüyor, 50(2) için 02.12.2026'ya kadar geçiş süresi iddia eden kaynaklar var; metin sadece "kamu yararı konularında halkı bilgilendirmek için yayınlanan" metni kapsıyor [İ, [Dudkowiak](https://www.dudkowiak.com/blog/ai-act-article-50-ai-content-labeling-and-code-of-practice-from-august-2-2026/)] [TEYİT]. Uygulama içinde AI sohbet özelliği yoksa etkisi düşük.
- Apple 5.1.2(i): kişisel veriyi üçüncü taraf AI ile paylaşmadan önce açık izin [R].

---

## 6. Bütçe

Varsayımlar: 1 USD = 49 TL. Rakamlar "tek seferlik" (lansmana kadar) ve "aylık yürüyen" olarak ayrıldı. Vergiler (20/B %15 vb.) dahil değil. [T] = tahmin, teklif topla. Tasarım ve UGC Türkiye fiyatlarında güvenilir bir fiyat tablosu **bulamadım**.

### 6.1 Tek seferlik

| Kalem | Düşük | Orta | Yüksek | Not |
|---|---|---|---|---|
| Apple Developer (yıllık) | $99 (4.850 TL) | $99 | $99 | TR'de bildirilen fiyat 1.029 TL (Aralık 2025); ödeme ekranında doğrula [İ] |
| Kuruluş | $165 (8.000 TL) şahıs | $570 (28.000 TL) Ltd. | $650 (32.000 TL) Ltd. | Faturaport aralıkları; Teknokent başvuru/kira ayrı [İ] |
| Cihaz | $100 (4.900 TL) mevcut Mac + bulut Mac | $1.440 (70.500 TL) Mac mini M4 16/512 (50.499 TL, 13.05.2026 Apple TR) + ikinci el iPhone ≈ 20.000 TL [T] | $2.700 (132.000 TL) MacBook Air 15" M4 (lansman 59.999 TL) + test cihazları [T] | Xcode Cloud: üyelikle 25 saat/ay ücretsiz [R] |
| Tasarım | $100 (4.900 TL) ikon+şablon, Figma Starter | $500 (24.500 TL) freelancer [T] | $2.500 (122.500 TL) stüdyo [T] | Figma Pro Full seat ≈ $16/ay [İ] |
| Hukuki metinler | $119 (5.800 TL) Termageddon | $364 (17.800 TL) Termageddon + avukat gözden geçirme 12.000 TL [T] | $1.500 (73.500 TL) hukuk bürosu paketi [T] | Apple Standart EULA ücretsiz |
| Marka | $205 (10.000 TL) TR kendi başvuru [T] | $410 (20.000 TL) TR vekilli [T] | $2.800 (137.000 TL) TR + EUIPO (≈ €900) + USPTO (2 sınıf ≈ $700+) + vekiller [T] | Resmî harç tablosunu kontrol et |
| İçerik üretimi (LLM+TTS) | $20 (980 TL) | $150 (7.350 TL) | $600 (29.400 TL) | Aşağıda hesap |
| Domain, e-posta, site | $12 (590 TL) | $100 (4.900 TL) | $150 (7.350 TL) | Kurumsal Apple kaydı için domain e-postası şart [R] |
| Pazarlama testi | $400 (19.600 TL) | $1.500 (73.500 TL) | $8.000 (392.000 TL) | Aşağıda |
| GDPR AB temsilcisi | $0 | $0 | $1.100 (54.000 TL) | Risk-bazlı karar [TEYİT] |
| **Ara toplam** | **$1.220 (≈ 59.800 TL)** | **$5.133 (≈ 251.500 TL)** | **$20.099 (≈ 984.900 TL)** | |
| Kontenjan | %15 = $183 | %15 = $770 | %20 = $4.020 | |
| **Toplam** | **≈ $1.400 (≈ 68.700 TL)** | **≈ $5.900 (≈ 289.300 TL)** | **≈ $24.100 (≈ 1.181.900 TL)** | Yüksek senaryo ek personel ve Teknokent kirasını içermiyor |

Ltd. kurulacaksa 50.000 TL sermaye taahhüdü ayrı kalem (Faturaport kaynağına göre blokaj yok, taahhüt yeterli [İ]).

### 6.2 Aylık yürüyen (lansman sonrası, vergi hariç)

| Kalem | Düşük | Orta | Yüksek |
|---|---|---|---|
| Bağ-Kur 4/b (geçerliyse) | ≈ $235 (11.600 TL) | ≈ $235 | ≈ $235 (+ ortak başına) |
| Muhasebe | $30 (1.500 TL) [T] | ≈ $92 (4.500 TL) | ≈ $163 (8.000 TL) |
| Backend/altyapı | $0 (Supabase Free / Firebase Spark) | $25 (Supabase Pro) [İ] | ≈ $125 |
| Araçlar (Workspace, Figma) | $0 | ≈ $23 | ≈ $100 |
| LLM/TTS bakım | $5 | $20 | $100 |
| AB temsilcisi | $0 | $0 | ≈ $90 |
| Pazarlama | $100 | $500 (Ads $300 + UGC $200) | $3.000 |
| **Toplam** | **≈ $370 (18.100 TL)** Bağ-Kur'lu; ≈ $135 Bağ-Kur'suz | **≈ $895 (43.900 TL)** | **≈ $3.800 (186.900 TL)** + isteğe bağlı yarı zamanlı yüklenici $1.000–1.500 |

### 6.3 Birim fiyat kaynakları

- **RevenueCat:** Pro plan, aylık izlenen gelir (MTR) 2.500 USD'ye kadar ücretsiz; üstünde MTR'nin %1'i (tüm tutar mı fazlası mı diye sayfadan teyit et) [R, [RevenueCat fiyat](https://www.revenuecat.com/pricing/)]. **Superwall:** abonelik altyapısı ücretsiz; paywall ürünü paywall'dan gelen gelirin ilk 10.000 USD/ayına kadar ücretsiz, sonrasında %1 [R, [Superwall](https://superwall.com/pricing)].
- **Analitik:** PostHog ve Mixpanel ücretsiz katmanda aylık 1M olay; TelemetryDeck ücretsiz katman aylık 100.000 sinyal, limit dolunca veri kabul etmez; Temmuz 2026'da fiyatlandırma güncellemesi var [İ, [TelemetryDeck](https://telemetrydeck.com/blog/pricing-update-2026/)]. Firebase Analytics ücretsiz [T, genel bilgi].
- **Backend:** Supabase Free/Pro 25 USD/ay; Cloudflare Workers Paid 5 USD/ay; Firebase Blaze kullanıma göre, harcama tavanı yok [İ].
- **LLM:** Anthropic fiyat sayfası [R, [Pricing](https://platform.claude.com/docs/en/about-claude/pricing)]: Haiku 5.5 giriş $0,10 / çıkış $0,50 (MTok, 100k token altı prompt); Sonnet 5.5 giriş $2 / çıkış $10; Batch API %50 indirim. **Örnek hesap [T]:** 20.000 kelime × (700 çıkış + 300 giriş token) = 14M çıkış + 6M giriş token. Haiku 5.5 ≈ $7,60, Sonnet 5.5 ≈ $152; Batch ile ≈ $3,80 / ≈ $76. Hata düzeltme/yeniden üretim için 3 katı bütçele.
- **TTS:** Google Cloud TTS: Standard/WaveNet $4/M karakter, Neural2 $16/M, Chirp 3 HD $30/M; ücretsiz allowance var (resmî sayfada 0–4M karakter, yenileme periyodu teyit edilmeli) [İ, [Google](https://cloud.google.com/text-to-speech/pricing)]. 20.000 kelime × ~120 karakter = 2,4M karakter → Neural2 ≈ $38, Chirp 3 HD ≈ $72. OpenAI gpt-4o-mini-tts ≈ $0,015/dk (tahmini, OpenAI forumu) [İ]. Cihazdaki AVSpeechSynthesizer ücretsiz (genel bilgi [T]).
- **Apple Ads (Türkiye açıldı, Ekim 2024):** TR'de arama sonuçları ortalama CPT **$0,85** (2025 verisi), arama sonucu reklamlarında dönüşüm oranı %65,82 (küresel), ortalama CPA $2,51 [İ, [MobileAction 2026 raporu](https://www.mobileaction.co/report/apple-ads-2026-benchmark-report/executive-summary/)]. Çıkarım: TR'de kurulum başına ≈ $1,3, global ortalama $2,5 civarı [T]. $400 bütçeyle düşük senaryoda ≈ 150–300 kurulum.
- **UGC:** Türkiye'de Bionluk gibi platformlarda 500–750 TL/video örnekleri (Kasım 2025, tek tek ilanlar) [İ, [Lilys](https://lilys.ai/notes/tr/creator-income-models-20251101/video-earn-money-ugc-guide)]; Avrupa'da video başı 150–450 € ve reklam kullanım hakkı için +%30–200 [İ, [Influentials](https://www.influentials.com/blog/how-much-does-ugc-cost-and-what-influences-the-price-a-guide-for-brands)]. Orta/yüksek senaryolarda TR ucuz creator + az sayıda yüksek kaliteli creator karışımı varsay [T].
- **Gelir tarafı örneği [T]:** Aylık 4,99 USD abonelik × 100 abone = 499 USD brüt. Apple SBP %15 sonrası ≈ 424 USD proceeds; 20/B %15 stopajı sonrası ≈ 360 USD. Bağ-Kur'lu sabit giderler (≈ $370/ay) yaklaşık 100 aboneyle kapanır.

---

## 7. Sıfırdan App Store'a: hafta hafta kontrol listesi

Hedef: 10–12 hafta. Apple kimlik/ödeme sorunları ve marka başvurusu paralel yürüsün.

**Hafta 0 (harcamadan önce)**
- SMMM ile 1 saatlik görüşme: §8 sorularını sor. Bireysel/kurumsal ve rejim kararını ver.
- Uygulama adı + alan adı + sosyal medya + marka çakışma taraması (TÜRKPATENT, EUIPO TMview, USPTO, App Store).
- Hedef pazar kararı: Türkiye mağazası açık mı? (Karma kullanım "münhasıran yurt dışı" şartını bozuyor; §2.3.)

**Hafta 1**
- Şahıs: vergi dairesi mükellefiyet açılışı (e-Devlet/Dijital Vergi Dairesi), 20/B istisna belgesi (aynı gün verilen örnek var, GİB örnek), USD hesap açılışı ve IBAN'ın vergi dairesine **1 ay içinde** bildirilmesi. Ltd.: MERSİS + ticaret sicili (kuruluş 1–2 hafta [T]), mali mühür/e-imza.
- TÜRKPATENT başvurusu (e-Devlet; sınıf 9, 41, gerekirse 42).
- Domain + yer tutucu olmayan, işlevsel web sitesi (kurumsal Apple kaydı için) + domain e-postası.
- Kurumsal ise: D-U-N-S başvurusu (≤ 5 iş günü + Apple'a yansıması ≤ 2 iş günü).

**Hafta 1–2**
- Apple Developer kaydı. Kimlik/isim yazımını belgelerle birebir yap. Ödeme reddedilirse Developer Support'a yaz, Developer app'ten tekrar dene; **2–4 hafta tampon** (forumlarda 2+ aylık vakalar var).
- Apple Distribution International ile fatura akışı, e-Arşiv portalı açılışı (B/C rotası için) [TEYİT].

**Hafta 2–3**
- App Store Connect > Business: Paid Apps Agreement (Account Holder), banka (USD, İngilizce karakter, hesap sahibi adı birebir), **W-8BEN/-E**, DSA trader beyanı, Small Business Program başvurusu.
- Gizlilik: aydınlatma metni, ayrı açık rıza metni (analitik), gizlilik politikası, EULA/Kullanım Şartları, çerez/SDK envanteri, KVKK m.9 aktarım dayanakları, VERBİS muafiyet kontrolü, GDPR temsilci kararı.

**Hafta 3–8 (paralel geliştirme)**
- StoreKit 2/RevenueCat entegrasyonu, paywall, restore, abonelik ürünleri; analitik rıza akışı; widget; hesap açılıyorsa silme; privacy manifest [T, genel bilgi].
- İçerik pipeline'ı: kelime listesi lisans kaydı, LLM üretimi + insan QA, TTS.
- TestFlight (iç/dış), Beta App Review.

**Hafta 8–9**
- App Store listesi: ekran görüntüleri, ikon, abonelik metinleri (3.1.2), App Privacy etiketleri, EULA/Privacy linkleri hem uygulamada hem metadata'da.
- İncelemeye gönder. İnceleme süresi ve ret/yeniden gönderme için 1–2 tur planla [T].

**Hafta 9–10: Yayın**
- Aşamalı yayın. İlk mali ay kapanır; finansal raporlar sonraki mali ayın ilk Cuması hazır.

**Hafta 10–16: Para akışı**
- İlk Apple ödemesi: mali ay sonundan sonra **45 gün içinde**. İlk nakit lansmandan yaklaşık 6–10 hafta sonra.
- 20/B: banka %15 keser, beyan yok (şartlar korunursa). Gerçek usul/Ltd.: aylık e-Arşiv, KDV, muhtasar, yıllık beyan; hizmet ihracı bedelini yıllık beyan tarihine kadar Türkiye'ye getir; yıllık gelir vergisi beyannamesi Mart'ta.

**Sürekli:** hasılatı yıllık 5,3 M TL limitine karşı izle; marka itiraz süresini takip et; KVKK aydınlatma güncellemeleri; Apple SBP associated account bildirimleri.

---

## 8. Mali müşavir / avukata sorulacaklar (kısa liste)

1. Şahıs + 20/B ile Bağ-Kur (4/b) zorunlu mu; zaten SSK'lıysam ne olur?
2. 20/B hasılat tanımına Apple'ın proceeds'u (komisyon sonrası) mi girer, ödeme tutarı mı?
3. GİB'in 30.01.2026 özelgesi ve Danıştay 2025/4071 ışığında GVK 89/13 %100 indirimini App Store geliri için kullanmak güvenli mi? Özelge talebi yapılmalı mı?
4. Apple'a fatura kesilecek mi; brüt mü net mi; tarih (rapor yayını mı ödeme mi); KDV 302 kodu; "yurt dışı müşteri" kim (Apple Distribution International mı, son kullanıcılar mı)?
5. Ltd.'de asgari KV (32/C), 3 yıllık yeni kuruluş muafiyeti ve 5 puan indirimin etkileşimi nedir?
6. Genç girişimci istisnasını 20/B ile veya normal tarifede nasıl kullanırım?
7. Yurt dışı SaaS/API faturalarında KDV sorumlu sıfatıyla beyan ve gider belgeleme?
8. ETBİS, İYS, mesafeli sözleşme/abonelik ön bilgilendirme yükümlülükleri?
9. KVKK m.9: RevenueCat/Firebase/PostHog için dayanak (standart sözleşme, açık rıza, taahhütname), bildirim yükümlülüğü ve minimum veri stratejisi.
10. GDPR m.27 AB temsilcisi gerekli mi; Türkiye için AB yeterlilik durumu?
11. Marka: sınıf seçimi, vekil ücreti, Madrid/EUIPO/USPTO planı.
12. Apple W-8BEN/-E'de Madde 7 mi Madde 12 mi?

---

## 9. Doğrulayamadıklarım ve çelişkili kaynaklar

- 11257 sayılı Kararın Resmî Gazete metnini okuyamadım; KPMG özetine dayandım. Tarih RG 30.04.2026, sayı 33239 olarak birkaç kaynakta tutarlı.
- TÜRKPATENT 2026 marka harç cetvelinin PDF'i okunamadı; iki ikincil kaynak çelişiyor.
- Apple'ın Türkiye için güncel TL üyelik bedeli ve Türk bankalarına ödeme deneyimi resmî kaynakta yok.
- Türkiye'de tasarımcı ve UGC fiyatı için güvenilir kaynak bulunamadı; bütçedeki rakamlar tahmin.
- Bağ-Kur prim oranı (%34,5 vs %35,75), 20/B ile 4/b ilişkisi, e-Arşiv/e-Fatura 2026 eşikleri kaynaklar arasında çelişkili.
- Remotevergi (2026) "Danıştay 2025/4071 şahıslar için lehte" ve "20/B yurt içi müşteri için kullanılamaz" gibi iddialar içeriyor; GİB broşürü ikincisini doğrulamıyor, ben tekrarlamadım.
- Vergimerkezi 2026 rehberindeki 20/B limiti 6,5 M TL "tahmini" yazıyor; GİB hesabına göre 5,3 M TL (4. dilim).

Kullandığım geçici dosyalar yalnızca scratchpad klasöründe (indirilen GİB broşürü, IRS anlaşma PDF'i, TÜRKPATENT tarife PDF'i); proje klasörüne yazmadım.
