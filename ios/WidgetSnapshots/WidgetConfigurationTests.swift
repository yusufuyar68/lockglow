import XCTest
import SwiftUI
import UIKit
import WidgetKit
import CoreModels

/// "Widget'ı Düzenle" (is5-w-ayar, ios/Widgets/WidgetConfiguration*.swift): the intent's defaults are
/// the options of a widget without choices, the meaning stays open only while the revealed word is
/// on screen, StandBy never hides it, the accents keep their measured contrast, and every choice is
/// rendered for review (attachments named `ayar-…`, made the same way as WidgetSnapshotTests: home
/// widgets with WidgetKit's default 16 pt margins, the iPhone SE sizes also at larger text sizes;
/// the large widget with "Anlamı gizle" as `large-anlam-gizli-…`).
/// That the defaults draw today's widgets is checked on WidgetSnapshotTests' own images, which pass
/// no options: they must equal the images of the commit before this one.
@MainActor
final class WidgetConfigurationTests: XCTestCase {
    private struct Look {
        let suffix: String
        let colorScheme: ColorScheme
        let renderingMode: WidgetRenderingMode
        /// False in StandBy: the system removes the widget's paper.
        var showsBackground = true
        var dynamicTypeSize = DynamicTypeSize.large
    }

    private let day = Look(suffix: "", colorScheme: .light, renderingMode: .fullColor)
    private let night = Look(suffix: "-koyu", colorScheme: .dark, renderingMode: .fullColor)
    private let tinted = Look(suffix: "-renkli", colorScheme: .dark, renderingMode: .accented)
    private let standBy = Look(suffix: "-standby", colorScheme: .dark, renderingMode: .fullColor, showsBackground: false)

    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private let margins = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    private let small = CGSize(width: 158, height: 158)
    private let smallSE = CGSize(width: 148, height: 148)
    private let medium = CGSize(width: 338, height: 158)
    private let mediumSE = CGSize(width: 321, height: 148)
    private let large = CGSize(width: 338, height: 354)
    private let largeSE = CGSize(width: 321, height: 324)

    // MARK: - Defaults

    /// A widget placed before "Widget'ı Düzenle" gets the intent's defaults: meaning shown, phosphor
    /// yellow, example on, the same as `WidgetDisplayOptions.standard`.
    func testIntentDefaultsAreTheStandardOptions() {
        let intent = WordWidgetConfigurationIntent()
        XCTAssertFalse(intent.hidesMeaning)
        XCTAssertEqual(intent.accent, .yellow)
        XCTAssertTrue(intent.showsExample)
        XCTAssertEqual(WidgetDisplayOptions(intent), .standard)
        XCTAssertFalse(WidgetDisplayOptions.standard.meaningIsHidden)
    }

    /// Without its paper (StandBy) the phone is locked and Göster would ask for Face ID first: the
    /// meaning shows, as on the Lock Screen; the other choices stay.
    func testStandByNeverHidesTheMeaning() {
        let chosen = WidgetDisplayOptions(hidesMeaning: true, accent: .pink, showsExample: false)
        XCTAssertEqual(chosen.forContainer(showsBackground: true), chosen)
        let standBy = chosen.forContainer(showsBackground: false)
        XCTAssertFalse(standBy.meaningIsHidden)
        XCTAssertEqual(standBy.accent, .pink)
        XCTAssertFalse(standBy.showsExample)
    }

    // MARK: - Anlamı gizle

    /// "Göster" opens the meaning of the word on screen until it changes: never a later turn of the
    /// same word, never another word; without "Anlamı gizle" nothing is hidden.
    func testRevealLastsUntilTheWordChanges() {
        let word = SnapshotWords.cards[0]
        let other = SnapshotWords.cards[1]
        let entries = [
            WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600)),
            WordEntry(date: now.addingTimeInterval(3600), word: other, nextChange: now.addingTimeInterval(7200)),
            WordEntry(date: now.addingTimeInterval(7200), word: word, nextChange: nil),
        ]
        let reveal = WidgetMeaningReveal(wordID: word.id, until: now.addingTimeInterval(3600))
        let selfTest = WidgetDisplayOptions(hidesMeaning: true)

        let revealed = ConfiguredWordProvider.configure(entries, options: selfTest, reveal: reveal)
        XCTAssertEqual(revealed.map { $0.options.meaningIsHidden }, [false, true, true])
        XCTAssertEqual(revealed.map { $0.date }, entries.map { $0.date })

        let untouched = ConfiguredWordProvider.configure(entries, options: selfTest, reveal: nil)
        XCTAssertEqual(untouched.map { $0.options.meaningIsHidden }, [true, true, true])

        let plain = ConfiguredWordProvider.configure(entries, options: .standard, reveal: reveal)
        XCTAssertEqual(plain.map { $0.options }, [.standard, .standard, .standard])

        // Without a next change the reveal lasts 4 hours, but only while the word stays on screen:
        // its next turn, 2 hours later, comes hidden.
        let fallback = WidgetMeaningReveal(wordID: word.id, until: now.addingTimeInterval(4 * 3600))
        let afterFallback = ConfiguredWordProvider.configure(entries, options: selfTest, reveal: fallback)
        XCTAssertEqual(afterFallback.map { $0.options.meaningIsHidden }, [false, true, true])

        // A reveal of another word, or one that ended before the entry, opens nothing.
        let stale = WidgetMeaningReveal(wordID: word.id, until: now)
        XCTAssertFalse(stale.covers(entries[0]))
        XCTAssertFalse(WidgetMeaningReveal(wordID: other.id, until: now.addingTimeInterval(3600)).covers(entries[0]))
    }

    /// The button passes the entry's next change; without one the meaning stays open 4 hours.
    func testShowMeaningIntentRecordsTheWordChange() {
        let change = now.addingTimeInterval(3600)
        let intent = ShowMeaningIntent(wordID: 7, until: change)
        XCTAssertEqual(intent.wordID, 7)
        XCTAssertEqual(intent.untilSeconds, 1_800_003_600)
        XCTAssertEqual(
            ShowMeaningIntent.reveal(wordID: 7, untilSeconds: intent.untilSeconds, now: now),
            WidgetMeaningReveal(wordID: 7, until: change)
        )
        XCTAssertEqual(ShowMeaningIntent(wordID: 7, until: nil).untilSeconds, 0)
        XCTAssertEqual(
            ShowMeaningIntent.reveal(wordID: 7, untilSeconds: 0, now: now),
            WidgetMeaningReveal(wordID: 7, until: now.addingTimeInterval(4 * 3600))
        )
    }

    /// The reveal is one small file (the widget extension's own container on a device).
    func testRevealFileRoundTrip() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("lockglow-reveal-\(UUID().uuidString)")
            .appendingPathComponent("widget_meaning_reveal.json")
        XCTAssertNil(WidgetMeaningReveal.load(from: url))
        let first = WidgetMeaningReveal(wordID: 42, until: now)
        first.save(to: url)
        XCTAssertEqual(WidgetMeaningReveal.load(from: url), first)
        let second = WidgetMeaningReveal(wordID: 43, until: now.addingTimeInterval(60))
        second.save(to: url)
        XCTAssertEqual(WidgetMeaningReveal.load(from: url), second)
        try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }

    // MARK: - Anlamı gizle on the large widget

    /// The large widget follows "Anlamı gizle" as the small and medium widgets do: before "Göster"
    /// no Turkish meaning is drawn (two words that differ only in their meaning give the same
    /// image, at the default size and at AX3 on an iPhone SE) and the widget differs from the one
    /// with the meaning shown; after "Göster" it is exactly the widget without the choice. StandBy
    /// (no paper) never hides it.
    func testLargeWidgetHidesOnlyTheMeaning() throws {
        let hidden = WidgetDisplayOptions(hidesMeaning: true)
        let opened = WidgetDisplayOptions(hidesMeaning: true, meaningRevealed: true)
        let lemmas = ["breakfast", "actually", "Could you tell me the way to", "listen"]
        let words = LargeSnapshotWords.all.filter { lemmas.contains($0.lemma) }
        XCTAssertEqual(words.count, lemmas.count)
        let seAX3 = Look(suffix: "-ax3", colorScheme: .light, renderingMode: .fullColor, dynamicTypeSize: .accessibility3)
        let cases: [(look: Look, size: CGSize)] = [(day, large), (day, largeSE), (seAX3, largeSE)]
        for word in words {
            let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
            let renamed = WordEntry(date: now, word: withMeaning("zzz başka bir anlam", of: word), nextChange: now.addingTimeInterval(3600))
            for (look, size) in cases {
                let context = "\(word.lemma) \(Int(size.width))\(look.suffix)"
                let hiddenImage = try largePNG(entry, options: hidden, size: size, look: look)
                XCTAssertEqual(hiddenImage, try largePNG(renamed, options: hidden, size: size, look: look), "meaning drawn while hidden: \(context)")
                XCTAssertNotEqual(hiddenImage, try largePNG(entry, options: .standard, size: size, look: look), "hidden looks like shown: \(context)")
                XCTAssertEqual(try largePNG(entry, options: opened, size: size, look: look), try largePNG(entry, options: .standard, size: size, look: look), "opened differs from shown: \(context)")
            }
            XCTAssertEqual(
                try largePNG(entry, options: hidden.forContainer(showsBackground: false), size: large, look: standBy),
                try largePNG(entry, options: .standard, size: large, look: standBy),
                "StandBy hides the meaning: \(word.lemma)"
            )
        }
    }

    /// "Vurgu rengi" reaches the large widget's band too, as on the small and medium widgets: each
    /// color draws a different widget, and yellow is the widget without choices.
    func testLargeWidgetTakesTheAccent() throws {
        let word = try XCTUnwrap(LargeSnapshotWords.all.first { $0.lemma == "breakfast" })
        let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
        let yellow = try largePNG(entry, options: WidgetDisplayOptions(accent: .yellow), size: large, look: day)
        let green = try largePNG(entry, options: WidgetDisplayOptions(accent: .green), size: large, look: day)
        let pink = try largePNG(entry, options: WidgetDisplayOptions(accent: .pink), size: large, look: day)
        XCTAssertEqual(yellow, try largePNG(entry, options: .standard, size: large, look: day))
        XCTAssertNotEqual(green, yellow)
        XCTAssertNotEqual(pink, yellow)
        XCTAssertNotEqual(pink, green)
    }

    /// Images for review (`large-anlam-gizli-<word><look>`): "Göster" in the meaning's place by
    /// day, at night, tinted and in StandBy (meaning shown there) on a 393 pt iPhone, on an iPhone
    /// SE (`-se-`) at the default and three larger text sizes (`-xxxl`, `-ax1`, `-ax3`), and opened
    /// (`-acik`); with a picture (`-resimli-`), hidden and opened.
    func testRenderLargeWidgetWithHiddenMeaning() {
        let hidden = WidgetDisplayOptions(hidesMeaning: true)
        let opened = WidgetDisplayOptions(hidesMeaning: true, meaningRevealed: true)
        let lemmas = ["breakfast", "actually", "Could you tell me the way to", "listen", "awkward"]
        let words = LargeSnapshotWords.all.filter { lemmas.contains($0.lemma) }
        XCTAssertEqual(words.count, lemmas.count)
        for word in words {
            let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
            let name = word.lemma
            for look in [day, night, tinted, standBy] {
                // As WordWidgetView passes them: StandBy shows the meaning.
                let shown = hidden.forContainer(showsBackground: look.showsBackground)
                renderLarge(entry, options: shown, size: large, look: look, name: "large-anlam-gizli-\(name)\(look.suffix)")
            }
            renderLarge(entry, options: opened, size: large, look: day, name: "large-anlam-gizli-\(name)-acik")
            for look in [day] + textSizes(of: day) {
                renderLarge(entry, options: hidden, size: largeSE, look: look, name: "large-anlam-gizli-se-\(name)\(look.suffix)")
            }
            renderLarge(entry, options: opened, size: largeSE, look: day, name: "large-anlam-gizli-se-\(name)-acik")
        }
        // The word's picture ("listen" has "ear" in card_symbols.json): hidden with the meaning,
        // back with it after "Göster".
        if let listen = LargeSnapshotWords.all.first(where: { $0.lemma == "listen" }) {
            let pictured = withMeaning(listen.glossTR ?? "", of: listen, symbol: "ear")
            let entry = WordEntry(date: now, word: pictured, nextChange: now.addingTimeInterval(3600))
            renderLarge(entry, options: hidden, size: large, look: day, name: "large-anlam-gizli-resimli-\(listen.lemma)")
            renderLarge(entry, options: opened, size: large, look: day, name: "large-anlam-gizli-resimli-\(listen.lemma)-acik")
        }
    }

    // MARK: - Vurgu rengi

    /// WCAG 2.2 contrast of every accent: by day the word's ink (and its Increase Contrast value)
    /// stands on the band, at least 7:1; at night the band is a line under the word on the night
    /// surface (the widget's background) and on StandBy's black, at least 3:1 (non-text). Yellow
    /// is the theme's band. The ink and surface values are LockglowTheme's (2026-10-24: Apple's
    /// semantic colors, ink is black by day with and without Increase Contrast).
    func testAccentsKeepTheirContrast() throws {
        let ink: UInt32 = 0x000000
        let inkHigh: UInt32 = 0x000000
        let nightSurface: UInt32 = 0x1C1C1E
        for accent in WidgetAccent.allCases {
            let tones = accent.tones
            XCTAssertGreaterThanOrEqual(contrast(ink, tones.day), 7, "\(accent) by day")
            XCTAssertGreaterThanOrEqual(contrast(inkHigh, tones.day), 7, "\(accent) by day, Increase Contrast")
            XCTAssertGreaterThanOrEqual(contrast(tones.night, nightSurface), 3, "\(accent) at night")
            XCTAssertGreaterThanOrEqual(contrast(tones.night, 0x000000), 3, "\(accent) in StandBy")
        }
        XCTAssertEqual(try hex(Theme.bandLight), WidgetAccent.yellow.tones.day)
        XCTAssertEqual(try hex(Theme.bandDark), WidgetAccent.yellow.tones.night)
    }

    // MARK: - Images

    func testRenderConfigurationChoices() {
        let hidden = WidgetDisplayOptions(hidesMeaning: true)
        let opened = WidgetDisplayOptions(hidesMeaning: true, meaningRevealed: true)
        let noExample = WidgetDisplayOptions(showsExample: false)
        // A typical word, the longest phrase and a long meaning.
        let words = SnapshotWords.cards.filter { ["breakfast", "Could you tell me the way to", "disagree"].contains($0.lemma) }
        XCTAssertEqual(words.count, 3)
        for word in words {
            let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
            let name = word.lemma
            for look in [day, night, tinted, standBy] {
                // As WordWidgetView passes them: StandBy shows the meaning.
                let shown = hidden.forContainer(showsBackground: look.showsBackground)
                renderSmall(entry, options: shown, size: small, look: look, name: "ayar-small-\(name)-gizli\(look.suffix)")
            }
            renderSmall(entry, options: opened, size: small, look: day, name: "ayar-small-\(name)-acik")
            for look in [day] + textSizes(of: day) {
                renderSmall(entry, options: hidden, size: smallSE, look: look, name: "ayar-small-se-\(name)-gizli\(look.suffix)")
                renderMedium(entry, options: hidden, size: mediumSE, look: look, name: "ayar-medium-se-\(name)-gizli\(look.suffix)")
            }
            for look in [day, night, tinted] {
                renderMedium(entry, options: hidden, size: medium, look: look, name: "ayar-medium-\(name)-gizli\(look.suffix)")
            }
            renderMedium(entry, options: opened, size: medium, look: day, name: "ayar-medium-\(name)-acik")
            renderMedium(entry, options: noExample, size: medium, look: day, name: "ayar-medium-\(name)-ornek-yok")
            renderMedium(entry, options: noExample, size: mediumSE, look: day, name: "ayar-medium-se-\(name)-ornek-yok")
        }
        let breakfast = WordEntry(date: now, word: SnapshotWords.cards[0], nextChange: now.addingTimeInterval(3600))
        for accent in WidgetAccent.allCases {
            let options = WidgetDisplayOptions(accent: accent)
            for look in [day, night, standBy] {
                renderSmall(breakfast, options: options, size: small, look: look, name: "ayar-small-vurgu-\(accent.rawValue)\(look.suffix)")
            }
            for look in [day, night, tinted] {
                renderMedium(breakfast, options: options, size: medium, look: look, name: "ayar-medium-vurgu-\(accent.rawValue)\(look.suffix)")
            }
        }
    }

    // MARK: - Helpers

    private func textSizes(of look: Look) -> [Look] {
        let sizes: [(suffix: String, size: DynamicTypeSize)] = [
            ("-xxxl", .xxxLarge),
            ("-ax1", .accessibility1),
            ("-ax3", .accessibility3),
        ]
        return sizes.map { textSize in
            Look(
                suffix: look.suffix + textSize.suffix,
                colorScheme: look.colorScheme,
                renderingMode: look.renderingMode,
                showsBackground: look.showsBackground,
                dynamicTypeSize: textSize.size
            )
        }
    }

    private func renderSmall(_ entry: WordEntry, options: WidgetDisplayOptions, size: CGSize, look: Look, name: String) {
        let view = SmallWordView(
            entry: entry,
            margins: margins,
            renderingMode: look.renderingMode,
            showsBackground: look.showsBackground,
            options: options
        )
        attach(view, size: size, look: look, name: name)
    }

    private func renderMedium(_ entry: WordEntry, options: WidgetDisplayOptions, size: CGSize, look: Look, name: String) {
        let view = MediumWordView(
            entry: entry,
            margins: margins,
            renderingMode: look.renderingMode,
            showsBackground: look.showsBackground,
            options: options
        )
        attach(view, size: size, look: look, name: name)
    }

    private func largeView(_ entry: WordEntry, options: WidgetDisplayOptions, look: Look) -> LargeWordView {
        return LargeWordView(
            entry: entry,
            margins: margins,
            renderingMode: look.renderingMode,
            showsBackground: look.showsBackground,
            options: options
        )
    }

    /// The large widget at 2x, as LargeWidgetSnapshotTests renders it.
    private func renderLarge(_ entry: WordEntry, options: WidgetDisplayOptions, size: CGSize, look: Look, name: String) {
        attach(largeView(entry, options: options, look: look), size: size, look: look, name: name, scale: 2)
    }

    private func largePNG(_ entry: WordEntry, options: WidgetDisplayOptions, size: CGSize, look: Look) throws -> Data {
        let image = try XCTUnwrap(renderer(largeView(entry, options: options, look: look), size: size, look: look, scale: 2).uiImage)
        return try XCTUnwrap(image.pngData())
    }

    /// `word` with another Turkish meaning (no short form) and, when given, a picture; the large
    /// widget's details kept.
    private func withMeaning(_ meaning: String, of word: WidgetWord, symbol: String? = nil) -> WidgetWord {
        var copy = WidgetWord(
            id: word.id, lemma: word.lemma, pos: word.pos, level: word.level, ipaUS: word.ipaUS,
            ipaUK: word.ipaUK, defMicro: word.defMicro, defShort: word.defShort, exampleEN: word.exampleEN,
            glossTR: meaning, glossShortTR: nil, sensitivity: word.sensitivity,
            confusableIDs: word.confusableIDs, symbol: symbol ?? word.symbol
        )
        copy.secondExampleEN = word.secondExampleEN
        copy.warning = word.warning
        return copy
    }

    private func attach<V: View>(_ view: V, size: CGSize, look: Look, name: String, scale: CGFloat = 3) {
        guard let image = renderer(view, size: size, look: look, scale: scale).uiImage else {
            XCTFail("could not render \(name)")
            return
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// What WidgetKit draws behind the view (WidgetSnapshotTests): the widget's paper in full
    /// color, black in StandBy, a dark panel when tinted.
    private func renderer<V: View>(_ view: V, size: CGSize, look: Look, scale: CGFloat = 3) -> ImageRenderer<some View> {
        let content = view
            .frame(width: size.width, height: size.height)
            .background {
                if look.renderingMode == .fullColor && look.showsBackground {
                    Theme.surface
                } else if !look.showsBackground {
                    Color.black
                } else {
                    Color(red: 0.09, green: 0.10, blue: 0.12)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .environment(\.colorScheme, look.colorScheme)
            .environment(\.dynamicTypeSize, look.dynamicTypeSize)
        let imageRenderer = ImageRenderer(content: content)
        imageRenderer.scale = scale
        return imageRenderer
    }

    /// WCAG 2.2 contrast ratio of two opaque sRGB colors.
    private func contrast(_ first: UInt32, _ second: UInt32) -> Double {
        func channel(_ value: UInt32) -> Double {
            let c = Double(value) / 255
            return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        func luminance(_ hex: UInt32) -> Double {
            return 0.2126 * channel((hex >> 16) & 0xFF) + 0.7152 * channel((hex >> 8) & 0xFF) + 0.0722 * channel(hex & 0xFF)
        }
        let a = luminance(first)
        let b = luminance(second)
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }

    /// The sRGB value of a fixed theme color (`Theme.bandLight`, `bandDark`).
    private func hex(_ color: Color) throws -> UInt32 {
        let resolved = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        XCTAssertTrue(resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        func byte(_ value: CGFloat) -> UInt32 {
            return UInt32((min(max(value, 0), 1) * 255).rounded())
        }
        return byte(red) << 16 | byte(green) << 8 | byte(blue)
    }
}
