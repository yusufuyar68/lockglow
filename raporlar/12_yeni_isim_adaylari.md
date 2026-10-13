# Naming and brand-clearance report (2026-10-11): preliminary screening, not legal advice

**Recommendation:** Lumiglot is the best overall pick. Verbaluz is the safest pick if you want no Spanish-slang flag.

I screened about 150 candidates against the US iTunes index and domains, then ran 12 to 15 through the deeper checks. The 2026 App Store is flooded: almost every real-word or Latin name had exact-name apps, so only blends and coinages survived. Raw outputs are in `...\scratchpad\names2\` (`pass1-5.jsonl`, `deep1-3.jsonl`, `tm*.txt`, scripts `screen.mjs`, `tm.mjs`, `play.mjs`).

## What was and wasn't checkable
- **Apple App Store:** the iTunes Search API worked for the us, tr, vn, mx, ru, es, de and gb storefronts. Example link: https://itunes.apple.com/search?term=lumiglot&entity=software&country=tr&limit=50
- **Google Play:** the search page is server-rendered and fetchable. A clean result reads "No results for X". Example link: https://play.google.com/store/search?q=lumiglot&c=apps
- **USPTO:** the public JSON endpoint behind https://tmsearch.uspto.gov worked with no captcha. I ran exact, fuzzy and prefix queries and found no exact mark for any of the top 5.
- **Trademarks outside the US: not checked.**
  - WIPO Global Brand DB is behind an ALTCHA captcha, which I did not touch.
  - TMview connection was reset (ECONNRESET).
  - EUIPO eSearch is a JS shell that can't be queried.
  - Justia is behind a Cloudflare challenge.
  - TÜRKPATENT was not attempted.
  - Web searches for each name found no marks, but that is not a registry check.
- **Domains:** RDAP URLs used were `rdap.verisign.com/com/v1/domain/<n>.com` and `pubapi.registry.google/rdap/domain/<n>.app`. 404 means probably free.
- **TikTok:** page fetches hit a challenge, but the public oEmbed endpoint (`tiktok.com/oembed?url=https://www.tiktok.com/@<name>`) returns JSON for existing accounts and 400 for missing ones. I checked it against duolingo (exists) and a gibberish handle (400).
- **Instagram:** WebFetch shows profile data when an account exists and a bare shell when it doesn't. "Nothing shown" therefore means likely free, but it is inferred, not confirmed.
- **Linguistic checks:** from my own knowledge plus a few web searches. A native-speaker check is still advisable, especially Vietnamese, which I could not verify.

## Cross-cutting flag for the "Lumi-" names
In Spain, "lumi" and "lumia" are colloquial slang for "prostitute". RAE lists "lumia", and Nokia Lumia ran into this in 2011. Usage in Latin America is disputed or unknown. Lumiglot, Dilumi and Lumisoz carry this as a prefix inside a coined word. I rate it low-to-moderate, since Nokia sold Lumia in Spain anyway. If Spain matters, prefer Verbaluz or Silabo.

Sources: [NBC News](https://www.nbcnews.com/news/world/nokias-lumia-translates-prostitute-spanish-flna119762), [Windows Central](https://windowscentral.com/lumia-spanish-prostitute), [Langenscheidt](https://en.langenscheidt.com/spanish-german/lumi).

## TOP 5

### 1. Lumiglot (8 chars, lu-mi-glot) — overall risk: Low–Med
- **Meaning:** lumi- (Latin lumen, light) plus -glot (Greek glotta, tongue or language, as in "polyglot"). It reads as "light of language", which fits a lock-screen glow.
- **Turkish reading:** "lu-mi-GLOT", every letter as spelled. Turks know "poliglot". Heard aloud, the likely misspellings are only a final "-lod" or "-klot".
- **Linguistic check:**
  - Turkish: no meaning or negative found.
  - Spanish: the "lumi" slang flag above. "-glot" reads as in "políglota".
  - Vietnamese: no meaning found (unverified). It will be said "lu-mi-gờ-lốt".
  - Russian "Люмиглот": "-глот" echoes "полиглот" (polyglot), which is positive. No negative found.
  - German and English: no meaning.
- **App stores:** no app named Lumiglot in the us, tr, vn, mx, ru, es, de or gb stores. Google Play returns "No results for lumiglot".
- **Trademarks:**
  - US: no LUMIGLOT. Nearest live marks are in unrelated classes.
    - LUMIGLOW, Ser. 99927597, class 28 puzzles, Melissa & Doug
    - LUMIGLO, Ser. 78086156 (reagents), 97733615 (bags), 99308230 (grapevines)
  - Elsewhere: not checked, blocked.
- **Domains:** lumiglot.com RDAP 404, lumiglot.app RDAP 404. Both are probably free, and this is the only top-5 name with both free.
- **Social:**
  - Instagram: @lumiglot exists. It is a small active account (42 followers, bio "Finding tales untold.", 12 posts). I could not tell its topic. https://www.instagram.com/lumiglot/
  - TikTok: @lumiglot oEmbed returns 400, so likely free.
  - Variants such as @lumiglotapp showed nothing (likely free, unverified).
- **App Store title:** "Lumiglot: Vocabulary Widget" (27)
- **Subtitle:** "English words on lock screen" (28)

### 2. Verbaluz (8 chars, ver-ba-luz) — overall risk: Low
- **Meaning:** verba (Latin, words) plus luz (Spanish/Portuguese, light), so "light of words". It is transparent to Spanish speakers and not slang-flagged.
- **Turkish reading:** "ver-ba-LUZ". If heard from a Spanish speaker ("lus") it might be written "verbalüz".
- **Linguistic check:**
  - Turkish: "verbal" is known; no negative found.
  - Spanish: "verbal" plus "luz" is transparent.
  - Vietnamese: final "z" will be dropped or voiced "lút"; no meaning found.
  - Russian: "верба" means willow, which is neutral to pleasant. No negative found.
  - German: V is read as [f], so "Ferbaluz", but no meaning.
  - English: reads as "verbal" plus "uz".
- **App stores:** no app named Verbaluz in the us, tr, vn, mx, ru, es, de or gb stores. Google Play has no exact match (fuzzy suggestions only).
- **Trademarks:**
  - US: no VERBALUZ. Nearest live marks:
    - VERBAL, Ser. 88462948 (class 9/41, individual in Japan)
    - VERBAL, Ser. 99886488 (class 9, digital media hubs)
    - VERALUZ, Ser. 98433956 (class 21 kitchenware, Argentina)
  - Elsewhere: not checked.
- **Domains:**
  - verbaluz.com is taken (registered 2025-09-07, redirects to an l.ink holding page).
  - verbaluz.app RDAP 404, probably free.
- **Social:** TikTok @verbaluz is likely free (400). Instagram @verbaluz showed nothing, likely free.
- **App Store title:** "Verbaluz: Vocabulary Widget" (27)
- **Subtitle:** "English words on lock screen" (28)

### 3. Silabo (6 chars, si-la-bo) — overall risk: Low–Med
- **Meaning:** syllable or syllabus. "Sílabo" means syllabus in Chile, Ecuador and Peru, and Italian has "sillabo". It signals learning directly.
- **Turkish reading:** "si-la-BO". Turkish "sıla" (homeland) is a phonetic neighbour, but it is harmless.
- **Linguistic check:**
  - Spanish: a real word. It is descriptive for education in the Andean countries (e.g. "e-sílabo" systems), which weakens distinctiveness. Mexico more often says "programa" or "temario".
  - Italian: the Sillabo is also the Syllabus of Errors (per a search summary; verify in DLE).
  - Russian: "Силабо" echoes "сила", no negative.
  - Vietnamese, German and English: no meaning found.
- **App stores:** no app named Silabo in the us, tr, vn, mx, ru, es, de or gb stores. The only fuzzy hit is the unrelated "UniPilot: AI Study Planner". On Google Play the nearest is Silabando, a Portuguese kids' literacy app (com.appsbergman.silabando).
- **Trademarks:** no SILABO in the US. Nearest is SILABS, Ser. 78550376, Silicon Labs, class 9 semiconductors. Elsewhere: not checked.
- **Domains:** silabo.com is taken (since 2012; the site was unreachable). silabo.app RDAP 404, probably free.
- **Social:** Instagram @silabo exists but is dormant (4 followers, one 2015 post). TikTok @silabo exists ("SilaBo").
- **App Store title:** "Silabo: Vocabulary Widget" (25)
- **Subtitle:** "Learn English on lock screen" (28)

### 4. Dilumi (6 chars, di-lu-mi) — overall risk: Low–Med
- **Meaning:** "dil" (Turkish for language or tongue; also "heart" in Hindi/Urdu) plus lumi (light). It is the strongest Turkish-first story of the five.
- **Turkish reading:** "di-lu-MI". It is spelled as heard.
- **Linguistic check:**
  - Turkish: no negative found.
  - Spanish: the "lumi" flag, but "Dilumi" as a whole has no meaning.
  - Russian "Дилуми", Vietnamese, German and English: no meaning found.
  - It may resemble Sri Lankan given names such as Dilum/Dilumi (unverified).
- **App stores:** no app named Dilumi in any of the 8 storefronts (the US store returns 0 results at all). Google Play has no exact match.
- **Trademarks:** no DILUMI in the US. Nearest marks are unrelated:
  - DILUMIX, Ser. 50146209, animal feed, Brazil
  - ILUMI, Ser. 90033243 and 97507947, dental and medical
  - a cancelled ILUMI smart-bulb app mark, Ser. 85662560
  - Elsewhere: not checked.
- **Domains:** dilumi.com is for sale at HugeDomains (registered 2015, price unknown). dilumi.app RDAP 404, probably free.
- **Social:** Instagram @dilumi is taken (private personal account, about 1k followers). TikTok @dilumi is taken ("Dil Umi").
- **App Store title:** "Dilumi: Vocabulary Widget" (25)
- **Subtitle:** "Learn English on lock screen" (28)

### 5. Lumisoz (7 chars, lu-mi-soz) — overall risk: Low–Med
- **Meaning:** lumi plus söz (Turkish for "word"), written without the ö as Turkish users do online. The story is Turkish-only.
- **Turkish reading:** "lu-mi-SÖZ". Heard aloud, it may be written "lumisöz" or "lumisoz".
- **Linguistic check:**
  - Spanish: the "lumi" flag; "soz" has no meaning.
  - English: "soz" is British slang for "sorry", which is mild and cute.
  - Russian, Vietnamese and German: no meaning found.
- **App stores:** no app named Lumisoz in the 8 storefronts. Google Play returns "No results for lumisoz".
- **Trademarks:** no LUMISOZ in the US. Nearest marks are LUMISO, Ser. 79324706 (Palintest, class 1/9 water-testing) and LUMISOL, Ser. 88623577 (class 1/2/6). Elsewhere: not checked.
- **Domains:** lumisoz.com RDAP 404 and lumisoz.app RDAP 404. Both are probably free.
- **Social:** Instagram @lumisoz is a placeholder (1 follower, no posts). TikTok @lumisoz is likely free (400).
- **App Store title:** "Lumisoz: Vocabulary Widget" (26)
- **Subtitle:** "English words on lock screen" (28)

## Other screened names and why they were dropped
| Name | Reason dropped |
|---|---|
| Lumilex | Contains "x". Instagram @lumilex and TikTok @lumilex are taken. lumilex.com is an active Israeli LED military/defense company, and lumilex.app is free. No US exact mark (one dead 2010 class-17 filing). Reserve alternative. |
| Lumiverb | USPTO near-mark LUMIVERO (live, classes 9/41/42, Lumivero LLC; Ser. 99897253, 97639013, 97639024), one letter away. .app is taken and .com is parked. |
| Verbalo | USPTO near-mark VERBAGO (live, class 9, language-learning software, Ser. 99605990), one letter away in the same field. |
| Verbluz | Clean (.com and .app both free, no store hits) but "rbl" is clunky. Verbaluz supersedes it. |
| Frasis, Fraso | Both clean in stores and US trademarks. Weak meaning (phrase). Fraso: IG and TikTok taken, fraso.com redirects to a German spa firm. Frasis: IG @frasis is a private personal account. Near "Frasify", an existing language-learning app. Runner-ups. |
| Lisano | Clean in stores and US trademarks, but .com and .app are both taken and the "lisan" (Arabic/Turkish for language) evocation is weak. |
| Kelimi, Kelimer | Clean, but only Turkish-descriptive ("kelime" is word) and meaningless elsewhere. |
| Lumilo | Crowded "Lumi-" trademark neighbourhood (LUMILY class 9 app, Ser. 99753341; LUMIQO; LUMIO). .com and .app both taken. |
| Dikto | Phonetic "dick" and Turkish "dik-" innuendo risk. Near DITTO (many live class 9/42 marks). |
| Hecelo | .com and .app both free, but Turkish c=/dʒ/ versus Spanish/English readings break the read-aloud rule. |
| Mirelo | Live exact US mark MIRELO (class 5 supplements, Ser. 99912872). Meaning unclear. |
| Lexira, Lexora, Lexilo, Lexeo, Lexiva, Lexero, Lexivo, Lexigo, Lexion, Lexis, Leksi, Leksa | All contain "x" or have exact apps/companies. Lexira has exact apps plus the Turkish firm LEXIRA YAZILIM. Lexeo is Lexeo Therapeutics (Nasdaq: LXEO). Lexilo is an Education app. |
| Verbi, Verbo, Verbia, Verbli, Verbly, Verba, Verbis, Verbum | Exact or direct competitor apps. Verbi and Verbo are Education apps, and Verbli is near Verbling Inc. Verbia is a company name. |
| Palabri, Letri, Logia, Glossa, Glossi, Glosso, Glosa, Frasi | Crowded niches or exact apps. Palabri: Palabria, Palabrio, Palabritas and Palabrita. Letri: Letris and Letria. Glossa: 4 exact apps. |
| Lumora, Lumio, Lumino, Lumo, Lumeo, Lumeta | 5 to 27 exact apps each, and crowded trademarks. |
| Kelimo, Kelam, Kelimat, Kalimo | 2 to 6 exact apps. |
| Lekto | "School Timetable Widget: Lekto" is an Education widget app. |
| Vorto | Vorto Technologies (logistics, many apps). |
| Parla, Parlo, Hablo, Sayla, Neno, Tolka, Glimo, Tilora, Slovo, Hodie, Vitrina, Lecta, Lectio, Dilek, Savio, Nolo, Lugat, Vani, Sapio, Gnosi, Scribo, Scriba, Mentora, Notio, Brevia, Glint, Tinta, Verso, Lemmo, Harfi, Dilo, Lucero, Mnemi, Mirada | Each has 1 to 9 exact or starts-with apps in the US store. Mirada's meaning is also "glance" in Spanish, so it is close to your rejected pattern. |
| Dilora | 0 apps, but reads as a given name (cf. Turkish "Dilara"). |
| Lumilia, Lumiglota | Four syllables or no added value. |

Not verified: I did not check Lexiva or Lumeta from the web this session. Treat my notes on those two as unconfirmed.
