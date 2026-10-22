# Ekran görüntüsü başlıkları (10 kare)

> **TASLAK (22 Ekim 2026).** Görüntüler: `docs/ekran-goruntuleri/yeni-tasarim-2026-10-22/`.
> **Marka uyarısı:** "Lockglow" adı için TÜRKPATENT araması ve marka vekili görüşü yapılmadı; karelerde ad ve ikon kesin değildir.

## Kurallar

- **Sıra önemli:** Aramada yalnızca ilk 2–3 dikey kare görünür. En güçlü üç fayda başa: kilit ekranı, Türkçe kart, widget'tan ses.
- **Başlık:** 2 satırı geçmesin; en çok yaklaşık 30 karakter (`raporlar/08_aso_isim_metadata.md` §6.1 ≤35 diyor). "Sen" diliyle, uygulamanın arayüzüyle aynı. Önce fayda, sonra özellik.
- **Gerçeği göster** (Kural 2.3.3): her kare uygulamanın gerçek ekranı ya da gerçek widget'ı olmalı. Sayılar doğru olmalı (933 kart; "10.000+" gibi şişirme yok).
- **Boyut (Apple'ın güncel kuralı, 22 Ekim 2026):**
  - **Zorunlu olan 6.3":** Apple'ın adıyla "iPhone with Dynamic Island (medium display)". Dikey **1206 × 2622** (iPhone 16 Pro, 17 Pro, 17) ya da 1179 × 2556 piksel. En az 1, en çok 10 görüntü.
  - **6.9" artık zorunlu değil:** 1260 × 2736, 1290 × 2796 ya da 1320 × 2868 (Pro Max). İsteğe bağlı.
  - **6.5":** 1284 × 2778 ya da 1242 × 2688. Yalnız 6.9" görüntü verilmezse isteniyor.
  - Apple, görüntüyü küçük ekranlar için kendisi küçültür. PNG ya da JPEG olur; saydamlık (alfa kanalı) olmaz.
  - Kaynak: [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications). Mağaza görseli oturumu 22 Ekim'de baktı (`docs/magaza/gorseller/README.md`).
  - Eski kural "6.9" ya da 6.5" zorunlu" diyordu; artık geçerli değil.
- **Hangi görüntüler bu boyutta:**
  - `docs/ekran-goruntuleri/yeni-tasarim-2026-10-22/` klasöründe yalnız `01` büyük (1320 × 2868, 6.9"). Ötekiler SE görüntüsü (750 × 1334); mağazada kullanılamaz.
  - `screenshots.yml` artık `pro` geçişinde iPhone NN Pro simülatöründe, yani doğrudan **1206 × 2622** boyutunda çekiyor. Çıktı, artifact içinde `named/pro/<ad>.png` olarak gelir (aşağıda "Yeniden çekim notları").
- **Yaş:** Kareler ve ikon her yaşa uygun olmalı (Kural 2.3.8).
- **Rakipten farklı görün** (Kural 4.3 riski): Orbit'in koyu lacivert, yıldızlı arka planını ve maskotlarını kullanmayın. Lockglow'un kendi kâğıt rengi (`#F3F3EE`) ve fosfor sarısı (`#F5E829`) yeter (`docs/tasarim/`).

## 10 kare

| # | Başlık (TR) | Uz. | Alt satır (isteğe bağlı) | Kullanılacak görüntü | Durum |
|---|---|---|---|---|---|
| 1 | **Telefona baktıkça bir kelime** | 28 | Türkçe anlamıyla, kilit ekranında | Kilit ekranı widget'ı, duvar kâğıdı üstünde (`WidgetSnapshotTests` "Lock Screen plate" çekimi) + saat 9:41 | **Yeni çekim/montaj gerekir.** Klasörde kilit ekranı karesi yok; en önemli kare bu |
| 2 | **Türkçe anlamı, örneği, sesi** | 27 | 933 kart: A1, A2, B1 | `01-akis-kelime-karti.png` | **Hazır** (1320 × 2868) |
| 3 | **Uygulamayı açmadan dinle** | 24 | Widget'ta Biliyorum, Dinle, Sonraki | `05-widget-orta.png` + `06-widget-kucuk-koyu.png`, bir ana ekran montajında | Montaj gerekir; widget'taki "9:00 AM" → "09:00" (Türkçe bölge ayarı) |
| 4 | **Sık yapılan hatayı baştan gör** | 29 | 571 kartta Dikkat kutusu | `01`'in "Dikkat" bölümü büyütülerek, ya da Pro Max'te Dikkat kutusu ortada yeniden çekim | Hazır görüntüden kırpma ya da yeniden çekim |
| 5 | **Söyle, telefon seni dinlesin** | 28 | Ses telefondan çıkmaz | Söyle sayfası, "Anlaşıldı!" sonucuyla (`LockglowScreenshotTests.testCaptureLongLemmaAndSoyle`) | **Yeni çekim gerekir** (klasörde yok) |
| 6 | **Unutmadan önce yeniden gelir** | 28 | Bilemedim, Zor, Bildim, Kolay | `02-tekrar-dort-cevap-se.png` | **Pro Max'te yeniden çek.** SE'de "Devamı ↓" Dikkat kutusunun üstüne biniyor |
| 7 | **Boşluğu doldur, kalıcı öğren** | 28 | Yanlışta doğrusunu hemen gör | `03-quiz-yanlis-cevap.png` | **Yeniden çek** (kırpılmış, 750 × 958). Tercihen doğru cevap anı; yanlış anı olumsuz durabilir |
| 8 | **Seviyeni seç: A1, A2 ya da B1** | 29 | İlk açılışta, bir dakikada | `08-acilis-seviye-se.png` | **Pro Max'te yeniden çek** |
| 9 | **Ara, bul, örnekleriyle dinle** | 28 | ı/i, ş/s karışsa da bulur | `09-sozluk-kart-se.png` | **Pro Max'te yeniden çek**; alttaki yarım "Dikkat" satırı görünmesin |
| 10 | **Reklam yok, hesap yok** | 21 | İlerlemen telefonunda kalır | `10-ayarlar-se.png` yerine: Ayarlar'da widget sağlığı **"Çalışıyor"** (yeşil) ve günlük hatırlatma görünür hâlde | **Yeniden çek.** Şimdiki görüntüde kırmızı "Güncellemiyor" var; mağazada "bozuk" izlenimi verir |

Başlık uzunlukları Python'la sayıldı (karakter).

**Kullanılmayacak:** `04-tekrar-baslangic-se.png` (her şey sıfır, boş durum) ve `07-widget-orta-renklendirilmis.png` (renklendirilmiş mod mağazada sönük durur; istenirse 3. karenin montajında küçük bir örnek olabilir).

## Yeniden çekim notları

- `screenshots.yml` (22 Ekim'den beri) üç geçiş çalıştırır: `se` (iPhone SE, açık), `pro` (iPhone NN Pro, 6.3", açık; mağaza boyutu) ve `pro-koyu` (aynı cihaz, koyu mod). İstenirse `-f gecisler="pro promax"` ile Pro Max (6.9") de eklenir. Bütün eksikler **tek turda** toplanıp bir kez çalıştırılmalı (Intel makinede ~1 saat).
- Görüntüler artifact içinde `named/<geçiş>/<ad>.png` adıyla gelir (`1-akis.png`, `17-tekrar-quiz-soru.png` gibi). Artifact 7 gün saklanır.
- Durum çubuğu iş akışında ayarlanıyor: saat **9:41**, tam Wi-Fi ve hücresel çubuk, tam pil, "Carrier" yazısı yok (`xcrun simctl status_bar … override`). Simülatör bölgesi İngilizce (ABD) kalıyor; uygulama metinleri zaten Türkçe.
- **Simülatörde çekilemeyenler:**
  - kilit ekranı (1. kare);
  - Söyle'nin "Anlaşıldı!" sonucu (5. kare): gerçek konuşma gerekiyor, uygulamada deneme yolu yok;
  - Ayarlar'da widget sağlığı **"Çalışıyor"** (10. kare): simülatörde widget listesi boş geliyor, satır "Bilinmiyor" diyor.

  Bu üçü gerçek iPhone'dan çekilmeli. Mağaza karesinde istenirse Ayarlar yerine başka bir ekran kullanılabilir.
- **Quiz (7. kare):** `testCaptureWaitedQuiz` Tanış turunda iki kez yanlış cevaplanan kelimeyi 10 dakika bekleyip tam ekran boşluk doldurma olarak çeker: `17-tekrar-quiz-soru` (soru) ve `17-tekrar-quiz-cevap` (doğru cevap anı). Yalnız `pro` geçişinde çalışır (bekleme ~8 dk).
- Açık tema ağırlıklı; bir kare (ör. 3'teki küçük widget) koyu tema olabilir.
- 2. ve 4. kare aynı görüntüden çıkıyorsa 4. kare için başka bir kelime seçin (ör. "look forward to" ya da bir phrasal verb).

## İngilizce (en-GB) başlıklar

| # | Başlık (EN) | Uz. |
|---|---|---|
| 1 | One word every time you look | 28 |
| 2 | Meaning in Turkish, with audio | 30 |
| 3 | Listen without opening the app | 30 |
| 4 | See common mistakes first | 25 |
| 5 | Say it, your phone listens | 26 |
| 6 | Words return before you forget | 30 |
| 7 | Fill the gap, remember it | 25 |
| 8 | Start at A1, A2 or B1 | 21 |
| 9 | Search and hear examples | 24 |
| 10 | No ads, no account | 18 |

İngilizce yerelleştirmede de **aynı Türkçe arayüz görüntüleri** kullanılır (uygulama Türkçe); başlık İngilizce olur.
