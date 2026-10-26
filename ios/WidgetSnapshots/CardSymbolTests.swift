import XCTest
import SwiftUI
import UIKit
import WidgetKit
import CoreModels

/// The words' pictures (docs/ozellik_planlari/kelime_gorselleri.md): every SF Symbol name in
/// `content-pipeline/data/card_symbols.json` (a resource of this bundle, project.yml) is drawn by
/// this system and, where the system's symbol list can be read, came with iOS 17.0 or earlier
/// (the app's deployment target). Then the large widget: the picture shows beside the word when
/// the meaning is shown, never while "Anlamı gizle" hides it; images for review
/// (`large-symbol-<word><look>`).
@MainActor
final class CardSymbolTests: XCTestCase {
    private let large = CGSize(width: 338, height: 354)
    private let largeSE = CGSize(width: 321, height: 324)
    private let margins = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    // MARK: The mapping

    /// card id -> SF Symbol name, from the bundled copy of card_symbols.json.
    private func mapping() throws -> [String: String] {
        let url = try XCTUnwrap(
            Bundle(for: CardSymbolTests.self).url(forResource: "card_symbols", withExtension: "json"),
            "card_symbols.json is not in the test bundle (project.yml, LockglowWidgetSnapshots)"
        )
        let symbols = try JSONDecoder().decode([String: String].self, from: Data(contentsOf: url))
        XCTAssertFalse(symbols.isEmpty)
        return symbols
    }

    func testEveryMappedSymbolIsDrawnByThisSystem() throws {
        let symbols = try mapping()
        var missing: [String] = []
        for (card, name) in symbols.sorted(by: { $0.key < $1.key }) {
            if UIImage(systemName: name) == nil {
                missing.append("\(card): \(name)")
            }
            // The check the views use: a name the system draws comes back unchanged.
            XCTAssertEqual(WordSymbol.systemName(name), UIImage(systemName: name) == nil ? nil : name, card)
        }
        XCTAssertTrue(missing.isEmpty, "SF Symbols this iOS (\(UIDevice.current.systemVersion)) does not have: \(missing)")
        // No name, an empty one or an unknown one: nothing is shown.
        XCTAssertNil(WordSymbol.systemName(nil))
        XCTAssertNil(WordSymbol.systemName(""))
        XCTAssertNil(WordSymbol.systemName("lockglow.no.such.symbol"))
    }

    /// Each name's first release, from the system's CoreGlyphs list (`symbols`: name -> release
    /// key, `year_to_release`: release key -> {"iOS": version}): iOS 17.0 at the latest, so an
    /// iPhone on the deployment target draws it too. When the list cannot be read (its place is
    /// not public API), the test notes it and passes: the check above still ran.
    func testEveryMappedSymbolCameWithIOS17OrEarlier() throws {
        let symbols = try mapping()
        guard let availability = CardSymbolTests.loadNameAvailability() else {
            XCTContext.runActivity(named: "name_availability.plist not found; release check skipped") { _ in }
            return
        }
        let releases = availability["symbols"] as? [String: Any] ?? [:]
        let years = availability["year_to_release"] as? [String: Any] ?? [:]
        var tooNew: [String] = []
        var unlisted: [String] = []
        for (card, name) in symbols.sorted(by: { $0.key < $1.key }) {
            guard let release = releases[name].map({ "\($0)" }) else {
                // An older alias the system still resolves is not in the list under that name.
                unlisted.append("\(card): \(name)")
                continue
            }
            let platforms = years[release] as? [String: Any]
            if let iOS = platforms?["iOS"].map({ "\($0)" }) {
                if !CardSymbolTests.version(iOS, isAtMost: [17, 0]) {
                    tooNew.append("\(card): \(name) (iOS \(iOS))")
                }
            } else if let year = Int(release.split(separator: ".").first ?? ""), year > 2023 {
                tooNew.append("\(card): \(name) (\(release))")
            }
        }
        XCTAssertTrue(tooNew.isEmpty, "symbols newer than iOS 17.0: \(tooNew)")
        if !unlisted.isEmpty {
            XCTContext.runActivity(named: "not in name_availability.plist: \(unlisted.joined(separator: ", "))") { _ in }
        }
    }

    /// The system's symbol list on the simulator (inside its runtime root) or a device.
    private static func loadNameAvailability() -> [String: Any]? {
        let relatives = [
            "/System/Library/CoreServices/CoreGlyphs.bundle/Contents/Resources/name_availability.plist",
            "/System/Library/CoreServices/CoreGlyphs.bundle/name_availability.plist",
        ]
        var roots = [""]
        if let simulatorRoot = ProcessInfo.processInfo.environment["SIMULATOR_ROOT"], !simulatorRoot.isEmpty {
            roots.insert(simulatorRoot, at: 0)
        }
        for root in roots {
            for relative in relatives {
                let path = root + relative
                guard let data = FileManager.default.contents(atPath: path),
                      let plist = try? PropertyListSerialization.propertyList(from: data, format: nil),
                      let dictionary = plist as? [String: Any] else {
                    continue
                }
                return dictionary
            }
        }
        return nil
    }

    /// "16.4" <= [17, 0]: compared part by part, missing parts count as 0.
    private static func version(_ text: String, isAtMost limit: [Int]) -> Bool {
        let parts = text.split(separator: ".").map { Int($0) ?? 0 }
        for index in 0..<max(parts.count, limit.count) {
            let part = index < parts.count ? parts[index] : 0
            let bound = index < limit.count ? limit[index] : 0
            if part != bound {
                return part < bound
            }
        }
        return true
    }

    func testVersionComparison() {
        XCTAssertTrue(CardSymbolTests.version("13.0", isAtMost: [17, 0]))
        XCTAssertTrue(CardSymbolTests.version("17", isAtMost: [17, 0]))
        XCTAssertTrue(CardSymbolTests.version("17.0", isAtMost: [17, 0]))
        XCTAssertFalse(CardSymbolTests.version("17.2", isAtMost: [17, 0]))
        XCTAssertFalse(CardSymbolTests.version("18.0", isAtMost: [17, 0]))
    }

    // MARK: The large widget

    /// "listen" (`LargeSnapshotWords`, whose fullest layout fits the 393 pt widget) with the
    /// picture card_symbols.json gives en.listen.v.1, and the same word without one.
    private func listen(symbol: String?) throws -> WidgetWord {
        let base = try XCTUnwrap(LargeSnapshotWords.all.first { $0.id == 240 })
        var word = WidgetWord(
            id: base.id, lemma: base.lemma, pos: base.pos, level: base.level, ipaUS: base.ipaUS,
            ipaUK: base.ipaUK, defMicro: base.defMicro, defShort: base.defShort, exampleEN: base.exampleEN,
            glossTR: base.glossTR, glossShortTR: base.glossShortTR, sensitivity: base.sensitivity,
            confusableIDs: base.confusableIDs, symbol: symbol
        )
        word.secondExampleEN = base.secondExampleEN
        word.warning = base.warning
        return word
    }

    func testLargeWidgetShowsThePictureOnlyWithTheMeaning() throws {
        let symbol = try XCTUnwrap(try mapping()["en.listen.v.1"])
        try XCTSkipIf(UIImage(systemName: symbol) == nil, "\(symbol) is not on this system")
        let pictured = try listen(symbol: symbol)
        let plain = try listen(symbol: nil)
        let shown = WidgetDisplayOptions.standard
        let hidden = WidgetDisplayOptions(hidesMeaning: true)
        var revealed = hidden
        revealed.meaningRevealed = true

        // Meaning shown (the default, or opened with "Göster"): the picture is drawn.
        XCTAssertNotEqual(try png(pictured, options: shown), try png(plain, options: shown))
        XCTAssertNotEqual(try png(pictured, options: revealed), try png(plain, options: revealed))
        // "Anlamı gizle" before "Göster": exactly the widget without a picture.
        XCTAssertEqual(try png(pictured, options: hidden), try png(plain, options: hidden))
    }

    /// Images for review: by day, at night, tinted and without paper on a 393 pt iPhone, and on an
    /// iPhone SE at the default size and AX3 (where the picture is the first thing to go), plus the
    /// hidden-meaning case.
    func testRenderLargeWidgetWithPicture() throws {
        let symbols = try mapping()
        let words = [
            try listen(symbol: symbols["en.listen.v.1"]),
        ]
        let looks: [(String, ColorScheme, WidgetRenderingMode, Bool, DynamicTypeSize, CGSize)] = [
            ("", .light, .fullColor, true, .large, large),
            ("-koyu", .dark, .fullColor, true, .large, large),
            ("-renkli", .dark, .accented, true, .large, large),
            ("-gece", .dark, .vibrant, false, .large, large),
            ("-se", .light, .fullColor, true, .large, largeSE),
            ("-se-ax3", .light, .fullColor, true, .accessibility3, largeSE),
        ]
        for word in words {
            for (suffix, scheme, mode, paper, textSize, size) in looks {
                let image = try render(word, options: .standard, size: size, colorScheme: scheme, renderingMode: mode, showsBackground: paper, textSize: textSize)
                attach(image, name: "large-symbol-\(word.lemma)\(suffix)")
            }
            let hidden = try render(word, options: WidgetDisplayOptions(hidesMeaning: true), size: large)
            attach(hidden, name: "large-symbol-\(word.lemma)-anlam-gizli")
        }
    }

    // MARK: Rendering

    private func png(_ word: WidgetWord, options: WidgetDisplayOptions) throws -> Data {
        let image = try render(word, options: options, size: large)
        return try XCTUnwrap(image.pngData())
    }

    private func render(
        _ word: WidgetWord,
        options: WidgetDisplayOptions,
        size: CGSize,
        colorScheme: ColorScheme = .light,
        renderingMode: WidgetRenderingMode = .fullColor,
        showsBackground: Bool = true,
        textSize: DynamicTypeSize = .large
    ) throws -> UIImage {
        let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
        let content = LargeWordView(
            entry: entry,
            margins: margins,
            renderingMode: renderingMode,
            showsBackground: showsBackground,
            options: options
        )
        .frame(width: size.width, height: size.height)
        .background {
            if renderingMode == .fullColor && showsBackground {
                Theme.surface
            } else if !showsBackground {
                Color.black
            } else {
                Color(red: 0.09, green: 0.10, blue: 0.12)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .environment(\.colorScheme, colorScheme)
        .environment(\.dynamicTypeSize, textSize)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 2
        return try XCTUnwrap(renderer.uiImage, "could not render \(word.lemma)")
    }

    private func attach(_ image: UIImage, name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
