import AVFoundation

/// "Dinle" on the watch: reads the English word with the watch's own US English voice (offline),
/// the best installed quality, a little slower than the default rate for an A2 learner, as on the
/// phone (`WordSpeech`). The synthesizer manages its own audio session
/// (`usesApplicationAudioSession = false`), so the app needs no audio session code; on the watch the
/// system plays it through the speaker or connected headphones.
@MainActor
final class WatchSpeaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var isSpeaking = false

    /// 0.9 of the default rate (the phone's `WordSpeech.rate`).
    private static let rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
    private static let voice: AVSpeechSynthesisVoice? = bestVoice()

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
        synthesizer.usesApplicationAudioSession = false
    }

    /// Speaks `text`; a second call replaces the first.
    func speak(_ text: String) {
        let spoken = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !spoken.isEmpty else {
            return
        }
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: spoken)
        utterance.voice = WatchSpeaker.voice
        utterance.rate = WatchSpeaker.rate
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
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

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.speechEnded()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.speechEnded()
        }
    }

    /// A replaced utterance ends too: the button keeps "Durdur" while the new one plays.
    private func speechEnded() {
        isSpeaking = synthesizer.isSpeaking
    }
}
