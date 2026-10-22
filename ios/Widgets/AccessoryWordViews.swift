import SwiftUI
import WidgetKit
import CoreModels

// Lock Screen families (docs/tasarim/ogrenme_ilkeleri.md 2.1): static text only, no buttons (they
// would not work while the device is locked) and the Turkish meaning is never hidden behind a tap.
// The system draws them in vibrant mode over the wallpaper and draws their background itself: the
// widget brings only its gray levels (`WidgetColors.lockScreen`, opaque grays, never opacity), the
// word and its thin band line are accentable, and nothing relies on color.

/// Two rows (ogrenme_ilkeleri 2.1): the word in serif bold (17 pt, then 15) with the thin band
/// line under it, and the Turkish meaning in SF semibold (15 pt) in a darker gray. No third row:
/// the English definition is not shown here. The family is 160 x 72 pt (153 x 68 on an iPhone SE).
/// As on the home widgets, every line is shown whole or not at all: the meaning first tries its
/// shorter forms (`WidgetGloss`), and only when none fits is it left out. On the Always-On display
/// the text keeps its gray levels; the system dims the screen.
struct RectangularWordView: View {
    let entry: WordEntry
    /// The widget's content margins (`widgetContentMargins`).
    var margins = EdgeInsets()
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    private var word: WidgetWord { entry.word }
    private var colors: WidgetColors { WidgetColors.lockScreen }

    var body: some View {
        ViewThatFits(in: .vertical) {
            rows(WidgetWordStep.lockScreen, meaning: .subheadline.weight(.semibold), lines: [1])
            // Until every long meaning has its short form (`gloss_short`): the whole meaning on
            // two lines rather than no meaning ("kendini pek iyi / hissetmemek").
            rows(WidgetWordStep.lockScreen, meaning: .subheadline.weight(.semibold), lines: [2])
            rows(WidgetWordStep.homeFloor, meaning: .subheadline.weight(.semibold), lines: [1])
            rows(WidgetWordStep.homeFloor, meaning: .footnote.weight(.semibold), lines: [1, 2])
            rows(WidgetWordStep.homeFloor, lastResort: true, meaning: .footnote.weight(.semibold), lines: [1])
            // Large text sizes and phrases whose meaning fits in no form: the word alone.
            WidgetFittingWord(
                lemma: word.lemma,
                steps: WidgetWordStep.homeFloor,
                lastResort: true,
                colors: colors,
                renderingMode: renderingMode
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(margins)
    }

    /// One layout variant: the word at the first of `steps` that fits and the meaning in
    /// `typeface` on the first of `lines` line counts that fits.
    private func rows(
        _ steps: [WidgetWordStep],
        lastResort: Bool = false,
        meaning typeface: Font,
        lines: [Int]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetFittingWord(
                lemma: word.lemma,
                steps: steps,
                lastResort: lastResort,
                colors: colors,
                renderingMode: renderingMode
            )
            if word.glossTR != nil {
                WidgetMeaning(forms: WidgetGloss.forms(of: word), typeface: typeface, lines: lines, color: colors.ink2)
                    // Room for the band line, which hangs below the word's frame.
                    .padding(.top, 5)
            }
        }
    }
}

/// One line of system text (the family ignores fonts), shortened step by step when it does not
/// fit: "actually · aslında, gerçekte" → "actually · aslında" → (the short form) → "actually".
/// The meaning's forms are those of the other widgets (`WidgetGloss`): never cut, a " / " pair
/// stays whole.
struct InlineWordView: View {
    let entry: WordEntry
    private var word: WidgetWord { entry.word }

    /// The line's versions, fullest first, the word alone last.
    private var versions: [String] {
        let forms = WidgetGloss.forms(of: word)
        let meanings = forms.isEmpty ? [word.defMicro] : forms
        return meanings.map { "\(word.lemma) · \($0)" } + [word.lemma]
    }

    var body: some View {
        let slots = WidgetFit.slots(versions)
        ViewThatFits(in: .horizontal) {
            Text(verbatim: slots[0])
            Text(verbatim: slots[1])
            Text(verbatim: slots[2])
            Text(verbatim: slots[3])
            Text(verbatim: slots[4])
            Text(verbatim: slots[5])
        }
        .widgetAccentable()
    }
}
