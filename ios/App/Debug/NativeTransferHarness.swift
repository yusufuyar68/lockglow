#if DEBUG && targetEnvironment(simulator)
import Foundation
import SwiftUI
import CoreModels

/// UI-test-only content: no AppModel, database, preferences or progress changes.
/// The app selects it only for an explicit simulator launch argument; device/Release builds
/// contain neither this view nor its deliberately excessive fixture strings.
struct NativeTransferHarness: View {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-lockglow.nativeOversizedCard")
    }

    var body: some View {
        GeometryReader { viewport in
            let pageHeight = min(500, viewport.size.height)
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    FeedCardView(
                        word: Self.word,
                        detail: Self.detail,
                        showsSwipeHint: true,
                        fillsPage: true
                    )
                    .frame(width: viewport.size.width, height: pageHeight)
                    ZStack {
                        Theme.surface
                        Text("İkinci sayfa")
                    }
                    .frame(width: viewport.size.width, height: pageHeight)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("İkinci sayfa")
                    .accessibilityIdentifier("native-harness.second-page")
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .frame(width: viewport.size.width, height: pageHeight, alignment: .topLeading)
            .accessibilityIdentifier("native-harness.pager")
        }
        .background(Theme.bg.ignoresSafeArea())
        // This fixture specifically exercises the normal-type ViewThatFits fallback.
        .environment(\.dynamicTypeSize, .large)
    }

    private static let word = WidgetWord(
        id: 900_002, lemma: "actually", pos: "adv", level: "B1",
        defMicro: "in fact",
        defShort: Array(repeating: "Used to explain what is really true about a situation.", count: 28).joined(separator: " "),
        exampleEN: "I thought it was expensive, but it was actually quite cheap.",
        glossTR: Array(repeating: "aslında, gerçekte olan durumu açıklarken", count: 24).joined(separator: " ")
    )
    private static let detail = CardDetail(
        examples: [.init(en: word.exampleEN, tr: "Pahalı olduğunu düşünmüştüm ama aslında oldukça ucuzdu.")],
        falseFriend: .init(trWord: "aktüel", trMeans: "güncel", enForThat: "current")
    )
}
#endif
