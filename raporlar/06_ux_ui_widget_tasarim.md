# iOS Vocabulary Widget App: UX/UI Product Spec

Date: 2026-10-10. Working title: **[App]**. Target: iPhone first (iOS 17+ for interactive widgets, designed for the iOS 26 Liquid Glass look, with graceful fallback to iOS 17-18). iPad and Mac come via the same widget families.

Scope: screens, flows and visual design only. App Store metadata, reviews, competitors, tech architecture and growth are covered by other agents.

**How to read the citations.**
- `[R#]` points to the reference list in section 9.
- "VERIFY" marks facts I could not confirm from a primary source.
- Apple HIG facts were pulled from the HIG's public DocC JSON (`developer.apple.com/tutorials/data/design/human-interface-guidelines/*.json`), the same content as the HIG website.
- Competitor details come from third-party teardowns (ScreensDesign chapter indexes, store listings), not hands-on use. Treat them as reported.

---

## 0. Design thesis and what the competitors do

### 0.1 Six design pillars

1. **Widget-first, app-second.** The Home Screen, Lock Screen and StandBy are the primary surface. A user who never opens the app after setup must still make progress. Widget taps (reveal, "I know it", quiz answers) count toward streak and XP.
2. **A calm pager, not a slot machine.** The full-screen vertical feed has soft stops ("10 new words seen, review 3 tricky ones?"). No infinite-scroll guilt, no lives or hearts.
3. **Honest money.** Price, trial end date and cancellation are visible on the first screen. The close button is always there. The free tier has a fully working, refreshing widget.
4. **Local-first and instant.** All feed words are on-device. No spinners for local data, and no network call inside a widget.
5. **Native-language-first.** The UI and translations default to the device language. Turkish, Arabic (RTL) and German (long words) are launch-quality, not afterthoughts.
6. **Accessibility is a feature.** VoiceOver-first feed alternatives, Dynamic Type to AX5, a dyslexia-friendly font, Reduce Motion, no audio autoplay.

### 0.2 Reported competitor UX (what to learn from, what to avoid)

**Monkey Taps, "Vocabulary - Learn words daily"** [R22][R24]
- Onboarding is about 13 steps. In order: the OS tracking prompt first, a welcome screen with social proof, discovery source, age, gender, name, weekly goal, notification warm-up, the OS notification prompt, level, app icon style, theme, and voice/accent.
- After onboarding come a cross-sell bundle upsell, goal and topic chips, then the paywall (3-day trial, reminder toggle). A widget install prompt comes after the paywall.
- Main app: a full-bleed statue wallpaper "welcome" with swipe-up cue, a word card (word, phonetic, definition, example, save/share), a feed with synonyms and etymology, collections, quiz, and a long grouped settings screen.
- Store listing: 10,000+ words, level and topic selection, themes. It is free with in-app purchases and ads, with up to about 10 price points ($9.99 to $149.99 lifetime) [R24].
- A recent 1-star review says custom words and the saved-word collection were moved behind the paywall, and reports widget and save-button problems [R24].

**Word of the Day (vocab quiz app)** [R23]
- A roughly 18-step, about 1:45 quiz-style onboarding with three "reinforcement" interstitials, a roughly 12-second "building your plan" screen, and a vocab profile summary.
- A hard paywall follows immediately (7-day trial, annual plan). The tracking prompt is the very first screen.

**Widget Vocabulary: Learn Words (Orbit Studios)** [R25]
- Released 2026-06-24, v2.2.5. Offers A1-C2 adaptive levels, flashcards, 1,000+ quiz levels, and IELTS/TOEFL/GRE/SAT packs. It has photography for rarer words and multilingual packs.
- Weekly and yearly premium subscriptions. About 100k downloads and 4.6 stars from about 1.1K ratings.

**Gaps we exploit:**
- Paywall before any value, and tracking and demographics asked up front.
- Widgets that are read-only, with no interaction.
- Saved items gated after the fact.
- Widget install taught as static instruction.
- No widget-health feedback.
- No RTL, Turkish or German polish reported.

---

## 1. Information architecture and screen inventory

### 1.1 Navigation model

Five tabs on the iOS 26 floating Liquid Glass tab bar [R9]. Apple's guidance is five or fewer tabs, single-word labels, SF Symbols, no disabled tabs, and the bar kept visible. A dedicated Search tab sits at the trailing end.

```
[ Words ]  [ Practice ]  [ Library ]  [ Progress ]  [ Search ]
  feed        review/quiz   saved/collections   streak/stats    dictionary+library
                            /topics browser
Profile button (top-trailing on Progress and Library) -> Settings (sheet)
Widgets entry -> Settings > Widgets, plus a TipKit tip on Words until a widget is detected
```

- The feed tab may use `tabBarMinimizeBehavior(.onScrollDown)` so cards get full height. Users restore the bar by tapping a tab or scrolling back [R9]. VERIFY on device with a paging scroll view.
- On iOS 17-25, replace glass with `.ultraThinMaterial` capsules.
- Sheets for transient tasks (share, add to collection, filter, paywall). Push for drill-down (collection, topic, word detail). Full-screen cover only for onboarding, quiz sessions and the paywall.
- Deep-link routes, shared by widgets, notifications, Controls and share links:
  - `/word/{id}`
  - `/review`
  - `/quiz/{type}`
  - `/collection/{id}`
  - `/widget-guide?kind=`
  - `/paywall?src=`

### 1.2 Global state patterns (apply to every screen)

| State | Treatment |
|---|---|
| Loading | Local data: no spinner. Remote or large data: skeleton after 300 ms. Skeleton shimmer becomes a static tint under Reduce Motion. |
| Empty | Illustration, one sentence, one primary action, one secondary link. Never a blank screen. Tabs are never disabled when empty; explain why instead [R9]. |
| Error | Non-modal inline banner with Retry. Network errors never block local content. Alerts are only for blocking states. Do not use notifications for errors [R10]. |
| Offline | Small "Offline: downloaded words still work" pill. No blocking. |
| Locked-premium | (a) Item shows a "Premium" pill with `lock.fill` plus text, never color alone. (b) Preview first: 3-5 free sample words or a first round free. (c) Tap opens a contextual sheet (paywall M2) with an equal-weight "Maybe later". Never lock or blur content the user already created. |
| Permission denied | Inline card, "Open Settings" button, and a note on what still works. |
| Reduce Motion / Reduce Transparency / Increase Contrast | Every state must have a defined alternative (section 5.5). |

### 1.3 Screen inventory

Legend for states: L = loading, E = empty, X = error/offline, P = locked-premium.

**A. Onboarding (O1-O17, detailed in section 3)**

| ID | Screen | Key components | States |
|---|---|---|---|
| O1 | Native language | list, search, auto-preselect | L: n/a |
| O2 | Welcome | looping demo, CTA | n/a |
| O3-O8 | Goal, level, calibration, topics, pace, times | single-question screens, chips, cards | skip states |
| O9 | Notification primer + OS prompt | benefit copy, preview notification | denied path |
| O10-O11 | Plan summary, commitment | summary card, press-and-hold | n/a |
| O12 | First-word tutorial | real feed with coach marks | n/a |
| O13 | Pick your look | theme carousel + live widget preview | P: premium themes previewable |
| O14-O15 | Widget guides | animated guide, detection | installed / not installed / skipped |
| O16 | Paywall | see 2.9 | L, X, P |
| O17 | All set | CTA | n/a |

**B. Words (feed)**

| ID | Screen | Purpose | Key components | States |
|---|---|---|---|---|
| F1 | Word Feed | Daily learning loop | full-screen vertical pager, card (2.2), action rail, top bar (deck chip, daily ring, streak) | L: skeleton; E: "all caught up"; X: audio/translation error; P: deck chip shows locked decks |
| F2 | Word Detail | Depth on demand | senses, synonyms/antonyms, collocations, word family, etymology, usage notes, false friends, personal note, report | L, X, P (optional sections) |
| F3 | Deck/Filter sheet | Choose what the feed shows | "For you" mix, level, topic, saved, review-due, collections | P badges |
| F4 | Batch complete card | Soft stop | "10 words seen" summary, CTAs: Review tricky / Keep going / Done | n/a |
| F5 | Share composer | Create share image | template carousel, theme switch, destination row | L: render; X: Instagram not installed fallback; P: premium templates/watermark off |
| F6 | Add to collection sheet | Save into collection | list, "New collection" row | E: no collections |
| F7 | Report/edit sheet | Fix wrong data | reason chips, note | X |

**C. Practice**

| ID | Screen | Key components | States |
|---|---|---|---|
| P1 | Practice hub | Daily Review card (due count), quiz type grid, "Recent mistakes" | E: "Nothing due, nice"; P: locked quiz types |
| P2 | Quiz setup | source (due / saved / collection / topic), length 5/10/20, timer toggle | E: fewer than 4 words (pad with distractors from deck) |
| P3-P10 | Question screens (8 types, 2.3) | prompt, options, skip | X: audio fail |
| P11 | Answer feedback (in-place state) | correct/incorrect, explanation, Continue | n/a |
| P12 | Results | score, words to review, XP/streak, share | n/a |

**D. Library**

| ID | Screen | Key components | States |
|---|---|---|---|
| L1 | Library hub | segmented: Saved / Collections / Topics / Mastered / My Words | E per segment |
| L2 | Saved list | rows with swipe actions, sort, multi-select | E |
| L3-L5 | Collections list, detail, create/edit | color/emoji, reorder, share read-only link | E |
| L6 | Add custom word | word, definition (optional auto-fill), example, translation | X: lookup fails, manual entry |
| L7 | Mastered | list, "Restore to learning" | E |
| L8 | Topics browser | grouped carousels, search, filters | L, X, P |
| L9 | Topic/pack detail | cover, count, % learned, preview 10 words, "Add to feed" | P |
| L10 | Share-extension UI ("Save word") | selected text, lookup result, collection picker | X |

**E. Search**

| ID | Screen | Key components | States |
|---|---|---|---|
| S1 | Search | recents, suggestions, results (library + dictionary) | E: "No match. Add it as a custom word"; X: offline dictionary subset |

**F. Progress**

| ID | Screen | Key components | States |
|---|---|---|---|
| R1 | Progress home | streak hero, goal ring, mastery bar, weekly chart, level progress | E: ghost chart "Your first day starts now" |
| R2 | Streak detail | month heatmap, freezes, rest days | n/a |
| R3 | Mastery breakdown | New / Learning / Reviewing / Mastered lists | E |
| R4 | Achievements | few, meaningful milestones | E |
| R5 | Weekly recap | auto-generated card, share | n/a |
| R6 | Year in Words (December) | shareable recap | n/a |

**G. Settings (T1-T14)**

| ID | Screen |
|---|---|
| T1 | Settings home |
| T2 | Level and content |
| T3 | Topics |
| T4 | Daily goal |
| T5 | Reminders |
| T6 | Appearance (theme, font, size, haptics, sounds) |
| T7 | Language (UI + native language for translations) |
| T8 | Voice and audio |
| T9 | Widgets (gallery and health) |
| T10 | Subscription |
| T11 | Account and data |
| T12 | Accessibility |
| T13 | Help and feedback |
| T14 | About and legal |

**H. Widgets**

| ID | Screen |
|---|---|
| W1 | Widget gallery and setup guide |
| W2 | Widget health |
| W3 | Lock Screen and StandBy guide |
| W4 | Control Center and Action button guide |

**I. Monetization**

| ID | Screen |
|---|---|
| M1 | Paywall (onboarding) |
| M2 | Contextual lock sheet |
| M3 | Win-back offer |
| M4 | Purchase success |
| M5 | Restore result |

**J. System**

| ID | Screen |
|---|---|
| Z1 | Launch screen (static, no ATT prompt) |
| Z2 | What's New sheet |
| Z3 | Permission-denied recovery cards |
| Z4 | Forced-update/maintenance |

---

## 2. Main experience

### 2.1 Vertical full-screen swipe feed (F1)

**Behavior**
- Full-screen vertical pager (`ScrollView` + `.scrollTargetBehavior(.paging)`, or a UIKit collection view). Swipe up for the next word, down for the previous.
- Prefetch the next 3 cards plus audio headers. Audio is local and short.
- Queue mix: about 70% new and 30% review (SRS due), adjustable in Settings. The first session starts with one known-level warm-up word.
- Gestures:
  - Vertical swipe: navigate.
  - Double-tap: save. Heart burst is static under Reduce Motion.
  - Single tap on the lower half: reveal or flip the secondary info when Active Recall mode is on.
  - Horizontal swipe right: "I know this", **off by default**, enabled in Settings > Gestures, always with an Undo toast (5 s). Every gesture has an on-screen button alternative [R4: use the simplest gesture; provide onscreen alternatives].
- Daily goal ring in the top bar. When the goal is reached, show F4 once. After 20 new words in a session, show a soft stop: "That's a lot of words. Review the tricky ones?" The user can always continue.
- Interstitials (promo cards) are **banned for the first 7 days**. After that, at most 1 per 30 cards, labeled "Suggested pack", dismissible, and never blocking the swipe.
- Edge cases:
  - **Reached the end of a deck:** "You've seen every word in this deck" with Switch deck / Start review / Add topics.
  - **Single-word deck:** pager bounce only, no loop.
  - **Orientation:** portrait only for the feed. iPad uses a centered 620 pt-max column.

**Top bar** (overlay, content-safe):
- Deck chip (`All my topics v`) opens F3.
- "3/5" ring.
- Streak flame number (SF Symbol `flame.fill` plus number).
- Controls use Liquid Glass (they are the control layer). Cards do not (Apple: keep glass out of the content layer) [R7].

### 2.2 Word card anatomy

Safe area respected. Card content sits on a solid theme surface (content layer). Controls float above on glass.

```
+--------------------------------------------------+
| [ All my topics v ]        ( 3/5 )   flame 12    |  top bar: glass controls
|                                                  |
|                                              (heart)  Save        <- action rail
|        ADJECTIVE · B2 · formal                (check)  I know this    (trailing side,
|                                               (share)  Share          handedness
|   re·sil·ient                                 ( ... )  More           setting)
|   /rɪˈzɪl.i.ənt/   (speaker US)  (speaker UK) |
|                                                  |
|   Able to recover quickly after difficulty.      |  definition
|   [ Easier ]                                     |
|                                                  |
|   "She is remarkably resilient."  (play)         |  example, word highlighted
|                                                  |
|   TR  dayanıklı, esnek, çabuk toparlanan         |  translation chip (native lang)
|                                                  |
|   synonyms:  tough   adaptable   hardy           |
|                                                  |
|        swipe up  ^   (first 3 sessions only)     |
+--------------------------------------------------+
```

| Element | Spec | Notes |
|---|---|---|
| Headword | New York Bold, 44 pt (relative to `.largeTitle`), autoshrink to 0.6 then wrap; never hyphenated | Syllable dots in `text.tertiary`. At AX sizes the card content scrolls inside the page (no truncation in scrollable regions) [R3]. |
| IPA | SF Pro 17, `text.secondary`, LTR forced | **Hidden from VoiceOver** (IPA reads as noise). The audio button carries the pronunciation. |
| POS / level / register chips | Footnote 13 Semibold, capsule, 28 pt tall, 44 pt tap area | Tap a chip to filter the feed by that attribute. |
| Audio | 56 pt circular button, plus accent chip (US/UK/AU) and speed toggle (1x / 0.7x) | Never autoplays by default; opt-in "Auto-pronounce" setting. Respects the silent switch only for UI sounds, not for user-tapped pronunciation. |
| Definition | Title 3 (20) Regular | **"Easier" toggle** swaps to a CEFR-A2-level definition. "Define in [native language]" toggle optional. |
| Example | New York Italic 18, headword in `accent` + semibold | Tap-to-speak the full sentence. |
| Translation | Chip, Callout 16, with language code | Can be hidden until tapped (Active Recall). |
| Synonyms | Max 3 chips | Tap pushes F2 for that word. |
| Action rail | Heart, check, share, more. 48 pt glass buttons, 12 pt gaps | Handedness setting: leading or trailing. |
| "I know this" | Button + optional gesture | Moves the word to Mastered (reversible). Counts toward auto-level calibration (after 10 "knows", suggest a level up). |
| "More" menu | Add to collection, Report, Copy, Notes, Hide this word | Hide-word list in Settings. |

**Card states**

| State | Behavior |
|---|---|
| Loading | Only when the very first card is not yet rendered. Skeleton words. |
| Empty | "All caught up" (see 2.1). |
| Error (audio) | Toast: "Couldn't play audio. Check your volume or Silent mode." with Retry. |
| Error (translation missing) | Chip shows "Translation coming soon. Report?" |
| Locked-premium | Locked decks are visible in F3. A locked word is never shown as a blurred card. A "Premium" word detail section shows a lock pill and a preview. |

### 2.3 Practice and quizzes

Eight question types. Each shows a persistent "Skip / I don't know" with no penalty, and there are no lives.

1. **Meaning match** (word to definition, and reverse).
2. **Listen and choose** (audio to word or spelling). Always provides a visual replay.
3. **Fill the blank** (cloze). Choose or type.
4. **Type it** (prompt: definition or translation; input normalized, including Turkish ı/İ folding, section 7).
5. **Flashcards** (flip, then self-grade: Again / Hard / Good / Easy). This is the SRS engine entry point.
6. **Match pairs** (6 pairs, optional timer).
7. **Odd one out / Synonym duel.**
8. **Speed round** (60 s true/false). Optional.
9. **Speak it** (pronunciation check). Microphone permission is requested just-in-time on first use, not in onboarding.

**Quiz screen anatomy**
- Top: close X (44 pt), segmented progress bar, optional timer. Not a heart count.
- Prompt card, solid surface.
- Options are full-width, 56 pt tall minimum, 12 pt spacing, with a label and an icon on feedback.
- Bottom sticky CTA ("Check" then "Continue").

**Feedback state (P11)**
- Correct: `checkmark.circle.fill`, text "Correct", success haptic [R6].
- Incorrect: `xmark.circle.fill`, text "Not quite, the answer is ...", warning haptic, one-line "why".
- Color is always paired with icon + text [R8][R4].

**Results (P12)**
- Score ring, "Words to review" list (tap to add to review), XP, streak update, share, "Practice mistakes".
- Empty states: no words due gives a friendly "Nothing due. Try a quick quiz on saved words"; fewer than 4 saved words pads distractors from the active deck.

### 2.4 Collections and favorites (Library)

- **Saved** is automatic (heart). Collections are user-made, with name, color and emoji. They can be reordered and shared as a read-only link.
- **Smart collections** (auto): Tricky (missed twice or more), Recently saved, Almost mastered.
- Row anatomy: word, POS, one-line gloss, mastery dots (4), trailing "..." menu. Swipe actions: Move, Remove, I know this.
- Sort by A-Z (locale collation, see section 7), date, or mastery. Search within the list.
- **Export (CSV and Anki-compatible) is free.** "Your data is yours" is a trust differentiator.
- Empty: "Tap the heart on any word to keep it here." plus a "Browse topics" button.
- Gating principle: never move already-created content behind a paywall (see anti-patterns, section 8).

### 2.5 Categories and topics browser (L8, L9)

- Sections: For you (from onboarding), By level (A1-C2), Exams (IELTS, TOEFL, YDS/YÖKDİL by region), Topics, Phrasal verbs and idioms, Roots and etymology.
- Topic card: cover art, name, word count, % learned ring, Free or Premium pill.
- Detail: cover, description, **10 preview words always visible**, "Add to my feed" toggle (multi-deck feed), "Start learning" CTA. Locked packs show the rest as rows with lock icons (not blurred) and the contextual paywall on tap.
- States: loading skeleton, offline shows only downloaded packs with a banner.

### 2.6 Progress and streak (R1-R6)

- Hero: streak number, a week row of 7 dots (checkmarks, with weekday letters; shapes differ from color), and the goal ring.
- **Streak rules designed to be forgiving:**
  - Counts any qualifying action: app session, widget reveal, widget "I know it", quiz answer.
  - One free **streak freeze earned every 7 days** (max 2), never sold.
  - "Rest days" can be chosen (for example Sundays).
- Mastery stacked bar (New / Learning / Reviewing / Mastered), a Swift Charts weekly words chart with audio-graph support, and level progress ("62% of B1 core words mastered").
- Achievements are few and meaningful (no badge spam).
- Empty (new user): ghost chart and "Your first day starts now."
- Share milestone creates a share card (section 6).

### 2.7 Settings (T1-T14)

Group order, top to bottom:
1. **Subscription** (status, manage, restore).
2. **Learning:** level (A1-C2 plus Auto-adjust toggle), topics, daily goal (3/5/10/20), new vs review mix, Active Recall mode, translation language, definition simplicity.
3. **Reminders:** up to 3 times, days, quiet hours, preview of the notification.
4. **Appearance:** theme gallery (free + premium), font (New York, SF Pro, SF Rounded, Atkinson Hyperlegible, OpenDyslexic), text size slider (respects Dynamic Type), haptics on/off, sounds on/off, action-rail side.
5. **Voice and audio:** accent (US/UK/AU), speed, auto-pronounce.
6. **Widgets:** gallery, health, Lock Screen guide, Control Center and Action button guide (W1-W4).
7. **Accessibility:** reduce motion override, high-contrast theme, VoiceOver tips, switch-friendly mode.
8. **Account and data:** optional Sign in with Apple, export, **delete account in-app (required if accounts exist)** [R19 5.1.1(v)], restore purchases.
9. **Help and feedback, About, Legal, Privacy.**

### 2.8 Widget gallery, setup guide and widget health (W1-W4)

**W1 Gallery and setup guide**
- Live in-app previews built from the same SwiftUI views as the widgets, grouped by location (Home Screen, Lock Screen, StandBy, iPad, Mac, Controls) and showing a Free or Premium badge.
- HIG warns against app elements that mimic widgets but don't behave like them [R1: best practice 10]. So previews carry a visible "Preview" caption and are not interactive; the only actions are "Add" and "How to add".
- Each preview opens an **animated step-by-step guide** (about 8 s looping clip, captioned, with a text transcript for accessibility [R4: captions, transcripts]).
- After the user returns to the app, detect the installed widget (`WidgetCenter.getCurrentConfigurations`) and confirm "Widget found. Nice."

**W2 Widget health** (fixes the "widget not refreshing" confusion)
- Rows (each with a status icon and text, not color alone):
  - "Widgets found: 2 (Small, Lock Screen)."
  - "Last updated 14:02. Next word at 16:00."
  - "Background App Refresh: On/Off."
  - "Low Power Mode: On. Widgets may update less often."
  - "Notifications: On/Off."
- Button: "Refresh widgets now". Apple says reloads triggered while the containing app is in the foreground don't count against the widget budget [R13].
- Copy explains in plain language: "Widgets update on a schedule set by iOS. Tapping Next on a widget updates it instantly."

**W3 / W4 Lock Screen, StandBy, Controls guides**
- Lock Screen steps: touch and hold the Lock Screen, tap Customize, tap the area below the clock.
- StandBy: turn the iPhone sideways while charging.
- Controls (iOS 18+): "Next word" and "Start 5-word review" in Control Center, plus Action button hint text, which Apple recommends using verbs ("Hold for Quiz") [R12].

### 2.9 Paywall variants

Shared rules (all variants):
- Close button visible immediately (44 pt, top-trailing). No delayed X.
- Price, billing period, trial length and **the exact trial end date** shown in readable text, above or next to the primary CTA.
- Prices come from StoreKit `displayPrice`. Never show a CTA before prices load.
- Footer: Restore Purchases, Terms, Privacy, Manage Subscription.
- No countdown timers, no pre-toggled trial switches that change price, no confirmshaming.
- App Review requires clear description of what the user gets before asking them to subscribe (3.1.2(c)), and that subscribers get what they paid for without extra tasks (3.1.2(a)) [R19].

**M1 Soft paywall in onboarding (default)**

```
+--------------------------------------------+
|                                        (X) |
|        [theme + widget montage]            |
|   Unlock everything. Try it free 7 days.   |
|                                            |
|   [check] All themes and fonts             |
|   [check] Interactive quiz widgets         |
|   [check] Custom decks, unlimited          |
|   [check] Exam packs: IELTS, TOEFL, YDS    |
|                                            |
|   ( ) Monthly      $x.xx / month           |
|   (o) Yearly       $xx.xx / year           |
|       about $x.xx a month   BEST VALUE     |
|                                            |
|   Today: everything unlocks                |
|   Oct 15: we remind you                    |
|   Oct 17: billing starts unless you cancel |
|                                            |
|  [      Start 7-day free trial        ]    |
|   Cancel anytime in Settings.              |
|        Not now                             |
|  Restore  ·  Terms  ·  Privacy            |
+--------------------------------------------+
```

**M1b Trial-timeline variant:** a vertical timeline (Today / Day 5 / Day 7) with a "Remind me before it ends" toggle. The reminder is a real local notification (if notifications are denied, offer an Add-to-Calendar reminder instead).

**M2 Contextual lock sheet** (half-height sheet)
- Shown when the user taps a locked item (theme, topic pack, quiz type). It shows a live preview of what they tried, one benefit line, and two equal-weight buttons: "Try free for 7 days" and "Keep [free option]".

**M3 Win-back** (once, for lapsed subscribers)
- Dismissible, shown on a calm screen, never during a quiz.

**M4 Success / M5 Restore result**
- Success confirms what unlocked and when the trial ends. Restore states: restored, nothing to restore, couldn't reach the App Store with Retry.

**Hard paywall (not recommended)**
- If the business insists on an A/B test, it must still show full price and trial terms and a restore link, and it must not run before the user sees the first word. I recommend against shipping it as default.

**Paywall states**

| State | Behavior |
|---|---|
| Loading prices | Skeleton plan cards, CTA disabled and labeled "Loading prices". |
| Error | "Can't reach the App Store" with Retry and Restore. |
| Already subscribed | Replace with "You're Premium" and manage link. |
| Purchase pending (Ask to Buy) | Friendly pending state, app remains usable. |
| User cancelled | Return to the paywall with no nagging. |
| Billing retry or grace | Settings banner "Update payment method", never blocking. |

**Placement.** See section 3 (step 16, after the widget guide). A/B variant B places the paywall before the widget guide (competitor-style). Measure D7 retention and revenue, not just conversion.

---

## 3. Onboarding flow (17 steps, about 90-100 s)

**Principles** [R2]
- Onboarding should be fast, fun and optional where possible, and occur after launch completes.
- Teach through interactivity.
- Postpone nonessential setup.
- Request permission in context, after explaining why.
- Let people experience the app before prompting for ratings or purchases.

**Deliberately removed vs competitors:**
- App Tracking Transparency prompt at launch (we don't track).
- Age, gender, name (Turkish name suffixes also break copy).
- "How did you hear about us" (moved to an optional day-2 survey).
- Fake "analyzing your answers" waits.
- Bundle upsell.
- Account creation.

**Progress UI:** thin progress bar plus step count at the top, back button always, "Skip" where marked. State persists, so a user who leaves mid-onboarding to add a widget resumes on the next step.

Notation: **EN** and **TR** give the exact suggested copy. `[App]` is the app name.

### O1. Native language (personalization: translation and UI language)
- EN: **"What's your native language?"** / "We'll show meanings and translations in it." / CTA "Continue"
- TR: **"Ana dilin nedir?"** / "Anlamları ve çevirileri bu dilde göstereceğiz." / CTA "Devam"
- Preselect the device language. List includes search and "More languages".

### O2. Welcome (value proposition)
- EN: **"A new word every time you look at your phone."** / "Widgets, quick swipes and tiny quizzes. About 2 minutes a day." / CTA "Get started". Footnote: "No account needed."
- TR: **"Telefonuna her baktığında yeni bir kelime."** / "Widget'lar, hızlı kaydırmalar ve mini testler. Günde yaklaşık 2 dakika." / CTA "Başla". Footnote: "Hesap gerekmez."
- Visual: looping demo of a card swiping up, and a widget on a wallpaper. Respects Reduce Motion with a static image. Small "Restore purchases" text link for reinstalls.

### O3. Why are you learning? (personalization, multi-select)
- EN: **"Why do you want to learn words?"** / "Pick all that apply."
  - Options: Exam prep (IELTS, TOEFL, YDS) / Career and work / Travel / Studying abroad / Movies, series and books / Just curious.
- TR: **"Neden kelime öğrenmek istiyorsun?"** / "Uygun olanların hepsini seç."
  - Options: Sınav hazırlığı (IELTS, TOEFL, YDS) / Kariyer ve iş / Seyahat / Yurt dışında eğitim / Film, dizi ve kitaplar / Sadece merak.
- Exam options are localized per region (Turkey: YDS, YÖKDİL).

### O4. Your level (personalization; maps internally to CEFR A1-C2)
- EN: **"How would you describe your English?"**
  - Beginner: "I know everyday words (house, travel)."
  - Intermediate: "I read easy articles (reluctant, thrive)."
  - Advanced: "I read novels and news (ephemeral, ubiquitous)."
  - Link: "Not sure? Take the 30-second check."
- TR: **"İngilizcen nasıl?"**
  - Başlangıç: "Günlük kelimeleri biliyorum (house, travel)."
  - Orta: "Basit makaleleri okuyorum (reluctant, thrive)."
  - İleri: "Roman ve haber okuyorum (ephemeral, ubiquitous)."
  - Link: "Emin değil misin? 30 saniyelik kısa testi çöz."

### O5. Quick calibration (optional, interactive)
- EN: **"Swipe: do you know this word?"** / Right = "I know it", Left = "Not yet" (also buttons). 8 cards.
- Result: "Looks like you're around B1-B2. We'll fine-tune as you go." / Skip: "Skip".
- TR: **"Kaydır: Bu kelimeyi biliyor musun?"** / Sağ = "Biliyorum", Sol = "Henüz değil". Sonuç: "Seviyen yaklaşık B1-B2 görünüyor. İlerledikçe ayarlarız." / "Atla".
- Purpose: teaches the "know it" mechanic by doing, and replaces demographic questions with something useful.

### O6. Topics (personalization, multi-select, minimum 3)
- EN: **"What do you want to read about?"** / "Pick at least 3. Change anytime."
  - Everyday life, Business, Science, Technology, Emotions, Nature, Health, Law, Art and culture, Food, Idioms, Phrasal verbs, Slang.
- TR: **"Hangi konular ilgini çekiyor?"** / "En az 3 tane seç. İstediğin zaman değiştirebilirsin."
  - Günlük hayat, İş dünyası, Bilim, Teknoloji, Duygular, Doğa, Sağlık, Hukuk, Sanat ve kültür, Yeme içme, Deyimler, Phrasal verb'ler, Argo.

### O7. Daily pace (commitment)
- EN: **"How many new words a day?"**
  - 3 · Light, about 1 min
  - 5 · Steady, about 2 min (recommended)
  - 10 · Serious, about 4 min
  - 20 · Intense, about 8 min
  - Note: "Widgets and reviews are extra. You can change this anytime."
- TR: **"Günde kaç yeni kelime?"**
  - 3 · Hafif, yaklaşık 1 dk
  - 5 · Dengeli, yaklaşık 2 dk (önerilen)
  - 10 · Ciddi, yaklaşık 4 dk
  - 20 · Yoğun, yaklaşık 8 dk
  - Not: "Widget'lar ve tekrarlar bunun dışında. İstediğin zaman değiştirebilirsin."

### O8. Reminder times (commitment and permission priming)
- EN: **"When should we remind you?"** / "Pick up to 3 times. Tie them to moments you already have."
  - Presets: Morning coffee 8:00 / Lunch 12:30 / Commute home 18:00 / Before bed 21:30 / Custom.
  - Live notification preview: "Word of the day: ephemeral · lasting a very short time."
- TR: **"Sana ne zaman hatırlatalım?"** / "En fazla 3 saat seç. Zaten yaşadığın anlara bağla."
  - Presets: Sabah kahvesi 08:00 / Öğle arası 12:30 / Eve dönüş 18:00 / Uyumadan önce 21:30 / Özel.
  - Önizleme: "Günün kelimesi: ephemeral · çok kısa süren."

### O9. Notification primer, then the OS prompt (permission priming)
- EN: **"Allow notifications so you don't miss a word."** / "1-3 gentle reminders a day, at the times you picked. Never spam. Widgets work either way." / CTA "Allow notifications" / secondary "Not now" (same size, no shame).
- Denied path: "No problem. Your widgets will keep you going. You can turn reminders on in Settings later."
- TR: **"Kelimeni kaçırmamak için bildirimlere izin ver."** / "Seçtiğin saatlerde günde 1-3 nazik hatırlatma. Asla spam yok. Widget'lar bildirim olmadan da çalışır." / "Bildirimlere izin ver" / "Şimdi değil".
- Denied: "Sorun değil. Widget'ların seni devam ettirir. Hatırlatmaları sonra Ayarlar'dan açabilirsin."
- Rationale: Apple says request permission after explaining why [R2]; notifications must not be required for the app to function [R19 4.5.4]. Optional "Quiet delivery" (provisional authorization) is offered if the user taps "Not now" once.

### O10. Your plan (commitment recap, real, under 1.2 s, no fake loading)
- EN: **"Your plan is ready."** / Level: Intermediate (B1-B2) · 5 new words a day · Topics: Business, Emotions, Idioms · Reminders: 8:00, 18:00 / CTA "Looks good" / link "Edit" / footnote "We'll adjust as you learn."
- TR: **"Planın hazır."** / Seviye: Orta (B1-B2) · Günde 5 yeni kelime · Konular: İş dünyası, Duygular, Deyimler · Hatırlatmalar: 08:00, 18:00 / "Harika görünüyor" / "Düzenle" / "Öğrendikçe sana göre ayarlarız."
- No invented projections ("B2 in 3 months") because they can't be backed up.

### O11. Make a small promise (commitment device)
- EN: **"Make a small promise."** / "Open a word, even for 30 seconds, every day for..." [3 days] [7 days] [30 days] / "Hold to commit." / note "Widget taps count too."
- TR: **"Küçük bir söz ver."** / "Her gün, 30 saniye bile olsa bir kelimeye bak..." [3 gün] [7 gün] [30 gün] / "Söz vermek için basılı tut." / "Widget'ta yaptığın dokunuşlar da sayılır."
- Haptic: hold ramps with a Core Haptics continuous pattern, then a success notification haptic [R6]. Accessibility alternative: a plain "Commit" button appears when VoiceOver or Switch Control is on (never long-press only).

### O12. Try it: your first words (interactive tutorial, teach by doing)
- Real feed with 3 cards from the user's level and topics. Coach marks (TipKit style, anchored near the control) [R2]:
  - EN: "Swipe up for the next word" / "Tap the speaker to hear it" / "Tap 'I know this' and it won't come back" / "Tap the heart to save it".
  - TR: "Yukarı kaydır, sıradaki kelime gelsin" / "Telaffuzu dinlemek için hoparlöre dokun" / "'Biliyorum'a dokun, bu kelime bir daha gelmesin" / "Kaydetmek için kalbe dokun".
- End line, EN: "Nice. That's the whole app." TR: "Harika. Uygulama bu kadar."

### O13. Pick your look (personalization, widget preview)
- EN: **"Make it yours."** / "Free themes are yours forever. Premium themes unlock later." Live widget preview updates as the user swipes themes. Premium themes have a lock pill and are previewable.
- TR: **"Seni yansıtsın."** / "Ücretsiz temalar sonsuza dek senin. Premium temalar sonra açılır."

### O14. Widget guide, Home Screen (widget install education)
- EN: **"Put your word on the Home Screen."**
  1. Touch and hold an empty spot on your Home Screen.
  2. Tap the + button (top left).
  3. Search for "[App]" and pick a size.
  4. Tap Add Widget, then Done.
  - Buttons: "I added it" / "Remind me later".
- TR: **"Kelimeni ana ekranına koy."**
  1. Ana ekranda boş bir yere dokunup basılı tut.
  2. Sol üstteki + düğmesine dokun.
  3. "[App]" ara ve bir boyut seç.
  4. Widget Ekle'ye, sonra Bitti'ye dokun.
  - Düğmeler: "Ekledim" / "Daha sonra hatırlat".
- A looping animated guide (Lottie or Rive, about 8 s, captioned) plays at the top. Respects Reduce Motion with a static step-by-step.
- On return, auto-detect the widget and celebrate: "Widget found. Your next word is on its way." / "Widget bulundu. Sıradaki kelimen yolda."
- Verify these UI strings against the current iOS release every year (VERIFY: iOS 26/27 wording; use Apple's own localized terms for Turkish).

### O15. Widget guide, Lock Screen and StandBy (optional)
- EN: **"Add it to your Lock Screen too."**
  1. Touch and hold your Lock Screen.
  2. Tap Customize, then Lock Screen.
  3. Tap the box under the clock and pick "[App]".
  - Bonus: "StandBy: turn your iPhone sideways while it charges."
- TR: **"Kilit ekranına da ekle."**
  1. Kilit ekranına basılı tut.
  2. Özelleştir'e, sonra Kilit Ekranı'na dokun.
  3. Saatin altındaki kutuya dokun ve "[App]" seç.
  - Bonus: "StandBy: şarjdayken iPhone'unu yan çevir." (VERIFY the Turkish StandBy name.)
- Skippable. Do not use app-name-plus-suffix constructions in Turkish (vowel harmony); keep the name in quotes.

### O16. Paywall
- See 2.9 M1. Copy (EN/TR):
  - Headline: "Unlock everything. Try it free for 7 days." / "Her şeyin kilidini aç. 7 gün ücretsiz dene."
  - Price line: "7 days free, then $39.99/year (about $3.33/month)." / "7 gün ücretsiz, sonra yıllık ₺[fiyat] (aylık yaklaşık ₺[fiyat])." Prices come from StoreKit.
  - Timeline: "Today: everything unlocks. Day 5: we remind you. Day 7: billing starts unless you cancel." / "Bugün: her şeyin kilidi açılır. 5. gün: sana hatırlatırız. 7. gün: iptal etmezsen ücretlendirilirsin."
  - Reassurance: "Cancel anytime in Settings. We'll remind you 2 days before your trial ends." / "İstediğin zaman Ayarlar'dan iptal edebilirsin. Deneme bitmeden 2 gün önce hatırlatırız."
  - Primary CTA: "Start free trial" / "Ücretsiz denemeyi başlat".
  - Secondary: "Not now" / "Şimdi değil" (not "No, I don't want to learn").
- Recommended placement: after the widget guide, so the user has already felt the value (swiped real words, saw the widget on their Home Screen). If the user leaves to install the widget and doesn't return, onboarding resumes at the paywall on next launch.
- A/B variant B: paywall before O14.

### O17. All set
- EN: **"You're all set."** / "Your first 5 words are waiting." / CTA "Start learning".
- TR: **"Hazırsın."** / "İlk 5 kelimen seni bekliyor." / "Öğrenmeye başla".
- Deferred asks (not onboarding): rating prompt after a positive moment (for example a 3-day streak), optional Sign in with Apple backup on day 3, and the "how did you find us" survey on day 2.

---

## 4. Widget design spec

### 4.1 Platform facts (cited)

**Sizes** (iPhone, points; the first and most common rows from the HIG table) [R1]

| Screen | Small | Medium | Large | Circular | Rectangular | Inline |
|---|---|---|---|---|---|---|
| 430x932 | 170x170 | 364x170 | 364x382 | 76x76 | 172x76 | 257x26 |
| 393x852, 390x844 | 158x158 | 338x158 | 338x354 | 72x72 | 160x72 | 234x26 |
| 375x812 | 155x155 | 329x155 | 329x345 | 72x72 | 157x72 | 225x26 |

- iPad extra large (1024x1366 device): 748x356 (canvas 795x378.5) [R1].
- visionOS: small 158x158, medium 338x158, large 338x354, extra large 450x338.
- Mac native widget point sizes: VERIFY (not in the HIG table I retrieved; design with flexible layouts).

**Margins and type**
- Standard margin 16 pt; tighter 11 pt for grouped graphics. Smaller margins on Mac desktop and Lock Screen/StandBy [R1].
- Minimum font size 11 pt. Avoid rasterizing text. Widgets support Dynamic Type from Large to AX5 [R1].
- Use the system font and text styles; a custom font works for large text with SF Pro for small text [R1][R3].

**Interactivity** [R14][R1]
- Tapping a widget opens the app. Buttons and Toggles run App Intents without launching.
- **Buttons and toggles are inactive on a locked device** until the person authenticates. Lock Screen widget buttons therefore need unlock first (VERIFY the exact UX on device).
- Inline accessory widgets offer only one tap target. Size targets so people can tap confidently (default 44x44 pt) [R1][R4].
- After `perform()` returns, the timeline reloads. Button and toggle interactions always guarantee a timeline reload.
- Intent-triggered reloads do not count against the refresh budget [R13]. So "Next word" is effectively free.
- Toggles update optimistically. For iPhone widgets running on a Mac, the round trip is slower; use `.invalidatableContent` on views awaiting new data [R14].
- Do not rethrow errors from `perform()`; show a stale or error state instead [R14].

**Refresh budget** [R13]
- Per-widget daily budget; frequently viewed widgets typically get **40-70 refreshes/day** (about one every 15-60 minutes). Timeline entries should be at least about 5 minutes apart.
- These reloads do **not** count: app in foreground, app intents, animations, locale change, Dynamic Type or Accessibility change. StandBy refreshes at a system-defined rate outside the budget.
- Policy: generate a full day of entries up front from the local queue (no network), use `atEnd`, and call `reloadTimelines` from the app only on real data changes (deck change, onboarding finished).

**Rendering modes** [R1][R16][R18]
- Full color (Light/Dark), Accented (tinted and clear on Home Screen), Vibrant (Lock Screen, StandBy low light).
- In accented mode the system removes the background, splits views into an accent group and a primary group, and fills with a tint or Liquid Glass. Content is first rendered white; partially transparent content keeps its opacity, which can hurt legibility [R18].
- Support matrix: `accessoryCircular` and `accessoryInline` support only Accented and Vibrant; `accessoryRectangular` supports all three [R16].
- **Backgrounds:** use `containerBackground(for: .widget)` so they are removable. Non-removable backgrounds exclude the widget from StandBy and iPad Lock Screen galleries [R15].
- StandBy and CarPlay: small widget scaled up, background removed, large glanceable text, no background color, low-light monochrome red tint [R1][R17].
- Always-On display: read `isLuminanceReduced` and use higher-contrast grays [R1][R16].

**Content rules from the HIG** [R1]
- Show dynamic information that changes through the day; keep the widget focused; offer multiple sizes only when they add value, and don't just stretch small content.
- If people check more often than you update, show when data was last updated.
- Use animated transitions (up to 2 s) to signal new information.
- Full-color images are for media content only, kept smaller than the widget.

### 4.2 Widget kinds and families

| Kind | Families | Purpose |
|---|---|---|
| **Word** | small, medium, large, XL (iPad), accessoryRectangular, accessoryInline | The core widget. Configurable (deck, theme, translation on/off, rotation interval). |
| **Quiz** | small, medium, large | Interactive recall. Home Screen only. |
| **Streak and Goal** | small, accessoryCircular, accessoryRectangular | Motivation. Pairs with Word in StandBy. |
| **Today's List** | large, XL | The day's 5 words at a glance. |

Per HIG, each family has distinct content instead of a stretched copy.

### 4.3 Typographic scale (widgets)

| Role | Small | Medium | Large | XL |
|---|---|---|---|---|
| Headword (New York Semibold) | 28-30 | 34 | 40 | 48 |
| IPA (SF Pro Regular) | 12 | 13 | 15 | 17 |
| POS/level (SF Pro Semibold) | 11-12 | 12 | 13 | 14 |
| Definition (SF Pro Regular) | 13 | 15 | 17 | 18 |
| Example (New York Italic) | - | 13 | 15 | 16 |
| Translation | 13 | 15 | 17 | 18 |
| Meta ("Next word 15:00") | - | - | 11 | 12 |

- Minimum 11 pt everywhere [R1].
- At accessibility Dynamic Type sizes, drop elements in this order: example, translation, IPA, POS, then definition to a single line. The word never drops.
- Use `ViewThatFits` and `minimumScaleFactor(0.7)` on the headword.

### 4.4 Per-family spec

**systemSmall** (158x158 to 170x170; content about 126x126)
- Priority: P1 word, P2 gloss (2 lines), P3 POS/IPA, P4 one button.
- Max one 44 pt hit-area button (trailing bottom). With a button present, drop IPA.
- Interactive options: "Next" (free), "Reveal" toggle in Reveal mode (the lower half is a big toggle labeled "Tap to reveal"), "I know it".
- Free: Word kind with default theme. Premium: Reveal mode, theme, per-widget deck.

```
+--------------------------+   158x158, 16pt margin
| adj · B2                 |   11-12pt, text.secondary
|                          |
| resilient                |   New York Semibold 30
|                          |
| able to recover quickly  |   13pt, 2 lines max
| after difficulties       |
|                   (Next) |   44pt hit area
+--------------------------+
```

**systemMedium** (338x158 to 364x170; content about 306x126)
- Left column: word, IPA, translation. Right column: definition and example.
- Bottom row: up to 3 buttons (Audio, Save, Know), 44 pt hit areas, plus "Next".
- Audio uses an AudioPlaybackIntent, which Apple says runs in the app process [R14]. VERIFY on device whether playback starts without foregrounding.

```
+------------------------------------------------------------+
| resilient        adj · B2   |  Able to recover quickly      |
| /rɪˈzɪl.i.ənt/              |  after difficulty.            |
|                             |                               |
| dayanıklı, esnek            |  "She is remarkably           |
|                             |   resilient."                 |
| (Audio) (Save) (Know)         (Next)                        |
+------------------------------------------------------------+
```

**systemLarge** (338x354 to 364x382; content about 306x322)
- Two variants:
  - Word detail: header (streak, "Word 3 of 5"), headword 40, IPA/POS, definition 17, example 15, translation, synonym chips, footer ("Next word at 15:00" plus buttons).
  - Today's List (see Kind table).
- Quiz Large: question card and 4 answer buttons at 44 pt each (176 pt plus header and spacing fits within 322 pt content height).

```
+------------------------------------------------------------+
| Word of the day · 3/5                          flame 12    |
|                                                            |
| resilient                                                  |
| /rɪˈzɪl.i.ənt/   adjective · B2                            |
|                                                            |
| Able to recover quickly after difficulty.                  |
|                                                            |
| "She is remarkably resilient."                             |
|                                                            |
| TR  dayanıklı, esnek, çabuk toparlanan                     |
|                                                            |
| tough   adaptable   hardy                                  |
|                                                            |
| Next word at 15:00      (Audio) (Save) (Know) (Next)       |
+------------------------------------------------------------+
```

**systemExtraLarge (iPad)** (748x356 device on iPad Pro 12.9"; flexible)
- Three columns: headword and IPA (40%), definition and example and translation (35%), "Today's 5" list (25%).
- Buttons in a footer row, 44 pt.
- iPad Lock Screen supports system small and accessory widgets, monochrome without tint [R1].

**accessoryRectangular** (160x72 to 172x76; Vibrant)
- Three lines: headword (headline 15 Semibold), IPA, one-line gloss (12). Use opaque grayscale (full-opacity white or light gray for prominent text, darker grays for secondary, not white with opacity) [R1].
- Buttons are inactive when locked; tap opens the word [R14]. Treat as read-only.

```
+-----------------------------+
| resilient            adj.   |   headline 15 semibold
| /rɪˈzɪl.i.ənt/              |   12pt
| able to recover quickly     |   12pt, tail truncation
+-----------------------------+
```

**accessoryCircular** (72x72 to 76x76)
- Gauge ring for today's goal; center number "3", with `/5` in 11 pt below. Premium: switch to streak count or due-review count.
- Use `AccessoryWidgetBackground` for a consistent look [R15].

```
    .-""-.
   /  3   \     ring = today's goal, center = words done
   \  /5  /
    '-..-'
```

**accessoryInline** (234x26 to 257x26; one line)
- `SF Symbol book.closed` + "resilient · bounce back". Roughly 26-30 characters.
- Single tap target; use `ViewThatFits` with fallback to headword only [R1].

**StandBy** (systemSmall scaled; two side by side)
- Pair "Word" with "Streak and Goal".
- No background color, large type, hierarchy through weight and size only (color is lost in low-light red tint) [R1][R17].
- Do not use photo themes. Mark the Quiz kind with `disfavoredLocations` for StandBy and CarPlay [R16].

**CarPlay**
- Only the small Word widget, glanceable, no quiz buttons.

**Mac (desktop and Notification Center)**
- iPhone widgets appear via Continuity. They render with iOS font metrics, and interactions round-trip to the iPhone [R16][R14].
- Native Mac widgets use macOS font sizing, so check sizes if sharing code [R16].
- v1: ship via Continuity. v2: native Mac target.

**Apple Watch (roadmap)**
- Smart Stack and complications use the accessory families.

### 4.5 Appearance modes (matrix)

| Mode | Behavior and design rule |
|---|---|
| Light | Theme `light` palette. Backgrounds in `containerBackground`. |
| Dark | Theme `dark` palette. Prefer dark backgrounds for dark mode [R1]. |
| Tinted (iOS 18+) | System removes background and tints. Mark the headword and primary button with `.widgetAccentable()`. Definition and example stay in the primary group. Do not rely on opacity for secondary text: raise opacity to 0.85-1.0 and use smaller weight steps. |
| Clear (iOS 26) | Glass background from the system. Raise weights one step (Regular to Medium) for text over glass. Remove gradients; swap images to `.widgetAccentedRenderingMode(.desaturated)` [R18]. |
| Vibrant (Lock Screen) | Opaque grayscale values. No thin weights. Provide a reduced-luminance variant using `isLuminanceReduced`. |
| StandBy night | Monochrome red tint by the system. Do not encode meaning in color. |

**Theme identity survives mode stripping.** Tinted and clear modes remove backgrounds, so premium identity must live in **type and layout**, not just backgrounds. That makes fonts a premium feature that still works in clear mode.

### 4.6 Premium vs free widgets

| Capability | Free | Premium |
|---|---|---|
| Word kind, all sizes, Lock Screen, StandBy | Yes (default deck, Paper/Ink/System themes) | Yes |
| Rotation interval | Daily, 4 h, 2 h, 1 h | Also 30 and 15 min |
| "Next word" button | Yes | Yes |
| Per-widget deck, level, translation toggle | Default deck only | Fully configurable (App Intent parameters) |
| Premium themes and fonts | No | Yes |
| Reveal mode, Quiz widget, audio button | Reveal: yes (basic) | Quiz and audio buttons |
| Today's List, XL layouts | Basic | Full |

**Never lock:** the widget refreshing, saving a word, or something the user already configured.
**If premium lapses:** widgets silently revert to free defaults (no "locked" overlays).

### 4.7 Configuration and App Intents

- AppIntentConfiguration parameters: Deck (AppEntity), Level override, Show translation, Theme, Rotation interval.
- Intents: `NextWordIntent`, `RevealIntent` (toggle), `SaveWordIntent` (toggle), `KnowWordIntent` (with "Undo" state), `AnswerQuizIntent(choice)`, `PlayAudioIntent` (AudioPlaybackIntent), plus `widgetURL`/`Link` deep links.
- Controls (iOS 18+): "Next word" and "Start 5-word review" with Action-button hint text using verbs [R12].

### 4.8 Widget states

| State | Behavior |
|---|---|
| Placeholder | Redacted shapes. |
| Snapshot/gallery | Real sample word. |
| First install, onboarding not finished | "Open [App] to pick your level" (deep link). |
| No data | Falls back to a bundled starter set. Never empty. |
| Stale / refresh delayed | Keep showing the word; show "Last updated" in large only. Do not hide stale data behind placeholders [R1]. |
| Goal done (Streak kind) | "Done for today". |
| Deleted deck | Falls back to default deck. |

---

## 5. Theming and design system

### 5.1 Color tokens (contrast checked, WCAG ratios computed)

Apple's contrast targets: 4.5:1 for text up to 17 pt, 3:1 at 18 pt and bold; check light, dark and Increase Contrast [R4][R8]. Prefer semantic system colors; avoid hard-coding values [R8].

| Token | Light | Dark | Contrast notes |
|---|---|---|---|
| `bg.canvas` | #FAF7F2 | #12110F | |
| `bg.surface` | #FFFFFF | #1C1B18 | |
| `bg.sunken` | #F1ECE3 | #0B0A09 | |
| `text.primary` | #1C1B19 | #F5F2EC | 16.1:1 / 16.9:1 on canvas |
| `text.secondary` | #5B574F | #B9B4A9 | 6.7:1 / 9.1:1 |
| `text.tertiary` | #6F6A60 | #948F84 | 5.0:1 / 5.9:1 |
| `accent` (indigo ink) | #3A3FD6 | #9DA1FF | 6.9:1 / 8.1:1 on canvas; white on accent 7.3:1 |
| `success` | #17794D | #4FD08A | 5.1:1 / 9.6:1 |
| `danger` | #C2381F | #FF7A62 | 5.1:1 / 7.4:1 |
| `warning` | #9A5700 | #F5B83D | 5.3:1 / 10.6:1 |
| `streak` (flame, graphic only) | #E8590C | #F5B83D | 3.35:1 (graphics threshold 3:1) |

Rules:
- Provide an Increase Contrast variant for each custom color [R8].
- Color is never the only signal (icon plus text) [R8][R4].
- Liquid Glass has no inherent color. Apply color sparingly, to primary actions, as a background rather than on symbols and text [R8].

### 5.2 Typography

| Role | Font | Size (Large) | Notes |
|---|---|---|---|
| Headword | New York (serif, `Font.Design.serif`) Bold | 44 (relativeTo `.largeTitle`) | Do not embed system fonts; use design constants [R3]. |
| Title 2 / section | SF Pro Semibold | 22 | |
| Body | SF Pro Regular | 17 | HIG default size [R3]. |
| Definition | SF Pro Regular | 20 (Title 3) | |
| Callout / translation | SF Pro Regular | 16 | |
| Footnote / chips | SF Pro Semibold | 13 | |
| Caption | SF Pro Regular | 12 / 11 | 11 pt is the HIG minimum [R3]. |
| Example | New York Italic | 18 | |

- Dynamic Type: support the full range. The Large default for Body is 17; at AX5 it reaches 53 (Apple's published table, not re-verified this session). Apple expects at least 200% enlargement [R4].
- Avoid Ultralight, Thin and Light weights at small sizes [R3]. Loose leading for long paragraphs; tight leading only when height-constrained, never for three or more lines [R3].
- Custom fonts (premium) must follow the minimum sizes and implement Dynamic Type and Bold Text [R3]. Use `Font.custom(_:size:relativeTo:)`. Every font must cover Turkish glyphs (ğ, ş, ı, İ, ç, ö, ü) and be checked for IPA coverage (VERIFY New York's IPA coverage).
- Accessibility fonts (free): Atkinson Hyperlegible and OpenDyslexic option.

### 5.3 Spacing, shape, glass

- Spacing scale 4/8/12/16/24/32/48. Screen margin 16.
- Corner radii: cards 28, chips capsule, buttons capsule. Use concentric corners (`ContainerRelativeShape`) inside widgets [R1].
- Liquid Glass is **only** for the control layer (tab bar, top bar, action rail, floating buttons, sheets). Keep it out of the content layer (cards, lists) [R7].
- Clear glass is for rich backgrounds (the Photo theme); add a 35% dim layer behind it if the background is bright [R7].
- Regular glass for text-heavy controls. Both variants adapt to Reduce Transparency and Increase Contrast [R7].
- Fallback below iOS 26: `.ultraThinMaterial` capsules.

### 5.4 Themes (premium feature)

Theme = palette (light and dark) + headword font + optional background art + widget behavior. Each theme must define how it degrades when the system removes backgrounds (tinted, clear, StandBy).

| Theme | Tier | Palette (verified contrast) | Font | Degradation |
|---|---|---|---|---|
| Paper | Free | canvas #FAF7F2, text #1C1B19 | New York | Type-led, degrades cleanly |
| Ink | Free | canvas #12110F, text #F5F2EC | New York | Same |
| System | Free | follows system | SF Pro | Same |
| Mono | Free | white on black | SF Pro | Built for tinted and StandBy |
| Editorial | Premium | #F4EBDD / #2A1F14, accent #8A3B12 (13.6:1 text, 6.6:1 accent) | New York | Serif-led |
| Midnight Library | Premium | #0E1A2B / #EAF0FA, accent #FFC857 (15.3:1, 11.4:1) | New York | Keeps hierarchy via size |
| Botanical | Premium | #E6EFE3 / #17301F, accent #2F6B3F (12.1:1, 5.4:1) | SF Rounded | Illustration removed in tinted |
| Terracotta Pop | Premium | #C8431B with white text (4.9:1) | SF Pro Bold | Color lost; bold type remains |
| Brutalist | Premium | #FFE600 with #000 (16.6:1) | Heavy grotesque | High-contrast, accessibility-friendly |
| Aurora | Premium | gradient #1B1464 to #7B2FF7 with white (15.8:1 to 5.85:1) | SF Pro | Gradient removed in accented |
| Notebook | Premium | #FBF8EF / #1F2A44, accent #C23A4D (13.4:1, 4.9:1) | Handwriting-style font | Font preserved |
| Photo | Premium | user photo, clear glass plus 35% dim | any | In-app only; widgets use removable background |

Acceptance rule for any new theme: body text 4.5:1, large text 3:1, Turkish glyphs present, a tinted and a clear mode preview approved.

### 5.5 Motion

- Purposeful, brief, optional [R11].
- Tokens: micro 120 ms, chips 200 ms, card spring (response about 0.35, damping about 0.85), reveal 250 ms ease-out. Widget data animations stay at or under 2 s [R1].
- Reduce Motion alternatives [R4]:
  - Tighten springs and reduce bounce.
  - Replace x/y transitions with fades.
  - Avoid animating blur in and out.
  - No confetti, no parallax, static heart-burst.
- Never block the user while an animation plays [R11].

### 5.6 Haptics

Apple's rules: system patterns for their documented meaning, consistent mappings, complement visuals, avoid overuse, short for discrete events, always optional, never repurpose a negative pattern for a positive result [R6].

| Event | Haptic |
|---|---|
| Page snap | None by default (overuse risk) |
| Save (double-tap) | Impact, soft |
| I know this | Impact, light |
| Reveal toggle | Selection |
| Quiz correct | Notification, success |
| Quiz wrong | Notification, warning (soft) |
| Daily goal reached | Notification, success plus sound |
| Commitment hold (O11) | Core Haptics continuous ramp, then success |
| Streak milestone | Custom Core Haptics |

- Settings has one toggle for all haptics. System Haptics setting is honored.

### 5.7 Sound

- Six short sounds (under 600 ms): reveal flip, correct tick, soft-low incorrect (not a buzzer), goal chime, streak chime, UI tap.
- UI sounds follow the silent switch (ambient category). User-tapped pronunciation plays through and briefly ducks other audio.
- Pronunciation never autoplays by default. Autoplay is an opt-in setting [R4: do not autoplay audio without controls].
- Pair audio cues with haptics for people with audio off [R4].

### 5.8 Iconography and components

- SF Symbols throughout. Filled variants for tab bars [R9]. Symbols scale with Dynamic Type.
- Components: primary/secondary/tertiary buttons, chips, segmented control, list rows, sheet, toast, banner, skeleton, empty-state, locked pill, coach mark.
- Every interactive element: 44x44 pt target (28 pt minimum), about 12 pt spacing around bezeled elements, 24 pt around unbezeled [R4].

---

## 6. Sharing and viral loop

### 6.1 Share card formats

| Format | Size | Use |
|---|---|---|
| Story background | 1080x1920 (9:16). Meta minimum is 720x1280 [R20] | Instagram Stories, TikTok photo |
| Sticker | Design at 640x480 (Meta's recommended sticker size) [R20]; export at 2x if accepted (VERIFY) | Instagram sticker over the user's own photo |
| Feed / chat | 1080x1350 (4:5) and 1080x1080 | WhatsApp, iMessage, feed posts |
| Video | 1080x1920, H.264, up to 20 s, under 50 MB recommended [R20] | Reels, TikTok. Animated word reveal with pronunciation audio |

**Safe zone.** Keep key content inside the central band. Common third-party guidance is about 250 px clear at top and bottom [R26]; one source says 340 px at the bottom (unverified, third-party). **Design to 250 top / 340 bottom** (content area about 1080x1330) to be safe, and test on a real device.

### 6.2 Templates

1. **Word poster:** the word big, IPA, definition, example, small wordmark.
2. **Streak flex:** streak number, week grid, optional name off by default.
3. **Quiz challenge:** score plus "Beat me" and a universal link. Friend taps the link and plays a 3-word challenge (App Clip is an option; VERIFY size limits).
4. **Collection share.**
5. **Year in Words** (December).

```
 1080x1920
+------------------------------+
|  (top 250 px: UI overlay)    |
|                              |
|                              |
|        ADJECTIVE · B2        |
|                              |
|        resilient             |   New York Bold ~160 px
|        /rɪˈzɪl.i.ənt/        |
|                              |
|  Able to recover quickly     |   ~54 px
|  after difficulty.           |
|                              |
|  "She is remarkably          |   italic ~46 px
|   resilient."                |
|                              |
|  [wordmark] Learn a word a   |   y about 1500-1580 (above bottom unsafe zone)
|             day              |
|  (bottom 340 px: reply bar)  |
+------------------------------+
```

### 6.3 Flow

- Tap Share on the card: a sheet shows a template carousel (live preview), a theme switch (free: Paper/Ink; premium: others), and a destination row (Instagram Stories, TikTok, WhatsApp, Messages, Save image, More).
- **Instagram Stories:** `instagram-stories://share?source_application=<FB App ID>`. Add `instagram-stories` to `LSApplicationQueriesSchemes` and call `canOpenURL` first. Put images on the pasteboard under `com.instagram.sharedSticker.backgroundImage`, `stickerImage`, `backgroundTopColor`, `backgroundBottomColor`. A Facebook App ID has been required since January 2023; without it users see an error [R20]. If Instagram isn't installed, fall back to the system share sheet.
- **TikTok:** Share Kit for iOS needs the client key, and sharing media requires photo library access with local identifiers [R21]. So the default path is the system share sheet or "Save to Photos" (add-only permission), then TikTok.
- Auto caption (localized): "Word of the day: resilient /rɪˈzɪl.i.ənt/. Able to recover quickly after difficulty. Learn a new word daily with [App] [link]."
- Free users get a small wordmark. Premium can hide it. The wordmark is the loop's attribution.
- **Sharing is always optional.** Do not require posting to unlock anything: App Review forbids requiring social actions for subscribers (3.1.2(a)) and forcing store actions for functionality (3.2.2(x)) [R19]. Any share-for-reward must be optional and never gate base features.
- Accessibility: set an image description on the share image and put the plain text in the caption.

---

## 7. Accessibility and localization

### 7.1 Accessibility

**VoiceOver and gestures**
- Vertical swipe conflicts with VoiceOver gestures. When VoiceOver, Switch Control or Full Keyboard Access is running, show visible "Previous word / Next word" buttons, and expose `accessibilityAdjustableAction` / custom actions (Play audio, Save, I know this, Share, Show translation) [R4: provide onscreen alternatives to gestures].
- Reading order on the card: word, part of speech, definition, example, translation.
- Hide IPA from VoiceOver. Set the speech language of the English headword to English so a Turkish voice does not read it.
- Label every control for Voice Control ("Play audio", "Save", "Know it", "Next") [R4].

**Dynamic Type**
- Support xSmall to AX5. Verify at the largest accessibility size. At AX sizes the feed card content scrolls inside the page, the layout stacks into one column, decorative elements go away, and nothing is truncated in scrollable regions [R3].
- Widgets support Large to AX5 [R1]; degrade by dropping elements (4.3).

**Contrast, color, motion**
- 4.5:1 up to 17 pt, 3:1 at 18 pt and bold [R4]. Check light, dark, Increase Contrast.
- Differentiate without color (icons plus text). Respect Reduce Motion, Reduce Transparency, Bold Text. Provide an opt-out for flashing effects (there are none by default) [R4].
- Do not autoplay audio or video without controls [R4]. Onboarding guide videos have captions and transcripts [R4].

**Targets and handedness**
- 44x44 pt minimum for default controls; 28x28 absolute minimum [R4]. Action-rail side setting for left/right-handed users.

**Testing checklist:** VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Larger Text AX5, Reduce Motion, Increase Contrast, Differentiate Without Color, Smart Invert, Bold Text.

### 7.2 Right-to-left (Arabic)

Apple's RTL rules [R5]:
- System components flip automatically. Use leading/trailing, not left/right.
- Align paragraphs (three or more lines) by language, not context. One or two lines follow the interface direction.
- Keep digit order within numbers. Reverse numeral order for progress and counting (ratings, progress bars); never flip the numerals themselves.
- Flip navigation controls and progress controls; preserve controls that refer to a real direction; do not flip logos, photos or the checkmark.
- Arabic has no uppercase. Increase RTL font size by about 2 pt in buttons, labels and titles to balance Latin all-caps [R5].

**Mixed-direction card spec (English headword in an Arabic UI)**

| Element | Direction | Alignment |
|---|---|---|
| Headword, IPA | LTR (forced) | Aligned to the interface leading edge (right in RTL) |
| English definition and example (multi-line) | LTR | Left-aligned (paragraph follows its language) [R5] |
| Arabic translation | RTL | Right-aligned |
| Action rail | Mirrors with UI | Trailing side becomes left; handedness setting still applies |
| Progress bars, week row | Mirrored | Day order reversed [R5] |

- Wrap embedded English in Arabic sentences with Unicode bidi isolates (U+2068/U+2069) to stop punctuation reordering.
- Test with native Arabic readers; the mixed card is the riskiest layout.

### 7.3 Long German words and Turkish length

- Translation chips and labels wrap to 2 lines; buttons never use fixed widths (use `ViewThatFits`).
- Provide soft hyphens (U+00AD) in definitions and translations through the content pipeline; never hyphenate the headword (shrink to 0.6x, then wrap).
- Small-widget content width is about 126 pt; at 13 pt that is about 20 characters per line, so a 30+ character German or Turkish translation must wrap or scale.
- QA with Xcode's Double-Length and RTL pseudolanguages. Stress strings: "Donaudampfschifffahrtsgesellschaft", "Benachrichtigungseinstellungen", "Çekoslovakyalılaştıramadıklarımızdan".
- Tab labels remain single words [R9].

### 7.4 Turkish casing and text pitfalls (İ/ı)

Turkish has dotted and dotless i. Uppercase i is İ (U+0130); uppercase ı is I; lowercase I is ı; lowercase İ is i [R27].

1. **Never use locale-less casing.** `"i".uppercased()` produces "I" (wrong in Turkish).
2. **Cast by the text's language, not the device locale.** Use `uppercased(with: Locale(identifier: "tr"))` for Turkish text and `en` for English text. `localizedUppercase` uses the device locale, so a Turkish device would turn the English word "title" into "TİTLE" (wrong), and an English device would turn "ışık" into "IŞIK" correctly but "iş" into "İŞ" incorrectly if the locale is wrong.
3. **Avoid ALL-CAPS UI styling.** Do not use `.textCase(.uppercase)` on user-visible Turkish strings unless the environment locale is Turkish. Prefer sentence case.
4. **Search and "type it" quiz matching.** Normalize both sides: fold ı/İ/I/i to a common key, then apply diacritic-insensitive folding. Note that dotless ı does not decompose to i, so build an explicit fold map (ı to i, İ to i, ğ to g, ş to s, ç to c, ö to o, ü to u). Users without a Turkish keyboard type "cicek" for "çiçek".
5. **Capitalization.** Do not use `.capitalized` on Turkish strings without the locale ("ılık" must become "Ilık", not "İlık").
6. **Sorting.** Use locale collation (Turkish order: c, ç, ... g, ğ, h, ı, i, ...). Test lists with ç, ğ, ı, ö, ş, ü.
7. **Fonts.** Every theme font must include ğ, Ğ, ş, Ş, ı, İ, ç, Ç, ö, Ö, ü, Ü (add to the acceptance test).
8. **Suffix harmony.** Do not concatenate the user's name or the app name with Turkish suffixes in copy. Rephrase to avoid it.
9. **Plurals** use stringsdict rules; Turkish uses a singular noun after a numeral ("5 kelime").
10. **Widget locale.** Widgets and `Text` follow the widget's environment locale; test Turkish casing in widget previews.

### 7.5 Launch locales

- UI: English, Turkish (first-class), then Spanish, Portuguese (BR), Arabic (RTL), German (long words), French, Russian, Indonesian.
- Translation (native-language) set is wider than the UI set.
- Dates, numbers and currency use system formatters. Arabic Eastern numerals follow locale [R5].

---

## 8. Differentiation and anti-patterns

### 8.1 Twenty-four concrete UX differentiators vs the competitor set

1. **Interactive Reveal widget:** tap-to-flip on the Home Screen turns a read-only widget into active recall (iOS 17+ App Intents).
2. **Quiz widget:** answer 3-4 choices directly on the Home Screen with in-place correct/incorrect feedback.
3. **"I know it" and "Again" on the widget:** SRS grading without opening the app.
4. **Pronunciation button on the widget** via an AudioPlaybackIntent (VERIFY behavior).
5. **Free "Next word" button:** intent taps don't consume the refresh budget [R13], so users can cycle words instantly.
6. **Widget-only learning counts** toward streaks and XP (the app may never be opened).
7. **Widget Health screen** that explains why a widget looks stale and fixes it.
8. **"Next word at 15:00" micro-label** in large widgets (Apple recommends showing last-updated info) [R1].
9. **Install before pay:** widget education precedes the paywall; value is experienced first.
10. **Animated widget-install guide with auto-detection** of the installed widget.
11. **Honest paywall:** trial end date shown, real reminder notification, always-visible X.
12. **Ad-free free tier** (business decision to confirm).
13. **No tracking prompt at launch, no demographics, no account required** (App Review 5.1.1(v)) [R19].
14. **Native-language-first onboarding** (language chosen on step 1, Turkish quality copy).
15. **Easier-definition toggle and CEFR-aware definitions** instead of dictionary-only text.
16. **False-friend alerts per native language** (for example Turkish "eventually" vs "eventüel").
17. **Soft stop in the feed** (batch-complete card) instead of infinite scroll.
18. **Forgiving streaks:** earned freezes, rest days, widget actions count.
19. **Capture words from anywhere:** Share Extension ("Save word") plus a Live Text camera path.
20. **Focus filters, Shortcuts, Control Center controls and Action button** (for example "Hold for Quiz") [R12].
21. **Handedness setting** for the feed action rail.
22. **Dyslexia-friendly and Atkinson Hyperlegible fonts free**, not premium.
23. **Free data export (CSV/Anki)** and no re-gating of saved content.
24. **Theme identity in type, not just backgrounds,** so premium themes still look right in iOS clear and tinted modes.

### 8.2 UX anti-patterns to avoid (with what to do instead)

**Paywall and pricing**
1. Hard paywall before the first word or before any value. Instead: soft paywall after value, with always-visible close.
2. Hidden or delayed close button. Instead: 44 pt X, visible immediately.
3. Hidden trial terms, tiny gray price text. Instead: price, period, trial end date adjacent to the CTA (App Review 3.1.2(c) requires describing what users get for the price) [R19].
4. Weekly price emphasized to hide the annual cost. Instead: annual and monthly (plus optional lifetime); if weekly exists, also show the annualized cost.
5. Confirmshaming ("No, I don't want to learn"). Instead: neutral "Not now".
6. Fake countdowns and fake scarcity.
7. Trial toggle that changes the price or hides the real plan.
8. A CTA labeled "Continue" that actually purchases.
9. Auto-renew with no reminder. Instead: reminder 2 days before.
10. Re-gating features users already used or created (the Monkey Taps complaint) [R24]. Instead: grandfather and never lock user data.
11. "Unlock Pro" overlays on most screens that make the app feel crippled [R23 note]. Instead: preview-first, one honest lock pill.
12. Forcing rating, review, social posting, or other store actions for functionality [R19 3.2.2(x), 3.1.2(a)].
13. Hidden Restore Purchases, or a lifetime price buried in a menu.

**Onboarding and permissions**
14. Tracking prompt before any value [R23]. Instead: do not track.
15. Asking age, gender and name without a user benefit.
16. Fake "analyzing..." loading screens. Instead: real, instant summary.
17. Notification permission without priming, or a primer where "Not now" is hidden [R2].
18. Rating prompt during onboarding [R2].
19. Account creation required for core use [R19 5.1.1(v)].
20. Long onboarding with no skippable steps. Keep it skippable where marked and resumable.

**Widgets**
21. Promising refresh intervals iOS can't guarantee. Instead: plan around budgets (40-70 refreshes/day) and show next-word times [R13].
22. Networking inside the widget. Instead: pre-build a day of entries locally.
23. Hiding stale data behind placeholders [R1].
24. A widget gallery full of near-identical sizes (stretched content) [R1].
25. In-app faux widgets that look interactive but aren't [R1].
26. Quiz buttons on the Lock Screen (inactive when locked) [R14].
27. Non-removable photo backgrounds (excluded from StandBy and iPad Lock Screen) [R15].

**Notifications and engagement**
28. More than one notification per event, guilt copy ("Your streak is about to die!") [R10]. Instead: "Two minutes is enough. Today's word: ephemeral."
29. Badges used for non-notification counts (weather, scores, streaks) [R10].
30. Long-running or constant haptics; haptics with no off switch [R6].
31. Audio autoplay without controls [R4].
32. Infinite feed with no stopping point.

**Accessibility and i18n**
33. Long-press-only or swipe-only controls [R4].
34. Locale-less string casing for Turkish (7.4).
35. Fixed-width buttons that truncate German and Turkish.
36. Locking accessibility features (bigger text, dyslexia font) behind premium.

---

## 9. Open questions, verification list, references

### 9.1 Things to verify before build

- Mac native widget point sizes (not in the HIG table I retrieved).
- iOS 26 and iOS 27 Home Screen and Lock Screen edit-mode wording for the install guides. Apple's WWDC26 session "WidgetKit foundations" is listed in the HIG resources [R1]; review it for iOS 27 changes (not read this session).
- Lock Screen button UX (authentication prompt behavior) and AudioPlaybackIntent from a widget, on a real device.
- Tab bar minimize behavior with a paging scroll view.
- Instagram bottom safe zone (250 vs 340 px, third-party) and sticker export size.
- New York IPA glyph coverage; Turkish StandBy name.
- Competitor details are from third-party teardowns, not hands-on.

### 9.2 Product decisions to confirm

- Ad-free free tier (a differentiator, a revenue tradeoff).
- Paywall placement A (after widget guide) vs B (before it). Measure D7 retention and revenue.
- Weekly plan: recommended against.
- Whether Reveal mode, premium rotation intervals and audio buttons sit in free or premium.

### 9.3 UX success metrics

- Time to first widget installed.
- Onboarding completion rate and step drop-off.
- Widget interaction rate (taps per widget per day).
- Day-7 and day-30 retention.
- Share rate.
- Trial-to-paid conversion and refund/cancel-within-trial rate.

### 9.4 References

- [R1] Apple HIG, Widgets: https://developer.apple.com/design/human-interface-guidelines/widgets (DocC JSON: https://developer.apple.com/tutorials/data/design/human-interface-guidelines/widgets.json). Sizes, margins, rendering modes, StandBy, interactivity, text, color.
- [R2] Apple HIG, Onboarding: https://developer.apple.com/design/human-interface-guidelines/onboarding
- [R3] Apple HIG, Typography: https://developer.apple.com/design/human-interface-guidelines/typography
- [R4] Apple HIG, Accessibility: https://developer.apple.com/design/human-interface-guidelines/accessibility
- [R5] Apple HIG, Right to left: https://developer.apple.com/design/human-interface-guidelines/right-to-left
- [R6] Apple HIG, Playing haptics: https://developer.apple.com/design/human-interface-guidelines/playing-haptics
- [R7] Apple HIG, Materials (Liquid Glass): https://developer.apple.com/design/human-interface-guidelines/materials
- [R8] Apple HIG, Color: https://developer.apple.com/design/human-interface-guidelines/color
- [R9] Apple HIG, Tab bars: https://developer.apple.com/design/human-interface-guidelines/tab-bars
- [R10] Apple HIG, Notifications: https://developer.apple.com/design/human-interface-guidelines/notifications
- [R11] Apple HIG, Motion: https://developer.apple.com/design/human-interface-guidelines/motion
- [R12] Apple HIG, Controls: https://developer.apple.com/design/human-interface-guidelines/controls
- [R13] WidgetKit, Keeping a widget up to date: https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date
- [R14] WidgetKit, Adding interactivity to widgets and Live Activities: https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities
- [R15] WidgetKit, Displaying the right widget background: https://developer.apple.com/documentation/widgetkit/displaying-the-right-widget-background
- [R16] WidgetKit, Preparing widgets for additional contexts and appearances (rendering modes, support matrix, luminance, disfavored locations): https://developer.apple.com/documentation/widgetkit/preparing-widgets-for-additional-platforms-contexts-and-appearances
- [R17] WidgetKit, Adding StandBy and CarPlay support to your widget: https://developer.apple.com/documentation/widgetkit/adding-standby-and-carplay-support-to-your-widget
- [R18] WWDC25 session 278, What's new in widgets (accented rendering, clear/tinted, `widgetAccentedRenderingMode`): https://developer.apple.com/videos/play/wwdc2025/278/
- [R19] App Review Guidelines (1.1, 2.3.1, 3.1.1, 3.1.2, 3.2.2(x), 4.5.4, 5.1.1, 5.1.2): https://developer.apple.com/app-store/review/guidelines/
- [R20] Meta, Sharing to Instagram Stories: https://developers.facebook.com/docs/instagram-platform/sharing-to-stories/
- [R21] TikTok Share Kit for iOS: https://developers.tiktok.com/doc/share-kit-ios-quickstart-v2
- [R22] ScreensDesign, Vocabulary - Learn words daily (onboarding teardown): https://screensdesign.com/apps/vocabulary-learn-words-daily/
- [R23] ScreensDesign, Word of the Day - Vocabulary (onboarding chapter index): https://screensdesign.com/apps/word-of-the-dayenglish-vocab/
- [R24] App Store, Vocabulary - Learn words daily (Monkey Taps): https://apps.apple.com/app/id1084540807
- [R25] MWM, Widget Vocabulary: Learn Words listing: https://mwm.ai/apps/widget-vocabulary-learn-words/6775767149
- [R26] Third-party Instagram Story safe-zone guidance (unofficial; sources disagree on the bottom margin): https://argil.ai/blog/instagram-story-dimensions
- [R27] ICU/CLDR Turkish case mapping (Apple open-source ICU data): https://opensource.apple.com/source/ICU/ICU-66112/icuSources/data/translit/tr_Upper.txt.auto.html

No files were written to the project folder. The only scratchpad files are two contrast-check scripts (`contrast.py`, `c2.py`).