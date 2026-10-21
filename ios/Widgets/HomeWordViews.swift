import SwiftUI
import WidgetKit
import CoreModels

// Home Screen widgets (docs/tasarim/README.md "Widget'lar", mockup `.wg`): paper and ink, the
// phosphor band under the English word as the only bright mark. English text is serif, Turkish
// and UI text SF Pro (no rounded, no italic). Fonts stay at 11 pt or above (`.caption2` is the
// smallest style used).
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
// Reading order for an A2 learner: the word, the Turkish meaning (bold, the largest text after
// the word), the simple English definition, then the example and the next change (medium only).
// Layout: the header has the highest layout priority, the text block the next one, so they are
// sized before the spacer and the buttons. The text block is a ViewThatFits: it shows the
// fullest variant that fits the space left (measured on real cards by WidgetSnapshotTests),
// instead of truncating every line to one.

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
    @Environment(\.widgetRenderingMode) private var environmentRenderingMode
    private var word: WidgetWord { entry.word }
    private var colors: WidgetColors { WidgetColors.forMode(renderingMode ?? environmentRenderingMode) }
    /// The part of the button row that lies in the bottom margin.
    private var bottomOverflow: CGFloat { min(buttonGroupOverflow, margins.bottom) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                WidgetHeadword(lemma: word.lemma, color: colors.ink, renderingMode: renderingMode)
                Spacer(minLength: 0)
                WidgetLevel(code: word.level, color: colors.ink2)
            }
            .layoutPriority(2)
            // The micro definition (at most 28 characters) is written for this family.
            ViewThatFits(in: .vertical) {
                textBlock(definitionLines: 2)
                textBlock(definitionLines: 1)
                textBlock(definitionLines: 0)
            }
            .padding(.top, headerGap)
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

    private func textBlock(definitionLines: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let gloss = word.glossTR {
                // Up to two lines: glosses can be "sonunda kendini ... bulmak" (26 characters).
                WidgetMeaning(gloss: gloss, typeface: .subheadline.weight(.bold), maxLines: 2, color: colors.ink)
            }
            if definitionLines > 0 || word.glossTR == nil {
                Text(word.defMicro)
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(colors.ink2)
                    .lineLimit(max(definitionLines, 1))
                    .fixedSize(horizontal: false, vertical: true)
                    .widgetEnglishVoice()
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
    @Environment(\.widgetRenderingMode) private var environmentRenderingMode
    private var word: WidgetWord { entry.word }
    private var colors: WidgetColors { WidgetColors.forMode(renderingMode ?? environmentRenderingMode) }
    /// The part of the button column that lies in the trailing margin.
    private var trailingOverflow: CGFloat { min(buttonGroupOverflow, margins.trailing) }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                // The IPA goes first when the row is too narrow, so the word keeps its size.
                ViewThatFits(in: .horizontal) {
                    header(showsIPA: true)
                    header(showsIPA: false)
                }
                .layoutPriority(2)
                ViewThatFits(in: .vertical) {
                    textBlock(definitionLines: 2, showExample: true, showNextChange: true)
                    textBlock(definitionLines: 2, showExample: true, showNextChange: false)
                    textBlock(definitionLines: 1, showExample: true, showNextChange: false)
                    textBlock(definitionLines: 2, showExample: false, showNextChange: false)
                    textBlock(definitionLines: 1, showExample: false, showNextChange: false)
                }
                .padding(.top, headerGap)
                .layoutPriority(1)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

    private func header(showsIPA: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            WidgetHeadword(lemma: word.lemma, color: colors.ink, renderingMode: renderingMode)
            if showsIPA, let ipa = word.ipaUS {
                Text(ipa)
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(colors.ink2)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
            WidgetLevel(code: word.level, color: colors.ink2)
        }
    }

    private func textBlock(definitionLines: Int, showExample: Bool, showNextChange: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            if let gloss = word.glossTR {
                WidgetMeaning(gloss: gloss, typeface: .callout.weight(.bold), maxLines: 1, color: colors.ink)
            }
            Text(word.defShort)
                .font(.system(.footnote, design: .serif))
                .foregroundStyle(colors.ink2)
                .lineLimit(definitionLines)
                .fixedSize(horizontal: false, vertical: true)
                .widgetEnglishVoice()
            if showExample {
                WidgetExampleLine(sentence: word.exampleEN, lemma: word.lemma, color: colors.ink2)
                    .widgetEnglishVoice()
            }
            if showNextChange, let next = entry.nextChange {
                // "Yeni kelime: 10:00": no Turkish suffix after the time (README point 13).
                Text("Yeni kelime: \(next, style: .time)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(colors.ink2)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Parts shared with the Lock Screen views

/// The widget's colors for its rendering mode. Full color uses the design tokens. When the system
/// tints the widget (accented Home Screen, vibrant Lock Screen) it keeps only each color's
/// opacity, so two opaque tokens would look the same: the system's hierarchical styles keep the
/// meaning and definition visibly quieter than the word, and the button circles become a faint
/// wash instead of an opaque disc that tinting would paint in the icon's own color.
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

    /// Tinted and vibrant rendering: the system's primary, secondary and quaternary styles.
    static var system: WidgetColors {
        return WidgetColors(
            ink: AnyShapeStyle(HierarchicalShapeStyle.primary),
            ink2: AnyShapeStyle(HierarchicalShapeStyle.secondary),
            buttonFill: AnyShapeStyle(HierarchicalShapeStyle.quaternary)
        )
    }

    static func forMode(_ mode: WidgetRenderingMode) -> WidgetColors {
        return mode == .fullColor ? tokens : system
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

/// The Turkish meaning: SF bold, no box behind it, read as "Türkçesi: …" (README point 14).
struct WidgetMeaning: View {
    let gloss: String
    let typeface: Font
    let maxLines: Int
    let color: AnyShapeStyle

    var body: some View {
        Text(gloss)
            .font(typeface)
            .foregroundStyle(color)
            .lineLimit(maxLines)
            .minimumScaleFactor(0.85)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(Text("Türkçesi: \(gloss)"))
    }
}

/// The medium widget's example on one line, never cut before the learned word (README
/// "Widget'lar"): the whole sentence when it fits; otherwise the sentence cut at its end, as long
/// as the word stays whole ("Please be patient. The doctor will see…"); otherwise it starts a few
/// words before the word ("… so I called the lost and found."), at the latest at the word itself.
/// The word is bold: the band is the screen's only yellow mark. Irregular forms ("teeth" for
/// "tooth") are not found; such a sentence is shown from its start and cut at its end.
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
        lines(WidgetExampleLine.versions(of: sentence, lemma: lemma))
    }

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
            .font(.system(.caption, design: .serif))
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
