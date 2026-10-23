# Kelime kartları: tasarım brifi (Codex için)

Ürün bir iPhone uygulaması (SwiftUI + WidgetKit), İngilizce kelime öğretiyor, arayüz Türkçe.
Aşağıdaki her yüzey için **3 farklı tasarım yönü** iste. Mockup'lar 390×844 pt telefon çerçevesinde olsun,
widget'lar gerçek widget boyutlarında. Masaüstü ya da web düzeni olmasın.

## Tasarlanacak yüzeyler

| # | Yüzey | Kod | Not |
|---|-------|-----|-----|
| 1 | **Akış kartı** (ana kart, tam sayfa, dikey kaydırmalı akış) | `ios/App/FeedCardView.swift` | En önemli yüzey. İlk karşılaşma ve tekrar hâlleri ayrı. |
| 2 | **Kartın tamamı / ayrıntı** (örnekler, hata kutusu, "Neden?" sheet'i) | `ios/App/CardDetailViews.swift` | `ExampleRow`, `MistakeBox`, `CardWhySheet` |
| 3 | **Quiz kartı** (boşluk doldurma, 4 şık, geri bildirim) | `ios/App/QuizCardView.swift` | "Boşluğa hangisi gelir?", "Doğrusu: …", "Zor muydu, kolay mı?" |
| 4 | **Cümle kurma kartı** (kelime karolarıyla cümle dizme) | `ios/App/SentencePracticeCards.swift` → `SentenceBuildCard` | |
| 5 | **Eşdizim seçme kartı** (collocation) | `ios/App/SentencePracticeCards.swift` → `CollocationChoiceCard` | |
| 6 | **Kelime widget'ı: küçük** | `ios/Widgets/HomeWordViews.swift` | "Sonraki" düğmesi |
| 7 | **Kelime widget'ı: orta** | `ios/Widgets/HomeWordViews.swift` | "Biliyorum" + "Sonraki" |
| 8 | **Kelime widget'ı: büyük** | `ios/Widgets/LargeWordView.swift` | Tanım + örnek |
| 9 | **Kilit ekranı: dikdörtgen + satır içi** | `ios/Widgets/AccessoryWordViews.swift` | Tek renk (vibrant) çizilir |
| 10 | **Quiz widget'ı: orta + büyük** | `ios/Widgets/QuizWidgetViews.swift` | Şıklara widget içinden dokunuluyor |
| 11 | **Haftalık özet paylaşım kartı** | `ios/App/WeeklyRecapShareCard.swift` | Paylaşılan görsel |

Önce 1, 6–9 birlikte tasarlanmalı: aynı kelimenin farklı yüzleri, aynı dili konuşmalı.

## Kartta ne var (veri)

Bir kart (`content/cards/`, örnek: `content-pipeline/data/gold_cards.json`):

- `lemma` (kelime), `pos` (tür: n/v/adj…), `level` (A1–C2), `ipa.us` / `ipa.uk`
- `def.micro` / `def.short` / `def.long` (İngilizce tanım; A1–A2 ilk karşılaşmada micro)
- `l1.tr.gloss` (Türkçe anlam), `l1.tr.note`, `l1.tr.mnemonic`, `l1.tr.false_friend`
- `l1.tr.mistakes[]`: `wrong` / `right` / `why` (Türklerin sık hatası)
- `examples[]`: `en` + `tr` (öğrenilen kelime cümlede işaretli)
- `collocations[]`, `synonyms[]`, `etymology.text`
- `quiz`: `cloze` + `answer` + `distractors[3]`

Akış kartında gösterilen bloklar (ilk karşılaşmada en çok 8 blok + 1 uyarı yeri):
üst satır (telaffuz · tür · seviye · "Şu an kilitli ekranda" · durum: "Yeni kelime" / "Öğreniyorsun" / "Bildiğin kelime"),
kelime, Türkçe anlam, İngilizce tanım, örnek cümle + çevirisi, uyarı ("Dikkat" + tek "Neden?"),
düğmeler "Dinle" · "Söyle" · "Biliyorum", ilk kartlarda "Yukarı kaydır" ipucu.

## Hâller (her yön bunları göstermeli)

- İlk karşılaşma / daha önce görülmüş / bilinen kelime
- Kısa kelime (*breakfast*) ve uzun kelime + uzun örnek cümle (*serendipity*, *nevertheless*)
- Uyarılı kart (false friend ya da sık hata) ve uyarısız kart
- Açık mod, koyu mod
- iPhone SE (375×667) ve en büyük erişilebilir yazı (AX5): kart kısalır, metin "…" ile kesilmez, satır kayar

## Kurallar (proje CLAUDE.md'sinden, uyulmalı)

- Apple HIG'den ayrılma; standart denetimler, sheet, SF Symbols.
- Yazı boyları Dynamic Type stilleri: Large Title 34, Title 1 28, Title 2 22, Title 3 20, Headline/Body 17,
  Callout 16, Subheadline 15, Footnote 13, Caption 12/11. Bir ekranda en çok 3–4 boy; 11 pt altı yok.
- Türkçe metin SF Pro; İngilizce kelime ve örnek cümle New York (serif) olabilir.
- Renk: label / secondaryLabel / tertiaryLabel; zemin systemBackground / secondarySystemBackground.
  Tek vurgu rengi marka sarısı; yalnız vurgu, büyük dolgu değil. Kontrast ≥ 4.5:1 (büyük yazı ≥ 3:1).
- 16 pt kenar boşluğu, 8 pt ızgara, dokunma alanı ≥ 44×44 pt, güvenli alan ve Dynamic Island.
- Dokunulamayan şey kapsül olmaz (seviye düz metin + noktalar).
- Widget'lar Apple'ın widget kenar boşluklarıyla.

## Teslim

Her yön için: kısa isim + bir cümle fikir, yukarıdaki hâllerle mockup'lar, kullanılan yazı stilleri ve renk token'ları listesi.
Kod yazma; seçilen yön ayrıca SwiftUI'a geçirilecek.
