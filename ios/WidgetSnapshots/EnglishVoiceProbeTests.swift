import Darwin
import SwiftUI
import UIKit
import XCTest

/// Throwaway probe (branch is4-tekrar-sonda, never merged; after is3-tema-ekran): what SwiftUI hands to VoiceOver for
/// `englishVoice()` in the patterns the app uses (audit V5, V6). It asserts nothing; it prints
/// each accessibility element's label, language and attributed-label attributes and attaches
/// the same text as "ses-probe".
final class EnglishVoiceProbeTests: XCTestCase {
    /// SwiftUI builds its accessibility tree only while an assistive client is active; turn on
    /// the automation client in-process (the KIF approach) so the hosting views expose it.
    private static let accessibilityEnabled: Bool = {
        guard let handle = dlopen("/usr/lib/libAccessibility.dylib", RTLD_NOW),
              let symbol = dlsym(handle, "_AXSSetAutomationEnabled") else {
            return false
        }
        typealias SetEnabled = @convention(c) (Int32) -> Void
        unsafeBitCast(symbol, to: SetEnabled.self)(1)
        return true
    }()

    @MainActor
    func testEnglishVoiceProbe() throws {
        let enabled = EnglishVoiceProbeTests.accessibilityEnabled
        RunLoop.main.run(until: Date().addingTimeInterval(1))
        let cases: [(String, AnyView)] = [
            ("A representation: Turkish / English / Turkish in .contain", AnyView(
                VStack {
                    Text(verbatim: "Doğrusu: borrow = ödünç almak")
                        .accessibilityRepresentation {
                            Text(verbatim: "Doğrusu:")
                            Text(verbatim: "borrow").englishVoice()
                            Text(verbatim: "Türkçesi: ödünç almak")
                        }
                }
                .accessibilityElement(children: .contain)
            )),
            ("B row .contain: English Text + Turkish Text + combined Turkish pair", AnyView(
                HStack {
                    VStack {
                        Text(verbatim: "borrow").englishVoice()
                        Text(verbatim: "ödünç almak")
                    }
                    VStack {
                        Text(verbatim: "yarın")
                        Text(verbatim: "Bildim")
                    }
                    .accessibilityElement(children: .combine)
                }
                .accessibilityElement(children: .contain)
            )),
            ("C button label: English Text(englishVoice) + Turkish mark", AnyView(
                Button {} label: {
                    HStack {
                        Text(verbatim: "spoon").englishVoice()
                        Text(verbatim: "Doğru cevap")
                    }
                }
            )),
            ("D button + representation of two Texts", AnyView(
                Button {} label: {
                    HStack {
                        Text(verbatim: "spoon").englishVoice()
                        Text(verbatim: "Doğru cevap")
                    }
                }
                .accessibilityRepresentation {
                    Text(verbatim: "spoon").englishVoice()
                    Text(verbatim: "Doğru cevap")
                }
            )),
            ("E ignore + label Text(AttributedString from NSAttributedString speech-language runs)", AnyView(
                Text(verbatim: "x")
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text(EnglishVoiceProbeTests.mixedLabel()))
            )),
            ("F baseline: combine Turkish + English(englishVoice)", AnyView(
                HStack {
                    Text(verbatim: "Doğrusu:")
                    Text(verbatim: "borrow").englishVoice()
                }
                .accessibilityElement(children: .combine)
            )),
            ("G button English label + Turkish value", AnyView(
                Button {} label: { Text(verbatim: "spoon").englishVoice() }
                    .accessibilityValue(Text(verbatim: "Doğru cevap"))
            )),
            ("H Turkish button + Turkish value (time)", AnyView(
                Button {} label: { Text(verbatim: "Buldum") }
                    .accessibilityValue(Text(verbatim: "yarın yine gelir"))
            )),
            ("I removed button trait + representation (answered option)", AnyView(
                Button {} label: {
                    HStack {
                        Text(verbatim: "spoon").englishVoice()
                        Text(verbatim: "Yanlış")
                    }
                }
                .allowsHitTesting(false)
                .accessibilityRemoveTraits(.isButton)
                .accessibilityRepresentation {
                    Text(verbatim: "spoon").englishVoice()
                    Text(verbatim: "Yanlış")
                }
            )),
        ]
        var report = ["iOS \(UIDevice.current.systemVersion), preferred \(Locale.preferredLanguages), automation \(enabled)"]
        for (name, view) in cases {
            report.append("== \(name)")
            report.append(contentsOf: describe(view))
        }
        for line in report {
            print("SESPROBE \(line)")
        }
        let attachment = XCTAttachment(string: report.joined(separator: "\n"))
        attachment.name = "ses-probe"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// "Doğrusu: " (tr-TR) + "borrow" (en-US) + ", Türkçesi: ödünç almak" (tr-TR), as the app's
    /// announcements build it, turned into an AttributedString for a SwiftUI label.
    private static func mixedLabel() -> AttributedString {
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: "Doğrusu: ", attributes: [.accessibilitySpeechLanguage: "tr-TR"]))
        text.append(NSAttributedString(string: "borrow", attributes: [.accessibilitySpeechLanguage: "en-US"]))
        text.append(NSAttributedString(string: ", Türkçesi: ödünç almak", attributes: [.accessibilitySpeechLanguage: "tr-TR"]))
        return (try? AttributedString(text, including: \.uiKit)) ?? AttributedString("conversion failed")
    }

    @MainActor
    private func describe(_ root: AnyView) -> [String] {
        let host = UIHostingController(rootView: root.padding())
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 300))
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.8))
        _ = host.view.accessibilityElements
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))
        var lines: [String] = []
        walk(host.view, depth: 0, into: &lines)
        window.isHidden = true
        if lines.isEmpty {
            lines.append("(no accessibility element found)")
        }
        return lines
    }

    @MainActor
    private func walk(_ node: NSObject, depth: Int, into lines: inout [String]) {
        guard depth < 10 else {
            return
        }
        if node.isAccessibilityElement {
            lines.append(String(repeating: "  ", count: depth) + line(for: node))
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
            walk(child, depth: depth + 1, into: &lines)
        }
    }

    @MainActor
    private func line(for node: NSObject) -> String {
        var attributes = ""
        if let attributed = node.accessibilityAttributedLabel, attributed.length > 0 {
            attributed.enumerateAttributes(in: NSRange(location: 0, length: attributed.length)) { values, range, _ in
                let pairs = values.map { "\($0.key.rawValue)=\($0.value)" }.sorted().joined(separator: ", ")
                attributes += " [\(range.location)+\(range.length): \(pairs)]"
            }
        }
        var hintAttributes = ""
        if let attributed = node.accessibilityAttributedHint, attributed.length > 0 {
            attributed.enumerateAttributes(in: NSRange(location: 0, length: attributed.length)) { values, range, _ in
                let pairs = values.map { "\($0.key.rawValue)=\($0.value)" }.sorted().joined(separator: ", ")
                hintAttributes += " [\(range.location)+\(range.length): \(pairs)]"
            }
        }
        return "\(type(of: node)) label=\(node.accessibilityLabel ?? "nil")"
            + " lang=\(node.accessibilityLanguage ?? "nil")"
            + " hint=\(node.accessibilityHint ?? "nil")"
            + " traits=\(node.accessibilityTraits.rawValue)"
            + " labelAttrs=\(attributes.isEmpty ? " none" : attributes)"
            + " hintAttrs=\(hintAttributes.isEmpty ? " none" : hintAttributes)"
    }
}
