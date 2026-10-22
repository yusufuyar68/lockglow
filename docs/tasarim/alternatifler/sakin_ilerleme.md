# Sakin ilerleme: tasarım keşfi (22 Ekim 2026)

[`sakin_ilerleme.html`](sakin_ilerleme.html) tarayıcıda açılan, tıklanabilir bir taslaktır. Swift kodu değişmedi.

- **Artifact:** https://claude.ai/artifact/7GwVsu35Nh33Ua1TTWJN19 (özel).
- **Taban:** `ios/arayuz-sik` dalı (1e4b4e6). Renk, yazı ve bileşenler `docs/tasarim/README.md` ile aynı.
- **Soru:** Kullanıcı ne öğrendiğini görünce motive olsun. Ama seri (streak) kaygısı, suçluluk ve bağımlılık tasarımı olmasın.

## Kısa cevap

İlerlemeyi **günle değil kelimeyle** ölç. Kelimeler raflarda birikir. Bir gün atlamak hiçbir şeyi sıfırlamaz. Sayı yalnız gerçekten unutulan bir kelimede düşer.

Kutlama, gerçek bir kanıta bağlı olsun. "Harikasın" yerine ne olduğunu söyle: "snack 5. rafa çıktı". Sarı fosfor şeridi yalnız İngilizce kelimede kalır; raflar, çubuklar ve halkalar mürekkep tonlarıdır.

Bu keşif, `raporlar/06_ux_ui_widget_tasarim.md` (bölüm 2.6, "affedici seri") ve `raporlar/10_yol_haritasi_sprint.md` (S3 "Streaks") önerilerinden bilerek ayrılıyor. Gerekçesi aşağıdaki kaynaklarda ve rakip verisinde:
- Vocabulous'un seri ve reklam modeli yorumların %8,3'ünde geçiyor ve bu yorumların puan ortalaması 2,22 (`raporlar/02_review_mining.md`).
- Lingo Widget "No streaks. No guilt." sözünü konum olarak kullanıyor ve 4,74 puanı var (`raporlar/03_rekabet_haritasi.md`).
- Kolay İngilizce'nin yeni widget'ı "günlük ilerleme" gösteriyor (`raporlar/14_guncel_fark_raporu.md`). Lockglow birikimi ve haftalık ritmi göstererek bundan ayrılır.

## Nasıl gezilir

- **Üst çubuk:** beş ekran (*Kitaplık, Bu hafta, Konular, Tekrar, Kilit ekranı*) ve tema (*Sistem / Açık / Koyu*).
- **Sağ panel:** her ekranın durumları, ekranın notu ("Neden böyle?", "Yapmıyoruz", veri, Swift) ve kaynak bağlantıları.
- **Kitaplık'ta ayrıca görünüm seçimi var:**
  - *Raflar* (öneri);
  - *Defter*: kelime raf yükseldikçe kurşun kalemden koyu mürekkebe döner;
  - *Bahçe*: tohumdan ağaca.
- **Doğrudan bağlantılar:** `#kitaplik`, `#hafta`, `#konular`, `#tekrar`, `#kilit`.
- **Örnek veri:** kelimeler, anlamlar ve örnek cümleler `content/drafts/kisisel_v1` kartlarından alındı. Sayılar örnektir: 86 kelime, 22'si yerleşmiş. Konu toplamları 933 kartlık destedendir. Taslak 26 Ekim 2026 pazartesi gününü gösterir.
- Sayfanın altında sekiz ilke ve "Yapmadıklarımız" listesi var.

## Ekranlar

### 1. İlerleme › Kitaplık (raflar)

Leitner'ın beş kutusu beş raf olur. En üstte bir raf daha var:

| Raf | Ad | Ne zaman sorulur | Kod |
|---|---|---|---|
| 1 | Yeni | her gün | `box == 1` |
| 2 | Tanıdık | 2 günde bir | `box == 2` |
| 3 | Güçleniyor | 4 günde bir | `box == 3` |
| 4 | Sağlam | 8 günde bir | `box == 4` |
| 5 | Çok sağlam | 16 günde bir | `box == 5` |
| üst | **Yerleşti** | ayda bir kısa tazeleme | `state == .known && !knownOverride` |
| ayrı kutu | Kendin işaretlediklerin | bir ay sonra bir kez | `state == .known && knownOverride` |

Ayrıntılar:
- Her rafta kelimeler kitap sırtı olarak durur. Rafın tonu Raf 1'de açık gri, "Yerleşti"de mürekkep rengidir.
- Rafa dokununca kelime kapsülleri açılır. Kelimeye dokununca alt sayfa çıkar: kelime, anlamı, rafı ve örnek cümlesi. Fosfor şeridi yalnız buradaki kelimededir.
- "Raflar nasıl çalışır?" kutusu açılınca şu kurallar görünür:
  - aralıklar 1, 2, 4, 8, 16 gün ve sonra ayda bir;
  - Bildim: bir üst raf;
  - Kolay: iki üst raf;
  - Zor: aynı raf, ara yarıya iner;
  - Bilemedim: Raf 1, 10 dakika sonra yine.

  Bunlar `Leitner.swift` ile birebir aynı.
- "Biliyorum" ile işaretlenen kelimeler kesik çizgili ayrı bir kutuda durur, çünkü henüz sınanmadılar. Bu, dürüst bir öz değerlendirmedir: bilmek ile "bildiğini sanmak" ayrı gösterilir.
- **Durumlar:** 86 kelime, ilk hafta (6 kelime), henüz boş.

**Neden "kalıcı" ya da "uzun süreli hafıza" demiyoruz?**
- Bilimde "uzun süreli hafıza" birkaç dakikadan uzun her hatırlamayı kapsar. Yani Raf 1'deki kelime de teknik olarak oradadır.
- Unutma hiç tamamen durmaz (Murre & Dros 2015). En iyi aralık, ne kadar süre hatırlamak istediğine göre değişir (Cepeda ve ark. 2006).
- 16 gün sonra bir kez doğru hatırlamak güçlü bir kanıttır, ama "sonsuza dek öğrendin" demek abartı olur.
- Bu yüzden üst rafın adı **Yerleşti**. Ekranda kısaca nedeni de yazar: "Unutma hiç tamamen durmaz; yerleşen kelimeler de ayda bir sorulur."

Üç görünümün karşılaştırması:

| Görünüm | Artısı | Eksisi |
|---|---|---|
| **Raflar** (öneri) | Kâğıt ve mürekkep kimliğine en uygunu. Kutuyu doğrudan gösterir, öğreticidir. | Çok kelimede raf taşar; bu yüzden 24 kitap ve "+N" gösterilir. |
| Defter | En sade ve en tipografik görünüm. Kelimeler okunur. | Raf bilgisi yalnız tondan anlaşılır, renk körü için zayıf. Alt sayfa şart. |
| Bahçe | Sıcak ve sevimli. | Kelime yazmaz, soyut kalır. Bahçe metaforu "bitki kurur" kalıbına çok yakın. Burada hiçbir şey kurumaz, ama beklenti doğar. |

### 2. İlerleme › Bu hafta (haftalık sakin özet)

Pazartesi yenilenen tek bir sayfa. Son 7 günü kapsar:
- **Giriş cümlesi:** "12 yeni kelimeyle tanıştın. 19 kelime bir üst rafa çıktı ve 3 kelime yerleşti: breakfast, bread, weekend."
- **Tanıştığın 12 kelime:** yana kayan kartlar. Ön yüzde kelime, anlam ve 5 çizgilik raf göstergesi var. Dokununca kart döner: örnek cümle (kelime fosfor çizgili) ve Türkçesi.
- **Seni zorlayanlar:** karışan kelimeler yan yana, kartın kendi ipucuyla. Örnek: borrow / lend için "borrow ≈ borç alırım"; actually için "aktüel değil, aslında".
- **Tahminin ne kadar tuttu?** (kalibrasyon) Kolay, Bildim ve Zor cevaplarının her biri için, o kelime bir sonraki sefer geldiğinde hatırlandı mı? Örnek: 13/14, 26/31, 6/9. Metin bunu yorumlar: "Kendini iyi tanıyorsun" ve "'Zor' da bilinmiş sayılır". Kendini değerlendirmeyi öğreten kart budur.
- **Gelecek hafta:** gün gün planlanan tekrar sayısı. Geçmiş günler hiç yok, yalnız plan var. Alt yazı: "Bir gün atlarsan o günün kelimeleri ertesi güne kayar, kaybolmaz."
- **Durumlar:**
  - dolu hafta;
  - sessiz hafta: "Bu hafta sessiz geçti. Kitaplığın yerinde." ve "Ara vermek öğrendiklerini silmez";
  - ilk hafta.
- **Bildirim:** haftalık bildirim varsayılan olarak kapalı. Kullanıcı açarsa haftada bir bildirim gelir.

### 3. İlerleme › Konular

- Seçilen her konu tek bir çubuktur: koyu kısım bildiğin, açık kısım öğrenilen, boş kısım henüz tanışılmayan kelimeler. Örnek satır: "7 bildiğin · 11 öğreniliyor · 40 yeni".
- Satıra dokununca o konunun kelimeleri görünür.
- Altta seçilmeyen konulardaki tekrarlar ve seviye çubukları (A1/A2/B1) var. Seviye çubukları Ayarlar'daki `LevelProgressRow`'un üç parçalı hâlidir.
- **"Bir konu bitti" durumu:** rozet çıkmaz. Yalnız bir cümle ve benzer bir konu önerisi gelir. Cümle, uygulamadaki mevcut kuralla aynı: "yeni kelimeler artık diğer konulardan geliyor" (`DeckFilter.newWordFeed`).
- Sıralama, yüzde ve karşılaştırma yok.

### 4. Tekrar (giriş ve tur sonu)

Yeni bir sekme açılmıyor. İlerleme ekranı Tekrar sekmesinden açılır.

| Durum | Ne değişiyor |
|---|---|
| Pazartesi girişi | Başlangıç kartının altında iki giriş kartı var: "Geçen haftanın özeti" (pazartesiden çarşambaya kadar) ve "Kitaplığın" (her gün, küçük raf çizimiyle). |
| Tur sonu | Her kelimenin satırına raf değişimi eklenir: "↑ Raf 2 → 3 · 4 gün sonra". Üstte üç kapsül: "7 yükseldi", "2 aynı rafta", "1 baştan". Bilemedim kırmızı gösterilmez; simgesi ve sözüyle görünür. |
| Bir kelime yerleşti | Bir kelime ilk kez en üst rafa çıkınca özetin başına onun kartı gelir: "fresh kitaplığının en üst rafına yerleşti. 16 gün aradan sonra da hatırladın." Fosfor kalem kelimenin altını bir kez çizer (0,7 sn) ve bir kez hafif titreşir. Hareket azaltma açıksa çizgi hazır gelir. |
| Zor geçen tur | Çok "Bilemedim" varsa üstte kısa bir not çıkar: "Zorlanmak işe yarar. Hatırlamaya çalışmak, hemen bakmaktan daha kalıcı iz bırakır." "Şimdi bir daha dene" düğmesi yok, çünkü 10 dakikalık ara bilerek konuldu. |
| Bugünlük tamam | "Harikasın, bugünlük tamam!" yerine "Bugünlük tamam." ve "Şimdi kapatabilirsin." gelir. Ek yeni kelime düğmesi ikincil kalır. |
| Aradan sonra | Gün sayısı ya da "kaçırdın" yazmaz. Metin: "Tekrar hoş geldin. 42 kelime tazelenmeyi bekliyor; hepsini bugün yapman gerekmiyor." Her turda en eski 20 kelime gelir (`reviewSessionLimit`). Bugün bir tur yeter. |

### 5. Kilit ekranı ve ana ekran

- **Yuvarlak widget:** "22 yerleşti". Halka, kitaplığın ne kadarının yerleştiğini gösterir.
- **Dikdörtgen widget:** "Kitaplık" başlığı, altı rafın küçük çubukları ve "86 kelime · 22 yerleşti".
- **Satır içi widget:** tarihin yanında "86 kelime".
- **Ana ekran:** küçük "Kitaplığın" widget'ı.
- **Durumlar:** kelime widget'ı + ilerleme, yalnız ilerleme, her zaman açık, ana ekran.
- **Bilerek yok:**
  - günlük ya da haftalık sayaç (pazartesi sabahı "0" görmek baskı yaratır);
  - varsayılan olarak "bekleyen tekrar" sayısı;
  - uygulama simgesinde kırmızı rozet.

## Öğrenme psikolojisinden kaynaklar

Kırk kaynağın hepsi doğrulandı (2026-10-22): 34 DOI Crossref'te başlık, yıl ve yazarla eşleşti; ötekiler sayfası açılarak doğrulandı. Özetler kısadır ve yayıncı özetine ya da bilinen ana bulguya dayanır.

### Kendini değerlendirme ve üstbiliş (metacognition)

- **Bjork, Dunlosky & Kornell (2013).** Self-Regulated Learning: Beliefs, Techniques, and Illusions. *Annual Review of Psychology* 64. https://doi.org/10.1146/annurev-psych-113011-143823
  - İnsanlar kolay ve akıcı gelen çalışmayı "öğrendim" sanır; zor ama etkili yöntemleri küçümser.
  - → "Kolay" cevabı tek başına karar değil; kalibrasyon kartı sonraki gerçek hatırlamayı gösterir.
- **Koriat & Bjork (2005).** Illusions of Competence in Monitoring One's Knowledge During Study. *JEP: LMC* 31(2). https://doi.org/10.1037/0278-7393.31.2.187
  - Cevap gözün önündeyken verilen "öğrendim" yargısı (JOL) fazla iyimserdir.
  - → "Biliyorum" ile işaretlenen kelimeler ayrı kutuda ve "sınanmadı" diye durur.
- **Kornell & Son (2009).** Learners' choices and beliefs about self-testing. *Memory* 17(5). https://doi.org/10.1080/09658210902832915
  - Öğrenciler kendini sınamayı yalnız "kontrol" sanır; oysa sınamanın kendisi öğretir.
  - → "Zor geçen tur" notu: hatırlamaya çalışmak öğrenmenin kendisidir.
- **Roediger & Karpicke (2006).** Test-Enhanced Learning. *Psychological Science* 17(3). https://doi.org/10.1111/j.1467-9280.2006.01693.x
  - Tekrar okumak kısa vadede iyi görünür; birkaç gün sonra sınanarak çalışan çok daha fazlasını hatırlar.
- **Karpicke & Roediger (2008).** The Critical Importance of Retrieval for Learning. *Science* 319. https://doi.org/10.1126/science.1152408
  - Yabancı dil kelimelerinde, bir kez bilinen kelimeyi yeniden hatırlamak bir hafta sonraki başarıyı çok artırdı; öğrenciler bunu tahmin edemedi.
  - → Bir kez "Bildim" denen kelime raflarda birkaç kez daha gelir; bu, ekranda "neden yine soruluyor?" diye açıklanır.
- **Dunlosky ve ark. (2013).** Improving Students' Learning With Effective Learning Techniques. *PSPI* 14(1). https://doi.org/10.1177/1529100612453266
  - On teknikten yalnız sınama ve aralıklı çalışma "yüksek fayda" aldı; altını çizme ve tekrar okuma düşük kaldı.
- **Bjork & Bjork (2011).** Making things hard on yourself, but in a good way. *Psychology and the Real World*. https://bjorklab.psych.ucla.edu/wp-content/uploads/sites/13/2016/04/EBjork_RBjork_2011.pdf
  - "İstenen zorluklar" çalışma anındaki başarıyı düşürür ama kalıcı öğrenmeyi artırır.
  - → Bilemedim başarısızlık gibi gösterilmez.

### Motivasyon

- **Ryan & Deci (2000).** Self-determination theory. *American Psychologist* 55(1). https://doi.org/10.1037/0003-066X.55.1.68
  - İçsel motivasyon özerklik, yeterlik ve ilişkili olma ile güçlenir.
  - → Hedef ve bildirimi kullanıcı seçer; ilerleme ekranı yeterlik duygusu verir.
- **Deci, Koestner & Ryan (1999).** Extrinsic rewards and intrinsic motivation (meta-analiz). *Psychological Bulletin* 125(6). https://doi.org/10.1037/0033-2909.125.6.627
  - Beklenen, somut ve göreve bağlı ödüller içsel motivasyonu azaltır; bilgi veren geri bildirim artırır.
  - → Puan, jeton ve rozet yok.
- **Bandura (1977).** Self-efficacy. *Psychological Review* 84(2). https://doi.org/10.1037/0033-295X.84.2.191
  - Öz-yeterliğin en güçlü kaynağı kişinin kendi başarı deneyimidir.
  - → Boş cesaretlendirme yerine gerçek kanıt: yerleşen kelimeler.
- **Amabile & Kramer (2011).** The Power of Small Wins. *Harvard Business Review*. https://hbr.org/2011/05/the-power-of-small-wins
  - Anlamlı bir işte küçük ilerleme, motivasyonu en çok artıran olaydı.
- **Dai, Milkman & Riis (2014).** The Fresh Start Effect. *Management Science* 60(10). https://doi.org/10.1287/mnsc.2014.1901
  - Hafta başı gibi zaman işaretleri yeniden başlamayı kolaylaştırır.
  - → Haftalık özet pazartesi yenilenir.
- **Wohl, Pychyl & Bennett (2010).** I forgive myself, now I can study. *Personality and Individual Differences* 48(7). https://doi.org/10.1016/j.paid.2010.01.029
  - Ertelediği için kendini affeden öğrenciler sonraki sınavda daha az erteledi.
  - → Dönüş ekranında suçlama yok.
- **Hattie & Timperley (2007).** The Power of Feedback. *Review of Educational Research* 77(1). https://doi.org/10.3102/003465430298487
  - Dört geri bildirim düzeyinden kişiye yönelik övgü en az etkili olanıdır.
  - → "Harikasın" yerine "snack 5. rafa çıktı".
- **Kluger & DeNisi (1996).** Feedback interventions (meta-analiz). *Psychological Bulletin* 119(2). https://doi.org/10.1037/0033-2909.119.2.254
  - Geri bildirimlerin yaklaşık üçte biri performansı düşürdü; dikkat kişiye kayınca etki kötüleşir.
- **Mueller & Dweck (1998).** Praise for intelligence. *JPSP* 75(1). https://doi.org/10.1037/0022-3514.75.1.33
  - Zekâsı için övülen çocuklar başarısızlıktan sonra daha çabuk vazgeçti.
- **Di Stefano, Gino, Pisano & Staats (2014).** Learning by Thinking: How Reflection Can Spur Progress. HBS Working Paper. https://doi.org/10.2139/ssrn.2414478
  - Pratikten sonra birkaç dakika düşünen kişiler, aynı süreyi ek pratikle geçirenlerden daha iyi yaptı.
  - → Haftalık özet bir yansıtma anıdır.
- **Sailer & Homner (2020).** The Gamification of Learning: a Meta-analysis. *Educational Psychology Review* 32. https://doi.org/10.1007/s10648-019-09498-w
  - Oyunlaştırmanın etkisi küçük-orta ve değişken; kanıt sınırlı.
- **Hanus & Fox (2015).** Assessing the effects of gamification in the classroom. *Computers & Education* 80. https://doi.org/10.1016/j.compedu.2014.08.019
  - Rozet ve liderlik tablosu olan sınıfta zamanla içsel motivasyon ve sınav başarısı daha düşüktü.
- **Kivetz, Urminsky & Zheng (2006).** The Goal-Gradient Hypothesis Resurrected. *Journal of Marketing Research* 43(1). https://doi.org/10.1509/jmkr.43.1.39
  - Hedefe yaklaştıkça çaba artar.
  - → Konu çubukları sınırlı, bitirilebilir hedefler gösterir. Sahte "hazır ilerleme" verilmez.

### Seri (streak) araştırmaları

- **Silverman & Barasch (2023).** On or Off Track: How (Broken) Streaks Affect Consumer Decisions. *Journal of Consumer Research* 49(6). https://doi.org/10.1093/jcr/ucac029
  - Kırık seri görmek davranışı sürdürmeyi azalttı. Etki, davranışın nasıl gösterildiğinden geliyordu. Kişi kırılmayı kendi hatası sayınca etki daha güçlüydü.
  - → Ardışık gün yok; kırılamayan birikim var.
- **Duolingo blogu.** How streaks keep Duolingo learners committed… ve Improving the streak. https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals · https://blog.duolingo.com/improving-the-streak
  - Şirket, kullanıcıların seriyi kaybetmekten güçlü biçimde kaçındığını kendi testleriyle anlatıyor. Bunlar tanıtım yazılarıdır; bağımsız değildir.
  - → Seri kayıptan kaçınma (loss aversion) ile çalışır; bu kaldıraç kullanılmaz.
- **Renfree ve ark. (2016).** Don't Kick the Habit: The Role of Dependency in Habit Formation Apps. *CHI EA*. https://doi.org/10.1145/2851581.2892495
  - Seri ve hatırlatıcılar tekrarı destekledi ama uygulamaya bağımlılık yarattı; uygulama bırakılınca davranış bozuldu.
- **Not:** "seri kaygısı" (streak anxiety) için hakemli bir çalışma bulunamadı. Yukarıdaki iki çalışma en yakın kanıttır.

### Dark pattern'ler ve dikkat tuzakları

- **Gray ve ark. (2018).** The Dark (Patterns) Side of UX Design. *CHI*. https://doi.org/10.1145/3173574.3174108
  - Beş strateji tanımlanır: ısrar (nagging), engelleme, gizleme, arayüz müdahalesi ve zorla eylem.
  - → Bildirim izni bir kez sorulur.
- **Mathur ve ark. (2019).** Dark Patterns at Scale. *PACM HCI (CSCW)*. https://doi.org/10.1145/3359183
  - 11 bin sitede 1.800'den fazla örnek bulundu: sahte aciliyet, utandırarak reddettirme (confirmshaming) gibi.
- **Monge Roffarello, Lukoff & De Russis (2023).** Attention Capture Deceptive Designs. *CHI*. https://doi.org/10.1145/3544548.3580729
  - Dikkat yakalayan 11 zararlı kalıp tanımlandı; aralarında sonsuz kaydırma da var.
  - → "Bugünlük tamam" bir bitiş noktasıdır; otomatik yeni tur yok.
- **Brignull.** Deceptive Patterns. https://www.deceptive.design/types
  - Aldatıcı tasarım türlerinin örnekli listesi. İnceleme için kontrol listesi olarak kullanılabilir.
- **Apple HIG.** Notifications ve Widgets. https://developer.apple.com/design/human-interface-guidelines/notifications · https://developer.apple.com/design/human-interface-guidelines/widgets
  - Aynı şey için birden fazla bildirim gönderilmez. Widget bir bakışta okunur.
- **FTC (2022).** Bringing Dark Patterns to Light. https://www.ftc.gov/system/files/ftc_gov/pdf/P214800%20Dark%20Patterns%20Report%209.14.2022%20-%20FINAL.pdf
- **OECD (2022).** Dark commercial patterns. *OECD Digital Economy Papers* 336. https://doi.org/10.1787/44f5e846-en
- **AB Dijital Hizmetler Yasası, madde 25.** https://eur-lex.europa.eu/eli/reg/2022/2065/oj
  - Kullanıcıyı manipüle eden arayüz yasak. Verilmiş bir seçimi tekrar tekrar sormak da örnekler arasında.
- **T.C. Ticaret Bakanlığı, Reklam Kurulu (2023, 2024).** https://ticaret.gov.tr/haberler/reklam-kurulu-tarafindan-karanlik-ticari-tasarimlar-incelemeye-alindi · https://ticaret.gov.tr/haberler/ticaret-bakanligi-reklam-kurulu-abonelik-hizmetlerine-iliskin-tasarim-tuzaklarina-dikkat-cekiyor
  - Ticari Reklam ve Haksız Ticari Uygulamalar Yönetmeliği'ndeki değişiklikle manipülatif arayüzler "haksız ticari uygulama" sayılıyor. 2024'te abonelik tuzaklarına ceza verildi.
  - Ayrı bir "karanlık örüntüler" kılavuzu bulunamadı; Bakanlık "karanlık ticari tasarım" terimini kullanıyor.
  - → İleride ücretli sürüm olursa: önceden seçili paket, gizli yenileme ve zor iptal olmamalı.

### Aralıklı tekrar ve kelime öğrenme

- **Leitner (1972).** *So lernt man lernen.* Herder. DOI yok: https://en.wikipedia.org/wiki/Leitner_system
- **Kornell (2009).** Spacing is more effective than cramming. *Applied Cognitive Psychology* 23(9). https://doi.org/10.1002/acp.1537
  - Katılımcıların çoğu için aralıklı çalışma daha etkiliydi, ama çoğu tersine inanıyordu.
  - → Günlük hedefi büyütmeye teşvik yok.
- **Cepeda ve ark. (2006).** Distributed practice in verbal recall tasks. *Psychological Bulletin* 132(3). https://doi.org/10.1037/0033-2909.132.3.354
  - En iyi aralık, bilginin ne kadar süre hatırlanması gerektiğine göre büyür.
- **Murre & Dros (2015).** Replication and Analysis of Ebbinghaus' Forgetting Curve. *PLOS ONE* 10(7). https://doi.org/10.1371/journal.pone.0120644
  - Unutma ilk saatlerde hızlı, sonra yavaş ama sürekli devam eder.
- **Settles & Meeder (2016).** A Trainable Spaced Repetition Model for Language Learning. *ACL*. https://doi.org/10.18653/v1/P16-1174
  - Kelime başına "yarı ömür" tahmini, Leitner'dan daha isabetliydi. Yarı ömür uzar ama sonsuz olmaz.
- **Ye, Su & Cao (2022).** A Stochastic Shortest Path Algorithm for Optimizing Spaced Repetition Scheduling. *KDD*. https://doi.org/10.1145/3534678.3539081
  - Açık kaynaklı FSRS algoritmasının temeli. FSRS'i kişiye göre ayarlamak için tekrar geçmişi gerekir (aşağıda "tekrar günlüğü").
- **Nation (2006).** How Large a Vocabulary is Needed For Reading and Listening? *Canadian Modern Language Review* 63(1). https://doi.org/10.3138/cmlr.63.1.59
  - Metnin yaklaşık %98'ini anlamak için okumada 8–9 bin, dinlemede 6–7 bin kelime ailesi gerekir.
  - → "Akıcılığa %X kaldı" gibi büyük hedefler korkutur; ekranlar küçük ve gerçek kazanımları gösterir.

### Sakin teknoloji

- **Weiser & Brown (1996).** The Coming Age of Calm Technology. https://calmtech.com/papers/coming-age-calm-technology.html
  - Sakin teknoloji dikkatin merkezi ile çevresi arasında yumuşakça gidip gelir.
  - → Kilit ekranı widget'ı bilgi verir, dikkat istemez.
- **Case.** Principles of Calm Technology. https://calmtech.com/
  - Teknoloji dikkati olabildiğince az kullanmalı. Ayrıca kitabı (2015): https://calmtech.com/book

## Veri: neler var, neler gerekiyor

### Zaten var (kod değişmeden okunabilir)

| Veri | Nerede | Hangi ekranda |
|---|---|---|
| `state` (`new` / `learning` / `known`) | `Learning/WordProgress.swift` (`progress.json`) | Kitaplık, Konular, widget |
| `box` (0–5) | aynı | Raflar, raf göstergesi |
| `knownOverride` | aynı | "Kendin işaretlediklerin" kutusu |
| `dueAt` | aynı | Gelecek hafta planı, dönüş ekranı, "ne zaman döner" |
| `reviews`, `lapses` | aynı | Zorlanan kelimeler (yalnız toplam; haftalık değil) |
| `exposures`, `lastSeenAt` | aynı | **Kullanılmıyor.** `lastSeenAt` hem görmede hem tekrarda değişiyor. Görme sayısı bir etkinlik ölçüsüdür, öğrenme değil; bilerek gösterilmez. |
| `ProgressCounts` (known, learning, dueToday) | `ReviewPlanner.counts` | Ayarlar'daki kutular |
| `newWordsStudiedToday`, `reviewsDoneToday` | `AppPreferences` (UserDefaults) | Bugünlük tamam. Ertesi gün silinir, geçmiş tutulmaz. |
| `dailyNewWords` | `AppPreferences` | Gelecek hafta planı |
| `topicsOf`, `topics` | `AppModel` (`topicsOf` private) | Konular |
| `levelValue` | `WidgetWord` | Seviyeler (`SettingsView.levelProgress` zaten hesaplıyor) |
| `RoundAnswer` (cevap, `dueAt`) | `ReviewView` (yalnız bellekte) | Tur sonu |
| `nextReviewDate(after:)`, `reviewSessionLimit = 20` | `AppModel` | Tamam ve dönüş ekranı |
| `CardDetail.noteTR`, `mnemonicTR`, `falseFriend` | `CoreModels` | "Seni zorlayanlar" ipuçları |
| `WidgetPlan`, `WidgetState` | `SharedState` (App Group) | Widget yalnız kuyruğu ve `knownIDs`'i görür. **İlerleme sayılarını görmez.** |

### Gerekiyor

| # | Ne | Neden | Not |
|---|---|---|---|
| 1 | `WordProgress.firstReviewedAt: Date?` | "Bu hafta tanıştığın 12 kelime" | Opsiyonel alan, sentezlenmiş `Codable` onu `decodeIfPresent` ile okur; eski `progress.json` bozulmaz. Eski kelimelerde nil kalır (o kelimeler "bu hafta" sayılmaz). |
| 2 | `WordProgress.knownAt: Date?` | "Bu hafta yerleşen 3 kelime", yerleşti anı | `Leitner.advance` mezun ederken ve `markKnown` sırasında yazılır; ikisini `knownOverride` ayırır. |
| 3 | **Tekrar günlüğü** (`review_log.jsonl`): `wordID, at, grade, boxBefore, boxAfter, stateAfter, source` (tekrar / quiz / widget) | Haftalık yükselen sayısı, haftanın zorlananları, kalibrasyon kartı. **Ayrıca FSRS (v1.2) ayarı tekrar geçmişi ister.** | Yalnız ekleme yapılır. `ProgressStore` ile aynı güvenlik kuralları: okunamayan satır atlanır, dosya ezilmez. Kayıt başına ~80 bayt; günde 40 tekrarla yılda ~1,2 MB. CloudKit eşitlemesi için de uygun. |
| 4 | `RoundAnswer.boxBefore`, `boxAfter` | Tur sonundaki "Raf 2 → 3" ve yerleşti anı | Bellekte; `recordReview` eski ve yeni ilerlemeyi zaten biliyor. |
| 5 | App Group'ta `progress_summary.json`: `version, total, settled, selfMarked, shelves[5], updatedAt` | Kilit ekranı ve ana ekran ilerleme widget'ı | Yalnız sayılar, kelime yok. Gizlilik manifesti değişmez (App Group dosyası). |
| 6 | **Davranış düzeltmesi:** "Biliyorum" denmiş kelime tazelemede doğru bilinirse `knownOverride = false` olsun | Yoksa "Kendin işaretlediklerin" kutusu hiç boşalmaz, kanıtlanan kelime "Yerleşti"ye geçmez. | Değişecek yer: `Leitner.advance` (`state == .known` dalı). Test gerekir. |
| 7 | Tercihler: `weeklyDigestNotification` (varsayılan kapalı), widget'ın göstereceği sayı | Bildirim ve widget seçimi | `AppPreferences`'a. |

**Kalibrasyon hesabı:** Haftadaki her Kolay, Bildim ya da Zor kaydı için aynı kelimenin bir sonraki kaydına bakılır. O kayıt `again` değilse kelime "hatırlandı" sayılır. Sonraki tekrarı henüz gelmemiş kelimeler hesaba girmez. Bir cevap türünde 5'ten az kayıt varsa o satır gösterilmez, çünkü küçük sayı yanıltır.

**Gelecek hafta hesabı:** hiç çalışılmazsa her kelimenin `dueAt`'i hangi güne düşer? Gecikmiş kelimeler bugüne yazılır. Bilerek yaklaşık bir hesap: yeni kelimeler ve verilecek cevaplar planı değiştirir.

## Swift'e taşıma önerisi

### Learning (saf, Linux'ta sınanır)

- **`LibraryStats`**
  - `make(words:progress:) -> LibraryStats`.
  - Alanlar: `shelves: [Int]` (Raf 1–5), `settled`, `selfMarked`, `total`.
  - Kitaplık, giriş kartı ve widget özeti aynı sayıyı buradan alır.
- **`TopicProgress`**
  - `rows(words:topicsOf:progress:) -> [TopicProgressRow]`.
  - Satır: `topicID, total, known, learning`.
  - Seviyeler için aynı fonksiyonun `levelValue` sürümü yazılır. Böylece `SettingsView.levelProgress` buraya taşınır.
- **`ReviewRecord` + `ReviewLogStore`**
  - `append(_:)`, `records(from:to:)`.
  - JSON Lines. Bozuk satır atlanır, dosya ezilmez.
- **`WeeklyDigest.make(log:progress:words:weekStart:calendar:)`**
  - Sonuç: `newWords`, `promotedCount`, `settled`, `struggled` (en çok üç), `calibration` (cevap türü başına hatırlanan / toplam), `nextWeek` (7 gün).
  - Test sınırları: hafta başı, yerel saat ve yeni alanları boş olan eski kayıtlar.
- **`Leitner`**
  - `review` ilk tekrarda `firstReviewedAt`'i yazar.
  - `advance` mezun ederken `knownAt`'i yazar.
  - Tazelemede doğru bilinen kelimede `knownOverride = false` olur.
- **`ProgressIngest`**: widget'tan gelen `unknown` olayları günlüğe `source: widget` ile yazılır. Bu yüzden imza bir günlük kaydı listesi de döndürmeli.

### SharedState

- **`ProgressSummary`** (`Codable`, `version`).
- `AppGroupStore`'a `readSummary()` ve `writeSummary(_:)` eklenir.

### Uygulama

- **`ProgressScreen.swift`** (yeni): Kitaplık, Bu hafta ve Konular'ı segmentli olarak toplar. Tekrar'ın `NavigationStack`'ine itilir.
- **`LibraryView`**:
  - raf satırı bir `Button`'dır;
  - kitap sırtları `Canvas` ya da `HStack` ile çizilir ve `accessibilityHidden` olur; satırın etiketi "Raf 3, Güçleniyor: 14 kelime";
  - AX yazı boyutlarında sırtlar gizlenir, satır yalnız ad ve sayı olur;
  - kapsül `WordDetailView`'a gider.
- **`WeeklyDigestView`**: kartlar `ScrollView(.horizontal)` ve `.scrollTargetBehavior(.viewAligned)` ile yapılır. Dönen kart `accessibilityAction` ile de çalışır.
- **`TopicProgressView`**: `LevelProgressRow`'un üç parçalı hâli.
- **`ReviewView`**:
  - `RoundAnswer`'a iki alan, `SummaryRow`'a raf satırı;
  - üstte kapsüller (`Label` + SF Symbol `arrow.up`, `equal`, `arrow.counterclockwise`);
  - yerleşti kartı için `HeadwordBand` + `.scaleEffect(x:anchor: .leading)` animasyonu ve `sensoryFeedback(.success)`; `accessibilityReduceMotion` açıkken animasyon yok;
  - zor tur notu, tamam metni, dönüş metni;
  - başlangıçta iki `NavigationLink` kartı.
- **`AppModel`**:
  - `topicsOf` için okuma fonksiyonu;
  - `recordReview` günlüğe yazar;
  - `persistProgress` sonrası özet dosyası yazılır (tur sonunda ve arka plana geçerken), sonra `WidgetCenter.shared.reloadTimelines(ofKind:)`.
- **`SettingsView`**: "İlerleme" bölümündeki üç kutu, İlerleme ekranına giden tek satır olur. "Haftalık özet bildirimi" anahtarı eklenir (varsayılan kapalı).
- **`ReminderScheduler`**: isteğe bağlı haftalık bildirim (pazartesi, hatırlatma saatinde). Metin sayı sıralamaz ve seri, ünlem ya da emoji içermez (ui2-bildirim'in kuralı).

### Widget

- Yeni tür **`ProgressWidget`** (`kind: "LockglowProgress"`).
- Aileler: `accessoryCircular` (`Gauge`, `.accessoryCircularCapacity`), `accessoryRectangular`, `accessoryInline` ve `systemSmall`.
- Zaman çizelgesi `.never`; uygulama yeniden yükler. Kilit ekranında renk yoktur, `.widgetAccentable()` yalnız sayıda olur.
- `WidgetSnapshotTests`'e üç görüntü eklenir.

### Testler

Linux'ta çalışan Swift testleri yazılır:
- `LibraryStats`, `TopicProgress` ve `WeeklyDigest` (hafta sınırı, boş günlük, eski kayıt);
- `ReviewLogStore` (ekleme, bozuk satır);
- `Leitner` (`knownOverride` düzeltmesi, `firstReviewedAt`, `knownAt`);
- `WordProgress`: yeni alanları olmayan eski JSON'un okunması.

### Başka oturumlarla çakışma

Bu öneri, şu an çalışan ui2-* oturumlarının dosyalarına dokunuyor. Onlar birleştikten sonra yapılmalı:

| Oturum | Dosyalar |
|---|---|
| ui2-tekrar | `ReviewView.swift` |
| ui2-ayarlar | `SettingsView.swift` |
| ui2-widget | `Widgets/` |
| ui2-bildirim | `ReminderScheduler.swift`, `ReminderPlanner.swift` |

Learning ve SharedState'teki yeni tipler (1. ve 3. adım) çakışmadan hemen yazılabilir.

## Öncelik sırası

| Sıra | İş | Büyüklük | Bağımlılık | Neden bu sırada |
|---|---|---|---|---|
| 1 | **Veri temeli:** `firstReviewedAt`, `knownAt`, tekrar günlüğü, `knownOverride` düzeltmesi | S–M | yok | Görünmez ama geçmiş ancak gönderildiği günden itibaren birikir. Bugün başlamazsa haftalık özet ve kalibrasyon haftalarca boş kalır. FSRS de bunu ister. |
| 2 | **Tur sonu:** raf değişimi, "yerleşti" anı, zor tur notu; tamam ve dönüş metinleri | S | ui2-tekrar birleşmeli | En sık görülen ekran. Yeni veri gerekmez (boxBefore ve boxAfter bellekte). |
| 3 | **Kitaplık (raflar)** + "Raflar nasıl çalışır?" + Tekrar'daki giriş kartı | M | `LibraryStats` | Uygulamanın nasıl öğrettiğini gösterir. Yeni veri gerekmez. |
| 4 | **Konular** + seviyeler; Ayarlar'daki kutular buraya bağlanır | S | ui2-ayarlar birleşmeli | Veri hazır. |
| 5 | **Haftalık özet** (kalibrasyon kartı olmadan) | M | 1, en az bir haftalık günlük | Pazartesi ritmi. |
| 6 | **Kilit ekranı ilerleme widget'ı** | M | 5. maddedeki özet dosyası, ui2-widget birleşmeli | Yeni widget türü. Kilit ekranında bir yer kaplar; kullanıcı ister. |
| 7 | **Kalibrasyon kartı** | S | 1 ve 2–3 haftalık günlük | Öğretici ama veri ister. |
| 8 | Haftalık bildirim (isteğe bağlı, varsayılan kapalı) | S | 5 | En son; bildirimi en az kullanmak ilke. |
| — | Defter ve Bahçe görünümleri | — | — | Seçenek olarak bırakıldı; öneri Raflar. |

## En iyi 5 fikir

1. **Kitaplık rafları.** Leitner kutuları şu rafları oluşturur: Yeni → Tanıdık → Güçleniyor → Sağlam → Çok sağlam → Yerleşti. İlerleme günle değil kelimeyle ölçülür; ara versen de raflar boşalmaz. "Kalıcı" denmez, dürüst ad "Yerleşti"dir.
2. **Tur sonunda kanıt, övgü değil.** Her kelime için "Raf 2 → 3 · 4 gün sonra" yazar. Bir kelime en üst rafa ilk kez çıkınca fosfor kalem altını bir kez çizer. Konfeti ve puan yok.
3. **"Tahminin ne kadar tuttu?"** Kolay, Bildim ve Zor dediğin kelimeleri sonra gerçekten hatırladın mı? Öz değerlendirmeyi öğretir ve "Zor da bilinmiş sayılır" fikrini veriyle gösterir.
4. **Pazartesi sakin özeti.** İçinde çevrilen 12 kelime kartı, karışan kelimeler kendi ipuçlarıyla yan yana ve gelecek haftanın planı var. Geçmiş günler gösterilmez. Sessiz haftada "Kitaplığın yerinde" der.
5. **Suçlamasız dönüş ve sakin kilit ekranı.** Gün sayısı yok; birikmiş tekrar küçük turlara bölünür. Kilit ekranında yalnız biriken sayı durur ("22 yerleşti"). "Biliyorum" dediğin kelimeler ayrı ve "sınanmadı" diye gösterilir.

## Açık sorular

- İlerleme Tekrar'dan mı açılsın (öneri), yoksa Sözlük sekmesi "Kelimelerim / Sözlük" diye mi bölünsün?
- Haftalık özet takvim haftası mı (pazartesi–pazar, öneri), yoksa her gün kayan son 7 gün mü?
- Yerleşti anında titreşim olsun mu? Bazı kullanıcılar titreşimi kapatıyor; sistem ayarına uyulur.
- Kilit ekranında yuvarlak widget'ın halkası kitaplığın tamamına göre mi (öneri), yoksa seçilen konulara göre mi?
- Cihazda denenmeli:
  - kitap sırtlarının küçük ekranda (iPhone SE) okunması;
  - kilit ekranı halkasının "her zaman açık" ekranda görünmesi;
  - kalibrasyon kartının birkaç haftalık gerçek veriyle anlamlı olup olmadığı.
