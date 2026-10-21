import SwiftUI
import UIKit
import WidgetKit
import CoreModels

// Lockglow design system (docs/tasarim/README.md, docs/tasarim/lockglow_ui_mockup.html): paper and
// ink, one bright color ("phosphor" yellow) only on the English word being learned.
// Compiled into the app, the widget extension and the widget snapshot bundle (ios/Shared), so it
// uses SwiftUI, UIKit, WidgetKit and CoreModels only. `Palette`, `GlowButtonStyle`, `ChoiceRow` and
// `SegmentButtons` (App/GlowStyle.swift) are app-only: QuizCardView.swift is also compiled into the
// snapshot bundle and must use the names below instead.
//
// API guide
//
// Colors (light / dark / increased contrast resolve automatically):
//     Theme.band, ink, ink2, ink3, primary, onPrimary, tint, tintSoft, bg, surface, surface2,
//     surface3, line, lineStrong, good, goodTint, bad, badTint, caution, cautionTint
//   - English and Turkish body text: ink; translation, IPA, notes: ink2; helper text: ink3.
//   - The one filled button of a screen: primary with onPrimary text (ink by day, yellow at night).
//   - Selected tab, option, step bar, progress: tint (ink, never yellow); soft selected fill: tintSoft.
//   - Pages: bg; cards: surface; capsules and wells: surface2; tracks: surface3; dividers: line;
//     control borders: lineStrong.
//   - Right / wrong / Dikkat triangle: good, bad, caution (always with an icon and a word, rule 4);
//     their panels: goodTint, badTint, cautionTint.
//
// Type (English is serif, Turkish and UI are SF Pro; no rounded, no italic):
//     Text(word.lemma).englishWordStyle().phosphorBand()          // 40 pt serif bold, scaled
//     Text(word.lemma).englishWordStyle(size: 46, maxSize: 60)    // Tekrar card front
//     Text(gloss).meaningStyle()                                  // .title bold, ink
//     Text(definition).definitionStyle()                          // .title3 serif, ink
//     Text(example).exampleStyle()                                // .body serif, ink
//     Text(translation).exampleTranslationStyle()                 // .callout, ink2
//     Text(word.lemma).widgetWordStyle().phosphorBand(.widget)    // widgets: .title3 bold serif
//   The same fonts without color: Theme.Fonts.englishWord(size:), meaning, definition, example,
//   exampleTranslation, widgetWord.
//
// Phosphor band (rule 1, only on the English word): `.phosphorBand()` in the app,
// `.phosphorBand(.widget)` in widgets. Apply it to the single-line word Text right after its font
// modifiers (before any padding or frame): the band is measured from the text's own frame. By day
// it is a highlighter behind the lower part of the letters; at night a slanted line under the
// descenders with a soft glow; in accented and vibrant widgets (tinted Home Screen, Lock Screen) a
// thin line in the word's color. The night line hangs up to ~0.45 em below the text frame: leave
// at least 8 pt (4 pt in widgets) before the next row. The modifier already adds
// `.widgetAccentable()`. Snapshot tests can force a mode: `.phosphorBand(.widget, renderingMode: .accented)`.
//   The same word inside an example sentence:
//     Text(ExampleMark.attributed(sentence, lemma: lemma, colorScheme: colorScheme))
//   (bold with a light yellow mark; `highlighted: false` for bold only, e.g. extra example rows).
//
// Controls (rule 2: everything tappable is a capsule, 44 pt hit area, no blue):
//     .buttonStyle(PrimaryCapsuleButtonStyle())                  // filled, full width, 50 pt
//     .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))     // large main button ("Başla")
//     .buttonStyle(SecondaryCapsuleButtonStyle())                // surface + lineStrong border
//     .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))     // surface2 fill, no border
//     .buttonStyle(ChipButtonStyle(isSelected: false))           // small chip ("Dene" examples)
//     .glassControl()                                            // Bitir, geri, Kapat only (rule 6)
//
// Containers and badges:
//     .cardSurface()                                     // surface, 22 pt corners, line border
//     .cardSurface(cornerRadius: Theme.Radius.wordCard)  // the word card (28 pt)
//     LevelBadge(level) / LevelBadge(code: word.level)   // "A2 ●●○", read as "Seviye A2"
//
// Dikkat diff (README point 5):
//     let diff = MistakeDiff(mistake)
//     Text(diff.wrongText())   // changed words: dotted underline in `bad`
//     Text(diff.rightText())   // changed words: underline + bold; other " / " options plain
//     MistakeDiff.sentence(mistake.wrong, containsWord: picked)   // "Neden?" rule of the quiz

// MARK: - Tokens

/// Color tokens, radii and fonts of the design (README "Kimlik: fosfor şeridi" table).
enum Theme {
    /// Phosphor yellow: only the English word's band and the same word in the example.
    static let band = dynamic(light: Tone(0xF5E829), dark: Tone(0xE9E040))
    /// Main text.
    static let ink = dynamic(
        light: Tone(0x15181B), dark: Tone(0xF3F4F0),
        lightHigh: Tone(0x0B0C0E), darkHigh: Tone(0xFFFFFF)
    )
    /// Secondary text: translations, IPA, explanations.
    static let ink2 = dynamic(
        light: Tone(0x4E555B), dark: Tone(0xB7BDC2),
        lightHigh: Tone(0x3A4046), darkHigh: Tone(0xD3D8DC)
    )
    /// Helper text, placeholders, chevrons.
    static let ink3 = dynamic(
        light: Tone(0x626A71), dark: Tone(0x8E959B),
        lightHigh: Tone(0x4E555B), darkHigh: Tone(0xB7BDC2)
    )
    /// Fill of the one main button of a screen: ink by day, phosphor at night.
    static let primary = dynamic(
        light: Tone(0x15181B), dark: Tone(0xE9E040),
        lightHigh: Tone(0x0B0C0E)
    )
    /// Text and icons on `primary`.
    static let onPrimary = dynamic(light: Tone(0xFFFFFF), dark: Tone(0x15181B))
    /// Selected tab, option, step bar and progress. Stays ink at night (never yellow).
    static let tint = dynamic(
        light: Tone(0x15181B), dark: Tone(0xF3F4F0),
        lightHigh: Tone(0x0B0C0E), darkHigh: Tone(0xFFFFFF)
    )
    /// Soft fill of a selected item (the selected tab).
    static let tintSoft = dynamic(
        light: Tone(0x15181B, 0.08), dark: Tone(0xFFFFFF, 0.10),
        lightHigh: Tone(0x15181B, 0.12), darkHigh: Tone(0xFFFFFF, 0.16)
    )
    /// Page background.
    static let bg = dynamic(light: Tone(0xF3F3EE), dark: Tone(0x0D0F11))
    /// Cards, lists, the selected segment.
    static let surface = dynamic(light: Tone(0xFFFFFF), dark: Tone(0x191C20))
    /// Capsules, wells, unselected segments, the Dikkat box.
    static let surface2 = dynamic(light: Tone(0xEBEBE4), dark: Tone(0x24282D))
    /// Tracks (progress, switches) and inactive steps.
    static let surface3 = dynamic(light: Tone(0xDEDED6), dark: Tone(0x30353B))
    /// Dividers and card borders.
    static let line = dynamic(
        light: Tone(0x15181B, 0.10), dark: Tone(0xFFFFFF, 0.09),
        lightHigh: Tone(0x15181B, 0.22), darkHigh: Tone(0xFFFFFF, 0.22)
    )
    /// Borders of options, bordered buttons and badges.
    static let lineStrong = dynamic(
        light: Tone(0x15181B, 0.22), dark: Tone(0xFFFFFF, 0.18),
        lightHigh: Tone(0x15181B, 0.45), darkHigh: Tone(0xFFFFFF, 0.40)
    )
    /// Right answer, "Çalışıyor". Always paired with an icon and a word.
    static let good = dynamic(
        light: Tone(0x17703F), dark: Tone(0x5BD08F),
        lightHigh: Tone(0x0F5A31), darkHigh: Tone(0x85E3AF)
    )
    static let goodTint = dynamic(light: Tone(0xDFF2E6), dark: Tone(0x5BD08F, 0.16))
    /// Wrong answer, reset. Always paired with an icon and a word.
    static let bad = dynamic(
        light: Tone(0xB3261E), dark: Tone(0xFF8C80),
        lightHigh: Tone(0x8E1B15), darkHigh: Tone(0xFFB0A8)
    )
    static let badTint = dynamic(light: Tone(0xFBE5E2), dark: Tone(0xFF8C80, 0.16))
    /// Only the Dikkat triangle and "Neredeyse!".
    static let caution = dynamic(
        light: Tone(0x8F5600), dark: Tone(0xFF9E5A),
        lightHigh: Tone(0x6E4200), darkHigh: Tone(0xFFBC8C)
    )
    /// Panel behind a caution result: 14 % caution over surface (mockup `.verdict.mid`).
    static let cautionTint = dynamic(light: Tone(0xEFE7DB), dark: Tone(0x392E28))

    // Fixed colors for drawing that already depends on the color scheme.
    /// Day band (behind the letters).
    static let bandLight = fixed(0xF5E829)
    /// Night band (under the letters).
    static let bandDark = fixed(0xE9E040)
    /// Blurred glow under the night band.
    static let bandGlow = fixed(0xE9E040, 0.38)
    /// The learned word in an example sentence: day highlight, night underline.
    static let markLight = fixed(0xF5E829, 0.80)
    static let markDark = fixed(0xE9E040, 0.95)
    /// Glow around the yellow main button at night.
    static let primaryGlow = fixed(0xE9E040, 0.35)
    /// Card shadows (light appearance only).
    static let shadowNear = fixed(0x15181B, 0.05)
    static let shadowFar = fixed(0x15181B, 0.12)

    /// Every tappable element is at least this tall and wide.
    static let minHitSize: CGFloat = 44

    /// Continuous corner radii of the mockup.
    enum Radius {
        /// The full word card (`.wcard`, `.hero`).
        static let wordCard: CGFloat = 28
        /// Quiz sentence, small cards (`.qcard`, `.card`).
        static let card: CGFloat = 22
        /// Grouped lists (`.group`, `.res .list`, `.steps`).
        static let group: CGFloat = 20
        /// Choice rows and quiz options (`.choice`, `.opt`).
        static let choice: CGFloat = 18
        /// Boxes inside a card: Dikkat, collocations (`.mist`, `.colls`).
        static let box: CGFloat = 16
        /// A segment inside `SegmentButtons`.
        static let segment: CGFloat = 13
    }

    /// Fonts of the type table. English text is serif (New York), Turkish and UI text SF Pro.
    /// Prefer the view modifiers (`englishWordStyle()` …), which also set color and scaling.
    enum Fonts {
        /// The English word at a fixed size (not scaled; `englishWordStyle` scales it).
        static func englishWord(size: CGFloat = 40) -> Font {
            .system(size: size, weight: .bold, design: .serif)
        }
        /// Turkish meaning, 28 pt bold.
        static let meaning = Font.title.weight(.bold)
        /// English definition, 20 pt serif.
        static let definition = Font.system(.title3, design: .serif)
        /// English example, 17 pt serif, never italic.
        static let example = Font.system(.body, design: .serif)
        /// Turkish translation of the example, 16 pt.
        static let exampleTranslation = Font.callout
        /// The word in Home Screen widgets, 20 pt bold serif.
        static let widgetWord = Font.system(.title3, design: .serif).weight(.bold)
    }

    private static func dynamic(light: Tone, dark: Tone, lightHigh: Tone? = nil, darkHigh: Tone? = nil) -> Color {
        return Color(uiColor: UIColor { traits in
            let high = traits.accessibilityContrast == .high
            if traits.userInterfaceStyle == .dark {
                return (high ? (darkHigh ?? dark) : dark).uiColor
            }
            return (high ? (lightHigh ?? light) : light).uiColor
        })
    }

    private static func fixed(_ hex: UInt32, _ opacity: Double = 1) -> Color {
        return Color(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// One sRGB value of a token.
private struct Tone: Sendable {
    let hex: UInt32
    let alpha: CGFloat

    init(_ hex: UInt32, _ alpha: CGFloat = 1) {
        self.hex = hex
        self.alpha = alpha
    }

    var uiColor: UIColor {
        return UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

// MARK: - Typography

extension View {
    /// The English word: serif bold, `size` pt at the default text size, scaled with Dynamic Type
    /// relative to `.largeTitle` up to `maxSize`; one line, shrinks to 60 % before truncating.
    func englishWordStyle(size: CGFloat = 40, maxSize: CGFloat = 56) -> some View {
        modifier(EnglishWordStyle(size: size, maxSize: maxSize))
    }

    /// The Turkish meaning: `.title` bold, ink, no box behind it.
    func meaningStyle() -> some View {
        font(Theme.Fonts.meaning)
            .foregroundStyle(Theme.ink)
    }

    /// The English definition: `.title3` serif, ink.
    func definitionStyle() -> some View {
        font(Theme.Fonts.definition)
            .foregroundStyle(Theme.ink)
    }

    /// An English example sentence: `.body` serif, ink, not italic.
    func exampleStyle() -> some View {
        font(Theme.Fonts.example)
            .foregroundStyle(Theme.ink)
    }

    /// The Turkish translation of an example: `.callout`, ink2.
    func exampleTranslationStyle() -> some View {
        font(Theme.Fonts.exampleTranslation)
            .foregroundStyle(Theme.ink2)
    }

    /// The word in Home Screen widgets: `.title3` bold serif, one line, accentable. No color is
    /// set, so the system's widget colors (and tinting) apply.
    func widgetWordStyle() -> some View {
        font(Theme.Fonts.widgetWord)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .widgetAccentable()
    }
}

private struct EnglishWordStyle: ViewModifier {
    @ScaledMetric private var size: CGFloat
    let maxSize: CGFloat

    init(size: CGFloat, maxSize: CGFloat) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: .largeTitle)
        self.maxSize = maxSize
    }

    func body(content: Content) -> some View {
        content
            .font(Theme.Fonts.englishWord(size: min(size, maxSize)))
            .foregroundStyle(Theme.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
    }
}

// MARK: - Phosphor band

/// Where the band is drawn: the night line is thinner in widgets (0.1 em instead of 0.13 em).
enum PhosphorBandPlacement {
    case app
    case widget
}

extension View {
    /// The brand mark behind / under the English word (README point 4). Apply it to the word's
    /// single-line `Text` after its font modifiers. `renderingMode` overrides the environment's
    /// `widgetRenderingMode` (snapshot tests); leave it nil elsewhere.
    func phosphorBand(_ placement: PhosphorBandPlacement = .app, renderingMode: WidgetRenderingMode? = nil) -> some View {
        modifier(PhosphorBandModifier(placement: placement, renderingMode: renderingMode))
    }
}

/// The band's slanted outline: a parallelogram whose top edge starts `slant` in from the left and
/// whose bottom edge ends `slant` before the right (a highlighter stroke).
struct PhosphorBandShape: Shape {
    var slant: CGFloat

    func path(in rect: CGRect) -> Path {
        let inset = min(max(slant, 0), rect.width / 2)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + inset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private enum PhosphorBandKind {
    /// Light appearance: yellow behind the lower part of the letters.
    case highlighter
    /// Dark appearance: a yellow line below the descenders with a blurred glow; no letter
    /// ever stands on yellow.
    case underline
    /// Accented and vibrant widgets: a thin line in the word's own (tinted) color.
    case line
}

private struct PhosphorBandModifier: ViewModifier {
    let placement: PhosphorBandPlacement
    let renderingMode: WidgetRenderingMode?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetRenderingMode) private var environmentRenderingMode
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .background(alignment: .topLeading) {
                GeometryReader { proxy in
                    PhosphorBandDrawing(kind: kind, placement: placement, size: proxy.size)
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                // The band never animates on its own; with Reduce Motion it also never follows
                // an animated change of the word.
                .transaction { transaction in
                    if reduceMotion {
                        transaction.animation = nil
                    }
                }
            }
            .widgetAccentable()
    }

    private var kind: PhosphorBandKind {
        let mode = renderingMode ?? environmentRenderingMode
        if mode == .accented || mode == .vibrant {
            return .line
        }
        return colorScheme == .dark ? .underline : .highlighter
    }
}

/// Draws the band in the text's coordinate space. Sizes are in em of the rendered text, derived
/// from the text's height, so they follow Dynamic Type and `minimumScaleFactor`.
private struct PhosphorBandDrawing: View {
    let kind: PhosphorBandKind
    let placement: PhosphorBandPlacement
    let size: CGSize

    var body: some View {
        let em = size.height / SerifMetrics.lineHeight
        let baseline = em * SerifMetrics.ascender
        // README point 4: the night line's top edge sits 2 pt below the descender line.
        let underlineTop = baseline + em * SerifMetrics.descender + 2
        switch kind {
        case .highlighter:
            band(
                CGRect(x: -0.08 * em, y: baseline - 0.56 * em, width: size.width + 0.16 * em, height: 0.8 * em),
                slant: 0.12 * em,
                color: Theme.bandLight
            )
        case .underline:
            let isWidget = placement == .widget
            Ellipse()
                .fill(Theme.bandGlow)
                .frame(width: size.width, height: 0.24 * em)
                .blur(radius: 0.16 * em)
                .position(x: size.width / 2, y: underlineTop + 0.07 * em)
            band(
                CGRect(
                    x: -0.08 * em,
                    y: underlineTop,
                    width: size.width + 0.16 * em,
                    height: max((isWidget ? 0.1 : 0.13) * em, 1.5)
                ),
                slant: (isWidget ? 0.08 : 0.1) * em,
                color: Theme.bandDark
            )
        case .line:
            band(
                CGRect(x: 0, y: underlineTop, width: size.width, height: max(0.1 * em, 1.5)),
                slant: 0.08 * em,
                color: .primary
            )
        }
    }

    private func band(_ rect: CGRect, slant: CGFloat, color: Color) -> some View {
        PhosphorBandShape(slant: slant)
            .fill(color)
            .frame(width: max(rect.width, 0), height: max(rect.height, 0))
            .position(x: rect.midX, y: rect.midY)
    }
}

/// Vertical metrics of the serif system font (New York Bold) per point of font size: the band is
/// placed from the text's height, the only size SwiftUI reports.
private enum SerifMetrics {
    private static let font: UIFont = {
        let base = UIFont.systemFont(ofSize: 100, weight: .bold)
        guard let descriptor = base.fontDescriptor.withDesign(.serif) else {
            return base
        }
        return UIFont(descriptor: descriptor, size: 100)
    }()

    static let ascender = font.ascender / 100
    /// Positive: how far the descenders reach below the baseline.
    static let descender = -font.descender / 100
    static let lineHeight = font.lineHeight > 0 ? font.lineHeight / 100 : 1.2
}

/// The learned word inside an example sentence (rule 1): bold, with a yellow mark by day and a
/// yellow underline at night. Inflected forms match ("borrow" marks "borrowed"); irregular forms
/// stay unmarked.
enum ExampleMark {
    /// The first place where `lemma` (each of its words, plus any ending) occurs as whole words.
    static func range(of lemma: String, in sentence: String) -> Range<String.Index>? {
        let parts = lemma.split(separator: " ").map { NSRegularExpression.escapedPattern(for: String($0)) + "\\w*" }
        guard !parts.isEmpty,
              let regex = try? NSRegularExpression(
                  pattern: "\\b" + parts.joined(separator: "\\s+") + "\\b",
                  options: [.caseInsensitive]
              ) else {
            return nil
        }
        let whole = NSRange(sentence.startIndex..<sentence.endIndex, in: sentence)
        guard let match = regex.firstMatch(in: sentence, options: [], range: whole) else {
            return nil
        }
        return Range(match.range, in: sentence)
    }

    /// `sentence` with the word bold and, when `highlighted`, marked. Use `highlighted: false`
    /// for further examples: at most two yellow marks per screen (the band and one example).
    static func attributed(
        _ sentence: String,
        lemma: String,
        colorScheme: ColorScheme,
        highlighted: Bool = true
    ) -> AttributedString {
        guard let found = ExampleMark.range(of: lemma, in: sentence) else {
            return AttributedString(sentence)
        }
        var word = AttributedString(String(sentence[found]))
        word.inlinePresentationIntent = .stronglyEmphasized
        if highlighted {
            if colorScheme == .dark {
                word.underlineStyle = Text.LineStyle(pattern: .solid, color: Theme.markDark)
            } else {
                word.backgroundColor = Theme.markLight
            }
        }
        var result = AttributedString(String(sentence[..<found.lowerBound]))
        result.append(word)
        result.append(AttributedString(String(sentence[found.upperBound...])))
        return result
    }
}

// MARK: - Buttons

/// The one filled button of a screen (mockup `.btn-primary`): `primary` capsule, `onPrimary`
/// text; a soft yellow glow at night. 54 pt (`minHeight: 54`) for the large bottom button.
struct PrimaryCapsuleButtonStyle: ButtonStyle {
    var fullWidth = true
    var minHeight: CGFloat = 50

    func makeBody(configuration: Configuration) -> some View {
        CapsuleButtonBody(configuration: configuration, kind: .primary, fullWidth: fullWidth, minHeight: minHeight)
    }
}

/// Any other button: a `surface` capsule with a `lineStrong` border and ink text (mockup
/// `.btn-bordered`), or with `tonal` a borderless `surface2` capsule (mockup `.btn-secondary`,
/// e.g. "Biliyorum" on the card).
struct SecondaryCapsuleButtonStyle: ButtonStyle {
    var fullWidth = false
    var minHeight: CGFloat = 44
    var tonal = false

    func makeBody(configuration: Configuration) -> some View {
        CapsuleButtonBody(
            configuration: configuration,
            kind: tonal ? .tonal : .bordered,
            fullWidth: fullWidth,
            minHeight: minHeight
        )
    }
}

private struct CapsuleButtonBody: View {
    enum Kind {
        case primary
        case bordered
        case tonal
    }

    let configuration: ButtonStyleConfiguration
    let kind: Kind
    let fullWidth: Bool
    let minHeight: CGFloat
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .font(.headline)
            .multilineTextAlignment(.center)
            .foregroundStyle(kind == .primary ? Theme.onPrimary : Theme.ink)
            .padding(.horizontal, fullWidth ? 24 : 20)
            .padding(.vertical, 8)
            .frame(
                minWidth: Theme.minHitSize,
                maxWidth: fullWidth ? .infinity : nil,
                minHeight: max(minHeight, Theme.minHitSize)
            )
            .background { fill }
            .contentShape(Capsule())
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }

    @ViewBuilder
    private var fill: some View {
        switch kind {
        case .primary:
            Capsule()
                .fill(Theme.primary)
                .shadow(color: colorScheme == .dark && isEnabled ? Theme.primaryGlow : .clear, radius: 10)
        case .bordered:
            Capsule()
                .fill(Theme.surface)
                .overlay(Capsule().strokeBorder(Theme.lineStrong, lineWidth: 1.5))
        case .tonal:
            Capsule()
                .fill(Theme.surface2)
        }
    }
}

/// A small capsule (mockup `.chip`): 36 pt tall, with transparent margins up to a 44 pt hit area.
/// Selected: `surface` with a 1.5 pt `tint` border (never yellow).
struct ChipButtonStyle: ButtonStyle {
    var isSelected = false

    func makeBody(configuration: Configuration) -> some View {
        ChipBody(configuration: configuration, isSelected: isSelected)
    }
}

private struct ChipBody: View {
    let configuration: ButtonStyleConfiguration
    let isSelected: Bool
    @ScaledMetric(relativeTo: .subheadline) private var height: CGFloat = 36
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .multilineTextAlignment(.center)
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(minWidth: Theme.minHitSize, minHeight: height)
            .background(isSelected ? Theme.surface : Theme.surface2, in: Capsule())
            .overlay {
                if isSelected {
                    Capsule().strokeBorder(Theme.tint, lineWidth: 1.5)
                }
            }
            .padding(.vertical, max(0, (Theme.minHitSize - height) / 2))
            .contentShape(Rectangle())
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

extension View {
    /// Glass for the control layer only (rule 6): Bitir, geri, Kapat. Cards, options, answer
    /// buttons, Devam and Başla stay opaque. iOS 17–25: a bordered capsule.
    @ViewBuilder
    func glassControl() -> some View {
        if #available(iOS 26.0, *) {
            self
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                .tint(Theme.ink)
        } else {
            self
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(Theme.ink)
        }
    }
}

// MARK: - Containers

extension View {
    /// A card (mockup `.wcard`, `.qcard`, `.card`): `surface` fill, continuous corners, `line`
    /// border, a soft shadow in the light appearance only. Does not clip (the band may overhang).
    func cardSurface(cornerRadius: CGFloat = Theme.Radius.card) -> some View {
        modifier(CardSurfaceModifier(cornerRadius: cornerRadius))
    }
}

private struct CardSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                shape
                    .fill(Theme.surface)
                    .shadow(color: colorScheme == .dark ? .clear : Theme.shadowNear, radius: 1, x: 0, y: 1)
                    .shadow(color: colorScheme == .dark ? .clear : Theme.shadowFar, radius: 14, x: 0, y: 10)
            }
            .overlay {
                shape.strokeBorder(Theme.line, lineWidth: 1)
            }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
}

/// "A2 ●●○" (rule 4: the level is never color alone). A1 one dot, A2 two, B1 and above three.
/// VoiceOver reads "Seviye A2".
struct LevelBadge: View {
    let code: String
    let dots: Int
    @ScaledMetric(relativeTo: .footnote) private var dotSize: CGFloat = 5

    init(_ level: Level) {
        code = level.rawValue
        dots = min(3, max(0, level.rank))
    }

    /// `code` as stored in `WidgetWord.level` ("A1", "A2", "B1"); an unknown code gets no dots.
    init(code: String) {
        self.code = code
        dots = Level(rawValue: code).map { min(3, max(0, $0.rank)) } ?? 0
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(verbatim: code)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Theme.ink)
            HStack(spacing: 2) {
                ForEach(1...3, id: \.self) { dot in
                    Circle()
                        .fill(dot <= dots ? Theme.ink : Theme.ink3.opacity(0.35))
                        .frame(width: dotSize, height: dotSize)
                }
            }
        }
        .padding(.leading, 8)
        .padding(.trailing, 9)
        .frame(minHeight: 24)
        .overlay(Capsule().strokeBorder(Theme.lineStrong, lineWidth: 1.5))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Seviye \(code)"))
    }
}

// MARK: - Dikkat diff

/// The Dikkat box's difference (README point 5): the right sentence is split on " / ", the wrong
/// sentence is compared word by word with the first option (longest common subsequence, ignoring
/// case and punctuation), and the words that are not shared are marked. Only the letters of a
/// word are marked, not the punctuation around it.
struct MistakeDiff: Equatable {
    struct Segment: Equatable {
        let text: String
        /// Not in the other sentence: dotted underline (wrong) or underline + bold (right).
        let isChanged: Bool
    }

    /// The wrong sentence, including the spaces between words.
    let wrong: [Segment]
    /// The first right option, including the spaces between words.
    let right: [Segment]
    /// The other right options (after " / "), shown unmarked.
    let otherRights: [String]

    init(wrong: String, right: String) {
        let options = right.components(separatedBy: " / ")
        let wrongTokens = MistakeDiff.tokens(wrong)
        let rightTokens = MistakeDiff.tokens(options.first ?? right)
        let kept = MistakeDiff.commonTokens(
            wrongTokens.map { MistakeDiff.normalized($0) },
            rightTokens.map { MistakeDiff.normalized($0) }
        )
        self.wrong = MistakeDiff.segments(wrongTokens, keeping: kept.wrong)
        self.right = MistakeDiff.segments(rightTokens, keeping: kept.right)
        otherRights = Array(options.dropFirst())
    }

    init(_ mistake: CardDetail.Mistake) {
        self.init(wrong: mistake.wrong, right: mistake.right)
    }

    /// The wrong sentence with its changed words underlined with dots in `color`.
    func wrongText(color: Color = Theme.bad) -> AttributedString {
        return MistakeDiff.attributed(wrong) { piece in
            piece.underlineStyle = Text.LineStyle(pattern: .dot, color: color)
        }
    }

    /// The right sentence with its changed words underlined (in the text color) and bold, then
    /// the other options unmarked.
    func rightText(includingOtherOptions: Bool = true) -> AttributedString {
        var text = MistakeDiff.attributed(right) { piece in
            piece.underlineStyle = Text.LineStyle(pattern: .solid)
            piece.inlinePresentationIntent = .stronglyEmphasized
        }
        if includingOtherOptions && !otherRights.isEmpty {
            text.append(AttributedString(" / " + otherRights.joined(separator: " / ")))
        }
        return text
    }

    /// True when `word` (one word or a phrase) occurs in `sentence` as whole words, ignoring case
    /// and punctuation: the quiz shows "Neden?" only then (README point 6).
    static func sentence(_ sentence: String, containsWord word: String) -> Bool {
        let needle = tokens(word).map { normalized($0) }.filter { !$0.isEmpty }
        let words = tokens(sentence).map { normalized($0) }.filter { !$0.isEmpty }
        guard !needle.isEmpty, needle.count <= words.count else {
            return false
        }
        for start in 0...(words.count - needle.count) where Array(words[start..<(start + needle.count)]) == needle {
            return true
        }
        return false
    }

    /// Lowercased letters, digits and inner apostrophes ("Don’t," → "don't"); empty for a token
    /// without letters ("—", "/"), which is never marked.
    static func normalized(_ token: String) -> String {
        var kept = ""
        for character in token.lowercased() {
            if character.isLetter || character.isNumber {
                kept.append(character)
            } else if character == "'" || character == "\u{2019}" {
                kept.append("'")
            }
        }
        while kept.hasPrefix("'") {
            kept.removeFirst()
        }
        while kept.hasSuffix("'") {
            kept.removeLast()
        }
        return kept
    }

    private static func tokens(_ sentence: String) -> [String] {
        return sentence.split(whereSeparator: { $0.isWhitespace }).map(String.init)
    }

    private static func isWordCharacter(_ character: Character) -> Bool {
        return character.isLetter || character.isNumber
    }

    /// Indexes of the tokens on the longest common subsequence (empty tokens never match).
    private static func commonTokens(_ a: [String], _ b: [String]) -> (wrong: Set<Int>, right: Set<Int>) {
        var lengths = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in stride(from: a.count - 1, through: 0, by: -1) {
            for j in stride(from: b.count - 1, through: 0, by: -1) {
                if !a[i].isEmpty && a[i] == b[j] {
                    lengths[i][j] = lengths[i + 1][j + 1] + 1
                } else {
                    lengths[i][j] = max(lengths[i + 1][j], lengths[i][j + 1])
                }
            }
        }
        var keptA = Set<Int>()
        var keptB = Set<Int>()
        var i = 0
        var j = 0
        while i < a.count && j < b.count {
            if !a[i].isEmpty && a[i] == b[j] {
                keptA.insert(i)
                keptB.insert(j)
                i += 1
                j += 1
            } else if lengths[i + 1][j] >= lengths[i][j + 1] {
                i += 1
            } else {
                j += 1
            }
        }
        return (keptA, keptB)
    }

    private static func segments(_ tokens: [String], keeping kept: Set<Int>) -> [Segment] {
        var result: [Segment] = []
        for (index, token) in tokens.enumerated() {
            if index > 0 {
                result.append(Segment(text: " ", isChanged: false))
            }
            guard !kept.contains(index),
                  !normalized(token).isEmpty,
                  let first = token.firstIndex(where: isWordCharacter),
                  let last = token.lastIndex(where: isWordCharacter) else {
                result.append(Segment(text: token, isChanged: false))
                continue
            }
            let end = token.index(after: last)
            if first > token.startIndex {
                result.append(Segment(text: String(token[..<first]), isChanged: false))
            }
            result.append(Segment(text: String(token[first..<end]), isChanged: true))
            if end < token.endIndex {
                result.append(Segment(text: String(token[end...]), isChanged: false))
            }
        }
        return result
    }

    private static func attributed(_ segments: [Segment], marking mark: (inout AttributedString) -> Void) -> AttributedString {
        var result = AttributedString()
        for segment in segments {
            var piece = AttributedString(segment.text)
            if segment.isChanged {
                mark(&piece)
            }
            result.append(piece)
        }
        return result
    }
}
