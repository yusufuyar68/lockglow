import XCTest
import SwiftUI
import UIKit
import WidgetKit
import CoreModels

/// The widgets' looks beyond full color (is5-w-cila): the tinted Home Screen of iOS 18 and the
/// clear and tinted Liquid Glass Home Screens of iOS 26 (accented rendering), the dark Home
/// Screen, StandBy by day and at night (red), and the word change. The color checks measure what
/// SwiftUI draws (a style filled into a small image), so they hold for the real styles; the
/// system's own tinting, glass and red night filter are not reproduced and are modelled in the
/// images and the night check:
/// - accented: the system paints every view one color and keeps only its opacity, so the check
///   is that every text and edge is opaque (Apple: no partly transparent content in this mode);
///   the images put the content on a dark tinted panel (`-renkli-koyu`, the dark tinted Home
///   Screen) and on a frosted, colorful wallpaper (`-cam`, the clear one);
/// - StandBy at night: the system draws the vibrant grays by their luminance in red; the model
///   puts each pixel's gray level in the red channel (`-gece-kirmizi`);
/// - StandBy in landscape: two small widgets without their paper, side by side on black and
///   scaled up as StandBy shows them (`standby-yatay-*`).
/// Contrast is WCAG 2.2's: at least 4.5:1 for text, 3:1 for a button's icon on its circle.
@MainActor
final class WidgetLookTests: XCTestCase {
    private struct RGBA {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        /// WCAG relative luminance of the (opaque) color.
        var luminance: Double {
            func linear(_ channel: Double) -> Double {
                return channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
        }
    }

    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private let margins = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

    /// A word, a phrase on two lines, the longest single word and a meaning with a comma.
    private var words: [WidgetWord] {
        return SnapshotWords.cards.filter { word in
            [1, 807, 899, 286].contains(word.id)
        }
    }

    // MARK: - Colors

    /// Accented rendering keeps only opacity: every text, icon and edge is opaque, and the button
    /// circle has no fill (an opaque disc would take the icon's color).
    func testAccentedColorsAreOpaque() throws {
        let colors = WidgetColors.forMode(.accented)
        for scheme in [ColorScheme.light, .dark] {
            XCTAssertGreaterThan(try opacity(colors.ink, scheme: scheme), 0.99, "ink \(scheme)")
            XCTAssertGreaterThan(try opacity(colors.ink2, scheme: scheme), 0.99, "ink2 \(scheme)")
            let edge = try XCTUnwrap(colors.buttonEdge)
            XCTAssertGreaterThan(try opacity(edge, scheme: scheme), 0.99, "edge \(scheme)")
            XCTAssertLessThan(try opacity(colors.buttonFill, scheme: scheme), 0.01, "fill \(scheme)")
        }
        // Also without the paper: accented wins over StandBy's no-paper styles.
        XCTAssertNotNil(WidgetColors.forMode(.accented, showsBackground: false).buttonEdge)
        XCTAssertNil(WidgetColors.forMode(.fullColor).buttonEdge)
        XCTAssertNil(WidgetColors.forMode(.vibrant).buttonEdge)
    }

    /// The dark Home Screen (full color, dark): ink and ink2 on the widget's paper, the button
    /// icon on its circle. By day too, as a guard.
    func testFullColorContrastOnThePaper() throws {
        let colors = WidgetColors.forMode(.fullColor)
        for scheme in [ColorScheme.dark, .light] {
            let paper = try pixel(AnyShapeStyle(Theme.surface), scheme: scheme)
            let circle = try pixel(colors.buttonFill, over: Theme.surface, scheme: scheme)
            let ink = try pixel(colors.ink, over: Theme.surface, scheme: scheme)
            let ink2 = try pixel(colors.ink2, over: Theme.surface, scheme: scheme)
            let icon = try pixel(colors.ink, over: Theme.surface2, scheme: scheme)
            XCTAssertGreaterThanOrEqual(contrast(ink, paper), 7, "ink \(scheme)")
            // ink2 carries 11–13 pt text (theme rule: at least 7:1).
            XCTAssertGreaterThanOrEqual(contrast(ink2, paper), 7, "ink2 \(scheme)")
            XCTAssertGreaterThanOrEqual(contrast(icon, circle), 4.5, "icon \(scheme)")
        }
    }

    /// StandBy by day: no paper, the system's styles on black.
    func testStandByContrastOnBlack() throws {
        let colors = WidgetColors.forMode(.fullColor, showsBackground: false)
        let black = RGBA(red: 0, green: 0, blue: 0, alpha: 1)
        let ink = try pixel(colors.ink, over: .black, scheme: .dark)
        let ink2 = try pixel(colors.ink2, over: .black, scheme: .dark)
        let circle = try pixel(colors.buttonFill, over: .black, scheme: .dark)
        XCTAssertGreaterThanOrEqual(contrast(ink, black), 7)
        XCTAssertGreaterThanOrEqual(contrast(ink2, black), 4.5)
        XCTAssertGreaterThanOrEqual(contrast(ink, circle), 4.5)
    }

    /// StandBy at night: the vibrant grays drawn in red by luminance (the model). The small
    /// widget's word and meaning (`ink`) stay at least 4.5:1 on black, the icon at least 3:1 on its
    /// darker circle; the grays are opaque (HIG: opaque grayscale values, not opacities of white).
    func testNightRedContrast() throws {
        let colors = WidgetColors.forMode(.vibrant, showsBackground: false)
        let black = RGBA(red: 0, green: 0, blue: 0, alpha: 1)
        let ink = try pixel(colors.ink, over: .black, scheme: .dark)
        let ink2 = try pixel(colors.ink2, over: .black, scheme: .dark)
        let circle = try pixel(colors.buttonFill, over: .black, scheme: .dark)
        for style in [colors.ink, colors.ink2, colors.buttonFill] {
            XCTAssertGreaterThan(try opacity(style, scheme: .dark), 0.99)
        }
        XCTAssertGreaterThan(ink.luminance, ink2.luminance)
        XCTAssertGreaterThan(ink2.luminance, circle.luminance)
        XCTAssertGreaterThanOrEqual(contrast(red(ink), black), 4.5)
        XCTAssertGreaterThanOrEqual(contrast(red(ink), red(circle)), 3)
    }

    // MARK: - Word change

    /// ogrenme_ilkeleri 2.1: a fade of at most 0.35 s on the Home Screen; no animation on the
    /// Lock Screen nor with Reduce Motion.
    func testWordChange() {
        XCTAssertEqual(WidgetWordChange.of(lockScreen: false, reduceMotion: false), .fade(seconds: 0.35))
        XCTAssertEqual(WidgetWordChange.of(lockScreen: false, reduceMotion: true), .still)
        XCTAssertEqual(WidgetWordChange.of(lockScreen: true, reduceMotion: false), .still)
        XCTAssertEqual(WidgetWordChange.of(lockScreen: true, reduceMotion: true), .still)
        XCTAssertLessThanOrEqual(WidgetWordChange.fadeSeconds, 0.35)
    }

    // MARK: - Text sizes

    /// The step tables behind "a small word never stands above a large meaning" (the 2026-10-22
    /// images: a 15 pt word under an xxxLarge meaning). Beside a meaning at the person's text
    /// size the word's steps all grow with Dynamic Type, as the meaning does. The unscaled floor
    /// is left for the default size, beside a 13 pt meaning, and for the word alone. Only a word
    /// that fits no step at the default size shrinks a little there ("misunderstanding" on an SE,
    /// to about 14.5 pt). Which table goes with which meaning is in the views; the SE images at
    /// `-xxxl`, `-ax1` and `-ax3` show it.
    func testWordNeverSmallerThanMeaning() {
        XCTAssertTrue(WidgetWordStep.homeFloorScaled.allSatisfy { $0.scales })
        XCTAssertTrue(WidgetWordStep.smallWidget.allSatisfy { $0.scales && $0.size >= 17 })
        XCTAssertTrue(WidgetWordStep.lockScreen.allSatisfy { $0.scales && $0.size >= 15 })
        XCTAssertTrue(WidgetWordStep.mediumWidgetScaled.allSatisfy { $0.scales && $0.size >= 15 })
        XCTAssertFalse(WidgetWordStep.homeFloor.allSatisfy { $0.scales })
    }

    // MARK: - Example line

    /// The medium widget's example is cut only between words (the 2026-10-22 images showed
    /// "…the museu…" and "…at s…"): each start of the sentence lists its cuts, fullest first,
    /// down to the one that ends right after the learned word.
    func testExampleLineCutsBetweenWords() {
        let breakfast = WidgetExampleLine.versions(of: "I usually have breakfast at seven.", lemma: "breakfast")
        XCTAssertEqual(breakfast.count, 4)
        XCTAssertEqual(breakfast[0].cuts, ["I usually have breakfast at seven.", "I usually have breakfast at…", "I usually have breakfast…"])
        XCTAssertEqual(breakfast[2].cuts, ["… usually have breakfast at seven.", "… usually have breakfast at…", "… usually have breakfast…"])
        XCTAssertEqual(breakfast[3].cuts, ["… breakfast at seven.", "… breakfast at…", "… breakfast…"])
        let museum = WidgetExampleLine.versions(
            of: "Could you tell me the way to the museum, please?",
            lemma: "Could you tell me the way to"
        )
        XCTAssertEqual(museum[0].cuts, [
            "Could you tell me the way to the museum, please?",
            "Could you tell me the way to the museum…",
            "Could you tell me the way to the…",
            "Could you tell me the way to…",
        ])
        XCTAssertEqual(museum[0].fitting, "Could you tell me the way to…")
        // A cut after a sentence's end needs no "…".
        let sorry = WidgetExampleLine.versions(of: "It was just a misunderstanding. I'm sorry.", lemma: "misunderstanding")
        XCTAssertEqual(sorry[0].fitting, "It was just a misunderstanding.")
        XCTAssertEqual(
            WidgetExampleLine.versions(of: "“Cash or card?” “Card, please.”", lemma: "cash or card")[0].cuts,
            ["“Cash or card?” “Card, please.”", "“Cash or card?” “Card…", "“Cash or card?”"]
        )
        // The word at the sentence's end: each start has one cut, the rest of the sentence.
        XCTAssertEqual(
            WidgetExampleLine.versions(of: "I left my phone on the train, so I called the lost and found.", lemma: "lost and found").map(\.cuts),
            [
                ["I left my phone on the train, so I called the lost and found."],
                ["… so I called the lost and found."],
                ["… called the lost and found."],
                ["… lost and found."],
            ]
        )
        // Not found (an irregular form): from the start, cut after any whole word.
        XCTAssertEqual(
            WidgetExampleLine.versions(of: "Her teeth are white.", lemma: "tooth")[0].cuts,
            ["Her teeth are white.", "Her teeth are…", "Her teeth…", "Her…"]
        )
        // More cuts than slots: an even spread, the fullest and the shortest kept.
        let many = (1...12).map { "c\($0)" }
        XCTAssertEqual(WidgetExampleLine.slots(many), ["c1", "c3", "c4", "c6", "c7", "c9", "c10", "c12"])
        XCTAssertEqual(WidgetExampleLine.slots(["a", "b"]), ["a", "b", "b", "b", "b", "b", "b", "b"])
        // Every cut of every snapshot example is a run of the sentence's own whole words.
        for word in SnapshotWords.all where !word.exampleEN.isEmpty {
            let sentenceWords = word.exampleEN.split(separator: " ").map(String.init)
            for version in WidgetExampleLine.versions(of: word.exampleEN, lemma: word.lemma) {
                XCTAssertEqual(WidgetExampleLine.slots(version.cuts).count, WidgetExampleLine.cutCount)
                for cut in version.cuts {
                    var body = cut
                    if body.hasPrefix("… ") {
                        body.removeFirst(2)
                    }
                    if body.hasSuffix("…") {
                        body.removeLast()
                    }
                    XCTAssertTrue(isRun(body.split(separator: " ").map(String.init), of: sentenceWords), cut)
                }
            }
        }
    }

    /// Whether `part` is a run of `whole`'s words; its last word may have lost a trailing comma,
    /// semicolon or colon (before the cut's "…").
    private func isRun(_ part: [String], of whole: [String]) -> Bool {
        guard let last = part.last, part.count <= whole.count else {
            return false
        }
        for start in 0...(whole.count - part.count) {
            let slice = Array(whole[start..<(start + part.count)])
            let lastWord = slice[slice.count - 1]
            let lastMatches = lastWord == last
                || lastWord.trimmingCharacters(in: CharacterSet(charactersIn: ",;:")) == last
            if Array(slice.dropLast()) == Array(part.dropLast()) && lastMatches {
                return true
            }
        }
        return false
    }

    // MARK: - Images

    func testRenderLooks() throws {
        for word in words {
            let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
            for (kind, size) in [("small", CGSize(width: 158, height: 158)), ("medium", CGSize(width: 338, height: 158))] {
                // The dark tinted Home Screen: opaque white content on a dark tinted panel.
                attach(
                    homeView(kind, entry: entry, mode: .accented, paper: false)
                        .frame(width: size.width, height: size.height)
                        .background(Color(red: 0.10, green: 0.13, blue: 0.20))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .environment(\.colorScheme, .dark),
                    name: "gorunum-\(kind)-\(word.lemma)-renkli-koyu"
                )
                // The clear (Liquid Glass) Home Screen: the same content on a frosted, colorful
                // wallpaper.
                attach(
                    homeView(kind, entry: entry, mode: .accented, paper: false)
                        .frame(width: size.width, height: size.height)
                        .background { glass }
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .environment(\.colorScheme, .dark),
                    name: "gorunum-\(kind)-\(word.lemma)-cam"
                )
            }
            // StandBy at night, small widget, drawn in red.
            if let night = image(
                homeView("small", entry: entry, mode: .vibrant, paper: false)
                    .frame(width: 158, height: 158)
                    .background(Color.black)
                    .environment(\.colorScheme, .dark)
            ) {
                attach(red(night), name: "gorunum-small-\(word.lemma)-gece-kirmizi")
            }
        }
        // StandBy in landscape: two small widgets side by side, scaled up, by day and at night.
        let pairs = [(words[0], words[1]), (words[2], words[3])]
        for (index, pair) in pairs.enumerated() {
            for night in [false, true] {
                let view = standBy(pair.0, pair.1, night: night)
                guard let picture = image(view) else {
                    continue
                }
                attach(night ? red(picture) : picture, name: "gorunum-standby-yatay-\(index + 1)\(night ? "-gece-kirmizi" : "")")
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func homeView(_ kind: String, entry: WordEntry, mode: WidgetRenderingMode, paper: Bool) -> some View {
        if kind == "small" {
            SmallWordView(entry: entry, margins: margins, renderingMode: mode, showsBackground: paper)
        } else {
            MediumWordView(entry: entry, margins: margins, renderingMode: mode, showsBackground: paper)
        }
    }

    /// A stand-in for the clear glass: a colorful wallpaper, blurred, under a light frost.
    private var glass: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.55, blue: 0.35), Color(red: 0.30, green: 0.45, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color(red: 0.98, green: 0.85, blue: 0.40))
                .frame(width: 120, height: 120)
                .offset(x: 60, y: -30)
                .blur(radius: 30)
            Color.white.opacity(0.12)
        }
    }

    /// StandBy's widget view on a 393 pt tall iPhone in landscape: two small widgets without
    /// their paper, each scaled up to about 2 times, on black.
    private func standBy(_ left: WidgetWord, _ right: WidgetWord, night: Bool) -> some View {
        let mode: WidgetRenderingMode = night ? .vibrant : .fullColor
        let scale: CGFloat = 2
        // Copies for the ForEach closure (it escapes, so it may not read `self`'s properties).
        let now = self.now
        let margins = self.margins
        return HStack(spacing: 24) {
            ForEach([left, right], id: \.id) { word in
                SmallWordView(
                    entry: WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600)),
                    margins: margins,
                    renderingMode: mode,
                    showsBackground: false
                )
                .frame(width: 158, height: 158)
                .scaleEffect(scale)
                .frame(width: 158 * scale, height: 158 * scale)
            }
        }
        .frame(width: 852, height: 393)
        .background(Color.black)
        .environment(\.colorScheme, .dark)
    }

    private func image<V: View>(_ view: V) -> UIImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        return renderer.uiImage
    }

    private func attach<V: View>(_ view: V, name: String) {
        guard let rendered = image(view) else {
            XCTFail("could not render \(name)")
            return
        }
        attach(rendered, name: name)
    }

    private func attach(_ image: UIImage, name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// The night model: each pixel's luminance in the red channel.
    private func red(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage, let pixels = rgbaPixels(of: cgImage) else {
            return image
        }
        var data = pixels
        for index in stride(from: 0, to: data.count, by: 4) {
            let color = RGBA(
                red: Double(data[index]) / 255,
                green: Double(data[index + 1]) / 255,
                blue: Double(data[index + 2]) / 255,
                alpha: 1
            )
            data[index] = UInt8(max(0, min(255, (red(color).red * 255).rounded())))
            data[index + 1] = 0
            data[index + 2] = 0
            data[index + 3] = 255
        }
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let provider = CGDataProvider(data: Data(data) as CFData),
              let result = CGImage(
                  width: cgImage.width,
                  height: cgImage.height,
                  bitsPerComponent: 8,
                  bitsPerPixel: 32,
                  bytesPerRow: cgImage.width * 4,
                  space: space,
                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                  provider: provider,
                  decode: nil,
                  shouldInterpolate: false,
                  intent: .defaultIntent
              ) else {
            return image
        }
        return UIImage(cgImage: result, scale: image.scale, orientation: .up)
    }

    /// The night model for one color: its gray level (luminance, sRGB-encoded) as the red
    /// channel, green and blue off; a gray of 0.75 becomes a red of 0.75.
    private func red(_ color: RGBA) -> RGBA {
        let level = min(max(color.luminance, 0), 1)
        let encoded = level <= 0.0031308 ? level * 12.92 : 1.055 * pow(level, 1 / 2.4) - 0.055
        return RGBA(red: encoded, green: 0, blue: 0, alpha: 1)
    }

    /// The image's pixels as premultiplied sRGB RGBA, 8 bits each.
    private func rgbaPixels(of cgImage: CGImage) -> [UInt8]? {
        let width = cgImage.width
        let height = cgImage.height
        var data = [UInt8](repeating: 0, count: width * height * 4)
        guard let space = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }
        let drawn: Bool = data.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return false
            }
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        return drawn ? data : nil
    }

    /// How opaque `style` is as drawn: filled over black and over white, an opaque style looks
    /// the same on both and a clear one takes the backdrop's color (1 minus the gap).
    /// ImageRenderer gave no transparent pixels here (run 39991796077 measured `Color.clear` at
    /// alpha 1), so the alpha channel alone cannot tell.
    private func opacity(_ style: AnyShapeStyle, scheme: ColorScheme) throws -> Double {
        let onBlack = try pixel(style, over: .black, scheme: scheme)
        let onWhite = try pixel(style, over: .white, scheme: scheme)
        let gap = ((onWhite.red - onBlack.red) + (onWhite.green - onBlack.green) + (onWhite.blue - onBlack.blue)) / 3
        return 1 - gap
    }

    /// What SwiftUI draws for `style`, filled over `backdrop` (none: transparent) in `scheme`.
    private func pixel(_ style: AnyShapeStyle, over backdrop: Color? = nil, scheme: ColorScheme) throws -> RGBA {
        let view = ZStack {
            if let backdrop {
                Rectangle().fill(backdrop)
            }
            Rectangle().fill(style)
        }
        .frame(width: 8, height: 8)
        .environment(\.colorScheme, scheme)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        let cgImage = try XCTUnwrap(renderer.cgImage)
        let pixels = try XCTUnwrap(rgbaPixels(of: cgImage))
        // The middle pixel; premultiplied, so divide by alpha for the color.
        let index = ((cgImage.height / 2) * cgImage.width + cgImage.width / 2) * 4
        let alpha = Double(pixels[index + 3]) / 255
        let divisor = alpha > 0 ? alpha * 255 : 255
        return RGBA(
            red: Double(pixels[index]) / divisor,
            green: Double(pixels[index + 1]) / divisor,
            blue: Double(pixels[index + 2]) / divisor,
            alpha: alpha
        )
    }

    private func contrast(_ first: RGBA, _ second: RGBA) -> Double {
        let lighter = max(first.luminance, second.luminance)
        let darker = min(first.luminance, second.luminance)
        return (lighter + 0.05) / (darker + 0.05)
    }
}
