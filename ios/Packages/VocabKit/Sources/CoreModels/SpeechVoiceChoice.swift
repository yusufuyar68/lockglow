import Foundation

/// An installed voice as `AVSpeechSynthesisVoice` describes it, without AVFoundation, so the
/// choice below is tested on Linux.
public struct SpeechVoiceInfo: Equatable, Sendable {
    /// `AVSpeechSynthesisVoiceQuality`: 1 default (compact), 2 enhanced, 3 premium.
    public enum Quality: Int, Comparable, Sendable {
        case standard = 1
        case enhanced = 2
        case premium = 3

        /// An unknown raw value (a future quality) counts as standard.
        public init(rawQuality: Int) {
            self = Quality(rawValue: rawQuality) ?? .standard
        }

        public static func < (lhs: Quality, rhs: Quality) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    public let identifier: String
    public let name: String
    /// "en-US", "en-GB".
    public let language: String
    public let quality: Quality
    /// `voiceTraits.isNoveltyVoice` (Bells, Bubbles...).
    public let isNovelty: Bool
    /// `voiceTraits.isPersonalVoice` (needs its own permission; never ours to use).
    public let isPersonal: Bool

    public init(identifier: String, name: String, language: String, quality: Quality, isNovelty: Bool = false, isPersonal: Bool = false) {
        self.identifier = identifier
        self.name = name
        self.language = language
        self.quality = quality
        self.isNovelty = isNovelty
        self.isPersonal = isPersonal
    }

    /// The name without a quality in brackets ("Ava (Premium)" → "Ava"): the quality is shown on
    /// its own, in Turkish.
    public var displayName: String {
        guard name.hasSuffix(")"), let open = name.lastIndex(of: "(") else {
            return name
        }
        let bare = name[..<open].trimmingCharacters(in: .whitespaces)
        return bare.isEmpty ? name : bare
    }

    /// A voice a learner should hear: no novelty or personal voice, and none of the old
    /// formant voices (Eloquence: Eddy, Flo, Reed...; MacinTalk: Fred, Albert...), which are
    /// robotic and do not show how a word sounds.
    public var isLearnerVoice: Bool {
        return !isNovelty
            && !isPersonal
            && !identifier.hasPrefix("com.apple.eloquence.")
            && !identifier.hasPrefix("com.apple.speech.synthesis.voice.")
    }
}

/// Which voice reads: premium first, then enhanced, then the standard (compact) voices.
public enum SpeechVoiceChoice {
    /// The voices offered for `accent`, best first: by quality, then the system's own voice for
    /// the language (`systemDefault`, `AVSpeechSynthesisVoice(language:)`), then by name.
    public static func offered(_ voices: [SpeechVoiceInfo], accent: SpeechAccent, systemDefault: String? = nil) -> [SpeechVoiceInfo] {
        let usable = voices.filter { $0.language == accent.languageCode && $0.isLearnerVoice }
        return usable.sorted { lhs, rhs in
            if lhs.quality != rhs.quality {
                return lhs.quality > rhs.quality
            }
            let lhsDefault = lhs.identifier == systemDefault
            let rhsDefault = rhs.identifier == systemDefault
            if lhsDefault != rhsDefault {
                return lhsDefault
            }
            let lhsName = lhs.name.lowercased()
            let rhsName = rhs.name.lowercased()
            if lhsName != rhsName {
                return lhsName < rhsName
            }
            return lhs.identifier < rhs.identifier
        }
    }

    /// The voice that reads: the chosen one while it is installed and offered for the accent,
    /// otherwise the best offered one. Nil when the accent has no offered voice at all.
    public static func voice(chosen: String?, among voices: [SpeechVoiceInfo], accent: SpeechAccent, systemDefault: String? = nil) -> SpeechVoiceInfo? {
        let ranked = offered(voices, accent: accent, systemDefault: systemDefault)
        if let chosen, let match = ranked.first(where: { $0.identifier == chosen }) {
            return match
        }
        return ranked.first
    }

    /// True while the accent has no enhanced or premium voice: "Ses ve aksan" then shows how to
    /// download a more natural one.
    public static func needsBetterVoice(_ voices: [SpeechVoiceInfo], accent: SpeechAccent) -> Bool {
        return !offered(voices, accent: accent).contains { $0.quality >= .enhanced }
    }
}
