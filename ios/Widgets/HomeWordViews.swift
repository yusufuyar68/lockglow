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
// bottom; medium: top, right and bottom), so each 34 pt circle sits 13 pt from those edges. The
// hit areas stay 44 x 44 pt and inside the widget's root view; a placeholder holds the part of the
// buttons that lies inside the margins, so the text never runs under them at any text size
// (accessibility audit D5). The glyphs stop growing at the first accessibility text size.
// Reading at a glance (A2 learner): the small widget shows the word and its Turkish meaning and
// nothing else. The medium widget adds a quiet (`ink2`) definition, example and next change.
// Layout: every line is shown whole or not at all, never cut with "…" and never broken inside a
// word. The text column is a vertical ViewThatFits over layout variants, fullest first: each
// variant gets the column's width, and the first whose height fits is shown. Inside a variant,
// each line that can shorten picks its own step for that width (`WidgetFittingWord`,
// `WidgetFittingText`). A line with no step that fits makes its variant too tall to be chosen
// (`WidgetFit.reject`), so the next variant tries smaller type or more lines. The last variant,
// the word alone, always fits.

/// How far the button group reaches into the widget margin on the widget's outer edges.
private let buttonGroupOverflow: CGFloat = 8
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
            // ogrenme_ilkeleri 2.1: the word steps down 24 → 20 → 17 pt (a phrase may take two
            // lines), then to 15 pt; the meaning starts at 17 pt bold and tries its shorter forms
            // (`WidgetGloss`) before it takes two lines or gets smaller.
            ViewThatFits(in: .vertical) {
                column(WidgetWordStep.smallWidget, meaning: .body.weight(.bold), lines: [1])
                column(WidgetWordStep.smallWidget, meaning: .body.weight(.bold), lines: [2])
                column(WidgetWordStep.smallWidget, meaning: .subheadline.weight(.bold), lines: [1])
                column(WidgetWordStep.smallWidget, meaning: .subheadline.weight(.bold), lines: [2])
                column(WidgetWordStep.smallWidgetPhrase, meaning: .subheadline.weight(.bold), lines: [1])
                column(WidgetWordStep.homeFloor, meaning: .subheadline.weight(.bold), lines: [1, 2])
                // Until every long meaning has its short form (`gloss_short`): 13 pt on two or
                // three lines rather than no meaning.
                column(WidgetWordStep.homeFloor, meaning: .footnote.weight(.bold), lines: [2, 3])
                column(WidgetWordStep.homeFloor, lastResort: true, meaning: .subheadline.weight(.bold), lines: [1, 2])
                WidgetFittingWord(
                    lemma: word.lemma,
                    steps: WidgetWordStep.homeFloor,
                    lastResort: true,
                    colors: colors,
                    renderingMode: renderingMode
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(.leading, max(margins.leading - buttonGroupOverflow, 0))
            .padding(.trailing, max(margins.trailing - buttonGroupOverflow, 0))
            .padding(.bottom, margins.bottom - bottomOverflow)
        }
    }

    /// One layout variant: the word at the first of `steps` that fits and, under it, the meaning
    /// in `typeface` on the first of `lines` line counts that fits.
    private func column(
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
            // Every card has a Turkish meaning; without one the word stands alone.
            let forms = WidgetGloss.forms(of: word)
            if !forms.isEmpty {
                WidgetMeaning(forms: forms, typeface: typeface, lines: lines, color: colors.ink)
                    .padding(.top, headerGap)
            }
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
            // one, else the micro one); only then does the meaning shorten (`WidgetGloss`), take
            // two lines and get smaller. The word alone is the last resort, so the meaning never
            // runs out of the column at large text sizes (accessibility audit D5).
            ViewThatFits(in: .vertical) {
                column(shortens: false, definition: true, example: true, nextChange: true)
                column(shortens: false, definition: true, example: true)
                column(shortens: false, definition: true)
                column(shortens: false)
                column()
                column(meaning: .subheadline.weight(.bold))
                wordRow(lastResort: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            // The button column's place (a row would take the width of the text); the column
            // itself is the overlay below.
            Color.clear
                .frame(width: Theme.minHitSize - trailingOverflow)
        }
        .padding(margins)
        .overlay(alignment: .trailing) {
            // Next in the easy corner (bottom of the column), Know the farthest from it.
            VStack(spacing: 0) {
                KnowWordButton(wordID: word.id, source: .systemMedium, colors: colors)
                Spacer(minLength: 0)
                SpeakWordButton(text: word.lemma, colors: colors)
                Spacer(minLength: 0)
                NextWordButton(wordID: word.id, source: .systemMedium, colors: colors)
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(.top, max(margins.top - buttonGroupOverflow, 0))
            .padding(.bottom, max(margins.bottom - buttonGroupOverflow, 0))
            .padding(.trailing, margins.trailing - trailingOverflow)
        }
    }

    /// The word row; with `lastResort` the word is never passed over (`WidgetFittingWord`).
    private func wordRow(lastResort: Bool = false) -> some View {
        WidgetWordRow(
            lemma: word.lemma,
            lastResort: lastResort,
            // A user's own word has no level.
            level: word.level.isEmpty ? nil : word.level,
            ipa: word.ipaUS,
            colors: colors,
            renderingMode: renderingMode
        )
    }

    /// One layout variant: the meaning on one or two lines, whole (`shortens` false) or in its
    /// shorter forms too; the next change sits at the bottom, beside the Next button.
    private func column(
        meaning typeface: Font = .callout.weight(.bold),
        shortens: Bool = true,
        definition: Bool = false,
        example: Bool = false,
        nextChange: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            wordRow()
            VStack(alignment: .leading, spacing: 3) {
                let forms = WidgetGloss.forms(of: word)
                if !forms.isEmpty {
                    WidgetMeaning(
                        forms: shortens ? forms : Array(forms.prefix(1)),
                        typeface: typeface,
                        lines: [1, 2],
                        color: colors.ink
                    )
                }
                // A user's own word has no definition and may have no example: no empty line.
                if definition && !(word.defShort.isEmpty && word.defMicro.isEmpty) {
                    WidgetDefinition(
                        texts: [word.defShort, word.defMicro],
                        typeface: .system(.footnote, design: .serif),
                        color: colors.ink2
                    )
                }
                if example && !word.exampleEN.isEmpty {
                    WidgetExampleLine(sentence: word.exampleEN, lemma: word.lemma, color: colors.ink2)
                        .widgetEnglishVoice()
                }
            }
            .padding(.top, headerGap)
            Spacer(minLength: 0)
            if nextChange, let next = entry.nextChange {
                // "Yeni kelime: 09:00": no Turkish suffix after the time (README point 13). Whole
                // or not at all, like the other lines.
                WidgetFittingText(
                    candidates: [["Yeni kelime: \(WidgetTime.clock(next))"]],
                    typeface: .caption2.weight(.medium),
                    color: colors.ink2
                )
                .padding(.top, 3)
            }
        }
    }
}

// MARK: - Parts shared with the Lock Screen views

/// The widget's colors for its rendering mode. Full color on the widget's own paper uses the
/// design tokens. When the system tints a Home Screen widget (accented and clear Home Screen,
/// StandBy at night) it keeps only each color's opacity, so two opaque tokens would look the
/// same: the system's hierarchical styles keep the meaning and definition visibly quieter than the
/// word, and the button circles become a faint wash instead of an opaque disc that tinting would
/// paint in the icon's own color. The same styles are used in full color when the system removes
/// the paper (StandBy, `showsWidgetContainerBackground`): ink on a black screen. The Lock Screen
/// has its own opaque grays (`lockScreen`).
struct WidgetColors {
    /// The word, the meaning and the button icons.
    let ink: AnyShapeStyle
    /// Definition, example, IPA, level and the next change; the meaning on the Lock Screen.
    let ink2: AnyShapeStyle
    /// The circle behind a button icon (mockup `.wb span`).
    let buttonFill: AnyShapeStyle

    /// Full color: `ink`, `ink2` and `surface2` (the background is `surface`, `WordWidgetView`).
    static var tokens: WidgetColors {
        return WidgetColors(
            ink: AnyShapeStyle(Theme.ink),
            ink2: AnyShapeStyle(Theme.ink2),
            buttonFill: AnyShapeStyle(Theme.surface2)
        )
    }

    /// Tinted rendering, or no paper: the system's primary, secondary and quaternary styles.
    static var system: WidgetColors {
        return WidgetColors(
            ink: AnyShapeStyle(HierarchicalShapeStyle.primary),
            ink2: AnyShapeStyle(HierarchicalShapeStyle.secondary),
            buttonFill: AnyShapeStyle(HierarchicalShapeStyle.quaternary)
        )
    }

    /// The Lock Screen (vibrant rendering; the system draws the background): opaque grays, white
    /// for the word and a darker gray for the meaning. The system turns their luminance into its
    /// vibrant material; Apple asks for "opaque grayscale values, rather than opacities of white"
    /// (HIG Widgets), so the hierarchy is never built with opacity. The gray stays the same on the
    /// Always-On display, where the system dims the whole screen.
    static var lockScreen: WidgetColors {
        return WidgetColors(
            ink: AnyShapeStyle(Color(white: 1)),
            ink2: AnyShapeStyle(Color(white: 0.75)),
            buttonFill: AnyShapeStyle(Color(white: 0.3))
        )
    }

    static func forMode(_ mode: WidgetRenderingMode, showsBackground: Bool = true) -> WidgetColors {
        return mode == .fullColor && showsBackground ? tokens : system
    }
}

/// One size step of a headword: `size` pt at the default text size, scaled with Dynamic Type
/// unless `scales` is false, on up to `lines` balanced lines (a single word stays on one line).
struct WidgetWordStep: Equatable {
    let size: CGFloat
    var lines = 1
    var scales = true

    /// The small widget (ogrenme_ilkeleri 2.1): 24, 20, then 17 pt on one line.
    static let smallWidget = [WidgetWordStep(size: 24), WidgetWordStep(size: 20), WidgetWordStep(size: 17)]
    /// A phrase on the small widget: two lines at 20 or 17 pt ("Could you tell / me the way to").
    static let smallWidgetPhrase = [WidgetWordStep(size: 20, lines: 2), WidgetWordStep(size: 17, lines: 2)]
    /// The Home Screen floor, 15 pt: one line, then two; at large text sizes also unscaled.
    static let homeFloor = [
        WidgetWordStep(size: 15),
        WidgetWordStep(size: 15, lines: 2),
        WidgetWordStep(size: 15, scales: false),
        WidgetWordStep(size: 15, lines: 2, scales: false),
    ]
    /// The rectangular Lock Screen widget: 17, then 15 pt on one line.
    static let lockScreen = [WidgetWordStep(size: 17), WidgetWordStep(size: 15)]
    /// The medium widget: 20, 17, 15 pt on one line, then a phrase on two lines at 17 or 15 pt;
    /// at large text sizes two unscaled 15 pt lines.
    static let mediumWidget = [
        WidgetWordStep(size: 20),
        WidgetWordStep(size: 17),
        WidgetWordStep(size: 15),
        WidgetWordStep(size: 17, lines: 2),
        WidgetWordStep(size: 15, lines: 2),
        WidgetWordStep(size: 15, lines: 2, scales: false),
    ]
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
                // VoiceOver reads the whole word once, on the first line, with an English voice.
                .accessibilityLabel(Text(verbatim: lemma))
                .accessibilityHidden(index > 0)
                .widgetEnglishVoice()
            }
        }
    }
}

/// The medium widget's word row: the word at the first of its size steps that fits whole beside
/// the level code (`WidgetWordStep.mediumWidget`: 20, 17, 15 pt, a phrase also on two lines), the
/// pronunciation when the row leaves room for it, and the level code. A word that fits no step
/// makes the variant around it too tall to be chosen, unless `lastResort`.
struct WidgetWordRow: View {
    let lemma: String
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
                steps: WidgetWordStep.mediumWidget,
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

    static let font = Font.system(.caption, design: .serif)
}

/// The level code ("A2"), small and quiet; VoiceOver reads "Seviye A2".
struct WidgetLevel: View {
    let code: String
    let color: AnyShapeStyle

    var body: some View {
        Text(code)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .lineLimit(1)
            .fixedSize()
            .accessibilityLabel(Text("Seviye \(code)"))
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
        .accessibilityLabel(Text("Türkçesi: \(spoken)"))
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
/// variant. VoiceOver reads the lines that are shown.
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
        .accessibilityElement(children: .combine)
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
/// anlamın widget'ta kısalması"): the whole meaning; its first sense, which drops what follows the
/// first comma or semicolon ("aslında, gerçekte" → "aslında") but keeps a " / " pair whole ("amca
/// / dayı"); the editor's short form (`gloss_short`, at most 16 characters). A form is never cut:
/// when none fits, the widget leaves the meaning out.
enum WidgetGloss {
    static func forms(of word: WidgetWord) -> [String] {
        guard let gloss = word.glossTR else {
            return []
        }
        return forms(of: gloss, short: short(of: word))
    }

    /// The forms without repeats ("kahvaltı" has one).
    static func forms(of gloss: String, short: String?) -> [String] {
        var result: [String] = []
        for candidate in [gloss, firstSense(of: gloss), short] {
            guard let form = candidate?.trimmingCharacters(in: .whitespaces), !form.isEmpty, !result.contains(form) else {
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
    /// without repeats.
    static func candidates(_ texts: [String], lines counts: [Int]) -> [[String]] {
        var result: [[String]] = []
        for count in counts {
            for text in texts {
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

/// The medium widget's example on one line, never cut before the learned word (README
/// "Widget'lar"): the whole sentence when it fits; otherwise the sentence cut at its end, as long
/// as the word stays whole ("Please be patient. The doctor will see…"); otherwise it starts a few
/// words before the word ("… so I called the lost and found."), at the latest at the word itself.
/// The word is bold: the band is the screen's only yellow mark. Irregular forms ("teeth" for
/// "tooth") are not found; such a sentence is shown from its start and cut at its end.
/// The line's ideal size is that of a hidden space, so the layout variants are chosen by the other
/// lines; the example then fits itself to the width it gets.
struct WidgetExampleLine: View {
    /// One way to show the sentence: `text` on one line, cut at its end when it is too long,
    /// chosen when `fitting` (its start up to the end of the word, plus the cut's "…") fits.
    struct Version: Equatable {
        let text: String
        let fitting: String
    }

    let sentence: String
    let lemma: String
    let color: AnyShapeStyle
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(verbatim: " ")
            .font(WidgetExampleLine.font)
            .hidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .leading) {
                lines(WidgetExampleLine.versions(of: sentence, lemma: lemma))
            }
    }

    static let font = Font.system(.caption, design: .serif)

    private func lines(_ versions: [Version]) -> some View {
        ViewThatFits(in: .horizontal) {
            line(versions[0])
            line(versions[1])
            line(versions[2])
            line(versions[3])
            line(versions[4])
        }
    }

    /// ViewThatFits compares the ideal width, which is the width of the hidden `fitting` text
    /// (a flexible frame reports its content's ideal width); placed, the line takes the whole
    /// width and shows as much of `text` as fits.
    private func line(_ version: Version) -> some View {
        styled(version.fitting)
            .hidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .leading) {
                styled(version.text)
            }
    }

    private func styled(_ text: String) -> some View {
        Text(ExampleMark.attributed(text, lemma: lemma, colorScheme: colorScheme, highlighted: false))
            .font(WidgetExampleLine.font)
            .foregroundStyle(color)
            .lineLimit(1)
    }

    /// Exactly five versions, fullest first: the whole sentence; the sentence cut after the word;
    /// the part from four words, two words and no word before the word, each after "… ". A version
    /// that does not exist (the word is near the start, or not found) repeats the one before it;
    /// ViewThatFits takes the first that fits, the last one otherwise.
    static func versions(of sentence: String, lemma: String) -> [Version] {
        let whole = Version(text: sentence, fitting: sentence)
        guard let match = ExampleMark.range(of: lemma, in: sentence) else {
            return Array(repeating: whole, count: 5)
        }
        let wordEnd = match.upperBound
        // Substrings share the sentence's indices.
        let wordsBefore = sentence[..<match.lowerBound].split(whereSeparator: { character in
            character.isWhitespace
        })
        var result = [whole, Version(text: sentence, fitting: String(sentence[..<wordEnd]) + "…")]
        for kept in [4, 2, 0] {
            if wordsBefore.count > kept {
                let start = kept == 0 ? match.lowerBound : wordsBefore[wordsBefore.count - kept].startIndex
                result.append(Version(
                    text: "… " + String(sentence[start...]),
                    fitting: "… " + String(sentence[start..<wordEnd]) + "…"
                ))
            } else {
                result.append(result[result.count - 1])
            }
        }
        return result
    }
}

extension View {
    /// English widget text (README point 14): the same approach as the app's
    /// `cardEnglishVoice()`, the environment's locale set to US English, so VoiceOver reads the
    /// word with an English voice. Turkish text and the time keep the device's locale.
    func widgetEnglishVoice() -> some View {
        environment(\.locale, Locale(identifier: "en_US"))
    }
}
