import SwiftUI
import WidgetKit
import CoreModels

// Lock Screen families: static text only, no buttons (they would not work while the device is
// locked). The system draws them in vibrant mode, where only luminance and opacity count: the
// text uses the system's hierarchical styles, the word and its thin band line are accentable,
// and nothing relies on color.

/// Three rows (mockup `.ls .rect`): the word in serif bold with the thin band line under it, the
/// Turkish meaning (semibold), the micro definition. Every row is one line; the family is about
/// 160 x 72 pt. Rows are dropped from the end when a large text size leaves no room. The widget
/// draws `AccessoryWidgetBackground` behind it (`WordWidgetView`), so the text keeps an inner
/// padding of at least 5 x 12 pt.
struct RectangularWordView: View {
    let entry: WordEntry
    /// The widget's content margins (`widgetContentMargins`); used when larger than the padding.
    var margins = EdgeInsets()
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    private var word: WidgetWord { entry.word }
    private var colors: WidgetColors { WidgetColors.system }

    var body: some View {
        ViewThatFits(in: .vertical) {
            rows(belowWord: 2)
            rows(belowWord: 1)
            rows(belowWord: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(EdgeInsets(
            top: max(margins.top, 5),
            leading: max(margins.leading, 12),
            bottom: max(margins.bottom, 5),
            trailing: max(margins.trailing, 12)
        ))
    }

    /// The word and the first `belowWord` rows under it, in reading order: the meaning (when the
    /// card has one), then the micro definition.
    private func rows(belowWord: Int) -> some View {
        let definitionRank = word.glossTR == nil ? 1 : 2
        return VStack(alignment: .leading, spacing: 1) {
            WidgetHeadword(
                lemma: word.lemma,
                typeface: Font.system(.headline, design: .serif).weight(.bold),
                color: colors.ink,
                renderingMode: renderingMode
            )
            // Room for the band line, which hangs below the word's frame.
            .padding(.bottom, 4)
            if belowWord >= 1, let gloss = word.glossTR {
                WidgetMeaning(gloss: gloss, typeface: .subheadline.weight(.semibold), maxLines: 1, color: colors.ink)
            }
            if belowWord >= definitionRank {
                Text(word.defMicro)
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(colors.ink2)
                    .lineLimit(1)
                    .widgetEnglishVoice()
            }
        }
    }
}

/// One line of system text (the family ignores fonts), shortened step by step when it does not
/// fit: "actually · aslında, gerçekte" → "actually · aslında" → "actually".
struct InlineWordView: View {
    let entry: WordEntry
    private var word: WidgetWord { entry.word }
    private var meaning: String { word.glossTR ?? word.defMicro }

    /// The meaning's first sense: the gloss up to its first comma.
    private var firstMeaning: String {
        let first = meaning.split(separator: ",", maxSplits: 1).first.map(String.init) ?? meaning
        let trimmed = first.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? meaning : trimmed
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Text(verbatim: "\(word.lemma) · \(meaning)")
            Text(verbatim: "\(word.lemma) · \(firstMeaning)")
            Text(word.lemma)
        }
        .widgetAccentable()
    }
}
