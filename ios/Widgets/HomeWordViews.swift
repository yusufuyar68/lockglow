import SwiftUI
import WidgetKit
import CoreModels

// Home Screen widgets (docs/tasarim/README.md "Widget'lar", mockup `.wg`): paper and ink, the
// phosphor band under the English word as the only bright mark. English text is serif, Turkish
// and UI text SF Pro (no rounded, no italic). Fonts stay at 11 pt or above (`.caption2` is the
// smallest style used); only a headword that does not fit otherwise shrinks below that.
// Home widgets have roughly 126 x 126 pt (small) and 306 x 126 pt (medium) of content area
// (116 x 116 and 289 x 116 pt on an iPhone SE); the 44 pt buttons take a large share of that, so
// the text is kept short.
// Buttons: Know, speaker, Next (WidgetButtons.swift). Three 44 pt buttons are 132 pt long: more
// than the small widget's content width and the medium widget's content height on an SE (116 pt;
// 126 pt on 6.1" phones). The widget disables the system content margins (`WordWidget`); these
// views apply them (`margins`, from `widgetContentMargins`) and draw the buttons in an overlay
// that reaches `buttonGroupOverflow` into the margin on the widget's outer edges (small: left,
// right and bottom; medium: top, right and bottom), so each 34 pt circle sits 13 pt from those
// edges. The hit areas stay 44 x 44 pt and inside the widget's root view; a placeholder holds the
// part of the buttons that lies inside the margins, so the text never runs under them. The glyphs
// stop growing at the first accessibility text size, so the group stays 132 pt and never pushes
// the text.
// Reading at a glance (A2 learner): the word is the largest text, the Turkish meaning (bold) the
// second; the English definition, the example and the next change are quiet (`ink2`) and one line
// each. The small widget shows at most three lines: the word, the meaning, and the micro definition
// only when the meaning takes one line.
// Layout: every line is a single line of text that is either shown whole or not at all, never cut
// with "…". The text column is a ViewThatFits over layout variants, fullest first; it compares the
// variants' ideal sizes (all lines on one line each) with the space left by the buttons. A word or
// meaning that does not fit steps down: it may shrink a little (`ShrinkableLine`), a phrase or a
// meaning of several words goes onto two balanced lines (`WidgetText.balancedLines`), and on the
// small widget the level code gives way to a long word. The last variant is the fallback for the
// largest text sizes and the longest phrases.

/// How far the button group reaches into the widget margin on the widget's outer edges.
private let buttonGroupOverflow: CGFloat = 8
/// Space between the word's row and the meaning: the night band hangs about 4 pt below the
/// word's frame (LockglowTheme, "Phosphor band").
private let headerGap: CGFloat = 6

struct SmallWordView: View {
    let entry: WordEntry
    /// The widget's content margins (`widgetContentMargins`); WidgetKit's default for home widgets.
    var margins = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    /// Replaces the environment's `showsWidgetContainerBackground` (snapshot tests only).
    var showsBackground: Bool? = nil
    /// Replaces the environment's `isLuminanceReduced` (snapshot tests only).
    var luminanceReduced: Bool? = nil
    @Environment(\.widgetRenderingMode) private var environmentRenderingMode
    @Environment(\.showsWidgetContainerBackground) private var environmentShowsBackground
    @Environment(\.isLuminanceReduced) private var environmentLuminanceReduced
    private var word: WidgetWord { entry.word }
    private var colors: WidgetColors {
        WidgetColors.forMode(
            renderingMode ?? environmentRenderingMode,
            showsBackground: showsBackground ?? environmentShowsBackground
        )
    }
    /// StandBy at night and other dimmed displays: no definition line.
    private var isDimmed: Bool { luminanceReduced ?? environmentLuminanceReduced }
    /// The part of the button row that lies in the bottom margin.
    private var bottomOverflow: CGFloat { min(buttonGroupOverflow, margins.bottom) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // At most three lines; the micro definition (at most 28 characters) only when it fits
            // whole under a one-line meaning.
            ViewThatFits {
                column(.large, meaningLines: 1, definition: !isDimmed)
                column(.large, meaningLines: 1)
                column(.large, meaningLines: 2)
                column(.large, wordLines: 2, meaningLines: 1)
                column(.small, meaningLines: 1, level: false)
                column(.small, meaningLines: 2, level: false)
                column(.small, wordLines: 2, meaningLines: 1, level: false)
                fallbackColumn
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
            Spacer(minLength: 4)
            // The button row's place; the row itself is the overlay below.
            Color.clear
                .frame(height: Theme.minHitSize - bottomOverflow)
        }
        .padding(margins)
        .overlay(alignment: .bottom) {
            // Next in the easy corner (bottom right), Know the farthest from it.
            HStack(spacing: 0) {
                KnowWordButton(wordID: word.id, source: .systemSmall, colors: colors)
                Spacer(minLength: 0)
                SpeakWordButton(text: word.lemma, colors: colors)
                Spacer(minLength: 0)
                NextWordButton(wordID: word.id, source: .systemSmall, colors: colors)
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(.leading, max(margins.leading - buttonGroupOverflow, 0))
            .padding(.trailing, max(margins.trailing - buttonGroupOverflow, 0))
            .padding(.bottom, margins.bottom - bottomOverflow)
        }
    }

    /// One layout variant: the word (with the level when `level`), the meaning in `meaningLines`
    /// lines and, when `definition`, the micro definition on one line.
    private func column(
        _ fit: WidgetWordFit,
        wordLines: Int = 1,
        meaningLines: Int,
        definition: Bool = false,
        level: Bool = true
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetWordLines(
                lemma: word.lemma,
                fit: fit,
                lines: wordLines,
                level: level ? word.level : nil,
                colors: colors,
                renderingMode: renderingMode
            )
            VStack(alignment: .leading, spacing: 2) {
                if let gloss = word.glossTR {
                    WidgetMeaning(gloss: gloss, typeface: .subheadline.weight(.bold), lines: meaningLines, color: colors.ink)
                    if definition {
                        WidgetDefinition(text: word.defMicro, typeface: .system(.caption, design: .serif), color: colors.ink2)
                    }
                } else {
                    // No Turkish meaning: the micro definition takes its place.
                    WidgetDefinition(text: word.defMicro, typeface: .system(.caption, design: .serif), lines: meaningLines, color: colors.ink2)
                }
            }
            .padding(.top, headerGap)
        }
    }

    /// The fallback for the longest phrases ("Could you tell me the way to") and the largest text
    /// sizes: a phrase on two lines at 17 pt, shrinking as far as it must, and the meaning at 13 pt
    /// in the room left (two lines at the default text size; cut only when even one does not fit).
    /// The one exception to three lines: such a phrase and its meaning do not fit whole in fewer.
    private var fallbackColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetWordLines(
                lemma: word.lemma,
                fit: .small,
                lines: 2,
                typeface: Font.system(.headline, design: .serif).weight(.bold),
                colors: colors,
                renderingMode: renderingMode
            )
            .layoutPriority(1)
            Group {
                if let gloss = word.glossTR {
                    WidgetMeaning(gloss: gloss, typeface: .footnote.weight(.bold), lines: 2, wraps: true, color: colors.ink)
                } else {
                    WidgetDefinition(text: word.defMicro, typeface: .system(.caption, design: .serif), lines: 2, color: colors.ink2)
                }
            }
            .padding(.top, headerGap)
        }
    }
}

struct MediumWordView: View {
    /// Which definition a layout variant shows: the short one when it fits on one line, else the
    /// micro definition (at most 28 characters).
    private enum DefinitionLength {
        case short
        case micro
    }

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
            // The definition gives way first (short, then micro), then the next change, the
            // example, the definition; the word shrinks last.
            ViewThatFits {
                column(.large, definition: .short, example: true, nextChange: true)
                column(.large, definition: .micro, example: true, nextChange: true)
                column(.large, definition: .micro, example: true)
                column(.large, definition: .micro)
                column(.large)
                column(.large, meaningLines: 2)
                column(.small, definition: .micro)
                column(.small, meaningLines: 2)
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

    /// One layout variant. The next change sits at the bottom, beside the Next button.
    private func column(
        _ fit: WidgetWordFit,
        meaningLines: Int = 1,
        definition: DefinitionLength? = nil,
        example: Bool = false,
        nextChange: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetWordLines(
                lemma: word.lemma,
                fit: fit,
                level: word.level,
                ipa: word.ipaUS,
                colors: colors,
                renderingMode: renderingMode
            )
            VStack(alignment: .leading, spacing: 3) {
                if let gloss = word.glossTR {
                    WidgetMeaning(gloss: gloss, typeface: .callout.weight(.bold), lines: meaningLines, color: colors.ink)
                }
                if let definition {
                    WidgetDefinition(
                        text: definition == .short ? word.defShort : word.defMicro,
                        typeface: .system(.footnote, design: .serif),
                        color: colors.ink2
                    )
                }
                if example {
                    WidgetExampleLine(sentence: word.exampleEN, lemma: word.lemma, color: colors.ink2)
                        .widgetEnglishVoice()
                }
            }
            .padding(.top, headerGap)
            Spacer(minLength: 0)
            if nextChange, let next = entry.nextChange {
                // "Yeni kelime: 09:00": no Turkish suffix after the time (README point 13).
                Text("Yeni kelime: \(WidgetTime.clock(next))")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(colors.ink2)
                    .lineLimit(1)
                    .padding(.top, 3)
            }
        }
    }
}

// MARK: - Parts shared with the Lock Screen views

/// The widget's colors for its rendering mode. Full color on the widget's own paper uses the
/// design tokens. When the system tints the widget (accented and clear Home Screen, vibrant Lock
/// Screen, StandBy at night) it keeps only each color's opacity, so two opaque tokens would look
/// the same: the system's hierarchical styles keep the meaning and definition visibly quieter
/// than the word, and the button circles become a faint wash instead of an opaque disc that
/// tinting would paint in the icon's own color. The same styles are used in full color when the
/// system removes the paper (StandBy, `showsWidgetContainerBackground`): ink on a black screen.
struct WidgetColors {
    /// The word, the meaning and the button icons.
    let ink: AnyShapeStyle
    /// Definition, example, IPA, level and the next change.
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

    /// Tinted and vibrant rendering, or no paper: the system's primary, secondary and quaternary
    /// styles.
    static var system: WidgetColors {
        return WidgetColors(
            ink: AnyShapeStyle(HierarchicalShapeStyle.primary),
            ink2: AnyShapeStyle(HierarchicalShapeStyle.secondary),
            buttonFill: AnyShapeStyle(HierarchicalShapeStyle.quaternary)
        )
    }

    static func forMode(_ mode: WidgetRenderingMode, showsBackground: Bool = true) -> WidgetColors {
        return mode == .fullColor && showsBackground ? tokens : system
    }
}

/// How large a layout variant draws the headword. ViewThatFits measures the word as if it already
/// had shrunk to `measuredScale` of its size (`ShrinkableLine`; the level and IPA beside it count
/// at full size); placed, the word takes the width it gets and shrinks only as far as it must
/// (`widgetWordStyle`: to 60 % at most).
enum WidgetWordFit {
    /// The word fits at 80 % of its size or more: still clearly the largest text.
    case large
    /// The word may shrink to about 65 % (the long phrases); on the small widget the level code
    /// gives way.
    case small

    var measuredScale: CGFloat {
        switch self {
        case .large:
            return 0.8
        case .small:
            return 0.65
        }
    }
}

/// The headword on one line or, for a phrase in a two-line variant, on two balanced lines, each
/// with its own band (the band is drawn for one line of text). The first line carries the IPA
/// (medium widget, when there is room) and the level code. VoiceOver reads the whole word once,
/// with an English voice.
struct WidgetWordLines: View {
    let lemma: String
    let fit: WidgetWordFit
    /// 2: a phrase in two balanced lines; a single word stays on one line.
    var lines = 1
    /// The level code ("A2"), nil to leave it out.
    var level: String? = nil
    /// The US pronunciation, shown after the word when the rest of the line leaves room for it.
    var ipa: String? = nil
    /// 20 pt on the Home Screen; the rectangular Lock Screen widget passes 17 pt.
    var typeface: Font = Theme.Fonts.widgetWord
    let colors: WidgetColors
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil

    var body: some View {
        let parts = lines > 1 ? WidgetText.balancedLines(lemma) : [lemma]
        // Room for the band, which hangs below each line's frame.
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    // Only the word shrinks; the level and the spacing keep their size.
                    ShrinkableLine(scale: fit.measuredScale) {
                        WidgetHeadword(lemma: part, typeface: typeface, color: colors.ink, renderingMode: renderingMode)
                            // VoiceOver reads the whole word once, on the first line.
                            .accessibilityLabel(Text(verbatim: lemma))
                            .accessibilityHidden(index > 0)
                            .widgetEnglishVoice()
                    }
                    .layoutPriority(1)
                    if index == 0 {
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
        }
    }
}

/// The English word with the phosphor band (README point 4): serif bold, one line, shrinking to
/// 60 % before it truncates. The band follows the rendering mode (yellow highlighter by day, a
/// yellow line under the letters at night, a thin line in the word's color when tinted) and,
/// like the word, is accentable.
struct WidgetHeadword: View {
    let lemma: String
    /// 20 pt on the Home Screen; the rectangular Lock Screen widget passes 17 pt.
    var typeface: Font = Theme.Fonts.widgetWord
    let color: AnyShapeStyle
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil

    var body: some View {
        // The Text's own font wins over the one `widgetWordStyle()` puts in the environment.
        Text(lemma)
            .font(typeface)
            .widgetWordStyle()
            .foregroundStyle(color)
            .phosphorBand(.widget, renderingMode: renderingMode)
            .widgetEnglishVoice()
    }
}

/// The pronunciation after the word on the medium widget. It takes the room the word and the
/// level leave and shows only when it fits whole; its own width never counts when ViewThatFits
/// measures the line (a hidden space of the same font sets the slot's ideal size).
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

/// The Turkish meaning: SF bold, no box behind it, read as "Türkçesi: …" (README point 14). On one
/// line, or with `lines` 2 on two balanced lines (a single word stays on one). Each line may
/// shrink to 85 % (`ShrinkableLine` lets ViewThatFits count on that). With `wraps` (fallbacks
/// only) it is one text that wraps onto up to `lines` lines and gives way when there is no room.
struct WidgetMeaning: View {
    let gloss: String
    let typeface: Font
    var lines = 1
    var wraps = false
    let color: AnyShapeStyle

    var body: some View {
        let parts = lines > 1 ? WidgetText.balancedLines(gloss) : [gloss]
        Group {
            if wraps {
                Text(verbatim: gloss)
                    .font(typeface)
                    .foregroundStyle(color)
                    // A single word shrinks rather than breaking between its letters.
                    .lineLimit(parts.count > 1 ? lines : 1)
                    .minimumScaleFactor(0.85)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                        ShrinkableLine(scale: 0.86) {
                            Text(verbatim: part)
                                .font(typeface)
                                .foregroundStyle(color)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Türkçesi: \(gloss)"))
    }
}

/// An English definition in serif, whole on one line (or `lines` balanced lines); the variant that
/// shows it is chosen only when it fits.
struct WidgetDefinition: View {
    let text: String
    let typeface: Font
    var lines = 1
    let color: AnyShapeStyle

    var body: some View {
        let parts = lines > 1 ? WidgetText.balancedLines(text) : [text]
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                Text(verbatim: part)
                    .font(typeface)
                    .foregroundStyle(color)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: text))
        .widgetEnglishVoice()
    }
}

/// Measures its line as `scale` times as wide when asked for its ideal size (ViewThatFits's
/// question), so a variant counts as fitting when its line fits once shrunk that far
/// (`minimumScaleFactor`). Any other proposal passes through: placed, the line takes the width it
/// gets and shrinks only as much as it must.
struct ShrinkableLine: Layout {
    let scale: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let line = subviews.first else {
            return .zero
        }
        let size = line.sizeThatFits(proposal)
        guard proposal.width == nil else {
            return size
        }
        return CGSize(width: (size.width * scale).rounded(.up), height: size.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for line in subviews {
            line.place(at: bounds.origin, proposal: ProposedViewSize(width: bounds.width, height: bounds.height))
        }
    }
}

/// Text helpers for the widget layouts.
enum WidgetText {
    /// `text` in two lines of about the same length, broken between words: the break that makes
    /// the longer line shortest, the first line the longer one on a tie ("Could you tell" / "me the
    /// way to", "aslında," / "gerçekte"). A single word stays one line.
    static func balancedLines(_ text: String) -> [String] {
        let words = text.split(separator: " ")
        guard words.count > 1 else {
            return [text]
        }
        var best = [text]
        var bestLength = Int.max
        for index in 1..<words.count {
            let first = words[..<index].joined(separator: " ")
            let second = words[index...].joined(separator: " ")
            let longer = max(first.count, second.count)
            if longer < bestLength || (longer == bestLength && first.count > second.count) {
                best = [first, second]
                bestLength = longer
            }
        }
        return best
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
