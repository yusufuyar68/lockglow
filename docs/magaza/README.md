# Mağaza sayfası (App Store)

> **TASLAK (23 Ekim 2026).** Uygulama henüz mağazada değil; TestFlight'ta. Hiçbir metin ya da görsel App Store Connect'e girilmedi, hiçbir sayfa yayımlanmadı. Girmek, yüklemek ve göndermek kullanıcının işidir (Apple hesabında her değişiklik için açık izin, `DEVIR.md`).
>
> Metinler `origin/main` aa7ef5d'ye göre yazıldı (içerik `2026.10.23-kisisel-10`, 1.203 kelime). Paralel is5 oturumları birleşince neyin değişeceği: [`app_review_kontrol_listesi.md`](app_review_kontrol_listesi.md) §10.

## Marka durumu: önce bunu oku

**"Lockglow" adı için TÜRKPATENT araması (sınıf 9, 41, 42) ve marka vekili görüşü henüz yapılmadı.** Bu klasördeki bütün metinler "Lockglow" adıyla yazıldı ama ad **kesin değil**. Ad değişirse ad alanları, açıklamalar, destek sayfası ve `docs/legal/` belgeleri birlikte değişir. Ekran görüntülerinde ve videoda ad ve ikon bilerek yok. Tanıtım sayfası (`marketing/landing/`) ve destek sayfası da bu iki adımdan önce yayımlanmaz.

## Dosyalar

| Dosya | Ne |
|---|---|
| [`kayit_metinleri_tr.md`](kayit_metinleri_tr.md) | Türkçe: ad, alt başlık, tanıtım metni, açıklama, anahtar kelimeler, Yenilikler; her iddianın kaynağı |
| [`kayit_metinleri_en.md`](kayit_metinleri_en.md) | İngilizce (U.K.): aynı alanlar; neden en-GB |
| [`kayit_metinleri_de.md`](kayit_metinleri_de.md), [`kayit_metinleri_nl.md`](kayit_metinleri_nl.md) | Almanca ve Felemenkçe mağaza sayfası taslağı (Almanya ve Hollanda denemesi; anadil konuşucusu okumadan girilmez) |
| [`rakip_analizi.md`](rakip_analizi.md) | 23 Ekim: Türkiye mağazasında 17 rakip, arama ifadeleri, anahtar kelime stratejisi, ekran görüntüsü kalıpları |
| [`rakiplerden_ogrenilenler.md`](rakiplerden_ogrenilenler.md) | 22 Ekim: rakip yorumlarından dersler; söylenmeyecekler |
| [`ekran_goruntusu_basliklari.md`](ekran_goruntusu_basliklari.md) | 8 kare (6.3"): senaryo, Türkçe ve İngilizce başlıklar, neyin gerçek neyin montaj olduğu |
| [`gorseller/`](gorseller/) | Üretilmiş kareler (taslak) ve nasıl üretildiği |
| [`onizleme_videosu.md`](onizleme_videosu.md) | 27 saniyelik önizleme videosu senaryosu, Apple kuralları, çekim notları |
| [`app_review_kontrol_listesi.md`](app_review_kontrol_listesi.md) | App Review risk listesi: izin metinleri, kişisel veri, widget, Kural 4.2 ve 2.3; göndermeden önce yapılacaklar |
| [`app_review_notu.md`](app_review_notu.md) | İnceleme ekibine İngilizce not |
| [`destek_ve_gizlilik_url.md`](destek_ve_gizlilik_url.md) | Destek ve gizlilik adresi önerisi; destek sayfası taslağı (TR, EN) |
| [`kategori_yas_fiyat.md`](kategori_yas_fiyat.md) | Kategori, yaş sınırı cevapları, fiyat ve ülke önerisi; abonelik notu |
| [`avrupa_acilis_plani.md`](avrupa_acilis_plani.md) | Türkçe konuşulan Avrupa ülkelerine açılış: hangi mağazada Türkçe aranır, DSA, GDPR, değişecek metinler |
| [`araclar/gorsel_uret.py`](araclar/gorsel_uret.py) | Ekran görüntülerinden mağaza karelerini üretir |
| [`araclar/metin_say.py`](araclar/metin_say.py) | Metin uzunluklarını ve anahtar kelime kurallarını denetler |

## Önerinin özeti

- **Ad (TR):** `Lockglow: İngilizce Kelime` (26)
- **Alt başlık (TR):** `Kilit Ekranında Ezberle, Öğren` (30)
- **Anahtar kelimeler (TR, 98 bayt):** `widget,telaffuz,kartları,ekranı,günlük,ezberleme,öğrenme,kelimeler,tekrar,testi,okunuş,ders`
- **İngilizce (U.K.):** `Lockglow: Vocabulary Widget` / `English for Turkish Speakers`; anahtar kelimeler 96 bayt
- **Öne çıkan farklar** (rakip analizine göre): Türkçe konuşanların sık yaptığı hatayı gösteren **Dikkat** kutusu, telefonda çalışan **Söyle**, widget'tan **ses**, Tanış + Hatırla. "Reklam yok, hesap yok" doğru ama artık tek başına fark değil.
- **Ekran görüntüleri:** 8 kare; sıra: kilitli ekran, Dikkat, widget'tan dinle, Tanış + Hatırla, Söyle, kendi kelimen, ilerleme, sözlük.
- **Kategori:** Eğitim + Başvuru Kaynakları. **Yaş:** 13+ öneriliyor (karar kullanıcının). **Fiyat:** ücretsiz, satın alma yok. **Ülke:** önce Türkiye.
- **App Privacy:** "Data Not Collected" (`docs/legal/app_store_privacy_etiketi.md` §2A).

## Apple sınırları ve kuralları (23 Ekim 2026'da Apple belgelerinden doğrulandı)

| Alan | Sınır | Aranır mı? | Ne zaman değişir? |
|---|---|---|---|
| Ad (Name) | 2–30 karakter | Evet | Gönderene kadar; sonra yalnızca yeni sürümle |
| Alt başlık (Subtitle) | 30 karakter | Evet | Yeni sürümle |
| Tanıtım metni (Promotional Text) | 170 karakter | **Hayır** | **İstediğin zaman**, sürüm gerekmez |
| Açıklama (Description) | 4000 karakter, düz metin | App Store aramasında hayır | Yalnızca yeni sürümle |
| Anahtar kelimeler (Keywords) | **100 bayt**, virgülle; **her kelime 2 karakterden uzun** | Evet | Yeni sürümle |
| Yenilikler (What's New) | 4000 karakter | Hayır | Her yeni sürümde zorunlu; **ilk sürümde alan yok** |
| Support URL | Zorunlu; gerçek iletişim bilgisine götürmeli | — | Yeni sürümle |
| Privacy Policy URL | Zorunlu; uygulamanın içinden de ulaşılmalı (Kural 5.1.1(i)) | — | İstediğin zaman |
| İnceleme notu | 4000 bayt | — | Her gönderimde |
| Ekran görüntüsü | 6.3" zorunlu (1206 × 2622), 6.9" isteğe bağlı; boy başına 1–10; alfa yok | — | Yeni sürümle |
| Önizleme videosu | İsteğe bağlı; 15–30 sn, 886 × 1920, en çok 30 kare/sn, boy başına en çok 3 | — | Yeni sürümle |

Kaynaklar: [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information), [Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), [App preview specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications), [App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-information/app-store-localizations), [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) (son güncelleme 16 Ekim 2026).

**Önemli ayrıntılar:**

- **Bayt mı, karakter mi?** App Store Connect belgesi anahtar kelime sınırını **100 bayt** diye veriyor. ç, ğ, ı, İ, ö, ş, ü UTF-8'de 2 bayt. `araclar/metin_say.py` bunu sayar.
- **Türkiye mağazasında aranan diller:** varsayılan **English (U.K.)**, ek **Turkish**. İki yerelleştirmenin ad, alt başlık ve anahtar kelimelerinin Türkiye'de arandığı yaygın kabul; Apple açıkça yazmıyor. English (U.S.) Türkiye'de aranmaz.
- **Anahtar kelime kuralları:** virgülden sonra boşluk yok; ad, alt başlık ve kategori kelimelerini tekrar etme; tekil varsa çoğulunu ekleme (İngilizce için); "app", rakip ve marka adları yasak; her kelime 2 karakterden uzun (`a2`, `b1` olmaz).
- **Ad ve alt başlık (Kural 2.3.7):** fiyat ("ücretsiz"), doğrulanamayan iddia ("en iyi", "#1"), başka uygulama adı yok. Başka platform adı (ör. Android) yok (2.3.10).
- **Yeni kurallar (16 Ekim 2026):** 2.3.14 (ürün sayfası görselleri doğrulanabilir ve uygulamayla ilgili olmalı) ve 2.5.19 (gizli ya da belgelenmemiş özellik yok). İkincisi için sürümde Tanılama ekranı kapatılmalı (`app_review_kontrol_listesi.md` G2).

## Yayın öncesi sıra (öneri)

1. TÜRKPATENT araması + marka vekili (ad kesinleşir).
2. Alan adı; destek ve gizlilik politikası sayfaları (`destek_ve_gizlilik_url.md`; gizlilik metni `docs/legal/` avukat onayından sonra, ilk ücretsiz sürüm için sadeleştirilmiş hâli).
3. Kod işleri (`app_review_kontrol_listesi.md` "Özet" G1–G3, G6): izin metinlerinin İngilizcesi ve `tr` dil klasörü; Tanılama'nın sürümde kapatılması; uygulama içi gizlilik bağlantısı; içerik kaynakları ve lisans atfı. Ayrıca `MARKETING_VERSION` 1.0.
4. Cihazda doğrulama: widget'taki Dinle uygulama açılmadan çalışıyor mu (3. kare ve videonun 2. sahnesi buna dayanıyor); kilitli ekran ve Söyle "Anlaşıldı!" görüntüleri gerçek iPhone'dan.
5. is5 işleri birleştiyse: metinleri `kayit_metinleri_tr.md` → "Paralel işler birleşince" listesine göre güncelle; `screenshots.yml`'yi bir kez çalıştırıp kareleri yeniden üret; `araclar/metin_say.py` ile say.
6. App Store Connect'te metinler, ekran görüntüleri, yaş anketi, App Privacy, erişilebilirlik etiketleri (isteğe bağlı, yalnız cihazda denenenler), inceleme notu (kullanıcı girer).
