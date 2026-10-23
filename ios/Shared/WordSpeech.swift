import AVFoundation
import CoreModels
import SharedState
import os

/// The settings of "Ses ve aksan" (`SpeechSettings`) in the App Group's UserDefaults. The app
/// writes them (`SpeechSettingsView`); the app's speech, the widget's speaker button (it runs in
/// the app, `SpeakWordIntent`) and the widget's IPA read them. Without an App Group (a test
/// bundle) the process's own defaults.
enum SpeechSettingsStore {
    static let defaults: UserDefaults = {
        if let group = AppGroupLocator.groupIdentifier(), let shared = UserDefaults(suiteName: group) {
            return shared
        }
        return .standard
    }()

    static var current: SpeechSettings {
        return SpeechSettings(defaults: defaults)
    }

    /// The recognizer's language in "Söyle": the accent's ("en-US", "en-GB").
    static var recognitionLocale: Locale {
        return Locale(identifier: current.accent.languageCode)
    }

    static func update(_ change: (inout SpeechSettings) -> Void) {
        var settings = current
        change(&settings)
        settings.save(to: defaults)
    }
}

extension WidgetWord {
    /// The IPA in the accent of "Ses ve aksan", read now. A view on screen while the accent may
    /// change (Akış, Sözlük, Tekrar) uses `AccentIPA` instead, which redraws.
    var chosenIPA: String? {
        return ipa(for: SpeechSettingsStore.current.accent)
    }
}

/// How Lockglow reads English aloud. Compiled into the app (the speaker buttons in `Speaker`) and
/// into the widget extension (`SpeakWordIntent`, which the system runs in the app's process):
/// the device's own voice (offline) in the accent of "Ses ve aksan", the voice chosen there or
/// the best installed one (premium, then enhanced, then standard), the chosen speed (slower for a
/// repeat with "Yavaş tekrar"), and a `.playback` audio session that ducks other audio.
enum WordSpeech {
    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "speech"
    )

    /// The speed of a first hearing with the current settings.
    static var rate: Float {
        return AVSpeechUtteranceDefaultSpeechRate * SpeechSettingsStore.current.rate.defaultRateMultiplier
    }

    /// The voice the current settings pick.
    static var voice: AVSpeechSynthesisVoice? {
        return voice(for: SpeechSettingsStore.current)
    }

    /// `text` with the current settings. A word and a card's sentence alike: the sentence stays
    /// one utterance, so the voice keeps its sentence stress and its pauses at the punctuation;
    /// `SpeechText` only removes what makes a voice stumble (spacing, "2-1", Turkish names).
    /// Every call counts as a hearing: the same text with the same voice and speed again within
    /// 30 seconds is read slower when "Yavaş tekrar" is on.
    static func makeUtterance(_ text: String) -> AVSpeechUtterance {
        let settings = SpeechSettingsStore.current
        let voice = voice(for: settings)
        let key = SpeechRepeatTracker.key(text: text, voiceIdentifier: voice?.identifier, rate: settings.rate)
        let isRepeat = repeats.register(key)
        let utterance = AVSpeechUtterance(attributedString: spokenText(text, accent: settings.accent))
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            * SpeechRules.rateMultiplier(settings.rate, isRepeat: isRepeat, slowRepeat: settings.slowRepeat)
        // For the device test: which voice read, how fast, and whether it was a repeat.
        logger.info(
            "speech voice: \(voice?.identifier ?? "none", privacy: .public), rate: \(utterance.rate, privacy: .public), repeat: \(isRepeat, privacy: .public)"
        )
        return utterance
    }

    /// The pieces of `SpeechText`, a Turkish name with its IPA for the voice.
    static func spokenText(_ text: String, accent: SpeechAccent) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let ipaKey = NSAttributedString.Key(AVSpeechSynthesisIPANotationAttribute)
        for piece in SpeechText.pieces(text, accent: accent) {
            if let ipa = piece.ipa {
                result.append(NSAttributedString(string: piece.text, attributes: [ipaKey: ipa]))
            } else {
                result.append(NSAttributedString(string: piece.text))
            }
        }
        return result
    }

    // MARK: Voices

    /// The voice that reads with `settings`: the chosen one while it is installed, otherwise the
    /// best installed one of the accent. With no offered voice at all, the system's voice for the
    /// accent, then American English: never nil while an English voice exists (a nil voice
    /// would read with the phone's language, Turkish).
    static func voice(for settings: SpeechSettings) -> AVSpeechSynthesisVoice? {
        let installed = catalog.voices
        let pick = SpeechVoiceChoice.voice(
            chosen: settings.voiceIdentifier,
            among: installed.map(info(of:)),
            accent: settings.accent,
            systemDefault: systemDefaultIdentifier(settings.accent)
        )
        if let pick, let voice = installed.first(where: { $0.identifier == pick.identifier }) {
            return voice
        }
        return AVSpeechSynthesisVoice(language: settings.accent.languageCode)
            ?? AVSpeechSynthesisVoice(language: SpeechAccent.american.languageCode)
    }

    /// The voices "Ses ve aksan" offers for `accent`, best first.
    static func offeredVoices(for accent: SpeechAccent) -> [SpeechVoiceInfo] {
        return SpeechVoiceChoice.offered(
            catalog.voices.map(info(of:)),
            accent: accent,
            systemDefault: systemDefaultIdentifier(accent)
        )
    }

    /// No enhanced or premium voice is installed for `accent` ("Daha doğal ses indir").
    static func needsBetterVoice(for accent: SpeechAccent) -> Bool {
        return SpeechVoiceChoice.needsBetterVoice(catalog.voices.map(info(of:)), accent: accent)
    }

    /// Reads the installed voices again at the next use: back from iPhone Settings, where a voice
    /// may have been downloaded (iOS also reports it, `availableVoicesDidChangeNotification`).
    static func refreshVoices() {
        catalog.invalidate()
    }

    static func info(of voice: AVSpeechSynthesisVoice) -> SpeechVoiceInfo {
        return SpeechVoiceInfo(
            identifier: voice.identifier,
            name: voice.name,
            language: voice.language,
            quality: SpeechVoiceInfo.Quality(rawQuality: voice.quality.rawValue),
            isNovelty: voice.voiceTraits.contains(.isNoveltyVoice),
            isPersonal: voice.voiceTraits.contains(.isPersonalVoice)
        )
    }

    private static func systemDefaultIdentifier(_ accent: SpeechAccent) -> String? {
        return AVSpeechSynthesisVoice(language: accent.languageCode)?.identifier
    }

    private static let catalog = VoiceCatalog()
    private static let repeats = RepeatMemory()

    // MARK: Audio session

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
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // With audio still running the session is deactivated anyway and `isBusy` is reported.
            logger.notice("audio session deactivation: \(error.localizedDescription, privacy: .public)")
        }
    }
}

/// The installed voices, read once (`speechVoices()` is slow the first time) and again after iOS
/// reports a change or after `invalidate()`. Any thread.
private final class VoiceCatalog: @unchecked Sendable {
    private let lock = NSLock()
    private var cached: [AVSpeechSynthesisVoice]?
    private var observer: NSObjectProtocol?

    var voices: [AVSpeechSynthesisVoice] {
        lock.lock()
        defer { lock.unlock() }
        if observer == nil {
            observer = NotificationCenter.default.addObserver(
                forName: AVSpeechSynthesizer.availableVoicesDidChangeNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                self?.invalidate()
            }
        }
        if let cached {
            return cached
        }
        let voices = AVSpeechSynthesisVoice.speechVoices()
        cached = voices
        return voices
    }

    func invalidate() {
        lock.lock()
        cached = nil
        lock.unlock()
    }
}

/// The last reading of the app's process (the app's speaker buttons and the widget's, which runs
/// here too), for "Yavaş tekrar".
private final class RepeatMemory: @unchecked Sendable {
    private let lock = NSLock()
    private var tracker = SpeechRepeatTracker()

    func register(_ key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return tracker.register(key, at: Date())
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
    /// Counts the starts (`speakAndWait`) and the stops (`stop`). `end`'s delayed release belongs
    /// to the generation that scheduled it: it never closes a session taken over since, such as
    /// a "Söyle" recording that started right after `stop()`.
    private var generation = 0

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
        generation += 1

        // If the app's own audio session cannot be activated (the system refuses it while the app
        // runs in the background), let the system manage the session for this utterance (WWDC20
        // session 10022: `usesApplicationAudioSession = false`) instead of staying silent.
        let appSession = WordSpeech.activateSession()
        synthesizer.usesApplicationAudioSession = appSession
        // For the device test: which process ran the widget intent, and which audio path it took.
        WordSpeech.logger.notice(
            "widget speech in \(Bundle.main.bundleIdentifier ?? "?", privacy: .public), app audio session: \(appSession, privacy: .public)"
        )
        let utterance = WordSpeech.makeUtterance(spoken)
        let id = ObjectIdentifier(utterance)
        current = utterance
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            waiter = continuation
            watchdog = Task { @MainActor [weak self] in
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

    /// Stops the widget speech at once (nothing happens when silent) and releases the audio session
    /// now, without `end`'s grace period: the caller (the "Söyle" microphone, via
    /// `Speaker.stopAll()`) takes the session over right after. The waiting intent returns.
    func stop() {
        // A release `end` still has pending must leave the session to the caller.
        generation += 1
        guard current != nil else {
            // A speech that has just ended may still be in `end`'s grace period: its intent
            // returns now (nothing happens when no intent waits).
            resumeWaiter()
            return
        }
        current = nil
        watchdog?.cancel()
        watchdog = nil
        synthesizer.stopSpeaking(at: .immediate)
        WordSpeech.deactivateSession()
        resumeWaiter()
    }

    private func timedOut(_ id: ObjectIdentifier) {
        guard let current, ObjectIdentifier(current) == id else { return }
        WordSpeech.logger.notice("widget speech timed out")
        synthesizer.stopSpeaking(at: .immediate)
        end(id)
    }

    /// Only the utterance started last may end the speech and release the audio session.
    private func end(_ id: ObjectIdentifier) {
        guard let current, ObjectIdentifier(current) == id else { return }
        self.current = nil
        watchdog?.cancel()
        watchdog = nil
        // `didFinish` can arrive while the last samples are still playing, and the app may be
        // suspended right after the intent returns: give the end of the word a moment. A call that
        // started meanwhile, or a `stop()` (the "Söyle" microphone), owns the session and has
        // already released this call's waiter: a newer `generation` leaves both alone.
        let ending = generation
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard let self, self.generation == ending else { return }
            WordSpeech.deactivateSession()
            self.resumeWaiter()
        }
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
