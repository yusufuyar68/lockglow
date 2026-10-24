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
/// shorter forms (`WidgetGloss`), and only when none fits is it left out. Above the default size
/// the word grows with the text size beside its meaning and never stands below it. When the word
/// and its meaning do not fit at the person's text size, the variants are tried again one text
/// size smaller at a time (AX4, AX3, AX2, AX1, xxxLarge, xxLarge, xLarge), then at the default
/// size, so the widget shows the largest text size at which the word and its meaning fit: never
/// straight down to the default size (the 2026-10-24 AX3 images were the default size, smaller
/// than AX1 and xxxLarge), and in the accessibility sizes never the word alone while a smaller
/// size keeps the meaning (AX1 left out the meaning that xxxLarge kept; this replaces the word
/// alone of ogrenme_ilkeleri 2.1). The word stands alone only when its meaning fits in no form,
/// even at the default size. On the Always-On display the text keeps its gray levels; the system
/// dims the screen.
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
            variants(at: dynamicTypeSize)
            // The person's size leaves no room for the word and its meaning: the same variants one
            // text size smaller at a time, so a larger size never drops straight to the default
            // size nor leaves the meaning out while a smaller size keeps it.
            smallerSizes
            // Nothing fits even at xLarge: the default text size, which draws exactly the default
            // layout, so the word and its meaning stay together. The 17 pt word comes first on its
            // own: at the default size and below it is the 17 pt step of the next variant, which
            // it draws the same way, so the default layout is unchanged.
            rows([WidgetWordStep(size: 17)], meaning: .subheadline.weight(.semibold), lines: [1, 2])
                .dynamicTypeSize(...DynamicTypeSize.large)
            // xLarge's 16.5 pt word over a 15 pt meaning: after the default 17 pt word over the
            // same meaning, before the default 15 pt word (`footnoteVariant`).
            footnoteVariant(at: .xLarge)
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
        // No animation when the word changes on the Lock Screen (WidgetMotion.swift).
        .widgetWordChange(id: word.id, lockScreen: true)
        .padding(margins)
        .widgetTurkishVoice()
    }

    /// The variants at the text size `size`, the size they are drawn at, fullest first. At the
    /// default size and below they are those of the default layout. Above it the word grows with
    /// the text size beside the meaning and never stands below it (the 2026-10-22 images showed
    /// "misunderstanding" smaller than "yanlış anlaşılma" at xxxLarge): the 15 pt step, scaled or
    /// not, is smaller than a `.subheadline` meaning there (xxxLarge 19.5 pt under 21 pt: "lost and
    /// found"; AX1 23.25 pt under 25 pt: "I can't wait"), so beside that meaning the word keeps its
    /// 17 pt step, and the 15 pt step takes the `.footnote` meaning (xxxLarge 19 pt, AX1 23 pt). In
    /// the standard sizes that variant comes later (`footnoteVariant`).
    @ViewBuilder
    private func variants(at size: DynamicTypeSize) -> some View {
        let wordSteps = size <= .large ? WidgetWordStep.lockScreen : [WidgetWordStep(size: 17)]
        rows(wordSteps, meaning: .subheadline.weight(.semibold), lines: [1])
        // A long meaning without a short form (the user's own words have none; every card's
        // meaning over 16 characters has `gloss_short`): the whole meaning on two lines
        // rather than no meaning ("bir şeyden / bıkmış olmak").
        rows(wordSteps, meaning: .subheadline.weight(.semibold), lines: [2])
        if size <= .large {
            rows(WidgetWordStep.homeFloorScaled, meaning: .subheadline.weight(.semibold), lines: [1])
        }
        if size <= .large || size.isAccessibilitySize {
            rows(WidgetWordStep.homeFloorScaled, meaning: .footnote.weight(.semibold), lines: [1, 2])
        }
    }

    /// The variants again at each text size between the person's and the default one, largest
    /// first. A size that is not smaller than the person's adds nothing (those variants were
    /// tried at the person's size). The retries are groups: a modifier on a Group applies to each
    /// of its views, and ViewThatFits tries them one by one, as if they were listed in `body`.
    @ViewBuilder
    private var smallerSizes: some View {
        smallerVariants(at: .accessibility4)
        smallerVariants(at: .accessibility3)
        smallerVariants(at: .accessibility2)
        smallerVariants(at: .accessibility1)
        smallerVariants(at: .xxxLarge)
        smallerVariants(at: .xxLarge)
        footnoteVariant(at: .xxxLarge)
        smallerVariants(at: .xLarge)
        footnoteVariant(at: .xxLarge)
    }

    /// The variants drawn at `size` when it is smaller than the person's text size; else nothing.
    @ViewBuilder
    private func smallerVariants(at size: DynamicTypeSize) -> some View {
        if size < dynamicTypeSize {
            Group {
                variants(at: size)
            }
            .dynamicTypeSize(size)
        }
    }

    /// The 15 pt step over the `.footnote` meaning at a standard size above the default one
    /// (xLarge to xxxLarge), when the person's size is at least that size; else nothing. It comes
    /// after the variants one size smaller: there the 17 pt step stands over a `.subheadline`
    /// meaning of the same size and is larger (xxLarge 20.4 pt over 19 pt before xxxLarge's 19.5
    /// pt over 19 pt; the default 17 pt over 15 pt before xLarge's 16.5 pt over 15 pt), so a larger
    /// size never shows a smaller word over the same meaning.
    @ViewBuilder
    private func footnoteVariant(at size: DynamicTypeSize) -> some View {
        if size <= dynamicTypeSize {
            rows(WidgetWordStep.homeFloorScaled, meaning: .footnote.weight(.semibold), lines: [1, 2])
                .dynamicTypeSize(size)
        }
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
        // No animation when the word changes on the Lock Screen (WidgetMotion.swift).
        .widgetWordChange(id: word.id, lockScreen: true)
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
