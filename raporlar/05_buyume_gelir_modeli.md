# Growth and monetization research: vocabulary/widget habit-subscription apps (as of 2026-10-10)

**Labels used throughout**
- **[S]** = number appears in the cited source (many sources are vendor or third-party and modeled).
- **[Est]** = third-party modeled revenue or download estimate (not company-disclosed).
- **[Calc]** = my arithmetic from cited inputs.
- **[A]** = my assumption or inference.

**Method caveats**
- Page contents were extracted through fetch summaries. Where sources conflict, I show both.
- I also queried Apple's public iTunes Lookup and RSS chart endpoints on 2026-10-10. Raw files are in the scratchpad `r/` folder and `tr_*.json`.
- I did not find any Monkey Taps founder interview, podcast, or X thread with real numbers. I also found no Mobbin, Growth.design or Retention.blog teardown of these apps. All onboarding teardowns below are from ScreensDesign.
- A "Widget Vocabulary: Learn Words" listing by Orbit Studios (Turkish-registered) exists. It was released 2026-06-24 ([iTunes lookup](https://itunes.apple.com/lookup?id=6775767149&country=tr)). I treat it as "your app" for the competitive snapshot below. Please confirm.

---

## 0. Headline findings

1. **Monkey Taps template [S].**
   - 22 to 41 onboarding questions, with a name/age/gender/goal quiz first.
   - A notification "warm-up" screen with time-window controls, then the iOS prompt.
   - Cosmetic personalization (icon, theme, voice).
   - A cross-app bundle upsell.
   - A paywall with a 3-day trial and a reminder toggle.
   - A widget-install prompt *after* purchase.
   - Sources: [Vocabulary](https://screensdesign.com/apps/vocabulary-learn-words-daily/), [Motivation](https://screensdesign.com/showcase/motivation-daily-quotes), [I am](https://screensdesign.com/apps/i-am-daily-affirmations/).
2. **Your position in Turkey (chart snapshot 2026-10-10).**
   - Widget Vocabulary is **#3 in Turkey Education top free** and **#17 in top grossing** ([TR free RSS](https://itunes.apple.com/tr/rss/topfreeapplications/limit=100/genre=6017/json), [TR grossing RSS](https://itunes.apple.com/tr/rss/topgrossingapplications/limit=100/genre=6017/json)).
   - Your TR rating count is only 190 ([lookup](https://itunes.apple.com/lookup?id=6775767149&country=tr)).
   - Monkey Taps' Vocabulary has no Turkish localization (6 languages: EN/FR/DE/IT/PT/ES; the TR storefront title is English) and does not appear in the TR top-100 grossing list ([lookup](https://itunes.apple.com/lookup?id=1084540807&country=tr)).
3. **Education benchmarks.**
   - Download-to-trial 6.5% median ([RevenueCat Education](https://www.revenuecat.com/state-of-subscription-apps-2026-education)).
   - 1-year LTV $45.10 and install LTV $1.06 ([Adapty 2026](https://adapty.io/state-of-in-app-subscriptions-report/)).
   - Education has the highest yearly price median of any category, $44.99 ([RevenueCat Education](https://www.revenuecat.com/state-of-subscription-apps-2026-education)).
4. **Paid Apple Ads do not pay back in my base-case model unless install-to-paid is above about 4.2% (emerging markets) or about 8.3% (US)** ([Section 6](#6-unit-economics-model-illustrative)). Organic (ASO, localization, creators) is the lever.

---

## 1. Onboarding teardown

### 1.1 Monkey Taps "Vocabulary – Learn words daily" (ScreensDesign video chapters)

Step count is inconsistent within the source: the page says 20 in one place and 22 in another ([ScreensDesign app page](https://screensdesign.com/apps/vocabulary-learn-words-daily/), [showcase page](https://screensdesign.com/showcase/vocabulary-learn-words-daily)). A separate written teardown says 13 steps and a €19.99/yr price, so treat counts and prices as approximate.

| # | Step |
|---|---|
| 1 | Welcome: isometric illustration, social-proof stats, "Get started" |
| 2 | **ATT (tracking) system prompt**, shown at the very start |
| 3 | "How did you hear about us?" (vertical list) |
| 4 | Interstitial: "Tailor your word recommendations" |
| 5 | Age range (skippable) |
| 6 | Gender (4 options) |
| 7 | Name input |
| 8 | Weekly word goal (3 options, skippable) |
| 9 | **Notification warm-up**: time picker, sample notification preview, frequency, "Allow and Save" |
| 10 | iOS notification permission modal |
| 11 | Vocabulary level (Beginner/Intermediate/Advanced cards) |
| 12 | App-icon style (3x3 grid) |
| 13 | Theme (6 themes) |
| 14 | Voice/accent (playable samples) |
| 15 | **Cross-app bundle upsell**: "Self-Growth Essentials" (discount across 6 apps) |
| 16 | Customization interstitial |
| 17 | Learning goal (e.g. "Enhance my lexicon", "Improve my job prospects") |
| 18 | Topic interests (multi-select) |
| 19 | **Paywall**: 3-day trial timeline, reminder toggle, "Start 3-day free trial now" |
| 20 | App Store purchase sheet (3-day trial, then annual) and success modal |
| 21 | **Widget install prompt** (after purchase; install / remind later) |
| 22 | Consistency goal (3 options, skippable) |

Then the app: core use, a quiz and settings.

**Per your checklist**
- **Goal, level, age, topics, "how did you hear", words per week/day:** all present (steps 3, 5, 8, 9, 11, 17, 18).
- **Notification priming:** a two-step warm-up plus system modal (steps 9 and 10).
- **Widget tutorial:** only after purchase (step 21).
- **Rating prompt:** the gallery shows rating and feedback modals, but ScreensDesign does not time-stamp them inside onboarding. In Motivation's chapter list there is no rating step ([Motivation](https://screensdesign.com/apps/motivation-daily-quotes/)).
- **"Building your plan" loading screen:** not shown in the Vocabulary teardown ([ScreensDesign](https://screensdesign.com/apps/vocabulary-learn-words-daily/)). A study counted only 9 of about 751 apps with that loader ([Lazyweb](https://www.lazyweb.com/research/building-your-plan-loading-screen-prevalence)). Verbi's loader reads "Building your beginner plan" ([ScreensDesign Verbi](https://screensdesign.com/apps/verbi-speak-a-new-language/)).
- **Paywall:** a free-trial "soft" paywall at the end, with a single annual plan shown at its monthly equivalent ([ScreensDesign](https://screensdesign.com/showcase/vocabulary-learn-words-daily)).
  - Conflicting evidence: an App Store reviewer in Japan complains of a hard paywall before any content, and the developer replies that an ad-supported free version exists ([apps.apple.com/jp](https://apps.apple.com/jp/app/id1084540807)).
  - AppGoblin estimates Vocabulary's revenue split at IAP 48% / ads 52% [Est] ([AppGoblin](https://www.appgoblin.info/apps/1084540807)).

### 1.2 Sister and competitor flows (same ScreensDesign method)

| App | Steps | Notable | Source |
|---|---|---|---|
| Motivation – Daily quotes (Monkey Taps) | **41** onboarding steps | Over 20 quiz questions (religion, zodiac, relationship status). Notification warm-up at steps 17-18. Free-trial offer screen, then paywall (3-day trial). Widget prompt at step 40 (after purchase). A separate bundle paywall shows 50% off annual. | [ScreensDesign](https://screensdesign.com/apps/motivation-daily-quotes/) |
| I am – Daily Affirmations (Monkey Taps) | **25** steps | ATT first, then welcome with social proof. Quiz includes zodiac, religious beliefs and relationship status. Bundle promo at step 17. Free-trial paywall at step 25 (3-day trial, reminder toggle). Widget screens appear after the paywall. | [ScreensDesign](https://screensdesign.com/apps/i-am-daily-affirmations/) |
| Word of the Day・Vocabulary (Vocabulous) | **27** steps | Role-model question. Notification warm-up. A "vocab profile" summary built from quiz answers. **Hard paywall**: one 7-day trial offer, annual price anchored as "$0.96 per week". | [ScreensDesign](https://screensdesign.com/showcase/word-of-the-dayenglish-vocab) |
| Daily-affirmation category average | about **13** steps | Most common paywall: free trial, soft | [ScreensDesign category](https://screensdesign.com/categories/daily-affirmation-apps/) |

### 1.3 What the evidence says about long quizzes
- **No controlled benchmark exists** for onboarding length versus conversion. Superwall says paywall open rate is the metric that correlates linearly with install-to-paid ([Superwall](https://superwall.com/features/conversion-stats)).
- **Long funnels can work.** RevenueCat describes Noom's funnel as up to 113 screens and 10-15 minutes ([RevenueCat](https://www.revenuecat.com/blog/growth/web-to-app-onboarding-funnel.md)). Forum anecdotes in the other direction conflict with each other ([web2wave thread](https://community.web2wave.com/t/how-long-should-the-quiz-be-before-the-paywall/105)).
- **Notification primers.**
  - 63% (41 of 65) of apps with a verified notification ask use at least one custom priming screen ([Lazyweb](https://www.lazyweb.com/research/what-percent-of-apps-show-notification-permission-primer)).
  - The Lazyweb dataset is vendor-proprietary.
- **ATT opt-in.**
  - Education apps rose from 7% (2023) to 14% (2025), against a 35% overall average (via a search-result summary of [Adjust](https://www.adjust.com/blog/att-opt-in-rates-2025); the Adjust page itself rate-limited my fetch).
- **Day-0 behavior.** In Education, 78.5% of trial starts and 28.5% of conversions happen on Day 0 ([RevenueCat Education](https://www.revenuecat.com/state-of-subscription-apps-2026-education)). Adapty reports about 90% of trial starts on Day 0 ([Adapty paywall guide](https://adapty.io/blog/markdown/high-performing-paywall-2026.md)).
- **Compliance note [A].** Religion, zodiac and relationship questions (Motivation, I am) are sensitive. Religion is a special-category data type under GDPR and KVKK. I did not find a source on this; verify with counsel before copying those questions.

---

## 2. Paywall and pricing

### 2.1 Benchmarks

| Metric | Value | Source |
|---|---|---|
| Download-to-paid (D35), all apps | median 2.0% | [RevenueCat 2026](https://www.revenuecat.com/state-of-subscription-apps) |
| Hard paywall vs freemium (D35) | 10.7% vs 2.1% median | [RevenueCat 2026](https://www.revenuecat.com/state-of-subscription-apps) |
| Hard vs soft (Adapty) | hard has **21% higher LTV**; soft converts about 50% better | [Adapty](https://adapty.io/state-of-in-app-subscriptions-report/) |
| Education download-to-trial | **6.5%** | [RevenueCat Education](https://www.revenuecat.com/state-of-subscription-apps-2026-education) |
| Install-to-trial overall / North America | 11.2% / 14.5% | [Adapty](https://adapty.io/state-of-in-app-subscriptions-report/) |
| Trial-to-paid (Adapty) | 27.8% | [Adapty](https://adapty.io/state-of-in-app-subscriptions-report/) |
| Trial-to-paid by trial length | ≤4 days 25.5%; 5-9 days 37.4%; 17-32 days 42.5% | [RevenueCat 2026](https://www.revenuecat.com/state-of-subscription-apps) |
| Education trial-length mix | 50.3% of Education trials are 5-9 days | [RevenueCat Education](https://www.revenuecat.com/state-of-subscription-apps-2026-education) |
| Cancellations on Day 0 | 3-day trial 55.4%; 7-day 39.8%; 14-day 35.7%; 30-day 31.1% | [RevenueCat insights](https://www.revenuecat.com/sosa-2026-insights-part-2) |
| Onboarding paywall with trial, install-to-paid | 1.78% (highest setup); 1.35% vs 0.89% in-app | [Adapty](https://adapty.io/state-of-in-app-subscriptions-report/), [Adapty paywall guide](https://adapty.io/blog/markdown/high-performing-paywall-2026.md) |
| Education 1-yr LTV (all plans) / install LTV | **$45.10** / **$1.06** | [Adapty](https://adapty.io/state-of-in-app-subscriptions-report/) |
| Education realized LTV per payer, 1 yr / D14 revenue per install | **$22.82** / **$0.30** | [RevenueCat Education](https://www.revenuecat.com/state-of-subscription-apps-2026-education) |
| Education annual plan share of subs | 59-66% | [RevenueCat Education](https://www.revenuecat.com/state-of-subscription-apps-2026-education) |
| Education yearly / monthly price median | **$44.99** / $9.99 | [RevenueCat Education](https://www.revenuecat.com/state-of-subscription-apps-2026-education) |
| Annual retention, non-AI vs AI | 30.7% vs 21.1% | [TechCrunch on RevenueCat](https://techcrunch.com/2026/03/10/ai-powered-apps-struggle-with-long-term-retention-new-report-shows) |
| Retention year 1 (2024 data): annual / monthly / weekly | 28% / 8% / 1.2% | [RevenueCat insights](https://www.revenuecat.com/sosa-2026-insights-part-2) |
| Annual cancellations in month 1 | 35% overall; Education about 30% | [RevenueCat insights](https://www.revenuecat.com/sosa-2026-insights-part-2) |
| Reactivation within 1 yr: annual / monthly | 5% / 20% | [RevenueCat insights](https://www.revenuecat.com/sosa-2026-insights-part-2) |
| Refund rate | RevenueCat median 3.5% (non-AI); Adapty benchmark **8.3%** (different definitions). Annual refunds 4.2%, weekly 2.6% (2025). | [TechCrunch on RevenueCat](https://techcrunch.com/2026/03/10/ai-powered-apps-struggle-with-long-term-retention-new-report-shows), [Adapty 2026](https://adapty.io/state-of-in-app-subscriptions-report/), [Adapty 2025](https://adapty.io/blog/state-of-in-app-subscriptions-2025-in-10-minutes/) |
| Weekly plans | 55.6% of 2025 subscription revenue. Weekly plan with trial has 12-month LTV $54.50 vs $7.40 without a trial. | [Adapty paywall guide](https://adapty.io/blog/markdown/high-performing-paywall-2026.md) |

**Data-quality flags**
- RevenueCat's page is internally inconsistent: IN/SEA D35 appears as both 1.4% and 0.7%, and the monthly median as both $10 and $8.
- TechCrunch's "trial-to-paid 8.5% AI / 5.6% non-AI" does not match RevenueCat's category data (22-44%). Do not use it.
- RevenueCat Education has no published median for Education trial-to-paid, 12-month retention, or refund rate. Those are not found.
- Superwall has no public benchmark report. I found only marketing pages. Its testimonials include "opt-in trial vs default trial +10% trial conversion" (single-app claim) ([Superwall](https://superwall.com/features/subscription-analytics), [trial template](https://superwall.com/solutions/design-your-trial-template)).

### 2.2 Paywall design patterns
- **Trial toggle / annual-only trial.**
  - Adapty says many top apps now put the trial only on annual.
  - Trials help LTV in Education, Utilities, Health & Fitness and Photo & Video.
  - Trial-length tests win on LTV 59.6% of the time ([Adapty paywall guide](https://adapty.io/blog/markdown/high-performing-paywall-2026.md)).
  - PeakTalk (an English-for-professionals app) shows a plan screen with an opt-in 7-day trial toggle and a 58% annual saving ([ScreensDesign PeakTalk](https://screensdesign.com/showcase/peaktalk-job-specific-english)).
- **Exit and discount offers.**
  - Adapty's expected impact of a 24-hour offer shown after a closed onboarding paywall is 10-15% ARPU. This is an expected range, not a measured result.
  - Discounts apply to 6.9% of subscriptions overall; Education leads at 14.3% ([Adapty paywall guide](https://adapty.io/blog/markdown/high-performing-paywall-2026.md)).
  - Monkey Taps shows a 50%-off annual bundle paywall ([ScreensDesign Motivation](https://screensdesign.com/apps/motivation-daily-quotes/)).
  - No exit-offer uplift number was found from RevenueCat or Superwall.
- **Lifetime plans.**
  - Vocabulary lists a $149.99 lifetime SKU in the US ([App Store](https://apps.apple.com/us/app/id1084540807)). An older snapshot shows $99.99 ([Adapty library](https://adapty.io/paywall-library/vocabulary/)).
  - Word of the Day lists lifetime at $19.99 and $29.99 ([Adapty library](https://adapty.io/paywall-library/word-of-the-day/)).
- **Price testing.**
  - Monkey Taps lists many Vocabulary SKUs from $9.99 to $69.99, which suggests ongoing price tests [A] ([App Store US](https://apps.apple.com/us/app/id1084540807)).
  - About 20% of top-100 grossing apps tested a price increase over six months, averaging +27% ([Lazyweb summary](https://www.lazyweb.com/research/duolingo-retention-experiments)).
  - Only 28.3% of price tests improved conversion, but 45.5% improved LTV. Localization tests had the highest LTV win rate, 62.3% ([Adapty paywall guide](https://adapty.io/blog/markdown/high-performing-paywall-2026.md)).
  - Weekly plans convert 2-7x better than annual ([Adapty](https://adapty.io/state-of-in-app-subscriptions-report/)).

### 2.3 Price points: USD and TRY

TRY-to-USD below uses 48.65 TRY/USD (mid-September 2026, [longforecast](https://longforecast.com/usd-to-try-forecast-today); about 48.4 on Sep 4 per [Trading Economics](https://tradingeconomics.com/turkey/currency%3Flang%3Dpl)). TRY listings come from the TR storefront pages; period labels are often unspecified.

| App | USD (US storefront) | TRY (TR storefront) | Source |
|---|---|---|---|
| **Widget Vocabulary** | weekly $9.99; yearly $49.99 | weekly ₺499.99 (about $10.28); yearly ₺2,499.99 (about $51.39) | [US](https://apps.apple.com/us/app/id6775767149), [TR](https://apps.apple.com/tr/app/id6775767149) |
| Vocabulary (Monkey Taps) | 1 month $14.99; 1 year $35.99 and $59.99; lifetime $149.99; other SKUs $9.99-$69.99 | 1 month ₺119.99 (about $2.47); 1 year ₺799.99 (about $16.44) and ₺1,999.99 (about $41.11); bundle ₺5,999.99 | [US](https://apps.apple.com/us/app/id1084540807), [TR](https://apps.apple.com/tr/app/id1084540807) |
| Kelibu (YDT/YÖKDİL/YDS) | n/a | monthly ₺299.99 (about $6.17); yearly ₺2,499.99 (about $51.39) | [TR](https://apps.apple.com/tr/app/id6484268631) |
| Tuna (YDS/YÖKDİL) | n/a | annual ₺29.99; monthly ₺15.99; "Premium" ₺249.99 (rating 2.9 from 28 ratings) | [TR](https://apps.apple.com/tr/app/id1582519650) |
| Word of the Day (Vocabulous) | weekly $7.99; monthly $9.99; annual $49.99/$99.99; lifetime $19.99/$29.99 | monthly ₺119.99; annual ₺599.99 and ₺2,999.99 | [Adapty](https://adapty.io/paywall-library/word-of-the-day/), [TR](https://apps.apple.com/tr/app/id987136347) |
| Duolingo Super (TR) | n/a | ₺139.99 to ₺1,209.99 (10 SKUs; periods not labeled) | [TR](https://apps.apple.com/tr/app/id570060128) |
| Learna Pro (TR) | n/a | ₺199.99 to ₺1,499.99 (the only labeled "1 Year" is ₺1,499.99, about $30.83) | [TR](https://apps.apple.com/tr/app/id6478287397) |
| Blarma (TR) | n/a | ₺299.99 / ₺899.99 / ₺2,499.99 (Family ₺1,799.99) | [TR](https://apps.apple.com/tr/app/id1594884449) |

- **Observation [A].** Your TR weekly price (₺499.99) is about the same as the US $9.99, and the TR yearly (₺2,499.99) about equals the US $49.99. Even so, the app ranks #3 free in TR Education (rank is not downloads).
- **Regional price index.** Adapty's pricing index has Turkey at 0.7 and India at 0.6 (UK/FR/DE/IT/ES = 1.2). Turkey weekly plans cost "almost 3.5x less" than in the US ([Adapty 2026](https://adapty.io/state-of-in-app-subscriptions-report/), [Adapty 2025](https://adapty.io/blog/state-of-in-app-subscriptions-2025-in-10-minutes/)).
- **Regional price medians.** IN/SEA median monthly is $3.75 and yearly $18.32; North America is $9.99 and $39.99 ([RevenueCat 2026](https://www.revenuecat.com/state-of-subscription-apps)).

### 2.4 Apple pricing mechanics in Türkiye
- **Price points.** Apple offers 900 price points and lets subscription developers pick a base storefront with auto-equalization, or define prices per storefront ([Apple newsroom 2022](https://www.apple.com/newsroom/2022/12/apple-announces-biggest-upgrade-to-app-store-pricing-adding-700-new-price-points/), [BusinessWire](https://www.businesswire.com/news/home/20221206005860/en)). I did not find a current TRY price-point list. Check App Store Connect.
- **Consent thresholds.** For Türkiye, Apple requires subscriber consent when a price increase exceeds 300 TRY (non-annual) or 3,000 TRY (annual). The US equivalents are $5 and $50. Thresholds can change with tax or FX ([Apple](https://developer.apple.com/help/app-store-connect/reference/auto-renewable-subscription-price-increase-thresholds)).
- **Taxes.** Türkiye's digital services tax fell from 7.5% to 5% on 2026-01-01, and falls to 2.5% on 2027-01-01 ([EY](https://globaltaxnews.ey.com/news/2026-0117-turkiye-revises-digital-service-tax-rate-for-2026-and-2027)). Apple applied this to developer proceeds on 2026-01-29 ([9to5Mac](https://9to5mac.com/?p=1037244)). VAT was raised from 18% to 20% in 2023 (search snippet only, unverified: [Fonoa](https://www.fonoa.com/resources/country-tax-guides/turkiye/tax-on-digital-services)).
- **Commission.** The Small Business Program rate is 15% for developers under $1M in prior-year proceeds ([PhoneArena](https://www.phonearena.com/news/apple-drops-app-store-fees_id128493), [CNBC](https://www.cnbc.com/2020/11/18/apple-will-cut-app-store-fees-by-half-to-15percent-for-small-developers.html)).
- **Apple's subscription rules** (3.1.2): period at least 7 days; describe what the user gets for the price before subscribing ([Apple guidelines](https://developer.apple.com/app-store/review/guidelines/)).

---

## 3. Acquisition

### 3.1 Organic short video (TikTok / Reels / Shorts)
- **Format data (language-learning apps).** In an analysis of 226 above-median posts (Mar 2023 to Oct 2026), median views were 138K. The format mix was talking head 46%, app demo 31%, silent UGC 16%, **slideshow 6%** ([Handler](https://gethandler.ai/outliers/collections/language-learning-apps/)).
  - Top hooks: AI-tutor reactions, mispronunciation jokes, meltdown reactions, silent text-overlay POVs, comparison listicles.
  - Recommended length: many top posts are 6-9 seconds.
  - This suggests slideshows are a minority winner in this niche [A].
- **Vocabulary-specific accounts.** I found no download-attributed data. Examples:
  - "Auntie Bev": more than 420,000 followers and about 5M views in a 2022 report ([Spectrum News](https://spectrumlocalnews.com/nc/triangle-sandhills/news/2022/01/07/durham-woman-viral-on-tik-tok-for-teaching-daily-vocabulary-words-to-expand-peoples-use-of-english-)).
  - Indonesian teacher "John Pare": about 1M followers ([thesis summary](https://repository.uninus.ac.id/1280/5/BAB%201%20VIANNY.pdf)).
  - I did not find a source for the "words that make you sound smarter" format.
- **Faceless slideshow automation (weak evidence).** The "Larry" agent case reports 500K views in 5 days and $670-714 MRR ([Stack Junkie](https://www.stack-junkie.com/blog/how-to-automate-tiktok-marketing-with-openclaw-larry-skill-deep-dive), [Termo](https://www.termo.ai/skills/larry)). Treat it as anecdotal.
- **Duolingo.** TikTok followers are reported as 2M to 13M depending on source; the sources conflict ([Business.com](https://www.business.com/b-newsletter/content/duolingo-tiktok/), [ContentGrip](https://www.contentgrip.com/duolingo-viral-strategy)). Much streak and XP content is user-generated ([GrowthCurve](https://growthcurve.co/what-the-best-language-learning-apps-get-right-about-growth)).
- **UGC creator pricing (vendor claims).**
  - $75-$500 per video for non-audience creators; $500-$1,200 per video via agency; $40-$150 offshore ([Hirevire](https://hirevire.com/blog/cost-to-hire-tiktok-creators)).
  - Performance-based example: $2 per 1,000 views ([Superappp](https://www.superappp.com/blog/how-to-scale-your-mobile-app-to-10k-with-ugc-everything-you-need-to-know-in-a-single-playbook)).
  - No vocabulary-app creator-program data was found.
  - Apple prohibits manipulating reviews and referrals under 5.6.3 ([Apple guidelines](https://developer.apple.com/app-store/review/guidelines/)).

### 3.2 Apple Ads
Table values are from AppTweak (Aug 2026 article, 2025 data).

| Metric | Value | Scope |
|---|---|---|
| Education median CPT | $1.52 | US search results |
| Education median CPI | $2.91 | US search results |
| Education median CR / TTR | 56.4% / 8.3% | US search results |
| Global median CPI (search results) | $1.80 | 38 countries |
| CPI, all categories (Turkey / Brazil / India / Indonesia / Saudi) | $1.02 / $1.05 / $0.89 / $0.95 / $1.29 | search results |
| Turkey TTR / CR | 9.2% / 48% | search results |
| Education custom-product-page adoption in Apple Ads | 13.5% | US |

Sources: [AppTweak benchmarks](https://www.apptweak.com/en/aso-blog/apple-ads-benchmarks?format=md), [2025 page](https://www.apptweak.com/aso-blog/apple-ads-benchmarks?page=6). Country CPIs are not Education-specific, and the US category and country datasets differ.

I found no Education CPI by country, no Meta CPI for Education, and no CPA benchmark.
- Facebook CPM in Turkey: $2.00-$3.50; Instagram CPM: $3.00-$5.00. India: Facebook $1.00-$1.80 ([Adligator](https://adligator.com/blog/meta-ads-cpm-by-country-benchmarks)).
- A Superads figure of $104 for Education CPI looks unreliable. I did not use it ([Superads](https://www.superads.ai/facebook-ads-costs/cost-per-app-install/education)).

### 3.3 ASO
- **Limits.** Name 30 characters, subtitle 30, keywords 100, promotional text 170 (does not affect ranking), up to 10 screenshots. Localize description, keywords, previews and screenshots per market ([Apple](https://developer.apple.com/app-store/product-page/)).
- **Multi-locale keyword coverage.** Apple indexes secondary locales per storefront. Vendor tests (not Apple documentation) say:
  - **TR** indexes Turkish, English (UK), French.
  - **BR, IN, ID, SA, AE** index their primary language plus English (UK).
  - **US** indexes English (US) plus Spanish (Mexico), Russian, Chinese (Simplified and Traditional), Arabic, French, Portuguese (Brazil), Vietnamese, Korean ([AppTweak](https://www.apptweak.com/en/aso-blog/how-to-benefit-from-cross-localization-on-the-app-store), [MobileAction](https://www.mobileaction.co/blog/app-store-cross-localization/)).
  - The 1,440-characters-across-locales figure is theoretical metadata space, not measured gain. No measured impact numbers were reported.
- **What Monkey Taps does.** Per Apple's lookup API, storefront titles are localized:
  - "Vocabulary - Aprende inglés" (MX, AR, CL, CO), "Aprenda palavras" (BR), "Wörter lernen" (DE), "Apprenez mots" (FR), "Impara parole" (IT), and Japanese/Korean titles.
  - Turkey, India, Indonesia, Saudi Arabia, UAE, Egypt and Pakistan keep the English title.
  - Source: [lookup US](https://itunes.apple.com/lookup?id=1084540807&country=us), [TR](https://itunes.apple.com/lookup?id=1084540807&country=tr), [MX](https://itunes.apple.com/lookup?id=1084540807&country=mx), [BR](https://itunes.apple.com/lookup?id=1084540807&country=br).
  - TR rating count is 1,202 versus 14,780 in India and 219,574 in the US.
  - Monkey Taps' Education ranks on 2026-10-10: US free #26 / grossing #19; GB grossing #34; BR free #12 / grossing #67; MX free #18; IN free #98 / grossing #79; ID grossing #92; DE grossing #93 ([US](https://itunes.apple.com/us/rss/topgrossingapplications/limit=100/genre=6017/json), [BR](https://itunes.apple.com/br/rss/topfreeapplications/limit=100/genre=6017/json), [MX](https://itunes.apple.com/mx/rss/topfreeapplications/limit=100/genre=6017/json)).
- **Custom product pages.**
  - Apple's claim: +2.5 percentage points on average versus a 1.6% baseline, up to 70 pages, with keywords assignable to a page ([Apple](https://developer.apple.com/app-store/custom-product-pages/)).
  - Adapty's data of 1M+ ad groups shows a smaller lift where baseline intent is already high ([Adapty](https://adapty.io/blog/do-apple-ads-custom-product-pages-work/)).
- **Screenshots.** The first three matter most, but the evidence is one non-education vendor case (OLBG +61%) ([SplitMetrics](https://splitmetrics.com/cases/olbg-ios-screenshots-optimization/)). Education iOS page-view-to-download is about 16.8% ([Adapty](https://adapty.io/blog/app-store-conversion-rate/)); Business of Apps cites 16% for 2024.
- **In-app events and featuring.**
  - Phiture claims over 50% impression and download lifts during event windows (agency test) ([Phiture](https://phiture.com/mobilegrowthstack/in-app-events-how-to-get-approved/)).
  - Apple's featuring nominations: give at least 2 weeks' notice, up to 3 months for wider consideration. Editors consider localization quality ([Apple](https://developer.apple.com/app-store/getting-featured/)).
  - Apple's editorial "Apps We Love" covers Motivation and names Vocabulary as a sister project ([Apple story](https://apps.apple.com/au/iphone/story/id1547810416)).

### 3.4 Cross-promotion and revenue claims (Monkey Taps)
- **Portfolio.** The Vocabulary listing names: Motivation, I am, Bible Widgets, Facts, Mood AI, Loving Kindness ([App Store](https://apps.apple.com/us/app/id1084540807)). The bundle "Self-Growth Essentials" is sold inside onboarding (US $59.99 annual SKU per [Adapty](https://adapty.io/paywall-library/vocabulary/); TR ₺5,999.99).
- **Installs / MAU / revenue [Est].**
  - Vocabulary: 16.1M installs, about 400K MAU, $50K+/month ([AppGoblin](https://www.appgoblin.info/apps/1084540807)).
  - Motivation: 82.6M installs, about 4M MAU, $200K+/month ([AppGoblin](https://www.appgoblin.info/apps/876080126)).
  - I am: 54.1M installs ([AppGoblin](https://www.appgoblin.info/apps/874656917)).
  - Other sources for Vocabulary: $200K/month and 200K+ monthly downloads ([Adapty library](https://adapty.io/paywall-library/vocabulary/)); $750K revenue or $50K/mo, 150-250K installs, on the same ScreensDesign page ([ScreensDesign](https://screensdesign.com/showcase/vocabulary-learn-words-daily)).
  - These disagree by up to 4x; none is official.
  - Motivation: $200K-$600K/month depending on source and year ([AppMasters](https://appmasters.com/blog/motivation-app-makes-600000-month) (fetch returned 404), [ScreensDesign](https://screensdesign.com/showcase/motivation-daily-quotes)).
- **Tech stack [Est].** AppGoblin lists Firebase and Mixpanel with Google/Facebook ad networks, and no attribution or subscription SDK detected (last scanned Aug 2026).
- **Founder interviews.** None found with concrete numbers.
  - Closest: HabitKit (a widget habit app) reached $10K MRR in 2024 and about $13.6K MRR by mid-2024; a December 2024 MKBHD feature drove its best month. The author says pricing was the most influential experiment ([Röhl 2024 review](https://sebastianroehl.substack.com/p/2024-my-indie-app-business-year-in)).
  - Habit Pixel: $28 MRR in June 2025, then about 900 subscriptions and $1K MRR by Jan 2026 after seasonal launches and widgets ([Indie Hackers](https://www.indiehackers.com/post/from-0-to-1k-mrr-in-8-months-bootstrapping-habit-pixel-as-a-solo-dev-684b6c056d)).
  - A verified-revenue small daily-quotes app: about $3.1K per 30 days ([TrustMRR via search](https://trustmrr.com/startup/daily-affirmations-quotes-app); the page now 404s).

---

## 4. Retention and engagement

- **Streaks (Duolingo).**
  - Learners at a 7-day streak are 2.4x more likely to return next day (correlational) ([Duolingo blog](https://blog.duolingo.com/how-duolingo-streak-builds-habit)).
  - Two equipped streak freezes: +0.38% daily active learners. A streak animation: +1.7% for new learners at day 7 ([Duolingo](https://making.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals)).
  - 600+ streak experiments; changing the CTA from "continue" to "commit to my goal" was a win ([Lenny's summary](https://www.recall.it/summary/lennys-podcast/behind-the-product-duolingo-streaks-or-jackson-shuttleworth-group-pm-retention-team)).
  - A widget that changes mood when you skip lessons was tested; no lift numbers are published ([Lazyweb](https://www.lazyweb.com/research/duolingo-retention-experiments)).
- **Notifications.**
  - Monkey Taps lets users choose notification count and time window, shows a sample notification, then triggers the iOS prompt ([ScreensDesign Vocabulary](https://screensdesign.com/apps/vocabulary-learn-words-daily/)).
  - iOS opt-in is roughly 56% per a secondary roundup of Batch (2025), unverified ([search summary](https://www.pushwoosh.com/blog/push-notification-benchmarks/)).
  - I found no Education-specific push benchmark.
  - Guilt-framed copy reportedly gave about a 3% retention lift at scale (agency claim, unmeasured) ([GrowthCurve](https://growthcurve.co/what-the-best-language-learning-apps-get-right-about-growth)).
- **Widget as retention.**
  - Monkey Taps asks for widget install right after purchase (Section 1).
  - I found no public retention-lift number for widgets.
  - Your v2.2.2 added custom decks (up to 5) that show on Lock Screen and Home Screen widgets ([App Store TR](https://apps.apple.com/tr/app/id6775767149)).
- **Social sharing.** Apple describes Motivation as letting users share quotes and set them as wallpaper ([Apple story](https://apps.apple.com/au/iphone/story/id1547810416)). No sharing-conversion data was found.
- **Referrals.**
  - A WHOOP case reports referrals at over 10% of new subscriptions (vendor case) ([Talkable](https://get.talkable.com/case-studies/whoop)).
  - A macro-tracker case: 151 paid conversions from 4,742 referred visitors ([ReferralHero](https://referralhero.com/blog/fitness-app-referral-program-case-study)).
  - RevenueCat says referral programs for subscription apps are "still very much in the early days" ([RevenueCat](https://www.revenuecat.com/blog/growth/how-to-build-a-referral-program-for-mobile-apps)).
  - Typical K-factor of 0.1-0.3 is a SaaS rule of thumb, unverified.
- **Review prompts.**
  - The system prompt shows at most 3 times per 365 days. This is Apple's documented rule, per vendor summaries ([CleverTap](https://clevertap.com/blog/improve-ios-app-ratings-with-skstorereviewcontroller/), [Atomic Object](https://spin.atomicobject.com/ios-review-prompt-customize/)).
  - Apple guideline 5.6.1: "Use the provided API... we will disallow custom review prompts." Guideline 3.2.2 also bars forcing ratings ([Apple guidelines](https://developer.apple.com/app-store/review/guidelines/)).
  - ScreensDesign galleries show custom-looking rating modals (Not Now / Submit) in Monkey Taps apps. Check whether those are the system prompt [A].
- **Churn and win-back.**
  - Apple win-back offers are configured in App Store Connect and shown via the StoreKit Message API ([Appbot](https://appbot.co/blog/win-back-apple-subscribers/)).
  - The Retention Messaging API shows offers inside the cancellation sheet. It is gated and in beta; sources conflict on its timeline ([9to5Mac](https://9to5mac.com/2025/07/23/apple-retention-offers-in-app-purchase/), [Adapty](https://adapty.io/blog/apple-s-retention-messaging-api/)).
  - Baseline reactivation: annual 5%, monthly 20% ([RevenueCat insights](https://www.revenuecat.com/sosa-2026-insights-part-2)).
  - No cancellation-survey benchmark was found.

---

## 5. Turkey and other emerging markets

### 5.1 Exam-driven demand
- **YKS 2026:** 2,425,560 applicants (2,560,649 in 2025). The YDT (foreign-language test) had 203,640 applicants, with 195,085 for English pre-exam, and 143,270 sat it ([GZT](https://www.gzt.com/gundem/2026-yksye-kac-kisi-girdi-osym-katilim-ve-basvuru-sayisi-aciklandi-4243248), [ÖSYM](https://osym.gov.tr/yksye-2-milyon-425-bin-560-aday-basvurdu)).
- **LGS 2026:** 1,022,658 applicants ([Karar](https://www.karar.com/guncel-haberler/1-milyondan-fazla-aday-ter-dokuyor-lgs-kapsamindaki-merkezi-sinav-2053577)). The English share of questions is not confirmed in official sources.
- **YÖKDİL/1 2026:** 113,881 applicants ([NTV](https://www.ntv.com.tr/egitim/yuksekogretim-kurumlari-yabanci-dil-sinavi-yapildi-yds-sonuclari-ne-zaman-aciklanacak-1715023)).
- **YDS:** I found no applicant count, but ÖSYM runs e-YDS in monthly sessions ([ÖSYM e-YDS 2025/10](https://www.osym.gov.tr/TR,33473/e-yds-202510-ingilizce-basvurularin-alinmasi-10092025.html)).
- **Not found:** an English component in KPSS, and IELTS/TOEFL volumes for Turkey.
- **English proficiency (EF EPI 2025, Wikipedia table):** Turkey 488, India 484, Brazil 482, Indonesia 471, Egypt 459, Saudi Arabia 404 ([Wikipedia](https://en.wikipedia.org/wiki/EF_English_Proficiency_Index); EF's own page gave no country scores).

### 5.2 Competitors in the TR App Store (2026-10-10)
- **Education top free (TR), top 5:** Learna, Duolingo, **Widget Vocabulary**, Orijinal Yayınlar Video Çözüm, MEB. Others in the list: Lingopanda #16, Praktika #26, Quizlet #43, Blarma #47, Busuu #52 ([TR free RSS](https://itunes.apple.com/tr/rss/topfreeapplications/limit=100/genre=6017/json)).
- **Education top grossing (TR):** #1 Duolingo, #2 Learna, #3 Simply Draw, #4 Praktika, #5 Busuu; **Widget Vocabulary #17**, Blarma #18, Quizlet #21, Anki #44 ([TR grossing RSS](https://itunes.apple.com/tr/rss/topgrossingapplications/limit=100/genre=6017/json)).
- **Exam-specific vocabulary apps:** Tuna, Kelibu, MemoNimo, YDS Forge ($1.99), YDS.NET ([App Store listings via search](https://apps.apple.com/us/app/id1582519650)).
- **Ratings snapshot:** Blarma 5,020 TR ratings (4.72); Learna 33,549 (4.43); Word of the Day 356 (4.51); Widget Vocabulary 190 (4.37) ([Blarma](https://itunes.apple.com/lookup?id=1594884449&country=tr), [Learna](https://itunes.apple.com/lookup?id=6478287397&country=tr), [Word of the Day](https://itunes.apple.com/lookup?id=987136347&country=tr)).

### 5.3 Purchasing power and platform
- Net minimum wage 2026 is ₺28,075.50 (US$652 per Bloomberg Tax at its rate; about $577 at 48.65 [Calc]) ([Bloomberg Tax](https://news.bloombergtax.com/daily-tax-report-international/turkey-labor-ministry-announces-increases-to-net-gross-minimum-wage-rates-for-2026)).
- The lira weakened about 17.5% over 12 months to early Sept 2026 ([Trading Economics](https://tradingeconomics.com/turkey/currency%3Flang%3Dpl)).
- iOS is about 25.8% of Turkish mobile traffic (July 2026) ([StatCounter](https://gs.statcounter.com/os-market-share/mobile/turkey)). Adapty names Turkey among the fastest-growing app markets.
- **Social reach (late 2025):** TikTok ad audience 44.9M adults 18+, Instagram 62.3M, YouTube 57.9M; internet penetration 88.3% ([DataReportal](https://datareportal.com/reports/digital-2026-turkey)).
- **Turkish TikTok edu landscape:** I found no systematic account/ranking data. The only items were TikTok LIVE English lessons with Meet2Talk ([Tamindir](https://www.tamindir.com/haber/tiktok-ucretsiz-canli-ingilizce-dersleri_90351/)) and a note that creator language content can be inaccurate. Search "YDS kelime" on TikTok directly.

### 5.4 Other emerging markets
- **Brazil.** Monkey Taps' Vocabulary ranks #12 free and #67 grossing in Education (localized title). Apple's Brazil alternative-payments framework went live 2026-06-18 (link-outs 15%, or 10% for eligible programs) ([ETV Bharat](https://www.etvbharat.com/en/technology/apple-unveils-new-app-store-rules-in-brazil-following-regulator-agreement-enn26061904464), [Appcharge](https://appcharge.com/blog/apple-brazil-framework-is-now-live-what-publishers-need-to-know)). The fee figures are from secondary sources.
- **Mexico.** Vocabulary is #18 free; Widget Vocabulary is #70 free ([MX RSS](https://itunes.apple.com/mx/rss/topfreeapplications/limit=100/genre=6017/json)).
- **India / Indonesia.**
  - Monkey Taps ranks #98 free and #79 grossing in India, and #92 grossing in Indonesia.
  - D35 download-to-paid is 0.7-1.4% and trial-to-paid 15.2% for IN/SEA developers; the weekly share is highest in LatAm ([RevenueCat 2026](https://www.revenuecat.com/state-of-subscription-apps)).
  - Apple Ads CPI: India $0.89, Indonesia $0.95 ([AppTweak](https://www.apptweak.com/en/aso-blog/apple-ads-benchmarks?format=md)).
- **MENA.** Lowest refund rates: 2.5% non-trial and 3.1% trial ([Adapty](https://adapty.io/state-of-in-app-subscriptions-report/)). Saudi Apple Ads CPI is $1.29; no Saudi Education top-free chart entry for Monkey Taps in my pull.
- **Spend growth (secondary, unverified).** A write-up says 60% of H1 2026 growth came from emerging markets, led by India, Brazil and Indonesia ([AppsOps summary](https://appsops.store/news/mobile-market-growth-h1-2026-emerging-markets-drove-60)).

---

## 6. Unit economics model (illustrative)

**This is an assumptions-based model, not a forecast.** Inputs are anchored to the cited benchmarks. Script: `C:\Users\yusuf\AppData\Local\Temp\claude\C--Users-yusuf-OneDrive-Desktop-Widget-Vocabulary--learn-words\e927268b-3cbe-437d-b9e4-b39cf6e813db\scratchpad\model_unit_econ.py` (not in the project).

**Input assumptions (per 1,000,000 monthly impressions)**

| Parameter | Pessimistic | Base | Optimistic | Anchor |
|---|---|---|---|---|
| Impression-to-tap (TTR) | 5% [A] | 7.4% | 8.3% | AppTweak global and US-Education medians |
| Tap-to-install (CR) | 40% [A] | 56% | 60% [A] | AppTweak medians (paid proxy for organic) |
| Installs reaching paywall | 60% [A] | 75% [A] | 90% [A] | no benchmark found |
| Paywall-to-trial | 6% [A] | 8.7% [A] | 14% [A] | calibrated so install-to-trial hits 3.6% / 6.5% / 12.6% |
| Install-to-trial (result) | 3.6% | **6.5%** | 12.6% | RevenueCat Education 6.5%; Adapty 11.2% overall, 14.5% NA |
| Trial-to-paid | 25.5% | 30% | 37.4% | RevenueCat ≤4-day and 5-9-day medians; Adapty 27.8% |
| Annual share of payers | 50% | 60% | 66% | RevenueCat Education 59-66% |
| Annual / weekly list price | $29.99 / $4.99 | $39.99 / $6.99 | $49.99 / $9.99 | RevenueCat medians; your US prices |
| Avg paid weeks per weekly payer | 4 [A] | 6.7 | 9 [A] | derived from Adapty $54.50 LTV (with trial) at ~$8.1/week |
| Geo price index vs US | 0.55 [A] | 0.70 | 0.90 [A] | Adapty: TR 0.7, IN 0.6 |
| Apple fee / refund rate | 15% / 8.3% | 15% / 3.5% | 15% / 2.5% | Small Business Program; Adapty 8.3%, RevenueCat 3.5%, Adapty MEA 2.5% |
| Annual first-renewal retention | 23% | 30% | 40% | RevenueCat 23-40% by category; 30.7% non-AI annual retention |

**Results**

| Metric | Pessimistic | Base | Optimistic |
|---|---|---|---|
| Installs / month | 20,000 | 41,440 | 49,800 |
| Install-to-paid | 0.92% | **1.95%** | 4.71% |
| New payers / month | 184 | 808 | 2,347 |
| Net first-12-month revenue per payer | $10.71 | $24.53 | $47.41 |
| Net 12-month revenue per install | $0.10 | $0.48 | $2.23 |
| **MRR at month 3** | $1,081 | $11,479 | $67,947 |
| **MRR at month 6** | $1,376 | $14,264 | $82,385 |
| **MRR at month 12** | $1,966 | $19,832 | $111,260 |
| **MRR at month 24** | $2,237 | $23,173 | $134,361 |

(MRR is net of Apple fee and refunds, with annual revenue amortized over 12 months; year-2 annual renewals included.)

**Sanity checks**
- The base-case install-to-paid of 1.95% is close to RevenueCat's 2.0% global D35 median and Adapty's 1.78% onboarding-paywall figure.
- The base-case net per-payer value ($24.53) sits near RevenueCat's Education realized LTV per payer ($22.82).
- Third-party estimates for Vocabulary imply about $0.21 per install (AppGoblin) to about $1.00 per install (Adapty library) [Calc], bracketing the base case.

**Break-even paid CPI [Calc]**
- With the base funnel, 12-month net revenue per install is about $0.68 (US-index 1.0), $0.48 (TR-like 0.7) and $0.41 (IN-like 0.6).
- At AppTweak's CPIs (US Education $2.91; TR $1.02; BR $1.05; IN $0.89; ID $0.95), 12-month payback needs roughly 8.3% install-to-paid in the US and about 4.2-4.5% in TR/BR/IN/ID.
- That is optimistic-scenario territory. Use Apple Ads on proven keywords or as research; lean on organic.

---

## 7. Legal and compliance for growth

- **Apple subscription disclosure.**
  - 3.1.2: describe what the user gets for the price before asking to subscribe ([Apple](https://developer.apple.com/app-store/review/guidelines/)).
  - Rejections cite title, length, price, per-unit price and working privacy/EULA links; the billed amount must be the most conspicuous price ([Apple forum](https://developer.apple.com/forums/thread/807082)).
  - Free trials are offered through App Store Connect.
- **US federal.**
  - The FTC "click-to-cancel" rule was vacated by the Eighth Circuit on 2025-07-08, but ROSCA enforcement continues. The FTC restarted rulemaking (ANPRM 2026-03-11) ([Cooley](https://www.cooley.com/news/insight/2025/2025-07-11-click-to-cancel-just-got-cancelled-eighth-circuit-vacates-entirety-of-ftcs-negative-option-rule), [Gibson Dunn](https://www.gibsondunn.com/wp-content/uploads/2026/02/ftc-restarts-negative-option-rulemaking-after-eighth-circuit-vacatur-enforcement-under-rosca-continues.pdf)).
  - State auto-renewal laws still apply.
- **UK.** The DMCC subscription regime is now planned for January 2027, with a 14-day cooling-off after trials and renewals. Non-UK businesses can be in scope ([Baker McKenzie](https://connectontech.bakermckenzie.com/uk-government-accelerates-dmcca-subscription-reforms-to-january-2027/), [Osborne Clarke](https://www.osborneclarke.com/insights/uk-digital-markets-competition-and-consumers-act-subscription-contracts-regime-take-shape)).
- **EU.** The Digital Fairness Act is pending; the Commission targeted Q3 2026 and I could not confirm adoption. Cancellation flows are in scope ([Heuking](https://www.heuking.de/en/news-events/newsletter-articles/detail/digital-fairness-act-implementation-obligations-companies-need-to-prepare-for.html)).
- **EU DMA and alternative payments.**
  - Apple announced on 2026-08-18 a new EU fee structure effective 2026-10-01. The commission is 26% for IAP (15% for Small Business and for second-year subscriptions); alternative payments 20% (10% reduced); link-outs 15% (10% reduced); a 5% Core Technology Commission applies only to alternative distribution ([TNW](https://thenextweb.com/news/apple-eu-app-store-fees-dma-core-technology-commission), [Phiture](https://phiture.com/blog/apple-new-app-store-terms-2026)).
  - Kids-category and under-13 apps cannot include external purchase links.
- **US link-outs.**
  - Guideline 3.1.1(a) allows buttons and external links in US-storefront apps ([Apple](https://developer.apple.com/app-store/review/guidelines/)).
  - Ninth Circuit (2025-12-11) kept the contempt finding but sent the commission rate back to the district court. The Supreme Court granted cert on 2026-06-30, limited to the contempt-standard question, and a final commission was not set as of the sources I found ([CourtListener/SCOTUSblog via Digital Policy Alert](https://digitalpolicyalert.org/event/39721-epic-games-filed-response-opposing-apples-supreme-court-stay-application-in-epic-games-v-apple), [SCOTUSblog](https://www.scotusblog.com/cases/apple-inc-v-epic-games-inc-3/)).
  - RevenueCat advises keeping IAP and adding a web button for US traffic only ([RevenueCat](https://www.revenuecat.com/blog/growth/apple-anti-steering-ruling-monetization-strategy)).
- **Turkey.**
  - Consumer law: Law 6502 Art. 52 and the Subscription Contracts / Distance Contracts regulations (14-day withdrawal, pre-contract information, cancellation not harder than sign-up). I could not confirm how they apply to app-store subscriptions; treat as legal-blog level ([Bilal Alyar](https://bilalalyar.av.tr/?p=101463), [Erdem & Erdem](https://www.erdem-erdem.av.tr/bilgi-bankasi/abonelik-sozlesmelerinin-sona-erdirilmesi)).
  - KVKK: Article 9 was rewritten (effective 2024-06-01; the old consent-only route ended 2024-09-01). Cross-border transfers (e.g. Firebase or Mixpanel servers outside Turkey) now need an adequacy decision, standard contracts or another safeguard ([Erdem & Erdem bulletin](https://www.erdem-erdem.av.tr/en/insights/personal-data-protection-bulletin-2024-third-quarter), [Mondaq](https://webiis08.mondaq.com/turkey/data-protection/1828986/kvkk-data-transactions-guideline)). Nothing I found addresses specific SDKs.
  - The Turkish Competition Authority opened an investigation (May 2024) into App Store anti-steering and mandatory IAP; no 2026 outcome found ([CNN Türk](https://www.cnnturk.com/ekonomi/rekabet-kurulu-app-storea-sorusturma-baslatti-2121090)).
- **GDPR / ePrivacy.** The CNIL view: an OS permission is not legal consent under ePrivacy Article 5(3); both are needed. Its mobile-app recommendation presumes SDK vendors are processors unless they use data for their own purposes ([donneespersonnelles.fr](https://www.donneespersonnelles.fr/application-mobile-rgpd), [CNIL](https://www.cnil.fr/en/mobile-applications-cnil-publishes-its-recommendations-better-privacy-protection)). Nothing I found covers Firebase or ATT specifically.
- **COPPA / kids.**
  - The amended COPPA Rule took effect 2025-06-23 with compliance by 2026-04-22. Sharing children's data with analytics vendors needs separate verifiable parental consent ([Federal Register](https://www.federalregister.gov/documents/2025/04/22/2025-05904/childrens-online-privacy-protection-rule), [Toy Association](https://www.toyassociation.org/ta/PressRoom2/News/2026-News/updated-coppa-rule-requirements-take-effect-april-22.aspx)).
  - Apple's Kids Category bars third-party analytics and ads, and bars links out or purchasing opportunities outside a parental gate (1.3 and 5.1.4 in [Apple guidelines](https://developer.apple.com/app-store/review/guidelines/)).
  - Texas age assurance (Declared Age Range API) became enforceable for new Texas accounts on 2026-06-04 after a Fifth Circuit stay; status could change ([AppleInsider](https://appleinsider.com/articles/26/06/03/age-verification-now-mandatory-for-app-store-users-in-texas)).
  - The cleanest posture is to target 13+ and do not collect birthdates from children [A].

---

## 8. Top 20 actionable growth tactics (ranked by expected impact / effort)

Impact and effort are my judgments (H/M/L), based on the evidence cited.

| # | Tactic | Impact / Effort | Why (evidence) |
|---|---|---|---|
| 1 | **Add full Turkish metadata plus Turkish in-app UI**, and populate English (UK) and French locales for TR indexing | H / L | TR indexes Turkish, English (UK) and French ([AppTweak](https://www.apptweak.com/en/aso-blog/how-to-benefit-from-cross-localization-on-the-app-store)). Your app is English-only (1 locale) while Monkey Taps lacks Turkish. Localization tests win LTV 62.3% ([Adapty](https://adapty.io/blog/markdown/high-performing-paywall-2026.md)). |
| 2 | **Exam-intent keyword clusters** (YDS, YÖKDİL, YDT, IELTS, TOEFL, SAT, GRE) in title/subtitle/keywords per locale | H / L | Exam volumes: YKS 2.43M, YDT 203,640, YÖKDİL/1 113,881 (Section 5). GrowthCurve favors long-tail clusters ([GrowthCurve](https://growthcurve.co/what-the-best-language-learning-apps-get-right-about-growth)). |
| 3 | **Fill the US secondary locales** (es-MX, pt-BR, ar, etc.) with English keywords | H / L | Vendor-tested indexing of 9 secondary locales in the US ([AppTweak](https://www.apptweak.com/en/aso-blog/how-to-benefit-from-cross-localization-on-the-app-store)). Needs verification; do not remove existing keywords. |
| 4 | **Paywall test: 3-day vs 7-day trial, plus annual-only trial toggle** | H / M | 5-9 day trials: 37.4% trial-to-paid vs 25.5% for ≤4 days (RevenueCat). Annual-only trial is a top-app pattern (Adapty). |
| 5 | **Test hard vs soft paywall** while keeping weekly + annual | H / M | Hard: 10.7% vs 2.1% D35 (RevenueCat); hard has 21% higher LTV, soft converts about 50% better (Adapty). Your weekly-heavy mix matches 55.6% weekly revenue share. |
| 6 | **Localized TR pricing test** (annual and weekly vs current ₺2,499.99 / ₺499.99) | H / L | TR index 0.7 (Adapty); competitors' TR annual prices range ₺599.99-₺2,999.99; price tests lift LTV 45.5% of the time. |
| 7 | **Notification warm-up screen** (time window and daily count, sample notification) before the iOS prompt | M-H / L | Monkey Taps pattern; 63% of apps asking for permission use primers (Lazyweb). |
| 8 | **Post-purchase widget-install step** (and a first-session home-screen widget guide) | M-H / L | Monkey Taps puts the widget prompt right after purchase (ScreensDesign). Track widget-install rate. |
| 9 | **Exit offer** to users who close the paywall (24-hour discount) | M / L | Adapty expects 10-15% ARPU; Education discounts on 14.3% of subs. Monkey Taps uses a 50% annual bundle offer. |
| 10 | **Turkish micro-creator program** (YDS/YKS teachers, "kelime" accounts), performance-based pay and Spark-ad rights | H / M | TikTok 44.9M adult reach (DataReportal). Talking head + app demo are 77% of outlier formats (Handler). Vendor cost data: $75-$500 per video; $2 per 1,000 views. |
| 11 | **Short, silent text-overlay hooks (5-9 s)**: "words that sound smarter", exam-word mistakes | M-H / L | Handler: silent text-overlay POVs are an outlier format. |
| 12 | **Faceless word-of-the-day slideshows at volume** | M / L | Slideshows are only 6% of language-niche outliers (Handler); automation case is anecdotal ($670-714 MRR). Use as a cheap secondary channel. |
| 13 | **Custom product pages per exam cluster** (YDS, YÖKDİL, IELTS), linked to keywords | M / M | Apple: +2.5pp on a 1.6% baseline; only 13.5% of Education advertisers use CPPs. |
| 14 | **"How did you hear about us?" and a post-install survey** to attribute creators | M / L | Monkey Taps asks the question at step 3. AppGoblin did not detect an attribution SDK on their apps. |
| 15 | **Streak + streak-freeze + "commit to my goal" CTA** | M / M | Duolingo: 2.4x next-day continuation at streak 7 (correlational); small but measurable freeze and animation lifts. |
| 16 | **System review prompt after a success moment**, never custom | M / L | Guideline 5.6.1 disallows custom prompts; 3 per 365 days. Your TR ratings (190) lag your rank. |
| 17 | **Win-back offers and Retention Messaging API** (when approved) | M / M | Annual reactivation 5%, monthly 20% (RevenueCat). Day-0 and month-1 cancellations dominate (annual month 1: Education about 30%). |
| 18 | **Brazil/Mexico expansion** with localized Spanish/Portuguese titles ("Aprende inglés", "Aprenda palavras") | M-H / M | Monkey Taps ranks #12 BR and #18 MX free with those titles. Brazil CPI $1.05 (AppTweak). |
| 19 | **In-app events and a featuring nomination** (e.g. "YKS/YDS 30-day word challenge") | M / M | Apple: submit 2 weeks to 3 months ahead; localization quality is a featuring factor. Phiture claims 50%+ impression lift during event windows. |
| 20 | **Compliance hygiene**: clear price/trial disclosure, KVKK transfer mechanism, no sensitive-data questions, 13+ posture | Risk-reducer / M | Apple 3.1.2; KVKK Art. 9 (2024); CNIL (OS permission ≠ consent); COPPA amendments (2026-04-22); Turkish Competition Authority probe. |

**Optional margin tactic.** A web checkout button for US traffic: US guideline 3.1.1(a) allows it, but the commission remains unsettled and IAP is still expected. Test only for US traffic.

**Biggest evidence gaps**
- No Education-specific retention or refund medians.
- No vocabulary-app creator-program numbers.
- No Turkish TikTok edu-account data.
- No Meta CPI for Education.
- No Monkey Taps founder numbers.

Each of these needs your own A/B tests or paid-tool data.