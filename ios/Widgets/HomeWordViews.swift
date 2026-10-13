import SwiftUI
import WidgetKit
import CoreModels

// Fonts stay at 11 pt or above (`.caption2` is the smallest style used).
// Home widgets have roughly 126 x 126 pt (small) and 306 x 126 pt (medium) of content area;
// the 44 pt buttons take a large share of that, so the text is kept short.
// Reading order for an A2 learner: the word, the Turkish meaning (semibold, one step larger than
// the rest), the simple English definition, then the example (medium only). The word and the
// meaning have a higher layout priority, so when space runs out the definition is cut first.

struct SmallWordView: View {
    let entry: WordEntry
    private var word: WidgetWord { entry.word }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(word.lemma)
                    .font(.title3.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .widgetAccentable()
                Spacer(minLength: 0)
                Text(word.level)
                    .font(.caption2.bold())
            }
            .layoutPriority(1)
            if let gloss = word.glossTR {
                // Up to two lines: glosses can be "dirençli, çabuk toparlanan" (28 characters).
                Text(gloss)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .layoutPriority(1)
            }
            Text(word.defShort)
                .font(.caption)
                .lineLimit(2)
            Spacer(minLength: 0)
            HStack(spacing: 0) {
                NextWordButton(wordID: word.id, source: .systemSmall)
                Spacer(minLength: 0)
                KnowWordButton(wordID: word.id, source: .systemSmall)
            }
        }
    }
}

struct MediumWordView: View {
    let entry: WordEntry
    private var word: WidgetWord { entry.word }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(word.lemma)
                        .font(.title3.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .widgetAccentable()
                    if let ipa = word.ipaUS {
                        Text(ipa)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                .layoutPriority(1)
                if let gloss = word.glossTR {
                    Text(gloss)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .layoutPriority(1)
                }
                Text(word.defShort)
                    .font(.footnote)
                    .lineLimit(2)
                Text(word.exampleEN)
                    .font(.caption)
                    .italic()
                    .lineLimit(1)
                Spacer(minLength: 0)
                // Show the "next word" label only when it fits next to the part of speech.
                ViewThatFits(in: .horizontal) {
                    metaRow(showNextLabel: true)
                    metaRow(showNextLabel: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // Buttons stacked in a column: two 44 pt targets fit the height, a row would not.
            VStack(spacing: 0) {
                NextWordButton(wordID: word.id, source: .systemMedium)
                KnowWordButton(wordID: word.id, source: .systemMedium)
            }
        }
    }

    private func metaRow(showNextLabel: Bool) -> some View {
        HStack(spacing: 8) {
            Text("\(word.pos) · \(word.level)")
                .font(.caption)
            Spacer(minLength: 0)
            if showNextLabel, let next = entry.nextChange {
                HStack(spacing: 3) {
                    Text("Sonraki")
                    Text(next, style: .time)
                }
                .font(.caption)
                .fixedSize()
            }
        }
    }
}
