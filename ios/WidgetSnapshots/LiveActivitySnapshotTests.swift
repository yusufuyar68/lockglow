import XCTest
import SwiftUI
import UIKit
import CoreModels

/// Renders the "Tekrar" round's Live Activity views (Widgets/LiveActivityViews.swift, compiled into
/// this bundle) for CI layout review, as the widget images are: an approximation. The Lock Screen
/// presentation is drawn on its own background (`Theme.bg`, as `activityBackgroundTint`) at the
/// HIG width of a 393 pt iPhone (371 pt) and about the iPhone SE's (353 pt), by day, at night,
/// stale, and on the SE at three larger text sizes. The Dynamic Island pieces are drawn on black
/// in the HIG sizes (expanded 371 pt wide, compact 52.33 x 36.67 pt each side of the camera,
/// minimal 36.67 pt); the system's own island shape and placement are not reproduced.
/// Image names start with `canli-`.
@MainActor
final class LiveActivitySnapshotTests: XCTestCase {
    private let running = ReviewActivityAttributes.ContentState(card: 4, total: 10)
    /// "Tanış + Hatırla" with two second tries: the widest counter a round shows.
    private let widest = ReviewActivityAttributes.ContentState(card: 11, total: 12)

    func testRenderLockScreen() {
        let widths: [(name: String, width: CGFloat)] = [("pro", 371), ("se", 353)]
        for (name, width) in widths {
            let looks: [(suffix: String, scheme: ColorScheme)] = [("", .light), ("-koyu", .dark)]
            for (look, scheme) in looks {
                renderLockScreen(state: running, stale: false, width: width, scheme: scheme, name: "canli-kilit-\(name)\(look)")
                renderLockScreen(state: running, stale: true, width: width, scheme: scheme, name: "canli-kilit-\(name)-eski\(look)")
            }
            renderLockScreen(state: widest, stale: false, width: width, scheme: .light, name: "canli-kilit-\(name)-11-12")
        }
        let sizes: [(suffix: String, size: DynamicTypeSize)] = [("-xxxl", .xxxLarge), ("-ax1", .accessibility1), ("-ax3", .accessibility3)]
        for (suffix, size) in sizes {
            renderLockScreen(state: widest, stale: false, width: 353, scheme: .light, size: size, name: "canli-kilit-se\(suffix)")
        }
    }

    func testRenderDynamicIsland() {
        for (state, label) in [(running, ""), (widest, "-11-12")] {
            render(expanded(state: state, stale: false), name: "canli-ada-genis\(label)")
            render(compact(state: state, stale: false), name: "canli-ada-kompakt\(label)")
        }
        render(expanded(state: running, stale: true), name: "canli-ada-genis-eski")
        render(compact(state: running, stale: true), name: "canli-ada-kompakt-eski")
        render(
            ReviewActivityIslandSymbol()
                .frame(width: 36.67, height: 36.67)
                .background(Color.black, in: Circle()),
            name: "canli-ada-kucuk"
        )
    }

    /// "Devam et" opens "Tekrar" and nothing else: never a word card.
    func testContinueLinkOpensTekrar() throws {
        let url = try XCTUnwrap(ReviewActivityAttributes.continueURL)
        XCTAssertEqual(url.absoluteString, "vocabwidget://review")
        XCTAssertTrue(ReviewActivityAttributes.isContinueURL(url))
        XCTAssertNil(DeepLink.wordID(from: url))
        let word = try XCTUnwrap(DeepLink.wordURL(id: 42))
        XCTAssertFalse(ReviewActivityAttributes.isContinueURL(word))
        let upperCased = try XCTUnwrap(URL(string: "VOCABWIDGET://review"))
        XCTAssertTrue(ReviewActivityAttributes.isContinueURL(upperCased))
    }

    /// "/" only in the visible counter; VoiceOver hears "toplam" (terimler §1).
    func testCounterTexts() {
        XCTAssertEqual(ReviewActivityText.counter(running), "Kart 4 / 10")
        XCTAssertEqual(ReviewActivityText.shortCounter(running), "4/10")
        XCTAssertEqual(ReviewActivityText.spokenCounter(running), "Kart 4, toplam 10")
        XCTAssertFalse(ReviewActivityText.spokenCounter(widest).contains("/"))
    }

    // MARK: Helpers

    private func expanded(state: ReviewActivityAttributes.ContentState, stale: Bool) -> some View {
        VStack(spacing: 8) {
            HStack {
                ReviewActivityIslandTitle()
                Spacer(minLength: 8)
                ReviewActivityIslandCounter(state: state, isStale: stale)
            }
            ReviewActivityIslandBottom(isStale: stale)
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 18)
        .frame(width: 371)
        .background(Color.black, in: RoundedRectangle(cornerRadius: 44, style: .continuous))
    }

    /// Leading and trailing views beside a stand-in for the camera (126 pt).
    private func compact(state: ReviewActivityAttributes.ContentState, stale: Bool) -> some View {
        HStack(spacing: 0) {
            ReviewActivityIslandSymbol()
                .frame(width: 52.33, height: 36.67)
            Color.black
                .frame(width: 126, height: 36.67)
            ReviewActivityIslandCounter(state: state, isStale: stale, short: true)
                .frame(width: 52.33, height: 36.67)
        }
        .background(Color.black, in: Capsule())
    }

    private func renderLockScreen(
        state: ReviewActivityAttributes.ContentState,
        stale: Bool,
        width: CGFloat,
        scheme: ColorScheme,
        size: DynamicTypeSize = .large,
        name: String
    ) {
        let view = ReviewActivityLockScreenView(state: state, isStale: stale)
            .frame(width: width)
            .frame(minHeight: 84)
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .environment(\.colorScheme, scheme)
            .environment(\.dynamicTypeSize, size)
        render(view, name: name)
    }

    private func render<V: View>(_ view: V, name: String) {
        // A gray wallpaper around it, so the activity's own edge shows in both appearances.
        let content = view
            .padding(12)
            .background(Color(white: 0.45))
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
