# Lockglow Yasal Belgeler: Dizin ve Yayın Rehberi

> **TASLAK PAKET.** Bu belgeler avukat değil, taslak hazırlama asistanı tarafından yazılmıştır ve **hukuki görüş değildir.** Hepsi avukat incelemesi içindir. Belirsiz noktalar **[TEYİT]** ile işaretlidir (aşağıda toplu liste var). Hazırlanma tarihi: 11 Ekim 2026. Marka adı değişeceği için her yerde **Lockglow** yer tutucusu kullanıldı.

Dayandığı kararlar ve bilgiler: `Widget_Vocabulary_Analiz_ve_Plan.md` §8 (teknik yığın), §9 (planlar), §11 (KVKK/GDPR), `raporlar/09_turkiye_hukuk_vergi_butce.md` §3 (KVKK, Apple 5.1.1/5.1.2/3.1.2) ve `marketing/landing/aydinlatma.html` (erken erişim listesi aydınlatması; üslup aynı tutuldu).

---

## 1. Dosya dizini

| Dosya | Ne işe yarar | Dil | Tür |
|---|---|---|---|
| `gizlilik_politikasi_tr.md` | Uygulama gizlilik politikası | TR | Herkese açık, App Store'a bağlanır |
| `privacy_policy_en.md` | Aynısının İngilizcesi (birebir çeviri değil, eşdeğer) | EN | Herkese açık |
| `kvkk_aydinlatma_uygulama_tr.md` | KVKK m.10 aydınlatma metni (uygulama için; **açık rızadan ayrı**) | TR | Herkese açık, uygulama içinde |
| `acik_riza_metni_analitik_tr.md` | İsteğe bağlı analitik için **ayrı** açık rıza metni + **uygulama içi ekranın birebir metni ve tasarım kuralları** | TR | Uygulama içi (ekran + uzun metin) |
| `analytics_consent_en.md` | Aynısının İngilizcesi | EN | Uygulama içi |
| `kullanim_sartlari_tr.md` | Kullanım Şartları / EULA + abonelik (3.1.2) + paywall alt metni | TR | Herkese açık; EULA alanı veya Apple standart EULA'sına tamamlayıcı |
| `terms_of_use_en.md` | Aynısının İngilizcesi | EN | Aynı |
| `app_store_privacy_etiketi.md` | App Store Connect "App Privacy" cevap kâğıdı + `PrivacyInfo.xcprivacy` kontrol listesi | TR (Apple terimleri EN) | Dahili çalışma belgesi, yayınlanmaz |
| `README.md` | Bu dizin | TR | Dahili |

**Yayınlanmayacaklar:** `app_store_privacy_etiketi.md`, `README.md`, ve diğer belgelerin başındaki "TASLAK" kutuları ile "Uygulama İçi Rıza Ekranı: Birebir Metin ve Tasarım Kuralları" bölümü (yayın metninden çıkarılır).

## 2. Doldurulacak alanlar

Tüm belgelerde bulk "bul-değiştir" yapın. Parantezli sayısal değerler (`[12]`, `[90]`, `[30]`, `[2]`) öneridir; gerçek yapılandırmaya göre kesinleştirin.

| Yer tutucu | Açıklama |
|---|---|
| Marka adı | Belgelere **Lockglow** yazıldı (2026-10-11, plan §4.4). TÜRKPATENT araması veya vekil görüşü adı değiştirirse "Lockglow" ve Türkçe ek "Lockglow'un" aranıp değiştirilmeli. |
| `[AD SOYAD]` / `[FULL NAME]` | Veri sorumlusunun tam adı. App Store satıcı adı ve Apple kaydıyla **birebir aynı** yazım. |
| `[E-POSTA]` / `[EMAIL]` | Destek ve KVKK başvuru adresi (ör. `privacy@...`). Aynı adres hem belgelerde hem App Store'da. |
| `[ADRES]` / `[ADDRESS]` | Kamuya açık adres. **Ev adresini yazmayın:** belgeli ofis/coworking veya KEP adresi tercih edin; ayrıca AB DSA "trader" beyanında adres 27 AB ülkesinde herkese açık görünür (plan §11.2). **[TEYİT]** |
| `[TARİH]` / `[DATE]` | "Son güncelleme" tarihi; her yayında değişir. Sürüm kodunu (`taslak-1` → `1.0`) da güncelleyin. |
| `[WEB SİTESİ ADRESİ]` / `[WEBSITE URL]` | Belgelerin yayınlandığı alan adı. |
| `[GİZLİLİK POLİTİKASI WEB ADRESİ]`, `[GİZLİLİK TERCİHLERİ SAYFASI ADRESİ]` | `app_store_privacy_etiketi.md` içindeki App Store Connect alanları. |
| `[FİYAT]` / `[PRICE]` | Elle yazılmaz; paywall'da StoreKit `displayPrice` ile gelir. Belgelerde yalnızca örnek metindir. |
| `[AB TEMSİLCİSİ]` | Yalnızca atanırsa; atanmayacaksa satırı silin. |
| `[E-POSTA SAĞLAYICI]`, `[ÜLKE]` | Destek e-postasını barındıran sağlayıcı. |
| `[Sentry]` işaretli satırlar / `[SEÇENEKLİ]` | Sentry kullanılmayacaksa ilgili satır, tablo satırı ve bölümleri silin. |
| `[SEÇENEKLİ] Beyan 2` | Avukat yurt dışı aktarım için ayrı beyan isterse tutulur, istemezse silinir. |
| `[standart sözleşme / diğer uygun güvence]` | Her sağlayıcı için avukatla belirlenen KVKK m.9 dayanağı. |
| `[17.0]` | Nihai minimum iOS sürümü. |
| Saklama süreleri | Analitik `[12]` ay, hata raporu `[90]` gün, destek `[2]` yıl, silme talebi `[30]` gün, abonelik kaydı yasal zamanaşımı yılı. |
| Metin sürüm kodları | `consent-analytics-tr-v1`, `consent-analytics-en-v1` (rıza kaydı için). Metin değişince artırın. |

## 3. Hangi belge nereye bağlanacak

| Yer | Bağlanacak belge(ler) | Not |
|---|---|---|
| **App Store Connect > App Information > Privacy Policy URL** | `gizlilik_politikasi_tr` ve `privacy_policy_en` (herkese açık web adresi) | Zorunlu (Apple 5.1.1(i)). Yerelleştirme başına ayrı adres tanımlanabilir **[TEYİT]** |
| **App Store Connect > App Privacy** | Aynı politika adresi + `app_store_privacy_etiketi.md` cevapları | Etiket, politika ve manifestler birbiriyle tutarlı olmalı |
| **App Store Connect > App Information > License Agreement** | `kullanim_sartlari_tr` (yalnızca **özel EULA / Seçenek B** seçilirse) | Aksi hâlde Apple'ın standart EULA'sı geçerli: `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/` |
| **App Description (TR + EN), sonuna** | "Kullanım Şartları (EULA): [adres]" ve "Gizlilik Politikası: [adres]" | Standart EULA kullanılıyorsa Apple bağlantısı; özel EULA ise kendi sayfanız |
| **Paywall alt satırı** | "Kullanım Şartları · Gizlilik Politikası · Satın Alımları Geri Yükle · Abonelikleri Yönet" + `kullanim_sartlari_tr` sonundaki kısa abonelik metni | Apple 3.1.2: başlık, süre, fiyat, yenileme, iptal; fiyat StoreKit'ten; deneme bitiş tarihi açık; kapatma düğmesi görünür |
| **Onboarding 2. adım (hoş geldin sonrası): rıza ekranı** | `acik_riza_metni_analitik_tr` / `analytics_consent_en` sonundaki ekran metni; altta **Aydınlatma Metni** ve **Açık Rıza Metni** bağlantıları | Düğmeler eşit ağırlıkta; ekran cevaplanmadan analitik/hata SDK'sı başlamaz |
| **Uygulama içi Ayarlar > Gizlilik** | Gizlilik Politikası, KVKK Aydınlatma Metni, Açık Rıza Metni, **Analitik tercihim** anahtarı, **Analitik verilerimi sil / kimliğimi sıfırla**, (Sentry varsa) **Hata raporları** anahtarı | Apple 5.1.1(i): politika uygulamada kolay erişilebilir |
| **Uygulama içi Ayarlar > Hakkında** | Kullanım Şartları, Lisanslar ve Atıflar | Açık lisanslı kaynakların atıfları |
| **App Review Information > Notes** | Rıza ekranının yeri, widget ekleme adımları, "Şimdi değil" ile her şeyin çalıştığı | İnceleme tarafını bilgilendirir |
| **Web sitesi altbilgisi** | Dört herkese açık belge | Erken erişim listesi için mevcut `aydinlatma.html` **ayrı kalır**; bu belgeler yalnızca uygulamayı kapsar. Bu sayfa da Lockglow adına güncellendi |
| **Çevrimdışı kopya** (uygulama paketinde) | Politika + aydınlatma + rıza (TR/EN) | İnternet yokken de erişim için **[TEYİT]** |

## 4. Belgelerin dayandığı kararlar (değişirse metinler değişir)

1. **Kimlik:** Veri sorumlusu şahıs [AD SOYAD]; şirket kurulursa tüm belgelerde veri sorumlusu değişir ve kullanıcılara bildirim yapılır.
2. **Analitik:** PostHog AB bulutu, **yalnızca açık rıza sonrası**, rastgele takma adlı kimlik, IP/GeoIP kapalı. "Anonim" kelimesi **kullanılmaz** (takma adlı veri).
3. **Çökme raporu:** Varsayılan Apple mekanizması; **Sentry opsiyonel** ve ayrı rıza/anahtar gerektirir. *Öneri:* MVP'de Sentry'siz çıkmak, aktarım ve rıza yükünü azaltır **[TEYİT]**.
4. **RevenueCat zorunlu ve ilk açılışta başlatılır** varsayımı (en geniş senaryo). Yalnızca paywall/geri yükleme anında başlatmak mümkünse veri azalır ve metinler sadeleşir **[TEYİT]**.
5. **Hata bildir:** e-posta taslağı açar (uygulama içi form yok).
6. **EULA:** Önce Apple standart EULA + tamamlayıcı Kullanım Şartları (Seçenek A+).
7. **Yok:** hesap, ATT/IDFA, reklam, konum, rehber, mikrofon (MVP), uzaktan push, yapay zekâ özellikleri, CloudKit (v1.2) ve CDN içerik güncellemesi (v1.1). Bunlar eklenmeden önce belgeler güncellenir.

## 5. Mühendislik bağımlılıkları (belgelerde söz verilenler uygulamada olmalı)

Aşağıdakiler yapılmazsa belgeler gerçeği yansıtmaz ve Apple/KVKK riski doğar:

- [ ] Rıza ekranı onboarding'in başında; iki düğme eşit ağırlıkta; ekran cevaplanmadan analitik/hata SDK'sı başlamaz (`optOut` varsayılan).
- [ ] Rastgele kimlik rıza anında üretilir; "Kabul ediyorum" ile **tarih + metin sürüm kodu + dil** kaydı tutulur; geri alma da kaydedilir.
- [ ] Ayarlar > Gizlilik: analitik anahtarı, "Analitik verilerimi sil / kimliğimi sıfırla" (kimliği gösterir, silme talebi e-postasını hazırlar), politika ve metinlere bağlantılar.
- [ ] Uygulama rıza **olmadan tam çalışır**; hiçbir özellik/paywall akışı rızaya bağlı değil; rıza karşılığında indirim/ödül yok.
- [ ] PostHog'ta IP ve GeoIP kapalı, autocapture ve session replay kapalı; olaylarda kelime/arama metni/özel liste içeriği yok; SDK'nın varsayılan olarak eklediği alanlar (IDFV, cihaz adı vb.) proxy ile doğrulandı.
- [ ] RevenueCat'te reklam/atıf/analitik entegrasyonları kapalı; **RevenueCat → PostHog entegrasyonu rıza vermeyen kullanıcılar için çalışmıyor** (aksi hâlde rızasız veri aktarımı olur); `collectDeviceIdentifiers()` çağrılmıyor.
- [ ] Analitik olay planındaki 44 olay ve ortak özellikler (`anon_id`, `storefront_country`, `native_language`, `cefr_level`, `plan_state`…) politika metniyle uyumlu; `campaign_token` (AdServices) MVP'de kullanılmıyor.
- [ ] Paywall'da fiyat, süre, yenileme, iptal ve bağlantılar (Kullanım Şartları + Gizlilik) var; deneme bitiş tarihi gösteriliyor.
- [ ] Manifestler ve etiketler `app_store_privacy_etiketi.md` ile uyumlu; her SDK değişikliğinde yeniden kontrol.
- [ ] Rıza dışı kullanıcı kimlikleri (ör. destek e-postası) için başvuru süreci (30 gün) ve silme iş akışı sahipli.

## 6. [TEYİT]: Avukata sorulacaklar (toplu liste)

**A. KVKK**

1. **m.9 yurt dışı aktarım dayanağı** (RevenueCat ABD, PostHog AB/ABD merkezli şirket, Sentry): standart sözleşme (veri sorumlusu → veri işleyen modülü) hangi sağlayıcı için kullanılacak, sağlayıcılar Türk standart sözleşmesini imzalar mı, imza sonrası **5 iş günü** bildirim yapıldı mı, açık rızanın sürekli aktarım için ek/tek dayanak olarak yeterliliği; ayrı "Beyan 2" gerekli mi. *(gizlilik politikası, aydınlatma, açık rıza)*
2. **Kurul İlke Kararı 18.02.2026, 2026/347:** metnin tamamının incelenmesi; "okudum ve anladım" ifadesinin yeri ve biçimi; "her beyan ayrı" gereğinin ekran ve uzun metne yansıması; "Kabul ediyorum / Şimdi değil" ikilisinin yeterliliği. *(aydınlatma, açık rıza)*
3. Rastgele kalıcı kimlik + cihaz/kullanım olaylarının KVKK'da kişisel veri sayılması (varsayım: evet) ve mobil SDK analitiği için çerez rehberi ilkelerinin kıyasen uygulanması.
4. **Sentry/çökme raporu** için hukuki sebep: açık rıza mı, meşru menfaat mi; ayrı beyan gerekir mi.
5. **Başvuru yöntemi:** e-posta ile başvurunun yeterliliği, KEP adresi gerekliliği, kimlik doğrulama (analitik kimliği), 30 gün ve ücret cümlesi.
6. **Kamuya açık adres:** Veri sorumlusu adresi olarak hangi adresin yazılacağı (ofis/coworking/KEP) ve Tebliğ gereği asgari kimlik/adres içeriği.
7. **VERBİS** muafiyeti (<50 çalışan, <100 milyon TL bilanço) ve şahıs olarak durum.
8. **Çocuk/reşit olmayan rızası:** KVKK'da yaş eşiği; 13+ konumlandırmada 13–17 yaş analitik rızası; GDPR m.8 eşiği (13–16); uygulama içi metne yansıması.
9. **Saklama süreleri** (analitik, hata raporu, destek yazışması, abonelik kaydı zamanaşımı).
10. **Rıza kaydı (ispat):** kaydın yeri/biçimi (cihaz + tek olay), geri alma olayının iletimi, metin sürümü değişince yeniden rıza.

**B. GDPR / AB**

11. GDPR m.3(2) kapsamı ve **m.27 AB temsilcisi** gerekliliği (plan: yılda ~420–4.750 €).
12. Türkiye'deki veri sorumlusunun AB'de barındırılan (PostHog AB) verilere erişimi ve AB-ABD aktarım mekanizmaları (SCC, DPF) için her sağlayıcının güncel durumu; DPA'ların imzalandığı.
13. Analitik için **e-Gizlilik (ePrivacy)** rızası: cihazdaki bilgiye erişim/depolama; hata raporları "kesinlikle gerekli" sayılabilir mi.
14. GDPR m.11 (kimlik doğrulanamayan veriler) yaklaşımının uygunluğu.

**C. Teknik gerçeklerin hukuki beyanlara etkisi**

15. **RevenueCat:** ilk açılışta mı yoksa paywall'da mı başlatılacağı; topladığı alanlar (IDFV, IP saklama süresi); DPA güncel sürümü.
16. **PostHog:** AB bölgesi, alt işleyenler, IP atma/GeoIP ayarlarının fiilen çalıştığı; SDK'nın varsayılan eklediği alanlar (IDFV, cihaz adı vb.).
17. **Sentry** kullanılacak mı; kullanılacaksa bölge, saklama süresi, `sendDefaultPii` ayarı, DPF/SCC durumu.
18. "Analitik verilerimi sil" iş akışı: sunucu tarafı silmenin el ile yapılması ve [30] gün taahhüdü gerçekçi mi.
19. "Hata bildir" kanalı (mailto mu, uygulama içi form mu): form olursa politika ve etiket değişir.
20. Gelecek özellikler (CloudKit, CDN, mikrofon/telaffuz, hesap, push, AdServices) için belgelerin güncellenme zamanı.

**D. Kullanım şartları / tüketici**

21. **Apple standart EULA mı, özel EULA mı;** özel EULA'da Apple asgari şartlarının güncel PLA metnine göre kontrolü; Apple EULA'sı ile tamamlayıcı şartlar arasında çelişki hâlinde hangisinin geçerli olacağı.
22. **Mesafeli sözleşme, cayma hakkı, abonelik ön bilgilendirmesi, ETBİS** yükümlülüklerinin Apple'ın satış modeli içinde (geliştirici satıcı sıfatında mı) karşılanması; plan raporunda bu alan araştırılmamış.
23. **Yetki ve uygulanacak hukuk:** Türk hukuku + İstanbul Mahkemeleri/İcra Daireleri şartının geçerliliği (kurucunun yerleşimi, tüketici mahkemesi/hakem heyeti, AB tüketicileri).
24. **Sorumluluk sınırlaması** ve haksız şart denetimi (kast/ağır kusur; tüketici sözleşmelerinde yıllık ücret üst sınırının geçerliliği).
25. **"Ömür boyu" tanımı;** Aile Paylaşımı kararı; deneme uygunluğu; hizmetin sona ermesi bildirimi; abonelik bittiğinde ücretsiz özelliklerin korunması taahhüdü.
26. **Fiyat deneyleri (A/B)** ve kullanıcıya farklı fiyat gösterilmesinin tüketici mevzuatı/şeffaflık açısından durumu.
27. İçerikte **yapay zekâ kullanım beyanı** (ifade ve doğruluğu; ilk 1.200 kart çift okuma dışında "tamamen denetlendi" denemez), açık lisans atıfları (CC BY-SA), sınav markaları için "bağlantımız yoktur" notu.

**E. App Store etiketi**

28. "Linked to you" için **muhafazakâr yorum** (kalıcı rastgele kimlik = bağlı) ve RevenueCat rehberindeki "anonim kimlik = bağlı değil" yorumu arasında tercih; isteğe bağlı analitiğin yine beyan edilmesi.
29. Apple'ın kendi topladığı çökme/analiz verisinin geliştirici beyanı kapsamı dışında olduğu; AdServices kullanılırsa etiket etkisi; CloudKit "toplama" sayılmaması.
30. `PrivacyInfo.xcprivacy` required-reason API kodlarının (UserDefaults, File timestamp, Disk space, System boot time) Apple'ın güncel tablosuna göre doğrulanması ve SDK manifest sürümleri.

## 7. Bu paketi hazırlarken doğrulanan dış bilgiler (özet ve sınırlar)

Aşağıdakiler kısa web taramasıyla bakıldı; **kesin kaynak olarak kullanılmamalı**, avukat ve sağlayıcı DPA'larından teyit edilmeli:

- RevenueCat'in Apple gizlilik rehberi: Purchase History için "App Functionality" ve "Analytics" amaçları öneriliyor; anonim kimlikle "kullanıcıya bağlı değil" deniyor; IDFA'yı kendisi toplamıyor ve cihaz tanılama bilgisi toplamıyor. DPA güncel sürümü Haziran 2026 olarak görünüyor; DPF katılımı doğrulanamadı.
- PostHog: iOS SDK'da `optOut()/optIn()` var ve durumu kalıcı; IP verisi proje ayarından atılabilir; AB bulutu Frankfurt'ta (ikincil kaynaklar); alt işleyenlerde ABD konumları görünüyor.
- Sentry: `sendDefaultPii` kapalıyken IP varsayılan olarak gönderilmez; AB barındırma seçeneği ve DPF/SCC mevcut (resmi sayfalar); şehir adı doğrulanamadı.
- 18.02.2026/347 sayılı Kurul İlke Kararı'nın tam metni **okunmadı**; plan raporundaki özetlere dayanıldı.

## 8. Kullanım notları

- Belgeler **"sen" yerine "siz"** hitabıyla yazıldı; yalnızca uygulama içi rıza ekranı onboarding dilindeki "sen" ile yazıldı (tutarlılık kararı avukatla netleştirilebilir).
- Tüm hukuki atıflar (KVKK m.5, m.7, m.8, m.9, m.10, m.11, m.13–14; GDPR m.6, 7, 8, 11, 13, 15–22, 27, 44 vd., 77) yaygın bilinen maddelerdir; Türk mevzuatına ve Kurul kararlarına ilişkin tarihler ve sayılar yalnızca plan raporlarındakilerdir (18.02.2026/347; standart sözleşme bildirimi 5 iş günü; Aydınlatma Tebliği RG 10.03.2018).
- Yayına almadan önce: (1) tüm `[…]` alanlarını doldurun, (2) tüm **[TEYİT]** notlarını avukatla kapatıp metinden silin, (3) "TASLAK" kutularını kaldırın, (4) sürüm ve tarihi güncelleyin, (5) `app_store_privacy_etiketi.md` Bölüm 5.5 doğrulamasını yapın.
