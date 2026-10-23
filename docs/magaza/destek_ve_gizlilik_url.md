# Destek ve gizlilik adresleri (Support URL, Privacy Policy URL)

> **TASLAK (23 Ekim 2026).** Hiçbir sayfa yayımlanmadı. Alan adı alınmadı. Yayımlamak ve App Store Connect'e girmek kullanıcının işidir.
>
> **Marka uyarısı:** "Lockglow" adı için TÜRKPATENT araması ve marka vekili görüşü bitmedi. Adı taşıyan bir sayfa (destek sayfası da) bu iki adımdan **önce yayımlanmaz** (`DEVIR.md`, `marketing/landing/` kuralıyla aynı).

## Apple ne istiyor? (23 Ekim 2026'da bakıldı)

| Alan | Zorunlu mu? | Şart |
|---|---|---|
| **Support URL** | Evet | Sayfa **gerçek iletişim bilgisine** götürmeli (e-posta, adres ya da telefon). Boş ya da "yakında" sayfası reddedilir (Kural 1.5 ve 2.1(a)). |
| **Privacy Policy URL** | Evet (bütün uygulamalar) | Çalışan bir adres. Gizlilik politikasına **uygulamanın içinden de** kolayca ulaşılmalı (Kural 5.1.1(i)). |
| Marketing URL | Hayır | Tanıtım sayfası. Marka kesinleşmeden boş bırakılır. |
| Copyright | Evet | Ör. `2026 <ad soyad>`. Kişinin adı App Store'da görünür; kullanıcı karar verir. |

Kaynaklar: [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information), [Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), [Review Guidelines 1.5, 2.1, 5.1.1](https://developer.apple.com/app-store/review/guidelines/).

## Önerilen adresler

Alan adı alınınca (`DEVIR.md` → "Yayın işleri": lockglow.com/.app) aynı alan adında iki dilli sayfalar:

| Sayfa | Türkçe | İngilizce (U.K. yerelleştirmesi için) |
|---|---|---|
| Destek | `https://<alan-adı>/destek` | `https://<alan-adı>/en/support` |
| Gizlilik politikası | `https://<alan-adı>/gizlilik` | `https://<alan-adı>/en/privacy` |

- App Store Connect'te bu iki alan **yerelleştirme başınadır**: Türkçe sayfaya Türkçe, English (U.K.) sayfasına İngilizce adres girilir.
- Kısa ve kalıcı adres seçin: uygulama içindeki gizlilik bağlantısı da bu adrese gider; adres değişirse uygulamanın yeni sürümü gerekir.
- **Ara çözüm (alan adı gecikirse):** depo zaten herkese açık; GitHub Pages ile aynı içerik yayımlanabilir. Ama adres kullanıcı adını taşır ve marka kontrolünden önce yayımlanmaz. Öneri: gönderim tarihine kadar alan adını almak.
- **Destek e-postası:** depoya kişisel e-posta **yazılmaz** (depo açık). Alan adıyla birlikte ayrı bir adres önerilir (ör. `destek@<alan-adı>`). Aşağıda `[DESTEK E-POSTASI]` yazan yerler o adresle doldurulur.

## Gizlilik politikası sayfası

- Metin `docs/legal/` klasöründe (taslak-2, avukat kontrolü bekliyor). O metin ileriki abonelikli sürüme göre yazıldı; ilk ücretsiz sürüm için **sadeleştirilmiş hâli** yayımlanmalı (`docs/legal/README.md` §4.1).
- Yayımlanacak sürümün söylemesi gerekenler (bugünkü uygulamaya göre; `docs/legal/app_store_privacy_etiketi.md` §2A ve §5.6):
  - Hesap, reklam, analitik ve üçüncü taraf kodu yok. Uygulama ve widget ağa çıkmaz. Tek istisna: iOS 26 ve sonrasında Söyle ilk kullanımda Apple'ın İngilizce konuşma modelini indirir; kişisel veri gönderilmez.
  - İlerleme, ayarlar, **kendi eklediğin kelimeler** ve yerel ölçüm yalnız telefonda durur. Uygulamayı silince silinir.
  - Söyle: mikrofon yalnız Söyle'ye dokununca açılır; ses kaydedilmez ve telefondan çıkmaz.
  - Günlük hatırlatma telefonda planlanan yerel bildirimdir; uzaktan bildirim yok.
- **İleride değişirse sayfa da değişir:** iCloud eşitlemesi (is5-icloud oturumu), dışa aktarma (is5-veri), analitik ya da abonelik gelirse gizlilik politikası, App Privacy cevabı ve mağaza açıklamasındaki gizlilik satırları birlikte güncellenir.
- **Uygulama içi bağlantı:** bugünkü uygulamada gizlilik politikası bağlantısı **yok** (23 Ekim 2026, `origin/main` aa7ef5d). Ayarlar'a bir satır eklenmesi gerekir; ayrıntı `app_review_kontrol_listesi.md` madde G3.

## Destek sayfası: Türkçe taslak

Uygulamanın diliyle aynı ton: "sen" dili, kısa cümleler, ünlem yok. Her cevap bugünkü uygulamaya göre yazıldı (kaynaklar sayfanın sonunda).

```text
Lockglow: Destek

Lockglow, kilitli ekranında ve ana ekranında İngilizce kelimeler gösterir. Her kelimenin Türkçe anlamı, örnek cümlesi ve okunuşu vardır. Uygulamanın dili Türkçedir.

Sorun mu var, öneri mi? Bize yaz: [DESTEK E-POSTASI]
Genelde birkaç gün içinde cevap veririz.

SIK SORULANLAR

Widget'ı nasıl eklerim?
Kilitli ekran: Kilitli ekranda boş bir yeri basılı tut. Alttaki Özelleştir'e dokun, sorarsa kilitli ekranı seç. Araç Takımı Ekle'ye dokun, listeden Lockglow'u seç. Bitti'ye dokun.
Ana ekran: Ana ekranda boş bir yeri basılı tut. Üstteki Düzenle'ye, sonra Araç Takımı Ekle'ye dokun. Lockglow'u ara, küçük ya da orta boyu seç. Widget'ı yerine taşı, Bitti'ye dokun.
iPhone widget'a "araç takımı" der.

Widget'taki kelime değişmiyor.
Widget'ın ne zaman yenileneceğine son kararı iOS verir; bazen birkaç dakika gecikir. Lockglow'u bir kez aç. Sonra Ayarlar'da Widget sağlığı sayfasına gir ve Widget'ları yenile düğmesine dokun. Kelimenin ne sıklıkla değişeceğini Ayarlar'da seçebilirsin.

Widget'taki düğmeler çalışmıyor.
Dinle ve Sonraki düğmeleri ana ekran widget'ındadır; Biliyorum yalnız orta boyda. Kilitli ekrandaki widget'ta düğme yoktur. iPhone kilitliyken widget düğmeleri çalışmaz; önce kilidi aç.

Söyle çalışmıyor.
Söyle mikrofon izni ister; iOS 17–25'te ayrıca konuşma tanıma izni. İzni kapattıysan iPhone Ayarları'nda Lockglow için aç. Dinle ve kartlar izinsiz de çalışır.
iOS 26 ve sonrası: İngilizce konuşma modeli ilk kullanımda bir kez iner. Bunun için internet gerekir; sonra gerekmez.
iOS 17–25: Telefonunda İngilizce konuşma tanıma hazır olmalı. iPhone Ayarları'nda Genel, sonra Klavye bölümüne gir. İngilizce (ABD) klavyeyi ekle ve Dikte'yi aç.

Sesim kaydediliyor mu?
Hayır. Söyle sesini yalnız telefonunda dinler. Ses kaydedilmez ve telefondan çıkmaz.

Günlük hatırlatmayı nasıl açar ya da kapatırım?
Ayarlar'da Hatırlatma bölümünden. Hatırlatma günde en çok bir kez gelir ve bir kelimeyi anlamıyla gösterir.

Yanlışlıkla "Biliyorum" dedim.
Ayarlar'da Bildiğin kelimeler listesine gir ve Geri al'a dokun. Kelime yeniden öğrenme listene döner.

Kendi kelimemi ekleyebilir miyim?
Evet. Ayarlar'da Kendi kelimelerin bölümünden İngilizce kelimeyi, Türkçe anlamını ve istersen bir örnek cümle ekle. Kelime widget'ta ve Tekrar'da karşına çıkar.

Hesap gerekiyor mu? Verilerim nerede?
Hesap yok, reklam yok. İlerlemen, ayarların ve kendi kelimelerin yalnız telefonunda durur; biz göremeyiz. Lockglow'u silersen bunlar da silinir.

Hangi iPhone'larda çalışır?
iOS 17 ve sonrası yüklü iPhone'larda.

Gizlilik politikası: [GİZLİLİK POLİTİKASI ADRESİ]
```

## Destek sayfası: İngilizce taslak (English U.K.)

```text
Lockglow: Support

Lockglow shows English words on your Lock Screen and Home Screen. Every word comes with its Turkish meaning, an example sentence and audio. The app itself is in Turkish.

A problem or an idea? Write to us: [SUPPORT EMAIL]
We usually reply within a few days.

FREQUENTLY ASKED QUESTIONS

How do I add the widget?
Lock Screen: touch and hold an empty part of the Lock Screen. Tap Customise, then the Lock Screen. Tap Add Widgets and choose Lockglow. Tap Done.
Home Screen: touch and hold an empty part of the Home Screen. Tap Edit, then Add Widget. Search for Lockglow, choose the small or medium size, place it and tap Done.

The word on my widget does not change.
iOS decides exactly when a widget refreshes, and it can sometimes be a few minutes late. Open Lockglow once. Then open Ayarlar (Settings), Widget sağlığı (widget health) and tap Widget'ları yenile (refresh widgets). In Ayarlar you can also choose how often the word changes.

The widget buttons do not work.
The Dinle (listen) and Sonraki (next) buttons are on the Home Screen widget; Biliyorum (I know it) is on the medium size only. The Lock Screen widget has no buttons. Widget buttons do not work while your iPhone is locked; unlock it first.

Söyle (pronunciation practice) does not work.
Söyle needs microphone permission, and on iOS 17–25 also speech recognition permission. If you turned it off, turn it on for Lockglow in the iPhone Settings app. Listening and the word cards work without it.
iOS 26 and later: the English speech model downloads once, on first use. This needs an internet connection; after that it does not.
iOS 17–25: your iPhone needs on-device English recognition. In Settings, go to General, then Keyboard. Add the English (US) keyboard and turn on Dictation.

Is my voice recorded?
No. Söyle listens only on your iPhone. Nothing is recorded, and your voice never leaves your phone.

How do I turn the daily reminder on or off?
In Ayarlar, under Hatırlatma (reminder). It comes at most once a day and shows a word with its meaning.

I tapped "Biliyorum" by mistake.
In Ayarlar, open Bildiğin kelimeler (known words) and tap Geri al (undo). The word goes back to your learning list.

Can I add my own words?
Yes. In Ayarlar, open Kendi kelimelerin (your own words) and add an English word, its Turkish meaning and, if you like, an example sentence. It then appears on your widget and in Tekrar (review).

Do I need an account? Where is my data?
No account and no ads. Your progress, settings and own words stay on your phone; we cannot see them. If you delete Lockglow, they are deleted too.

Which iPhones does it work on?
iPhones with iOS 17 or later.

Privacy Policy: [PRIVACY POLICY URL]
```

İngilizce sayfada Türkçe düğme adları parantez içinde İngilizce karşılığıyla verildi: uygulama Türkçe olduğu için kullanıcı ekranda Türkçe adı görür. iOS'un kendi düğme adları (Customise, Add Widgets, Edit, Done) İngiliz yazımıyla ve Apple'ın İngilizce adlarıyla yazıldı **[TEYİT: iOS 26 İngilizce (U.K.) menü adları cihazda kontrol edilmeli]**.

## Cevapların kaynağı (origin/main aa7ef5d, 23 Ekim 2026)

| Cevap | Kaynak |
|---|---|
| Widget ekleme adımları | Açılış akışındaki rehber (`ios/App/WidgetGuideView.swift`; ekran görüntüsü `0c-acilis-widget-kilit`, `0d-acilis-widget-ana`) |
| Widget'ları yenile, Widget sağlığı | `ios/App/WidgetHealthView.swift:36–37, 138` |
| Kilitliyken düğmeler çalışmaz | Apple WidgetKit belgesi ([Adding interactivity](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)); kilitli ekran widget'ında düğme yok (`docs/tasarim/ogrenme_ilkeleri.md` 2.1) |
| Söyle izin ve model mesajları | `ios/App/PronunciationPracticeView.swift:113, 875–905` |
| Ses kaydedilmez | `ios/App/PronunciationPracticeView.swift:143`; `docs/legal/app_store_privacy_etiketi.md` V9 |
| Bildiğin kelimeler, Geri al | Ekran görüntüsü `9-bildiklerim` |
| Kendi kelimelerin | `ios/App/CustomWordsView.swift`; ekran görüntüsü `15d-kendi-kelime-liste` ("Widget'ta ve Tekrar'da karşına çıkacak") |
| iOS 17 | `ios/project.yml:5` |

Uygulamadaki metinler değişirse (ör. is5 oturumlarının yeniden tasarımları) bu cevaplar da kontrol edilir.
