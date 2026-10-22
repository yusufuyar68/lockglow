# Mağaza metinleri (App Store)

> **TASLAK (22 Ekim 2026).** Uygulama henüz mağazada değil; TestFlight'ta. Hiçbir metin App Store Connect'e girilmedi. Girmek ve göndermek kullanıcının işidir (Apple hesabında her değişiklik için açık izin, `DEVIR.md`).

## Marka durumu: önce bunu oku

**"Lockglow" adı için TÜRKPATENT araması (sınıf 9, 41, 42) ve marka vekili görüşü henüz yapılmadı.** Bu klasördeki bütün metinler "Lockglow" adıyla yazıldı ama ad **kesin değil**. Ad değişirse ad alanları, açıklamalar, ekran görüntüsü kareleri ve `docs/legal/` belgeleri birlikte değişir. Tanıtım sayfası (`marketing/landing/`) da bu iki adımdan önce yayımlanmaz.

## Dosyalar

| Dosya | Ne |
|---|---|
| [`kayit_metinleri_tr.md`](kayit_metinleri_tr.md) | Türkçe: ad, alt başlık, tanıtım metni, açıklama, anahtar kelimeler, "Bu sürümde yeni" |
| [`kayit_metinleri_en.md`](kayit_metinleri_en.md) | İngilizce (U.K.): aynı alanlar; neden en-GB |
| [`ekran_goruntusu_basliklari.md`](ekran_goruntusu_basliklari.md) | 10 kare: başlık, kullanılacak görüntü, yeniden çekilecekler |
| [`rakiplerden_ogrenilenler.md`](rakiplerden_ogrenilenler.md) | Rakip sayfalarından ve yorumlardan dersler; söylenmeyecekler |
| [`kategori_yas_fiyat.md`](kategori_yas_fiyat.md) | Kategori, yaş sınırı cevapları, fiyat ve ülke önerisi; abonelik notu |
| [`app_review_notu.md`](app_review_notu.md) | İnceleme ekibine İngilizce not (mikrofon, arka plan sesi) |

## Önerinin özeti

- **Ad (TR):** `Lockglow: İngilizce Kelime` (26)
- **Alt başlık (TR):** `Kilit Ekranında Ezberle, Öğren` (30)
- **Anahtar kelimeler (TR, 99 bayt):** `widget,telaffuz,kartları,ekranı,günlük,ezberleme,öğrenme,kelimeler,sözlük,tekrar,testi,ders`
- **İngilizce (U.K.):** `Lockglow: Vocabulary Widget` / `English for Turkish Speakers`
- **Kategori:** Eğitim + Başvuru Kaynakları. **Yaş:** 13+. **Fiyat:** ücretsiz, satın alma yok. **Ülke:** önce Türkiye.
- **App Privacy:** "Data Not Collected" (`docs/legal/app_store_privacy_etiketi.md` §2A).

## Apple sınırları ve kuralları (22 Ekim 2026'da Apple belgelerinden doğrulandı)

| Alan | Sınır | Aranır mı? | Ne zaman değişir? |
|---|---|---|---|
| Ad (Name) | 2–30 karakter | Evet | Gönderene kadar; sonra yalnızca yeni sürümle |
| Alt başlık (Subtitle) | 30 karakter | Evet | Yeni sürümle |
| Tanıtım metni (Promotional Text) | 170 karakter | **Hayır** | **İstediğin zaman**, sürüm gerekmez |
| Açıklama (Description) | 4000 karakter, düz metin | App Store aramasında hayır | Yalnızca yeni sürümle |
| Anahtar kelimeler (Keywords) | **100 bayt**, virgülle; her kelime 2 karakterden uzun | Evet | Yeni sürümle |
| Bu sürümde yeni (What's New) | 4000 karakter | Hayır | Her yeni sürümde zorunlu; **ilk sürümde alan yok** |

Kaynaklar: [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information), [Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), [Search](https://developer.apple.com/app-store/search/), [Product page](https://developer.apple.com/app-store/product-page/), [App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-information/app-store-localizations).

**Önemli ayrıntılar:**

- **Bayt mı, karakter mi?** App Store Connect belgesi anahtar kelime sınırını **100 bayt** diye veriyor (Apple'ın pazarlama sayfaları "100 characters" diyor). Bayt esas alındı: ç, ğ, ı, İ, ö, ş, ü UTF-8'de 2 bayt.
- **Türkiye mağazasında aranan diller:** varsayılan **English (U.K.)**, ek **Turkish**. Yani iki yerelleştirmenin ad, alt başlık ve anahtar kelimeleri Türkiye'de aranır (yaklaşık 2 × 100 bayt). English (U.S.) Türkiye'de aranmaz.
- **Anahtar kelime kuralları:** virgülden sonra boşluk yok; ad, alt başlık ve kategori kelimelerini tekrar etme; tekil varsa çoğulunu ekleme (İngilizce için); "app" gibi genel kelimeler, rakip ve marka adları yasak.
- **Ad ve alt başlık (Kural 2.3.7):** fiyat ("ücretsiz"), doğrulanamayan iddia ("en iyi", "#1"), başka uygulama adı yok. Başka platform adı (ör. Android) yok (2.3.10).
- **Türkçe harfler:** Apple aksan eşleşmesini belgelemiyor; denemede "ingilizce" araması "İngilizce…" adlarını buldu. Görünen metinde doğru Türkçe yazılır, aksansız tekrar eklenmez.

## Yayın öncesi sıra (öneri)

1. TÜRKPATENT araması + marka vekili (ad kesinleşir).
2. Alan adı ve gizlilik politikası web sayfası (`docs/legal/` avukat onayından sonra; ilk ücretsiz sürüm için sadeleştirilmiş hâli, `docs/legal/README.md` §4.1).
3. Info.plist izin metinlerinin İngilizcesi ve "kelime ya da cümle" düzeltmesi (`docs/legal/app_store_privacy_etiketi.md` §5.6; `ios/project.yml`'de, ayrı iş).
4. Ekran görüntülerinin Pro Max boyutunda tek turda yeniden çekilmesi (`ekran_goruntusu_basliklari.md`).
5. App Store Connect'te metinler, yaş anketi, App Privacy, inceleme notu (kullanıcı girer).
