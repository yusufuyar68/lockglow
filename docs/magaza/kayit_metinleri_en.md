# App Store kayıt metinleri: İngilizce (en-GB)

> **TASLAK (22 Ekim 2026).** App Store Connect'e henüz girilmedi.
>
> **Marka uyarısı:** "Lockglow" adı için **TÜRKPATENT araması ve marka vekili görüşü yapılmadı.** Ad kesin değil.

## Neden İngilizce (U.K.)?

Apple'ın tablosuna göre **Türkiye mağazasının varsayılan dili English (U.K.), ek dili Turkish**. İki yerelleştirmenin de adı, alt başlığı ve anahtar kelimeleri Türkiye'de aranır ([App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-information/app-store-localizations), 22 Ekim 2026'da bakıldı). English (U.S.) Türkiye'de aranmaz.

Bu yüzden öneri:

- **Ana dil (Primary Language): Turkish.**
- **İkinci yerelleştirme: English (U.K.).** Telefonu İngilizce olan Türk kullanıcılar bu metni görür. Ayrıca 100 bayt daha anahtar kelime alanı demektir.
- English (U.S.) şimdilik gerekmez. ABD mağazası hedef değil; açılırsa aynı metin kopyalanır.

Yazım: İngiliz yazımı (ör. "colour", "practise" fiil). Sade İngilizce: okuyan kişi büyük olasılıkla İngilizce öğrenen biri.

Uzunluklar Python'la sayıldı (`len()`, satır sonu 1 karakter; anahtar kelimeler UTF-8 bayt).

## Özet

| Alan | Sınır | Öneri | Uzunluk |
|---|---|---|---|
| Name | 30 karakter | `Lockglow: Vocabulary Widget` | 27 |
| Subtitle | 30 karakter | `English for Turkish Speakers` | 28 |
| Promotional Text | 170 karakter | aşağıda | 153 |
| Description | 4000 karakter | aşağıda | 3454 |
| Keywords | 100 bayt | aşağıda | 98 bayt |
| What's New | 4000 karakter | 1.0'da alan yok | — |

## Name

```text
Lockglow: Vocabulary Widget
```

`raporlar/08_aso_isim_metadata.md`'deki öneriyle aynı. "vocabulary widget" İngilizce aramada widget uygulamalarının uzun kuyruğu.

## Subtitle

```text
English for Turkish Speakers
```

Kime yapıldığını tek satırda söyler; rakiplerin İngilizce sayfalarından ayrılır. "english" ve "turkish" aranır.

**Yedek:** `Learn English Words in Turkish` (30).

## Promotional Text

153 karakter.

```text
An English word every time you look at your phone, with its Turkish meaning, an example and audio. Listen from the widget. Practise saying it with Söyle.
```

## Description

```text
You look at your phone dozens of times a day. Lockglow turns each look into a tiny English lesson: one word, with its Turkish meaning, right on your Lock Screen and Home Screen. You read it, hear it and learn it without opening the app.

Lockglow is made for Turkish speakers who are learning everyday English. Words are at A1, A2 and B1 level: food, travel, health, work and the English you need every day.

WHY IT WORKS
• A little every day: the word comes to you while you do something else.
• Explained in Turkish: every card has a Turkish meaning, an example sentence and its Turkish translation.
• Review before you forget: hard words come back often, easy words less often.
• See the mistake first: many cards show a mistake Turkish speakers often make, and the right way. For example, not "I did breakfast" but "I had breakfast".

LOCK SCREEN AND HOME SCREEN WIDGETS
• Small and medium Home Screen widgets; rectangular and one-line Lock Screen widgets.
• The speaker button on the Home Screen widget reads the word aloud without opening the app.
• "Biliyorum" (I know it) and "Sonraki" (next) buttons right on the Home Screen widget.
• You choose how often the word changes: from 5 minutes to 2 hours.
• A widget health screen shows whether your widget is updating.

933 WORD CARDS
• 179 A1, 418 A2 and 336 B1 cards.
• 668 words, 132 phrasal verbs, common phrases and collocations.
• Pronunciation (IPA), Turkish meaning, a short English definition and about 2,800 example sentences with Turkish translations.
• A "Dikkat" (watch out) box on 571 cards: the wrong and the right use, with a short note in Turkish.

REVIEW AND QUIZ
• Four answers for a new word: Bilemedim, Zor, Bildim, Kolay (didn't know, hard, knew it, easy). Each button shows when the word will come back.
• Leitner box system: a word comes back when it is due.
• Due words come back as a four-option fill-in-the-blank quiz. If you pick the wrong one, you see the right answer and its meaning at once.
• Daily goal for new words: 5, 10, 15 or 20.

SÖYLE: PRONUNCIATION PRACTICE
• Say the word or the example sentence aloud. Your phone listens and answers in Turkish: right, almost, or what to pay attention to.
• Recognition runs only on your iPhone. Your voice is not recorded and never leaves your phone.

DICTIONARY
• Search all cards in English or Turkish, even if you type "i" for "ı" or "s" for "ş".
• Example sentences and audio for every word.

START YOUR WAY
• On first launch, choose your level and topics; the app shows you how to add the widget, step by step.
• Topics include food and drink, home, family, shopping, health, city and transport, travel, the workplace, feelings, social life and phrasal verbs.
• Daily reminder: one notification at the time you choose, on days when you have words to study.
• Known words list: undo a word you marked by mistake.

PRIVACY
• No account, no ads, no tracking.
• Your progress stays on your phone; we cannot see it.
• Lockglow does not send your data to any server.

GOOD TO KNOW
• The app's interface and explanations are in Turkish.
• iPhone with iOS 17 or later.
• Söyle: on iOS 26 and later, the English speech model downloads on first use. On iOS 17–25 your phone needs on-device English (US) recognition.
• iOS decides exactly when a widget refreshes; sometimes it can be a few minutes late.

Privacy Policy: [PRIVACY POLICY URL]
Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```

3454 karakter. Türkçe açıklamanın eşdeğeri; aynı doğrulanmış sayılar. "The app's interface and explanations are in Turkish" satırı bilerek eklendi: İngiliz bir kullanıcı uygulamayı İngilizce öğretmeni sanıp hayal kırıklığıyla düşük puan vermesin.

## Keywords

```text
lock,screen,learn,words,flashcards,pronunciation,daily,vocab,dictionary,quiz,memorize,beginner,esl
```

98 karakter, **98 bayt** (sınır 100; hepsi ASCII). `memorize` ABD yazımıyla bırakıldı: anahtar kelimeler görünmez ve bu yazım daha çok aranıyor olabilir **[doğrulanmadı]**. Ad ve alt başlıktaki `lockglow`, `vocabulary`, `widget`, `english`, `turkish`, `speakers` tekrar edilmedi. "lock" + "screen" ile "lock screen", "vocabulary lock screen", "english words widget" gibi birleşimler oluşur (`raporlar/08` §1: düşük rekabetli widget uzun kuyruğu).

**Seçenek B (çapraz yerelleştirme, dolaylı kanıt):** Türkiye'de bu alan da arandığı için bazı geliştiriciler buraya Türkçe kelime koyar (ör. `defteri,kartı,çalışma`). Apple bunu belgelemiyor; İngiltere'deki kullanıcı için anlamsızdır. Önerim **A (yukarıdaki)**: ilk sürümde temiz kalsın, arama raporuna bakıp sonra karar verin.

## What's New

**1.0:** alan yok. TestFlight "What to Test" için (174 karakter):

```text
First release: Lock Screen and Home Screen widgets, 933 word cards, four-answer review, fill-in-the-blank quiz, dictionary, Söyle pronunciation practice and a daily reminder.
```

**1.1 ve sonrası için kalıp:**

```text
New
• [Feature]: [what it does for you, one sentence].
• [N] new words: [topics].

Fixes
• Fixed [problem].

If you enjoy Lockglow, a rating on the App Store helps a lot.
```
