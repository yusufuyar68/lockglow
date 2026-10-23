# Lockglow Privacy Policy

> **DRAFT:** Not a lawyer-reviewed document. Do not publish before legal review. Fill in all bracketed fields and resolve every **[TEYİT]** item (Turkish for "to be confirmed by counsel"). Delete this box before publishing.
>
> **draft-2 (22 October 2026):** the "Söyle" (microphone, on-device speech recognition) and read-aloud / widget speaker sections were updated after checking the app's code. Every changed place is marked **[TEYİT]**. The text is written for the later version with a subscription and analytics; for a first free version, see `README.md` §4.1 (simplification).
>
> **[ÖNERİ is5-veri, 2026-10-24]** **draft-3 proposals:** words you add yourself, local metrics, the "Verilerin" (your data) screen (export, import, erase everything) and iCloud sync, checked against the app's code of 24 October 2026 (`origin/main` cb3cf7a + branch `is5-veri` 79d4113). Every proposal is marked `[ÖNERİ is5-veri]`; code evidence (file:line) is in the matching proposals of the Turkish policy `gizlilik_politikasi_tr.md`.

**Last updated:** [DATE] · **Version:** draft-2

---

## In short

- Lockglow does not ask you to create an account. You never give us your name, email or phone number to use it.
- Your learning progress, saved words and settings stay **on your device only**.

> **[ÖNERİ is5-veri, 2026-10-24]** Replace this bullet and add two (reason: iCloud sync is now in the code, off by default, and the "Verilerin" screen was added):
>
> - Your learning progress, the words you add and your settings stay **on your device**. If you turn on "iCloud ile eşitle" (iCloud sync), your progress and your own words are also kept **in your own iCloud account**; we cannot see them (Section 3.11). **[TEYİT]**
> - In **Settings > Progress > Verilerin** you can export your data as files, restore it from a backup, or erase all app data. Files go only where you choose; they never reach us (Section 3.10).
> - Words you add yourself can appear on the widget and the Lock Screen, so do not type personal or sensitive information into them (Section 3.1a).

- For **Söyle** (pronunciation practice) the microphone turns on only when you tap it and allow it. Your voice is turned into text on your phone; it is not recorded and not sent to us or anyone else. The speaker buttons that read words aloud (including the widget's) also use the phone's own voice. **[TEYİT]**
- We show no ads, we do not track you across other apps or websites, and we do not sell your data.
- Usage statistics (analytics) are collected **only if you say yes**. Saying no does not limit any feature of the app.
- We use RevenueCat to check your subscription status. We never see your card details; Apple handles the payment.

---

## 1. Who is responsible for your data

In this policy, "we" means:

**[FULL NAME]** (an individual developer, acting as a sole proprietor, not a company)
Email: [EMAIL]
Address: [ADDRESS] **[TEYİT: which address goes into a public document. A verifiable office/coworking address or a registered electronic mail (KEP) address may be preferable to a home address.]**
Representative for users in the EU: [EU REPRESENTATIVE — insert if appointed, otherwise delete this line] **[TEYİT: whether GDPR Art. 27 requires one.]**

The seller name shown on the App Store is the same person.

We are based in Türkiye. Turkish data protection law (Law No. 6698, "KVKK") applies to us. Where we offer the app to people in the EU/EEA, we also follow the GDPR.

## 2. What this policy covers

This policy covers the Lockglow iOS app and its widgets. Our website and early-access list have a separate privacy notice.

If you live in Türkiye, please also read our KVKK **Notice (Aydınlatma Metni)**. Optional analytics has its own **Consent Text**. These documents work together.

## 3. What data we handle

### 3.1 Data that stays on your device

The following is stored on your device and is **not sent to us**:

- your chosen level, goals and settings,
- saved words, "I know it" marks, learning status, quiz results and streak,
- custom lists you create,
- words you add yourself (the English word, its Turkish meaning, and an optional example sentence and note),
- widget settings and reminder times.

This data lives in storage shared between the app and its widgets, and it is deleted when you delete the app. If you back up your device to iCloud or a computer, Apple's backup service may include this data. That depends on your Apple settings and on Apple's own policy; we have no access to those backups.

> **[ÖNERİ is5-veri, 2026-10-24]** The list above and this paragraph should be replaced as follows. Reason (evidence in the Turkish policy `gizlilik_politikasi_tr.md` §3.1 proposal): the app has no streak and no custom lists; most data sits in the app's own Application Support folder, not in the storage shared with the widgets; local metrics are excluded from device backups, the other files are not.
>
> The following is stored on your device and is **not sent to us**:
>
> - your settings: start level, chosen topics, daily goal, how often the widget changes word, reminder on/off and time, voice and accent,
> - your learning state: each word's status and box, next review date, answer and mistake counts, how often you saw it on the widget, "Biliyorum" (I know it) marks and saved words,
> - a review log: the time, result and place (review session or widget) of every answer,
> - words you add yourself (Section 3.1a),
> - your recent dictionary searches (at most 8) and when you first saw a word in the feed,
> - local metrics (Section 3.9),
> - if you turned on iCloud sync, the state of the last sync (Section 3.11).
>
> Most of this data is kept in the app's own on-device storage. The words the widgets show (including your own), your widget taps and the voice setting are kept in on-device storage shared by the app and its widgets. If a file is damaged, the app does not delete it; it sets it aside under another name and uses the daily backup copy, and these copies stay on your device too. Deleting the app or using "Hepsini sil" (erase everything, Section 3.10) removes this on-device data.
>
> If you back up your device to iCloud or a computer, this data (except local metrics) may be included in Apple's device backup. That depends on your Apple settings and Apple's own policy; we have no access to those backups. Device backup is a separate Apple feature from the in-app iCloud sync in Section 3.11. **[TEYİT]**

Reminders are scheduled locally on your device (local notifications). We do not send a push token to any server. Words are read aloud with your device's own voice (see Section 3.8). **[TEYİT]**

> **[ÖNERİ is5-veri, 2026-10-24]** New subsection **3.1a Words you add yourself**:
>
> For each word you type in with "Kendi kelimeni ekle" (add your own word) the app keeps: the English word, its Turkish meaning, an optional example sentence and note, and the dates it was added and last changed. This stays on your device. The app keeps one backup copy a day and sets a damaged file aside under another name instead of deleting it. If you turn on iCloud sync, these words also go to your iCloud account (Section 3.11). They are not sent to us.
>
> **They can appear on the Lock Screen.** Your own words rotate on the widget like the other cards. The Lock Screen widget can show the word and its Turkish meaning, the Home Screen widget also the example sentence, and anyone holding your phone can see them. If you use the Apple Watch app, the widget's words are also sent to the watch and can appear there. A word may also appear in a reminder notification **[TEYİT]**. So please **do not type personal or sensitive information** (names, phone numbers, addresses, passwords, health details and the like) into your own words, examples or notes.

### 3.2 Subscription and purchase information (required)

When you buy Premium, Apple processes the payment. Apple does not give us your card number, your Apple ID email or your name.

To check whether a subscription is active, we use **RevenueCat, Inc.** To show prices and check your status, the app sends RevenueCat:

- a random app user ID generated by RevenueCat (this is not an account and is not linked to your name),
- Apple's purchase transaction data (product, purchase and expiry dates, trial/renewal/refund state),
- your App Store country and the app and iOS versions,
- your IP address, which is unavoidably visible in any internet connection.

**[TEYİT: the current list of fields RevenueCat collects (e.g. device identifier IDFV, IP retention period), and whether the SDK starts at first launch or only at the paywall / restore. This text assumes the broader "starts at first launch" scenario.]**

This processing is needed to deliver the subscription feature. It does not depend on analytics consent.

### 3.3 Optional usage statistics (only with your permission)

When you first use the app we show a consent screen. If you tap **"I agree"**, the data below is collected. If you tap **"Not now"**, no analytics data is collected and the analytics tool is never started.

- **Identifier:** At the moment you agree, a random ID is generated on your device. It is not linked to your name, email, phone number or advertising identifier (IDFA). It is pseudonymous: it does not identify you directly, but it connects records coming from the same device.
- **Events:** Which screens you open, onboarding steps, whether a widget is installed and how many, widget taps (such as "Next" or "I know it"), counts of learning actions, quiz completion, paywall views and which experiment group you are in.
- **Device and setting information:** App and iOS version, device model, language, App Store country, chosen level and goal, and subscription state (none/trial/paid/expired).

**What we do not send:** the content of your word lists, text you type in search, your name, email, location or contacts. Location is not derived from your IP address, and your IP address is not stored in analytics records **[TEYİT: confirm these settings are configured in the analytics tool and verified with real network traffic.]**

Analytics data is processed in **PostHog**'s EU cloud region. You can withdraw your consent at any time (see Section 10).

### 3.4 Crash and error information

- **Apple's own mechanism:** If you allow sharing with app developers under "Analytics & Improvements" on your iPhone, Apple may give us aggregated, non-identifying crash reports and usage statistics. Apple is the one that collects this data.
- **[OPTIONAL — only if Sentry is used:]** If you allow it, crash and error reports are sent to Sentry. They contain the app version, iOS version, device model and the technical trace of the error. They do not contain your name, email or IP address **[TEYİT]**. This is a separate switch in Settings > Privacy and is off by default.

### 3.5 When you write to us

If you email us for support or use "Report a mistake", we process your email address, your message and (for a report) the ID of the word concerned. **[TEYİT: whether "Report a mistake" opens an email draft or is an in-app form. An in-app form with a server would require updating this section and the App Store privacy label.]**

### 3.6 Data we do not handle

Lockglow does **not** collect your location, contacts, photos, camera, health data, payment card details or advertising identifier (IDFA). The microphone is used only for Söyle, on the device; no audio is collected (see Section 3.7) **[TEYİT]**. It does **not** track you across other apps or websites, shows **no ads**, does **not sell** your data and does not share it for advertising.

There is no AI chat in the app, and your personal data is not sent to third-party AI services.

### 3.7 Pronunciation practice ("Söyle") and the microphone

**[TEYİT: rewritten in draft-2 (22 October 2026) after checking the app's code.]**

With "Söyle" ("Say it") you say the card's word or its example sentence aloud, and the app tells you in Turkish whether you said it right (for example "Doğru!" (right), "Neredeyse!" (almost), "Bir daha dene" (try again)).

- **Permission is asked only when you use it.** Microphone permission is requested the first time you tap "Söyle", at that moment, never at app launch. On iOS 17–25 **speech recognition permission** is requested as well; on iOS 26 and later only the microphone permission is requested. If you decline, the rest of the app (cards, review, read-aloud, widgets) works as before. You can turn the permissions off at any time in iPhone Settings under Lockglow.
- **The microphone is on only while listening.** Listening stops by itself when you finish speaking, after a few seconds if you say nothing, when the time limit is reached, or when you tap "Bitti" (done). It stops at once if the app goes to the background, if an interruption such as a phone call occurs, or if you close the Söyle screen. The app never listens in the background.
- **Your voice does not leave your device.** Your speech is turned into text only on your device, by Apple's on-device speech recognition, and compared with the target word or sentence. On iOS 17–25 the app requires recognition to run on the device: if your phone has no on-device English recognition, Söyle does not work and shows a message; your voice is never sent to a server instead. On iOS 26 and later, the Apple component the app uses does not send audio to Apple's servers either.
- **Nothing is recorded, stored or shared.** The audio is held in memory only during that attempt and is never written to a file. The recognized text and the result are only shown on screen; they are not saved to your learning progress, to the backup or anywhere else. Neither the audio, nor the recognized text, nor the result is sent to us or to third parties (analytics included).
- **Your voice is not used to identify you.** The app creates no voiceprint and does not verify identity by voice; it only turns the words you say into text.
- **Model download:** On iOS 26 and later, Apple's English speech model is downloaded once from Apple on first use. Your voice is not sent in that download; the model is managed by iOS, stored on your iPhone and may be shared with other apps.

If Söyle ever changes so that audio or recognized text would leave your device, we will update this policy first and ask for your permission again.

**[TEYİT: whether purely on-device audio that never reaches us counts as "processing" by us under KVKK; the assumption that voice used only for transcription, not identification, is not biometric (special category) data. README §6 questions 20 and 31.]**

> **[ÖNERİ is5-veri, 2026-10-24]** Check (2026-10-24): Section 3.7 still matches the code (evidence in the Turkish policy `gizlilik_politikasi_tr.md` §3.7 proposal). Proposed corrections: (1) "English" should read "the English accent you chose (US or UK)": the "Ses ve aksan" (voice and accent) setting now also sets the recognizer's language; on iOS 17–25 the app falls back to US English when the chosen accent cannot be recognized on the device. Section 3.8's "US English voice" should likewise become "the US or UK English device voice you chose". (2) A developer screen in test builds ("Söyle tanılama") keeps the last 20 attempts' result, duration, confidence and error code **in memory only** (never what was said; gone when the app quits) and is currently enabled in release builds too; if it is not switched off before release, add that the result is kept in memory for a test screen while the app is open. (3) Nothing from Söyle goes into the export file or the iCloud copy.

### 3.8 Read-aloud and the widget's speaker button

**[TEYİT: added in draft-2 (22 October 2026).]**

- The speaker buttons in the app and the **"Kelimeyi dinle"** (listen to the word) button on the Home Screen widgets read the English word or sentence **with the iPhone's own US English voice, on the device**. No internet connection is used, and the text is not sent to any server.
- The widget button works without bringing the app to the screen. For this, iOS runs Lockglow briefly in the background to read the word; the app's "audio in the background" capability is used only for this read-aloud. The microphone is never turned on in the background.
- The text read aloud is the card's word or sentence. For a word you added yourself (Section 3.1), the word and example you typed are read; this also happens on the device, and the text is not sent anywhere. Taps on the button are not recorded and not sent to us.
- Apple's Personal Voice is not used. If you downloaded a higher-quality English voice in iPhone Settings, the app may use it; that download is between you and Apple.

> **[ÖNERİ is5-veri, 2026-10-24]** New subsection **3.9 Local metrics (on your device only)**:
>
> To see whether studying stays light, the app keeps a few numbers on your device. Per day, counts and durations only: how many questions you answered and how many you got right at the first try, round lengths, rounds ended early with "Bitir", how many taps a new word took, the result of the later check on words you marked "Biliyorum", and how many words are in each box. Per daily reminder: when it was set for, whether it was opened, and whether the app was opened afterwards. No words and none of your answers are stored in these metrics.
>
> The metrics cover the last 120 days; older entries are deleted automatically. They never leave your device by themselves: they are not sent to us, not shared with the widgets, not synced to iCloud and not included in iCloud or computer backups. "İlerlemeyi sıfırla" (reset progress) and "Hepsini sil" delete them. They go into files only if you use "Dışa aktar" (export, Section 3.10).

> **[ÖNERİ is5-veri, 2026-10-24]** New subsection **3.10 Controlling your data: the "Verilerin" screen** (Settings > Progress > Verilerin).
>
> **Export ("Dışa aktar").** Runs only when you tap it. The app writes the files into its own temporary folder and opens the iPhone share sheet; you choose where they go (Files/iCloud Drive, AirDrop, Mail or another app). The files are not sent to us, and this feature uses no internet connection. The files are:
>
> - `lockglow-yedek-YYYY-MM-DD.json`, a backup containing, for each word, the card number, English word, Turkish meaning, learning state, box, next review / last answer / first answer / last seen dates, and answer, mistake and widget-view counts; the list of words you know; your own words with example, note and dates; the review log (time, result and place of every answer); local metrics; your settings (start level, chosen topics, daily goal, widget change interval, reminder on/off and time); your recent dictionary searches; and the time of the export and the app and content versions.
> - Four CSV files for spreadsheets: `lockglow-ilerleme-…csv` (progress), `lockglow-bildigin-kelimeler-…csv` (known words), `lockglow-kendi-kelimeler-…csv` (own words), `lockglow-olcumler-…csv` (metrics).
>
> The files are unencrypted, readable text. Once you share a file, that copy is outside the app's control: the terms and privacy policy of the service you chose (for example your email provider or iCloud Drive) apply, and we cannot delete it. Send it only to places you trust. The copies in the app's temporary folder are removed when you leave the "Verilerin" screen, at the next export and by "Hepsini sil"; iOS also clears that folder from time to time.
>
> **Import ("İçe aktar").** You pick a backup file with the iPhone file picker. The app reads it on the phone, checks it, shows a summary and merges it with your current data only after you confirm; nothing on the phone is deleted. If a word is on both sides, the record with more answers is kept; your own words with the same English word are matched; your own words get new numbers when theirs are already taken on the phone. The review log comes along with the records that are kept. Local metrics, settings and recent searches are not imported. No data leaves your phone in this step; but if iCloud sync is on, the imported progress and words go to your iCloud account and other devices at the next sync.
>
> **Erase everything ("Hepsini sil").** This is separate from "İlerlemeyi sıfırla" (reset progress), which clears progress, the review log, local metrics, recent searches and feed history but keeps your own words and settings. After a plain Turkish confirmation, "Hepsini sil" first turns iCloud sync off and then deletes every file the app keeps on the device: progress and its daily backup, damaged copies set aside, your own words and their backup, the review log, local metrics, the sync state, caches and temporary files (including the app's copies of earlier exports); the files shared with the widgets (widget plan, widget state, pending widget taps); every app setting (including voice and accent); and the app's pending and delivered reminders. The app then opens like a new install. This cannot be undone; you may want to share a backup file first.
>
> "Hepsini sil" does not delete: **the iCloud sync copy** (delete it with "iCloud'daki kopyayı sil" on the iCloud sync screen; Section 3.11); copies inside earlier iCloud or computer backups of your iPhone (restoring one of those may bring old data back; you manage them in your Apple settings); files you exported and shared before; iOS permissions (microphone, speech recognition, notifications: change them in iPhone Settings); Apple's downloaded speech model (a system file managed by iOS).

> **[ÖNERİ is5-veri, 2026-10-24]** New subsection **3.11 iCloud sync (optional, off by default)**. This was planned as a future feature; it is now in the code. In the current build the iCloud capability is not yet added, so the switch stays off and the screen says sync is not ready in this version. The text below is for the version in which it is turned on. **[TEYİT]**
>
> If you turn on **Settings > Progress > iCloud ile eşitle**, the following is stored as one copy in Apple's iCloud key-value storage **in your own iCloud account**, and reaches your other devices signed in to the same Apple account:
>
> - your progress on words (learning state, box, dates, answer, mistake and view counts, "Biliyorum" and saved marks),
> - the words you added (English word, Turkish meaning, example, note, dates), and for deleted own words a random identifier and the time of deletion,
> - the time you last used "İlerlemeyi sıfırla".
>
> Your settings, review log, local metrics, daily counts and recent searches are not synced.
>
> This copy is kept on Apple's servers, which may be outside Türkiye, under Apple's iCloud terms and privacy policy. We cannot see or read it; there is no developer dashboard or server **[TEYİT]**. To recognise the iCloud account sync was turned on with, your device keeps an opaque marker from iOS on the device only; if the account changes, sync stops by itself so your words do not go to someone else's iCloud.
>
> Sync is not a backup: what you delete or reset on one device goes on the others too. Turning sync off leaves the iCloud copy in place. You delete it with **"iCloud'daki kopyayı sil"** on the iCloud sync screen; if sync is on on another device, that device uploads its copy again, so turn it off there first. Deleting the app or "Hepsini sil" does not delete the iCloud copy. **[TEYİT: whether iCloud key-value data of a deleted app can be seen and deleted under iPhone Settings > [your name] > iCloud > Manage Storage; if not, tell users to use the in-app button before deleting the app.]**

## 4. Why we use data

- To run the app and widgets on your device,
- to verify your subscription, unlock Premium features, restore purchases and prevent fraud,
- to answer support requests and mistake reports,
- **only with your permission:** to understand which parts of the app work, improve onboarding and the paywall, and find crashes,
- to meet legal obligations and to defend our rights in a dispute.

We do not send marketing emails or remote push notifications. If that changes, we will ask you first.

## 5. Legal bases

| Activity | KVKK Art. 5 | GDPR Art. 6 |
|---|---|---|
| Subscription verification and Premium access | Art. 5/2-c (performance of a contract), Art. 5/2-f (legitimate interest: fraud prevention) | Art. 6(1)(b), Art. 6(1)(f) |
| Optional analytics | Art. 5/1 (explicit consent) | Art. 6(1)(a) (consent); in the EU, consent is also relied on for accessing information on your device **[TEYİT: ePrivacy rules]** |
| [Sentry] crash reports | Art. 5/1 (explicit consent) **[TEYİT: legitimate interest may be considered]** | Art. 6(1)(a) **[TEYİT]** |
| Support correspondence | Art. 5/2-c, Art. 5/2-f | Art. 6(1)(b), Art. 6(1)(f) |
| Legal obligations and defence of rights | Art. 5/2-ç, Art. 5/2-e | Art. 6(1)(c), Art. 6(1)(f) |

We do not process special categories of personal data.

## 6. Service providers and who receives data

| Provider | Purpose | Location | Required? |
|---|---|---|---|
| **Apple Inc.** | App Store, payments, StoreKit, optional iCloud backups. Independent controller for its own services | Worldwide | Needed to get the app from the App Store |
| **RevenueCat, Inc.** | Subscription and purchase verification, paywall | United States | **Required** (subscription feature) |
| **PostHog** | Usage statistics (EU cloud region) | Hosted in the EU (Germany); the company is US-based **[TEYİT]** | **Optional** (consent only) |
| **Sentry (Functional Software, Inc.)** | Crash reports | [US / EU region **TEYİT**] | **Optional** (consent only; if used) |
| [EMAIL PROVIDER] | Support correspondence | [COUNTRY] | — |

These providers process data only on our instructions and under a written contract / data processing addendum **[TEYİT: confirm signed]**. We may disclose information to public authorities where the law requires it.

> **[ÖNERİ is5-veri, 2026-10-24]** Add below the table: "Services you send exported files to through the share sheet (for example Mail, AirDrop, Files, iCloud Drive, other apps) are not our service providers; you send the file to them and we never see it." Add to the Apple row: "optional iCloud sync (in your own iCloud account; Section 3.11)". **[TEYİT: whether Apple acts as the user's own provider / independent controller for this, or as our processor, given that we cannot access the copy.]**

## 7. International transfers

Some of the providers above are outside Türkiye (in the US and the EU), so your data is transferred abroad.

- **From Türkiye (KVKK Art. 9):** Transfers rely on one of the safeguards provided by KVKK (for example the Board's standard contract). When a standard contract is used, we notify the Turkish Personal Data Protection Authority within 5 business days of signing. **[TEYİT: which basis is used for which provider, whether each provider will sign, and whether the notification was made. Explicit consent alone may not be a safe basis for continuous transfers.]**
- **From the EU/EEA (GDPR Art. 44 ff.):** We use mechanisms such as standard contractual clauses or the provider's participation in the EU-US Data Privacy Framework **[TEYİT: current status per provider]**.

The data transferred is minimised: no name, email, location or advertising ID is sent.

> **[ÖNERİ is5-veri, 2026-10-24]** Add for iCloud sync: "**iCloud sync (optional):** If you turn it on, your progress and your own words go to Apple's servers, which may be outside Türkiye, to be kept in your iCloud account. We do not access that copy; Apple keeps it under its iCloud terms. If you do not turn it on, this transfer does not happen." **[TEYİT: whether data the user sends to their own iCloud account, which the developer cannot access, is a transfer abroad by us under KVKK Art. 9; if so, the legal basis (appropriate safeguards; explicit consent for incidental transfers) and whether turning on the switch can count as explicit consent.]** A user sending an exported file to a service abroad is not our transfer **[TEYİT]**.

## 8. How long we keep data

| Data | Retention |
|---|---|
| Data on your device | Until you delete the app |
| Subscription/purchase record (RevenueCat) | For the duration of the subscription relationship and afterwards for [TEYİT: statutory limitation period] years |
| Analytics records (PostHog) | Up to [12] months, or until you withdraw consent and request deletion **[TEYİT: retention will be configured in the tool]** |
| Crash reports ([Sentry]) | Up to [90] days **[TEYİT]** |
| Support correspondence | [2] years after the request is resolved **[TEYİT]** |

When the period ends, data is deleted, destroyed or anonymised.

> **[ÖNERİ is5-veri, 2026-10-24]** Split the "Data on your device" row:
>
> | Data | Retention |
> |---|---|
> | Learning data, your own words and settings on your device | Until you delete the app or use "Hepsini sil" (progress and review log also by "İlerlemeyi sıfırla") |
> | Review log | Same; when the file passes about 8 MB the oldest answers are removed |
> | Local metrics | Last 120 days |
> | Recent dictionary searches | Last 8 searches |
> | Temporary files prepared for export | Until you leave the "Verilerin" screen, the next export, "Hepsini sil" or iOS clears the temporary folder |
> | Files you exported and shared | Under your control; we cannot delete them |
> | iCloud sync copy | Until you use "iCloud'daki kopyayı sil" (deleting the app or turning sync off does not delete it) **[TEYİT]** |

## 9. Children

Lockglow is not directed to children under 13 and is not in the App Store's Kids category. We do not knowingly collect personal data from children under 13. If you think a child has given us data, write to [EMAIL] and we will delete it.

Analytics consent is optional. If your country sets a minimum age for giving consent to data processing (for example 16 in some EU countries) and you are under it, please give consent only with the approval of a parent or guardian **[TEYİT: age-threshold approach and how it appears in the in-app text]**.

## 10. Your rights and how to use them

**Under KVKK Art. 11** you can: learn whether your data is processed; request information about it; learn the purpose and whether it is used accordingly; learn the third parties it is transferred to in Türkiye or abroad; ask for correction of incomplete or wrong data; ask for deletion or destruction under KVKK Art. 7; ask that these actions be notified to recipients; object to a result against you based solely on automated analysis; and claim compensation if you suffer damage from unlawful processing.

**Under the GDPR (if you are in the EU/EEA)** you also have the rights of access (Art. 15), rectification (Art. 16), erasure (Art. 17), restriction (Art. 18), notification to recipients (Art. 19), data portability (Art. 20), objection (Art. 21), and not to be subject to decisions based solely on automated processing (Art. 22). You can withdraw consent at any time; withdrawal does not affect the lawfulness of processing before it.

### Inside the app

In **Settings > Privacy** you can:

- **Analytics preference:** turn it on or off. Turning it off stops analytics.
- **Delete my analytics data / reset my ID:** analytics stops, the ID on your device is deleted and a new one is generated. To have records tied to the old ID deleted from the server as well, send us the prepared deletion-request email. We complete the request within [30] days. **[TEYİT: this workflow will be built in the app; server-side deletion will be manual.]**
- Open links to the Notice, Consent Text, this policy and the Terms of Use.
- For on-device data: export your word lists (CSV) or delete the app to remove all on-device data.

> **[ÖNERİ is5-veri, 2026-10-24]** This bullet is wrong for the current code: there is no "word lists" feature, and export is not in Settings > Privacy but in **Settings > Progress > Verilerin**. Replace it with:
>
> In **Settings > Progress > Verilerin**, for the data on your device:
>
> - **Export:** get a copy of the data the app keeps about you on the device as a readable backup file (JSON) and spreadsheet files (CSV) (KVKK Art. 11(1)(a)–(b); GDPR Art. 15 access, Art. 20 portability).
> - **Import:** move a backup to another phone (GDPR Art. 20).
> - **Erase everything:** delete all the app's data on the device (KVKK Art. 7 and 11(1)(e); GDPR Art. 17). You can correct or delete your own words in the app (GDPR Art. 16).
> - **Delete the iCloud copy** (on the iCloud sync screen): delete the sync copy in your iCloud account.
>
> Because this data never reaches us, we hold no copy of it that we could hand over or delete on request; these tools let you do it yourself. **[TEYİT: to what extent KVKK Art. 11 and GDPR Arts. 15/17/20 bind us for data that stays on the user's device or in their own iCloud account; whether presenting these tools as "exercising your rights" could mislead; the assumption that JSON and CSV meet Art. 20's "structured, commonly used and machine-readable" test.]**

### By email

For other requests write to **[EMAIL]**. To let us find your analytics records, include the analytics ID shown in Settings > Privacy; without it we may be unable to verify that records are yours (GDPR Art. 11). We respond to requests within 30 days at the latest; if the action requires extra cost, the fee in the Turkish Board's tariff may be charged. **[TEYİT: accepted request methods, identity verification and a KEP address]**

### Complaints

Please contact us first. If you find our answer inadequate or receive none in time, you can complain to the Turkish **Personal Data Protection Board** (KVKK Art. 14). If you live in the EU/EEA, you can also contact your national data protection authority (GDPR Art. 77).

## 11. Security

Data minimisation is our first safeguard: most data never leaves your device. Data that is transferred travels over encrypted connections (HTTPS). We assess providers for their data protection commitments and limit access to those who need it. No system is perfectly secure; if a data breach occurs we will make the notifications that the law requires.

## 12. Changes

We may update this policy. For an important change (for example a new provider, a new type of data, or a new feature such as iCloud sync), we will tell you in the app and, if the new processing needs your permission, ask again. The current version is always available in the app and at [WEBSITE URL].

> **[ÖNERİ is5-veri, 2026-10-24]** The example "a new feature such as iCloud sync" is out of date: iCloud sync is in the code (Section 3.11). When it is switched on, this policy, the KVKK notice and the App Store label must be updated in the same release; a better example would be "an account or a feature that connects to a server".

## 13. Contact

[FULL NAME] · [EMAIL] · [ADDRESS]

---

*Last updated: [DATE] · Version: draft-2*

*Turkish version: gizlilik_politikasi_tr.md (the Turkish text prevails for users in Türkiye **[TEYİT]**)*
