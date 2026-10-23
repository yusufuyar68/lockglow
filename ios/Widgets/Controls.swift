import AppIntents
import SwiftUI
import WidgetKit
import CoreModels

// iOS 18 controls: "Kelimeyi dinle", "Sonraki kelime", "Tekrar'ı aç". People put them in Control
// Center, in place of the Lock Screen's two bottom buttons, or on the Action button. The system
// draws a control from its symbol and title: on the Lock Screen only the symbol, and a locked
// device hides the title. Names are those of docs/tasarim/terimler.md; the symbols are the widget
// buttons' (WidgetButtons.swift) and the Tekrar tab's (RootView).
// A control has no timeline: the system redraws it when it asks, not when the widget's word
// changes. So no control shows the word; the two word controls work it out when tapped
// (`ShownWord`, Shared/ControlsIntents.swift), the word every widget shows at that moment.
// The gallery lists the controls in LockglowWidgetsBundle's order. They are registered there
// under `if #available(iOS 18.0, *)`; iOS 17 keeps the widget buttons only.

@available(iOS 18.0, *)
struct SpeakWordControl: ControlWidget {
    static let kind = "SpeakWordControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: SpeakWordControl.kind) {
            ControlWidgetButton(action: SpeakShownWordIntent()) {
                Label("Kelimeyi dinle", systemImage: "speaker.wave.2")
            }
        }
        .displayName("Kelimeyi dinle")
        .description("Widget'taki kelimeyi sesli okur.")
    }
}

@available(iOS 18.0, *)
struct NextWordControl: ControlWidget {
    static let kind = "NextWordControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: NextWordControl.kind) {
            ControlWidgetButton(action: NextShownWordIntent()) {
                Label("Sonraki kelime", systemImage: "forward.fill")
            }
        }
        .displayName("Sonraki kelime")
        .description("Widget'larda sıradaki kelimeye geçer.")
    }
}

@available(iOS 18.0, *)
struct OpenReviewControl: ControlWidget {
    static let kind = "OpenReviewControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: OpenReviewControl.kind) {
            ControlWidgetButton(action: OpenReviewIntent(target: .review)) {
                Label("Tekrar'ı aç", systemImage: "arrow.triangle.2.circlepath")
            }
        }
        .displayName("Tekrar'ı aç")
        .description("Lockglow'u Tekrar'da açar.")
    }
}

/// "Sonraki kelime" control: the widget's "Sonraki" (`NextWordIntent`) on the word the widgets
/// show right now. Runs in the widget extension, like the widget button. After a widget button
/// the system reloads that widget; after a control it reloads only the control, so this asks for
/// the widgets itself: all of them, so every widget that shows the word moves on together.
struct NextShownWordIntent: AppIntent {
    /// The button's name (docs/tasarim/terimler.md §3).
    static var title: LocalizedStringResource {
        "Sonraki kelime"
    }

    /// Control-only: not offered in Shortcuts, Spotlight or Siri.
    static var isDiscoverable: Bool {
        false
    }

    init() {}

    func perform() async throws -> some IntentResult {
        guard let word = ShownWord.current() else {
            return .result()
        }
        _ = try await NextWordIntent(wordID: word.id, source: WidgetEventSource.control.rawValue).perform()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
