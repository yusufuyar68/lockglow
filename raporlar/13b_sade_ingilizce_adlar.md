# Sade İngilizce isim taraması, tur 3 (2026-10-11)

**Bu bir ön taramadır, hukuki tavsiye değildir.** Her şey salt okunur yapıldı: giriş yok, hesap yok, form yok, captcha çözümü yok. Ham çıktılar ve scriptler `C:\Users\yusuf\AppData\Local\Temp\claude\C--Users-yusuf-OneDrive-Desktop-Widget-Vocabulary--learn-words\e927268b-3cbe-437d-b9e4-b39cf6e813db\scratchpad\names3_en\` klasöründe (`pass1-4.jsonl`, `deep1.jsonl`, `deep1b.jsonl`, `tm_pass*.txt`, `play_pass1.jsonl`, `dom_finalists*.jsonl`, `combined.txt`).

## Kısa sonuç
- Yön: A1-A2 seviyesinde, iki kelimelik birleşik adlar. Yaklaşık 240 aday taradım. Derin kontrole 11 isim girdi.
- **Sıralama: 1. Lockglow, 2. Learnbell, 3. Wordbell, 4. Lockbell, 5. Wordshine.**
- En temiz ve en iyi alan adı durumu: **Lockglow** (`.com`, `.app`, `.io` boş görünüyor, hiçbir mağazada eşleşme yok). Riski "Düşük–Orta" yazdım, çünkü kilit ekranında "Glow" adlı küçük bir olumlama uygulaması ve "GlowLock" adlı bir ekran süresi uygulaması var (ikisi de başka ürün). Yine de 1. sıraya koydum: TOP 5 içinde tek boş `.com`, en güçlü tescil yapısı (kelime öğretmeyi anlatmıyor).
- Learnbell daha düşük riskli ama "learn" kelimesi tanımlayıcı olduğu için tescil yapısı biraz zayıf ve `.com` park halinde. Bu yüzden 2. oldu.
- Kendini en iyi anlatan isim: **Wordbell** ("ring a bell" sözüne gönderme yapıyor). Ama App Store'da aynı fikirde küçük bir rakip var: "English Word Bell". Bu yüzden risk Orta.
- Bu turda öğrendiklerim:
  1. "word + lamp / light / shine / candle" kalıbı İncil'i çağrıştırıyor (Mezmur 119:105, "Sözün ayağıma kandildir"). Mağazalarda bu adlar hep İncil uygulaması çıkıyor. Türkiye pazarı için istemezsiniz.
  2. Türkçede "bit" = bit (parazit). "-bit" ile biten adları (Saybit, Brightbit vb.) eledim.
  3. Düz İngilizce `.com` adlarının neredeyse hepsi alınmış. Ama çoğu "park" sayfası (satılık olabilir). `.app` ve `.io` çok daha sık boş.
  4. "word" ile başlayan adların çoğunda tam adlı oyun/sözlük uygulaması var. Bu yüzden "word" yerine "lock", "learn", "bell", "glow" gibi parçalar daha temiz çıktı.

## Ne kontrol edilebildi, ne edilemedi
- **App Store (iTunes Search API):** us, tr, gb, de, vn, mx, es, ru çalıştı. Hızlı elemede sadece US, derin kontrolde 8 mağaza. Her isim için hem bitişik ("lockglow") hem ayrık ("lock glow") yazım arandı. Örnek: https://itunes.apple.com/search?term=lockglow&entity=software&country=tr&limit=50
- **Google Play:** arama sayfası okunabildi. Sonuç başlıkları tek tek incelendi (sadece İngilizce/US arama). Örnek: https://play.google.com/store/search?q=lockglow&c=apps
- **ABD markaları (USPTO tmsearch JSON):** tam eşleşme, benzer yazım ve önek aramaları çalıştı. Bir kez 403 (hız sınırı) aldım, bekleyip yeniden denedim.
- **ABD dışı marka kayıtları: kontrol edilemedi, doğrulanmadı.**
  - TMview: bugün tarayıcıda "Problem detected" (WAF) hatası, doğrudan API'de ECONNRESET. Durdurdum.
  - WIPO Global Brand DB: tur 2'de ALTCHA captcha vardı, bu turda denemedim.
  - EUIPO eSearch: JS kabuğu, sorgulanamıyor (tur 2).
  - TÜRKPATENT: giriş istiyor, denemedim.
  - Yani Türkiye, AB, İngiltere, Vietnam, Meksika marka durumu **doğrulanmadı**.
- **Alan adları:** `rdap.verisign.com` (.com, .net), `pubapi.registry.google` (.app), `rdap.identitydigital.services` (.io). Kontrol olarak google.com/.app/.io çalıştı. 404 = büyük olasılıkla boş (kesin değil). Alınmış `.com` sayfaları ayrıca açıldı.
- **TikTok:** `tiktok.com/oembed` (200 = hesap var, 400 = yok gibi). Kontrol: duolingo 200, uydurma ad 400.
- **YouTube:** `youtube.com/@ad` (404 = boş). Kontrol: duolingo 200, uydurma ad 404. Kanal içeriğini okuyamadım.
- **Instagram:** WebFetch ile. Profil bilgisi çıkarsa hesap var. Sadece boş kabuk çıkarsa "büyük olasılıkla boş" (tahmin, kesin değil). Özel (private) hesaplar da "alınmış" sayıldı.
- **X (Twitter), App Store Connect ad uygunluğu, Play Console ad uygunluğu:** kontrol edilmedi (giriş gerekir), doğrulanmadı.
- **Dil kontrolleri:** kendi bilgimle ve birkaç web aramasıyla. Vietnamca için anadili konuşan kontrolü yapılmadı, doğrulanmadı. Rusça argo notlarım da doğrulanmadı.

## TOP 5

### 1. Lockglow (8 harf, lok-glo) — genel risk: Düşük–Orta
- **Anlam / hikaye:** Lock (kilit ekranı) + glow (parlama). "Kilit ekranında parlayan kelime." Ayrıca "glow up" (gelişmek) sözüyle de oynuyor: İngilizcen kilit ekranında parlasın. Kelimeler A1-A2 seviyesinde. Adın kendisi "kelime/dil" demiyor, bunu başlık söyler.
- **Türkler nasıl okur:** "lok-glo" (sondaki w sessize yakın okunur, bazıları "lok-glov" der). Duyduktan sonra yazarken "Lokglo" diyenler olabilir. Tek zor yer "glow" yazımı.
- **Dil kontrolü:**
  - Türkçe: anlamlı/olumsuz bir şey bulamadım. "lok" Türkçede "lök" (sersem, argo) gibi duyulabilir ama aynı kelime değil.
  - İspanyolca: olumsuz anlam yok.
  - Vietnamca: "gl-" kümesi zor, "lốc" (hortum) anlamlı bir kelime ama zararsız. Doğrulanmadı.
  - Rusça: olumsuz anlam bulamadım (doğrulanmadı).
  - Almanca: "locken" (çekmek) ile benzer, olumsuz değil.
  - İngilizce: net ve olumlu.
- **Ayırt edicilik: Önerici (suggestive), jenerik değil.** "Lock" kilit ekranı özelliğini anlatır, "glow" ise ima eder. İkisi de kelime öğretme hizmetini doğrudan anlatmaz, bu yüzden 41. sınıf (eğitim) için "keyfi"ye yakın. Tescil için güçlü taraf bu.
- **App Store (8 mağaza):** us, tr, gb, de, vn, mx, es, ru: tam adlı uygulama yok, "Lockglow ile başlayan" yok, adı içeren yok. Komşu uygulamalar: "GlowLock: Screen Time Blocker" (ters sıra, ekran süresi engelleyici) ve "Glow: Lock Screen Affirmations" (LK Shop LLC, olumlama sözleri, Health & Fitness, 2026-06, 0 değerlendirme). İkisi farklı ürün, ama kilit ekranı + glow kelimeleri yakın. Bulmak için: https://itunes.apple.com/search?term=glow%20lock%20screen&entity=software&country=us&limit=15
- **Google Play:** "lockglow" ve "lock glow" aramalarında tam eşleşme yok. İlk sonuçlar alakasız (Glow Block, Good Lock, AuraLook vb.).
- **Markalar (ABD):** LOCKGLOW tam, benzer yazım ve önek aramalarında kayıt yok (26 sonuç, hiçbiri yakın değil). Yakın komşu: GLOWLOCK (3. sınıf, makyaj spreyi, bir kişi). ABD dışı: **doğrulanmadı.**
- **Alan adları:** lockglow.com, lockglow.app, lockglow.io, lockglow.net: hepsi RDAP 404 (büyük olasılıkla boş). getlockglow.com ve lockglowapp.com da boş. TOP 5 içinde `.com`'u boş çıkan tek aday.
- **Sosyal:**
  - TikTok @lockglow alınmış (müzik/lirik hesabı, alakasız). @lockglowapp boş (400).
  - YouTube @lockglow boş (404). @lockglowapp boş.
  - Instagram @lockglow ve @lockglowapp: boş kabuk, büyük olasılıkla boş (tahmin).
- **App Store başlığı:** "Lockglow: Vocabulary Widget" (27)
- **Alt başlık:** "English words on lock screen" (28)
- **Dikkat:** İsim "lock" ile başladığı için bazı kullanıcılar "uygulama kilidi" sanabilir. Başlık ve ikon bunu düzeltir.

### 2. Learnbell (9 harf, lörn-bel) — genel risk: Düşük
- **Anlam / hikaye:** Learn (öğren) + bell (zil). Zil = hatırlatma. Her gün çalan "öğrenme zili". Spaced repetition için doğal bir fikir.
- **Türkler nasıl okur:** "lörn-bel". İçinde w yok. "Learn" kelimesini A1 seviyesinde herkes bilir.
- **Dil kontrolü:**
  - Türkçe: "bel" (vücut kısmı) ile ses benzerliği var, olumsuz değil.
  - İspanyolca: olumsuz anlam yok.
  - Vietnamca: "lơn-ben", anlamlı bir risk görmedim (doğrulanmadı).
  - Rusça: yok (doğrulanmadı).
  - Almanca: "Lern-" (öğrenme) gibi okunur, olumlu.
  - İngilizce: net.
  - Not: "BELL.bg" Bulgaristan'da İngilizce öğreten bir uygulama; ayrıca İngiltere'de "Bell English" okulu 2025-10'da kapandı. Bunlar "Bell" ile ilgili hatırlatma, markası bugün aktif mi doğrulanmadı.
- **Ayırt edicilik: Önerici ama biraz zayıf.** "Learn" doğrudan eğitim hizmetini anlatıyor (tescilde "learn" için feragat istenebilir). "Bell" ima ediyor. Bütün olarak tescil edilebilir, ama Lockglow kadar güçlü değil.
- **App Store (8 mağaza):** hiçbirinde tam adlı, "Learnbell ile başlayan" ya da adı içeren uygulama yok.
- **Google Play:** tam eşleşme yok. İlk sonuçlar MyBell, eBeLl, Lesson Bell, Bluebell, OnlineBell (alakasız).
- **Markalar (ABD):** LEARNBELL ve "learn bell" aramasında kayıt yok. ABD dışı: **doğrulanmadı.**
- **Alan adları:**
  - learnbell.com alınmış (2016-02-14'ten beri, Afternic isim sunucuları, "/lander" park sayfası). Satılık olabilir, fiyat doğrulanmadı.
  - learnbell.app, .io, .net: boş (404). getlearnbell.com, learnbellapp.com da boş.
- **Sosyal:**
  - TikTok @learnbell boş (400), @learnbellapp boş.
  - YouTube @learnbell kanal var (içerik doğrulanmadı), @learnbellapp boş.
  - Instagram @learnbell ve @learnbellapp: boş kabuk, büyük olasılıkla boş (tahmin).
- **App Store başlığı:** "Learnbell: Vocabulary Widget" (28)
- **Alt başlık:** "English words on lock screen" (28)

### 3. Wordbell (8 harf, vörd-bel) — genel risk: Orta
- **Anlam / hikaye:** Word + bell. Zil bir hatırlatma, ama asıl güzellik şu: İngilizcede "Does it ring a bell?" = "Tanıdık geliyor mu?". Aralıklı tekrar tam olarak bunu soruyor. Öğrenen A2'de bunu bilmese bile "kelime + zil" adı anlıyor. Beş isim içinde hikayesi en iyisi bu.
- **Türkler nasıl okur:** "vörd-bel". Duyup yazarken "Vordbel" ya da "Wordbel" yazabilirler. Tek w var (Türkçede w yok, v diye okunur).
- **Dil kontrolü:**
  - Türkçe: "bel" ile benzerlik zararsız.
  - İspanyolca: "guord-bel", olumsuz yok.
  - Vietnamca: "word" zor, "ướt" (ıslak) gibi duyulabilir, zararsız. Doğrulanmadı.
  - Rusça: "Ворд" = Microsoft Word çağrışımı, olumsuz değil.
  - Almanca: "Wort" + "Bell", olumlu.
  - İngilizce: net.
- **Ayırt edicilik: Önerici.** "Word" zayıf (tanımlayıcı) parça, "bell" ve "ring a bell" şakası ayırt edici olan. Bütün olarak iyi bir birleşik ad.
- **App Store (8 mağaza):** tam adlı "Wordbell" uygulaması yok. **Ama 8 mağazanın hepsinde "English Word Bell" çıkıyor:** [English Word Bell](https://apps.apple.com/us/app/english-word-bell/id6762029885), Utilities, bireysel Çinli geliştirici, 2026-05 çıkış, 0 değerlendirme. Açıklaması bildirimlerden kelime ezberletme (aynı fikir). Bu yüzden risk Orta. Adı aynı sözcüklerden oluşuyor ve aynı işi yapıyor.
- **Google Play:** tam eşleşme yok (sonuçlar Wordle ağırlıklı).
- **Markalar (ABD):** WORDBELL tam ve "word bell" aramasında kayıt yok. Yakın komşu: WORDWELL (35. sınıf, reklam metin yazarlığı, Kanada). ABD dışı: **doğrulanmadı.**
- **Alan adları:**
  - wordbell.com alınmış (2021-08-10, GoDaddy, "/lander" park sayfası, satılık olabilir, fiyat doğrulanmadı).
  - wordbell.app, .io, .net boş (404). getwordbell.com, wordbellapp.com da boş.
- **Sosyal:**
  - TikTok @wordbell boş (400). @wordbellapp, @getwordbell boş.
  - Instagram @wordbell alınmış (özel hesap, 26 takipçi). @wordbellapp: boş kabuk, büyük olasılıkla boş (tahmin).
  - YouTube @wordbell kanal var (içerik doğrulanmadı), @wordbellapp boş.
- **App Store başlığı:** "Wordbell: Vocabulary Widget" (27)
- **Alt başlık:** "Learn English on lock screen" (28)
- **Neden 3. sırada:** Hikayesi en iyisi, ama "English Word Bell" yüzünden aramada yan yana çıkarsınız. Bunu kabul ediyorsanız bence en çok sevilecek isim bu. Etmiyorsanız Learnbell'e geçin.

### 4. Lockbell (8 harf, lok-bel) — genel risk: Düşük
- **Anlam / hikaye:** Lock (kilit ekranı) + bell (hatırlatma zili). "Kilit ekranındaki zil." Kısa ve w içermiyor.
- **Türkler nasıl okur:** "lok-bel". Her harf okunduğu gibi, yazım kolay.
- **Dil kontrolü:**
  - Türkçe: zararsız.
  - İspanyolca: olumsuz yok.
  - Vietnamca: yok (doğrulanmadı).
  - Rusça: yok (doğrulanmadı).
  - Almanca: "locken" (çekmek), olumsuz değil.
  - İngilizce: kapı kilidi ve kapı zili (doorbell) akla gelebilir. Akıllı kapı kilidi ürünleri gibi duyulabilir. Bu bir çağrışım riski.
- **Ayırt edicilik: Önerici.** Lock ve bell, ikisi de kelime öğretmeyi anlatmıyor. 41. sınıf için keyfiye yakın.
- **App Store (8 mağaza):** tam adlı, ile başlayan veya adı içeren uygulama yok.
- **Google Play:** tam eşleşme yok (Bell Bank Mobile, LocumBell, Blackbell Apps vb. alakasız).
- **Markalar (ABD):** LOCKBELL ve "lock bell" aramasında kayıt yok. Yakın komşular: LOCKWELL (42. sınıf, bilgisayar güvenliği), SKYBELL (9. sınıf, video kapı zili). Benzerlik düşük. ABD dışı: **doğrulanmadı.**
- **Alan adları:** lockbell.com alınmış (2020-07-23, siteye bağlanılamıyor, yani kullanılmıyor gibi). lockbell.app, .io, .net boş. getlockbell.com, lockbellapp.com boş.
- **Sosyal:** TikTok @lockbell alınmış (hesap adı rakamlardan oluşan bir kullanıcı, içeriği doğrulanmadı). Instagram @lockbell alınmış (özel, 0 takipçi). YouTube @lockbell kanal var (alakasız görünüyor, doğrulanmadı).
- **App Store başlığı:** "Lockbell: Vocabulary Widget" (27)
- **Alt başlık:** "Learn English on lock screen" (28)
- **Neden 4. sırada:** Temiz ama hikayesi Wordbell/Learnbell kadar güçlü değil, kapı kilidi çağrışımı var ve sosyal hesapların üçü de alınmış.

### 5. Wordshine (9 harf, vörd-şayn) — genel risk: Düşük–Orta
- **Anlam / hikaye:** Word + shine (parlamak). "Kelimen parlasın." Lockglow ile aynı parlama fikri, ama "word" içeriyor ve anlaşılması daha kolay.
- **Türkler nasıl okur:** "vörd-şayn". İki zor nokta: w ve "sh" (Türkçe ş ile yakın, sorun değil).
- **Dil kontrolü:**
  - Türkçe: yok.
  - İspanyolca: yok.
  - Vietnamca: "shine" yazımı zor, olumsuz yok (doğrulanmadı).
  - Rusça: yok (doğrulanmadı).
  - Almanca: "Wort-Schein", olumlu.
  - İngilizce: net. **İncil çağrışımı hafif:** "Word" + "shine" Hristiyan içerikte sık geçiyor (aynı aile: Wordlamp, Wordlight). Wordshine için mağazada İncil uygulaması çıkmadı, ama risk var.
- **Ayırt edicilik: Önerici.**
- **App Store (8 mağaza):** tam adlı, ile başlayan, adı içeren uygulama yok.
- **Google Play:** tam eşleşme yok (sonuçlar Vocabulary - Learn words daily, Zann WordUp vb. başka adlar).
- **Markalar (ABD):** WORDSHINE ve "word shine" aramasında kayıt yok. Yakın komşu: WORDSHIRE (9/35/42, Polonyalı oyun uygulaması), benzerlik düşük. ABD dışı: **doğrulanmadı.**
- **Alan adları:** wordshine.com alınmış (2025-12-14, Afternic, "/lander" park, yeni alınmış, muhtemelen yeniden satış). wordshine.app, .io, .net boş. getwordshine.com, wordshineapp.com boş.
- **Sosyal:** TikTok @wordshine boş (400). Instagram @wordshine alınmış (özel, 0 takipçi, "One good quote at a time"). YouTube @wordshine kanal var ("365 Interpretations", alakasız).
- **App Store başlığı:** "Wordshine: Vocabulary Widget" (28)
- **Alt başlık:** "English words on lock screen" (28)
- **Neden 5. sırada:** Hafif İncil çağrışımı, `.com` yeni alınmış bir yeniden satış alanı ve Instagram alınmış.

### TOP 5 yan yana
| | Lockglow | Learnbell | Wordbell | Lockbell | Wordshine |
|---|---|---|---|---|---|
| Harf | 8 | 9 | 8 | 8 | 9 |
| "w" sayısı | 1 (glow) | 0 | 1 | 0 | 1 |
| Ayırt edicilik | Önerici (keyfiye yakın) | Önerici (biraz zayıf) | Önerici | Önerici | Önerici |
| 8 mağaza, tam ad | Yok | Yok | Yok, ama "English Word Bell" (aynı fikir) | Yok | Yok |
| Google Play | Temiz | Temiz | Temiz | Temiz | Temiz |
| ABD marka | Temiz | Temiz | Temiz | Temiz | Temiz |
| .com | Boş görünüyor | Park (satılık olabilir) | Park (satılık olabilir) | Alınmış, kullanılmıyor | Park, yeni alınmış |
| .app / .io | Boş / boş | Boş / boş | Boş / boş | Boş / boş | Boş / boş |
| TikTok / Instagram / YouTube | Alınmış / boş (tahmin) / boş | Boş / boş (tahmin) / var | Boş / alınmış / var | Alınmış / alınmış / var | Boş / alınmış / var |
| Risk | Düşük–Orta | Düşük | Orta | Düşük | Düşük–Orta |

## Sizin örnek adlarınızın durumu
| Ad | Sonuç |
|---|---|
| Glowword | Elendi. glowword.app "GlowWord 萤火单词" adlı kelime/çeviri ürünü, DE/MX/ES'de "GlowWords" dil uygulaması, GLOWWORM (9. sınıf) bir harf uzakta. |
| Pocket Words | Elendi. ABD'de iki tam adlı uygulama: "PocketWords - Learn Vocabulary" (Education) ve "Pocket Words: Brain Puzzle". |
| Word Lamp | Elendi. wordlamp.app bir İncil okuyucu, Play aramasında İncil uygulamaları çıkıyor. |
| Daily Spark | Elendi. 6 tam adlı uygulama (4'ü Education/Productivity/Lifestyle). Ayrıca tanımlayıcı, tescili zor. |
| Lockword | Elendi. "LockWords: Lock Screen Widgets" (Education) doğrudan rakip. |
| Tiny Words | Elendi. "Tiny Words" ve "TinyWords - Toddler Vocabulary" (ikisi de Education). |

## Elenen diğer isimler ve nedenleri
Yaklaşık 240 adayın tamamı ABD App Store, ABD markaları ve alan adları açısından hızlı elemeden geçti (ham liste: `combined.txt`). Aşağıda gruplar halinde. "Tam adlı uygulama" = ABD App Store'da adı aynı olan uygulama var.

| İsim(ler) | Neden elendi |
|---|---|
| Pocketglow | pocketglow.com 2008'den beri uygulama yapan bir firma, dil uygulamaları var (SpeakEasy, Electric French, Playwords). |
| Sayglow | sayglow.app canlı bir prompter (teleprompter) uygulaması, sayglow.com ve TikTok @sayglow alınmış. |
| Wordlamp | wordlamp.app bir İncil okuyucu (yukarıya bakın). |
| Wordlight, Wordcandle, Wordtorch | Wordlamp ile aynı İncil çağrışımı ("Your word is a lamp..."). Wordlight: Play'de tam ad "WordLight" ve "WordLight Tamil Bible". Wordtorch: Rusçada "торч" argo riski (doğrulanmadı). Wordcandle mağazalarda temiz ama 10 harf ve İncil çağrışımı. |
| Tinylamp, Pocketlamp, Learnlamp, Lamplearn, Daylamp, Hellolamp, Talklamp, Speaklamp, Lamptalk, Lingolamp, Brightlamp | Mağaza ve ABD markası olarak temiz, ama "lamp" mağazalarda çoğunlukla İncil teması. Tinylamp'ta TikTok @tinylamp ve .com alınmış. Yedek: Tinylamp. |
| Lamplit, Lamplock, Dailylamp, Littlelamp | Tam adlı İncil uygulaması (LampLit - Bible Reading Plans, Lamp Lock: Bible App Blocker, Play'de "Daily Lamp: Bible Widget" ve "LittleLamp - Bible Stories"). |
| Saybell | Yedek. 8 mağaza, Play ve marka temiz. Ama anlamı zayıf ("say" + "bell"), Instagram @saybell alınmış (515 takipçi), YouTube alınmış, .com alınmış. |
| Hellolock | Yedek. 8 mağaza ve marka temiz, .app boş. "Hello English" (büyük bir uygulama) ve "Windows Hello" çağrışımı var. Komşu uygulama "HiLock" (Utilities). |
| Lockping | Play'de tam ad "LockPing" (RM-Worx). .com alınmış. |
| Learnping, Wordping, Pingword | Mağazalar temiz. Ama anlam zayıf, .com satılık (HugeDomains), Learnping .app alınmış, TikTok @learnping alınmış. |
| Lockspark | Play'de tam ad: "LockSpark: Lock Screen Effects". |
| Locklearn | "Lock Learn: Passive Learning!" ve "Lock&Learn" serisi (Education), doğrudan rakip. |
| Lockbloom | Play'de "LockBloom Password Manager" (ile başlayan). Alan adları boş ama yakın ad. |
| Lockbright, Locklight, Lockbud, Sparklock, Minilock | Temiz ama anlamı zayıf ya da ilgi çekici değil. Lockbright'ta TikTok @lockbright alınmış. İsteğe bağlı yedek. |
| Wordbit, Wordbite, Saybit, Speakbit, Brightbit, Sparkbit, Knowbit, Daybit | Türkçede "bit" = bit (parazit). Ayrıca WordBit (Play'de net.wordbit.* kilit ekranı kelime uygulamaları) ve WordBites (Play'de Education) doğrudan rakip. |
| Wordstar, Wordpal, Wordbloom, Wordbridge, Talkbit, Lockstep, Tinyspark, Glowbit, Sunbit, Honeyword, Littlewords, Wordbee | Canlı, aynı ad ABD markası 9/41/42. sınıflarda (örn. WORDPAL: dil öğrenme uygulaması, Dynamic Apps Ltd; WORDBEE: çeviri yazılımı; LITTLEWORDS: 35/42; HONEYWORD: 16/41). |
| Wordseed, Wordmate, Wordspark, Wordnest, Wordbird, Wordstep, Wordhop, Wordwalk, Wordpath, Wordpop, Wordhive, Wordtree, Wordpond, Wordcard, Wordsprout, Wordstack, Wordjar, Wordfox, Wordsnack, Wordtap, Wordnote, Wordspot, Wordsip, Wordring, Wordcup, Wordshelf, Wordpin, Wordglow, Wordnudge | Tam adlı uygulama(lar) var (çoğu Education veya oyun; örn. "Wordseed: Vocabulary Builder", "WordSpark Daily", "Wordspot – Vocabulary Builder", "Wordglow — Vocab Test Prep", "WordNudge: Vocabulary Builder"). |
| Tinywords, Pocketwords, Dailyspark, Dayword, Dayspark, Sparkwords, Helloword, Hiwords, Easywords, Openwords, Heartword, Heartwords, Tapword, Sayhello, Pocketlingo, Pocketteacher, Pocketpal, Smallsteps, Tinystep, Brushup, Byheart | Tam adlı Education/ilgili uygulama var (örn. "Dayword - Learn Chinese Daily", "Spark Words", "HelloWord", "Say Hello - Language Learning", "Pocket Lingo - Learn Languages", "Pocket Teacher"). Byheart: ayrıca canlı BYHEART markası (besin, bebek maması). |
| Dailyglow, Dailystep, Dailybit, Sparkday, Sparkstep, Stepspark, Dayglow, Daybright, Glowday, Glowbook, Glowjar, Glowcard, Glowstep, Glowlock, Tinyglow, Tinybite, Tinytalk, Talkseed, Talklight, Onebite, Helloday, Knownow | Tam adlı uygulama (çoğu sağlık/planlayıcı), ya da Play'de tam ad (Glowstep: "GlowStep"). Tinyglow: ABD'de bebek arabası markası (12. ve 20. sınıf), mağaza temiz ama anlam zayıf. Dailybit: "DayBits" ve Türkçe "bit" sorunu. Helloday: 8 mağaza temiz ama alan adları alınmış, anlam zayıf. |
| Wordkit, Hiword, Heyword, Keepword, Starword, Stepword, Lampwords, Pockettutor, Brightword, Brightwords, Stickywords, Freshwords | Yakın ad ya da tam ad: Wordkite oyunu, HiWord.AI (Education), "Heywords: AI Word Stickers", KeepWords, "StarWords - English Learning", "StepWord - Learn English & AI" (Play), "LAMP Words For Life", PocketTutor, "Sticky Words-Learn Vocabulary" (Play), "Fresh Words: Word game" (Play). |
| Eyeword, Wordeye | EYEWORDS canlı ABD markası (9. ve 16. sınıf, okuma yazma eğitim materyali), neredeyse aynı. Anlam da zayıf. |
| Wordblink, Spotword, Lookword, Wordnow, Nowword, Wordbeam | Mağazalar temiz. Ama "blink/wink/glance" ailesine çok yakın (istemediniz) ya da anlamı belirsiz. |
| Chimeword, Learnchime, Saychime | Mağazalar temiz, .com ve .app boş. Ama "Chime" çok bilinen bir ABD fintech markası (bu turda doğrulamadım) ve Türkçe okunuşu belirsiz. Yedek. |
| Wordbean, Sunword, Smallwords, Seedword, Seedwords, Sproutword, Candleword, Bellword, Bellwords, Nestword, Jarword, Wordnod, Wordhi, Wordtea, Teaword, Teasip, Tinytongue, Tiptongue, Pinword, Wordbrick, Wordpebble, Ahaword, Ahaday, Ringword, Bulbword, Wordding, Wordchime, Earword, Wordheart, Kindwords, Beeword, Sayseed, Wordfriend, Glowtalk, Glowlearn, Glowwords, Glowseed, Lightwords | Mağazalarda tam ad yok ama anlam zayıf, kelime sırası tersten kurulmuş ya da ilgi çekici değil. Ahaword: TikTok @ahaword alınmış. Teaword: TikTok @teaword alınmış, çay hikayesi zayıf. Glowtalk: "Glow - Talk to Glow" ile başlıyor. Teasip: canlı TEASIP markası (içecek). |
| Waitwords, Minutewords, Minwords | Alan adları boş ama tanımlayıcı (descriptive), tescil için zayıf. |
| Moonword, Wordstone, Wordlook, Hellobell, Hilock, Daybell, Morningbell, Dayring, Lockkey, Lockcard, Lockbook, Lockleaf, Daydrop, Daybloom, Tinybell, Tinybird, Tinynest, Littleseed, Brightseed, Glownest, Littlebell, Pocketbell | Tam adlı uygulama ya da canlı ABD markası (WORDLOOK 9. sınıf oyun, WORDSTONE 45, DAYBLOOM 9/42, TINYBIRD 42, TINYNEST 9, LITTLESEED 9/42/16/41, GLOWNEST 9, HELLOBELL 9 çağrı cihazı). Littlebell ve Pocketbell mağazada temiz ama anlam zayıf ve .com/.app alınmış. |

## Bu turda yapamadıklarım / sizin yapmanız gerekenler
1. **TÜRKPATENT, EUIPO, UK IPO, TMview, WIPO taramaları:** Lockglow, Learnbell, Wordbell, Lockbell ve (isterseniz) Wordshine için elle yapılmalı. Özellikle sınıf 9, 41, 42. "BELL" parçası için İngiltere ve AB'de 41. sınıfta (İngilizce eğitimi) kayıt var mı bakın (Bell Educational Trust, aktif mi doğrulanmadı).
2. **App Store Connect ve Play Console'da ad uygunluğu:** hesap gerektirdiği için denemedim.
3. **X (Twitter) kullanıcı adları:** denemedim.
4. **Instagram boş kabuk = tahmin:** gerçekten boş mu, hesap açarken görün (@lockglow, @learnbell).
5. **Park alan adlarının fiyatı:** learnbell.com, wordbell.com, wordshine.com satılık olabilir, fiyat doğrulanmadı. Gerekirse broker sorgusu yapın.
6. **Vietnamca ve Rusça anlam kontrolü:** anadili konuşan biri baksın.
7. **İsim seçiminden sonra:** bir marka vekilinden görüş alın (özellikle LOCKGLOW ve WORDBELL için "English Word Bell" konusu).
