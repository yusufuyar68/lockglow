import XCTest
import SwiftUI
import UIKit
import WidgetKit
import CoreModels

/// The home widgets at iPad sizes, rendered like `WidgetSnapshotTests` (which has the iPhone
/// sizes and the other looks): the smallest iPad widgets, on an iPad mini or a 768 pt wide iPad
/// (small 141 x 141 pt, medium 305.5 x 141 pt: smaller than the iPhone SE's), also at larger text
/// sizes, and the largest, on a 13" iPad (170 x 170 pt, 378.5 x 170 pt). Point sizes from the HIG
/// widget size table. The same layouts must hold: the meaning never runs under the buttons and is
/// never cut. The Lock Screen families are not rendered here: their iPad sizes are not in the
/// table.
@MainActor
final class IPadWidgetSnapshotTests: XCTestCase {
    private struct Family {
        let name: String
        let isMedium: Bool
        let size: CGSize
        /// Also rendered at larger text sizes (`-xxxl`, `-ax1`).
        var textSizes = false
    }

    private let families = [
        Family(name: "small-ipad-mini", isMedium: false, size: CGSize(width: 141, height: 141), textSizes: true),
        Family(name: "medium-ipad-mini", isMedium: true, size: CGSize(width: 305.5, height: 141), textSizes: true),
        Family(name: "small-ipad-13", isMedium: false, size: CGSize(width: 170, height: 170)),
        Family(name: "medium-ipad-13", isMedium: true, size: CGSize(width: 378.5, height: 170)),
    ]

    func testRenderHomeWidgetsAtIPadSizes() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        for word in SnapshotWords.all {
            let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
            for family in families {
                var textSizes: [(suffix: String, size: DynamicTypeSize)] = [("", .large)]
                if family.textSizes {
                    textSizes += [("-xxxl", .xxxLarge), ("-ax1", .accessibility1)]
                }
                for textSize in textSizes {
                    render(entry: entry, family: family, textSize: textSize.size, name: "\(family.name)-\(word.lemma)\(textSize.suffix)")
                }
            }
        }
    }

    /// Full color by day on the widget's paper, with WidgetKit's default 16 pt margins.
    private func render(entry: WordEntry, family: Family, textSize: DynamicTypeSize, name: String) {
        let margins = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        let widget = Group {
            if family.isMedium {
                MediumWordView(entry: entry, margins: margins, renderingMode: .fullColor, showsBackground: true)
            } else {
                SmallWordView(entry: entry, margins: margins, renderingMode: .fullColor, showsBackground: true)
            }
        }
        let content = widget
            .frame(width: family.size.width, height: family.size.height)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .environment(\.colorScheme, .light)
            .environment(\.dynamicTypeSize, textSize)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 2
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
