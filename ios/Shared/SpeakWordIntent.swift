import AppIntents
import Foundation

/// Widget button: say the word aloud without opening the app.
///
/// `AudioPlaybackIntent` is what makes this work: Apple's WidgetKit documentation ("Adding
/// interactivity to widgets and Live Activities") says the system performs an intent that adopts
/// it in the app's process, while an ordinary `AppIntent` runs in the widget extension. So this
/// file is compiled into the app AND into the widget extension (`Shared/` in project.yml): the
/// extension needs the type for `Button(intent:)`, the app needs it to run `perform()`. The app
/// also declares the `audio` background mode: Apple documents that the `.playback` category needs
/// it to play while the app is in the background (otherwise activation fails, `cannotStartPlaying`).
///
/// Home screen families only (Lock Screen buttons would not work while the device is locked).
struct SpeakWordIntent: AudioPlaybackIntent {
    /// The button's name (docs/tasarim/terimler.md §3).
    static var title: LocalizedStringResource {
        "Kelimeyi dinle"
    }

    /// Widget-only: not offered as a "speak any text" action in Shortcuts, Spotlight or Siri.
    static var isDiscoverable: Bool {
        false
    }

    @Parameter(title: "Okunacak metin")
    var text: String

    init() {}

    init(text: String) {
        self.text = text
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        await WordSpeechPlayer.shared.speakAndWait(text)
        return .result()
    }
}
