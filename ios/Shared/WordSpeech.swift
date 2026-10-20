import AVFoundation
import os

/// How Lockglow reads English aloud. Compiled into the app (the speaker buttons in `Speaker`) and
/// into the widget extension (`SpeakWordIntent`, which the system runs in the app's process):
/// the device's own US English voice (offline), the best installed quality, a little slower than
/// the default rate for an A2 learner, and a `.playback` audio session that ducks other audio.
enum WordSpeech {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "speech"
    )

    /// 0.9 of the default rate.
    static let rate = AVSpeechUtteranceDefaultSpeechRate * 0.9

    /// The best installed US English voice (an enhanced or premium voice when the user has
    /// downloaded one). Looked up once per process.
    static let voice: AVSpeechSynthesisVoice? = bestVoice()

    static func makeUtterance(_ text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = rate
        return utterance
    }

    /// Playback, so a tap is heard even with the silent switch on; other audio dips.
    /// Returns false (and logs why) when the system refuses to activate the session.
    @discardableResult
    static func activateSession() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
            return true
        } catch {
            logger.error("audio session not activated: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    static func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
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

/// Reads one text for the widget's speaker button and returns when the speech is over. The
/// widget intent must not return earlier: the app was most likely launched in the background
/// just for this tap and is suspended again soon after `perform()` returns.
@MainActor
final class WordSpeechPlayer: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = WordSpeechPlayer()

    private let synthesizer = AVSpeechSynthesizer()
    /// The utterance being read right now; kept so a stale callback can be told apart.
    private var current: AVSpeechUtterance?
    private var waiter: CheckedContinuation<Void, Never>?
    private var watchdog: Task<Void, Never>?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Speaks `text`. A second call replaces the first. Returns after the speech ended, after it
    /// was replaced, or after `timeout` seconds (a speech that never starts must not keep the
    /// intent running).
    func speakAndWait(_ text: String, timeout: TimeInterval = 8) async {
        let spoken = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !spoken.isEmpty else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        // Release the call this one replaces; its cancel callback arrives with a stale utterance.
        current = nil
        watchdog?.cancel()
        resumeWaiter()

        // If the app's own audio session cannot be activated (the system refuses it while the app
        // runs in the background), let the system manage the session for this utterance (WWDC20
        // session 10022: `usesApplicationAudioSession = false`) instead of staying silent.
        synthesizer.usesApplicationAudioSession = WordSpeech.activateSession()
        let utterance = WordSpeech.makeUtterance(spoken)
        let id = ObjectIdentifier(utterance)
        current = utterance
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            waiter = continuation
            watchdog = Task { [weak self] in
                do {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                } catch {
                    return
                }
                self?.timedOut(id)
            }
            synthesizer.speak(utterance)
        }
    }

    private func timedOut(_ id: ObjectIdentifier) {
        guard let current, ObjectIdentifier(current) == id else { return }
        synthesizer.stopSpeaking(at: .immediate)
        end(id)
    }

    /// Only the utterance started last may end the speech and release the audio session.
    private func end(_ id: ObjectIdentifier) {
        guard let current, ObjectIdentifier(current) == id else { return }
        self.current = nil
        watchdog?.cancel()
        watchdog = nil
        WordSpeech.deactivateSession()
        resumeWaiter()
    }

    private func resumeWaiter() {
        let pending = waiter
        waiter = nil
        pending?.resume()
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in
            self.end(id)
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in
            self.end(id)
        }
    }
}
