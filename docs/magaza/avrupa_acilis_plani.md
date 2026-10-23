# Türkçe konuşulan Avrupa ülkelerine açılış planı

> **TASLAK (24 Ekim 2026).** Hukuki görüş değildir. **[TEYİT]** işaretli her madde avukata sorulacak (`docs/legal/README.md` §6). App Store Connect'e hiçbir şey girilmedi. Ülke açmak, beyan vermek ve metin girmek kullanıcının işidir (her adım için açık izin, `DEVIR.md`).
>
> Dayanak: ilk sürüm **ücretsiz, satın almasız, SDK'sız**; uygulama hiçbir sunucuya veri göndermiyor, App Privacy cevabı **"Data Not Collected"** (`docs/legal/app_store_privacy_etiketi.md` §2A, `docs/legal/README.md` §4.1). Bu değişirse (abonelik, analitik) plan baştan gözden geçirilir.
>
> **Marka uyarısı:** "Lockglow" adı için TÜRKPATENT araması ve marka vekili görüşü yapılmadı. AB'ye açılmadan önce **EUIPO** araması da gerekir (`raporlar/09` §4).

## Kısa özet

1. **Yeni dil gerekmiyor.** İçerik ve arayüz olduğu gibi kalır (Türkçe + İngilizce). Yalnızca mağazada ülke eklenir.
2. **Hukuki yük ülkeye değil bölgeye bağlı.** AB'ye bir kez hazırlanınca (DSA beyanı + GDPR'a uygun gizlilik metni) 27 ülkenin hepsi aynı işle açılır. İngiltere ve İsviçre ayrı bölge sayılır.
3. **Asıl sorun hukuk değil, mağazada bulunmak.** Apple'ın tablosuna göre **Almanya ve Hollanda mağazalarında Türkçe yok**: oradaki aramalarda Türkçe ad ve anahtar kelimeler kullanılmaz. Kıbrıs mağazasında Türkçe var.
4. Veri toplanmadığı için GDPR işi küçük: gizlilik metninde birkaç cümle ve iletişim bilgisi.

## 1. Hangi ülkeler, hangi sırayla

Apple'ın mağaza dilleri tablosu ([App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-information/app-store-localizations), 24 Ekim 2026'da bakıldı):

| Ülke | Bölge | Mağazanın varsayılan dili | Ek diller | Türkçe ad ve anahtar kelime orada aranır mı? |
|---|---|---|---|---|
| Türkiye (bugün) | — | English (U.K.) | Turkish | Evet |
| **Kıbrıs** | AB | English (U.K.) | Greek, **Turkish** | **Evet** |
| **Almanya** | AB | German | English (U.K.) | **Hayır** |
| **Hollanda** | AB | Dutch | English (U.K.) | **Hayır** |
| Avusturya | AB | German | English (U.K.) | Hayır |
| Belçika | AB | English (U.K.) | Dutch, French | Hayır |
| Fransa | AB | French | English (U.K.) | Hayır |
| İsveç | AB | Swedish | English (U.K.) | Hayır |
| Danimarka | AB | English (U.K.) | Danish | Hayır |
| İsviçre | AB dışı | German | English (U.K.), French, Italian | Hayır |
| Birleşik Krallık | AB dışı | English (U.K.) | — | Hayır |

**KKTC:** Apple'da ayrı bir mağaza yok. KKTC'deki kullanıcıların çoğu Türkiye hesabı kullanır, yani zaten Türkiye mağazasından ulaşırlar **[TEYİT]**. "Kıbrıs" mağazası Kıbrıs Cumhuriyeti'dir ve AB'dedir.

**Önerilen sıra:**

| Aşama | Ülkeler | Neden |
|---|---|---|
| **A** | Kıbrıs, Almanya, Hollanda, Avusturya, Belçika, Fransa, İsveç, Danimarka (AB'deki Türkçe konuşan nüfus) | Hepsi tek AB hazırlığıyla açılır. Ek ülke ek hukuki iş getirmez |
| **B** (isteğe bağlı) | Birleşik Krallık, İsviçre | UK GDPR ve İsviçre veri koruma yasası ayrı. Veri toplanmadığı için yük küçük ama metinde ayrıca anılmalı **[TEYİT]** |

Bütün AB'yi birden açmak da mümkün: Türkçe bilmeyen biri indirse bile zarar yok, açıklama içeriğin Türkçe olduğunu söylüyor. Ama hedef kitle bu sekiz ülkede.

## 2. Hukuk ve Apple tarafı (AB için bir kez)

### 2.1 DSA tacir (trader) beyanı: en önemli karar

Apple'ın sayfası ([DSA compliance](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-compliance-information), 24 Ekim 2026'da okundu):

- AB'de dağıtım yapan herkes tacir olup olmadığını **kendisi** beyan eder. Apple bu kararı vermez.
- **Tacir dersen:** adres (ya da belgeli posta kutusu), telefon ve e-posta **AB'deki bütün ürün sayfalarında herkese açık** görünür. Adres belgeyle doğrulanır, telefon ve e-posta doğrulama koduyla.
- **Tacir değil dersen:** iletişim bilgisi istenmez. Apple bunun yerine AB'li kullanıcılara "tüketici hakları bu geliştiriciyle yapılan sözleşmelere uygulanmaz" bilgisini gösterir.

**Öneri:** İlk sürüm ücretsiz, satın almasız ve reklamsız olduğu için "tacir değilim" demek savunulabilir görünüyor **[TEYİT: avukat]**. Abonelik ya da ücretli sürüm gelince durum değişir. O zaman tacir beyanı gerekir ve ev adresi yerine **ofis, coworking ya da şirket adresi** kullanılmalı (`raporlar/09` §1.2).

### 2.2 GDPR

İlk sürümde uygulama kişisel veriyi bize göndermiyor. Bize ulaşabilecek tek veri, kullanıcının kendi yazdığı **destek e-postası**. Bu yüzden:

| Konu | Durum | Yapılacak |
|---|---|---|
| Gizlilik politikasında GDPR bölümü | **Var** (TR ve EN: haklar m.15–22, AB denetim makamına şikâyet, yurt dışı aktarım) | §3'teki küçük eklemeler |
| GDPR m.27 AB temsilcisi | Politikada yer tutucu var | Ara sıra ve küçük çaplı işlemede m.27(2) istisnası olabilir: tek veri destek e-postası. Temsilci gerekmeyebilir **[TEYİT]**. Gerekirse yılda yaklaşık 420–4.750 € (`docs/legal/README.md` §6-B 11) |
| Rıza ekranı ve yaş sınırı (Almanya ve Hollanda 16, Avusturya ve Kıbrıs 14, Belçika, İsveç ve Danimarka 13) | Analitik olmadığı için **rıza ekranı gerekmez** | Analitik eklenirse ülkeye göre yaş sınırı yeniden ele alınır **[TEYİT: yaş tablosu]** |
| e-Gizlilik (cihazda bilgi saklama) | Yalnızca uygulamanın kendi işi için yerel kayıt var | Rıza gerekmez (kesinlikle gerekli saklama) **[TEYİT]** |
| Veri işleme kaydı (m.30) | Küçük işletme istisnası olabilir | Destek e-postası için bir sayfalık kayıt tutmak yine de ucuz **[TEYİT]** |
| İngiltere (aşama B) | UK GDPR | Politikada "UK GDPR" ve ICO bir cümleyle anılır; UK temsilcisi için m.27 sorusu orada da sorulur **[TEYİT]** |

### 2.3 Almanya'ya özgü: künye (Impressum)

Almanya'da dijital hizmet sunanların bir kısmı ad, adres ve iletişim bilgisi gösteren bir künye sayfası vermek zorunda (DDG §5). Kural "iş amaçlı, genellikle ücretli" hizmetlere uygulanır. Ücretsiz ve gelirsiz ilk sürüm bunun dışında kalabilir **[TEYİT: avukat]**. Gelir gelince destek sayfasına künye eklenir. Adres sorunu DSA'dakiyle aynı (ev adresi yazılmaz).

### 2.4 Diğer kontroller

- **Yaş sınırı:** Apple'ın yaş derecesi bütün ülkelerde aynı (13+). Ayrı iş yok.
- **Şifreleme beyanı (export compliance):** Ülkeden bağımsız. Mevcut cevap geçerli.
- **Erişilebilirlik Yasası (EAA, Haziran 2025):** E-ticaret gibi belirli hizmetleri kapsar. Ücretsiz bir öğrenme uygulaması büyük olasılıkla kapsam dışı, mikro işletmeler de muaf **[TEYİT]**. Uygulama zaten Dynamic Type, VoiceOver ve kontrast kurallarına uyuyor (`CLAUDE.md`).
- **Marka:** EUIPO'da sınıf 9, 41 ve 42 araması. Türkiye araması yapılmadan AB'ye açılmamalı.

## 3. Gizlilik ve yasal metinlerde değişecekler

Gizlilik politikası (`gizlilik_politikasi_tr.md` / `privacy_policy_en.md`) GDPR'ı zaten anıyor. Değişecekler:

| Yer | Değişiklik |
|---|---|
| §1 Veri sorumlusu (TR ve EN satır 38) | AB temsilcisi satırı: gerekmiyorsa silinir, gerekiyorsa temsilci yazılır |
| §1 (EN satır 42) | "Where we offer the app to people in the EU/EEA" artık geçerli. Hangi ülkelerde sunulduğu yazılmaz; genel kalır |
| §5 Hukuki sebepler | Destek e-postası için GDPR m.6/1-b ya da f; sadeleştirilmiş sürümde tek satır kalır (`docs/legal/README.md` §4.1) |
| §7 Yurt dışına aktarım | AB'li kullanıcının e-postası **Türkiye'ye** gelir. Türkiye için AB yeterlilik kararı yok, GDPR m.44 ve devamı anılmalı (m.49/1-b: kullanıcının kendisi yazıyor) **[TEYİT]** |
| §9 Çocuklar | "Bazı AB ülkelerinde 16" cümlesi analitik içindir; sadeleştirilmiş sürümde analitikle birlikte çıkar |
| §10 Şikâyet hakkı | "Yaşadığınız AB ülkesinin veri koruma makamı" cümlesi var; aşama B'de ICO (İngiltere) ve FDPIC (İsviçre) eklenir |
| Kullanım şartları §12 | Uygulanacak hukuk ve mahkeme maddesi (Türk hukuku + İstanbul) AB tüketicisine karşı tek başına yetmez: AB tüketicisi kendi ülkesinin zorunlu kurallarından vazgeçirilemez. "Bu madde yaşadığınız ülkenin zorunlu tüketici kurallarını etkilemez" cümlesi eklenir **[TEYİT]** |
| Destek sayfası (`destek_ve_gizlilik_url.md`) | Aşama A'da değişiklik yok. Tacir olunursa ya da gelir gelirse künye bölümü eklenir |
| KVKK aydınlatma metni | Değişmez (Türkiye içindir) |

**Dil:** Politika Türkçe ve İngilizce kalır. Kitle Türkçe konuşuyor, uygulama da Türkçe. GDPR m.12 "açık ve sade dil" ister; Almanca ya da Felemenkçe çeviri şart değil gibi görünüyor **[TEYİT]**.

## 4. Mağaza metinleri

### 4.1 Aşama A: yeni metin yazmadan

- **Kıbrıs:** Türkçe ve en-GB metinler orada da aranır. Hiçbir şey değişmez.
- **Almanya, Hollanda ve diğerleri:** Yalnızca **English (U.K.)** metni aranır. Mevcut en-GB alt başlığı `English for Turkish Speakers` doğru kitleye konuşuyor. Ama İngilizce bilmeyen ve telefonu Almanca olan biri `türkisch englisch vokabeln` diye arayınca uygulamayı **bulamaz**.
- Telefonu Türkçe olan biri Almanya mağazasında hangi metni görür? Apple bunu cihaz dili, mağaza dili ve ana dile göre seçtiğini söylüyor. Kesin kural yazmıyor **[TEYİT: Almanya hesabıyla bakılacak]**.
- **Kontrol:** Almanya mağazasında en-GB anahtar kelimelerine Türkiye'ye özel terimler girmiş: `yds,yokdil,ydt`. Bunlar orada boşa gider ama zarar vermez. Ayrı ülke için ayrı anahtar kelime **yok**: en-GB metni bütün ülkelerde aynıdır.

### 4.2 Aşama A sonrası deneme: Almanca ve Felemenkçe mağaza sayfası

Almanya'da aranmanın tek yolu **Almanca (German) yerelleştirmesi** eklemek. Uygulamayı çevirmek gerekmez, yalnızca mağaza sayfası çevrilir:

- **Örnek ad ve alt başlık:** `Lockglow: Englisch für Türken` ya da `Lockglow: Englisch-Vokabeln` / `Mit türkischen Erklärungen` **[TEYİT: anadili Almanca biri okusun; "für Türken" yerine "auf Türkisch" daha nazik olabilir]**.
- **Anahtar kelimeler:** `türkisch, englisch, vokabeln, lernen, widget, sperrbildschirm, wortschatz…`.
- **Açıklamanın ilk satırı açık olmalı:** "Erklärungen und Benutzeroberfläche auf Türkisch" (açıklamalar ve arayüz Türkçe). Yoksa Türkçe bilmeyen Almanlar indirir, tek yıldız verir, Kural 2.3 riski doğar.
- **Ekran görüntüleri:** Türkçe kalır, çünkü uygulama Türkçe. Almanca başlık yazılabilir ama ekran Türkçe olmalı.
- Avusturya ve İsviçre de varsayılan olarak Almanca kullanır; aynı metin oralarda da işe yarar.
- Hollanda için aynısı **Felemenkçe (Dutch)** ile yapılır.

**Ölçüm:** App Store Connect'te ülkeye göre indirme sayısı. Almanca sayfa eklemeden önce ve sonra 4 hafta karşılaştırılır.

### 4.3 Ekran görüntüsü ve video

Değişmez. Görsellerde ülkeye özgü bir şey yok.

## 5. Adım adım liste

**Kullanıcının yapacakları (her biri için Claude izin ister, Apple hesabına Claude girmez):**

- [ ] Avukattan şu maddelerin cevabı: DSA tacir mi değil mi (§2.1), m.27 temsilcisi (§2.2), Impressum (§2.3), kullanım şartlarındaki hukuk maddesi (§3)
- [ ] EUIPO marka araması (sınıf 9, 41, 42)
- [ ] App Store Connect → Business → DSA beyanı
- [ ] App Store Connect → Pricing and Availability → aşama A ülkelerini seç
- [ ] (Deneme) Almanca ve Felemenkçe mağaza sayfalarını gir

**Claude'un hazırlayabilecekleri (depoda, taslak olarak):**

- [ ] Gizlilik politikası ve kullanım şartlarında §3'teki değişiklikler (TR ve EN, [TEYİT] işaretli)
- [x] Almanca ve Felemenkçe mağaza metni taslağı ([`kayit_metinleri_de.md`](kayit_metinleri_de.md), [`kayit_metinleri_nl.md`](kayit_metinleri_nl.md); 24 Ekim 2026). Uzunluklar `araclar/metin_say.py` ile denetlendi. Anadili konuşan biri okumadan girilmez
- [ ] `kategori_yas_fiyat.md` → "Ülkeler" bölümünün bu plana göre güncellenmesi
- [ ] `app_review_kontrol_listesi.md`'ye AB satırı (DSA beyanı yapılmadan AB seçilmez)

## 6. Ne zaman yeniden bakılır

- Abonelik, satın alma ya da reklam gelirse: DSA tacir beyanı, künye, tüketici hakları (cayma), AB KDV (Apple keser ama faturalama yine kontrol edilir), `docs/legal/` tam paketi.
- Analitik ya da çökme raporu SDK'sı gelirse: rıza ekranı, ülkeye göre yaş sınırları, aktarım dayanakları, App Privacy etiketi.
- İçerik başka bir ana dile çevrilirse (ör. Almanca konuşanlar için İngilizce): bu belge değil, yeni bir dil planı gerekir.
