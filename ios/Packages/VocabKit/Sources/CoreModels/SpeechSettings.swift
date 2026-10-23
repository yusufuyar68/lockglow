import Foundation

/// The English accent Lockglow reads aloud, listens for in "Söyle" and writes the IPA in. Chosen
/// in "Ayarlar", "Ses ve aksan"; stored in the App Group so the widget shows the same IPA.
public enum SpeechAccent: String, CaseIterable, Codable, Sendable {
    /// General American: the content's main accent (`ipa_us`).
    case american = "us"
    /// Southern British (`ipa_uk`).
    case british = "uk"

    /// BCP 47 tag of the voices (`AVSpeechSynthesisVoice.language`) and of the speech
    /// recognizer: "en-US", "en-GB".
    public var languageCode: String {
        switch self {
        case .american:
            return "en-US"
        case .british:
            return "en-GB"
        }
    }
}

/// How fast "Dinle" reads.
public enum SpeechRate: String, CaseIterable, Codable, Sendable {
    case slow
    case normal
    case fast

    /// Multiplier of the system's default speech rate (`AVSpeechUtteranceDefaultSpeechRate`,
    /// 0.5). Normal keeps the 0.9 the app has read with since the first build (a little slower
    /// than the default for an A2 learner); fast is the system's default, a natural pace; slow is
    /// clearly slower but still connected speech. Not heard on a device yet.
    public var defaultRateMultiplier: Float {
        switch self {
        case .slow:
            return 0.76
        case .normal:
            return 0.9
        case .fast:
            return 1.0
        }
    }
}

/// The settings of "Ses ve aksan". The app writes them; the app's speech (the widget's speaker
/// button too, which runs in the app) and the widget's IPA read them from the App Group's
/// UserDefaults. Unknown or missing values read as the defaults: American, normal speed, slow
/// repeat on, the best installed voice.
public struct SpeechSettings: Equatable, Sendable {
    public var accent: SpeechAccent
    public var rate: SpeechRate
    /// "Yavaş tekrar": hearing the same text again right away reads it slower
    /// (`SpeechRules.rateMultiplier`).
    public var slowRepeat: Bool
    /// The voice chosen for each accent (`AVSpeechSynthesisVoice.identifier`). None: the best
    /// installed voice of the accent (`SpeechVoiceChoice`).
    public var voiceIdentifiers: [SpeechAccent: String]

    public static let standard = SpeechSettings(accent: .american, rate: .normal, slowRepeat: true, voiceIdentifiers: [:])

    public init(accent: SpeechAccent, rate: SpeechRate, slowRepeat: Bool, voiceIdentifiers: [SpeechAccent: String]) {
        self.accent = accent
        self.rate = rate
        self.slowRepeat = slowRepeat
        self.voiceIdentifiers = voiceIdentifiers
    }

    /// The voice chosen for the current accent; nil for the best installed one.
    public var voiceIdentifier: String? {
        return voiceIdentifiers[accent]
    }

    /// UserDefaults keys. SwiftUI's `@AppStorage` reads and writes the same keys (the raw values
    /// of the enums, a Bool for the slow repeat).
    public enum Key {
        public static let accent = "lockglow.speech.accent"
        public static let rate = "lockglow.speech.rate"
        public static let slowRepeat = "lockglow.speech.slowRepeat"

        public static func voice(_ accent: SpeechAccent) -> String {
            return "lockglow.speech.voice.\(accent.rawValue)"
        }
    }

    public init(defaults: UserDefaults) {
        let standard = SpeechSettings.standard
        accent = defaults.string(forKey: Key.accent).flatMap(SpeechAccent.init(rawValue:)) ?? standard.accent
        rate = defaults.string(forKey: Key.rate).flatMap(SpeechRate.init(rawValue:)) ?? standard.rate
        // `bool(forKey:)` also reads a launch argument ("NO"), which arrives as text.
        slowRepeat = defaults.object(forKey: Key.slowRepeat) == nil ? standard.slowRepeat : defaults.bool(forKey: Key.slowRepeat)
        var voices: [SpeechAccent: String] = [:]
        for accent in SpeechAccent.allCases {
            if let identifier = defaults.string(forKey: Key.voice(accent)), !identifier.isEmpty {
                voices[accent] = identifier
            }
        }
        voiceIdentifiers = voices
    }

    public func save(to defaults: UserDefaults) {
        defaults.set(accent.rawValue, forKey: Key.accent)
        defaults.set(rate.rawValue, forKey: Key.rate)
        defaults.set(slowRepeat, forKey: Key.slowRepeat)
        for accent in SpeechAccent.allCases {
            if let identifier = voiceIdentifiers[accent] {
                defaults.set(identifier, forKey: Key.voice(accent))
            } else {
                defaults.removeObject(forKey: Key.voice(accent))
            }
        }
    }
}

/// The speed rules of "Dinle".
public enum SpeechRules {
    /// "Yavaş tekrar": a repeat is read at this share of the chosen speed...
    public static let repeatSlowdown: Float = 0.8
    /// ...but never slower than this share of the default rate (slower sounds broken, not clearer).
    public static let slowestMultiplier: Float = 0.6
    /// A start of the same text with the same voice and speed within this many seconds of the
    /// previous start is a repeat. Long enough for a sentence and a second tap, short enough that
    /// coming back to a card later is a first hearing again.
    public static let repeatWindow: TimeInterval = 30

    /// Multiplier of the default rate for one reading: the chosen speed, slower for a repeat when
    /// "Yavaş tekrar" is on.
    public static func rateMultiplier(_ rate: SpeechRate, isRepeat: Bool, slowRepeat: Bool) -> Float {
        let chosen = rate.defaultRateMultiplier
        guard isRepeat && slowRepeat else {
            return chosen
        }
        return max(slowestMultiplier, chosen * repeatSlowdown)
    }

    /// Pause after a sentence when a text is read one sentence at a time (`SpeechText.sentences`),
    /// on top of the voice's own: 0.25 s between sentences, 0.45 s between the two speakers of a
    /// dialogue, at the normal speed; longer as the reading gets slower, so a slow reading keeps
    /// its rhythm. Not heard on a device yet.
    public static func pause(endsTurn: Bool, rateMultiplier: Float) -> TimeInterval {
        let base: TimeInterval = endsTurn ? 0.45 : 0.25
        let slowdown = Double(SpeechRate.normal.defaultRateMultiplier / max(rateMultiplier, 0.1))
        return base * slowdown
    }
}

/// Remembers the last reading, to tell a second hearing ("Yavaş tekrar"). The key is the text
/// with the voice and speed it was read with: picking another voice or speed and hearing the same
/// sample is a first hearing of that voice, not a repeat.
public struct SpeechRepeatTracker: Sendable {
    private var lastKey: String?
    private var lastStart: Date?

    public init() {}

    public static func key(text: String, voiceIdentifier: String?, rate: SpeechRate) -> String {
        return "\(rate.rawValue)|\(voiceIdentifier ?? "-")|\(text)"
    }

    /// Records a start; true when the same key started less than `SpeechRules.repeatWindow`
    /// seconds before. Every start renews the window, so a third tap is slow too.
    public mutating func register(_ key: String, at now: Date) -> Bool {
        defer {
            lastKey = key
            lastStart = now
        }
        guard let lastKey, let lastStart, lastKey == key else {
            return false
        }
        let elapsed = now.timeIntervalSince(lastStart)
        return elapsed >= 0 && elapsed < SpeechRules.repeatWindow
    }
}

extension WidgetWord {
    /// The IPA in `accent`: `ipa_uk` for British, `ipa_us` for American. When a card has only
    /// one (the widget's seed words have no `ipa_uk`), that one is shown rather than nothing.
    public func ipa(for accent: SpeechAccent) -> String? {
        switch accent {
        case .american:
            return ipaUS ?? ipaUK
        case .british:
            return ipaUK ?? ipaUS
        }
    }
}
