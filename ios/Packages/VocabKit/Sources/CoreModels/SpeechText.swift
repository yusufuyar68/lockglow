import Foundation

/// Prepares a word or a card's sentence for the speech synthesizer.
///
/// A sentence stays ONE utterance, so the voice gives it its own sentence stress, intonation and
/// pauses at the punctuation (cutting it into pieces would read every piece as a sentence of its
/// own). A text of several sentences, often a dialogue ("“Is it far?” “No, ten minutes.”"), is
/// read one sentence at a time with a pause between (`sentences`, `SpeechRules.pause`): longer
/// between the two speakers, longer still at a slow speed. Inside a sentence this only removes
/// what makes a voice stumble:
/// - line breaks and runs of spaces: one space (a line without closing punctuation gets a full
///   stop, so the voice pauses there);
/// - "..." becomes "…", read as a pause rather than as dots;
/// - a score or a short range, "2-1", "3-4": "2 to 1" (a voice may say "two minus one");
/// - two quotes of a dialogue written without a space, "”“": a space, so the two speakers are
///   two sentences;
/// - Turkish names in the English sentences ("Ayşe", "Çağla", "Can"): an IPA pronunciation, since
///   an English voice reads them with English letter rules ("Can" as the verb, "Cem" as "Kem")
///   or stumbles on ç, ğ, ı, ş. The IPA uses the accent's own English sounds (no ö, ü, ı vowels):
///   "Ayşe" is "aɪʃɛ" for an American voice, "aɪʃe" for a British one.
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

    /// One sentence of a text and the pause it needs after it.
    public struct Sentence: Equatable, Sendable {
        public let text: String
        /// The sentence closes a quote or the next one opens one: the other speaker of a dialogue
        /// talks next.
        public let endsTurn: Bool

        public init(text: String, endsTurn: Bool = false) {
            self.text = text
            self.endsTurn = endsTurn
        }
    }

    /// The normalized text cut after ".", "?", "!" or "…" (and a closing quote) where a space and
    /// a new sentence follow (a capital, a digit or an opening quote). Not after a title or an
    /// initial ("Dr. Kaya", "Mr. Chen", "J. Smith"), nor inside a sentence ("3 a.m. because").
    /// A text of one sentence is one item; an empty text none.
    public static func sentences(_ text: String) -> [Sentence] {
        let characters = Array(normalized(text))
        var result: [Sentence] = []
        var current = ""
        var index = 0
        while index < characters.count {
            let character = characters[index]
            current.append(character)
            index += 1
            guard sentenceEnds.contains(character) else {
                continue
            }
            while index < characters.count && closingQuotes.contains(characters[index]) {
                current.append(characters[index])
                index += 1
            }
            guard index + 1 < characters.count,
                  characters[index] == " ",
                  startsSentence(characters[index + 1]),
                  !(character == "." && endsWithAbbreviation(current)) else {
                continue
            }
            let closesQuote = current.last.map { closingQuotes.contains($0) && $0 != ")" } ?? false
            let endsTurn = closesQuote || openingQuotes.contains(characters[index + 1])
            result.append(Sentence(text: current, endsTurn: endsTurn))
            current = ""
            // The space between the sentences.
            index += 1
        }
        if !current.isEmpty {
            result.append(Sentence(text: current))
        }
        return result
    }

    private static let sentenceEnds: Set<Character> = [".", "?", "!", "…"]
    private static let closingQuotes: Set<Character> = ["”", "\"", "’", ")"]
    private static let openingQuotes: Set<Character> = ["“", "\"", "‘", "("]
    /// Words with a full stop that do not end a sentence before a name (lowercase, no stop).
    private static let titles: Set<String> = ["dr", "mr", "mrs", "ms", "st", "prof", "mt", "jr", "sr", "vs"]

    private static func startsSentence(_ character: Character) -> Bool {
        return character.isUppercase || character.isNumber || openingQuotes.contains(character)
    }

    /// `text` (ending with its full stop) ends with "Dr.", "Mr." or a one-letter initial ("J.").
    private static func endsWithAbbreviation(_ text: String) -> Bool {
        let word = String(text.dropLast().reversed().prefix { $0.isLetter }.reversed())
        if word.count == 1 {
            return word.first?.isUppercase == true
        }
        return titles.contains(word.lowercased())
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
        // ICU writes a no-break space as \x{00A0} (Swift's \u{00A0} is no regex escape).
        joined = replacing(#"[ \t\x{00A0}]+"#, in: joined, with: " ")
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

    /// Turkish spelling is phonemic: letter by letter to the nearest English sounds of the accent.
    /// "ay", "ey", "oy" before a consonant are one diphthong ("Ayşe": aɪ); "ğ" is silent (it only
    /// lengthens the vowel before it); "ü" is "ju" ("Gül"), only "u" right after a "y" ("Büyükada").
    static func transliterated(_ word: String, accent: SpeechAccent) -> String {
        var letters: [Character] = []
        for character in word {
            switch character {
            case "I":
                letters.append("ı")
            case "İ":
                letters.append("i")
            default:
                letters.append(contentsOf: String(character).lowercased())
            }
        }
        var ipa = ""
        var index = 0
        while index < letters.count {
            let letter = letters[index]
            let next: Character? = index + 1 < letters.count ? letters[index + 1] : nil
            let afterNext: Character? = index + 2 < letters.count ? letters[index + 2] : nil
            let vowelFollows = afterNext.map { vowels.contains($0) } ?? false
            if next == "y", let diphthong = diphthongs[letter], !vowelFollows {
                ipa += diphthong
                index += 2
                continue
            }
            let previous: Character? = index > 0 ? letters[index - 1] : nil
            ipa += sound(of: letter, after: previous, accent: accent)
            index += 1
        }
        return ipa
    }

    private static let vowels: Set<Character> = ["a", "e", "ı", "i", "o", "ö", "u", "ü", "â", "î", "û"]
    private static let diphthongs: [Character: String] = ["a": "aɪ", "e": "eɪ", "o": "ɔɪ"]

    private static func sound(of letter: Character, after previous: Character?, accent: SpeechAccent) -> String {
        let british = accent == .british
        switch letter {
        case "a", "â":
            return british ? "æ" : "ɑ"
        case "c":
            return "dʒ"
        case "ç":
            return "tʃ"
        case "e":
            return british ? "e" : "ɛ"
        case "g":
            return "ɡ"
        case "ğ":
            return ""
        case "ı":
            return "ə"
        case "i", "î":
            return british ? "iː" : "i"
        case "j":
            return "ʒ"
        case "o":
            return british ? "ɒ" : "oʊ"
        case "ö":
            return british ? "ɜː" : "ɝ"
        case "r":
            return "ɹ"
        case "ş":
            return "ʃ"
        case "u", "û":
            return british ? "uː" : "u"
        case "ü":
            let vowel = british ? "uː" : "u"
            return previous == "y" ? vowel : "j" + vowel
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
            assertionFailure("invalid pattern \(pattern)")
            return text
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: template)
    }
}
