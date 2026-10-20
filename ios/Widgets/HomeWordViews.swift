import SwiftUI
import WidgetKit
import CoreModels

// Fonts stay at 11 pt or above (`.caption2` is the smallest style used).
// Home widgets have roughly 126 x 126 pt (small) and 306 x 126 pt (medium) of content area
// (116 pt high on an iPhone SE); the 44 pt buttons take a large share of that, so the text is
// kept short.
// Three 44 pt buttons are 132 pt long: a little more than the content area of the small widget
// is wide on an SE (116 pt) and than the medium one is high (126 pt, SE 116 pt). The button group
// is therefore laid out at its natural size and extends into the 16 pt widget margin on both
// sides (`buttonGroupOverflow`): the text is not touched, the hit areas stay 44 x 44 pt.
// Reading order for an A2 learner: the word, the Turkish meaning (semibold, one step larger than
// the rest), the simple English definition, then the example (medium only).
// Layout: the header has the highest layout priority, the text block the next one, so they are
// sized before the spacer and the buttons. The text block is a ViewThatFits: it shows the
// fullest variant that fits the space left (measured on real cards by WidgetSnapshotTests),
// instead of truncating every line to one.

/// How far the 132 pt button group is allowed to reach into the widget margin, per side, at most.
private let buttonGroupOverflow: CGFloat = 8

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
            .layoutPriority(2)
            // The micro definition (at most 28 characters) is written for this family.
            ViewThatFits(in: .vertical) {
                textBlock(definitionLines: 2)
                textBlock(definitionLines: 1)
                textBlock(definitionLines: 0)
            }
            .layoutPriority(1)
            Spacer(minLength: 0)
            // Next, speaker, Know: 3 x 44 pt, centered; wider than the content area on an SE.
            HStack(spacing: 0) {
                NextWordButton(wordID: word.id, source: .systemSmall)
                SpeakWordButton(text: word.lemma)
                KnowWordButton(wordID: word.id, source: .systemSmall)
            }
            .padding(.horizontal, -buttonGroupOverflow)
            .frame(maxWidth: .infinity)
        }
    }

    private func textBlock(definitionLines: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let gloss = word.glossTR {
                // Up to two lines: glosses can be "sonunda kendini ... bulmak" (26 characters).
                Text(gloss)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if definitionLines > 0 || word.glossTR == nil {
                Text(word.defMicro)
                    .font(.caption)
                    .lineLimit(max(definitionLines, 1))
                    .fixedSize(horizontal: false, vertical: true)
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
                    Spacer(minLength: 0)
                    Text(word.level)
                        .font(.caption2.bold())
                }
                .layoutPriority(2)
                ViewThatFits(in: .vertical) {
                    textBlock(definitionLines: 2, showExample: true, showNextChange: true)
                    textBlock(definitionLines: 2, showExample: true, showNextChange: false)
                    textBlock(definitionLines: 1, showExample: true, showNextChange: false)
                    textBlock(definitionLines: 2, showExample: false, showNextChange: false)
                    textBlock(definitionLines: 1, showExample: false, showNextChange: false)
                }
                .layoutPriority(1)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // Buttons stacked in a column (a row would take the width of the text): speaker, Next,
            // Know. 3 x 44 pt is more than the content height, see `buttonGroupOverflow`.
            VStack(spacing: 0) {
                SpeakWordButton(text: word.lemma)
                NextWordButton(wordID: word.id, source: .systemMedium)
                KnowWordButton(wordID: word.id, source: .systemMedium)
            }
            .padding(.vertical, -buttonGroupOverflow)
            .frame(maxHeight: .infinity)
        }
    }

    private func textBlock(definitionLines: Int, showExample: Bool, showNextChange: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            if let gloss = word.glossTR {
                Text(gloss)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            Text(word.defShort)
                .font(.footnote)
                .lineLimit(definitionLines)
                .fixedSize(horizontal: false, vertical: true)
            if showExample {
                Text(word.exampleEN)
                    .font(.caption)
                    .italic()
                    .lineLimit(1)
            }
            if showNextChange, let next = entry.nextChange {
                HStack(spacing: 3) {
                    Text("Sonraki")
                    Text(next, style: .time)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
    }
}
