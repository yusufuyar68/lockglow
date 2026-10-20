# Güncel fark raporu: rakipler ve Lockglow (2026-10-20)

Önceki raporlar (01–13) 10 Ekim tarihli. Bu rapor iki şeye bakıyor: o günden bu yana rakiplerde ne değişti, Lockglow bugün rakiplere göre nerede duruyor.

**Kaynak:** Apple'ın iTunes lookup API'si, App Store sayfaları ve TR yorum akışı (20 Ekim). Kolay İngilizce, Orbit ve WordPal güncellemeleri API'den ayrıca doğrulandı. Diğer rakamlar tek kaynaktan geliyor.

---

## 1. 10 günde ne değişti?

### En önemli üç gelişme

1. **Kolay İngilizce widget'a geçti (19 Ekim, v4.7).**
   - Türkiye'nin en büyük kelime uygulaması bu: 36.919 TR puanı, 4.80.
   - 2025'ten beri ilk güncellemesi. Ana ekran ve kilit ekranı widget'ı geldi: günün kelimesi, anlamı, günlük ilerleme.
   - Fiyatlar: aylık ₺49,99, yıllık ₺299,99, aile ₺399,99, ömür boyu ₺499,99.
   - **Sonuç:** "Türkçe açıklamalı kilit ekranı kelime uygulaması" alanı artık boş değil. 03 numaralı raporun "1. fırsat" maddesi zayıfladı.
2. **Orbit (Widget Vocabulary) hızla büyüyor, ama kullanıcıları kızgın.**
   - v3.1.0 (11 Ekim): telaffuz alıştırması. Kelimeyi 5 saniyede sesli söylüyorsun, uygulama doğru mu diye bakıyor, seri tutuyor.
   - TR puan sayısı 10 günde 190'dan 297'ye çıktı, puan 4.37'den 4.28'e düştü. TR Eğitim listesinde 3. sıradan yaklaşık 6. sıraya indi.
   - Fiyat değişmedi: haftalık ₺499,99, yıllık ₺2.499,99.
   - Son 10 TR yorumdan 8'i şikâyet:
     - 6'sı fiyat ve ödeme duvarı ("haftada 500 TL'ye değmez");
     - 3'ü yanıltıcı reklam ("reklamda widget bedava, uygulama paralı");
     - 1'i kelimelerin YDS/YÖKDİL'e uymadığını söylüyor;
     - 1'i hata bildiriyor: ana ekran widget'ı "deste yok" diyor, kilit ekranı çalışıyor.
3. **Sesli telaffuz alıştırması ortak trend oldu.** Orbit (söyle ve kontrol et), Lingo Widget (anlam ve telaffuz hatırlama) ve Wordismo (konuşma dersleri, yapay zekâyla sohbet) aynı hafta bunu ekledi.

### Diğer rakipler

| Uygulama | Değişiklik |
|---|---|
| Monkey Taps Vocabulary | v7.5.0 (14 Ekim): yeni temalar, yeni kelimeler. Başka bir şey yok. |
| WordPal | v4.7.2 (14 Ekim): **ilk kilit ekranı widget'ı.** |
| Lingo Widget | v4.5.10 (16 Ekim): bilinen kelimeler günlük karttan düşüyor, hızlı hatırlama sorusu. |
| Atlas | v7.17 (13 Ekim): yalnızca hata düzeltme. |
| Kelime+ (YDS) | v2.54.0 (12 Ekim): yeni cihazlar için küçük tasarım düzeltmeleri. |
| Wordismo | v4.0.13 (15 Ekim): konuşma pratiği, yapay zekâyla sohbet. |
| Learna | v4.0.0 (20 Ekim): "yapay zekâ iyileştirmeleri". TR Eğitim'de yaklaşık 4. sırada. |
| Vocabulous, WordUp, Blarma | Yeni sürüm yok. |

### Kimsede olmayanlar (hâlâ boşluk)

- Hiçbir rakip **Denetim Merkezi (Control Center) widget'ı, StandBy, Canlı Etkinlik (Live Activity)** ya da **cihaz içi yapay zekâ (Apple Foundation Models)** duyurmadı.
- Hiçbiri **FSRS** gibi modern bir tekrar algoritmasından söz etmiyor.
- Ekim ayında öne çıkan yeni bir kilit ekranı kelime uygulaması bulunamadı. Arama dar kaldı, kesin değil.
- Apple'ın 4.3 (kopya uygulama) kuralıyla ilgili Ekim'de yeni bir haber bulunamadı.

---

## 2. Lockglow bugün nerede?

### Rakiplerden güçlü olduğu yerler

- **İçerik kalitesi:** 753 kart, elle denetlenmiş. Türkçe anlam, örnek cümle ve Türkçesi, yaygın hatalar, eşdizimler var. Rakiplerin 1 yıldızlı yorumlarındaki en büyük dert olan yanlış ve uydurma kelime sorunu burada yok.
- **Widget'ta Türkçe anlam önde.** Ne Orbit'te ne Monkey Taps'ta var.
- **"Biliyorum" ve "Sonraki" düğmeleri widget'ın içinde.** Rakiplerde en çok istenen özellik buydu (02 numaralı rapor, 6. madde).
- **Ana ekran ve kilit ekranı aynı kelimeyi gösteriyor.** Orbit'teki "ana ekranda deste yok" hatasının tersi.
- **Gerçek aralıklı tekrar:** Leitner kutuları ve boşluk doldurma sorusu. Monkey Taps'te ve Orbit'te aralıklı tekrar yok.
- **Reklam yok, hesap yok, ağ yok.** Her şey cihazda.

### Eksikler

Önem sırasına göre:

| # | Eksik | Kimde var | Not |
|---|---|---|---|
| 1 | **Widget görünümü sade, gri.** Tema ve renk seçimi yok. | Monkey Taps, Orbit, MyVocab, Lingo | Mağazada ilk göze çarpan şey bu. Başka oturumda **`tasarim/arayuz-mockup`** dalında üzerinde çalışılıyor. |
| 2 | **Açılış (onboarding) ekranı yok.** Seviye seçimi, widget kurma rehberi yok. | Herkeste. Kolay İngilizce bile "adım adım widget rehberi" ekledi. | Widget kurmayı bilmeyen kullanıcı uygulamayı bırakır. |
| 3 | **Konu ve sınav desteleri yok.** Kullanıcı neyi öğreneceğini seçemiyor (ör. yalnızca iş, yalnızca seyahat). | Orbit, Monkey Taps, Kelime+ (YDS) | Seyahat, iş, sağlık, sosyal setleri başka oturumlarda yazılıyor. Uygulamaya "deste seç" ekranı da gerekecek. |
| 4 | **Sesli telaffuz alıştırması yok.** Yalnızca dinleme var. | Orbit, Lingo, Wordismo | Ekim'in ortak trendi. Apple'ın konuşma tanıma özelliğiyle (Speech) cihazda yapılabilir. |
| 5 | **Kendi kelimeni ekleme yok.** | Orbit (5 özel deste), Atlas, Quizlet | Yorumlarda en çok istenenlerden. |
| 6 | **Widget'tan ses yok.** | Birkaç küçük rakip | **`ios/widget-ses`** dalında başka oturumda yapılıyor. |
| 7 | **"Zor/Kolay" cevabı main'de değil.** | WordUp, Atlas | **`ios/zor-kolay`** dalında hazır, main'e birleşmeyi bekliyor. |
| 8 | **Ödeme sistemi yok** (StoreKit). | Herkeste | Kişisel kullanım için gerekmez. Mağazadan önce gerekir. |
| 9 | **Paylaşma yok.** Kelime kartını resim olarak paylaşma yok. | Monkey Taps | Büyüme için ucuz bir kanal. |

---

## 3. Öneriler

### Tasarım

1. **Widget'a karakter kazandır.** Koyu arka plan, tek vurgu rengi, 3–4 hazır tema. Türkçe anlam renkli olsun. Orbit'in koyu ve yıldızlı görünümü TR'de tutuyor. Bu iş `tasarim/arayuz-mockup` dalının konusu, oradaki taslakla birleştirilmeli.
2. **Kısa bir açılış akışı ekle**, en çok 4 ekran:
   1. seviye (A1 / A2 / B1);
   2. konu seçimi;
   3. "widget nasıl eklenir" animasyonu;
   4. ilk kelime.

   Ödeme duvarı açılışta olmamalı. Orbit'in yorumlarındaki en büyük öfke bu.
3. **"Deste seç" ekranı.** Yeni setler (seyahat, iş, sağlık, sosyal) gelince kullanıcı widget'ta hangilerinin döneceğini seçebilmeli.

### Özellik

4. **Sesli telaffuz alıştırması.** Apple'ın konuşma tanıma özelliğiyle cihazda çalışır, sunucu ve ücret gerekmez. Rakipler yeni ekledi; TR'de Türkçe açıklamalı sürümü yok.
5. **Denetim Merkezi widget'ı ve StandBy görünümü.** iOS 18'den beri var, kimse kullanmıyor. Ucuz bir fark yaratır. Ör. Denetim Merkezi'nde "sıradaki kelime" düğmesi; telefon şarjdayken yatay ekranda büyük kelime kartı.
6. **Kendi kelimeni ekle.** Basit bir form: kelime, Türkçe anlam, isteğe bağlı örnek. Widget dönüşümüne katılsın.

### Altyapı

7. **FSRS'e geçiş** (planda v1.2 olarak duruyor). Rakiplerin hiçbiri modern tekrar algoritmasını öne çıkarmıyor. Mağaza metninde "akıllı tekrar" diye anlatılabilir. Önce `ios/zor-kolay` dalı birleşmeli, çünkü FSRS dört cevap ister (Tekrar, Zor, İyi, Kolay).
8. **iCloud yedeği** (CloudKit, isteğe bağlı). Şu an ilerleme yalnızca cihazda. Telefon değişince ilerleme kaybolur. Hesap gerektirmez, Apple kimliğiyle çalışır.
9. **Cihaz içi yapay zekâ (Apple Foundation Models), ihtiyatla.** Örneğin kullanıcının eklediği kelimeye örnek cümle önerebilir. Ama Lockglow'un gücü elle denetlenmiş içerik. Yapay zekâ yalnızca kullanıcının kendi kelimelerinde ve "öneri" etiketiyle kullanılmalı.

### Mağazaya çıkış (sonra)

10. **Fiyat:** Kolay İngilizce çıpası ₺299,99/yıl ve ₺499,99 ömür boyu. Orbit'in haftalık ₺499,99'u tepki çekiyor.
    - Haftalık abonelik koyma.
    - Kilit ekranı widget'ı **ücretsiz kalsın**.
    - Paralı kısım desteler, temalar ve alıştırmalar olsun.
11. **Reklam dürüst olsun:** "Ücretsiz widget" deniyorsa gerçekten ücretsiz olmalı. Orbit bu yüzden 1 yıldız alıyor.
12. **4.3 riski:** Kategori kalabalık. Mağaza metninde "Türkçe anlam, elle denetlenmiş içerik, aralıklı tekrar" farkı açıkça yazılmalı; kopya gibi görünen metin ve ekran görüntüsünden kaçınılmalı.

---

## 4. Kısa özet

- Rakipler 10 günde üç şey yaptı: **kilit ekranı widget'ı ekledi** (WordPal, Kolay İngilizce), **sesli telaffuz ekledi** (Orbit, Lingo, Wordismo), **fiyatı değiştirmedi** (Orbit hâlâ çok pahalı ve kullanıcıları şikâyetçi).
- Lockglow **içerik, Türkçe anlam, widget düğmeleri ve tekrar sisteminde** önde.
- Lockglow **görünüm, açılış akışı, deste seçimi ve telaffuz alıştırmasında** geride.
- En büyük yeni tehdit **Kolay İngilizce**: büyük Türk kitlesi, ucuz fiyat, artık widget'ı da var.
- Sıradaki en etkili üç iş:
  1. widget tasarımı (zaten başladı);
  2. açılış akışı ve deste seçimi;
  3. sesli telaffuz alıştırması.
