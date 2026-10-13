# Widget Vocabulary: Learn Words — Derin İnceleme ve "Kelime Widget'ı" Uygulaması Ürün Planı

> **Tarih:** 10 Ekim 2026 · **Hazırlayan:** Claude (Opus 5.5, koordinatör) + 10 araştırma alt ajanı (Sonnet)
> **Kapsam:** (1) App Store'daki *Widget Vocabulary: Learn Words* uygulamasının ayrıntılı incelemesi, (2) bu kategorideki pazarın, rakiplerin ve kullanıcı yorumlarının analizi, (3) benzer ama daha iyi bir uygulama için ürün, içerik, teknik, gelir, büyüme, hukuk/vergi ve takvim planı.
> **Ayrıntılı ajan raporları:** [`raporlar/`](raporlar/) klasöründe. Bu dosya onların **sentezi ve karar belgesidir**; çelişen önerileri burada karara bağladım.
> **Etiketler:** **[D]** doğrulanmış (Apple API, mağaza sayfası, resmi kaynak) · **[T]** üçüncü taraf tahmini (Sensor Tower, AppGoblin, MWM vb.) · **[Ç]** benim çıkarımım/kararım · **[TEYİT]** uzman (SMMM/avukat) onayı gerekli.

---

## İçindekiler

0. [Yönetici özeti](#0-yönetici-özeti)
1. [Hedef uygulamanın anatomisi: Widget Vocabulary (Orbit Studios)](#1-hedef-uygulamanın-anatomisi-widget-vocabulary-orbit-studios)
2. [Kullanıcının sesi: yorum analizi](#2-kullanıcının-sesi-yorum-analizi)
3. [Pazar ve rekabet](#3-pazar-ve-rekabet)
4. [Fırsat, konumlandırma ve ürün tezi](#4-fırsat-konumlandırma-ve-ürün-tezi)
5. [Ürün tanımı: MVP kapsamı ve Ücretsiz/Premium sınırı](#5-ürün-tanımı-mvp-kapsamı-ve-ücretsizpremium-sınırı)
6. [UX/UI ve widget tasarımı](#6-uxui-ve-widget-tasarımı)
7. [İçerik stratejisi](#7-içerik-stratejisi)
8. [Teknik mimari](#8-teknik-mimari)
9. [Gelir modeli, fiyatlandırma ve paywall](#9-gelir-modeli-fiyatlandırma-ve-paywall)
10. [ASO ve büyüme](#10-aso-ve-büyüme)
11. [Türkiye: hesap, şirket, vergi, KVKK](#11-türkiye-hesap-şirket-vergi-kvkk)
12. [Bütçe](#12-bütçe)
13. [Yol haritası ve 12 haftalık sprint planı](#13-yol-haritası-ve-12-haftalık-sprint-planı)
14. [KPI'lar, analitik ve deney planı](#14-kpilar-analitik-ve-deney-planı)
15. [Risk kaydı](#15-risk-kaydı)
16. [Karar kaydı (önerilen varsayılanlar)](#16-karar-kaydı-önerilen-varsayılanlar)
17. [Önümüzdeki 7 gün: yapılacaklar](#17-önümüzdeki-7-gün-yapılacaklar)
18. [Ekler: rapor dizini ve kaynaklar](#18-ekler-rapor-dizini-ve-kaynaklar)

---

## 0. Yönetici özeti

**Tek cümlelik strateji [Ç]:** Türkçe konuşan (ardından Rusça/Vietnamca/İspanyolca konuşan) İngilizce öğrenicileri için, **ücretsiz ve gerçekten çalışan bir widget'ı huni olarak kullanan**, sınav paketleri + etkileşimli widget + doğrulanmış içerik + Türkçe "tuzak kelime" katmanını premium yapan, **dürüst fiyatlı ve yerelleştirilmiş** bir kelime widget'ı uygulaması.

**En önemli 12 bulgu**

1. **Hedef uygulama yeni ve küçük ama hızlı [D].** *Widget Vocabulary: Learn Words* (ID 6775767149), İstanbul'daki **Orbit Studios Teknoloji Ltd. Şti.**'nin uygulaması. 24 Haziran 2026'da yayınlandı, 15 haftada 11 sürüm çıkardı (v2.2.5). 167 mağazada toplam ~1.320 puanı var (ağırlıklı 4,56). Bunların 418'i ABD'de (4,72), 240'ı Vietnam'da, 190'ı Türkiye'de (4,37).
2. **Gelişmekte olan pazarlarda listelerde ama para kazanamıyor [D+T].** Eğitim kategorisi ücretsiz listesinde **Türkiye #3**, Kazakistan #3, Belarus #3, Vietnam #21. ABD'de ilk 100'de yok. Sensor Tower'ın kamuya açık tahmini "geçen ay ~100 bin indirme, ~10 bin $ gelir", yani **indirme başına ~0,10 $** [T]. Organik anahtar kelime sıralamaları zayıf. Liste sırası büyük olasılıkla ücretli/organik olmayan trafikten geliyor [Ç].
3. **Monetizasyonu kullanıcıyı kızdırıyor [D].** Haftalık **9,99 $** (TR **₺499,99**), yıllık 49,99 $ (TR ₺2.499,99). 56 yazılı yorumun ortalaması **2,66**. Yorumların **%55'i**, 1–2 yıldızlı yorumların **%85'i** ödemeyle ilgili. En keskin şikâyet: **widget'ın kendisi bile ücretli**.
4. **Kategori lideri Monkey Taps'in "Vocabulary" uygulaması [D+T].** 219.574 ABD puanı, 12,5M+ indirme [T]. Gelir tahminleri 14 kata kadar çelişiyor (aylık 50 bin – 700 bin $) [T]. Widget'ı **ücretsiz**, yani huni. Zayıf noktaları: deneme sonrası yıllık ücretlendirme şikâyetleri (yorumların %12,9'u, ort. 1,40★), uydurma/yanlış kelimeler, kaydedilen kelimelerin paywall'a alınması.
5. **Türkiye'de lider boşluk var [D].** Monkey Taps TR listesini yerelleştirmemiş (TR'de 1.202 puan). Yerel lider *Kolay İngilizce Kelime Öğren* (36.922 puan) **Ocak 2025'ten beri güncellenmiyor** ve widget'ı yok. YDS/YÖKDİL'e odaklı, widget'lı ve kaliteli tek ciddi oyuncu küçük (Kelime+, 1.626 puan).
6. **Talep büyük [D].** 2026'da YDT'ye 203.640, YÖKDİL/1'e 113.881 kişi başvurdu, YKS'ye 2,43M. e-YDS her ay yapılıyor. TR aramalarında "yds kelime" #1 öneri. **"Widget" kelimesinin TR'de arama hacmi yok denecek kadar az.** Widget'ı **dönüşüm aracı** olarak kullanmalı, anahtar kelime olarak değil.
7. **Klon dalgası ve Apple riski [D].** 2026'da ~86 "vocab + widget" uygulaması çıktı. Sadece 3'ü 100+ puana ulaştı (ortanca 1 puan). Apple, **8 Haziran 2026'da Kılavuz 4.3'ü sertleştirdi**: doygun kategorilerde gelişmeyen veya müşteri çekmeyen uygulamalar kaldırılabiliyor. **Farklılaşma zorunlu.**
8. **Kimse etkileşimli widget'ı ve StandBy'ı pazarlamıyor [D].** iOS 17+ App Intents ile widget'ta "Göster / Biliyorum / Tekrar / Mini quiz" yapılabiliyor. Widget butonlarından gelen yenilemeler bütçeden düşmüyor. Bu hem ürün hem 4.3 savunması.
9. **Ücretli reklam şimdilik kârsız [Ç, kaynaklı model].** Temel senaryoda yüklemelerin ~%2'si ödeme yapıyor. Reklam maliyetinin çıkması için bu oranın ABD'de ~%8,3'e, TR'de ~%4,2'ye çıkması gerek. **Büyüme organik**: ASO, yerelleştirme, TikTok/Reels içerik üreticileri, sınav takvimi.
10. **İçerik kalitesi en ucuz kaldıraç [D+Ç].** Claude ile 4.000 kelime kartı üretmek ~90–200 $. Asıl maliyet insan denetimi (~120–150 saat). Rakiplerin 1★ nedenleri yanlış seviye, uydurma kelime, cinsel içerik ve tekrar. Bunlar içerik sürecindeki doğrulama aşamalarıyla çözülür.
11. **Vergi tarafında kolay yol var [D, TEYİT].** Tek kurucu için **şahıs + GVK Mükerrer 20/B** yolu: hasılattan %15 nihai stopaj, KDV/fatura yok, 2026 sınırı 5,3M TL. "Yazılım ihracatı" indirimi App Store için **tartışmalı** (GİB 30.01.2026 özelgesi aleyhte).
12. **Takvim gerçekçi [Ç].** 12 Ekim'de başlayıp **10 Aralık'ta sessiz lansman, 15 Aralık'ta tam lansman**, Yeni Yıl dalgasında v1.1. Kayarsa 5 Ocak'a ertelenir.

**Kritik kararlarım (çelişkiler giderildi) [Ç]**

| Konu | Karar | Neden |
|---|---|---|
| Paywall türü | **Değer gösterildikten sonra, kapatılabilir (soft) paywall + çalışan ücretsiz widget**. Sert paywall'ı A/B deneyi olarak test et | Orbit'in 1★ nedeni sert paywall + ücretli widget. Puanlar mağazaya özel ve ASO'yu besliyor. Monkey Taps da widget'ı ücretsiz bırakıyor |
| Plan seti | **Yıllık (7 gün deneme) + aylık + ömür boyu**. Haftalık lansmanda yok, sadece deney kolu | Haftalık plan iade ve 1★ şikâyetlerini yönlendiriyor. 5–9 günlük denemede denemeden ödemeye geçiş %37,4, ≤4 günde %25,5 |
| TR fiyatı | Yıllık **₺899,99** (deney: ₺599,99 / ₺899,99 / ₺1.299,99), aylık ₺149,99, ömür boyu ₺1.999,99 | TR çıpaları: Kolay İngilizce ₺299,99/yıl, Monkey Taps ₺799,99/yıl, Orbit ₺2.499,99/yıl |
| Platform | **Native SwiftUI, iOS 17+**, sadece iPhone. Android v2'de native Kotlin + Glance | Widget her durumda native yazılmak zorunda |
| Abonelik altyapısı | **RevenueCat ilk günden** (Paywalls + Experiments) | Paywall deneyleri P0. Aylık izlenen gelir 2.500 $'a kadar ücretsiz |
| İçerik büyüklüğü | Lansman **min. 2.500 kart (hedef 4.000)**, 7 seviye × 60 kategori. 18–24 ayda ~20 bin | Rakipler "10.000+" diyor ama asıl şikâyet sayı değil, seviye uyumu |
| İlk pazar | **EN arayüz + TR arayüz/çeviri** ile global yayın. TR, VN, KZ/RU, MX ilk odak | Orbit'in puanlarının %43'ü, yazılı yorumlarının %77'si TR/VN/UA/KZ'den |
| Takip/Reklam | **ATT yok, reklam yok** (MVP) | Gizlilik bir konumlandırma avantajı. Monkey Taps'e takip davası soruşturması açılmış durumda |

---

## 1. Hedef uygulamanın anatomisi: Widget Vocabulary (Orbit Studios)

> Ayrıntı: [`raporlar/01_appstore_profile.md`](raporlar/01_appstore_profile.md). Ekran görüntüleri: [`referans/orbit_widget_vocabulary_ekranlar/`](referans/orbit_widget_vocabulary_ekranlar/)

### 1.1 Kimlik kartı [D]

| Alan | Değer |
|---|---|
| Ad / alt başlık | **Widget Vocabulary: Learn Words** / "Easy & Fast English Learning" |
| App ID / Bundle | 6775767149 / `io.orbitstudios.widgetvocabulary` |
| Satıcı | ORBIT STUDIOS TEKNOLOJI LIMITED SIRKETI (Kağıthane, İstanbul) · geliştirici ID 1885662777 |
| Kategori | Education (tek kategori) |
| Yaş derecesi | 4+, "Contains: Advertising" |
| Yayın / güncel sürüm | 24.06.2026 / **v2.2.5 (25.09.2026)** |
| Boyut / min. iOS | 118,6 MB / iOS 15.0 (iPad "Designed for iPad", Apple Silicon Mac'te çalışır) |
| Arayüz dili | **Sadece İngilizce**. Mağaza metni ES, DE, PT-BR, JA, KO, ZH, RU, NL, SV, IT'ye yerelleştirilmiş, **TR değil** |
| Android | Var (Tem 2026). 1K+ yükleme, ~22 puan, ort. 3,0 |
| Teknoloji yığını | Gizlilik politikası: **Google AdMob, Firebase Analytics, Crashlytics, RevenueCat**, IDFA. AppGoblin: Flutter, OneSignal, Facebook SDK [T] |
| Gizlilik etiketi | "Data Used to Track You: Device ID". Kullanım, tanılama ve satın alma verisi "Not Linked to You" |

### 1.2 Özellikler: iddia edilen ve gözlenen [D]

| Özellik | Kaynak | Not [Ç] |
|---|---|---|
| Kilit ekranı + ana ekran widget'ları, gün içinde otomatik yenilenme | Mağaza açıklaması | Çekirdek vaat |
| A1–C2 seviye seçimi | Açıklama | Yorumlarda "başlangıç seçtim, C2 kelime geldi" şikâyeti var |
| "10.000+ kelime", "binlerce flashcard" | Ekran görüntüsü / açıklama | Tutarsız sayılar |
| "1.000+ seviyeli" quiz, seviye haritası | Ekran görüntüsü 4 | Oyunlaştırılmış harita |
| IELTS / TOEFL / GRE / SAT paketleri | Ekran görüntüsü 6 | **YDS/YÖKDİL yok**, TR pazarında boşluk |
| "10+ dil" (görselde 6 dil) | Ekran görüntüsü 8 | Arayüz yalnızca İngilizce |
| Anadili İngilizce olan seslendirme | Açıklama | Doğrulanamadı |
| Özel desteler (5 adet, 50–1.000+ kelime), widget'ta fonetik | v2.2.1 (26.08.2026) | En son eklenen gerçek özellik |
| Aralıklı tekrar (SRS), çeviri | Sadece geliştirici sitesinde | Mağazada iddia edilmiyor |

### 1.3 Ekran görüntüsü anlatısı ve tasarım dili [D]

- 8 iPhone + 5 iPad ekranı. Lacivert yıldızlı arka plan, beyaz başlık, altın vurgu. Maskot olarak kitap karakteri var.
- Sıralama: ① Kilit ekranından öğren → ② Widget'ları kişiselleştir (**fotoğraf/illüstrasyon arka planlı** widget'lar: *Sonder, Limerence, Petrichor*) → ③ 10.000+ kelime (kelime kartı; **yatay oklarla** geçiliyor) → ④ Seviye haritası quiz → ⑤ Nadir ve güçlü kelimeler → ⑥ Sınav paketleri → ⑦ Kelime listesi → ⑧ 10+ dil.
- **Konumlandırma [Ç]:** "estetik nadir kelimeler + widget". *Sonder, Limerence, Petrichor* gibi şiirsel kelimeler sosyal medyada iyi çalışıyor ama öğrenici için düşük fayda sağlıyor. Fotoğraf arka planları StandBy ve iOS 18/26'nın renklendirilmiş (tinted) ve şeffaf (clear) modlarında sistem tarafından **siliniyor**, widget'ın kimliği kayboluyor. Bizim için tasarım fırsatı: kimliği tipografiyle taşıyan temalar.

### 1.4 Fiyatlandırma [D]

| Mağaza | Haftalık | Yıllık |
|---|---|---|
| ABD | **9,99 $** | **49,99 $** |
| Türkiye | **₺499,99** | **₺2.499,99** |
| Euro bölgesi | 9,99 € | 59,99 € |
| Vietnam | 299.000₫ | 1.499.000₫ |
| Kazakistan | 5.990₸ | 29.990₸ |
| Hindistan | ₹999 | ₹4.999 |

- Yıllık fiyat her yerde tam olarak 5 × haftalık. 7 günlük deneme var (geliştiricinin yorum yanıtında).
- Haftalık 9,99 $ yıllık bazda ~520 $ ediyor. Taranan vocab uygulamaları arasında **en yüksek haftalık fiyat** (diğerleri 3,99–7,99 $).
- TR'de 1 haftalık Orbit ücreti, Kolay İngilizce Pro'nun ~1,7 yıllık ücretine eşit.

### 1.5 Performans ve tahminler

| Metrik | Değer | Güven |
|---|---|---|
| Toplam puan (167 mağaza) | ~1.320, ağırlıklı 4,56 | [D] |
| Yazılı yorum | 56 adet, ort. **2,66** | [D] |
| TR Eğitim ücretsiz / en çok kazanan | **#3 / #17** | [D] |
| KZ / BY / VN / MX Eğitim ücretsiz | #3 / #3 / #21 / #70 | [D] |
| ABD Eğitim | İlk 100'de yok (MWM'ye göre #123) | [D/T] |
| Sensor Tower "geçen ay" | ~100 bin indirme, ~10 bin $ gelir | [T] |
| MWM / AppGoblin | 100 bin+ indirme / ~21 bin yükleme, ~2,6 bin MAU | [T] (çelişkili) |
| Organik anahtar kelime sıralaması | Yalnızca uzun kuyruklu "widget" terimlerinde #1–#12 (US "learn words widget" #1, TR "ingilizce widget" #2). Ana terimlerde ilk 25'te yok | [D] |

**Yorumum [Ç]:** Liste sırası ile organik görünürlük ve gelir arasında büyük bir uçurum var. Bu, ucuz pazarlarda ücretli/sosyal edinim + yüksek fiyatlı sert paywall + düşük dönüşüm tablosuna uyuyor. Model, ABD tarzı fiyatı gelişmekte olan pazar kitlesine uyguluyor.

### 1.6 Geliştiricinin oyun kitabı [D+Ç]

- Orbit Studios'un portföyü: **Holy Bible Widget: Daily Verse** (ABD 2.054 puan; ST ~100 bin indirme / ~60 bin $ [T]), Ayat Online: Hourly Widgets (TR 1.499 puan), Along (motivasyon), Rooster (alarm), ClueDom (bulmaca, sadece Android).
- Bu, Monkey Taps'in yöntemi: **tek widget motoru, birçok niş** (Motivation → I am → Facts → Vocabulary → Bible Widgets). Hızlı sürüm, RevenueCat + AdMob + Firebase.
- Kamuya açık kurucu ya da ekip bilgisi yok.

### 1.7 SWOT [Ç]

| Güçlü | Zayıf |
|---|---|
| Hızlı sürüm döngüsü · estetik widget görselleri · A1–C2 + sınav paketleri · TR/KZ/VN'de liste görünürlüğü · Android var | Sert paywall + ücretli widget · haftalık 9,99 $ · yalnızca İngilizce arayüz · TR yerelleştirme yok · YDS/YÖKDİL yok · içerik/seviye tutarsızlığı · takip ve reklam SDK'ları · fotoğraf arka planlar tinted/StandBy'da bozuluyor |
| **Fırsatlar (bizim için)** | **Tehditler (bizim için)** |
| TR yerelleştirme · sınav paketleri · ücretsiz widget hunisi · etkileşimli widget · dürüst fiyat · içerik kalitesi | Orbit hızlı kopyalayabilir (TR + YDS ekleyebilir) · Monkey Taps kilit ekranı odağına kaydı · Apple 4.3 sertleşmesi · TR'de düşük ödeme gücü |

---

## 2. Kullanıcının sesi: yorum analizi

> Ayrıntı: [`raporlar/02_review_mining.md`](raporlar/02_review_mining.md). Hedef uygulama için 56 yorum elle kodlandı. Rakipler için ~5.000 yorum (Monkey Taps 1.761 iOS + 900 Play, Atlas, Vocabulous, WordUp, widget nişi) anahtar kelime sınıflandırıcıyla analiz edildi.

### 2.1 Sayılar [D]

| Örneklem | n | Ort.★ | 1–2★ oranı |
|---|---|---|---|
| **Orbit (tüm yazılı yorumlar)** | 56 | **2,66** | **%59** |
| Monkey Taps iOS (son 12 ay) | 1.123 | 2,92 | %46 |
| Atlas (2024+) | 521 | **4,32** | %12 |
| WordUp (2024+) | 597 | 4,24 | %14 |
| Vocabulous (2024+) | 553 | 2,82 | %51 |
| Widget nişi (Dogan, Voca, Lingo, WOTD…) | 143 | 3,00 | %48 |

> Not: Yazılı yorumlar mutsuz kesimi abartır. Orbit'in yalnızca yıldız ortalaması 4,56. TR'de 21 ve 28 Eylül'de aynı gün gelen kısa 5★ yorum kümesi var; kampanya etkisi olabilir [Ç].

### 2.2 Orbit'in temaları (elle kodlandı) [D]

| Tema | Pay | Ort.★ |
|---|---|---|
| Herhangi bir ödeme şikâyeti | **%55** | 1,45 |
| "Ödemeden hiçbir şey çalışmıyor" | %39 | 1,05 |
| Fiyat çok yüksek (haftalık, bölgesel) | %25 | 1,93 |
| Değer görmeden ödeme isteniyor / reklam ile gerçek uyumsuz | %14 | 1,00 |
| **Widget'ın kendisi ücretli** | %9 | 1,00 |
| Deneme sonrası otomatik ücretlendirme / iade | %7 | 1,25 |
| Seviye uyumsuzluğu (çok zor kelimeler) | %5 | 1,00 |
| Övgü: "harika/faydalı", widget sayesinde gün boyu maruz kalma, IELTS hazırlığı | %27+ | 5,00 |

### 2.3 Rakiplerde öne çıkan acılar [D]

- **Monkey Taps:** deneme/fatura (%12,9, ort. **1,40**; %6,7'den %14,5'e yükseldi), kilitli temel özellikler (kaydedilen kelimeleri görmek ücretli), uzun onboarding sonrası fiyat sürprizi, **yapay zekâ ile uydurulmuş kelimeler ve robotik ses** (bu yorumların %80'i 1–2★), **cinsel içerikli kelimeler** (4+ yaş derecesiyle; %86'sı 1–2★), widget sıklık kontrolü yok, "bildim" butonu çalışmıyor ve kelimeler tekrar ediyor.
- **Widget nişi:** "kelimeler çok kolay" (Dogan'ın yorumlarının %49'u), tekrar, yanlış tanım, beyaz/donmuş widget.
- **Vocabulous:** günün kelimesini görmek için reklam/jeton zorunluluğu, seri (streak) hataları. Reklam + seri modeli olumsuz örnek.
- **Atlas (en iyi puan):** derin müfredat, çoklu quiz türleri. Gerçek bir öğrenme döngüsü, paywall olsa bile iyi niyet kazandırıyor.

### 2.4 Sıralı özellik istekleri (rakipler genelinde) [D]

1. Zengin kart: etimoloji, daha çok örnek, eş/zıt anlamlı, deyimler (84)
2. Daha fazla ücretsiz özellik / daha uzun deneme (44)
3. Telaffuz: IPA, UK/US aksanı, örnek cümle sesi (35)
4. Kendi kelimelerini ekleme, içe/dışa aktarma (CSV/Anki) (34)
5. Kaydedilenlerle pratik, flashcard, aralıklı tekrar (31)
6. Hata bildirme, kaynaklı tanım (31)
7. Ana dilde çeviri (27)
8. **Widget kontrolü:** yenileme aralığı, "günde tek kelime", kilit ve ana ekranı senkronlama (27)
9. Tema/font (22) · 10. Sözlük araması (21) · 11. Senkron/iPad/Watch (21) · 12. "Biliyorum / gizle" (17) · 13. **Tek seferlik ödeme / ömür boyu** (16) · 14. İnce seviye ve kategori kontrolü, hassas kategorileri kapatma (16) · 15. Çalışan yenileme hatırlatıcısı, kolay iptal (14)

### 2.5 Ürüne çevirdiğim 12 ders [Ç]

1. **En az bir ana ekran + bir kilit ekranı widget'ı ücretsiz ve sürekli çalışsın.**
2. **Paywall'dan önce değer göster:** ilk kelimeler kaydırılsın, widget kurulsun, sonra fiyat gelsin.
3. **Haftalık 9,99 $ gibi bir manşet fiyat olmasın.** Yıllık + ömür boyu öne çıksın. Fiyatlar bölgesel olsun.
4. **Deneme süreci güvenilir olsun:** deneme bitmeden 2 gün önce **gerçekten** bildirim gönderilsin, iptal yolu görünür olsun.
5. **Seviye kalibrasyonu yapılsın ve seçilen seviyeye uyulsun** (seviye saflığı kuralı: L seviyesi seçildiyse sadece L, tekrar için en fazla L-1).
6. **"Biliyorum / gizle / tekrar etme"** hem uygulamada hem widget'ta olsun.
7. **Uydurma kelime ve yanlış tanım sıfır olsun:** içerik doğrulama aşaması + "hata bildir" butonu.
8. **İçerik güvenliği:** hassas kategoriler varsayılan olarak KAPALI, kilit ekranında güvenli ilk örnek, doğru yaş derecesi.
9. **Widget kontrolü:** aralık seçimi, "bu kelime N saat kalsın", kilit/ana ekran senkronu, tekrar etmeme süresi.
10. **Telaffuz:** IPA + US/UK aksanı. Yapay zekâ sesi doğal değilse hiç kullanma.
11. **Yakalama:** sözlük araması, paylaşım menüsünden "kelime kaydet", özel listeler, CSV/Anki dışa aktarma (ücretsiz).
12. **Yayından sonra hiçbir özelliği paywall'ın arkasına taşıma.** Kaydedilen kelimeler ve temel tekrar her zaman ücretsiz.

---

## 3. Pazar ve rekabet

> Ayrıntı: [`raporlar/03_rekabet_haritasi.md`](raporlar/03_rekabet_haritasi.md) (32 uygulamalık liste, özellik matrisi, fiyat tablosu, gelir tahminleri, klon dinamikleri).

### 3.1 Oyuncu haritası [D, tahminler T]

| Uygulama | ABD puan | TR puan | Model / fiyat (ABD) | Öne çıkan | Zayıf |
|---|---|---|---|---|---|
| **Vocabulary – Monkey Taps** | 219.574 (4,77) | 1.202 | Aylık 9,99–14,99 $, yıllık 35,99–59,99 $, ömür boyu 149,99 $ + reklam | Marka ve puan hendeği, 7 uygulamalı tek motor, Watch/iMessage, ücretsiz widget | Fatura şikâyetleri, uydurma kelimeler, TR yerelleştirmesi yok, takip davası soruşturması |
| **Widget Vocabulary – Orbit** | 418 (4,72) | 190 (4,37) | Haftalık 9,99 $ / yıllık 49,99 $ | TR/KZ/BY'de #3 | Bkz. §1.7 |
| Word of the Day – Vocabulous | 38.952 | 356 | Haftalık 7,99 $ … yıllık 99,99 $ | Editör seçimi, oyunlar, SRS | Reklam/jeton zorunluluğu (~830 bin € fiyatla satıldı [T]) |
| Atlas (Sayan Yazılım, TR) | 12.498 | 8.599 | Yıllık 19,99–49,99 $, ömür boyu 74,99 $ | En derin müfredat, YZ öğretmen | Kilit ekranı widget'ı yok, listelerde yok |
| WordUp (Geeks) | 13.844 | 3.585 | Yıllık 49–79,99 $ | 25 bin kelime bilgi haritası, YZ | Widget yok, hatalar |
| Kolay İngilizce Kelime Öğren | – | **36.922** (4,80) | ₺299,99/yıl, ₺499,99 ömür boyu | TR'deki yerleşik taban, 1M+ indirme [T] | **Ocak 2025'ten beri güncelleme yok**, widget yok |
| Kelime+ (YDS/YÖKDİL) | – | 1.626 | ₺49,99/ay, ₺149,99/yıl | **Tek ciddi TR sınav + widget oyuncusu** (Kontrol Merkezi dahil) | Küçük, dar |
| Lingo Widget (Oğuz Doruk) | 101 | 17 | Haftalık 4,99 $, ömür boyu 59,99–119,99 $ | 31 dil, "seri yok, suçluluk yok" | Küçük |
| Hourly Kana / Hangul / Hanzi | 744 | – | ~34,99 $/yıl | **Dile ve sınava özel widget**, ~100 günde 744 puan | – |
| Learna (Deep Flow) | 429.682 | 33.549 | Abonelik | TR Eğitim #1, YZ konuşma öğretmeni; ST ~6M $/ay ABD [T] | Kelime odaklı değil (komşu kategori) |

### 3.2 Gelir büyüklükleri: sadece büyüklük sırası [T]

- **Monkey Taps Vocabulary:** ST ~700 bin $/ay (ABD), AppGoblin "50 bin $+"/ay, Latka şirket toplamı ~6M $ (2023). **14 kata kadar çelişki var.** Plan bu sayılara göre değil, büyüklük sırasına göre yapılmalı.
- **Monkey Taps Bible Widgets:** 16 ayda 117 bin ABD puanı, Reference #7. Tek motorla yeni niş açmanın kanıtı.
- **Vocabulous:** ~830 bin € satış [T]. **Drops:** 31M $ + 19M $ bonusla Kahoot'a satıldı (2020).
- **Orbit:** ~10 bin $/ay [T, düşük güven].

### 3.3 Klon dalgası ve 4.3 riski [D]

- ABD arama örnekleminde 2026'da çıkan 86 "vocab + widget" uygulamasından sadece 3'ü 100+ puana ulaştı (Hourly Kana 744, Orbit 418, Hourly Hangul 356). 39'unun puanı sıfır.
- Haziran–Ağustos 2026'da ayda 7–11 yeni klon çıktı.
- **Apple, 08.06.2026:** doygun kategorilerde "güncellenmeyen, geliştirilmeyen veya müşteri çekemeyen" uygulamalar kaldırılabilir. Aynı geliştiriciden birden fazla benzer uygulama yayınlamak en riskli davranış.

### 3.4 Boşluklar (sıralı) [D+Ç]

1. **Türkçe öncelikli İngilizce kelime widget'ı:** TR'ye yerelleştirilmiş liste, makul fiyat, Türkçe "tuzak kelime" (false friend) katmanı.
2. **YDS / YÖKDİL / YKS-Dil widget paketleri** (sadece Kelime+ ve Kavra var).
3. **Monkey Taps'in yerelleştirmediği gelişmekte olan pazarlar:** AR/SA/EG, VI, ID, TH, PL, RU/KZ. Orbit KZ'de #3, VN'de #21 (sadece İngilizce metinle).
4. **Güven ve kontrol:** doğrulanmış tanım, kategori engelleme, "bu kelimeyi tekrar gösterme", ücretsiz kaydedilenler, şeffaf deneme süreci.
5. **Etkileşimli widget ve StandBy:** kimse pazarlamıyor.
6. Güncel olmayan SAT/GRE/IELTS uygulamaları (Magoosh 2019–2020'den beri güncellenmedi).
7. Sonraki dalga: İngilizce dışındaki hedef diller (Hourly Kana modeli), mesleki paketler (iş, tıp, hukuk).

---

## 4. Fırsat, konumlandırma ve ürün tezi

### 4.1 Konumlandırma cümlesi [Ç]

> **"Telefonuna her baktığında, seviyene uygun, doğrulanmış bir İngilizce kelime. Widget'ta dokun, öğren. Uygulamayı açmasan bile."**
> İngilizce mağaza alt başlığı: *"Word of the Day on Lock Screen"* · Türkçe: *"Günlük İngilizce Widget & YDS"*

### 4.2 Kazanmanın dört ayağı [Ç]

1. **Kitle kaması:** Türk öğreniciler (YDS/YÖKDİL/IELTS/iş İngilizcesi) → ardından RU/VI/ES/PT çeviri katmanları. Varsayılan arayüz İngilizce + Türkçe.
2. **Öğrenme yüzeyi olarak widget:** Göster / Biliyorum / Tekrar / mini quiz widget'ta. Bu dokunuşlar seriye ve aralıklı tekrara (SRS) sayılsın. Uygulama hiç açılmasa da ilerleme olsun.
3. **İçerik güveni:** 3 katmanlı tanımlar (widget için yazılmış, hiç kesilmeyen), seviye saflığı, uydurma kelime yok, Türkçe tuzak kelimeler ve tipik hatalar.
4. **Dürüst para:** çalışan ücretsiz widget, görünür kapatma tuşu, deneme bitiş tarihi açıkça yazılı ve hatırlatıcısı gerçekten çalışıyor, ömür boyu seçeneği.

### 4.3 Personalar [Ç]

| Persona | Seviye | İhtiyaç | Kanca |
|---|---|---|---|
| **Sınava hazırlanan** (YDS/YÖKDİL/YDT, IELTS) | B1–C1 | Sınavda çıkan kelime + eş anlamlı kümeleri | "YDS kelimeleri kilit ekranında" |
| **Kariyer odaklı** (iş İngilizcesi) | B1–C1 | Toplantı/e-posta kelimeleri, eşdizimler | "Daha profesyonel konuş" |
| **Kelime meraklısı** (global) | C2/S | Nadir, güzel, "akıllı görün" kelimeleri | Paylaşılabilir estetik kartlar |
| **Başlangıç** | A1–A2 | Günlük kelimeler, ana dil desteği | "Günde 2 dakika" |

### 4.4 Ad önerileri [D: çakışma taraması, TEYİT: marka]

> **Güncelleme (2026-10-11): ilk kısa liste marka taramasından geçemedi.** Ayrıntı: [`raporlar/11_isim_taramasi.md`](raporlar/11_isim_taramasi.md).

| Aday | Sonuç | Neden |
|---|---|---|
| ~~Wordglance~~ | ❌ **Kullanılamaz** | Google Play'de birebir aynı adlı, widget'lı bir kelime uygulaması var: *WordGlance: Learn Languages* (Türk geliştirici, `com.nusret.wordglance`). iOS'ta *GlanceWord* (Türk geliştirici, aynı ürün). "GLANCE" 9/38/41/42 sınıflarında başkalarına tescilli. @wordglance Instagram ve TikTok hesapları başkasında. İlk ASO taraması yalnızca iOS'a bakmıştı |
| ~~Wordwink~~ | ❌ **Kullanılamaz** | ABD'de **WORDWINKS** (Reg. 4482587) sınıf 9'da dil öğreten bir mobil uygulama için tescilli. wordwink.com alınmış |
| Lexpeek | ⚠️ Mümkün, riskli | Birebir çakışma yok, ama "-peek" adlı kelime widget'ları kalabalık (Wordpeek, PeekMemo…). PEEK 9/42 sınıflarında AB/UK'de tescilli. @lexpeek Instagram ve TikTok hesapları başkasında |

**2. tur (2026-10-11):** ~150 uydurma/birleşik ad tarandı. Ayrıntı: [`raporlar/12_yeni_isim_adaylari.md`](raporlar/12_yeni_isim_adaylari.md). Gerçek kelimelerin ve Latince köklerin neredeyse hepsinin mağazada birebir adlı uygulaması çıktı.

| Aday | Risk | Not |
|---|---|---|
| Lumiglot | Düşük–Orta | .com ve .app boş, mağaza ve ABD markasında yok. İspanya argosunda "lumi" sorunu |
| Verbaluz | Düşük | .app boş, .com alınmış |
| Silabo | Düşük–Orta | And ülkeleri İspanyolcasında "müfredat" demek (ayırt edicilik zayıf) |
| Dilumi | Düşük–Orta | Türkçe hikâyesi güçlü. .com satılık, sosyal hesaplar alınmış |
| Lumisoz | Düşük–Orta | Yalnızca Türkçe hikâye. .com ve .app boş |

**Karar:** Kurucu bu beşini beğenmedi, 3. tur istendi (Türkçe kökenli ve sade/gündelik İngilizce yönleri).

**3. tur (2026-10-11):** iki yönde ~480 ad tarandı. Ayrıntı: [`raporlar/13a_turkce_kokenli_adlar.md`](raporlar/13a_turkce_kokenli_adlar.md), [`raporlar/13b_sade_ingilizce_adlar.md`](raporlar/13b_sade_ingilizce_adlar.md). Alan adı ve mağaza bilgileri ilk üç adda tarafımca yeniden doğrulandı.

| Aday | Yön | Risk | Not |
|---|---|---|---|
| Lockglow | İngilizce | Düşük–Orta | Beş adayın içinde .com'u boş olan tek ad (.app de boş). Mağaza, Play ve ABD markasında yok. "Kelime" demediği için ayırt edici, kayda daha uygun. Türkçede "lok-glov" okunur |
| Learnbell | İngilizce | Düşük | Çakışma yok. .com park edilmiş, .app boş. "Learn" tanımlayıcı, marka biraz zayıf |
| Wordbell | İngilizce | Orta | "Does it ring a bell?" hikâyesi en güzeli. Ama "English Word Bell" adlı aynı konseptte bir uygulama var |
| Gozat | Türkçe | Düşük–Orta | "Göz at" ürünü birebir anlatıyor. Mağaza, Play ve ABD markası temiz. .app ve .com.tr boş, .com alınmış, sosyal hesaplar dolu. Yalnızca TR |
| Pirilti | Türkçe | Düşük–Orta | Temiz. .app boş, .com 11 gün önce alınmış. Türkçe adlar içinde küresel olmaya en yakını |
| Aferin | Türkçe | Orta | En sıcak ad. Ama aferin.app'te "yakında" sayfası var (olası rakip), "Afarin Kids" komşu |

Notlar: "-bit" ile biten adlar Türkçe "bit" (parazit) yüzünden elendi. "Word + lamp/light/shine" adları İncil uygulamalarıyla karışıyor. TÜRKPATENT bu turda da kontrol edilemedi (giriş istiyor); seçilen ad mutlaka elle aratılmalı.

**Önerim:** Lockglow. §12'ye göre TR tek başına sabit gideri karşılamıyor, yani küresel çalışan tek bir ad lazım. Gozat Türkiye'de daha sıcak ama yurt dışında anlamsız. App Store'da dil başına ayrı ad vermek mümkün, ancak iki marka iki tescil ve bölünmüş pazarlama demek.

**Karar (2026-10-11): Lockglow.** Kesinleşmeden önce yapılacaklar: lockglow.com ve lockglow.app'i hemen kaydet; TÜRKPATENT'te 9, 41 ve 42. sınıflarda arat; marka vekilinden TR/AB/ABD görüşü al. Sosyal hesaplar: TikTok @lockglow başkasında, @lockglowapp boş; Instagram @lockglow büyük olasılıkla boş. Adı kesinleştirmeden önce bir marka vekilinin TÜRKPATENT/EUIPO/USPTO görüşü alınmalı.
**Ders:** Ad taraması iOS, **Google Play**, marka veri tabanları, domain ve sosyal medya hesaplarının hepsini kapsamalı.

---

## 5. Ürün tanımı: MVP kapsamı ve Ücretsiz/Premium sınırı

> Ayrıntı: [`raporlar/10_yol_haritasi_sprint.md`](raporlar/10_yol_haritasi_sprint.md) §2, [`raporlar/06_ux_ui_widget_tasarim.md`](raporlar/06_ux_ui_widget_tasarim.md) §4.6

### 5.1 MVP: MoSCoW (benim birleştirilmiş versiyonum) [Ç]

**MUST (yoksa yayınlanmaz)**

| # | Özellik | Sınır |
|---|---|---|
| M1 | Onboarding (~14 ekran, §6.3) | Takip izni (ATT) yok, yaş/cinsiyet/isim yok, hesap yok |
| M2 | Tam ekran dikey kelime akışı | Kelime, IPA (US/UK), sözcük türü, seviye, 3 katmanlı tanım, 1–2 örnek, TR karşılık, Kaydet / Biliyorum / Paylaş |
| M3 | Kelime detayı + telaffuz | AVSpeechSynthesizer (MVP), "Kolay tanım" geçişi |
| M4 | Ana ekran widget'ı küçük + orta | 48 saatlik önceden hesaplanmış zaman çizelgesi, dokununca kelimeye gider |
| M5 | Kilit ekranı widget'ı dikdörtgen + satır içi (+ dairesel hedef halkası) | Kilitliyken butonlar çalışmaz, salt okunur |
| M6 | **Etkileşimli "Sonraki" + "Biliyorum"** (iOS 17 App Intents) | Temel farklılaştırıcı. Bu dokunuşlar yenileme bütçesinden düşmez |
| M7 | Widget ayarları | Aralık (günlük/4s/2s/1s ücretsiz; 30/15 dk premium), deste/seviye, tema |
| M8 | Seviyeler + konular | 7 seviye (A1–C2 + S), kategoriler (§7) |
| M9 | Öğrenme durumu | Yeni / Öğreniyor / Biliyor / Kaydedildi. Basit Leitner algoritması widget kuyruğunu besler |
| M10 | Quiz (çoktan seçmeli, 2 yönlü) | Kaydedilen ve görülen kelimelerden. Sonuç ekranı |
| M11 | Yerel bildirimler | Günde 1–3, saat seçimi. 64 bekleyen bildirim sınırına göre kayan takvim |
| M12 | Paywall + abonelik | RevenueCat. Yıllık + 7 gün deneme, aylık, ömür boyu. Satın alımları geri yükleme, şartlar, gizlilik, abonelik yönetimi |
| M13 | **Widget Sağlığı ekranı** | "Widget bulundu: 2 · Son güncelleme 14:02 · Sonraki kelime 16:00 · Arka plan yenileme açık/kapalı" |
| M14 | İçerik seti | Min. 2.500 kart (hedef 4.000), %100 TR katmanı, "hata bildir" |
| M15 | Analitik + çökme raporu | ~44 olay (§14). Onay akışı |
| M16 | TR arayüz yerelleştirmesi | Erken pazarda dönüşüm etkisi yüksek, ~150 metin |
| M17 | Ayarlar, yasal metinler, destek, hassas kategori anahtarı | – |

**SHOULD:** seri + günlük hedef halkası · "kelime kartı" paylaşım görseli (Stories formatı) · büyük widget / "Bugünün 5 kelimesi" · paywall'ı kapatınca tek seferlik teklif · teklif kodları (içerik üreticileri için) · arama · kaydedilenlerden oluşan "Tricky" akıllı koleksiyonu.

**COULD:** Göster/Quiz widget'ı (v1.1'e kayabilir) · alternatif ikonlar · Kontrol Merkezi kontrolü (iOS 18) · Siri/Kısayollar · paylaşım menüsünden "kelime kaydet".

**WON'T (MVP):** Android, hesap/giriş, bulut senkronu (v1.2 CloudKit), YZ sohbet, kamera/OCR, Apple Watch, iPad optimizasyonu, Live Activity, reklam, sıralama tabloları, uzaktan push.

**Kesme sırası (G1'de geride kalınırsa):** büyük widget → arama → teklif → temalar 4'ten 2'ye → seri → (TR çeviri katmanı kalır) → içerik 4.000'den 2.500'e.
**Asla kesilmeyenler:** ücretsiz widget, paywall, analitik, Widget Sağlığı, içerik denetimi, geri yükleme, yasal metinler.

### 5.2 Ücretsiz / Premium sınırı (nihai) [Ç]

| Yetenek | Ücretsiz | Premium |
|---|---|---|
| Kelime widget'ı, tüm boyutlar, kilit ekranı, StandBy | ✅ (ücretsiz desteler, 4 ücretsiz tema) | ✅ |
| Yenileme aralığı | Günlük / 4 s / 2 s / 1 s | + 30 dk / 15 dk |
| "Sonraki" ve "Biliyorum" widget butonları | ✅ | ✅ |
| Widget başına deste/seviye/çeviri yapılandırması | Varsayılan deste | ✅ Tam |
| Göster (reveal) ve Quiz widget'ı, ses butonu | Göster: temel | ✅ |
| İçerik | ~%42 kart (günlük hayat, duygular, **Türkçe tuzak kelimeler**, ilk 50 phrasal verb/deyim, her kategoriden 10 kartlık tadımlık) | 60 kategorinin tamamı: **YDS/YÖKDİL, IELTS, TOEFL, SAT, GRE**, iş, tıp, hukuk, akıllı görünme kelimeleri |
| Kaydetme, "Biliyorum", arama, CSV/Anki dışa aktarma | ✅ Sınırsız | ✅ |
| Quiz | Günde 1 oturum (10 soru) | Sınırsız, tüm türler, SRS tekrar modu, istatistikler |
| Özel liste | 1 liste / 50 kelime | Sınırsız |
| Temalar / fontlar | 4 ücretsiz (Kâğıt, Mürekkep, Sistem, Mono) + **disleksi dostu font ücretsiz** | 8+ premium tema |
| Paylaşım kartı | Küçük filigranlı | Filigransız + premium şablonlar |
| Reklam | **Yok** | Yok |

**Asla kilitlenmeyenler:** widget'ın yenilenmesi, kelime kaydetme, kullanıcının oluşturduğu içerik, erişilebilirlik özellikleri. **Abonelik biterse** widget'lar sessizce ücretsiz varsayılana döner; kilit katmanı gösterilmez.

---

## 6. UX/UI ve widget tasarımı

> Ayrıntı (ekran envanteri, ASCII tel kafes çizimleri, EN/TR metinler, renk ve yazı tipi değerleri, 24 farklılaştırıcı, 36 kaçınılacak hata): [`raporlar/06_ux_ui_widget_tasarim.md`](raporlar/06_ux_ui_widget_tasarim.md)

### 6.1 Tasarım ilkeleri

1. **Önce widget, sonra uygulama:** ilerlemenin bir kısmı widget'ta olur.
2. **Sakin akış:** "10 kelime gördün, zor olanlara bakalım mı?" diye yumuşak duraklar. Sonsuz kaydırma yok.
3. **Dürüst para:** fiyat, deneme bitiş tarihi ve iptal yolu ilk ekranda. Kapatma tuşu hemen görünür.
4. **Yerel ve anında:** widget içinde ağ isteği yok, yerel veride yükleniyor animasyonu yok.
5. **Önce ana dil:** Türkçe metinler birinci sınıf kalitede. İ/ı büyük-küçük harf tuzaklarına dikkat.
6. **Erişilebilirlik özelliktir:** Dynamic Type AX5'e kadar, VoiceOver için akışa alternatif butonlar, Reduce Motion desteği.

### 6.2 Bilgi mimarisi

```
[ Kelimeler ]  [ Pratik ]  [ Kütüphane ]  [ İlerleme ]  [ Ara ]
   akış        tekrar/quiz   kaydedilen/koleksiyon   seri/istatistik   sözlük
                             /konu tarayıcı
Profil (sağ üst) → Ayarlar (sayfa) → Widget'lar: Galeri · Sağlık · Kilit Ekranı/StandBy rehberi
Deep link: /word/{id} · /review · /quiz/{tip} · /collection/{id} · /widget-guide · /paywall?src=
```

### 6.3 Onboarding (14 ekran, ~90 sn) [Ç: UX ve büyüme raporlarının birleşimi]

| # | Ekran | TR metin (özet) | Amaç |
|---|---|---|---|
| 1 | Ana dil | "Ana dilin nedir?" (cihaz dili önceden seçili) | Çeviri dili |
| 2 | Hoş geldin | "Telefonuna her baktığında yeni bir kelime." · "Hesap gerekmez." | Değer önerisi |
| 3 | Amaç (çoklu seçim) | Sınav (YDS/YÖKDİL/IELTS) · Kariyer · Seyahat · Dizi/kitap · Merak | Kişiselleştirme |
| 4 | Seviye | Başlangıç / Orta / İleri, örnek kelimelerle · "30 saniyelik test" | Seviye ataması |
| 5 | Hızlı kalibrasyon (isteğe bağlı) | "Kaydır: Bu kelimeyi biliyor musun?" (8 kart) | "Biliyorum" mekaniğini öğretme |
| 6 | Konular (en az 3) | İş dünyası, Duygular, Deyimler, Phrasal verb'ler… | Kişiselleştirme |
| 7 | Günlük tempo | 3 · 5 (önerilen) · 10 · 20 | Taahhüt |
| 8 | Hatırlatma saatleri | Sabah kahvesi 08:00 · Öğle 12:30 · Eve dönüş 18:00 + bildirim önizlemesi | İzin hazırlığı |
| 9 | Bildirim izni (önce açıklama, sonra sistem istemi) | "Seçtiğin saatlerde günde 1–3 nazik hatırlatma. Widget'lar bildirim olmadan da çalışır." | İzin |
| 10 | Planın hazır | Gerçek özet, **sahte "analiz ediliyor" beklemesi yok** | Taahhüt |
| 11 | İlk kelimeler | 3 gerçek kart + ipuçları ("Yukarı kaydır", "Biliyorum'a dokun") | Yaparak öğretme |
| 12 | Görünüm | Tema karuseli + canlı widget önizlemesi | Kişiselleştirme |
| 13 | **Widget kurulum rehberi** | Animasyonlu, 4 adım + "Ekledim". Geri dönünce **widget otomatik algılanır** ("Widget bulundu!") | Widget kurulum oranı |
| 14 | **Paywall** → kapatılırsa tek seferlik teklif (en fazla 1 kez) → "Hazırsın" | "7 gün ücretsiz dene" + zaman çizelgesi (Bugün / 5. gün hatırlatırız / 7. gün ücretlendirilir) | Dönüşüm |

Sonraya ertelenenler: puan istemi (3 günlük seri sonrası), "bizi nereden duydun?" (2. gün tek soru), kilit ekranı rehberi (ilk gün banner olarak).
**A/B testi:** paywall widget rehberinden önce (B kolu) ya da sonra (varsayılan).

### 6.4 Widget aileleri

| Tür | Boyutlar | İçerik |
|---|---|---|
| **Kelime** | küçük, orta, büyük, XL (iPad), kilit dikdörtgen, satır içi | Çekirdek widget, yapılandırılabilir |
| **Quiz** | küçük, orta, büyük | Ana ekranda 3–4 şıklı soru (kilit ekranında yok) |
| **Seri ve Hedef** | küçük, kilit dairesel, dikdörtgen | Motivasyon. StandBy'da Kelime widget'ıyla yan yana |
| **Bugünün Listesi** | büyük, XL | Günün 5 kelimesi |

```
systemSmall (158×158)            systemMedium (338×158)
+--------------------------+     +-----------------------------------------------+
| adj · B2                 |     | resilient       adj · B2 | Able to recover    |
| resilient                |     | /rɪˈzɪl.i.ənt/           | quickly after...   |
| able to recover quickly  |     | dayanıklı, esnek         | "She is remarkably |
|                   (Next) |     | (Ses) (Kaydet) (Biliyorum)        (Sonraki)   |
+--------------------------+     +-----------------------------------------------+
accessoryRectangular (160×72)   accessoryInline
| resilient          adj. |      📖 resilient · çabuk toparlanan
| /rɪˈzɪl.i.ənt/          |
| able to recover quickly |
```

**Kritik kurallar [D, Apple HIG/WidgetKit]:**
- `containerBackground(for: .widget)` zorunlu. Kaldırılamayan arka planlı widget StandBy ve iPad kilit ekranı galerisinden düşer.
- iOS 18 renklendirilmiş (tinted) ve iOS 26 şeffaf (clear/Liquid Glass) modlarında sistem arka planı kaldırır. Tema kimliği **tipografiyle** taşınmalı; vurgu öğeleri `.widgetAccentable()` ile işaretlenir.
- Minimum yazı boyutu 11 pt, kenar boşluğu 16 pt, dokunma alanı 44 pt.
- Kilit ekranında butonlar cihaz kilitliyken çalışmaz.
- Büyük widget'ta "Sonraki kelime 15:00" etiketi. Eski veri asla placeholder arkasına saklanmaz.

### 6.5 Kaçınılacak 10 kritik hata (36'dan seçildi)

1. Değer görmeden sert paywall · 2. Geç beliren veya gizli kapatma tuşu · 3. Gizli deneme şartları · 4. Haftalık fiyatı öne çıkarıp yıllık maliyeti gizlemek · 5. Utandırıcı ret metni ("Hayır, öğrenmek istemiyorum") · 6. Sahte geri sayım · 7. Yayından sonra özelliği paywall'a taşımak · 8. Açılışta ATT istemi + demografik sorular · 9. iOS'un garanti edemeyeceği yenileme aralıklarını vaat etmek · 10. Türkçe metinlerde dil ayarı olmadan büyük harfe çevirmek (`"i".uppercased()` → "I" olur, "İ" olmaz).

---

## 7. İçerik stratejisi

> Ayrıntı (60 kategorilik tam tablo, şema, editoryal kurallar, 3 hazır prompt, QA rubriği, 25 kartlık örnek veri): [`raporlar/07_icerik_stratejisi.md`](raporlar/07_icerik_stratejisi.md) · Örnek veri: [`veri/ornek_kelime_seti_25.json`](veri/ornek_kelime_seti_25.json)

### 7.1 Seviyeler ve hacim

| Seviye | TR adı | MVP kart | Tam kütüphane |
|---|---|---|---|
| A1 | Başlangıç | 250 | 700 |
| A2 | Temel | 450 | 1.200 |
| B1 | Orta | 700 | 2.200 |
| B2 | Orta-Üstü | 800 | 3.600 |
| C1 | İleri | 750 | 4.300 |
| C2 | Uzman | 450 | 3.500 |
| **S** | **Havalı kelimeler** (nadir, edebi, "akıllı görün") | 600 | 4.350 |
| **Toplam** | | **4.000** | **~19.850** |

- **Seviye saflığı:** sadece seçilen seviye gösterilir (tekrar için en fazla bir alt seviye). Rakiplerin 1 numaralı içerik şikâyeti buna dayanıyor.
- **Tekrarsız ufuk:** 1 seviye + komşu seviye + 5 konu seçen tipik kullanıcı için ~450–700 kartlık havuz, günde 3–5 yeni kelimeyle **4–8 ay** yeter.
- **Lansman kapıları:** her seviyede ≥250 kart, her görünür kategoride ≥20 kart, %100 TR katmanı, ilk 1.200 kartın tamamı insan denetiminden geçmiş, hassas kategoriler kapalı.

### 7.2 Kategori yapısı (60 kategori, 9 grup)

**A.** Günlük hayat (12) · **B.** Seyahat ve kültür (2) · **C.** İnsanlar, duygular, sosyal (8) · **D.** İş, para, toplum (8) · **E.** Bilim, teknoloji, sağlık (6) · **F.** Sanat, medya, fikirler (5) · **G.** Dil zanaatı: phrasal verb, deyim, eşdizim, argo, atasözü, **kafa karıştıran kelimeler ve Türkçe tuzak kelimeler**, kökler, "X yerine şunu söyle" (8) · **H.** Havalı kelimeler (3) · **I.** Sınav paketleri: Akademik, IELTS, TOEFL, SAT/ACT, GRE, **YDS/YÖKDİL çekirdek (MVP'de 300 kart)**, YÖKDİL alanları (Fen/Sağlık/Sosyal), TOEIC (8).

**Vitrin kategorileri (pazarlama ve ekran görüntüleri):** Duygular · Phrasal Verbs · Deyimler · **Türkçe Tuzak Kelimeler** · Akıllı Görünme Kelimeleri · Nadir ve Güzel Kelimeler · **YDS/YÖKDİL Çekirdek**.
Erişim dağılımı: 12 ücretsiz, 26 örneklemeli (ilk %30 ücretsiz), 22 premium kategori → kartların ~%42'si ücretsiz.

### 7.3 Kart şeması (özet)

`id = en.lemma.pos.senseNo` · **bir kart = bir anlam**.

| Alan | Sınır | Kullanıldığı yer |
|---|---|---|
| `def.micro` | ≤28 karakter | Kilit satır içi/dikdörtgen, bildirim başlığı |
| `def.short` | ≤80 | Küçük ve orta widget |
| `def.long` | ≤220 | Büyük widget, uygulama |
| `ipa.us / ipa.uk` | ≤26 | Küçük widget ve üstü |
| `examples[2–3]` | EN ≤80/110 · TR ≤100/130 | Orta widget (1. örnek), büyük widget, uygulama |
| `l1.tr.gloss` | ≤28 | Widget 2. satır |
| `l1.tr.equivalence` | full / partial / cognate / **false_friend** / none | Rozet |
| `l1.tr.mistakes`, `l1.tr.mnemonic`, `l1.tr.note` | – | Uygulama (Türk öğreniciye özel değer) |
| `tags.sensitivity` | 0–2 | Güvenlik filtresi |
| `quiz.cloze + distractors` | ≤100 | Etkileşimli widget quiz'i |
| `meta.status/model/prompt_ver/reviewer` | – | Kaynak izi |

**Türkçe tuzak kelime örnekleri [D, TDK ile doğrulandı]:** actual ≠ aktüel · sympathetic ≠ sempatik · **enervate ≠ enerji verici** (tam tersi: hâlsiz bırakmak) · fabric ≠ fabrika · magazine ≠ mağaza · pasta ≠ pasta · pension ≠ pansiyon · sensible ≠ hassas · eventually ≠ eventüel.

### 7.4 Üretim hattı

```
(0) Başlık kelime + anlam planı (açık lisanslı listeler)
 → (1) Prompt A: İngilizce çekirdek (Claude Haiku 5.5, Batch)
 → (2) Prompt B: Türkçe katman
 → (3) Deterministik kontroller (şema, uzunluk, örnekte kelime geçiyor mu, tanımda başlık kelime yok,
        IPA'yı CMUdict ile karşılaştırma, Türkçe yazım denetimi, hassas kelime listesi)
 → (4) Prompt C: bağımsız eleştirmen (Claude Sonnet 5.5): 22 puanlık rubrik, GEÇER ≥18 ve kritik 0 yok
 → (≤2 düzeltme turu)
 → (5) İnsan denetimi: ilk 1.200 kart çift okuma; geri kalanlarda Türkçe öncelikli tarama + işaretlenenlerin düzeltilmesi
 → (6) Ses + quiz türetimi → (7) Sürümlü yayın + uygulama içi "hata bildir" kuyruğu
```

- **En zayıf alanlar:** IPA, etimoloji, CEFR seviyesi, Türkçe doğallık. IPA CMUdict'ten alınır. Etimoloji isteğe bağlıdır, güven bayrağıyla gelir, uydurma etimoloji kara listesi tutulur.
- **Durdurma kuralı:** bir partide insan düzeltme oranı %25'i, kritik hata oranı %5'i aşarsa partinin tamamı yeniden denetlenir ve prompt düzeltilir. 100 kartlık "altın set" her prompt değişikliğinde yeniden çalıştırılır.
- **Maliyet:** LLM ~90–200 $ (4.000 kart), insan denetimi ~120–150 saat (≈1,4–3,8 bin $). **Bütçe önce editöre ayrılmalı.**

### 7.5 Lisans (kısa) [D, TEYİT: avukat]

| Kaynak | Durum |
|---|---|
| **NGSL / NAWL** (CC BY-SA 4.0), **CEFR-J** (atıfla ücretsiz), **Open English WordNet** (CC BY 4.0), **Princeton WordNet** (serbest), **CMUdict** (serbest), **Tatoeba** (CC BY 2.0 FR) | ✅ Atıf ekranıyla kullanılabilir. Share-alike veriyi ayrı etiket dosyasında tut |
| Wiktionary / kaikki (CC BY-SA + GFDL) | ⚠️ Türetilmiş veri CC BY-SA kalmalı. Sadece UK IPA ve doğrulama için |
| **Oxford 3000/5000, Cambridge EVP, COCA listeleri, Merriam-Webster/Oxford API metinleri** | ❌ Lisans olmadan kullanma. "Oxford onaylı" gibi iddialarda bulunma |
| AWL (Coxhead) | Belirsiz, onun yerine NAWL kullan |
| IELTS/TOEFL/YDS adları | Marka. "…hazırlığı için" ifadesi + "bağlantımız yoktur" notu kullan; adda kullanma |

### 7.6 İçerikle etkileşim

Günün kelimesi editoryal takvimi · mevsimlik paketler (Yeni Yıl "30 günde kelime meydan okuması", YDS/2 22.11.2026 (ÖSYM'den teyit edilmeli), YKS Haziran, okula dönüş) · haftalık "yeni paket" yayını · kullanıcı listeleri · v2'de Kindle'dan içe aktarma ve "ilgi alanına göre YZ kelimeleri".

---

## 8. Teknik mimari

> Ayrıntı (kod taslakları, WWDC/Apple kaynakları, belirsizlik listesi): [`raporlar/04_teknik_mimari.md`](raporlar/04_teknik_mimari.md)

### 8.1 Bağlam [D]

- iOS 27, Xcode 27 ve Swift 6.4 Eylül 2026'da çıktı.
- 28.04.2026'dan beri yüklemeler için **iOS 26 SDK zorunlu**.
- Haziran 2026'da iPhone'ların %79'u iOS 26, %14'ü iOS 18 kullanıyordu → **iOS 17 tabanı** (etkileşimli widget için) cihazların büyük çoğunluğunu kapsıyor.
- iOS 27 yenilikleri: `systemExtraLargePortrait` widget ailesi. Apple'ın iOS 27 rehberine göre Küçük İşletme Programı'ndaki ve 2M altı indirmeli uygulamalar için Foundation Models'e ücretsiz Private Cloud Compute erişimi var.

### 8.2 Önerilen yığın [Ç]

| Katman | Seçim |
|---|---|
| Dil/arayüz | Swift 6, SwiftUI, Observation · min. **iOS 17.0** (`#available` ile iOS 18 Kontroller ve iOS 26 Liquid Glass) |
| Widget | WidgetKit, `AppIntentTimelineProvider`, App Intents (paylaşılan paket), iOS 18 ControlWidget (v1.1) |
| İçerik veritabanı | **Salt okunur, uygulamayla birlikte gelen SQLite** (GRDB 7.x + FTS5). App Group'a kopyalanır, `?immutable=1` ile açılır |
| Kullanıcı verisi | Uygulamaya özel GRDB (veya SwiftData). CloudKit senkronu v1.2 (CKSyncEngine) |
| Widget ↔ uygulama | **Atomik JSON anlık görüntüsü** (`widget_plan.json`) + **olay posta kutusu** (`events/`). Widget asla canlı ve yazılabilir bir SQLite'a yazmaz (0xDEAD10CC çökmeleri) |
| İlk açılış öncesi | Widget paketinde 300–500 kelimelik seed JSON (widget uygulama açılmadan eklenirse boş kalmasın) |
| SRS | MVP: Leitner (5 kutu), `Scheduler` protokolü arkasında → v1.2: **FSRS-6** (`swift-fsrs`, MIT, belirli bir commit'e sabitlenmiş) |
| Abonelik | **RevenueCat** (Paywalls + Experiments + webhook'lar), StoreKit 2. Hak durumu App Group'a yazılır, widget asla StoreKit çağırmaz |
| Analitik | **PostHog (AB bulutu)**, açık rızadan sonra başlatılır · Sentry/MetricKit çökme raporu |
| Bildirim | Yerel bildirim, 7–14 günlük kayan takvim (64 bekleyen sınırı). Uzaktan push v1.2 |
| İçerik güncellemesi | v1.1: CDN'den (ör. Cloudflare R2) sürümlü veritabanı/JSON farkları. Veri olduğu, kod olmadığı için App Review'a takılmaz |
| İçerik hattı | Python + Claude API (Haiku 5.5 taslak, Sonnet 5.5 yargıç, Batch API) + Streamlit/Airtable denetim arayüzü |
| Ses | MVP: AVSpeechSynthesizer · v1.2: en çok kullanılan 3–5 bin kelime için önceden üretilmiş nöral TTS (Google Chirp 3 HD ~30 $/M karakter), geri kalanı Background Assets ile |
| CI/CD | Xcode Cloud (ayda 25 saat ücretsiz) + TestFlight (yenileme bütçesi ancak burada test edilebilir) |
| Android (v2) | Ayrı native Kotlin + Compose + **Glance** uygulaması. Aynı SQLite şeması ve aynı FSRS |

### 8.3 "Her X saatte yeni kelime" nasıl güvenilir çalışır [D]

- Apple'ın bütçesi widget örneği başına **günde ~40–70 yenileme** ve dinamik. Girişler arası en az ~5 dk olmalı.
- **Bütçeden düşmeyenler:** uygulama ön plandayken yapılan yenilemeler, App Intent dokunuşları (Sonraki/Biliyorum), yerel ayar ve Dynamic Type değişiklikleri.
- **Strateji:** tek bir `timeline()` çağrısında **~48 saatlik girişler** (en fazla ~96) üretilir. Politika `.atEnd`. Program `(seed, deste, seviye, başlangıç, aralık)` girdilerinin saf bir fonksiyonu, giriş zamanları aralık sınırlarına hizalı, böylece widget'lar kendi aralarında senkron. Uygulama arka plana geçerken bir kez `reloadAllTimelines()`. Widget'ta ağ isteği yok.
- Bellek sınırı ~30 MB (resmi belge değil, çökme günlüklerinden). Görüntüler küçültülmeli, en fazla ~50–100 satır okunmalı.
- Kilit ekranı için paylaşılan dosyalar `.completeUntilFirstUserAuthentication` korumasıyla yazılmalı, yoksa kilitliyken boş görünür.
- Widget'tan ses (`AudioPlaybackIntent`) gecikmeli ve kırılgan. Çekirdek özellik yapılmamalı; yedek olarak dokununca uygulama açılıp ses çalınsın.

### 8.4 Klasör yapısı

```
App/            Features: Onboarding, Placement, Learn, Quiz, Library, Search, Stats, Settings, Paywall
WidgetExtension/ WordWidget (home + lock), QuizWidget, StreakWidget, Controls/, Resources/seed_words.json, PrivacyInfo.xcprivacy
Packages/       CoreModels · ContentStore (GRDB salt okunur) · SharedState (App Group posta kutusu)
                Scheduler (kuyruk + SRS) · AppIntentsKit · UserStore · Entitlements · Audio · Design · Analytics
Tools/ContentPipeline/   (uygulamayla gönderilmez) seed oluşturucular, Claude prompt'ları, doğrulayıcılar, QA arayüzü, DB paketleyici
Docs/           lisanslar ve atıflar (uygulamadaki "Teşekkürler" ekranı)
```

### 8.5 App Review riskleri [D]

| Kural | Önlem |
|---|---|
| **4.3(b) Spam** (08.06.2026'da sertleşti) | Özgün ad, ikon ve ekranlar · etkileşimli widget + SRS + TR katmanı · tek bundle ID · rakip adı/varlığı kullanma |
| 4.2 Asgari işlevsellik | Uygulamanın kendisi de değerli olmalı (quiz, kütüphane, arama, istatistik) |
| **3.1.2 Abonelik** | Fiyat, dönem, yenileme ve iptal metni · Şartlar + Gizlilik linkleri hem paywall'da hem metadata'da · geri yükleme · en belirgin fiyat gerçekten ödenecek tutar olmalı |
| **4.4 / 2.5.18** | Widget'ta satın alma ve reklam yok |
| 5.1.1 / 5.1.2 | Gizlilik politikası uygulamada ve App Store Connect'te · üçüncü taraf YZ'ye veri gönderiliyorsa açık izin · hesap açılıyorsa uygulama içinden silme |
| 2.3 Metadata | Ekran görüntüleri gerçek uygulamayı göstermeli · inceleme notunda widget nasıl eklenir anlatılmalı |
| Gizlilik manifesti | Her hedef (uygulama + widget `.appex`) için `PrivacyInfo.xcprivacy` (App Group UserDefaults: 1C8F.1) |
| Yaş derecesi | Yeni 13+/16+/18+ anketi (31.01.2026'dan beri zorunlu) · hassas içerik kapalıyken 4+/9+ hedeflenebilir [Ç] |
| "Widget güncellenmiyor" | Widget Sağlığı ekranı + Yardım sayfası |

---

## 9. Gelir modeli, fiyatlandırma ve paywall

> Ayrıntı: [`raporlar/05_buyume_gelir_modeli.md`](raporlar/05_buyume_gelir_modeli.md)

### 9.1 Kıyas değerleri [D, kaynaklı]

| Metrik | Değer | Kaynak |
|---|---|---|
| Eğitim: indirmeden denemeye (D30, ortanca) | **%6,5** | RevenueCat 2026 |
| Eğitim yıllık / aylık ortanca fiyat | **44,99 $** / 9,99 $ | RevenueCat 2026 |
| Eğitim: ödeyen başına gerçekleşen 1 yıllık LTV / D14'te yükleme başına gelir | 22,82 $ / 0,30 $ | RevenueCat 2026 |
| Denemeden ödemeye geçiş, deneme süresine göre | ≤4 gün **%25,5** · 5–9 gün **%37,4** · 17–32 gün %42,5 | RevenueCat 2026 |
| 0. günde iptal | 3 günlük denemede %55,4 · 7 günlükte **%39,8** | RevenueCat |
| Sert ve freemium paywall, D35 indirmeden ödemeye | %10,7 / %2,1 | RevenueCat 2026 |
| Sert ve yumuşak paywall (Adapty) | Sertin LTV'si %21 yüksek, yumuşak ~%50 daha iyi dönüştürüyor | Adapty |
| 1. yıl tutundurma: yıllık / aylık / haftalık | %28 / %8 / %1,2 | RevenueCat |
| Eğitim deneme başlangıçlarının 0. günde olanı | %78,5 | RevenueCat |
| TR bölgesel fiyat endeksi | 0,7 (ABD = 1) | Adapty |

### 9.2 Plan seti ve fiyatlar (lansman varsayılanı + deney kolları) [Ç]

| Plan | ABD | TR | Not |
|---|---|---|---|
| **Yıllık + 7 gün deneme** (öne çıkan) | **39,99 $** (deney: 29,99 / 49,99 $) | **₺899,99** (deney: ₺599,99 / ₺1.299,99) | Deneme sadece yıllık planda |
| Aylık | 7,99 $ | ₺149,99 | Çıpa |
| Ömür boyu | 79,99 $ | ₺1.999,99 | "Kiralama değil satın alma" isteği. Yıllığın 2 katı |
| Haftalık | – (deney kolu: 3,99–4,99 $, yıllık karşılığı da gösterilerek) | – | Lansmanda yok |
| Kapatınca tek seferlik teklif | Yıllık %40 indirimli | Aynı | En fazla 1 kez |

- Fiyatlar ülke bazında **elle** ayarlanır: TR, VN, KZ, IN, MX, BR, EG. Kur hareketi %10'u geçerse veya her ay gözden geçirilir. TR'de fiyat artışı ₺300'ü (yıllıkta ₺3.000'i) aşarsa abone onayı gerekir.
- Family Sharing'i açmak **geri alınamaz**; sonraya bırakılmalı.
- iOS 18 win-back teklifleri v1.2'de. WWDC26'da duyurulan "12 ay taahhütlü aylık ödeme" ileride test edilebilir.

### 9.3 Paywall kuralları

- **Yer:** onboarding sonunda, widget rehberinden **sonra**. Ayrıca bağlama göre: kilitli paket, premium tema, Quiz widget'ı.
- Kapatma tuşu hemen görünür · fiyatlar StoreKit'ten (`displayPrice`) · **deneme bitiş tarihi** yazılı · "5. gün hatırlatırız" (gerçek yerel bildirim; bildirim kapalıysa takvime ekleme önerilir) · Geri Yükle / Şartlar / Gizlilik / Abonelik Yönetimi alt satırda.
- Yasak: geri sayım, fiyatı değiştiren deneme anahtarı, utandırıcı ret metni, "Devam" yazıp satın alan buton.

### 9.4 Birim ekonomisi senaryoları (açıklayıcı, aylık 1M gösterim başına) [Ç, kaynaklı varsayımlar]

| | Kötümser | **Temel** | İyimser |
|---|---|---|---|
| Aylık yükleme | 20.000 | 41.440 | 49.800 |
| Yüklemeden denemeye | %3,6 | **%6,5** | %12,6 |
| Denemeden ödemeye | %25,5 | %30 | %37,4 |
| Yüklemeden ödemeye | %0,92 | **%1,95** | %4,71 |
| Ödeyen başına ilk 12 ay net gelir | 10,71 $ | 24,53 $ | 47,41 $ |
| **12. ay MRR** (Apple payı ve iadeler sonrası) | **~2,0 bin $** | **~19,8 bin $** | **~111 bin $** |

- **Ücretli edinimde başa baş:** temel huniyle 12 aylık yükleme başına net gelir ABD'de ~0,68 $, TR benzeri pazarda ~0,48 $. AppTweak'e göre CPI: ABD Eğitim **2,91 $**, TR ~**1,02 $** (tüm kategoriler).
- **Kural:** yüklemeden ödemeye ≥%2,5 ve D14'te yükleme başına gelir ≥ 1,5 × test CPI olmadan ücretli reklama para harcanmaz.
- **Sağlama:** Orbit'in ~0,10 $/indirme tahmini [T] kötümser senaryoya yakın. Sert paywall + aşırı fiyatın gelişmekte olan pazardaki sonucu bu.

---

## 10. ASO ve büyüme

> Ayrıntı (US/TR'de 170 anahtar kelime tablosu, rakip metadata incelemesi, 8 yerel ayar planı, CPP ve In-App Event listesi, Apple Ads grupları): [`raporlar/08_aso_isim_metadata.md`](raporlar/08_aso_isim_metadata.md) · Büyüme taktikleri: [`raporlar/05_buyume_gelir_modeli.md`](raporlar/05_buyume_gelir_modeli.md) §8

### 10.1 Anahtar kelime stratejisi [D]

- **ABD:** ana terimler (vocabulary, word of the day, learn words) Monkey Taps'in (220 bin puan) kalesi → **ulaşılmaz**. Kazanılabilir alan: **widget uzun kuyruğu**. "vocab widget", "flashcard widget", "vocabulary lock screen" (otomatik tamamlamada #1), "english words widget", "words widget". İlk 5'teki uygulamaların ortanca puanı 500'ün altında. Sınav terimlerinde orta zorluk: "ielts vocabulary" ve "gre words" düşük.
- **TR:** "widget" araması yok denecek kadar az. Hacim şu terimlerde: **"ingilizce kelime", "kelime ezberleme", "kelime öğren"** (orta), **"yds kelime", "yökdil kelime", "günlük kelime", "günün kelimesi"** (düşük zorluk, otomatik tamamlamada #1), "kelime kartları", "kelime defteri". Birçok TR rakip alt başlık alanını boş bırakmış; doldurmak ucuz bir avantaj.
- **Puanlar mağazaya özel:** TR'de rekabet için ~1–5 bin TR puanı, UK/AU/CA için ~500–2 bin yeterli.

### 10.2 Metadata taslakları (ad: **Lockglow**, bkz. §4.4; TÜRKPATENT ve vekil kontrolü bekliyor) [D: uzunluklar kodla sayıldı]

| Yerel ayar | Başlık (≤30) | Alt başlık (≤30) | Anahtar kelime alanı (≤100 bayt) |
|---|---|---|---|
| en-US | Lockglow: Vocabulary Widget | Word of the Day on Lock Screen | `learn,english,daily,vocab,flashcards,builder,ielts,toefl,sat,gre,quiz,memorize,test,study,toeic,esl` |
| **tr** | Lockglow: Kelime Ezberleme | Günlük İngilizce Widget & YDS | `öğren,ezberle,kartları,yökdil,defteri,öğrenme,test,quiz,ielts,toefl,sözlük,flashcard,vocab` |
| en-GB (UK + **TR'de ikincil indeks**, satıcı raporu) | Lockglow: Vocabulary Widget | Learn English Words & IELTS | `day,lock,screen,vocab,flashcards,builder,toefl,yds,yokdil,ydt,quiz,test,study,b1,b2,c1,a1,daily` |
| es-MX / pt-BR / ru / vi | Yerel başlıklar ("Vocabulario Inglés", "Английские слова", "Từ vựng tiếng Anh") | Yerel | Yerel |

**TR tanıtım metni:** "Kilit ekranında her gün yeni bir İngilizce kelime. Widget'ı ekle, uygulamayı açmadan kelime ezberle. YDS, YÖKDİL ve günlük İngilizce için. Ücretsiz başla."
**Kategori:** Education (birincil) + Reference (ikincil).

### 10.3 Görseller

- **10 ekran görüntüsü:** ① "Uygulamayı açmadan kelime öğren" (ana + kilit ekranı) ② Kilit ekranında günün kelimesi ③ Anlam, örnek, telaffuz ④ A1'den C2'ye ⑤ 30 saniyede kartlar ⑥ Mini testler ⑦ Günlük seri ⑧ **YDS, YÖKDİL, IELTS, TOEFL** (TR'de 3. veya 4. sıraya alınır) ⑨ Her boyutta widget ⑩ "Ücretsiz başla".
- **Önizleme videosu (15–30 sn):** kilit açılır, yeni kelime görünür → 3 dokunuşta widget eklenir → kart → quiz → seri → bitiş ekranı.
- **Özel ürün sayfaları (CPP):** IELTS · TOEFL · SAT/GRE · İş İngilizcesi · **YDS/YÖKDİL** · LGS/YKS İngilizce · Kilit Ekranı Widget'ı · rakipten geçiş.
- **Uygulama içi etkinlikler:** "30 Günlük Kelime Koşusu" (Ocak/Eylül) · **"YDS Kelime Kampı"** (YDS/2: 22.11.2026, ÖSYM'den teyit edilmeli) · IELTS Kelime Takviyesi · Okula Dönüş Paketi.

### 10.4 Büyüme taktikleri: ilk 15 (etki/efor sırasına göre) [Ç, büyüme ajanının listesinden]

1. **Tam TR metadata + TR arayüz** (Yüksek/Düşük) · 2. **Sınav kümesi anahtar kelimeleri** (YDS/YÖKDİL/YDT/IELTS) · 3. ABD ikincil yerel ayarlarını İngilizce anahtar kelimelerle doldurma (tartışmalı taktik, risk notunu oku) · 4. Paywall: 3 ve 7 günlük deneme + sadece yıllıkta deneme · 5. Sert ve yumuşak paywall testi · 6. **TR fiyat testi** · 7. Bildirim izni öncesi açıklama ekranı · 8. Widget kurulum adımı + otomatik algılama · 9. Paywall'ı kapatana tek seferlik teklif · 10. **Türk mikro içerik üretici programı** (YDS/YKS öğretmenleri, "kelime" hesapları; performans bazlı ödeme + Spark Ads hakkı) · 11. Kısa (5–9 sn), sessiz, metin bindirmeli videolar ("akıllı görünme kelimeleri", "YDS'de herkesin yaptığı hata") · 12. Yüzsüz "günün kelimesi" slayt gösterileri (ucuz ikinci kanal) · 13. Sınav kümelerine özel CPP'ler · 14. "Bizi nereden duydun?" anketi (içerik üreticisi atfı için) · 15. Seri + seri dondurma + "hedefime söz veriyorum" CTA'sı.

- **TikTok/Reels gerçekleri [D]:** dil öğrenme nişinde öne çıkan videoların %46'sı konuşan kafa, %31'i uygulama demosu, %16'sı sessiz UGC, slayt gösterisi sadece %6.
- **TR erişimi [D]:** TikTok'ta 44,9M, Instagram'da 62,3M yetişkin.
- **UGC maliyeti [T]:** TR'de video başına ₺500–750 örnekleri görülüyor. Global: 75–500 $ veya 1.000 izlenme başına ~2 $.
- **Apple Ads [D]:** ABD Eğitim CPT 1,52 $, CPI 2,91 $ · TR CPI ~1,02 $. Başlangıç bütçe dağılımı: marka %5–10 · rakip %20 · genel %40 · keşif %30. **Sadece araştırma amaçlı ve kanıtlanmış terimlerde.**
- **Puan istemi:** sadece sistem API'si. Yılda 3 kez gösterilebiliyor. Başarı anında tetiklenir: 3. gün sonrası + (7 günlük seri **veya** %80+ quiz **veya** 10. öğrenilen kelime). Kendi "beğendin mi?" filtresini koyma (5.6.1).
- **Sonraki pazarlar:** Brezilya ve Meksika (yerelleştirilmiş başlıklarla Monkey Taps BR'de #12, MX'te #18) · Vietnam ve Kazakistan/Rusça (Orbit'in kanıtladığı talep).

---

## 11. Türkiye: hesap, şirket, vergi, KVKK

> Ayrıntı (karşılaştırma tabloları, mevzuat referansları, SMMM'ye sorulacak 12 soru, hafta hafta kontrol listesi): [`raporlar/09_turkiye_hukuk_vergi_butce.md`](raporlar/09_turkiye_hukuk_vergi_butce.md) · **Bu bölüm hukuki/vergi tavsiyesi değildir. [TEYİT]**

### 11.1 Karar ağacı

```
Zaten Ltd./A.Ş.'n var mı?
├─ EVET → Apple KURUMSAL hesap (D-U-N-S, kurumsal e-posta + çalışan web sitesi)
│         Kurumlar vergisi %25 · asgari KV %10 · "yazılım ihracatı" indirimi (%100) App Store için TARTIŞMALI
│         Mükerrer 20/B KULLANILAMAZ
└─ HAYIR (tek kurucu) → Şahıs + GVK Mükerrer 20/B (önerilen başlangıç)
          • Apple BİREYSEL hesap (satıcı adı = yasal adın)
          • Vergi dairesinden istisna belgesi · TR bankasında özel hesap · IBAN 1 ay içinde bildirilir
          • Banka hasılattan %15 NİHAİ stopaj keser · KDV yok · fatura yok · gider düşülmez
          • 2026 sınırı 5.300.000 TL (aşılırsa o yılın tamamı beyan edilir)
          • 18–29 yaşında ve ilk kez mükellefsen: genç girişimci istisnası (400 bin TL, 3 yıl), normal tarifede
          • Ortak/yatırımcı gelirse, gelir sınıra yaklaşırsa ya da kurumsal satıcı adı istenirse → Ltd.'ye geçiş
```

### 11.2 Bilinmesi gereken tuzaklar

- **AB DSA "trader" beyanı:** bireysel hesapta **adres, telefon ve e-posta 27 AB ülkesinin ürün sayfalarında herkese açık görünür**. Ev adresi yerine ofis veya coworking adresi (belgeli) kullan.
- **Apple kaydı:** Mayıs–Ağustos 2026'da TR'den ödeme reddi ve kimlik doğrulama sorunları bildirildi (ör. Türkçe karakterli isimler) → **2–4 hafta tampon**. Kimlikteki yazımla birebir aynı yaz. TR üyelik bedeli Aralık 2025'te 1.029 TL olarak bildirildi.
- **Paid Apps Agreement + banka + W-8BEN** tamamlanmadan abonelik satılamaz. W-8BEN'de Madde 7 (ticari kazanç) mı Madde 12 (telif, %10) mı sorusu [TEYİT].
- **Küçük İşletme Programı'na başvur** → %15 komisyon.
- **Nakit akışı:** Apple mali ay sonundan sonra **45 gün içinde** öder. İlk para lansmandan ~6–10 hafta sonra gelir.
- **TR dijital hizmet vergisi:** 01.01.2026'dan itibaren %5, 2027'de %2,5. Apple bunu geliştirici gelirine yansıtıyor.
- **"Yazılım ihracatı" indirimi:** Cumhurbaşkanı Kararı 11257 (30.04.2026) ile oran %100 oldu. Ancak **GİB 30.01.2026 özelgesine** göre TR kullanıcısı da olan uygulama "münhasıran yurt dışı" şartını karşılamıyor. Danıştay 3. D. 21.10.2025 kararı (Google Play, KDV) ise lehte.
- **Bağ-Kur:** 2026'da aylık ~₺11,4–11,8 bin. 20/B ile birlikte 4/b yükümlülüğü doğup doğmadığı belirsiz [TEYİT]. Genç girişimci prim desteği 2026'da kaldırıldı.

### 11.3 KVKK / GDPR / Apple gizlilik

- **Aydınlatma metni + ayrı açık rıza metni** (analitik için). Kurul İlke Kararı 18.02.2026/347: iki metin ayrı olmalı, "okudum ve anladım" ifadesi kullanılmalı.
- **Yurt dışına aktarım (m.9):** RevenueCat, PostHog, Sentry gibi hizmetler için standart sözleşme imzalanmalı ve **5 iş günü içinde KVKK'ya bildirilmeli**. Minimum ve takma adlı veri kullanılmalı.
- **VERBİS:** <50 çalışan ve <100M TL bilanço ise büyük olasılıkla muaf [TEYİT].
- **GDPR:** AB kullanıcısı varsa m.27 AB temsilcisi gerekebilir (yılda ~420–4.750 €) [TEYİT].
- **Apple:** analitik izni ücretli özelliğe şart koşulamaz (5.1.1(ii)) · gizlilik etiketleri SDK'ları da kapsar · çocuk kategorisi seçilmez (13+ konumlandırma).

### 11.4 Marka

TÜRKPATENT sınıf 9 + 41 (+42): itiraz yoksa 6–12 ay; ücretler kaynaklarda çelişkili, resmi tarifeden kontrol edilmeli. EUIPO 1. sınıf 850 €. USPTO sınıf başına 350 $ ve yabancılar için ABD'li avukat zorunlu. **Ad seçmeden önce tarama yapılmalı.**

---

## 12. Bütçe

> Kur: 1 $ ≈ 49 TL (Ekim 2026). Vergiler hariç. [T] = tahmin, teklif alınmalı.

### 12.1 Tek seferlik (lansmana kadar)

| Kalem | Düşük | Orta | Yüksek |
|---|---|---|---|
| Apple Developer (yıllık) | 99 $ | 99 $ | 99 $ |
| Şirket/mükellefiyet kuruluşu | 165 $ (şahıs) | 570 $ (Ltd.) | 650 $ |
| Cihaz (Mac + test iPhone) | 100 $ (mevcut) | 1.440 $ | 2.700 $ |
| Tasarım (ikon, ekranlar, mağaza görselleri) | 100 $ | 500 $ [T] | 2.500 $ [T] |
| Hukuki metinler (+ KVKK avukatı) | 119 $ | 364 $ | 1.500 $ |
| Marka tescili | 205 $ (TR) | 410 $ (TR, vekilli) | 2.800 $ (TR + AB + ABD) |
| İçerik üretimi (LLM + TTS) | 20 $ | 150 $ | 600 $ |
| **İnsan içerik denetimi (120–150 saat)** [Ç: eklendi] | 600 $ (kurucu + gönüllü) | **2.000 $** | 3.800 $ |
| Domain, e-posta, web sitesi | 12 $ | 100 $ | 150 $ |
| Pazarlama testi (UGC + Apple Ads) | 400 $ | 1.500 $ | 8.000 $ |
| AB temsilcisi | 0 | 0 | 1.100 $ |
| Yedek (%15–20) | ~270 $ | ~1.070 $ | ~4.800 $ |
| **Toplam** | **≈ 2,1 bin $ (~100 bin TL)** | **≈ 8,2 bin $ (~400 bin TL)** | **≈ 28,7 bin $ (~1,4M TL)** |

### 12.2 Aylık sabit gider (lansman sonrası)

| | Düşük | Orta | Yüksek |
|---|---|---|---|
| Bağ-Kur (geçerliyse) | ~235 $ | ~235 $ | ~235 $+ |
| Muhasebe (SMMM) | 30 $ | 92 $ | 163 $ |
| Altyapı + araçlar + LLM bakım | 5 $ | ~70 $ | ~325 $ |
| Pazarlama | 100 $ | 500 $ | 3.000 $ |
| **Toplam** | **≈ 370 $** | **≈ 900 $** | **≈ 3,8 bin $** |

**Başa baş [Ç]:** ~370 $/ay sabit gider, yılda ~4,4 bin $ ediyor. Bunu karşılamak için yılda ya **~150 ABD yıllık abonesi** (39,99 $ × Apple %15 × stopaj %15 sonrası ≈ 29 $) ya da **~400 TR yıllık abonesi** gerekir (₺899,99'dan KDV %20, DST %5, Apple %15 ve stopaj %15 düşülünce ≈ 10,5 $). TR tek başına sabit gideri zor karşılar; global İngilizce öğrenici kitlesi şart.

---

## 13. Yol haritası ve 12 haftalık sprint planı

> Ayrıntı (hafta hafta 4 paralel iş akışı, lansman haftası gün gün, kesme sırası, ekip seçenekleri): [`raporlar/10_yol_haritasi_sprint.md`](raporlar/10_yol_haritasi_sprint.md)

### 13.1 Fazlar

| Faz | Zaman | Hedef | Kapı |
|---|---|---|---|
| **0: Doğrulama** | H1–2 (12–25 Eki) | Talep ve kama testi: açılış sayfası + bekleme listesi, sahte fiyat butonu, 14 TikTok/Reels videosu (EN+TR), 8–10 görüşme, widget teknik denemesi | **G0 (25 Eki):** 5 koşuldan 3'ü (açılış sayfası→e-posta ≥%8–12; e-posta bırakanların ≥%30'u ücretli plana tıklıyor; ≥1 video 30 bin+ izlenme; görüşülenlerin ≥6'sı yükler; yorumlarda ≥3 açık doğrulandı) |
| **MVP** | H3–9 | App Review'dan geçen, para kazanan v1.0 | **G1 (20 Kas)** tüm özellikler tamam · **G2 (1 Ara)** incelemeye gönderim · **G3 (10 Ara)** sessiz lansman |
| **Lansman** | H10 | **15 Ara tam lansman** | – |
| v1.1 | 28 Ara – 11 Oca | Yeni Yıl dalgası: +500–1.500 kart (toplam 4.000), Quiz/Göster widget'ı, büyük widget, paylaşım kartları, paywall testleri 1–3 | D7 ≥%10, puan ≥4,4 |
| v1.2 | Oca–Şub | FSRS-6, CloudKit senkronu, 2. çeviri katmanı (RU veya VI veya ES, veriye göre), nöral ses, win-back teklifleri | D30 ≥%5 |
| v1.3 | Şub–Mar | Seviye testi, istatistik paneli, Kontrol Merkezi, ömür boyu ve haftalık testleri, YÖKDİL alan paketleri | Yüklemeden ödemeye ≥%2,5 |
| v1.4–1.5 | Mar–May | 9–11,5 bin kart, öğrenme yolları ("30 günde B1→B2"), Watch komplikasyonu | – |
| **v2** | Haz–Eyl 2027 | **Android (Kotlin + Glance)**, YZ "bağlam içinde açıkla", 5+ arayüz dili | LTV:CAC ≥3 veya ≥10 bin $ MRR |
| **v3** | 2028 | B2B/okullar (sınıf kodu), İngilizce dışı hedef diller (Hourly Kana modeli) | ≥3 okul talebi |

### 13.2 12 haftalık özet (H1 = 12 Ekim 2026)

| Hafta | iOS | Tasarım | İçerik | Büyüme |
|---|---|---|---|---|
| H1 (12–18 Eki) | **Apple hesabı + Paid Apps Agreement + banka + vergi formu (kritik yol)**, Küçük İşletme Programı, Xcode projesi (App + Widget + Intents + App Group), **widget teknik denemesi** (3 cihazda 24 girişli zaman çizelgesi) | Rakip ekranları, moodboard, 3 marka yönü | Kaynak/lisans denetimi, şema, prompt v0, 50 kartlık pilot | Hesaplar, açılış sayfası, 7 video, görüşmeler |
| H2 (19–25 Eki) | Veri katmanı, CSV→SQLite aracı, analitik sarmalayıcı, sandbox IAP | Tasarım sistemi, kart ve widget hi-fi | 300 kartlık pilot + TR denetimi | 7 video daha, sahte fiyat butonu → **G0** |
| H3 (26 Eki–1 Kas) | Akış, kart, filtreler, durumlar, deep link | Onboarding, paywall v1, ikon | 1.000 kart + üretim hattı | **Ad kararı (D4)** + marka/domain taraması |
| H4 (2–8 Kas) | Üretim widget'ları (küçük/orta/kilit), tema motoru → **ilk iç TestFlight** | Son ikon, widget görselleri | 1.800 kart | ASO taslağı, beta listesi (30–50 kişi) |
| H5 (9–15 Kas) | Quiz, Leitner, bildirimler, onboarding, Sonraki/Biliyorum intent'leri | Quiz, ayarlar, boş durumlar | **2.500 kart → içerik dondurma v1** | 1–2 video/gün |
| H6 (16–22 Kas) | Paywall (RevenueCat), analitik olayları, yasal metinler, Widget Sağlığı → **G1 + dış beta** | Paywall varyantları | TR arayüz metinleri, TR mağaza metni, gizlilik politikası/şartlar | Basın kiti, içerik üretici listesi |
| H7 (23–29 Kas) | Hata ayıklama, erişilebilirlik, **widget QA matrisi** (≥10 cihaz/iOS, Düşük Güç Modu, Arka Plan Yenileme kapalı) | Son ekran görüntüleri, önizleme videosu | Öğretmen 300 kartlık örneği denetler | İçerik üreticisi 1. dalga (teklif kodları) |
| H8 (30 Kas–6 Ara) | RC → **1 Ara gönderim (G2)** | Ret durumuna hazır | v1.1 içerik partisi başlar | Bekleme listesine e-posta |
| H9 (7–13 Ara) | İnceleme tamponu → **10 Ara sessiz lansman** | PPO varyantları | +500 kart | Anahtar kelime indeksleme kontrolü |
| H10 (14–20 Ara) | Düzeltmeler | – | – | **15 Ara tam lansman**: içerik üreticileri, Reddit/TR toplulukları, Telegram YDS grupları, bekleme listesi |
| H11 (21–27 Ara) | v1.0.2 düzeltmesi, v1.1 geliştirmesi | PPO | Hata bildirimlerine 48 saatte yanıt | Paywall deneyi #1, 2. dalga |
| H12 (28 Ara–3 Oca) | **v1.1 gönderimi** | Yeni Yıl görselleri | "30 Günlük Meydan Okuma" | In-App Event, Yeni Yıl kampanyası → **G4 (4 Oca)** |

**B planı:** G2 ≥1 hafta kayarsa tam lansman **5 Ocak** (Yeni Yıl kararlılık zirvesi); 2 hafta kayarsa 12 Ocak. 22 Aralık – 1 Ocak arası yeni özellik gönderilmez.

### 13.3 Ekip [Ç]

**Önerilen: B modeli.** Kurucu (iOS + ürün) + **büyüme/içerik generalisti** (TikTok'a yatkın, TR/EN) + yarı zamanlı tasarımcı (H1–8, haftada 10–15 saat) + serbest Türkçe dil uzmanı / İngilizce öğretmeni (20–40 saat).
**Dışarı verilmeyecekler:** widget/WidgetKit kodu, analitik, paywall mantığı, marka sesi ve hesap sahipliği.

---

## 14. KPI'lar, analitik ve deney planı

### 14.1 Kuzey yıldızı

**Haftalık Aktif Widget Öğrenicisi (WAWL):** son 7 günde ≥1 widget'ı kurulu olan **ve** ≥5 öğrenme eylemi yapan kullanıcı (Biliyorum/Öğreniyorum işaretleme, quiz cevabı, widget Göster/Biliyorum dokunuşu). İş metrikleri bunun yanında izlenir: MRR, aktif deneme, yükleme başına net gelir.

### 14.2 Huni hedefleri (ilk ~1.000 yüklemeyle kalibre edilecek)

| Aşama | Hedef |
|---|---|
| Ürün sayfası → yükleme | ≥%25 (Eğitim iOS ortalaması ~%16,8) |
| Onboarding tamamlama | ≥%70 |
| Bildirim izni | ≥%55 |
| **İlk 24 saatte widget kurulumu** | ≥%30 (iddialı hedef %45) |
| Paywall görüntüleme → deneme | ≥%8–12 |
| Yükleme → deneme (D30) | ≥%6,5 (hedef %8–12) |
| Deneme → ödeme | ≥%30 (iddialı hedef %35–40) |
| Yükleme → ödeme (D35) | %2–4 |
| D1 / D7 / D30 (tüm yüklemeler) | ≥%30 / ≥%14 / ≥%6 |
| Widget kurmuş kullanıcıların D30'u | ≥%15 |
| İade oranı | ≤%4 |
| Çökmesiz oturum | ≥%99,5 |
| App Store puanı | ≥4,5 |

**30. gün karar ağacı:** yüklemeden denemeye <%4 → paywall/konumlandırma sorunu · D1 <%20 → ilk oturum/içerik sorunu · widget kurulumu <%20 → rehber sorunu · denemeden ödemeye <%25 → deneme sırasında değer hissedilmiyor · iade >%5 → fiyat/ödeme metni net değil.

### 14.3 Olay planı (44 olay; tam liste raporda)

Gruplar: Yaşam döngüsü (5) · Onboarding (10) · İzinler ve widget (12; `widget_installed_detected`, `widget_action_tapped`, `widget_refresh_report` kritik) · Öğrenme (6) · Quiz/etkileşim (6) · Monetizasyon (5) + sunucu tarafı RevenueCat webhook'ları (deneme, dönüşüm, yenileme, iade).
Her olaya eklenen ortak özellikler: `anon_id`, `storefront_country`, `native_language`, `cefr_level`, `plan_state`, `has_widget`, `widget_count`, `experiment_flags`, `content_version`. IDFA ve kişisel veri yok.

### 14.4 İlk 10 deney (öncelik sırasıyla)

| ID | Test | Birincil metrik (koruma metriği) |
|---|---|---|
| E-01 | Yumuşak (varsayılan) / sert / sert + teklif paywall | D14 yükleme başına gelir (puan, D1) |
| E-02 | Yıllık 29,99 / 39,99 / 49,99 $ | Paywall görüntüleme başına gelir |
| E-03 | 3 / 7 gün deneme / denemesiz | Denemeden ödemeye (iade) |
| E-04 | Paywall yeri: widget rehberinden önce / sonra / ilk widget kurulumundan sonra | Yüklemeden denemeye (onboarding tamamlama) |
| E-17 | **TR fiyatı ₺599,99 / ₺899,99 / ₺1.299,99** | TR'de paywall başına gelir |
| E-06 | Widget istemi: onboarding adımı / banner / ikisi | 24 saatte widget kurulumu |
| E-07 | Plan seti: yıllık + aylık + ömür boyu / + haftalık / sadece yıllık | Yüklemeden ödemeye (ödeyen başına ortalama gelir) |
| E-09 | Paywall tasarımı: özellik listesi / widget önizlemesi / deneme zaman çizelgesi | Denemeden ödemeye, iade |
| E-14 | Varsayılan widget: kelime + tanım / sadece kelime + "dokun, göster" | WAWL, widget dokunma oranı |
| E-16 | Mağaza sayfası: önce widget / önce öğrenme sonucu / TR'ye özel ekranlar | Ürün sayfasından yüklemeye |

> **Örneklem gerçeği:** %8 temel oranda %25 göreli artışı yakalamak için kol başına ~2.900 kullanıcı gerekir. Önce büyük farkları test et; aynı anda tek paywall deneyi; Bayesçi okuma (≥%90).

---

## 15. Risk kaydı

| # | Risk | Olasılık / Etki | Önlem |
|---|---|---|---|
| R1 | **4.3 ret veya kaldırma** (doygun kategori, 08.06.2026 sertleşmesi) | O / Y | Özgün marka + etkileşimli widget + SRS + TR katmanı · tek uygulama · düzenli anlamlı güncelleme · net inceleme notları |
| R2 | Widget güncellenmiyor / bayat kalıyor | O / Y | 48 saatlik çizelge, ağ yok, arka plana geçerken yenileme, bayatlık telemetrisi, Widget Sağlığı ekranı |
| R3 | İçerik lisansı / fikri mülkiyet | O / Y | Açık lisanslı listeler, özgün metin, kaynak kaydı, atıf ekranı, sınav markalarını adda kullanmama |
| R4 | Doygunluk / yüksek edinim maliyeti | Y / Y | Organik öncelik, TR kaması, ASO uzun kuyruğu, içerik üreticileri; G4 kuralına kadar ücretli reklam yok |
| R5 | İade ve fatura şikâyetleri | O / O | Haftalık plan yok, çalışan hatırlatıcı, net metin, kolay iptal |
| R6 | Yanlış tanım/çeviri → 1★ | O / O | Üretim hattı + eleştirmen + insan denetimi + "hata bildir" + CDN üzerinden hızlı düzeltme |
| R7 | Novelty sonrası tutundurma uçurumu | Y / Y | SRS rotasyonu, etkileşimli widget, seri, bildirimler, v1.2 derinliği |
| R8 | TikTok viralliğine bağımlılık | Y / Y | Çok kanallı dağıtım, e-posta listesi, TR toplulukları, ASO, tekrarlanabilir video formatları |
| R9 | TR fiyatı ve kur | Y / O | Ülke bazında elle fiyat, aylık gözden geçirme, E-17 testi |
| R10 | Tek kişilik geliştirmede kayma / tükenmişlik | Y / O | Kesme sırası, 5 Ocak B planı, B ekip modeli |
| R11 | **Orbit veya Monkey Taps TR + YDS'yi kopyalar** | O / O | Hız, içerik derinliği (YDS eş anlamlı kümeleri, tuzak kelimeler), TR toplulukları, marka |
| R12 | Apple hesap/ödeme kurulum gecikmesi (TR'ye özgü sorunlar) | O / Y | 1. hafta başla, 2–4 hafta tampon |
| R13 | KVKK / GDPR uyumsuzluğu | O / O | Minimum veri, açık rıza, standart sözleşme bildirimi, avukat kontrolü |
| R14 | Hassas içerik → yaş derecesi / şikâyet | D / O | Hassasiyet 2 hiç yok, 1 sadece etiketli kategoride, kilit ekranında güvenli ilk örnek |
| R15 | Tatil dönemi inceleme gecikmesi | O / O | 1 Aralık gönderimi, 22 Ara – 1 Oca arası özellik gönderme yok |
| R16 | Widget'tan ses / kilit ekranı butonları beklendiği gibi çalışmıyor | O / D | Çekirdek özellik yapma, cihazda test et |

---

## 16. Karar kaydı (önerilen varsayılanlar)

| # | Karar | **Önerim** | Ne zamana |
|---|---|---|---|
| D1 | Native mi cross-platform mu | **Native SwiftUI, iOS 17+, sadece iPhone** | H1 |
| D2 | Paywall modeli | **Yumuşak paywall + çalışan ücretsiz widget; sert paywall E-01'de test** | H3 |
| D3 | ABD fiyatı | **39,99 $/yıl (7 gün), 7,99 $/ay, 79,99 $ ömür boyu**; haftalık yok | H5 |
| D3b | TR fiyatı | **₺899,99/yıl, ₺149,99/ay, ₺1.999,99 ömür boyu** + E-17 | H5 |
| D4 | Ad | **Lockglow** (kurucu seçti, 2026-10-11; §4.4). Kesinleşmeden önce TÜRKPATENT araması (9, 41, 42. sınıflar) ve marka vekili görüşü. ~~Wordglance~~ marka taramasından geçemedi | H3 |
| D5 | Kategori | Education + Reference | H4 |
| D6 | Diller | **EN + TR arayüz, TR çeviri katmanı.** 2. katman (RU/VI/ES) v1.2'de veriye göre | H5 |
| D7 | Abonelik altyapısı | **RevenueCat** | H1 |
| D8 | Backend | Yok (MVP) → v1.1'de içerik için CDN | H1 |
| D9 | Analitik | PostHog (AB bulutu) + Sentry/MetricKit, rızaya bağlı | H2 |
| D10 | İçerik | Açık listeler + Claude ile özgün taslak + insan denetimi + kaynak kaydı | H1 |
| D11 | Ses | AVSpeech (MVP) → nöral ses v1.2 | H4 |
| D12 | Hesap türü | Şirket yoksa **şahıs + 20/B + bireysel hesap** (DSA adresi için ofis adresi) [TEYİT] | H1 |
| D13 | Lansman | **10 Ara sessiz, 15 Ara tam, 28 Ara v1.1**; B planı 5 Oca | H6 |
| D14 | Ücretli reklam | G4 kuralı sağlanmadan yok | G4 |
| D15 | Reklam/ATT | **Yok** | H1 |
| D16 | Hesap/giriş | Yok (MVP), CloudKit v1.2 | H1 |
| D17 | Ekip | **B modeli** (kurucu + büyüme/içerik generalisti) | H1 |

---

## 17. Önümüzdeki 7 gün: yapılacaklar

1. **Apple Developer kaydı** (veya mevcut hesabı doğrula) → Paid Apps Agreement, banka (USD hesap, İngilizce karakterlerle), W-8BEN, Küçük İşletme Programı. *Kritik yol, hemen başla.*
2. **SMMM ile 1 saatlik görüşme** (§11 ve 09 raporundaki 12 soru) → şahıs + 20/B ya da mevcut şirket kararı.
3. **Ad kısa listesi için tarama:** App Store, TÜRKPATENT, EUIPO, USPTO, .com/.app, Instagram/TikTok kullanıcı adları.
4. **Widget teknik denemesi:** App Group + 24–48 girişli zaman çizelgesi + "Sonraki" intent'i. 3 fiziksel cihazda, Release yapılandırmasıyla.
5. **İçerik pilotu:** 50 kartı 3 prompt'la üret ([07 raporu §6](raporlar/07_icerik_stratejisi.md)), 25 kartlık [örnek setle](veri/ornek_kelime_seti_25.json) karşılaştır. Bir Türkçe/İngilizce dil uzmanı bul.
6. **Faz 0 doğrulaması:** açılış sayfası + bekleme listesi + sahte fiyat butonu. 7 kısa video (EN + TR): "YDS'de herkesin karıştırdığı 5 kelime", "aktüel ≠ actual".
7. **Rakipleri bizzat incele:** Orbit ve Monkey Taps'i indir, onboarding ve paywall akışlarını ekran kaydıyla belgele, widget yenileme davranışını 48 saat gözlemle.

---

## 18. Ekler: rapor dizini ve kaynaklar

### 18.1 Ajan raporları (`raporlar/`)

| Dosya | İçerik | Boyut |
|---|---|---|
| [01_appstore_profile.md](raporlar/01_appstore_profile.md) | Orbit uygulamasının tam profili: metadata, 30 ülkede fiyat, sürüm geçmişi, gizlilik, geliştirici, Android, tahminler | ~380 satır |
| [02_review_mining.md](raporlar/02_review_mining.md) | Yorum madenciliği: Orbit + 9 rakip, temalar, istekler, Reddit, 15 ders | ~440 satır |
| [03_rekabet_haritasi.md](raporlar/03_rekabet_haritasi.md) | 32 uygulama, özellik matrisi, fiyat tablosu (USD/TRY), gelir tahminleri, Monkey Taps'in oyun kitabı, klon dalgası | ~600 satır |
| [04_teknik_mimari.md](raporlar/04_teknik_mimari.md) | WidgetKit, veri katmanları, SRS, lisanslar, LLM maliyeti, StoreKit, gizlilik, App Review | ~640 satır |
| [05_buyume_gelir_modeli.md](raporlar/05_buyume_gelir_modeli.md) | Onboarding teardown, paywall kıyasları, TR fiyatları, edinim, birim ekonomisi, hukuk, 20 taktik | ~450 satır |
| [06_ux_ui_widget_tasarim.md](raporlar/06_ux_ui_widget_tasarim.md) | Ekran envanteri, 17 adımlı onboarding (EN/TR), widget spesifikasyonları, tasarım sistemi, erişilebilirlik | ~1.230 satır |
| [07_icerik_stratejisi.md](raporlar/07_icerik_stratejisi.md) | 60 kategori, şema, editoryal kurallar, 3 prompt, rubrik, 25 örnek kart | ~1.430 satır |
| [08_aso_isim_metadata.md](raporlar/08_aso_isim_metadata.md) | 170+ anahtar kelime (US/TR/VN/MX/RU/KZ), metadata, isimler, CPP, Apple Ads | ~670 satır |
| [09_turkiye_hukuk_vergi_butce.md](raporlar/09_turkiye_hukuk_vergi_butce.md) | Apple hesabı, 20/B, hizmet ihracatı, KVKK, marka, bütçe, hafta hafta kontrol listesi | ~410 satır |
| [10_yol_haritasi_sprint.md](raporlar/10_yol_haritasi_sprint.md) | Fazlar, MoSCoW, 12 haftalık sprint, 44 olay, 20 deney, 21 risk, karar kaydı | ~640 satır |

### 18.2 Veri ve referanslar

- [`veri/ornek_kelime_seti_25.json`](veri/ornek_kelime_seti_25.json): şema v1.0 ile yazılmış 25 kart (A1 *breakfast* → S *sonder*), TR katmanlı.
- [`referans/orbit_widget_vocabulary_ekranlar/`](referans/orbit_widget_vocabulary_ekranlar/): Orbit'in 8 iPhone + 5 iPad ekran görüntüsü + ikon (sadece iç rakip analizi için; yayınlanmamalı).

### 18.3 Temel kaynaklar (seçme)

- Apple: [iTunes Lookup](https://itunes.apple.com/lookup?id=6775767149&country=tr) · [App Store sayfası](https://apps.apple.com/tr/app/widget-vocabulary-learn-words/id6775767149) · [TR Eğitim listesi RSS](https://itunes.apple.com/tr/rss/topfreeapplications/limit=200/genre=6017/json) · [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) · [Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date) · [Small Business Program](https://developer.apple.com/app-store/small-business-program/) · [DSA trader](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-compliance-information)
- Kıyaslar: [RevenueCat SOSA 2026 – Education](https://www.revenuecat.com/state-of-subscription-apps-2026-education) · [Adapty 2026](https://adapty.io/state-of-in-app-subscriptions-report/) · [AppTweak Apple Ads benchmarks](https://www.apptweak.com/en/aso-blog/apple-ads-benchmarks)
- Tahmin siteleri: [Sensor Tower – Orbit](https://app.sensortower.com/overview/6775767149) · [MWM](https://mwm.ai/apps/widget-vocabulary-learn-words/6775767149) · [AppGoblin – Monkey Taps](https://www.appgoblin.info/apps/1084540807)
- Onboarding incelemeleri: [ScreensDesign – Vocabulary](https://screensdesign.com/apps/vocabulary-learn-words-daily/)
- Apple 4.3 güncellemesi: [MacRumors 09.06.2026](https://www.macrumors.com/2026/06/09/app-store-guidelines-low-quality-apps/)
- TR vergi: [GİB Mükerrer 20/B broşürü](https://www.alomaliye.com/wp-content/uploads/2024/12/2024-icerik-kazanc-istisna.pdf) · [KPMG – 11257 sayılı Karar](https://kpmgvergi.com/yayinlar/mali-bultenler/vergi/bazi-hizmet-ihracati-ve-yurt-disi-istirak-kazanclarina-uygulanan-istisna-ve-indirim-oranlari-artiran-cumhurbaskani-karari-yayimlandi/4481) · [Alomaliye – App Store gelirleri özelgesi](https://www.alomaliye.com/2026/02/18/app-store-ve-google-playden-elde-edilen-gelirler-nasil-vergilendirilir/)
- Sınav sayıları: [ÖSYM – YKS 2026](https://osym.gov.tr/yksye-2-milyon-425-bin-560-aday-basvurdu)
- İçerik lisansları: [NGSL](https://www.newgeneralservicelist.com/new-general-service-list) · [Open English WordNet](https://en-word.net/) · [Wiktionary Copyrights](https://en.wiktionary.org/wiki/Wiktionary:Copyrights)

> **Yöntem notu:** Tüm mağaza verileri 10 Ekim 2026'da canlı olarak Apple'ın kamuya açık uç noktalarından çekildi. Üçüncü taraf gelir/indirme tahminleri birbirleriyle 14 kata kadar çelişiyor; yalnızca büyüklük sırası olarak kullanılmalı. Vergi ve hukuk bölümleri ikincil kaynaklara dayanıyor ve uzman onayı gerektiriyor.
