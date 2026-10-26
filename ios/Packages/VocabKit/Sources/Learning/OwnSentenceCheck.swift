import Foundation
import CoreModels

// "Kendi cümleni yaz" (docs/ozellik_planlari/kendi_cumlen.md): the learner writes an English
// sentence with a word and gets calm, short feedback in Turkish. Two layers:
// - `OwnSentenceCheck`: fixed rules that always run (is the word there, is it English, a capital
//   letter, an end mark). Pure, so the Linux check tests it.
// - `OwnSentenceAdvice`: the on-device language model's suggestion (App/OwnSentenceAI.swift), in a
//   form without FoundationModels, so its Turkish texts and its clean-up are tested here too.
// Practice only (ogrenme_ilkeleri 3): nothing here is a review, a grade or a score. The sentence
// is never stored.

/// What the rules found in one sentence.
public struct OwnSentenceFeedback: Equatable, Sendable {
    public enum Verdict: String, Equatable, Sendable {
        /// The word is there and the sentence looks like an English sentence.
        case good
        /// Something to look at; never "wrong" (the rules cannot judge grammar).
        case caution
    }

    /// One note, in the order shown.
    public enum Issue: String, CaseIterable, Equatable, Sendable {
        case empty
        /// Fewer than `OwnSentenceCheck.minimumWords` words.
        case tooShort
        case missingWord
        /// ç, ğ, ı, ö, ş or ü: probably written in Turkish.
        case turkishLetters
        case noCapital
        case noEndPunctuation

        /// A short Turkish title (A2, calm).
        public var title: String {
            switch self {
            case .empty:
                return "Cümle yok"
            case .tooShort:
                return "Cümle çok kısa"
            case .missingWord:
                return "Kelime cümlede yok"
            case .turkishLetters:
                return "Türkçe harf var"
            case .noCapital:
                return "Büyük harfle başla"
            case .noEndPunctuation:
                return "Sonuna nokta koy"
            }
        }

        /// One or two short Turkish sentences: what to do.
        public var message: String {
            switch self {
            case .empty:
                return "Bu kelimeyle İngilizce bir cümle yaz."
            case .tooShort:
                return "En az üç kelimelik bir cümle yaz."
            case .missingWord:
                return "Yukarıdaki kelimeyi cümlende kullan."
            case .turkishLetters:
                return "Cümlede ç, ğ, ı, İ, ö, ş ya da ü var. Cümleyi İngilizce harflerle yaz."
            case .noCapital:
                return "İngilizce cümle büyük harfle başlar."
            case .noEndPunctuation:
                return "Cümlenin sonuna nokta, soru işareti ya da ünlem koy."
            }
        }
    }

    public let issues: [Issue]

    public init(issues: [Issue]) {
        self.issues = issues
    }

    public var verdict: Verdict {
        return issues.isEmpty ? .good : .caution
    }

    public var title: String {
        switch issues.count {
        case 0:
            return "Kelimeyi kullandın"
        case 1:
            return "Bir not var"
        default:
            return "Birkaç not var"
        }
    }

    public var message: String {
        if issues.isEmpty {
            return "Kelime cümlende var. Büyük harf ve sondaki işaret de yerinde."
        }
        if issues == [.empty] {
            return "Yazınca Kontrol et'e dokun."
        }
        return "Cümleni düzelt, sonra yine Kontrol et'e dokun."
    }
}

/// The fixed rules of "Kendi cümleni yaz".
public enum OwnSentenceCheck {
    /// Characters read; the field takes no more (`limited`).
    public static let maxLength = 200
    /// Words a sentence needs.
    public static let minimumWords = 3
    /// Words that may stand between the first word of a phrase and the rest ("ask her out",
    /// "pick it up").
    static let phraseGap = 3

    private static let turkishLetters: Set<Character> = ["ç", "ğ", "ı", "ö", "ş", "ü", "Ç", "Ğ", "İ", "Ö", "Ş", "Ü"]
    private static let endMarks: Set<Character> = [".", "!", "?", "…"]
    /// Closing marks that may follow the end mark ("He said "yes."").
    private static let closingMarks: Set<Character> = ["\"", "'", ")", "]", "”", "’"]
    /// Stand-in words of a phrase on the cards and the words that may take their place: "change
    /// your mind" is "I changed my mind", "lock yourself out" is "I locked myself out".
    private static let standIns: [String: Set<String>] = [
        "your": possessives,
        "one's": possessives,
        "yourself": reflexives,
        "oneself": reflexives,
    ]
    private static let possessives: Set<String> = ["my", "your", "his", "her", "its", "our", "their"]
    private static let reflexives: Set<String> = ["myself", "yourself", "himself", "herself", "itself", "ourselves", "yourselves", "themselves"]
    /// Stand-ins for any one word ("give someone a hand" is "She gave me a hand").
    private static let anyWord: Set<String> = ["someone", "somebody", "something", "sb", "sth"]

    /// `text` cut to `maxLength` characters.
    public static func limited(_ text: String) -> String {
        return text.count > maxLength ? String(text.prefix(maxLength)) : text
    }

    /// The notes for `sentence` written with `lemma`, in a fixed order: an empty sentence has
    /// that one note; a too short one gets no notes on its capital letter or end mark (a word or
    /// two is not a sentence yet).
    public static func check(_ sentence: String, lemma: String) -> OwnSentenceFeedback {
        let text = plain(limited(sentence))
        let tokens = words(of: text)
        guard !tokens.isEmpty else {
            return OwnSentenceFeedback(issues: [.empty])
        }
        var issues: [OwnSentenceFeedback.Issue] = []
        let isShort = tokens.count < minimumWords
        if isShort {
            issues.append(.tooShort)
        }
        if !contains(lemma, in: text) {
            issues.append(.missingWord)
        }
        if text.contains(where: { turkishLetters.contains($0) }) {
            issues.append(.turkishLetters)
        }
        if !isShort {
            // The first letter or digit: a sentence may start with a number ("2 cats…").
            if let first = text.first(where: { $0.isLetter || $0.isNumber }), first.isLowercase {
                issues.append(.noCapital)
            }
            if !hasEndMark(text) {
                issues.append(.noEndPunctuation)
            }
        }
        return OwnSentenceFeedback(issues: issues)
    }

    /// `lemma` occurs in `sentence`: with any ending (`LemmaMatch`), as a common irregular form
    /// ("forgot" for "forget", "teeth" for "tooth"; `TextHarvest.irregularForms`), and a phrase
    /// also with up to `phraseGap` words after its first word ("ask her out"). A phrase that
    /// starts with "be" is also found without it, and its stand-ins ("your", "yourself",
    /// "someone") take any fitting word ("change your mind": "I changed my mind"). An empty lemma
    /// is always found.
    public static func contains(_ lemma: String, in sentence: String) -> Bool {
        let text = plain(sentence)
        let target = words(of: plain(lemma))
        guard !target.isEmpty else {
            return true
        }
        if LemmaMatch.range(of: target.joined(separator: " "), in: text) != nil {
            return true
        }
        let tokens = words(of: text)
        if matches(target, in: tokens) {
            return true
        }
        if target.count > 1 && target[0] == "be" {
            return matches(Array(target.dropFirst()), in: tokens)
        }
        return false
    }

    // MARK: Text

    /// Typographic quotes made plain (the keyboard's smart punctuation), runs of white space and
    /// line breaks made one space, trimmed.
    static func plain(_ text: String) -> String {
        var result = ""
        var pendingSpace = false
        for character in text {
            if character.isWhitespace || character.isNewline {
                pendingSpace = !result.isEmpty
                continue
            }
            if pendingSpace {
                result.append(" ")
                pendingSpace = false
            }
            switch character {
            case "’", "‘", "ʼ":
                result.append("'")
            case "“", "”":
                result.append("\"")
            default:
                result.append(character)
            }
        }
        return result
    }

    /// The words of `text`, lowercased: runs of letters, digits and inner apostrophes ("can't").
    static func words(of text: String) -> [String] {
        var result: [String] = []
        var current = ""
        func flush() {
            let word = current.trimmingCharacters(in: CharacterSet(charactersIn: "'"))
            if !word.isEmpty {
                result.append(word.lowercased())
            }
            current = ""
        }
        for character in text {
            if character.isLetter || character.isNumber || character == "'" || character == "’" {
                current.append(character == "’" ? "'" : character)
            } else {
                flush()
            }
        }
        flush()
        return result
    }

    private static func hasEndMark(_ text: String) -> Bool {
        var trimmed = Substring(text)
        while let last = trimmed.last, closingMarks.contains(last) || last.isWhitespace {
            trimmed = trimmed.dropLast()
        }
        guard let last = trimmed.last else {
            return false
        }
        return endMarks.contains(last)
    }

    // MARK: Word match

    /// `token` is `word` with any ending, or one of its common irregular forms; in a phrase, a
    /// stand-in `word` also takes the words that may replace it (`standIns`, `anyWord`).
    private static func token(_ token: String, matches word: String, inPhrase: Bool) -> Bool {
        if inPhrase {
            if anyWord.contains(word) {
                return true
            }
            if let forms = standIns[word], forms.contains(token) {
                return true
            }
        }
        if token.hasPrefix(word) {
            return true
        }
        return TextHarvest.irregularForms[token]?.contains(word) == true
    }

    /// Every word of `target` in a row in `tokens`, or (for a phrase) its first word, at most
    /// `phraseGap` other words, then the rest in a row.
    private static func matches(_ target: [String], in tokens: [String]) -> Bool {
        guard let first = target.first else {
            return true
        }
        let rest = Array(target.dropFirst())
        let inPhrase = !rest.isEmpty
        for start in tokens.indices where token(tokens[start], matches: first, inPhrase: inPhrase) {
            if rest.isEmpty {
                return true
            }
            let earliest = start + 1
            let latest = min(start + 1 + phraseGap, tokens.count - rest.count)
            guard earliest <= latest else {
                continue
            }
            for restStart in earliest...latest {
                let inRow = rest.indices.allSatisfy { offset in
                    token(tokens[restStart + offset], matches: rest[offset], inPhrase: true)
                }
                if inRow {
                    return true
                }
            }
        }
        return false
    }
}

/// The on-device model's suggestion on a sentence (App/OwnSentenceAI.swift), cleaned up: a
/// "correction" that only changes letter case or punctuation is dropped (the rules already say
/// that), so is anything that is not plain English text or is too long. Shown as a suggestion
/// ("Öneri · cihazda"), never as a verdict, never counted.
public struct OwnSentenceAdvice: Equatable, Sendable {
    public enum Kind: String, CaseIterable, Equatable, Sendable {
        /// The word is used with the card's meaning and the sentence is fine.
        case fine
        /// The word is used with another meaning than the card's.
        case wordMeaning
        case grammar
        /// The word needs another form (-s, -ed, -ing, a plural).
        case wordForm
        case spelling
        /// Understandable, but a native speaker would say it another way.
        case unnatural
    }

    /// Characters of a suggested sentence, at most; a longer one is dropped, never cut.
    public static let maxLength = 200

    public let kind: Kind
    /// The learner's sentence with its mistakes fixed (English); nil when there is none.
    public let correctedSentence: String?
    /// A more natural way to say the same thing (English); nil when there is none.
    public let naturalAlternative: String?

    /// `original` is the learner's sentence and `lemma` the word it was written with: a
    /// suggestion that only differs from the sentence in case or punctuation is dropped, and so
    /// is an alternative that repeats the correction, and any suggestion without the word (the
    /// learner's idea is kept). A "fine" sentence keeps no correction. A grammar, form or spelling
    /// note whose only correction was case or punctuation becomes "fine": the rules already say
    /// that, and a mistake note with nothing to look at would only worry.
    public init(kind: Kind, correctedSentence: String?, naturalAlternative: String?, original: String, lemma: String) {
        let originalKey = OwnSentenceAdvice.key(original)
        var resolvedKind = kind
        var corrected = OwnSentenceAdvice.cleaned(correctedSentence)
        if kind == .fine {
            corrected = nil
        }
        if let text = corrected, OwnSentenceAdvice.key(text) == originalKey {
            corrected = nil
            if kind == .grammar || kind == .wordForm || kind == .spelling {
                resolvedKind = .fine
            }
        }
        if let text = corrected, !OwnSentenceCheck.contains(lemma, in: text) {
            corrected = nil
        }
        var alternative = OwnSentenceAdvice.cleaned(naturalAlternative)
        if let text = alternative {
            let textKey = OwnSentenceAdvice.key(text)
            if textKey == originalKey || corrected.map(OwnSentenceAdvice.key) == textKey
                || !OwnSentenceCheck.contains(lemma, in: text) {
                alternative = nil
            }
        }
        self.kind = resolvedKind
        self.correctedSentence = corrected
        self.naturalAlternative = alternative
    }

    public var title: String {
        return OwnSentenceAdvice.title(for: kind)
    }

    public var message: String {
        return OwnSentenceAdvice.message(for: kind)
    }

    /// A short Turkish title per kind. Hedged: the model can be wrong.
    public static func title(for kind: Kind) -> String {
        switch kind {
        case .fine:
            return "İyi görünüyor"
        case .wordMeaning:
            return "Anlam farklı olabilir"
        case .grammar:
            return "Dilbilgisine bak"
        case .wordForm:
            return "Kelimenin biçimine bak"
        case .spelling:
            return "Yazımına bak"
        case .unnatural:
            return "Daha doğal söylenebilir"
        }
    }

    /// One or two short Turkish sentences per kind; they stand without a suggested sentence.
    public static func message(for kind: Kind) -> String {
        switch kind {
        case .fine:
            return "Kelimeyi yukarıdaki anlamda kullanmışsın. Cümle de anlaşılır."
        case .wordMeaning:
            return "Kelimeyi burada başka bir anlamda kullanmış olabilirsin. Yukarıdaki anlama bir daha bak."
        case .grammar:
            return "Cümlenin dilbilgisine bir daha bak."
        case .wordForm:
            return "Kelimeye -s, -ed ya da -ing gibi bir ek gerekebilir."
        case .spelling:
            return "Bir kelime farklı yazılıyor olabilir."
        case .unnatural:
            return "Cümle anlaşılıyor. İngilizcede daha doğal bir söyleyiş var."
        }
    }

    // MARK: Clean-up

    /// Answers a model writes instead of leaving a field empty.
    private static let emptyAnswers: Set<String> = ["none", "n a", "na", "null", "nil", "empty", "no correction", "no change"]

    /// `text` trimmed, its typographic quotes, dashes and ellipsis made plain and its outer
    /// quotes removed; nil when it is empty, longer than `maxLength`, has fewer than two words, a
    /// character outside printable ASCII (not English, or junk) or is a stand-in for nothing.
    static func cleaned(_ text: String?) -> String? {
        guard let text else {
            return nil
        }
        var plain = OwnSentenceCheck.plain(text)
            .replacingOccurrences(of: "—", with: "-")
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "…", with: "...")
        while plain.count >= 2, let first = plain.first, first == "\"" || first == "'", plain.last == first {
            plain = String(plain.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
        }
        guard !plain.isEmpty, plain.count <= maxLength else {
            return nil
        }
        guard plain.unicodeScalars.allSatisfy({ $0.value >= 0x20 && $0.value <= 0x7E }) else {
            return nil
        }
        let words = OwnSentenceCheck.words(of: plain)
        guard words.count >= 2, !emptyAnswers.contains(words.joined(separator: " ")) else {
            return nil
        }
        return plain
    }

    /// The words of `text` without case or punctuation: two sentences with the same key differ
    /// only in those.
    static func key(_ text: String) -> String {
        return OwnSentenceCheck.words(of: OwnSentenceCheck.plain(text)).joined(separator: " ")
    }
}
