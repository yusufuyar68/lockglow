# Review mining: "Widget Vocabulary: Learn Words" vs. vocabulary-widget competitors (as of 2026-10-10)

Method note: numbers marked **[measured]** come straight from Apple's public RSS/lookup endpoints, the Google Play review RPC, or the Reddit archive. Theme counts for the competitors come from my keyword classifier (regexes), not human coding. Spot-checks of 14 samples per theme showed roughly 85-95% precision for the monetization themes and 70-85% for content/widget themes. "Too-easy words" is poor, about 45% precision on Monkey Taps. All theme counts are lower bounds on recall. The target app's 56 reviews were coded by hand. Anything marked **[interpretation]** is my inference. Raw data and scripts are in `C:\Users\yusuf\AppData\Local\Temp\claude\C--Users-yusuf-OneDrive-Desktop-Widget-Vocabulary--learn-words\e927268b-3cbe-437d-b9e4-b39cf6e813db\scratchpad\reviews\` (`data\*.json`, `scripts\*.js`). Nothing was written to the project folder.

---

## 1. App IDs used

| App | trackId | Why |
|---|---|---|
| **Widget Vocabulary: Learn Words** (ORBIT STUDIOS TEKNOLOJI LTD STI, Istanbul; released 2026-06-24; v2.2.5; free, IAP weekly $9.99 / yearly $49.99) | **6775767149** | Exact title match in the iTunes search API (`term=widget+vocabulary`). The coordinator confirmed the ID. It is the target. |
| Vocabulary - Learn words daily (Monkey Taps) | 1084540807 | Main competitor. 354k ratings. |
| Vocabulary Builder by Atlas (SAYAN YAZILIM, Turkey) | 1438344260 | Same positioning (A1-C2 levels, exam packs, quizzes, paywall), same dev country, has widgets. |
| Word of the Day: Widget (Dogan Ekici) | 1536210624 | Largest pure "word widget" app. |
| Word of The Day Widget: Voca (Zipo Apps) | 6739798854 | Closest widget niche app. |
| Lingo Widget: Daily Vocabulary (Oguz Doruk) | 6740177041 | Closest widget niche app. |
| Vocabulary Builder by Learning (Learning Learn MCHJ) | 6738261069 | Look-alike. |
| WOTD - Word of the Day (Jin Quan Wong) | 6758013770 | Free, no-paywall counterexample. |
| Word of the Day・Vocabulary (Vocabulous) | 987136347 | Context: ads and streak model. |
| WordUp | 1365078730 | Context. |

Android package IDs: target `io.orbitstudios.widgetvocabulary`; Monkey Taps `com.hrd.vocabulary`.

Endpoints used:
- `https://itunes.apple.com/{cc}/rss/customerreviews/page={1..10}/id={ID}/sortby=mostrecent/json`
- `https://itunes.apple.com/lookup?id={ID}&country={cc}`
- Google Play `batchexecute` (UsvDTd) review RPC and the Play listing HTML.
- PullPush Reddit archive: `https://api.pullpush.io/reddit/search/{submission|comment}/`

---

## 2. Data volume per app and storefront [measured]

**Target (6775767149).** I pulled all 75 storefronts I could enumerate, including the ones the coordinator named (us, vn, tr, ua, kz, mx, jp, kr, co, kg, br, eg, uz, ca, gb), under both `mostrecent` and `mosthelpful`. I re-ran it with retries to rule out transient feed errors. Result: **56 text reviews in total**.

| Storefront | Text reviews |
|---|---|
| tr | 28 |
| vn | 9 |
| ua | 5 |
| us | 4 |
| gb | 3 |
| mx | 2 |
| fr, kr, cl, kz, jo | 1 each |

**jp has 0 text reviews** despite 32 ratings.

Star ratings (counts only; the API gives no star split) total **1,314 ratings across 59 storefronts, weighted average 4.56**:
- us 418 (4.72), vn 240 (4.52), tr 190 (4.37), ua 92 (4.45), kz 46 (4.74), mx 39 (4.82), jp 32 (4.22)
- co 23, kg 22, br 18, eg 17, kr 14, uz 14, ca 13, by 13

So only 4.3% of ratings carry text. The US has 418 ratings but just 4 text reviews.

| App | iOS text reviews pulled | Analysis window | iOS store ratings (all storefronts) |
|---|---|---|---|
| Monkey Taps | 1,761 (us 500, ca 324, au 184, gb 150, in 125, br 105, de 76, mx 69, za 43, es 39, tr 37, nz 26, ru 25, ae 24, sa 19, ie 15) | since 2025-10-10: n=1,123 | 354,079; avg 4.74 (us 219,574 at 4.77) |
| Atlas | 737 (us 300, tr 200, gb 78, ca 30, au 25, de 24, in 20, fr 18, other 42) | since 2024-01-01: n=521 | 42,729; avg 4.75 |
| Vocabulous | 1,481 (us 500, ca 481, gb 450, au 50) | since 2024-01-01: n=553 | 39,308; avg 4.67 |
| WordUp | 828 (us 500, ca 130, gb 89, au 59, in 50) | since 2024-01-01: n=597 | 17,523; avg 4.75 |
| Widget-niche pool | n=143 | all time | Dogan 2,733 ratings (4.19); Voca 562 (4.52); Lingo 246 (4.72) |

The widget-niche pool is Dogan 57, Learning 26, WOTD 23, Lingo 20 and Voca 17. Cortex "Words" returned only 1 review.

Caveats:
- RSS gives at most ~500 reviews per storefront, and only reviews with text.
- Monkey Taps' US sample covers 2026-04-22 to 2026-10-08. Recent months are therefore US-dominated, while older months come from other storefronts. Time trends are affected by this composition.

**Google Play [measured]:**
- Target: Play lists it with ~22 ratings, avg 3.0, 1,000+ installs, IAP $9.99-$49.99, last updated 2026-07-21. Only 5 text reviews were retrievable (details in section 8).
- Monkey Taps: Play avg 4.51 from 113,350 ratings. Star counts: 1★ 7,959, 2★ 2,173, 3★ 3,604, 4★ 10,071, 5★ 89,520. 5M+ installs, IAP $2.99-$169.99. I pulled 900 text reviews (us 600 from 2026-04-08 to 2026-10-09, gb 300).

---

## 3. Rating stats [measured]

| Text-review sample | n | Avg ★ | 1★ / 2★ / 3★ / 4★ / 5★ | % 1-2★ |
|---|---|---|---|---|
| **Target** (all) | 56 | **2.66** | 30 / 3 / 0 / 2 / 21 | 59% |
| Monkey Taps iOS (last 12 months) | 1,123 | 2.92 | 374 / 145 / 145 / 116 / 343 | 46% |
| Monkey Taps iOS (all time) | 1,761 | 3.12 | 507 / 202 / 235 / 206 / 611 | 40% |
| Monkey Taps Play | 900 | 3.03 | 314 / 88 / 72 / 106 / 320 | 45% |
| Atlas (2024+) | 521 | 4.32 | 50 / 10 / 36 / 50 / 375 | 12% |
| WordUp (2024+) | 597 | 4.24 | 62 / 21 / 43 / 57 / 414 | 14% |
| Vocabulous (2024+) | 553 | 2.82 | 212 / 71 / 54 / 35 / 181 | 51% |
| Widget-niche pool | 143 | 3.00 | 51 / 17 / 11 / 9 / 55 | 48% |
| ... Dogan only | 57 | 2.02 | 32 / 11 / 2 / 5 / 7 | |
| ... Voca only | 17 | 1.94 | | |
| ... Lingo only | 20 | 4.45 | | |
| ... WOTD only | 23 | 4.22 | | |
| ... Learning only | 26 | 3.65 | | |

Text-review average vs. all-star average:
- Target: 2.66 text vs 4.56 star-only. Gap of about -1.9.
- Monkey Taps: 3.12 text vs 4.74 star-only. Gap of about -1.6.
- **[interpretation]** Text reviewers are the unhappy tail, and the target's tail is the most negative.

Target, by version and month (small n):
- v2.2.3: n=19, avg 2.74
- v2.2.4: n=7, avg 3.29
- v2.2.5: n=24, avg 2.38
- Sep 2026: n=40, avg 2.92
- Oct 1-7: n=13, avg 1.69

Target, by storefront group:
- Turkey: 28 reviews, avg 3.21 (13 of them 1-2★).
- Everyone else: 28 reviews, avg 2.11 (20 of them 1-2★).
- Six Turkish 5★ one-line reviews were posted on the same day (2026-09-21), with more on 09-28. **[interpretation]** This looks like a prompt or campaign effect, but I cannot tell. Treat Turkish positivity with caution.

Monkey Taps, by month (since Oct 2025): avg stays within 2.5-3.15 with no clear trend, and Oct 2026 is 2.52 (n=27).

---

## 4. Theme tables

### 4a. Target app, hand-coded (n=56; multi-label)

| Theme | Count | % of 56 | Avg ★ | Implication |
|---|---|---|---|---|
| Any monetization complaint | 31 | 55% | 1.45 | 28 of 33 1-2★ reviews (85%) are monetization. This is the dominant pain. |
| "Nothing works without paying" / everything locked | 22 | 39% | 1.05 | The free tier gives no visible value. |
| Price too high (weekly, regional, vs competitors) | 14 | 25% | 1.93 | $9.99/week annualizes to about $520. Vietnam, Turkey and Kazakhstan reviewers cite local prices. |
| Pay demanded before value / bait-and-switch / ad mismatch | 8 | 14% | 1.00 | Paywall appears after onboarding or before any word is shown. |
| Widget itself paywalled | 5 | 9% | 1.00 | Core promise ("widget") is gated. This is the sharpest brand-promise break. |
| Free-trial / auto-charge / refund | 4 | 7% | 1.25 | Weekly renewal after trial; one Kazakhstan review says the 2,000 tenge charge came despite the "free week". |
| Weekly plan specifically | 3 | 5% | 1.33 | |
| Level mismatch / words too hard | 3 | 5% | 1.00 | Onboarding said "know a little" but C2 words followed. A Turkish review calls the words ones native speakers don't know. A Ukrainian review says beginner words are too hard and pronunciation unclear. |
| Praise: generic ("great", "useful") | 15 | 27% | 5.00 | |
| Praise: easy and fast | 4 | 7% | 5.00 | |
| Praise: price justified | 3 | 5% | 5.00 | A Turkish user says it was worth the fee after trying it. |
| Praise: widget exposure all day | 2 | 4% | 5.00 | |
| Praise: IELTS prep | 1 | 2% | 5.00 | |
| Praise: breadth of word pool | 1 | 2% | 5.00 | |
| Praise: UI | 1 | 2% | 5.00 | |
| Singles | 1 each | | | Hard UI; content too small (Vietnam); age-inappropriate "sexual" word list shown in free section; no "mark known" (4★); wants auto-generated exam deck (Korea); wants a one-time purchase (Ukraine). |

### 4b. Monkey Taps iOS, last 12 months (n=1,123, regex classifier)

| Theme | Count | % | Avg ★ | % of 1-2★ reviews that mention it | Implication |
|---|---|---|---|---|---|
| Monetization (any) | 376 | 33.5 | 1.96 | 52% | Even the category leader gets punished for pricing. |
| Paywall / locked features | 165 | 14.7 | 2.19 | 21% | Saved words, practice, quiz results, search, themes and widget customization are gated. |
| Free-trial / billing / refund | 145 | 12.9 | **1.40** | 25% | The most damaging single theme. Reviewers say the promised pre-renewal reminder never came and an annual charge hit after a 3-day trial. |
| Price too high | 128 | 11.4 | 1.74 | 20% | Complaints are about $47-$60 per year. |
| Bait / long onboarding before price reveal | 66 | 5.9 | 1.53 | 11% | Reviewers describe 10-20 minute setups. A quiz whose results are paywalled is a recurring grievance. |
| Widget mentioned | 83 | 7.4 | 2.84 | 7% | Mixed: praised, but also tied to complaints. |
| Lock-screen mentioned | 25 | 2.2 | 3.48 | 1% | Mostly positive. |
| Widget problem (blank, not rotating, stuck) | 13 | 1.2 | 3.15 | 1% | Low recall in a regex but real. |
| Widget customization behind paywall | 21 | 1.9 | 2.24 | 2% | |
| "Just use a dictionary / ChatGPT / Merriam-Webster" | 66 | 5.9 | 2.33 | 8% | Users compare the paid app to free substitutes. |
| Save / hide / mark known / search / custom words | 64 | 5.7 | 2.94 | 5% | |
| Notifications (any) | 62 | 5.5 | 2.37 | 7% | |
| ...spam / too frequent | 22 | 2.0 | 2.09 | 3% | |
| Pronunciation / audio | 61 | 5.4 | 3.21 | 3% | |
| Definition / content errors | 45 | 4.0 | 2.33 | 6% | |
| AI-generated content or voice (negative) | 30 | 2.7 | **1.83** | 5% | 80% of these are 1-2★. |
| Repetition of words | 29 | 2.6 | 2.21 | 3% | |
| Words too obscure / archaic | 23 | 2.0 | 1.91 | 3% | Includes made-up "Dictionary of Obscure Sorrows" words. |
| Sexual / inappropriate words | 22 | 2.0 | **1.59** | 4% | 86% are 1-2★. Reviews from 2026 say the app is rated 4+. The current listing says 13+. |
| Ads / pop-ups | 39 | 3.5 | 2.69 | 4% | |
| Upsell nagging | 25 | 2.2 | 2.00 | 4% | |
| Customization / themes | 38 | 3.4 | 3.08 | 3% | |
| Bugs / crashes / battery | 36 | 3.2 | 2.50 | 3% | |
| Languages / translation | 31 | 2.8 | 2.77 | 3% | |
| Support unreachable | 17 | 1.5 | 1.47 | 3% | 94% are 1-2★. |
| Privacy / data | 13 | 1.2 | 2.23 | 2% | |
| Sync / account | 8 | 0.7 | 1.63 | 1% | |
| Streaks / gamification | 8 | 0.7 | 2.88 | 1% | |

Praise in Monkey Taps 4-5★ reviews (n=459, low recall):
- Vocabulary growth: 30%
- Design/UI: 7%
- Simplicity: 4%
- Content quality: 3%
- Widget love: 3%
- No ads: 3%

Trend [measured; composition caveat above]:
- Trial/billing complaints rose from 6.7% of reviews (Oct-Dec 2025) to 14.5% (May-Sep 2026).
- Sexual-content complaints first appear in Feb 2026 and run 2-4 per month after that.
- AI-content complaints appear from Mar 2026 and run 2-7 per month after that.

### 4c. Cross-app matrix: % of all reviews mentioning the theme (% of 1-2★ reviews mentioning it in parentheses)

Windows are Monkey Taps 12 months; Atlas, Vocabulous and WordUp since 2024-01-01; pool all time.

| Theme | Monkey Taps | Atlas | Vocabulous | WordUp | Widget pool |
|---|---|---|---|---|---|
| Monetization (any) | 33.5 (52) | 15.9 (40) | 28.8 (44) | 8.0 (27) | 9.1 (7) |
| Paywall / locked | 14.7 (21) | 10.0 (23) | 9.9 (16) | 1.7 (6) | 4.9 (1) |
| Price too high | 11.4 (19) | 5.2 (12) | 11.8 (19) | 1.7 (5) | 2.8 (4) |
| Trial / billing | 12.9 (25) | 2.5 (13) | 9.6 (17) | 2.3 (12) | 0.7 (1) |
| Bait / onboarding | 5.9 (11) | 1.3 (7) | 3.8 (7) | 1.2 (6) | 2.1 (3) |
| Ads | 3.5 (4) | 4.8 (13) | **12.8 (16)** | 1.7 (5) | 9.8 (10) |
| Streaks / gamification | 0.7 (1) | 0.8 (2) | **8.3 (10)** | 0.3 (0) | 0 |
| Too-easy words | 1.2 (2) | 1.2 (2) | 1.3 (2) | 0.3 (0) | **13.3 (26)** |
| Repetition | 2.6 (3) | 2.7 (0) | 2.0 (2) | 0.8 (2) | **6.3 (10)** |
| Definition errors | 4.0 (6) | 0.4 (3) | 1.8 (2) | 0.8 (2) | **7.0 (13)** |
| AI content | 2.7 (5) | 3.5 (8) | 3.3 (4) | **5.0 (12)** | 4.2 (6) |
| Sexual content | 2.0 (4) | 0 | 0 | 0.8 (2) | 0.7 (1) |
| Pronunciation | 5.4 (3) | 1.2 (2) | 2.5 (2) | 2.3 (6) | **7.7 (3)** |
| Widget mentioned | 7.4 (7) | 1.0 (0) | 3.8 (6) | 0.2 (0) | **16.8 (9)** |
| Bugs / crashes | 3.2 (3) | 3.3 (12) | 6.1 (6) | **10.6 (42)** | 1.4 (1) |
| Sync / account | 0.7 (1) | 2.1 (8) | 2.2 (3) | 3.2 (7) | 0.7 (0) |
| Languages / translation | 2.8 (3) | 2.5 (0) | 0.4 (0) | 1.5 (2) | **7.7 (6)** |
| Quiz / practice | 6.1 (5) | **13.4 (17)** | 6.5 (4) | 5.2 (1) | 4.2 (0) |

Dogan, read by hand: 28 of 57 reviews (49%) complain the words are too basic (avg 1.46★). Another 9 mention ads.

---

## 5. Representative examples (paraphrased; source tag = app / storefront / stars / date)

**Paywall and bait-and-switch**
- Target / vn / 1★ / 2026-10-01: The paywall appeared before any trial. The onboarding survey asked level, yet C2 words came back anyway. The free section surfaced a sexual-topic word list, so the reviewer asks if the app targets only adults.
- Target / tr / 1★ / 2026-10-01: "Money trap." Asks for payment for everything. The reviewer wishes at least one widget were free.
- Target / ua / 1★ / 2026-09-30: Wasted time finding out nothing is usable without a subscription.
- Target / us / 1★ / 2026-08-02 (Ukrainian text): Payment was demanded before they even knew what was in the app. The ad doesn't match reality.
- Monkey Taps / us / 1★ / 2026-09-17: A bait-and-switch on a "free" app: a profile is built before the reviewer learns it is a subscription.
- Monkey Taps / us / 2★ / 2026-09-26: The app lets you save words but charges to view them.
- Monkey Taps / us / 2★ / 2026-09-24: Took a free quiz, then was told the results cost money.

**Weekly price and billing**
- Target / tr / 1★ / 2026-09-15: A weekly price of about 500 TL is outrageous.
- Target / tr / 2★ / 2026-10-02: Was charged another week after the free trial ended, and asks for a refund.
- Target / kz / 1★ / 2026-09-23: Promised a free week, but 2,000 tenge was charged.
- Monkey Taps / us / 1★ / multiple, Jul-Oct 2026: Chose the "remind me before trial ends" option, never got the reminder, and was billed $36-$64 for a year.
- Monkey Taps / us / 1★ / 2026-09-27: Signed up for a 3-day trial, was charged for the full year without warning, and the refund request was denied.

**Level and difficulty**
- Dogan / us / 1★: Today's word was "twelve". Reviewer deleted the app.
- Dogan / us / 2★ (2025): Set to the most advanced setting and still got "cosmic".
- Voca / sg / 1★ / 2026-08-05: Same words repeat, and "guest house" appears at the advanced level.
- Monkey Taps / us / 3★ / 2026-09-04: Great concept, but difficulty needs a finer scale than beginner/intermediate/advanced.
- Monkey Taps / us / 1★ / 2026-07-12: The placement test shows exotic words, but the lessons are 5th-grade level.

**Content accuracy and AI**
- Monkey Taps / us / 1★ / 2026-09-30: The widget showed a word that doesn't exist, apparently invented from phonetics.
- WOTD / us / 3★ / 2026-09-10: The word of the day is obsolete and the context would be odd to use.
- Learning / ie / 1★ / 2026-08-08: The app invented a word, and the etymology box contained obvious AI chatter.
- Voca / gb / 1★ / 2025-09-04: A wrong definition of "diligent".
- Monkey Taps / us / 1★ / 2026-09-16: The AI voice mispronounces words such as "solace".

**Inappropriate content**
- Monkey Taps / us / 1★ / 2026-07-20: Constant sexual terms despite a 4+ rating. Reviewers want to turn the category off; one tried blocking topics and says it did not work.

**Widget behavior**
- Monkey Taps / us / 3★ / 2026-05: Lock-screen and home-screen widgets show different words. Wants one synchronized word.
- Monkey Taps / us / 3★ / 2026-08: Wants to choose how long a word stays in the widget.
- Monkey Taps / us / 4★ / 2026-01: Home-screen widget changes too often and frequency can't be set. The FAQ says it can.
- Vocabulous / us / 2★ / 2026-08-12: The widget shows a word from August 4 instead of the current word.
- Vocabulous / us / 2★ / 2026-08-12: "False advertising." Advertised as a new word daily in the widget, but it forces opening the app.
- Learning / us / 5★ / 2026-08-31: The home-screen widget shows only a white screen.

**What users love**
- Target / us / 5★ / 2026-07-07 (v1.1.2): The only vocab app they stuck with because words on the home screen keep appearing all day. Practices a few minutes in the app.
- Target / tr / 5★ / 2026-09-22: Widget learning is practical because words appear all day without opening the app.
- Target / tr / 5★ / 2026-09-23: IELTS prep "lifesaver."
- WOTD / us / 5★ (multiple, 2026): No ads, no paywall, no account, straight to the word. Reviewers explicitly praise this.
- Monkey Taps / us / 5★ / 2026-08-07: Sees the hourly update while brushing teeth or waiting in line.
- Atlas / us / 5★ / 2026-09-13: Pretty regularly changing widget images, plus words that stick.

---

## 6. Ranked feature requests

Counts are explicit-request sentences, matched by regex across Monkey Taps all time, Atlas, Vocabulous, WordUp and the widget pool. Spot-checked precision is about 65-75%, so treat these as order-of-magnitude. Target-specific requests are listed after the table.

| Rank | Request | Count |
|---|---|---|
| 1 | Richer entries: etymology/roots, more examples and senses, synonyms/antonyms, idioms, images, definition sources | 84 |
| 2 | More free features / free practice / longer trial (stop paywalling basics) | 44 |
| 3 | Pronunciation: IPA/phonetic text, accent choice (UK), fix/add audio, audio for example sentences | 35 |
| 4 | Add / import / export / edit own words and lists (CSV, Excel, PDF, Anki) | 34 |
| 5 | Practice / test saved words, flashcards, spaced repetition, typed answers | 31 |
| 6 | Report an error / flag a word; curated, sourced definitions | 31 |
| 7 | More languages / translations into native language | 27 |
| 8 | Widget control: change interval, "one word a day", keep the same word, sync lock and home screen | 27 |
| 9 | Theming / widget styles, fonts, wallpapers, icons | 22 |
| 10 | Search / look up any word and add it | 21 |
| 11 | Sync / login / backup / iPad / Mac / Watch | 21 |
| 12 | Mark known / skip / hide / "not interested" | 17 |
| 13 | One-time purchase / lifetime / monthly option / cheaper plan | 16 |
| 14 | Finer difficulty / topic / category control (including hiding sexual or "made-up" categories) | 16 |
| 15 | Working renewal reminder, easy cancel, refund path | 14 |
| 16 | Notification control (times, volume, turn off streaks) | 10 |
| 17 | Skip or shorten onboarding; show price up front; show quiz results before paying | 8 |

Target-specific requests, hand-coded:
- A free widget (5 reviews).
- Mark known words (1).
- Auto-generated exam deck, e.g. TOEIC (1).
- A one-time purchase instead of a subscription (1).
- Regional pricing (1).

Beyond the explicit list, the complaint themes in section 4 imply further requests:
- A free widget.
- A no-bait onboarding.
- Level calibration.
- Safe categories.

---

## 7. Competitor comparison of pain points [measured, plus interpretation]

- **Monkey Taps (leader).**
  - Praised for design, simplicity and the lock-screen widget.
  - Pain points: trial/billing (12.9%, avg 1.40), paywalled basics, 4+ vs sexual vocabulary, AI voice and content, and widget frequency control.
  - The widget itself is free: a Reddit commenter says it works without a subscription (r/iOSsetups, 2025-10-26), and reviews say customization is the paywalled part.
  - **[interpretation]** Monkey Taps' widget is the funnel, while the target's widget is the paywalled product. That difference explains much of the target's 1★ rate.
  - Privacy: a law firm lists Monkey Taps and its Vocabulary app in a possible class-action investigation over alleged tracking (allegations only): https://www.ahdootwolfson.com/blog/monkey-taps-apps-class-action-investigation/

- **Atlas (structured learner).**
  - Text avg 4.32, with only 12% 1-2★.
  - Praised for multi-modal quizzes, exam prep, and the TR/YDS audience.
  - Complaints: ads gating content (13% of negatives), paywall, AI sentences, account loss or sync (8%), no skip for known words, and no import.
  - **[interpretation]** Depth and a real learning loop buy goodwill even with a paywall.

- **Vocabulous.**
  - Avg 2.82 since 2024.
  - Pain: forced ads and coins to see the daily word, "missed word" streak bugs, and heavy gamification (8.3% mention, avg 2.22).
  - **[interpretation]** This is the cautionary tale for streak-plus-ad monetization of a word-of-the-day product.

- **WordUp.**
  - Avg 4.24.
  - Pain: bugs/crashes (10.6% of reviews, 42% of negatives), AI images, login and account problems, and removed features.

- **Widget niche (Dogan, Voca, WOTD, Lingo, Learning).**
  - Dogan and Voca (avg 2.02 / 1.94): words too easy, repeated, wrong. 49% of Dogan reviews say too basic.
  - Lingo (4.45): praised for the widget, with few complaints. Requests: custom words, Latin and Vietnamese, iPad. One reviewer says once 90 words are marked known the widget gets stuck.
  - WOTD (4.22): praised for no ads, no paywall, no account, and a responsive developer. Complaints: some definitions look AI-written, with obsolete words.

- **Target.**
  - Pain is almost entirely monetization: 55% of reviews, 85% of negatives.
  - Little product criticism so far: content, level fit and widget behavior appear in only a handful.
  - It has far less text volume than Monkey Taps, so some themes seen elsewhere (accuracy, repetition, notifications) are not yet measurable.

---

## 8. Off-store discussions

**Google Play, target [measured].** The 5 retrievable reviews:
- 3 are 1★. They say the widget is paid (Portuguese), that you can do almost nothing unless you buy (Turkish), and that hiring an English teacher would be more economical.
- 2 are 5★: "quite helpful", and good/useful but very expensive.
- The same paywall pattern appears on Android.

**Reddit.** Reddit blocks direct access (HTTP 403) and the search tool can't index it. I used the PullPush archive, which is incomplete and promo-heavy. Nothing relevant came up for r/ApplyingToCollege or r/apple. The r/GRE hits were old posts about Magoosh and other GRE vocab apps, not widgets.

1. **r/ChineseLanguage, 2026-06-28** (a free Chinese lock-screen widget): https://reddit.com/r/ChineseLanguage/comments/1uhygi7/chinese_lockscreen_widget_and_everyone_should_use/
   - Users thanked the developer because other widget apps "charged a bunch."
   - The thread asks for interval options down to 5 minutes, a pinyin toggle, traditional characters, and example sentences on the lock screen.
   - A commenter argues the free tier is not truly free, and another wishes the free/paid split were clearer in the listing.
2. **r/LearnJapaneseNovice, 2026-07-08** (kanji lock-screen widget): https://reddit.com/r/LearnJapaneseNovice/comments/1uqrkfy/i_kept_forgetting_kanji_so_i_built_a/
   - A $25 lifetime price was attacked for being "pay for a widget." The free tier showed a bare character without definitions, and users compared it to free alternatives (Ringotan) and to Anki.
   - A user asked for a different word on every unlock.
3. **r/iosapps, 2026-06-24** (dictionary widgets): https://reddit.com/r/iosapps/comments/1ueeihn/would_you_use_dictionary_widgets_to_help/
   - Replies like "I like the passive exposure idea."
   - Requests: spaced repetition, Apple Watch, gamified checking of widget words, different card styles on the home screen, and more languages.
4. **r/EnglishLearning, 2025-12-14:** https://reddit.com/r/EnglishLearning/comments/1pm1zg5/is_there_a_vocabulary_mobile_app_that_only_does/
   - Wants an app with just "my own words + quizzes" under $5/month.
   - Already tried Vocabulary, Word of the Day, Wurrd and Vocab, and found them too bloated or too subscription-heavy.
5. **r/vocabulary, 2025-01-04:** https://reddit.com/r/vocabulary/comments/1ht9wp5/looking_for_free_vocabulary_app_alternative_to/
   - Likes the Monkey Taps notifications and type choice but wants a free alternative, or a small one-time fee.
6. **r/languagelearning, 2026-04-04:** https://reddit.com/r/languagelearning/comments/1sca7uu/what_vocabulary_app_did_you_actually_see/
   - Recurring view: vocabulary memorization alone doesn't stick.
   - Commenters recommend Anki (spaced repetition) and learning in context.
7. **r/iosapps comment, 2025-07** (https://reddit.com/r/iosapps/comments/1lqgngs/built_a_flashcard_app_for_myself_turned_out/): A user says WordUp (paid), Vocabulary.com and a dictionary app all failed them. They want widgets of random words from collections, quick add, a share-sheet lookup, and pronunciation.
8. **r/iosapps, 2026-09-09** (https://reddit.com/r/iosapps/comments/1wbvwbx/tired_of_duolingo_streaks_i_built_a/): Demand for no streaks and no notification pressure for passive learning.
9. **Other mentions.** Monkey Taps is recommended in r/writing (2023) and r/AstarionBG3 (2025-12), the latter for frequency-settable lock-screen words. r/iOSAppsMarketing reports Monkey Taps' revenue at about $12M a year (unverified): https://reddit.com/r/iOSAppsMarketing/comments/1n436do/how_a_littleknown_spanish_app_studio_monkey_taps/

**Twitter/X and YouTube.** Not retrievable. WebSearch returned no X posts. YouTube page fetches returned only titles, so I found generic "best vocabulary apps" videos but no usable commentary on these apps.

**Blogs and roundups** (vendor-written ones are flagged):
- SlashGear praises Monkey Taps' interface and widgets but calls the voice robotic: https://www.slashgear.com/1544971/apps-to-enhance-vocabulary-2024/
- mindomax (prices checked 2026-09-26) lists Monkey Taps at $59.99/year and 10 tiers, and says it focuses on new words rather than testing old ones. It lists Atlas as $10.99-$49.99/year or $74.99 lifetime, and WordUp Pro at $49/year. https://www.mindomax.com/best-vocabulary-apps
- Glancealot (a competing vendor) argues widgets can't test recall and that bulk import is a gap: https://glancealot.app/articles/vocabulary-lock-screen-widget-apps/

---

## 9. Key insights for building a better app (top 15, concrete)

1. **Make at least one lock-screen and one home-screen widget free and ongoing.**
   - Evidence: 5 of 56 target reviews are explicit "widget is paid" complaints, all 1★, and Play has the same.
   - Monkey Taps' free widget is its funnel, and Reddit praises free widgets.
   - Charge for depth: packs, practice, themes, and extra widgets.
2. **Show value before the paywall.**
   - Show the first word and a working widget before any survey or price screen. 14% of target reviews are "pay before value" and 85% of Monkey Taps' bait complaints are 1-2★.
   - Keep onboarding under 2 minutes and make the price and trial terms visible on the first paywall screen.
3. **Drop the $9.99/week headline.**
   - It annualizes to about $520 against a $49.99 yearly price. Weekly drives refund complaints.
   - Lead with annual plus a lifetime option, since "buy not rent" requests recur across apps.
   - Localize pricing: Turkey, Vietnam, Ukraine and Kazakhstan supply 77% of the target's text reviews and 43% of its ratings.
4. **Make trials trustworthy.**
   - Monkey Taps' trial/billing complaints average 1.40★ and rose from 6.7% to 14.5% of reviews.
   - If you promise a pre-renewal reminder, make it fire. Add an in-app cancel button and a visible refund path, and avoid trial-to-annual auto-billing without a clear screen.
5. **Calibrate level and respect it.**
   - A Vietnamese 1★ chose "know a little" and got C2. Dogan is 49% "too basic," and Monkey Taps' "advanced" still shows easy words.
   - Add an "I don't know" button in the placement test, finer levels, per-widget level, and a feedback loop (too easy / too hard).
6. **Add "I know this word" / skip / hide.**
   - It is a top request across Monkey Taps and Atlas and the target's only constructive 4★ review.
   - Without it, repetition and too-easy complaints persist.
7. **Curate content and cut AI errors.**
   - Definition errors, made-up words and AI content drive 1-2★ reviews (80% of AI-content mentions in Monkey Taps).
   - Use human- or dictionary-validated definitions with sources, and only include real words. Make obscure or fictional lexicons opt-in, and add a "report error" button.
8. **Ship content safety.**
   - Monkey Taps' sexual-word complaints (86% 1-2★) arose from a 4+ rating and unfilterable categories. A target review also flags a sexual-topic list in the free section.
   - Default to a safe category set, offer category opt-outs on the widget, and rate the app correctly (Monkey Taps is now 13+).
9. **Give widget rotation controls and make refresh reliable.**
   - Offer interval choice (5 minutes to 24 hours), "keep this word N hours," a one-word-a-day mode, lock/home sync, and a no-repeat cool-down.
   - Test blank, stale and cut-off text states. Widget-mentioning reviews average 2.99★, and stuck, stale and white-screen widgets recur.
10. **Fix pronunciation.**
    - Use native-quality audio, IPA text, and a UK/US accent choice.
    - Pronunciation errors from AI voices erode trust, and a target beginner flagged pronunciation as unclear.
11. **Add search and capture.**
    - Include dictionary lookup, add-any-word, a share-sheet capture flow, and custom lists with import (about 55 explicit requests, ranks 4 and 10).
    - This is also the gap Reddit threads describe ("my own words plus quizzes under $5").
12. **Localize.**
    - Add native-language glosses (Turkish, Vietnamese, Ukrainian, Russian, Spanish) with localized store listing, onboarding and paywall. The app is English-only today.
    - Add goal-based auto decks (TOEIC, IELTS, YDS), since a Korean reviewer asked for exactly that and a Turkish reviewer credits IELTS prep.
13. **Keep the learning loop light and no streak by default.**
    - Offer quizzes on saved words with spaced repetition, but don't force streaks. Vocabulous' streak and ad monetization drew 8.3% of reviews at 2.22★.
    - Give notification time and volume controls.
14. **Don't move features behind the paywall after launch.**
    - Reviewers of Monkey Taps, Vocabulous and WordUp complain about previously free items going premium.
    - Keep saved words and basic review free, and grandfather free users.
15. **Build trust: support, sync, privacy.**
    - Show a support email and fast replies; WOTD's developer responsiveness earned 5★.
    - Add iCloud sync and Restore Purchases (account-loss and sync reviews are 3% of reviews and 8% of Atlas's negatives).
    - Position privacy positively; WOTD gets praise for "no tracking," and Monkey Taps faces class-action scrutiny.

Caveats:
- The target text sample is small (n=56).
- The Turkish 5★ cluster may be a prompt or campaign effect.
- Text reviews over-represent unhappy users.
- Regex counts are approximate, not human-coded.
- Reddit coverage came from an incomplete archive.
- Twitter/X and YouTube produced nothing usable.
