# Lockglow Gizlilik Politikası

> **TASLAK:** Bu metin hukuki görüş alınmadan yayınlanmamalıdır. Köşeli parantez içindeki alanlar doldurulmalı, **[TEYİT]** işaretli noktalar avukatla netleştirilmelidir. Yayınlamadan önce bu kutuyu silin.
>
> **taslak-2 (22 Ekim 2026):** "Söyle" (mikrofon, cihaz içi konuşma tanıma) ve sesli okuma / widget hoparlör düğmesi bölümleri uygulamanın koduyla karşılaştırılarak güncellendi. Değişen her yer **[TEYİT]** ile işaretli. Metin, abonelik ve analitik içeren ileriki sürüme göre yazılmıştır; ilk ücretsiz sürüm için sadeleştirme: `README.md` §4.1.
>
> **[ÖNERİ is5-veri, 2026-10-24]** **taslak-3 önerileri:** kendi eklediğiniz kelimeler, yerel ölçüm, "Verilerin" ekranı (dışa aktar, içe aktar, hepsini sil) ve iCloud ile eşitleme, uygulamanın 24 Ekim 2026 koduyla (`origin/main` cb3cf7a + dal `is5-veri` 79d4113) karşılaştırıldı. Her öneri `[ÖNERİ is5-veri]` ile işaretli; kabul edilen öneri metne işlenip işaret silinir.

**Son güncelleme:** [TARİH] · **Sürüm:** taslak-2

---

## Kısaca

- Lockglow hesap istemez. Ad, e-posta veya telefon numarası vermeden kullanırsınız.
- Öğrenme ilerlemeniz, kaydettiğiniz kelimeler ve ayarlarınız **yalnızca cihazınızda** durur.

> **[ÖNERİ is5-veri, 2026-10-24]** Bu maddeye şu eklenmeli ve altına iki madde konmalı. Neden: iCloud ile eşitleme artık kodda (varsayılan kapalı; `ios/App/SyncController.swift:55–56`, `ios/App/SyncSettingsView.swift:71–73`), "Verilerin" ekranı da eklendi (`ios/App/SettingsView.swift:500–504`).
>
> - Öğrenme ilerlemeniz, kendi eklediğiniz kelimeler ve ayarlarınız **cihazınızda** durur. "iCloud ile eşitle"yi açarsanız ilerlemeniz ve kendi kelimeleriniz ayrıca **sizin iCloud hesabınızda** saklanır; biz bunları göremeyiz (Bölüm 3.11). **[TEYİT]**
> - **Ayarlar > İlerleme > Verilerin** bölümünden verilerinizi dosya olarak dışa aktarabilir, bir yedekten geri yükleyebilir veya uygulamadaki tüm verileri silebilirsiniz. Dosyalar yalnızca sizin seçtiğiniz yere gider; bize gelmez (Bölüm 3.10).
> - Kendi eklediğiniz kelimeler widget'ta ve kilitli ekranda görünebilir. Bu yüzden onlara kişisel veya hassas bilgi yazmayın (Bölüm 3.1a).

- **Söyle** (telaffuz alıştırması) için mikrofon yalnızca siz dokunduğunuzda ve izninizle açılır. Sesiniz telefonunuzda yazıya çevrilir; kaydedilmez, bize ya da başkasına gönderilmez. Kelimeleri okuyan hoparlör düğmeleri (widget'takiler dahil) de telefonun kendi sesini kullanır. **[TEYİT]**
- Reklam göstermeyiz, sizi uygulamalar arasında izlemeyiz, verilerinizi satmayız.
- Kullanım istatistikleri **yalnızca siz izin verirseniz** toplanır. İzin vermemeniz uygulamanın hiçbir özelliğini kısıtlamaz.
- Abonelik durumunuzu doğrulamak için RevenueCat hizmetini kullanırız. Kart bilgilerinizi görmeyiz; ödemeyi Apple alır.

---

## 1. Veri sorumlusu

Bu politikada "biz" dediğimizde şunu kastediyoruz:

**[AD SOYAD]** (gerçek kişi, şahıs olarak faaliyet gösteren geliştirici)
E-posta: [E-POSTA]
Adres: [ADRES] **[TEYİT: Kamuya açık bir metne hangi adresin yazılacağı. Ev adresi yerine belgeli ofis/coworking adresi veya KEP adresi tercih edilebilir.]**
AB'de yerleşik kullanıcılar için temsilci: [AB TEMSİLCİSİ — atanacaksa yazılacak, atanmayacaksa bu satır silinecek] **[TEYİT: GDPR m.27 kapsamında temsilci gerekip gerekmediği.]**

Uygulamanın App Store'da görünen satıcı adı da yukarıdaki kişidir.

## 2. Bu politika neyi kapsar?

Bu politika, Lockglow iOS uygulamasını ve widget'larını kapsar. İnternet sitesi ve erken erişim listesi için ayrı bir aydınlatma metni geçerlidir.

Türkiye'de yaşıyorsanız ayrıca 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") uyarınca hazırladığımız **Aydınlatma Metni**'ne bakın. İsteğe bağlı analitik için **Açık Rıza Metni** ayrı bir belgedir. Bu üç metin birbirini tamamlar.

## 3. Hangi verileri işliyoruz?

### 3.1 Yalnızca cihazınızda kalan veriler

Şunlar cihazınızda saklanır ve **bize gönderilmez**:

- seçtiğiniz seviye, hedef ve ayarlar,
- kaydettiğiniz kelimeler, "biliyorum" işaretleri, öğrenme durumu, quiz sonuçları ve seriniz,
- oluşturduğunuz özel listeler,
- kendi eklediğiniz kelimeler (İngilizce kelime, Türkçe anlamı, isteğe bağlı örnek cümle ve notunuz),
- widget ayarlarınız ve bildirim saatleriniz.

Bu veriler uygulama ile widget'ların ortak kullandığı cihaz içi alanda tutulur. Uygulamayı sildiğinizde silinir. Cihazınızı iCloud veya bilgisayara yedekliyorsanız bu veriler Apple'ın yedekleme hizmetine dahil olabilir. Bu, Apple ayarlarınıza ve Apple'ın politikasına bağlıdır; biz bu yedeklere erişmeyiz.

> **[ÖNERİ is5-veri, 2026-10-24]** Bölüm 3.1'in listesi ve bu paragraf (satır 45–51) koda göre aşağıdaki metinle değiştirilmeli.
>
> *Neden:* (1) Uygulamada "seri" yok (`ios/App/ProgressOverviewView.swift:9`, `ios/App/ReviewView.swift:24`: "No streak") ve "özel liste" özelliği yok (kodda `CustomList`/"özel liste" araması boş); (2) verilerin çoğu widget'larla ortak alanda değil, uygulamanın kendi alanında (Application Support) duruyor: `progress.json` (`ios/Packages/VocabKit/Sources/Learning/ProgressStore.swift:28`), `custom_words.json` (`Learning/CustomWords.swift:479`), `review_log.jsonl` (`Learning/ReviewLog.swift:134`), `local_metrics.json` (`Learning/LocalMetricsRecorder.swift:40`), `sync_state.json` (`Learning/SyncSnapshot.swift:367–375`); ortak alanda (App Group) widget planı, widget durumu ve bekleyen widget dokunuşları (`SharedState/AppGroupStore.swift:9–11`) ile "Ses ve aksan" ayarı (`ios/Shared/WordSpeech.swift:6–15`) var; (3) yerel ölçüm cihaz yedeğine girmiyor (`LocalMetricsRecorder.swift:221–231`, `isExcludedFromBackup`), diğer dosyalar için böyle bir işaret yok (kodda arama).
>
> Önerilen metin:
>
> Şunlar cihazınızda saklanır ve **bize gönderilmez**:
>
> - ayarlarınız: başlangıç seviyesi, seçtiğiniz konular, günlük hedef, widget'ın kelime değiştirme aralığı, hatırlatmanın açık olup olmadığı ve saati, ses ve aksan seçimi,
> - öğrenme durumunuz: her kelimenin öğrenme durumu ve kutusu, bir sonraki tekrar tarihi, cevap ve hata sayıları, widget'ta kaç kez görüldüğü, "Biliyorum" işaretleri ve kaydettiğiniz kelimeler,
> - tekrar kaydı: verdiğiniz her cevabın zamanı, sonucu ve nerede verildiği (Tekrar ya da widget),
> - kendi eklediğiniz kelimeler (Bölüm 3.1a),
> - Sözlük'teki son aramalarınız (en fazla 8) ve Akış'ta bir kelimeyi ilk ne zaman gördüğünüz,
> - yerel ölçüm (Bölüm 3.9),
> - iCloud ile eşitlemeyi açtıysanız son eşitlemenin durumu (Bölüm 3.11).
>
> Bu verilerin çoğu uygulamanın kendi cihaz içi alanında tutulur. Widget'ların gösterdiği kelimeler (kendi kelimeleriniz dahil), widget'tan yaptığınız dokunuşlar ve ses ayarı, uygulama ile widget'ların ortak kullandığı cihaz içi alanda durur. Bir dosya bozulursa uygulama onu silmez, yanına ayırır ve günlük yedek kopyayı kullanır; bu kopyalar da cihazınızda kalır. Uygulamayı sildiğinizde veya "Hepsini sil"i kullandığınızda (Bölüm 3.10) cihazdaki bu veriler silinir.
>
> Cihazınızı iCloud'a veya bilgisayara yedekliyorsanız bu veriler (yerel ölçüm hariç) Apple'ın cihaz yedeğine dahil olabilir. Bu, Apple ayarlarınıza ve Apple'ın politikasına bağlıdır; biz bu yedeklere erişmeyiz. Cihaz yedeği, Bölüm 3.11'deki "iCloud ile eşitle"den ayrı bir Apple özelliğidir. **[TEYİT]**

Hatırlatma bildirimleri cihazınızda zamanlanır (yerel bildirim). Bunun için sunucumuza bildirim anahtarı göndermeyiz. Kelimeler cihazın kendi sesiyle okunur (bkz. Bölüm 3.8). **[TEYİT]**

> **[ÖNERİ is5-veri, 2026-10-24]** Yeni alt bölüm **3.1a Kendi eklediğiniz kelimeler** (Bölüm 3.1'den sonra):
>
> "Kendi kelimeni ekle" ile yazdığınız her kelime için şunlar saklanır: İngilizce kelime, Türkçe anlamı, isteğe bağlı örnek cümle ve notunuz, eklendiği ve son değiştirildiği tarih. Bunlar cihazınızda durur. Uygulama günde bir kez bir yedek kopya alır; okunamayan bir dosyayı silmez, ayrı bir adla yanına ayırır. iCloud ile eşitlemeyi açarsanız bu kelimeler iCloud hesabınıza da gider (Bölüm 3.11). Bize gönderilmez.
>
> **Kilitli ekranda görünebilir.** Kendi kelimeleriniz diğer kartlar gibi widget'ta döner. Kilitli ekran widget'ı kelimeyi ve Türkçe anlamını, ana ekran widget'ı ayrıca örnek cümleyi gösterebilir; telefonunuzu eline alan herkes bunları görebilir. Apple Watch uygulaması kullanıyorsanız widget'ın kelimeleri saate de gönderilir ve orada görünebilir. Kelime, hatırlatma bildiriminde de geçebilir **[TEYİT]**. Bu yüzden kendi kelimelerinize, örnek cümlenize ve notunuza **ad, telefon numarası, adres, şifre, sağlık bilgisi gibi kişisel veya hassas bilgiler yazmayın.**
>
> *Kod:* alanlar `Learning/CustomWords.swift:14–25`; dosya ve günlük yedek `:471–484`, `:570–586`; ayrılan kopya `custom_words-unreadable-<zaman>.json` `:595–604`; widget'a giden alanlar (kelime, anlam, örnek) `:60–71`; kendi kelimeler her destenin başında `ios/App/AppModel+CustomWords.swift:12–14`; kilitli ekran aileleri `ios/Widgets/WordWidget.swift:22–28`, satır içi widget "kelime · anlam" `ios/Widgets/AccessoryWordViews.swift:121`; widget'larda `privacySensitive`/`redacted` yok (kodda arama). Hatırlatma: başlık kelimeyi taşır (`Learning/ReminderPlanner.swift:318–320`), hatırlatma `words`/`newWordFeed` destesinden seçer (`ios/App/AppModel.swift:355–376`); hassas konu süzgeci (`ReminderPlanner.swift:351`) kendi kelimelere işlemez, çünkü `widgetWord` hassasiyet değeri vermez (`CustomWords.swift:60–71`). Kendi kelimenin bildirimde gerçekten çıktığı telefonda denenmedi **[TEYİT]**. Saat: widget planı her yazılışta Apple Watch'a gönderilir (`ios/App/WatchPlanRelay.swift:1–4`, `ios/App/WatchBridge.swift:62`, WatchConnectivity); Apple Watch bu politikada hiç anılmıyor, ayrı denetlenmeli (bu denetimin kapsamı dışında).

### 3.2 Abonelik ve satın alma bilgisi (zorunlu)

Premium'u satın aldığınızda ödemeyi Apple alır. Apple, kart numaranızı, Apple Kimliğinizin e-postasını veya adınızı bize vermez.

Aboneliğin geçerli olup olmadığını doğrulamak için **RevenueCat, Inc.** hizmetini kullanırız. Uygulama, fiyatları göstermek ve abonelik durumunuzu kontrol etmek için RevenueCat'e şu bilgileri gönderir:

- RevenueCat'in ürettiği rastgele bir uygulama kullanıcı kimliği (hesap değildir; adınızla ilişkili değildir),
- Apple'ın satın alma işlem bilgileri (ürün, satın alma ve bitiş tarihi, deneme/yenileme/iade durumu),
- App Store ülkesi, uygulama ve iOS sürümü,
- her internet bağlantısında kaçınılmaz olarak görülen IP adresi.

**[TEYİT: RevenueCat'in güncel olarak topladığı alanların listesi (ör. cihaz kimliği IDFV, IP saklama süresi) ve SDK'nın uygulama ilk açıldığında mı yoksa yalnızca paywall/geri yükleme anında mı başlatılacağı. Bu metin, daha kapsamlı olan "ilk açılışta başlatılır" varsayımıyla yazıldı.]**

Bu işleme, uygulamanın abonelik işlevini sunmak için gereklidir ve analitik iznine bağlı değildir.

### 3.3 İsteğe bağlı kullanım istatistikleri (yalnızca izninizle)

Uygulamayı ilk kullandığınızda size bir izin ekranı gösteririz. **"Kabul ediyorum"** derseniz aşağıdaki veriler toplanır. **"Şimdi değil"** derseniz hiçbir analitik veri toplanmaz ve analitik aracı hiç başlatılmaz.

- **Kimlik:** İzin verdiğiniz anda cihazınızda rastgele bir kimlik üretilir. Bu kimlik adınız, e-postanız, telefon numaranız veya reklam kimliğinizle (IDFA) ilişkili değildir. Takma adlı (pseudonim) bir veridir; yani sizi doğrudan tanımlamaz, ancak aynı cihazdan gelen kayıtları birbirine bağlar.
- **Olaylar:** Hangi ekranların açıldığı, onboarding adımları, widget'ın kurulu olup olmadığı ve kaç adet olduğu, widget'tan yapılan dokunuşlar ("Sonraki", "Biliyorum" gibi), öğrenme eylemlerinin sayıları, quiz'in tamamlanması, paywall'ın görüntülenmesi ve hangi deney grubunda olduğunuz.
- **Cihaz ve ayar bilgisi:** Uygulama ve iOS sürümü, cihaz modeli, dil, App Store ülkesi, seçtiğiniz seviye ve hedef, abonelik durumunuz (yok/deneme/ücretli/bitmiş).

**Göndermediklerimiz:** Kelime listelerinizin içeriği, arama kutusuna yazdığınız metinler, adınız, e-postanız, konumunuz ve rehberiniz analitiğe gönderilmez. IP adresinden konum çıkarımı yapılmaz ve IP adresi analitik kayıtlarında saklanmaz **[TEYİT: Analitik aracında bu ayarların yapıldığı ve gerçek ağ trafiği ile doğrulandığı kontrol edilecek.]**

Analitik verileri **PostHog**'un AB bölgesindeki bulut hizmetinde işlenir. İzninizi dilediğiniz zaman geri alabilirsiniz (bkz. Bölüm 10).

### 3.4 Çökme ve hata bilgisi

- **Apple'ın kendi mekanizması:** iPhone'unuzda "Analiz ve İyileştirmeler" altında uygulama geliştiricileriyle paylaşımı açtıysanız Apple, çökme raporlarını ve genel kullanım istatistiklerini bize toplu ve kimliksiz biçimde sunabilir. Bu veriyi toplayan Apple'dır.
- **[SEÇENEKLİ — yalnızca Sentry kullanılacaksa:]** İzin verdiğiniz takdirde çökme ve hata raporları Sentry hizmetine gönderilir. Bu raporlarda uygulama sürümü, iOS sürümü, cihaz modeli ve hatanın teknik izi bulunur; adınız, e-postanız veya IP adresiniz bulunmaz **[TEYİT]**. Bu tercih Ayarlar > Gizlilik bölümünde ayrı bir anahtardır ve varsayılan olarak kapalıdır.

### 3.5 Bize yazdığınızda

Destek için veya "Hata bildir" ile bize e-posta gönderirseniz e-posta adresinizi, mesajınızı ve (hata bildiriminde) ilgili kelimenin kimliğini işleriz. **[TEYİT: "Hata bildir" düğmesinin e-posta oluşturma ekranı mı yoksa uygulama içi form mu olacağı. Uygulama içi form ve sunucu kullanılırsa bu bölüm ve App Store gizlilik etiketi güncellenmelidir.]**

### 3.6 İşlemediğimiz veriler

Lockglow; konumunuzu, rehberinizi, fotoğraflarınızı, kameranızı, sağlık verilerinizi, ödeme kartı bilgilerinizi ve reklam kimliğinizi (IDFA) **toplamaz**. Mikrofon yalnızca Söyle alıştırmasında, cihaz içinde kullanılır; ses toplanmaz (bkz. Bölüm 3.7) **[TEYİT]**. Uygulama sizi başka uygulama ve sitelerde **izlemez**, reklam göstermez, verilerinizi **satmaz** ve reklam amacıyla kimseyle paylaşmaz.

Uygulamada yapay zekâ sohbeti yoktur; kişisel verileriniz üçüncü taraf yapay zekâ hizmetlerine gönderilmez.

### 3.7 Telaffuz alıştırması ("Söyle") ve mikrofon

**[TEYİT: Bu bölüm taslak-2'de (22 Ekim 2026) uygulamanın koduyla karşılaştırılarak yeniden yazıldı.]**

"Söyle" özelliğinde kartın kelimesini ya da örnek cümlesini sesli söylersiniz; uygulama doğru söyleyip söylemediğinizi Türkçe olarak bildirir ("Doğru!", "Neredeyse!", "Bir daha dene" gibi).

- **İzin yalnızca kullanırken istenir.** Mikrofon izni, "Söyle"ye ilk dokunduğunuzda, o anda istenir; uygulama açılırken istenmez. iOS 17–25'te buna ek olarak **konuşma tanıma izni** istenir; iOS 26 ve sonrasında yalnızca mikrofon izni istenir. İzin vermezseniz uygulamanın geri kalanı (kartlar, tekrar, sesli okuma, widget'lar) aynen çalışır. İzinleri istediğiniz zaman iPhone Ayarları'nda Lockglow bölümünden kapatabilirsiniz.
- **Mikrofon yalnızca dinlerken açıktır.** Dinleme; konuşmanız bitince, hiç konuşmazsanız birkaç saniye sonra, süre dolunca ya da "Bitti"ye dokununca kendiliğinden durur. Uygulama arka plana geçerse, bir arama gibi bir ses kesintisi olursa ya da Söyle sayfasını kapatırsanız dinleme hemen durur. Uygulama arka planda mikrofonu dinlemez.
- **Sesiniz cihazınızdan çıkmaz.** Konuşmanız, Apple'ın iPhone'unuzda çalışan konuşma tanıma özelliğiyle yalnızca cihazınızda yazıya çevrilir ve hedef kelime ya da cümleyle karşılaştırılır. iOS 17–25'te uygulama, tanımanın cihazda yapılmasını zorunlu tutar: telefonunuzda cihaz içi İngilizce tanıma yoksa Söyle çalışmaz ve bir uyarı gösterir; ses, sunucuya gönderilerek tanınmaz. iOS 26 ve sonrasında kullanılan Apple bileşeni de sesi Apple sunucularına göndermez.
- **Kaydedilmez, saklanmaz, paylaşılmaz.** Ses yalnızca o deneme sürerken bellekte tutulur; dosyaya yazılmaz. Tanınan metin ve sonuç yalnızca ekranda gösterilir; öğrenme ilerlemenize, yedeğe ya da başka bir yere kaydedilmez. Ses, tanınan metin ve sonuç bize ya da üçüncü taraflara (analitik dahil) gönderilmez.
- **Sesiniz sizi tanımak için kullanılmaz.** Uygulama ses izi çıkarmaz ve sesinizle kimlik doğrulamaz; yalnızca söylediğiniz kelimeleri yazıya çevirir.
- **Model indirme:** iOS 26 ve sonrasında, ilk kullanımda Apple'ın İngilizce konuşma modeli Apple'dan bir kez indirilir. Bu indirmede sesiniz gönderilmez; modeli iOS yönetir, iPhone'unuzda saklanır ve başka uygulamalarla paylaşılabilir.

Söyle, sesi ya da tanınan metni cihaz dışına gönderecek biçimde değişirse önce bu politikayı günceller ve sizden yeniden izin isteriz.

**[TEYİT: Ses yalnızca kullanıcının cihazında işlendiği ve bize ulaşmadığı için bunun KVKK anlamında bizim tarafımızdan "işleme" sayılıp sayılmadığı; sesin kimlik tespiti için kullanılmadığından biyometrik (özel nitelikli) veri sayılmayacağı varsayımı. README §6 soru 20 ve 31.]**

> **[ÖNERİ is5-veri, 2026-10-24]** Kontrol (2026-10-24): Bölüm 3.7'deki cümleler kodla hâlâ uyumlu. Kanıt: izinler yalnız ilk kullanımda (`ios/App/PronunciationRecognizer.swift:262–330`; iOS 26+'da konuşma tanıma izni sorulmaz `:276–309`, iOS 17–25'te sorulur `:311–318`, `:347`), cihaz içi tanıma zorunlu (`:319–321`, `:745`), ses yalnız bellekte tanıyıcıya verilir (`:373–387`; dosya yazma yok), arka plan, kesinti, mod değişimi ve sayfa kapanınca iptal (`ios/App/PronunciationPracticeView.swift:216–260`), model indirme (`PronunciationRecognizer.swift:592`). Söyle'nin hiçbir verisi yedek dosyasına (`Learning/DataExport.swift:12–21`) ya da iCloud kopyasına (`Learning/SyncSnapshot.swift:21–37`) girmez.
>
> Üç küçük düzeltme önerisi:
> 1. "İngilizce" yerine artık "seçtiğiniz İngilizce aksanda (ABD ya da İngiltere)" demek gerekir: "Ses ve aksan" ayarı tanıyıcının dilini de belirliyor (`ios/Shared/WordSpeech.swift:22–24`, `ios/App/PronunciationRecognizer.swift:40–41`; iOS 17–25'te seçilen aksan cihazda tanınamıyorsa ABD İngilizcesine geçer `:319–321`; `ios/Packages/VocabKit/Sources/CoreModels/SpeechSettings.swift:7–18`). Bölüm 3.8'deki "İngilizce (ABD) sesiyle" de aynı nedenle "seçtiğiniz İngilizce (ABD ya da İngiltere) cihaz sesiyle" olmalı.
> 2. Test derlemelerindeki geliştirici ekranı "Söyle tanılama", son 20 denemenin sonucunu, süresini, güven değerini ve hata kodunu **yalnızca bellekte** tutar; söylenen metni tutmaz, uygulama kapanınca silinir (`PronunciationRecognizer.swift:822–888`). Ekran şu an mağaza derlemesinde de açık (`ios/App/WidgetHealthView.swift:11`, `showsInRelease = true`). Yayından önce kapatılmazsa "Tanınan metin ve sonuç yalnızca ekranda gösterilir" cümlesine "sonuç, uygulama açık kaldıkça bir test ekranında bellekte tutulur" eklenmeli.
> 3. Konuşma tanıma izin metni değişti (`ios/project.yml:65`); bu bölüme etkisi yok (bkz. `app_store_privacy_etiketi.md` §5.6).

### 3.8 Sesli okuma ve widget'taki hoparlör düğmesi

**[TEYİT: Bu bölüm taslak-2'de (22 Ekim 2026) eklendi.]**

- Uygulamadaki hoparlör düğmeleri ve ana ekran widget'larındaki **"Kelimeyi dinle"** düğmesi, İngilizce kelimeyi ya da cümleyi **iPhone'un kendi İngilizce (ABD) sesiyle, cihaz içinde** okur. Okuma için internet bağlantısı kullanılmaz; okunan metin hiçbir sunucuya gönderilmez.
- Widget'taki düğme uygulamayı ekrana getirmeden çalışır. Bunun için iOS, Lockglow'u kısa bir süre arka planda çalıştırır ve kelimeyi okutur; uygulamanın "arka planda ses çalma" yetkisi yalnızca bu sesli okuma içindir. Mikrofon arka planda açılmaz.
- Okunan metin kartın kelimesi ya da cümlesidir. Kendi eklediğiniz bir kelimede (Bölüm 3.1) sizin yazdığınız kelime ve örnek cümle okunur; okuma yine cihaz içinde yapılır ve metin hiçbir yere gönderilmez. Düğmeye bastığınız bilgisi kaydedilmez ve bize gönderilmez.
- Apple'ın "Kişisel Ses" (Personal Voice) özelliği kullanılmaz. iPhone Ayarları'ndan daha kaliteli bir İngilizce ses indirdiyseniz uygulama onu kullanabilir; bu indirme sizinle Apple arasındadır.

> **[ÖNERİ is5-veri, 2026-10-24]** Yeni alt bölüm **3.9 Yerel ölçüm (yalnızca cihazınızda)**:
>
> Uygulama, çalışmanın sizi yorup yormadığını görmek için cihazınızda bazı sayılar tutar. Her gün için yalnızca sayılar ve süreler: kaç soruya cevap verdiğiniz ve kaçını ilk denemede bildiğiniz, tur süreleri, "Bitir" ile erken biten turlar, yeni bir kelimede kaç kez dokunduğunuz, "Biliyorum" dediğiniz kelimelerin sonraki kontrolünün sonucu ve kutulardaki kelime sayıları. Her günlük hatırlatma için: ne zamana kurulduğu, açılıp açılmadığı ve sonrasında uygulamanın açılıp açılmadığı. Kelimeler ve cevaplarınızın kendisi bu ölçüme yazılmaz.
>
> Ölçüm son 120 günü tutar; daha eskisi kendiliğinden silinir. Cihazınızdan kendiliğinden çıkmaz: bize gönderilmez, widget'larla paylaşılmaz, iCloud ile eşitlenmez, iCloud veya bilgisayar yedeğine alınmaz. "İlerlemeyi sıfırla" ve "Hepsini sil" ölçümü siler. Yalnızca siz "Dışa aktar"ı kullanırsanız dosyalara yazılır (Bölüm 3.10).
>
> *Kod:* `Learning/LocalMetrics.swift:1–17` (amaç, 120 gün), `:167` (eskiyi atma), `:291–314` (günlük alanlar), `:419–424` (hatırlatma kaydı); `Learning/LocalMetricsRecorder.swift:31–40` (dosya), `:221–231` (`isExcludedFromBackup`); sıfırlama `ios/App/AppModel.swift` `resetProgress`; eşitlenmez: `Learning/SyncSnapshot.swift:21–37`, `ios/App/SyncSettingsView.swift:105`; dışa aktarılır: `ios/App/AppModel+DataControls.swift:41`. Kod yorumu da artık dışa aktarmayı anlatıyor (`LocalMetrics.swift:8–9`).

> **[ÖNERİ is5-veri, 2026-10-24]** Yeni alt bölüm **3.10 Verileriniz üzerinde denetim: "Verilerin" ekranı** (Ayarlar > İlerleme > Verilerin; `ios/App/SettingsView.swift:500–504`, `ios/App/DataControlsView.swift`).
>
> **Dışa aktar.** Yalnızca siz dokunduğunuzda çalışır. Uygulama dosyaları kendi geçici klasörüne yazar ve iPhone'un paylaşma penceresini açar; dosyaların nereye gideceğini siz seçersiniz (Dosyalar/iCloud Drive, AirDrop, Mail veya başka bir uygulama). Dosyalar bize gönderilmez; bu özellik internet bağlantısı kullanmaz. Oluşan dosyalar:
>
> - `lockglow-yedek-YYYY-AA-GG.json`: bir yedek. İçinde her kelime için kart numarası, İngilizce kelime, Türkçe anlam, öğrenme durumu, kutu, bir sonraki tekrar, son cevap, ilk cevap ve son görülme tarihleri, cevap, hata ve widget'ta görülme sayıları; bildiğiniz kelimelerin listesi; kendi kelimeleriniz (örnek cümle, not ve tarihleriyle); tekrar kaydı (her cevabın zamanı, sonucu ve nerede verildiği: Tekrar ya da widget); yerel ölçüm; ayarlarınız (başlangıç seviyesi, seçtiğiniz konular, günlük hedef, widget değişim aralığı, hatırlatmanın açık olup olmadığı ve saati); Sözlük'teki son aramalarınız; ayrıca dosyanın oluşturulma zamanı ve uygulama ile içerik sürümü.
> - Hesap tablosu için dört CSV dosyası: `lockglow-ilerleme-…csv`, `lockglow-bildigin-kelimeler-…csv`, `lockglow-kendi-kelimeler-…csv`, `lockglow-olcumler-…csv`.
>
> Dosyalar şifresiz, okunabilir metindir. Bir dosyayı paylaştığınızda o kopya artık uygulamanın denetiminde değildir: seçtiğiniz hizmetin (ör. e-posta sağlayıcısı, iCloud Drive) kendi şartları ve gizlilik politikası geçerlidir ve o kopyayı biz silemeyiz. Dosyayı yalnızca güvendiğiniz yerlere gönderin. Uygulamanın geçici klasöründeki dosyalar "Verilerin" sayfası kapanınca, bir sonraki dışa aktarmada ve "Hepsini sil" ile silinir; iOS da bu klasörü zaman zaman kendisi temizler. Telefon kilitliyken bu dosyalar şifreli kalır.
>
> **İçe aktar.** Bir yedek dosyasını iPhone'un dosya seçicisiyle siz seçersiniz. Uygulama dosyayı telefonda okur, denetler, bir özet gösterir ve ancak siz onaylarsanız mevcut verilerinizle birleştirir; telefondaki hiçbir şey silinmez. Aynı kelime iki tarafta da varsa daha çok cevap verilmiş kayıt kalır; aynı İngilizce kelimeye sahip kendi kelimeleriniz eşleştirilir; numarası telefonda dolu olan kendi kelimelerinize yeni numara verilir. Tekrar kaydı, kalan kayıtla birlikte gelir. Yerel ölçüm, ayarlar ve son aramalar içe aktarılmaz. Bu sırada hiçbir veri telefonunuzdan çıkmaz; ancak iCloud ile eşitleme açıksa içe aktarılan ilerleme ve kelimeler bir sonraki eşitlemeyle iCloud hesabınıza ve diğer cihazlarınıza da gider.
>
> **Hepsini sil.** "İlerlemeyi sıfırla"dan ayrıdır ("İlerlemeyi sıfırla" ilerlemeyi, tekrar kaydını, yerel ölçümü, son aramaları ve Akış geçmişini siler; kendi kelimelerinizi ve ayarlarınızı bırakır). "Hepsini sil", Türkçe bir onaydan sonra önce iCloud ile eşitlemeyi kapatır, sonra uygulamanın cihazdaki tüm dosyalarını siler: ilerleme ve günlük yedeği, okunamadığı için ayrılmış kopyalar, kendi kelimeleriniz ve yedeği, tekrar kaydı, yerel ölçüm, eşitleme durumu, önbellek ve geçici dosyalar (daha önce dışa aktarılan dosyaların uygulamadaki kopyaları dahil); widget'larla ortak alandaki dosyalar (widget planı, widget durumu, bekleyen widget dokunuşları); uygulamanın tüm ayarları (ses ve aksan dahil); uygulamanın bekleyen ve gelmiş hatırlatmaları. Sonra uygulama ilk kez kurulmuş gibi açılır. Bu işlem geri alınamaz; isterseniz önce yedek dosyasını paylaşın.
>
> "Hepsini sil" şunları silmez: **iCloud'daki eşitleme kopyası** (onu "iCloud ile eşitle" ekranındaki "iCloud'daki kopyayı sil" ile silersiniz; Bölüm 3.11); iPhone'unuzun daha önce alınmış iCloud veya bilgisayar yedeklerindeki kopyalar (bu yedeklerden birini geri yüklerseniz eski veriler geri gelebilir; yedekleri Apple ayarlarınızdan yönetirsiniz); daha önce dışa aktarıp paylaştığınız dosyalar; iOS izinleri (mikrofon, konuşma tanıma, bildirim; iPhone Ayarları'ndan değiştirilir); Apple'ın indirdiği konuşma modeli (iOS'un yönettiği bir sistem dosyası).
>
> *Kod:* dışa aktarma `ios/App/AppModel+DataControls.swift:13–72` (geçici klasör `lockglow-disa-aktarim`, `:14–16`; önce boşaltılır `:62`), paylaşma penceresi `ios/App/DataControlsView.swift:77–85` (`ShareLink`), dosya adları ve içerik `Learning/DataExport.swift:12–21`, `:93–106`, `:433–446`; ağ kodu yok (`URLSession`/`URLRequest`/`NWConnection` araması boş). Sayfa kapanınca silme (`DataControlsView.swift`, `.onDisappear`) ve `.completeFileProtection` (`AppModel+DataControls.swift`, `write`) 24 Ekim'de çalışma ağacında henüz commit'lenmemiş değişiklik olarak görüldü **[TEYİT: son kodda]**. İçe aktarma `DataControlsView.swift:49` (`fileImporter`, yalnız JSON), `AppModel+DataControls.swift:78–157` (en fazla 50 MB okunur `:93`, `DataExport.swift:30`; onay ekranı `DataControlsView.swift:215–255`; eşitleme açıksa iCloud'a da gider `:154–155`), kurallar `Learning/DataImport.swift:9–26`. Silme `AppModel+DataControls.swift:161–220` (önce eşitleme kapanır `:166`; Application Support, Documents, Caches, geçici klasör ve App Group `:191–204`; UserDefaults ve App Group UserDefaults `:208–220`), hatırlatmalar `DataControlsView.swift:208–209`, iCloud kopyası kalır `DataControlsView.swift:190`, klasör boşaltma `Learning/DataErase.swift:1–49`.

> **[ÖNERİ is5-veri, 2026-10-24]** Yeni alt bölüm **3.11 iCloud ile eşitleme (isteğe bağlı, varsayılan olarak kapalı)**. Bu bölüm daha önce "gelecek özellik" olarak düşünülüyordu; özellik artık kodda. Şimdiki derlemede iCloud yeteneği uygulamaya henüz eklenmediği için anahtar kapalı kalır ve ekran "bu sürümde henüz hazır değil" der (`ios/App/SyncKeyValueCloud.swift:8–10`, `ios/App/SyncSettingsView.swift:71–73`; `ios/project.yml:105–109` yalnız App Group yetkisini içeriyor). Metin, özellik açıldığı sürüm için yazıldı. **[TEYİT]**
>
> **Ayarlar > İlerleme > iCloud ile eşitle** anahtarını açarsanız şu veriler, Apple'ın iCloud anahtar-değer deposunda (`NSUbiquitousKeyValueStore`) **sizin iCloud hesabınızda** tek bir kopya olarak saklanır ve aynı Apple hesabını kullanan diğer cihazlarınıza gider:
>
> - kelimelerdeki ilerlemeniz (öğrenme durumu, kutu, tarihler, cevap, hata ve görülme sayıları, "Biliyorum" ve kaydetme işaretleri),
> - kendi eklediğiniz kelimeler (İngilizce kelime, Türkçe anlam, örnek cümle, not, tarihler), sildiğiniz kendi kelimelerin rastgele bir kimliği ve silinme zamanı,
> - "İlerlemeyi sıfırla"yı kullandığınız zaman.
>
> Ayarlarınız, tekrar kaydı, yerel ölçüm, günlük sayılar ve son aramalarınız eşitlenmez.
>
> Bu kopya Apple'ın sunucularında, Türkiye dışında da olabilecek veri merkezlerinde, Apple'ın iCloud şartları ve gizlilik politikasına göre tutulur. Biz bu kopyayı göremeyiz ve okuyamayız; geliştiriciye açık bir panel veya sunucu yoktur **[TEYİT]**. Cihazınız, eşitlemeyi açtığınız iCloud hesabını tanımak için iOS'un verdiği anlamsız bir işareti yalnızca cihazda saklar; hesap değişirse eşitleme kendiliğinden durur, başka birinin iCloud'una kelimeleriniz gitmez.
>
> Eşitleme bir yedek değildir: bir cihazda sildiğiniz ya da sıfırladığınız şey diğer cihazlarda da gider. Eşitlemeyi kapattığınızda iCloud'daki kopya kalır. Kopyayı **"iCloud ile eşitle" ekranındaki "iCloud'daki kopyayı sil"** ile silersiniz; başka bir cihazda eşitleme açıksa o cihaz kopyayı yeniden yükler, önce orada kapatın. Uygulamayı silmek veya "Hepsini sil" iCloud'daki kopyayı silmez. **[TEYİT: Uygulama silindikten sonra iCloud anahtar-değer deposundaki verinin iPhone Ayarları > [adınız] > iCloud > Depolamayı Yönet altında görünüp silinip silinemediği; görünmüyorsa kullanıcıya "silmeden önce uygulamadaki düğmeyi kullanın" denmeli.]**
>
> *Kod:* `ios/App/SyncKeyValueCloud.swift:3–17` (tek anahtar `lockglow.sync.1`, zlib, 900 KB sınırı), `:83–110` (hesap işareti `ubiquityIdentityToken`, yalnız cihazda karşılaştırılır; `SyncController.swift:22–24`, `:111`, `:295–320`); varsayılan kapalı `ios/App/SyncController.swift:55–56`, `:85–86`, `:118`; kapatma ve kopyayı silme `:148–180`; kopyanın içeriği `Learning/SyncSnapshot.swift:21–37`, `:101–148`; eşitlenmeyenler `ios/App/SyncSettingsView.swift:101–105`; ekrandaki metinler `:42`, `:72`, `:110–112`; sıfırlamanın yayılması `ios/App/AppModel+Sync.swift:82`, `SyncController.swift:259`; cihazdaki eşitleme durumu dosyası `sync_state.json` (son kopyanın bir örneğini ve kelime kimliklerini tutar, `Learning/SyncSnapshot.swift:301–316`, `:359–375`), cihaz yedeğinden hariç tutulmuyor.

## 4. Verileri neden işliyoruz?

- Uygulamayı ve widget'ları cihazınızda çalıştırmak,
- aboneliğinizi doğrulamak, premium özellikleri açmak, satın alımları geri yüklemek ve sahteciliği önlemek,
- destek ve hata bildirimlerinizi yanıtlamak,
- **yalnızca izninizle:** uygulamanın hangi bölümlerinin işe yaradığını anlamak, onboarding ve paywall'ı iyileştirmek, çökmeleri bulmak,
- hukuki yükümlülüklerimizi yerine getirmek ve olası hukuki uyuşmazlıklarda haklarımızı savunmak.

Size pazarlama e-postası veya uzaktan bildirim (push) göndermeyiz. Bu değişirse önce sizden izin isteriz.

## 5. Hukuki sebepler

| İşleme | KVKK m.5 | GDPR m.6 |
|---|---|---|
| Abonelik doğrulama ve premium erişim | m.5/2-c (sözleşmenin ifası), m.5/2-f (meşru menfaat: sahteciliği önleme) | m.6(1)(b), m.6(1)(f) |
| İsteğe bağlı analitik | m.5/1 (açık rıza) | m.6(1)(a) (rıza); AB'de cihazdaki bilgiye erişim için de rıza **[TEYİT: e-Gizlilik kuralları]** |
| [Sentry] çökme raporları | m.5/1 (açık rıza) **[TEYİT: meşru menfaat de düşünülebilir]** | m.6(1)(a) **[TEYİT]** |
| Destek yazışmaları | m.5/2-c, m.5/2-f | m.6(1)(b), m.6(1)(f) |
| Hukuki yükümlülük ve hak savunması | m.5/2-ç, m.5/2-e | m.6(1)(c), m.6(1)(f) |

Özel nitelikli kişisel veri işlemeyiz.

## 6. Hizmet sağlayıcılar ve verilerin paylaşıldığı taraflar

| Sağlayıcı | Ne için | Konum | Zorunlu mu? |
|---|---|---|---|
| **Apple Inc.** | App Store, ödeme, StoreKit, isteğe bağlı iCloud yedekleri. Kendi hizmetleri için bağımsız veri sorumlusudur | Dünya geneli | Uygulamayı App Store'dan edinmek için gerekli |
| **RevenueCat, Inc.** | Abonelik ve satın alma doğrulama, paywall | ABD | **Zorunlu** (abonelik işlevi) |
| **PostHog** | Kullanım istatistikleri (AB bulut bölgesi) | AB (Almanya) üzerinde barındırılır; şirket ABD merkezlidir **[TEYİT]** | **İsteğe bağlı** (yalnızca izinle) |
| **Sentry (Functional Software, Inc.)** | Çökme raporları | [ABD / AB bölgesi **TEYİT**] | **İsteğe bağlı** (yalnızca izinle; kullanılacaksa) |
| [E-POSTA SAĞLAYICI] | Destek yazışmaları | [ÜLKE] | — |

Bu sağlayıcılar, verileri yalnızca bizim talimatlarımız doğrultusunda ve yazılı sözleşme/veri işleme eki çerçevesinde işler **[TEYİT: Sözleşmelerin imzalanıp imzalanmadığı]**. Yasal zorunluluk hâlinde yetkili kamu kurumlarına bilgi verebiliriz.

> **[ÖNERİ is5-veri, 2026-10-24]** Tablonun altına şu paragraf eklenmeli: "Dışa aktardığınız dosyaları paylaşma penceresinden gönderdiğiniz hizmetler (ör. Mail, AirDrop, Dosyalar, iCloud Drive, başka uygulamalar) bizim hizmet sağlayıcımız değildir; dosyayı onlara siz gönderirsiniz ve biz bu dosyaları görmeyiz." Ayrıca Apple satırının "Ne için" sütununa "isteğe bağlı iCloud ile eşitleme (sizin iCloud hesabınızda; Bölüm 3.11)" eklenmeli. **[TEYİT: Geliştirici iCloud kopyasına erişemediği hâlde, eşitlemeyi uygulama kurduğu için Apple'ın bu hizmette kullanıcının kendi hizmet sağlayıcısı / bağımsız veri sorumlusu mu, yoksa bizim adımıza veri işleyen mi sayılacağı.]**

## 7. Yurt dışına aktarım

Yukarıdaki sağlayıcıların bir kısmı Türkiye dışında (ABD ve AB'de) bulunur. Bu nedenle verileriniz yurt dışına aktarılır.

- **Türkiye'den aktarım (KVKK m.9):** Aktarım, KVKK'nın öngördüğü uygun güvencelerden biriyle yapılır (ör. Kurul'un standart sözleşmesi). Standart sözleşme kullanıldığında imzadan itibaren 5 iş günü içinde Kişisel Verileri Koruma Kurumu'na bildirim yapılır. **[TEYİT: Hangi sağlayıcı için hangi dayanak kullanılacak, sağlayıcıların bunu imzalayıp imzalamayacağı, bildirimin yapıldığı. Açık rıza, sürekli aktarım için tek başına güvenli bir dayanak olmayabilir.]**
- **AB/AEA'dan aktarım (GDPR m.44 ve devamı):** Standart sözleşme hükümleri veya sağlayıcının AB-ABD Veri Gizliliği Çerçevesi'ne katılımı gibi mekanizmalar kullanılır **[TEYİT: Her sağlayıcı için güncel durum]**.

Aktarılan veri en aza indirilmiştir: ad, e-posta, konum veya reklam kimliği aktarılmaz.

> **[ÖNERİ is5-veri, 2026-10-24]** iCloud ile eşitleme için bu bölüme şu madde eklenmeli: "**iCloud ile eşitleme (isteğe bağlı):** Eşitlemeyi açarsanız ilerlemeniz ve kendi kelimeleriniz, sizin iCloud hesabınızda saklanmak üzere Apple'ın Türkiye dışında olabilecek sunucularına gider. Bu kopyaya biz erişmeyiz; Apple kendi iCloud şartlarına göre saklar. Eşitlemeyi açmazsanız bu aktarım olmaz." **[TEYİT: Avukat: (1) Geliştiricinin erişmediği, kullanıcının kendi iCloud hesabına kendi seçimiyle giden veri KVKK m.9 anlamında bizim yaptığımız bir yurt dışı aktarım sayılır mı; (2) sayılırsa dayanak (m.9 uygun güvenceler; arızi aktarım için açık rıza: anahtarı açmak açık rıza sayılabilir mi, ayrı bir metin gerekir mi); (3) Apple ile aramızda veri işleme sözleşmesi bulunmadığına göre bu nasıl anlatılır.]** Dışa aktarılan dosyayı kullanıcının yurt dışındaki bir hizmete göndermesi bizim aktarımımız değildir **[TEYİT]**.

## 8. Ne kadar süre saklıyoruz?

| Veri | Süre |
|---|---|
| Cihazınızdaki veriler | Uygulamayı silene kadar |
| Abonelik/satın alma kaydı (RevenueCat) | Abonelik ilişkisi boyunca ve sonrasında [TEYİT: yasal zamanaşımı süresi] yıl |
| Analitik kayıtları (PostHog) | En fazla [12] ay veya rızanızı geri alıp silme talep edene kadar **[TEYİT: Saklama süresi aracın ayarında yapılandırılacak]** |
| Çökme raporları ([Sentry]) | En fazla [90] gün **[TEYİT]** |
| Destek yazışmaları | Talebin sonuçlanmasından sonra [2] yıl **[TEYİT]** |

Süre dolunca veriler silinir, yok edilir veya anonim hale getirilir.

> **[ÖNERİ is5-veri, 2026-10-24]** "Cihazınızdaki veriler" satırı şöyle ayrılmalı:
>
> | Veri | Süre |
> |---|---|
> | Cihazınızdaki öğrenme verileri, kendi kelimeleriniz, ayarlar | Uygulamayı silene veya "Hepsini sil"i kullanana kadar (ilerleme ve tekrar kaydı için ayrıca "İlerlemeyi sıfırla") |
> | Tekrar kaydı | Aynı; dosya yaklaşık 8 MB'ı aşınca en eski cevaplar silinir |
> | Yerel ölçüm | Son 120 gün |
> | Sözlük'teki son aramalar | Son 8 arama |
> | Dışa aktarma için hazırlanan geçici dosyalar | Bir sonraki dışa aktarmaya, "Hepsini sil"e veya iOS'un geçici klasörü temizlemesine kadar |
> | Dışa aktarıp paylaştığınız dosyalar | Sizin denetiminizde; biz silemeyiz |
> | iCloud ile eşitleme kopyası | "iCloud'daki kopyayı sil"i kullanana kadar (uygulamayı silmek veya eşitlemeyi kapatmak silmez) **[TEYİT]** |
>
> *Kod:* `Learning/ReviewLog.swift:110–129` (8 MB / 6 MB), `Learning/LocalMetrics.swift:16`, `ios/App/SozlukRecentSearches.swift:11`, `ios/App/AppModel+DataControls.swift:13–16`, `:62`, `ios/App/SyncController.swift:148–180`.

## 9. Çocuklar

Lockglow 13 yaşın altındaki çocuklara yönelik değildir ve App Store'da çocuklar (Kids) kategorisinde yer almaz. 13 yaşın altındaki çocuklardan bilerek kişisel veri toplamayız. Çocuğunuzun bize veri verdiğini düşünüyorsanız [E-POSTA] adresine yazın, ilgili veriyi sileriz.

Analitik izni isteğe bağlıdır. Yaşadığınız ülkede kişisel veri rızası için belirli bir yaş sınırı varsa (ör. bazı AB ülkelerinde 16) ve bu yaşın altındaysanız, izni ancak ebeveyn veya vasinizin onayıyla verin **[TEYİT: Yaş sınırı yaklaşımı ve bunun uygulama içi metne nasıl yansıyacağı]**.

## 10. Haklarınız ve nasıl kullanırsınız?

**KVKK m.11 kapsamında** şunları yapabilirsiniz: verilerinizin işlenip işlenmediğini öğrenmek; işlenmişse bilgi istemek; işleme amacını ve amaca uygun kullanılıp kullanılmadığını öğrenmek; yurt içinde veya yurt dışında aktarıldığı üçüncü kişileri öğrenmek; eksik veya yanlış işlenmişse düzeltilmesini istemek; KVKK m.7 çerçevesinde silinmesini veya yok edilmesini istemek; bu işlemlerin aktarılan üçüncü kişilere bildirilmesini istemek; yalnızca otomatik sistemlerle analiz edilmesi sonucu aleyhinize bir sonuç çıkmasına itiraz etmek; kanuna aykırı işleme nedeniyle zarara uğrarsanız zararın giderilmesini talep etmek.

**GDPR kapsamında (AB/AEA'da iseniz)** ayrıca şu haklarınız vardır: erişim (m.15), düzeltme (m.16), silme (m.17), işlemenin kısıtlanması (m.18), alıcılara bildirim (m.19), veri taşınabilirliği (m.20), itiraz (m.21) ve yalnızca otomatik işlemeye dayalı kararlara tabi olmama (m.22). Rızanızı her zaman geri alabilirsiniz; geri alma, öncesindeki işlemenin hukuka uygunluğunu etkilemez.

### Uygulama içinden yapabilecekleriniz

**Ayarlar > Gizlilik** bölümünde:

- **Analitik tercihim:** Açın veya kapatın. Kapattığınızda analitik durur.
- **Analitik verilerimi sil / kimliğimi sıfırla:** Analitik durdurulur, cihazdaki kimliğiniz silinir ve yeni bir kimlik üretilir. Eski kimliğe bağlı kayıtların sunucudan da silinmesi için uygulamanın hazırladığı silme talebi e-postasını bize gönderirsiniz. Talebi [30] gün içinde sonuçlandırırız. **[TEYİT: Bu iş akışı uygulamada böyle geliştirilecek; sunucu tarafı silme el ile yapılacak.]**
- Aydınlatma Metni, Açık Rıza Metni, bu politika ve kullanım şartlarına bağlantılar.
- Cihazdaki verileriniz için: kelime listelerinizi dışa aktarabilir (CSV) veya uygulamayı silerek tüm cihaz içi verileri kaldırabilirsiniz.

> **[ÖNERİ is5-veri, 2026-10-24]** Bu madde koda göre yanlış: "kelime listeleri" diye bir özellik yok ve dışa aktarma **Ayarlar > Gizlilik**'te değil, **Ayarlar > İlerleme > Verilerin**'de (`ios/App/SettingsView.swift:500–504`). Yerine şu alt başlık konmalı:
>
> **Ayarlar > İlerleme > Verilerin** bölümünde, cihazınızdaki veriler için:
>
> - **Dışa aktar:** Uygulamanın cihazda sizinle ilgili tuttuğu verilerin bir kopyasını okunabilir bir yedek dosyası (JSON) ve hesap tablosu dosyaları (CSV) olarak alırsınız (KVKK m.11/1-a ve b; GDPR m.15 erişim, m.20 veri taşınabilirliği).
> - **İçe aktar:** Bir yedeği başka bir telefona taşırsınız (GDPR m.20).
> - **Hepsini sil:** Uygulamanın cihazdaki tüm verilerini silersiniz (KVKK m.7 ve m.11/1-e; GDPR m.17). Kendi kelimelerinizi uygulamada düzeltebilir veya silebilirsiniz (GDPR m.16).
> - **iCloud'daki kopyayı sil** ("iCloud ile eşitle" ekranında): iCloud hesabınızdaki eşitleme kopyasını silersiniz.
>
> Bu veriler bize hiç ulaşmadığı için, bunlarla ilgili bir başvurunuzda size verebileceğimiz veya silebileceğimiz bir kopya bizde yoktur; bu araçlar bu işlemleri doğrudan sizin yapmanızı sağlar. **[TEYİT: Avukat: veri sorumlusunun erişemediği, yalnız kullanıcının cihazında veya kendi iCloud hesabında duran veri için KVKK m.11 ve GDPR m.15/17/20'nin bizi ne ölçüde bağladığı; araçların "haklarınızı kullanma yolu" olarak anlatılmasının yanıltıcı olup olmadığı; GDPR m.20'nin "yapılandırılmış, yaygın kullanılan, makinece okunabilir" şartını JSON ve CSV'nin karşıladığı varsayımı.]**

### E-posta ile

Diğer talepleriniz için **[E-POSTA]** adresine yazın. Analitik kayıtlarınızı bulabilmemiz için Ayarlar > Gizlilik'te görünen analitik kimliğinizi ekleyin; bu kimlik olmadan, kayıtların size ait olduğunu doğrulayamayabiliriz (GDPR m.11). Başvurularınızı en geç 30 gün içinde sonuçlandırırız; işlem ayrıca bir maliyet gerektiriyorsa Kurul'un belirlediği tarifedeki ücret istenebilir. **[TEYİT: Başvuru yöntemleri, kimlik doğrulama ve KEP adresi]**

### Şikayet hakkı

Önce bize başvurmanızı rica ederiz. Yanıtımızı yetersiz bulursanız veya süresinde yanıt alamazsanız Türkiye'de **Kişisel Verileri Koruma Kurulu**'na şikayette bulunabilirsiniz (KVKK m.14). AB/AEA'da yaşıyorsanız bulunduğunuz ülkenin veri koruma otoritesine başvurabilirsiniz (GDPR m.77).

## 11. Güvenlik

Verileri en aza indirmek ilk önlemimizdir: çoğu veri zaten cihazınızdan çıkmaz. Aktarılan veriler şifreli bağlantı (HTTPS) ile iletilir. Sağlayıcıları veri koruma yükümlülükleri açısından değerlendirir, erişimi gerekli kişilerle sınırlarız. Hiçbir sistem yüzde yüz güvenli değildir; bir veri ihlali olursa mevzuatın öngördüğü bildirimleri yaparız.

## 12. Değişiklikler

Bu politikayı güncelleyebiliriz. Önemli bir değişiklikte (ör. yeni bir sağlayıcı, yeni bir veri türü, iCloud senkronu gibi yeni bir özellik) uygulama içinde sizi bilgilendiririz; yeni bir işleme için izin gerekiyorsa yeniden izin isteriz. Güncel sürüm her zaman uygulamada ve [WEB SİTESİ ADRESİ] adresinde yayınlanır.

> **[ÖNERİ is5-veri, 2026-10-24]** "iCloud senkronu gibi yeni bir özellik" örneği artık güncel değil: iCloud ile eşitleme kodda (Bölüm 3.11). Özellik açıldığı sürümde bu politika, aydınlatma metni ve App Store etiketi aynı anda güncellenmeli; örnek olarak "hesap veya sunucuya bağlanan yeni bir özellik" yazılabilir.

## 13. İletişim

[AD SOYAD] · [E-POSTA] · [ADRES]

---

*Son güncelleme: [TARİH] · Sürüm: taslak-2*

*English version: privacy_policy_en.md*
