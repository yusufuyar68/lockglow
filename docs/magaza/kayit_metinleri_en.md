# App Store kayıt metinleri: İngilizce (en-GB)

> **TASLAK (23 Ekim 2026).** App Store Connect'e girilmedi.
>
> **Marka uyarısı:** "Lockglow" adı için **TÜRKPATENT araması ve marka vekili görüşü yapılmadı.** Ad kesin değil.
>
> Türkçe metnin karşılığı; aynı iddialar, aynı kaynaklar ([`kayit_metinleri_tr.md`](kayit_metinleri_tr.md) → "İddia → kaynak"). Uygulama durumu: `origin/main` aa7ef5d, içerik `2026.10.23-kisisel-10`.

## Neden İngilizce (U.K.)?

Apple'ın tablosuna göre **Türkiye mağazasının varsayılan dili English (U.K.), ek dili Turkish** ([App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-information/app-store-localizations), 23 Ekim 2026'da yeniden bakıldı). İki yerelleştirmenin adı, alt başlığı ve anahtar kelimeleri Türkiye'de aranır (Apple bunu açıkça yazmıyor; yaygın kabul ve `raporlar/08` §1.3'teki kısmi kanıt). English (U.S.) Türkiye'de aranmaz.

- **Ana dil (Primary Language): Turkish.**
- **İkinci yerelleştirme: English (U.K.).** Telefonu İngilizce olan Türk kullanıcı bu metni görür. Ayrıca 100 bayt daha anahtar kelime alanı.
- English (U.S.) şimdilik gerekmez. ABD mağazası hedef değil.

Yazım: İngiliz yazımı ("practise" fiil, "learnt", "Customise"). Sade İngilizce: okuyan kişi büyük olasılıkla İngilizce öğreniyor. Uygulamanın Türkçe düğme adları (Biliyorum, Dinle, Sonraki, Söyle, Tekrar) olduğu gibi yazıldı ve ilk geçtiği yerde parantezle açıklandı: kullanıcı ekranda bu adları görecek.

Uzunluklar Python'la sayıldı ([`araclar/metin_say.py`](araclar/metin_say.py)).

## Özet

| Alan | Sınır | Öneri | Uzunluk |
|---|---|---|---|
| Name | 30 karakter | `Lockglow: Vocabulary Widget` | 27 |
| Subtitle | 30 karakter | `English for Turkish Speakers` | 28 |
| Promotional Text | 170 karakter | aşağıda | 147 |
| Description | 4000 karakter | aşağıda | 3957 |
| Keywords | 100 bayt | aşağıda | 96 bayt |
| What's New | 4000 karakter | 1.0'da alan yok | — |

## Name

```text
Lockglow: Vocabulary Widget
```

27 karakter. Google en-GB'de "vocabulary widget (iphone, lock screen)" önerisi var; widget uygulamalarının uzun kuyruğu (`rakip_analizi.md` §3.1).

**Yedek:** `Lockglow: Learn English Words` (29). "learn english words" daha çok aranır ama rekabeti güçlü; o zaman alt başlık `Lock Screen Vocabulary Widget` (29) olur ve anahtar kelimeler yeniden kurulur.

## Subtitle

```text
English for Turkish Speakers
```

28 karakter. Kime yapıldığını tek satırda söyler; İngilizce sayfası olan rakiplerden ayırır. Google en-GB'de "english for turkish speakers" önerisi var.

**Yedek:** `Learn English Words in Turkish` (30).

## Promotional Text

```text
An English word every time you look at your phone, with its Turkish meaning, an example and audio. Meet it, then recall it. Add your own words too.
```

147 karakter. Aramayı etkilemez; istenildiği zaman değişir.

## Description

```text
You look at your phone dozens of times a day. Lockglow turns each look into a tiny English lesson: one English word with its Turkish meaning, right on your Lock Screen and Home Screen.

Lockglow is made for Turkish speakers who are learning everyday English. Words are at A1, A2 and B1 level: the English you need at home, at work and in the shops.

WHY IT WORKS
• A little every day: the word comes to you while you do something else.
• Seeing is not enough: you meet a new word first, then recall it once straight away.
• Back before you forget: hard words come back often, easy words less often.
• Explained in Turkish: every word has a Turkish meaning, an example sentence and its Turkish translation.
• See the mistake first: more than 600 words show a mistake Turkish speakers often make, and the right way. For example, not "I did breakfast" but "I had breakfast".

WIDGETS
• Small and medium Home Screen widgets; rectangular and one-line Lock Screen widgets.
• Your Lock Screen and Home Screen show the same word.
• The Dinle (listen) button on the Home Screen widget reads the word aloud without opening the app.
• The medium widget has Biliyorum (I know it), Dinle and Sonraki (next) buttons; the small one has Dinle and Sonraki.
• You choose how often the word changes: every 30 minutes, or every 1, 2 or 4 hours.
• A widget health page shows whether your widget is working.

MEET, RECALL, REVIEW
• New words come in rounds of 5. First you guess the meaning, then you recall it from four options.
• For new words you don't rate yourself: your answer does.
• Due words return as four-option fill-in-the-blank questions; well-known words, as recalling the English yourself.
• A round has at most 10 questions. Daily goal for new words: 5, 10, 15 or 20.

SÖYLE: PRONUNCIATION PRACTICE
• Say the word or the example sentence aloud. Your phone listens and answers in Turkish: understood, almost, or what to pay attention to.
• Recognition runs only on your iPhone. Your voice is not recorded and never leaves your phone.

YOUR OWN WORDS
• Heard a word in a series or at work? Add it yourself: the English word, its Turkish meaning and, if you like, an example sentence.
• Your own words appear on your widget and in your feed and reviews too.

YOUR PROGRESS
• Your library: how many words you have met, which ones have settled, and what you learnt this week.
• No percentages, no rankings, no streak counter. A word you forget moves back down; it is not a punishment.

DICTIONARY
• Search every word in English or Turkish, even without Turkish letters: type "odunc" and you get "ödünç".
• Browse by topic or reopen your recent searches.
• Each word has example sentences, words used with it and audio; many have "Dikkat" (watch out) boxes.

MORE THAN 1,200 WORDS
• Single words, phrasal verbs, phrases and collocations.
• Pronunciation, Turkish meaning, a short English definition and over 3,600 example sentences with Turkish translations.
• 30 topics: food, home, family, shopping, health, the city, travel, school, the workplace, technology, feelings, small talk and more.

START YOUR WAY
• On first launch, choose your level and topics; we show you how to add the widget, step by step.
• An optional daily reminder at a time you choose, at most once a day. It shows a word with its meaning and skips days you have already finished.

PRIVACY
• No account, no ads, no tracking.
• Your progress and your own words stay on your phone; we cannot see them.
• Lockglow does not send your data to any server.

GOOD TO KNOW
• The app's interface is in Turkish. It works on iPhone with iOS 17 or later.
• Söyle: on iOS 26 and later, the English speech model downloads once, on first use. On iOS 17–25 your phone needs on-device English (US) recognition.
• The Lock Screen widget has no buttons, and widget buttons do not work while your iPhone is locked.
• iOS decides exactly when a widget refreshes; sometimes it can be a few minutes late.

Privacy Policy: [PRIVACY POLICY URL]
```

3957 karakter (sınır 4000). "The app's interface is in Turkish" satırı bilerek var: İngilizce konuşan biri uygulamayı İngilizce sanıp düşük puan vermesin.

## Keywords

```text
lock,screen,learn,words,flashcards,pronunciation,daily,vocab,quiz,memorize,beginner,practice,day
```

96 karakter, **96 bayt** (sınır 100; hepsi ASCII). Her kelime 2 karakterden uzun. Ad ve alt başlıktaki `lockglow`, `vocabulary`, `widget`, `english`, `turkish`, `speakers` tekrar edilmedi.

| Kelime | Neden |
|---|---|
| lock, screen | "lock screen vocabulary", "vocabulary widget lock screen" (Google en-GB önerisi) |
| learn, words | "learn english words", "english words widget" |
| flashcards | "english flashcards"; tekil yazılmadı (Apple: tekil ve çoğulu birlikte yazma) |
| pronunciation | Söyle |
| daily, day | "daily english words", "word of the day" |
| vocab | "vocab widget"; kısaltmayla arayanlar |
| quiz | Boşluk doldurma ve Hatırla soruları |
| memorize | ABD yazımı bilerek: anahtar kelimeler görünmez, bu yazım daha çok aranıyor olabilir **[doğrulanmadı]** |
| beginner | A1–A2 |
| practice | "english practice" (İngiliz yazımında da isim hâli "practice") |

**Çıkanlar (22 Ekim taslağına göre):** `dictionary` (Türkiye'de sözlük uygulamaları baskın), `esl` (Türkiye'de öneri kanıtı yok). **Yazılamayanlar:** `a1`, `a2`, `b1` (2 karakter).

**Seçenek (çapraz yerelleştirme):** Türkiye'de bu alan da arandığı için buraya birkaç Türkçe kelime (ör. `reklamsız,okunuş,ezber`) konabilir. Apple bunu belgelemiyor ve İngiltere'deki kullanıcı için anlamsız. Öneri: ilk sürümde temiz kalsın; arama raporuna bakıp sonra karar verin.

## What's New

**1.0:** alan yok. TestFlight "What to Test" için:

```text
Please try: Tanış + Hatırla rounds, adding your own words, Kitaplığın (progress), sentences in Söyle, the listen button on the widget and new topics.
```

149 karakter.

**1.1 ve sonrası için kalıp:**

```text
New
• [Feature]: [what it does for you, one sentence].
• New words: [topics].

Fixes
• Fixed [problem].
```
