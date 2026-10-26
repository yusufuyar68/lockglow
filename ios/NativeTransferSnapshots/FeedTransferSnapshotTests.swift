import XCTest
import SwiftUI
import UIKit
import CoreModels
@testable import Lockglow

/// Hosted tests deliberately use the app's views rather than compiling copies of their sources.
/// Attachments are review material, not a claim that an unreviewed image matches a golden image.
@MainActor
final class FeedTransferSnapshotTests: XCTestCase {
    private struct Look {
        let name: String
        var scheme: ColorScheme = .light
        var contrast: ColorSchemeContrast = .standard
        var type: DynamicTypeSize = .large
    }

    private let widths: [CGFloat] = [375, 390]
    private let height: CGFloat = 500
    private let looks = [
        Look(name: "light"),
        Look(name: "dark", scheme: .dark),
        Look(name: "light-high-contrast", contrast: .increased),
        Look(name: "dark-high-contrast", scheme: .dark, contrast: .increased),
        Look(name: "light-ax5", type: .accessibility5),
        Look(name: "dark-ax5", scheme: .dark, type: .accessibility5),
    ]

    func testOptionAFeedAtPhoneWidthsAndAccessibleLooks() throws {
        for width in widths {
            for look in looks {
                let card = FeedCardView(
                    word: Self.word,
                    detail: Self.detail,
                    known: .init(isKnown: false, markKnown: {}, undoKnown: {}),
                    showsSwipeHint: true,
                    openDetail: {}
                )
                let content = Group {
                    if look.type.isAccessibilitySize {
                        ScrollView { card }
                    } else {
                        card
                    }
                }
                let host = HostedView(content, size: CGSize(width: width, height: height), look: look)
                defer { host.close() }
                try attach(host, name: "feed-a-\(Int(width))-\(look.name)-top")

                // AX5 uses the feed's natural-height path; retain its end as well as its top.
                if look.type.isAccessibilitySize {
                    let scroll = try XCTUnwrap(scrollViews(in: host.view).first)
                    XCTAssertGreaterThan(scroll.contentSize.height, scroll.bounds.height)
                    scrollToEnd(scroll, host: host)
                    try attach(host, name: "feed-a-\(Int(width))-\(look.name)-bottom")
                }
            }
        }
    }

    func testOversizedNormalTypeCardScrollLayoutInsidePager() throws {
        for width in widths {
            // These intentionally excessive strings exist only here, never in the content store.
            // Even the smallest FitStep retains the definition and meaning, so none can fit.
            let longWord = WidgetWord(
                id: 900_002, lemma: "actually", pos: "adv", level: "B1",
                defMicro: "in fact",
                defShort: Array(repeating: "Used to explain what is really true about a situation.", count: 28).joined(separator: " "),
                exampleEN: Self.word.exampleEN,
                glossTR: Array(repeating: "aslında, gerçekte olan durumu açıklarken", count: 24).joined(separator: " ")
            )
            let page = FeedCardView(
                word: longWord, detail: Self.detail, showsSwipeHint: true, openDetail: {}
            )
            .frame(width: width, height: height)
            // Reproduce the relevant nesting of FeedView: a fixed-height card in a vertical pager.
            let content = ScrollView(.vertical) {
                VStack(spacing: 0) {
                    page
                    Color.clear.frame(height: height)
                }
            }
            .scrollTargetBehavior(.paging)
            let host = HostedView(content, size: CGSize(width: width, height: height), look: Look(name: "light"))
            defer { host.close() }

            let scrolls = scrollViews(in: host.view)
            let inner = try XCTUnwrap(scrolls.first { scroll in
                hasScrollAncestor(scroll) && scroll.contentSize.height > scroll.bounds.height + 1
            }, "The normal-type ViewThatFits fallback must create a genuinely scrollable inner view.")
            let outer = try XCTUnwrap(scrolls.first { !hasScrollAncestor($0) })
            XCTAssertGreaterThan(inner.bounds.height, 0)
            XCTAssertGreaterThan(inner.contentSize.height, inner.bounds.height + 100)
            XCTAssertLessThanOrEqual(inner.contentSize.width, inner.bounds.width + 1)
            let outerOffset = outer.contentOffset
            try attach(host, name: "feed-a-\(Int(width))-oversized-top")
            scrollToEnd(inner, host: host)
            XCTAssertEqual(outer.contentOffset.y, outerOffset.y, accuracy: 1, "Moving the inner card must keep the outer page in place.")
            try attach(host, name: "feed-a-\(Int(width))-oversized-bottom")
            // NativeTransferTests exercises real swipes and the final Neden? / Kapat action.
            // A plain hosted unit-test process has no accessibility automation client.
        }
    }

    func testQuietPaperOnlyAddsGradientInStandardLightAppearance() throws {
        let size = CGSize(width: 240, height: 200)
        for look in looks.filter({ !$0.type.isAccessibilitySize }) {
            let quiet = HostedView(Color.clear.cardSurface(appearance: .quietPaper), size: size, look: look)
            defer { quiet.close() }
            let image = try attach(quiet, name: "surface-quiet-paper-\(look.name)", needsInk: false)
            let a = try pixel(image, at: CGPoint(x: 40, y: 100))
            let b = try pixel(image, at: CGPoint(x: 200, y: 100))
            if look.scheme == .light && look.contrast == .standard {
                XCTAssertGreaterThan(a.distance(to: b), 2, "The light paper must actually render a gradient.")
            } else {
                XCTAssertLessThanOrEqual(a.distance(to: b), 1, "Night and increased contrast must render a flat semantic fill.")
                let expected: CGFloat = look.scheme == .dark ? 0 : 255
                for channel in [a.r, a.g, a.b] {
                    XCTAssertEqual(channel, expected, accuracy: 1)
                }
            }

            let standard = HostedView(Color.clear.cardSurface(), size: size, look: look)
            defer { standard.close() }
            let standardImage = try attach(standard, name: "surface-default-\(look.name)", needsInk: false)
            let c = try pixel(standardImage, at: CGPoint(x: 40, y: 100))
            let d = try pixel(standardImage, at: CGPoint(x: 200, y: 100))
            XCTAssertLessThanOrEqual(c.distance(to: d), 1, "Existing cardSurface() callers retain a flat surface.")
            let expected: CGFloat = look.scheme == .dark ? 0 : 255
            XCTAssertEqual(c.r, expected, accuracy: 1)
            XCTAssertEqual(c.g, expected, accuracy: 1)
            XCTAssertEqual(c.b, expected, accuracy: 1)
        }
    }

    func testExampleMarkKeepsDefaultYellowAndScopesGreenToExplicitCaller() throws {
        let sentence = "She actually arrived early."
        let green = PhosphorBandColors(day: 0xB8EF86, night: 0xA8DC78)
        let original = ExampleMark.attributed(sentence, lemma: "actually", colorScheme: .light)
        let defaultRun = try XCTUnwrap(original.runs.first { $0.backgroundColor != nil })
        XCTAssertEqual(String(original[defaultRun.range].characters), "actually")
        XCTAssertEqual(defaultRun.backgroundColor, Theme.markLight)
        XCTAssertEqual(Theme.markLight, Color(.sRGB, red: 245.0 / 255, green: 232.0 / 255, blue: 41.0 / 255, opacity: 0.80))
        XCTAssertEqual(PhosphorBandColors.phosphor.light, Theme.bandLight)
        XCTAssertNil(defaultRun.underlineStyle)
        XCTAssertEqual(defaultRun.inlinePresentationIntent, .stronglyEmphasized)

        let explicit = ExampleMark.attributed(sentence, lemma: "actually", colorScheme: .light, colors: green)
        let greenRun = try XCTUnwrap(explicit.runs.first { $0.backgroundColor != nil })
        XCTAssertEqual(greenRun.backgroundColor, green.light.opacity(0.80))
        XCTAssertNotEqual(greenRun.backgroundColor, defaultRun.backgroundColor)
        XCTAssertEqual(ExampleMark.attributed(sentence, lemma: "actually", colorScheme: .light), original)

        let dark = ExampleMark.attributed(sentence, lemma: "actually", colorScheme: .dark)
        let darkRun = try XCTUnwrap(dark.runs.first { $0.underlineStyle != nil })
        XCTAssertEqual(String(dark[darkRun.range].characters), "actually")
        XCTAssertNil(darkRun.backgroundColor)
        XCTAssertEqual(Theme.markDark, Color(.sRGB, red: 233.0 / 255, green: 224.0 / 255, blue: 64.0 / 255, opacity: 0.95))
        XCTAssertEqual(darkRun.inlinePresentationIntent, .stronglyEmphasized)
        let unmarked = ExampleMark.attributed(sentence, lemma: "actually", colorScheme: .light, highlighted: false, colors: green)
        XCTAssertTrue(unmarked.runs.allSatisfy { $0.backgroundColor == nil && $0.underlineStyle == nil })
        XCTAssertTrue(unmarked.runs.contains { $0.inlinePresentationIntent == .stronglyEmphasized })
    }

    private static let word = WidgetWord(
        id: 900_001, lemma: "actually", pos: "adv", level: "B1", ipaUS: "/ˈæk.tʃu.ə.li/",
        defMicro: "in fact", defShort: "used to say what is really true",
        exampleEN: "I thought it was expensive, but it was actually quite cheap.", glossTR: "aslında, gerçekte"
    )
    private static let detail = CardDetail(
        examples: [.init(en: word.exampleEN, tr: "Pahalı olduğunu düşünmüştüm ama aslında oldukça ucuzdu.")],
        falseFriend: .init(trWord: "aktüel", trMeans: "güncel", enForThat: "current")
    )

    // MARK: Public UIKit hosting and scrolling (no SwiftUI private class names).

    @MainActor
    private final class HostedView {
        let window: UIWindow
        let container = UIViewController()
        let controller: UIHostingController<AnyView>
        let requestedSize: CGSize
        private weak var previousKeyWindow: UIWindow?
        var view: UIView { controller.view }

        init<V: View>(_ content: V, size: CGSize, look: Look) {
            let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
            let root = content
                .frame(width: size.width, height: size.height, alignment: .topLeading)
                .background(Theme.bg)
                .environment(\.colorScheme, look.scheme)
                // Contrast is a read-only SwiftUI environment value. The host's UIKit
                // accessibilityContrast trait below supplies the actual system setting.
                .environment(\.dynamicTypeSize, look.type)
                .ignoresSafeArea()
            controller = UIHostingController(rootView: AnyView(root))
            window = scene.map { UIWindow(windowScene: $0) } ?? UIWindow(frame: CGRect(origin: .zero, size: size))
            requestedSize = size
            previousKeyWindow = scene?.windows.first { $0.isKeyWindow }
            window.frame = CGRect(origin: .zero, size: size)
            window.rootViewController = container
            container.view.frame = window.bounds
            container.addChild(controller)
            controller.view.frame = container.view.bounds
            controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            container.view.addSubview(controller.view)
            controller.didMove(toParent: container)
            container.setOverrideTraitCollection(UITraitCollection(traitsFrom: [
                UITraitCollection(userInterfaceStyle: look.scheme == .dark ? .dark : .light),
                UITraitCollection(accessibilityContrast: look.contrast == .increased ? .high : .normal),
                UITraitCollection(preferredContentSizeCategory: look.type.isAccessibilitySize ? .accessibilityExtraExtraExtraLarge : .large),
            ]), forChild: controller)
            window.makeKeyAndVisible()
            settle()
        }

        func settle() {
            window.setNeedsLayout()
            window.layoutIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.25))
            window.layoutIfNeeded()
        }

        func close() {
            controller.dismiss(animated: false)
            window.isHidden = true
            window.rootViewController = nil
            previousKeyWindow?.makeKeyAndVisible()
        }
    }

    @discardableResult
    private func attach(_ host: HostedView, name: String, needsInk: Bool = true) throws -> UIImage {
        host.settle()
        XCTAssertEqual(host.window.bounds.size, host.requestedSize, "The scene must preserve the requested snapshot viewport.")
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2
        format.opaque = true
        let image = UIGraphicsImageRenderer(bounds: host.window.bounds, format: format).image { _ in
            host.window.drawHierarchy(in: host.window.bounds, afterScreenUpdates: true)
        }
        XCTAssertEqual(image.size, host.requestedSize)
        if needsInk {
            // A blank image is a failure even without a golden-image comparison.
            XCTAssertGreaterThan(try contrastRange(image), 40, "\(name) must contain rendered reading content.")
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        return image
    }

    private func scrollViews(in view: UIView) -> [UIScrollView] {
        let current = (view as? UIScrollView).map { [$0] } ?? []
        return current + view.subviews.flatMap { scrollViews(in: $0) }
    }

    private func hasScrollAncestor(_ view: UIView) -> Bool {
        var ancestor = view.superview
        while let current = ancestor {
            if current is UIScrollView { return true }
            ancestor = current.superview
        }
        return false
    }

    private func scrollToEnd(_ scroll: UIScrollView, host: HostedView) {
        let end = max(-scroll.adjustedContentInset.top, scroll.contentSize.height - scroll.bounds.height + scroll.adjustedContentInset.bottom)
        scroll.setContentOffset(CGPoint(x: -scroll.adjustedContentInset.left, y: end), animated: false)
        host.settle()
        XCTAssertEqual(scroll.contentOffset.y, end, accuracy: 1)
    }

    private struct RGB {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        func distance(to other: RGB) -> CGFloat {
            max(abs(r - other.r), max(abs(g - other.g), abs(b - other.b)))
        }
    }

    private func contrastRange(_ image: UIImage) throws -> Int {
        let source = try XCTUnwrap(image.cgImage)
        var bytes = [UInt8](repeating: 0, count: 64 * 64 * 4)
        let rendered = bytes.withUnsafeMutableBytes { storage -> Bool in
            guard let context = CGContext(
                data: storage.baseAddress, width: 64, height: 64, bitsPerComponent: 8, bytesPerRow: 64 * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ) else { return false }
            context.draw(source, in: CGRect(x: 0, y: 0, width: 64, height: 64))
            return true
        }
        XCTAssertTrue(rendered)
        let rgb = bytes.enumerated().compactMap { $0.offset % 4 == 3 ? nil : Int($0.element) }
        return (rgb.max() ?? 0) - (rgb.min() ?? 0)
    }

    private func pixel(_ image: UIImage, at point: CGPoint) throws -> RGB {
        let source = try XCTUnwrap(image.cgImage)
        var bytes: [UInt8] = [0, 0, 0, 0]
        let rendered = bytes.withUnsafeMutableBytes { storage -> Bool in
            guard let context = CGContext(
                data: storage.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ) else { return false }
            context.translateBy(x: -floor(point.x * image.scale), y: -floor(point.y * image.scale))
            context.draw(source, in: CGRect(x: 0, y: 0, width: CGFloat(source.width), height: CGFloat(source.height)))
            return true
        }
        XCTAssertTrue(rendered)
        return RGB(r: CGFloat(bytes[0]), g: CGFloat(bytes[1]), b: CGFloat(bytes[2]))
    }
}
