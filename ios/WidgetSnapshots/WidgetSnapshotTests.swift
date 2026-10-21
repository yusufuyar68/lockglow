import XCTest
import SwiftUI
import UIKit
import CoreModels

/// Renders the widget views (compiled into this bundle from Widgets/) at real widget sizes and
/// attaches the images, so the layouts can be reviewed in CI without placing a widget on a home
/// screen. An approximation: WidgetKit's own chrome, tinting and Lock Screen vibrancy are not
/// reproduced; home widgets get WidgetKit's default 16 pt content margin. The widget disables
/// the system margins and the views apply them, so the margins are passed in as on a device.
@MainActor
final class WidgetSnapshotTests: XCTestCase {
    private struct Family {
        let name: String
        let size: CGSize
        let margin: CGFloat
    }

    // Point sizes on a 393 pt wide iPhone (15/16/17) and on the 375 pt iPhone SE.
    private let families = [
        Family(name: "small", size: CGSize(width: 158, height: 158), margin: 16),
        Family(name: "small-se", size: CGSize(width: 148, height: 148), margin: 16),
        Family(name: "medium", size: CGSize(width: 338, height: 158), margin: 16),
        Family(name: "medium-se", size: CGSize(width: 321, height: 148), margin: 16),
        Family(name: "rect", size: CGSize(width: 160, height: 72), margin: 0),
        Family(name: "inline", size: CGSize(width: 240, height: 22), margin: 0),
    ]

    func testRenderWidgetFamiliesForStressWords() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        for word in SnapshotWords.all {
            let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
            for family in families {
                render(view(for: family, entry: entry), family: family, name: "\(family.name)-\(word.lemma)")
            }
        }
    }

    @ViewBuilder
    private func view(for family: Family, entry: WordEntry) -> some View {
        let margins = EdgeInsets(
            top: family.margin, leading: family.margin, bottom: family.margin, trailing: family.margin
        )
        switch family.name {
        case "small", "small-se":
            SmallWordView(entry: entry, margins: margins)
        case "medium", "medium-se":
            MediumWordView(entry: entry, margins: margins)
        case "rect":
            RectangularWordView(entry: entry)
                .padding(margins)
        default:
            InlineWordView(entry: entry)
                .padding(margins)
        }
    }

    private func render<V: View>(_ view: V, family: Family, name: String) {
        let content = view
            .frame(width: family.size.width, height: family.size.height)
            .background(Color(white: 0.93))
            .clipShape(RoundedRectangle(cornerRadius: family.margin > 0 ? 22 : 6, style: .continuous))
            .environment(\.colorScheme, .light)
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
