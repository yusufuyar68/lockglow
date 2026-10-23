# App Review notu (App Store Connect > App Review Information > Notes)

> **TASLAK (23 Ekim 2026).** İnceleme ekibi İngilizce okur; not İngilizce. Hesap olmadığı için demo hesabı alanı boş kalır ("Sign-in required" kapalı). Uygulama durumu: `origin/main` aa7ef5d.
>
> Gizlilik dayanağı: `docs/legal/app_store_privacy_etiketi.md` §2A ve §5.6. Risk listesi: [`app_review_kontrol_listesi.md`](app_review_kontrol_listesi.md).

```text
Lockglow shows English words with Turkish meanings on the Lock Screen and Home Screen, for Turkish speakers learning everyday English (A1-B1). The app's interface is in Turkish. No account, no sign-in, no in-app purchases, no ads, no analytics. The app and its widget make no network requests. On iOS 26 and later, the first use of "Söyle" asks iOS to download Apple's on-device English speech model (AssetInventory); no user data is sent.

How to review:
1. First launch: choose a level (A1/A2/B1) and topics, or tap "Atla" (skip) to skip onboarding.
2. Add a widget: touch and hold the Home Screen > Edit > Add Widget > Lockglow (small or medium). The Lock Screen widget is added from the Lock Screen > Customize > Add Widgets.
3. Home Screen widget buttons (icons): checkmark = "Biliyorum" (I know this word; medium widget only), speaker = "Dinle" (reads the word aloud), forward = "Sonraki" (next word). Lock Screen widgets show the word and meaning only; they have no buttons.
4. "Tekrar" tab (review): new words come in rounds of 5 ("Tanış" = meet, then "Hatırla" = recall, a 4-option question). Due words come back as fill-in-the-blank or recall questions.
5. "Söyle" (pronunciation practice): tap the microphone icon on a word card, allow the microphone, and say the word. Without permission, the rest of the app works normally.
6. "Ayarlar" (settings) > "Kendi kelimelerin": add your own word; it then appears on the widget and in reviews.

Microphone and speech recognition: used only in "Söyle", only after the user taps it, and only while listening. Recognition runs on the device only (iOS 26+: SpeechAnalyzer with DictationTranscriber; iOS 17-25: SFSpeechRecognizer with requiresOnDeviceRecognition = true; when on-device recognition is unavailable the feature shows setup steps instead of using a server). Audio is never written to a file or sent anywhere. On iOS 17-25 the device needs on-device English (US) recognition (English keyboard with Dictation enabled).

Background audio (UIBackgroundModes: audio): used only for the speaker button on the Home Screen widget. The button is an AudioPlaybackIntent, which the system runs in the app's process; it reads the word aloud with the on-device AVSpeechSynthesizer voice. The microphone is never used in the background, and listening stops when the app leaves the foreground.

Notifications: one optional local daily reminder, off by default; no push notifications.
```

Uzunluk: 2.431 karakter. 2.437 bayt (Apple'ın bu alan için sınırı 4.000 bayt).

## Notlar

- **22 Ekim taslağından farkı:** Tanış + Hatırla (4. adım) ve kendi kelimeler (6. adım) eklendi; widget düğmeleri boya göre ayrıldı (Biliyorum yalnız orta widget'ta, `ios/Widgets/HomeWordViews.swift:121–127, 296–306`); hatırlatmanın varsayılan kapalı olduğu yazıldı (`ios/App/AppPreferences.swift:83–91`); izin verilmezse uygulamanın çalıştığı söylendi (`ios/App/PronunciationPracticeView.swift:891–893`, Kural 5.1.1(iv)); içerik cümlesi eklendi (Kural 5.2).
- **Menü adları:** inceleme ekibi büyük olasılıkla ABD İngilizcesiyle çalışır; bu yüzden "Customize" (uygulamanın rehberi de bu adları veriyor: `ios/App/WidgetGuideView.swift:102–109`).
- **"No network requests"** kodda doğrulandı (23 Ekim 2026: `URLSession` ya da `http` adresi yok). Tek istisna, iOS 26+'da sistemin indirdiği konuşma modeli; notta yazılı. Analitik, abonelik, iCloud ya da içerik indirme eklenirse cümle **değişmeli**.
- **İçerik cümlesi çıkarıldı (denetim):** kartlar Claude ile yazıldı ve henüz insan denetiminden geçmedi; ayrıca `content_meta.attribution` O metin başlık kelime seçimi için açık lisanslı listelere de atıf yapıyor ve "uygulama içi Teşekkürler ekranı" diyor; böyle bir ekran yok. Kaynak/lisans ve GRDB (MIT) lisans bildirimi netleşince içerik cümlesi yeniden yazılabilir (`app_review_kontrol_listesi.md` G6).
- **Sürümde gizlenecekler:** "Widget sağlığı" altındaki "Tanılama" (Yerel ölçüm, Söyle tanılama) mağaza derlemesinde kapalı olmalı (`ios/App/WidgetHealthView.swift:11`, G2). Kapatılmazsa nota bir satır eklenir: "Widget sağlığı > Tanılama shows local, on-device counters for the developer; nothing leaves the device."
- **Paralel is5 işleri birleşirse** (Denetim Merkezi, Canlı Etkinlik, Siri, iCloud, Watch, iPad) her biri için nota bir adım eklenir; özellikle iCloud gelirse ilk paragraftaki "make no network requests" cümlesi yeniden yazılır.
- Widget ekleme adımları iOS 26'ya göre; menü adları değişirse güncelleyin.
