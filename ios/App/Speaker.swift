import AVFoundation
import SwiftUI

/// Reads English text aloud with the device's own voice (offline; nothing leaves the phone).
/// Voice, rate and audio session come from `WordSpeech` (Shared/), the same ones the widget's
/// speaker button uses.
@MainActor
final class Speaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = Speaker()

    /// The text being read right now (drives the speaker icon); nil when silent.
    @Published private(set) var speakingText: String?

    private let synthesizer = AVSpeechSynthesizer()
    private var current: ObjectIdentifier?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Starts reading `text`; a second tap on the text being read stops it.
    func toggle(_ text: String) {
        let wasSpeakingThis = speakingText == text
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        if wasSpeakingThis {
            finish()
            return
        }
        WordSpeech.activateSession()
        let utterance = WordSpeech.makeUtterance(text)
        current = ObjectIdentifier(utterance)
        speakingText = text
        synthesizer.speak(utterance)
    }

    /// Stops reading at once (nothing happens when silent) and releases the audio session.
    func stop() {
        guard current != nil else { return }
        synthesizer.stopSpeaking(at: .immediate)
        finish()
    }

    /// Silences everything that reads aloud in the app's process: the speaker buttons and the
    /// widget's speaker button (`SpeakWordIntent` runs here, through `WordSpeechPlayer`). The "Söyle"
    /// microphone calls this before it takes the audio session.
    static func stopAll() {
        shared.stop()
        WordSpeechPlayer.shared.stop()
    }

    private func finish() {
        current = nil
        speakingText = nil
        WordSpeech.deactivateSession()
    }

    /// Only the utterance started last may clear the state: a cancelled one reports back after
    /// the next one has already started.
    private func utteranceEnded(_ id: ObjectIdentifier) {
        if id == current {
            finish()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in
            self.utteranceEnded(id)
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in
            self.utteranceEnded(id)
        }
    }
}

/// Speaker icon that reads `text` aloud (44 pt target). The icon animates while it is reading.
struct SpeakButton: View {
    @ObservedObject private var speaker = Speaker.shared
    let text: String
    var accessibilityName = "Dinle"

    var body: some View {
        let isSpeaking = speaker.speakingText == text
        Button {
            speaker.toggle(text)
        } label: {
            Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.title3)
                .symbolEffect(.variableColor.iterative, isActive: isSpeaking)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(isSpeaking ? "Durdur" : accessibilityName)
    }
}
