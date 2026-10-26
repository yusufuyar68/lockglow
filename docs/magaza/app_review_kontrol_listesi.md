# App Review: risk kontrol listesi

> **TASLAK (23 Ekim 2026).** Hukuki görüş değildir. Apple'ın kural metni 23 Ekim 2026'da okundu ([App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), son güncelleme 16 Ekim 2026). Uygulama durumu: `origin/main` aa7ef5d, içerik `2026.10.23-kisisel-10`.
>
> Göndermeden önce her satırı yeniden kontrol edin. Paralel is5 oturumları birleşince bazı satırlar değişir (en altta "Birleşince yeniden bak").

**Durum işaretleri:** ✅ bugün uygun · ⚠️ göndermeden önce iş var · ❌ bugün kuralı karşılamıyor · ❓ cihazda ya da Apple'da doğrulanmalı.

**Sahip:** "kod" yazan maddeler kod değişikliği ister; bu oturum koda dokunmadı. Koordinatör ilgili oturuma verir.

## Özet: göndermeden önce mutlaka

| # | İş | Kural | Sahip |
|---|---|---|---|
| G1 | İzin metinlerinin İngilizcesi ve "kelime ya da cümle" düzeltmesi; Türkçe dil klasörü (`tr.lproj`) | 5.1.1(ii), 2.3 | kod (`ios/project.yml` + yeni `InfoPlist.strings`) |
| G2 | `DiagnosticsSwitch.showsInRelease = false` (Yerel ölçüm ve Söyle tanılama sürümde görünmesin) | 2.5.19, 2.1 | kod (`ios/App/WidgetHealthView.swift:11`) |
| G3 | Uygulama içinde gizlilik politikası bağlantısı (Ayarlar'da bir satır) | 5.1.1(i) | kod + yayımlanmış sayfa |
| G4 | Çalışan destek ve gizlilik adresleri | 1.5, 2.1(a) | kullanıcı (alan adı, `destek_ve_gizlilik_url.md`) |
| G5 | Widget'taki Dinle'nin uygulama açılmadan ses çıkardığını cihazda doğrula | 2.3.1, 2.3.3, 2.5.4 | kullanıcı (iPhone) |
| G6 | İçerik kaynakları ve lisans atfı: `content_meta.attribution` "uygulama içi Teşekkürler ekranı" diyor ama böyle bir ekran yok; GRDB (MIT) lisans bildirimi de uygulamada yok; kartlar Claude ile yazıldı, insan denetimi bekliyor | 5.2.1, 2.3 | içerik + kod |
| G7 | Marka: TÜRKPATENT + marka vekili (ad ve ikon) | 4.1, 5.2 | kullanıcı |
| G8 | İnceleme notu (`app_review_notu.md`) güncel hâliyle | 2.1, 2.3.1(a) | kullanıcı girer |

## 1. İzin metinleri (Info.plist) — Kural 5.1.1(ii), (iii), (iv)

| # | Kontrol | Durum | Ayrıntı |
|---|---|---|---|
| 1.1 | Mikrofon izni yalnız Söyle'ye dokununca istenir | ✅ | İzin açılışta istenmez; Söyle sayfasında istenir (`docs/legal/app_store_privacy_etiketi.md` V9). |
| 1.2 | İzin verilmezse uygulama çalışmaya devam eder | ✅ | Söyle "Mikrofon izni kapalı" der ve "Dinle ve kartlar izinsiz de çalışır." diye ekler (`ios/App/PronunciationPracticeView.swift:877–893`). Kural 5.1.1(iv) "başka yol sun" diyor; karşılanıyor. |
| 1.3 | Bildirim izni zorunlu değil | ✅ | Hatırlatma varsayılan kapalı; isteğe bağlı (`ios/App/AppPreferences.swift:83–91`). Kural 5.1.2(i): sistem özelliği kullanım şartı olamaz. |
| 1.4 | Metin ne yaptığını açık ve tam söylüyor | ⚠️ | Mikrofon metni yalnız "kelimeyi" diyor; Söyle'nin "Örnek cümle" modu da var (`PronunciationPracticeView.swift:97–98`). Öneri aşağıda. |
| 1.5 | İngilizce karşılık | ❌ | `ios/` altında hiç `.lproj` ya da `InfoPlist.strings` yok; metinler yalnız Türkçe. İngilizce (U.K.) mağaza sayfası açılınca telefonu İngilizce olan kullanıcı Türkçe izin penceresi görür. |
| 1.6 | Uygulamanın dili mağazada doğru görünüyor mu? | ❌ ❓ | `developmentLanguage: en` (`ios/project.yml:6`) ve Türkçe dil klasörü yok. App Store "Diller" satırını paketteki dil klasörlerinden çıkarır; bugünkü pakette mağaza **"İngilizce"** gösterebilir, uygulama ise Türkçedir. Bu Kural 2.3'e (doğru bilgi) ters düşer **[TEYİT: TestFlight derlemesinin App Store Connect'teki dil satırına bakın]**. Çözüm: `tr` dil klasörü (Türkçe `InfoPlist.strings`) ve gerekirse geliştirme dilini `tr` yapmak. İkincisi sistem düğmelerinin (Paylaş, Vazgeç gibi) Türkçe görünmesini de sağlar. |

**Önerilen izin metinleri** (Apple'ın biçimi: kısa, tam cümle, ne için kullanıldığı açık; `docs/legal/app_store_privacy_etiketi.md` §5.6 ile aynı içerik):

| Anahtar | Türkçe (`tr`) | İngilizce (`en`, en-GB yazımı) |
|---|---|---|
| `NSMicrophoneUsageDescription` | Söyle alıştırmasında söylediğin kelimeyi ya da cümleyi dinlemek için mikrofon kullanılır. Ses kaydedilmez ve telefondan çıkmaz. | Söyle listens to the word or sentence you say so it can check your pronunciation. Nothing is recorded, and your voice never leaves your iPhone. |
| `NSSpeechRecognitionUsageDescription` | Söylediğin kelimenin ya da cümlenin anlaşılıp anlaşılmadığını görmek için konuşma tanıma kullanılır. Bu iş telefonda yapılır; sesin hiçbir yere gönderilmez. | Speech recognition checks whether the word or sentence you say was understood. It runs only on your iPhone; your voice is not sent anywhere. |

Konuşma tanıma izni iOS 17–25'te sorulur; iOS 26+'da kod sormaz (`docs/legal/app_store_privacy_etiketi.md` §5.6). Anahtar yine de durmalı: Speech çerçevesi kullanılırken anahtar yoksa uygulama çöker ([NSSpeechRecognitionUsageDescription](https://developer.apple.com/documentation/bundleresources/information-property-list/nsspeechrecognitionusagedescription)).

## 2. Kişisel veri ve gizlilik — Kural 5.1.1, 5.1.2, 2.3

| # | Kontrol | Durum | Ayrıntı |
|---|---|---|---|
| 2.1 | App Privacy cevabı "Data Not Collected" gerçekle uyumlu | ✅ | Uygulamada ve widget'ta ağ kodu yok; analitik, reklam, hesap, satın alma, CloudKit yok. Tek üçüncü taraf paketi GRDB (yerel veritabanı). Gizlilik manifestinde toplanan veri türü yok (`ios/App/PrivacyInfo.xcprivacy`). |
| 2.2 | Söyle'nin model indirmesi | ✅ ❓ | iOS 26+'da Apple'ın İngilizce konuşma modeli ilk Söyle kullanımında iner; açılışta değil. Ekranda "İngilizce konuşma modeli iniyor. Bu yalnız ilk seferde olur." yazar (`PronunciationPracticeView.swift:113`). Kural 4.2.3(ii) ilk açılışta zorunlu indirmede boyutu söylemeyi istiyor; bizde açılışta değil, kullanıcı dokununca. İstenirse metne yaklaşık boyut eklenebilir **[boyut cihazda ölçülmeli]**. |
| 2.3 | Kendi kelimeler | ✅ | Kullanıcının yazdığı kelime, anlam, örnek ve not yalnız telefonda dosyada (`ios/App/CustomWordLibrary.swift`). Paylaşılmaz, sunucuya gitmez. Kullanıcı içeriği başkasına gösterilmediği için Kural 1.2 (UGC) kapsamı dışında. |
| 2.4 | Yerel ölçüm | ✅ ⚠️ | Yalnız sayılar ve süreler, kelime ya da cevap yok; 120 gün; yedeğe girmez (`Learning/LocalMetrics.swift:3–16`). Veri cihazdan çıkmadığı için "toplama" sayılmaz. Ama G2: sürüm derlemesinde ekranı gizlenmeli. |
| 2.5 | Gizlilik politikası adresi App Store Connect'te ve uygulamada | ❌ | Adres yok (alan adı alınmadı); uygulamada bağlantı yok. G3, G4. |
| 2.6 | Gizlilik politikasının içeriği bugünkü uygulamayla aynı | ⚠️ | `docs/legal/` taslak-2 ileriki abonelikli sürüme göre. İlk ücretsiz sürüm için sadeleştirilmiş hâli (`docs/legal/README.md` §4.1; `destek_ve_gizlilik_url.md`). |
| 2.7 | Mağaza metnindeki gizlilik cümleleri | ✅ | "Hesap yok, reklam yok, takip yok", "İlerlemen ve kendi kelimelerin telefonunda durur", "verini hiçbir sunucuya göndermez": bugün doğru. iCloud eşitlemesi gelirse değişir (en altta). |
| 2.8 | Yaş beyanı ve gizlilik politikası tutarlı | ⚠️ | `kategori_yas_fiyat.md` 13+ öneriyor (birkaç kartta sigara/alkol göndermesi). Gizlilik politikası "13 yaş altına yönelik değil" diyor. İkisi birlikte değişmeli. |

## 3. Widget davranışı — Kural 2.5.16, 2.5.18, 4.2, HIG

| # | Kontrol | Durum | Ayrıntı |
|---|---|---|---|
| 3.1 | Widget uygulamanın işiyle ilgili | ✅ | Kural 2.5.16. Widget kelimeyi ve anlamını gösterir. |
| 3.2 | Widget'ta reklam yok | ✅ | Kural 2.5.18. |
| 3.3 | Kilitli ekran widget'ı yararlı bilgi gösterir, yalnız uygulamayı açan bir kısayol değil | ✅ | Kelime ve Türkçe anlam (`ios/Widgets/AccessoryWordViews.swift:5–13`). HIG bunu istiyor. |
| 3.4 | Kilitli ekranda düğme yok; kilitliyken düğme çalışmaz | ✅ | Kod buna göre kurulmuş (`ios/Widgets/WidgetButtons.swift:6–8`). Mağaza metni ve video kilitli ekranda düğme göstermiyor. |
| 3.5 | Widget boş kalmıyor | ✅ ❓ | İlk plandan önce 400 kelimelik paket içi yedek liste var (`ios/Widgets/Resources/seed_words.json`). Simülatörde "Widget sağlığı: Bilinmiyor" görünüyor; inceleme ekibi widget'ı cihazda ekleyince dolu görmeli. |
| 3.6 | Hassas kartlar widget'ta görünmez | ✅ | 9 kart (`card.sensitivity = 1`) widget'a ve bildirime girmez (`QueueComposer.swift:99–101`). Kilitli ekran herkesin görebileceği bir yer. |
| 3.7 | Dinle düğmesi ve arka plan ses modu | ⚠️ ❓ | `SpeakWordIntent` bir `AudioPlaybackIntent`; Apple, widget'tan ses başlatan düğme için bunu öneriyor. Arka plan modu `audio` (`ios/project.yml:72–73`). Kural 2.5.4 "audio playback"ı meşru sayıyor; duyulur ses çalındığı için uygun görünüyor. Bu birleşim için Apple'ın açık bir örneği yok. **Cihazda çalıştığı doğrulanmadı** (`ios/README.md:254`, G5). İnceleme notunda açıklandı. |
| 3.8 | Widget sesi | ✅ | Telefonun en iyi İngilizce (ABD) sesi, çevrimdışı (`ios/Shared/WordSpeech.swift`). Türkçe okuma yok; metinler bunu iddia etmiyor. |
| 3.9 | Widget'ın yenilenme gecikmesi | ✅ | Açıklama "son kararı iOS verir; bazen birkaç dakika gecikebilir" diyor. Kötü yorum ve 2.3 riskini azaltır. |
| 3.10 | StandBy | ✅ | Ayrı bir StandBy düzeni yok; iOS küçük widget'ı kendisi gösterir. Metinler StandBy iddia etmiyor. |

## 4. Az işlev ve kopya riski — Kural 4.2, 4.2.2, 4.3(b)

| # | Kontrol | Durum | Ayrıntı |
|---|---|---|---|
| 4.1 | Uygulama widget'tan ibaret değil | ✅ | Akış kartları, Tekrar (Tanış + Hatırla, boşluk doldurma, hatırlama ekranı), Söyle, Sözlük, kendi kelimeler, ilerleme. Kural 4.2 için güçlü. |
| 4.2 | Statik liste değil, uygulamaya özgü deneyim | ✅ | Kural 4.2.2. Aralıklı tekrar ve cihaz içi telaffuz alıştırması var. |
| 4.3 | Benzerlerinden ayırt ediliyor | ⚠️ | Kural 4.3(b) "zaten çok bulunanla ayırt edilemeyen" uygulamayı reddeder. Mağazada çok sayıda kelime widget'ı var (`rakip_analizi.md`). Ayıranlar: Türkçe konuşana özel Dikkat kutuları (630 kart), Tanış + Hatırla, cihaz içi Söyle, widget'tan ses, kendi kelimeler, veri toplamama. İnceleme notunda kısaca yazıldı. |
| 4.4 | Rakibin görsel dili kullanılmıyor | ✅ | Ekran görüntüleri Lockglow'un kendi kâğıt rengi ve fosfor şeridiyle; maskot ya da koyu yıldızlı zemin yok (`ekran_goruntusu_basliklari.md`). |
| 4.5 | Aynı uygulamanın kopyası yok | ✅ | Tek uygulama, tek bundle (Kural 4.3(a)). |

## 5. Mağaza bilgileri — Kural 2.3

| # | Kontrol | Durum | Ayrıntı |
|---|---|---|---|
| 5.1 | Her iddia bugünkü uygulamada var | ✅ | `kayit_metinleri_tr.md` → "İddia → kaynak" tablosu. Bağımsız denetçi 23 Ekim'de kontrol etti (`kayit_metinleri_tr.md` sonu). |
| 5.2 | Sayılar şişirilmemiş, eskimeye dayanıklı | ✅ | "1.200'den çok kelime", "3.600'den çok örnek", "600'den çok kelimede Dikkat". İçerik eklendikçe doğru kalır; içerik **azalırsa** düzeltilmeli. |
| 5.3 | Ad, alt başlık, anahtar kelimede fiyat, "en iyi", "#1", rakip adı yok | ✅ | Kural 2.3.7. "Ücretsiz" kelimesi bilerek yok. |
| 5.4 | Başka platform adı yok | ✅ | Kural 2.3.10 (Android vb.). |
| 5.5 | Ekran görüntüleri uygulamayı kullanılırken gösterir | ✅ ⚠️ | Kural 2.3.3. Kareler gerçek ekran görüntüleri; 1. ve 3. kare gerçek widget çıktılarıyla montaj. Mümkünse 1. kare gerçek cihazdan alınmış kilitli ekranla değiştirilir. |
| 5.6 | Görseller her yaşa uygun | ✅ | Kural 2.3.8. |
| 5.7 | Önizleme videosu yalnız uygulamanın ekran kaydı | ✅ | Kural 2.3.4; `onizleme_videosu.md`. |
| 5.8 | "Çocuklar için" ifadesi yok | ✅ | Kural 2.3.8. |
| 5.9 | İlk sürümde "Yenilikler" alanı yok | ✅ | 1.1'den sonra her sürümde zorunlu ve açık olmalı (Kural 2.3.12). Kalıp `kayit_metinleri_tr.md`'de. |
| 5.10 | Yaratıcı görseller (creative assets) | ✅ | Yeni Kural 2.3.14 (16 Ekim 2026): ürün sayfası görselleri uygulamayla ilgili, her yaşa uygun, doğrulanamayan iddiasız. Karelerde "en iyi", fiyat, indirim yok. |

## 6. Bütünlük ve gizli özellik — Kural 2.1, 2.5.19

| # | Kontrol | Durum | Ayrıntı |
|---|---|---|---|
| 6.1 | Sürüm derlemesinde geliştirici ekranı yok | ❌ | `DiagnosticsSwitch.showsInRelease = true` (`ios/App/WidgetHealthView.swift:11`). Koddaki not "App Store'dan önce false yap" diyor. Yeni Kural 2.5.19 gizli ya da belgelenmemiş özellikleri yasaklıyor; bu ekran gizli değil ama "Kabul hedefleri", "Güven aralığı" gibi teknik satırlar inceleme ekibine yarım iş gibi görünebilir. G2. |
| 6.2 | "Teknik bilgiler" (Widget sağlığı) | ✅ ⚠️ | Açılır bir bölüm; gizli değil. App Group, plan kimliği gibi teknik adlar gösteriyor. Kalabilir; istenirse sürümde gizlenir. |
| 6.3 | Uygulamada "beta", "TestFlight", "taslak" yazısı yok | ❓ | Ekranlarda görülmedi. Sürüm satırı "Lockglow 0.1.0 · içerik …" (`SettingsView.swift:548–557`). Mağaza sürümü için `MARKETING_VERSION` 1.0 yapılmalı (`ios/Config/Base.xcconfig:21`). |
| 6.4 | Yer tutucu metin yok | ⚠️ | İçerik veritabanındaki atıf metni "[TASLAK …]" içeriyor (`content_meta.attribution`). Uygulamada gösterilmiyor ama kaynak/lisans durumu netleşmeli (G6). |
| 6.5 | Debug başlatma argümanları | ✅ ❓ | Ekran görüntüsü testleri için yalnız DEBUG'da çalışan yollar varsa sürümde derlenmez; birleşen is5 işlerinde yeniden bakın. |
| 6.6 | Uygulama çökmeden açılıyor, içerik yüklü | ✅ ❓ | TestFlight build 30 kullanıcının telefonunda denenmeli (`DEVIR.md` → "Açık işler"). |

## 7. Fikrî haklar — Kural 4.1, 5.2

| # | Kontrol | Durum | Ayrıntı |
|---|---|---|---|
| 7.1 | Ad ve ikon başkasının markasına benzemiyor | ❓ | TÜRKPATENT araması ve marka vekili görüşü bekleniyor (G7). |
| 7.2 | İçerik kaynakları | ⚠️ | Tanım, örnek ve çeviriler Lockglow için yazıldı (`content_meta.attribution`). Ama aynı metin "başlık kelime seçimi açık lisanslı listelere dayanır" ve "uygulama içi Teşekkürler ekranı" diyor; ekran yok. Kullanılan listeler (ör. NGSL/NAWL CC BY-SA 4.0, Open English WordNet CC BY 4.0, CMUdict) gerçekten kullanıldıysa lisans atfı uygulamada gösterilmeli; kullanılmadıysa cümle düzeltilmeli. Avukat onayı da bekleniyor (G6). |
| 7.3 | Ses | ✅ | iOS'un kendi sesi (AVSpeechSynthesizer); dış ses dosyası yok. |
| 7.4 | Mağaza görsellerindeki yazı tipleri | ✅ | Inter (OFL) ve KaTeX_Main (MIT); SF Pro kullanılmadı (`gorseller/README.md`). |

## 8. Hesap, ödeme, yaş

| # | Kontrol | Durum | Ayrıntı |
|---|---|---|---|
| 8.1 | Giriş yok → demo hesabı gerekmez | ✅ | App Store Connect'te "Sign-in required" kapalı. |
| 8.2 | Satın alma yok | ✅ | StoreKit yok. Kural 3.1 kapsamı dışında. |
| 8.3 | Yaş derecesi anketi | ⚠️ | Öneri 13+ (`kategori_yas_fiyat.md`). Apple araştırması "hepsi None olursa 4+" diyor; alkol/tütün göndermesi sorusu dürüst cevaplanmalı. Karar kullanıcının. |
| 8.4 | Erişilebilirlik etiketleri (isteğe bağlı) | ⚠️ ❓ | Ürün sayfasında "Accessibility Nutrition Labels" şimdilik isteğe bağlı. Bir özellik ancak ana görevlerin hepsi o özellikle yapılabiliyorsa beyan edilir. Aday: Karanlık Arayüz (sistem koyu modu), Daha Büyük Metin (Dinamik Tür, AX boyları), Yeterli Kontrast, Azaltılmış Hareket, VoiceOver, Sesle Denetim. **Her biri cihazda denenmeden beyan edilmez.** |
| 8.5 | İhracat beyanı | ✅ | `ITSAppUsesNonExemptEncryption: false` (`ios/project.yml:66`). |

## 9. İnceleme ekibinin göreceği ilk dakika

- Açılışta seviye, konu, widget rehberi, ilk kelime; her sayfada "Atla" var. Ödeme duvarı, hesap ve izin isteği yok.
- Widget'ı eklemek için inceleme notunda adımlar var (`app_review_notu.md`).
- Söyle iOS 17–25 cihazında İngilizce dikte yoksa çalışmaz ve kurulum adımını gösterir; not bunu söylüyor.
- Hatırlatma teklifi Tekrar'da kart olarak çıkar ("Her gün 1 hatırlatma gönderelim mi?"); "Şimdi değil" ile geçilir.

## 10. Birleşince yeniden bak (paralel is5 oturumları)

Aşağıdaki işler `main`'e birleşirse mağaza metinleri, görseller ve bu liste birlikte güncellenir. Bugünkü metinler bunların **hiçbirini** iddia etmiyor.

| Oturum | Ne değişir | Mağazada etkisi | Kural riski |
|---|---|---|---|
| is5-w-buyuk (büyük widget) | Yeni widget boyu | Açıklamadaki widget listesi; yeni kare olabilir | — |
| is5-w-kilit (kilit ekranı ilerleme halkası, yeni widget'lar) | Yuvarlak kilitli ekran widget'ı olabilir | Widget listesi | — |
| is5-w-quiz (etkileşimli quiz widget'ı) | Widget'ta soru | Yeni kare adayı ("widget'tan cevapla") | Kilitliyken düğme çalışmaz; metin buna göre |
| is5-kontrol (Denetim Merkezi) | Denetim Merkezi düğmesi | "Bilmen gerekenler"e iOS 18 notu | — |
| is5-canli (Canlı Etkinlik) | Kilitli ekranda tur | Yeni özellik satırı | 4.5.3: Canlı Etkinlik reklam ya da spam olamaz |
| is5-kisayol (Siri, Kısayollar) | Siri ve Spotlight | Yeni özellik satırı | — |
| is5-icloud (iCloud yedek/eşitleme) | Veri iCloud'a gider | **Gizlilik cümleleri değişir** ("yalnız telefonunda" yanlış olur); App Privacy ve gizlilik politikası yeniden kontrol | 5.1; iCloud yeteneği kullanıcı adımı |
| is5-watch (Apple Watch) | Saat uygulaması | Watch ekran görüntüleri gerekir; açıklamaya satır | 2.3; Watch bundle kullanıcı adımı |
| is5-ipad (iPad, Mac) | iPad desteği | **13" iPad ekran görüntüleri zorunlu olur**; açıklamadaki "iPhone" satırı | 2.3.3 |
| is5-haftalik (paylaşılabilir kart) | Paylaşım | Yeni özellik satırı; paylaşım kartında kişisel veri olmamalı | 5.1 |
| is5-veri (dışa aktar, sil) | Veri yönetimi | Gizlilik bölümüne "verini dışa aktar ya da sil" satırı; G3 için uygun yer | 5.1.1(v) |
| is5-fsrs (FSRS; yeni kurulumda varsayılan, 2026-10-25) | Zamanlama | "Aralıklı tekrar" cümlesi doğru kalır; "yapay zekâ" yazılmaz | 2.3 |
| is5-dinle-yaz, is5-cumle, is5-kulak, is5-golgeleme | Yeni alıştırmalar | Tekrar ve Söyle bölümlerine satır; yeni kare adayları | — |
| is5-akilli-bildirim | Hatırlatma saati kendiliğinden | "seçtiğin saatte" cümlesi değişebilir | 4.5.4: bildirim pazarlama için kullanılmaz |
| is5-seviye (seviye testi) | Açılış | "Sana göre başla" bölümü | — |
| is5-ses (gelişmiş sesler, aksan) | Ses | "İngiliz ve Amerikan aksanı" yazılabilir (yalnız gelirse) | — |
| is5-icerik-s20/s21/s22 (+180 kart) | Kart sayısı | Yuvarlak sayılar doğru kalır; konu listesi güncellenebilir | — |
| is5-akis-tasarim, is5-sozluk-tasarim, is5-w-tasarim, is5-w-cila, is5-ikon | Görünüm | **Ekran görüntüleri yeniden üretilir** (`gorseller/README.md` → "Nasıl üretilir?") | 2.3.3 |
