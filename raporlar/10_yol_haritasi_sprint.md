# EXECUTION ROADMAP: iOS Vocabulary-Widget Subscription App
Prepared 2026-10-10. Working title: **[APP]**; the name is open decision D4.
Plan clock: **W1 = Mon 2026-10-12 ... W12 = Mon 2026-12-28 to Sun 2027-01-03.**

Benchmarks below are planning hypotheses. Items marked (V) need verification by the market/legal/tech agents. Sources are listed in section 10.

---

## 0. Strategy skeleton (read first)

**Thesis.** "Swipe feed + home/lock widgets + quizzes + categories + themes + hard paywall" is a commodity (Widget Vocabulary, Monkey Taps). We will not win on feature count. We win on four things:

1. **A wedge audience.** Turkish learners (YDS/YÖKDİL/IELTS/general), with native-language gloss and Turkish creators/ASO. Global English UI stays the default. (V) Confirm exam angles with the market agent.
2. **The widget as the learning surface, not decoration.** Interactive "Know it / Review" buttons (iOS 17 App Intents), spaced-repetition-driven rotation, and CEFR level targeting.
3. **Distribution.** A TikTok/Reels/Shorts content engine plus ASO. Paid UA is off until unit economics are proven.
4. **A distinct brand, UX and original content.** This is the best defence against a Guideline 4.3 "copycat/spam" rejection.

**Hypotheses Phase 0 must test**

| ID | Hypothesis | Phase 0 evidence |
|---|---|---|
| H1 | Demand exists: people will opt in for a "widget vocabulary" app | Waitlist conversion, TikTok saves/comments |
| H2 | A wedge message beats the generic one (A: exam-prep, B: widget aesthetic, C: native-language gloss) | Landing page and video variants |
| H3 | Willingness to pay at $30-45/yr or weekly | Fake-door pricing click-through, interviews |
| H4 | We can get organic reach without paid spend | Views, profile-to-link CTR |

**Reference numbers (from RevenueCat State of Subscription Apps 2026; some via secondary write-ups, V)**

| Metric | Value | Use in this plan |
|---|---|---|
| Education download-to-trial (D30), median | 6.5% | Floor target for install→trial |
| Education revenue per install at D14, median | $0.30 | Floor target for early monetization |
| Education yearly median price | $44.99 (highest of all categories) | Price test ceiling |
| Education monthly median price | $9.99 | Reference |
| Education trial length | 50.3% of trials are 5-9 days | Informs trial-length test |
| Education trial starts on Day 0 | 78.5% | The paywall must convert at install |
| Hard-paywall median download-to-paid (D35), all categories | ~10.7% vs ~2.1% freemium | Directional only; secondary-sourced, V |
| Trial→paid by trial length (all categories, secondary) | ≤4 days ≈ 25.5%; 17-32 days ≈ 42.5% | Directional only |
| WidgetKit budget | Typically 40-70 reloads/day for a widget users frequently view; dynamic and not guaranteed | Dictates the widget architecture |

**Tech defaults (details in section 9)**

| Area | Default |
|---|---|
| Platform | Native iOS, SwiftUI, iOS 17+ minimum (V: check install-base share) |
| Widgets | WidgetKit, App Intents (interactive), Lock Screen accessory widgets |
| Storage | SQLite (GRDB) in an **App Group** container |
| Notifications | Local only (cap of 64 pending, so rolling schedule) |
| Backend | None at MVP |
| Content updates | Static versioned JSON on a CDN |
| Purchases | StoreKit 2 via RevenueCat |
| Analytics | PostHog (or Firebase) plus RevenueCat |
| Crashes | Sentry or Crashlytics |
| CI/CD | Xcode Cloud or fastlane |
| Tracking | No ATT prompt, no IDFA |

**Widget architecture (one paragraph)**
- The app writes a precomputed queue of the next 24-48 words (chosen by SRS, level and topic) to the App Group.
- The widget's `TimelineProvider` builds dated entries from that queue, for example one per hour.
- A timeline of N dated entries displays on schedule without a reload per entry. The reload policy `.atEnd` is charged once per timeline, not per entry.
- The app calls `WidgetCenter.reloadAllTimelines()` on setting changes and when foregrounded. Reloads while the app is in the foreground are budget-free.
- No network calls in the widget.
- Detect installed widgets via `WidgetCenter.getCurrentConfigurations()`. Log "last timeline build" timestamps to the App Group and report them on the next app open.

**Critical path.** Almost every slip comes from one of these dependency chains.
1. Apple Developer account + Paid Apps Agreement + tax + bank → IAP sandbox/prod → paywall → submission. **Start W1; lead time can be 1-3 weeks.**
2. Name decision (D4, W3) → icon/brand → screenshots/ASO listing → submission.
3. Content freeze (W5) → Turkish QA → TR store listing/loc (W6-7) → submission.
4. Widget spike (W1) → production widgets (W4) → device QA matrix (W7).

---

## 1. Product phases

| Phase | Window | Goal | Scope | Exit / gate criteria |
|---|---|---|---|---|
| **Phase 0: Validate** | W1-2 (Oct 12-25) | Decide go/no-go and pick the wedge | Landing page + waitlist; fake-door pricing; 14+ TikTok/Reels videos (EN + TR); 8-10 learner interviews; competitor teardown (both apps); widget tech spike (dev runs in parallel, ≤50% time, reusable) | **G0** (see Phase 0 scorecard below) |
| **MVP** | W1-9 build + ship (soft launch Thu Dec 10; public Tue Dec 15) | Ship a monetizable, App Review-safe v1.0 | Section 2 Musts and selected Shoulds | Approved build; crash-free ≥99.5% in beta; paywall verified in prod; ≥70% onboarding completion in beta |
| **v1.1** (Dec 28-Jan 11) | New Year wave | Fix first-week learnings, ride the resolution peak | +500 words; share-as-image; large widget; interactive widget actions (if not in 1.0); paywall tests 1-3; Turkish UI polish | D7 ≥10% (all installs); rating ≥4.4 |
| **v1.2** (Jan-Feb) | Depth + trust | Retention and content | Better SRS; exam/academic packs after licensing review; native glosses ES/PT-BR/AR; pre-rendered neural audio; CloudKit sync (reinstall safety); win-back offers | D30 ≥5% |
| **v1.3** (Feb-Mar) | Personalization | Conversion and activation | Placement test; stats dashboard; alt app icons; Shortcuts/Control Center control (iOS 18); referral; Lifetime offer test | Install→paid ≥2.5% |
| **v1.4** (Mar-Apr) | Content breadth | Catalog and SEO | 6k words; phrasal verbs/idioms; collections; custom lists | Catalog complete; ASO keyword coverage |
| **v1.5** (Apr-May) | Structured learning | Habit and ARPU | 30-day "B1→B2" paths; review mode; Watch complication; Live Activity for quiz | WAWL up 30% vs v1.1 |
| **v2** (Jun-Sep 2027) | Platform + AI + languages | Scale | Android (Kotlin/Jetpack Compose + Glance widgets, shared JSON/SQLite content); AI tutor (explain-in-context, sentence feedback); more UI languages (ES, PT-BR, AR, DE, FR, RU, ID, HI); accounts, cross-device sync | Trigger: LTV:CAC ≥3, ≥$10k MRR, or a documented Android waitlist |
| **v3** (2028) | New segments | Diversify revenue | B2B/schools (class codes, teacher dashboards, word-list assignment, institutional pricing); multi-language learning (Spanish/German/French vocab using the same content engine); partnerships (exam-prep centers) | Trigger: ≥3 inbound school requests or a pilot LOI |

**Phase 0 scorecard (thresholds are starting points)**

| Test | Pass threshold |
|---|---|
| Landing page visitor → email | ≥12% warm, ≥8% cold |
| Fake-door pricing: emails clicking a paid plan | ≥30% of emails (yearly ≥50% of those) |
| TikTok/Reels | ≥1 video ≥30k views; ≥3 videos with save rate ≥3%; ≥30 "what's the app?" comments |
| Interviews (n=8-10) | ≥6 would install; ≥3 currently pay for a learning tool |
| Teardown | ≥3 exploitable gaps confirmed in 1-3★ reviews |

Go = meet 3 of 5. If top-of-funnel is strong but pricing is weak, iterate pricing or position rather than kill. If both are weak, pivot the angle (for example exam-only) before spending MVP weeks.

**Teardown deliverables.** Complete before G0.
- Flow recordings of both apps' onboarding and paywall: step counts, price points, trial length, copy tactics.
- Widget behaviour test: refresh cadence, sizes, interactivity.
- 50-word content audit: accuracy, repeats, level spread.
- Review mining of 1-3★ reviews from the last 12 months, tagged by theme.
- ASO teardown: title, subtitle, keywords, screenshots, rating counts.
- TR storefront prices.
- Feature-parity matrix, "wedge hypothesis" and "do-not-copy list" (4.3 risk).

**Phase 0 budget.** About $150-300 of test ads plus tools.

---

## 2. MVP scope (strict MoSCoW)

### MUST (ships or we don't ship)

| # | Feature | Notes / ruthless boundary |
|---|---|---|
| M1 | **Onboarding ≤8 screens** | Goal → level (self-select CEFR; no placement test) → native-language gloss (TR/none) → 3 topics → daily goal → notification primer → widget walkthrough → paywall. Every step is analytics-instrumented. |
| M2 | **Word feed** (full-screen vertical swipe) | Word, IPA, POS, simple definition, 1-2 examples, TR gloss, Know/Learning/Save. One card design. |
| M3 | **Word detail + pronunciation** | AVSpeechSynthesizer (free, offline) at MVP. Neural pre-rendered audio is v1.2. |
| M4 | **Home Screen widgets** (small + medium) | Word + definition. Timeline built from a queue (section 0). Tap deep-links to the word. |
| M5 | **Lock Screen widgets** | `accessoryRectangular` and `accessoryInline`. Cheap once M4 exists. |
| M6 | **Widget settings** | Rotation interval (15m / 1h / 3h / daily), level and topic filter, theme. |
| M7 | **Local notifications** | Word of the day, 1-3 per day, time pickers. Rolling schedule (64-pending cap), topped up on app open and via a background app refresh task. |
| M8 | **Levels + topics** | Six CEFR levels A1-C2. Launch topics: Business, Travel, Academic, Daily Life, Idioms/Phrasal Verbs, Tech. |
| M9 | **Learning state** | Known / Learning / Saved. Favorites list. Simple Leitner (3-box) scheduling feeds the widget queue and quiz pool. |
| M10 | **Quiz** (one session type) | 10 multiple-choice questions (word→definition and definition→word) from seen/saved words. Results screen. |
| M11 | **Themes** | 4 curated (1 default, 3 premium) for in-app and widgets. Widget aesthetics are our marketing surface. |
| M12 | **Paywall + subscriptions** | Hard paywall at the end of onboarding. Yearly with trial plus weekly. Restore purchases, terms/privacy links, price/renewal disclosure, Manage Subscription link. RevenueCat entitlements. |
| M13 | **Analytics + crash reporting** | The ~44 events of section 5. |
| M14 | **Content set** | ~2,500 words, original definitions and examples, TR gloss. Provenance log, QA pass, "report a mistake" button. |
| M15 | **Settings / legal / support** | Privacy policy, ToS, support link, manage subscription, notification settings. |
| M16 | **Brand + App Store assets** | Distinct name, icon and screenshot storyline (4.3 defence). |

### SHOULD (if on schedule at G1, Nov 20)

| # | Feature | Notes |
|---|---|---|
| S1 | **Turkish UI localization + TR store listing** | ~150 strings. High conversion impact in the early market. Placed in W6-7. |
| S2 | **Interactive widget buttons** ("Know it / Review") via App Intents | Our primary differentiator. Build W5-6 if the widget is solid; otherwise v1.1. |
| S3 | **Streaks** (+ daily goal ring) | Cheap retention lever. |
| S4 | **Share-as-image** | "Word card" image share for TikTok/Stories (viral loop). |
| S5 | **Rating prompt** | Triggered after value (≥5 known words or a good quiz score). Use a happy/not-happy pre-prompt. |
| S6 | **Downsell on paywall close** | 50% off yearly or weekly-only. |
| S7 | **Offer codes + creator promo flow** | For seeding. |
| S8 | **Basic search** | Search over the bundled set. |
| S9 | **Large widget** | Only if medium is stable. |

### COULD (only if everything else is done)

Alt app icons; haptics polish; Siri Shortcut "word of the day"; StandBy tuning (it works free; test only); "Hard words" auto-collection; in-app What's New; widget gallery screen.

### WON'T (MVP). State this firmly to avoid scope creep.

Android; accounts/login; cloud sync; social/leaderboards/friends; AI tutor/chat; camera/OCR; Apple Watch; iPad optimization (iPhone-only target); Mac; web app; user-created word lists; multiple gloss languages beyond TR; Live Activities; exam-branded packs (IELTS/TOEFL/YDS: licensing and trademark review first); gamification beyond streaks (XP, leagues); ads; referral program; Lifetime plan; pre-rendered neural audio; remote push (APNs).

### Cut order if behind at G1 (Nov 20), in this order
1. Large widget, search, downsell
2. Alt icons and other Coulds
3. Themes 4→2
4. Turkish UI (keep the TR gloss; store listing in TR)
5. Streaks
6. Interactive widget buttons → v1.1
7. Quiz → single mode

**Never cut:** paywall, analytics, widgets, notifications, content QA, restore purchases, privacy/terms.

### Definition of Done for submission (G2)
- Crash-free sessions ≥99.5% on TestFlight (≥50 testers).
- Widget QA matrix passes (see W7).
- Sandbox purchase, trial, restore and expiry verified; a production smoke purchase is feasible post-release.
- No "Lorem ipsum", no competitor names/assets in metadata, and no placeholder content.
- App Privacy labels and `PrivacyInfo.xcprivacy` complete for the app and all SDKs.
- App Review notes written (how widgets are added, test subscription flow).

---

## 3. Twelve-week sprint plan (4 parallel tracks)

**Calendar and gates**

| Week | Dates | Headline | Gate |
|---|---|---|---|
| W1 | Oct 12-18 | Phase 0 wk1 + dev spike | |
| W2 | Oct 19-25 | Phase 0 wk2 | **G0** scorecard Sun Oct 25; decision Mon Oct 26 |
| W3 | Oct 26-Nov 1 | MVP sprint A: foundations | (Oct 29 is a Turkish public holiday) |
| W4 | Nov 2-8 | Sprint B: core loop + widgets | Internal alpha TestFlight Fri Nov 6 |
| W5 | Nov 9-15 | Sprint C: quiz/SRS/notifications/onboarding | **Content freeze v1** |
| W6 | Nov 16-22 | Sprint D: paywall/analytics/themes | **G1** feature-complete Fri Nov 20 → external beta 1 |
| W7 | Nov 23-29 | Beta + polish | |
| W8 | Nov 30-Dec 6 | RC build + **submit Tue Dec 1** | **G2** submit criteria |
| W9 | Dec 7-13 | App Review buffer + soft launch | **G3** release Wed Dec 9; live **Thu Dec 10** |
| W10 | Dec 14-20 | **PUBLIC LAUNCH Tue Dec 15** | |
| W11 | Dec 21-27 | Holiday stabilization | |
| W12 | Dec 28-Jan 3 | New Year wave + retro | **G4** go/no-go on paid UA and v1.2 |

**Why soft launch five days before the public push:**
- ASO keyword indexing needs time.
- Production IAP, receipt and webhook paths only fully test in production.
- Prod-only bugs are cheaper to fix before the creator wave.

**Fallback.**
- If G2 slips ≥1 week: submit by Dec 8, soft launch ~Dec 17, and move the public launch to Tue Jan 5 (the New Year resolution peak; nothing lost).
- If G2 slips ≥2 weeks: launch Jan 12.
- Do not submit new features Dec 22-Jan 1. Apple has historically published a holiday review schedule around Dec 23-27 (V: check Apple Developer news).

### Week-by-week deliverables

**W1 (Oct 12-18): Phase 0 kickoff**
- **iOS dev:**
  - Enroll/verify the Apple Developer Program account and start the Paid Apps Agreement, tax forms and bank details (critical path).
  - Apply to the Small Business Program (15% commission).
  - Xcode project: App + Widget + Intents targets, App Group, CI.
  - **Widget spike:** 24-entry hourly timeline from the App Group DB on 3 physical devices (Home + Lock Screen), measuring reload behaviour.
  - RevenueCat project and product stubs. Landing page tech (Framer/Carrd + form + PostHog).
- **Designer:** Teardown screen boards in Figma; moodboard; 3 brand directions; one-page landing design.
- **Content:**
  - Word-list source and licence audit (e.g., NGSL/NAWL/AWL, CEFR-J; avoid Oxford/Cambridge/Merriam-Webster definitions).
  - Content schema: word, lemma, POS, IPA, CEFR, definition, examples ×2, TR gloss, topics, frequency, collocations, audio_id, version.
  - LLM drafting prompt v0; 50-word pilot.
  - TikTok script bank (30 hooks across EN + TR).
- **Growth:** TikTok/IG/YouTube accounts (EN + TR). Landing page live by Wed. Publish 7 videos. Recruit 8-10 interviewees. Start review mining.
- **Dependency:** Account/bank/tax enrollment, started now.

**W2 (Oct 19-25): Phase 0 close**
- **iOS dev:** Data layer + CSV→SQLite content import tool; navigation shell; design-system tokens; analytics wrapper with event schema v1; sandbox IAP test; onboarding skeleton.
- **Designer:** Design system (type, color, 4 themes); hi-fi for feed card, word detail and widget layouts (S/M/Lock).
- **Content:** 300-word pilot set (A1-B1 spread) fully drafted; native Turkish reviewer samples the TR gloss; error taxonomy defined.
- **Growth:** 7 more videos (14 total); fake-door pricing page; finish interviews; synthesis. **G0 scorecard Sun Oct 25.**
- **Gate:** G0.

**W3 (Oct 26-Nov 1): MVP sprint A**
- **iOS dev:** Feed screen (vertical pager); word card; level/topic filter; known/learning/saved; repository layer; deep links.
- **Designer:** Onboarding flow hi-fi; paywall v1 (2 variants); 3 icon concepts.
- **Content:** 1,000 words done and QA'd; content build pipeline (generate → auto-checks → human sample → build SQLite).
- **Growth:** **Decide name (D4)** and check trademarks, domain, handles. Draft App Store listing. Waitlist nurture email #1.
- **Dependency:** Name → icon/ASO.

**W4 (Nov 2-8): MVP sprint B**
- **iOS dev:** Production widgets (home S/M, lock rect/inline); theme engine; shared state; reload hooks. **Internal alpha 1 (TestFlight) Fri Nov 6.**
- **Designer:** Final icon (5-second test with 5-10 people); widget art; themes.
- **Content:** 1,800 words; TR gloss QA for A1-B2.
- **Growth:** ASO keyword research → title/subtitle/keyword draft; screenshot storyline; recruit 30-50 beta testers from the waitlist; shortlist 20 micro-creators (EN learning + TR).

**W5 (Nov 9-15): MVP sprint C**
- **iOS dev:** Quiz (2 modes); Leitner scheduling; streak; notifications (rolling schedule, time picker); onboarding build with permission priming.
- **Designer:** Quiz/results/stats/settings/empty states; App Store screenshots v1; rating prompt.
- **Content:** **2,500 words complete; content freeze v1;** category mapping; "report a mistake" flow data.
- **Growth:** TikTok ramp to 1-2/day; build-in-public posts.

**W6 (Nov 16-22): MVP sprint D → G1**
- **iOS dev:** Paywall (RevenueCat Paywalls/Offerings), intro offers, restore, manage subscription; full analytics events; remote config; settings/legal. **Feature-complete Fri Nov 20 (G1)** → submit **external TestFlight beta 1** (Beta App Review ~1-2 days).
- **Designer:** Paywall final + variants; onboarding polish/motion; preview-video storyboard.
- **Content:** Turkish UI strings; store listing translations (TR); privacy policy + ToS (templated; Legal agent review); FAQ/support page.
- **Growth:** Beta invites; press kit; "widget setup aesthetic" video series; creator outreach list finalized.

**W7 (Nov 23-29): Beta + polish** (Thanksgiving/Black Friday noise for US ads; irrelevant for organic)
- **iOS dev:**
  - Bug bash, performance, accessibility (Dynamic Type, VoiceOver basics), Turkish localization, crash reporting. Beta 2 Fri Nov 27.
  - **Widget QA matrix:** ≥10 devices/OS versions; Low Power Mode; Background App Refresh off; widget not updating for >24h without app open; battery sampling.
- **Designer:** App Store screenshots final (6.9"); preview video 15-30s; final icon variants for PPO.
- **Content:** QA pass 2: a teacher reviews a 300-word sample; fix list; 40 captions for TikTok/IG.
- **Growth:** Beta feedback loop; onboarding fixes; waitlist ≥ X; creator outreach wave 1 (TestFlight/offer codes); set up App Store Connect Analytics and Apple Ads (Discovery) account.

**W8 (Nov 30-Dec 6): RC build + submit**
- **iOS dev:** RC build Mon Nov 30; regression; **G2 gate; submit Tue Dec 1** with subscription products attached to the version (review screenshot + localization), App Privacy labels, export compliance, age rating, App Review notes. Respond to rejections same day.
- **Designer:** On-call for metadata/asset rejections; launch creative templates (TikTok/IG).
- **Content:** Launch-week content calendar (14 days); v1.1 content batch +500 words started.
- **Growth:** Teaser email #1; landing page → "launching Dec 10/15"; Apple featuring nomination submitted (V: check lead-time guidance); Turkish media pitch list.

**W9 (Dec 7-13): App Review buffer + soft launch**
- **iOS dev:**
  - Buffer for up to two rejection cycles plus an appeal; **G3 Wed Dec 9: approved build, manual release; live Thu Dec 10** (TR + all storefronts, no big announcement).
  - Start v1.0.1.
  - Monitor RevenueCat, crash-free and widget error logs.
- **Designer:** 1.0.1 fixes; PPO variants prepared.
- **Content:** Ship +500-word drop via remote JSON.
- **Growth:** Soft-launch sanity checks (listing, keyword indexing); schedule creator posts for Dec 15-17; DM Turkish creators.

**W10 (Dec 14-20): LAUNCH WEEK (see day-by-day below)**

**W11 (Dec 21-27): Holiday stabilization**
- **iOS dev:** v1.0.2 hotfix by ~Dec 21 at the latest; start v1.1 (interactive widget actions, large widget, share cards).
- **Designer:** PPO setup; v1.1 UI.
- **Content:** Drip content; respond to mistake reports within 48h.
- **Growth:** Paywall experiment #1 live (E-01/E-07); creator wave 2; winning-video iteration; Apple Ads Discovery test ($10-20/day, only if funnel holds).

**W12 (Dec 28-Jan 3): New Year wave + retro**
- **iOS dev:** v1.1 submitted Mon Dec 28 → release as approved.
- **Designer:** New Year campaign assets.
- **Content:** "30-Day Vocabulary Challenge" content; in-app event.
- **Growth:** Resolution push (App Store in-app event, TikTok/Reels challenge, TR "yeni yıl" angle). **Retro Sun Jan 3; G4 decision Mon Jan 4.**

### Launch week (W10), day by day

| Day | Tasks |
|---|---|
| Mon Dec 14 | Final listing check; confirm RevenueCat prod webhooks; dashboards green; support inbox/macros ready |
| **Tue Dec 15** | Public launch: creator posts (EN + TR); founder TikTok/IG/Shorts launch video; Reddit posts (respect each subreddit's rules, no spam); TR communities (X/Twitter TR, Instagram TR "ingilizce" pages, Telegram YDS groups); email waitlist #2 (App Store link + offer code); Turkish tech/startup media pitch |
| Wed Dec 16 | Reply to every review/comment; triage top bug; hotfix if crash-free <99% |
| Thu Dec 17 | Second creator wave; look at paywall→trial and onboarding drop-offs; first PPO read |
| Fri Dec 18 | Weekly KPI review; decide whether v1.0.1 ships Monday; decide next week's paywall test |
| Weekend | Content batch; monitor |

Product Hunt is low priority for this consumer-learner audience. Use it only as a cheap "link and backlink" play.

### Rituals
- Monday planning.
- Friday demo with a TestFlight build.
- Weekly KPI review from W9.
- Written go/no-go at each gate.

---

## 4. Team and roles

| | **A. Solo founder + freelancers** | **B. Two-person core (recommended)** | **C. Three-person team** |
|---|---|---|---|
| People | Founder (iOS dev + PM + growth) | Founder (iOS dev + PM) + **growth/content generalist** (TikTok-native, TR/EN) | iOS dev, designer/brand, growth + content |
| Designer | Contract, ~10-15 h/wk, W1-8 | Contract, ~10-15 h/wk, W1-8 | Full-time/equity |
| Content QA | Freelance Turkish English-teacher + LLM drafting | Same (generalist runs the pipeline) | Content lead |
| Pros | Cheapest, fastest decisions | Fixes the #1 solo failure mode (distribution); dev stays focused | Highest throughput, redundancy |
| Cons | Growth track is neglected; bus factor | Coordination cost; equity/comp conversation | Cash/equity heavy |
| Approx. cash through W12 (estimate) | $3-8k | $6-14k | $15-30k |

**Recommendation: B.** Hire or partner for growth/content in W1. If it must be solo, plan on W11 as a slip buffer and cap your content-engine output at ~1 video/day.

**Outsource**

| Item | Approach |
|---|---|
| Logo, icon, App Store screenshots, preview video | Designer or freelancer ($300-1,000) |
| Turkish reviewer + English-teacher QA | Freelance, ~20-40 h total |
| Legal docs | Template (Termly/iubenda) + short lawyer review ($0-800) |
| Creator/UGC videos | $50-300 per video or rev-share |
| Accounting/VAT/entity advice | Turkish accountant (V: consult a tax adviser) |
| Pre-rendered TTS | v1.2 (API cost) |

**Do not outsource:** the widget/WidgetKit code, analytics instrumentation, paywall logic, or the brand's voice and account ownership.

**Rough cash for a lean solo/2-person MVP (estimate).** Dev account $99/yr; tools mostly free tiers (RevenueCat free until a revenue threshold, V; PostHog free tier); designer $2-6k; content QA $500-1,500; LLM API <$200; creators $500-2,000; Apple Ads test $300-1,000; legal $0-800.

---

## 5. KPIs and analytics plan

### North star
**Weekly Active Widget Learners (WAWL):** users who, in a rolling 7 days, (a) have ≥1 widget installed per `getCurrentConfigurations()` or a recent timeline build, and (b) completed ≥5 learning actions (cards marked known/learning, quiz answers).

**Why.** A widget alone is passive. An in-app session alone ignores the habit surface. Phase 0/W7 beta should test whether "widget installed" correlates with D30 retention and trial→paid. If it does not, re-define the NSM.
Business metrics sit beside it: MRR, active trials, net revenue per install.

### Funnel metrics and starting targets (hypotheses; calibrate with the first ~1,000 installs)

| Stage | Metric | Starting target |
|---|---|---|
| Store | Impression → product page view | Track only |
| Store | Product page view → install (CVR) | ≥25% (V: verify against category baselines) |
| Activation | Install → onboarding start | ≥95% |
| Activation | Onboarding completion (reaches paywall) | ≥70% |
| Permissions | Notification opt-in (after primer) | ≥55% |
| Widgets | **Widget install rate** (≥1 widget within 24h of install) | ≥30% with guided walkthrough; stretch 45% (V) |
| Monetization | Paywall view → trial start | ≥8-12% |
| Monetization | **Install → trial start (D30)** | ≥6.5% (education median); target 8-12% with hard paywall |
| Monetization | **Trial → paid** | ≥30%; stretch 35-40% |
| Monetization | Install → paid (D35) | 2-4% (RevenueCat hard-paywall median is ~10.7% across all categories, so treat as a ceiling; V) |
| Monetization | Revenue per install (D14) | ≥$0.30 (education median); stretch $0.60 |
| Retention | D1 / D7 / D30 (all installs) | ≥30% / ≥14% / ≥6% |
| Retention | D30 for widget-installed users | ≥15% (should beat non-widget) |
| Engagement | Widget-active users | ≥25% of D7 actives |
| Quality | Refund rate | ≤4% of paid |
| Quality | Crash-free sessions | ≥99.5% |
| Quality | App Store rating | ≥4.5 |

### Illustrative unit economics
If install→trial is 8% and trial→paid is 30%, install→paid is 2.4%. At a ~$18 blended net revenue per payer (yearly $39.99 net of 15% commission, plus weekly churners), net revenue is about $0.43 per install. That supports a **CPI ceiling of ~$0.40 at break-even**: organic and low-CPI geographies only until the funnel proves better.

**Rule: no paid UA until install→paid ≥2.5% and D14 revenue per install ≥1.5× blended CPI test.**

### Day-30 decision tree

| Signal | Interpretation | Action |
|---|---|---|
| Install→trial <4% | Paywall or positioning problem | Run paywall/price experiments, rework onboarding value story |
| D1 <20% | Onboarding or content problem | Fix first session, notification timing, content quality |
| Widget install <20% | Walkthrough problem | Test E-15/E-16 |
| Trial→paid <25% | Value not felt in trial | Test trial length, trial timeline, reminder |
| Refund >5% | Billing clarity problem | Trial timeline UI; clearer price copy |
| All healthy | Continue | Plan v1.2; consider small paid UA tests |

### Super properties (attached to every event)
`anon_id` (UUID, no IDFA), `app_version`, `build`, `os_version`, `device_model`, `locale`, `storefront_country`, `native_language`, `cefr_level`, `goal`, `plan_state` (none/trial/paid/expired/refunded), `has_widget`, `widget_count`, `notif_status`, `days_since_install`, `install_source`, `experiment_flags{}`, `content_version`.

**Conventions.** snake_case `object_action` names; no PII; revenue and subscription lifecycle events come server-side from RevenueCat webhooks (source of truth) while the client emits funnel intent events; no ATT prompt (Apple Ads attribution via the AdServices token).

### Event plan (44 events)

| # | Event | Fires when | Key properties |
|---|---|---|---|
| **Lifecycle** | | | |
| 1 | `app_first_open` | First launch | install_source, campaign_token, locale, device_model, os_version |
| 2 | `app_open` | Foreground | launch_source (icon/widget/notification/deeplink), days_since_install, has_widget |
| 3 | `session_end` | Background | duration_s, words_viewed, screens_count |
| 4 | `app_updated` | First launch after update | from_version, to_version |
| 5 | `content_update_applied` | Remote JSON applied | content_version, words_added |
| **Onboarding** | | | |
| 6 | `onboarding_started` | Step 1 shown | variant |
| 7 | `onboarding_step_viewed` | Each step | step_id, step_index, variant |
| 8 | `onboarding_step_completed` | Each step | step_id, time_on_step_ms |
| 9 | `onboarding_goal_selected` | Goal chosen | goal |
| 10 | `onboarding_level_selected` | Level chosen | cefr_level, method (self/test) |
| 11 | `onboarding_language_selected` | Native language chosen | lang |
| 12 | `onboarding_topics_selected` | Topics chosen | topics[], count |
| 13 | `onboarding_daily_goal_selected` | Goal chosen | words_per_day |
| 14 | `onboarding_completed` | Finished | duration_s, steps_skipped |
| 15 | `onboarding_abandoned` | Backgrounded before finish | last_step_id |
| **Permissions and widgets** | | | |
| 16 | `notif_primer_viewed` | Primer shown | variant, placement |
| 17 | `notif_permission_result` | System prompt answered | granted, context |
| 18 | `notif_scheduled` | Schedule set | count, times[], per_day |
| 19 | `notif_opened` | Opened from notification | notif_type, word_id, local_hour |
| 20 | `widget_prompt_viewed` | Widget nudge shown | placement (onboarding/banner/settings), variant |
| 21 | `widget_tutorial_started` / `widget_tutorial_completed` | Walkthrough | step, variant |
| 22 | `widget_installed_detected` | Found via `getCurrentConfigurations` | family, kind, count_total, days_since_install |
| 23 | `widget_removed_detected` | Count drops | family, tenure_days |
| 24 | `widget_config_changed` | User edits widget | theme, rotation_interval, level, topic |
| 25 | `widget_tapped` | App opened via widget | family, word_id, entry_age_min |
| 26 | `widget_action_tapped` | Interactive button | action (known/review/next), family |
| 27 | `widget_refresh_report` | Reported on app open | refresh_count_24h, last_build_at, stale_hours |
| **Learning** | | | |
| 28 | `word_viewed` | Card shown ≥1s | word_id, source (feed/widget/notif/search/saved), level, topic, dwell_ms |
| 29 | `word_marked` | Status changed | word_id, status (known/learning/saved/unsaved), source |
| 30 | `word_audio_played` | Audio tapped | word_id, engine, source |
| 31 | `word_shared` | Share sheet | word_id, share_type (image/text), channel |
| 32 | `filter_changed` | Level/topic change | level, topics[], source |
| 33 | `search_performed` | Search | query_len, results_count |
| **Quiz and engagement** | | | |
| 34 | `quiz_started` | Quiz begins | mode, source, pool_size, question_count |
| 35 | `quiz_question_answered` | Each question | word_id, correct, response_ms, index |
| 36 | `quiz_completed` | Quiz ends | score, total, duration_s |
| 37 | `streak_updated` | Daily | streak_len, action (increment/reset/freeze) |
| 38 | `daily_goal_completed` | Goal met | words_goal, streak |
| 39 | `rating_prompt_shown` | SKStoreReview triggered | trigger, session_count, prompt_result |
| **Monetization** | | | |
| 40 | `paywall_viewed` | Paywall shown | paywall_id, placement, experiment_id, variant, trigger |
| 41 | `paywall_dismissed` | Closed or downsell shown | paywall_id, time_on_paywall_ms, dismiss_type |
| 42 | `paywall_plan_selected` | Plan tapped | plan, price_local, currency |
| 43 | `purchase_initiated` | StoreKit sheet opened | product_id, offer_type, price_local |
| 44 | `purchase_result` | Success/cancel/fail | product_id, result, error_code |
| **Server-side (RevenueCat webhooks)** | | | |
| S1 | `trial_started` | Webhook | product_id, trial_len, price, currency, country, paywall_id |
| S2 | `trial_converted` / `trial_cancelled` | Webhook | product_id, days_in_trial |
| S3 | `subscription_renewed` / `expired` / `billing_issue` | Webhook | product_id, renewal_index |
| S4 | `refunded` | Webhook | product_id, days_since_purchase |
| **Support and settings** | | | |
| S5 | `restore_tapped` / `restore_result` | Restore flow | result |
| S6 | `settings_changed` | Settings | key, old, new |
| S7 | `theme_selected` | Theme | theme_id, is_premium, source |
| S8 | `feedback_submitted` / `content_report_submitted` | Support | type, word_id |
| S9 | `error_logged` | Handled error | code, context (content_load/purchase/widget_sync) |

---

## 6. Experiment backlog (first 20)

**Sample-size reality.** At a baseline of ~8% and a +25% relative lift, you need ~2,900 users per arm (~6k installs per test). At 200 installs/day that is a month per test.
- Test **large swings** first.
- Run **one paywall test at a time** and use upstream proxies (paywall-view→trial, which has a higher base rate).
- Use Bayesian reads (RevenueCat Experiments or similar). Ship at ≥90% probability to beat control with guardrails intact.
- Guardrails for every test: D1 retention, rating, refund rate.

Priority: P0 = first 4 weeks after launch, P1 = weeks 5-10, P2 = later.

| ID | Area | Test | Hypothesis | Primary metric (guardrail) | Pri |
|---|---|---|---|---|---|
| E-01 | Paywall model | Hard vs soft (X after 3s) vs hard + downsell | Hard maximizes revenue per install; soft preserves ratings and word-of-mouth | Revenue per install D14 (rating, D1) | P0 |
| E-02 | Pricing | Yearly $29.99 vs $39.99 vs $49.99 | Education tolerates higher yearly prices (median $44.99) | Revenue per paywall view (trial→paid) | P0 |
| E-03 | Trial length | 3-day vs 7-day vs no trial on yearly | 7-day lets the widget habit form → higher trial→paid | Trial→paid (refund rate) | P0 |
| E-04 | Paywall placement | Before onboarding vs after onboarding vs after first widget install ("aha") | Paywall after personalization/aha converts better | Install→trial (onboarding completion) | P0 |
| E-05 | Notification primer | Custom value-prop primer vs direct system prompt | A primer raises opt-in | Opt-in rate (D7 retention) | P0 |
| E-06 | Widget prompt | Widget tutorial step in onboarding vs home-screen banner vs both | Early guided prompt maximizes widget install | Widget install within 24h (onboarding completion) | P0 |
| E-07 | Plan lineup | Weekly+Yearly vs Weekly+Monthly+Yearly vs Yearly-only | A simpler lineup lifts conversion; weekly anchors yearly | Install→paid (ARPPU) | P0 |
| E-08 | Onboarding length | 5 vs 8 vs 12 steps | More personalization raises commitment | Install→trial (completion) | P1 |
| E-09 | Paywall design | Feature list vs widget-preview hero vs "trial timeline" (day 0 → reminder → billing) | Timeline cuts early cancellations and refunds | Trial→paid, refund rate | P1 |
| E-10 | Personalization on paywall | "Your plan: 15 words/day to reach B2" vs generic | Personalized plan raises perceived value | Paywall→trial | P1 |
| E-11 | Downsell | 50% off yearly / weekly-only / Lifetime on close vs none | Downsell recovers dismissers | Revenue per paywall view | P1 |
| E-12 | Weekly price | $3.99 vs $4.99 vs $6.99 | Weekly price shifts mix toward yearly | ARPPU, plan mix | P1 |
| E-13 | Level method | Self-select vs 5-question placement test | Placement increases perceived personalization and retention | Onboarding completion, D7 | P1 |
| E-14 | Default widget content | Word + definition vs word-only with tap-to-reveal | Interactivity raises engagement | WAWL, widget tap rate | P1 |
| E-15 | Widget tutorial format | Looping video vs illustrated steps vs in-app confirm-check | Confirm-check raises completion | Widget install rate | P1 |
| E-16 | Store page | PPO: widget-first vs learning-outcomes vs Turkish-specific screenshots; icon test | Widget-first screenshots win cold traffic | PPV→install | P1 |
| E-17 | TR pricing | Local TRY price points (3 levels) | Lower TR price raises conversion enough to net out | Revenue per paywall view (TR) | P1 |
| E-18 | Social proof | Ratings/testimonials/learner count vs none | Social proof lifts paywall conversion | Paywall→trial | P2 |
| E-19 | Notification timing/copy | Fixed vs user-chosen vs learned time; teaser vs question copy | Learned time lifts open rate | Notif open rate, D7 | P2 |
| E-20 | Rating prompt timing | After 5th known word vs after quiz success vs D3 | Post-success prompting raises rating | Rating average, prompt→rate | P2 |

Other candidates held in reserve: widget rotation default (hourly vs 3-hourly vs daily), first screen after paywall, streak on/off and streak freeze.

---

## 7. Risk register (likelihood and impact: L/M/H)

| # | Risk | L | I | Mitigation | Early warning / owner |
|---|---|---|---|---|---|
| R1 | **App Review rejects under 4.3 (copycat/spam; saturated category)** | M | H | Distinct name/icon/UI, original content, unique features (interactive widget, SRS, CEFR, native gloss); one bundle ID only; no competitor names/assets; no template/white-label code; clear App Review notes; appeal path + request a call | Rejection note. Owner: founder |
| R2 | **Widget refresh limits** (budget ~40-70/day, dynamic; widget stale) | M | H | Dated multi-entry timelines; no network in widget; reload on foreground; weekly "stale widget" telemetry; clear in-app messaging; fallback entries | `widget_refresh_report.stale_hours` |
| R3 | **Content licensing / IP** | M | H | Permissively licensed word lists; original LLM-drafted text with provenance log; no scraping of commercial dictionaries; attribution page for CC BY sources; avoid exam trademarks (IELTS/TOEFL/YDS) in name/subtitle | Legal agent audit pre-freeze |
| R4 | **Market saturation / high CAC** | H | H | Organic-first; niche wedge (TR, exams, widget aesthetics); ASO; creator seeding; no paid UA until G4 rule | Install→paid <2% |
| R5 | **Refund rate / billing complaints** (weekly plans, hard paywall) | H | M | Clear price/renewal copy; trial timeline UI; pre-trial reminder; easy cancel link; support macros | Refund >5% |
| R6 | **Apple policy changes** (3.1.x, subscription rules, SDK requirements) | M | M | Monitor Apple Developer news; build with current required SDK; abstract paywall layer; track US anti-steering developments (V) as an optional margin lever, not a dependency | Policy notices |
| R7 | **Dependence on TikTok virality** (also regulatory risk) | H | H | Multi-channel (TikTok + Reels + Shorts), email list, Turkish communities, ASO, creator mix; target repeatable formats, not one viral hit | Views/installs from one source >60% |
| R8 | **Turkey pricing and FX** (lira depreciation, lower purchasing power, tax treatment, Apple price changes) | H | M | Set TR prices per territory explicitly; review monthly or at >10% FX move; test TR price (E-17); hold proceeds in USD where possible; confirm VAT/digital-service tax with an adviser (V) | TR revenue per install; FX |
| R9 | **Solo-dev schedule slip / burnout** | H | M | Cut order (section 2); Jan 5 fallback; weekly demo; growth/content support | G1 slip |
| R10 | **Content errors (wrong definition/translation)** → bad reviews | M | M | QA pipeline: auto-checks + 300-word teacher sample + native TR reviewer; "report a mistake" button; remote JSON hotfix | Report rate |
| R11 | **Retention cliff** (novelty fades after week 1) | H | H | SRS-driven rotation; streaks; notifications; WAWL tracking; interactive widget; v1.2 depth | D7 <10% |
| R12 | **Rating damage from hard paywall** | M | M | Pre-rating "happy?" filter; ask only after value; respond to reviews; E-01 soft arm | Rating <4.3 |
| R13 | **Incumbent response** (price cuts, copying our differentiator) | M | M | Speed of iteration; own the TR wedge and brand; avoid pure feature races | Competitor changelogs |
| R14 | **Privacy / legal** (GDPR, KVKK, age gating, privacy labels, EU trader status) | M | M | Minimal data; no ATT/IDFA; privacy manifest; 13+ positioning (not Kids category); Legal agent review (V) | Pre-submission checklist |
| R15 | **Account/payment setup delays** (Paid Apps Agreement, tax, bank, entity/D-U-N-S) | M | H | Start W1; test IAP in sandbox early; keep individual enrollment as the fastest path | Agreement status |
| R16 | **Third-party SDK/outage** (RevenueCat, analytics) | L | M | Cached offerings/entitlements; analytics failures non-blocking | Status pages |
| R17 | **Platform shift** (new iOS SDK, design language, widget API changes) | M | L | Native SwiftUI stays close to the platform; plan one compatibility pass per fall; check minimum iOS share (V) | Release notes |
| R18 | **Trademark/name conflict** | M | H | Check App Store, domains, handles, USPTO/EUIPO/TÜRKPATENT before locking (D4) | W3 |
| R19 | **Holiday timing** (reduced App Review capacity, ad cost spikes) | M | M | Submit Dec 1; Jan 5 fallback; no feature submissions Dec 22-Jan 1 | Review queue |
| R20 | **Battery/perf complaints from frequent widget refresh** | L | M | Conservative default rotation (1h); no network in widget; sample battery in beta | Review text |
| R21 | **Local notification cap (64 pending)** → silent users | M | M | Rolling schedule; top-up on open and via background refresh; consider remote push in v1.2 | Opt-in vs open rate |

---

## 8. Launch checklist

### Pre-launch (T-14 to T-1)
**Accounts and finance**
- [ ] Apple Developer account active; **Paid Apps Agreement, tax and bank complete**
- [ ] Small Business Program approved
- [ ] EU trader status declared if distributing in the EU (V)

**Build**
- [ ] RC build passes crash-free ≥99.5% on TestFlight
- [ ] Widget QA matrix done (≥10 devices/OS; Low Power Mode; Background App Refresh off)
- [ ] Sandbox purchase/trial/restore/expiry verified
- [ ] Built with the current required Xcode/SDK
- [ ] `PrivacyInfo.xcprivacy` for app and SDKs

**App Store Connect**
- [ ] Name, subtitle, keywords (100 chars), promo text, description (EN + TR)
- [ ] 6.9" screenshots + app preview video
- [ ] Age rating questionnaire
- [ ] Privacy policy, support and marketing URLs
- [ ] App Privacy labels
- [ ] Subscription group, products, localizations, review screenshots, prices incl. TR territory pricing
- [ ] Subscriptions attached to the version
- [ ] App Review notes with the widget how-to
- [ ] Manual release selected

**Growth**
- [ ] Offer codes created
- [ ] Apple Ads account ready (no spend yet)
- [ ] In-App Event drafted
- [ ] Featuring nomination submitted
- [ ] Press kit; creator briefs; 14-day content calendar
- [ ] Teaser email sent
- [ ] Support inbox and macros
- [ ] Dashboards: RevenueCat, PostHog funnels, App Store Connect Analytics

### Launch day (Tue Dec 15)
- [ ] Verify the live listing in EN + TR and a real-device install
- [ ] Production smoke purchase (with refund) to confirm webhooks
- [ ] Creator posts go live; founder launch video; waitlist email with offer code
- [ ] Reddit/TR communities posts (follow each community's rules)
- [ ] Every review and comment answered
- [ ] Hourly check of crash-free, paywall funnel and RevenueCat
- [ ] Triage and hotfix gate (crash-free <99% → hotfix)

### First 30 days
- **Week 1:** Daily dashboard review. v1.0.1 hotfix. Review responses. First PPO test.
- **Week 2:** E-01/E-07 live. Creator wave 2. Analyze funnel stage by stage with the decision tree.
- **Week 3:** v1.1 ships (+500 words, interactive actions, large widget, share cards). New Year campaign.
- **Week 4:** Retro and G4. Decide paid UA tests, v1.2 priorities and content packs.
- **Ongoing:**
  - Weekly KPI review.
  - Monthly refund and TR FX/price review.
  - Content error reports resolved within 48h.
  - Update the experiment log.

---

## 9. Decision log (founder decisions with recommended defaults)

| # | Decision | Options | **Recommended default** | Why | Decide by |
|---|---|---|---|---|---|
| D1 | Native vs cross-platform | Native SwiftUI / Flutter / RN | **Native SwiftUI, iOS-only** | Widgets, Lock Screen and App Intents are native regardless; fastest path to quality | W1 |
| D2 | Paywall model | Hard / soft / freemium | **Hard paywall after onboarding, trial on yearly; run soft arm in E-01** | Hard-paywall conversion is much higher in benchmarks; ratings guardrail | W3 |
| D3 | Price points (US) | Many | **Yearly $39.99 (7-day trial), weekly $4.99 (no trial)**; test $29.99/$49.99; no Lifetime or monthly at launch | Education yearly median is $44.99; weekly anchors yearly | W5 |
| D3b | TR pricing | Equalized tier / custom | **Custom TRY price, reviewed monthly or at >10% FX move**; test (E-17) | Lira depreciation and purchasing power | W5, then monthly |
| D4 | Name | Brandable vs keyword-descriptive | **Brandable, unique, ≤30 chars; keywords in subtitle** ("Vocabulary Widget & Word of the Day"); avoid "Vocabulary"/competitor-like names, and avoid IELTS/TOEFL/YDS in name | Reduces 4.3 and trademark risk. Shortlist 5, check App Store/domain/handles/trademarks | W3 |
| D5 | Category | Education / Reference / Productivity | **Education primary, Reference secondary** (V: confirm with ASO chart-depth analysis) | Matches the audience; check chart competition | W4 |
| D6 | Languages | UI and gloss | **EN UI at MVP; TR UI as Should (W6-7); gloss = TR + none.** Next gloss: ES, PT-BR, AR (v1.2) | Focus on the early market; ~150 strings is cheap | W5 |
| D7 | Minimum iOS | 16 / 17 / 18 | **iOS 17** (interactive widgets, StandBy); revisit with current adoption (V) | Differentiator needs iOS 17 | W1 |
| D8 | Backend | None / Firebase / custom | **None at MVP; CDN JSON for content** | Speed; local notifications only | W1 |
| D9 | Analytics + paywall tooling | PostHog/Firebase; RC Paywalls vs Superwall | **PostHog + RevenueCat (Paywalls + Experiments)**; add Superwall only if RC tests are insufficient | One SDK for a solo dev (V: check current pricing) | W2 |
| D10 | Content strategy | Licensed API / LLM-original + QA | **Permissive word lists + original LLM drafts + human QA + provenance log** | Licensing safety and control | W1 |
| D11 | Audio | AVSpeech / pre-rendered TTS | **AVSpeech at MVP; neural pre-render in v1.2** | Zero cost and offline | W4 |
| D12 | Developer account type | Individual / company | **Individual now (fastest); company later if B2B is on the table (app transfer is possible)** | Time to market | W1 |
| D13 | Launch plan | Single launch / soft + public | **Soft Dec 10, public Dec 15, New Year wave Dec 28; fallback Jan 5** | ASO indexing; resolutions peak | W6 |
| D14 | Paid UA | Now / after G4 | **None until the install→paid rule is met** | Unit economics | G4 |
| D15 | Free tier shape (if soft wins) | Limited words/day / one widget | **3 words/day + 1 widget + 1 quiz/day** | Keeps the habit loop, paywalls themes/levels | After E-01 |
| D16 | Device scope | iPhone / iPad | **iPhone-only target at MVP** | QA surface | W1 |
| D17 | Accounts | None / Sign in with Apple | **No accounts at MVP; CloudKit sync v1.2** | Smaller scope and privacy | W1 |
| D18 | Tracking posture | ATT or not | **No ATT prompt; no IDFA** | Avoids a conversion-hurting prompt | W2 |
| D19 | Team shape | A / B / C | **B** (section 4) | Distribution risk | W1 |

---

## 10. Sources and verification flags

- RevenueCat State of Subscription Apps 2026, Education breakout (download-to-trial 6.5% D30; yearly median $44.99; monthly median $9.99; trial length; revenue per install D14 $0.30): https://www.revenuecat.com/state-of-subscription-apps-2026-education
- RevenueCat State of Subscription Apps 2026 overview: https://www.revenuecat.com/state-of-subscription-apps
- Hard-paywall vs freemium download-to-paid (10.7% vs 2.1%) and trial-length conversion rates came through secondary write-ups, for example https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026.md and https://pricepush.app/blog/trial-to-paid-conversion-rate-benchmarks. These are **not verified against the PDF** and were not reported in the Education breakout.
- Apple, Keeping a widget up to date (typical 40-70 daily reloads, dynamic budget, foreground reloads not counted): https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date.md ; WWDC21 "Principles of great widgets": https://developer.apple.com/videos/play/wwdc2021/10048/
- Turkey App Store pricing: no current 2026 tier chart or tax notice was found. Check Apple's price tier chart in App Store Connect and ask a Turkish tax adviser (V). Context on Turkish tech prices and consumption taxes: https://turkishminute.com/2026/07/15/turkey-has-worlds-most-expensive-iphone-as-taxes-and-inflation-push-up-tech-prices/amp/

**Flags for other agents (V)**
- Current iOS adoption (minimum iOS 17 decision).
- Apple's holiday review schedule and featuring-nomination lead time.
- Store CVR baselines for Education.
- Current RevenueCat/PostHog pricing thresholds.
- Licensing of specific word lists (NGSL/NAWL/AWL/CEFR-J) and example-sentence sources.
- Turkish VAT/digital-services tax treatment of subscription proceeds.
- US anti-steering developments (web checkout lever).
- Turkish exam calendar hooks (YDS/YÖKDİL dates).
- EU trader status requirement.

### Critical Files for Implementation
The working directory (C:\Users\yusuf\OneDrive\Desktop\Widget Vocabulary- learn words) is empty, so there are no existing files to modify. The files to create first:
- C:\Users\yusuf\OneDrive\Desktop\Widget Vocabulary- learn words\docs\roadmap.md (this plan, saved as the master roadmap)
- C:\Users\yusuf\OneDrive\Desktop\Widget Vocabulary- learn words\docs\analytics-event-spec.md (section 5 events as a tracking-plan spec)
- C:\Users\yusuf\OneDrive\Desktop\Widget Vocabulary- learn words\docs\content-schema-and-pipeline.md (content schema, licence audit and QA pipeline)
- C:\Users\yusuf\OneDrive\Desktop\Widget Vocabulary- learn words\docs\experiment-backlog.md (section 6 as a living log)
- C:\Users\yusuf\OneDrive\Desktop\Widget Vocabulary- learn words\docs\decision-log.md (section 9 as a living log)
