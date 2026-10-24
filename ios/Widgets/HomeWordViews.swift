import SwiftUI
import WidgetKit
import CoreModels

// Home Screen widgets (docs/tasarim/README.md "Widget'lar", docs/tasarim/ogrenme_ilkeleri.md 2.1,
// mockup `.wg`): paper and ink, the phosphor band under the English word as the only bright mark.
// English text is serif, Turkish and UI text SF Pro (no rounded, no italic). Fonts stay at 11 pt or
// above (`.caption2` is the smallest style used); only a 16-letter word on an iPhone SE shrinks a
// little below its 15 pt floor (`WidgetFittingWord`, last resort).
// Home widgets have roughly 126 x 126 pt (small) and 306 x 126 pt (medium) of content area
// (116 x 116 and 289 x 116 pt on an iPhone SE); the 44 pt buttons take a large share of that.
// Buttons (WidgetButtons.swift): the small widget has two, speaker and Next. Three 44 pt buttons
// would take 132 pt, more than an SE's 116 pt, with no room between them (ogrenme_ilkeleri 2.1);
// Know is on the medium widget and in the app. The medium widget keeps Know, speaker, Next in a
// column. The widget disables the system content margins (`WordWidget`); these views apply them
// (`margins`, from `widgetContentMargins`) and draw the buttons in an overlay that reaches
// `buttonGroupOverflow` into the margin on the widget's outer edges (small: left, right and
// bottom; medium: top, right and bottom), so each 34 pt circle sits 11 pt from those edges (HIG
// Widgets: the tighter 11 pt margin for buttons and shapes; text keeps the 16 pt margins). The
// hit areas stay 44 x 44 pt and inside the widget's root view; a placeholder holds the part of the
// buttons that lies inside the margins, so the text never runs under them at any text size
// (accessibility audit D5). The glyphs stop growing at xxLarge: Next (forward.fill) is about 1.4 ×
// the font size and still fits the 34 pt circle there; at xxxLarge it touched the edge, at AX1 it
// ran out of it.
// Reading at a glance (A2 learner): the small widget shows the word and its Turkish meaning and
// nothing else. The medium widget adds a quiet (`ink2`) definition, example and next change.
// Layout: every line is shown whole or not at all, never cut with "…" and never broken inside a
// word. The text column is a vertical ViewThatFits over layout variants, fullest first: each
// variant gets the column's width, and the first whose height fits is shown. Inside a variant,
// each line that can shorten picks its own step for that width (`WidgetFittingWord`,
// `WidgetFittingText`). A line with no step that fits makes its variant too tall to be chosen
// (`WidgetFit.reject`), so the next variant tries smaller type or more lines. When the person's
// text size leaves no room for the meaning, the variants are tried again at smaller text sizes,
// so the meaning stays and is never larger than the word: the home widgets above AX1 at AX1
// first, then at xxxLarge, then at the default size; the Lock Screen rectangle at the default
// size (`RectangularWordView`). The home widgets' text area does not grow with the
// text size (fixed margins and button place), so at the default size they draw exactly the
// default layout, which has the meaning. The last variant, the word alone, always fits, in
// height too (`WidgetWordAlone`).

/// How far the button group reaches into the widget margin on the widget's outer edges: with the
/// 5 pt between a 34 pt circle and its 44 pt hit area, the circle sits 16 - 10 + 5 = 11 pt from the
/// edge (HIG Widgets' tighter margin).
private let buttonGroupOverflow: CGFloat = 10
/// Space between the word and the meaning: the night band hangs about 4 pt below the word's
/// frame (LockglowTheme, "Phosphor band").
private let headerGap: CGFloat = 6

struct SmallWordView: View {
    let entry: WordEntry
    /// The widget's content margins (`widgetContentMargins`); WidgetKit's default for home widgets.
    var margins = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    /// Replaces the environment's `showsWidgetContainerBackground` (snapshot tests only).
    var showsBackground: Bool? = nil
    /// is5-w-ayar: "Widget'ı Düzenle" choices (WidgetConfigurationOptions.swift).
    var options = WidgetDisplayOptions.standard
    @Environment(\.widgetRenderingMode) private var environmentRenderingMode
    @Environment(\.showsWidgetContainerBackground) private var environmentShowsBackground
    private var word: WidgetWord { entry.word }
    private var colors: WidgetColors {
        WidgetColors.forMode(
            renderingMode ?? environmentRenderingMode,
            showsBackground: showsBackground ?? environmentShowsBackground
        )
    }
    /// The part of the button row that lies in the bottom margin.
    private var bottomOverflow: CGFloat { min(buttonGroupOverflow, margins.bottom) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ogrenme_ilkeleri 2.1: the word steps down 22 → 20 → 17 pt (a phrase may take two
            // lines), then to 15 pt; the meaning starts at 17 pt bold and tries its shorter forms
            // (`WidgetGloss`) on one line, then on two, before it gets smaller. At large text sizes
            // the word and the meaning are shown (2.1): when they do not fit at the person's size,
            // the same variants are tried again at AX1 (above it), at the largest standard size,
            // then at the default size, and only then is the meaning left out (the word alone, the
            // last variant). The meaning is never larger than the word: beside a meaning the word
            // grows with the text size, and it drops to an unscaled 15 pt (or shrinks a little,
            // "misunderstanding" on an SE) only in the last variant at the default size, beside a
            // 13 pt meaning, and in the word alone. (A 15 pt word beside an xxxLarge meaning was
            // the 2026-10-22 images' "small word, large meaning".)
            // The retries are groups: a modifier on a Group applies to each of its views, and
            // ViewThatFits tries them one by one, as if they were listed here.
            ViewThatFits(in: .vertical) {
                variants
                // Above AX1: AX1's variants first, so a larger size never shows smaller text than
                // AX1 (the 2026-10-24 AX3 images were smaller than AX1 and even than xxxLarge).
                Group {
                    variants
                }
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                // The person's size leaves no room for the meaning: the largest standard size, the
                // same variants.
                Group {
                    variants
                }
                .dynamicTypeSize(...WidgetText.largestStandardSize)
                // Nothing fits at the person's size nor at xxxLarge: the default text size. The
                // small widget's text area does not grow with the text size (fixed margins and
                // button row), so these draw exactly the default layout, which has the meaning
                // (ogrenme_ilkeleri 2.1).
                Group {
                    column(WidgetWordStep.smallWidget, meaning: .body, lines: [1, 2])
                    column(WidgetWordStep.smallWidget, meaning: .subheadline, lines: [1, 2])
                    column(WidgetWordStep.smallWidgetPhrase, meaning: .subheadline, lines: [1])
                    column(WidgetWordStep.homeFloorScaled, meaning: .subheadline, lines: [1, 2])
                    column(WidgetWordStep.homeFloorScaled, meaning: .footnote, lines: [2, 3])
                    column(WidgetWordStep.homeFloor, lastResort: true, meaning: .footnote, lines: [1, 2])
                }
                .dynamicTypeSize(...DynamicTypeSize.large)
                // is5-w-ayar: "Anlamı gizle" and no variant above has room for the Göster button
                // (a phrase on two lines): the default layout with the meaning, never the word
                // alone. Without the choice these are the variants above again and fail again.
                Group {
                    column(WidgetWordStep.smallWidgetPhrase, meaning: .subheadline, lines: [1])
                    column(WidgetWordStep.homeFloorScaled, meaning: .subheadline, lines: [1, 2])
                    column(WidgetWordStep.homeFloorScaled, meaning: .footnote, lines: [2, 3])
                    column(WidgetWordStep.homeFloor, lastResort: true, meaning: .subheadline, lines: [1, 2])
                }
                .dynamicTypeSize(...DynamicTypeSize.large)
                .widgetMeaningShown()
                WidgetWordAlone(lemma: word.lemma, colors: colors, renderingMode: renderingMode)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // The next word fades in; the buttons stay still. No motion in vibrant rendering (the
            // iPad Lock Screen, StandBy at night) (WidgetMotion.swift).
            .widgetWordChange(id: word.id, lockScreen: (renderingMode ?? environmentRenderingMode) == .vibrant)
            .layoutPriority(1)
            Spacer(minLength: 2)
            // The button row's place; the row itself is the overlay below.
            Color.clear
                .frame(height: Theme.minHitSize - bottomOverflow)
        }
        .padding(margins)
        .overlay(alignment: .bottom) {
            // Next in the easy corner (bottom right), the speaker in the other corner: the wide
            // gap between them keeps one from being pressed for the other.
            HStack(spacing: 0) {
                SpeakWordButton(text: word.lemma, colors: colors)
                Spacer(minLength: 8)
                NextWordButton(wordID: word.id, source: .systemSmall, colors: colors)
            }
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            .padding(.leading, max(margins.leading - buttonGroupOverflow, 0))
            .padding(.trailing, max(margins.trailing - buttonGroupOverflow, 0))
            .padding(.bottom, margins.bottom - bottomOverflow)
        }
        .widgetTurkishVoice()
        .widgetAccent(options.accent)
    }

    /// The variants at one text size, fullest first. The 22/20/17 pt steps never stand below the
    /// meaning beside them (`SmallWidgetHeadword`): they grow as `.title3` does, more slowly than
    /// `.body`, so above the default size a 17 pt step was smaller than a `.body` meaning (AX1:
    /// "actually" at 26.35 pt over a 28 pt "aslında"). Each is followed by the same variant with
    /// the word stopped at the largest standard size: above it a word too wide for its own steps
    /// keeps its xxxLarge size beside the larger meaning instead of dropping a whole step, so it is
    /// never smaller than at xxxLarge ("actually" 28.6 pt, "awkward" 26 pt; the 2026-10-24 AX3
    /// images had 26.35 and 23.25 pt). Up to xxxLarge that variant is the one before it again.
    /// The floor steps keep the same rule: above the default size the 15 pt step is smaller than
    /// a `.subheadline` meaning (xxxLarge 19.5 pt under 21 pt: "date", "stop", "disagree", "end
    /// up", "I can't wait"; AX1 "breakfast" 23.25 pt under 25 pt), so there the meaning takes the
    /// `.footnote` variant instead (19 and 23 pt). At the default size nothing changes.
    @ViewBuilder
    private var variants: some View {
        column(WidgetWordStep.smallWidget, meaning: .body, lines: [1, 2], wordAboveMeaning: true)
        column(WidgetWordStep.smallWidget, meaning: .body, lines: [1, 2], wordAboveMeaning: true, wordStopsGrowing: true)
        column(WidgetWordStep.smallWidget, meaning: .subheadline, lines: [1, 2], wordAboveMeaning: true)
        column(WidgetWordStep.smallWidget, meaning: .subheadline, lines: [1, 2], wordAboveMeaning: true, wordStopsGrowing: true)
        column(WidgetWordStep.smallWidgetPhrase, meaning: .subheadline, lines: [1], wordAboveMeaning: true)
        column(WidgetWordStep.homeFloorScaled, meaning: .subheadline, lines: [1, 2], wordAboveMeaning: true)
        // A long meaning without a short form (the user's own words have none; every card's
        // meaning over 16 characters has `gloss_short`): 13 pt on two or three lines rather than
        // no meaning.
        column(WidgetWordStep.homeFloorScaled, meaning: .footnote, lines: [2, 3], wordAboveMeaning: true)
    }

    /// One layout variant: the word at the first of `steps` that fits and, under it, the meaning
    /// in `style` bold on the first of `lines` line counts that fits. With `wordAboveMeaning` a
    /// step smaller than the meaning is passed over, and with `wordStopsGrowing` the word stops
    /// growing at the largest standard size (`SmallWidgetHeadword`).
    private func column(
        _ steps: [WidgetWordStep],
        lastResort: Bool = false,
        meaning style: Font.TextStyle,
        lines: [Int],
        wordAboveMeaning: Bool = false,
        wordStopsGrowing: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if wordAboveMeaning {
                SmallWidgetHeadword(
                    lemma: word.lemma,
                    steps: steps,
                    meaning: style,
                    maximumWordSize: wordStopsGrowing ? WidgetText.largestStandardSize : nil,
                    colors: colors,
                    renderingMode: renderingMode
                )
            } else {
                WidgetFittingWord(
                    lemma: word.lemma,
                    steps: steps,
                    lastResort: lastResort,
                    colors: colors,
                    renderingMode: renderingMode
                )
            }
            // Every card has a Turkish meaning; without one the word stands alone.
            let forms = WidgetGloss.forms(of: word)
            if !forms.isEmpty {
                WidgetMeaning(forms: forms, typeface: Font.system(style, design: .default).weight(.bold), lines: lines, color: colors.ink)
                    .widgetMeaningReveal(options, wordID: word.id, until: entry.nextChange, colors: colors, aboveButtonRow: true)
                    .padding(.top, headerGap)
            }
        }
    }
}

/// The small widget's word over a meaning in `meaning` style, never smaller than that meaning:
/// `WidgetFittingWord` over the size steps that are at least the meaning's size at the current
/// text size (both measured where the variant is drawn, so inside a retry group at that group's
/// size). With `maximumWordSize` the word stops growing at that text size while the meaning keeps
/// the current one. When no step is left, or none fits, the variant around it is passed over
/// (`WidgetFit.reject`).
private struct SmallWidgetHeadword: View {
    let lemma: String
    let steps: [WidgetWordStep]
    /// The text style of the meaning under the word (`.body`, `.subheadline` or `.footnote`).
    let meaning: Font.TextStyle
    let maximumWordSize: DynamicTypeSize?
    let colors: WidgetColors
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    let renderingMode: WidgetRenderingMode?
    @ScaledMetric(relativeTo: .body) private var bodySize: CGFloat = 17
    @ScaledMetric(relativeTo: .subheadline) private var subheadlineSize: CGFloat = 15
    @ScaledMetric(relativeTo: .footnote) private var footnoteSize: CGFloat = 13

    init(
        lemma: String,
        steps: [WidgetWordStep],
        meaning: Font.TextStyle,
        maximumWordSize: DynamicTypeSize?,
        colors: WidgetColors,
        renderingMode: WidgetRenderingMode?
    ) {
        self.lemma = lemma
        self.steps = steps
        self.meaning = meaning
        self.maximumWordSize = maximumWordSize
        self.colors = colors
        self.renderingMode = renderingMode
    }

    var body: some View {
        let limit = maximumWordSize ?? DynamicTypeSize.accessibility5
        SmallWidgetHeadwordSteps(
            lemma: lemma,
            steps: steps,
            minimumSize: meaningSize,
            colors: colors,
            renderingMode: renderingMode
        )
        .dynamicTypeSize(...limit)
    }

    /// The meaning's point size at the current text size.
    private var meaningSize: CGFloat {
        switch meaning {
        case .subheadline:
            return subheadlineSize
        case .footnote:
            return footnoteSize
        default:
            return bodySize
        }
    }
}

/// `SmallWidgetHeadword`'s word at its own text size: the steps of at least `minimumSize` pt
/// there (scaled as `WidgetFittingWord` scales them), a hair's tolerance so that equal sizes at the
/// default text size (the 17 pt step over a 17 pt meaning) stay.
private struct SmallWidgetHeadwordSteps: View {
    let lemma: String
    let steps: [WidgetWordStep]
    let minimumSize: CGFloat
    let colors: WidgetColors
    let renderingMode: WidgetRenderingMode?
    /// 100 times the Dynamic Type factor of `.title3`, as in `WidgetFittingWord`.
    @ScaledMetric(relativeTo: .title3) private var scaledHundred: CGFloat = 100

    init(
        lemma: String,
        steps: [WidgetWordStep],
        minimumSize: CGFloat,
        colors: WidgetColors,
        renderingMode: WidgetRenderingMode?
    ) {
        self.lemma = lemma
        self.steps = steps
        self.minimumSize = minimumSize
        self.colors = colors
        self.renderingMode = renderingMode
    }

    var body: some View {
        let kept = steps.filter { step in
            let size = step.scales ? step.size * scaledHundred / 100 : step.size
            return size >= minimumSize - 0.1
        }
        if kept.isEmpty {
            WidgetFit.reject
        } else {
            WidgetFittingWord(
                lemma: lemma,
                steps: kept,
                colors: colors,
                renderingMode: renderingMode
            )
        }
    }
}

struct MediumWordView: View {
    let entry: WordEntry
    /// The widget's content margins (`widgetContentMargins`); WidgetKit's default for home widgets.
    var margins = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    /// Replaces the environment's `showsWidgetContainerBackground` (snapshot tests only).
    var showsBackground: Bool? = nil
    /// is5-w-ayar: "Widget'ı Düzenle" choices (WidgetConfigurationOptions.swift).
    var options = WidgetDisplayOptions.standard
    @Environment(\.widgetRenderingMode) private var environmentRenderingMode
    @Environment(\.showsWidgetContainerBackground) private var environmentShowsBackground
    private var word: WidgetWord { entry.word }
    private var colors: WidgetColors {
        WidgetColors.forMode(
            renderingMode ?? environmentRenderingMode,
            showsBackground: showsBackground ?? environmentShowsBackground
        )
    }
    /// The part of the button column that lies in the trailing margin.
    private var trailingOverflow: CGFloat { min(buttonGroupOverflow, margins.trailing) }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // The next change gives way first, then the example, then the definition (the short
            // one, else the micro one); a definition too wide for its line gives way alone, and
            // the example and the next change stay when they fit (2026-10-24 xxxLarge images: no
            // half-empty widget). Only then does the meaning shorten (`WidgetGloss`), take
            // two lines and get smaller. When the word and the meaning do not fit at the person's
            // text size, the whole ladder (`ladder`) is tried again at smaller sizes before the
            // meaning is left out: above AX1 at AX1 first, then at the largest standard size, then
            // the smaller meaning at the default size. The word alone is the last resort, so the
            // meaning never runs out of the column at large text sizes (accessibility audit D5).
            // The retries are groups: a modifier on a Group applies to each of its views, and
            // ViewThatFits tries them one by one, as if they were listed here.
            ViewThatFits(in: .vertical) {
                ladder
                // Above AX1: AX1's whole ladder first, so a larger size never shows smaller text
                // or fewer lines than AX1 (the 2026-10-24 AX3 images had the word and the meaning
                // alone, half the widget empty, where AX1 also had "Yeni kelime").
                Group {
                    ladder
                }
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                Group {
                    ladder
                }
                .dynamicTypeSize(...WidgetText.largestStandardSize)
                // Nothing fits even at xxxLarge (from xLarge to xxxLarge the retry above is the
                // person's own size): the default text size; the text column does not grow with
                // the text size.
                column(smallMeaning: true)
                    .dynamicTypeSize(...DynamicTypeSize.large)
                wordRow(WidgetWordStep.mediumWidget, lastResort: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            // The next word fades in; the buttons stay still. No motion in vibrant rendering (the
            // iPad Lock Screen) (WidgetMotion.swift).
            .widgetWordChange(id: word.id, lockScreen: (renderingMode ?? environmentRenderingMode) == .vibrant)
            // The button column's place (a row would take the width of the text); the column
            // itself is the overlay below.
            Color.clear
                .frame(width: Theme.minHitSize - trailingOverflow)
        }
        .padding(margins)
        .overlay(alignment: .trailing) {
            // Next in the easy corner (bottom of the column), Know the farthest from it. Above and
            // below the column its part of the margins (6 pt with the default 16 pt), as gaps that
            // give way when the widget is too short (`columnGap`): an iPad mini's medium widget is
            // 141 pt tall, and the three 44 pt hit areas did not fit the 129 pt left between two
            // 6 pt paddings (w-medium-4). There each gap is 4.5 pt and the buttons touch; from
            // 144 pt up (every iPhone) the gaps are 6 pt and the space between the buttons takes
            // the rest, as before.
            VStack(spacing: 0) {
                columnGap(max(margins.top - buttonGroupOverflow, 0))
                KnowWordButton(wordID: word.id, source: .systemMedium, colors: colors)
                Spacer(minLength: 0)
                SpeakWordButton(text: word.lemma, colors: colors)
                Spacer(minLength: 0)
                NextWordButton(wordID: word.id, source: .systemMedium, colors: colors)
                columnGap(max(margins.bottom - buttonGroupOverflow, 0))
            }
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            .padding(.trailing, margins.trailing - trailingOverflow)
        }
        .widgetTurkishVoice()
        .widgetAccent(options.accent)
    }

    /// One text size's ladder, fullest first: the whole meaning with the lines that follow it,
    /// then the meaning's shorter forms, then the smaller meaning. A line that gives way leaves
    /// its place to the next one down, never a hole the next change would fit in: without the
    /// example the definition keeps "Yeni kelime" (the 2026-10-24 xxxLarge images: an example
    /// that no longer fits on two lines left the bottom third empty), and so does a shortened
    /// meaning. The definition is never kept with a shortened meaning (ogrenme_ilkeleri 2.2).
    @ViewBuilder
    private var ladder: some View {
        Group {
            column(shortens: false, definition: true, example: true, nextChange: true)
            column(shortens: false, definition: true, example: true)
            column(shortens: false, definition: true, nextChange: true)
            column(shortens: false, definition: true)
            column(shortens: false, example: true, nextChange: true)
            column(shortens: false, example: true)
            column(shortens: false, nextChange: true)
            column(shortens: false)
        }
        column(nextChange: true)
        column()
        column(smallMeaning: true)
    }

    /// A gap of at most `height` pt above or below the button column. It is offered the height the
    /// three buttons leave before the space between them is (layout priority), so it is `height`
    /// when there is room, the half of what is left when there is not, and the column never
    /// overflows the widget. No width, so the column stays as wide as its buttons.
    private func columnGap(_ height: CGFloat) -> some View {
        Color.clear
            .frame(width: 0)
            .frame(maxHeight: height)
            .layoutPriority(1)
    }

    /// The word row at the first of `steps` that fits; with `lastResort` (the word alone) it is
    /// never passed over (`WidgetFittingWord`) and may drop to an unscaled 15 pt. Beside a meaning
    /// it grows with the text size, as the meaning does, so a small word never stands above a
    /// large meaning.
    private func wordRow(_ steps: [WidgetWordStep], lastResort: Bool = false) -> some View {
        WidgetWordRow(
            lemma: word.lemma,
            steps: steps,
            lastResort: lastResort,
            // A user's own word has no level.
            level: word.level.isEmpty ? nil : word.level,
            ipa: word.chosenIPA, // is5-ses: "Ses ve aksan" (App Group)
            colors: colors,
            renderingMode: renderingMode
        )
    }

    /// One layout variant: the meaning on one or two lines, whole (`shortens` false) or in its
    /// shorter forms too, 16 pt (`.callout`) or with `smallMeaning` 15 pt (`.subheadline`); the
    /// next change sits at the bottom, beside the Next button.
    private func column(
        smallMeaning: Bool = false,
        shortens: Bool = true,
        definition: Bool = false,
        example: Bool = false,
        nextChange: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            wordRow(WidgetWordStep.mediumWidgetScaled)
            VStack(alignment: .leading, spacing: 3) {
                let forms = WidgetGloss.forms(of: word)
                if !forms.isEmpty {
                    WidgetMeaning(
                        forms: shortens ? forms : Array(forms.prefix(1)),
                        typeface: smallMeaning ? .subheadline.weight(.bold) : .callout.weight(.bold),
                        lines: [1, 2],
                        color: colors.ink
                    )
                    .widgetMeaningReveal(options, wordID: word.id, until: entry.nextChange, colors: colors)
                }
                // A user's own word has no definition and may have no example: no empty line.
                if definition && !(word.defShort.isEmpty && word.defMicro.isEmpty) {
                    WidgetDefinition(
                        texts: [word.defShort, word.defMicro],
                        typeface: .system(.footnote, design: .serif),
                        color: colors.ink2
                    )
                }
                if example && options.showsExample && !word.exampleEN.isEmpty {
                    WidgetExampleLine(sentence: word.exampleEN, lemma: word.lemma, color: colors.ink2)
                        .widgetEnglishVoice()
                }
            }
            .padding(.top, headerGap)
            Spacer(minLength: 0)
            if nextChange, let next = entry.nextChange {
                // "Yeni kelime: 09:00": no Turkish suffix after the time (README point 13). Whole
                // or not at all, like the other lines. VoiceOver says "Sonraki değişim: 09:00",
                // the name Widget sağlığı uses (docs/tasarim/terimler.md §5).
                let clock = WidgetTime.clock(next)
                WidgetFittingText(
                    candidates: [["Yeni kelime: \(clock)"]],
                    typeface: .caption2.weight(.medium),
                    color: colors.ink2
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "Sonraki değişim: \(clock)"))
                .padding(.top, 3)
            }
        }
    }
}

// MARK: - Parts shared with the Lock Screen views

/// The widget's colors for its rendering mode (`forMode`):
/// - Full color on the widget's own paper: the design tokens (`tokens`).
/// - Full color without the paper (StandBy by day, `showsWidgetContainerBackground` false): the
///   system's hierarchical styles, ink on the black screen (`system`).
/// - Accented (the tinted Home Screen of iOS 18, the clear and tinted Liquid Glass Home Screen of
///   iOS 26): the system takes away the paper, puts its glass or tint behind the widget and
///   paints each view in one color, keeping only its opacity (white on iOS 26; the accent group,
///   the word and its band, in the tint color on iOS 18). Apple asks for no partly transparent
///   content in this mode ("Optimizing your widget for accented rendering mode and Liquid
///   Glass"): every text is opaque, so it stands out of the glass at the system's own contrast,
///   and a button's circle is an opaque outline, since an opaque disc would be painted the icon's
///   color (`accented`).
/// - Vibrant (the Lock Screen; StandBy at night, which the system draws in red): opaque grays,
///   white for the word (and the home widgets' meaning), darker grays for quieter parts
///   (`lockScreen`).
struct WidgetColors {
    /// The word, the meaning and the button icons.
    let ink: AnyShapeStyle
    /// Definition, example, IPA, level and the next change; the meaning on the Lock Screen.
    let ink2: AnyShapeStyle
    /// The circle behind a button icon (mockup `.wb span`).
    let buttonFill: AnyShapeStyle
    /// The circle's edge, 1.5 pt (visible on bright clear glass); nil for none (the fill shows
    /// the circle).
    var buttonEdge: AnyShapeStyle? = nil

    /// Full color: `ink`, `ink2` and `surface2` (the background is `surface`, `WordWidgetView`).
    static var tokens: WidgetColors {
        return WidgetColors(
            ink: AnyShapeStyle(Theme.ink),
            ink2: AnyShapeStyle(Theme.ink2),
            buttonFill: AnyShapeStyle(Theme.surface2)
        )
    }

    /// No paper in full color: the system's primary, secondary and quaternary styles.
    static var system: WidgetColors {
        return WidgetColors(
            ink: AnyShapeStyle(HierarchicalShapeStyle.primary),
            ink2: AnyShapeStyle(HierarchicalShapeStyle.secondary),
            buttonFill: AnyShapeStyle(HierarchicalShapeStyle.quaternary)
        )
    }

    /// Accented rendering (tinted and Liquid Glass Home Screens): everything opaque. The quieter
    /// lines stay apart by their smaller serif type, not by opacity; the button circle is an
    /// outline around the icon.
    static var accented: WidgetColors {
        return WidgetColors(
            ink: AnyShapeStyle(HierarchicalShapeStyle.primary),
            ink2: AnyShapeStyle(HierarchicalShapeStyle.primary),
            buttonFill: AnyShapeStyle(Color.clear),
            buttonEdge: AnyShapeStyle(HierarchicalShapeStyle.primary)
        )
    }

    /// Vibrant rendering (the Lock Screen, where the system draws the background, and StandBy at
    /// night): opaque grays, white for the word (and the home widgets' meaning), darker grays for
    /// the quieter parts. The system turns their luminance into its vibrant material (red in StandBy
    /// at night); Apple asks for "opaque grayscale values, rather than opacities of white" (HIG
    /// Widgets), so the hierarchy is never built with opacity. The gray stays the same on the
    /// Always-On display, where the system dims the whole screen.
    static var lockScreen: WidgetColors {
        return WidgetColors(
            ink: AnyShapeStyle(Color(white: 1)),
            ink2: AnyShapeStyle(Color(white: 0.75)),
            buttonFill: AnyShapeStyle(Color(white: 0.3))
        )
    }

    static func forMode(_ mode: WidgetRenderingMode, showsBackground: Bool = true) -> WidgetColors {
        if mode == .accented {
            return accented
        }
        if mode == .vibrant {
            return lockScreen
        }
        return showsBackground ? tokens : system
    }
}

/// One size step of a headword: `size` pt at the default text size, scaled with Dynamic Type
/// unless `scales` is false, on up to `lines` balanced lines (a single word stays on one line).
/// The sizes are those of Apple's text styles at the default text size (Title 28, Title 2 22,
/// Title 3 20, Body 17, Subheadline 15); every step scales as `.title3` does
/// (`WidgetFittingWord`), so a smaller step never grows past a larger one.
struct WidgetWordStep: Equatable {
    let size: CGFloat
    var lines = 1
    var scales = true

    /// The small widget (ogrenme_ilkeleri 2.1): 22, 20, then 17 pt on one line (Title 2, Title 3
    /// and Body sizes).
    static let smallWidget = [WidgetWordStep(size: 22), WidgetWordStep(size: 20), WidgetWordStep(size: 17)]
    /// A phrase on the small widget: two lines at 20 or 17 pt ("Could you tell / me the way to").
    static let smallWidgetPhrase = [WidgetWordStep(size: 20, lines: 2), WidgetWordStep(size: 17, lines: 2)]
    /// The Home Screen floor, 15 pt scaled with Dynamic Type: one line, then two.
    static let homeFloorScaled = [WidgetWordStep(size: 15), WidgetWordStep(size: 15, lines: 2)]
    /// The floor without Dynamic Type: the last resort (`WidgetWordAlone`).
    static let homeFloorUnscaled = [
        WidgetWordStep(size: 15, scales: false),
        WidgetWordStep(size: 15, lines: 2, scales: false),
    ]
    /// The Home Screen floor, 15 pt: one line, then two; at large text sizes also unscaled.
    static let homeFloor = homeFloorScaled + homeFloorUnscaled
    /// The rectangular Lock Screen widget: 17, then 15 pt on one line.
    static let lockScreen = [WidgetWordStep(size: 17), WidgetWordStep(size: 15)]
    /// The medium widget beside a meaning: 20, 17, 15 pt on one line, then a phrase on two lines
    /// at 17 or 15 pt, all scaled with Dynamic Type, as the meaning is. Beside the 16 pt meaning
    /// the longest phrases take 15 pt: a 16 pt floor would put "Could you tell me the way to" on
    /// two lines on an SE and push its definition and example out.
    static let mediumWidgetScaled = [
        WidgetWordStep(size: 20),
        WidgetWordStep(size: 17),
        WidgetWordStep(size: 15),
        WidgetWordStep(size: 17, lines: 2),
        WidgetWordStep(size: 15, lines: 2),
    ]
    /// The medium widget's word alone: at large text sizes also two unscaled 15 pt lines.
    static let mediumWidget = mediumWidgetScaled + [WidgetWordStep(size: 15, lines: 2, scales: false)]
}

/// The headword at the first of its size steps that fits the width whole, each line with its own
/// band (the band is drawn for one line of text); no hyphen, no "…". A word that fits no step
/// makes the variant around it too tall to be chosen (`WidgetFit.reject`); with `lastResort` it
/// is never passed over and, after the steps, shrinks to at most 75 % of the last one (11.25 pt,
/// above Apple's 11 pt floor; only "misunderstanding" at 15 pt on an SE needs this). VoiceOver
/// reads the whole word once, with an English voice.
struct WidgetFittingWord: View {
    let lemma: String
    let steps: [WidgetWordStep]
    var lastResort = false
    let colors: WidgetColors
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    /// 100 times the Dynamic Type factor of `.title3` (100 at the default text size).
    @ScaledMetric(relativeTo: .title3) private var scaledHundred: CGFloat = 100

    init(
        lemma: String,
        steps: [WidgetWordStep],
        lastResort: Bool = false,
        colors: WidgetColors,
        renderingMode: WidgetRenderingMode? = nil
    ) {
        self.lemma = lemma
        self.steps = steps
        self.lastResort = lastResort
        self.colors = colors
        self.renderingMode = renderingMode
    }

    var body: some View {
        let slots = WidgetFit.slots(steps.isEmpty ? [WidgetWordStep(size: 15)] : steps)
        ViewThatFits(in: .horizontal) {
            lines(slots[0])
            lines(slots[1])
            lines(slots[2])
            lines(slots[3])
            lines(slots[4])
            lines(slots[5])
            if lastResort {
                lines(slots[5], minimumScale: 0.75)
            } else {
                WidgetFit.reject
            }
        }
    }

    private func lines(_ step: WidgetWordStep, minimumScale: CGFloat = 1) -> some View {
        let size = step.scales ? step.size * scaledHundred / 100 : step.size
        let parts = WidgetText.balancedLines(lemma, count: step.lines)
        // Room for the band, which hangs below each line's frame.
        return VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                WidgetHeadword(
                    lemma: part,
                    typeface: Theme.Fonts.englishWord(size: size),
                    color: colors.ink,
                    renderingMode: renderingMode,
                    minimumScale: minimumScale
                )
                // VoiceOver reads the whole word once, on the first line, with an English voice:
                // one element per line (without `.ignore` the line was read twice).
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: lemma))
                .accessibilityHidden(index > 0)
                .widgetEnglishVoice()
            }
        }
    }
}

/// The word alone, the last layout variant of the small and the Lock Screen widget: at the first
/// of the Home Screen floor's steps that fits the width and the height, else at an unscaled 15 pt.
/// At the largest text sizes a phrase on two scaled lines can fit the width and still be taller
/// than the widget ("I can't / wait" ran out of the Lock Screen rectangle at AX3); it gets smaller
/// instead of being cut.
struct WidgetWordAlone: View {
    let lemma: String
    let colors: WidgetColors
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil

    var body: some View {
        ViewThatFits(in: .vertical) {
            WidgetFittingWord(
                lemma: lemma,
                steps: WidgetWordStep.homeFloor,
                colors: colors,
                renderingMode: renderingMode
            )
            WidgetFittingWord(
                lemma: lemma,
                steps: WidgetWordStep.homeFloorUnscaled,
                lastResort: true,
                colors: colors,
                renderingMode: renderingMode
            )
        }
    }
}

/// The medium widget's word row: the word at the first of its size steps that fits whole beside
/// the level code (`WidgetWordStep.mediumWidget`: 20, 17, 15 pt, a phrase also on two lines), the
/// pronunciation when the row leaves room for it, and the level code. A word that fits no step
/// makes the variant around it too tall to be chosen, unless `lastResort`.
struct WidgetWordRow: View {
    let lemma: String
    /// The word's size steps; `WidgetWordStep.mediumWidgetScaled` beside a meaning.
    var steps = WidgetWordStep.mediumWidget
    var lastResort = false
    /// The level code ("A2"), nil to leave it out.
    var level: String? = nil
    /// The US pronunciation, shown after the word when the rest of the row leaves room for it.
    var ipa: String? = nil
    let colors: WidgetColors
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            // The word takes the width the level and the spacing leave; the pronunciation takes
            // what the word leaves.
            WidgetFittingWord(
                lemma: lemma,
                steps: steps,
                lastResort: lastResort,
                colors: colors,
                renderingMode: renderingMode
            )
            .layoutPriority(1)
            if let ipa {
                WidgetIPA(ipa: ipa, color: colors.ink2)
            } else if level != nil {
                Spacer(minLength: 0)
            }
            if let level {
                WidgetLevel(code: level, color: colors.ink2)
            }
        }
    }
}

/// One line of the English word with the phosphor band (README point 4): serif bold, one line.
/// It shrinks only in the last resort (`minimumScale` below 1); a size step is chosen only when
/// the word fits whole. The band follows the rendering mode (yellow highlighter by day, a yellow
/// line under the letters at night, a thin line in the word's color when tinted or on the Lock
/// Screen) and, like the word, is accentable.
struct WidgetHeadword: View {
    let lemma: String
    /// The size step's font (`WidgetFittingWord`).
    var typeface: Font = Theme.Fonts.widgetWord
    let color: AnyShapeStyle
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    var minimumScale: CGFloat = 1

    var body: some View {
        Text(lemma)
            .font(typeface)
            .lineLimit(1)
            .minimumScaleFactor(minimumScale)
            .widgetAccentable()
            .foregroundStyle(color)
            .phosphorBand(.widget, renderingMode: renderingMode)
            .widgetEnglishVoice()
    }
}

/// The pronunciation after the word on the medium widget. It takes the room the word and the
/// level leave and shows only when it fits whole; its own width never counts when the row is
/// measured (a hidden space of the same font sets the slot's ideal size).
struct WidgetIPA: View {
    let ipa: String
    let color: AnyShapeStyle

    var body: some View {
        Text(verbatim: " ")
            .font(WidgetIPA.font)
            .hidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .leading) {
                ViewThatFits(in: .horizontal) {
                    Text(verbatim: ipa)
                        .font(WidgetIPA.font)
                        .foregroundStyle(color)
                        .lineLimit(1)
                    Color.clear
                        .frame(width: 0, height: 0)
                }
            }
            .accessibilityHidden(true)
    }

    /// `.footnote` serif, the size of the medium widget's definition and example (one size fewer
    /// on the widget; it was `.caption`, 12 pt).
    static let font = Font.system(.footnote, design: .serif)
}

/// The level code ("A2"), small and quiet; VoiceOver reads "Seviye A2". `.footnote` bold, the
/// widgets' secondary size (it was `.caption2`; the large widget then keeps four sizes).
struct WidgetLevel: View {
    let code: String
    let color: AnyShapeStyle

    var body: some View {
        Text(code)
            .font(.footnote.weight(.bold))
            .foregroundStyle(color)
            .lineLimit(1)
            .fixedSize()
            .accessibilityLabel(Text(verbatim: "Seviye \(code)"))
    }
}

/// The Turkish meaning: SF bold, no box behind it, read as "Türkçesi: …" with the whole meaning
/// (README point 14). For each line count in `lines` it tries the meaning's forms (`WidgetGloss`),
/// fullest first, and shows the first that fits whole. When none fits, the variant around it is
/// passed over: the meaning is never cut.
struct WidgetMeaning: View {
    /// The meaning's forms, fullest first; the first is the whole meaning.
    let forms: [String]
    let typeface: Font
    /// The line counts to try, in order.
    var lines = [1]
    let color: AnyShapeStyle

    private var spoken: String { forms.first ?? "" }

    var body: some View {
        WidgetFittingText(
            candidates: WidgetText.candidates(forms, lines: lines),
            typeface: typeface,
            color: color
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Türkçesi: \(spoken)"))
    }
}

/// An English definition in serif on one line, whole: the first of `texts` that fits (the medium
/// widget: the short definition, else the micro one). When neither fits, the variant around it is
/// passed over.
struct WidgetDefinition: View {
    let texts: [String]
    let typeface: Font
    let color: AnyShapeStyle

    var body: some View {
        WidgetFittingText(
            candidates: WidgetText.candidates(texts, lines: [1]),
            typeface: typeface,
            color: color
        )
        .widgetEnglishVoice()
    }
}

/// Widget text that is shown whole or not at all: the first candidate (a list of lines, fullest
/// first) whose every line fits the width on one line. When none fits, the view reports a height
/// no widget has (`WidgetFit.reject`), so the vertical ViewThatFits around it passes over the
/// variant. VoiceOver reads the lines that are shown as one element, in the voice of the
/// environment's locale (the English definition with `widgetEnglishVoice()`).
struct WidgetFittingText: View {
    let candidates: [[String]]
    let typeface: Font
    let color: AnyShapeStyle

    var body: some View {
        let slots = WidgetFit.slots(candidates)
        if slots.isEmpty {
            WidgetFit.reject
        } else {
            ViewThatFits(in: .horizontal) {
                lines(slots[0])
                lines(slots[1])
                lines(slots[2])
                lines(slots[3])
                lines(slots[4])
                lines(slots[5])
                WidgetFit.reject
            }
        }
    }

    private func lines(_ lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(verbatim: line)
                    .font(typeface)
                    .foregroundStyle(color)
                    .lineLimit(1)
            }
        }
        // An explicit label, not `.combine`: a combined element loses the English voice
        // (LockglowTheme `englishVoice()`).
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: lines.joined(separator: " ")))
    }
}

/// Helpers for the fitting lines.
enum WidgetFit {
    /// How many steps a fitting line tries (ViewThatFits needs a fixed number of children).
    static let slotCount = 6

    /// A view no widget has room for: the last choice of a fitting line that must not be shown
    /// cut. A vertical ViewThatFits then passes over the variant that contains it.
    static var reject: some View {
        Color.clear
            .frame(width: 0, height: 100_000)
            .accessibilityHidden(true)
    }

    /// `items` as exactly `slotCount` slots: the first `slotCount`, the last one repeated to fill
    /// the rest (a repeated step that did not fit does not fit again); empty when `items` is.
    static func slots<Item>(_ items: [Item]) -> [Item] {
        let kept = Array(items.prefix(slotCount))
        guard let last = kept.last else {
            return []
        }
        return kept + Array(repeating: last, count: slotCount - kept.count)
    }
}

/// The Turkish meaning's forms for the widgets, fullest first (ogrenme_ilkeleri 2.1, "Türkçe
/// anlamın widget'ta kısalması"): the whole meaning, then one shorter form. That is the editor's
/// short form (`gloss_short`, at most 16 characters) when the card has one: every meaning longer
/// than 16 characters has it, and the editor often chose it over the first sense on purpose
/// ("stop": "durmak/durdurmak", not the narrower "durmak"; "cash or card": "nakit mi kart mı",
/// not "nakit mi"). Without one (a short meaning, or the user's own word) it is the first sense,
/// which drops what follows the first comma or semicolon ("aslında, gerçekte" → "aslında") but
/// keeps a " / " pair whole ("amca / dayı"). A form is never cut: when none fits, the widget
/// leaves the meaning out.
enum WidgetGloss {
    static func forms(of word: WidgetWord) -> [String] {
        guard let gloss = word.glossTR else {
            return []
        }
        return forms(of: gloss, short: short(of: word))
    }

    /// The forms without repeats ("kahvaltı" has one) or empty ones.
    static func forms(of gloss: String, short: String?) -> [String] {
        let editorShort = short?.trimmingCharacters(in: .whitespaces) ?? ""
        let shorter = editorShort.isEmpty ? firstSense(of: gloss) : editorShort
        var result: [String] = []
        for candidate in [gloss, shorter] {
            let form = candidate.trimmingCharacters(in: .whitespaces)
            guard !form.isEmpty, !result.contains(form) else {
                continue
            }
            result.append(form)
        }
        return result
    }

    /// The meaning up to its first comma or semicolon outside brackets ("x (a, b), c" → "x (a,
    /// b)"); the whole meaning when it has none.
    static func firstSense(of gloss: String) -> String {
        var depth = 0
        var end = gloss.endIndex
        scan: for index in gloss.indices {
            let character = gloss[index]
            if character == "(" {
                depth += 1
            } else if character == ")" {
                depth = max(depth - 1, 0)
            } else if depth == 0 && (character == "," || character == ";") {
                end = index
                break scan
            }
        }
        let trimmed = gloss[..<end].trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? gloss : trimmed
    }

    /// The card's short form (`l1.tr.gloss_short`, `WidgetWord.glossShortTR`).
    static func short(of word: WidgetWord) -> String? {
        return word.glossShortTR
    }
}

/// Text helpers for the widget layouts.
enum WidgetText {
    /// The largest standard text size (no accessibility size): where the word and the meaning
    /// stop growing when they fit at no larger size.
    static let largestStandardSize = DynamicTypeSize.xxxLarge

    /// `text` in two lines of about the same length (`balancedLines(_:count:)`).
    static func balancedLines(_ text: String) -> [String] {
        return balancedLines(text, count: 2)
    }

    /// `text` in at most `count` lines of about the same length, broken between words: the breaks
    /// that make the longest line shortest, then the lines most even, then the earlier lines the
    /// longer ones ("Could you tell" / "me the way to", "aslında," / "gerçekte", "kendini" / "pek
    /// iyi" / "hissetmemek"). A single word stays one line.
    static func balancedLines(_ text: String, count: Int) -> [String] {
        let words = text.split(separator: " ").map(String.init)
        let lineCount = min(count, words.count)
        guard lineCount > 1 else {
            return [text]
        }
        var best = [text]
        var bestLengths = [Int.max]
        // Every way to cut the words into `lineCount` runs; a widget line has a few words.
        func search(from start: Int, lines: [String]) {
            let left = lineCount - lines.count
            if left == 1 {
                let candidate = lines + [words[start...].joined(separator: " ")]
                let lengths = candidate.map { $0.count }
                if isMoreBalanced(lengths, than: bestLengths) {
                    best = candidate
                    bestLengths = lengths
                }
                return
            }
            for end in (start + 1)...(words.count - left + 1) {
                search(from: end, lines: lines + [words[start..<end].joined(separator: " ")])
            }
        }
        search(from: 0, lines: [])
        return best
    }

    /// The candidates of a fitting line: for each line count in turn, each text in balanced lines,
    /// without repeats. Empty texts are left out (a card without a short definition), so no
    /// candidate is an empty line.
    static func candidates(_ texts: [String], lines counts: [Int]) -> [[String]] {
        var result: [[String]] = []
        for count in counts {
            for text in texts where !text.trimmingCharacters(in: .whitespaces).isEmpty {
                let candidate = balancedLines(text, count: count)
                if !result.contains(candidate) {
                    result.append(candidate)
                }
            }
        }
        return result
    }

    private static func isMoreBalanced(_ lengths: [Int], than other: [Int]) -> Bool {
        let longest = lengths.max() ?? 0
        let otherLongest = other.max() ?? Int.max
        if longest != otherLongest {
            return longest < otherLongest
        }
        let spread = lengths.reduce(0) { $0 + $1 * $1 }
        let otherSpread = other.reduce(0) { $0 + $1 * $1 }
        if spread != otherSpread {
            return spread < otherSpread
        }
        return lengths.lexicographicallyPrecedes(other, by: >)
    }
}

/// Times on the widgets.
enum WidgetTime {
    /// "09:00" (README point 13): 24-hour time with two-digit hours, as Turkish writes it, whatever
    /// the device's language or 12/24-hour setting (an en-US device wrote "9:00 AM").
    static func clock(_ date: Date, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

/// The medium widget's example (README "Widget'lar"): the whole sentence on one line, else on two
/// balanced lines, never cut with "…" and never broken inside a word (2026-10-24 images: "Could
/// you tell me the way to the…"). It is the large widget's `LargeExampleText` at `.footnote`
/// serif: the learned word bold wherever `LemmaMatch` finds it (the band stays the screen's only
/// yellow mark), an irregular form ("teeth" for "tooth") plain. When neither line count fits the
/// width, the line makes its variant too tall to be chosen (`WidgetFit.reject`), so a variant
/// without the example is shown instead of a cut sentence. VoiceOver reads the whole sentence
/// once, with an English voice.
struct WidgetExampleLine: View {
    let sentence: String
    let lemma: String
    let color: AnyShapeStyle

    var body: some View {
        LargeExampleText(sentence: sentence, lemma: lemma, lines: [1, 2], typeface: WidgetExampleLine.font, color: color)
    }

    /// `.footnote` serif, the definition's size (medium widget: word 20, meaning 16, definition and
    /// example 13, next change 11; it was `.caption`, 12 pt, a fifth size).
    static let font = Font.system(.footnote, design: .serif)
}

extension View {
    /// English widget text (README point 14): the same approach as the app's
    /// `cardEnglishVoice()`, the environment's locale set to US English, so VoiceOver reads the
    /// word with an English voice. Inside `widgetTurkishVoice()` it switches back for its part.
    func widgetEnglishVoice() -> some View {
        environment(\.locale, Locale(identifier: "en_US"))
    }

    /// Turkish widget text, set on each widget view as a whole: the environment's locale set to
    /// Turkish, so VoiceOver reads the meaning, the buttons and the hints with a Turkish voice. The
    /// app is not localized (its development language is English), and on the iOS 26 simulator
    /// a localized Turkish `Text("Türkçesi: …")` reached VoiceOver tagged "en-Latn-US"
    /// (`WidgetVoiceOverTests`, 2026-10-22); with this locale and `Text(verbatim:)` it is tagged
    /// Turkish whatever the device's language.
    func widgetTurkishVoice() -> some View {
        environment(\.locale, Locale(identifier: "tr_TR"))
    }
}
