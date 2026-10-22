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
/// The views are told the rendering mode, whether the system shows their paper and whether the
/// display is dimmed (the environment's own values cannot be set here), so the tinted images show
/// the thin band line and the system text styles on a dark stand-in for the tinted background,
/// the StandBy images the small widget without its paper on black, and the Always-On images the
/// rectangular widget without its definition row.
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
        /// Also rendered at night, tinted and (small) in StandBy: the 393 pt sizes; the SE sizes
        /// check the fit only.
        let allLooks: Bool
    }

    /// The appearance an image is rendered in; `suffix` is added to the attachment name.
    private struct Look {
        let suffix: String
        let colorScheme: ColorScheme
        let renderingMode: WidgetRenderingMode
        /// False in StandBy: the system removes the widget's paper.
        var showsBackground = true
        /// The Always-On display.
        var luminanceReduced = false
    }

    // Point sizes on a 393 pt wide iPhone (15/16/17) and on the 375 pt iPhone SE.
    private let families = [
        Family(name: "small", kind: .small, size: CGSize(width: 158, height: 158), margin: 16, allLooks: true),
        Family(name: "small-se", kind: .small, size: CGSize(width: 148, height: 148), margin: 16, allLooks: false),
        Family(name: "medium", kind: .medium, size: CGSize(width: 338, height: 158), margin: 16, allLooks: true),
        Family(name: "medium-se", kind: .medium, size: CGSize(width: 321, height: 148), margin: 16, allLooks: false),
        Family(name: "rect", kind: .rectangular, size: CGSize(width: 160, height: 72), margin: 0, allLooks: false),
        Family(name: "inline", kind: .inline, size: CGSize(width: 240, height: 22), margin: 0, allLooks: false),
    ]

    private let day = Look(suffix: "", colorScheme: .light, renderingMode: .fullColor)
    private let night = Look(suffix: "-koyu", colorScheme: .dark, renderingMode: .fullColor)
    private let tinted = Look(suffix: "-renkli", colorScheme: .dark, renderingMode: .accented)
    /// StandBy by day: full color without the widget's paper.
    private let standBy = Look(suffix: "-standby", colorScheme: .dark, renderingMode: .fullColor, showsBackground: false)
    /// The Lock Screen: light text on a dark wallpaper.
    private let lockScreen = Look(suffix: "", colorScheme: .dark, renderingMode: .vibrant)
    /// The Always-On display: the Lock Screen dimmed.
    private let alwaysOn = Look(suffix: "-aod", colorScheme: .dark, renderingMode: .vibrant, luminanceReduced: true)

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

    /// Phrases and meanings that do not fit on one line break between words into two lines of
    /// about the same length; a single word is never broken.
    func testBalancedLines() {
        XCTAssertEqual(WidgetText.balancedLines("Could you tell me the way to"), ["Could you tell", "me the way to"])
        XCTAssertEqual(WidgetText.balancedLines("kendini pek iyi hissetmemek"), ["kendini pek iyi", "hissetmemek"])
        XCTAssertEqual(WidgetText.balancedLines("sonunda kendini ... bulmak"), ["sonunda kendini", "... bulmak"])
        XCTAssertEqual(WidgetText.balancedLines("aslında, gerçekte"), ["aslında,", "gerçekte"])
        XCTAssertEqual(WidgetText.balancedLines("sabırsızlanıyorum"), ["sabırsızlanıyorum"])
    }

    private func looks(for family: Family) -> [Look] {
        switch family.kind {
        case .small:
            return family.allLooks ? [day, night, tinted, standBy] : [day]
        case .medium:
            return family.allLooks ? [day, night, tinted] : [day]
        case .rectangular:
            return [lockScreen, alwaysOn]
        case .inline:
            return [lockScreen]
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
                showsBackground: look.showsBackground,
                luminanceReduced: look.luminanceReduced
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
                renderingMode: look.renderingMode,
                luminanceReduced: look.luminanceReduced
            )
        case .inline:
            InlineWordView(entry: entry)
                .padding(margins)
        }
    }

    /// What WidgetKit would draw behind the view: the widget's `surface` in full color, black in
    /// StandBy, a dark tinted panel, the Lock Screen plate (`AccessoryWidgetBackground`) on a dark
    /// wallpaper (fainter on the Always-On display), or just the wallpaper behind the inline line.
    @ViewBuilder
    private func backdrop(for family: Family, look: Look) -> some View {
        switch family.kind {
        case .small, .medium:
            if look.renderingMode == .fullColor && look.showsBackground {
                Theme.surface
            } else if look.renderingMode == .fullColor {
                Color.black
            } else {
                Color(red: 0.09, green: 0.10, blue: 0.12)
            }
        case .rectangular:
            ZStack {
                Color(white: look.luminanceReduced ? 0.04 : 0.16)
                Color.white.opacity(look.luminanceReduced ? 0.06 : 0.14)
            }
        case .inline:
            Color(white: 0.16)
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
