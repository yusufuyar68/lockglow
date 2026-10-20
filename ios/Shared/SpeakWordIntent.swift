import AppIntents
import Foundation

/// Widget button: say the word aloud without opening the app.
///
/// `AudioPlaybackIntent` is what makes this work: Apple's WidgetKit documentation ("Adding
/// interactivity to widgets and Live Activities") says the system performs an intent that adopts
/// it in the app's process, while an ordinary `AppIntent` runs in the widget extension. So this
/// file is compiled into the app AND into the widget extension (`Shared/` in project.yml): the
/// extension needs the type for `Button(intent:)`, the app needs it to run `perform()`. The app
/// also declares the `audio` background mode; developers report that without it the audio session
/// cannot be activated while the app is launched in the background (error 561015905).
///
/// Home screen families only: Lock Screen widgets are not interactive.
struct SpeakWordIntent: AudioPlaybackIntent {
    static var title: LocalizedStringResource {
        "Kelimeyi seslendir"
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
