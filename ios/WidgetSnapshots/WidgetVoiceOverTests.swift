import Darwin
import SwiftUI
import UIKit
import WidgetKit
import XCTest
import CoreModels

/// What VoiceOver gets from the widget views (ios/README.md point 14; accessibility audit V5 and
/// V6; text audit #15): the English word, definition and example in an English voice, the
/// Turkish meaning, the next change and the buttons in the device's voice, the "Biliyorum" hint
/// of the 3-day rule, and no empty element for a user's own word. The views are hosted in a window
/// and their accessibility elements read as is3-tema's probe did (docs/denetim/
/// kontrast_tema_2026-10-22.md, "Simülatörde ölçüm"): the element's `accessibilityLanguage`, else
/// its label's speech-language attribute. This is the data VoiceOver reads in the app's hosting,
/// not the voice itself and not WidgetKit's archive: a check on a device stays on the README list.
/// Every element found is attached ("widget-sesler").
@MainActor
final class WidgetVoiceOverTests: XCTestCase {
    private struct Element {
        let label: String
        /// The element's language or its label's speech language; nil for the device's voice.
        let language: String?
        let hint: String?

        var isEnglish: Bool {
            return language?.lowercased().hasPrefix("en") == true
        }
    }

    /// SwiftUI builds its accessibility tree only while an assistive client is active: the
    /// automation client is turned on in this process (KIF's approach, as in is3-tema's probe).
    private static let accessibilityEnabled: Bool = {
        guard let handle = dlopen("/usr/lib/libAccessibility.dylib", RTLD_NOW),
              let symbol = dlsym(handle, "_AXSSetAutomationEnabled") else {
            return false
        }
        typealias SetEnabled = @convention(c) (Int32) -> Void
        unsafeBitCast(symbol, to: SetEnabled.self)(1)
        return true
    }()

    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private let margins = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

    func testWidgetVoices() throws {
        try XCTSkipUnless(WidgetVoiceOverTests.accessibilityEnabled, "accessibility automation is not available")
        RunLoop.main.run(until: Date().addingTimeInterval(1))
        var report = ["iOS \(UIDevice.current.systemVersion), preferred \(Locale.preferredLanguages)"]
        let words = SnapshotWords.all.filter { word in
            [1, 286, 1_000_000, 1_000_001].contains(word.id)
        }
        XCTAssertEqual(words.count, 4)
        for word in words {
            let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
            let families: [(name: String, elements: [Element])] = [
                ("small", elements(
                    of: SmallWordView(entry: entry, margins: margins, renderingMode: .fullColor, showsBackground: true),
                    size: CGSize(width: 158, height: 158)
                )),
                ("medium", elements(
                    of: MediumWordView(entry: entry, margins: margins, renderingMode: .fullColor, showsBackground: true),
                    size: CGSize(width: 338, height: 158)
                )),
                ("rect", elements(
                    of: RectangularWordView(entry: entry, renderingMode: .vibrant),
                    size: CGSize(width: 160, height: 72)
                )),
                ("inline", elements(of: InlineWordView(entry: entry), size: CGSize(width: 234, height: 26))),
            ]
            for family in families {
                report.append("== \(family.name) \(word.lemma)")
                report.append(contentsOf: family.elements.map { element in
                    "  label=\(element.label) lang=\(element.language ?? "nil") hint=\(element.hint ?? "nil")"
                })
                check(family.elements, of: word, family: family.name)
            }
        }
        for line in report {
            print("WIDGETSES \(line)")
        }
        let attachment = XCTAttachment(string: report.joined(separator: "\n"))
        attachment.name = "widget-sesler"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func check(_ elements: [Element], of word: WidgetWord, family: String) {
        let found = elements.map { "\($0.label) [\($0.language ?? "nil")]" }.joined(separator: " | ")
        let context = "\(family) \(word.lemma): \(found)"
        // The word, once, in an English voice.
        let headwords = elements.filter { $0.label == word.lemma }
        XCTAssertEqual(headwords.count, 1, context)
        XCTAssertTrue(headwords.allSatisfy { $0.isEnglish }, context)
        // The whole Turkish meaning, never in the English voice. The Lock Screen rectangle leaves
        // a meaning that fits on no line out; the others always have one at the default size.
        let meaning = "Türkçesi: \(word.glossTR ?? "")"
        let meanings = elements.filter { $0.label == meaning }
        if family != "rect" || (word.glossTR ?? "").count <= 16 {
            XCTAssertEqual(meanings.count, 1, context)
        }
        XCTAssertFalse(meanings.contains { $0.isEnglish }, context)
        // No empty element, no "·" read aloud, no level for a word without one.
        XCTAssertFalse(elements.contains { $0.label.trimmingCharacters(in: .whitespaces).isEmpty }, context)
        XCTAssertFalse(elements.contains { $0.label.contains("·") }, context)
        if word.level.isEmpty {
            XCTAssertFalse(elements.contains { $0.label.hasPrefix("Seviye") }, context)
        }
        switch family {
        case "small":
            XCTAssertTrue(elements.contains { $0.label == "Kelimeyi dinle" && !$0.isEnglish }, context)
            XCTAssertTrue(elements.contains { $0.label == "Sonraki kelime" && !$0.isEnglish }, context)
        case "medium":
            checkMedium(elements, of: word, context: context)
        default:
            break
        }
    }

    private func checkMedium(_ elements: [Element], of word: WidgetWord, context: String) {
        let know = elements.filter { $0.label == "Biliyorum" }
        XCTAssertEqual(know.count, 1, context)
        XCTAssertEqual(know.first?.hint, KnowWordButton.hint, context)
        XCTAssertFalse(know.contains { $0.isEnglish }, context)
        if !word.isUserAdded {
            // The English definition (short or micro) in an English voice.
            XCTAssertTrue(
                elements.contains { ($0.label == word.defShort || $0.label == word.defMicro) && $0.isEnglish },
                context
            )
            XCTAssertTrue(elements.contains { $0.label == "Seviye \(word.level)" && !$0.isEnglish }, context)
        }
        if !word.exampleEN.isEmpty, word.exampleEN.localizedCaseInsensitiveContains(word.lemma) {
            // The example (whole, or from a few words before the word) in an English voice.
            XCTAssertTrue(
                elements.contains { element in
                    element.label != word.lemma
                        && element.label.localizedCaseInsensitiveContains(word.lemma)
                        && element.isEnglish
                },
                context
            )
        }
        if word.id == 1 {
            // "Yeni kelime: 10:00" on screen, "Sonraki değişim: …" for VoiceOver.
            XCTAssertTrue(elements.contains { $0.label.hasPrefix("Sonraki değişim: ") && !$0.isEnglish }, context)
        }
    }

    // MARK: - Reading the accessibility elements

    private func elements<V: View>(of view: V, size: CGSize) -> [Element] {
        let host = UIHostingController(rootView: view.frame(width: size.width, height: size.height))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 300))
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.8))
        _ = host.view.accessibilityElements
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))
        var found: [Element] = []
        walk(host.view, depth: 0, into: &found)
        window.isHidden = true
        return found
    }

    private func walk(_ node: NSObject, depth: Int, into found: inout [Element]) {
        guard depth < 12 else {
            return
        }
        if node.isAccessibilityElement {
            found.append(Element(
                label: node.accessibilityLabel ?? "",
                language: language(of: node),
                hint: node.accessibilityHint
            ))
        }
        var children: [NSObject] = []
        if let elements = node.accessibilityElements as? [NSObject], !elements.isEmpty {
            children = elements
        } else {
            let count = node.accessibilityElementCount()
            if count != NSNotFound && count > 0 {
                for index in 0..<count {
                    if let child = node.accessibilityElement(at: index) as? NSObject {
                        children.append(child)
                    }
                }
            }
        }
        if children.isEmpty, let view = node as? UIView {
            children = view.subviews
        }
        for child in children {
            walk(child, depth: depth + 1, into: &found)
        }
    }

    /// The element's language, else the speech-language attribute of its label
    /// (`UIAccessibilitySpeechAttributeLanguage`); nil when VoiceOver uses the device's voice.
    private func language(of node: NSObject) -> String? {
        if let language = node.accessibilityLanguage, !language.isEmpty {
            return language
        }
        guard let attributed = node.accessibilityAttributedLabel, attributed.length > 0 else {
            return nil
        }
        var speech: String?
        attributed.enumerateAttributes(in: NSRange(location: 0, length: attributed.length)) { values, _, _ in
            for (key, value) in values where speech == nil && key.rawValue.hasSuffix("Language") {
                speech = "\(value)"
            }
        }
        return speech
    }
}
