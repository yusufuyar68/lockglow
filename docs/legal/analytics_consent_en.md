# Explicit Consent Text: Optional Analytics

**Lockglow Mobile App**

> **DRAFT:** Not lawyer-reviewed. Resolve every **[TEYİT]** item (to be confirmed by counsel) before use. This text is built on the approach of the Turkish Personal Data Protection Board's Principle Decision of 18.02.2026 (No. 2026/347): the information notice and the consent text are separate documents, and each declaration is collected separately. The full text of that decision has not yet been read; this draft relies on summaries **[TEYİT]**. Delete this box before publishing.

**Last updated:** [DATE] · **Version:** draft-1 · **Text version code (for the consent record):** consent-analytics-en-v1

---

## What you should know

- This consent is **optional.** If you say no, **no feature** of the app (free or paid) is restricted, and nothing extra is asked of you or charged.
- You can **withdraw consent at any time**, as easily as you gave it: **Settings > Privacy > Analytics preference.**
- General information about how we handle your personal data is in the **separate** Privacy Notice (KVKK "Aydınlatma Metni") and Privacy Policy.
- This screen is not a condition for using the app. If you do not consent, the analytics tool is never started.

## 1. Who is responsible

[FULL NAME] · [EMAIL] · [ADDRESS] **[TEYİT: public address]**

## 2. What you are consenting to

You are asked to consent to the processing of the data below for the stated purpose, and to its transfer to a service provider abroad.

### 2.1 Which data?

- **Random analytics ID:** Generated randomly on your device at the moment you consent. It is not linked to your name, email, phone number or advertising identifier (IDFA). It does not identify you directly, but it connects records coming from the same device (pseudonymous data).
- **Usage events:** Screens opened, onboarding steps, whether and how many widgets are installed, widget taps (such as "Next" or "I know it"), counts of learning actions, quiz completion, paywall views, experiment group.
- **Device and setting information:** App and iOS version, device model, language, App Store country, chosen level and goal, subscription state (none/trial/paid/expired).

**Not collected:** the content of your word lists, text you type in search, your name, email, location, contacts or advertising ID. Location is not derived from your IP address, and your IP address is not stored in analytics records **[TEYİT: to be verified by configuration and network traffic]**.

### 2.2 For what purpose?

To understand which parts of the app are used, where people get stuck and which changes help, and to improve onboarding, the paywall and the widget experience. The data is not used for advertising, profiling or sale to third parties, and we do not track you across apps.

### 2.3 Who receives it?

**PostHog** (analytics provider, data processor), EU cloud region. Data is hosted in the EU (Germany); the company is US-based **[TEYİT]**. For that reason your data is transferred outside Türkiye.

The transfer relies on an appropriate safeguard under KVKK Art. 9 (for example a standard contract), and a standard contract is notified to the Turkish Personal Data Protection Authority within 5 business days of signing. The consent in this text is requested as an **additional** basis for the transfer. **[TEYİT: whether a separate declaration (Declaration 2) is needed for the transfer, and whether explicit consent is a suitable basis for continuous transfers. If needed, use "Declaration 2" below.]**

### 2.4 How long is it kept?

Up to [12] months, or until you withdraw consent and ask for deletion **[TEYİT]**.

## 3. Withdrawing consent and deletion

- **Withdraw:** Turn off Settings > Privacy > Analytics preference. Analytics stops immediately.
- **Delete:** In the same screen, **"Delete my analytics data / reset my ID"** deletes the ID on your device and generates a new one. To have records tied to the old ID deleted from the server, send the email prepared by the app to [EMAIL]; we complete it within [30] days **[TEYİT: workflow]**.
- Withdrawal does not affect the lawfulness of processing before it.

## 4. Consequence of not consenting

None. All features of the app, including paid subscriptions, work in full without analytics consent. No paid feature is ever tied to this consent.

## 5. Declaration

> **Declaration 1: Processing of analytics data**
>
> I have **read and understood** the Privacy Notice. I give my explicit consent, **freely and on an informed basis**, to the processing of the data listed in 2.1 for the purpose in 2.2. I know I can withdraw this consent at any time.

> **[OPTIONAL — if counsel requires it] Declaration 2: Transfer abroad**
>
> I give my explicit consent, **freely and on an informed basis**, to the transfer of the data listed in 2.1 abroad to the service provider described in 2.3.

Consent is given only by tapping **"I agree"** on the in-app screen. No other action (closing the screen, continuing to use the app, staying silent) counts as consent. No option is pre-selected.

## 6. Record of consent

The burden of proving consent is on the controller. We therefore record the **date and time** you consented, the **text version code** and the **language**, as well as the date of any withdrawal (on the device, and as a single event sent at the moment of consent). This record contains no information that identifies you. **[TEYİT: where and in what form the record is kept; how the withdrawal event is delivered.]** If the text or the scope of processing changes materially (for example a new purpose or a new provider), consent is requested again under a new version.

## 7. Age

The app is not directed to children under 13. If your country sets a minimum age for consent to data processing and you are under it, consent should be given only with the approval of a parent or guardian. **[TEYİT: consent of minors in Türkiye and how the app handles it; GDPR Art. 8 age threshold.]**

## 8. Contact

[FULL NAME] · [EMAIL]

---

*Last updated: [DATE] · Version: draft-1*

*Turkish version: acik_riza_metni_analitik_tr.md*

---
---

# In-App Consent Screen: Exact Copy and Design Rules

This section is not shown to users; it is for the developer and designer. The Turkish copy uses the informal "sen" form of the app's onboarding; the English copy mirrors it.

## Screen copy (EN)

**Title:** Help us improve the app?

**Body:**
If you allow it, we measure which screens you use and which features work, using a random ID; we don't collect your name, email or word lists. This data is sent to an analytics service abroad (in the EU region). Your choice doesn't affect any feature of the app, and you can change it anytime in Settings > Privacy.

**Links (small, below the body):** Notice · Consent Text

**Buttons (identical in size and style):**
`I agree` | `Not now`

## Screen copy (TR, for reference)

**Başlık:** Uygulamayı geliştirmemize yardım eder misin?
**Düğmeler:** `Kabul ediyorum` | `Şimdi değil`
(Full Turkish body text: see acik_riza_metni_analitik_tr.md.)

> Note: the word "anonymous" is deliberately not used. A random ID is pseudonymous, not anonymous; calling it "anonymous" would be misleading, and the word should also be avoided in App Store text, ads and in-app copy.

## Design and implementation rules

1. **Equal weight:** Both buttons have the same size, font weight, fill style (both filled or both outlined) and visual priority. "Not now" must not be small, faded or a text link. Do not colour "I agree" and grey out "Not now".
2. **Nothing pre-selected.** Closing, swiping away the screen or continuing to use the app is not consent.
3. **No analytics or crash-reporting SDK starts, or makes a network request, before the screen is answered.** Install SDKs in opted-out state and start them only after "I agree". The random ID is generated at that moment.
4. **The app works fully without consent** (Apple App Review Guideline 5.1.1(ii)): no feature, paid function, content or paywall flow depends on this choice. After "Not now" the app is not degraded or slowed and shows no extra warnings. Premium is never offered in exchange for consent, and no discount or reward is given for consenting.
5. **No nagging:** After "Not now" the screen is not shown again automatically. The user can turn it on later in Settings > Privacy. **[TEYİT: re-ask policy; re-asking when the text version changes.]**
6. **Easy withdrawal:** The Analytics preference switch and "Delete my analytics data / reset my ID" are on the same screen, at most 2 taps away. Turning the switch off puts the SDK in opt-out and no new events are sent.
7. **Placement:** Show the screen at the very start of onboarding (right after the welcome screen, before any onboarding events); otherwise the onboarding funnel cannot be measured. Funnel metrics will cover only consenting users and will be biased; interpret the KPI plan accordingly.
8. **Record:** At "I agree", store the date/time, text version code and language (see Section 6). Record withdrawals too.
9. **Links** open in the app (web view or Safari), and an offline copy should be available **[TEYİT]**.
10. **Accessibility:** VoiceOver, Dynamic Type and Reduce Motion are supported; the two buttons have equal reading order priority and clear labels.
11. **If Sentry is used:** crash reports need a separate declaration and a separate switch (Settings > Privacy > Crash reports, off by default). The button on this screen does not grant consent for crash reports; the two declarations are not bundled **[TEYİT]**.
12. **RevenueCat-to-analytics link:** RevenueCat's integration that forwards events to the analytics tool must not run without consent; purchase data of users who did not consent must not reach the analytics tool.
