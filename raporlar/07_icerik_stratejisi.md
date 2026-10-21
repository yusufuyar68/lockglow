# Content strategy: iOS vocabulary-widget app (EN learned, TR first L1)

Date: 2026-10-10. Scope: product-side content only. No files were written to the project folder. Working files (sample dataset, validator, taxonomy script) are in the scratchpad: `C:\Users\yusuf\AppData\Local\Temp\claude\C--Users-yusuf-OneDrive-Desktop-Widget-Vocabulary--learn-words\e927268b-3cbe-437d-b9e4-b39cf6e813db\scratchpad\content\` (`sample_dataset_slim.json`, `sample_data.js`, `validate.js`, `taxo.js`).

---

## 0. Executive summary (decisions I recommend)

1. **Launch with about 4,000 carefully calibrated cards, not "10,000+".** Competitors claim 10K to 25K, but their main review complaint is level mismatch, not size. 4,000 cards across 7 levels and 60 categories gives a non-repeating pool of about 5 to 8 months for a typical level+topic selection (maths in §3). Grow to about 20,000 over 18 to 24 months (about 1,000 per month).
2. **Differentiate on quality and the Turkish layer, not word count.** None of the big widget apps I audited offers Turkish-specific false friends, L1 mistake notes, or serious YDS/YÖKDİL content inside a polished widget app. Orbit Studios' "Widget Vocabulary" already has about 190 ratings on the Turkish storefront, so Turkish is not empty.
3. **Author three text tiers per card** (`micro` ≤28, `short` ≤80, `long` ≤220 chars) and never auto-truncate. Widgets are the product, and truncated definitions read badly.
4. **One card = one lemma + one sense** (or one multiword expression). The Turkish layer is an overlay (`l1.tr`) so a second L1 later costs about 40% of a new entry, not 100%.
5. **LLM cost is trivial (about $0.02 to 0.05 per entry, assumption-based). Human review is about 90% of the content budget** (about 120 to 150 reviewer-hours for launch).
6. **Weakest LLM fields are IPA, etymology, CEFR level and Turkish naturalness.** Source IPA from a pronunciation dictionary, make etymology optional with a confidence flag, and keep a bilingual human in the loop. The sample dataset shows what that looks like. In my own verification pass I had to correct three etymologies and one set of Turkish spellings.

---

## 1. Competitor content audit

Method: iTunes Search/Lookup API (US storefront unless noted), App Store descriptions and screenshots (viewed), developer sites. I did not hands-on test the apps, so in-app category lists are partial. Rating counts are as of 2026-10-10. "n/s" means not stated.

| App (developer) | Ratings (avg) | Library size claim | Levels | Topics / packs seen | Widget/content notes |
|---|---|---|---|---|---|
| **Vocabulary – Learn words daily** (Monkey Taps) | 219.6K (4.77) | "10,000+ words" (screenshot and FAQ) | 4 (beginner, intermediate, advanced, expert per their site). Reviewers say the advanced level still serves basic words | Topics grouped in the UI ("About ourselves": Emotions, Human body, People, Sexology…). Curated collections: Elegant Adjectives, Mythical Words, Words about emotions, Beautiful Words. "Journey" chapters (e.g. "Words Everyone Should Know"). User-added words, collections, favorites, history | Lock-screen widget shows lemma + "(v.) To clarify, explain" (about 25 chars). 6 UI languages. Premium price points seen on the US page: $9.99 to $149.99 (monthly $14.99, annual $35.99 to 59.99, lifetime $149.99) |
| **Word of the Day・Vocabulary** (Vocabulous) | 39.0K (4.67), claims 7M+ downloads | n/s | Assessment-based personalized plan | Editor-picked daily word with illustration. "Stop Saying" swap collections (very good → excellent). SAT/GRE/IELTS/TOEFL positioning. Games, crosswords in 15+ topics (Entertainment, Technology, Travel, Idioms…) | Home and Lock widgets. Daily quizzes, SRS. 10 UI languages. Subscription |
| **Widget Vocabulary: Learn Words** (Orbit Studios, your reference app) | 418 US (4.72); 190 TR (4.37). Launched 2026-06-24 | "thousands of flashcards", "1,000+ quiz levels" | A1 to C2 | Exam packs IELTS/TOEFL/GRE/SAT. Rare words (screens: solivagant, vellichor, sonder, limerence, petrichor, sagacious). Multiple learned languages (ES, FR, DE, IT, PT…). TTS pronunciation | Lock and Home widgets, 6+ widget skins. Weekly + yearly premium. English-only UI |
| **WordUp** (Geeks) | 13.8K (4.76) | "25,000 most common English words" (prioritized via a "knowledge map") | Adaptive | Idioms and phrasal verbs with AI images. AI tutor chat. 9 challenge types | Not widget-first |
| **Vocabulary Builder by Atlas** (Sayan Yazılım, Turkish developer) | 12.5K US (4.77); 8.6K TR | "thousands of words, phrases, idioms" | Placement test: Beginner to "Super-Proficient" | Curriculum per level plus Idioms, Phrasal Verbs, Academic, Business, Exam (TOEFL/GRE/SAT/IELTS). WOTD with short article and illustration | Home widgets. AI tutor. 7 UI languages |
| **New Vocabulary Builder: Daily** (Zamalabs, Turkish developer) | 34 (4.79) | "17K+ words, 42 categories" | CEFR chip visible (B1 in screenshot) | Custom categories from favorites | Lock and Home widgets with configurable refresh rate |
| **MyVocab** (Positive Mindset) | 364 (4.68) | "thousands, by category" | Level selector | Science, Technology, Business, Nature, History, Architecture, Cinema, Psychology, Literature… | 180+ fonts/backgrounds, collections, sharing |
| **Learn on Widgets** (Turkish developer) | 1 | "500 Oxford-verified words" (claim; avoid any similar claim yourself) | n/s | Idioms, phrases | Premium "+300 new words/month", 13 languages. $9.99/mo or $39.99 lifetime |
| *Turkish storefront peers* | | | | | |
| Kolay İngilizce Kelime Öğren | 36.9K TR (4.80) | 10 words/day, 300/month | n/s | SRS, leaderboards | Not widget-first |
| English Words Trainer | 5.3K TR (4.86) | "4,000+ words by category" | 3 | Verbs, adjectives, people, nutrition, health, education, home, work, fashion, hobbies, nature, animals, travel, justice, skills. SRS at 1/3/7/30/120 days | Pictures, video, 16 UI languages |
| Kelime+ (YDS/YÖKDİL) | 1.6K TR (4.62) | Top-1,000 YDS words (2013 to 2018) + 1,000 more | n/s | YDS/e-YDS/YÖKDİL only | **Home, Lock and Control Center widgets.** ₺49.99/month. The only focused Turkish exam widget app I found |
| Blarma | 5.0K TR (4.72) | n/s | n/s | AI stories, 30 languages | Not widget-first |
| Magoosh Vocabulary Builder | 7.0K US (4.72) | about 1,200 words (third-party guide) | Leveled | GRE/SAT oriented | Reference point for a "small but curated" library |

**Takeaways**
- Claimed library sizes range from 500 to 25,000. Nobody publishes per-topic counts. Top-rated apps do not win on size.
- Topic counts are 9 to 42. Common shelves: emotions, personality, tech, business, science, nature, history, psychology, literature. Two recurring "hooks": curated "beautiful/rare/elegant" collections and exam packs (IELTS/TOEFL/GRE/SAT).
- Levels: CEFR (Orbit, Zamalabs) vs generic 3 to 4 tiers (Monkey Taps, EWT) vs placement tests (Atlas, Vocabulous). Level purity is a visible pain point.
- Widget content is minimal: lemma + POS + a gloss of about 25 to 40 chars. Almost nobody shows IPA or an L1 gloss on the widget.
- **Whitespace:** (a) Turkish L1 quality layer (false friends, mistakes, nuance notes), (b) YDS/YÖKDİL in a premium-feeling widget app, (c) collocations, phrasal verbs and "stop saying" in widget form, (d) calibrated levels, (e) interactive widget quizzes (iOS 17+), (f) honest, per-category counts.
- Licensing, briefly: do not copy definitions, examples or level lists from Oxford/Cambridge/Merriam-Webster/Collins, and avoid "Oxford-verified"-style claims. NGSL (about 2,800 words, about 92% text coverage) and NAWL (963 words) are useful seed lists, but my search could not confirm their license terms. Defer to the licensing agent.

---

## 2. Proposed taxonomy

### 2.1 Levels (7)

| Level | UI name EN / TR | Scope | MVP cards | Full library |
|---|---|---|---|---|
| A1 | Starter / Başlangıç | Top everyday survival words | 250 | 700 |
| A2 | Elementary / Temel | Common daily-life words | 450 | 1,200 |
| B1 | Intermediate / Orta | Work, travel, opinions | 700 | 2,200 |
| B2 | Upper-Intermediate / Orta-Üstü | Abstract topics, exam core | 800 | 3,600 |
| C1 | Advanced / İleri | Formal, academic, nuance | 750 | 4,300 |
| C2 | Mastery / Uzman | Low-frequency but standard | 450 | 3,500 |
| S | Fancy words / Havalı kelimeler | Rare, literary, "sound smarter", "beautiful" words beyond learner lists | 600 | 4,350 |
| | | **Total** | **4,000** | **19,850** |

Rules:
- **Level and topic are orthogonal.** Every card has exactly one `level` and one `primary_topic` (for counting) plus up to 3 secondary topics.
- **S-level inclusion criteria:** attested in at least 2 reliable dictionaries; usable in a real sentence; at most 5% archaic; at most 5% coined words (flagged `coined`, e.g. *sonder*); no slurs.
- **CEFR assignment:** use a licensed/open CEFR list where one exists (licensing agent), otherwise `editorial_estimate`. Frequency is only a weak proxy (concrete words like *luggage* are rare but easy), so use it as a sanity check and for the S cutoff.
- **Level purity rule:** serve level L only. Optionally allow L-1 for review. This directly fixes the Monkey Taps complaint.
- **Placement test:** about 24 adaptive questions drawn from about 240 anchor cards (about 40 per level). It sets the start level and is re-tuned by "know it / still learning" taps.
- **Personas:** (1) exam-taker (YDS/YÖKDİL/IELTS/TOEFL, B1 to C1), (2) career English (B1 to C1), (3) word-nerd (C2/S, a global audience), (4) beginner (A1/A2). MVP weights B1 to C1 (56%).

### 2.2 Topic categories (60)

Legend: **F** = free; **S** = sample (first 30% free, min 20); **P** = premium (10-card taster free). **HERO** = launch marketing and screenshot category. Counts are primary-category cards (no double counting). Single-word vs multiword at launch: about 3,450 single-word cards and about 550 multiword cards.

| # | Category (`id`) | Levels | MVP | Full | Access |
|---|---|---|---|---|---|
| | **A. Everyday Life** | | | | |
| 1 | Food & Drink `food_drink` | A1-B2 | 100 | 400 | F |
| 2 | Home & Household `home_household` | A1-B2 | 80 | 250 | F |
| 3 | Family & Relationships `family_relationships` | A1-B2 | 70 | 220 | F |
| 4 | Clothes & Fashion `clothes_fashion` | A1-B2 | 60 | 220 | F |
| 5 | Shopping & Money `shopping_money` | A1-B2 | 70 | 220 | F |
| 6 | Health & Body `health_body` | A1-B2 | 80 | 300 | F |
| 7 | Cities, Transport & Directions `cities_transport` | A1-B2 | 80 | 330 | F |
| 8 | Weather & Seasons `weather_seasons` | A1-B1 | 40 | 150 | F |
| 9 | Time, Dates & Daily Routines `time_routines` | A1-B1 | 50 | 150 | F |
| 10 | Hobbies, Sports & Games `hobbies_sports` | A1-C1 | 80 | 300 | S |
| 11 | School & Learning `school_learning` | A1-B2 | 60 | 220 | F |
| 12 | Nature, Animals & Outdoors `nature_animals` | A1-C1 | 60 | 300 | S |
| | *subtotal* | | *830* | *3,060* | |
| | **B. Travel & Culture** | | | | |
| 13 | Travel & Tourism `travel_tourism` | A2-C1 | 70 | 300 | S |
| 14 | Countries, Culture & Celebrations `culture_celebrations` | A2-C1 | 50 | 250 | S |
| | *subtotal* | | *120* | *550* | |
| | **C. People, Feelings & Social** | | | | |
| 15 | Emotions & Feelings `emotions_feelings` (HERO) | A1-C2 | 110 | 350 | F |
| 16 | Personality & Character `personality` | A2-C2 | 80 | 280 | S |
| 17 | Social Skills & Small Talk `social_skills` | A2-C1 | 60 | 200 | S |
| 18 | Compliments & Insults (PG) `compliments_insults` | B1-C2 | 60 | 220 | S (compliments free, insults premium) |
| 19 | Love, Dating & Friendship `love_friendship` | A2-C1 | 40 | 180 | S |
| 20 | Mind, Psychology & Habits `mind_psychology` | B2-C2 | 70 | 240 | S |
| 21 | Opinions, Debate & Persuasion `opinions_debate` | B1-C2 | 50 | 200 | P |
| 22 | Success, Motivation & Productivity `success_productivity` | B1-C2 | 50 | 200 | S |
| | *subtotal* | | *520* | *1,870* | |
| | **D. Work, Money & Society** | | | | |
| 23 | Business & Management `business_management` | B1-C2 | 70 | 400 | P |
| 24 | Workplace & Office English `workplace_office` | B1-C1 | 60 | 300 | S |
| 25 | Careers & Job Interviews `careers_interviews` | B1-C1 | 40 | 200 | S |
| 26 | Finance & Economics `finance_economics` | B1-C2 | 50 | 350 | P |
| 27 | Marketing, Sales & E-commerce `marketing_ecommerce` | B2-C2 | 20 | 200 | P |
| 28 | Law & Legal `law_legal` | B2-C2 | 30 | 220 | P |
| 29 | Politics & Government `politics_government` | B2-C2 | 30 | 200 | P |
| 30 | Society, Media & News `society_media` | B1-C2 | 40 | 220 | S |
| | *subtotal* | | *340* | *2,090* | |
| | **E. Science, Tech & Health** | | | | |
| 31 | Technology & Internet `technology_internet` | A2-C2 | 80 | 300 | S |
| 32 | AI, Data & Programming `ai_data_programming` | B2-C2 | 40 | 280 | P |
| 33 | Science & Space `science_space` | B1-C2 | 50 | 300 | S |
| 34 | Medicine & Healthcare (professional) `medicine_healthcare` | B2-C2 | 50 | 350 | P |
| 35 | Environment & Climate `environment_climate` | B1-C2 | 50 | 200 | S |
| 36 | Engineering, Construction & Maths `engineering_maths` | B2-C2 | 0 | 250 | P |
| | *subtotal* | | *270* | *1,680* | |
| | **F. Arts, Media & Ideas** | | | | |
| 37 | Literature & Writing `literature_writing` | B1-C2 | 40 | 220 | S |
| 38 | Art, Design & Architecture `art_design_architecture` | B2-C2 | 20 | 200 | P |
| 39 | Music, Film & Entertainment `music_film` | A2-C1 | 30 | 200 | S |
| 40 | History & Mythology `history_mythology` | B2-C2 | 30 | 160 | S |
| 41 | Philosophy & Ethics `philosophy_ethics` | C1-S | 20 | 150 | P |
| | *subtotal* | | *140* | *930* | |
| | **G. Language Craft (word types)** | | | | |
| 42 | Phrasal Verbs `phrasal_verbs` (HERO) | A2-C1 | 200 | 800 | S (first 50 free) |
| 43 | Idioms & Expressions `idioms_expressions` (HERO) | B1-C2 | 180 | 700 | S (first 50 free) |
| 44 | Collocations & Word Partners `collocations` | B1-C1 | 60 | 550 | P |
| 45 | Everyday Slang & Informal English `slang_informal` | B1-C1 | 60 | 250 | P |
| 46 | Proverbs & Sayings (with Turkish counterparts) `proverbs_sayings` | B1-C1 | 30 | 120 | S |
| 47 | Confusing Words & Turkish False Friends `confusing_words` (HERO) | A2-C1 | 100 | 300 | F |
| 48 | Roots, Prefixes & Word Families `roots_word_families` | B2-C2 | 40 | 200 | P |
| 49 | "Stop Saying X" Power Swaps `stop_saying` | B1-C2 | 50 | 200 | S |
| | *subtotal* | | *720* | *3,120* | |
| | **H. Sophisticated / "Fancy" Words** | | | | |
| 50 | Words That Make You Sound Smarter `sound_smarter` (HERO) | C1-S | 160 | 500 | S |
| 51 | Rare & Beautiful Words `rare_beautiful` (HERO) | C2-S | 150 | 400 | S |
| 52 | Literary & Poetic Words `literary_poetic` | C2-S | 60 | 250 | P |
| | *subtotal* | | *370* | *1,150* | |
| | **I. Exam Packs** | | | | |
| 53 | Academic Core (incl. academic writing phrases) `academic_core` | B2-C1 | 120 | 600 | S |
| 54 | IELTS Academic `ielts` | B2-C2 | 60 | 600 | P |
| 55 | TOEFL iBT `toefl` | B2-C2 | 50 | 500 | P |
| 56 | SAT / ACT `sat_act` | C1-C2 | 80 | 500 | P |
| 57 | GRE `gre` | C2-S | 80 | 700 | P |
| 58 | YDS / YÖKDİL Core `yds_yokdil_core` (HERO, Turkish) | B1-C1 | 300 | 1,400 | P |
| 59 | YÖKDİL Fields (Fen / Sağlık / Sosyal) `yokdil_fields` | B2-C2 | 0 | 800 | P |
| 60 | TOEIC / Business English Exams `toeic_business` | B1-C1 | 0 | 300 | P |
| | *subtotal* | | *690* | *5,400* | |
| | **TOTAL (60 categories)** | | **4,000** | **19,850** | F: 12, S: 26, P: 22 |

Access model result: about 1,670 of 4,000 launch cards (about 42%) are free. That is generous enough for a good widget experience and reviews, while premium holds depth (exam packs, professional fields, collocations, slang, custom lists).

YDS/YÖKDİL notes (verify against the ÖSYM guide): YÖKDİL has three field booklets (Fen, Sağlık, Sosyal), hence category 59. Commercial prep sites put vocabulary at about 6 of 80 questions, but vocabulary underlies reading; this split is unverified. The YDS pack should carry a `synonym_cluster_id` per card (YDS rewards synonym recognition). Do not copy ÖSYM question text; build your own list from frequency plus editorial judgment.

---

## 3. MVP size and growth plan

**Recommendation: ship 4,000 cards** (table above, 60 categories; range 3,500 to 4,500).

Why 4,000:
- Covers a complete A1→C2 path and the four hero hooks (Sound Smarter, Rare & Beautiful, Phrasal/Idioms, Turkish False Friends) plus a real YDS/YÖKDİL starter pack.
- **No-repeat horizon:** a typical user (one level, plus the adjacent one, plus 5 topics) has a pool of about 450 to 700 cards. At the default of 3 to 5 new words/day (widget exposures beyond that are reviews), the pool lasts about 4 to 8 months. S-level at 600 cards lasts about 120 days at 5/day. This is why S, C1 and B2 get the most MVP cards.
- Review load is feasible: about 120 to 150 human hours (§6).

Launch gates (do not ship until true): every level has at least 250 cards; every visible category has at least 20 cards (hide categories with 0, e.g. #36, #59, #60); 100% of cards have the Turkish layer; Tier-A cards (top 1,200) are fully human-reviewed; all sensitive/opt-in categories are gated.

**Growth plan**

| Milestone | Total cards | Main additions |
|---|---|---|
| Launch (M0) | 4,000 | Table above |
| M+2 | 6,500 | Exam packs to about 250 each; YDS core to about 700; Business, Finance, Tech, Medicine |
| M+4 | 9,000 | Collocations, slang, Law, Politics, AI/Data; first seasonal packs |
| M+6 | 11,500 | YÖKDİL fields launch; S-level to about 2,000; **second L1 overlay on the core 4,000** (Spanish-LatAm, Portuguese-BR and Arabic are my hypotheses, to validate with market data) |
| M+9 | 15,000 | Arts, Engineering, Marketing, TOEIC |
| M+12 | 17,500 | Long-tail topics; user-requested lists promoted into the catalog |
| M+18 to 24 | about 20,000 | Full table |

Cadence: about 250 reviewed cards/week; "weekly drop" push; every release publishes a content version so fixes go out without an app update (hotfix target 48h).

---

## 4. Word entry schema (v1.0)

Design rules:
- One card = one lemma + one sense (or one multiword expression). `id = lang.lemma_slug.pos.senseNo`. Add a second card for a second sense only if it carries at least 20% of usage (e.g. *look up* vs *look up to*).
- All L1 content lives in `l1.<lang>`; nothing Turkish-specific is at the top level.
- Three authored definition tiers (`micro/short/long`), authored, not truncated.
- Character limits are in Unicode grapheme clusters. Turkish strings run about 15 to 25% longer, so TR limits are slightly larger.
- Sample JSON omits default/empty values (listed in `defaults`).

| Field | Req | Limit | Used on |
|---|---|---|---|
| `id`, `lemma` | R | lemma ≤28 | all (lemma auto-shrinks to 60%) |
| `type` | R | word / phrasal_verb / idiom / collocation / proverb / phrase | filters |
| `pos` | R | n v adj adv prep conj pron det interj phv idm phr | all |
| `sense_no`, `sense_note` | R/O | note ≤40 | app |
| `level` | R | A1..C2, S. `level_source`: list / editorial_estimate / editor_verified | filters |
| `freq` | O | `rank` int, `zipf` float (null for multiword) | sorting |
| `ipa.us`, `ipa.uk` | R (single words) | ≤26 each | small+ |
| `audio.us/uk` | O | file ids | app |
| `def.micro` | R | ≤28 | lock inline/rect, watch, notification title |
| `def.short` | R | ≤80 | small, medium |
| `def.long` | R | ≤220 | large, app |
| `grammar.pattern` | O | ≤50 | app (verbs, phrasals) |
| `examples[2-3]` | R | `en` ≤80 first / ≤110; `tr` ≤100 / ≤130; `register`; `focus` (exact surface form) | medium (ex 1), large/app |
| `synonyms` / `antonyms` | O | ≤5 / ≤3, each ≤16 | large, app |
| `collocations` | O | ≤5, each ≤28 | large, app |
| `word_family` | O | ≤4 | app |
| `etymology` | O | text ≤200; `origin`; `confidence` high/medium/low | large (first sentence), app |
| `l1.tr.gloss` | R | ≤28 | small, medium, lock (2nd line) |
| `l1.tr.alt` | O | ≤3, each ≤24 | app |
| `l1.tr.equivalence` | R | full / partial / cognate / false_friend / none | app badge |
| `l1.tr.false_friend` | O | `{tr_word, tr_means, en_for_that}` | app, "false friend" pack |
| `l1.tr.note` | O | ≤220 (Turkish) | app |
| `l1.tr.mistakes[0-2]` | O | `wrong`/`right` ≤80 (English); `why` ≤200 (Turkish) | app |
| `l1.tr.mnemonic` | O | ≤160 (Turkish; sound-alikes are L1-specific) | app, large |
| `tags` | R | `primary_topic`, `topics` ≤4, `exams`, `register`, `vibes`, `flags`, `sensitivity` 0 to 2 | filters, safety |
| `quiz` | O | `cloze` ≤100 with `______`; `answer`; 3 `distractors` ≤16 | interactive widget quiz, notifications |
| `meta` | R | `status`, `qa_flags`, `prompt_ver`, `model`, `reviewer`, `reviewed_at`, `content_ver` | pipeline |

**Widget capacity (design assumptions, iPhone 15 at default Dynamic Type; validate on devices):**

| Surface | Approx. text room | Fields |
|---|---|---|
| Lock inline | 1 line, about 22 to 26 chars | `lemma` + `def.micro` or `tr.gloss` |
| Lock circular | about 6 to 9 chars | level badge / streak / truncated lemma, no definition |
| Lock rectangular, Watch | 3 lines × about 24 chars | lemma, `def.micro` (2 lines) |
| Home small, StandBy | about 5 to 6 lines × 18 to 20 chars | lemma, POS, `def.short` or `tr.gloss` |
| Home medium | about 6 to 7 lines × 36 to 40 chars | lemma, IPA, level chip, `def.short`, example 1 (≤80), `tr.gloss` |
| Home large | about 14 lines × 36 to 40 chars | + `def.long`, 2 examples with TR, synonyms, etymology (first sentence) |
| Notification | title ≤40, body about 110 | lemma + `def.short`, or quiz prompt |
| Interactive quiz (iOS 17+) | 1 prompt + 2 to 3 buttons ≤16 chars | `quiz` |

Turkish-specific tech note: uppercasing must be locale-aware (`uppercased(with: Locale(identifier: "tr"))`), otherwise "i" becomes "I" not "İ". Search should be diacritic-insensitive even though stored text follows TDK circumflex spelling (dâhil, hâlsiz).

---

## 5. Editorial guidelines and quality rubric

### 5.1 Definition style
- Substitutable fragments, sentence case, no final period for `micro`/`short`. Verbs: bare infinitive ("make something less harmful"); adjectives: a participle/adjective phrase ("found everywhere"); nouns: a noun phrase ("the first meal of the day"). `long` = 1 to 2 full sentences with at most one usage warning (confusion, formality, uncountable, false friend).
- Never use the headword or its derivatives. Use simpler words than the headword (defining vocabulary at or below CEFR level minus 1; A1 to B1 cards use basic words only).
- No parentheses in `micro`. Register labels go in tags, not the definition.
- Most frequent sense first; one sense per card; sense disambiguation in `sense_note`.
- Original text only (LLM-written from scratch plus human edit); do not paraphrase from a commercial dictionary.

### 5.2 Example sentences
- 8 to 16 words, one idea, contemporary and concrete, showing the typical collocation/pattern; vocabulary not above the headword's level; order easy→hard; use inflected forms where natural; never "X means…".
- `focus` must be the exact surface form in the sentence (validator checks it).
- First example must be public-lock-screen safe.
- Diverse, gender-balanced names (Ayşe, Mehmet, Sam, Maria, Kenji) or pronouns; no real people, brands, politics, religion, violence, sex, drugs, gambling, illness as a joke, or nationality stereotypes; do not tie negative traits to any gender, ethnicity, nationality or religion.

### 5.3 Safety and bias
- **Sensitivity tiers:** 0 clean; 1 mildly negative or rude (e.g. *condescending*), only in Insults/Compliments, clearly labeled; 2 profanity or slurs: never a headword in MVP. A future opt-in "mature" pack would need Apple's age-rating questionnaire and 17+/18+ style rating review.
- **Public-lock-screen rule:** sensitive topics (sexuality, drugs, violence, death) default OFF and are opt-in. Do not copy Monkey Taps' visible "Sexology" topic as a default shelf.
- Singular "they"; no gendered job terms; US spelling by default with UK variants in `variants`; both IPAs always.
- **Coined words** (e.g. *sonder*) get `flags: ["coined"]`, `register: informal`, a "not standard" note and `not_for_exams`.
- **Etymology:** include only if verifiable in at least two references. Null is fine. Maintain a blacklist of folk etymologies (posh = "port out, starboard home", golf = "gentlemen only, ladies forbidden", tip = "to insure promptness", OK origin myths) because LLMs reproduce them. Where origins are disputed say so (see *deadline* in the sample).

### 5.4 Turkish translation rules
1. `gloss` = the most common natural equivalent **for this sense**, dictionary form (verbs -mek/-mak, nouns nominative), ≤28 chars; up to 3 alternates, most common first.
2. **Frequency of use beats purism.** TDK purist coinages are not what people say: TDK redirects *kronik* to "süreğen", *akut* to "iveğen", *pragmatik* to "yararcı". Use *kronik, akut, pragmatik*; mention the TDK form only in `alt` or `note`.
3. Spelling follows TDK Yazım Kılavuzu including circumflex (**dâhil, hâlsiz, hâlâ, hikâye**; confirmed against the TDK dictionary API). Run a Turkish spell check (Zemberek or Hunspell tr_TR).
4. If the English item has no single Turkish equivalent, give a short paraphrase, set `equivalence: partial|none`, and explain in `note`. Never invent a calque. Mark idioms with `full` only when Turkish has a real equivalent (*break the ice* = *buzları eritmek*).
5. Example translations are natural and idiomatic, not word-for-word: pro-drop (omit "o" unless needed), natural SOV order, **-miş only for discovery/surprise** (as in the sample *actually* example), register mapping (formal = siz, informal = sen), no added or dropped information, names unchanged.
6. Technical terms: give the form people really use. If two exist, give both (*kimlik avı, oltalama*; *oltalama* is not in TDK but is common in banking and legal text).
7. `mistakes` only for genuine Turkish-L1 interference; return `[]` rather than pad. `mnemonic` must be harmless (no profanity, no mocking, no religious/political jokes) or null. All mnemonics need human approval.
8. Verification sources: TDK Güncel Türkçe Sözlük (sozluk.gov.tr, I checked terms through its API), a Turkish corpus (e.g. TNC/trTenTen) for frequency, and a bilingual human.

**Typical Turkish-L1 interference patterns (tag cards with these):** missing/extra articles; no plural after numerals ("two book"); uncountables treated as countable (information, advice, luggage, news); prepositions vs case suffixes; borrow/lend, say/tell, make/do; he/she (Turkish "o" is genderless); pronunciation: /θ ð/ and /w/→v, vowel insertion in s-clusters, final-syllable stress habit (*chronic*, *meticulous*).

### 5.5 False friends for Turkish speakers (verified against TDK unless noted)
| English | Looks like | Turkish word means (TDK) | English really means |
|---|---|---|---|
| actual / actually | aktüel | güncel | gerçek / aslında |
| sympathetic | sempatik | sevimli, hoşa giden | anlayışlı, derdini anlayan |
| enervate | enerji | güç, canlılık | hâlsiz bırakmak (opposite) |
| fabric | fabrika | factory | kumaş |
| magazine | mağaza | büyük dükkân | dergi |
| college | kolej | yabancı dil ağırlıklı okul | üniversite düzeyi kurum |
| pasta | pasta | cake | makarna |
| pension | pansiyon | guesthouse | emekli maaşı |
| casket | kasket | siperli başlık | tabut / küçük kutu |
| smoking | smokin | tuxedo | sigara içme |
| grip (English) | grip | flu | tutuş, kavrama |
| sensible | hassas | duyarlı | mantıklı |
| eventually | eventüel | olası (**marginal**: not in TDK, used in formal/commercial Turkish and via French/German) | sonunda |

### 5.6 Quality rubric (score 0/1/2 each, max 24)
Critical (must be 2, or 1 with a reviewer note): sense accuracy; Turkish gloss correctness and sense match; safety/inclusivity; etymology truthfulness; quiz validity. **PASS = 20 or more and no 0.**
(2026-10-13: criterion 12 added after the 474-card review, where multi-answer cloze quizzes were the most frequent problem. Previously 11 criteria, max 22, PASS 18.)

| # | Criterion |
|---|---|
| 1 | Sense accuracy (critical) |
| 2 | Definition clarity, simpler-than-headword, no circularity |
| 3 | Widget fit (each tier stands alone, within limits) |
| 4 | Example naturalness and typical usage |
| 5 | Example safety/inclusivity, lock-screen safe (critical) |
| 6 | Turkish gloss correctness/sense match (critical) |
| 7 | Turkish example naturalness and faithfulness |
| 8 | Learner value (collocations, mistakes, notes are genuine, no padding) |
| 9 | Etymology truthfulness, null allowed (critical) |
| 10 | Level and tags plausible (CEFR, topics; exam tags only from curated lists) |
| 11 | Pronunciation (IPA and stress verified) |
| 12 | Quiz validity: exactly one option fits the blank, no distractor also works (critical) |

---

## 6. LLM generation pipeline (product level)

**Stages:** (0) headword + sense plan (frequency, topic, level, sense inventory from the licensing agent's sources) → (1) Prompt A: English core → (2) Prompt B: Turkish layer → (3) automated validation → (4) Prompt C: independent critic (different model if possible) → up to 2 repair loops → (5) human review → (6) audio and quiz derivation → (7) versioned release; in-app "report an issue" feeds back to a queue.

**IPA is the weakest field.** Seed US IPA from a pronunciation dictionary (e.g. CMUdict ARPAbet→IPA) and have the LLM only propose UK/variants; any disagreement is a human task. Never ship LLM-only IPA for rare words.

### Prompt A: English core (system + user)
```
SYSTEM
You are a senior learner's-dictionary editor writing entries for a vocabulary widget app for adult English learners (CEFR A1-C2). You write precise, natural, culturally neutral, glanceable content. You never invent facts: if you are not certain about pronunciation, etymology, frequency or CEFR level, output null for that field and list it in "uncertain_fields". Output ONE JSON object valid against the supplied schema. No markdown, no commentary.

RULES
1 Definitions: def.micro (<=28 chars), def.short (<=80), def.long (<=220) all describe the SAME single sense in SENSE.
  - Lowercase fragment, no final period for micro/short; long = 1-2 sentences.
  - Substitutable: verb -> bare infinitive ("make something less harmful"); adjective -> adjective/participle phrase ("found everywhere"); noun -> noun phrase.
  - Never use the headword or its derivatives. Use words at least one CEFR level easier than {{target_level}} (A1-B1 entries: basic words only).
  - No parentheses in micro. Usage labels go to tags, not the definition.
  - def.long may add ONE usage warning (common confusion, formality, uncountable, false friend).
2 Examples (2-3): 8-16 words each, <=110 chars (first <=80). Natural, current, concrete, typical of real use (show the common collocation/pattern). Vary inflected forms. Never define the word inside the sentence. Order easy->hard. Vocabulary <= {{target_level}}. Names: varied and gender-balanced (e.g. Ayse, Mehmet, Sam, Maria, Kenji). No real people, brands, politics, religion, violence, sex, drugs, gambling, nationality stereotypes. Example 1 must be safe on a public lock screen. Give "focus": the exact surface form used.
3 synonyms (<=5, <=16 chars, true same-sense substitutes), antonyms (<=3), collocations (<=5, <=28 chars, high-frequency; never invent combinations), word_family (<=4).
4 etymology.text (<=200 chars): one verifiable, interesting fact in plain words. NEVER folk etymologies or acronym myths. If disputed, say so; if unsure return null. confidence: high|medium|low.
5 ipa: broad phonemic, US and UK, with stress marks. Prefer {{ipa_ref}} if supplied; otherwise null + uncertain.
6 level: CEFR estimate (+level_confidence 0-1). "S" only for rare/literary/"fancy" words beyond C2 or outside learner lists. Recent coinages: tags.flags ["coined"].
7 quiz.cloze (<=100 chars, one ______), answer = exact form, 3 distractors (<=16 chars) that are clearly wrong in context. Exactly one option may fit: no distractor may also complete the sentence correctly or naturally.
8 If the word is offensive, sexual, violent or a slur: set tags.sensitivity (1 mild, 2 strong), write NO examples, return {"skip_reason": "..."}.

INPUT
lemma: {{lemma}}   pos: {{pos}}   SENSE: {{sense_hint}}   (one card = one sense)
target_level: {{target_level}}   primary_topic: {{primary_topic}}   zipf: {{zipf}}   exam_tags(curated): {{exam_tags}}
known_confusables: {{confusables}}   ipa_ref: {{ipa_ref}}
SCHEMA: {{json_schema}}
GOLD EXAMPLES: {{gold_entries_2}}
```

### Prompt B: Turkish layer
```
SYSTEM
You are a bilingual English-Turkish lexicographer and a teacher of English to Turkish speakers. You follow TDK spelling (including circumflex: dâhil, hâlâ, hikâye). You receive ONE finished English entry as JSON and return the Turkish layer "l1.tr" ONLY, as JSON.

RULES
1 gloss (<=28 chars): the most common natural Turkish equivalent for THIS sense, in dictionary form (verbs -mek/-mak, nouns nominative). Choose what Turkish speakers actually say, not purist TDK coinages (kronik, not süreğen; put the TDK form in alt/note). Up to 3 alt glosses (<=24 chars), most common first. If no single equivalent exists, give a short paraphrase and set equivalence "partial" or "none".
2 equivalence: full | partial | cognate | false_friend | none.
3 false_friend: ONLY if a Turkish word looks or sounds like the English word but means something different (e.g. aktüel vs actual). Give tr_word, tr_means, en_for_that. If unsure -> null. Check against FALSE_FRIEND_SEED. Never invent one.
4 Translate each English example into natural, idiomatic Turkish, not word for word. Keep register (formal = siz, informal = sen). Pro-drop; natural SOV order; use -miş only for discovery/surprise as in the English; no added or dropped information; names unchanged. <=100 chars (first) / <=130.
5 note (<=220 chars, Turkish): one useful nuance for Turkish learners (register, split/merge of senses, TDK alternative). No filler.
6 mistakes (0-2): ONLY genuine Turkish-L1 interference (articles, preposition vs case suffix, plural after numeral, uncountables, borrow/lend-type pairs, false friends, stress/pronunciation). wrong/right <=80 chars (English), why <=200 chars (Turkish). If none, return [].
7 mnemonic (<=160, Turkish) or null: sound-alike, shared root with a Turkish word (petrol/petra), or cultural bridge. Must be harmless: no profanity, no mocking, no religion/politics. If no honest hook exists -> null.
8 Self-check (stripped before publishing): backtranslation[] (literal English back-translation of each Turkish example) and uncertain_fields[].
Return JSON only.

INPUT
ENTRY: {{english_entry_json}}
FALSE_FRIEND_SEED: {{ff_list}}
```

### Prompt C: QA critic
```
SYSTEM
You are a strict QA editor for a bilingual EN->TR vocabulary app. Be skeptical: LLM entries often contain (a) invented or folk etymologies, (b) examples that define the word, (c) a gloss for the wrong sense, (d) over-literal Turkish, (e) CEFR levels too low for rare words, (f) wrong IPA stress, (g) invented false friends, (h) quiz blanks that more than one option could fill.
Score each RUBRIC criterion 0/1/2 with a one-line reason, then give a verdict: PASS (total >= 20/24, no critical 0), FIX (list exact field edits) or REJECT. A quiz problem alone is FIX, never REJECT.
Explicitly verify: lemma not in definitions; every example contains its "focus"; Turkish examples faithful to the backtranslation; etymology not in MYTHS and plausible; lengths within limits; false_friend claim is real; example 1 is lock-screen safe; IPA stress matches IPA_REF if given; exactly one quiz option fits the blank.
Return JSON: {"scores":{...},"total":n,"verdict":"PASS|FIX|REJECT","issues":[{"field","severity","problem","suggested_fix"}]}

INPUT
ENTRY: {{entry_json}}   BACKTRANSLATION: {{backtranslation}} (from Prompt B; not stored on the card)   RUBRIC: {{rubric}}   IPA_REF: {{ipa_ref}}   MYTHS: {{etym_myth_list}}
```

### Validation checklist
**Deterministic (every card, blocking):** schema + enums; limits in grapheme clusters; `focus` found in the English example (lemmatizer, e.g. spaCy); headword/stem absent from `micro`/`short`; at least 95% of definition words are at or below level-1 (word list); duplicate/near-duplicate definitions and examples across the catalog (exact + embedding); sensitivity wordlist plus moderation classifier; IPA charset, stress mark present, and diff against the CMUdict-derived US IPA; Turkish: NFC normalization, contains Turkish letters, no leftover English outside quotes, Zemberek/Hunspell spelling, verb gloss ends -mek/-mak, `gloss` differs from lemma unless a true loan, sentence ends with punctuation, consistent siz/sen; exam tags only from curated lists; cloze contains exactly one blank and answer is not in distractors.
**LLM (Prompt C):** rubric scoring and myth check.
**Human:** see below.

### Human review workflow
- Roles: content lead (English editor), Turkish linguist (bilingual), second spot-checker.
- Batches of about 250 cards in a review UI (Airtable/Retool/simple Streamlit) showing the entry, critic notes and a reason-code dropdown (DEF_CIRCULAR, DEF_TOO_HARD, EX_UNNATURAL, TR_WRONG_SENSE, TR_UNNATURAL, IPA_WRONG, ETYM_UNVERIFIED, LEVEL_MISMATCH, BIAS, SENSITIVE, LENGTH, DUP).
- **Tiers:** Tier A (top 1,200 cards: A1 to B2 core + hero collections) gets a full double-read (EN+TR). Tier B (the rest) gets Turkish-focused skim plus deep-fix on critic-flagged cards, about 10 to 20% English sample.
- **Stop-the-line:** if a batch's human edit rate exceeds 25% or any critical error type exceeds 5%, review the whole batch and fix the prompt. Keep a 100-card "gold set"; re-run it whenever a prompt changes and compare critic scores before rollout.
- Mnemonics, false-friend claims, `confidence != high` etymologies and every `coined` word are always human-approved.
- Track edit distance, reason codes and in-app "report issue" rate; target under 0.2% of card views.

### Volume and cost (rough, assumption-based; verify current pricing)
Per entry: Prompt A about 2.3K tokens in (cacheable) + about 0.75K out; Prompt B about 1.0K in + about 0.5K out; Prompt C about 1.9K in + about 0.3K out. At an assumed $3 / $15 per million in/out tokens: about $0.04 per entry unoptimized, about $0.017 with prompt caching plus batch (50%), about $0.02 to 0.05 including about 30% regeneration.

| Scope | Entries | LLM cost | Human review (hours / cost at $10 to 25 per hour) |
|---|---|---|---|
| Launch | 4,000 | about $90 to 200 | about 120 to 150 h, about $1.4 to 3.8K |
| M+6 | 11,500 | about $250 to 575 | about 300 to 380 h |
| Full | 20,000 | about $440 to 1,000 | about 520 to 650 h |

Human time assumptions: Tier A 2.5 min per card, Tier B 45 sec skim plus 25% of cards × 3 min fixes. Plan the editor budget first; model spend is noise.

---

## 7. Sample dataset (25 entries, schema v1.0)

Distribution: A1 1, A2 2, B1 2, B2 5, C1 7, C2 4, S 4. Types: 23 words, 1 phrasal verb, 1 idiom. Includes 3 false-friend cards (*actually, sympathetic, enervate*), 1 cognate (*chronic*), 1 coined word (*sonder*), 1 disputed-etymology card (*deadline*).
All 25 entries passed my validator (limits, `focus` found in the English example, topic IDs exist in the taxonomy, no circular definitions). Frequencies are wordfreq-en list ranks (inflected forms counted separately, so lemma-level rank is not exact; e.g. *procrastinate* ranks 41K). IPA was cross-checked against Wiktionary. Turkish terms were checked against the TDK dictionary API where possible.

```json
{
"schema_version": "1.0",
"l1_langs": ["tr"],
"defaults": {"type": "word", "sense_no": 1, "level_source": "editorial_estimate", "example.register": "neutral", "tags.register": "neutral", "tags.sensitivity": 0, "meta.status": "sample"},
"entries": [
{
  "id": "en.breakfast.n.1",
  "lemma": "breakfast",
  "pos": "n",
  "level": "A1",
  "freq": {"rank":2426,"zipf":4.61},
  "ipa": {"us":"/ˈbrɛkfəst/","uk":"/ˈbrɛkfəst/"},
  "def": {
    "micro": "first meal of the day",
    "short": "the first meal of the day, eaten in the morning",
    "long": "The first meal of the day, usually eaten in the morning before work or school. It can be light (tea and toast) or large (eggs, cheese, olives, and more)."
  },
  "examples": [
    {"en":"I usually have breakfast at seven.","tr":"Genellikle yedide kahvaltı yaparım.","focus":"breakfast"},
    {"en":"Ayşe made breakfast for the whole family.","tr":"Ayşe bütün aile için kahvaltı hazırladı.","focus":"breakfast"},
    {"en":"Breakfast is included in the hotel price.","tr":"Kahvaltı otel fiyatına dâhildir.","focus":"Breakfast"}
  ],
  "synonyms": ["morning meal"],
  "collocations": ["have breakfast","skip breakfast","make breakfast","breakfast in bed","a light breakfast"],
  "etymology": {"text":"From 'break' + 'fast': the meal that breaks the long overnight fast since dinner.","origin":"English","confidence":"high"},
  "l1": {"tr": {
      "gloss": "kahvaltı",
      "equivalence": "full",
      "note": "Türkçedeki 'kahvaltı' da bir birleşik sözcüktür (kahve altı). İngilizcede öğün adlarından önce genellikle 'the' kullanılmaz.",
      "mistakes": [
        {"wrong":"I did breakfast at eight.","right":"I had breakfast at eight.","why":"'Kahvaltı yapmak' kalıbını 'do' ile kurmayın; İngilizcede 'have breakfast' denir ('make breakfast' = hazırlamak)."},
        {"wrong":"I eat the breakfast at 8.","right":"I eat breakfast at 8.","why":"Öğün adlarının önüne genellikle 'the' gelmez."}
      ],
      "mnemonic": "Break + fast = orucu bozmak. İftar gibi, ama her sabah: gece boyu süren açlığı bozan öğün."
  }},
  "tags": {"primary_topic":"food_drink","topics":["food_drink","time_routines"]},
  "quiz": {"cloze":"We usually eat ______ at 7 a.m., before school.","answer":"breakfast","distractors":["dinner","supper","lunch"]}
},
{
  "id": "en.borrow.v.1",
  "lemma": "borrow",
  "pos": "v",
  "level": "A2",
  "freq": {"rank":7101,"zipf":4},
  "ipa": {"us":"/ˈbɑːroʊ/","uk":"/ˈbɒrəʊ/"},
  "def": {
    "micro": "take and give back later",
    "short": "take something from someone and give it back later",
    "long": "To take something that belongs to someone else, with their permission, and return it after a time. You borrow FROM someone; the other person lends it TO you."
  },
  "grammar": {"pattern":"borrow + sth + from + sb"},
  "examples": [
    {"en":"Can I borrow your pen for a minute?","tr":"Kalemini bir dakikalığına ödünç alabilir miyim?","focus":"borrow"},
    {"en":"She borrowed some money from her brother.","tr":"Kardeşinden biraz para ödünç aldı.","focus":"borrowed"},
    {"en":"You can borrow up to five books from the library.","tr":"Kütüphaneden en fazla beş kitap ödünç alabilirsiniz.","register":"formal","focus":"borrow"}
  ],
  "synonyms": ["take on loan"],
  "antonyms": ["lend"],
  "collocations": ["borrow money","borrow a book","borrow from a friend","living on borrowed time","borrow an idea"],
  "word_family": [{"lemma":"borrower","pos":"n"},{"lemma":"loan","pos":"n"}],
  "etymology": {"text":"From Old English 'borgian' (to borrow, lend, give a pledge), from 'borg', a pledge: borrowing once meant leaving something as a guarantee.","origin":"Old English","confidence":"high"},
  "l1": {"tr": {
      "gloss": "ödünç almak",
      "alt": ["borç almak"],
      "equivalence": "partial",
      "note": "Türkçede 'ödünç' hem alma hem verme için kullanılır (ödünç almak / ödünç vermek). İngilizcede iki ayrı fiil var: borrow = alan, lend = veren.",
      "mistakes": [
        {"wrong":"Can you borrow me your pen?","right":"Can you lend me your pen? / Can I borrow your pen?","why":"'Borrow' yalnızca alan kişi için; veren kişi 'lend' kullanır."},
        {"wrong":"I borrowed him my book.","right":"I lent him my book.","why":"Kitabı veren kişi olarak 'lend' (lent) kullanılır."}
      ],
      "mnemonic": "Borrow ≈ BORÇ alırım. Borç alan 'borrow' der, borç veren 'lend'."
  }},
  "tags": {"primary_topic":"confusing_words","topics":["confusing_words","shopping_money","school_learning"],"flags":["confusable:lend"]},
  "quiz": {"cloze":"Could I ______ your charger? Mine is dead.","answer":"borrow","distractors":["lend","give","owe"]},
  "meta": {"qa_flags":["ipa_us_regional_variant"]}
},
{
  "id": "en.luggage.n.1",
  "lemma": "luggage",
  "pos": "n",
  "level": "A2",
  "freq": {"rank":9624,"zipf":3.8},
  "ipa": {"us":"/ˈlʌɡɪdʒ/","uk":"/ˈlʌɡɪdʒ/"},
  "def": {
    "micro": "bags and cases for a trip",
    "short": "the bags and suitcases you take with you when you travel",
    "long": "All the bags, suitcases, and boxes a traveler takes on a journey. 'Baggage' means almost the same and is common in airline English. It is uncountable: never 'luggages'."
  },
  "examples": [
    {"en":"Please keep your luggage with you at all times.","tr":"Lütfen bagajınızı her zaman yanınızda tutun.","register":"formal","focus":"luggage"},
    {"en":"The airline lost our luggage on the way to Izmir.","tr":"Havayolu şirketi, İzmir'e giderken bagajımızı kaybetti.","focus":"luggage"},
    {"en":"Do you have any luggage to check in?","tr":"Teslim edeceğiniz bagajınız var mı?","register":"formal","focus":"luggage"}
  ],
  "synonyms": ["baggage"],
  "collocations": ["hand luggage","carry-on luggage","check in luggage","lost luggage","luggage allowance"],
  "etymology": {"text":"From 'lug' (to drag or carry with effort) + '-age': literally, the things you have to lug around.","origin":"English","confidence":"high"},
  "l1": {"tr": {
      "gloss": "bagaj",
      "alt": ["seyahat eşyası"],
      "equivalence": "partial",
      "note": "Türkçedeki 'bagaj' arabanın bagajı anlamına da gelir; İngilizcede araba bagajı 'trunk' (ABD) veya 'boot' (İngiltere)'dir, 'luggage' değildir.",
      "mistakes": [
        {"wrong":"I have two luggages.","right":"I have two bags. / two pieces of luggage","why":"'Luggage' sayılamayan isimdir, çoğul eki almaz; sayı için 'bag' veya 'piece of luggage' kullanın."},
        {"wrong":"My luggage are heavy.","right":"My luggage is heavy.","why":"Sayılamayan isimler tekil fiil alır."}
      ],
      "mnemonic": "'Lug' = sürükleyerek taşımak. Luggage = sürükleyip taşıdığın şeyler."
  }},
  "tags": {"primary_topic":"travel_tourism","topics":["travel_tourism","cities_transport"],"flags":["uncountable"]},
  "quiz": {"cloze":"The airline lost my ______, so I had no clothes for the trip.","answer":"luggage","distractors":["ticket","passport","flight"]}
},
{
  "id": "en.actually.adv.1",
  "lemma": "actually",
  "pos": "adv",
  "sense_note": "in fact",
  "level": "B1",
  "freq": {"rank":302,"zipf":5.49},
  "ipa": {"us":"/ˈæktʃuəli/","uk":"/ˈæktʃuəli/"},
  "def": {
    "micro": "in fact; in reality",
    "short": "used to say what is really true, often when it is not what people expect",
    "long": "Used to show what is really true or what really happened, especially when it is surprising or different from what was expected. It does NOT mean 'at the moment' ('currently' or 'now' mean that)."
  },
  "examples": [
    {"en":"I thought the test would be hard, but it was actually quite easy.","tr":"Sınavın zor olacağını sanıyordum ama aslında oldukça kolaymış.","focus":"actually"},
    {"en":"Actually, I'd prefer tea, if that's okay.","tr":"Aslında çay tercih ederim, sakıncası yoksa.","focus":"Actually"},
    {"en":"He looks shy, but he actually loves meeting new people.","tr":"Çekingen görünüyor ama aslında yeni insanlarla tanışmaya bayılıyor.","focus":"actually"}
  ],
  "synonyms": ["in fact","in reality","really","in truth"],
  "collocations": ["actually quite","what actually happened","did you actually","but actually","actually, no"],
  "word_family": [{"lemma":"actual","pos":"adj"}],
  "etymology": {"text":"From 'actual', from Latin 'actus' (a doing, a deed): 'actually' = in deed, in real fact, not just in theory.","origin":"Latin","confidence":"high"},
  "l1": {"tr": {
      "gloss": "aslında, gerçekte",
      "alt": ["doğrusu","esasında"],
      "equivalence": "false_friend",
      "false_friend": {"tr_word":"aktüel","tr_means":"güncel, şu anki","en_for_that":"current / currently"},
      "note": "Türkçedeki 'aktüel' = 'güncel'. İngilizce 'actual/actually' ise 'gerçek/aslında' demektir. 'Şu anda' için 'currently' veya 'at the moment' kullanılır.",
      "mistakes": [
        {"wrong":"The actual price of petrol is very high.","right":"The current price of petrol is very high.","why":"'Güncel' = 'current'; 'actual' = gerçek/asıl."},
        {"wrong":"Actually I'm studying English. (= şu anda)","right":"I'm currently studying English.","why":"'Actually' zaman bildirmez; 'şu anda' için 'currently / at the moment'."}
      ],
      "mnemonic": "ACT = eylem: 'actually' = fiilen, gerçekte. 'Aktüel' (güncel) tuzağına düşme."
  }},
  "tags": {"primary_topic":"confusing_words","topics":["confusing_words","social_skills"],"flags":["false_friend_tr"]},
  "quiz": {"cloze":"He looks young, but he is ______ forty.","answer":"actually","distractors":["rarely","recently","fortunately"]}
},
{
  "id": "en.deadline.n.1",
  "lemma": "deadline",
  "pos": "n",
  "level": "B1",
  "freq": {"rank":5871,"zipf":4.12},
  "ipa": {"us":"/ˈdɛdlaɪn/","uk":"/ˈdɛdlaɪn/"},
  "def": {
    "micro": "last time to finish a task",
    "short": "the latest date or time by which something must be finished",
    "long": "A fixed date or time by which a task must be completed or handed in. Missing a deadline can have consequences, such as a penalty or a lost opportunity."
  },
  "examples": [
    {"en":"The deadline for the report is Friday at noon.","tr":"Raporun son teslim tarihi cuma günü öğlen.","focus":"deadline"},
    {"en":"We worked all night to meet the deadline.","tr":"Son teslim tarihine yetişmek için bütün gece çalıştık.","focus":"deadline"},
    {"en":"She asked for a deadline extension.","tr":"Son teslim tarihinin uzatılmasını istedi.","focus":"deadline"}
  ],
  "synonyms": ["due date","cutoff","time limit"],
  "collocations": ["meet a deadline","miss a deadline","tight deadline","set a deadline","extend the deadline"],
  "etymology": {"text":"First a line around a US Civil War prison camp that prisoners could not cross. The 'time limit' sense came later (printing); the link between the two is only indirectly documented.","origin":"American English","confidence":"medium"},
  "l1": {"tr": {
      "gloss": "son teslim tarihi",
      "alt": ["son tarih","teslim süresi"],
      "equivalence": "full",
      "note": "Gündelik iş dilinde Türkçede de 'deadline' aynen kullanılır; resmî yazıda 'son teslim tarihi' tercih edin.",
      "mistakes": [
        {"wrong":"The deadline is until Friday.","right":"The deadline is Friday. / We must finish by Friday.","why":"Türkçedeki 'cumaya kadar' kalıbı 'until' ile çevrilir; ama bitiş anı için 'by' kullanılır."}
      ],
      "mnemonic": "'Dead' (ölü) + 'line' (çizgi): bu çizgiyi geçersen iş 'ölür'."
  }},
  "tags": {"primary_topic":"workplace_office","topics":["workplace_office","business_management","school_learning"]},
  "quiz": {"cloze":"The project is late, so we asked for a new ______.","answer":"deadline","distractors":["salary","holiday","uniform"]},
  "meta": {"qa_flags":["etymology_link_debated"]}
},
{
  "id": "en.look_up_to.phv.1",
  "lemma": "look up to",
  "type": "phrasal_verb",
  "pos": "phv",
  "sense_note": "admire",
  "level": "B2",
  "ipa": {"us":"/lʊk ˈʌp tu/","uk":"/lʊk ˈʌp tuː/"},
  "def": {
    "micro": "admire and respect",
    "short": "admire and respect someone, often an older or more experienced person",
    "long": "To feel great respect and admiration for someone and see them as a role model. The opposite is 'look down on'. Careful: 'look up' without 'to' means something different (search for information)."
  },
  "grammar": {"pattern":"look up to + sb (inseparable)"},
  "examples": [
    {"en":"I've always looked up to my older sister.","tr":"Ablamı hep örnek aldım.","focus":"looked up to"},
    {"en":"Many young players look up to him.","tr":"Birçok genç oyuncu onu kendine örnek alıyor.","focus":"look up to"},
    {"en":"Children look up to teachers who treat them fairly.","tr":"Çocuklar, kendilerine adil davranan öğretmenlere büyük saygı duyar.","focus":"look up to"}
  ],
  "synonyms": ["admire","respect","idolize"],
  "antonyms": ["look down on"],
  "collocations": ["look up to a role model","always looked up to","someone to look up to","look up to your parents"],
  "etymology": {"text":"Picture a child literally looking up at a taller person: 'up' = higher status. The opposite 'look down on' uses the same picture.","origin":"English","confidence":"high"},
  "l1": {"tr": {
      "gloss": "hayran olmak, örnek almak",
      "alt": ["saygı duymak"],
      "equivalence": "partial",
      "note": "Tek sözcüklük bir karşılığı yok; bağlama göre 'hayran olmak', 'saygı duymak' veya 'örnek almak'. Zıttı 'look down on' = 'tepeden bakmak'.",
      "mistakes": [
        {"wrong":"I looked up to the word in the dictionary.","right":"I looked up the word in the dictionary.","why":"'Look up' = bakıp bulmak; 'to' eklenince anlam tamamen değişir."},
        {"wrong":"I look up my father.","right":"I look up to my father.","why":"Saygı duymak için 'to' şarttır."}
      ],
      "mnemonic": "Yukarı (up) bakıyorsun çünkü karşındaki senden 'yüce': yukarı bakmak = hayran olmak."
  }},
  "tags": {"primary_topic":"phrasal_verbs","topics":["phrasal_verbs","social_skills","family_relationships"],"flags":["inseparable"]},
  "quiz": {"cloze":"I really ______ my grandfather. He taught me to work hard and be kind.","answer":"look up to","distractors":["look down on","look after","look into"]},
  "meta": {"qa_flags":["cefr_estimate_check"]}
},
{
  "id": "en.break_the_ice.idm.1",
  "lemma": "break the ice",
  "type": "idiom",
  "pos": "idm",
  "level": "B2",
  "ipa": {"us":"/breɪk ðə ˈaɪs/","uk":"/breɪk ðə ˈaɪs/"},
  "def": {
    "micro": "ease an awkward start",
    "short": "do or say something to make people feel relaxed when they first meet",
    "long": "To start a conversation or activity in a way that makes people who do not know each other feel more comfortable. It is often done with a joke, a question, or a small game."
  },
  "grammar": {"pattern":"break the ice (with sb)"},
  "examples": [
    {"en":"He told a funny story to break the ice at the meeting.","tr":"Toplantıda buzları eritmek için komik bir hikâye anlattı.","focus":"break the ice"},
    {"en":"A quick game helped break the ice on the first day of the course.","tr":"Kısa bir oyun, kursun ilk gününde buzları eritmeye yardımcı oldu.","focus":"break the ice"},
    {"en":"Offering her a coffee was a good way to break the ice.","tr":"Ona kahve ikram etmek, ortamı yumuşatmanın iyi bir yoluydu.","focus":"break the ice"}
  ],
  "synonyms": ["ease the tension","get talking"],
  "collocations": ["an icebreaker","break the ice with sb","help break the ice","icebreaker question","a good way to break the ice"],
  "word_family": [{"lemma":"icebreaker","pos":"n"}],
  "etymology": {"text":"Probably from the literal image of breaking ice to open a path. The figurative sense ('make a first step') is recorded in the late 1500s; Shakespeare uses it in The Taming of the Shrew.","origin":"English","confidence":"medium"},
  "l1": {"tr": {
      "gloss": "buzları eritmek",
      "alt": ["ortamı yumuşatmak","ilk adımı atmak"],
      "equivalence": "full",
      "note": "Türkçede de aynı imge var: 'buzları eritmek'. İngilizcede özellikle ilk tanışma anındaki gerginliği kırmak için kullanılır.",
      "mistakes": [
        {"wrong":"He broke ice at the party.","right":"He broke the ice at the party.","why":"Deyim kalıptır; 'the' eksik bırakılmaz."}
      ],
      "mnemonic": "Buz gibi soğuk ortam: 'buzu kır' = break the ice. Türkçedeki 'buzları eritmek' ile aynı görüntü."
  }},
  "tags": {"primary_topic":"idioms_expressions","topics":["idioms_expressions","social_skills"]},
  "quiz": {"cloze":"A short game is a great way to ______ at a new team's first meeting.","answer":"break the ice","distractors":["break the rules","break a leg","break down"]},
  "meta": {"qa_flags":["etymology_medium_verify"]}
},
{
  "id": "en.sympathetic.adj.1",
  "lemma": "sympathetic",
  "pos": "adj",
  "sense_note": "understanding",
  "level": "B2",
  "freq": {"rank":9549,"zipf":3.81},
  "ipa": {"us":"/ˌsɪmpəˈθɛtɪk/","uk":"/ˌsɪmpəˈθɛtɪk/"},
  "def": {
    "micro": "understanding others' pain",
    "short": "showing that you understand and care about someone's problems",
    "long": "Showing that you understand and care about someone's problems or feelings. It does not mean 'nice' or 'likable': for that, use 'likeable', 'friendly', or 'charming'."
  },
  "examples": [
    {"en":"The nurse was very sympathetic when I told her about my fears.","tr":"Hemşireye korkularımı anlattığımda çok anlayışlı davrandı.","focus":"sympathetic"},
    {"en":"Her boss was sympathetic and let her leave early.","tr":"Müdürü anlayış gösterip erken çıkmasına izin verdi.","focus":"sympathetic"},
    {"en":"I'm sympathetic to your situation, but the rules are the rules.","tr":"Durumuna anlayış gösteriyorum ama kurallar kurallardır.","focus":"sympathetic"}
  ],
  "synonyms": ["understanding","compassionate","caring","kind"],
  "antonyms": ["unsympathetic","heartless","indifferent"],
  "collocations": ["a sympathetic ear","sympathetic to/towards","a sympathetic response","sympathetic nervous system"],
  "word_family": [{"lemma":"sympathy","pos":"n"},{"lemma":"sympathize","pos":"v"}],
  "etymology": {"text":"From Greek 'sympatheia', 'fellow feeling': syn 'together' + pathos 'feeling, suffering'.","origin":"Greek","confidence":"high"},
  "l1": {"tr": {
      "gloss": "anlayışlı, şefkatli",
      "alt": ["merhametli","destekleyici"],
      "equivalence": "false_friend",
      "false_friend": {"tr_word":"sempatik","tr_means":"sevimli, cana yakın, hoş","en_for_that":"likeable / charming"},
      "note": "'Sempatik' = sevimli, hoşa giden. İngilizce 'sympathetic' = acıyı/derdi anlayan. Tıpta 'sempatik sinir sistemi' = 'sympathetic nervous system' (orada eşleşir).",
      "mistakes": [
        {"wrong":"Your brother is a very sympathetic person. (= sevimli)","right":"Your brother is a very likeable person.","why":"'Sevimli' için 'likeable/charming'; 'sympathetic' = anlayışlı, derdini anlayan."}
      ],
      "mnemonic": "'Sempatik' diye okuma: sym-pa-THET-ik. Sym = birlikte + pathos = acı: derdini paylaşan."
  }},
  "tags": {"primary_topic":"emotions_feelings","topics":["emotions_feelings","personality","confusing_words"],"flags":["false_friend_tr"]},
  "quiz": {"cloze":"When I lost my job, my manager was very ______ and offered to help.","answer":"sympathetic","distractors":["jealous","careless","strict"]}
},
{
  "id": "en.phishing.n.1",
  "lemma": "phishing",
  "pos": "n",
  "level": "B2",
  "freq": {"rank":30917,"zipf":2.95},
  "ipa": {"us":"/ˈfɪʃɪŋ/","uk":"/ˈfɪʃɪŋ/"},
  "def": {
    "micro": "scam emails that steal data",
    "short": "tricking people into giving passwords or money, usually with fake emails",
    "long": "A type of online fraud in which criminals send fake emails, texts, or websites that look real, to trick you into revealing passwords, card numbers, or other private information."
  },
  "examples": [
    {"en":"Never click a link in an email you weren't expecting; it could be phishing.","tr":"Beklemediğin bir e-postadaki bağlantıya asla tıklama; kimlik avı olabilir.","focus":"phishing"},
    {"en":"The bank warned customers about a new phishing scam.","tr":"Banka, müşterileri yeni bir kimlik avı dolandırıcılığına karşı uyardı.","focus":"phishing"},
    {"en":"Our company runs phishing tests to train employees.","tr":"Şirketimiz, çalışanları eğitmek için oltalama testleri yapıyor.","focus":"phishing"}
  ],
  "synonyms": ["email scam"],
  "collocations": ["phishing email","phishing attack","phishing scam","phishing link","fall for phishing"],
  "word_family": [{"lemma":"phish","pos":"v"},{"lemma":"phisher","pos":"n"}],
  "etymology": {"text":"A respelling of 'fishing': criminals 'fish' for passwords with bait. The 'ph' echoes older hacker slang 'phreaking'. In use since the mid-1990s.","origin":"English (hacker slang)","confidence":"high"},
  "l1": {"tr": {
      "gloss": "kimlik avı, oltalama",
      "alt": ["dolandırıcılık e-postası"],
      "equivalence": "full",
      "note": "Bankacılık ve resmî dilde 'oltalama', haberlerde 'kimlik avı' daha yaygın; ikisi de doğru. Fiil: 'phish' (oltalama yapmak).",
      "mistakes": [
        {"wrong":"I got a fishing email.","right":"I got a phishing email.","why":"'Fishing' (balık avı) ile aynı okunur; bilgisayar dolandırıcılığı 'ph' ile yazılır."}
      ],
      "mnemonic": "Ph-ishing = fishing: şifreni yakalamak için 'olta' atarlar. Türkçesi de zaten 'oltalama'."
  }},
  "tags": {"primary_topic":"technology_internet","topics":["technology_internet","society_media","finance_economics"],"flags":["homophone:fishing"]},
  "quiz": {"cloze":"Never enter your password on a page you reached from a ______ email.","answer":"phishing","distractors":["fishing","phasing","filming"]},
  "meta": {"qa_flags":["tr_term_not_in_tdk_both_used"]}
},
{
  "id": "en.chronic.adj.1",
  "lemma": "chronic",
  "pos": "adj",
  "sense_note": "long-lasting (illness, problem)",
  "level": "B2",
  "freq": {"rank":5110,"zipf":4.2},
  "ipa": {"us":"/ˈkrɑːnɪk/","uk":"/ˈkrɒnɪk/"},
  "def": {
    "micro": "lasting a long time",
    "short": "lasting a long time or constantly returning, especially an illness",
    "long": "Describes a disease or problem that lasts a long time or keeps coming back. The opposite is 'acute' (sudden and short). It can also describe bad habits or problems: chronic lateness."
  },
  "examples": [
    {"en":"She has suffered from chronic back pain for years.","tr":"Yıllardır kronik sırt ağrısı çekiyor.","focus":"chronic"},
    {"en":"Chronic stress can damage your health.","tr":"Kronik stres sağlığınıza zarar verebilir.","focus":"Chronic"},
    {"en":"The city has a chronic shortage of affordable housing.","tr":"Şehirde uygun fiyatlı konut sıkıntısı kronikleşmiş durumda.","focus":"chronic"}
  ],
  "synonyms": ["long-term","persistent","ongoing","long-lasting"],
  "antonyms": ["acute","short-term"],
  "collocations": ["chronic pain","chronic illness","chronic disease","chronic fatigue","chronic shortage"],
  "word_family": [{"lemma":"chronically","pos":"adv"},{"lemma":"chronicle","pos":"n"}],
  "etymology": {"text":"From Greek 'khronos' (time): a chronic illness lasts through time. Same root as chronology and synchronize.","origin":"Greek","confidence":"high"},
  "l1": {"tr": {
      "gloss": "kronik",
      "alt": ["müzmin","süreğen (TDK)"],
      "equivalence": "cognate",
      "note": "Türkçedeki 'kronik' ile aynı anlam, kolay kelime. Dikkat: vurgu İngilizcede ilk hecede (KRON-ik), Türkçede son hecede (kro-NİK).",
      "mistakes": [
        {"wrong":"I had chronic pain yesterday.","right":"I had severe pain yesterday.","why":"'Chronic' şiddeti değil süreyi anlatır; 'dün' gibi kısa süre için 'severe' veya 'acute' kullanın."}
      ],
      "mnemonic": "Kronik = kronometre, kronoloji ile aynı kök (khronos = zaman): zamana yayılan hastalık."
  }},
  "tags": {"primary_topic":"medicine_healthcare","topics":["medicine_healthcare","health_body"],"flags":["cognate_tr"]},
  "quiz": {"cloze":"He has ______ asthma, so he always carries an inhaler.","answer":"chronic","distractors":["acute","sudden","brief"]}
},
{
  "id": "en.procrastinate.v.1",
  "lemma": "procrastinate",
  "pos": "v",
  "level": "C1",
  "freq": {"rank":41321,"zipf":2.71},
  "ipa": {"us":"/proʊˈkræstəneɪt/","uk":"/prəʊˈkræstɪneɪt/"},
  "def": {
    "micro": "delay things you should do",
    "short": "delay doing something you should do, usually because you don't feel like it",
    "long": "To keep putting off a task that needs to be done, often by doing something easier or more fun instead. It suggests an unhelpful habit, not a planned delay (for that, use 'postpone')."
  },
  "grammar": {"pattern":"procrastinate (about/over sth); person as subject"},
  "examples": [
    {"en":"I always procrastinate when I have to write an essay.","tr":"Kompozisyon yazmam gerektiğinde hep oyalanıp işi sonraya bırakıyorum.","focus":"procrastinate"},
    {"en":"Stop procrastinating and start your homework!","tr":"Oyalanmayı bırak da ödevine başla!","register":"informal","focus":"procrastinating"},
    {"en":"He procrastinated for weeks before calling the dentist.","tr":"Diş hekimini aramayı haftalarca erteleyip durdu.","focus":"procrastinated"}
  ],
  "synonyms": ["put off","delay","stall"],
  "antonyms": ["act promptly"],
  "collocations": ["tend to procrastinate","stop procrastinating","a chronic procrastinator","procrastinate about work","procrastinate for days"],
  "word_family": [{"lemma":"procrastination","pos":"n"},{"lemma":"procrastinator","pos":"n"}],
  "etymology": {"text":"From Latin 'pro' (forward) + 'crastinus' (of tomorrow, from 'cras' = tomorrow): literally, 'to push forward to tomorrow'.","origin":"Latin","confidence":"high"},
  "l1": {"tr": {
      "gloss": "işi sürekli ertelemek",
      "alt": ["oyalanmak","savsaklamak"],
      "equivalence": "partial",
      "note": "'Ertelemek' (postpone) planlı olabilir; 'procrastinate' ise alışkanlık hâline gelmiş, zararlı erteleme/oyalanmadır ('sonra yaparım' tavrı).",
      "mistakes": [
        {"wrong":"The meeting was procrastinated until Monday.","right":"The meeting was postponed until Monday.","why":"Toplantı gibi planlı ertelemeler için 'postpone'; 'procrastinate' kişinin kendi alışkanlığıdır, nesne almaz."}
      ],
      "mnemonic": "Latince 'cras' = yarın: pro-CRAS-tinate = işi yarına doğru itmek."
  }},
  "tags": {"primary_topic":"success_productivity","topics":["success_productivity","mind_psychology","school_learning"],"vibes":["relatable"]},
  "quiz": {"cloze":"I know I should study, but I keep ______ and scrolling on my phone.","answer":"procrastinating","distractors":["rushing","succeeding","cooperating"]},
  "meta": {"qa_flags":["ipa_us_variant_prə"]}
},
{
  "id": "en.resilient.adj.1",
  "lemma": "resilient",
  "pos": "adj",
  "level": "C1",
  "freq": {"rank":15044,"zipf":3.5},
  "ipa": {"us":"/rɪˈzɪliənt/","uk":"/rɪˈzɪliənt/"},
  "def": {
    "micro": "quick to recover",
    "short": "able to recover quickly after problems, shocks, or illness",
    "long": "Able to bounce back quickly after difficulties, or (of a material) able to return to its shape after being bent or stretched. Used for people, communities, economies, and materials."
  },
  "examples": [
    {"en":"Children are often more resilient than adults expect.","tr":"Çocuklar çoğu zaman yetişkinlerin düşündüğünden daha dirençlidir.","focus":"resilient"},
    {"en":"The economy proved resilient despite the crisis.","tr":"Ekonomi, krize rağmen dirençli olduğunu kanıtladı.","focus":"resilient"},
    {"en":"Resilient teams learn from failure instead of blaming each other.","tr":"Dirençli ekipler birbirini suçlamak yerine başarısızlıktan ders çıkarır.","focus":"Resilient"}
  ],
  "synonyms": ["tough","hardy","adaptable","strong"],
  "antonyms": ["fragile","vulnerable"],
  "collocations": ["highly resilient","remarkably resilient","resilient economy","resilient to stress","stay resilient"],
  "word_family": [{"lemma":"resilience","pos":"n"}],
  "etymology": {"text":"From Latin 'resilire', 'to jump back' (re- 'back' + salire 'to jump'): a resilient person 'springs back'.","origin":"Latin","confidence":"high"},
  "l1": {"tr": {
      "gloss": "dirençli, çabuk toparlanan",
      "alt": ["esnek","psikolojik olarak sağlam"],
      "equivalence": "partial",
      "note": "Psikolojide isim hâli 'resilience' için 'psikolojik dayanıklılık' (bazen 'psikolojik sağlamlık') denir. Vurgu 'toparlanma'dır, sadece katlanmak değil.",
      "mistakes": [
        {"wrong":"This phone is very resilient to water.","right":"This phone is very resistant to water.","why":"'Resilient' toparlanmayı anlatır; suya/darbeye karşı dayanıklılık için 'resistant' (water-resistant)."}
      ],
      "mnemonic": "Latince 'salire' = zıplamak: düşünce topun geri zıplaması gibi toparlanan."
  }},
  "tags": {"primary_topic":"mind_psychology","topics":["mind_psychology","personality","success_productivity"],"vibes":["inspiring"],"flags":["confusable:resistant"]},
  "quiz": {"cloze":"After losing her job, she proved ______ and found a better one within months.","answer":"resilient","distractors":["fragile","reluctant","generous"]}
},
{
  "id": "en.mitigate.v.1",
  "lemma": "mitigate",
  "pos": "v",
  "level": "C1",
  "freq": {"rank":14170,"zipf":3.54},
  "ipa": {"us":"/ˈmɪtɪɡeɪt/","uk":"/ˈmɪtɪɡeɪt/"},
  "def": {
    "micro": "make less harmful",
    "short": "make something bad less serious, harmful, or painful",
    "long": "To reduce how serious, harmful, or painful something is, without removing it completely. Common in formal writing about risks, damage, and climate change: mitigate the effects, impact, or risk of something."
  },
  "grammar": {"pattern":"mitigate + the effects/risk/impact of sth"},
  "examples": [
    {"en":"Planting trees can help mitigate the effects of climate change.","tr":"Ağaç dikmek, iklim değişikliğinin etkilerini hafifletmeye yardımcı olabilir.","register":"formal","focus":"mitigate"},
    {"en":"The company took steps to mitigate the risk of data loss.","tr":"Şirket, veri kaybı riskini azaltmak için önlemler aldı.","register":"formal","focus":"mitigate"},
    {"en":"Good insulation mitigates heat loss in winter.","tr":"İyi yalıtım, kışın ısı kaybını azaltır.","focus":"mitigates"}
  ],
  "synonyms": ["alleviate","reduce","lessen","ease"],
  "antonyms": ["worsen","aggravate"],
  "collocations": ["mitigate the risk","mitigate the impact","mitigate the effects","mitigate damage","mitigating circumstances"],
  "word_family": [{"lemma":"mitigation","pos":"n"},{"lemma":"mitigating","pos":"adj"}],
  "etymology": {"text":"From Latin 'mitigare', 'to soften': mitis 'mild, gentle' + agere 'to do, make': literally 'make mild'.","origin":"Latin","confidence":"high"},
  "l1": {"tr": {
      "gloss": "hafifletmek, azaltmak",
      "alt": ["etkisini azaltmak"],
      "equivalence": "full",
      "note": "Sorunu tamamen ortadan kaldırmaz, şiddetini azaltır. 'Önlemek' (prevent) değildir.",
      "mistakes": [
        {"wrong":"We must mitigate against floods.","right":"We must mitigate the effects of floods.","why":"'Mitigate' doğrudan nesne alır; 'against' ile kullanılmaz ('militate against' ile karıştırılır)."},
        {"wrong":"This law will mitigate crime completely.","right":"This law will reduce crime.","why":"'Mitigate' tamamen önlemek değil, hafifletmektir."}
      ],
      "mnemonic": "Latince 'mitis' = yumuşak: sert bir sorunu yumuşatmak."
  }},
  "tags": {"primary_topic":"environment_climate","topics":["environment_climate","academic_core","business_management"],"exams":["ielts","toefl","sat"],"register":"formal","flags":["confusable:militate"]},
  "quiz": {"cloze":"Sandbags can ______ the damage caused by flooding.","answer":"mitigate","distractors":["ignore","predict","celebrate"]},
  "meta": {"qa_flags":["exam_tags_unverified"]}
},
{
  "id": "en.eloquent.adj.1",
  "lemma": "eloquent",
  "pos": "adj",
  "level": "C1",
  "freq": {"rank":22069,"zipf":3.21},
  "ipa": {"us":"/ˈɛləkwənt/","uk":"/ˈɛləkwənt/"},
  "def": {
    "micro": "fluent and persuasive",
    "short": "able to speak or write in a clear, fluent, and persuasive way",
    "long": "Good at expressing ideas in a way that is clear, powerful, and moving. Used for people (an eloquent speaker) and for things such as speeches, writing, or even silence: 'an eloquent look'."
  },
  "examples": [
    {"en":"She gave an eloquent speech about the importance of education.","tr":"Eğitimin önemi üzerine akıcı ve etkileyici bir konuşma yaptı.","focus":"eloquent"},
    {"en":"He was too nervous to be eloquent, but his honesty won everyone over.","tr":"Belagatli konuşamayacak kadar gergindi ama dürüstlüğüyle herkesi etkiledi.","focus":"eloquent"},
    {"en":"Her tears were more eloquent than any words.","tr":"Gözyaşları her sözden daha çok şey anlatıyordu.","register":"literary","focus":"eloquent"}
  ],
  "synonyms": ["articulate","fluent","persuasive","expressive"],
  "antonyms": ["inarticulate","tongue-tied"],
  "collocations": ["eloquent speech","eloquent speaker","eloquent plea","speak eloquently","eloquent silence"],
  "word_family": [{"lemma":"eloquence","pos":"n"},{"lemma":"eloquently","pos":"adv"}],
  "etymology": {"text":"From Latin 'eloqui', 'to speak out' (e- 'out' + loqui 'to speak'). Same root as 'loquacious' and 'colloquial'.","origin":"Latin","confidence":"high"},
  "l1": {"tr": {
      "gloss": "belagatli, etkili konuşan",
      "alt": ["akıcı","anlamlı (bakış)"],
      "equivalence": "partial",
      "note": "'Belagatli' resmî/edebî bir sözcüktür; gündelik dilde 'iyi konuşan', 'etkileyici konuşan' denir. Bakış ve sessizlik için 'anlamlı, çok şey anlatan'.",
      "mistakes": [
        {"wrong":"He is very eloquent in English because he speaks fast.","right":"He is very fluent in English because he speaks fast.","why":"'Eloquent' sadece akıcılık değil, etkili ve ikna edici anlatımdır; hız/akıcılık için 'fluent'."}
      ],
      "mnemonic": "'Loqui' = konuşmak. E-loqui-ent: sözü 'dışarı' (e-) güzelce çıkaran."
  }},
  "tags": {"primary_topic":"sound_smarter","topics":["sound_smarter","social_skills","literature_writing"],"exams":["sat","gre"],"register":"formal","vibes":["smart"]},
  "quiz": {"cloze":"The lawyer's closing argument was so ______ that the jury was moved.","answer":"eloquent","distractors":["vague","brief","clumsy"]},
  "meta": {"qa_flags":["exam_tags_unverified"]}
},
{
  "id": "en.pragmatic.adj.1",
  "lemma": "pragmatic",
  "pos": "adj",
  "level": "C1",
  "freq": {"rank":15248,"zipf":3.49},
  "ipa": {"us":"/præɡˈmætɪk/","uk":"/præɡˈmætɪk/"},
  "def": {
    "micro": "practical and realistic",
    "short": "dealing with problems in a sensible, realistic way, not by theory",
    "long": "Focused on what works in real situations rather than on ideals or theory. A pragmatic person or plan accepts limits and chooses practical solutions. Usually a compliment in English."
  },
  "examples": [
    {"en":"We need a pragmatic solution, not a perfect one.","tr":"Mükemmel olmasa da pratik ve gerçekçi bir çözüme ihtiyacımız var.","focus":"pragmatic"},
    {"en":"She took a pragmatic approach and focused on small steps.","tr":"Pragmatik bir yaklaşım benimseyip küçük adımlara odaklandı.","focus":"pragmatic"},
    {"en":"Being pragmatic, he accepted the lower offer.","tr":"Gerçekçi davranıp daha düşük teklifi kabul etti.","focus":"pragmatic"}
  ],
  "synonyms": ["practical","realistic","sensible","down-to-earth"],
  "antonyms": ["idealistic","impractical"],
  "collocations": ["pragmatic approach","pragmatic solution","pragmatic decision","take a pragmatic view","pragmatic about money"],
  "word_family": [{"lemma":"pragmatism","pos":"n"},{"lemma":"pragmatist","pos":"n"},{"lemma":"pragmatically","pos":"adv"}],
  "etymology": {"text":"From Greek 'pragmatikos', 'skilled in business', from 'pragma' (deed, action): related to the root of 'practice'.","origin":"Greek","confidence":"high"},
  "l1": {"tr": {
      "gloss": "pratik, gerçekçi",
      "alt": ["pragmatik","sonuç odaklı"],
      "equivalence": "partial",
      "note": "Türkçede 'pragmatik' bazen 'çıkarcı' tonu taşır; İngilizcede genelde olumlu/nötrdür (TDK karşılığı 'yararcı', günlük dilde nadir).",
      "mistakes": [
        {"wrong":"He is pragmatic; he only thinks about his own benefit.","right":"He is opportunistic / self-serving.","why":"'Pragmatic' çıkarcı demek değildir; 'çıkarcı' için 'opportunistic, self-serving'."}
      ],
      "mnemonic": "Pragma = eylem (Yunanca); 'pratik' ile aynı kökten: iş gören, sonuç getiren."
  }},
  "tags": {"primary_topic":"business_management","topics":["business_management","personality","philosophy_ethics"],"exams":["sat","gre","toefl"],"vibes":["smart"]},
  "quiz": {"cloze":"Rather than wait for the perfect plan, the manager took a ______ approach.","answer":"pragmatic","distractors":["romantic","theoretical","emotional"]},
  "meta": {"qa_flags":["exam_tags_unverified","tr_tone_note_verify"]}
},
{
  "id": "en.ambiguous.adj.1",
  "lemma": "ambiguous",
  "pos": "adj",
  "level": "C1",
  "freq": {"rank":13460,"zipf":3.57},
  "ipa": {"us":"/æmˈbɪɡjuəs/","uk":"/æmˈbɪɡjuəs/"},
  "def": {
    "micro": "having more than one meaning",
    "short": "unclear because it can be understood in more than one way",
    "long": "Open to more than one interpretation, so the meaning is not clear. Used for words, sentences, rules, and situations: an ambiguous answer, an ambiguous ending. 'Vague' means not clear or detailed enough."
  },
  "examples": [
    {"en":"The contract wording is ambiguous, so it can be read in two ways.","tr":"Sözleşmenin ifadesi muğlak olduğundan iki farklı şekilde okunabiliyor.","focus":"ambiguous"},
    {"en":"Her answer was ambiguous; I couldn't tell if she agreed.","tr":"Cevabı muğlaktı; katılıp katılmadığını anlayamadım.","focus":"ambiguous"},
    {"en":"The film has an ambiguous ending that fans still argue about.","tr":"Filmin hâlâ hayranları arasında tartışılan muğlak bir sonu var.","focus":"ambiguous"}
  ],
  "synonyms": ["unclear","vague","equivocal","open to debate"],
  "antonyms": ["clear","unambiguous","explicit"],
  "collocations": ["highly ambiguous","ambiguous wording","ambiguous meaning","deliberately ambiguous","ambiguous situation"],
  "word_family": [{"lemma":"ambiguity","pos":"n"},{"lemma":"ambiguously","pos":"adv"}],
  "etymology": {"text":"From Latin 'ambiguus', 'going both ways', from 'ambigere' (to wander): ambi- 'around' + agere 'to drive'.","origin":"Latin","confidence":"high"},
  "l1": {"tr": {
      "gloss": "belirsiz, muğlak",
      "alt": ["çift anlamlı","iki anlama gelebilen"],
      "equivalence": "full",
      "note": "'Ambiguous' (muğlak), 'ambitious' (hırslı) ve 'ambivalent' (kararsız, iki duygulu) ile sık karıştırılır.",
      "mistakes": [
        {"wrong":"I'm ambiguous about moving abroad.","right":"I'm ambivalent about moving abroad.","why":"Kişinin iki yönlü duygusu için 'ambivalent'; 'ambiguous' söz, cümle ve durumlar içindir."},
        {"wrong":"He is a very ambiguous person. (= hırslı)","right":"He is a very ambitious person.","why":"'Ambiguous' muğlak, 'ambitious' hırslıdır."}
      ],
      "mnemonic": "Ambi- = iki taraflı (ambidextrous: iki elini de kullanan): iki yöne giden = ambiguous."
  }},
  "tags": {"primary_topic":"academic_core","topics":["academic_core","society_media","literature_writing"],"exams":["ielts","toefl","sat"],"flags":["confusable:ambitious","confusable:ambivalent"]},
  "quiz": {"cloze":"The sign was so ______ that half the drivers turned left and half turned right.","answer":"ambiguous","distractors":["ambitious","ambivalent","abundant"]},
  "meta": {"qa_flags":["exam_tags_unverified"]}
},
{
  "id": "en.condescending.adj.1",
  "lemma": "condescending",
  "pos": "adj",
  "level": "C1",
  "freq": {"rank":25327,"zipf":3.1},
  "ipa": {"us":"/ˌkɑːndɪˈsɛndɪŋ/","uk":"/ˌkɒndɪˈsɛndɪŋ/"},
  "def": {
    "micro": "talking down to people",
    "short": "behaving as if you are smarter or more important than other people",
    "long": "Showing, usually by your tone, that you think you are better than someone and that they cannot understand easily. A condescending remark may sound polite but feels insulting."
  },
  "examples": [
    {"en":"I hate his condescending tone; he explains things as if I were a child.","tr":"Beni çocuk yerine koyan o tepeden bakan tavrından nefret ediyorum.","focus":"condescending"},
    {"en":"She gave me a condescending smile and walked away.","tr":"Bana küçümseyici bir gülümsemeyle bakıp uzaklaştı.","focus":"condescending"},
    {"en":"Try not to be condescending when you teach beginners.","tr":"Yeni başlayanlara öğretirken tepeden bakmamaya çalış.","focus":"condescending"}
  ],
  "synonyms": ["patronizing","superior","snooty"],
  "antonyms": ["respectful","humble"],
  "collocations": ["condescending tone","condescending attitude","a condescending smile","sound condescending","come across as condescending"],
  "word_family": [{"lemma":"condescend","pos":"v"},{"lemma":"condescension","pos":"n"}],
  "etymology": {"text":"From Latin 'condescendere' (to stoop down). Early English 'condescend' meant to graciously agree or deign, not to insult; the patronizing tone developed later.","origin":"Latin","confidence":"medium"},
  "l1": {"tr": {
      "gloss": "küçümseyici, tepeden bakan",
      "alt": ["üstten bakan","çocuk yerine koyan"],
      "equivalence": "full",
      "note": "Türkçedeki 'tepeden bakmak' (TDK: küçümsemek) tam karşılığıdır. Her zaman olumsuzdur; iltifat olarak kullanılmaz.",
      "mistakes": [
        {"wrong":"My teacher is very condescending; she always thinks of us.","right":"My teacher is very considerate; she always thinks of us.","why":"'Considerate' = düşünceli; 'condescending' = küçümseyici. İkisi de 'con-' ile başladığı için karışır."}
      ],
      "mnemonic": "İçinde 'descend' (inmek) var: yüksekten inip sana 'lütfeden' biri."
  }},
  "tags": {"primary_topic":"compliments_insults","topics":["compliments_insults","personality","social_skills"],"flags":["mildly_negative"],"sensitivity":1},
  "quiz": {"cloze":"Please don't be so ______; I understand the instructions perfectly.","answer":"condescending","distractors":["considerate","contented","convenient"]},
  "meta": {"qa_flags":["etymology_medium_verify"]}
},
{
  "id": "en.meticulous.adj.1",
  "lemma": "meticulous",
  "pos": "adj",
  "level": "C2",
  "freq": {"rank":21284,"zipf":3.24},
  "ipa": {"us":"/məˈtɪkjələs/","uk":"/məˈtɪkjələs/"},
  "def": {
    "micro": "very careful about details",
    "short": "showing great care and attention to every small detail",
    "long": "Very careful and precise, paying attention to even the smallest details. Usually praise: a meticulous planner, meticulous records. It can sound slightly critical if it suggests someone is too fussy."
  },
  "examples": [
    {"en":"He is meticulous about keeping accurate records.","tr":"Kayıtları doğru tutma konusunda son derece titizdir.","focus":"meticulous"},
    {"en":"The chef prepared the dish with meticulous care.","tr":"Şef, yemeği büyük bir titizlikle hazırladı.","focus":"meticulous"},
    {"en":"Thanks to meticulous planning, the event ran without a single problem.","tr":"Titiz bir planlama sayesinde etkinlik tek bir aksaklık olmadan geçti.","focus":"meticulous"}
  ],
  "synonyms": ["thorough","painstaking","careful","precise","fastidious"],
  "antonyms": ["careless","sloppy"],
  "collocations": ["meticulous attention","meticulous planning","meticulous research","meticulous detail","meticulously planned"],
  "word_family": [{"lemma":"meticulously","pos":"adv"},{"lemma":"meticulousness","pos":"n"}],
  "etymology": {"text":"From Latin 'meticulosus', 'fearful', from 'metus' (fear). English first used it for 'timid'; the 'careful about details' sense came via French in the 1800s.","origin":"Latin","confidence":"high"},
  "l1": {"tr": {
      "gloss": "titiz, özenli",
      "alt": ["çok dikkatli","detaycı"],
      "equivalence": "full",
      "note": "'Titiz' bazen 'aşırı seçici, memnun edilmesi güç' tonu da taşır (TDK); İngilizce 'meticulous' ise çoğunlukla övgüdür.",
      "mistakes": [
        {"wrong":"me-ti-cu-LOUS (stress on the last syllable)","right":"meh-TIK-yuh-lus (stress on the 2nd syllable)","why":"Türkçede vurgu genelde sondadır; bu kelimede ikinci hece vurgulanır."},
        {"wrong":"He is meticulous of details.","right":"He is meticulous about details.","why":"Edat 'of' değil, 'about' (veya 'in') olur."}
      ],
      "mnemonic": "Latince 'metus' = korku: hata yapmaktan korktuğu için her ayrıntıyı iki kez kontrol eden."
  }},
  "tags": {"primary_topic":"personality","topics":["personality","workplace_office","sound_smarter"],"exams":["gre","sat"],"vibes":["smart"]},
  "quiz": {"cloze":"The editor was ______ and found a typo on every page.","answer":"meticulous","distractors":["careless","generous","lazy"]},
  "meta": {"qa_flags":["ipa_uk_variant","exam_tags_unverified"]}
},
{
  "id": "en.ubiquitous.adj.1",
  "lemma": "ubiquitous",
  "pos": "adj",
  "level": "C2",
  "freq": {"rank":16814,"zipf":3.42},
  "ipa": {"us":"/juˈbɪkwɪtəs/","uk":"/juːˈbɪkwɪtəs/"},
  "def": {
    "micro": "found everywhere",
    "short": "seeming to be present everywhere at the same time",
    "long": "Present, appearing, or found everywhere, often so common that people stop noticing it. Frequently used for technology and trends: ubiquitous smartphones, a ubiquitous logo. Formal."
  },
  "examples": [
    {"en":"Smartphones have become ubiquitous in modern life.","tr":"Akıllı telefonlar modern hayatın her yerinde karşımıza çıkıyor.","focus":"ubiquitous"},
    {"en":"Coffee shops are ubiquitous in this neighborhood.","tr":"Bu mahallede kafelere her yerde rastlanıyor.","focus":"ubiquitous"},
    {"en":"The company's logo is ubiquitous; you see it on every street.","tr":"Şirketin logosu her yerde; her sokakta karşına çıkıyor.","focus":"ubiquitous"}
  ],
  "synonyms": ["omnipresent","widespread","pervasive"],
  "antonyms": ["rare","scarce"],
  "collocations": ["ubiquitous presence","increasingly ubiquitous","ubiquitous technology","become ubiquitous","virtually ubiquitous"],
  "word_family": [{"lemma":"ubiquity","pos":"n"}],
  "etymology": {"text":"From Latin 'ubique', 'everywhere' (ubi 'where' + -que). The noun 'ubiquity' came first in English.","origin":"Latin","confidence":"high"},
  "l1": {"tr": {
      "gloss": "her yerde bulunan, yaygın",
      "alt": ["hemen her yerde görülen"],
      "equivalence": "partial",
      "note": "Tek sözcüklük Türkçe karşılığı yok. 'Yaygın' (common) ile karıştırma: 'ubiquitous' gerçekten 'her yerde' demektir.",
      "mistakes": [
        {"wrong":"u-bi-ki-TUS (starts like \"umut\")","right":"yoo-BIK-wi-tus","why":"Kelime /juː/ ('yu') ile başlar; 'ü/u' değil. Vurgu ikinci hecede."}
      ],
      "mnemonic": "Latince 'ubi' = nerede: 'nerede arasan orada'."
  }},
  "tags": {"primary_topic":"technology_internet","topics":["technology_internet","sound_smarter","society_media"],"exams":["gre","sat","toefl"],"register":"formal","vibes":["smart"]},
  "quiz": {"cloze":"In big cities, fast-food restaurants are ______; there is one on every corner.","answer":"ubiquitous","distractors":["rare","ancient","hidden"]},
  "meta": {"qa_flags":["exam_tags_unverified"]}
},
{
  "id": "en.ephemeral.adj.1",
  "lemma": "ephemeral",
  "pos": "adj",
  "level": "C2",
  "freq": {"rank":29260,"zipf":2.99},
  "ipa": {"us":"/ɪˈfɛmərəl/","uk":"/ɪˈfɛmərəl/"},
  "def": {
    "micro": "lasting a very short time",
    "short": "lasting only a short time, often with a sense of beauty or sadness",
    "long": "Lasting for a very short time. Often used with a poetic feeling for beautiful things that disappear quickly: cherry blossoms, fame, a mood, a trend. Not the same as 'temporary', which is neutral."
  },
  "examples": [
    {"en":"Social media fame is often ephemeral.","tr":"Sosyal medya şöhreti çoğu zaman geçicidir.","focus":"ephemeral"},
    {"en":"The cherry blossoms are beautiful but ephemeral.","tr":"Kiraz çiçekleri güzel ama kısa ömürlü.","focus":"ephemeral"},
    {"en":"She wrote about the ephemeral joy of a summer evening.","tr":"Bir yaz akşamının uçup giden mutluluğunu yazdı.","register":"literary","focus":"ephemeral"}
  ],
  "synonyms": ["fleeting","transient","short-lived","momentary"],
  "antonyms": ["eternal","permanent","lasting"],
  "collocations": ["ephemeral nature","ephemeral beauty","ephemeral pleasure","ephemeral fame","ephemeral art"],
  "word_family": [{"lemma":"ephemera","pos":"n"},{"lemma":"ephemerality","pos":"n"}],
  "etymology": {"text":"From Greek 'ephemeros', 'lasting a day' (epi 'on' + hemera 'day'). The mayfly, whose adult life lasts about a day, is the classic example.","origin":"Greek","confidence":"high"},
  "l1": {"tr": {
      "gloss": "geçici, kısa ömürlü",
      "alt": ["uçup giden","gelip geçici"],
      "equivalence": "partial",
      "note": "'Geçici' (temporary) nötrdür; 'ephemeral' çoğunlukla şiirsel bir hüzün ya da güzellik çağrıştırır: 'gelip geçici'.",
      "mistakes": [
        {"wrong":"'Ephemeral' means 'eternal'.","right":"'Ephemeral' = short-lived; 'eternal' is its opposite.","why":"'Eternal' (ebedî) ile sesi benzer ama anlamı tam zıttır."}
      ],
      "mnemonic": "Yunanca 'hemera' = gün: bir günlük ömür = ephemeral."
  }},
  "tags": {"primary_topic":"rare_beautiful","topics":["rare_beautiful","sound_smarter","literature_writing"],"exams":["gre","sat"],"register":"literary","vibes":["beautiful","poetic"],"flags":["confusable:eternal"]},
  "quiz": {"cloze":"Snowflakes are ______: they melt the moment they touch your hand.","answer":"ephemeral","distractors":["eternal","enormous","edible"]},
  "meta": {"qa_flags":["exam_tags_unverified"]}
},
{
  "id": "en.serendipity.n.1",
  "lemma": "serendipity",
  "pos": "n",
  "level": "C2",
  "freq": {"rank":40016,"zipf":2.74},
  "ipa": {"us":"/ˌsɛrənˈdɪpɪti/","uk":"/ˌsɛrənˈdɪpɪti/"},
  "def": {
    "micro": "happy accident",
    "short": "the lucky chance of discovering something good without looking for it",
    "long": "The happy experience of finding something valuable or delightful by chance rather than by planning. Often used for lucky meetings, discoveries, and coincidences: 'a moment of pure serendipity'."
  },
  "examples": [
    {"en":"We found this café by pure serendipity.","tr":"Bu kafeyi tam bir tesadüf eseri keşfettik.","focus":"serendipity"},
    {"en":"Many scientific discoveries were the result of serendipity.","tr":"Pek çok bilimsel keşif mutlu bir tesadüfün ürünüdür.","focus":"serendipity"},
    {"en":"It was serendipity that we sat next to each other on the train.","tr":"Trende yan yana oturmamız tam bir mutlu tesadüftü.","focus":"serendipity"}
  ],
  "synonyms": ["luck","fluke","happy accident"],
  "antonyms": ["misfortune"],
  "collocations": ["pure serendipity","by serendipity","sheer serendipity","a moment of serendipity","serendipity strikes"],
  "word_family": [{"lemma":"serendipitous","pos":"adj"},{"lemma":"serendipitously","pos":"adv"}],
  "etymology": {"text":"Coined in 1754 by Horace Walpole after the Persian fairy tale 'The Three Princes of Serendip' (Serendip = old name of Sri Lanka), whose heroes kept making lucky discoveries.","origin":"English coinage (Persian tale)","confidence":"high"},
  "l1": {"tr": {
      "gloss": "mutlu tesadüf",
      "alt": ["beklenmedik keşif","şans eseri bulma"],
      "equivalence": "partial",
      "note": "Tek sözcüklük karşılığı yok; 'mutlu tesadüf' en yaygın söyleyiş. 'Tesadüf' tek başına iyi ya da kötü olabilir; serendipity her zaman güzel bir sonuç taşır.",
      "mistakes": [
        {"wrong":"It was a serendipity.","right":"It was serendipity. / It was a serendipitous meeting.","why":"'Serendipity' sayılamayan isimdir, 'a' almaz; sayılabilir kullanım için 'serendipitous' sıfatı."}
      ],
      "mnemonic": "Serendip adasının üç prensi hep aradığından fazlasını buldu: serendipity."
  }},
  "tags": {"primary_topic":"rare_beautiful","topics":["rare_beautiful","sound_smarter","love_friendship"],"vibes":["beautiful","lucky"]},
  "quiz": {"cloze":"Meeting my business partner at that random party was pure ______.","answer":"serendipity","distractors":["strategy","punishment","routine"]},
  "meta": {"qa_flags":["ipa_us_variant_ə"]}
},
{
  "id": "en.enervate.v.1",
  "lemma": "enervate",
  "pos": "v",
  "level": "S",
  "freq": {"rank":231190,"zipf":1.26},
  "ipa": {"us":"/ˈɛnərveɪt/","uk":"/ˈɛnəveɪt/"},
  "def": {
    "micro": "drain of energy",
    "short": "make someone feel weak or drained of energy",
    "long": "To weaken someone by taking away their energy or strength. Careful: although it looks like 'energy' or 'energize', it means the opposite. Formal and literary; common on GRE-style lists."
  },
  "grammar": {"pattern":"enervate + sb/sth (often passive: be enervated by)"},
  "examples": [
    {"en":"The long heat wave enervated the whole town.","tr":"Uzun süren sıcak hava dalgası bütün kasabayı hâlsiz bıraktı.","register":"formal","focus":"enervated"},
    {"en":"She felt enervated after hours of pointless meetings.","tr":"Saatler süren anlamsız toplantıların ardından kendini bitkin hissetti.","register":"formal","focus":"enervated"},
    {"en":"The humid weather enervates even the strongest runners.","tr":"Nemli hava, en güçlü koşucuları bile bitkin düşürür.","register":"formal","focus":"enervates"}
  ],
  "synonyms": ["drain","exhaust","weaken","sap"],
  "antonyms": ["energize","invigorate"],
  "collocations": ["feel enervated","enervating heat","enervating effect","utterly enervated"],
  "word_family": [{"lemma":"enervation","pos":"n"},{"lemma":"enervating","pos":"adj"}],
  "etymology": {"text":"From Latin 'enervare', 'to weaken': e- 'out' + nervus 'sinew': literally 'to cut out the sinews'.","origin":"Latin","confidence":"high"},
  "l1": {"tr": {
      "gloss": "hâlsiz bırakmak",
      "alt": ["güçten düşürmek","bitkin düşürmek"],
      "equivalence": "false_friend",
      "false_friend": {"tr_word":"enerji","tr_means":"güç, canlılık","en_for_that":"energize / invigorate"},
      "note": "'Enerji' kökünü çağrıştırdığı için ters anlaşılır: enervate = enerjiyi AZALTMAK. Enerji vermek = 'energize'.",
      "mistakes": [
        {"wrong":"A cup of coffee enervates me in the morning.","right":"A cup of coffee energizes me in the morning.","why":"'Enervate' enerji vermek değil, almaktır."}
      ],
      "mnemonic": "e-NERV-ate: sinirleri (nerve) 'dışarı' çıkarılmış gibi hâlsiz. 'e-NERJİ' değil, 'e-NERV'."
  }},
  "tags": {"primary_topic":"gre","topics":["gre","sound_smarter","health_body"],"exams":["gre","sat"],"register":"formal","vibes":["smart"],"flags":["commonly_misused","false_friend_tr"]},
  "quiz": {"cloze":"The endless humidity ______ the travelers until they could barely walk.","answer":"enervated","distractors":["energized","inspired","refreshed"]},
  "meta": {"qa_flags":["exam_tags_unverified"]}
},
{
  "id": "en.mellifluous.adj.1",
  "lemma": "mellifluous",
  "pos": "adj",
  "level": "S",
  "freq": {"rank":86508,"zipf":2.08},
  "ipa": {"us":"/məˈlɪfluəs/","uk":"/məˈlɪfluəs/"},
  "def": {
    "micro": "sweet and smooth to hear",
    "short": "sweet and smooth to the ear, like a beautiful voice or music",
    "long": "Describes sounds, especially voices, music, or words, that are smooth, sweet, and pleasant to hear, as if flowing like honey. A literary word for a beautiful speaking or singing voice."
  },
  "examples": [
    {"en":"The radio host's mellifluous voice made the late-night news feel soothing.","tr":"Radyo sunucusunun tatlı, akıcı sesi gece haberlerini bile rahatlatıcı kılıyordu.","focus":"mellifluous"},
    {"en":"A mellifluous melody drifted from the open window.","tr":"Açık pencereden kulağa hoş gelen bir melodi süzülüyordu.","register":"literary","focus":"mellifluous"},
    {"en":"Her mellifluous Italian made even a simple order sound like poetry.","tr":"Ahenkli İtalyancası, sıradan bir siparişi bile şiir gibi dinletiyordu.","register":"literary","focus":"mellifluous"}
  ],
  "synonyms": ["melodious","dulcet","silvery","smooth"],
  "antonyms": ["harsh","grating","raspy"],
  "collocations": ["mellifluous voice","mellifluous tones","mellifluous sound","mellifluous prose"],
  "word_family": [{"lemma":"mellifluously","pos":"adv"}],
  "etymology": {"text":"From Late Latin 'mellifluus', 'flowing with honey': mel 'honey' + fluere 'to flow'.","origin":"Latin","confidence":"high"},
  "l1": {"tr": {
      "gloss": "tatlı sesli, ahenkli",
      "alt": ["kulağa hoş gelen","akıcı ve tatlı"],
      "equivalence": "partial",
      "note": "Yazılı/edebî bir sözcüktür; yalnızca ses, müzik ve söz için kullanılır. Tat için kullanılmaz.",
      "mistakes": [
        {"wrong":"The cake was mellifluous.","right":"The cake was delicious. / The singer's voice was mellifluous.","why":"'Mel' (bal) kökü yüzünden tat için denemeyin; yalnızca ses ve söz için."}
      ],
      "mnemonic": "Latince 'mel' = bal: bal gibi akan ses."
  }},
  "tags": {"primary_topic":"rare_beautiful","topics":["rare_beautiful","music_film","sound_smarter"],"exams":["gre"],"register":"literary","vibes":["beautiful","poetic"]},
  "quiz": {"cloze":"The choir's ______ harmonies filled the old church.","answer":"mellifluous","distractors":["shrill","grating","muffled"]},
  "meta": {"qa_flags":["exam_tags_unverified"]}
},
{
  "id": "en.petrichor.n.1",
  "lemma": "petrichor",
  "pos": "n",
  "level": "S",
  "freq": {"rank":152851,"zipf":1.6},
  "ipa": {"us":"/ˈpɛtrɪˌkɔːr/","uk":"/ˈpɛtrɪkɔː/"},
  "def": {
    "micro": "smell of rain on dry earth",
    "short": "the pleasant smell of the ground when rain falls after a dry spell",
    "long": "The fresh, earthy smell that rises from dry soil when rain first falls on it. Scientists coined the word in 1964; the smell comes partly from plant oils and a compound called geosmin made by soil bacteria."
  },
  "examples": [
    {"en":"After weeks of drought, the first rain filled the air with petrichor.","tr":"Haftalarca süren kuraklığın ardından ilk yağmur havayı toprak kokusuyla doldurdu.","focus":"petrichor"},
    {"en":"I opened the window to breathe in the petrichor.","tr":"Yağmur sonrası toprak kokusunu içime çekmek için pencereyi açtım.","focus":"petrichor"},
    {"en":"Many people say petrichor is their favorite smell.","tr":"Birçok kişi, yağmur sonrası toprak kokusunun en sevdiği koku olduğunu söyler.","focus":"petrichor"}
  ],
  "synonyms": ["smell of rain"],
  "collocations": ["the scent of petrichor","a hint of petrichor","smell petrichor","petrichor and geosmin"],
  "etymology": {"text":"Coined in 1964 by Australian scientists Isabel Joy Bear and Richard G. Thomas from Greek 'petra' (stone) + 'ichor' (the fluid in the veins of the gods).","origin":"Greek (modern coinage)","confidence":"high"},
  "l1": {"tr": {
      "gloss": "yağmur sonrası toprak kokusu",
      "alt": ["petrikor"],
      "equivalence": "partial",
      "note": "Gündelik Türkçede tek sözcük yok; 'petrikor' bilim ve popüler yazıda kullanılır. 'Toprak kokusu' aynı imgeyi taşır.",
      "mistakes": [
        {"wrong":"I love the petrichor of fresh bread.","right":"I love the smell of fresh bread.","why":"'Petrichor' yalnızca yağmurun toprakta çıkardığı kokudur."}
      ],
      "mnemonic": "Petrol ile aynı kök (petra = taş): taşa/toprağa yağmur değince çıkan 'ilahi' koku."
  }},
  "tags": {"primary_topic":"rare_beautiful","topics":["rare_beautiful","weather_seasons","nature_animals"],"register":"literary","vibes":["beautiful","calm"],"flags":["science_coinage"]},
  "quiz": {"cloze":"The first rain after the drought released a wonderful ______ from the dry ground.","answer":"petrichor","distractors":["perfume","petroleum","pesticide"]},
  "meta": {"qa_flags":["ipa_uncertain_us_uk_variants"]}
},
{
  "id": "en.sonder.n.1",
  "lemma": "sonder",
  "pos": "n",
  "sense_note": "coined word",
  "level": "S",
  "freq": {"rank":104603,"zipf":1.92},
  "ipa": {"us":"/ˈsɑːndər/","uk":"/ˈsɒndə/"},
  "def": {
    "micro": "everyone has a full life",
    "short": "realizing that every stranger has a life as complex as your own",
    "long": "A coined word for the sudden realization that every passerby has a life as rich and complicated as yours. Invented by John Koenig for 'The Dictionary of Obscure Sorrows'; treat it as informal and not standard."
  },
  "examples": [
    {"en":"Watching the commuters rush by, I felt a wave of sonder.","tr":"Acele eden yolcuları izlerken içimi bir \"sonder\" duygusu kapladı.","register":"informal","focus":"sonder"},
    {"en":"Sonder hit me as I looked at the strangers in the café.","tr":"Kafedeki yabancılara bakarken birden \"sonder\" hissine kapıldım.","register":"informal","focus":"Sonder"},
    {"en":"'Sonder' is popular online, but you won't find it in every dictionary.","tr":"\"Sonder\" internette popüler ama her sözlükte bulamazsın.","register":"informal","focus":"Sonder"}
  ],
  "collocations": ["a wave of sonder","a moment of sonder","feel sonder"],
  "etymology": {"text":"Coined in 2012 by John Koenig for his 'Dictionary of Obscure Sorrows' project, inspired by German 'sonder-' (special) and French 'sonder' (to probe).","origin":"English neologism","confidence":"high"},
  "l1": {"tr": {
      "gloss": "herkesin hikâyesi var hissi",
      "alt": ["sonder (yeni sözcük)"],
      "equivalence": "none",
      "note": "Türkçede karşılığı yoktur; 'sonder' uydurma (neolojizm) bir sözcüktür, Türkçe metinlerde genellikle olduğu gibi kullanılır.",
      "mistakes": [
        {"wrong":"In my IELTS essay I used 'sonder' to describe empathy.","right":"Use 'empathy' or 'compassion' in exams.","why":"Yeni türetilmiş sözcükler sınavda ve resmî yazıda risklidir."}
      ],
      "mnemonic": "SON-der ≈ 'son derece': herkesin son derece dolu bir hayatı var."
  }},
  "tags": {"primary_topic":"rare_beautiful","topics":["rare_beautiful","emotions_feelings","mind_psychology"],"register":"informal","vibes":["poetic","deep"],"flags":["coined","not_for_exams"]},
  "quiz": {"cloze":"Looking at the crowded train, I had a strange moment of ______: every face had a whole story.","answer":"sonder","distractors":["sorrow","solitude","surprise"]},
  "meta": {"qa_flags":["coined_word","ipa_uncertain_no_standard"]}
}
]
}
```

---

## 8. Content-driven engagement

### 8.1 Word of the Day (WOTD) system
- **Two slots per day:** (1) a personalized word from the user's level + topics; (2) a global **Editor's Pick** (same for everyone, which is shareable and a social hook). Each WOTD card carries the story layer: etymology fact, mnemonic, Turkish nuance note.
- **Weekly rhythm (Editor's Pick):** Mon Motivation (resilience/habit words); Tue Tech (phishing, ubiquitous…); Wed "Sound Smarter"; Thu Etymology Throwback; **Fri False-Friend Friday (Turkish)**; Sat Idiom/Slang; Sun Slow Sunday (Rare & Beautiful).
- **Monthly series:** Stop-Saying swap week; a Turkish proverb ↔ English proverb week; "words you already know" (cognates like *chronic* ↔ *kronik*) as an onboarding quick-win pack, since Turkish borrowed many French/English words. Pair it with a false-friends warning so it never misleads.

### 8.2 Seasonal and event calendar (Oct 2026 to Sep 2027)
Dates marked (verify) are approximate or come from a single commercial source.

| Month | Hook | Pack / series |
|---|---|---|
| Oct 2026 | Halloween (Oct 31); Republic Day (Oct 29, Türkiye) | "Spooky & Gothic" (eerie, macabre, haunt, sinister); "Freedom & Independence" |
| Nov 2026 | YDS second session reported for Nov 22 (verify on ÖSYM); Teachers' Day (Nov 24, Türkiye); Black Friday (Nov 27) | YDS/YÖKDİL final-sprint countdown (30/14/7 days); "Learn & Teach"; "Shopping & Deals" |
| Dec 2026 | Dictionary "Word of the Year" announcements; New Year | "Words of the Year" roundup (editorial commentary only); "New Year, New Habits" (resolutions) |
| Jan 2027 | Resolution season | Productivity/Habits pack (procrastinate, discipline…) |
| Feb 2027 | Valentine's (Feb 14); Ramadan about Feb 8 to Mar 9 (verify with Diyanet) | "Love & Compliments"; optional neutral "Gratitude & Generosity" |
| Mar 2027 | Women's Day (Mar 8); spring equinox/Nevruz/World Poetry Day (Mar 20 to 21); Eid al-Fitr about Mar 9 to 11 (verify) | "Trailblazers"; "Spring & Poetic"; neutral "Hospitality & Celebration" |
| Apr 2027 | Apr 23: National Sovereignty & Children's Day (Türkiye) + World Book Day | "Books & Reading"; Rare & Beautiful tie-in (petrichor) |
| May 2027 | May 19 Youth & Sports Day; Eid al-Adha about May 16 to 19 (verify) | "Sports & Energy"; exam-season stamina pack |
| Jun to Aug 2027 | Summer travel; YÖKDİL second session (date to verify) | Travel pack (luggage, itinerary); "Summer reading list"; YÖKDİL countdown |
| Sep 2027 | Back to school | "Study Skills & New Term" |

Keep religious-holiday packs optional, neutral in tone, and light on push notifications.

### 8.3 User-created lists
- Create/add by typing (autocomplete from the master catalog), long-press "Save" on a widget, share-sheet from Safari/Notes, and camera/Live Text scan of a page.
- Unknown words trigger on-demand pipeline generation (automated checks only) flagged "AI draft" with a report button; promoted to the catalog after human review once N users save it.
- A widget can be bound to a list. Lists are shareable via link; add classroom lists with a class code later.
- Free: 1 list (about 30 words). Premium: unlimited. Store lists local-first (iCloud/CloudKit).

### 8.4 Import from Kindle and books (power-user feature, not core)
Ranked by feasibility (all need legal and technical verification; there is no official Amazon API):
1. **Paste/share any text** (article, book excerpt, subtitles .srt): extract words above the user's level, ranked by frequency. Works everywhere, no dependency on Amazon.
2. **Kindle e-reader Vocabulary Builder file** (`vocab.db`, SQLite, on the device over USB; structure from community documentation, verify on current firmware) via the Files app. Gives words plus the user's lookup sentence.
3. **`My Clippings.txt` highlights** parser.
4. **Readwise CSV/API** for users who already sync Kindle/Apple Books.
5. **Camera scan** of a printed page (VisionKit Live Text).

The Kindle iOS app does not expose an export. Process on-device; store only lemma plus the user's own lookup sentence privately; never publish or share book excerpts; do not upload whole books.

### 8.5 AI "words from your interests"
Flow: onboarding chips plus free text ("Formula 1, cooking, cybersecurity") → **retrieval first**: filter the catalog by level and topic/vibe tags and have the LLM re-rank about 40 existing, human-reviewed cards with a one-line "why this fits you". For gaps, generate new entries through Prompts A/B (flagged "AI draft"). Cache results; one list costs about $0.01 to 0.03. Guardrails: moderate free text; no examples about real people or brands; daily caps.

```
SYSTEM: You are a vocabulary curator for an English learner at level {{level}} whose first language is Turkish. From CANDIDATES (JSON list of card ids + lemma + def.micro + tags) pick the {{n}} cards that best match INTERESTS and are useful in real conversation or reading about them. Prefer variety of word types (verbs, collocations, 2-3 phrasal verbs/idioms). Never pick cards with tags.sensitivity>0. For each pick return {id, why (<=80 chars, English)}. If fewer than {{n}} strong matches exist, return the matches and "gaps": up to 10 lemmas (level {{level}}) you recommend adding. JSON only.
INPUT: INTERESTS: {{user_interests_moderated}}  CANDIDATES: {{candidates_json}}
```

### 8.6 Other content-driven hooks
- **Interactive widget quizzes** (iOS 17+ App Intents) using `quiz.cloze` and `distractors`, with "I know it / learn again" buttons feeding spaced repetition. This is why every card carries quiz data.
- Shareable word cards (image generator) for story posts; Turkish-proverb weeks; a "streak" with one weekly free freeze.

---

## 9. Uncertainty register and what still needs verification

**IPA (flag for human/pronunciation-dictionary check):**
- *sonder*: coined word, no standard; /ˈsɑːndər/ and /ˈsɒndə/ taken from Wiktionary GA/RP.
- *petrichor*: variants /-kɔːr/ vs /-kər/ (US).
- *borrow*: US /ɑː/ vs /ɔː/ is regional.
- *procrastinate*: US first vowel /proʊ-/ vs /prə-/.
- *serendipity*: US /-ɪti/ vs /-əti/.
- *meticulous*: UK /mɪˈtɪkjʊləs/.
- *enervate*: UK and the obsolete /iːˈnɜːrveɪt/.
- *ubiquitous*: US/UK vowel length.
- *condescending* and *ephemeral*: reduced-vowel variants.
- IPA was cross-checked against Wiktionary, but its dialect labels are inconsistent. Do not treat Wiktionary as the shipping source (CC BY-SA); use it only to verify.

**CEFR levels:** all are `editorial_estimate`. A1/A2 are fairly safe. The B2 to S assignments are rough, especially *look up to*, *break the ice*, *phishing*, *chronic*, *pragmatic*, *meticulous* (C1 vs C2) and *procrastinate*.

**Frequency:** from wordfreq (en). It counts surface forms, not lemma+sense, so treat as a sort key only.

**Exam tags:** `ielts/toefl/sat/gre` tags in the sample are indicative and unverified (flagged `exam_tags_unverified`). Source them from curated lists, never from the LLM.

**Etymology:**
- Cross-checked against Wiktionary: *borrow, luggage, phishing, petrichor, serendipity, meticulous, sonder, ephemeral, enervate, mellifluous, chronic, resilient, procrastinate, ubiquitous, mitigate, condescend*.
- Checked via web search: *break the ice* (a figurative sense recorded in the late 1500s, Shakespeare uses it, the nautical origin is an inference).
- Not independently cross-checked: *breakfast, actually, sympathetic, eloquent, pragmatic, ambiguous* (standard knowledge, low risk).
- *deadline*: the prison-line story is widely repeated, but Wiktionary says only indirect evidence links it to "due date", so I marked it medium and flagged it. This is a good example of the myth risk in §5.3.
- *condescending*: medium (the "was once polite" claim is supported for early senses, not for a precise date).
- Corrections I made during verification: *deadline* (softened), *borrow* ("to borrow, lend, pledge"), *sonder* (added the German/French inspiration and confirmed 2012).

**Turkish:**
- Verified present in TDK: bagaj, kahvaltı, ödünç almak/vermek, muğlak, belagatli, titiz, hâlsiz, dâhil, anlayışlı, tepeden bakmak, kronikleşmek, hafifletmek, geçici, kısa ömürlü, savsaklamak, fabrika, mağaza, kolej, pansiyon, kasket, smokin, hassas, grip, sempatik, aktüel. TDK spells *dâhil* and *hâlsiz* with a circumflex, which I applied.
- **Not in TDK but widely used:** oltalama, kimlik avı, mutlu tesadüf, petrikor, buzları eritmek. These are normal in real usage; keep them, but a native editor should confirm preference.
- Medium-confidence points: the "pragmatik sounds like çıkarcı" tone note, "psikolojik dayanıklılık/sağlamlık" usage, and the nuance of *buzları eritmek* (Turkish also uses it for easing tension after a conflict, not only at first meetings).
- *eventually/eventüel*: `eventüel` is marginal (not in TDK), so I used *actually/aktüel* (TDK-verified) as the sample false friend and kept *eventually* in the table only as a flagged item.
- All mnemonics (the iftar link, "son derece", "borç", "rezil" idea omitted) are creative and need native-editor approval.

**Capacity numbers:** widget character capacities are design assumptions; test on devices with Dynamic Type and real Turkish strings.

**Market data:** App Store listing claims (word counts, user counts) are unaudited marketing claims; in-app topic lists were not hands-on tested.

**Licensing (brief):** confirm the license of any frequency/CEFR/headword seed list (my search could not confirm NGSL/NAWL terms). Keep all definitions and examples original.

---

### Sources and method
- App data: iTunes Search/Lookup API plus App Store pages (apps.apple.com), screenshots reviewed visually; mwm.ai and vocabulary.monkeytaps.app (Monkey Taps levels, themes, FAQ); tryneologics.com best-vocabulary-apps guide (Magoosh about 1,200 words).
- Turkish exam format: rehberpanda.com (commercial prep site, unverified against ÖSYM), Sakarya University / NTV pages from search; verify with osym.gov.tr.
- Seed list stats: newgeneralservicelist.com, Wikipedia NGSL page, JALT papers (NGSL 2,801 words, NAWL 963 words, license unconfirmed).
- Language checks: TDK Güncel Türkçe Sözlük API (sozluk.gov.tr), en.wiktionary.org (IPA and etymology), wordfreq (frequency), a web search on the origin of *break the ice*.
- Scratchpad files: `sample_dataset_slim.json` (the JSON above), `sample_dataset.json` (full, unslimmed), `validate.js`, `taxo.js`.
