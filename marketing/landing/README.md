# Tanıtım sayfası (özel önizleme)

> **YAYIMLAMA KURALI (marka):** "Lockglow" adı için **TÜRKPATENT araması ve marka vekili görüşü bitmedi.**
>
> - Bu sayfayı internete **yayımlama**.
> - Hiçbir alan adına, Cloudflare Pages'e, GitHub Pages'e, Netlify'a ya da benzeri bir barındırmaya **koyma**.
> - Şimdilik tek izinli kullanım: **özel bir Artifact önizlemesi** (claude.ai, yalnız sahibi görür).
> - Bu kural, marka görüşü olumlu gelene ve kullanıcı açıkça izin verene kadar geçerli. Ad değişirse bu sayfa da değişir.
>
> Sayfada yanlışlıkla yayımlanmaya karşı `<meta name="robots" content="noindex, nofollow">` var; bu, kuralın yerini tutmaz.

| Dosya | İçerik |
|---|---|
| `index.html` | Tek dosyalık sayfa (yalnız Türkçe). CSS ve betik içinde; dış kod, dış yazı tipi, çerez yok. |
| `img/` | Uygulamanın 22 Ekim 2026 ekran görüntülerinden kırpılıp WebP'ye çevrilmiş 4 görsel (toplam ~85 KB). Kaynak: `docs/ekran-goruntuleri/yeni-tasarim-2026-10-22/` (01, 05, 06, 12). |
| `aydinlatma.html` | KVKK aydınlatma metni **TASLAĞI**. Form demo olduğu için şu an veri toplanmıyor; metin, form ileride gerçek olursa kullanılacak. Avukat onayı gerekir, köşeli parantezli alanlar boş. |

## Bölümler

1. **Kilit ekranında kelime:** kilit ekranı maketi ("Sonraki kelime" düğmesiyle değişir, kendiliğinden dönmez), widget türleri, tek satırlık widget'ın kısalma basamakları, orta ve küçük widget görüntüleri.
2. **Öğretici ve yormayan tekrar:** Tanış + Hatırla (sayfada denenebilir küçük bir örnek: `borrow`), aralıklı tekrar basamakları (1, 2, 4, 8, 16 gün; çubuk boyu gün sayısıyla orantılı), "yormayan" kuralları (seri yok, tur en çok 10 soru, günde tek hatırlatma).
3. **Söyle:** Dinle → Söyle → Sonuç; tanıma cihaz içinde, ses kaydedilmez ve telefondan çıkmaz. iOS sürüm notu.
4. **Dikkat ve sahte dost:** 598 kartta Dikkat; dört sahte dost (actually/aktüel, apartment/apartman, fabric/fabrika, sofa/sofa) ve Akış kartı görüntüsü.
5. **Uygulamada ayrıca:** Sözlük, açılışta seviye ve konu seçimi, "Nasıl öğrenirim?" rehberi.
6. **Gizlilik:** hesap yok, reklam ve takip yok, ilerleme telefonda, ses telefonda.
7. **Bekleme listesi:** **demo** form (aşağıya bak).

## Kimlik

`docs/tasarim/README.md`'deki birleşik tasarım uygulandı:

- **Kâğıt ve mürekkep:** renkler oradaki token tablosundan, açık ve koyu (Gece) iki tema. Sayfa sistem görünümünü izler; üstteki "Kâğıt / Gece" düğmesi seçimi yalnız o tarayıcıda hatırlar.
- **Fosfor şeridi:** sarı yalnız öğrenilecek İngilizce kelimede (gündüz kelimenin alt yarısının arkasında, gece harflerin altından geçen ışıyan çizgi). Kilit ekranı maketinde şerit, tek renk ince çizgidir.
- **Yazı:** İngilizce serif, Türkçe ve arayüz sistem yazısı. Dış yazı tipi yüklenmez: Apple cihazlarda New York ve SF, Windows'ta Georgia ve Segoe UI görünür.
- **Kapsül = dokunulur**, mavi bağlantı rengi yok; renk tek başına anlam taşımaz (Dikkat'te yanlış kelime noktalı, doğru kelime kalın ve çizgili; sahte dostta "≠" ve kelimeler).

Metinler `docs/magaza/kayit_metinleri_tr.md` (açıklama ve tanıtım metni) ile `docs/tasarim/ogrenme_ilkeleri.md` (§1, §2.3 Tanış + Hatırla, §2.7 Söyle, sahte dost) üstüne yazıldı. Sayılar `ios/App/Resources/content.sqlite`'tan (`2026.10.22-kisisel-6`): 1.068 kart (179 A1, 475 A2, 414 B1), 598 kartta Dikkat, 7 sahte dost. İçerik değişince sayıları güncelle.

## Bekleme listesi formu: DEMO

- Form **hiçbir yere bağlı değil.** Betikte ağ isteği (`fetch`, `sendBeacon`) yok; e-posta saklanmaz, konsola da yazılmaz.
- Alanlarda bilerek `name` özniteliği yok: betik çalışmasa bile tarayıcı e-postayı adres satırına eklemez.
- Gönderince yalnız biçim kontrolü yapılır ve "Demo: … hiçbir şey gönderilmedi" yazar. Formun üstünde de demo olduğu yazar.
- **Kişisel veri toplayan gerçek bir form kurulmadı.** Gerçek forma geçmek ayrı bir karar ve iş:
  1. marka görüşü ve yayın izni (yukarıdaki kural);
  2. form servisi seçimi (verinin nerede, hangi ülkede tutulacağı);
  3. `aydinlatma.html`'nin doldurulması ve avukat onayı (KVKK m.10, yurt dışına aktarım m.9);
  4. lansman e-postası için ticari elektronik ileti / İYS sorusunun mali müşavir veya avukatla netleşmesi;
  5. ancak bunlardan sonra kod: gönderim, hata durumları, onay metninin kayda eklenmesi.

## Eski sayfadan kaldırılanlar (22 Ekim 2026)

- **Fiyat "sahte kapı" testi ve planlar:** sayfada uygulamada olmayan özellikler (sınav paketleri, quiz widget'ı, temalar, Premium) vardı. Mağaza metinlerinin kuralı: yalnız uygulamada olan özellikler yazılır.
- **YDS, YÖKDİL, IELTS, TOEFL, C1–C2 iddiaları:** içerik A1–B1; yanıltıcı olurdu.
- **İngilizce dil seçeneği:** uygulama Türkçe konuşanlar için; sayfa yalnız Türkçe.
- **Ölçüm (utm, analitik uç noktası, olay sayımı):** sayfa yayımlanmayacağı için gereksiz; gizlilik bölümüyle de çelişiyordu.
- Eski Faz 0 ölçüm karnesi git geçmişinde duruyor (bu dosyanın önceki sürümü).

## Artifact önizlemesi

- Özel önizleme (22 Ekim 2026, sürüm 1): https://claude.ai/artifact/HKw8kQi6M9nbmWSn5r6q4U. Yalnız sahibi açabilir. Güncellerken aynı bağlantıya yükle, yeni bağlantı açma.
- Artifact kendi `<!doctype>`, `<html>`, `<head>` ve `<body>` iskeletini ekler. Yüklerken `index.html`'den bu sarmalayıcı çıkarılır, içerik aynen kalır.
- Görseller `img/…` yoluyla, `aydinlatma.html` kendi adıyla yan dosya olarak yüklenir.
- Önizleme **özel** kalır; paylaşım bağlantısı açılmaz.

## Dürüstlük kuralları

- Kilit ekranı maketi tanıtım amaçlıdır ve öyle yazar. Öteki görseller gerçek uygulamanın simülatör görüntüleridir; App Store ekran görüntüleri de gerçek uygulamadan alınmalıdır (App Store Kılavuzu 2.3).
- Sayfa yalnız ilk sürümde olacak özellikleri anlatır. Tanış + Hatırla gibi 22 Ekim'de geliştirilen akışlar, ilk sürüm listesinde (`ogrenme_ilkeleri.md` §1c) olduğu için yazıldı; yayından önce uygulamayla yeniden karşılaştır.
- "Ücretsiz" yazılmaz: fiyat kararı verilmedi.
