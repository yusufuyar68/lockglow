import Foundation
import CoreModels
import TextFold

/// An "İngilizcesini yaz" question (`ReviewPlanner.typeQuestion`): the Turkish meaning is shown and
/// the learner types the English word (docs/tasarim/ogrenme_ilkeleri.md 2.4, "Dinle ve seç, Yaz").
/// `check` compares what was typed the way a Turkish keyboard needs: case, Turkish letters (İ and
/// ı are i, `TextFold`), apostrophes, hyphens, end punctuation and extra spaces never count.
public struct TypeQuestion: Equatable, Sendable {
    /// Another card's headword, for "Senin yazdığın: lend = ödünç vermek".
    struct OtherWord: Equatable, Sendable {
        let lemma: String
        let meaning: String?
        /// Its meaning shares a part with this question's prompt ("söylemek": say and tell).
        let sameMeaning: Bool
    }

    public let wordID: Int
    /// The Turkish meaning shown ("ödünç almak").
    public let prompt: String
    /// The headword as the card writes it ("borrow", "I'd love to").
    public let answer: String
    /// Tells the word apart when another card has the same meaning: the Turkish translation of
    /// the card's example. Nil when no other card shares a meaning with it, or without one.
    public let context: String?
    /// How many letters "Bir harf göster" can give: half of the answer's letters, at least one.
    public let maxHints: Int
    /// The comparison forms that count as right: the answer, also with "to" in front of a verb
    /// ("to borrow") and with an article in front of a noun ("a spoon").
    let acceptedKeys: Set<String>
    /// Every other headword by comparison form.
    let otherWords: [String: OtherWord]

    init(
        wordID: Int,
        prompt: String,
        answer: String,
        context: String?,
        acceptedKeys: Set<String>,
        otherWords: [String: OtherWord]
    ) {
        self.wordID = wordID
        self.prompt = prompt
        self.answer = answer
        self.context = context
        self.acceptedKeys = acceptedKeys
        self.otherWords = otherWords
        let letters = TypeQuestion.countLetters(answer)
        maxHints = letters < 2 ? 0 : max(1, letters / 2)
    }

    /// How a typed answer compares with the word.
    public enum Result: Equatable, Sendable {
        /// The word itself.
        case right
        /// The word with a small spelling mistake (`typoAllowance`): counts as "Zor".
        case almost
        /// Another card's word whose meaning is the same ("tell" for "söylemek" when the card is
        /// "say"): not wrong, but not this card's word either; the learner tries again.
        case sameMeaning(String)
        /// Another card's word, with its Turkish meaning when it has one.
        case otherWord(String, meaning: String?)
        /// Anything else, an empty answer included.
        case wrong
    }

    public func check(_ typed: String) -> Result {
        let key = TypeQuestion.key(typed)
        guard !key.isEmpty else {
            return .wrong
        }
        if acceptedKeys.contains(key) {
            return .right
        }
        // A real word, even one edit away ("than" for "then"), is not a spelling mistake.
        for form in [key] + TypeQuestion.withoutLead(key) {
            if let other = otherWords[form] {
                return other.sameMeaning ? .sameMeaning(other.lemma) : .otherWord(other.lemma, meaning: other.meaning)
            }
        }
        let allowance = TypeQuestion.typoAllowance(letters: TypeQuestion.countLetters(answer))
        let typedScalars = Array(key.unicodeScalars)
        if allowance > 0, acceptedKeys.contains(where: { EditDistance.between(Array($0.unicodeScalars), typedScalars) <= allowance }) {
            return .almost
        }
        return .wrong
    }

    /// The answer with its first `letters` letters shown and every other letter as "_"; spaces,
    /// apostrophes and hyphens stay ("look after", 3 → "loo_ _____").
    public func hint(letters: Int) -> String {
        var shown = 0
        var result = ""
        for character in answer {
            if character.isLetter {
                result.append(shown < letters ? character : "_")
                shown += 1
            } else {
                result.append(character)
            }
        }
        return result
    }

    /// The answer's letters (spaces, apostrophes and hyphens left out).
    public var letterCount: Int {
        return TypeQuestion.countLetters(answer)
    }

    /// Spelling mistakes that still count as "almost": none in a word of up to three letters
    /// (one changed letter there is another word: cat, car, cut), one up to seven letters, two
    /// from eight on. A missing, extra or changed letter and two swapped neighbours are one each.
    public static func typoAllowance(letters: Int) -> Int {
        if letters <= 3 {
            return 0
        }
        return letters <= 7 ? 1 : 2
    }

    /// The comparison form: `TextFold` (Unicode NFC, Turkish letters mapped before lowercasing so
    /// İ, I and ı are all i, marks dropped, spaces collapsed), then apostrophes dropped (’ ‘ ' ` ´
    /// ʼ: "I’d" and "Id" are "id"), hyphens and dashes read as spaces ("second-hand"), and the
    /// punctuation around words dropped ("How far is it?").
    public static func key(_ text: String) -> String {
        let folded = TextFold.fold(text)
        var cleaned = ""
        for character in folded {
            if "'’‘`´ʼ".contains(character) {
                continue
            }
            if "-‐‑‒–—".contains(character) {
                cleaned.append(" ")
            } else if ".,!?;:\"“”«»()[]…".contains(character) {
                cleaned.append(" ")
            } else {
                cleaned.append(character)
            }
        }
        return cleaned.split(whereSeparator: { $0 == " " }).joined(separator: " ")
    }

    static func countLetters(_ text: String) -> Int {
        return text.filter { $0.isLetter }.count
    }

    /// `key` without a leading "to" or article: "to tell" is looked up as "tell".
    static func withoutLead(_ key: String) -> [String] {
        for lead in ["to ", "a ", "an ", "the "] where key.hasPrefix(lead) && key.count > lead.count {
            return [String(key.dropFirst(lead.count))]
        }
        return []
    }
}

extension ReviewPlanner {
    /// A typed answer is at most this long (comparison form, spaces included) and this many
    /// words: "Could you tell me the way to" is too much typing for one review.
    public static let typeMaxLength = 20
    public static let typeMaxWords = 3

    /// The "İngilizcesini yaz" question of `word`, or nil without a Turkish meaning or when the
    /// answer is longer than `typeMaxLength` or `typeMaxWords`. `candidates`: every loaded word,
    /// so that another card's word is told apart from a spelling mistake. `exampleTranslation`:
    /// the Turkish translation of the card's example, shown only when another card shares a
    /// meaning with this one.
    public static func typeQuestion(
        for word: WidgetWord,
        candidates: [WidgetWord],
        exampleTranslation: String? = nil
    ) -> TypeQuestion? {
        let prompt = (word.glossTR ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let answer = word.lemma.trimmingCharacters(in: .whitespacesAndNewlines)
        let answerKey = TypeQuestion.key(answer)
        guard !prompt.isEmpty, !answerKey.isEmpty,
              answerKey.count <= typeMaxLength,
              answerKey.split(separator: " ").count <= typeMaxWords else {
            return nil
        }
        var accepted: Set<String> = [answerKey]
        if ["v", "phv"].contains(word.pos), !answerKey.hasPrefix("to ") {
            accepted.insert("to " + answerKey)
        }
        if word.pos == "n", TypeQuestion.withoutLead(answerKey).isEmpty {
            for article in ["a ", "an ", "the "] {
                accepted.insert(article + answerKey)
            }
        }
        let promptParts = meaningParts(prompt)
        var others: [String: TypeQuestion.OtherWord] = [:]
        var sharesMeaning = false
        for candidate in candidates where candidate.id != word.id {
            let key = TypeQuestion.key(candidate.lemma)
            guard !key.isEmpty, !accepted.contains(key), others[key] == nil else {
                continue
            }
            let gloss = candidate.glossTR?.trimmingCharacters(in: .whitespacesAndNewlines)
            let meaning = (gloss?.isEmpty ?? true) ? nil : gloss
            let same = meaning.map { !meaningParts($0).isDisjoint(with: promptParts) } ?? false
            sharesMeaning = sharesMeaning || same
            others[key] = TypeQuestion.OtherWord(lemma: candidate.lemma, meaning: meaning, sameMeaning: same)
        }
        let context = exampleTranslation?.trimmingCharacters(in: .whitespacesAndNewlines)
        return TypeQuestion(
            wordID: word.id,
            prompt: prompt,
            answer: answer,
            context: sharesMeaning && !(context?.isEmpty ?? true) ? context : nil,
            acceptedKeys: accepted,
            otherWords: others
        )
    }
}
