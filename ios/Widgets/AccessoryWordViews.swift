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
/// shorter forms (`WidgetGloss`), and only when none fits is it left out. From xLarge to xxxLarge a
/// meaning that does not fit at the person's text size is shown at the default size instead, with
/// the word. In the accessibility sizes the word stands alone when it fits at a scaled size, which
/// is always larger than at the default size; when it does not, the word and its meaning are shown
/// at the default size (ogrenme_ilkeleri 2.1). It is never shown alone at an unscaled 15 pt while
/// a meaning would fit. On the Always-On display the text keeps its gray levels; the system dims
/// the screen.
struct RectangularWordView: View {
    let entry: WordEntry
    /// The widget's content margins (`widgetContentMargins`).
    var margins = EdgeInsets()
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var word: WidgetWord { entry.word }
    private var colors: WidgetColors { WidgetColors.lockScreen }

    var body: some View {
        ViewThatFits(in: .vertical) {
            rows(WidgetWordStep.lockScreen, meaning: .subheadline.weight(.semibold), lines: [1])
            // A long meaning without a short form (the user's own words have none; every card's
            // meaning over 16 characters has `gloss_short`): the whole meaning on two lines
            // rather than no meaning ("bir şeyden / bıkmış olmak").
            rows(WidgetWordStep.lockScreen, meaning: .subheadline.weight(.semibold), lines: [2])
            rows(WidgetWordStep.homeFloor, meaning: .subheadline.weight(.semibold), lines: [1])
            rows(WidgetWordStep.homeFloor, meaning: .footnote.weight(.semibold), lines: [1, 2])
            rows(WidgetWordStep.homeFloor, lastResort: true, meaning: .footnote.weight(.semibold), lines: [1])
            // The accessibility sizes (ogrenme_ilkeleri 2.1): the word alone, but only at a scaled
            // step, so it is larger than at the default size. The padding holds the band line
            // under the last line, which hangs below the text frame.
            if dynamicTypeSize.isAccessibilitySize {
                WidgetFittingWord(
                    lemma: word.lemma,
                    steps: WidgetWordStep.homeFloorScaled,
                    colors: colors,
                    renderingMode: renderingMode
                )
                .padding(.bottom, 4)
            }
            // Otherwise the default text size, which draws exactly the default layout: the word
            // and its meaning stay together (from xLarge up, and in the accessibility sizes when
            // the larger word does not fit).
            rows(WidgetWordStep.lockScreen, meaning: .subheadline.weight(.semibold), lines: [1, 2])
                .dynamicTypeSize(...DynamicTypeSize.large)
            rows(WidgetWordStep.homeFloor, meaning: .subheadline.weight(.semibold), lines: [1])
                .dynamicTypeSize(...DynamicTypeSize.large)
            rows(WidgetWordStep.homeFloor, meaning: .footnote.weight(.semibold), lines: [1, 2])
                .dynamicTypeSize(...DynamicTypeSize.large)
            rows(WidgetWordStep.homeFloor, lastResort: true, meaning: .footnote.weight(.semibold), lines: [1, 2])
                .dynamicTypeSize(...DynamicTypeSize.large)
            // A meaning that fits in no form: the word alone, never taller than the widget.
            WidgetWordAlone(lemma: word.lemma, colors: colors, renderingMode: renderingMode)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(margins)
        .widgetTurkishVoice()
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
            let forms = WidgetGloss.forms(of: word)
            if !forms.isEmpty {
                WidgetMeaning(forms: forms, typeface: typeface, lines: lines, color: colors.ink2)
                    // Room for the band line, which hangs below the word's frame.
                    .padding(.top, 5)
            }
        }
    }
}

/// One line of system text (the family ignores fonts), shortened step by step when it does not
/// fit: "actually · aslında, gerçekte" → "actually · aslında" (the shorter form) → "actually".
/// The meaning's forms are those of the other widgets (`WidgetGloss`): never cut, a " / " pair
/// stays whole.
/// The family shows a single Text, so VoiceOver gets its own two elements instead (text audit
/// #15, accessibility audit V5): the word with an English voice, then "Türkçesi: …" with the
/// whole meaning in the device's voice; the "·" is not read.
struct InlineWordView: View {
    let entry: WordEntry
    private var word: WidgetWord { entry.word }

    /// The line's versions, fullest first, the word alone last.
    static func versions(of word: WidgetWord) -> [String] {
        let forms = WidgetGloss.forms(of: word)
        // Every card has a Turkish meaning; the English micro definition is only a fallback.
        let meanings = (forms.isEmpty ? [word.defMicro] : forms).filter { meaning in
            !meaning.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return meanings.map { "\(word.lemma) · \($0)" } + [word.lemma]
    }

    var body: some View {
        let slots = WidgetFit.slots(InlineWordView.versions(of: word))
        ViewThatFits(in: .horizontal) {
            Text(verbatim: slots[0])
            Text(verbatim: slots[1])
            Text(verbatim: slots[2])
            Text(verbatim: slots[3])
            Text(verbatim: slots[4])
            Text(verbatim: slots[5])
        }
        .widgetAccentable()
        .accessibilityRepresentation {
            spoken
        }
        .widgetTurkishVoice()
    }

    /// What VoiceOver reads: two elements, so each keeps its own voice (`.combine` or one label
    /// would read both with one voice).
    private var spoken: some View {
        HStack {
            Text(verbatim: word.lemma)
                .widgetEnglishVoice()
            if let meaning = WidgetGloss.forms(of: word).first {
                Text(verbatim: "Türkçesi: \(meaning)")
                    .widgetTurkishVoice()
            }
        }
    }
}
