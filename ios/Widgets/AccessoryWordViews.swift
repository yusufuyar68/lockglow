import SwiftUI
import WidgetKit
import CoreModels

// Lock Screen families: static text only, no buttons. In vibrant rendering the system tints
// everything, so the headword is marked accentable and nothing relies on color.

/// Three lines: the word, the Turkish meaning (semibold), the micro definition. Everything is
/// one line; the rectangular family is about 72 pt tall (22 + 20 + 16 pt of text).
struct RectangularWordView: View {
    let entry: WordEntry
    private var word: WidgetWord { entry.word }

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(word.lemma)
                .font(.headline)
                .lineLimit(1)
                .widgetAccentable()
            if let gloss = word.glossTR {
                Text(gloss)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Text(word.defMicro)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InlineWordView: View {
    let entry: WordEntry
    private var word: WidgetWord { entry.word }

    var body: some View {
        Text("\(word.lemma) · \(word.glossTR ?? word.defMicro)")
            .widgetAccentable()
    }
}
