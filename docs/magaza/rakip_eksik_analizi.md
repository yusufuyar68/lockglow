# Türkiye'deki rakipler ve Lockglow'un eksikleri (25 Ekim 2026)

> Ayrıntılı rakip tabloları ve anahtar kelime stratejisi: [`rakip_analizi.md`](rakip_analizi.md) (23 Ekim). Bu belge onun üzerine kurulu ve şu soruya cevap veriyor: rakiplerde ne var, bizde ne yok?
>
> **Kaynaklar:**
> - 25 Ekim'de taranan TR App Store sayfaları.
> - Üçüncü taraf siteler (Tamindir, AlternativeTo ve benzerleri).
> - Kodun bugünkü hali (build 39).
>
> [D] = bilgi yalnızca üçüncü taraf bir kaynaktan geliyor, doğrulanmadı.

---

## 1. Rakipler beş gruba ayrılıyor

| Grup | Örnekler | Güçlü yanı | Fiyat (TR) |
|---|---|---|---|
| **A. Büyük Türkçe kelime uygulamaları** | Kolay İngilizce (36.919 puan, 4,8), Atlas (8.634), English Words Trainer (5.286), Blarma (5.413), WordUp (3.588) | Çok puan, geniş içerik, sınav listeleri, Android'de de varlar | Kolay yıllık ₺299,99; Atlas yıllık ₺699,99; WordUp Pro yıllık ₺284–399 |
| **B. Sınava odaklı** | Kelibu (YDS, YÖKDİL, YDT), YDS TOEFL Kelime Kartları (319 puan), EnPratik [D], Flaş İngilizce | YDS, YÖKDİL ve TOEFL listeleri; A1–C2; deneme sınavları | Kelibu yıllık ₺2.499,99 (pahalı); Kartlar yıllık ₺599,99 |
| **C. Widget odaklı (doğrudan rakipler)** | Orbit/Widget Vocabulary (Eğitim'de 7. sırada), Lugat, Wordlet, Lingo Widget, Zarafa, Wrd, Word Widget | Kilit ekranında Türkçe anlam, widget'ta "Biliyorum" düğmesi | Lugat ve Wordlet ücretsiz. Orbit ₺499,99/hafta, Lingo ₺119,99/hafta |
| **D. Kilit ekranı katmanı** | WordBit (yalnızca Android'de gerçek kilit ekranı katmanı [D]) | Telefonun kilidi her açıldığında soru; A1–C2; 10 binden fazla kelime [D] | Ücretsiz ve reklamlı [D] |
| **E. Genel dil uygulamaları** | Duolingo (496 bin puan), Monkey Taps Vocabulary (Türkçe yok) | Marka, seri, sosyal özellikler | Duolingo ₺329–1.209 |

Küçük, yeni Türkçe uygulamalar da var: Vocaby (4.000+ kelime), İngilizce Kelime Ezberleme App (aylık ₺49,99, haftalık yarışma, kitaptan kelime ekleme), Kelime Defteri. Puanları çok az; tehdit değiller ama fikir verecek özellikleri var.

---

## 2. Özellik karşılaştırması

| Özellik | Lockglow | Rakiplerde durum |
|---|---|---|
| Kilit ekranı ve ana ekran widget'ı, Türkçe anlam | ✅ | Artık sıradan (C grubunun hepsinde, Kolay'da da) |
| Widget'ta soru (quiz widget) | ✅ | Lugat'ta mini test, Lingo'da "Quick Recall" |
| Widget'tan, uygulamayı açmadan sesli okuma | ✅ | Lingo'da yalnızca premium'da; uygulamayı açmadan çaldığı belli değil [D] |
| Live Activity, Denetim Merkezi, StandBy, Siri | ✅ hepsi | Zarafa'da Live Activity, Wordlet'te Denetim Merkezi var. **Hepsi bir arada başka kimsede yok** |
| Apple Watch | ✅ (henüz yayında değil) | Gördüğüm rakiplerde yok |
| Aralıklı tekrar | ✅ Leitner (FSRS kapalı) | Wordlet FSRS'yi varsayılan kullanıyor; büyük uygulamalarda "akıllı tekrar" var |
| Türk konuşanların tipik hataları, "Dikkat" kutusu, sahte dostlar | ✅ | **Kimsede tam karşılığı yok.** En güçlü farkımız bu |
| Cihazda telaffuz kontrolü | ✅ | Orbit'te ve Kartlar'da var, ama ses cihazdan çıkıyor mu belli değil |
| Kulak alıştırması (minimal çiftler), cümle kurma | ✅ | Gördüğüm rakiplerde yok |
| Hesap yok, reklam yok, veri toplanmıyor | ✅ | Lugat'ta da böyle; tek başına fark yaratmıyor |
| **Kelime sayısı** | ❌ **1.383** | Vocaby 4.000+, Kartlar 5.000+, WordBit 10 bin+ [D] |
| **B2, C1, C2 seviyeleri** | ❌ yok (en üst B1) | Neredeyse herkes A1–C2 diyor |
| **Sınav listeleri (YDS, YÖKDİL, YDT, IELTS, TOEFL)** | ❌ | Atlas, Kelibu, Kartlar, Flaş, EnPratik, WordBit |
| **Gerçek insan sesi** | ❌ (sistem sesi; voices.json boş) | EWT'de ana dili İngilizce olan kişinin sesi var, Kartlar'da ABD ve İngiliz sesi |
| **Görsel, video, hikâye** | ❌ | Kelibu'da resim ve video modu, Flaş'ta hikâye ve görsel, WordUp'ta video ve fotoğraf |
| **Yapay zekâ öğretmen veya sohbet** | ❌ | Atlas, Flaş, WordUp (GPT sohbeti) |
| **Sosyal özellikler (lig, düello, sıralama)** | ❌ (bilinçli olarak yok) | Wordlet (düello, lig, seri), Kelibu (lider tablosu), Ezberleme App (haftalık yarışma) |
| **Okuduğun metinden kelime ekleme** | ❌ (yalnızca elle ekleme) | Ezberleme App'te kitap bölümünden ekleme var |
| **Liste paylaşma, öğretmen ve sınıf** | ❌ | Kelime Defteri'nde liste paylaşma var |
| **Cihazlar arası eşitleme** | ⚠️ kod hazır, entitlement bekliyor | Çoğunda hesapla eşitleme var |
| **Android** | ❌ | Kolay, WordBit, EnPratik, Atlas, Duolingo Android'de de var |
| **Gelir modeli** | ❌ (hiç yok) | Herkeste abonelik var; Kolay'da aile planı ve ömür boyu seçenek de var |
| **Mağazada görünürlük ve puan** | ❌ (yalnızca TestFlight'ta) | Kolay 36 bin puan, Orbit Eğitim'de 7. sırada |

---

## 3. Eksiklerimiz, önem sırasıyla

### Kritik (kullanıcı kazanmayı doğrudan etkiliyor)

1. **İçerik B1'de bitiyor ve az.** Türkiye'de kelime uygulaması arayanların büyük kısmı sınava çalışan öğrenciler. Aramalarda "ingilizce b1 kelime" ve "seviye testi" önerileri görünüyor; TOEFL, YÖKDİL ve YDS'yi rakipler öne çıkarıyor. 1.383 kelime ve B2 yok, bu kitleye "yetmez" izlenimi veriyor.
   - **Öneri:** Önce B2'yi ekle (yaklaşık 800–1.000 kelime). Ardından ayrı bir "YDS/YÖKDİL çekirdek" destesi hazırla.
   - "Gündelik İngilizce" konumlanması korunabilir. Sınav destesi ek bir paket olarak sunulabilir; ileride ücretli olması da mümkün.
2. **Android yok.** Türkiye'de telefonların büyük çoğunluğu Android. Kolay ve WordBit büyük kitlelerini oradan topluyor. Kısa vadede bu bir ürün kararı; ama pazar büyüklüğü hesabında iOS'un küçük bir dilim olduğunu kabul etmek gerekiyor.
3. **Mağazada değiliz ve sosyal kanıt yok.** Bu kategoride Ekim ayında en az dört yeni Türkçe widget uygulaması çıktı. Erken çıkıp puan toplamak, yeni özellik eklemekten daha değerli olabilir.

### Önemli (elde tutmayı ve kaliteyi etkiliyor)

4. **Ses kalitesi.** Rakipler "ana dili İngilizce olan kişinin sesi" diye reklam yapıyor. Sistem sesiyle bunu söyleyemiyoruz. **Öneri:** en sık kullanılan 1.000 kelime için kayıtlı ses. Altyapı (`RecordedSpeech`) zaten hazır.
5. **Bağlam ve görsel yok.** Kelibu ve Flaş görselle, WordUp videoyla öğretiyor.
   - **Öneri:** somut kelimelere görsel ekle (A1–A2 için yeterli).
   - Bir de Safari ve paylaşım menüsünden kelime ekleme, Canlı Metin ile kamerayla kelime yakalama özellikleri ekle. Böylece "okuduğun yerden ekle" boşluğu da kapanır.
6. **FSRS hâlâ kapalı.** Wordlet bunu açıkça satış argümanı yapıyor. Deneme bittiyse varsayılan yapılabilir.
7. **iCloud eşitlemesi açık değil.** Telefon değiştiren kullanıcı ilerlemesini kaybetmekten korkar. Bu tek bir entitlement adımı; ucuz bir iş.

### Konumlanma kararı gerektirenler

8. **Oyunlaştırma ve sosyal özellikler.** Seri ve puan olmaması bilinçli bir ilke; Lingo, Wrd ve Zarafa da aynısını söylüyor. Yine de Türkiye'de öğrenci kitlesinde arkadaşla yarışmanın (Kelibu, Wordlet) çekici olduğu görülüyor.
   - **Öneri:** ilkeyi bozmadan bir orta yol bulunabilir. Örnek: isteğe bağlı "arkadaşınla haftalık özet karşılaştır".
   - Paylaşılabilen haftalık özet zaten var.
9. **Yapay zekâ.** Rakipler "yapay zekâ öğretmen" etiketiyle fiyatı ₺2.999'a kadar çıkarıyor.
   - Lockglow'un ilkesiyle uyumlu yol iOS 26'nın cihaz üzerindeki modeli olabilir.
   - "Kelimeyle cümle kur, kontrol etsin" gibi bir özellik veri dışarı çıkmadan yapılabilir. Bu ayırt edici bir iddia olur.
10. **Gelir modeli.** Fiyatlar çok dağınık: ücretsizden ₺499,99/haftaya kadar.
    - Kolay'ın yıllık ₺299,99 ve ömür boyu ₺799,99 fiyatları "makul" algısını belirliyor.
    - Haftalık planlar yorumlarda tepki çekiyor.
    - Mevcut "widget ve temel kelimeler ücretsiz, desteler ücretli" fikri bu tabloya uyuyor. B2 ve sınav desteleri doğal bir ücretli paket olur.

---

## 4. Korunması gereken üstünlüklerimiz

- **Türk konuşanlara özel hata uyarıları ve sahte dostlar:** başka kimsede yok, mağaza sayfasında ilk sırada gösterilmeli.
- **Widget ekosisteminin genişliği:** quiz widget'ı, Live Activity, Denetim Merkezi, StandBy, Siri ve Watch hepsi bir arada başka kimsede yok.
- **Cihazda telaffuz kontrolü, kulak alıştırması ve cümle kurma:** bu üçü birlikte widget rakiplerinin hiçbirinde yok.
- **Gizlilik:** tek başına fark değil ama yukarıdakilerle birlikte güçlü.

**Kısaca:** Ürün kalitesi ve widget derinliğinde öndeyiz. Eksiğimiz içeriğin genişliği (B2 ve sınav), ses, görsel ve mağazada görünürlük. En yüksek getiriyi verecek sıra şöyle:
1. Mağazaya çıkmak.
2. iCloud ile FSRS'yi açmak.
3. B2 destesi.
4. Kayıtlı ses.
5. Sınav destesi.

---

## Kaynaklar

- [Vocabulary – Monkey Taps (TR)](https://apps.apple.com/tr/app/id1084540807)
- [Vocaby](https://apps.apple.com/tr/app/id6476399251)
- [WordUp (TR)](https://apps.apple.com/tr/app/id1365078730)
- [YDS TOEFL Kelime Kartları](https://apps.apple.com/tr/app/id6476772947)
- [Kelibu](https://apps.apple.com/tr/app/id6484268631)
- [Lingo Widget](https://apps.apple.com/tr/app/id6740177041)
- [İngilizce Kelime Ezberleme App](https://apps.apple.com/tr/app/id6670163416)
- [Kelime Defteri](https://apps.apple.com/tr/app/id1552578182)
- [Pratik İngilizce](https://apps.apple.com/tr/app/id993438731)
- [Tamindir – WordBit](https://www.tamindir.com/indir/wordbit/amp/)
- [Tamindir – EnPratik](https://www.tamindir.com/indir/enpratik/)
- [Tamindir – kelime ezberleme uygulamaları](https://www.tamindir.com/blog/ingilizce-kelime-ezberleme_74457/)
- [All Language Resources – WordBit](https://www.alllanguageresources.com/?p=18323)
- [AlternativeTo – WordUp](https://alternativeto.net/software/wordup-vocabulary/about/)
- [Teknoblog – Flashwords](https://www.teknoblog.com/flashwords-uygulama-inceleme/)
- [DonanımHaber – Apple Türkiye 2025](https://www.donanimhaber.com/apple-turkiye-2025-in-en-populer-uygulama-ve-oyunlarini-acikladi--199561)
