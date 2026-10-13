# ASO PLAN: vocabulary-widget app (US, TR + UK/AU/CA/VN/MX/RU/KZ). Data pulled 2026-10-10

Raw data (every query, cache, page dump, scripts) is in the scratchpad: `C:\Users\yusuf\AppData\Local\Temp\claude\C--Users-yusuf-OneDrive-Desktop-Widget-Vocabulary--learn-words\e927268b-3cbe-437d-b9e4-b39cf6e813db\scratchpad` (`out_*.txt`, `hints_*.txt`, `td_us.jsonl`, `td_tr.jsonl`, `names_out*.txt`, `cache/`). Nothing was written to the project folder.

## 0. Read this first

**Scope note.** The original brief calls "Widget Vocabulary: Learn Words" a competitor. The later coordinator message calls it the "target app". I report its rank everywhere, so both readings are covered. Sections 3 and 4 (new brand name plus metadata) are written for a new, differently branded app. If WV itself is being re-optimized, use the same keyword and metadata logic and see the "WV delta" bullets below.

**Verified facts about WV** (iTunes API, apps.apple.com pages, Apple RSS charts):
- ID 6775767149, by ORBIT STUDIOS TEKNOLOJI LIMITED SIRKETI.
- Released 2026-06-24, version 2.2.5 (updated 2026-09-25), Free, Education only, UI language EN only.
- Subtitle everywhere (US, TR, GB, AU, CA): "Easy & Fast English Learning".
- Its TR page serves English metadata, which is consistent with no Turkish listing localization.
- Ratings per storefront: US 418 (4.7), TR 190 (4.4), MX 39, VN 240, GB 10, CA 13, AU 3.
- Education top-free rank today (Apple RSS, feed timestamp 2026-10-10): **#3 TR, #3 KZ, #3 BY**, #21 VN, #70 MX. It is not in the top 100 for US, RU, UA, ES or BR.
- Its organic keyword ranks are far weaker than its chart rank (see Appendix A). My hypothesis, unverifiable from public data: the chart position comes from paid or non-search traffic.
- WV delta, if it is the app being optimized:
  - Add `tr`, `vi` and a Ukrainian listing; TR is its strongest market and has no localized listing.
  - Use the unused subtitle slots.
  - Add the `en-GB` and `en-AU` listings.

**Key findings**
1. Monkey Taps "Vocabulary - Learn words daily" owns every head term. It has 220k US ratings, 17k UK, 16.8k CA, 10.1k AU and 1.2k TR. Ratings are per storefront, so the same app is about 10 to 100 times weaker in TR, UK, AU, CA, MX, VN and KZ.
2. The "widget" long-tail is the beatable space in the US and UK/AU/CA. Terms like "vocab widget", "flashcard widget", "vocabulary lock screen" and "english words widget" have median top-5 ratings under 500, mostly 0 to 40 ratings. "Vocabulary lock screen" and "vocabulary words widget" are #1 autocomplete suggestions.
3. In TR, "widget" has almost no autocomplete or search demand ("kelime widget" and "ingilizce kelime widget" return no suggestions). Use widget as a conversion hook in screenshots, not as the main keyword. Real TR volume sits in:
   - "ingilizce kelime", "kelime ezberleme" and "kelime öğren" (medium difficulty).
   - "yds kelime", "yökdil kelime" and "günlük kelime" (low difficulty, #1 autocomplete).
4. Several TR vocabulary listings leave the subtitle empty (Kelime Kartları, VocabBuilder, Kelime+, İngilizce Öğren: Kelime Widget). A filled TR subtitle is a cheap edge.
5. Name shortlist, all clean in US, TR, GB, AU, CA, MX, VN and RU app searches: **Wordglance, Lexpeek, Wordwink**. Wordglance and Lexpeek were also unregistered as .com and .app in RDAP.
6. Category: Education primary, Reference secondary (Monkey Taps uses that pair).
7. Cross-locale indexing is vendor-reported only; I could not confirm it empirically (Section 6).

## 1. Keyword research

### 1.1 Method and how to read the tables
- **Ranking source:** iTunes Search API, `https://itunes.apple.com/search?term=<kw>&entity=software&country=<cc>&limit=25` (limit=50 for VN/MX/RU/KZ). Order approximates, but is not identical to, in-app App Store search (no personalization or install velocity).
- **Autocomplete source:** `https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints?clientApplication=Software&term=<kw>` with an `X-Apple-Store-Front` header per storefront (US 143441, TR 143480, GB 143444, AU 143460, CA 143455, VN 143471, MX 143468, RU 143469, KZ 143517). It works and returns different lists per storefront.
- **Rating counts** are per storefront (`userRatingCount`).
- **Difficulty (my heuristic, not Apple data):** based on the median rating count of the top-5 results.
  - Low: below 500.
  - Med: 500 to 9,999.
  - High: 10,000 or more, or the #1 app has 200k or more and the median is 3,000 or more.
  - It is a proxy for incumbents' social proof. It ignores title-match strength, install velocity and API-versus-app ranking differences.
- **Autocomplete column:** `#n` means the exact term is suggestion n when typed. `prefix` means the term itself is not suggested but longer completions exist. `none` means no suggestions at all, a low-volume signal. Hint order is popularity-ordered, not volume. Use Apple Ads "Search Popularity" for real scores.
- **Rel:** H, M or L. This is my relevance judgment for a vocabulary-widget app.
- **WV rank:** where Widget Vocabulary ranks. `>n` means not in the n results returned.
- **App abbreviations:**
  - MonkeyTaps = Vocabulary - Learn words daily.
  - Vocabulous = Word of the Day・Vocabulary.
  - Atlas = Vocabulary Builder by Atlas.
  - Magoosh = Vocabulary Builder by Magoosh.
  - Learning VB = Vocabulary Builder by Learning.
  - WotD:Widget = Word of the Day: Widget.
  - Vocab:LEW = Vocab: Learn English Words.
  - Voca WotD = Word of The Day Widget: Voca.

### 1.2 US (en-US), 86 relevant candidates

| Keyword | Rel | Top-5 ranking (ratings) | WV rank | Difficulty | Autocomplete |
|---|---|---|---|---|---|
| vocabulary | H | MonkeyTaps (220k); Vocabulous (39k); Learning VB (551); Magoosh (7.0k); Elevate (544k) | >23 | High | #2 |
| vocab | H | MonkeyTaps (220k); Vocab:LEW (2.1k); Magoosh (7.0k); Vocabulous (39k); Elevate (544k) | >25 | High | #6 |
| vocabulary builder | H | MonkeyTaps (220k); Magoosh (7.0k); Elevate (544k); WordPal (10k); Atlas (13k) | >24 | High | #1 |
| vocabulary app | H | MonkeyTaps (220k); Vocabulous (39k); Learning VB (551); Magoosh (7.0k); Dictionary.com (328k) | >22 | High | prefix |
| learn words | H | MonkeyTaps (220k); Elevate (544k); Vocab:LEW (2.1k); Vocabulous (39k); WordPal (10k) | >22 | High | #8 |
| learn new words | H | MonkeyTaps (220k); Vocabulous (39k); Elevate (544k); Magoosh (7.0k); Daily Vocab: Learn New (0) | >22 | High | #5 |
| word of the day | H | Vocabulous (39k); MonkeyTaps (220k); WOTD (33); M-Webster (329k); WotD:Widget (1.6k) | >22 | High | #1 |
| word of the day widget | H | MonkeyTaps (220k); WOTD (33); M-Webster (329k); Vocabulous (39k); WotD:Widget (1.6k) | >23 | High | #1 |
| daily words | H | MonkeyTaps (220k); Vocabulous (39k); Daily Words of Wisdom (1.8k); MyVocab (364); WotD:Widget (1.6k) | >21 | Med | #5 |
| widget | M | Widgetsmith (775k); Color Widgets (526k); iScreen (152k); Mico (100k); Widgetable (386k) | >22 | High | prefix |
| vocabulary widget | H | MonkeyTaps (220k); MyVocab (364); Vocabulous (39k); Vocabulary Widget (5); M-Webster (329k) | #12 | High | #2 |
| word widget | H | MonkeyTaps (220k); WOTD (33); WotD:Widget (1.6k); Vocabulous (39k); Word Widget (2) | #9 | Med | #2 |
| home screen widget | M | Color Widgets (526k); Widgetsmith (775k); LockWidget (28k); Widget Custom HomeScreen (2.8k); iScreen (152k) | >24 | High | #1 |
| lock screen widget | M | LockWidget (28k); iScreen (152k); Lock Screen Widgets (113); Lock Screen 27 (7.8k); Widgetsmith (775k) | >23 | High | prefix |
| flashcard widget | H | Flashcard Widget: Study Helper (39); MemorizeWidget (14); Flash Cards Widget (6); Flashcard Widget: MemoPic (1); Very Simple Flashcards (2) | >24 | Low | #1 |
| learn english | M | Learna (430k); Duolingo (5.5M); Learn English US for Beginners (1.3k); EWA (196k); ELSA (114k) | >23 | High | #4 |
| english vocabulary | H | MonkeyTaps (220k); English Vocabulary in Use (187); Dictionary.com (328k); Atlas (13k); English Vocabulary 2000 (269) | >23 | High | #3 |
| english words | H | MonkeyTaps (220k); Learn English w/ flashcards (870); Dictionary.com (328k); Vocabulous (39k); Learn English A1-C1: 2Shine (1.1k) | >23 | High | #5 |
| learn english words | H | MonkeyTaps (220k); Learn English w/ flashcards (870); 10 Minute English (12k); Learn English Words - Louga (3); Vocabulous (39k) | >24 | High | prefix |
| english learning | M | Duolingo (5.5M); Learna (430k); ELSA (114k); EWA (196k); MonkeyTaps (220k) | >22 | High | prefix |
| learn vocabulary | H | MonkeyTaps (220k); WordPal (10k); Magoosh (7.0k); Vocabulous (39k); Dictionary.com (328k) | >23 | High | #1 |
| build vocabulary | H | MonkeyTaps (220k); WordPal (10k); Vocabulous (39k); Magoosh (7.0k); Elevate (544k) | >24 | High | #1 |
| improve vocabulary | H | MonkeyTaps (220k); Elevate (544k); Magoosh (7.0k); Learning VB (551); Vocabulous (39k) | >24 | High | #2 |
| advanced vocabulary | M | MonkeyTaps (220k); Magoosh (7.0k); Oxford (29k); Atlas (13k); WordPal (10k) | >25 | High | #1 |
| vocabulary trainer | M | Vocabulary Trainer (0); WordPal (10k); MonkeyTaps (220k); PONS Vocabulary Trainer (20); Vocabulary Trainer: German (3) | >22 | Low | #1 |
| vocabulary quiz | M | WordPal (10k); Quiz Vocabulary (5); Magoosh (7.0k); Quizzitive (3.2k); MonkeyTaps (220k) | >23 | Med | #1 |
| vocabulary test | M | Magoosh (7.0k); Vocabulary Test (3); IELTS Vocab Flashcards (5.3k); WordPal (10k); MonkeyTaps (220k) | >24 | Med | #1 |
| vocabulary games | M | Quizzitive (3.2k); Elevate (544k); MonkeyTaps (220k); Magoosh (7.0k); WordPal (10k) | >21 | High | #3 |
| vocab words | H | MonkeyTaps (220k); Dictionary.com (328k); Vocab Words (0); Vocabulous (39k); Daily Vocab Words (0) | #16 | High | #1 |
| flashcards | H | Quizlet (1.13M); Flash Cards Flashcards Maker (18k); Amazing Flash Cards (1.3k); Noji (14k); Simply Flashcards (3) | >22 | High | #2 |
| flashcard | M | Quizlet (1.13M); Flash Cards Flashcards Maker (18k); Amazing Flash Cards (1.3k); Noji (14k); Flashcards maker (905) | >23 | High | prefix |
| spaced repetition | M | Spaced Repetition SmartCards+ (2.3k); Space (34); AlgoApp (20k); Mochi (175); Synapse (5) | >25 | Low | #1 |
| memorize words | M | MonkeyTaps (220k); Memorize By Heart (2.4k); Elevate (544k); Memorize Anything Forever (1); MemoCoach (2.6k) | >23 | Med | prefix |
| sat vocabulary | H | SAT Flashcards: Prep & Vocab (1.0k); MonkeyTaps (220k); SAT Word of the Day (309); Magoosh (7.0k); SAT English Vocabulary 2025 (25) | >23 | Med | #1 |
| sat words | M | SAT Word of the Day (309); SAT Flashcards (1.0k); MonkeyTaps (220k); WordPal (10k); SAT Vocabulary Words Quiz Prep (53) | >22 | Med | #1 |
| sat prep | M | SAT Prep 2026 Smartschool (1.4k); Brainblast (570); Khan Academy (112k); SAT Practice,Prep,Flashcards (1.8k); OnePrep (641) | >23 | Med | #3 |
| gre vocabulary | H | GRE Vocab Flashcards (11k); Magoosh (7.0k); GRE Prep by Magoosh (11k); GRE GMAT Vocab Flashcards (0); GRE Vocabulary Cartoons (540) | >22 | Med | #3 |
| gre words | M | GRE Vocab Flashcards (11k); Magoosh (7.0k); GRE Vocabulary Flashcards Prep (254); GRE WordsApp (0); GRE Words Flashcards 2026 (0) | >21 | Low | #1 |
| gre prep | M | GRE Prep by Magoosh (11k); GRE Vocab Flashcards (11k); GRE Test Prep 2026 (55); GMAT Math Flashcards (1.6k); GRE Prep 2026 (95) | >22 | Med | #1 |
| ielts | M | IELTS: Speaking & Listening (536); IELTS Exam Preparation & Tutor (1.4k); IELTS Vocab Flashcards (5.3k); IELTS Prep App (710); EnglishScore (3.1k) | >25 | Med | #8 |
| ielts vocabulary | H | IELTS Vocab Flashcards (5.3k); 6000 IELTS Academic Vocab (24); IELTS Vocabulary practice (86); IELTS Vocabulary PRO (1); Voca: IELTS Vocabulary 2026 (6) | >25 | Low | #1 |
| ielts prep | M | IELTS Prep App (710); IELTS Prep App – Practice (64); IELTS Exam Prep & Tutor (1.4k); IELTS Vocab Flashcards (5.3k); IELTS Prep App - Exam Writing (602) | >23 | Med | prefix |
| toefl | M | TOEFL Prep & Practice (3.2k); TOEFL Flashcards (4.1k); TOEFL Practice Test 2026 (60); Practice for TOEFL Test Pro (138); 6000 TOEFL Vocabulary (20) | >24 | Low | #6 |
| toefl vocabulary | H | TOEFL Flashcards (4.1k); 6000 TOEFL Vocabulary (20); Toefl Vocabulary Quizzes (114); Magoosh (7.0k); TOEFL Prep & Practice (3.2k) | >21 | Med | #1 |
| toeic | M | English Test - TOEIC (8); Listening for the TOEIC (96); Reading for the TOEIC (92); Learn English Vocabulary TOEIC (1.9k); Santa (130) | >22 | Low | #3 |
| business english | M | Business English by BEP (273); Business English Conversations (11); ELSA (114k); Business English: Learn & Read (16); Business English: Learn Words (4) | >22 | Low | #4 |
| english for work | M | English Words for Work, Office (0); 10 Minute English (12k); LingoSwipe (0); Open English (10k); English for Work & Life (0) | >23 | Low | prefix |
| english grammar | M | English Grammar in Use & Test (349); LearnEnglish Grammar UK (40k); English Grammar Practice (19); English Grammar - Book (459); English Grammar Test Game (1.2k) | >25 | Low | #6 |
| word learning | M | MonkeyTaps (220k); Vocabulous (39k); Elevate (544k); WordPal (10k); Word Vault (4) | >23 | High | #2 |
| new words | H | MonkeyTaps (220k); Vocabulous (39k); M-Webster (329k); Word of the Day: Daily new word (0); MyVocab (364) | >24 | High | #5 |
| daily vocabulary | H | MonkeyTaps (220k); Vocabulous (39k); Daily Vocab (0); Dictionary.com (328k); Voca WotD (304) | >22 | High | #3 |
| word a day | H | MonkeyTaps (220k); Vocabulous (39k); M-Webster (329k); WOTD (33); WotD:Widget (1.6k) | >24 | High | #10 |
| idioms | M | Idioms and Slang Dictionary (1.1k); English Idioms (0); English Idioms and Slangs (37); English Idioms Cards (920); English language: Learn & Play (7.6k) | >23 | Med | #2 |
| phrasal verbs | M | English Phrasal Verbs in Use (1.2k); Phrasal Verbs: Visual Learner (18); English Phrasal Verbs Cards (1.1k); Phrasal Verbs in Action (15); English Phrasal Verb (19) | >25 | Low | #2 |
| english idioms | M | Idioms and Phrases for English (0); English Idioms and Slangs (37); English Idioms Cards (920); English Idioms (0); English Idioms Daily (4) | >23 | Low | #2 |
| word roots | M | Prefix, Suffix & Root Words (32); WordBranch (5); EtymologyExplorer (1.6k); Etymonline (12k); Stem Cards (29) | >24 | Low | prefix |
| vocabulary lock screen | H | MonkeyTaps (220k); MyVocab (364); Learning VB (551); Vocabulary Daily Words (122); Lock Learn (3) | >24 | Low | #1 |
| lock screen vocabulary | H | MonkeyTaps (220k); MyVocab (364); Learning VB (551); Vocabulary: Learn words (0); LockScreenNotes (1.6k) | >22 | Med | prefix |
| vocabulary words widget | H | MonkeyTaps (220k); M-Webster (329k); Atlas (13k); **WidgetVocab** (418); Vocabulary builder: Voca (2.0k) | #4 | High | #1 |
| daily vocabulary widget | H | MonkeyTaps (220k); M-Webster (329k); WOTD (33); Vocabulous (39k); Vocabulary Widget (5) | #7 | High | #2 |
| word of the day lock screen | H | MonkeyTaps (220k); WOTD (33); Daily Bible Verse Widget (5.5k); Spell Grid (3.8k); PopWords! (5.6k) | >19 | High | #1 |
| vocab widget | H | MonkeyTaps (220k); Vocab Widget (0); Vocab Widget - Learn New (1); MyVocab (364); Vocabulous (39k) | #10 | Low | #1 |
| learn words widget | H | **WidgetVocab** (418); WotD:Widget (1.6k); Atlas (13k); WRD (2.8k); WidgetWord (1) | #1 | Med | none |
| english words widget | H | **WidgetVocab** (418); Atlas (13k); Wordet (2); Wrd – Word of the Day Widget (5); Vocabulary Widget (5) | #1 | Low | prefix |
| widget flashcards | M | Tapioca (0); AnkiMobile (2.4k); Flashcard Widget: Study Helper (39); Flashcard Widget: MemoPic (1); MemorizeWidget (14) | >23 | Low | prefix |
| flashcards widget | H | Flashcard Widget: Study Helper (39); MemorizeWidget (14); Flash Cards Widget (6); Very Simple Flashcards (2); Moca (41) | >24 | Low | prefix |
| vocabulary flashcards | H | IELTS Vocab Flashcards (5.3k); MonkeyTaps (220k); Flashcards Vocabulary (1); deft (16); GRE Vocab Flashcards (11k) | >22 | Med | #1 |
| english flashcards | M | Flash Cards App Learn English (3.0k); MonkeyTaps (220k); English Flashcards + (314); Atlas (13k); Quizlet (1.13M) | >22 | High | #1 |
| ielts words | M | IELTS WORDS (0); IELTS Vocab Flashcards (5.3k); 6000 IELTS Academic Vocab (24); WordUp (14k); English Collocations (280) | >19 | Low | #2 |
| toefl words | M | TOEFL Flashcards (4.1k); Toefl Vocabulary Quizzes (114); TOEFL Words & Practice (0); English Words for TOEFL (1); Atlas (13k) | #11 | Low | prefix |
| ielts flashcards | M | IELTS Vocab Flashcards (5.3k); IELTS Exam Prep & Tutor (1.4k); IELTS Flashcards, Vocabulary (0); 6000 IELTS Academic Vocab (24); IELTS Vocabulary - Flashcards (0) | >22 | Low | prefix |
| gre flashcards | M | GRE Vocab Flashcards (11k); GRE Prep by Magoosh (11k); GMAT Math Flashcards (1.6k); GRE Vocabulary Flashcards (254); Manhattan Prep GRE (1.7k) | >18 | Med | #1 |
| sat flashcards | M | SAT Flashcards: Prep & Vocab (1.0k); SAT Flashcards! (10); SAT Flashcards Lite (1); SAT Practice,Prep,Flashcards (1.8k); SAT Prep by Magoosh (1.1k) | >20 | Med | #2 |
| vocabulary for ielts | M | IELTS Vocab Flashcards (5.3k); Voca: IELTS Vocabulary 2026 (6); IELTS Vocabulary practice (86); IELTS Exam Prep (1.4k); 6000 IELTS Academic Vocab (24) | >24 | Low | prefix |
| english vocabulary builder | M | Vocabulous (39k); MonkeyTaps (220k); WordPal (10k); WordUp (14k); Magoosh (7.0k) | >23 | High | #2 |
| advanced english words | M | Daily: Advanced English Words (0); Learn Advanced English Words (1); WordPal (10k); Advanced English Dictionary (241); Oxford (29k) | >24 | Low | prefix |
| word of the day english | M | Vocabulous (39k); Word of the Day - Learn English (1.2k); WotD:Widget (1.6k); Dictionary.com (328k); Word of the day – Quiz Games (646) | >24 | Med | none |
| learn a new word every day | M | WotD:Widget (1.6k); Vocabulous (39k); Atlas (13k); WordPal (10k); MyVocab (364) | >24 | High | none |
| new word every day | H | MonkeyTaps (220k); WOTD (33); Vocabulous (39k); WotD:Widget (1.6k); Glyph (0) | >24 | Med | prefix |
| vocabulary daily words | H | MonkeyTaps (220k); Vocabulous (39k); Voca WotD (304); Vocabulary Daily Words (122); Magoosh (7.0k) | >23 | High | #3 |
| daily vocab | H | MonkeyTaps (220k); Daily Vocab (0); Vocabulous (39k); Daily Vocab (0); Daily Vocab: Learn New Words (0) | >24 | Low | #6 |
| vocab daily | M | MonkeyTaps (220k); Daily Vocab (0); Vocabulous (39k); Magoosh (7.0k); Vocab - Word of the Day (377) | >24 | High | prefix |
| english vocab | M | Vocabulous (39k); MonkeyTaps (220k); QuickVocab (1); Atlas (13k); WordPal (10k) | >24 | High | #5 |
| english vocab words | M | Dictionary.com (328k); Vocab:LEW (2.1k); WordPal (10k); WordUp (14k); Vocabulary builder: Voca (2.0k) | #12 | High | none |
| words widget | H | MonkeyTaps (220k); Vocab Widget (0); MyVocab (364); WotD:Widget (1.6k); WOTD (33) | #7 | Low | prefix |
| learn english widget | H | **WidgetVocab** (418); Atlas (13k); 10 Minute English (12k); WotD:Widget (1.6k); Lola Speak (15k) | #1 | High | none |

Low-relevance rows, kept for the record. All are High difficulty except where noted, and the intent is games, dictionary or generic study:
- Games and puzzles: words, word game, word puzzle, wordle, word finder, brain training (Elevate and Impulse own it).
- Dictionary and reference: dictionary, english dictionary, thesaurus, synonyms (Med), antonyms (Low), etymology (Med), definition, word meaning, word power (Low).
- Generic learning: learn languages, language learning, study.
- Other: vocabulary for kids (Med), learn spanish words, esl (bank results), vocabulary 2026 (Low), act vocabulary (Low), gmat vocabulary (Med), dictionary widget, quiz widget, study widget, language learning widget.
- Do not target any of them.

**Autocomplete evidence, US widget intent** (hint lists):
- "vocabulary" suggests "vocabulary daily word(s)".
- "vocab" suggests "vocabulary daily words", "vocab games".
- "word of the day" suggests "word of the day widget", "...lock screen", "...free".
- "daily vocab" suggests "daily vocabulary widget", "daily vocab widget", "daily vocab word".
- "vocabulary daily words" suggests "...free lock screen", "...lockscreen", "...widget free", "...widget".
- "learn words" suggests "learn words daily".

### 1.3 TR (tr), 83 relevant candidates

| Keyword | Rel | Top-5 ranking (ratings) | WV rank | Difficulty | Autocomplete |
|---|---|---|---|---|---|
| kelime öğren | H | Kolay Ing.Kelime (37k); Blarma (5.0k); Eng Words Trainer (5.3k); Quizlet (29k); Pingua (37) | >23 | Med | #2 |
| kelime öğrenme | H | Quizlet (29k); Duolingo (492k); Blarma (5.0k); Eng Words Trainer (5.3k); Kolay Ing.Kelime (37k) | >25 | High | #2 |
| ingilizce kelime | H | Kolay Ing.Kelime (37k); Eng Words Trainer (5.3k); Ing.Kelime Kartlari (1.3k); Atlas (8.6k); MomoLingo (29k) | >22 | Med | #8 |
| ingilizce kelime öğren | H | Kolay Ing.Kelime (37k); Eng Words Trainer (5.3k); 6000 Words (439); YDS-YÖKDİL Kelime Robotu (3); Atlas (8.6k) | >24 | Med | prefix |
| ingilizce kelime ezberle | H | Eng Words Trainer (5.3k); Kolay Ing.Kelime (37k); İngilizce Kelime Ezberle (7); WordUp (3.6k); LetMeSpeak (14k) | >23 | Med | prefix |
| kelime ezberle | H | Memorize Words - English (3); Kolay Ing.Kelime (37k); VocabBuilder (818); Ing.Kelime Kartlari (1.3k); Flashwords (2.1k) | >24 | Med | #3 |
| kelime ezberleme | H | Quizlet (29k); Kolay Ing.Kelime (37k); Membra (8); Ing.Kelime Kartlari (1.3k); VocabBuilder (818) | >24 | Med | #2 |
| kelime ezber | H | Flaş İngilizce: Kelime Ezberle (45); Ing.Kelime Kartlari (1.3k); Kelime Ezberi: YDS & YÖKDİL (14); Flashwords (2.1k); Mehmet Hoca YDS (3) | >24 | Low | #3 |
| kelime widget | H | Lingo Widget (17); Wrd (5); Atlas (8.6k); Word Widget (6); İngilizce Öğren: Kelime Widget (1) | #6 | Low | prefix |
| kelime ezberleme uygulaması | M | YDS Koçu (3); Flaş İngilizce (45); Molly (24); VibeLing (4); Mindomax (0) | >15 | Low | none |
| widget | M | Widgetsmith (19k); Color Widgets (7.4k); iScreen (4.5k); Widgetable (20k); Themify (3.8k) | >23 | Med | prefix |
| ingilizce widget | H | Word Widget (6); **WidgetVocab** (190); İngilizce Öğren: Kelime Widget (1); Hapax (0); Wordlet (12) | #2 | Low | none |
| ingilizce kelime widget | H | Hapax (0); Word Widget (6); İngilizce Öğren: Kelime Widget (1); Wrd (5); Atlas (8.6k) | #6 | Low | none |
| günün kelimesi | H | Günün Kelimesi (8); Günlük Kelime (0); Lügat. (89); Words: Word of the day (32); Word of the day (1) | >24 | Low | #1 |
| günlük kelime | H | Günlük Kelime (0); Daily Word Guess, Harfçi (483); Ing.Kelime Kartlari (1.3k); WordUp (3.6k); Learn Daily English Words (12) | >25 | Low | #1 |
| ingilizce günlük kelime | H | Vocabulous (356); Flashwords (2.1k); Simpler (15k); WordUp (3.6k); Günlük Kelime: A1 İngilizce (1) | >25 | Med | none |
| kelime kartları | H | Quizlet (29k); Ing.Kelime Kartlari (1.3k); Associate Words (677); Atlas (8.6k); Flashcards: Revise & Recall (0) | >25 | Med | #1 |
| kelime kartı | H | Flashcards maker (353); Quizlet (29k); Ing.Kelime Kartlari (1.3k); YDS YÖKDİL Kelime Kartları (2); YDS TOEFL Kelime Kartları (317) | >25 | Low | #3 |
| ingilizce kelime kartları | H | Ing.Kelime Kartlari (1.3k); İngilizce Kelime Kartlarım (5); Flashwords (2.1k); Quizlet (29k); LetMeSpeak (14k) | >23 | Med | #1 |
| flashcard | M | Flashcards maker (353); Quizlet (29k); Flashcards World (65); Flashcards Maker (10); Flashcards - Learn Chinese (0) | >24 | Low | prefix |
| ingilizce | M | Duolingo (492k); Voscreen (2.1k); Busuu (88k); Eng Words Trainer (5.3k); PORO (168) | >23 | High | #10 |
| ingilizce öğren | M | Simpler (15k); Duolingo (492k); Kolay Ing.Kelime (37k); Busuu (88k); Talko (3) | >25 | High | prefix |
| ingilizce öğrenme | M | Duolingo (492k); Kolay Ing.Kelime (37k); Learna (34k); Busuu (88k); Learn English A1-C1 (1.2k) | >23 | High | #1 |
| ingilizce öğrenme uygulaması | M | MomoLingo (29k); Duolingo (492k); Falou (22k); English Verbs (7); Savgo (4) | >22 | High | none |
| ingilizce kelimeler | H | Eng Words Trainer (5.3k); Ing.Kelime Kartlari (1.3k); 6000 Words (439); Kolay Ing.Kelime (37k); Atlas (8.6k) | >24 | Med | #6 |
| ingilizce kelime test | M | Ing.Kelime Kartlari (1.3k); Spanish German English Turkish Language Set (38); Hello7 (4.2k); Learn English with TV Series (179); İngilizce Kelime Yarışması (137) | >24 | Low | prefix |
| ingilizce quiz | M | Quiz English-Turkish (15); Duolingo (492k); İngilizce öğren - Cümle Kur (1.7k); Atlas (8.6k); Learn English Vocabulary Pop Quiz (733) | >25 | Med | #1 |
| yds | H | Kelime+ YDS (1.6k); YDS Pro (18); MODADİL YDS KELİMELERİ (23); YDS - Yapı Denetim Sistemi (44, irrelevant); ydsCepte (1.9k) | >24 | Low | #2 |
| yds kelime | H | Kelime+ YDS (1.6k); MODADİL YDS KELİMELERİ (23); YDS 5000 Kelime (18); ydsCepte (1.9k); YDS TOEFL Kelime Kartları (317) | >23 | Low | #1 |
| yds kelime ezberleme | H | YDS - YÖKDİL Kelime Ezberleme (35); Kolay Ing.Kelime (37k); YDS Koçu (3); ydsCepte (1.9k); Wordana (10) | >24 | Low | none |
| yökdil | H | Kelime+ YDS (1.6k); MODADİL YÖKDİL SAĞLIK (73); MODADİL YÖKDİL SOSYAL (5); Reading Power (2.1k); YDS Pro (18) | >25 | Low | #5 |
| yökdil kelime | H | Kelime+ YDS (1.6k); YDS - YÖKDİL Kelime Ezberleme (35); MODADİL YÖKDİL SOSYAL (5); MODADİL YÖKDİL SAĞLIK (73); Atlas (8.6k) | >25 | Low | #1 |
| yds yökdil | H | YDS YÖKDİL Sınav Hazırlık (46); Kelime+ YDS (1.6k); YDS Pro (18); YDS YÖKDİL YDT Altın Kurallar (12); RhKitap (2) | >25 | Low | #3 |
| yks ingilizce | M | Learn English A1-C1: 2Shine (1.2k); Doping Hafıza (16k); POV (3); Shadowing English (9); Eng Words Trainer (5.3k) | >25 | Med | none |
| lgs ingilizce | M | LGS İngilizce Kelime (4); Lgs İngilizce (1); Jasmin Academy (89); Lafazan (1); WORD and USE (14) | >25 | Low | #2 |
| ielts | M | IELTS Practice Band 9 (91); IELTS Vocab Flashcards (1.1k); IELTS by IDP (21); 6000 IELTS Academic Vocab (16); IELTS Prep: English Band 9 (170) | >25 | Low | #4 |
| toefl | M | TOEFL Prep & Practice (330); TOEFL Flashcards (1.2k); TOEFL Practice Test 2026 (13); Practice for TOEFL Test Pro (28); TOEFL Practice Test + (17) | >22 | Low | #3 |
| ingilizce deyimler | M | İngilizce Deyimler Öğren (3); EnglishCentral (14k); Praktika (53k); English language: Learn & Play (945); Buddy.ai (80k) | >25 | High | prefix |
| phrasal verbs | M | English Phrasal Verbs in Use (672); Phrasal Verbs in Action (1); Phrasal Verbs: English Grammar (4); Visual Learner (5); Learn English Phrasal Verbs (4) | >24 | Low | prefix |
| en çok kullanılan ingilizce kelimeler | M | Vocaby (11); İngilizce Kelimeler 3500 (0); 3000 İngilizce Kelime Ezberle (1); Oxford 5000 (65); WordMax (2) | >10 | Low | none |
| vocabulary | H | MonkeyTaps (1.2k); Atlas (8.6k); TOEFL Flashcards (1.2k); Blarma (5.0k); Vocabulary.com (289) | #9 | Med | #2 |
| vocab | H | MonkeyTaps (1.2k); VocabBuilder (818); Vocab - Workplace English (47); VocabNote (0); Atlas (8.6k) | >24 | Med | #5 |
| vocabulary builder | M | Magoosh (239); Atlas (8.6k); WordUp (3.6k); MonkeyTaps (1.2k); Vocabulary Builder – English (0) | >23 | Med | #2 |
| learn words | H | MonkeyTaps (1.2k); Atlas (8.6k); WRD (1.4k); A1-C1: Learn words in context (0); Flashwords (2.1k) | #18 | Med | #1 |
| word of the day | H | Vocabulous (356); WotD:Widget (22); MonkeyTaps (1.2k); Atlas (8.6k); WidgetWord (0) | >20 | Low | #1 |
| english words | M | Eng Words Trainer (5.3k); MonkeyTaps (1.2k); Atlas (8.6k); Learn English A1-C1 (1.2k); Learn English w/ flashcards (545) | >25 | Med | #1 |
| learn english | M | Learna (34k); LearnEnglish Podcast (4.1k); Duolingo (492k); LearnEnglish Grammar UK (8.1k); Learn English A1-C1 (1.2k) | >24 | Med | #6 |
| kelime hafızası | M | Kelime Gezmece (88k, game); Kelime Kancası İngilizce Ezber (5); Word Weaver (59); parolla (30); Flaş İngilizce (45) | >24 | Low | none |
| aralıklı tekrar | M | Tekrar – Flashcards (0); Memoki (0); AccelaStudy (5); Leitner Box (9); MiiWords (0) | >23 | Low | none |
| ingilizce kelime ezberleme | H | Kolay Ing.Kelime (37k); Ing.Kelime Kartlari (1.3k); İngilizce 3000 Kelime Öğren (6); Eng Words Trainer (5.3k); Quizlet (29k) | >23 | Med | #1 |
| ingilizce kelime ezberleme uygulaması | M | Flaş İngilizce (45); Molly (24); VibeLing (4); Shock Dictionary (3); Card ai (0) | >7 | Low | none |
| iş ingilizcesi | M | PeakTalk (247); Business English: Learn Words (5); Vocab - Workplace English (47); LetMeSpeak (14k); Cambly (16k) | >25 | Low | none |
| akademik ingilizce | M | İngilizce 3000 Kelime Öğren (6); Academic English (0); Akademik İngilizce YDS/YÖKDİL (1); English Reading and Listening (160); Duolingo (492k) | >25 | Low | #1 |
| kelime ezberle widget | H | Word Widget (6); Wrd (5); İngilizce Öğren: Kelime Widget (1); Hapax (0); Zarafa (0) | >20 | Low | none |
| kelime defteri | H | Tureng Vocabulary Notebook (438); Word Notebook (20); Quizlet (29k); Kelime Defteri (5); Kiki (1) | >22 | Low | #4 |
| ingilizce kelime defteri | H | Learn Languages: Vocabulary (0); Tureng Vocabulary Notebook (438); Kolay Ing.Kelime (37k); Word Notebook (20); Reading Power (2.1k) | >22 | Low | #1 |
| kelime ezber defteri | M | WordUp (3.6k); Word Notebook (20); Wordrop (3); Kiki (1); Learn Languages: Vocabulary (0) | >20 | Low | none |
| ingilizce ezber | M | Kolay Ing.Kelime (37k); Fable Words (6); Kelime Kancası (5); Vocappulary (6); VocabBuilder (818) | >22 | Low | prefix |
| ingilizce kelime yds | M | Kolay Ing.Kelime (37k); VocabBuilder (818); Wordana (10); LexiPro (9); Atlas (8.6k) | >23 | Med | prefix |
| kilit ekranı kelime | H | Lingo Widget (17); Loro (0); Vocab Builder: Live Word (2); LockWords: Lock Screen Widgets (0); Zarafa (0) | >18 | Low | none |
| günün sözü | M | Positive - Quotes (3.3k); Book Quotes (19k); Günün Sözü (3); ÖzlüSÖZ (32); Günün Sözü (9) | >23 | Low | #1 |
| ingilizce a1 | M | Learn English A1-C1 (1.2k); Duolingo (492k); Eng Words Trainer (5.3k); Simpler (15k); LearnEnglish Grammar (8.1k) | >24 | Med | none |
| ingilizce b1 | M | EnglishCentral (14k); Praktika (53k); Learn English A1-C1 (1.2k); Buddy.ai (80k); Nerola (6) | >25 | High | prefix |
| ingilizce b2 | M | EnglishCentral (14k); Buddy.ai (80k); Praktika (53k); Learn English A1-C1 (1.2k); Nerola (6) | >25 | High | none |
| ingilizce kelime hazinesi | M | Turkish Vocabulary Trainer (1.5k); ABA English (3.4k); PORO (32); Words: Word of the day (32); 5000 English Words (0) | >21 | Low | none |
| kelime öğrenme widget | M | Zarafa (0); İngilizce Öğren: Kelime Widget (1); Wrd (5); Atlas (8.6k); Word Widget (6) | >17 | Low | none |
| kelime ezberleme widget | M | Word Widget (6); İngilizce Öğren: Kelime Widget (1); Wrd (5); Hapax (0); Zarafa (0) | >12 | Low | none |
| kelime ezber yds | M | Kelime Ezberi: YDS & YÖKDİL (14); Vocamap (4); Fable Words (6); YDS Arapça Kelime (1); Reading Power (2.1k) | >24 | Low | none |
| ingilizce yds | M | Kelime+ YDS (1.6k); YDS 5000 Kelime (18); YDS Pro (18); Fable Words (6); Reading Power (2.1k) | >25 | Low | prefix |
| yds ezber | M | ydsCepte (1.9k); Vocably (24); Vocamap (4); Kelime Ezberi (14); Reading Power (2.1k) | >24 | Low | none |
| yökdil ezber | M | Vocably (24); Vocamap (4); Kelime Ezberi (14); Reading Power (2.1k); VocabBuilder (818) | >23 | Low | none |
| tyt ingilizce | M | YKS TYT YDT 2026 (0); Doping Hafıza (16k); TATS Dijital Kitap (28); Yds Yökdil İngilizce Kelime (62); İngilizce kelimeler öğren (21) | >22 | Low | none |
| ayt ingilizce | M | TATS Dijital Kitap (28); Yds Yökdil İngilizce Kelime (62); İngilizce kelimeler öğren (21); YKS TYT AYT LGS KPSS (402); İngilizce Yds Kelimeler (3) | >23 | Low | none |
| ingilizce hazırlık | M | Kelime+ YDS (1.6k); Atlas (8.6k); EnglishCentral (14k); Lexipal (63); Kolay Ing.Kelime (37k) | >25 | Med | none |
| ingilizce kelime anlamları | M | Word Widget (6); Lügat: İngilizce (32); VocabNote (0); Newlings (1); Vocabulary Synonyms & Antonyms (3) | >24 | Low | none |
| widget kelime | H | Word Widget (6); İngilizce Öğren: Kelime Widget (1); Lingo Widget (17); **WidgetVocab** (190); Wrd (5) | #4 | Low | none |
| kelime kartı yds | M | YDS TOEFL Kelime Kartları (317); Lexi: YDS Vocabulary Builder (6); Wordana (10); Ing.Kelime Kartlari (1.3k); YDS - YÖKDİL Kelime Soruları (1) | >25 | Low | none |
| ingilizce öğren widget | H | Zarafa (0); İngilizce Öğren: Kelime Widget (1); Atlas (8.6k); **WidgetVocab** (190); WRD (1.4k) | #4 | Low | none |
| ingilizce kelime öğrenme uygulaması | M | MomoLingo (29k); Falou (22k); Duolingo (492k); Flaş İngilizce (45); Jumpspeak (77) | >22 | High | none |
| IELTS kelime | M | Atlas (8.6k); IELTS Words & Practice (0); IELTS Vocabulary 2026 (1); English Radio (756); FlashVocab (6) | #22 | Low | #1 |
| toefl kelime | M | YDS TOEFL Kelime Kartları (317); YDS Toefl 2026 (5); English Radio (756); Mubex 2026 TOEFL Kelime Ezber (0); Atlas (8.6k) | #23 | Low | prefix |
| ingilizce kelime ezberleme programı | M | Eng Words Trainer (5.3k); LetMeSpeak (14k); Learn English w/ flashcards (545); vocabulary animals (0); ABC alphabet flash cards (0) | >19 | Med | none |
| ingilizce telaffuz kelime | M | Flashwords (2.1k); Wordismo (1.7k); Learna (34k); ABA English (3.4k); Dictionary & Translator (11k) | >25 | Med | none |

Low-relevance TR terms (not targeted):
- Word-game intent: kelime, kelime oyunu, kelime avı, kelime bulmaca, sözcük (Kelimelik, Kelime Gezmece and similar own it).
- Dictionary and translation: sözlük, ingilizce sözlük, ingilizce türkçe sözlük (Tureng and Sesli Sözlük), ingilizce türkçe, ingilizce çeviri (Google Translate).
- Other: kpds, üds (unrelated apps), ales, ingilizce fiiller, ingilizce konuşma, ingilizce telaffuz, dil öğren, dil öğrenme, yabancı dil (Duolingo and Busuu).
- Not directly relevant: kelime hazinesi, kelime bilgisi, almanca kelime, kilit ekranı widget and ekran widget (theme apps).

**Diacritics.** TR search is only partly diacritic-insensitive in the API. "yökdil" versus "yokdil" gave 14 of 15 overlapping results, "günlük kelime" versus "gunluk kelime" 13 of 15, and "ingilizce kelime öğren" versus "ingilizce kelime ogren" only 8 of 14. Use proper Turkish characters in the title and subtitle. Treat folding in the keyword field as unproven.

### 1.4 UK / AU / CA notes (core terms, limit=25)
- **Ratings are much lower there**, so ranking is easier (rating counts below are from the same API runs):

| | MonkeyTaps ratings | Vocabulous ratings | Education chart rank of MonkeyTaps |
|---|---|---|---|
| US | 220k | 39k | #26 |
| GB | 17k | 3.8k | #40 |
| CA | 16.8k | 2.5k | #15 |
| AU | 10.1k | 1.6k | #10 |
| TR | 1.2k | 356 | not in top 100 |

- **Widget terms are nearly empty.** For "vocabulary widget", the GB top 5 is MonkeyTaps, then Vocabulary Widget (0), MyVocab (42), Voca (13) and mug (16). The AU and CA lists look similar. Rated Low to Med in all three storefronts.
- **Exam terms:**
  - "ielts vocabulary": top app is Vocabulary Flashcards - IELTS with 678 ratings in GB, 689 in AU and 1,156 in CA. Everything else has fewer than 100.
  - "sat vocabulary": GB and AU top results have 0 to 5 ratings.
  - "gre vocabulary": top app has 291 (GB), 114 (AU) or 462 (CA) ratings.
- **Autocomplete in GB, AU and CA** for "vocabulary" includes "vocabulary widget" and, in AU and CA, "vocabulary lock screen". That is stronger widget intent than the US list.
- **WV there:** #1 only for its own brand query "widget vocabulary" (10, 3 and 13 ratings). WV ranks for none of the generic terms.
- **Competitors localize English per storefront** (exact titles and subtitles from app pages):
  - MonkeyTaps: US "Word of the day widget & games"; GB, AU, CA and TR "Write & speak more confidently".
  - Vocabulous: US subtitle "English Vocab Builder & Games"; GB, AU and TR "English Vocab Builder App"; CA title "Word of the Day・English Vocab" with subtitle "New Vocabulary Builder & Games".
  - Atlas: US "Daily Word of the Day Widget"; GB and TR "Word of the Day, Flashcards"; **AU "Flash cards: IELTS Prep"**; CA "Learn New English Words".
  - Reading: separate `en-GB`, `en-AU` and `en-CA` listings are standard practice. AU is IELTS-oriented.

### 1.5 Added markets, per coordinator request (limit=50; WV rank included)

**Vietnam (vn)**

| Keyword | Top-5 (ratings) | WV rank | Difficulty | Autocomplete |
|---|---|---|---|---|
| từ vựng | Luyện Từ (241); Learn English Vocabulary App (39.6k); Quizlet (99.6k); 3000 Từ Tiếng Anh (2); Dịch Tiếng Anh KALA (155k) | >48 | High | #7 |
| học từ vựng | Learn English Vocabulary App (39.6k); Quizlet (99.6k); MochiVocab (45k); Luyện Từ (241); Bloom (2.4k) | >44 | High | #5 |
| từ vựng tiếng anh | Learn English Vocabulary App (39.6k); eVocabulary (3.5k); Tiếng Anh Giao Tiếp Thông Dụng (105); KALA (155k); Bloom (2.4k) | >44 | Med | #2 |
| học tiếng anh mỗi ngày | Học Tiếng Anh Cơ Bản (10.3k); Duno (924); Baby Shark English (9); Duolingo (768k); 4English (111k) | >48 | High | #1 |
| từ vựng ielts | Voca: IELTS Vocabulary 2026 (312); 6000 IELTS Academic Vocabulary (29); Learn English Vocabulary App (39.6k); 4English (111k); IELTS song ngữ (1.7k) | >47 | Med | #2 |
| từ vựng toeic | Voca: TOEIC Vocabulary 2026 (645); Learn English Vocabulary App (39.6k); eVocabulary (3.5k); IIG Elearning (94); 600 Từ Vựng TOEIC (188) | >48 | Med | #1 |
| flashcard | Quizlet (99.6k); Memko (137); Flips (13); Flashcards maker (1.0k); Flashcards World (625) | >48 | Med | #4 |
| widget | iScreen (61k); Widgy (1.0k); Widgetsmith (56k); Color Widgets (29k); Widgetable (23k) | #20 | High | #4 |
| vocab | Vocab - Workplace English (25); MonkeyTaps (3.4k); MochiVocab (45k); 4English (111k); Quizlet (99.6k) | #40 | High | #4 |
| word of the day | Vocabulous (465); MonkeyTaps (3.4k); WotD:Widget (23); Hapax (1); DailyLingo (0) | >43 | Low | #2 |
| learn words | **WidgetVocab (240)**; 6000 Words Learn English (595); 6000 Words Chinese (86); 6000 Words Korean (157); MonkeyTaps | **#1** | Low | prefix |

- Autocomplete leaders: "từ vựng tiếng anh", "từ vựng ielts", "từ vựng toeic", "học từ vựng tiếng anh miễn phí", "...theo chủ đề".
- The "widget" autocomplete there is theme-oriented ("widget đẹp").
- Education chart: WV #21; other vocabulary apps are Learn English Words - 4English (#43), MochiVocab (#65) and MyWords (#99).

**Mexico (mx, es-MX)**

| Keyword | Top-5 (ratings) | WV rank | Difficulty | Autocomplete |
|---|---|---|---|---|
| vocabulario inglés | Wlingua (8.1k); Vocabulario inglés (7); MonkeyTaps ES "Vocabulary - Aprende inglés" (4.1k); Tobo (9); EWA (54k) | #39 | Med | #2 |
| palabras en inglés | 3000 palabras (391); Vocabulary - Aprende inglés (4.1k); Duolingo (736k); MomoLingo (15k); Aprender Ingles principiantes (153) | >48 | Med | prefix |
| aprender palabras | Vocabulary - Aprende inglés (4.1k); WRD (251); Langova (0); Aprender Palabras Ingles App (0); Wordspot (0) | >48 | Low | #2 |
| palabra del día | Palabra del dia—Frases Español (1.5k); Vocabulary - Aprende inglés (4.1k); Wordling (125); Palora (3.5k); Palabra del Día Widget (5) | >47 | Med | #5 |
| inglés fácil | Inglés Fácil - Francisco Ochoa (842); Duolingo (736k); ELSA (33k); Inglés Fácil (0); Menura (322) | >47 | Med | #1 |
| aprender inglés rápido | Simpler (3.6k); Wlingua (8.1k); Aprende inglés rápido en 3d (117); Curso De Inglês (4); BNR (274) | #20 | Low | prefix |
| flashcards | Flashka (1.2k); Quizlet (18.8k); Flashcards World (407); Noji (1.9k); Vaia (1.6k) | >47 | Med | #1 |
| widget inglés | **WidgetVocab (39)**; Vocabulary - Aprende inglés (4.1k); Word Widget: Inglés Diario (0); Duolingo (736k); Parla English (413) | **#1** | Low | prefix |
| learn words | Vocabulary - Aprende inglés (4.1k); WRD (251); A1-C1 (0); **WidgetVocab (39)**; Elevate (6.4k) | **#4** | Low | prefix |
| vocab | Vocabulary Builder - Vocab (6); Vocabulary - Aprende inglés (4.1k); Vocab – Vocabulario Inglés (38); VoCat (10); Vocabulary.com (50) | #17 | Low | prefix |

- MonkeyTaps localizes its title for MX ("Vocabulary - Aprende inglés") and ES ("Vocabulary - Aprende palabras"). In Education top-free it is #18 in MX, #13 in ES and #12 in BR.
- WV is #70 in the MX Education chart.
- Autocomplete: "palabra del día widget" exists in MX.

**Russia (ru) and Kazakhstan (kz)**

| Keyword | Top-5 (ratings) | WV rank | Difficulty | Autocomplete |
|---|---|---|---|---|
| RU английские слова | Английский язык. Учить слова (13k); WORDY (177); Английские слова. Учить язык (1.5k); 3000 слов (4.4k); Учить английские слова (35) | >48 | Med | #5 |
| RU учить английские слова | Английский язык. Учить слова (13k); Английские слова. Учить язык (1.5k); Мой словарь (2.3k); Quizlet (79k); Skyeng (83k) | >46 | High | #2 |
| RU слово дня | Слово дня — толковый словарь (9.2k); Слово дня (37); Factly (345); Стихи дня (483); Стаканчик (9.7k) | >42 | Low | #1 |
| RU виджет | Widgetsmith (45k); Color Widgets (26k); Widgetable (31k); iScreen (15k); кулон виджет (50k) | >45 | High | #6 |
| RU английский виджет | Zarafa (4); Английский - Word Widget (79); **WordPeek** — слово на локскрине (0); Wordbee (0); Lola Speak (1.3k) | >45 | Low | prefix |
| RU vocabulary | MonkeyTaps (696); My Words (1.2k); Quizlet (79k); Английский язык. Учить слова (13k); Vocabulary - новое слово дня (2) | #9 | Med | #1 |
| RU vocab | Vocab – Английский для работы (47); MonkeyTaps (696); Vocab:LEW (0); WhatsApp (4.1M); Word of the Day・Thesaurus (284) | #22 | Low | #3 |
| RU learn words | A1-C1 (0); MonkeyTaps (696); Words - Учи иностранные языки (7.3k); Английский язык. Учить слова (13k); WRD (228) | #25 | Med | #1 |
| KZ английские слова | Английский язык. Учить слова (655); WORDY (212); Quizlet (12.6k); Учить английский: слова с нуля (651); Learn English w/ flashcards (925) | >50 | Med | #2 |
| KZ ағылшын тілі | Ағылшын тілін үйрену (395); Duolingo (121k); Learn English for Beginners (14); 2Shine (1.9k); Sozbe Soz (0) | >14 | Low | #2 |
| KZ vocabulary | MonkeyTaps (515); 6000 IELTS Academic Vocabulary (12); English Vocabulary in Use (86); Learn English w/ flashcards (925); Quizlet (12.6k) | #18 | Med | #3 |
| KZ vocab | Vocab - Workplace English (34); Vocab:LEW (0); 6000 IELTS (12); MonkeyTaps (515); WhatsApp (968k) | #13 | Low | #8 |
| KZ learn words | MonkeyTaps (515); Quizlet (12.6k); Learn English w/ flashcards (925); WRD (323); Words (925) | #10 | Med | #1 |
| KZ word of the day | Vocabulous (61); MonkeyTaps (515); WotD:Widget (3); Word of the Day (1); M-Webster (227) | >43 | Low | #1 |

- RU/KZ/BY Education charts: WV is #3 in KZ and BY. The only other vocabulary apps in the KZ top 100 are Zarafa: Vocabulary Widget (#7) and WRD (#80). In BY: Zarafa #13, WRD #35, Mnemo #56, MonkeyTaps #70.
- Not in the RU or UA top 100. UA vocabulary peers: WRD #18, Zarafa #34, Calleo #57.
- **Conflict flag:** "WordPeek — слово на локскрине" exists in the RU store, so avoid the names Peekword and WordPeek.

## 2. Competitor metadata teardown (exact `trackName` plus subtitle from apps.apple.com pages, rating counts per storefront)

"(none)" means no subtitle set: the page falls back to the category name. Chart = Top Free rank inside the app's category shown on its own page.

### 2.1 US top vocabulary apps (selected by rank score across 21 core queries)

| # | Title | Subtitle | Seller | Category | Ratings | Chart |
|---|---|---|---|---|---|---|
| 1 | Vocabulary - Learn words daily | Word of the day widget & games | Monkey Taps | Education, Reference | 219.6k | #26 Edu |
| 2 | Word of the Day・Vocabulary | English Vocab Builder & Games | Vocabulous US | Education | 39.0k | – |
| 3 | Elevate - Brain Training Games | Vocab, Memory, & Math Puzzles | The Mind Company | Education | 544k | #24 Edu |
| 4 | Dictionary.com: English Words | Dictionary, Thesaurus, Vocab | Curiosity Media | Reference | 327.8k | #151 Ref |
| 5 | Vocabulary Builder by Magoosh | (none) | Magoosh | Games > Word | 7.0k | #199 Word |
| 6 | WordPal - Vocabulary Builder | Learn new words: expand vocab | Dynamic Apps | Education | 10.2k | #146 Edu |
| 7 | Vocabulary Builder by Atlas | Daily Word of the Day Widget | SAYAN YAZILIM (Turkish) | Education | 12.5k | – |
| 8 | Merriam-Webster Dictionary | (none) | Merriam-Webster | Reference | 329k | #48 Ref |
| 9 | Word of the Day: Widget | Learn a new word every day. | Dogan Ekici | Education | 1.6k | – |
| 10 | WOTD - Word of the Day | Aesthetic Daily Word Widget | Jin Quan Wong | Reference | 33 | – |
| 11 | Vocabulary Builder by Learning | Daily Words app & Vocab Widget | Learning Learn MCHJ | Education | 551 | – |
| 12 | MyVocab - Learn new words | Improve vocabulary daily | Positive Mindset | Education | 364 | – |
| 13 | Learn English with flashcards! | Vocabulary learning app | Nikita Olifer | Education | 870 | – |
| 14 | Vocab: Learn English Words | Vocabulary Builder: Daily Word | Word Search Games | Reference | 2.1k | – |
| 15 | Word of The Day Widget: Voca | Daily Vocabulary Word Builder | Zipo Apps | Education | 304 | – |
| – | WordUp - Vocabulary Builder | Learn New English Words Via AI | Geeks | Education | 13.8k | – |
| – | Vocabulary.com | (none) | Curiosity Media | Education | 5.0k | – |
| – | Widget Vocabulary: Learn Words | Easy & Fast English Learning | Orbit Studios | Education | 418 | – |
| – | Word Widget: Daily Vocabulary | Learn English: Word of the Day | Erdi Tuncalp | Education | 2 | – |
| – | Lingo Widget: Daily Vocabulary | Word Flashcards · Lock Screen | Oguz Doruk | Education | 101 | – |

**Observed targeting.** Metadata words show intent; hidden keyword fields are not visible.
- Everyone uses one of five clusters: "vocabulary/vocab/vocab builder", "word of the day", "widget", "learn/new words" or "daily".
- Monkey Taps covers vocabulary, learn, words, daily, widget, games and word of the day. Its description opens with "The word of the day on your Lock Screen..." and touts 10,000+ words with levels and topics.
- Atlas uses the exact Atlas strings "Daily Word of the Day Widget" (US) and "Flash cards: IELTS Prep" (AU), showing locale-specific targeting.
- Widget-first indies (Voca, WOTD, Word Widget, Lingo Widget, Learning VB, MyVocab) use "Widget", "Lock Screen" or "Daily" in subtitles and have almost no ratings.
- Descriptions open with a benefit hook: "Learn a new English word every day — right from your home screen..." (Word Widget).

### 2.2 TR top vocabulary apps (selected by rank score across 24 core queries)

| # | Title | Subtitle | Seller | Ratings (TR) | Chart (TR) |
|---|---|---|---|---|---|
| 1 | Vocabulary Builder by Atlas | Word of the Day, Flashcards | SAYAN YAZILIM | 8.6k | – |
| 2 | Kolay İngilizce Kelime Öğren | 5 Dakikada İngilizce Ezberle | Furkan Sevgili | 36.9k | #182 Edu |
| 3 | İngilizce Kelime Kartları | (none) | CODEIDA | 1.3k | – |
| 4 | English Words Trainer | Daily Vocabulary Builder | Emre Vona | 5.3k | – |
| 5 | Quizlet: AI-powered flashcards | Get better marks with Quizlet | Quizlet | 29.4k | #43 Edu |
| 6 | Vocabulary - Learn words daily | Write & speak more confidently | Monkey Taps | 1.2k | – |
| 7 | VocabBuilder: İngilizce Kelime | (none) | Mustafa Dayanir | 818 | – |
| 8 | Flashwords: Learn Vocabulary | Spanish, French, German words | muhammed kılınç | 2.1k | – |
| 9 | Blarma: Vocabulary Lessons | Learn Spanish & 30 Languages | Blarma | 5.0k | #47 Edu |
| 10 | Kelime+: YDS, YÖKDİL Hazırlık | (none) | Kemal Bakacak | 1.6k | – |
| 11 | WordUp \| Vocabulary Builder | Learn English Words Daily | Geeks | 3.6k | – |
| 12 | Wrd – Word of the Day Widget | Learn Vocabulary & Phrases | Anastasiia Iaemurd | 5 | – |
| 13 | Word Widget: Daily Vocabulary | Learn English: Word of the Day | Erdi Tuncalp | 6 | – |
| 14 | İngilizce Öğren: Kelime Widget | (none) | Oguz Doruk | 1 | – |
| 15 | Widget Vocabulary: Learn Words | Easy & Fast English Learning | Orbit Studios | 190 | **#3 Edu** |
| – | Hapax: Word of the Day Widget | Daily English vocabulary | QUIETSPIRE | 0 | – |
| – | Lingo Widget: Daily Vocabulary | Language Flashcards & Words | Oguz Doruk | 17 | – |
| – | YDS - YÖKDİL Kelime Ezberleme | (none) | – | 35 | – |
| – | MODADİL YDS KELİMELERİ | (none) | MODA DİL AKADEMİSİ | 23 | – |
| – | Word of the Day・Vocabulary | English Vocab Builder App | Vocabulous | 356 | – |

**Observed targeting in TR.**
- Turkish publishers dominate (Atlas, Kolay İngilizce, Kelime Kartları, English Words Trainer, Kelime+, WV).
- The strong TR keyword clusters: "ingilizce kelime", "kelime ezberle(me)", "kelime kartları", "yds/yökdil", "kelime öğren".
- Exam apps: VocabBuilder's description targets "YDS, YÖKDİL, YDT ve TOEFL". Kelime+ targets the "most frequently asked 1000 words in YDS/e-YDS/YÖKDİL". YDS - YÖKDİL Kelime Ezberleme claims "AI assistant".
- İngilizce Öğren: Kelime Widget is a TR-language widget app with no subtitle set (1 rating).
- Monkey Taps' TR listing is a generic English variant, not Turkish.

### 2.3 Education charts today (Apple RSS)
- US: Monkey Taps #26, Elevate #24.
- TR: WV #3, Blarma #47.
- Neither chart includes more than these vocabulary apps in the top 100.

## 3. App name proposals (clean = no matching `trackName` in US/TR top-15 results; RDAP free? = not registered in `rdap.verisign.com` (.com) and `pubapi.registry.google` (.app); RDAP 404 is not a guarantee, confirm at a registrar)

| # | Name | US/TR app conflicts | .com | .app | Other markets (GB, AU, CA, MX, VN, RU) | Notes |
|---|---|---|---|---|---|---|
| 1 | **Wordglance** | none | free? | free? | clean | Literal widget metaphor ("glance"); short; easy to say |
| 2 | **Lexpeek** | none | free? | free? | clean | Short; "lex" = words, "peek" = glance |
| 3 | **Wordwink** | none | taken | free? | clean | Playful; "a wink of a word" |
| 4 | Lumiword | none | taken | free? | clean | "Luminous" word; calm brand |
| 5 | Lexiglance | none | taken | free? | clean | Longer; same metaphor as #1 |
| 6 | Wordlume | none | taken | free? | – | "Lume" = light |
| 7 | Lexisnack | none | taken | free? | – | Bite-size words |
| 8 | Wordtick | none | taken | free? | – | Tick = checklist/streak |
| 9 | Lexcue | none | taken | free? | – | Cue/flash card |
| 10 | Lexbyte | none | taken | free? | – | Bite + tech |
| 11 | Lexilume | none | taken | free? | – | |
| 12 | Peekword | none in US/TR | taken | free? | **RU conflict "WordPeek — слово на локскрине"** | Avoid |
| 13 | Wordglint | none | taken | taken | – | Domains gone |
| 14 | Wordhalo | none | taken | taken | – | Domains gone |
| 15 | Verbaly | none | taken | taken | – | Domains gone |

Rejected on conflicts: Wordly (Wordly® game 6.1k ratings), Wordtap, Wordnook, Wordbloom, Wordnest, Wordstack, Wordspark, Vocabo, Vocaly, Lexly, Lexiloop, Wordtrail, Vocaglance (app "VocaGlance - Learn Vocabulary"), Lockword (TR "LockWords: Lock Screen Widgets"), Glimword (a lock-screen vocab app "Glim" exists), Kelimo and Kelimecik (word games).

**Recommended top 3:** 1) Wordglance, 2) Lexpeek, 3) Wordwink. Before committing, run trademark searches (USPTO, TÜRKPATENT, EUIPO) and confirm domains at a registrar.

**Title and subtitle combos** (≤30 chars each, counted in code):

| Name | Title (≤30) | Subtitle (≤30) | Target market |
|---|---|---|---|
| Wordglance | Wordglance: Vocabulary Widget (29) | Word of the Day on Lock Screen (30) | US primary |
| Wordglance | Wordglance: Vocabulary Widget (29) | Learn English Words Daily (25) | learner variant (alt) |
| Wordglance | Wordglance: Kelime Ezberleme (28) | Günlük İngilizce Widget & YDS (29) | TR |
| Lexpeek | Lexpeek: Vocabulary Widget (26) | Word of the Day on Lock Screen (30) | US alt |
| Wordwink | Wordwink: Learn Words Widget (28) | Daily Vocabulary & Flashcards (29) | alt (uses "learn words widget" where WV currently ranks #1) |

## 4. Draft metadata (name Wordglance; checked for length in code)

### 4.1 en-US (primary language)
- **Title (29):** `Wordglance: Vocabulary Widget`
- **Subtitle (30):** `Word of the Day on Lock Screen`
- **Keyword field (99 chars/99 bytes):** `learn,english,daily,vocab,flashcards,builder,ielts,toefl,sat,gre,quiz,memorize,test,study,toeic,esl`
  - No spaces, no duplicates, no title/subtitle words.
  - Apple's guidance is that name plus subtitle plus keywords form one combined pool, so words are not repeated (AppsOps and AppTweak guides). Phrases such as "vocabulary widget", "word of the day widget", "vocabulary lock screen" and "learn english words" form across the fields.
  - Singular/plural handled by Apple, so "word" is not needed beside "words".
- **Alt A/B subtitle (25):** `Learn English Words Daily`, with keyword field `day,lock,screen,vocab,flashcards,builder,ielts,toefl,sat,gre,quiz,memorize,test,study,toeic,esl` (still ≤100). Product Page Optimization only tests creatives, so test metadata sequentially.
- **Promotional text (150/170):** `Your Lock Screen is now a vocabulary coach. Add the widget, glance at a new word all day, and build your English vocabulary in seconds. Free to start.`
  - Promotional text can be edited without a new submission (Apple: 170 chars).
- **Description, first lines** (line 1 is the hook; the product page folds after roughly 3 lines):
  1. `Learn a new word every time you unlock your phone.` (50)
  2. `Wordglance puts a vocabulary widget on your Home Screen and Lock Screen: word of the day, meaning, example and pronunciation at a glance.` (137)
  3. `Build your English vocabulary in seconds with flashcards, quick quizzes and daily streaks. Free to start.` (105)
  - Description is not indexed for search (vendor sources); optimize it for conversion.
  - Feature claims here (pronunciation, quizzes, streaks, A1–C2 levels) are placeholders. Align them with the real app.

### 4.2 tr
- **Title (28):** `Wordglance: Kelime Ezberleme`
- **Subtitle (29):** `Günlük İngilizce Widget & YDS`
- **Keyword field (90 chars / 98 UTF-8 bytes):** `öğren,ezberle,kartları,yökdil,defteri,öğrenme,test,quiz,ielts,toefl,sözlük,flashcard,vocab`
  - Designed to be safe even if the limit is 100 bytes (Apple's doc says "100 bytes"; ASC shows a live counter, verify there). Turkish diacritics use 2 bytes each.
  - Phrases formed across title, subtitle and keywords include "ingilizce kelime ezberleme", "ingilizce kelime", "günlük kelime", "kelime widget", "ingilizce widget", "yds kelime", "yökdil kelime", "kelime öğren", "kelime kartları" and "kelime defteri".
  - "vocabulary" and "word of the day" are carried by the `en-GB` listing (Section 5).
- **Promotional text (154):** `Kilit ekranında her gün yeni bir İngilizce kelime. Widget'ı ekle, uygulamayı açmadan kelime ezberle. YDS, YÖKDİL ve günlük İngilizce için. Ücretsiz başla.`
- **Description first lines:**
  1. `Telefonunu her açtığında yeni bir İngilizce kelime öğren.` (57)
  2. `Wordglance, ana ekran ve kilit ekranı widget'ı ile günün kelimesini, anlamını, örnek cümlesini ve telaffuzunu gösterir.` (119)
  3. `Kelime kartları, mini testler ve günlük seri ile İngilizce kelime ezberleme artık kolay. Ücretsiz başla.` (104)
  - Content claims are placeholders, as above.

## 5. Localization leverage (cross-localization)

**Mechanism.** Each storefront has a primary locale plus secondary locales that also feed its search index. Keywords in different locales that serve the same storefront add up, so one extra locale means up to 30+30+100 more characters of metadata indexed in that storefront. Phrases form only inside one locale, not across locales (AppTweak). Apple does not document this; it is "industry observation" (MobileAction).

**Which locales are indexed, per source** (no Apple documentation exists; this is vendor-reported only):

| Storefront | Primary | Secondary locales indexed |
|---|---|---|
| **US** | en-US | es-MX, ru, zh-Hans, ar, fr-FR, pt-BR, zh-Hant, vi, ko (AppTweak test run in 2022 and republished 2025-11-21; MobileAction 2026-04-15; aso.dev table updated 2026-07-10). Conflict: one guide (Sonar) says only es-MX. |
| **TR** | tr | en-GB (MobileAction 2026-04; aso.dev lists EN_GB and TR). AppTweak's 2022 table also lists French. |
| UK | en-GB | en-AU |
| AU | en-AU | en-GB |
| CA | en-CA | fr-CA |

**What I could and could not verify.**
- My test: I searched the US store with terms in es-MX, vi, ru, ko, zh-Hans, zh-Hant, fr, ar and pt-BR, plus control languages not in the list (de, it, ja, pl, tr). Result counts were similar for listed and control languages (about 150–190 results each). Apple's search also matches across languages. So the iTunes API cannot discriminate and gives no confirmation either way.
- Observed behavior consistent with a TR/en-GB link: apps without a Turkish listing display the same English subtitle in TR, GB, AU and CA, which differs from their US listing (Monkey Taps "Write & speak more confidently", Vocabulous "English Vocab Builder App"). This shows display fallback, not indexing.
- Apple "frowns on" the tactic per AppTweak, but no rejections have been publicized.
- WWDC26 announced Product Page Headers, an Asset Library and Personalized Collections. No keyword-indexing changes were announced (Gummicube, AppsOps). AppsOps speculates about a possible shift to semantic matching.
- If a localization is added, its title and subtitle are required and visible to users in that language. Use real translations, not placeholders.

**Plan per locale** (all lengths counted; keyword fields without spaces; locale-specific):

| Locale | Serves | Title | Subtitle | Keyword field |
|---|---|---|---|---|
| en-US (primary) | US | Wordglance: Vocabulary Widget | Word of the Day on Lock Screen | see 4.1 |
| **en-GB** | UK primary; **TR and AU secondary** | Wordglance: Vocabulary Widget | Learn English Words & IELTS (27) | `day,lock,screen,vocab,flashcards,builder,toefl,yds,yokdil,ydt,quiz,test,study,b1,b2,c1,a1,daily` (95) |
| en-AU | AU primary; UK secondary | Wordglance: Vocabulary Widget | IELTS & PTE Words Every Day (27) | `learn,english,lock,screen,vocab,flashcards,builder,toefl,naplan,quiz,memorise,test,study,academic` (97) |
| en-CA | CA primary | Wordglance: Vocabulary Widget | CELPIP & IELTS English Words (28) | `learn,day,lock,screen,vocab,flashcards,builder,toefl,immigration,canada,quiz,memorize,test,study,tef` (100) |
| tr | TR | see 4.2 | | see 4.2 |
| es-MX | MX primary; US secondary | Wordglance: Vocabulario Inglés (30) | Palabra del día en tu pantalla (30) | `aprender,widget,tarjetas,memoria,flashcards,fácil,rápido,bloqueo,principiantes,diario,vocab,ielts` (97 chars/99 bytes) |
| pt-BR | BR primary; US secondary | Wordglance: Vocabulário Inglês (30) | Palavra do dia no seu widget (28) | `aprender,cartões,memorizar,flashcards,fácil,rápido,bloqueio,tela,iniciantes,diário,vocab,vocabulary` (99 chars/103 bytes) |
| ru | RU (also KZ/BY use Russian); US secondary | Wordglance: Английские слова (28) | Виджет: слово дня на экране (27) | `учить,выучить,карточки,запоминание,словарный,запас,блокировки,ежедневно,ielts,toefl,vocabulary,vocab` (100 chars; ~164 UTF-8 bytes, so confirm in ASC) |
| vi | VN; US secondary | Wordglance: Từ vựng tiếng Anh (29) | Học từ mới mỗi ngày qua widget (30) | `flashcard,ghi,nhớ,ielts,toeic,hàng,màn,hình,khóa,vocabulary,vocab,điển,miễn,phí,thông,dụng` (~91 chars; keyword tokens must be single words) |

**English-only extension locales for US keyword space** (US secondary; all English keywords are unique versus en-US, with titles in English and the subtitle in the local language; native-speaker review required for each subtitle):

| Locale | Subtitle | Keyword field (≤100) | Theme |
|---|---|---|---|
| fr-FR | Un mot d'anglais par jour (25) | `improve,new,spaced,repetition,language,fluent,beginner,intermediate,cefr,grammar,phrases,efl,a1,a2` (98) | learner level terms |
| zh-Hant | 英文單字小工具・每日一字 | `gmat,act,ssat,psat,college,prep,essay,exam,practice,score,admissions,cambridge,business,career` (94) | exam prep |
| zh-Hans | 英语单词小组件・每日一词 | `brain,training,puzzle,memory,trivia,spelling,bee,crossword,wordle,synonyms,antonyms,riddle,game,fun` (99) | brain/word-game adjacencies |
| ko | 영어 단어 위젯・오늘의 단어 | `dictionary,thesaurus,definition,meaning,etymology,roots,prefix,suffix,idioms,slang,pronunciation` (96) | reference terms |
| ar | ويدجت مفردات إنجليزية يومية | `students,kids,teens,adults,professionals,work,writing,reading,public,presentation,interview,resume` (98) | audience terms |

Caveats:
- Do not duplicate keywords across locales that serve the same storefront; it adds nothing. Duplicates across different storefronts are fine (for example `vocab`/`ielts` in es-MX serve MX).
- Putting English words in a non-English locale's keyword field is hidden from users but is exactly the contested tactic. If a risk is unacceptable, drop the extension locales.
- Replacing keywords in a secondary locale can hurt rankings that depended on them; make changes one locale at a time and watch.

## 6. Creative strategy

### 6.1 Screenshots (up to 10 per device; Apple: min 1, max 10; screenshot sizes as of the Apple spec page)
Ordering rationale: the first 2–3 portrait screenshots show in search results, so #1 must answer "what is it" in two seconds. Competitors mostly show app UI; lead with the device Home/Lock Screen with the widget. Then show the learning value, then retention (streaks), then exam packs, then the conversion close.

| # | EN caption (chars) | TR caption (chars) | Visual |
|---|---|---|---|
| 1 | Learn words without opening the app (35) | Uygulamayı açmadan kelime öğren (31) | Hero: Home Screen and Lock Screen with widgets |
| 2 | Word of the Day on your Lock Screen (35) | Kilit ekranında günün kelimesi (30) | Lock Screen close-up (inline/circular/rectangular) |
| 3 | Meaning, example & pronunciation (32) | Anlam, örnek cümle, telaffuz (28) | Word card detail |
| 4 | Pick your level: A1 to C2 (25) | Seviyeni seç: A1'den C2'ye (26) | Level and topic picker |
| 5 | Flashcards that fit in 30 seconds (33) | 30 saniyede kelime kartları (27) | Flashcard session |
| 6 | Quick quizzes lock it in (24) | Mini testlerle kalıcı ezber (27) | Quiz UI |
| 7 | Daily streaks keep you going (28) | Günlük seri seni motive eder (28) | Streak/progress |
| 8 | IELTS, TOEFL, SAT & GRE packs (29) | YDS, YÖKDİL, IELTS, TOEFL (25) | Exam packs (for TR, move this to #3 or #4) |
| 9 | Widgets in every size (21) | Her boyutta widget (18) | All widget sizes |
| 10 | Free to start. Add your first widget (36) | Ücretsiz başla, ilk widget'ını ekle (35) | Setup walkthrough |

Captions assume features the app may not have; keep only what ships. Heavy legibility: ≤ about 35 chars at large size. Use the same ordering across locales except for the TR exam pack move.

### 6.2 App preview video storyboard (Apple spec: 15–30 s, up to 3 per device size and locale, H.264 up to 500 MB, portrait 886×1920 accepted for 6.9"/6.5"/6.1"; the poster frame defaults to 5 s and can be changed)

| Time | Beat | On-screen text (muted-safe) |
|---|---|---|
| 0–3 s | Hook: finger unlocks the phone, a new word appears on the Lock Screen | "A new word every unlock" |
| 3–8 s | Long-press, add widget in 3 taps, widget appears on Home Screen | "Add the widget in seconds" |
| 8–14 s | Tap the word: card with meaning, example and pronunciation | "Meaning, example, sound" |
| 14–20 s | Flashcard swipe then a 3-question quiz | "Remember it for good" |
| 20–26 s | Streak counter goes from 1 to 7, level badge | "Build the habit" |
| 26–30 s | End card: icon, name, "Free to start" | – |

Set the poster frame to the Lock Screen hero. Previews appear before screenshots. Apple's page does not say whether they autoplay muted; treat audio as optional and use captions. Apple says new Product Page Headers (video or image) are coming "soon" (WWDC26 via Gummicube): plan the same hero for them.

### 6.3 Custom Product Pages (Apple: up to 70 per app; can vary screenshots, previews and promotional text; each has a unique URL; keywords can be assigned so a page appears in search for them; verify keyword-linking and deep-link support in App Store Connect)

| CPP | Audience and traffic source | Hook (screenshot 1 and promo text) |
|---|---|---|
| IELTS Vocabulary | Apple Ads exact "ielts vocabulary", "ielts words"; AU, UK, CA, VN, TR | "IELTS words on your Lock Screen" |
| TOEFL Vocabulary | "toefl vocabulary"; VN, TR, MX | "Academic words every day" |
| SAT / GRE Words | US "sat vocabulary", "gre vocabulary" | "SAT words in your widget" |
| Business English | "business english", "english for work" | "Meeting words, on your Lock Screen" |
| YDS / YÖKDİL (TR) | "yds kelime", "yökdil kelime", "yds" | "YDS kelimeleri kilit ekranında" |
| LGS / YKS English (TR) | "lgs ingilizce", "yks ingilizce" | "Sınav kelimeleri cebinde" |
| Lock Screen Widget | "vocabulary lock screen", "word of the day widget" | "Your Lock Screen is a classroom" |
| Learners (VN/MX/RU/KZ) | local keywords, localized | Local-language hero, English words |
| Competitor-switch | Apple Ads on competitor names | "A simpler way to learn words" |

### 6.4 In-App Events (Apple: up to 10 published and 15 approved at once, up to 31 days long, up to 14 days promotion lead; name ≤30, short description ≤50, long description ≤120; no prices, no "best"/"#1", no all caps)

| Event | Short description | Badge | Timing |
|---|---|---|---|
| 30-Day Word Sprint (18) | Learn 3 new words a day for 30 days (35) | Challenge | January ("new year") and September |
| IELTS Vocabulary Boost (22) | 200 high-frequency IELTS words in 4 weeks (41) | Challenge | before IELTS-heavy months (AU/UK/CA) |
| YDS Kelime Kampı (16) | YDS için 30 günde 300 kelime (28) | Challenge | ÖSYM calendar: YDS/2 is reported for **22 Nov 2026** (kariyer.net, eleman.net; registration closed 8 Oct, late 14 Oct; verify at osym.gov.tr) |
| Back-to-School Word Pack (24) | SAT, ACT and GRE words in your widget (37) | Special Event | August–September |
| World English Language Day | New words for 23 April | Special Event | April |

## 7. Ratings, category and Apple Ads

### 7.1 Ratings and reviews for ASO
- **Ratings are per storefront.** MonkeyTaps shows 220k (US) versus 1.2k (TR). To compete for TR phrases, target roughly 1–5k TR ratings; for UK/AU/CA roughly 500–2k. Earn them locally, not from US traffic.
- **System prompt:** use `AppStore.requestReview` / SwiftUI `@Environment(\.requestReview)`. Apple's documentation: at most 3 prompts per 365 days per device. It may not display even when called, and it only appears in App Store/TestFlight builds. A forum thread reports exceptions; treat the limit as a system rule.
- **Timing (recommended):**
  - Trigger on a success moment, after day 3+ of use AND (a 7-day streak OR a finished quiz at 80%+ OR the 10th learned word).
  - Never on first launch, never right after the paywall, never after an error.
  - Gate by app version.
  - Because only 3 prompts per year are available, spend the first on the best moment.
- **Compliance:** do not build a custom "do you like the app?" gate before the system prompt. Review-gating is disallowed by App Review Guidelines (cited as 5.6.1 in third-party summaries; verify). A permanent "Rate us" button in Settings that opens the App Store review URL (`...?action=write-review`) is allowed.
- **Reviews:** reply to reviews in the review's language (a Turkish reply for TR reviews). Replying often improves rating changes. Do not reset the rating on version updates unless needed.

### 7.2 Category choice

| Category | Evidence from this data | Pros | Cons |
|---|---|---|---|
| **Education (primary)** | Top-10 search results for core vocab queries: US 72% Education, 17% Reference, 7% Games; TR 91% Education, 8% Games. Education top-free charts: US MonkeyTaps #26, Elevate #24; TR WV #3. | Where users and competitors are; charts feed discovery; works in TR (#3) | Crowded top-100: Duolingo, AI tutors, school/exam apps (in the US top-100 only 2 vocabulary apps) |
| **Reference (secondary)** | US dictionary and word-of-day apps sit there: Merriam-Webster #48, Oxford #73, Dictionary.com #151, WOTD, Vocab:LEW. TR: Tureng #8, TDK #13. MonkeyTaps is Education + Reference. | Dictionary/word-of-day intent; lower density; secondary slot costs nothing | Chart there is Bible/translation/dictionary-led; primary Reference would lose learner traffic |
| Lifestyle | No vocabulary apps in the US or TR top-100 | Aesthetic widget audience | Wrong intent for learning; none of the competitors use it |
| Productivity / Graphics & Design | Widget utility leaders (Widgetsmith, Color Widgets) | Widget searchers | Heavy competition, wrong intent |

**Recommendation:** Education primary, Reference secondary. Do not choose Games > Word (Magoosh sits there with a #199 rank).

### 7.3 Apple Ads (Apple Ads = formerly Search Ads) keyword groups
Benchmarks (not Turkey-specific for CPT):
- US Education median CPT $1.52, CPI $2.91, TTR 8.3%, CR 56.4% (AppTweak, 2025 table).
- Country CPT: US $1.58, UK $1.31, AU $1.17, CA $0.96, CR 60–65% (Adapty, updated 2026-07-13).
- Turkey: CPI about $1.02 and CR 48% across all categories (AppTweak). No Turkey CPT or Education figure found.
- Treat all bids below as starting hypotheses.

| Group | Match | US examples | TR examples |
|---|---|---|---|
| Brand | exact | wordglance, wordglance vocabulary | wordglance, wordglance kelime |
| Competitor | exact | vocabulary - learn words daily, monkey taps, word of the day vocabulary, vocabulary builder atlas, wordup, magoosh vocabulary builder, vocabulary.com, widget vocabulary | kolay ingilizce kelime öğren, english words trainer, ingilizce kelime kartları, blarma, kelime+, widget vocabulary |
| Generic, widget (core) | exact | vocabulary widget, word widget, vocab widget, daily vocabulary widget, vocabulary lock screen, word of the day widget, words widget, flashcard widget, english words widget | kelime widget, ingilizce widget, kilit ekranı kelime |
| Generic, head | exact + broad | vocabulary, vocab, word of the day, learn words, vocabulary builder, flashcards | ingilizce kelime, kelime ezberleme, kelime öğren, kelime kartları, kelime defteri |
| Exam | exact | ielts vocabulary, toefl vocabulary, sat vocabulary, gre vocabulary | yds kelime, yökdil kelime, yds, yökdil, ielts kelime |
| Discovery | Search Match + broad, negatives | start with Search Match on, graduate converters to exact | same |

- Negatives to start with: words with friends, wordle, crossword, dictionary, translate, bible, kids, banking, esl (US); kelimelik, kelime oyunu, bulmaca, çeviri, sözlük (TR).
- Send each group to its matching CPP.
- Recommended ratios: brand 5–10%, competitor 20%, generic 40%, discovery 30%.

## 8. Open items and verification checklist
- Cross-locale indexing is unverified (Section 5); confirm with a test keyword after publishing if it matters.
- Check Search Popularity scores in Apple Ads for the top 30 terms; autocomplete is only an ordering signal.
- The 100-byte versus 100-character keyword limit: Apple's doc says bytes. ASC shows a live counter, so confirm there, especially for ru, vi and TR.
- Check name trademarks and domains at registrars; RDAP "free?" is not a guarantee.
- Have native speakers review TR, es-MX, pt-BR, ru, vi, fr, zh, ko and ar copy.
- Validate that the product actually has the features named in captions and descriptions.
- ÖSYM exam dates come from secondary sources; verify at osym.gov.tr.
- Keyword fields of competitors are not visible; "targeting" above is inferred from titles, subtitles and descriptions.

## Appendix A. Where Widget Vocabulary ranks (iTunes API order; limit 25, or 50 for VN/MX/RU/KZ)

| Market | Keyword → rank |
|---|---|
| US | learn words widget #1; english words widget #1; learn english widget #1; vocabulary words widget #4; daily vocabulary widget #7; words widget #7; word widget #9; vocab widget #10; vocabulary widget #12; vocab words #16; toefl words #11; english vocab words #12; core terms (vocabulary, vocab, learn words, word of the day, ...) not in top 22–25 |
| TR | ingilizce widget #2; widget kelime #4; ingilizce öğren widget #4; kelime widget #6; ingilizce kelime widget #6; vocabulary #9; learn words #18; IELTS kelime #22; toefl kelime #23; core terms (ingilizce kelime, kelime ezberleme, ...) not in top 22–25 |
| VN | learn words **#1**; widget #20; vocab #40 |
| MX | widget inglés **#1**; learn words #4; vocab #17; aprender inglés rápido #20; vocabulario inglés #39 |
| RU | vocabulary #9; vocab #22; learn words #25 |
| KZ | learn words #10; vocab #13; vocabulary #18 |
| GB, AU, CA | "widget vocabulary" #1 (brand query only) |
| Education chart (Apple RSS, 2026-10-10) | TR #3, KZ #3, BY #3, VN #21, MX #70; not in top 100: US, RU, UA, ES, BR |

## Sources
- iTunes Search API: https://itunes.apple.com/search; Apple RSS charts: https://itunes.apple.com/{cc}/rss/topfreeapplications/limit=100/genre=6017/json (xml for MX, UA, ES, BR)
- Apple hints endpoint: https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints
- App Store pages (subtitle, chart position): https://apps.apple.com/{cc}/app/id{trackId}
- Apple docs: [Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information), [Screenshot specs](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), [App preview specs](https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications), [Custom product pages](https://developer.apple.com/app-store/custom-product-pages/), [In-App Events](https://developer.apple.com/app-store/in-app-events/), [Requesting reviews](https://developer.apple.com/documentation/storekit/requesting-app-store-reviews.md)
- Cross-localization: [AppTweak](https://www.apptweak.com/en/aso-blog/how-to-benefit-from-cross-localization-on-the-app-store), [MobileAction](https://www.mobileaction.co/blog/app-store-cross-localization/), [aso.dev](https://aso.dev/metadata/cross-localization/), [AppsOps keyword rules](https://appsops.store/news/aso-keyword-field-strategy-ios26-2026)
- WWDC26: [Gummicube](https://www.gummicube.com/blog/aso-takeaways-from-apples-wwdc26/)
- Apple Ads benchmarks: [AppTweak](https://www.apptweak.com/en/aso-blog/apple-ads-benchmarks), [Adapty](https://adapty.io/blog/apple-ads-benchmarks-2026/)
- Exam dates: [kariyer.net](https://www.kariyer.net/universite-rehberi-blog/?p=3333), [eleman.net](https://www.eleman.net/is-rehberi/ne-zaman/yds-ne-zaman-h16368)
- Domain checks: https://rdap.verisign.com/com/v1/domain/ and https://pubapi.registry.google/rdap/domain/
