import Darwin
import SwiftUI
import UIKit
import WidgetKit
import XCTest
import SharedState

/// What VoiceOver gets from the progress widget's families: each is one element with a whole
/// Turkish sentence in a Turkish voice (`widgetTurkishVoice()`), never "3 / 5" ("bölü") or an
/// empty element. Read as `WidgetVoiceOverTests` does (the views hosted in a window, the element's
/// `accessibilityLanguage` or its label's speech language); every element found is attached
/// ("ilerleme-sesler"). A check with VoiceOver on a device stays on the README list.
@MainActor
final class ProgressWidgetVoiceOverTests: XCTestCase {
    private struct Element {
        let label: String
        let language: String?
    }

    /// SwiftUI builds its accessibility tree only while an assistive client is active (as in
    /// `WidgetVoiceOverTests`).
    private static let accessibilityEnabled: Bool = {
        guard let handle = dlopen("/usr/lib/libAccessibility.dylib", RTLD_NOW),
              let symbol = dlsym(handle, "_AXSSetAutomationEnabled") else {
            return false
        }
        typealias SetEnabled = @convention(c) (Int32) -> Void
        unsafeBitCast(symbol, to: SetEnabled.self)(1)
        return true
    }()

    func testProgressVoices() throws {
        try XCTSkipUnless(ProgressWidgetVoiceOverTests.accessibilityEnabled, "accessibility automation is not available")
        RunLoop.main.run(until: Date().addingTimeInterval(1))
        let calendar = Calendar.current
        let now = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date(timeIntervalSince1970: 1_800_000_000))!
        let evening = calendar.date(bySettingHour: 21, minute: 40, second: 0, of: now)!
        let cases: [(name: String, status: ProgressStatus?)] = [
            ("bekliyor", ProgressStatus(date: now, dailyGoal: 5, newWordsToday: 3, dueNow: 4, dueToday: 6, nextDue: evening)),
            ("sirada", ProgressStatus(date: now, dailyGoal: 5, newWordsToday: 3, dueNow: 0, dueToday: 6, nextDue: evening)),
            ("yeni", ProgressStatus(date: now, dailyGoal: 5, newWordsToday: 0, dueNow: 0, dueToday: 0, nextDue: nil)),
            ("veri-yok", nil),
        ]
        var report = ["iOS \(UIDevice.current.systemVersion), preferred \(Locale.preferredLanguages)"]
        for item in cases {
            let entry = ProgressEntry(date: now, status: item.status)
            let families: [(name: String, expected: String, elements: [Element])] = [
                ("daire", ProgressText.goalSpoken(item.status), elements(
                    of: ProgressCircularView(entry: entry),
                    size: CGSize(width: 72, height: 72)
                )),
                ("rect", ProgressText.rectangular(item.status, calendar: calendar).spoken, elements(
                    of: ProgressRectangularView(entry: entry, calendar: calendar),
                    size: CGSize(width: 160, height: 72)
                )),
                ("inline", ProgressText.inline(item.status, calendar: calendar).spoken, elements(
                    of: ProgressInlineView(entry: entry, calendar: calendar),
                    size: CGSize(width: 234, height: 26)
                )),
            ]
            for family in families {
                report.append("== \(family.name) \(item.name)")
                report.append(contentsOf: family.elements.map { element in
                    "  label=\(element.label) lang=\(element.language ?? "nil")"
                })
                let context = "\(family.name) \(item.name): "
                    + family.elements.map { "\($0.label) [\($0.language ?? "nil")]" }.joined(separator: " | ")
                XCTAssertEqual(family.elements.map(\.label), [family.expected], context)
                XCTAssertTrue(family.elements.allSatisfy { $0.language?.lowercased().hasPrefix("tr") == true }, context)
                XCTAssertFalse(family.elements.contains { $0.label.contains("/") }, context)
            }
        }
        for line in report {
            print("ILERLEMESES \(line)")
        }
        let attachment = XCTAttachment(string: report.joined(separator: "\n"))
        attachment.name = "ilerleme-sesler"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Reading the accessibility elements (as in WidgetVoiceOverTests)

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
            found.append(Element(label: node.accessibilityLabel ?? "", language: language(of: node)))
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
