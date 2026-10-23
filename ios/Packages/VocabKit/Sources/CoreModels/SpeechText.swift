import Foundation

/// Prepares a word or a card's sentence for the speech synthesizer.
///
/// A sentence stays ONE utterance, so the voice gives it its own sentence stress, intonation and
/// pauses at the punctuation (cutting it into pieces would read every piece as a sentence of its
/// own). This only removes what makes a voice stumble mid-sentence:
/// - line breaks and runs of spaces: one space (a line without closing punctuation gets a full
///   stop, so the voice pauses there);
/// - "..." becomes "…", read as a pause rather than as dots;
/// - a score or a short range, "2-1", "3-4": "2 to 1" (a voice may say "two minus one");
/// - two quotes of a dialogue written without a space, "”“": a space, so the two speakers are
///   two sentences;
/// - Turkish names in the English sentences ("Ayşe", "Çağla", "Can"): an IPA pronunciation, since
///   an English voice reads them with English letter rules ("Can" as the verb, "Cem" as "Kem")
///   or stumbles on ç, ğ, ı, ş. The IPA uses English sounds only (no ö, ü, ı vowels).
public enum SpeechText {
    public struct Piece: Equatable, Sendable {
        public let text: String
        /// Pronunciation for the voice (`AVSpeechSynthesisIPANotationAttribute`); nil: read as
        /// written.
        public let ipa: String?

        public init(text: String, ipa: String? = nil) {
            self.text = text
            self.ipa = ipa
        }
    }

    /// `text` ready for the voice: the normalized text in pieces, the Turkish names with their
    /// IPA. A text without names is one piece.
    public static func pieces(_ text: String, accent: SpeechAccent = .american) -> [Piece] {
        let normal = normalized(text)
        var pieces: [Piece] = []
        var plain = ""
        // The last character before the current word that is not a space ("so Can paid": "o").
        var previous: Character?
        var index = normal.startIndex
        while index < normal.endIndex {
            let character = normal[index]
            guard character.isLetter else {
                plain.append(character)
                if !character.isWhitespace {
                    previous = character
                }
                index = normal.index(after: index)
                continue
            }
            var end = index
            while end < normal.endIndex && normal[end].isLetter {
                end = normal.index(after: end)
            }
            let word = String(normal[index..<end])
            if let ipa = turkishNameIPA(word, after: previous, accent: accent) {
                if !plain.isEmpty {
                    pieces.append(Piece(text: plain))
                    plain = ""
                }
                pieces.append(Piece(text: word, ipa: ipa))
            } else {
                plain += word
            }
            previous = normal[normal.index(before: end)]
            index = end
        }
        if !plain.isEmpty {
            pieces.append(Piece(text: plain))
        }
        return pieces
    }

    /// The text with the spacing, dots, ranges and dialogue quotes made regular (see the type).
    public static func normalized(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        var joined = ""
        for line in lines {
            if let last = joined.last {
                joined += closingPunctuation.contains(last) ? " " : ". "
            }
            joined += line
        }
        joined = replacing(#"[ \t\u{00A0}]+"#, in: joined, with: " ")
        joined = replacing(#"\.{3,}"#, in: joined, with: "…")
        // Only one or two digits on each side and no other number touching them: a score or a
        // short range, never a phone number, a year span, a chain ("1-2-3") or a decimal
        // ("1.5-2"). A full stop after it is the end of the sentence.
        joined = replacing(#"(?<![\d-])(?<!\d[.,:])(\d{1,2})-(\d{1,2})(?!\d|-|[.,:]\d)"#, in: joined, with: "$1 to $2")
        joined = joined.replacingOccurrences(of: "”“", with: "” “")
        return joined
    }

    /// Turkish names without a Turkish letter that an English voice misreads: "c" is /dʒ/.
    /// "Can" is a name only in the middle of a sentence (`turkishNameIPA`).
    public static let namesWithTurkishC: Set<String> = [
        "Can", "Cem", "Ece", "Ecem", "Ceren", "Cansu", "Cenk", "Cemre", "Ceyda", "Cihan", "Cemal",
        "Cengiz", "Canan", "Selcan", "Ercan", "Hacer", "Cevdet", "Tuncay",
    ]

    /// The IPA of `word` when it is a Turkish name: a capitalized word with a Turkish letter
    /// (ç, ğ, ı, İ, ö, ş, ü), or one of `namesWithTurkishC`. "Can" counts only after a letter, a
    /// digit or a comma ("so Can paid"); at the start of a sentence or a quote it is the verb
    /// ("Can you help?").
    static func turkishNameIPA(_ word: String, after previous: Character?, accent: SpeechAccent) -> String? {
        guard let first = word.first, first.isUppercase else {
            return nil
        }
        let hasTurkishLetter = word.contains { turkishLetters.contains($0) }
        guard hasTurkishLetter || namesWithTurkishC.contains(word) else {
            return nil
        }
        if word == "Can" {
            guard let previous, previous.isLetter || previous.isNumber || previous == "," else {
                return nil
            }
        }
        return transliterated(word, accent: accent)
    }

    private static let turkishLetters: Set<Character> = ["ç", "ğ", "ı", "ö", "ş", "ü", "Ç", "Ğ", "İ", "Ö", "Ş", "Ü"]

    private static let closingPunctuation: Set<Character> = [".", "?", "!", ":", ";", ",", "…", "\"", "”", "'", "’"]

    /// Turkish spelling is phonemic: letter by letter to the nearest English sounds. "ğ" is
    /// silent (it only lengthens the vowel before it).
    static func transliterated(_ word: String, accent: SpeechAccent) -> String {
        var ipa = ""
        for character in word {
            switch character {
            case "I", "ı":
                ipa += "ə"
            case "İ", "i", "î":
                ipa += "i"
            default:
                for lower in String(character).lowercased() {
                    ipa += sound(of: lower, accent: accent)
                }
            }
        }
        return ipa
    }

    private static func sound(of letter: Character, accent: SpeechAccent) -> String {
        switch letter {
        case "a", "â":
            return "ɑ"
        case "c":
            return "dʒ"
        case "ç":
            return "tʃ"
        case "e":
            return "ɛ"
        case "g":
            return "ɡ"
        case "ğ":
            return ""
        case "j":
            return "ʒ"
        case "o":
            return "oʊ"
        case "ö":
            return accent == .british ? "ɜː" : "ɝ"
        case "r":
            return "ɹ"
        case "ş":
            return "ʃ"
        case "u", "û":
            return "u"
        case "ü":
            return "ju"
        case "y":
            return "j"
        case "x":
            return "ks"
        case "q":
            return "k"
        default:
            return String(letter)
        }
    }

    private static func replacing(_ pattern: String, in text: String, with template: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return text
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: template)
    }
}
