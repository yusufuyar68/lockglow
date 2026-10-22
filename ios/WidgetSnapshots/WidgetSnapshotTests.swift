import XCTest
import SwiftUI
import UIKit
import WidgetKit
import CoreModels

/// Renders the widget views (compiled into this bundle from Widgets/) at real widget sizes and
/// attaches the images, so the layouts can be reviewed in CI without placing a widget on a home
/// screen. An approximation: WidgetKit's own chrome, tinting and Lock Screen vibrancy are not
/// reproduced; home widgets get WidgetKit's default 16 pt content margin. The widget disables
/// the system margins and the views apply them, so the margins are passed in as on a device.
/// The views are told the rendering mode and whether the system shows their paper (the
/// environment's own values cannot be set here), so the tinted images show the thin band line and
/// the system text styles on a dark stand-in for the tinted background, the StandBy images the
/// small widget without its paper on black (by day in full color, at night, `-standby-gece`, in
/// the system styles: the system's red tint is not reproduced), and the Lock Screen images the
/// opaque grays on a dark wallpaper (darker still on the Always-On display, `-aod`).
/// The iPhone SE sizes are also rendered at three larger text sizes (`-xxxl`, `-ax1`, `-ax3`):
/// the meaning must never run under the buttons or be cut (accessibility audit D5).
@MainActor
final class WidgetSnapshotTests: XCTestCase {
    private enum Kind {
        case small
        case medium
        case rectangular
        case inline
    }

    private struct Family {
        let name: String
        let kind: Kind
        let size: CGSize
        let margin: CGFloat
        /// Also rendered at night, tinted and (small) in StandBy: the 393 pt sizes.
        let allLooks: Bool
        /// Also rendered at larger text sizes: the SE sizes.
        var textSizes = false
    }

    /// The appearance an image is rendered in; `suffix` is added to the attachment name.
    private struct Look {
        let suffix: String
        let colorScheme: ColorScheme
        let renderingMode: WidgetRenderingMode
        /// False in StandBy: the system removes the widget's paper.
        var showsBackground = true
        /// The Always-On display (only the backdrop changes).
        var luminanceReduced = false
        var dynamicTypeSize = DynamicTypeSize.large
    }

    // Point sizes from the HIG widget size table: a 393 pt wide iPhone (15/16/17) and the 375 x
    // 667 pt iPhone SE.
    private let families = [
        Family(name: "small", kind: .small, size: CGSize(width: 158, height: 158), margin: 16, allLooks: true),
        Family(name: "small-se", kind: .small, size: CGSize(width: 148, height: 148), margin: 16, allLooks: false, textSizes: true),
        Family(name: "medium", kind: .medium, size: CGSize(width: 338, height: 158), margin: 16, allLooks: true),
        Family(name: "medium-se", kind: .medium, size: CGSize(width: 321, height: 148), margin: 16, allLooks: false, textSizes: true),
        Family(name: "rect", kind: .rectangular, size: CGSize(width: 160, height: 72), margin: 0, allLooks: false),
        Family(name: "rect-se", kind: .rectangular, size: CGSize(width: 153, height: 68), margin: 0, allLooks: false, textSizes: true),
        Family(name: "inline", kind: .inline, size: CGSize(width: 234, height: 26), margin: 0, allLooks: false),
        Family(name: "inline-se", kind: .inline, size: CGSize(width: 225, height: 26), margin: 0, allLooks: false),
    ]

    private let day = Look(suffix: "", colorScheme: .light, renderingMode: .fullColor)
    private let night = Look(suffix: "-koyu", colorScheme: .dark, renderingMode: .fullColor)
    private let tinted = Look(suffix: "-renkli", colorScheme: .dark, renderingMode: .accented)
    /// StandBy by day: full color without the widget's paper.
    private let standBy = Look(suffix: "-standby", colorScheme: .dark, renderingMode: .fullColor, showsBackground: false)
    /// StandBy at night: the system draws the widget in vibrant mode without its paper.
    private let standByNight = Look(suffix: "-standby-gece", colorScheme: .dark, renderingMode: .vibrant, showsBackground: false)
    /// The Lock Screen: light text on a dark wallpaper.
    private let lockScreen = Look(suffix: "", colorScheme: .dark, renderingMode: .vibrant)
    /// The Always-On display: the Lock Screen dimmed.
    private let alwaysOn = Look(suffix: "-aod", colorScheme: .dark, renderingMode: .vibrant, luminanceReduced: true)
    /// The larger text sizes of the SE images.
    private let textSizes: [(suffix: String, size: DynamicTypeSize)] = [
        ("-xxxl", .xxxLarge),
        ("-ax1", .accessibility1),
        ("-ax3", .accessibility3),
    ]

    func testRenderWidgetFamiliesForStressWords() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        for word in SnapshotWords.all {
            let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
            for family in families {
                for look in looks(for: family) {
                    render(
                        view(for: family, look: look, entry: entry),
                        family: family,
                        look: look,
                        name: "\(family.name)-\(word.lemma)\(look.suffix)"
                    )
                }
            }
        }
    }

    /// "Yeni kelime: 09:00" whatever the simulator's language (en-US wrote "9:00 AM").
    func testNextChangeClockIsTwentyFourHour() throws {
        let timeZone = try XCTUnwrap(TimeZone(identifier: "Europe/Istanbul"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let morning = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 10, day: 22, hour: 9, minute: 0)))
        let evening = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 10, day: 22, hour: 21, minute: 5)))
        XCTAssertEqual(WidgetTime.clock(morning, timeZone: timeZone), "09:00")
        XCTAssertEqual(WidgetTime.clock(evening, timeZone: timeZone), "21:05")
    }

    /// Phrases and meanings that do not fit on one line break between words into lines of about
    /// the same length; a single word is never broken.
    func testBalancedLines() {
        XCTAssertEqual(WidgetText.balancedLines("Could you tell me the way to"), ["Could you tell", "me the way to"])
        XCTAssertEqual(WidgetText.balancedLines("kendini pek iyi hissetmemek"), ["kendini pek iyi", "hissetmemek"])
        XCTAssertEqual(WidgetText.balancedLines("sonunda kendini ... bulmak"), ["sonunda kendini", "... bulmak"])
        XCTAssertEqual(WidgetText.balancedLines("aslında, gerçekte"), ["aslında,", "gerçekte"])
        XCTAssertEqual(WidgetText.balancedLines("sabırsızlanıyorum"), ["sabırsızlanıyorum"])
        XCTAssertEqual(WidgetText.balancedLines("kendini pek iyi hissetmemek", count: 3), ["kendini", "pek iyi", "hissetmemek"])
        XCTAssertEqual(WidgetText.balancedLines("… yolunu tarif eder misiniz?", count: 3), ["… yolunu", "tarif eder", "misiniz?"])
        XCTAssertEqual(WidgetText.balancedLines("aslında, gerçekte", count: 3), ["aslında,", "gerçekte"])
        XCTAssertEqual(WidgetText.balancedLines("misunderstanding", count: 2), ["misunderstanding"])
    }

    /// The meaning shortens to the editor's short form when the card has one, else to its first
    /// sense (a " / " pair stays whole); it is never cut and no form repeats.
    func testGlossFormsNeverCutTheMeaning() {
        XCTAssertEqual(WidgetGloss.forms(of: "aslında, gerçekte", short: nil), ["aslında, gerçekte", "aslında"])
        XCTAssertEqual(WidgetGloss.forms(of: "aslında, gerçekte", short: " "), ["aslında, gerçekte", "aslında"])
        XCTAssertEqual(WidgetGloss.forms(of: "amca / dayı", short: nil), ["amca / dayı"])
        XCTAssertEqual(WidgetGloss.forms(of: "aynı fikirde olmamak", short: "hemfikir olmamak"), ["aynı fikirde olmamak", "hemfikir olmamak"])
        XCTAssertEqual(WidgetGloss.forms(of: "kahvaltı", short: "kahvaltı"), ["kahvaltı"])
        // The editor's short form wins over the first sense: never the narrower "durmak", never
        // the broken question "nakit mi".
        XCTAssertEqual(WidgetGloss.forms(of: "durmak, durdurmak", short: "durmak/durdurmak"), ["durmak, durdurmak", "durmak/durdurmak"])
        XCTAssertEqual(WidgetGloss.forms(of: "nakit mi, kart mı?", short: "nakit mi kart mı"), ["nakit mi, kart mı?", "nakit mi kart mı"])
        XCTAssertEqual(WidgetGloss.forms(of: "demek, anlamına gelmek", short: "anlamına gelmek"), ["demek, anlamına gelmek", "anlamına gelmek"])
        XCTAssertEqual(WidgetGloss.firstSense(of: "durmak; durdurmak"), "durmak")
        XCTAssertEqual(WidgetGloss.firstSense(of: "x (a, b), c"), "x (a, b)")
        XCTAssertEqual(
            WidgetText.candidates(["aslında, gerçekte", "aslında"], lines: [1, 2]),
            [["aslında, gerçekte"], ["aslında"], ["aslında,", "gerçekte"]]
        )
        // A card without a short definition: the micro one, never an empty line.
        XCTAssertEqual(WidgetText.candidates(["", "first meal of the day"], lines: [1]), [["first meal of the day"]])
        XCTAssertEqual(WidgetText.candidates(["", " "], lines: [1, 2]), [])
        // Every snapshot card with a short form shows it as its second form.
        for word in SnapshotWords.cards {
            if let short = word.glossShortTR {
                XCTAssertEqual(WidgetGloss.forms(of: word).last, short, word.lemma)
            }
        }
    }

    /// The user's own words (`WidgetWord.isUserAdded`) have no part of speech, level, English
    /// definition or short meaning and may have no example: no layout shows an empty line or an
    /// empty level for them (kendi_kelime.md §6). The images show the rest (`be fed up with`,
    /// `awkward`).
    func testUserWordsLeaveNoEmptyLines() throws {
        let awkward = try XCTUnwrap(SnapshotWords.userAdded.first { $0.lemma == "awkward" })
        let fedUp = try XCTUnwrap(SnapshotWords.userAdded.first { $0.lemma == "be fed up with" })
        XCTAssertTrue(SnapshotWords.userAdded.allSatisfy { $0.isUserAdded })
        XCTAssertFalse(SnapshotWords.cards.contains { $0.isUserAdded })
        XCTAssertEqual(WidgetGloss.forms(of: awkward), ["garip"])
        XCTAssertEqual(WidgetGloss.forms(of: fedUp), ["bir şeyden bıkmış olmak"])
        XCTAssertEqual(InlineWordView.versions(of: awkward), ["awkward · garip", "awkward"])
        XCTAssertEqual(InlineWordView.versions(of: fedUp), ["be fed up with · bir şeyden bıkmış olmak", "be fed up with"])
        // A word with no meaning and no definition: the word alone, never "awkward · ".
        let bare = WidgetWord(id: 1_000_002, lemma: "awkward", pos: "", level: "", defMicro: "", defShort: "", exampleEN: "")
        XCTAssertEqual(InlineWordView.versions(of: bare), ["awkward"])
        XCTAssertEqual(WidgetGloss.forms(of: bare), [])
    }

    private func looks(for family: Family) -> [Look] {
        let base: [Look]
        switch family.kind {
        case .small:
            base = family.allLooks ? [day, night, tinted, standBy, standByNight] : [day]
        case .medium:
            base = family.allLooks ? [day, night, tinted] : [day]
        case .rectangular:
            base = [lockScreen, alwaysOn]
        case .inline:
            base = [lockScreen]
        }
        guard family.textSizes, let first = base.first else {
            return base
        }
        return base + textSizes.map { textSize in
            Look(
                suffix: first.suffix + textSize.suffix,
                colorScheme: first.colorScheme,
                renderingMode: first.renderingMode,
                showsBackground: first.showsBackground,
                luminanceReduced: first.luminanceReduced,
                dynamicTypeSize: textSize.size
            )
        }
    }

    @ViewBuilder
    private func view(for family: Family, look: Look, entry: WordEntry) -> some View {
        let margins = EdgeInsets(
            top: family.margin, leading: family.margin, bottom: family.margin, trailing: family.margin
        )
        switch family.kind {
        case .small:
            SmallWordView(
                entry: entry,
                margins: margins,
                renderingMode: look.renderingMode,
                showsBackground: look.showsBackground
            )
        case .medium:
            MediumWordView(
                entry: entry,
                margins: margins,
                renderingMode: look.renderingMode,
                showsBackground: look.showsBackground
            )
        case .rectangular:
            RectangularWordView(
                entry: entry,
                margins: margins,
                renderingMode: look.renderingMode
            )
        case .inline:
            InlineWordView(entry: entry)
                .padding(margins)
        }
    }

    /// What WidgetKit would draw behind the view: the widget's `surface` in full color, black in
    /// StandBy, a dark tinted panel, or on the Lock Screen just the wallpaper (the system draws no
    /// plate there; darker on the Always-On display).
    @ViewBuilder
    private func backdrop(for family: Family, look: Look) -> some View {
        switch family.kind {
        case .small, .medium:
            if look.renderingMode == .fullColor && look.showsBackground {
                Theme.surface
            } else if !look.showsBackground {
                Color.black
            } else {
                Color(red: 0.09, green: 0.10, blue: 0.12)
            }
        case .rectangular, .inline:
            Color(white: look.luminanceReduced ? 0.04 : 0.16)
        }
    }

    private func cornerRadius(for family: Family) -> CGFloat {
        switch family.kind {
        case .small, .medium:
            return 22
        case .rectangular:
            return 12
        case .inline:
            return 6
        }
    }

    private func render<V: View>(_ view: V, family: Family, look: Look, name: String) {
        let content = view
            .frame(width: family.size.width, height: family.size.height)
            .background {
                self.backdrop(for: family, look: look)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius(for: family), style: .continuous))
            .environment(\.colorScheme, look.colorScheme)
            .environment(\.dynamicTypeSize, look.dynamicTypeSize)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        guard let image = renderer.uiImage else {
            XCTFail("could not render \(name)")
            return
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
