# Lockglow kelime kartları: Codex için tasarım brifi

> Bu dosya Codex için yazıldı. Kendi başına yeter: depoya erişemesen de işi bu dosyayla yapabilirsin.
> Depo herkese açık: `github.com/yusufuyar68/lockglow`. Aşağıdaki dosya yolları bu depoya göredir.
> Brifteki bilgiler 25 Ekim 2026'daki koddan ve veriden çıkarıldı.

---

## 0. Görevin kısaca

- **Rolün:** Bu işte ürün tasarımcısısın. Lockglow adlı iPhone uygulamasının kelime kartlarını ve widget'larını yeniden tasarlayacaksın.
- **Kod yazmayacaksın.** Swift yazma, depodaki hiçbir dosyayı değiştirme. Çıktın tarayıcıda açılan **mockup'lar** (HTML) ve kısa **açıklamalar** (Markdown).
- **3 tasarım yönü:** Birbirinden gerçekten farklı 3 yön önereceksin: **A, B, C**.
  - Kullanıcı birini seçecek.
  - Seçilen yönü başka bir ekip SwiftUI'a geçirecek. Bu yüzden çizdiğin her şey SwiftUI ve WidgetKit ile kurulabilir olmalı (§4.9).
- **Ayrıca "Yön 0" (bugün):** Bugünkü hâli aynı çerçevelerde çiz. Kullanıcı yeni yönleri bununla karşılaştıracak.
  - Yön 0'ı **düzeltmeden** çiz, kural dışı yerleriyle birlikte. Aykırı yerleri çerçeve notunda "bugün: kural dışı" diye işaretle.
  - Bugün olmayan bir hâlin (ör. widget'ta "Biliyorum" onayı) yerine "bugün yok" notu koy.
  - §12 kontrol listesi Yön 0 için değil, yalnız A, B ve C içindir.
- **İki tur var:**
  - **Tur 1 (çekirdek set):** Akış kartı (yüzey 1), kelime widget'ları küçük, orta ve büyük (yüzey 6–8) ve kilit ekranı (yüzey 9). Bunlar aynı kelimenin farklı yüzleri; aynı dili konuşmalı.
  - **Tur 1'i teslim edince DUR.** README'nin en başına "Tur 1 bitti, yön seçimi bekleniyor." yaz.
  - **Tur 2 (kalanlar):** Kartın tamamı ve "Neden?" (yüzey 2), quiz kartı (3), cümle kurma (4), eşdizim seçme (5), quiz widget'ı (10) ve haftalık özet paylaşım kartı (11).
  - Tur 2'ye **yalnız kullanıcı yeni bir mesajla bir yön seçince** başla. Tur 2 yalnız seçilen yönde yapılır. Yön 0 için Tur 2 çizilmez.
- **Birimler:**
  - "pt" iOS noktasıdır. Mockup'ta 1 pt = 1 CSS px.
  - Paylaşım görselinde 1 pt = 3 görsel pikseli (360×640 pt = 1080×1920 px).
- **İki terim:**
  - **İlk karşılaşma:** Kelimeyi Akış'ta ilk gördüğün gün.
  - **Tekrar karşılaşma:** Kelimeyi Akış'ta daha sonra yeniden görmek. Tekrar sekmesiyle ilgisi yok.

---

## 1. Ürün

- **Ad:** Lockglow, "kilit ekranında parlayan kelime".
- **Ne yapar:** İngilizce kelimeyi kilitli ekranda, ana ekranda ve uygulamada gösterir. Açıklamalar Türkçedir.
- **Platform:** iPhone, iOS 26+, SwiftUI + WidgetKit. Site ya da masaüstü uygulaması değil.
- **Kitle:** Türkçe konuşan, günlük İngilizce öğrenmek isteyen A1–B1 öğrenciler. Kurucu kullanıcının İngilizcesi A2 ve altı; uygulama önce onun için yapılıyor.
- **İçerik:** 1.383 kart, yalnız A1 (192), A2 (580) ve B1 (611).
  - 878'i tek kelime.
  - Geri kalanlar: kalıp fiil 192, kalıp 180, eşdizim 104, deyim 28, atasözü 1.
- **Sekmeler (4 tane):**
  - Akış (`rectangle.stack`)
  - Tekrar (`arrow.triangle.2.circlepath`)
  - Sözlük (`character.book.closed`)
  - Ayarlar (`gearshape`)
- **Ton:** Sakin bir arkadaş.
  - Seri, puan, rozet ve suçlama yok. Günde tek hatırlatma. Az titreşim, az hareket.
  - "Sen" diye hitap eder. Kısa, sade, A2 düzeyinde Türkçe. Ünlem ve övgü yok.
  - Görsel dil "kâğıt ve mürekkep": Apple sistem renkleri ve tek bir fosfor sarısı vurgu.
- **Uygulama ikonu:**
  - Koyu antrasit kare (#1F2328 → #0B0D0F dikey degrade).
  - Ortasında eğik kenarlı, kalın, limon sarısı bir şerit (#F5E829).
  - Şeridin üstünde uzun, altında kısa iki açık gri çizgi.
  - Bütünü "fosforlu kalemle çizilmiş bir satır" gibi görünür.

---

## 2. Çalışma adımları (bu sırayla)

1. **Oku.** Bu brifi baştan sona oku. §4 (kurallar) ve §11 (yasaklar) bağlayıcıdır.
2. **Kodu gör.** Erişebiliyorsan §7'deki dosyalara bak. Erişemiyorsan §7'deki tarifler yeterli.
3. **Yön 0'ı çiz.** Bugünkü Akış kartını ve widget'ları §7'deki tarife göre çiz. Kapsamı §8.1'de yazıyor.
4. **3 yön belirle.** Her yön için şunları yaz:
   - kısa bir ad (ör. "Sessiz sayfa");
   - tek cümlelik ana fikir;
   - bugüne göre neyi değiştirdiği;
   - neyi feda ettiği (her yönün bir bedeli olmalı).

   Üç yön birbirinin renk değişikliği olmasın; hiyerarşi, yoğunluk ya da yerleşimde farklı olsunlar.

   **Sabit olanlar** (hiçbir yön değiştiremez):
   - okuma sırası: kelime → Türkçe anlam → İngilizce tanım → örnek;
   - ilk karşılaşmada en çok 8 blok ve tek uyarı yeri;
   - §4'teki bütün kurallar ve §5'teki renk anlamları.

   **Serbest olanlar:**
   - düğme satırının ve üst bilgi satırının yeri (ör. düğmeler kartın dibine inebilir);
   - blokların kutu, çizgi ya da boşlukla gruplanması;
   - boy hiyerarşisi ve yoğunluk;
   - widget'ta düğme yerleşimi.

   §4.8'deki blok sırası bugünkü sıradır, kural değildir.
5. **Çekirdek seti çiz.**
   - Önce **bir yönü uçtan uca bitir**, sonra diğerine geç.
   - Önce §8.1'deki zorunlu çerçeveleri çiz. Zaman kalırsa §8.2'deki ek hâlleri ekle.
6. **Kendini denetle.** §12'deki kontrol listesini A, B ve C için tek tek uygula. Kural dışı bir şey bulursan düzelt.
7. **Teslim et ve dur.** §3'teki biçimle teslim et. Tur 1 burada biter.
8. **(Kullanıcı yön seçerse) Tur 2.** Kalan yüzeyleri seçilen yönde §7 ve §8.3'e göre çiz, denetle ve teslim et.

---

## 3. Teslim biçimi

### Dosyalar

Depoya yazabiliyorsan **yalnız** `docs/tasarim/codex/` klasörüne yaz, başka hiçbir dosyaya dokunma. Yazamıyorsan aynı yapıyı bir zip olarak ver.

```
docs/tasarim/codex/
  index.html                        yönler arasında geçiş + karşılaştırma tablosu
  yon-0-bugun.html                  bugünkü hâl (Tur 1 kapsamı)
  yon-a-<kisa-ad>.html              Tur 1
  yon-b-<kisa-ad>.html              Tur 1
  yon-c-<kisa-ad>.html              Tur 1
  yon-<harf>-<kisa-ad>-tur2.html    Tur 2, yalnız seçilen yön
  README.md                         açıklamalar (aşağıda)
```

### HTML kuralları

- **Tek dosya:** Her HTML tek dosya olsun. İnternetten yüklenen kaynak (CDN, web yazı tipi, uzak görsel) kullanma. Dosyalar arası göreli bağlantılar serbest.
- **Yazı tipleri:**
  - Türkçe arayüz: `font-family: -apple-system, "SF Pro Text", system-ui, sans-serif;`
  - İngilizce kelime ve cümle: `font-family: ui-serif, "New York", Georgia, serif;`
- **Windows'ta açılacak:** Mockup'lar Windows bilgisayarda da açılacak. Orada yazılar Segoe UI ve Georgia görünür; satır kırılımları değişir.
  - Kritik satır bölümlerini `<br>` ile sabitle (ör. "Could you tell / me the way to", iki satırlık anlam).
  - En sıkı çerçevelerde (SE, AX5, widget) yatayda biraz pay bırak.
  - README'ye "satır kırılımları SF Pro / New York'a göre yaklaşıktır" notunu yaz.
- **SF Symbols:**
  - Her simgeyi basit bir satır içi SVG ile çiz.
  - Adını çerçevenin içine yazma; gerçek boyutlu çerçeveyi bozar. Adı SVG'ye `data-sf="speaker.wave.2"` ve `<title>` olarak ekle.
  - Çerçevenin altındaki ölçü notunda da listele.
- **Çerçeve etiketi:** Her çerçevenin **üstünde** küçük bir etiket olsun: yüzey · hâl · mod · cihaz · yazı boyu.
  - Örnek: `Akış kartı · İlk karşılaşma · Koyu · iPhone SE · AX5`
- **Ölçü notu:** Her çerçevenin **altında** kısa bir not olsun:
  - kullanılan Dynamic Type stilleri;
  - renk token'ları;
  - SF Symbols adları.
- **Açık/koyu:** Sayfada bir açık/koyu düğmesi olsun. Zorunlu çerçevelerde istenen modlar (§8.1) ayrı çerçeve olarak da görünsün.
- **Kayan sayfa:** AX5'te Akış ya da kartın tamamı gibi kayan bir sayfayı uzun bir çerçeve olarak çiz.
  - Genişlik aynı kalır, boy içerik kadar uzar.
  - 844 pt hizasına (SE'de 667) kesik bir "ekran sınırı" çizgisi koy.
  - Sekme çubuğunu ilk ekranın dibine sabitle.

### Çerçeve ölçüleri

| Çerçeve | Boy (pt) | Not |
|---|---|---|
| iPhone (ana) | 390×844 | Üst güvenli alan 47, alt 34 (ana ekran çubuğu). Üstte çentik ya da Dynamic Island çizebilirsin. |
| iPhone SE | 375×667 | Üst 20, alt 0. Dynamic Island yok. |
| Küçük widget | 158×158 · SE 148×148 | İçerik kenar boşluğu 16 → içerik ~126×126 · SE ~116×116 |
| Orta widget | 338×158 · SE 321×148 | İçerik ~306×126 · SE ~289×116 |
| Büyük widget | 338×354 · SE 321×324 | İçerik ~306×322 · SE ~289×292 |
| Kilit ekranı dikdörtgen | 160×72 · SE 153×68 | Kenar boşluğunu sistem verir |
| Kilit ekranı satır içi | 234×26 | Tek satır metin, saatin üstünde |
| StandBy | Küçük widget boyu, yatay telefonda iki widget yan yana | Siyah zemin |
| Paylaşım görseli | 360×640 (1080×1920 px) | 9:16 hikâye biçimi |

- **Uygulama ekranları:** Alttaki sekme çubuğunu göster: iOS 26'nın yüzen cam sekme çubuğu, §1'deki 4 sekme ve simgeleri.
- **Widget'lar:** Bir ana ekran ya da kilit ekranı zemininin üstünde göster. Kilit ekranı için koyu bir duvar kâğıdı ve büyük saat kullan.

### README.md içeriği

**Her yön için:**
1. Ad ve tek cümlelik fikir
2. Bugüne göre ne değişti (madde madde)
3. Neyi feda ettin, neden
4. Kullanılan yazı stilleri: Dynamic Type stil adıyla, punto yazarak değil (ör. "Türkçe anlam: Title 1 kalın")
5. Kullanılan renk token'ları (§5'teki adlarla). Yeni token eklediysen açık, koyu ve Yüksek Kontrast hex değerleriyle.
6. Kontrolünü yaptığın renk çiftleri ve kontrast oranları
7. Önerdiğin yeni Türkçe metinlerin listesi (§4.6 kurallarına uygun)
8. §10'daki sorulara cevapların
9. Riskler: SwiftUI'da ya da WidgetKit'te zor olabilecek yerler
10. §12 kontrol listesinin sonucu

**`index.html` içindeki karşılaştırma tablosu:**
- Satırlar: okunurluk, sakinlik, SE'ye sığma, AX5'e uyum, widget ile tutarlılık, SwiftUI'a geçirme zorluğu.
- Sütunlar: Yön 0, A, B, C.
- Her hücreye kısa bir puan ve bir cümle yeter.

---

## 4. Değişmez kurallar

Bunlar kullanıcının açık isteği. A, B ve C bunlara uymak zorunda.

### 4.1 Apple dili
- **Apple Human Interface Guidelines'tan ayrılma.**
  - Gezinmede büyük başlık kullan.
  - Alt sekme çubuğunda SF Symbols kullan.
  - Ayarlar ve listelerde iOS'un gruplu liste görünümünü kullan.
  - İkinci derece sayfaları sheet olarak aç.
  - Onaylarda iOS uyarısı kullan.
  - Standart denetimleri tercih et.
- **Mockup'lar mobildir:** telefon çerçevesinde ya da widget boyutlarında. Masaüstü ya da web düzeni yok.

### 4.2 Yazı
- **Yazı boyları Dynamic Type metin stillerinden gelir.** Sabit punto yazma.

| Stil | Varsayılan (L) | xxxLarge | AX1 | AX3 | AX5 (en büyük) |
|---|---|---|---|---|---|
| Large Title | 34 | 40 | 44 | 52 | 60 |
| Title 1 | 28 | 34 | 38 | 48 | 58 |
| Title 2 | 22 | 28 | 34 | 44 | 56 |
| Title 3 | 20 | 26 | 31 | 43 | 55 |
| Headline (kalın) / Body | 17 | 23 | 28 | 40 | 53 |
| Callout | 16 | 22 | 26 | 38 | 51 |
| Subheadline | 15 | 21 | 25 | 36 | 49 |
| Footnote | 13 | 19 | 23 | 33 | 44 |
| Caption 1 | 12 | 18 | 22 | 32 | 43 |
| Caption 2 | 11 | 17 | 20 | 29 | 40 |

  Değerler Apple'ın iOS Dynamic Type tablosundan alındı. Ondan farklıysa Apple'ın tablosu esastır.
- **Bir ekranda en çok 3–4 farklı metin boyu olur.** Hiyerarşiyi boy ve kalınlıkla kur.
- **Hiçbir yerde 11 pt'nin altına inme.**
- **Yazı aileleri:**
  - Türkçe arayüz SF Pro ile yazılır.
  - İngilizce kelime ve örnek cümle New York (serif) ile yazılabilir.
  - Üçüncü bir yazı ailesi yok.
  - Türkçeyi serif yazma.
- **Ağırlık:** En kalın ağırlıkları (Heavy, Black) metinde kullanma.
- **Biçim:** İtalik yok. Çok satırlı metin sola dayalı olur.

### 4.3 Renk
- **Anlamsal renk mantığı:**
  - Metin üç kademeyle yazılır: label (`ink`), secondaryLabel (`ink2`), tertiaryLabel (`ink3`).
  - Zeminler systemBackground ve secondarySystemBackground'dur. Ayraçlar separator'dır.
- **Tek vurgu rengi marka sarısıdır.** Yalnız vurgu için kullanılır, büyük dolgu yapmaz.
  - Sarı yalnız iki yerde olur: öğrenilecek İngilizce kelimenin **şeridi** ve örnek cümlede **aynı kelimenin işareti**.
  - Düğmelerin, seçili öğelerin ve ilerleme çubuklarının rengi (sistem tint'i) sarı değil, **mürekkeptir**: gündüz siyah, gece beyaz.
  - Bu ayrımı koru. Sarı düğme, sarı zemin ya da sarı ikon önerme.
- **Kontrast:** Açık, koyu ve Yüksek Kontrast modlarının her birinde:
  - metin kontrastı en az 4.5:1 (büyük yazıda en az 3:1);
  - **denetim sınırı** (düğme, şık, çip kenarı) zemine karşı en az 3:1. `surface2` dolgusu tek başına zemine karşı yalnız 1.1–1.5:1 verir, bu yüzden yanına 1 pt `lineStrong` kenar gerekir.
- **Renk tek başına anlam taşımaz.** Her anlamın yanında ikon ya da söz olur.

### 4.4 Ölçüler
- Kenar boşluğu 16 pt.
- 8 pt ızgara: boşluklar 4, 8, 12, 16, 24, 32 gibi.
- Dokunma alanı en az 44×44 pt. Komşu dokunma alanları arasında en az 8 pt boşluk.
- Güvenli alana ve Dynamic Island'a saygı.
- Widget'larda Apple'ın widget kenar boşlukları.

### 4.5 Ekrana sığma
- **Kapsam:** Her ekran iPhone SE (375×667) ile Pro Max arasında ve en büyük yazı boyunda (AX5) kesilmeden çalışmalı. Widget'lar da buna dahil.
- **Kesilme yok:** Metin hiçbir zaman "…" ile kesilmez. Satır kayar ya da sayfa kayar. Widget'ta bir satır ya tam görünür ya hiç görünmez.
- **Kelime asla kesilmez.**
  - Harf aralığı daraltılmaz.
  - Kelimeyi bölen tire yok.
  - Kalıplar en çok 2 dengeli satıra kayar.
- **Tek kelime sığmazsa son çare merdiveni:**
  1. **Akış'ta ve uygulamada:** Kelime 0.75 ölçeğe kadar küçülebilir. Bu, "küçültme yok" kuralının tek istisnasıdır; 0.75'in altına inilmez.
  2. **AX boylarında:** Kelime boyu bir üst sınırda durur. Bu sınırı, "misunderstanding" 390 ve SE genişliğinde 0.75 ölçekle sığacak biçimde sen seç ve README'ye yaz. Bugün sınır 56 pt.
  3. **Widget'ta ölçek küçültme yok.** Kelime basamak basamak iner: bugün küçük widget'ta 22 → 20 → 17 → 15 pt. Kelime hiçbir zaman yanındaki anlamdan küçük olmaz.
- **Akış kartının içinde kaydırma yok.** Kart sığmazsa en alttan kısalır (§7.1'deki kısalma merdiveni). Yalnız AX boylarında kartlar sayfa sayfa değil, doğal boylarında kayar.

### 4.6 Türkçe metin kuralları

**Hitap**
- Kullanıcıya "sen" denir.
- Uygulama kendinden "biz" diye söz eder ("Tamam. 3 gün sonra bir kez soracağız."). "Ben" demez.
- Düğmeler 1. tekil olabilir: "Biliyorum", "Bildim", "Bilemedim".

**Yazım**
- Büyük harf yalnız cümle başında olur. Vurgu için BÜYÜK HARF yok.
- Ünlem yok. İki istisna var: "Anlaşıldı!" ve "Neredeyse!".
- Kişiye övgü ya da suçlama yok.
- Bir cümle en çok yaklaşık 12 kelime olur. Bir açıklama en çok iki cümledir.
- Parantez içinde İngilizce terim yok.
- Sayı birimi "kelime"dir, "kart" değil.
- **Ekler:** Değişkene, sayıya ve saate Türkçe ek gelmez. Cümleyi ek gerekmeyecek biçimde kur. Örnekler: "Hatırlatma: 20:00", "Öğrenmeye döndü: breakfast", "Yeni kelime: 09:00".
- **Saat:** 24 saatle ve iki haneyle yazılır: 09:00.
- **İşaretler:** "/" yalnız görünür sayaçta durur ("Kart 3 / 10"). Üç nokta tek karakterdir (…).
- Tutulamayan zaman sözü verme.

**Kullanılacak terimler** (parantezdekiler kullanılmaz)
- **Sekmeler:** Akış · Tekrar (Quiz, Test) · Sözlük · Ayarlar.
- **Ekran ve sheet adları:** Söyle (Telaffuz testi, Konuş) · Nasıl öğrenirim? · Widget sağlığı. Söyle bir sekme değildir.
- **Düğmeler:**
  - Dinle (Seslendir, Oynat; çalarken "Durdur")
  - Biliyorum (Öğrendim, Bildiklerime ekle)
  - Öğrenmeye geri al (Kaldır, Sil). Kısa "Geri al" yalnız "Bildiğin kelime" yazısının yanında ya da 5 saniyelik bildirimde kullanılır.
  - Anlamını göster (Cevabı göster, Çevir)
  - Bilemedim · Zor · Bildim · Kolay · "Zor muydu, kolay mı?"
  - Sonraki kelime (Atla, Geç). Widget'taki kısa "Sonraki" henüz terim listesinde yok; kullanırsan "yeni metin" diye işaretle.
  - Devam (İleri) · Bitir (Çık) · Tamam (OK) · Kapat (Bitti) · Vazgeç (İptal)
  - dokun (bas, tıkla)
- **Kavramlar:**
  - kelime (sözcük) · kart (yalnız görünüş için) · kalıp (ifade, öbek) · kalıp fiil · deyim
  - anlam (mana, çeviri, tercüme) · Türkçesi (Çeviri)
  - örnek cümle · Hafıza ipucu · Dikkat (Uyarı, Hata) · sahte dost (tuzak kelime)
  - birlikte kullanılır (eşdizim, collocation)
  - öğrenme listesi (kuyruk) · basamak (kutu, raf) · seviye (düzey) · konu (deste, kategori)
  - kilitli ekran (kilit ekranı) · ana ekran
- **Durum adları:** Yeni kelime · Öğreniyorsun · Bildiğin kelime.

**Metin kullanımı:** Mevcut metinleri aynen kullan. Yeni metin önerirsen mockup'ta yanına "yeni metin" notu koy ve README'ye yaz.

### 4.7 Önceki tasarım turunun altı kuralı (hâlâ geçerli)
1. Şerit öğrenilecek kelimeyi gösterir. Sarı yalnız orada olur.
2. **Dokunulan her şey dolu ya da kenarlı bir kapsüldür. Dokunulamayan şey kapsül olmaz.** Ör. seviye düz metin ve noktalarla yazılır. Mavi bağlantı yok.
3. İngilizce serif, Türkçe SF. Üçüncü yazı ailesi yok.
4. Renk tek başına anlam taşımaz.
5. Kart sondan kısalır. Kart içinde kaydırma yok.
6. Cam (Liquid Glass) yalnız denetim katmanındadır: sekme çubuğu, Kapat ve Bitir gibi. İçerikte cam yok.

### 4.8 Öğrenme ilkeleri (tasarımı doğrudan etkiler)

**İlk karşılaşma sade olur:** en çok 8 blok ve tek uyarı yeri.
- Bugünkü sıra: kelime + şerit → üst bilgi satırı (okunuş · tür · seviye) → Dinle/Söyle/Biliyorum → Türkçe anlam → İngilizce tanım → bir örnek cümle → Türkçesi → tek satır uyarı.
- İngilizce tanım: A1–A2'de **micro**, B1'de **short** tanım gösterilir.
- Diğer anlamlar ve eşdizimler kartın tamamına gider.

**Okuma sırası değişmez:** kelime → Türkçe anlam → İngilizce tanım → örnek.
- Hiçbir kısaltma Türkçe anlamı gizlemez. Türkçe anlam asla kesilmez.
- Widget'ta önce İngilizce tanım düşer. Sonra Türkçe anlam şu sırayla kısalır:
  1. tam anlam;
  2. yalnız ilk eş anlam (virgülden sonrası düşer; "/" ile yazılmış eş, ör. "amca / dayı", hiç düşmez);
  3. `gloss_short`.

  Anlam ancak bunların hiçbiri sığmazsa gizlenir.

**Uyarı yerinin önceliği:** sahte dost > Dikkat (sık hata) > iki anlam > kalıp fiil.

**Dikkat iki katmanlıdır:**
- Kartta tek satır ("✕ … → ✓ …") ve bir "Neden?" düğmesi olur.
- "Neden?" bir sheet açar. Sheet'ten yeni sheet açılmaz.
- Yanlış cümle hiçbir zaman tek başına durmaz; yanında hep doğrusu olur.
- İngilizce cümlenin içine Türkçe not yazılmaz. Not, cümlenin dışında küçük bir Türkçe etiket olur.

**Sahte dost şarttır:** Tek satırda gösterilir. Anlamı renk değil "≠" işareti taşır.

**Görmek tekrar sayılmaz:** Akış'ta ya da widget'ta görmek puan değiştirmez. "Az önce gördüklerin" gibi eski kelime listeleri yok.

**Geri bildirim işe dairdir:** Ör. "Doğrusu: borrow", "Senin seçtiğin: lend = ödünç vermek".
- Övgü, "Yanlış!" başlığı ve sayaç yok.
- Yanlış cevapta titreşim ve kırmızı yok.
- Kendiliğinden ilerleme yok; kullanıcı "Devam"a dokunur.

**Hareket:**
- Fotoğraf ya da süs görseli yok.
- Sonsuz animasyon yok.
- Animasyon en çok 200 ms. Hareketi Azalt açıkken yalnız solma olur.

**Düğmeler:**
- Bir ekranda en çok bir dolu (ana) düğme olur.
- Kendini puanlama düğmeleri ("Zor", "Kolay") eşit ağırlıkta görünür.

### 4.9 Widget kuralları (WidgetKit sınırları ve şartlar)

**Yalnız düğme ve aç/kapa çalışır** (App Intent).
- Kaydırma, sürükleme, yazı girişi, sheet, uyarı ve menü yok.
- Düğme dışındaki gövdeye dokununca uygulama açılır.

**Widget kendiliğinden ve zamanla değişmez.**
- Birkaç saniye sonra kaybolan onay olmaz.
- Bir onay, kullanıcı başka bir düğmeye dokunana ya da sıradaki kelime gelene kadar kalır.
- Animasyon yalnız içerik değişiminde kısa bir solmadır.

**Küçük widget:**
- Yalnız kelime ve Türkçe anlam gösterir. Tür, seviye, okunuş, tanım ve örnek yok.
- En çok 2 düğme olur: Dinle ve Sonraki. "Biliyorum" orta ve büyük widget'ta olur.

**Kilit ekranı:**
- Düğme yok; kilitliyken çalışmaz.
- Dikdörtgen widget en çok iki katmandır: kelime ve anlam. Üçüncü satır (tanım, okunuş) yok.
- Sistem her şeyi tek renk çizer. Hiyerarşi saydamlıkla değil, **opak gri tonlarla** kurulur: beyaz (#FFFFFF), açık gri (#BFBFBF), koyu gri (#4D4D4D). Beyazın saydamlığını kullanma.
- Anlam hiç gizlenmez.

**Düzen:**
- Uygulama ekranına benzeyen widget düzeni yok. Widget bir bakışta okunur.

**Tek renk modlar:** Renklendirilmiş / Liquid Glass ana ekranda her şey tek renk ve opak olur.
- Hiyerarşi yalnız boy ve kalınlıkla kurulur.
- Düğmelerde dolgu yerine 1.5 pt kontur olur.
- Sarı örnek işareti bu modda yok; kelime yalnız kalın yazılır.

**Vurgu rengi:**
- Bütün mockup'larda şerit sarıdır.
- Kullanıcının "Vurgu rengi" ayarındaki yeşil ve pembe yalnız tek bir "Widget'ı Düzenle" çerçevesinde gösterilebilir.
- Yeni vurgu rengi ya da tema önerme.

---

## 5. Bugünkü tasarım sistemi (token'lar)

Kodda `ios/Shared/LockglowTheme.swift`. Bu token'ları kullan. Yeni token gerekiyorsa adını ve değerlerini README'ye yaz.

### 5.1 Renkler

| Token | Açık | Koyu | Yüksek Kontrast (açık / koyu) | Kullanım |
|---|---|---|---|---|
| `band` (fosfor sarısı) | #F5E829 | #E9E040 | – | Yalnız kelime şeridi ve örnekteki kelime işareti |
| `ink` (label) | #000000 | #FFFFFF | – | Ana yazı, sistem tint'i |
| `ink2` (secondaryLabel) | #3C3C43 | #C7C7CC | #2C2C30 / #E5E5EA | Çeviri, okunuş, not |
| `ink3` (tertiaryLabel) | #636366 | #98989D | #3C3C43 / #C7C7CC | Yardımcı yazı. `surface3` üstünde yazı olarak kullanılmaz |
| `primary` / `onPrimary` | #000000 / #FFFFFF | #FFFFFF / #000000 | – | Ekranın tek ana düğmesi: dolgu ve üstündeki yazı |
| `bg` | #F2F2F7 | #000000 | – | Sayfa zemini (gece saf siyah, OLED) |
| `sheetBg` | #F2F2F7 | #1C1C1E | – | Sheet zemini (gece siyah değil) |
| `surface` | #FFFFFF | #1C1C1E | – | Kart, sheet, gruplu liste, widget zemini |
| `surface2` | #E5E5EA | #2C2C2E | – | Düğme dolgusu, çip, kutu |
| `surface3` | #D1D1D6 | #3A3A3C | – | İlerleme izi |
| `line` | #3C3C43 %29 | #545458 %65 | %45 / %100 | Ayraç, kart kenarı (yalnız süs) |
| `lineStrong` | siyah %52 | beyaz %42 | siyah %64 / beyaz %56 | Denetim kenarı (en az 3:1) |
| `good` / `goodTint` | #1E7433 / #E4EEE7 | #30D158 / good %16 | #165526 / #58DA78 | Doğru cevap, "Bildiğin kelime" |
| `bad` / `badTint` | #CE0014 / #F9E0E3 | #FF6961 / bad %16 | #9A000F / #FFA29D | Kart yüzeylerinde yalnız Dikkat (§11) |
| `caution` / `cautionTint` | #BE3100 / #F6E2DB | #FF9F0A / #3C2E1B | #8D2400 / #FFAD2D | Yalnız Dikkat üçgeni ve "Neredeyse!" |

### 5.2 Yazı rolleri (bugün, Akış kartı)

| Rol | Bugünkü stil |
|---|---|
| İngilizce kelime | Serif kalın 34, Large Title ile ölçeklenir, en çok 56 |
| Türkçe anlam | Title 1 kalın (28); kısalınca Title 2 (22) |
| İngilizce tanım, örnek cümle, İngilizce uyarı parçası | Body serif (17) |
| Üst bilgi satırı, düğmeler, örneğin Türkçesi, Türkçe uyarı parçası | Callout (16) |
| Tam genişlik düğme yazısı | Headline (17) |
| Widget kelimesi | Serif kalın, Title 3 ile ölçeklenir |

### 5.3 Köşe yarıçapları (hepsi "continuous")
- Kelime kartı 28
- Kart 22
- Grup 20
- Şık 18
- Kutu 16
- Segment 13

### 5.4 Parçalar

**Ana düğme:** Tam genişlik kapsül, en az 50 pt (alt çubukta 54), Headline.
- Gündüz: siyah dolgu, beyaz yazı.
- Gece: **beyaz dolgu, siyah yazı**, Apple uygulamalarındaki gibi. Kullanıcı bunu 24 Ekim'de seçti.

**İkincil düğme:** `surface` dolgu, 1.5 pt `lineStrong` kenar.

**Tonal düğme:** `surface2` dolgu, 1 pt `lineStrong` kenar.

**Çip:** 36 pt yükseklik; dokunma alanı 44 pt'ye tamamlanır. `surface2` dolgu, 1 pt `lineStrong` kenar.

**Basma tepkisi:** opaklık 0.85, ölçek 0.985, 120 ms.

**Kart yüzeyi:**
- Gündüz: `surface` dolgu, 1 pt `line` kenar ve yumuşak iki gölge.
- Gece: dolgu `bg` (saf siyah); kartı yalnız kenar çizgisi belli eder.

**Fosfor şeridi:**
- **Gündüz:** Eğik bir paralelkenar, harflerin alt yarısının arkasında.
  - Üst kenarı taban çizgisinin 0.56 em üstünde, alt kenarı 0.24 em altındadır (toplam 0.8 em).
  - Yatayda kelimeden iki yana 0.08 em taşar.
  - Üst kenar alt kenara göre 0.12 em sağa kaymıştır.
- **Gece:** Kuyruklu harflerin 2 pt altında eğik sarı bir çizgi (uygulamada 0.13 em, widget'ta 0.1 em kalın) ve hafif ışıma.
- **Tek renk modlar** (kilit ekranı, renklendirilmiş ana ekran): Kelime renginde ince bir çizgi.
- **Her Zaman Açık ekran:** 1 pt çizgi, ışıma yok.
- Kontrastı Artır ve Saydamlığı Azalt açıkken ışıma yok.

**Örnekte kelime işareti:**
- Kelime kalın yazılır.
- Gündüz arkasına %80 sarı vurgu konur; gece altına sarı çizgi çekilir.
- Bir ekranda en çok iki sarı işaret olur: şerit ve örnekteki kelime.
- Bugün işaret, kelime cümlede aranarak bulunur. Ekli biçimler bulunur (borrow → borrowed). Düzensiz biçimler (tooth → teeth) ve zamir değişimi (your → my) bulunmaz; o zaman kelime hiç işaretlenmez.

**Dikkat farkı:**
- Yanlış cümlede değişen kelimenin altı `bad` renkte noktalı çizilir.
- Doğru cümlede değişen kelime kalın yazılır, altı düz çizilir.

---

## 6. Kart verisi

### 6.1 Alanlar

Bir kartta şu alanlar var. Hepsi her kartta dolu değil.

- `lemma`: kelime ya da kalıp (boşluklu olabilir).
- `type`: word · phrasal_verb · phrase · collocation · idiom · proverb.
- `pos`: tür. Türkçe adları:
  - n "isim", v "fiil", adj "sıfat", adv "zarf"
  - phv "kalıp fiil", phr "kalıp", idm "deyim", det "belirleyici"
  - `interj` (4 kart: welcome, please, oops, pardon) için Türkçe ad yok; bugün ham "interj" görünüyor.
- `level`: A1 / A2 / B1. Bugün bir, iki ya da üç noktayla gösterilir: "A2 ●●○".
- `ipa.us` / `ipa.uk`: okunuş. Kullanıcı ayarda ABD ya da İngiltere aksanını seçer.
- `def.micro` / `def.short` / `def.long`: İngilizce tanımın üç uzunluğu.
- `examples[]`: `en` + `tr`. Genelde 3 tane. Akış'ta ilki gösterilir.
- `synonyms[]`, `antonyms[]`, `confusables[]` (sık karışan kelimeler), `collocations[]` (birlikte kullanılanlar), `word_family[]`.
- `etymology.text`: köken. Veride var ama **bugün hiçbir ekranda gösterilmiyor**.
- `l1.tr` (Türkçe katman):
  - `gloss`: Türkçe anlam. En uzunları 28 karakter (ör. "söylemesi kolay, yapması zor").
  - `gloss_short`: widget için en çok 16 karakterlik kısa anlam. 147 kartta dolu.
  - `alt[]`: diğer anlamlar.
  - `false_friend`: `{tr_word, tr_means, en_for_that}`. Yalnız 8 kartta var: sofa, apartment, college, actually, fabric, sympathetic, actual, eventually.
  - `note`: Türkçe açıklama.
  - `mistakes[]`: `{wrong, right, why}`, Türklerin sık yaptığı hata. 733 kartta var. Kartın Dikkat'i, doğru ya da yanlış cümlesinde kartın kelimesi geçen **ilk** hatadır.
  - `mnemonic`: hafıza ipucu. 273 kartta var.
- `quiz`: `cloze` (içinde tek "______"), `answer`, `distractors[3]`.
- `sensitivity`: 1 ise kart widget'ta ve bildirimde görünmez.

### 6.2 Mockup'larda kullanacağın kartlar

Uydurma kelime kullanma; aşağıdakileri kullan. Kart D bir kullanıcının ekleyeceği türden örnek bir kelimedir.

**Kart A: kısa A1 kelime, sık hatalı → `breakfast`**

İlk hatanın `why` metninde veride "kurmayın" yazıyor. "Sen" kuralına göre burada "kurma" diye düzeltildi.

```json
{"lemma":"breakfast","pos":"n","level":"A1","ipa":{"us":"/ˈbrɛkfəst/","uk":"/ˈbrɛkfəst/"},
 "def":{"micro":"first meal of the day","short":"the first meal of the day, eaten in the morning"},
 "examples":[
  {"en":"I usually have breakfast at seven.","tr":"Genellikle yedide kahvaltı yaparım."},
  {"en":"Ayşe made breakfast for the whole family.","tr":"Ayşe bütün aile için kahvaltı hazırladı."},
  {"en":"Breakfast is included in the hotel price.","tr":"Kahvaltı otel fiyatına dâhildir."}],
 "collocations":["have breakfast","skip breakfast","make breakfast","breakfast in bed","a light breakfast"],
 "etymology":"From 'break' + 'fast': the meal that breaks the long overnight fast since dinner.",
 "tr":{"gloss":"kahvaltı",
  "note":"Türkçedeki 'kahvaltı' da bir birleşik sözcüktür (kahve altı). İngilizcede öğün adlarından önce genellikle 'the' kullanılmaz.",
  "mistakes":[
   {"wrong":"I did breakfast at eight.","right":"I had breakfast at eight.","why":"'Kahvaltı yapmak' kalıbını 'do' ile kurma; İngilizcede 'have breakfast' denir ('make breakfast' = hazırlamak)."},
   {"wrong":"I eat the breakfast at 8.","right":"I eat breakfast at 8.","why":"Öğün adlarının önüne genellikle 'the' gelmez."}],
  "mnemonic":"Break + fast = orucu bozmak. İftar gibi, ama her sabah: gece boyu süren açlığı bozan öğün."},
 "quiz":{"cloze":"We usually eat ______ at 7 a.m., before school.","answer":"breakfast","distractors":["dinner","supper","lunch"]}}
```

Bugün Akış'taki Dikkat satırı şöyle görünür: "✕ I did breakfast → ✓ I had breakfast". Kısa parça, değişen kelimeyi ve iki yanındaki birer kelimeyi gösterir.

**Kart B: sahte dost + sık hata → `actually` (B1)**

```json
{"lemma":"actually","pos":"adv","level":"B1","ipa":{"us":"/ˈæktʃuəli/","uk":"/ˈæktʃuəli/"},
 "def":{"micro":"in fact; in reality","short":"used to say what is really true, often when it is not what people expect"},
 "examples":[
  {"en":"I thought the test would be hard, but it was actually quite easy.","tr":"Sınavın zor olacağını sanıyordum ama aslında oldukça kolaymış."},
  {"en":"Actually, I'd prefer tea, if that's okay.","tr":"Aslında çay tercih ederim, sakıncası yoksa."},
  {"en":"He looks shy, but he actually loves meeting new people.","tr":"Çekingen görünüyor ama aslında yeni insanlarla tanışmaya bayılıyor."}],
 "synonyms":["in fact","in reality","really","in truth"],"confusables":["currently"],
 "collocations":["actually quite","what actually happened","did you actually","but actually","actually, no"],
 "tr":{"gloss":"aslında, gerçekte","gloss_short":"aslında","alt":["doğrusu","esasında"],
  "false_friend":{"tr_word":"aktüel","tr_means":"güncel, şu anki","en_for_that":"current / currently"},
  "note":"Türkçedeki 'aktüel' = 'güncel'. İngilizce 'actual/actually' ise 'gerçek/aslında' demektir. 'Şu anda' için 'currently' veya 'at the moment' kullanılır.",
  "mistakes":[
   {"wrong":"The actual price of petrol is very high.","right":"The current price of petrol is very high.","why":"'Güncel' = 'current'; 'actual' = gerçek/asıl."},
   {"wrong":"Actually I'm studying English. (= şu anda)","right":"I'm currently studying English.","why":"'Actually' zaman bildirmez; 'şu anda' için 'currently / at the moment'."}],
  "mnemonic":"ACT = eylem: 'actually' = fiilen, gerçekte. 'Aktüel' (güncel) tuzağına düşme."},
 "quiz":{"cloze":"He looks young, but he is ______ forty.","answer":"actually","distractors":["currently","recently","fortunately"]}}
```

Bugünkü metinler (verideki gibi, kısaltılmadan):
- **Kart ve büyük widget'taki uyarı satırı:** "aktüel ≠ actually · aktüel = current / currently"
- **"Neden?" sheet'i, üç satır:**
  - "aktüel ≠ actually"
  - "aktüel = güncel, şu anki → current / currently"
  - "actually = aslında, gerçekte"
- **Kartın tamamındaki kutu:** "aktüel Türkçede: güncel, şu anki"
- **Kartın Dikkat'i ikinci hatadır,** çünkü cümlesinde "actually" geçen ilk hata odur: ✕ "Actually I'm studying English." → ✓ "I'm currently studying English."
- **"(= şu anda)" notu:** İlkelere göre İngilizce cümlenin içinde durmaz. Cümlenin dışında küçük bir Türkçe etiket olur, ör. "şu anda demek istiyorsan".
- Kısa biçim önerirsen "yeni metin" diye işaretle.

**Kart C: uzun deyim, uyarısız → `on the tip of your tongue` (B1)**

```json
{"lemma":"on the tip of your tongue","pos":"idm","level":"B1",
 "ipa":{"us":"/ɑːn ðə ˈtɪp əv jʊr ˈtʌŋ/","uk":"/ɒn ðə ˈtɪp əv jɔː ˈtʌŋ/"},
 "def":{"micro":"almost able to remember it","short":"you know a word or name, but you cannot remember it at this moment"},
 "examples":[
  {"en":"The word is on the tip of my tongue.","tr":"Kelime dilimin ucunda."},
  {"en":"Wait, I know this song! The title is on the tip of my tongue.","tr":"Dur, bu şarkıyı biliyorum! Adı dilimin ucunda."}],
 "tr":{"gloss":"dilinin ucunda olmak","gloss_short":"dilinin ucunda","note":"Türkçedeki 'dilimin ucunda' ile aynı resim. 'Your' yerine my, his, her gelir.","mistakes":[]},
 "quiz":{"cloze":"What's that actor's name? It's on the tip of my ______.","answer":"tongue","distractors":["lips","nose","finger"]}}
```

Bugün bu kartın örneklerinde kelime **hiç işaretlenmiyor**, çünkü cümlede "your" değil "my" geçiyor. Yön 0'da işaretsiz çiz.

**Kart D: kullanıcının kendi kelimesi** (destede yok, kullanıcı ekler)
- Alanlar:
  - kelime: "shortcut"
  - Türkçe anlam: "kısa yol"
  - örnek: "I know a shortcut to the station." (Türkçesi yok)
  - not: "Haritada gördüm."
- Okunuş, seviye, tanım ve uyarı yok.
- Üst bilgi satırında tür yerine "Senin kelimen" (`person.fill`) yazar.

**Zorlama örnekleri** (sığma denemesi için)
- **"Could you tell me the way to"** (A2, en uzun kalıp, 28 karakter)
  - Anlam: "yolu tarif eder misiniz?", kısa: "yolu tarif edin".
  - Widget'ta iki dengeli satır: "Could you tell / me the way to".
- **"under the weather"**
  - Anlam: "kendini pek iyi hissetmemek", kısa: "iyi hissetmemek".
- **Diğer uzun kalıplar:** "the day before yesterday", "not the end of the world", "what have you been up to" (anlam: "bu aralar neler yapıyorsun?").
- **Uzun tek kelime:** "misunderstanding" ("yanlış anlaşılma").
- **En uzun örnek cümle** (ikinci örnek ve kartın tamamı için, 98 karakter):
  - "I mean" kartı: “Do you like your new job, Tolga?” “It's OK. I mean, the people are nice, but the hours are long.”
  - İlk örnekler içinde en uzunu Kart B'nin ilk örneği (65 karakter).

**Alıştırma örnekleri**
- **Boşluk doldurma:** "I eat soup with a ______, not with a fork." → spoon ("kaşık"). Çeldiriciler: knife ("bıçak"), plate, cup.
- **Quiz widget'ı:**
  - Kelime: "borrow" /ˈbɑːroʊ/.
  - Şıklar: "izin vermek", "ödünç almak" (doğru), "cevaplamak".
  - Yanlış seçimde gösterilen satır: "Senin seçtiğin: allow = izin vermek".
  - Örnek cümle: "Can I borrow your pen?"
- **Cümle kurma:** "Can I have a spoon, please?" / "Bir kaşık alabilir miyim lütfen?"
- **Eşdizim:** "Sorry, I ______ a mistake." → made / did.

---

## 7. Yüzeyler: bugün ne var, senden ne bekleniyor

Her yüzey için şu başlıklar var:
- **Amaç**
- **Bugün:** yukarıdan aşağı, Yön 0 için.
- **Sorunlar:** koddan çıkan, tasarımda çözmeni istediğimiz noktalar.
- **Senden:** bu yüzeyde özellikle beklediklerimiz.

### 7.1 Akış kartı (yüzey 1) · TUR 1

Dosyalar: `ios/App/FeedCardView.swift`, `FeedView.swift`.

**Amaç**
- Akış sekmesi destedeki her kelimeyi **tam sayfa bir kart** olarak gösterir.
- Kartlar dikey kayar; her kaydırmada bir kart geçer.
- Kullanıcı kartta kelimeyi okur, "Dinle" ile dinler, "Söyle" ile telaffuz dener, "Biliyorum" ile kelimeyi öğrenme listesinden çıkarır.
- Ürünün en önemli ekranı budur.

**Sayfa iskeleti (bugün)**
- **Başlık "Akış":**
  - Large Title kalın.
  - Elle çizilmiş bir satır, gerçek gezinme çubuğu değil.
  - Üst güvenli alanın altında 52 pt boşluk, satır en az 52 pt.
  - AX1'de büyümeyi durdurur.
- **Kart:** Başlığın altından sekme çubuğunun üstüne kadar uzanır.
  - Kenarlardan 16 pt boşluk; üstte 4, altta 12.
  - Sekme çubuğu iOS 26'nın yüzen cam çubuğu. Altından bir sonraki kartın şeridi görünmez.
- **Kartın içi:** Yaklaşık yüksekliğini bu ölçülerden hesapla ve README'ye yaz.
- **Sayfa göstergesi:** Sayaç ya da sayfa noktası yok.
- **Kart geçişi:** Çıkan kart %70 opaklığa ve %97 ölçeğe iner. Hareketi Azalt açıkken yalnız solar.
- **Kart yüzeyi:**
  - 28 pt köşe.
  - Gündüz beyaz kart ve yumuşak gölge.
  - Gece saf siyah kart ve 1 pt kenar.
- **İç boşluk:** Yatay 20 pt. Metin ekran kenarından 36 pt içeride.

**Kartın içi, yukarıdan aşağı (bugün)**

1. **İngilizce kelime:** Serif kalın 34, şeritli.
   - Kalıp tek satıra sığmazsa iki dengeli satıra bölünür; her satır kendi şeridini alır.
2. **Üst bilgi satırı:** Satır dolarsa alta kayar.
   - **Okunuş:** Callout serif, `ink2`. Bugün hep ABD okunuşu.
   - **Tür:** Ör. "isim". Callout, `ink2`.
   - **Seviye:** "A1" ve noktalar ●○○. Kapsül yok. Callout kalın, `ink`.
   - **Kilit ekranı notu:** `lock` simgesi ve "Şu an kilitli ekranda". Yalnız bu kelime o an kilit ekranı widget'ında görünüyorsa çıkar.
   - **Durum etiketi:** Sağa yaslıdır.
     - "Yeni kelime" (`circle.dashed`)
     - "Öğreniyorsun" (`circle.lefthalf.filled`)
     - "Bildiğin kelime" (`checkmark.circle.fill`, yeşil)
3. **Düğme satırı:**
   - **Dinle** (`speaker.wave.2`): Çalarken "Durdur" yazar, simge dolu olur.
   - **Söyle:** Yalnız `mic` simgesi, 44 pt daire. Yazı yalnız AX boylarında çıkar. "Söyle" sheet'ini açar.
   - **Biliyorum** (`checkmark`): Sağa yaslı. Biliniyorsa seçili görünür; dokunuş geri alır.
   - Görünüm: `surface2` kapsüller, 1 pt kenar, Callout yarı kalın.
4. **Türkçe anlam:** Ör. "kahvaltı". Title 1 kalın, `ink`. Kutu yok.
5. **İngilizce tanım:** Body serif, geniş satır aralığı.
6. **İnce ayraç**, sonra **örnek cümle:**
   - Solda kenar boşluğuna taşan büyük, süs amaçlı bir tırnak işareti ("). AX boylarında gizli.
   - Cümle Body serif. Kelime kalın ve sarı işaretli.
   - Altında Türkçesi: Callout, `ink2`.
   - Sağda 34 pt hoparlör dairesi (`speaker.wave.2`). Cümleyi okur.
7. **Esnek boşluk**, sonra **ayraç** ve kartın dibinde **uyarı yeri:**
   - **Sahte dost:** `exclamationmark.triangle` (caution rengi), "aktüel ≠ actually · aktüel = current / currently" ve sağda **"Neden?"** çipi.
   - **Dikkat:** "✕ I did breakfast → ✓ I had breakfast" ve "Neden?" çipi.
     - ✕ kırmızı; yanlış kelimenin altı noktalı.
     - ✓ yeşil; doğru kelime kalın ve altı düz çizgili.
   - **İki anlam:** `lightbulb` ve "İngilizcede ikisi de: …"
   - **Kalıp fiil:** `lightbulb` ve "Türkçede tek fiil: kalkmak → İngilizcede iki parça: get up"
8. **"Yukarı kaydır" ipucu:** `chevron.up`, sağa yaslı. İlk 3 kart değişiminden sonra kalıcı olarak kalkar.

**İlk karşılaşma ile tekrar karşılaşma**
- **İlk karşılaşma:**
  - "Yeni kelime" etiketi.
  - A1–A2'de micro tanım.
  - Tek örnek, tek satır uyarı.
- **Tekrar karşılaşma:**
  - Durum etiketi yalnız "Öğreniyorsun" ya da "Bildiğin kelime" ise görünür.
  - Short tanım.
  - Yer varsa ikinci örnek.
  - Bütün uyarılar görünür. Dikkat **tam not** olarak çıkar:
    - başlık satırı: `exclamationmark.triangle`, "Dikkat" ve "Neden?";
    - "✕ Yanlış" / "✓ Doğru" etiketli iki cümle;
    - altında gerekçe (`why`).

**Kısalma merdiveni (SE ve büyük yazı)**

Kart sığmazsa sırayla şu adımlara iner.
1. **Geniş hâl:** İkinci örnekli. Yalnız tekrar karşılaşmada.
2. **Tam hâl:** O karşılaşmanın kısaltılmamış hâli; ilk karşılaşmada §4.8'deki 8 blok. Bu, "kartın tamamı" (yüzey 2) değildir.
3. **Daha sıkı boşluklar.**
4. **Anlam küçülür:** Anlam Title 2'ye iner, kilit ekranı notu gizlenir.
5. **Gerekçe gizlenir:** Dikkat'in gerekçesi gösterilmez.
6. **Tek uyarı:** Yalnız tek uyarı satırı kalır.
7. **"Örnek cümle" satırı:** Örnek yerine bu satır gelir.
   - Görünüm: tam genişlik tonal kapsül, sağda `chevron.right`.
   - Dokununca kartın tamamını açar.
8. **Birleşik satır:** Örnek ve uyarı tek satırda birleşir: "Örnek cümle ve Dikkat", "Örnek cümle ve sahte dost" ya da "Örnek cümle ve not".

**"Biliyorum" sonrası**
- Düğme seçili kalır, etiket "Bildiğin kelime" olur.
- Altta **ters renkli bir bildirim çubuğu** çıkar:
  - Renk: gündüz siyah zemin ve açık yazı; gece beyaz zemin ve siyah yazı.
  - Biçim: 22 pt köşeli dikdörtgen (kapsül değil), gölgeli.
  - Metin: `checkmark` ve "Tamam. 3 gün sonra bir kez soracağız."
  - Sağda "Geri al": hafif dolgulu, kenarlı bir kapsül.
  - Çubuk 5 saniye kalır; VoiceOver açıkken 10 saniye.

**Gün sonu kartı** (günlük yeni kelime hedefi dolunca araya giren sayfa)
- `sun.max`
- "Bugünlük 5 yeni kelime yeter." (Title 1 kalın)
- "Yarın kilitli ekranında yenileri olacak." (Body, `ink2`)
- Düğmeler:
  - Tekrar turu varsa: ana düğme "Tekrar'a geç (8 kelime)", ikincil düğme "Devam et".
  - Tekrar turu yoksa: yalnız "Devam et".

**Boş hâller**
- **Yüklenirken:** Yalnız dönen gösterge.
- **Hata:** "Kelimeler yüklenemedi", altında "Uygulamayı kapatıp yeniden aç." Sistemin boş durum görünümü, `tray` simgesi.

**AX boyları**
- Sayfalama kapanır; kartlar doğal boylarında alt alta kayar.
- Düğmeler tam genişlikte alt alta dizilir. "Söyle" yazısıyla görünür.
- Dikkat etiketleri cümlelerin üstüne geçer. Tırnak gizlenir.

**Sorunlar**
- **Fazladan boylar:** Metin boyları aslında 4 tane: 34 kelime, 28 anlam, 17 tanım/örnek, 16 üst bilgi/düğmeler/Türkçesi. Fazlalıklar şunlar:
  - 13 pt simgeler (✕, ✓, `chevron.right`);
  - 34 pt süs tırnak;
  - "Senin kelimen" etiketi 15 pt (kod hatası).
- **Izgara:** Boşlukların çoğu 8 pt ızgarasının dışında (10, 14, 18, 22; iç boşluk 20).
- **Kesilme riski:**
  - Kelime tek satıra zorlanıyor ve 0.6'ya kadar küçülüyor; kural 0.75.
  - Son kısalma adımında tanım 3 satırla sınırlı.
  - Son çare kırpma, metni kartın kenarında kesebilir.
- **"Söyle":** Yalnız simge; diğer iki düğmenin yazısı var. Bu yüzden zor fark ediliyor.
- **Kartın tamamına yol yok:** Normal boydaki bir karttan oraya gidilemiyor; yalnız "Neden?" var. Kartın tamamı yalnız 7. ve 8. kısalma adımlarında açılabiliyor.
- **Bildirim çubuğu:** iOS'ta karşılığı olmayan bir "toast".
- **Okunuş:** Kullanıcının aksan ayarına bakmıyor, hep ABD okunuşu.

**Senden**
- **3 yönde kart:** İlk karşılaşma ve tekrar karşılaşma hâlleri.
- **Kartın tamamına giriş:** Normal karttan kalıcı ve sakin bir giriş noktası.
- **Metin hiyerarşisi:** En çok 4 boyda, simge ve süs boyları da dahil, tutarlı bir hiyerarşi.
- **"Söyle":** Tutarlı bir çözüm: yazılı mı, simge mi, nerede.
- **"Biliyorum" sonrası onay:** İlkeler yeni bir bileşen istemiyor ve bugünkü 5 saniyelik bildirimi öneriyor. Yeni bir biçim önerirsen nedenini yaz. Korunacaklar:
  - metin "Tamam. 3 gün sonra bir kez soracağız.";
  - "Geri al" en az 5 saniye (VoiceOver'da 10) kalır;
  - onay kendiliğinden ilerlemez.
- **SE'de kısalma:** Kartın SE'de hangi adımda nasıl kısaldığını göster; en az 3 adım.

### 7.2 Kartın tamamı ve "Neden?" (yüzey 2) · TUR 2

Dosyalar: `ios/App/SozlukWordPage.swift`, `CardDetailViews.swift`, `FeedWhySheet.swift`.

**Amaç**

**Kartın tamamı** kelimenin her şeyini tek sütunda gösterir. Şuralardan açılır:
- Sözlük araması ve konuları;
- "Bildiğin kelimeler";
- haftalık özet;
- Siri ve Spotlight;
- Tekrar boşken hatırlatmaya dokunma;
- Akış'taki "Örnek cümle" satırı.

Widget'a dokununca uygulama **Akış'ta o kelimenin kartında** açılır. Kartın tamamı yalnız kelime destede değilse açılır.

**"Neden?" sheet'i** karttaki tek satır uyarının açıklamasıdır.

**Kartın tamamı, bugün yukarıdan aşağı**
1. **Kelime:** Serif, şeritli.
2. **Künye satırı:** Okunuş, tür, seviye ve durum.
   - Seviye burada **kenarlı bir kapsül** ("A2 ●●○"). Bu, kapsül kuralına aykırı.
   - Durum yalnız kelime yeni değilse görünür.
3. **Eylemler:**
   - "Dinle" kapsülü.
   - "Söyle": çıplak `mic.circle` simgesi, kapsül değil.
4. **Anlam bloğu:**
   - Türkçe anlam: Title 1 kalın.
   - "Ayrıca: doğrusu, esasında": Callout, `ink2`.
   - Short tanım: Body serif.
5. **Bağlantılar:** Gruplu liste satırları, `chevron.right` ile.
   - "Başka anlamı" (`square.on.square`)
   - "Karıştırma" (`arrow.left.arrow.right`), alt yazısı "Bu kelimeyle sık karışır."
6. **"Örnekler":** Her biri cümle, Türkçesi ve hoparlör. Kelime yalnız kalın, sarı yok.
7. **Uyarılar:**
   - Her sık hata için bir **Dikkat kutusu**:
     - kutu: `surface2`, 16 pt köşe;
     - başlık: `exclamationmark.triangle` ve "Dikkat";
     - "✕ Yanlış" / "✓ Doğru" etiketli iki cümle;
     - gerekçe.
   - **"Sahte dost" kutusu:** En altında "aktüel Türkçede: güncel, şu anki".
   - **"Not" ve "Hafıza ipucu":** Tek kartta, `info.circle` ve `lightbulb` simgeleriyle.
8. **"Birlikte kullanılır":** Her eşdizim dinlenebilir bir çiptir: `speaker.wave.2` ve "have breakfast".
9. **"Durum" kartı** (en altta):
   - Simge, durum adı ve açıklama:
     - "Henüz çalışmaya başlamadın."
     - "Bu kelimeyi Tekrar'da çalışıyorsun."
     - "3 gün sonra bir kez soracağız."
   - Düğme: "Biliyorum olarak işaretle" ya da "Öğrenmeye geri al".

**"Neden?" sheet'i (bugün)**
- **Yükseklik:** Yarım ve tam açılabilir; AX boylarında yalnız tam.
- **Başlık:** "Neden?", sol üstte "Kapat".
- **Üstte kelime:** Serif kalın, şeritsiz.
- **Sahte dostsa:** §6.2'deki üç hizalı satır.
- **Dikkatse:** Tam Dikkat notu.
- **Sonra, çizgilerle ayrılmış bölümler:**
  - "Not"
  - diğer hatalar
  - "Birlikte kullanılır"
  - "Başka örnekler"

**Sorunlar**
- **Üç ayrı detay tasarımı var:**
  - kartın tamamı: kutulu;
  - Akış'taki "Neden?": kutusuz, çizgili;
  - açılış turundaki "Neden?": kutulu, eşdizimler tek satırda.

  Başlık renkleri ve yükseklikleri birbirini tutmuyor.
- **Sayfa başlığı yok:** Kartın tamamında başlık olmadığı için kaydırınca üst çubuk boş kalıyor.
- **Sheet zemini:** Akış'tan açılan sheet gece saf siyah. Kural, sheet'in gece `sheetBg` (#1C1C1E) olması.
- **Başlık hiyerarşisi karışık:**
  - "Örnekler", "Durum" ve "Birlikte kullanılır" Headline.
  - "Dikkat", "Sahte dost" ve "Not" kutu içinde Callout kalın.
  - Birden çok hata varsa "Dikkat" başlığı arka arkaya tekrarlanıyor.
- **Ayraçlar tutarsız:** Biri girintili, biri girintisiz.
- **Gösterilmeyen veri:** Köken ve eş anlamlılar veride var ama gösterilmiyor.

**Senden**
- **Tek yapı:** Tek bir "kartın tamamı" yapısı: bölüm sırası, başlık ölçeği, kutu mu çizgi mi.
- **"Neden?" sheet'i:** Bu yapının yarım boy alt kümesi olsun.
- **Köken ve eş anlamlılar:** Yerini ve biçimini öner, ya da neden gösterilmemesi gerektiğini yaz.
- **Durum bölümü:** Bölümün kendisi ve "Biliyorum olarak işaretle" düğmesi.

### 7.3 Quiz kartı (yüzey 3) · TUR 2

Dosya: `ios/App/QuizCardView.swift`.

**Amaç**
- Tekrar sekmesinde, vadesi gelmiş bir kelime için **boşluk doldurma** sorusu.
- 4 şık var. Kullanıcı seçer, geri bildirimi okur, "Devam"a dokunur.

**Bugün**
- **Tur başlığı:**
  - "Kart 3 / 10" (Headline, `ink2`).
  - 6 pt ilerleme çubuğu.
  - Sağda cam "Bitir" düğmesi.
  - Sekme çubuğu gizli.
- **Soru:** "Boşluğa hangisi gelir?" Subheadline yarı kalın, `ink2`. Cevaptan sonra kaybolur.
- **Cümle kartı:**
  - Title 2 serif.
  - Boşluk kalın alt çizgilerle çizilir; arkası `surface2`.
  - Kart köşesi 22.
- **4 şık:**
  - Title 3 serif.
  - Sığarsa 2 sütun, sığmazsa tek sütun.
  - En az 56 pt yükseklik.
  - Tek satırken kapsül, uzayınca 28 pt köşeli.
  - `surface` dolgu, 1.5 pt kenar.

**Doğru cevap**
- Cümle dolu görünür; cevap sarı işaretli. Altında "Dinle" kapsülü çıkar.
- Yalnız doğru şık kalır:
  - "Doğru cevap" ve `checkmark.circle.fill`;
  - yeşil kenar, açık yeşil dolgu.
- **Geri bildirim kutusu** (`surface2`, köşe 18):
  - "Doğru." (yeşil tik)
  - "spoon = kaşık"
- **Alt çubuk:**
  - "Devam" ana düğmesi.
  - "Zor muydu, kolay mı?"
  - "Zor" (`tortoise`) ve "Kolay" (`hare`) yan yana, eşit ağırlıkta.
- Başarı titreşimi.

**Yanlış cevap**
- İki şık kalır: önce doğru şık (yeşil), sonra seçilen şık.
  - Seçilen şıkta "Yanlış" ve `xmark.circle`.
  - Renk `ink2`, **kırmızı yok**.
- **Geri bildirim kutusu:**
  - `lightbulb` ve "Doğrusu: spoon = kaşık"
  - "Senin seçtiğin: knife = bıçak"
  - Kartın Dikkat'i ilgiliyse altında "Neden?" bölümü.
- **Alt çubuk:**
  - `clock` ve "Bu kelimeyi bir sonraki turda yine soracağız." ya da "Bu kelime yarın yine gelir."
  - "Devam"
- Titreşim yok.

**Sorunlar**
- **Köşeler:** Yan yana üç farklı köşe var (22 / 28 / 18).
- **Boylar:** Cümle Title 2, şıklar Title 3; iki boy çok yakın.
- **"Zor" / "Kolay":** Kelimenin ne zaman döneceği gözle görünmüyor.
- **Yanlış seçilen şık:** Cevapsız bir şıktan zor ayırt ediliyor.

**Senden**
- **Üç hâl:** Cevapsız, doğru ve yanlış.
- **Yanlış şık:** Kırmızı kullanmadan daha belirgin bir işaret dili.
- **"Zor" / "Kolay":** Her birinin kelimeyi ne zaman geri getireceğini sakin bir dille göster, ör. "2 gün sonra" ve "5 gün sonra". Bunlar yeni metin; §4.6'daki ek kuralına uy.

### 7.4 Cümle kurma kartı (yüzey 4) · TUR 2

Dosya: `ios/App/SentencePracticeCards.swift` → `SentenceBuildCard`.

**Amaç**
- Kullanıcı Türkçe cümleyi görür ve karışık İngilizce kelime karolarını doğru sıraya dizer.
- Bu bir pratiktir; kelimenin basamağı değişmez.
- Tur en çok 5 soru: kur, seç, kur, seç, kur.
- Ekranın başlığı "Cümle kur". Üstte "Soru 2 / 5" ve bir ilerleme çubuğu var.

**Bugün**
- **"Cümleyi kur":** Callout yarı kalın, `ink2`.
- **Türkçe istem kartı:**
  - "Türkçesi" (Footnote)
  - Altında "Bir kaşık alabilir miyim lütfen?" (Title 3 yarı kalın, sans)
- **"Senin cümlen" kutusu:**
  - Boşken "Kelimelere sırayla dokun." (Callout, `ink3`)
  - Doldukça karolar dizilir. Son karo yerleşince sondaki noktalama ("?") görünür.
  - Altında "Çıkarmak için kelimeye dokun."
- **"Kelimeler" bankası:**
  - Karolar kapsül biçiminde: Title 3 serif, `surface` dolgu, 1.5 pt kenar, en az 44×44.
  - Yerleşen karonun eski yerinde kesik çizgili boş bir kapsül kalır.
- **Alt çubuk:** "Kontrol et" ana düğmesi.
  - Tüm karolar yerleşene kadar %40 opak ve pasif.
  - Denetimden sonra "Devam" olur.

**Denetimden sonra**
- **Doğru:**
  - Bütün karolar yeşil kenarlı.
  - Kutu: "Doğru.", cümle (kelime sarı işaretli), "Türkçesi: …" ve "Dinle".
- **Yanlış:**
  - Yalnız yeri kayan karolar kesik kenarlı olur ve `arrow.left.arrow.right` ikonu alır.
  - Kutu: "Doğrusu:", doğru cümle ve "Yeri farklı olan kelimeler işaretli."
- **Etkileşim:** Dokunarak ve sürükle-bırakla çalışır.

**Sorunlar**
- **Çift metin:** Türkçe cümle iki kez görünüyor: istemde ve geri bildirimde.
- **Kap stilleri:** Bir ekranda dört ayrı kap stili var (köşe 22, 16, 18 ve kapsül).
- **"Kontrol et":** Pasifken nedenini yazmıyor.
- **Yerinde duran karolar:** Yanlış cümlede işaretsiz kalıyor; "doğru yerde" ile "işaretsiz" ayırt edilemiyor.
- **Sürükle-bırak:** Keşfedilemiyor.

**Senden**
- **Dört hâl:** Boş, kısmen dolu, doğru ve yanlış.
- **Tek kap dili:** Yüzey 3 ve 5 ile aynı.

### 7.5 Eşdizim seçme kartı (yüzey 5) · TUR 2

Dosya: `ios/App/SentencePracticeCards.swift` → `CollocationChoiceCard`.

**Amaç**
- Sabit fiil eşdizimini seçtirir. İki şık var: make/do ya da say/tell.
- Türkçede ikisi çoğu zaman tek fiille söylenir ("yapmak", "söylemek"). Bu yüzden sık karışır.

**Bugün**
- **Başlık:** "Hangisi birlikte kullanılır?" Cevaptan sonra da kalır.
- **Cümle kartı:**
  - "Sorry, I ______ a mistake." (Title 3 serif)
  - Varsa altında "Türkçesi: …"
- **Şıklar:** İki eşit kapsül yan yana: "made" / "did". AX boylarında alt alta.
- **Doğru seçimde:**
  - Tek şık kalır: "Doğru cevap".
  - Kutuda "Doğru." ve "Birlikte kullanılır: make a mistake".
- **Yanlış seçimde:**
  - İki şık kalır.
  - Kutuda "Doğrusu: made", "Birlikte kullanılır: …" ve "Türkçede ikisine de çoğu zaman “yapmak” deriz."
- **"Devam" çubuğu:** Yalnız seçimden sonra belirir, içerik zıplıyor.

**Sorunlar** (quiz kartıyla tutarsızlıklar)
- **Ölçüler:** Cümle boyu, işaret boyu ve şık boşlukları quiz kartından farklı.
- **Doğru kelime işareti:** Burada alt çizgi, quiz kartında sarı.
- **Tekrar eden bilgi:** "Doğru" üç kez söyleniyor: yeşil kenar, "Doğru cevap" ve "Doğru.".

**Senden**
- **Ortak dil:** Yüzey 3, 4 ve 5'i **tek bir alıştırma dili** olarak tasarla. Aynı olsun:
  - başlık rolü;
  - cümle boyu;
  - şık;
  - geri bildirim kutusu;
  - alt çubuk.

### 7.6 Kelime widget'ı: küçük (yüzey 6) · TUR 1

Dosya: `ios/Widgets/HomeWordViews.swift`.

**Amaç:** Bir bakışta İngilizce kelimeyi ve Türkçe anlamını gösterir.

**Bugün, yukarıdan aşağı**
- **Kelime:** Serif kalın, şeritli.
  - Boy basamakları: 22 → 20 → 17 → 15. Kalıpta iki satırda 20 → 17.
- **Türkçe anlam:** Kalın. Boyu Body → Subheadline → Footnote basamaklarıyla iner.
- **Altta iki simge düğme:** Solda **Dinle** (`speaker.wave.2`), sağda **Sonraki** (`forward.fill`).
  - 34 pt daire, `surface2` dolgu, 44×44 dokunma alanı.
  - Kenardan 11 pt içeride.
- **Gövdeye dokunma:** Düğme dışındaki yer uygulamayı Akış'ta o kelimede açar.

**Widget ayarları** ("Widget'ı Düzenle")
- **"Anlamı gizle":** Anlamın yerinde "Göster" kapsülü durur. Kullanıcı önce kendisi hatırlamaya çalışır. "Göster"e dokunmak tekrar sayılmaz.
- **"Vurgu rengi":** Sarı, Yeşil ya da Pembe (§4.9).
- **"Örnek cümle":** Orta ve büyük widget için.

**Görünüm modları** (hepsini çiz)
- **Tam renk:** Gündüz ve gece.
- **Renklendirilmiş / Liquid Glass:** Tek renk, düğmelerde kontur (§4.9).
- **StandBy gece:** Kırmızı tek renk, siyah zemin, animasyon yok.

**Sorunlar**
- **Düğme sınırı:** Tam renkte düğme dairesinin kenarı yok. Zeminle sınırı yalnız 1.20:1 (gündüz) ve 1.15:1 (gece); kural 3:1.
- **"Anlamı gizle":** Açıkken küçük widget'ta **üç dokunma hedefi** oluyor: "Göster" ve iki düğme. Kural en çok 2.
- **Galeri örneği:** Galerideki örnek kelime "resilient" (C1). A2 öğrencisi için yanlış bir örnek.

**Senden**
- **3 yönde hâller:** Normal, "Anlamı gizle" ve uzun kalıp.
- **Üç hedef sorunu:** Bir çözüm öner.

### 7.7 Kelime widget'ı: orta (yüzey 7) · TUR 1

Dosya: `ios/Widgets/HomeWordViews.swift`.

**Bugün**
- **Düzen:** Solda metin sütunu, sağda düğme sütunu.
- **Metin sütunu:**
  - **Kelime satırı:**
    - kelime: serif kalın, 20 → 17 → 15;
    - okunuş: Footnote serif, `ink2`; yalnız tam sığarsa;
    - seviye kodu "A1": Footnote kalın, `ink2`.
  - **Türkçe anlam:** Callout kalın.
  - **İngilizce tanım:** Footnote serif, `ink2`, tek satır.
  - **Örnek cümle:** Footnote serif, `ink2`; kelime kalın, şerit yok, 1–2 satır.
  - **Altta "Yeni kelime: 09:00":** Caption 2, 11 pt; en alt sınırda.
- **Düğme sütunu:** **Biliyorum** (`checkmark`) · **Dinle** · **Sonraki**. Hepsi yalnız simge.
- **Kısalma sırası:**
  1. "Yeni kelime" satırı gider.
  2. Örnek gider.
  3. Tanım gider.
  4. Anlam küçülür.
  5. Kısa anlama geçilir.

**Sorunlar**
- **"Biliyorum" sonrası:** Onay yok, geri alma yok. Dokununca kelime kaybolur, hiçbir görsel geri bildirim olmaz.
- **Düğme adları:** Burada yok, büyük widget'ta var.
- **iPad mini:** Düğmelerin dokunma alanları birbirine değiyor.
- **Bekleyen karar:** 23 Ekim'de bu widget için bir karar alındı, ama henüz koda geçmedi (§9).

**Senden**
- **"Biliyorum" onayı:** Widget içinde onay ve "Geri al" hâli. Örnek: `checkmark` ve "Tamam. 3 gün sonra bir kez soracağız.", yanında "Geri al".
  - Onay §4.9'a göre kendiliğinden kaybolmaz.
  - Sonraki kelimeye geçilene ya da başka bir düğmeye dokunulana kadar kalır.
- **Düğme adları:** Büyük widget'la tutarlı bir çözüm (§10, soru 7).

### 7.8 Kelime widget'ı: büyük (yüzey 8) · TUR 1

Dosya: `ios/Widgets/LargeWordView.swift`.

**Bugün, yukarıdan aşağı**
- **Kelime satırı:** Kelime (serif kalın, 28 → 22 → 20) ve sağda seviye kodu.
- **Okunuş:** Ayrı satırda.
- **Türkçe anlam:** Title 3 kalın.
- **Tanım:** Subheadline serif, `ink2`, 1–2 satır.
- **İki örnek cümle:** Subheadline serif, `ink`; kelime kalın.
- **Uyarı satırı:**
  - Sahte dost: `exclamationmark.triangle` ve "aktüel ≠ actually · aktüel = current / currently".
  - Dikkat: "✕ … → ✓ …".
- **"Yeni kelime: 09:00":** Footnote.
- **Altta üç düğme:** "Biliyorum" · "Dinle" · "Sonraki". Her biri bir simge dairesi ve altında Footnote yarı kalın ad.

**Sorunlar**
- **Widget ayarları:** "Anlamı gizle", "Vurgu rengi" ve "Örnek cümle" bu boyda uygulanmıyor, ama ayar ekranında görünüyor.
- **Okunuş:** Hep ABD okunuşu.
- **Örnek rengi:** Örnekler burada `ink`, orta widget'ta `ink2`.

**Senden**
- **Ana hâller:** Kart A, Kart B (sahte dost) ve Kart C (uzun deyim).
- **"Anlamı gizle" açıkken:** Bu boyun nasıl göründüğünü çiz.

### 7.9 Kilit ekranı (yüzey 9) · TUR 1

Dosya: `ios/Widgets/AccessoryWordViews.swift`.

§4.9'daki kilit ekranı kuralları burada geçerli: düğme yok, en çok iki katman, opak gri tonlar, anlam gizlenmez.

**Dikdörtgen (160×72)**
- **1. satır:** Kelime, serif kalın, 17 → 15. Şerit ince bir çizgi olarak çizilir.
- **2. satır:** Türkçe anlam, Subheadline yarı kalın. Renk opak açık gri (#BFBFBF), saydam beyaz değil. 1–2 satır.

**Satır içi** (saatin üstünde)
- Tek satır metin; yazı tipini sistem seçer.
- Kısalma sırası:
  1. "actually · aslında, gerçekte"
  2. "actually · aslında"
  3. "actually"

**Dairesel:** Bugün yok. İstersen öneri olarak çiz.

**Senden**
- **Gerçekçi mockup:** Koyu bir duvar kâğıdı üstünde, saatle birlikte.
- **Her Zaman Açık:** 1 pt çizgi, ışıma yok.
- **Uzun kalıp:** "Could you tell me the way to" ile sığma denemesi.

### 7.10 Quiz widget'ı: orta ve büyük (yüzey 10) · TUR 2

Dosya: `ios/Widgets/QuizWidgetViews.swift`.

**Amaç**
- Bir İngilizce kelime ve **üç Türkçe şık**.
- Kullanıcı widget içinden bir şıkka dokunur; doğrusu hemen işaretlenir. "Devam" ile sonraki soru gelir.
- Kendiliğinden hiçbir şey değişmez.
- Puan, sayaç ve kırmızı yok. Cevap bir görme sayılır, not değil.

**Orta (bugün)**
- **Üst satır:**
  - Durum satırı (Footnote yarı kalın): "Bu kelime ne demek?" / "Doğru." / "Doğrusu: ödünç almak"
  - Altında şeritli kelime.
  - Sağda hoparlör. Cevaptan sonra yanında yuvarlak bir "Devam" (`arrow.right`) çıkar.
- **Şıklar:** Üç şık yan yana sütun. Köşe 14, Subheadline yarı kalın.

**Büyük (bugün)**
- **Durum satırı:** Subheadline yarı kalın.
- **Kelime satırı:** Okunuşla birlikte.
- **Cevaptan sonra:** Hoparlörün yanında "Devam" yazılı, `arrow.right` simgeli bir kapsül çıkar. Büyük yazıda ya da uzun kelimede yuvarlak simge düğmesine döner.
- **Şıklar:** Üç tam genişlik satır. Köşe 16, Body yarı kalın. Solda 20 pt işaret yeri.
- **Cevaptan sonra alt bölüm:**
  - "Senin seçtiğin: allow = izin vermek"
  - Örnek cümle: "Can I borrow your pen?"

**Cevaptan sonra şıklar**

| Durum | Zemin | Kenar | İşaret |
|---|---|---|---|
| Cevaptan önce | `surface2` | `lineStrong` 1 pt | yok |
| Doğru şık | `goodTint` | `good` 2 pt | `checkmark.circle.fill` |
| Yanlış seçilen | şeffaf | `lineStrong` 1 pt | `xmark.circle.fill`, `ink2` |
| Diğer şık | şeffaf | `line` 1 pt | yok, metin `ink2` |

**Boş hâller** (ikon yok, düğme yok)

| Başlık | Açıklama |
|---|---|
| "Sorular hazır değil" | "Soruları hazırlamak için uygulamayı bir kez aç." |
| "Henüz soru yok" | "Sorular tanıştığın kelimelerden gelir. Önce Tekrar'da birkaç kelimeyle tanış." |
| "Şimdilik soru kalmadı" | "Yeni sorular uygulamayı açınca gelir." |

**Sorunlar**
- **Köşeler:** Orta 14, büyük 16; token tablosunda şık köşesi 18.
- **Yanlış şık:** Çok silik.
- **Orta boy:** "Senin seçtiğin" satırı yok.
- **Boş hâller:** Çok sade.
- **Devam simgesi:** Burada `arrow.right`, kelime widget'ında "Sonraki" `forward.fill`.

**Senden**
- **Hâller:** Orta ve büyük boyda cevapsız, doğru ve yanlış; üç boş hâl.
- **Modlar:** Renklendirilmiş mod ve gece.
- **Boş hâl:** Sakin bir ikon ve "uygulamayı aç" yönlendirmesi. Gövdeye dokununca uygulama açılır (§4.9).

### 7.11 Haftalık özet paylaşım kartı (yüzey 11) · TUR 2

Dosya: `ios/App/WeeklyRecapShareCard.swift`.

**Amaç**
- Pazartesi açılan "Geçen hafta" sayfasında bir "Paylaş" düğmesi var.
- Düğme, geçen haftanın kelimelerinden bir **hikâye görseli** hazırlar. Görsel sistem paylaşım sayfasıyla gönderilir.

**Bugün**
- **Görsel:**
  - 1080×1920 px (360×640 pt, 9:16).
  - Hep gündüz görünümü, hep varsayılan yazı boyu.
  - Zemin #F2F2F7.
- **İçerik** (yukarıdan aşağı):
  1. "Geçen haftanın kelimeleri" (Headline, `ink2`).
  2. En çok 6 kelime. Her birinde:
     - İngilizce kelime: Title 1 serif kalın;
     - altında Türkçe anlam: Callout, `ink2`.

     Yalnız **ilk kelimede** sarı şerit var.
  3. Altta imza: "Lockglow" (Callout yarı kalın, `ink3`). Logo yok.
- **Görselde olmayanlar:** İsim, tarih ve sayı. Kişisel konulu ve kullanıcının eklediği kelimeler alınmaz.
- **Sayfadaki düğme:**
  - "Paylaş" (`square.and.arrow.up`), ikincil kapsül.
  - Altında: "Resimde yalnız kelimeler ve anlamları var."

**Sorunlar**
- **Güvenli alan:** Hikâye uygulamaları üstte ve altta yaklaşık 250 görsel pikseli kapatıyor. Bu, 360×640 pt'lik çerçevede yaklaşık 84 pt eder. Bugünkü boşluk 72 pt (216 px). Başlık ve imza çubukların altında kalabilir.
- **Küçülme ve kesilme:** Kelime 0.5'e kadar küçülüyor ve "…" ile kesilebiliyor.
- **Az kelime:** 1–2 kelimede alt yarı boş kalıyor.
- **İmza:** Çok zayıf.

**Senden**
- **Hâller:** 1, 3 ve 6 kelime; uzun deyim; iki satırlık anlam.
- **Güvenli alan:** Üstte ve altta en az **84 pt** boş bırak (mockup'ta 84 CSS px).
- **İmza:** Sakin ama tanınır bir marka imzası. İkondaki şerit fikri kullanılabilir.

---

## 8. Çizilecek çerçeveler

### 8.1 Zorunlu çerçeveler: Tur 1, her yön (A, B, C)

Önce bunları çiz. "Açık + koyu" yazan yerde iki ayrı çerçeve çiz.

**Akış kartı**
1. Kart A, ilk karşılaşma (Dikkat satırı) · 390 · açık + koyu
2. Kart B, ilk karşılaşma (sahte dost) · 390 · açık + koyu
3. Kart B, tekrar karşılaşma ("Öğreniyorsun", tam Dikkat notu, ikinci örnek) · 390 · açık
4. Kart C, uzun deyim, uyarısız · SE · açık
5. SE'de kısalma: Kart B tekrar karşılaşma, en az 3 adım · açık
6. Kart A · AX5 · 390 · açık (uzun kayan çerçeve)
7. "Biliyorum" onayı ("Bildiğin kelime") · 390 · koyu
8. Gün sonu kartı · 390 · açık
9. Bir Yüksek Kontrast çerçevesi (Kart A) · 390 · koyu

**Küçük, orta ve büyük widget** (her boy için)
1. Kart A ve Kart B · açık + koyu
2. Uzun kalıp ("Could you tell me the way to") ya da Kart C · SE · açık
3. "Anlamı gizle" hâli · açık
4. Renklendirilmiş / Liquid Glass · tek çerçeve
5. xxxLarge ve AX5 · birer çerçeve. AX5'te widget'ın sığmak için hangi basamağa indiğini göster.

Ayrıca:
- Orta ve büyük widget: "Biliyorum" onayı · açık.
- Küçük widget: StandBy gece · tek çerçeve.

**Kilit ekranı**
1. Dikdörtgen: Kart A ve Kart C.
2. Satır içi: üç kısalma.
3. Her Zaman Açık: tek çerçeve, 390.

**Yön 0 (bugün)** için yalnız şunlar çizilir:
- Akış: Kart A ve B ilk karşılaşma, SE kısalma, AX5.
- Küçük, orta ve büyük widget: Kart A ve B.
- Kilit ekranı: dikdörtgen Kart A.

### 8.2 Ek hâller: Tur 1, zaman kalırsa (yalnız açık mod)

- **Akış:**
  - "Şu an kilitli ekranda" notu.
  - "Yukarı kaydır" ipucu.
  - Kart D (kullanıcının kendi kelimesi).
  - Hata hâli ("Kelimeler yüklenemedi").
- **Widget'lar:**
  - Kart C'nin bütün boyları.
  - iPad mini orta widget.
  - Tek bir "Widget'ı Düzenle" çerçevesinde yeşil ve pembe vurgu.
- **Kilit ekranı:** Dairesel widget önerisi.

### 8.3 Tur 2 (yalnız seçilen yön)

| Yüzey | Göstermen gereken hâller |
|---|---|
| 2 Kartın tamamı | Kart A ve B tam sayfa (AX5'te biri) · "Neden?" sheet'i yarım ve tam boy (sahte dost ve Dikkat) · Kart D |
| 3 Quiz | Cevapsız · Doğru · Yanlış ("Neden?" bölümüyle) · AX5 |
| 4 Cümle kurma | Boş · Kısmen dolu · Doğru · Yanlış |
| 5 Eşdizim | Cevapsız · Doğru · Yanlış |
| 10 Quiz widget'ı | Orta ve büyük: cevapsız · doğru · yanlış · üç boş hâl · Renklendirilmiş |
| 11 Paylaşım kartı | 1, 3 ve 6 kelime · Uzun deyim · Güvenli alan işaretli |

Tur 2'de her yüzeyin en az bir hâlini koyu modda ve en az birini SE'de çiz.

### 8.4 İstisnalar
- **11 Paylaşım kartı:** Yalnız açık mod ve varsayılan yazı boyu. Cihaz çerçevesi yok.
- **9 Kilit ekranı:** Tek renk vibrant modda çizilir; açık/koyu ayrımı yok.
- **StandBy:** Yalnız gece. Kırmızı tek renk, siyah zemin.
- **Renklendirilmiş mod:** Koyu bir ana ekran zemini, tek renk içerik ve bir renk tonu (ör. #8FB4FF).
- **Widget yazı boyu:** Bugün widget kelimesi xxxLarge'da (Title 3 = 26 pt), düğmeler xxLarge'da büyümeyi durdurur. Diğer satırlar sığmazsa aynı düzen sırayla AX4 → AX3 → AX2 → AX1 → xxxLarge boyunda denenir. Yeni yönde başka bir sınır seçersen README'ye yaz.

---

## 9. Önceki çalışmalar ve kararlar

Aşağıdakileri tekrar önerme. Önereceksen nedenini yaz.

### 21 Ekim: birleşik tasarım (bugünkü temel)
- Üç tasarımcı yarıştı: okunabilirlik, marka ve iOS 26 yerel. Okunabilirlik kazandı.
- Diğerlerinden alınanlar:
  - fosfor şeridi;
  - Dikkat farkı;
  - "Neden?" kutusu;
  - camın yalnız denetimlerde olması;
  - seviye noktaları.

### "Sakin ilerleme"
- İlerleme günle değil kelimeyle ölçülür.
- Seri, suçluluk ve rozet yok.
- Basamaklar: Yeni → Tanıdık → Güçleniyor → Sağlam → Çok sağlam → Yerleşti.
- Kısmen uygulandı.

### Gece / OLED
- Gece sayfa zemini saf siyah, kartlar dolgusuz. Gece hiçbir yerde sarı dolgu yok.
- **24 Ekim kararı:** Gece ana düğmesi dolgulu beyaz, yazısı siyah. Önceki "%12 dolgu + 2 pt kenar" düğmesi ikincil düğmeye benzediği için bırakıldı.
- **Reddedilen:** Uygulama içinde ekstra karartma.
- **Bekleyen:** Kehribar ya da "soluk fosfor" gece tonu. Kullanıcı onayı bekleniyor.

### 23 Ekim: widget dilleri, karar "Sakin şerit"
Karar alındı, **büyük kısmı henüz koda geçmedi.** Bugünkü dil sakinleşerek kalıyor.

**Kararlaştırılanlar:**
- **Şerit:** Widget'ta şerit yarı yüksekliğe (0.4 em) iner. İki satırlık kalıpta bant gibi görünmez.
- **Örnekteki kelime:** Örnek cümlede kelimenin sarı işareti (yalnız tam renkte).
- **Küçük widget:** Kelime bir basamak büyür.
- **Anlam:** Ağırlığı kalın yerine yarı kalın.
- **Düğmeler:** 1 pt `lineStrong` kenar alır (3:1 sınır).
- **Orta widget:**
  - Katmanlar: kelime ve "isim · A1" etiketi, Türkçe anlam, örnek.
  - Okunuş, İngilizce tanım ve "Yeni kelime" satırı büyük widget'a gider.
  - Altta **adlı kapsül düğme satırı**: "Biliyorum · Dinle · Sonraki". AX boylarında bugünkü simge sütununa döner.

**Reddedilenler:**
- kenardan başlayan şerit;
- serif Türkçe;
- BÜYÜK HARFLİ etiketler;
- sarı imleç;
- kâğıt dokulu zemin;
- "Az önce" listesi (görmek tekrar değildir);
- dolu siyah "Sonraki" düğmesi;
- en kalın (Black/Heavy) ağırlıklar;
- kenarsız simge düğmeler;
- saf siyah widget gece zemini.

**Yönler için:** En az bir yönün widget'ları bu kararı temel alsın. Diğer yönler farklıysa nedenini yaz.

---

## 10. Karar vermeni istediğimiz sorular

README'de her yön için kısa cevap ver ve cevabını mockup'ta göster.

### Tur 1'de cevapla
1. Normal Akış kartından **kartın tamamına** nasıl gidilir?
2. Akış kartında metin boyları 4'te kalırken **simge ve süs boyları** (13 pt simgeler, 34 pt tırnak) hiyerarşiye nasıl oturur? Hangi rol hangi stili alır?
3. Kart iç boşluğu ve boşluklar **8 pt ızgarasına** nasıl oturur? Bugün iç boşluk 20; metin kenardan 36 pt içeride.
4. **"Söyle"** yazılı mı olur, simge mi? Akış'ta ve kartın tamamında aynı mı olur?
5. **Seviye** her yerde aynı ve kapsülsüz nasıl gösterilir?
6. **"Biliyorum" onayı** nasıl olur: Akış'ta (bugün ters renkli bildirim) ve widget'ta (bugün hiç yok)?
7. Orta widget için karar adlı düğmelerdi. Bunu **küçük, orta ve büyük** widget'ta nasıl tutarlı uygularsın? AX boylarında ne olur?
8. "Anlamı gizle" açıkken **küçük widget'taki** üç dokunma hedefi sorunu nasıl çözülür?
9. Örnek cümledeki **süs tırnak** kalsın mı?
10. **Widget şeridi** 0.4 em'e inince nasıl görünür? Uygulamadaki şeritle uyumlu mu?

### Tur 2'de cevapla
11. **Kırmızı kullanmadan** yanlış cevap nasıl belirgin olur (quiz kartı ve quiz widget'ı)?
12. Alıştırma kartları (3, 4, 5) için **tek bir dil** nasıl kurulur: köşe, cümle boyu, şık, geri bildirim kutusu, alt çubuk?
13. **Kartın tamamı ve "Neden?"** için tek yapı nasıl olur: kutu mu, çizgi mi?
14. **Köken** ve **eş anlamlılar** gösterilsin mi? Gösterilecekse nerede?
15. Gece **dolgulu beyaz ana düğme** siyah sayfada fazla parlamadan nasıl durur?
16. **Paylaşım kartında** marka imzası nasıl olur?

---

## 11. Yasaklar

**Kapsam**
- Kod yazma. Depodaki dosyaları değiştirme. Yalnız `docs/tasarim/codex/` klasörüne yazabilirsin.
- Masaüstü ya da web sayfası düzeni yapma. Her şey telefon ya da widget çerçevesinde olur.

**Metin ve yazı**
- "…" ile kesilen metin yok.
- Kelimeyi 0.75'in altına küçültme yok. Widget'ta ölçek küçültme hiç yok (§4.5).
- Harf aralığını daraltma yok.
- 11 pt altında yazı yok.
- Sabit punto yok; Dynamic Type stil adı kullan.
- Bir ekranda 4'ten fazla metin boyu yok.

**Renk**
- Sarı düğme, sarı zemin, sarı ikon ya da sarı büyük alan yok. Sarı yalnız kelime şeridinde ve örnekteki kelime işaretinde olur.
- Yeni vurgu rengi ya da tema yok.
- Mavi bağlantı yok.
- Kırmızı (`bad`) kart yüzeylerinde yalnız Dikkat'te olur: ✕ işareti ve yanlış cümlede değişen kelimenin noktalı alt çizgisi.
- Yanlış cevapta kırmızı yok.

**Biçim**
- Dokunulamayan şeye kapsül biçimi yok. Dokunulan şey kenarsız olmaz.
- İçerik katmanında cam (Liquid Glass) yok.
- Fotoğraf, illüstrasyon, emoji ve süs görseli yok. Simgeler SF Symbols olur.

**Ton**
- Seri, puan, rozet, konfeti, "Harika!" ya da "Yanlış!" yok.
- Övgü ve suçlama yok.
- "Az önce gördüklerin" gibi eski kelime listesi yok.

**Hareket**
- Sonsuz animasyon yok.
- 200 ms'den uzun animasyon yok.

**Dil**
- Türkçe metinde "siz" hitabı yok.
- Uydurma terim yok (§4.6).
- Değişkene, sayıya ya da saate ek yok.

**Widget**
- Küçük widget'ta tür, seviye, okunuş, tanım, örnek ya da üçüncü bir düğme yok.
- Kilit ekranında düğme yok, üçüncü satır yok, saydam beyaz yok.
- Kendiliğinden kaybolan onay yok. Kaydırma, sheet ve menü yok.
- 44×44'ten küçük dokunma alanı yok.

---

## 12. Teslimden önce kontrol listesi

Bu liste **A, B ve C** için. Yön 0 için değil.

README'ye "kontrol listesi: geçti" yaz. Geçmeyen madde varsa nedenini açıkla.

**Çerçeveler**
- [ ] §8.1'deki zorunlu çerçevelerin hepsi var.
- [ ] İstenen yerlerde açık ve koyu çerçeve var (§8.4'teki istisnalar dışında).
- [ ] SE ve AX5 çerçeveleri var (widget'lar dahil). Hiçbir metin kesilmiyor, hiçbir şey taşmıyor.
- [ ] Widget'lar gerçek boylarında.

**Yazı**
- [ ] Hiçbir ekranda 4'ten fazla metin boyu yok.
- [ ] Hiçbir yazı 11 pt altında değil.
- [ ] Bütün yazılar Dynamic Type stil adıyla belgelendi.
- [ ] Okuma sırası her yüzeyde aynı: kelime → Türkçe anlam → tanım → örnek.

**Renk ve kontrast**
- [ ] Sarı yalnız şeritte ve örnekteki kelimede. Bir ekranda en çok iki sarı işaret var.
- [ ] Metin kontrastı açık, koyu ve Yüksek Kontrast'ta en az 4.5:1.
- [ ] Denetim sınırları en az 3:1. Kontrol ettiğin çiftler README'de.

**Ölçüler ve biçim**
- [ ] Dokunma alanları en az 44×44 ve aralarında en az 8 pt boşluk var.
- [ ] Kenar boşluğu 16 pt, boşluklar 8 pt ızgarasında.
- [ ] Dokunulamayan hiçbir şey kapsül değil. Dokunulan her şeyin dolgusu ya da kenarı var.

**Metin**
- [ ] Türkçe metinler §4.6'ya uygun. Yeni metinler işaretli.

**Widget**
- [ ] Küçük widget yalnız kelime + anlam + 2 düğme.
- [ ] Kilit ekranı tek renk, opak gri, iki katman, düğmesiz.
- [ ] Renklendirilmiş modda hiyerarşi yalnız boy ve kalınlıkla kuruluyor.

**README ve teslim**
- [ ] §10'daki Tur 1 soruları cevaplandı.
- [ ] Her yönün neyi feda ettiği yazıldı.
- [ ] Yön 0 aynı çerçevelerde var ve karşılaştırma tablosu dolu.
- [ ] README'nin başında "Tur 1 bitti, yön seçimi bekleniyor." yazıyor.
