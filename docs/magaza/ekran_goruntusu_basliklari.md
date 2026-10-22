# Ekran görüntüsü başlıkları (10 kare)

> **TASLAK (22 Ekim 2026).** Görüntüler: `docs/ekran-goruntuleri/yeni-tasarim-2026-10-22/`.
> **Marka uyarısı:** "Lockglow" adı için TÜRKPATENT araması ve marka vekili görüşü yapılmadı; karelerde ad ve ikon kesin değildir.

## Kurallar

- **Sıra önemli:** Aramada yalnızca ilk 2–3 dikey kare görünür. En güçlü üç fayda başa: kilit ekranı, Türkçe kart, widget'tan ses.
- **Başlık:** 2 satırı geçmesin; en çok yaklaşık 30 karakter (`raporlar/08_aso_isim_metadata.md` §6.1 ≤35 diyor). "Sen" diliyle, uygulamanın arayüzüyle aynı. Önce fayda, sonra özellik.
- **Gerçeği göster** (Kural 2.3.3): her kare uygulamanın gerçek ekranı ya da gerçek widget'ı olmalı. Sayılar doğru olmalı (933 kart; "10.000+" gibi şişirme yok).
- **Boyut:** Apple'ın listesinde büyük iPhone (6.9") için 1260 × 2736, 1290 × 2796 ya da 1320 × 2868 piksel (dikey) kabul ediliyor; bu yoksa 6.5" (1284 × 2778 ya da 1242 × 2688) zorunlu. Cihaz boyutu başına en az 1, en çok 10 görüntü; Apple büyük görüntüyü küçük ekranlar için kendisi küçültür ([Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), 22 Ekim 2026). Klasördeki 10 dosyadan **yalnızca `01` bu boyutta** (1320 × 2868); SE görüntüleri (750 × 1334) mağazada kullanılamaz.
- **Yaş:** Kareler ve ikon her yaşa uygun olmalı (Kural 2.3.8).
- **Rakipten farklı görün** (Kural 4.3 riski): Orbit'in koyu lacivert, yıldızlı arka planını ve maskotlarını kullanmayın. Lockglow'un kendi kâğıt rengi (`#F3F3EE`) ve fosfor sarısı (`#F5E829`) yeter (`docs/tasarim/`).

## 10 kare

| # | Başlık (TR) | Uz. | Alt satır (isteğe bağlı) | Kullanılacak görüntü | Durum |
|---|---|---|---|---|---|
| 1 | **Telefona baktıkça bir kelime** | 28 | Türkçe anlamıyla, kilit ekranında | Kilit ekranı widget'ı, duvar kâğıdı üstünde (`WidgetSnapshotTests` "Lock Screen plate" çekimi) + saat 9:41 | **Yeni çekim/montaj gerekir.** Klasörde kilit ekranı karesi yok; en önemli kare bu |
| 2 | **Türkçe anlamı, örneği, sesi** | 27 | 933 kart: A1, A2, B1 | `01-akis-kelime-karti.png` | **Hazır** (1320 × 2868) |
| 3 | **Uygulamayı açmadan dinle** | 24 | Widget'ta Biliyorum, Dinle, Sonraki | `05-widget-orta.png` + `06-widget-kucuk-koyu.png`, bir ana ekran montajında | Montaj gerekir; widget'taki "9:00 AM" → "09:00" (Türkçe bölge ayarı) |
| 4 | **Sık yapılan hatayı baştan gör** | 29 | 571 kartta Dikkat kutusu | `01`'in "Dikkat" bölümü büyütülerek, ya da Pro Max'te Dikkat kutusu ortada yeniden çekim | Hazır görüntüden kırpma ya da yeniden çekim |
| 5 | **Söyle, telefon seni dinlesin** | 28 | Ses telefondan çıkmaz | Söyle sayfası, "Doğru!" sonucuyla (`LockglowScreenshotTests.testCaptureLongLemmaAndSoyle`) | **Yeni çekim gerekir** (klasörde yok) |
| 6 | **Unutmadan önce yeniden gelir** | 28 | Bilemedim, Zor, Bildim, Kolay | `02-tekrar-dort-cevap-se.png` | **Pro Max'te yeniden çek.** SE'de "Devamı ↓" Dikkat kutusunun üstüne biniyor |
| 7 | **Boşluğu doldur, kalıcı öğren** | 28 | Yanlışta doğrusunu hemen gör | `03-quiz-yanlis-cevap.png` | **Yeniden çek** (kırpılmış, 750 × 958). Tercihen doğru cevap anı; yanlış anı olumsuz durabilir |
| 8 | **Seviyeni seç: A1, A2 ya da B1** | 29 | İlk açılışta, bir dakikada | `08-acilis-seviye-se.png` | **Pro Max'te yeniden çek** |
| 9 | **Ara, bul, örnekleriyle dinle** | 28 | ı/i, ş/s karışsa da bulur | `09-sozluk-kart-se.png` | **Pro Max'te yeniden çek**; alttaki yarım "Dikkat" satırı görünmesin |
| 10 | **Reklam yok, hesap yok** | 21 | İlerlemen telefonunda kalır | `10-ayarlar-se.png` yerine: Ayarlar'da widget sağlığı **"Çalışıyor"** (yeşil) ve günlük hatırlatma görünür hâlde | **Yeniden çek.** Şimdiki görüntüde kırmızı "Güncellemiyor" var; mağazada "bozuk" izlenimi verir |

Başlık uzunlukları Python'la sayıldı (karakter).

**Kullanılmayacak:** `04-tekrar-baslangic-se.png` (her şey sıfır, boş durum) ve `07-widget-orta-renklendirilmis.png` (renklendirilmiş mod mağazada sönük durur; istenirse 3. karenin montajında küçük bir örnek olabilir).

## Yeniden çekim notları

- `screenshots.yml` zaten küçük (SE) **ve büyük (Pro Max)** simülatörde çekiyor (`.github/workflows/screenshots.yml:44–45`). Son çalıştırmanın Pro Max çıktıları GitHub'da duruyorsa yeni çalıştırma gerekmez; yoksa bütün eksikler **tek turda** toplanıp bir kez çalıştırılmalı (~12 dk macOS, kota 10 kat sayılıyor).
- Simülatörde saat **9:41**, Türkçe bölge (24 saat), tam şarj; "Carrier" yazısı görünmesin.
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
