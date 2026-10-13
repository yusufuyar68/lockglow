# Türkçe köklü isim adayları: 3. tur, ön tarama (2026-10-11)

Bu rapor ön taramadır. Hukuki tavsiye değildir. Her şey salt okunur yapıldı: giriş yok, hesap yok, form yok, captcha çözümü yok.

**Kısa sonuç**
- Yaklaşık 240 Türkçe köklü ad taradım. 20'den fazlasını 8 mağazada derin kontrol ettim.
- Gerçek, yaygın Türkçe kelimelerin çoğu App Store'da, alan adlarında ve sosyal medyada zaten alınmış. Temiz kalanlar azdı.
- Sıralama: **1. Aferin, 2. Gozat, 3. Pirilti, 4. Anlami, 5. Anladim.**
- **Aferin** en sıcak ve en Türkçe olanı. **Gozat** en temiz ve ürüne en uygun olanı (göz at = glance). Aferin için TÜRKPATENT araması çakışma çıkarırsa Gozat'a geçin.
- En büyük bilinmeyen hepsi için aynı: **TÜRKPATENT**. Ona giriş yapmadan bakamadım (aşağıda).

Ham çıktılar: `...\scratchpad\names3_tr\` (pass1-8.jsonl, r2_*.jsonl, deep_*.jsonl, tm_us_*.txt, dom_*.txt, play_*.txt, tiktok_*.txt, table_raw.tsv). Araçlar: screen.mjs, screen2.mjs, tm.mjs, play.mjs, tt.mjs, dom.mjs, whois.mjs.

## Neyi kontrol edebildim, neyi edemedim

- **Apple App Store:** iTunes Search API ile us, tr, gb, de, vn, mx, es, ru mağazaları. Örnek bağlantı: https://itunes.apple.com/search?term=gozat&entity=software&country=tr&limit=50
  - **Düzeltilmiş hata:** İlk turlarda Türkçe noktasız "ı" harfini "i" gibi saymadım. Bu yüzden "ı" içeren bazı adların uygulamasını kaçırdım (örnek: Hatırla, Bakıver, Kıvılcım). Hatayı buldum. Bütün finalistleri düzeltilmiş araçla (screen2.mjs) yeniden taradım. İlk turda "var" diye elenen adlar bu hatadan etkilenmedi.
  - Arama en fazla 50 sonuç döndürür. Henüz yayımlanmamış veya sadece ad rezerve edilmiş uygulamalar görünmez.
- **Google Play:** Arama sayfası. "No results for X" temiz demektir. Örnek: https://play.google.com/store/search?q=gozat&c=apps
- **USPTO (ABD):** tmsearch.uspto.gov'un JSON uç noktası. Birebir, bulanık ve önek aramaları yaptım. Ayrıca yazım varyantlarını da denedim.
- **TÜRKPATENT: doğrulanmadı (giriş gerekiyor).** OPTS marka sorgusu (opts.turkpatent.gov.tr) beni giriş sayfasına yönlendirdi ("Oturum Süresi Doldu"). Giriş yapmadım. Bu tur için en önemli eksik bu.
- **TMview: doğrulanmadı (WAF).** "Problem detected" hatası verdi. Atlatmaya çalışmadım.
- **WIPO Global Brand DB (captcha) ve EUIPO eSearch (JS kabuğu): doğrulanmadı.** 2. turda da engelliydi, bu turda tekrar denemedim.
- **Alan adları:** `.com` ve `.app` için RDAP. `.com.tr` için TRABIS WHOIS (whois.trabis.gov.tr). `.io` için whois.nic.io. "404 / yok" = büyük olasılıkla boş, kesin değil.
- **TikTok:** oEmbed uç noktası (200 = hesap var, 400 = büyük olasılıkla yok).
- **Instagram:** WebFetch. Profil verisi görünüyorsa hesap var. Boş kabuk = büyük olasılıkla boş (çıkarım, kesin değil).
- **Dil kontrolü:** kendi bilgimle ve birkaç web aramasıyla yaptım. Anadili konuşan biriyle doğrulatın, özellikle Vietnamca (doğrulanmadı).
- **App Store Connect ad uygunluğu:** ancak uygulama kaydı açarak test edilir. Yapmadım.

## Ortak uyarılar

1. **Türk markasının "gerçek kelime" sorunu.** Günlük Türkçe kelimeler TÜRKPATENT'te çoğu zaman başka sınıflarda tescilli olur. Sınıf 9, 41 ve 42'de (uygulama, eğitim, yazılım) çakışma çıkabilir. Bu da elle aranmalı.
2. **ASCII yazım sorunu.** Ö, ü, ş, ı harfleri yazımdan düşünce okunuş bir miktar belirsiz kalır. Her adayda bunu ayrıca yazdım.
3. **Bu nişte Türkçe adlı rakipler zaten var.** Örnek: "Kilitli Kelime" (Eğitim, TR) adlı Türkçe bir kilit ekranı kelime uygulaması mevcut, bu yüzden "Kilit-" adlarının hepsini eledim. Benzer şekilde "Bildim: Kelime Ezberle" ve "Şimdi Anladım" (Eğitim) var.
4. **Listeye almadan elediklerim (argo/anlam riski):** Gün- (İngilizce "gun"), Cümle- ("cum"), Kus ("kus" = kusmak), Bakla (Tagalogcada küçümseyici), Dik- (argo çağrışım), Sözcü (gazete), Dersim (siyasi hassasiyet), Hadi (popüler Türk bilgi yarışması uygulaması), Tureng / Sesli Sözlük / Ekşi benzerleri.

## TOP 5

### 1. Aferin (6 harf, a-fe-rin). Genel risk: Orta. Küresel: Kısmen (TR odaklı)
- **Anlam / hikâye:** "Aferin!" = bravo, aferin sana. Doğru cevap verince ekranda çıkan sevinç sesi. Ürünün tonu: sıcak, cesaretlendiren. Kelime Farsça kökenli (TDK: Farsça *āferīn*). Farsça, Azerice ve Kürtçede de var. Romence "aferim" ("tamam, bravo") de aynı kökten.
- **Türkler nasıl okur:** "a-fe-RİN" (vurgu sonda). Duyunca yazarken bir kısmı "aferim" yazabilir. TDK doğrusunun "aferin" olduğunu söylüyor, ama "aferim" yanlışı çok yaygın. Bu yazım karışıklığı biraz risk.
- **Dil kontrolü (önce TR argo):**
  - Türkçe: argo veya küfür çağrışımı bulamadım. Alaycı kullanım var ("Aferin sana, bozdun") ama hafif. Çocuğa söylenen kelime olduğu için yetişkinlere biraz "öğretmen tonu" verebilir.
  - İngilizce, İspanyolca, Almanca: anlam yok, olumsuz çağrışım yok.
  - Rusça: "афера" (dolandırıcılık) sesine uzaktan benziyor. Hafif bir risk, ana pazar değil.
  - Vietnamca: "a-phê-rin" okunur, anlam bulamadım (doğrulanmadı).
- **App Store (8 mağaza):** hiçbirinde "Aferin" adlı uygulama yok. Komşular: **"Afarin Kids"** (Eğitim, Aras Hasan, ABD'de 169 puan) ve "Afarin" (Kitap). Bunlar aynı kelimenin Farsça yazımı, bir harf farkı. Başka: "Aferin" soyadlı geliştirici Mustafa Aferin'in uygulamaları (Lezzetio, MIVORA), konuyla ilgisiz.
- **Google Play:** tam eşleşme yok (sadece bulanık sonuçlar).
- **Marka:**
  - ABD: AFERIN yok. En yakınlar farklı kelimeler: AERIN (Aerin LLC, lüks ev/perakende, sınıf 35 ve diğerleri), AFERIY (sınıf 9 pil, Çin firması). Düşük risk.
  - TÜRKPATENT: **doğrulanmadı.**
- **Alan adları:**
  - aferin.com: dolu (2002'den beri, Afternic'te satışta, fiyat bilinmiyor).
  - aferin.app: **dolu, 2026-06-09'da kaydedilmiş, sayfasında "Launching Soon" yazıyor.** Sahibi bilinmiyor, olası rakip olabilir.
  - aferin.com.tr: dolu (2016).
  - aferin.io: boş.
  - Boş yedekler: getaferin.com, aferinapp.com, aferinkelime.com.
- **Sosyal:** Instagram @aferin dolu (kişisel hesap, 29 takipçi, tek gönderi 2016, uyuyor). TikTok @aferin dolu. TikTok @aferinapp ve @getaferin boş görünüyor.
- **App Store başlığı (TR):** "Aferin: İngilizce Kelime" (24). **Alt başlık:** "Kilit ekranında kelime öğren" (28).
  - EN: "Aferin: English Words" (21) / "Word cards on your lock screen" (30).
- **Küresel mi?** Küresel marka olarak önermem. Anlam yalnızca Türkçe, Farsça, Azerice ve Balkanlarda anlaşılır. TR mağazası için çok iyi. Global mağaza için ayrı ad düşünün.

### 2. Gozat (5 harf, go-zat). Genel risk: Düşük–Orta. Küresel: Hayır (yalnızca TR)
- **Anlam / hikâye:** "göz at" = bir bakış at, göz gezdir. Ürünün tam karşılığı: kilit ekranına bir göz at, yeni kelime. "Gözat" Windows'ta "Browse" düğmesi olarak da bilinir, yani tanıdık bir kelime.
- **Türkler nasıl okur:** "gö-ZAT". ASCII yazımda "o" aslında "ö". Türkler zaten "gözat" diye anlar. Yazarken "gozat" ve "gözat" ikisi de çıkar.
- **Dil kontrolü (önce TR argo):**
  - Türkçe: argo bulamadım. "Göz atmak" bazen birine "göz süzmek" anlamında da kullanılır, ama küfür değil.
  - İspanyolca: "gozar" (keyif almak) fiiline benziyor. Bazı Latin Amerika argolarında cinsel çağrışımı var. Düşük risk, ama İspanyolca pazarda dikkat.
  - İngilizce: "go-zat", "goat" ile karışabilir. Anlamı yok.
  - Rusça, Almanca, Vietnamca: anlam bulamadım (Vietnamca doğrulanmadı).
- **App Store (8 mağaza):** tam eşleşme yok, önek yok, içeren yok. TR'de "Gözat" araması sadece alakasız uygulamalar (ProTube vb.) döndürdü.
- **Google Play:** tam eşleşme yok.
- **Marka:**
  - ABD: GOZAT yok. Komşular farklı kelimeler: GOAT (sınıf 9 güneş gözlüğü ve kumar yazılımı; GOAT SOLUTIONS LTD, sınıf 35/41/45), GOZEE (sınıf 9 para transferi uygulaması), YOZAT (sınıf 9 aksesuar). Düşük risk.
  - TÜRKPATENT: **doğrulanmadı.** Özel not: "göz" kökü optik/gözlükçülerde yaygın. Sınıf 9 gözlükleri de kapsar. Elle bakılmalı.
- **Alan adları:**
  - gozat.com: dolu (2001'den beri, açılmayan IIS sayfası).
  - gozat.app: **boş.**
  - gozat.com.tr: **boş.**
  - gozat.io: **boş.**
  - Yedekler boş: getgozat.com, gozatapp.com.
- **Sosyal:** Instagram @gozat dolu (kişisel, 17 takipçi, tek gönderi 2014, uyuyor). TikTok @gozat dolu. TikTok @gozatapp ve @getgozat boş görünüyor.
- **App Store başlığı (TR):** "Gozat: İngilizce Kelime" (23). **Alt başlık:** "Her bakışta yeni bir kelime" (27).
  - EN: "Gozat: English Words" (20) / "One word card at every glance" (29).
- **Küresel mi?** Hayır. Anlam sadece Türkçede (ve kısmen Azericede) var. Türkiye mağazası için temiz ve güvenli seçim. Yurtdışı için başka bir ad gerekir.

### 3. Pirilti (7 harf, pi-ril-ti). Genel risk: Düşük–Orta. Küresel: Evet, kurgu ad olarak
- **Anlam / hikâye:** "pırıltı" = parıltı, ışıltı. Kilit ekranında her gün küçük bir parıltı, yeni bir kelime. Şiirsel ve sıcak, "ışık" ailesinden.
- **Türkler nasıl okur:** "pı-rıl-TI". Ama ASCII "Pirilti" iki noktalı i ile yazıldığından bazı kişiler "pi-ril-ti" okur. İkisi de anlaşılır. Gerçek kelimeyi arayan "pırıltı" yazarsa sizi bulamaz, bu bir dezavantaj.
- **Dil kontrolü (önce TR argo):**
  - Türkçe: argo yok. "pırt" (çocuk dilinde gaz sesi) ile çok uzak bir ses benzerliği var. Ciddi bulmadım.
  - Portekizce: "pirilampo" (ateşböceği) çağrışımı, tatlı ve ışıkla uyumlu.
  - İspanyolca, İngilizce, Almanca, Rusça: anlam bulamadım.
  - Vietnamca: "pi-ri-li-ti" okunur, anlam bulamadım (doğrulanmadı).
  - Okunması kolay, küresel olarak telaffuz edilebilir.
- **App Store (8 mağaza):** tam eşleşme yok, önek yok, içeren yok. TR'de "Pırıltı" araması alakasız sonuçlar verdi.
- **Google Play:** tam eşleşme yok.
- **Marka:**
  - ABD: PIRILTI yok, varyantlar (Pirilty, Pirelti) da temiz. Yazım varyantı "Pirelti" aramasında PIRELLI çıktı (lastik devi, sınıf 9/28/41/42 dahil geniş portföy). Pirilti ile Pirelli arasında iki harf fark var, farklı kelime ve farklı sektör. Düşük–orta.
  - TÜRKPATENT: **doğrulanmadı.**
- **Alan adları:**
  - pirilti.com: dolu, **yalnızca 11 gün önce (2026-09-30) kaydedilmiş**, boş sayfa. Biri bu adı kapmış olabilir.
  - pirilti.app: **boş.**
  - pirilti.com.tr: dolu (2006).
  - pirilti.io: boş.
  - Yedekler boş: getpirilti.com, piriltiapp.com.
- **Sosyal:** TikTok @pirilti **boş** (400). Instagram @pirilti boş kabuk döndürdü, büyük olasılıkla boş (çıkarım, doğrulanmadı).
- **App Store başlığı (TR):** "Pirilti: İngilizce Kelime" (25). **Alt başlık:** "Her gün parıldayan bir kelime" (29).
  - EN: "Pirilti: English Words" (22) / "Lock screen word cards daily" (28).
- **Küresel mi?** En olası aday. Kurgu bir ad gibi okunuyor, anlam engeli yok. Anlamı yalnızca Türkçede gizli.

### 4. Anlami (6 harf, an-la-mı). Genel risk: Düşük–Orta. Küresel: Hayır (yalnızca TR)
- **Anlam / hikâye:** "anlamı" = onun anlamı. Kelimenin altında hep aynı soru: "anlamı?". Doğrudan kelime öğrenme ile ilgili.
- **Türkler nasıl okur:** "an-la-MI" (anlamı). ASCII'de "ı" yerine "i" yazıldığı için yazım "anlami" olur. Bu yazılışa her gün rastlarlar, sorun olmaz. Bazıları "anlamı" diye yazıp bulamayabilir.
- **Dil kontrolü (önce TR argo):**
  - Türkçe: argo yok. Çok sık kullanılan masum bir kelime.
  - Diğer diller: anlam bulamadım (İspanyolca, İngilizce, Almanca, Rusça). Vietnamca doğrulanmadı.
- **App Store (8 mağaza):** tam eşleşme yok, önek yok, içeren yok. Yakın kelime: "Anlam" (Oyun) ve "Anlamlı Günler" (Üretkenlik), farklı adlar.
- **Google Play:** tam eşleşme yok.
- **Marka:**
  - ABD: ANLAMI yok. Varyantlar da temiz.
  - TÜRKPATENT: **doğrulanmadı.** "Anlam" kökü eğitimde betimleyici sayılabilir. Bunu uzman değerlendirmeli.
- **Alan adları:**
  - anlami.com: dolu (2017'den beri, boş sayfa).
  - anlami.app: **boş.**
  - anlami.com.tr: **boş.**
  - anlami.io: boş.
  - Yedekler boş: getanlami.com, anlamiapp.com.
- **Sosyal:** Instagram @anlami dolu ("Hayatın Anlamı", 6 takipçi). TikTok @anlami dolu ("An Lami"). TikTok @anlamiapp ve @getanlami boş görünüyor.
- **App Store başlığı (TR):** "Anlami: İngilizce Kelime" (24). **Alt başlık:** "Kelime anlamı kilit ekranında" (29).
  - EN: "Anlami: English Words" (21) / "Learn English on lock screen" (28).
- **Küresel mi?** Hayır. Sadece Türkçe konuşanlar için anlamlı. Telaffuz kolay ama hikâye kaybolur.

### 5. Anladim (7 harf, an-la-dım). Genel risk: Orta. Küresel: Hayır (yalnızca TR)
- **Anlam / hikâye:** "anladım" = anladım, kavradım. Kelimeyi öğrenince kullanıcının söylediği an. "Anladım" düğmesi uygulama içinde de kullanılabilir.
- **Türkler nasıl okur:** "an-la-DIM" (anladım). ASCII'de "ı" yerine "i" yazıldığı için "Anladim" olur. Herkes anlar.
- **Dil kontrolü (önce TR argo):**
  - Türkçe: argo yok. Alaycı kullanımı var ("Anladım..." = "peki, tamam"), hafif.
  - Diğer diller: anlam bulamadım (İspanyolca, İngilizce, Almanca, Rusça). Vietnamca doğrulanmadı.
- **App Store (8 mağaza):** tam eşleşme yok. **Yakın komşu: "Şimdi Anladım" (Eğitim, DOPING BİLİŞİM, TR'de 276 puan) ve "Şimdi Anladım Uzman" (Eğitim).** İsim içinde "Anladım" geçiyor, aynı kategori. Bu yüzden riski Orta tutuyorum. Ayrıca aynı niş kelime kalıbında "Bildim: Kelime Ezberle" (Eğitim) var.
- **Google Play:** tam eşleşme yok.
- **Marka:**
  - ABD: ANLADIM yok, hiçbir yakın komşu yok.
  - TÜRKPATENT: **doğrulanmadı.** "Şimdi Anladım" markası olabilir, özellikle aratın.
- **Alan adları:**
  - anladim.com: dolu (2011'den beri, "Anladım Danışmanlık" adlı aktif danışmanlık sitesi).
  - anladim.app: **boş.**
  - anladim.com.tr: dolu (2012).
  - anladim.io: boş.
  - Yedekler boş: getanladim.com, anladimapp.com.
- **Sosyal:** Instagram @anladim dolu (kişisel, 19 takipçi). TikTok @anladim dolu. TikTok @anladimapp ve @getanladim boş görünüyor.
- **App Store başlığı (TR):** "Anladim: İngilizce Kelime" (25). **Alt başlık:** "Kilit ekranında kelime kartı" (28).
  - EN: "Anladim: English Words" (22) / "Word cards on your lock screen" (30).
- **Küresel mi?** Hayır.

### Yerelleştirilmiş ad stratejisi (kısa)
App Store Connect'te her dil için farklı uygulama adı girilebilir. Türkiye mağazasında Türkçe bir ad (Aferin veya Gozat), diğer mağazalarda ayrı bir küresel ad kullanılabilir. Bunun için Pirilti gibi kurgu adlar en rahatı. Kararı marka ve ASO ihtiyacına göre siz verirsiniz.

## Elenen diğer adlar ve nedenleri

"Aynı adlı uygulama" = ABD veya TR mağazasında birebir (veya noktasız ı düzeltmesiyle) aynı adda uygulama var.

| Ad(lar) | Neden elendi |
|---|---|
| **Hatirla** | Güçlü fikir ("hatırla") ama 8 mağazada 2 aynı adlı uygulama var (Hatırla+ ve Hatırla: Akıllı Hatırlatıcı, Üretkenlik). Play'de "HATIRLA: Reminder & Countdown" var. hatirla.com HugeDomains'te satılık, hatirla.app dolu. |
| **Bakiver** | "Bakıver" = bir göz at, ürüne çok uygun. Ama canlı bir iOS uygulaması var: Veritera'nın saha-denetim hizmeti "Bakıver" (bakiver.app, 2026-04). TikTok ve Instagram dolu. |
| **Nedemek** | "Ne demek?" tam Türk öğrencinin sorusu. 8 mağazada ve Play'de temiz, ABD'de marka yok. Ama çok betimleyici (kelime sözlüğü siteleri aynı adı kullanıyor), TÜRKPATENT'te zorlanabilir. nedemek.com (2007, satılık), nedemek.app (2023), nedemek.com.tr (2025), IG ve TikTok dolu. Not: "ne demek" aynı zamanda "rica ederim" anlamına gelir. Güçlü fikir, zayıf marka. |
| **Yani** | Kısa, "yani / that is" anlamı Türkçede, Arapçada, Hintçe-Urduca ve Svahilicede ortak, küresel olabilir. Ama Play'de "Yani: Your AI Friend" birebir var. ABD'de canlı YANI HEALTH (sınıf 42, LastMinute Inc). yani.com (1998), yani.app (2018), yani.com.tr (2016), TikTok dolu. Kısa ve yaygın kelime olduğu için sicilde kalabalık. Instagram sonucu belirsiz (boş kabuk), doğrulanmadı. |
| Merakli | Eğitim kategorisinde "Meraklı Zihinler" (FERNUS) ve TÜBİTAK "Meraklı Minik" aileleri var. "Meraklı" aynı zamanda "fazla meraklı / fırsatçı" anlamı taşıyabilir. |
| Akici | "Akıcı" = akıcı (fluent), konsept güzel. Ama "Akıcı Konuş AI" (TR ve ABD) benzer niş. akici.com ve akici.com.tr dolu. |
| Cepsoz | Tüm ayak izi **en temiz** (stores, Play, USPTO; .com, .app, .com.tr, .io boş; TikTok boş). Ama ses ve imaj zayıf ("jep-söz"). **Yedek seçenek.** Aynı kalıp: Cepdil, Cepkart, Sozcep, Sozgoz, Sozkart, Kartsoz, Hecekart, Sozbak, Baksoz (temiz ama sönük). |
| Kalsin | Temiz (mağaza, Play, USPTO, .app ve .com.tr boş), ama anlam zayıf ("kalsın"). TikTok dolu. |
| Heyecan | Mağazalarda temiz, ama öğrenmeyle bağı zayıf, çok genel. heyecan.com (1999) ve .com.tr dolu, TikTok dolu. |
| Tekrarla, Yine, Aklinda | Mağazalarda temiz ama betimleyici veya zayıf. Tekrarla: "Tekrar – Flashcards" kardeşi var. Yine: ABD'de birebir YINE markası (sınıf 3), Play'de "Yine - Bible", .com ve .app dolu. Aklinda: "Aklında Tut" oyunu var. |
| Ansoz | ansoz.com bir eğitici oyuncak markası (çocuk puzzle ve STEM), eğitim alanında çakışma. |
| Anlamli, Anlamo, Ucunda, Diline, Bidaha, Gordum, Hatirladim, Benimse, Derlem, Edinim | Mağaza olarak temiz ama ya betimleyici (Anlamli: onlarca "anlamlı sözler" uygulaması), ya hikâyesi zayıf, ya ö/ü/ş harfi sorunu var. |
| **Kilit-: Kilit, Kilitli, Kilitle, Kilitsoz, Kilitdil** | "Kilitli Kelime" (Eğitim, TR) zaten var. Çok benzer. |
| **Sözlük/söz ailesi:** Soz, Sozce, Sozcuk, Sozluk, Sozu, Sozel, Sozlu, Sozbul | Aynı adlı uygulama var (Söz: Kelime Oyunu; Söz: Learn Kyrgyz; Sözce: Kelime Oyunu; Sözcük; Sozluk; Sozu). |
| **Dil ailesi:** Dilbaz, Dilce, Dilci, Dilim, Dilly | Aynı adlı veya yakın uygulama: Dilbaz (Oyun), Dilce: İngilizce Öğren (Eğitim), Dilci YDS YÖKDİL YDT (Eğitim), Dilim, dilly. |
| **Kelime ailesi:** Kelimecik, Kelimekart, Kelimeli, Kelimem, Kelimoji, Kelim, Kelimeci | Aynı adlı veya benzer oyun/eğitim uygulaması var (Kelimecik: Word Puzzle, Kelime Kart, Kelimeli, Kelimem, Kelimoji: Turkish Word Game, Kelimelik). |
| **Hece / harf:** Hece, Harfik, Hecele | Hece (Eğitim) ve HECE: Türkçe Kelime Oyunu var; Harfik: Kelime Oyunu var; Hecele için "Hecelerim" oyunu ve c okunuşu sorunu (hece: ce = dʒ). |
| **Ezber / hafıza / tekrar:** Ezberle, Ezber, Hafiza, Unutma, Hatirlat, Tekrar, Bildim, Bilirim, Buldum | Aynı adlı uygulama var: Ezberle (Eğitim), Hafıza, Unutma: Second Brain, Hatirlat, Tekrar – Flashcards, **Bildim: Kelime Ezberle (Eğitim, bire bir niş)**, Bilirim (oyun, de/mx/es/ru'da birebir), Buldum. |
| **Bilgi / merak:** Merak, Bilgi, Bilge, Bilgin, Bilig, Bilik | Merak: Dinleyerek Öğren (Eğitim) birebir. Bilgi, Bilgin, Bilge çok kalabalık. Bilig: Almanca "billig" (ucuz) ile aynı okunur ve "Bilig: Travel" uygulaması var. |
| **Işık / gün / cep:** Yildiz, Parilti, Kivilcim, Fener, Kandil, Parlak, Gunce, Gunluk, Bugun, Cebim, Cepte | Yıldız ve benzerleri çok kalabalık. Kıvılcım: Sınav Koçun (Eğitim) var. Parıltı: .com ve .app dolu. Günce, Günlük, Bugün, Cebim: birebir uygulamalar. |
| **Göz / bakış / an:** Gozcu, Gozde, Gozum, Gozlem, Bakis, Bakin, Anlik, Anda, Anla, Anlam, Anlat | Gözcü (gazete / uygulama), Gözde, Anlam (Oyun), Anlat! (Oyun), ANLIK, Anda: birebir. Bakış: ş yazım sorunu. |
| **Ses / günlük ifadeler:** Aha, Evet, Hele, Naber, Neyse, Oley, Peki, Bakalim, Bibak, Kolay, Harika, Dostum, Hocam, Hoca, Ustam, Usul, Taze, Odak | Birebir uygulama (Aha, Evet, Hele, Naber, Neyse, Oley, Bakalim, Bibak, Kolay, Hocam: Görüntülü Özel Ders, Ustam, Usul, Taze, Odak) veya çok kalabalık. Dostum: Afgan komutan Dostum çağrışımı. Harika: temiz ama anlam genel, .com/.app dolu. |
| **Doğa ve diğer:** Lokma, Damla, Zerre, Boncuk, Filiz, Fidan, Tohum, Susam, Pencere, Vitrin, Defter, Terim, Deyim, Mana, Mani, Fikra, Nukte, Muhabbet, Geveze, Cevher | Birebir uygulama (Lokma, Boncuk, Filiz, Fidan, Tohum: İngilizce & Almanca, Pencere, Vitrin, Defter, Mana, Mani, Fikra, Nukte, Muhabbet). **Susam:** Susam Sokağı (Sesame Street) markası çağrışımı, Sesame Workshop riski. **Terim:** Fatih Terim çağrışımı. |
| **Köken ve diğer:** Bitig, Til, Tilek, Sav, Sozo, Puhu, Ozan, Zinde, Odak, Kavra, Idrak, Belagat, Huner, Marifet | Birebir uygulama (Kavra: Word Puzzle, Idrak: Qur'an Explorer, Belagat, Ozan, Puhu, Zinde, Sav) veya anlam zayıf. Bitig .com hatalı çıktı, doğrulanmadı. |
| **Karma ve oyunlu birleşimler:** Sozmoji, Ekransoz, Acilsoz, Gunsoz, Sozgun, Dilgun, Dilimce, Dilimde, Dilsel, Dilbilir, Hecelik, Heceli, Hecegun, Ezbercik, Ezbero, Lafcik, Kelimce, Kelimcik, Harfiye, Harfin, Harfli, Harfa, Hecem | Mağazada temiz ama ses ve imaj zayıf; Gunsoz ve Sozgun İngilizce "gun" çağrışımı taşıyor; Acilsoz "acil" (urgent) gibi okunur; Kelimcik resmi olmayan bir yazım. |
| Dilcan, Sozcan, Sozy, Sozi, Sozlen, Sozum, Sozlugum, Lafi, Laf, Lafa, Lafiz, Kelo, Kelimen, Akilli, Akilda, Pekistir, Ipucu, Farket, Cevher, Algi, Yanit, Yanni, Hazine, Hazir, Gozlem, Hepsi, Hergun, Bellek, Adim, Adimli | Çoğu birebir veya önek uygulama (Lafi, Laf, Lafa, Kelo, Sozi, Hazine, Hazır, Adim, bellek); veya anlam ve harf sorunu (Sozlugum ö/ü/ğ, Pekistir ş, Lafiz dini çağrışım). |

## Elle yapılması gerekenler

1. **TÜRKPATENT (en önemli).** https://opts.turkpatent.gov.tr marka sorgusu giriş istiyor. Siz e-Devlet ile girip Aferin, Gozat, Pirilti, Anlami, Anladim için 9, 41 ve 42. sınıflarda arayın.
   - Aferin: AFERİN, AFERIN, AFARİN, AFERİM.
   - Gozat: GÖZAT, GOZAT, "GÖZ AT", GOZET.
   - Pirilti: PIRILTI, PIRILTİ, PIRIL.
   - Anlami: ANLAMI, ANLAMİ, ANLAM.
   - Anladim: ANLADIM, ANLADİM, "ŞİMDİ ANLADIM".
2. **TMview, EUIPO, WIPO** (TR, EM, US, VN, MX, GB) elle: bu turda WAF/captcha nedeniyle yapılamadı.
3. **aferin.app** kimde, ne zaman satılacak veya ne yapılacak? "Launching Soon" sayfası var, rakip olabilir. Sahibi bilinmiyor.
4. **Pirilti:** pirilti.com'u 11 gün önce kaydeden kim? Alakasız bir yatırımcı da olabilir.
5. **Instagram sonuçları** (@pirilti, @cepsoz boş kabuk) kesin değil. Hesap açarak doğrulayın.
6. **App Store Connect ve Play Console'da ad kullanılabilirliği** (kayıt açmadan test edilemez).
7. **Dil kontrolü:** özellikle Vietnamca (ve Türk arkadaşlarla argo testi: "Aferin", "Gozat", "Pirilti" için).
8. **Logo / görsel marka araması** (Vienna kodu) yapılmadı.
