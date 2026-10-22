# Lockglow Gece / OLED: alternatif tasarım yönü (22 Ekim 2026)

[`gece_oled.html`](gece_oled.html) tarayıcıda açılan, tıklanabilir bir taslak. Artifact (özel): https://claude.ai/artifact/PVNkSgJagU2M411UiTwRVS. Bu yalnız bir öneri:
- Swift kodu değişmedi.
- Cihazda ya da Xcode'da denenmedi.
- Karşılaştırma `ios/arayuz-sik` dalındaki tasarıma göre: [`../README.md`](../README.md), [`../lockglow_ui_mockup.html`](../lockglow_ui_mockup.html), `ios/Shared/LockglowTheme.swift`.

**Kullanım durumu:** Kullanıcı kelimelerin çoğunu akşam görüyor: yatakta, ışık kapalı, ekran kısık, çoğu zaman kilitli ekranda. Bu tasarım o an için. Gündüz tasarımı ("kâğıt ve mürekkep") aynen kalır.

**Amaç:**
- göz yormamak;
- uykuyu olabildiğince az bozmak;
- kısık ışıkta da rahat okunmak.

**Bu belgedeki terimler:**
- **mockup:** tıklanabilir taslak ekranlar. Gerçek uygulama değil.
- **token:** tasarımdaki bir rengin adı (ör. `ink` = ana yazı rengi).
- **ipRGC:** gözde, görmeye değil iç saate (uyku saatine) çalışan hücreler. İçlerinde **melanopsin** adlı ışık algılayıcı var.
- **melanopik:** bu hücreleri uyaran ışık. **Melanopik EDI** (lx) bu uyaranın ölçüsü: "aynı etkiyi veren gün ışığı kaç lüks olurdu?"
- **opsin şablonu, Govardovskii şablonu:** ışık algılayıcının hangi renge ne kadar duyarlı olduğunu gösteren hazır eğri.
- **R² (r²):** eğrinin ölçümlere ne kadar uyduğu; 1'e yakınsa iyi uyar.
- **halation:** açık renk yazının koyu zeminde dağılıp bulanık görünmesi.
- **vibrant:** iOS'un kilitli ekran widget'larını tek renkte çizme biçimi.
- **trait:** iOS'ta ekranın o anki özelliği (koyu mod, yazı boyutu gibi). Renkler buna göre seçilir.
- **kapsül, plaka, iz:** kapsül = yuvarlak uçlu düğme ya da kutu; plaka = kilitli ekranda widget'ın arkasındaki yarı saydam zemin; iz = ilerleme çubuğunun boş kısmı.

## Mockup nasıl gezilir

- **Üst çubuktaki ekranlar:**
  - sistem yüzeyleri: Kilitli ekran, Her zaman açık, StandBy;
  - uygulama: Akış, Tekrar, Quiz, Sözlük, Bu gece bitti;
  - kartlardaki mikrofon düğmesi Söyle sayfasını açar (Dinliyorum → Kontrol ediliyor → Doğru! / Neredeyse! / Bir daha dene / Seni duyamadım; sonuçlar sırayla örnek olarak gelir);
  - Widget'lar ve Ayarlar.
- **Sağ paneldeki kontroller:**
  - **Ton:** Kehribar (önerilen), Soluk fosfor, Mevcut koyu.
  - **Yan yana:** aynı ekranı mevcut koyu temanın renkleriyle ikinci bir telefonda gösterir.
  - **Ekran parlaklığı (taklit):** ışığı gerçek ekran gibi azaltır, %5'e kadar.
  - **Night Shift taklidi.**
  - **Geçişler:** yavaş solma ya da hareketsiz.
  - **Cihaz:** iPhone (390 × 844) ya da iPhone SE (375 × 667).
  - **Yazı boyutu (Dynamic Type):** beş kademe. Erişilebilirlik boyutunda kart kısalmaz, kayar; kelime sığmazsa %60'a kadar küçülür.
  - Ekrana özel seçenekler: saat rengi, duvar kâğıdı, StandBy kırmızı modu, widget görünümü.
  - Her ekranın tasarım notu ve Swift notu.
- **Alttaki tablo:** bütün tokenlar. Kontrast ve "mavi uyaran" değerleri sayfada canlı hesaplanır, bu belgedeki sayılarla aynıdır.
- **Doğrudan bağlantılar:** `#kilit`, `#aod`, `#standby`, `#akis`, `#tekrar`, `#quiz`, `#sozluk`, `#bitti`, `#widget`, `#ayarlar`.
- **Kartlar:** `content/drafts/kisisel_v1` içinden olduğu gibi alındı. Gece konulu kelimeler seçildi: bedtime, pillow, dream, tonight, wake up, nap, sleep in, blanket, midnight, alarm, calm down, tired, quiet. "Yarın 08:30", "Hatırlatma: 20:00" gibi değerler örnektir.

## En iyi 5 fikir

1. **Işık bütçesi: büyük alanlar karanlık.**
   - Zemin gerçek siyah (`#000`). Kartın dolgusu yok, yalnız ince kenar çizgisi var.
   - Ana düğme dolu değil ve sarı değil: %12 mürekkep zemin, 2 pt parlak mürekkep kenar, kalın yazı. Kenar onu gri kenarlı ikincil düğmelerden ayırır. Sarı yalnız kelimede kalır.
   - Mevcut koyu temada en parlak alan dolu sarı ana düğme: bağıl parlaklık L = %71. Gece hâlinde düğmenin ortalaması yaklaşık %6–9.
2. **Kehribar mürekkep ve şerit.**
   - Mürekkep `#E2C8A0`: siyahta 13,0:1. Mevcut koyu temada 17,4:1.
   - Aynı ekran parlaklığında beyaza göre melanopik ("mavi") uyaran yaklaşık %43. Mevcut mürekkep %88.
   - Şerit `#FFB547`: 12,0:1, uyaran %21. Mevcut sarı şerit %30.
   - Şeritteki ışıma kalkar.
3. **"Bu gece 5 kelime" durma noktası.**
   - Akış sonsuz değil: üstte "Bu gece 2 / 5", sonunda "Bu geceki 5 kelime tamam. İyi uykular."
   - "5 kelime daha" var ama küçük ve sessiz. Varsayılan yol uyumak.
4. **Her zaman açık ve StandBy için ayrı düzen.**
   - `isLuminanceReduced` iken dikdörtgen widget'ta yalnız kelime ve anlam kalır. Plaka yok, şerit çok ince bir çizgiye (1 pt) iner.
   - StandBy'da sistem karanlıkta her şeyi kırmızı çizer. Hiyerarşi bu yüzden yalnız boyut, kalınlık ve parlaklıkla kurulur.
5. **Sistemin yapabildiğini öğret, kendin taklit etme.**
   - Kilitli ekran widget'larının rengini uygulama seçemez. Ayarlar'da tek adımlık ipucu: "Kilitli ekranı kehribar yap."
   - İkinci ipucu: Beyaz Noktayı Azalt kısayolu (yan tuşa üç kez bas).
   - Uygulama ekran parlaklığını kendisi değiştirmez.

Ek fikirler:
- Kartlar kaymaz, yavaşça solar (420 ms + 420 ms). "Hareketsiz" seçilince geçiş yok.
- Doğru/yanlış renkleri yumuşak ama okunur (siyahta 10–11:1). Yanlış şık kesik çizgili; renk tek başına anlam taşımaz.
- Gece tonu varsayılan olarak yalnız telefon koyu moddayken açılır (Apple'ın "uygulamaya özel görünüm ayarı koyma" önerisine uygun).

## Bilim: göz, gece okuma ve mavi ışık

Her maddenin kaynağı yanında. Notlar:
- "(özet)": kaynağın yalnız özetini (abstract) ya da arama sonucunu okudum, tam metnini okumadım. Makale özetleri [Europe PMC](https://europepmc.org/) üzerinden kontrol edildi (22 Ekim 2026).
- Sayıların çoğu benim aktarmam, kelimesi kelimesine alıntı değil.

### 1. Uyku saatini hangi ışık etkiler?

- Gözde, görmeye değil iç saate çalışan bir hücre türü var: **melanopsin** taşıyan ipRGC'ler.
  - İnsan melanopsini yaklaşık **480 nm**'de (mavi-camgöbeği) en duyarlı.
  - Göz merceği süzdükten sonra tepe yaklaşık **490 nm**'ye kayar (32 yaşında bir göz için).
  - Kaynak: [Brown ve ark., PLoS Biology 2022](https://pmc.ncbi.nlm.nih.gov/articles/PMC8929548/); ölçüm sistemi [CIE S 026:2018](https://www.cie.co.at/publications/cie-system-metrology-optical-radiation-iprgc-influenced-responses-light-0).
- Melatonini en çok baskılayan bölge kısa dalga boyları:
  - [Brainard ve ark. 2001, J Neurosci](https://pmc.ncbi.nlm.nih.gov/articles/PMC6763155): 72 kişi, 627 gece testi, 420–600 nm. En etkili bölge 446–477 nm; bir opsin şablonuna uyuyor (R² = 0,91) (özet).
  - [Thapan, Arendt, Skene 2001, J Physiol](https://pmc.ncbi.nlm.nih.gov/articles/PMC2278766/): 22 kişi, 424–548 nm arası altı dalga boyu. En iyi uyan eğrinin tepesi 459 nm (r² = 0,74). Çubuk ve koni hücreleri veriye uymuyor (r² < 0,1) (özet).
  - Kırmızı ve kehribar (uzun dalga) bu eğrinin çok düşük ucunda kalır: etkisi az ama sıfır değil.
- **Uzman önerisi** ([Brown 2022](https://pmc.ncbi.nlm.nih.gov/articles/PMC8929548/)):
  - yatmadan en az 3 saat önce gözdeki ışık en çok **10 lx melanopik EDI** olmalı;
  - uyku ortamı en çok **1 lx**.
  - Gringras 2015'in ölçtüğü değerler (aşağıda) bu sınırın üstünde. Birimler birebir aynı değil (Gringras "melanopik lux" ölçüyor, Brown "melanopik EDI" diyor; ölçüm karanlık odada ve otomatik parlaklıkta), ama yön aynı. Yani gece ekranı "az ışık" ilkesiyle tasarlanmalı.

### 2. Gece ekranı uykuyu ne kadar bozuyor?

- [Chang, Aeschbach, Duffy, Czeisler 2015, PNAS](https://pmc.ncbi.nlm.nih.gov/articles/PMC4313820): 12 kişi, beş akşam boyunca 4 saat iPad'de ya da basılı kitapta okudu. Aşağıdaki sayılar tam metinden alındı; 22 Ekim'de ikinci kez kontrol edilemedi (özette sayı yok). iPad ile:
  - melatonin baskılanması %55 (kitapta %19, anlamlı değil);
  - uykuya dalma süresi 25,7 dakika (kitapta 15,8);
  - melatonin başlangıcı 1,5 saatten fazla gecikti;
  - sabah uyanıklık daha düşüktü.
  - Kısıt: tam parlaklıkta, 4 saat okuma. [Zeitzer'in yorumu](https://pmc.ncbi.nlm.nih.gov/articles/PMC4313797/): gündüz yeterli ışık alanlarda etki daha küçük olabilir (özet).
- **Etkiyi parlaklık ve melanopik doz belirler:**
  - [Schöllhorn ve ark. 2023, Communications Biology](https://pmc.ncbi.nlm.nih.gov/articles/PMC9974389): 72 sağlıklı erkek (kadınlar yok). Parlaklığı ve rengi eşit, melanopik içeriği farklı ekranlar denendi (yaklaşık 5–150 lx melanopik EDI).
    - Etki doza bağlı: en düşükten en yükseğe uykuya dalma süresi yaklaşık %50 uzadı, melatonin yaklaşık %50 azaldı.
    - Yazarlar melatonin farklarını görece küçük buluyor.
  - [Gringras ve ark. 2015, Frontiers in Public Health](https://www.frontiersin.org/articles/10.3389/fpubh.2015.00233/full): yazı gösterirken melanopik lux iPad Air'de 302, iPhone 5s'te 55, Kindle Paperwhite'ta 35. Bütün cihazların tepe ışığı 445–455 nm'de. Büyük ve parlak ekran daha çok melanopik ışık verir.
- **Night Shift tek başına yetmeyebilir:**
  - [Nagare, Plitnick, Figueiro, Lighting Research & Technology 51(3), 2019](https://pmc.ncbi.nlm.nih.gov/articles/PMC6561503) (çevrimiçi 2018): iPad'de düşük ve yüksek renk sıcaklıklı iki Night Shift ayarı arasında melatonin baskılanması farkı yok. Yazarlara göre parlaklığı değiştirmeden yalnız tayfı değiştirmek "yetersiz olabilir" (özet).
  - Duraccio ve ark., "Does iPhone night shift mitigate negative effects of smartphone use on sleep outcomes in emerging adults?", *Sleep Health* 7(4):478–484, 2021, [doi:10.1016/j.sleh.2021.03.005](https://doi.org/10.1016/j.sleh.2021.03.005): 167 kişi, 18–24 yaş, yatmadan önceki bir saatte yedi gece. Night Shift açık, kapalı ve telefonsuz gruplar arasında anlamlı uyku farkı yok. Gecede 6,8 saatten çok uyuyanlarda en iyi sonuç telefonsuz grupta (özet).
- **Kehribar gözlük** ([Burkhart & Phelps 2009](https://pubmed.ncbi.nlm.nih.gov/20030543/)): uyku kalitesi kendi beyanına göre arttı. Zayıf kanıt: 20 kişi, melatonin ölçülmedi.

**Tasarım sonucu:**
- Renk sıcaklığı yardımcı olur ama asıl kaldıraç **toplam ışık**: parlaklık × yanan alan.
- Bu yüzden önce büyük alanları karartıyoruz (siyah zemin, dolgusuz kart, dolgusuz düğme). Sonra mürekkebi ısıtıyoruz.
- Uygulamanın tek başına uykuyu "koruduğunu" söylemeyiz. Sadece daha az ışık veririz.

### 3. Karanlıkta açık yazı mı, aydınlıkta koyu yazı mı?

- Koyu yazı açık zeminde (pozitif polarite) genelde daha iyi okunur:
  - [Piepenbrock, Mayr, Mund, Buchner 2013, Ergonomics](https://documentacion.fundacionmapfre.org/documentacion/bib/143702.do): genç ve yaşlı okurlarda (özet).
  - [Piepenbrock, Mayr, Buchner 2014](https://documentacion.fundacionmapfre.org/documentacion/publico/en/bib/150136.do): nedeni, parlak ekranda göz bebeğinin küçülmesi ve görüntünün keskinleşmesi (özet).
  - [Buchner, Mayr, Brandt 2009](https://madoc.bib.uni-mannheim.de/26118/): üstünlük "yüksek ekran parlaklığından" geliyor (özet).
  - Benim çıkarımım: kısık ışıkta bu üstünlük küçülür. Gece beyaz zemin ise odayı aydınlatır.
- **Sonuç:** gece koyu zemin doğru, ama okunurluğu başka yoldan desteklemek gerekir:
  - yazılar ince değil;
  - Türkçe anlam 28 pt yarı kalın;
  - İngilizce kelime serif kalın;
  - satır aralığı geniş.
- **Saf beyaz yazı siyahta "taşar":** astigmatı olan okurlarda harfler bulanık görünür (halation). Kaynak: [Level Access](https://www.levelaccess.com/blog/accessibility-for-people-with-astigmatism/). Bu zayıf bir kaynak (sektör yazısı, hakemli değil), oranlar belirsiz.
  - Yine de öneri aynı yönde: saf beyaz (#FFF, 21:1) yerine kırık beyaz ya da kehribar, 12–15:1.
- [Apple HIG, Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode):
  - en az 4,5:1, küçük yazıda tercihen 7:1;
  - "koyu zemin, parlak ön plan".

### 4. OLED'e özgü

- **Pil:** Siyah piksel kapalıdır. Ama tasarruf parlaklığa bağlı ([Purdue 2021](https://www.purdue.edu/newsroom/releases/2021/Q3/dark-mode-may-not-save-your-phones-battery-life-as-much-as-you-think,-but-there-are-a-few-silver-linings.html), Dash & Hu, MobiSys 2021):
  - %30–50 parlaklıkta koyu mod yalnız %3–9 tasarruf eder;
  - %100'de %39–47.
  - Gece kısık ekranda pil kazancı küçüktür. Asıl kazanç gözde.
- **"Siyah sürünmesi" (black smear):** Tam kapalı pikseller geç yandığı için kaydırırken iz kalabilir. Bazı tasarımcılar bu yüzden "siyah görünen çok koyu gri" kullanıyor ([MacStories, LookUp](https://www.macstories.net/linked/designing-a-dark-theme-for-oled-iphones/)).
  - Bu anekdot düzeyinde; ölçülmüş üretici verisi bulamadım.
  - Öneri: sayfa `#000`, kayan listelerin satırları `surface` (`#0D0B09`, piksel hafif açık). Cihazda bakılmalı.

### 5. Apple'ın sistem yüzeyleri

- **Her zaman açık:**
  - iPhone 14 Pro ve sonrası Pro modellerde ve iPhone 17'de varsayılan açık; iPhone Air'de varsayılan kapalı. Kilitlenince ekran kararır, yenileme 1 Hz'e kadar iner ([Apple Destek](https://support.apple.com/en-us/109351)).
  - Uyku odağında (Sleep Focus) kapanabilir (özet: [iPhone Kullanma Kılavuzu](https://support.apple.com/guide/iphone/keep-the-iphone-display-on-longer-iph7117338a8/ios)).
- **`isLuminanceReduced`:** [SwiftUI belgesi](https://developer.apple.com/documentation/swiftui/environmentvalues/isluminancereduced). Apple önerisi: görünümün parlaklığını düşür, şekilleri doldurmak yerine çiz, daha az parlak renk seç.
  - WidgetKit, kilitli ekran widget'larında Her zaman açık için bu değişkeni kullanmayı söylüyor ([Preparing widgets…](https://developer.apple.com/documentation/widgetkit/preparing-widgets-for-additional-contexts-and-appearances)).
- **Kilitli ekran rengi:** Kilitli ekran widget'ları `vibrant` modda tek renk çizilir ([WidgetRenderingMode](https://developer.apple.com/documentation/widgetkit/widgetrenderingmode)). Apple: kullanıcı kilitli ekranı renkli bir tona boyayabilir.
  - Yani rengi uygulama değil kullanıcı seçer. İpucu fikri buradan.
- **StandBy:**
  - WidgetKit `systemSmall` widget'ı ekranın yarısına büyütür ve zeminini kaldırır ([StandBy ve CarPlay desteği](https://developer.apple.com/tutorials/data/documentation/widgetkit/adding-standby-and-carplay-support-to-your-widget.md), [Doğru widget zemini](https://developer.apple.com/documentation/widgetkit/displaying-the-right-widget-background.md)).
  - Karanlıkta "WidgetKit … widget'lar için kırmızı ton kullanır" ([Preparing widgets…](https://developer.apple.com/documentation/widgetkit/preparing-widgets-for-additional-contexts-and-appearances)). Apple'ın kullanıcı kılavuzu da Gece Modu'nun az ışıkta kırmızı ton verdiğini söylüyor ([Apple Destek, StandBy](https://support.apple.com/guide/iphone/iph878d77632/ios), özet). Kapatma yolu (Ayarlar → StandBy → Gece Modu) üçüncü taraf rehberlerden ([Guiding Tech](https://www.guidingtech.com/why-is-my-standby-red-on-iphone/), özet).
  - `containerBackgroundRemovable(false)` widget'ı StandBy galerisinden çıkarır. Lockglow'da bunu yapmamalı.
- **Night Shift:** renkleri "spektrumun sıcak ucuna" kaydırır, varsayılan gün batımından gün doğumuna. Uyku hakkında iddiası yok ([Apple Destek](https://support.apple.com/118583)).
- **Beyaz Noktayı Azalt:** parlak renklerin yoğunluğunu azaltır ([Apple Destek](https://support.apple.com/en-us/111773)). Erişilebilirlik Kısayolu'na bağlanabilir.
- **Hareket:**
  - [HIG Motion](https://developer.apple.com/design/human-interface-guidelines/motion): gereksiz animasyon dikkat dağıtır; hareket isteğe bağlı olmalı.
  - [`accessibilityReduceMotion`](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion).
  - [WCAG 2.3.3](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html): etkileşimle gelen hareket kapatılabilmeli.
  - Animasyonun uykuyu bozduğunu gösteren hakemli bir çalışma bulamadım. Gerekçemiz dikkat ve sakinlik.

### 6. Kontrast nasıl hesaplandı?

- **Formül:** WCAG 2 ([W3C](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)):
  - sRGB doğrusallaştırılır;
  - L = 0,2126 R + 0,7152 G + 0,0722 B;
  - oran = (L1 + 0,05) / (L2 + 0,05);
  - yazı için 4,5:1, büyük yazı için 3:1, AAA için 7:1.
- **APCA:** ([Myndex](https://github.com/Myndex/apca-introduction)) WCAG 2'nin koyu modda zayıf kaldığını söyler. Ama standart değil ve tartışmalı. Burada WCAG 2 kullanıldı.

## Önerilen renk tokenları

"Mavi" sütunu, aynı ekran parlaklığında o rengin melanopik uyaranının beyaza oranıdır (beyaz = %100). Model aşağıda.

### Kehribar (önerilen)

| Token | Değer | Siyah (`bg`) | Kapsül (`surface2`) | Mavi | Kullanım |
|---|---|---|---|---|---|
| `bg` | `#000000` | — | — | — | Sayfa |
| `surface` | `#0D0B09` (L %0,34) | — | — | — | Gruplu liste, quiz cümlesi, kayan satırlar |
| `surface2` | `#17130F` (L %0,68) | — | — | — | Kapsül, Dikkat kutusu |
| `surface3` | `#231D17` | — | — | — | İz (ilerleme, anahtar) |
| `line` / `lineStrong` | `#241C13` / `#473827` | 1,3 / 1,9 | — | — | Kart kenarı / düğme kenarı |
| `ink` | `#E2C8A0` | **13,0** | 11,4 | %43 | Kelime, Türkçe anlam, örnek |
| `ink2` | `#BFA27C` | **8,7** | 7,6 | %26 | Tanım, çeviri, IPA |
| `ink3` | `#957D63` | **5,4** | 4,7 | %15 | Yardımcı yazı, sayaç |
| `band` | `#FFB547` | 12,0 | 10,5 | %21 | Yalnız şerit ve örnekteki kelimenin alt çizgisi |
| `primaryBg` / `primaryInk` | `#1B1813` / `#E2C8A0` (kenar: `ink`, 2 pt) | yazı/zemin **11,0**; kenar/siyah 13,0; kenar/`lineStrong` 7,0 | — | %43 | Ana düğme (tonal mürekkep + parlak kenar, kalın yazı; sarı değil) |
| `good` | `#A7C98A` | 11,4 | 10,0 | %37 | Doğru (simge + kelime) |
| `bad` | `#FF9580` | 9,9 | 8,7 | %25 | Yanlış (simge + kelime) |
| `caution` | `#E6CB72` | 13,1 | 11,6 | %32 | Yalnız Dikkat üçgeni |
| `goodTint` / `badTint` | %12 | — | — | — | Geri bildirim kutusu |
| `bandGlow`, `primaryGlow` | yok | — | — | — | Gece ışıma yok |

**Yüksek kontrast (Increase Contrast) önerisi:**
- `ink` `#F2DEBE` (16,0:1);
- `ink2` `#D3BA97` (11,2:1);
- `ink3` `#B39C7F` (8,0:1);
- `band` `#FFC266` (13,2:1).

### Soluk fosfor (markaya yakın seçenek)

- Zeminler: `bg` `#000000`, `surface` `#0C0C0A`, `surface2` `#161613`.
- Mürekkepler:
  - `ink` `#DAD7C6`: 14,5:1, mavi %61;
  - `ink2` `#B4B2A3`: 9,8:1, %39;
  - `ink3` `#8E8C7E`: 6,2:1 (kapsülde 5,4), %23.
- `band` `#D6DC6E`: 14,3:1, mavi %36. Lockglow'un limon sarısının soluk hâli.
- Ana düğme: `#1A1A18` zemin üstünde `#DAD7C6` kalın yazı (12,0:1), 2 pt `#DAD7C6` kenar.
- Durum renkleri: `good` `#9FD0A0`, `bad` `#FF9A8C`, `caution` `#F2B37A`.
- Kehribardan daha çok mavi verir, ama markayı daha iyi korur.

### Mevcut koyu tema (karşılaştırma)

- `bg` `#0D0F11` (L %0,47).
- Kart `surface` `#191C20` (L %1,14).
- Mürekkepler:
  - `ink` `#F3F4F0`: 17,4:1, mavi %88;
  - `ink2`: 10,1:1;
  - `ink3`: 6,3:1 (kapsülde 4,9).
- `band` `#E9E040`: 13,9:1, mavi %30, ışımalı.
- Ana düğme dolu sarı: L %71. Ekranda yazıdan sonra en çok ışık veren alan bu.

### "Mavi" sütununun modeli (kaba, yalnız sıralama için)

- **Model:**
  - OLED ana renkleri Gauss eğrisi olarak alındı: mavi 455 nm, yeşil 530 nm, kırmızı 625 nm.
  - Melanopsin duyarlılığı: Govardovskii şablonu (λmax 480 nm) × basit bir mercek süzgeci. Birleşik tepe 489 nm'de, yani CIE S 026'nın 490 nm'sine yakın.
  - Ana renklerin parlaklık payları sRGB'den alındı.
- **Bu modelde:** beyazın melanopik uyaranının yaklaşık %64'ü mavi, %36'sı yeşil ana renkten gelir. Kırmızının payı %1'in altında.
- **Sonuç:** sıcak renk mavi ve yeşili birlikte azaltır. Kehribar bu yüzden sarı-yeşilden (fosfor) daha az uyaran verir.
- **Kesin değer için** iPhone ekranının ölçülmüş tayfı ve CIE S 026 araç kutusu gerekir. Bu sayılar kesin değer olarak kullanılmamalı.

### Reddedilen fikir: uygulama içinde ekstra karartma

- Ekranın üstüne %20 siyah katman koymak:
  - `ink` 13,0'dan 8,3:1'e düşer;
  - `ink3` 3,7:1'e düşer, 4,5'in altı.
- %30'da `ink3` 3,0:1 olur.
- Bunun yerine sistemin Beyaz Noktayı Azalt ayarı önerilir. Kullanıcı açıp kapatır, kontrast oranı bozulmaz.

## Mevcut koyu temaya ne eklenebilir (az değişiklikle)

Önem sırasıyla. İlk üçü yalnız token ve küçük bileşen değişikliği.

1. **Koyu modda ışımaları kaldır.** `Theme.bandGlow` ve `Theme.primaryGlow` bugün sabit (`fixed`) renkler ve zaten yalnız gece çiziliyor. Değerleri `.clear` olur ya da `PhosphorBandDrawing` ve `CapsuleButtonBody` ışımayı hiç çizmez. Şerit çizgisi kalır.
2. **Koyu modda ana düğmeyi dolu olmayan bir düğme yap.** Üç seçenek var (A, B, C); tabloda karşılaştırma için iki dolu hâl de var. Sayılar `is3-tema` dalının gerçek koyu değerleriyle (zemin `#000`, ikincil düğme: `surface` `#191C20` dolgu + `lineStrong` beyaz %40 kenar = `#757779`). "Ort. L": 358 × 54 pt'lik düğmenin ortalama bağıl parlaklığı (dolgu ve kenar birlikte).

   | Seçenek | Dolgu / kenar | Kenar–siyah | Kenar–ikincil kenar | Ort. L | Sarı odak |
   |---|---|---|---|---|---|
   | Eski: dolu sarı | `#E9E040` | — | — | %71 | 2 (şerit + düğme) |
   | İlkeler: dolu açık mürekkep | `#F3F4F0` | — | — | %90 | 1 |
   | A: tonal sarı (`is3-tema` cfdd806) | `band` %16 / `band` %45, 1,5 pt | 3,5:1 | 1,3:1 (yalnız renk tonuyla ayrılır) | %2,4 | 2 |
   | B: tonal mürekkep | `ink` %12 / `ink` %45, 1,5 pt | 4,1:1 | 1,1:1: ikincil düğmeden ayırt edilmez (`is3-tema` ölçümü) | %2,1 | 1 |
   | **C: B + parlak kenar (önerilen)** | `ink` %12 / `ink` %100, **2 pt**, **kalın yazı** | 19:1 | **4,1:1** | %8,6 | 1 |

   - C, "ekranın tek ana düğmesi"ni parlaklıkla ayırır: kenarı ikincil düğmenin gri kenarından 4:1 daha açık. Yazı da kalın.
   - Işık: C, dolu açık mürekkep düğmenin (ilkeler) yaklaşık onda biri, eski dolu sarının sekizde biri. A'nın yaklaşık 3,7 katı.
   - Sarı yalnız kelimede kalır: `ogrenme_ilkeleri.md`'nin "koyu ekranda iki sarı odak olmasın" kuralı (Choi 2017) korunur.
   - A'nın artısı en az ışık; eksisi ikinci sarı odak. Karar koordinatörün. Seçilen hâle göre `ogrenme_ilkeleri.md`'deki "koyu temada ana düğme açık mürekkep" satırı güncellenmeli.
3. **Koyu modda zemin `#000`, kartlar dolgusuz.**
   - `Theme.bg` koyu `#000000`.
   - `cardSurface()` koyu modda `surface` dolgusu yerine yalnız `line` kenar.
   - Sayfalar (sheet) ve gruplu listeler `surface`'ta kalır, katman farkı kaybolmaz.
4. **Her zaman açık düzeni.** `RectangularWordView`'da `@Environment(\.isLuminanceReduced)`:
   - tanım satırı gizlenir;
   - şerit 1 pt olur;
   - `AccessoryWidgetBackground` çizilmez.
5. **StandBy kontrolü.**
   - `WidgetSnapshotTests`'e kırmızı tek renk ve zeminsiz `systemSmall` varyantı.
   - Kelime en büyük, tanım en sönük olmalı. Renk farkına güvenilmez.
6. **Kart geçişi.** Akış'ta ve Tekrar'da `.transition(.opacity)` + `easeInOut(0.42)`. Reduce Motion açıksa animasyon yok. Kaydırma yine kullanıcının elinde.
7. **Durma noktası (isteğe bağlı).** Saat 21:00'den sonra ya da kullanıcı açarsa "Bu gece N kelime" ve "Bu geceki N kelime tamam" ekranı.
8. **İki ipucu satırı (Ayarlar → Yardım).** "Kilitli ekranı kehribar yap" ve "Beyaz Noktayı Azalt".
9. **Mürekkebi hafif ısıt (isteğe bağlı).**
   - Koyu `ink` `#F3F4F0` yerine `#E9E4D6` (`#0D0F11` zeminde 15,1:1, mavi %71).
   - Marka nötr kalır, saf beyaza yakın parlama azalır.

## Swift'e taşırken dikkat

1. **Ton mimarisi.**
   - `Theme.dynamic` bugün açık/koyu ve yüksek kontrastı ayırıyor. Gece tonu üçüncü bir eksen.
   - iOS 17 özel trait'leri bunu çağrı yerlerini değiştirmeden çözer:
     - `UITraitDefinition` ile `NightToneTrait` (kapalı / kehribar / fosfor);
     - SwiftUI tarafında `UITraitBridgedEnvironmentKey`;
     - `UIColor { traits in traits[NightToneTrait.self] … }`.
   - Böylece `Theme.ink` gibi statik adlar aynı kalır.
   - İki dikkat noktası:
     - `bandDark`, `markDark`, `bandGlow`, `primaryGlow` bugün sabit `Color` (`fixed`). Trait'i okumazlar; dinamik sağlayıcıya taşınmaları gerekir.
     - SwiftUI'nin `Color(uiColor:)` çözerken köprülenen özel trait'i sağlayıcıya verdiği belgelenmemiş, özellikle widget uzantısında. Cihazda doğrulanmalı. Olmazsa yedek yol: `Environment` değeri ve `Theme`'de tona göre renk döndüren işlevler.
   - Proje iOS 17 hedefli (`ios/project.yml`), bu API'ler var.
2. **Ne zaman açılır?**
   - Varsayılan: yalnız `colorScheme == .dark` iken. Apple HIG uygulamaya özel görünüm ayarından kaçınmayı öneriyor; "Her zaman" seçeneği isteğe bağlı kalmalı.
   - Saate bağlı açma (21:00 sonrası) istenirse `TimelineView` ya da sahne aktif olunca yeniden değerlendirme gerekir.
3. **Widget hedefi.**
   - Tonu App Group `UserDefaults`'tan okur.
   - Kilitli ekranda (vibrant) renk zaten yok sayılır. Orada yalnız opaklık hiyerarşisi ve `widgetAccentable()` işe yarar.
   - Ana ekranda `containerFill` gece tonunda `Color.black`.
   - `containerBackground(for: .widget)` kaldırılabilir kalmalı, yoksa StandBy galerisinden çıkar.
   - Zeminsiz hâli `showsWidgetContainerBackground` ile ayır.
4. **Saf siyah ve kaydırma.** Sayfa `#000`. Uzun kayan listelerde (Sözlük) satır zemini `surface` olsun. Cihazda kaydırırken iz kalıyor mu bakılmalı.
5. **Yazı.**
   - Gece Türkçe anlam `.title.weight(.semibold)` (bold yerine). Açık yazı koyu zeminde zaten kalın görünür.
   - İngilizce kelime serif bold kalır. Hiçbir yerde `.light` ya da `.thin` yok.
   - Dynamic Type (yazı boyutu) ölçekleri değişmez.
6. **Cam (iOS 26).**
   - Liquid Glass sekme çubuğu ve `glassControl()` koyu zeminde hafif parlar. Gece tonunda sekme çubuğu arka planı siyah tutulabilir mi, cihazda bakılmalı.
   - Olmazsa `glassControl()` gece tonunda `.bordered` dalına düşebilir.
7. **Hareket.**
   - `accessibilityReduceMotion` ve uygulamadaki "Hareketsiz" seçimi aynı yolu kullanmalı.
   - `repeatForever` nabız yok. "Dinle" çalarken yalnız simge ve yazı değişir ("Çalıyor").
8. **Söyle sayfası.** Mikrofon düğmesi ana düğmeyle aynı tonal stilde (dolu değil). Dinlerken nabız yok; yalnız simge ve yazı değişir. `FeedbackPanel` zemini `goodTint` / `badTint` (%12); "Neredeyse!" için `surface2` ve `caution` simge.
9. **Renk tek başına anlam taşımaz (kural 4).** Yanlış şık kesik çizgili kenar (`StrokeStyle(dash: [6, 4])`), doğru şık düz kenar ve simge.
10. **Bildirim.** Hatırlatma kullanıcının saatinde kalır. Gece yarısından sonra yeni bildirim planlanmaz.
11. **Parlaklık API'si.** `UIScreen.brightness` değiştirilmez. Kullanıcının ayarına dokunulmaz.
12. **Test.**
    - `WidgetSnapshotTests` ve ekran görüntüsü testlerine gece tonu eklenebilir (`screenshots.yml` kota nedeniyle az çalıştırılmalı).
    - Cihazda denenmeli:
      - kehribar mürekkebin %10 parlaklıkta okunması;
      - Her zaman açık ekranında 1 pt şeridin görünmesi;
      - StandBy kırmızı modda hiyerarşi;
      - kilitli ekran widget'larının saat rengini alması (iOS 17, 18, 26);
      - Türkçe iOS menü adları ("Beyaz Noktayı Azalt", "Erişilebilirlik Kısayolu").

## Uygulama planı (öneri: üç küçük adım)

Bu planı uygulayacak oturum için. Dosya adları `ios/arayuz-sik` dalına (1e4b4e6) göre. O sırada `ui2-*` oturumları aynı dosyaları değiştiriyordu. Bu yüzden önce onların dalları birleşmeli, sonra bu adımlar başlamalı. Satır numarası yerine işlev adları verildi.

Her adım kendi başına bir PR olabilir. Önce 1. adım: en az risk, en çok ışık kazancı.

**Durum (22 Ekim akşamı, dalları okuyarak):**
- `is3-tema` (cfdd806) 1. adımın çoğunu yaptı: koyu `bg` `#000`, koyu modda dolgusuz kart, tonal sarı ana düğme ve kenarı (seçenek A), `primaryGlow` saydam. Şerit ışıması %18'e indi; Yüksek Kontrast, Saydamlığı Azalt ve `isLuminanceReduced` iken çizilmiyor.
- Kalanlar:
  - `ReviewView` → `GradeButtonBody`'nin varsayılan düğmesinde gece kenarı yok (o dosyaya `is3-tema` dokunmadı; `is3-tekrar` da aynı dosyada çalışıyor);
  - `DoneMark` ışıması koşulsuz;
  - A mı C mi kararı (aşağıda "Mevcut koyu temaya" 2. madde; B tek başına ikincil düğmeden ayırt edilmiyor) ve buna göre `ogrenme_ilkeleri.md`'deki "koyu temada ana düğme açık mürekkep" satırının güncellenmesi. `is3-tema` B için iki satırlık hazır değişiklik yazdı; C buna kenar kalınlığı, kenar opaklığı ve yazı kalınlığı ekler.
- `is3-kilit` 2. adımın bir kısmını yaptı: dikdörtgen kilit ekranı widget'ı artık hep iki satır (kelime + anlam), tanım satırı yok, `AccessoryWidgetBackground` kalktı (zemini sistem çiziyor). Aşağıdaki 2. adım tablosunda bu yüzden yalnız şerit (Her zaman açık ekranda 1 pt) ve StandBy kalıyor.

### Adım 1: Koyu modda ışık bütçesi (yalnız mevcut koyu tema)

Gece tonu henüz yok. Yalnız bugünkü koyu tema daha az ışık verir.

| Dosya | Değişiklik |
|---|---|
| `ios/Shared/LockglowTheme.swift` → `Theme.bg` | Koyu değer `0x0D0F11` → `0x000000`. |
| `LockglowTheme.swift` → `CardSurfaceModifier` | Koyu modda dolgu yok, yalnız `Theme.line` kenar. Açık mod aynı. |
| `LockglowTheme.swift` → `CapsuleButtonBody` (`.primary`) | Koyu modda dolu değil. Önerilen C: dolgu `Theme.ink.opacity(0.12)`, yazı `Theme.ink` kalın, 2 pt `Theme.ink` kenar. (A: `band` %16 dolgu, `band` yazı, 1,5 pt `band` %45 kenar.) Işıma (`primaryGlow` gölgesi) kalkar. Seçenekler: aşağıda "Mevcut koyu temaya" 2. madde. |
| `LockglowTheme.swift` → `PhosphorBandDrawing` (`.underline`) | Bulanık `Ellipse` ışıması çizilmez; çizgi kalır. |
| `ios/App/ReviewView.swift` → `GradeButtonBody` (varsayılan cevap "Bildim": `Theme.primary` dolgu + `primaryGlow` gölge) ve `DoneMark` | Aynı kural: koyu modda tonal ve **aynı 1,5 pt kenar**. Kenar olmadan tonal dolgu siyahta yalnız 1,2–1,3:1 ve düğmenin sınırı görünmez. `DoneMark`'ın ışıması da şerit gibi Yüksek Kontrast, Saydamlığı Azalt ve Her zaman açık ekranda çizilmez. |
| `ios/App/GlowStyle.swift` → `Palette.glow` / `onGlow` | `Theme.primary` / `onPrimary`'ye bağlı. `GlowButtonStyle` 1e4b4e6'da hâlâ `OnboardingView`'da kullanılıyor; tonal kural oraya da uygulanmalı. |

**Kabul ölçütü:**
- Koyu modda hiçbir ekranda dolu sarı alan yok.
- Ana düğme yazısı zemininde en az 9:1.
- Açık mod ekran görüntüleri değişmez.

**Test:**
- `screenshots.yml` bir kez, yalnız koyu mod için çalıştırılır (kota).
- `WidgetSnapshotTests` değişmez, çünkü widget'lar bu adımda değişmiyor.

### Adım 2: Widget'lar için gece düzeni

| Dosya | Değişiklik |
|---|---|
| `ios/Widgets/AccessoryWordViews.swift` → `RectangularWordView` | (`is3-kilit` sonrası tanım satırı zaten yok.) `@Environment(\.isLuminanceReduced)` iken şerit 1 pt olur; bugün `.line` çizgisi `max(0.1 em, 1.5)` (17 pt'de yaklaşık 1,7 pt). |
| `ios/Widgets/WordWidget.swift` → `containerFill` | (`is3-kilit` sonrası dikdörtgen için zaten `Color.clear`.) Ana ekran aileleri koyu modda `Theme.bg` (`#000`). |
| `ios/Widgets/HomeWordViews.swift` | `@Environment(\.showsWidgetContainerBackground)` false ise (StandBy) iç boşluk ve yazı boyutu büyür. Düğme sırası değişmez. |
| `ios/WidgetSnapshots/WidgetSnapshotTests.swift` | Yeni görünümler: "her-zaman-acik" (`isLuminanceReduced` ortamda ayarlanabiliyorsa onunla; ayarlanamıyorsa görünüme bir parametre verilir) ve "standby" (`.vibrant`, zeminsiz `systemSmall`, kırmızıya boyanmış önizleme). |

**Kabul ölçütü:**
- Her zaman açık ekranında dikdörtgen widget'ta yalnız kelime ve anlam var.
- StandBy kırmızı önizlemesinde kelime en büyük ve en parlak öğe.
- `containerBackgroundRemovable(false)` hiçbir yerde yok.

**Test:** Linux paket testleri her push'ta çalışır. macOS işi `-f runner=macos-15-intel` ile bir kez.

### Adım 3: Gece tonu (kehribar / soluk fosfor) ve durma noktası

Kullanıcı ton seçimini onaylarsa yapılır (bkz. "Açık sorular").

| Dosya | Değişiklik |
|---|---|
| `LockglowTheme.swift` | `NightToneTrait` (`UITraitDefinition`; değerler: kapalı / kehribar / fosfor). `Theme.dynamic` koyu dalda bu trait'e göre "Önerilen renk tokenları" tablosundaki değeri döndürür. Sabit renkler (`bandDark`, `markDark`, `bandGlow`, `primaryGlow`) dinamik sağlayıcıya taşınır. |
| Uygulamanın kök görünümü (`LockglowApp`) | Ayar değeri `UITraitBridgedEnvironmentKey` ile trait'e köprülenir. Köprü widget'ta ya da `Color(uiColor:)` çözümünde çalışmazsa yedek yol: `Environment` değeri ve tona göre renk döndüren işlevler. |
| App Group `UserDefaults` | Ton ayarı widget hedefiyle paylaşılır; `WidgetCenter.reloadAllTimelines()` ile widget yenilenir. |
| `ios/App/SettingsView.swift` | "Gece görünümü" bölümü: Ne zaman açılsın (Koyu modda / Her zaman / Kapalı), Hangi ton, Geçişler. "Yardım" bölümüne iki ipucu satırı. Metinler bu belgedeki mockup'tan. |
| `ios/App/FeedView.swift` | Gece tonu açıkken "Bu gece N / M" sayacı ve son karttan sonra "Bu geceki N kelime tamam" ekranı. N, Ayarlar'daki "Bir gecede kaç kelime?" (3 / 5 / 10). Kart değişimi `.transition(.opacity)`, `accessibilityReduceMotion` ya da "Hareketsiz" iken animasyonsuz. |
| `ios/App/PronunciationPracticeView.swift` → `FeedbackPanel` | Gece tonunda `goodTint` / `badTint` %12; mikrofon tonal. |

**Kabul ölçütü:**
- Bu belgedeki tabloyla aynı kontrastlar: `ink` 13,0:1, `ink2` 8,7:1, `ink3` en az 4,5:1 (kapsülde 4,7).
- Gece tonu kapalıyken koyu mod 1. adımdaki gibi kalır.
- VoiceOver, Dynamic Type (en büyük boyutta kart kayar) ve Reduce Motion ile denenir.

**Cihazda denenecekler:** "Swift'e taşırken dikkat" bölümünün son maddesindeki liste.

## Açık sorular

- Gece tonu ayrı bir seçenek mi olsun, yoksa koyu modun kendisi mi bu olsun? Öneri: koyu mod bu olsun; Ayarlar'da yalnız ton seçimi.
- Kehribar mı, soluk fosfor mu? Kehribar daha az mavi; fosfor markaya daha yakın. Kullanıcıyla iki telefon yan yana gece denenmeli.
- Durma noktası herkes için mi, yalnız akşam mı? "5 kelime daha" ne kadar görünür olmalı?
- Uyku odağı açıkken (Focus) gece tonu otomatik açılabilir mi? `INFocusStatusCenter` yalnız "odak açık mı" bilgisini verir, hangi odak olduğunu vermez. Ayrıca kullanıcı izni ve ek bir uygulama yeteneği (capability) gerekebilir; Apple belgesinde doğrulanmalı.
