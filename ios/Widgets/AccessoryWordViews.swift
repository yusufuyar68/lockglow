import SwiftUI
import WidgetKit
import CoreModels

// Lock Screen families: static text only, no buttons (they would not work while the device is
// locked). The system draws them in vibrant mode (accented where the Lock Screen is tinted), where
// only luminance and opacity count: the text uses the system's hierarchical styles, the word and
// its thin band line are accentable, and nothing relies on color.

/// Three rows (mockup `.ls .rect`): the word in serif bold with the thin band line under it, the
/// Turkish meaning (semibold), the micro definition. The family is about 160 x 72 pt. As on the
/// home widgets, every row is shown whole or not at all: the variants drop the definition, put a
/// long meaning on two smaller lines, then let a long word shrink. On the Always-On display
/// (`isLuminanceReduced`) the definition is left out: the dimmed screen keeps the word and its
/// meaning. The widget draws `AccessoryWidgetBackground` behind it (`WordWidgetView`), so the text
/// keeps an inner padding of at least 5 x 12 pt.
struct RectangularWordView: View {
    let entry: WordEntry
    /// The widget's content margins (`widgetContentMargins`); used when larger than the padding.
    var margins = EdgeInsets()
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    /// Replaces the environment's `isLuminanceReduced` (snapshot tests only).
    var luminanceReduced: Bool? = nil
    @Environment(\.isLuminanceReduced) private var environmentLuminanceReduced
    private var word: WidgetWord { entry.word }
    private var colors: WidgetColors { WidgetColors.system }
    private var isDimmed: Bool { luminanceReduced ?? environmentLuminanceReduced }

    var body: some View {
        ViewThatFits {
            rows(.large, meaningLines: 1, definition: !isDimmed)
            rows(.large, meaningLines: 1)
            rows(.large, meaningLines: 2)
            rows(.small, meaningLines: 1)
            rows(.small, meaningLines: 2)
            fallbackRows
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(EdgeInsets(
            top: max(margins.top, 5),
            leading: max(margins.leading, 12),
            bottom: max(margins.bottom, 5),
            trailing: max(margins.trailing, 12)
        ))
    }

    /// The word and, in reading order, the meaning in `meaningLines` lines (15 pt on one line,
    /// 13 pt on two) and, when `definition`, the micro definition. A card without a meaning shows
    /// the micro definition in its place.
    private func rows(_ fit: WidgetWordFit, meaningLines: Int, definition: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            headword(fit)
            if let gloss = word.glossTR {
                WidgetMeaning(gloss: gloss, typeface: meaningFont(lines: meaningLines), lines: meaningLines, color: colors.ink)
                if definition {
                    WidgetDefinition(text: word.defMicro, typeface: .system(.caption, design: .serif), color: colors.ink2)
                }
            } else {
                WidgetDefinition(text: word.defMicro, typeface: .system(.caption, design: .serif), lines: meaningLines, color: colors.ink2)
            }
        }
    }

    /// The fallback for the longest phrases and the largest text sizes: the word at 15 pt shrinking
    /// as far as it must ("Could you tell me the way to" fits whole only this way), the meaning
    /// wrapping onto two lines in the room left.
    private var fallbackRows: some View {
        VStack(alignment: .leading, spacing: 1) {
            headword(.small, typeface: Font.system(.subheadline, design: .serif).weight(.bold))
                .layoutPriority(1)
            if let gloss = word.glossTR {
                WidgetMeaning(gloss: gloss, typeface: meaningFont(lines: 2), lines: 2, wraps: true, color: colors.ink)
            } else {
                WidgetDefinition(text: word.defMicro, typeface: .system(.caption, design: .serif), color: colors.ink2)
            }
        }
    }

    /// The word at 17 pt unless `typeface` says otherwise.
    private func headword(_ fit: WidgetWordFit, typeface: Font? = nil) -> some View {
        WidgetWordLines(
            lemma: word.lemma,
            fit: fit,
            typeface: typeface ?? Font.system(.headline, design: .serif).weight(.bold),
            colors: colors,
            renderingMode: renderingMode
        )
        // Room for the band line, which hangs below the word's frame.
        .padding(.bottom, 4)
    }

    private func meaningFont(lines: Int) -> Font {
        return lines > 1 ? .footnote.weight(.semibold) : .subheadline.weight(.semibold)
    }
}

/// One line of system text (the family ignores fonts), shortened step by step when it does not
/// fit: "actually · aslında, gerçekte" → "actually · aslında" → "actually".
struct InlineWordView: View {
    let entry: WordEntry
    private var word: WidgetWord { entry.word }
    private var meaning: String { word.glossTR ?? word.defMicro }

    /// The meaning's first sense: the gloss up to its first comma (or semicolon).
    private var firstMeaning: String {
        let first = meaning.split(whereSeparator: { $0 == "," || $0 == ";" }).first.map(String.init) ?? meaning
        let trimmed = first.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? meaning : trimmed
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Text(verbatim: "\(word.lemma) · \(meaning)")
            Text(verbatim: "\(word.lemma) · \(firstMeaning)")
            Text(verbatim: word.lemma)
        }
        .widgetAccentable()
    }
}
