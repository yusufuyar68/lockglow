import SwiftUI
import UIKit
import WidgetKit
import CoreModels

// Lockglow design system (docs/tasarim/README.md, docs/tasarim/lockglow_ui_mockup.html): Apple's
// semantic colors (system grouped backgrounds, label / secondaryLabel / tertiaryLabel, separator,
// one tint: ink), one bright color ("phosphor" yellow) only on the English word being learned.
// Values since 2026-10-24: docs/denetim/kontrast_tema_2026-10-22.md (top section).
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
//   - English and Turkish body text: ink (label); translation, IPA, notes: ink2 (secondaryLabel);
//     helper text: ink3 (tertiaryLabel, here kept at 4.5:1 so it can carry text).
//   - The one main button of a screen: primary with onPrimary text. By day a filled ink capsule;
//     at night no lit fill and never yellow: a faint ink tint, a full ink edge and bold text
//     (docs/tasarim/alternatifler/gece_oled.md, option C). Yellow stays on the word alone.
//   - Selected tab, option, step bar, progress: tint (ink, never yellow); soft selected fill: tintSoft.
//   - Pages: bg (systemGroupedBackground by day, pure black at night); cards, sheets and grouped
//     rows: surface (secondarySystemGroupedBackground; at night cards take the page black with a
//     line border); capsules and wells: surface2 (systemGray5); tracks: surface3 (systemGray4);
//     dividers: line (separator); control borders: lineStrong.
//   - Right / wrong / Dikkat triangle: good, bad, caution (Apple's green, red and orange, darkened
//     or lightened just enough for 4.5:1; always with an icon and a word, rule 4); their panels:
//     goodTint, badTint, cautionTint.
//
// Contrast rules (WCAG 2.2; table and script: docs/denetim/kontrast_tema_2026-10-22.md):
//   - Text is at least 4.5:1 on bg, surface and surface2 in all four looks (light, dark, each with
//     Increase Contrast), and good, bad and caution also on their own tint panel; ink2 is at least
//     7:1 on bg, surface and surface2 (small text, docs/tasarim/ogrenme_ilkeleri.md).
//   - Never ink3 text on surface3 (about 3.9:1 in both appearances). ink3 is for helper text on
//     bg, surface or surface2, icons and dots.
//   - Every border of a control (lineStrong) is at least 3:1 against bg, surface and surface2
//     (WCAG 1.4.11), 4.5:1 with Increase Contrast, on a surface or surface2 fill or none. The
//     styles below draw it; a hand-made capsule needs a 1 pt lineStrong edge,
//     since a surface2 fill alone is 1.1-1.5:1 against the page.
//   - line is decoration only (dividers, card edges): never the only sign of a control.
//
// Type (Dynamic Type text styles only; English is serif, Turkish and UI are SF Pro; no rounded,
// no italic; nothing below 11 pt `.caption2`; at most 3-4 sizes per screen):
//     Text(word.lemma).englishWordStyle().phosphorBand()          // Large Title 34 pt serif bold
//     Text(word.lemma).englishWordStyle(size: 28, maxSize: 46)    // long phrase: Title 1 step
//     Text(gloss).meaningStyle()                                  // .title bold, ink
//     Text(definition).definitionStyle()                          // .title3 serif, ink
//     Text(example).exampleStyle()                                // .body 17 pt serif, ink
//     Text(mistake.wrong).exampleFont()                           // Dikkat sentences: .body serif
//     Text(translation).exampleTranslationStyle()                 // .callout, ink2
//     Text(word.lemma).widgetWordStyle().phosphorBand(.widget)    // widgets: .title3 bold serif
//     Text(example).englishVoice()                                // VoiceOver: English voice
//   The same fonts without color: Theme.Fonts.englishWord(size:), meaning, definition, example
//   (17 pt `.body` serif, also the example and Dikkat sentences: `exampleFont()`),
//   exampleTranslation, widgetWord.
//   `englishVoice()` goes on the English Text itself (or on an element whose whole spoken text is
//   English), never on a container or a button with a Turkish label, hint or value: everything
//   under it is read with the English voice. `.combine` loses it. See the method for details.
//
// Phosphor band (rule 1, only on the English word): `.phosphorBand()` in the app,
// `.phosphorBand(.widget)` in widgets. Apply it to the single-line word Text right after its font
// modifiers (before any padding or frame): the band is measured from the text's own frame. By day
// it is a highlighter behind the lower part of the letters; at night a slanted line under the
// descenders with a faint glow (none with Increase Contrast, Reduce Transparency or the dimmed
// Always-On display); in accented and vibrant widgets (tinted Home Screen, Lock Screen) a
// thin line in the word's color. On the dimmed Always-On display every line is 1 pt
// (ogrenme_ilkeleri 2.1). The night line hangs up to ~0.45 em below the text frame: leave
// at least 8 pt (4 pt in widgets) before the next row. The modifier already adds
// `.widgetAccentable()`. Snapshot tests can force a mode: `.phosphorBand(.widget, renderingMode: .accented)`.
//   The same word inside an example sentence:
//     Text(ExampleMark.attributed(sentence, lemma: lemma, colorScheme: colorScheme))
//   (bold with a light yellow mark; `highlighted: false` for bold only, e.g. extra example rows).
//
// Controls (rule 2: everything tappable is a capsule, 44 pt hit area, no blue):
//     .buttonStyle(PrimaryCapsuleButtonStyle())                  // main, full width, 50 pt; night:
//                                                                // ink tint + 2 pt ink edge, bold
//     .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))     // large main button ("Başla")
//     .buttonStyle(SecondaryCapsuleButtonStyle())                // surface + 1.5 pt lineStrong
//     .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))     // surface2 + 1 pt lineStrong
//     .buttonStyle(ChipButtonStyle(isSelected: false))           // small chip ("Dene" examples)
//     .glassControl()                                            // Bitir, geri, Kapat only (rule 6)
//
// Containers and badges:
//     .cardSurface()                                     // surface (night: bg), 22 pt, line border
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
    /// Main text (label): black by day, white at night.
    static let ink = dynamic(light: Tone(0x000000), dark: Tone(0xFFFFFF))
    /// Secondary text (secondaryLabel as an opaque gray): translations, IPA, explanations. At
    /// least 7:1 on bg, surface and surface2, so it also carries 11-13 pt text.
    static let ink2 = dynamic(
        light: Tone(0x3C3C43), dark: Tone(0xC7C7CC),
        lightHigh: Tone(0x2C2C30), darkHigh: Tone(0xE5E5EA)
    )
    /// Helper text, placeholders, chevrons (tertiaryLabel, darkened to 4.5:1). Never text on
    /// `surface3`. With Increase Contrast it takes ink2's value.
    static let ink3 = dynamic(
        light: Tone(0x636366), dark: Tone(0x98989D),
        lightHigh: Tone(0x3C3C43), darkHigh: Tone(0xC7C7CC)
    )
    /// Fill of the one main button of a screen: ink by day; at night a 12 % ink tint over the
    /// page (no lit area and no yellow at night, gece_oled.md option C). The night edge is drawn
    /// by `PrimaryCapsuleButtonStyle`.
    static let primary = dynamic(light: Tone(0x000000), dark: Tone(0xFFFFFF, 0.12))
    /// Text and icons on `primary`, and the night edge: white by day, ink (white) at night.
    static let onPrimary = dynamic(light: Tone(0xFFFFFF), dark: Tone(0xFFFFFF))
    /// The one tint: selected tab, option, step bar and progress. Ink, also at night (never yellow).
    static let tint = dynamic(light: Tone(0x000000), dark: Tone(0xFFFFFF))
    /// Soft fill of a selected item (the selected tab).
    static let tintSoft = dynamic(
        light: Tone(0x000000, 0.08), dark: Tone(0xFFFFFF, 0.10),
        lightHigh: Tone(0x000000, 0.12), darkHigh: Tone(0xFFFFFF, 0.16)
    )
    /// Page background: systemGroupedBackground by day, pure black at night (OLED pixels off).
    static let bg = dynamic(light: Tone(0xF2F2F7), dark: Tone(0x000000))
    /// A short sheet's background: systemGroupedBackground as an elevated sheet, `bg` by day and
    /// `surface`'s #1C1C1E at night, so the sheet's edge and corners stand out from the black page
    /// (gece_oled.md step 3: sheets stay on surface at night).
    static let sheetBg = dynamic(light: Tone(0xF2F2F7), dark: Tone(0x1C1C1E))
    /// Cards by day, sheets and grouped lists, the selected segment
    /// (secondarySystemGroupedBackground).
    static let surface = dynamic(light: Tone(0xFFFFFF), dark: Tone(0x1C1C1E))
    /// Capsules, wells, unselected segments, the Dikkat box (systemGray5).
    static let surface2 = dynamic(light: Tone(0xE5E5EA), dark: Tone(0x2C2C2E))
    /// Tracks (progress, switches) and inactive steps (systemGray4). No ink3 text on it.
    static let surface3 = dynamic(light: Tone(0xD1D1D6), dark: Tone(0x3A3A3C))
    /// Dividers and card borders (separator; decoration; at night the card's only edge).
    static let line = dynamic(
        light: Tone(0x3C3C43, 0.29), dark: Tone(0x545458, 0.65),
        lightHigh: Tone(0x3C3C43, 0.45), darkHigh: Tone(0x545458)
    )
    /// Borders of options, buttons, chips and badges: at least 3:1 against bg, surface and
    /// surface2 on any of those fills (WCAG 1.4.11), 4.5:1 with Increase Contrast.
    static let lineStrong = dynamic(
        light: Tone(0x000000, 0.52), dark: Tone(0xFFFFFF, 0.42),
        lightHigh: Tone(0x000000, 0.64), darkHigh: Tone(0xFFFFFF, 0.56)
    )
    /// Right answer, "Çalışıyor" (systemGreen). Always paired with an icon and a word.
    static let good = dynamic(
        light: Tone(0x1E7433), dark: Tone(0x30D158),
        lightHigh: Tone(0x165526), darkHigh: Tone(0x58DA78)
    )
    /// 12 % good over white by day, 16 % good at night.
    static let goodTint = dynamic(light: Tone(0xE4EEE7), dark: Tone(0x30D158, 0.16))
    /// Wrong answer, reset (systemRed). Always paired with an icon and a word.
    static let bad = dynamic(
        light: Tone(0xCE0014), dark: Tone(0xFF6961),
        lightHigh: Tone(0x9A000F), darkHigh: Tone(0xFFA29D)
    )
    /// 12 % bad over white by day, 16 % bad at night.
    static let badTint = dynamic(light: Tone(0xF9E0E3), dark: Tone(0xFF6961, 0.16))
    /// Only the Dikkat triangle and "Neredeyse!" (systemOrange).
    static let caution = dynamic(
        light: Tone(0xBE3100), dark: Tone(0xFF9F0A),
        lightHigh: Tone(0x8D2400), darkHigh: Tone(0xFFAD2D)
    )
    /// Panel behind a caution result: 14 % caution over surface (mockup `.verdict.mid`).
    static let cautionTint = dynamic(light: Tone(0xF6E2DB), dark: Tone(0x3C2E1B))

    // Fixed colors for drawing that already depends on the color scheme.
    /// Day band (behind the letters).
    static let bandLight = fixed(0xF5E829)
    /// Night band (under the letters).
    static let bandDark = fixed(0xE9E040)
    /// Blurred glow under the night band: faint (at most 15-20 %, ogrenme_ilkeleri.md). The band
    /// draws none with Increase Contrast, Reduce Transparency or the dimmed Always-On display.
    static let bandGlow = fixed(0xE9E040, 0.18)
    /// The learned word in an example sentence: day highlight, night underline.
    static let markLight = fixed(0xF5E829, 0.80)
    static let markDark = fixed(0xE9E040, 0.95)
    /// Glow around the main button at night: none since the button is not filled (gece_oled.md
    /// step 1). Kept for callers; transparent.
    static let primaryGlow = fixed(0xE9E040, 0)
    /// Card shadows (light appearance only).
    static let shadowNear = fixed(0x000000, 0.05)
    static let shadowFar = fixed(0x000000, 0.12)

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
        /// The English word at a fixed size (not scaled; `englishWordStyle` scales it). The
        /// default is the Large Title size, 34 pt.
        static func englishWord(size: CGFloat = 34) -> Font {
            .system(size: size, weight: .bold, design: .serif)
        }
        /// Turkish meaning, 28 pt bold.
        static let meaning = Font.title.weight(.bold)
        /// English definition, 20 pt serif.
        static let definition = Font.system(.title3, design: .serif)
        /// English text in the example's family, 17 pt `.body` serif, never italic: example
        /// sentences and the Dikkat sentences (`exampleFont()`), collocations, the form field.
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
    /// The English word: serif bold, `size` pt at the default text size (by default the Large
    /// Title size, 34 pt), scaled with Dynamic Type relative to `.largeTitle` up to `maxSize`; one
    /// line, shrinks to 60 % before truncating.
    func englishWordStyle(size: CGFloat = 34, maxSize: CGFloat = 56) -> some View {
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

    /// An English example sentence: `.body` serif (`exampleFont()`), ink, not italic.
    func exampleStyle() -> some View {
        exampleFont()
            .foregroundStyle(Theme.ink)
    }

    /// The font of English example sentences and of the Dikkat box's wrong and right sentences:
    /// the `.body` text style (17 pt at the default text size) in serif, so it scales with Dynamic
    /// Type (ogrenme_ilkeleri 2.2, type table; 2026-10-24: Apple's type scale instead of 18 pt).
    /// `bold` for the right sentence. No color is set.
    func exampleFont(bold: Bool = false) -> some View {
        font(bold ? Theme.Fonts.example.weight(.bold) : Theme.Fonts.example)
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

    /// English text (README point 14, `accessibilitySpeechLanguage = "en-US"`). SwiftUI has no
    /// speech-language modifier; VoiceOver takes a text's language from the environment's locale.
    /// Apply it to English text only: Turkish text must keep the Turkish voice.
    ///
    /// Measured 2026-10-22 on the iOS 26.2 simulator (audit V5, V6; probe and table in
    /// docs/denetim/kontrast_tema_2026-10-22.md); not yet heard on a device:
    /// - It works: the element's `accessibilityLanguage` and the label's speech-language attribute
    ///   become "en-Latn-US" for `Text(verbatim:)`, `Text(someString)`, `Text(attributedString)`,
    ///   a button and an `.accessibilityElement(children: .ignore)` element with its own
    ///   `accessibilityLabel` (put it on that element, after the label, as the card titles do).
    ///   Prefer `Text(verbatim:)` for literals: older iOS versions were reported to keep the
    ///   device's voice for a localized `Text("breakfast")`.
    /// - `.accessibilityElement(children: .combine)` drops it: "Doğrusu: borrow" merged from a
    ///   Turkish and an English Text is read with one (the device's) voice. Keep the English part
    ///   a separate element, or give the merged element an explicit label.
    /// - A button takes the language of its label for the whole element: with an English label
    ///   (even when only the inner Text has this modifier) its Turkish hint and the "button" trait
    ///   are read with the English voice too. Give such buttons no Turkish hint, or keep the
    ///   English word out of the button.
    /// - Everything under the modifier switches, Turkish text and formatted dates or numbers
    ///   included: never put it on a mixed container.
    /// - `cardEnglishVoice()` (CardDetailViews) and `widgetEnglishVoice()` (HomeWordViews) do the
    ///   same thing; new code uses this one, which compiles in every target.
    func englishVoice() -> some View {
        environment(\.locale, Locale(identifier: "en_US"))
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
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    // is5-w-ayar: a Home Screen widget's accent (WidgetConfigurationAccent.swift); phosphor yellow
    // everywhere else.
    @Environment(\.phosphorBandColors) private var bandColors

    func body(content: Content) -> some View {
        content
            .background(alignment: .topLeading) {
                GeometryReader { proxy in
                    PhosphorBandDrawing(
                        kind: kind,
                        placement: placement,
                        size: proxy.size,
                        glows: glows,
                        isDimmed: isLuminanceReduced,
                        colors: bandColors
                    )
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

    /// The night line's glow: never with Increase Contrast or Reduce Transparency (a blur
    /// around the line), nor on the dimmed Always-On display (as little light as possible).
    private var glows: Bool {
        return contrast != .increased && !reduceTransparency && !isLuminanceReduced
    }
}

/// Draws the band in the text's coordinate space. Sizes are in em of the rendered text, derived
/// from the text's height, so they follow Dynamic Type and `minimumScaleFactor`.
private struct PhosphorBandDrawing: View {
    let kind: PhosphorBandKind
    let placement: PhosphorBandPlacement
    let size: CGSize
    /// Draws the faint glow under the night line.
    let glows: Bool
    /// The dimmed Always-On display (`isLuminanceReduced`): the line is 1 pt (ogrenme_ilkeleri 2.1).
    let isDimmed: Bool
    /// Day, night and glow colors (is5-w-ayar: `PhosphorBandColors`, phosphor yellow by default).
    let colors: PhosphorBandColors

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
                color: colors.light
            )
        case .underline:
            let isWidget = placement == .widget
            if glows {
                Ellipse()
                    .fill(colors.glow)
                    .frame(width: size.width, height: 0.24 * em)
                    .blur(radius: 0.16 * em)
                    .position(x: size.width / 2, y: underlineTop + 0.07 * em)
            }
            band(
                CGRect(
                    x: -0.08 * em,
                    y: underlineTop,
                    width: size.width + 0.16 * em,
                    height: isDimmed ? 1 : max((isWidget ? 0.1 : 0.13) * em, 1.5)
                ),
                slant: (isWidget ? 0.08 : 0.1) * em,
                color: colors.dark
            )
        case .line:
            band(
                CGRect(x: 0, y: underlineTop, width: size.width, height: isDimmed ? 1 : max(0.1 * em, 1.5)),
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
    /// The same matcher picks the widget plan's example (`LemmaMatch`, CoreModels).
    static func range(of lemma: String, in sentence: String) -> Range<String.Index>? {
        return LemmaMatch.range(of: lemma, in: sentence)
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

/// The one main button of a screen (mockup `.btn-primary`): `primary` capsule, `onPrimary`
/// text. By day a filled ink capsule. At night no lit area and no yellow (gece_oled.md option
/// C): a faint ink tint, a 2 pt ink edge (3 pt with Increase Contrast or Button Shapes) and bold
/// text set it apart from the gray-edged secondary buttons. 54 pt (`minHeight: 54`) for the
/// large bottom button.
struct PrimaryCapsuleButtonStyle: ButtonStyle {
    var fullWidth = true
    var minHeight: CGFloat = 50

    func makeBody(configuration: Configuration) -> some View {
        CapsuleButtonBody(configuration: configuration, kind: .primary, fullWidth: fullWidth, minHeight: minHeight)
    }
}

/// Any other button: a `surface` capsule with a 1.5 pt `lineStrong` border and ink text (mockup
/// `.btn-bordered`), or with `tonal` a `surface2` capsule with a 1 pt `lineStrong` edge (mockup
/// `.btn-secondary`, e.g. "Biliyorum" on the card). The gray fill alone is 1.1-1.5:1 against the
/// page; the edge gives the 3:1 boundary (audit K1), 1.5 pt with Increase Contrast or Button
/// Shapes.
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
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityShowButtonShapes) private var showsButtonShapes

    var body: some View {
        configuration.label
            // `.weight(.bold)`, not `.bold()`: `.headline` is semibold and already counts as bold,
            // so `.bold()` leaves it unchanged (seen in the 2026-10-22 screenshots).
            .font(isNightPrimary ? .headline.weight(.bold) : .headline)
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
                .overlay {
                    // The night fill is a 12 % tint, about as dark as a secondary button. The ink
                    // edge is the boundary (14-21:1) and the difference: 3.7-4.2:1 brighter than
                    // a lineStrong edge, only 2.5-2.8:1 with Increase Contrast (lineStrong is
                    // brighter there), so with Increase Contrast or Button Shapes it is twice a
                    // secondary's width (docs/denetim/kontrast_gece_c_2026-10-22.md).
                    if isNightPrimary {
                        Capsule().strokeBorder(Theme.onPrimary, lineWidth: emphasizesEdge ? 3 : 2)
                    }
                }
        case .bordered:
            Capsule()
                .fill(Theme.surface)
                .overlay(Capsule().strokeBorder(Theme.lineStrong, lineWidth: 1.5))
        case .tonal:
            Capsule()
                .fill(Theme.surface2)
                .overlay(Capsule().strokeBorder(Theme.lineStrong, lineWidth: emphasizesEdge ? 1.5 : 1))
        }
    }

    private var emphasizesEdge: Bool {
        return contrast == .increased || showsButtonShapes
    }

    /// The main button at night: not filled, so it takes an edge and bold text.
    private var isNightPrimary: Bool {
        return kind == .primary && colorScheme == .dark
    }
}

/// A small capsule (mockup `.chip`): 36 pt tall, with transparent margins up to a 44 pt hit area.
/// Unselected: `surface2` with a 1 pt `lineStrong` edge (1.5 pt with Increase Contrast or Button
/// Shapes). Selected: `surface` with a 1.5 pt `tint` border (never yellow).
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
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityShowButtonShapes) private var showsButtonShapes

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
                } else {
                    Capsule().strokeBorder(
                        Theme.lineStrong,
                        lineWidth: contrast == .increased || showsButtonShapes ? 1.5 : 1
                    )
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
    /// border, a soft shadow in the light appearance only. At night the fill is the page's black
    /// (no lit card area, gece_oled.md step 1) and the `line` border alone outlines the card; the
    /// fill stays opaque, so taps and overlapping content behave as by day. Does not clip (the
    /// band may overhang).
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
                    .fill(colorScheme == .dark ? Theme.bg : Theme.surface)
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

/// "A2 ●●○" (rule 4: the level is never color alone). A1 one dot, A2 two, B1 and above three;
/// an empty dot is a 1 pt `ink3` ring (5:1 and more; a pale fill was 1.6:1, audit K2).
/// VoiceOver reads "Seviye A2". The code is Footnote bold, or `textStyle` bold where the line
/// around it is set in another size (the Sözlük page's Callout facts).
struct LevelBadge: View {
    let code: String
    let dots: Int
    let textStyle: Font.TextStyle
    @ScaledMetric(relativeTo: .footnote) private var dotSize: CGFloat = 5

    init(_ level: Level, textStyle: Font.TextStyle = .footnote) {
        code = level.rawValue
        dots = min(3, max(0, level.rank))
        self.textStyle = textStyle
    }

    /// `code` as stored in `WidgetWord.level` ("A1", "A2", "B1"); an unknown code gets no dots.
    init(code: String, textStyle: Font.TextStyle = .footnote) {
        self.code = code
        dots = Level(rawValue: code).map { min(3, max(0, $0.rank)) } ?? 0
        self.textStyle = textStyle
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(verbatim: code)
                .font(.system(textStyle, design: .default).weight(.bold))
                .foregroundStyle(Theme.ink)
            HStack(spacing: 2) {
                ForEach(1...3, id: \.self) { dot in
                    if dot <= dots {
                        Circle()
                            .fill(Theme.ink)
                            .frame(width: dotSize, height: dotSize)
                    } else {
                        Circle()
                            .strokeBorder(Theme.ink3, lineWidth: 1)
                            .frame(width: dotSize, height: dotSize)
                    }
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
