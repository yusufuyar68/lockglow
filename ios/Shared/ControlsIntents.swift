import AppIntents
import Combine
import Foundation
import CoreModels
import SharedState
import Scheduler

// The intents of the iOS 18 controls (Widgets/Controls.swift) that run in the app's process.
// Like SpeakWordIntent.swift, this file is compiled into the app AND into the widget extension
// (`Shared/` in project.yml): the extension needs the types for `ControlWidgetButton(action:)`,
// the app runs `perform()`.
// - "Kelimeyi dinle" is an `AudioPlaybackIntent`: the system runs it in the app's process, as it
//   does the widget's speaker.
// - "Tekrar'ı aç" is an `OpenIntent`. Apple ("Creating controls to perform actions across the
//   system"): a control opens the app with an intent that conforms to `OpenIntent`, and the
//   intent must be in both the app and the widget extension.

/// The word every widget shows right now, read from the App Group as the widget reads it
/// (`WordDataSource.load`, Widgets/): the plan and the widget state, or the bundled seed words
/// when there is no plan. Never throws, never opens SQLite.
enum ShownWord {
    static func current(at now: Date = Date()) -> WidgetWord? {
        let store = AppGroupLocator.containerURL().map { AppGroupStore(containerURL: $0) }
        let plan = store?.readPlan()
        let state = store?.readState()
        let hasPlan = !(plan?.queue.isEmpty ?? true)
        let seedWords: [WidgetWord] = hasPlan ? [] : SeedWords.load()
        let input = RotationInput.resolve(plan: plan, state: state, seedWords: seedWords)
        return TimelinePlanner.shownWord(
            input: input,
            now: now,
            alignmentOffset: TimelinePlanner.localAlignmentOffset(for: now)
        )
    }
}

/// "Kelimeyi dinle" control: says the word the widgets show right now, without opening the app.
/// The word is worked out when the control is tapped (`ShownWord`): a control is not redrawn when
/// the widget's word changes, so it cannot carry the word as the widget button does.
struct SpeakShownWordIntent: AudioPlaybackIntent {
    /// The button's name (docs/tasarim/terimler.md §3).
    static var title: LocalizedStringResource {
        "Kelimeyi dinle"
    }

    /// Control-only, like the widget's speaker: not offered in Shortcuts, Spotlight or Siri.
    static var isDiscoverable: Bool {
        false
    }

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        if let word = ShownWord.current() {
            await WordSpeechPlayer.shared.speakAndWait(word.lemma)
        }
        return .result()
    }
}

/// The screens a control can open. Only Tekrar for now.
enum ControlScreen: String, AppEnum {
    case review

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Ekran"

    static var caseDisplayRepresentations: [ControlScreen: DisplayRepresentation] = [
        .review: "Tekrar",
    ]
}

/// "Tekrar'ı aç" control: opens the app on Tekrar. The system brings the app to the foreground
/// and runs `perform()` there; RootView switches the tab (`ControlOpenRequest`).
struct OpenReviewIntent: OpenIntent {
    static var title: LocalizedStringResource {
        "Tekrar'ı aç"
    }

    /// Control-only: not offered in Shortcuts, Spotlight or Siri.
    static var isDiscoverable: Bool {
        false
    }

    @Parameter(title: "Ekran", default: .review)
    var target: ControlScreen

    init() {}

    init(target: ControlScreen) {
        self.target = target
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        ControlOpenRequest.shared.screen = target
        return .result()
    }
}

/// The screen a control asked the app to open. `OpenReviewIntent` sets it; RootView opens the
/// screen and sets it back to nil. Published, so RootView still sees a request made while the app
/// was launching (its `onReceive` gets the current value first).
@MainActor
final class ControlOpenRequest: ObservableObject {
    static let shared = ControlOpenRequest()

    @Published var screen: ControlScreen?
}
