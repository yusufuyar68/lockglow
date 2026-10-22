import Foundation

/// How "Söyle" reads an error of the iOS 17–25 speech recognizer (SFSpeechRecognizer, on the device
/// only): README "Söyle: bilinen belirsizlikler" 8, plan G1. Pure, so that the rules are tested on
/// Linux; the app passes in the error's domain and code.
///
/// Only "No speech detected" means the learner said nothing ("Seni duyamadım"). Any other error
/// means recognition did not run. On-device English recognition that is not set up (no English
/// (US) keyboard, Dictation off, its language not downloaded) fails every take even when
/// `supportsOnDeviceRecognition` is true (Apple forum 731230 and 739006: 1101, "Siri and Dictation
/// are disabled"). So after a few such takes in a row the page says how to set it up, instead of
/// asking the learner again and again to speak more clearly.
public enum RecognitionFailures {
    /// Failed takes in a row after which the set-up instructions show.
    public static let setUpHintAfter = 2

    /// False for the errors that only mean "no result": nothing was said (kAFAssistantErrorDomain
    /// 1110), or the request was cancelled (kAFAssistantErrorDomain 216, kLSRErrorDomain 301).
    /// The two cancel codes are from developer reports, not from Apple's documentation: check them
    /// in "Söyle tanılama" on the phone.
    public static func isFailure(domain: String, code: Int) -> Bool {
        switch (domain, code) {
        case ("kAFAssistantErrorDomain", 1110), ("kAFAssistantErrorDomain", 216), ("kLSRErrorDomain", 301):
            return false
        default:
            return true
        }
    }
}

/// Failed takes in a row on the iOS 17–25 path, for as long as the app runs (closing the page does
/// not reset it). A take with a transcription resets it; a take with nothing said leaves it as it is.
public struct RecognitionFailureStreak: Equatable, Sendable {
    public private(set) var count = 0

    public init() {}

    /// Recognition worked: something was heard.
    public mutating func recordHeard() {
        count = 0
    }

    /// Recognition did not run. True when the page should say how to set up on-device English
    /// recognition rather than "try again".
    public mutating func recordFailure() -> Bool {
        count += 1
        return count >= RecognitionFailures.setUpHintAfter
    }
}
