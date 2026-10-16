import AVFoundation
import SwiftUI

/// Reads English text aloud with the device's own voice (offline; nothing leaves the phone).
/// The best installed US English voice is used (an enhanced or premium voice when the user has
/// downloaded one), a little slower than the default rate for an A2 learner.
@MainActor
final class Speaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = Speaker()

    /// The text being read right now (drives the speaker icon); nil when silent.
    @Published private(set) var speakingText: String?

    private let synthesizer = AVSpeechSynthesizer()
    private var current: ObjectIdentifier?
    private lazy var voice: AVSpeechSynthesisVoice? = Speaker.bestVoice()

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
        let session = AVAudioSession.sharedInstance()
        // Playback, so a tap on "Dinle" is heard even with the silent switch on; other audio dips.
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        current = ObjectIdentifier(utterance)
        speakingText = text
        synthesizer.speak(utterance)
    }

    private func finish() {
        current = nil
        speakingText = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
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

    private static func bestVoice() -> AVSpeechSynthesisVoice? {
        let candidates = AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language == "en-US"
                && !voice.voiceTraits.contains(.isNoveltyVoice)
                && !voice.voiceTraits.contains(.isPersonalVoice)
        }
        let best = candidates.max { $0.quality.rawValue < $1.quality.rawValue }
        return best ?? AVSpeechSynthesisVoice(language: "en-US")
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
