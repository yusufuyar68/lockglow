# Faz 0 açılış sayfası

Planın Faz 0'ı (12–25 Ekim): talep var mı, ve hangi mesaj/fiyat çekiyor? Bu sayfa TikTok/Reels videolarının "bio linki" olarak kullanılır.

| Dosya | İçerik |
|---|---|
| `index.html` | Tek dosyalık sayfa (TR/EN): değer önerisi, canlı widget görseli, Türkçe tuzak kelime örnekleri, **sahte kapı fiyat testi**, bekleme listesi formu |
| `aydinlatma.html` | KVKK aydınlatma metni **TASLAĞI** (avukat onayı gerekir, köşeli parantezli alanları doldur) |

Dış bağımlılık, çerez ve üçüncü taraf betik yok. Kelime içerikleri `veri/ornek_kelime_seti_25.json` ile birebir aynı.

## Yayından önce yapılacaklar

1. **Form uç noktası:** `index.html` içindeki `CONFIG.formEndpoint`'i doldur. Boş kalırsa form "demo modunda" çalışır ve hiçbir veri gönderilmez. Seçenekler:
   - **Formspree** (en kolayı, JSON kabul eder): formu oluştur, `https://formspree.io/f/<id>` adresini yapıştır. Ücretsiz katman aylık kayıt sayısını sınırlıyor; güncel limiti sitesinden kontrol et (doğrulamadım). ABD merkezli olduğu için yurt dışına aktarım sayılır (aydınlatma metni §5).
   - **Tally / Google Forms**: JSON göndermez. Kullanırsan `submitForm` içindeki `fetch` gövdesini o servise göre değiştirmen gerekir.
   - **Kendi uç noktan** (ör. Cloudflare Worker + D1/KV): veri senin kontrolünde kalır, biraz kod gerekir. İstersen yazarım.
2. **Aydınlatma metni:** veri sorumlusu bilgileri, hizmet sağlayıcı ve ülke. Avukata göster ([TEYİT]).
3. **Ticari elektronik ileti / İYS:** Listedekilere lansman e-postası atmak, 6563 sayılı Kanun kapsamında ticari elektronik ileti sayılabilir. Onay metni ve İYS kaydı gerekip gerekmediğini mali müşavir veya avukatla netleştir ([TEYİT]).
4. **Marka: Lockglow** (2026-10-11'de seçildi, plan §4.4). Sayfa bu adla hazır, ama **TÜRKPATENT araması ve marka vekili görüşü gelmeden yayınlama**. Ad yine değişirse güncellenecek yerler: `CONFIG.brand`, `<title>`, meta etiketleri, başlıktaki logo (`Lock<span>glow</span>`), `fdBody` metinleri ve `aydinlatma.html`'deki marka adı.
   ~~Wordglance~~ kullanılamaz (Google Play'de aynı adlı ve aynı türde bir uygulama var, `raporlar/11_isim_taramasi.md`).
5. **Barındırma** (senin hesabınla; ben senin adına hesap açamam ya da yayına alamam):
   - **Cloudflare Pages:** `marketing/landing` klasörünü yükle. Ücretsiz, Türkiye'de hızlı.
   - **GitHub Pages / Netlify Drop:** klasörü sürükle-bırak.

## Ölçüm: Faz 0 karnesi

Her videonun linkine ayrı bir `utm_content` koy. Böylece hangi videonun kayıt getirdiği görülür:

```
https://<alan-adı>/?utm_source=tiktok&utm_medium=bio&utm_content=v01
```

Kayıt formu her satıra `utm_source`, `utm_content`, `plan_interest` (sahte kapıda seçilen plan) ve `goal` alanlarını ekler. Tablo bu alanlara göre filtrelenebilir.

| Test | Geçme eşiği (plan §13.1) |
|---|---|
| Ziyaretçi → e-posta | ≥ %8 soğuk trafik / ≥ %12 sıcak trafik |
| E-posta bırakanlardan fiyat planına tıklayan | ≥ %30 (bunların ≥ %50'si yıllık) |
| Video | ≥ 1 video 30 bin+ izlenme; ≥ 3 videoda kaydetme oranı ≥ %3; toplam ≥ 30 "hangi uygulama?" yorumu |
| Görüşme (8–10 kişi) | ≥ 6 kişi "yüklerim" diyor; ≥ 3 kişi zaten bir öğrenme aracına para ödüyor |

**Karar:** 5 testten en az 3'ü geçerse devam. Dikkat: ziyaretçi sayısı formdan değil, barındırma servisinin analitiğinden alınır (Cloudflare Web Analytics çerezsizdir). Sahte kapı tıklamalarını ayrıca saymak için `CONFIG.analyticsEndpoint` doldurulmalı.

## Dürüstlük kuralları

- Sahte kapı (fiyat butonu) tıklandığında uygulamanın henüz yayında olmadığı ve ödeme alınmadığı açıkça söylenir. Kart bilgisi asla istenmez.
- "Lansman indirimi" vaadi lansmanda gerçekten uygulanmalı.
- Sayfadaki widget görseli tanıtım amaçlı bir maketidir. App Store ekran görüntüleri ise gerçek uygulamadan alınmalıdır (App Store Kılavuzu 2.3).
