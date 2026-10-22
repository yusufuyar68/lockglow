# App Review notu (App Store Connect > App Review Information > Notes)

> **TASLAK (22 Ekim 2026).** İnceleme ekibi İngilizce okur; not İngilizce. Hesap olmadığı için demo hesabı alanı boş kalır ("Sign-in required" kapalı).
>
> Gizlilik dayanağı: `docs/legal/app_store_privacy_etiketi.md` §2A ve §5.6.

```text
Lockglow shows English words with Turkish explanations on the Lock Screen and Home Screen. The app's interface is in Turkish. No account, no sign-in, no in-app purchases, no ads, no analytics. The app itself makes no network requests. On iOS 26 and later, the first use of "Söyle" asks iOS to download Apple's on-device English speech model (AssetInventory); no user data is sent.

How to review:
1. On first launch, choose a level (A1/A2/B1) and topics, or tap "Atla" (skip).
2. Add a widget: long-press the Home Screen > Edit > Add Widget > Lockglow. The Lock Screen widget is added from the Lock Screen > Customize.
3. Home Screen widget buttons: checkmark = "I know this word", speaker = read the word aloud, forward icon = next word. The Lock Screen widgets show the word only.
4. "Söyle" (pronunciation practice): tap the microphone on a word card, allow the microphone, and say the word.

Microphone and speech recognition: used only in "Söyle", only after the user taps it, and only while listening. Recognition runs on the device only (iOS 26+: SpeechAnalyzer with DictationTranscriber; iOS 17-25: SFSpeechRecognizer with requiresOnDeviceRecognition = true, and the feature shows a message instead of using a server when on-device recognition is unavailable). Audio is never written to a file or sent anywhere. On iOS 17-25 the device needs on-device English (US) recognition.

Background audio (UIBackgroundModes: audio): used only for the speaker button on the Home Screen widget. The button is an AudioPlaybackIntent, which the system runs in the app's process; it reads the word aloud with the on-device AVSpeechSynthesizer voice. The microphone is never used in the background, and listening stops when the app leaves the foreground.

Notifications: one optional local daily reminder; no push notifications.
```

Notlar:

- Karakter sınırı Apple belgesinde yazmıyor; not kısa tutuldu **[TEYİT]**.
- "No network requests" cümlesi kodda doğrulandı (2026-10-22); tek istisna iOS 26+'da sistemin indirdiği konuşma modeli, notta yazılı. Analitik, abonelik ya da içerik indirme eklenirse cümle **silinmeli**.
- Widget ekleme adımları iOS 26'ya göre; menü adları değişirse güncelleyin.
- Söyle için iOS 17–25 cihazında İngilizce dikte kurulu değilse inceleme ekibi hata görebilir; nota bu yüzden yazıldı.
