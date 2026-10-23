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
/// the recorded clip of the text in the accent and the character of "Ses ve aksan" when the app
/// has one (`recordedPlayer`), otherwise the device's own voice (offline) in that accent: the
/// voice chosen there or the best installed one of the character (premium, then enhanced, then
/// standard); the chosen speed (slower for a repeat with "Yavaş tekrar"), and a `.playback`
/// audio session that ducks other audio.
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

    /// `text` as ONE utterance with the current settings (the widget's speaker button reads a word
    /// this way). Every call counts as a hearing: the same text with the same voice and speed
    /// again within 30 seconds is read slower when "Yavaş tekrar" is on.
    static func makeUtterance(_ text: String) -> AVSpeechUtterance {
        let reading = Reading(text)
        return reading.utterance(text)
    }

    /// `text` as one utterance per sentence (`SpeechText.sentences`), each but the last with the
    /// pause that follows it (`SpeechRules.pause`), so the sentences of a card example and the two
    /// speakers of a dialogue are heard apart. One sentence, a word or a phrase: one utterance, as
    /// `makeUtterance`. Speak them in order on one synthesizer; the last one ends the reading. One
    /// hearing for "Yavaş tekrar", however many sentences.
    static func makeUtterances(_ text: String) -> [AVSpeechUtterance] {
        let reading = Reading(text)
        let sentences = SpeechText.sentences(text)
        guard sentences.count > 1 else {
            return [reading.utterance(text)]
        }
        return sentences.enumerated().map { index, sentence -> AVSpeechUtterance in
            let utterance = reading.utterance(sentence.text)
            if index < sentences.count - 1 {
                utterance.postUtteranceDelay = SpeechRules.pause(endsTurn: sentence.endsTurn, rateMultiplier: reading.rateMultiplier)
            }
            return utterance
        }
    }

    /// The voice, speed and accent of one reading, worked out once for all its utterances.
    private struct Reading {
        let voice: AVSpeechSynthesisVoice?
        let accent: SpeechAccent
        let rateMultiplier: Float

        init(_ text: String) {
            let settings = SpeechSettingsStore.current
            let voice = WordSpeech.voice(for: settings)
            let key = SpeechRepeatTracker.key(text: text, voiceIdentifier: voice?.identifier, rate: settings.rate)
            let isRepeat = WordSpeech.repeats.register(key)
            let rateMultiplier = SpeechRules.rateMultiplier(settings.rate, isRepeat: isRepeat, slowRepeat: settings.slowRepeat)
            // For the device test: which voice read, how fast (share of the default rate), and
            // whether it was a repeat.
            WordSpeech.logger.info(
                "speech voice: \(voice?.identifier ?? "none", privacy: .public), rate x: \(rateMultiplier, privacy: .public), repeat: \(isRepeat, privacy: .public)"
            )
            self.voice = voice
            self.accent = settings.accent
            self.rateMultiplier = rateMultiplier
        }

        func utterance(_ text: String) -> AVSpeechUtterance {
            let utterance = AVSpeechUtterance(attributedString: WordSpeech.spokenText(text, accent: accent))
            utterance.voice = voice
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * rateMultiplier
            return utterance
        }
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
    /// best installed one of the accent and the gender ("Ses karakteri"), otherwise the best of the
    /// accent. With no offered voice at all, the system's voice for the
    /// accent, then American English: never nil while an English voice exists (a nil voice
    /// would read with the phone's language, Turkish).
    static func voice(for settings: SpeechSettings) -> AVSpeechSynthesisVoice? {
        let snapshot = catalog.snapshot
        let pick = SpeechVoiceChoice.voice(
            chosen: settings.voiceIdentifier,
            among: snapshot.infos,
            accent: settings.accent,
            gender: settings.gender,
            systemDefault: snapshot.systemDefaults[settings.accent]
        )
        if let pick, let voice = snapshot.voices.first(where: { $0.identifier == pick.identifier }) {
            return voice
        }
        return AVSpeechSynthesisVoice(language: settings.accent.languageCode)
            ?? AVSpeechSynthesisVoice(language: SpeechAccent.american.languageCode)
    }

    /// The voices "Ses ve aksan" offers for `accent`, best first.
    static func offeredVoices(for accent: SpeechAccent) -> [SpeechVoiceInfo] {
        let snapshot = catalog.snapshot
        return SpeechVoiceChoice.offered(snapshot.infos, accent: accent, systemDefault: snapshot.systemDefaults[accent])
    }

    /// No enhanced or premium voice of `gender` is installed for `accent` ("Daha doğal ses indir").
    static func needsBetterVoice(for accent: SpeechAccent, gender: SpeechVoiceGender) -> Bool {
        return SpeechVoiceChoice.needsBetterVoice(catalog.snapshot.infos, accent: accent, gender: gender)
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
            isPersonal: voice.voiceTraits.contains(.isPersonalVoice),
            gender: gender(of: voice)
        )
    }

    private static func gender(of voice: AVSpeechSynthesisVoice) -> SpeechVoiceGender? {
        switch voice.gender {
        case .female:
            return .female
        case .male:
            return .male
        default:
            return nil
        }
    }

    private static let catalog = VoiceCatalog()
    private static let repeats = RepeatMemory()

    // MARK: Recorded clips

    /// The bundle's recorded voices (`RecordedSpeech/voices.json`); none in the widget extension
    /// and in a build without clips, where the device's voice reads everything.
    private static let recordedVoices: RecordedSpeechVoices? = {
        guard let url = Bundle.main.url(forResource: "voices", withExtension: "json", subdirectory: "RecordedSpeech"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return RecordedSpeechVoices(json: data)
    }()

    /// The app has recorded clips for `settings` (the accent and the character, no voice chosen by name).
    static func hasRecordedVoice(for settings: SpeechSettings) -> Bool {
        return recordedVoices?.voice(for: settings) != nil
    }

    /// A player for the recorded clip of `text` in the accent and the character of "Ses ve
    /// aksan", at the chosen speed (slower for a repeat with "Yavaş tekrar"), ready to play. Nil
    /// when there is no clip: the voice reads (`makeUtterances`). A call counts as a hearing, as
    /// `makeUtterances`.
    static func recordedPlayer(_ text: String) -> AVAudioPlayer? {
        let settings = SpeechSettingsStore.current
        guard let voice = recordedVoices?.voice(for: settings),
              let directory = Bundle.main.url(forResource: voice.key, withExtension: nil, subdirectory: "RecordedSpeech") else {
            return nil
        }
        let url = directory.appendingPathComponent("\(RecordedSpeechVoices.key(for: text)).\(voice.ext)")
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        let player: AVAudioPlayer
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            logger.error("recorded clip not opened: \(error.localizedDescription, privacy: .public)")
            return nil
        }
        let key = SpeechRepeatTracker.key(text: text, voiceIdentifier: "recorded.\(voice.key)", rate: settings.rate)
        let isRepeat = repeats.register(key)
        let rateMultiplier = SpeechRules.rateMultiplier(settings.rate, isRepeat: isRepeat, slowRepeat: settings.slowRepeat)
        player.enableRate = true
        player.rate = RecordedSpeechVoices.playbackRate(rateMultiplier)
        player.prepareToPlay()
        logger.info(
            "speech clip: \(voice.key, privacy: .public), rate x: \(rateMultiplier, privacy: .public), repeat: \(isRepeat, privacy: .public)"
        )
        return player
    }

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

/// The installed voices and the system's own voice for each accent, read once (`speechVoices()`
/// is slow the first time) and again after iOS reports a change or after `invalidate()`. Any
/// thread. The voices are read outside the lock: iOS may report a change while they load, and
/// `invalidate()` takes the lock; a snapshot read across an invalidation is used once, not kept.
private final class VoiceCatalog: @unchecked Sendable {
    struct Snapshot {
        let voices: [AVSpeechSynthesisVoice]
        let infos: [SpeechVoiceInfo]
        /// `AVSpeechSynthesisVoice(language:)` for each accent.
        let systemDefaults: [SpeechAccent: String]
    }

    private let lock = NSLock()
    private var cached: Snapshot?
    private var generation = 0
    private var isObserving = false

    var snapshot: Snapshot {
        startObserving()
        lock.lock()
        if let cached {
            lock.unlock()
            return cached
        }
        let started = generation
        lock.unlock()

        let voices = AVSpeechSynthesisVoice.speechVoices()
        var systemDefaults: [SpeechAccent: String] = [:]
        for accent in SpeechAccent.allCases {
            systemDefaults[accent] = AVSpeechSynthesisVoice(language: accent.languageCode)?.identifier
        }
        let snapshot = Snapshot(voices: voices, infos: voices.map(WordSpeech.info(of:)), systemDefaults: systemDefaults)

        lock.lock()
        if generation == started {
            cached = snapshot
        }
        lock.unlock()
        return snapshot
    }

    func invalidate() {
        lock.lock()
        cached = nil
        generation += 1
        lock.unlock()
    }

    private func startObserving() {
        lock.lock()
        let isFirst = !isObserving
        isObserving = true
        lock.unlock()
        guard isFirst else {
            return
        }
        _ = NotificationCenter.default.addObserver(
            forName: AVSpeechSynthesizer.availableVoicesDidChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.invalidate()
        }
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
final class WordSpeechPlayer: NSObject, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    static let shared = WordSpeechPlayer()

    private let synthesizer = AVSpeechSynthesizer()
    /// The recorded clip playing right now, if the reading is one.
    private var player: AVAudioPlayer?
    /// The utterance or the clip being read right now; kept so a stale callback can be told apart.
    private var current: ObjectIdentifier?
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
    /// was replaced, or after `timeout` seconds at the normal speed, more for a slower reading (a
    /// speech that never starts must not keep the intent running).
    func speakAndWait(_ text: String, timeout: TimeInterval = 8) async {
        let spoken = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !spoken.isEmpty else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        // A stopped clip reports nothing.
        player?.stop()
        player = nil
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
        // A recorded clip needs the app's own session; on the fallback path the voice reads.
        let recorded = appSession ? WordSpeech.recordedPlayer(spoken) : nil
        let utterance = recorded == nil ? WordSpeech.makeUtterance(spoken) : nil
        let id: ObjectIdentifier
        let limit: TimeInterval
        if let recorded {
            recorded.delegate = self
            player = recorded
            id = ObjectIdentifier(recorded)
            // The clip's own length at its speed, and a moment to start.
            limit = max(timeout, recorded.duration / Double(max(recorded.rate, 0.5)) + 2)
        } else if let utterance {
            id = ObjectIdentifier(utterance)
            // `timeout` is for the normal speed; a slow (or slow repeat) reading of a phrase may need more.
            let normalRate = AVSpeechUtteranceDefaultSpeechRate * SpeechRate.normal.defaultRateMultiplier
            limit = timeout * max(1, Double(normalRate / max(utterance.rate, 0.05)))
        } else {
            return
        }
        current = id
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            waiter = continuation
            watchdog = Task { @MainActor [weak self] in
                do {
                    try await Task.sleep(nanoseconds: UInt64(limit * 1_000_000_000))
                } catch {
                    return
                }
                self?.timedOut(id)
            }
            if let recorded {
                if !recorded.play() {
                    WordSpeech.logger.notice("recorded clip did not play")
                    end(id)
                }
            } else if let utterance {
                synthesizer.speak(utterance)
            }
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
        player?.stop()
        player = nil
        WordSpeech.deactivateSession()
        resumeWaiter()
    }

    private func timedOut(_ id: ObjectIdentifier) {
        guard current == id else { return }
        WordSpeech.logger.notice("widget speech timed out")
        synthesizer.stopSpeaking(at: .immediate)
        player?.stop()
        end(id)
    }

    /// Only the utterance or the clip started last may end the speech and release the audio session.
    private func end(_ id: ObjectIdentifier) {
        guard current == id else { return }
        current = nil
        player = nil
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

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let id = ObjectIdentifier(player)
        Task { @MainActor in
            self.end(id)
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        let id = ObjectIdentifier(player)
        Task { @MainActor in
            self.end(id)
        }
    }
}
