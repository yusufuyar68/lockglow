import Darwin
import SwiftUI
import UIKit
import XCTest

/// Throwaway probe (branch is3-tema-ekran, never merged): what SwiftUI hands to VoiceOver for
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
            ("01 Text(verbatim:) + englishVoice", AnyView(Text(verbatim: "breakfast").englishVoice())),
            ("02 Text(String) + englishVoice", AnyView(Text(String("breakfast")).englishVoice())),
            ("03 Text(\"literal\") + englishVoice", AnyView(Text("breakfast").englishVoice())),
            ("04 Text(verbatim:) without modifier", AnyView(Text(verbatim: "breakfast"))),
            ("05 Text(verbatim:) + tr_TR locale", AnyView(
                Text(verbatim: "breakfast").environment(\.locale, Locale(identifier: "tr_TR"))
            )),
            ("06 Text(AttributedString) + englishVoice", AnyView(
                Text(AttributedString("I eat breakfast at seven.")).englishVoice()
            )),
            ("07 ignore + label(verbatim) + header + englishVoice", AnyView(
                VStack {
                    Text(verbatim: "breakfast")
                    Text(verbatim: "A1")
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "breakfast"))
                .accessibilityAddTraits(.isHeader)
                .englishVoice()
            )),
            ("08 combine: Turkish + English(englishVoice)", AnyView(
                HStack {
                    Text(verbatim: "Doğrusu:")
                    Text(verbatim: "borrow").englishVoice()
                }
                .accessibilityElement(children: .combine)
            )),
            ("09 Button(label verbatim) + englishVoice on button", AnyView(
                Button {} label: { Text(verbatim: "breakfast") }.englishVoice()
            )),
            ("10 Button(label verbatim + englishVoice) + Turkish hint", AnyView(
                Button {} label: { Text(verbatim: "breakfast").englishVoice() }
                    .accessibilityHint(Text(verbatim: "Kelimeyi dinle"))
            )),
            ("11 Turkish Text(verbatim:)", AnyView(Text(verbatim: "kahvaltı"))),
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
