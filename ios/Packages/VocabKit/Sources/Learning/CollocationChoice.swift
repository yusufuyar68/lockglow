import Foundation

/// "Hangisi birlikte kullanılır?": the verb of a fixed pair ("make a mistake", "do the dishes",
/// "say sorry", "tell the truth") left out of an example sentence or of a card's collocation, with
/// the other verb of the pair as the second option ("made" / "did"). Turkish often has one verb
/// for both ("hata yapmak", "ödev yapmak"; "doğruyu söylemek", "yalan söylemek"), so these pairs
/// are a typical mix-up (ogrenme_ilkeleri 1 item 7). Not always: "make friends" is "arkadaş
/// edinmek", "tell a story" "hikâye anlatmak"; `sharesTurkishVerb` says when the comparison holds.
///
/// Only listed partners count. A verb is left out when a word that goes with it, and not with the
/// other verb, follows it, with at most a few small words between ("made a big mistake", "told us
/// a funny story"). Words that take both verbs ("do a puzzle" / "make a puzzle", "do a deal" /
/// "make a deal", "do lunch" / "make lunch") are not on the lists, and neither are words that are
/// often the first half of a longer noun ("a cooking course", "a washing machine"): the other
/// option must be wrong.
///
/// Folded keys (`TextFold.fold`, ’ read as ') are compared; the options keep the sentence's
/// capital ("Make sure…" → "Make" / "Do").
public struct CollocationChoice: Equatable, Sendable {
    public enum Pair: String, Sendable {
        /// make / do: Turkish "yapmak" for both with many partners.
        case makeDo
        /// say / tell: Turkish "söylemek" for both with a few partners.
        case sayTell
    }

    public let pair: Pair
    /// The text before the blank exactly as written, its space included ("Sorry, I "); empty
    /// when the blank comes first.
    public let before: String
    /// The text after the blank exactly as written (" a mistake.").
    public let after: String
    /// The left-out verb as written ("made", "Make").
    public let answer: String
    /// The other verb of the pair in the same form and case ("did", "Do").
    public let distractor: String
    /// The pair in its plain form, for the feedback: "make a big mistake", "tell us a funny story".
    public let phrase: String
    /// The partner word, folded ("mistake").
    public let partner: String

    public init(pair: Pair, before: String, after: String, answer: String, distractor: String, phrase: String, partner: String) {
        self.pair = pair
        self.before = before
        self.after = after
        self.answer = answer
        self.distractor = distractor
        self.phrase = phrase
        self.partner = partner
    }

    /// Turkish says this pair with "yapmak" (make / do) or "söylemek" (say / tell), as it would
    /// say the other verb: "hata yapmak", "ödev yapmak", "yalan söylemek". Only then may the
    /// feedback say why the two are easy to mix up; "make friends" (arkadaş edinmek) or "tell a
    /// story" (hikâye anlatmak) would teach a wrong comparison.
    public var sharesTurkishVerb: Bool {
        return CollocationChoice.oneTurkishVerb.contains(partner)
    }

    /// The answer and the distractor in a mixed order: the same seed and attempt give the same
    /// order, and over two attempts in a row the answer sits once in each place.
    public func options(seed: Int, attempt: Int = 0) -> [String] {
        var generator = PracticeRandom(seed: seed)
        let answerFirst = (generator.next(below: 2) + attempt) % 2 == 0
        return answerFirst ? [answer, distractor] : [distractor, answer]
    }

    /// The whole text with the answer in the blank: the sentence as written.
    public var filled: String {
        return before + answer + after
    }

    /// The first listed pair in `text` (an example sentence, or a collocation when `verbFirst`:
    /// then the verb must be its first word, and a phrase with a placeholder such as "sb" or
    /// "something" is not used). Nil when there is none.
    public static func find(in text: String, verbFirst: Bool = false) -> CollocationChoice? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = trimmed.split(whereSeparator: { $0.isWhitespace })
        let cores = words.map { core(of: $0) }
        let keys = cores.map { SentenceTiles.key($0.text) }
        let isQuestion = trimmed.hasSuffix("?")
        if verbFirst && keys.contains(where: { placeholders.contains($0) }) {
            return nil
        }
        let starts = verbFirst ? Array(keys.indices.prefix(1)) : Array(keys.indices)
        for index in starts {
            guard let verb = verbs[keys[index]], cores[index].isBare else {
                continue
            }
            // "Did the shopping take long?": "did" asks, it is not "do the shopping".
            if isQuestion && auxiliaries.contains(keys[index])
                && (index == 0 || questionWords.contains(keys[index - 1])) {
                continue
            }
            guard let partner = partnerPlace(after: index, verb: verb.lemma, keys: keys, cores: cores),
                  let other = byLemma[verb.otherLemma],
                  let otherForm = other.forms[form(of: keys[index], verb: verb, keys: keys, at: index)] else {
                continue
            }
            let written = cores[index].text
            // The verb's own letters, without the punctuation before it ("“Make").
            let word = words[index]
            let start = word.index(word.startIndex, offsetBy: cores[index].leading.count)
            let end = word.index(start, offsetBy: written.count)
            // "make fun" goes on as "make fun of".
            var last = partner
            if let tail = partnerTails[keys[partner]], partner + 1 < keys.count, keys[partner + 1] == tail,
               cores[partner].isBare {
                last = partner + 1
            }
            let phrase = [verb.lemma] + cores[(index + 1)...last].map { $0.text == "I" ? "I" : $0.text.lowercased() }
            return CollocationChoice(
                pair: verb.pair,
                before: String(trimmed[..<start]),
                after: String(trimmed[end...]),
                answer: written,
                distractor: written.first?.isUppercase == true ? capitalized(otherForm) : otherForm,
                phrase: phrase.joined(separator: " "),
                partner: keys[partner]
            )
        }
        return nil
    }

    // MARK: Lists

    enum Form: Hashable {
        case base
        case third
        case past
        case participle
        case ing
    }

    struct Verb {
        let lemma: String
        let otherLemma: String
        let pair: Pair
        let forms: [Form: String]
    }

    private static let make = Verb(lemma: "make", otherLemma: "do", pair: .makeDo, forms: [
        .base: "make", .third: "makes", .past: "made", .participle: "made", .ing: "making",
    ])
    private static let doVerb = Verb(lemma: "do", otherLemma: "make", pair: .makeDo, forms: [
        .base: "do", .third: "does", .past: "did", .participle: "done", .ing: "doing",
    ])
    private static let say = Verb(lemma: "say", otherLemma: "tell", pair: .sayTell, forms: [
        .base: "say", .third: "says", .past: "said", .participle: "said", .ing: "saying",
    ])
    private static let tell = Verb(lemma: "tell", otherLemma: "say", pair: .sayTell, forms: [
        .base: "tell", .third: "tells", .past: "told", .participle: "told", .ing: "telling",
    ])

    /// Every written form of the four verbs → its verb.
    static let verbs: [String: Verb] = {
        var result: [String: Verb] = [:]
        for verb in [make, doVerb, say, tell] {
            for form in verb.forms.values {
                result[form] = verb
            }
        }
        return result
    }()

    private static let byLemma: [String: Verb] = [
        "make": make, "do": doVerb, "say": say, "tell": tell,
    ]

    /// Words that go with one verb of the pair only.
    static let partners: [String: Set<String>] = [
        "make": [
            "mistake", "mistakes", "decision", "decisions", "appointment", "appointments",
            "reservation", "reservations", "mess", "money", "friends", "progress", "promise",
            "promises", "excuse", "excuses", "noise", "effort", "choice", "choices", "suggestion",
            "suggestions", "complaint", "complaints", "sure", "fun", "announcement", "difference",
            "plan", "plans", "sense",
        ],
        "do": [
            "homework", "housework", "dishes", "laundry", "shopping", "exercise", "chores",
            "gardening", "sightseeing", "best", "business", "favour", "favor", "research",
            "overtime", "damage", "harm", "yoga",
        ],
        "say": ["sorry", "hello", "goodbye", "bye", "thanks", "yes", "no"],
        "tell": ["truth", "lie", "lies", "story", "stories", "joke", "jokes", "secret", "secrets", "difference"],
    ]

    /// Partners that Turkish says with "yapmak" or "söylemek" (`sharesTurkishVerb`): "hata
    /// yapmak", "ödev yapmak", "alışveriş yapmak", "doğruyu söylemek". Not "karar vermek",
    /// "randevu almak", "para kazanmak", "bulaşık yıkamak", "özür dilemek", "fıkra anlatmak".
    static let oneTurkishVerb: Set<String> = [
        "mistake", "mistakes", "homework", "housework", "shopping", "exercise", "research", "noise",
        "plan", "plans", "reservation", "reservations", "announcement", "choice", "choices",
        "business", "gardening", "chores", "yoga", "overtime", "favour", "favor", "best",
        "truth", "lie", "lies",
    ]

    /// A partner that goes on with a fixed word: "make fun of".
    private static let partnerTails: [String: String] = ["fun": "of"]

    /// A partner followed by one of these is part of something else: "say no one knows", "say no
    /// more" are no "say no".
    private static let partnerBlockers: [String: Set<String>] = [
        "no": ["one", "idea", "more", "longer", "way", "problem", "doubt", "matter", "time"],
    ]

    /// Small words that may stand between the verb and its partner ("a big", "a lot of", "your
    /// own"). Object pronouns too ("do me a favour"), but not "you": "Do you exercise?" asks.
    private static let fillers: Set<String> = [
        "a", "an", "the", "my", "your", "his", "her", "its", "our", "their", "some", "any", "no",
        "this", "that", "these", "those", "big", "small", "little", "few", "lot", "lots", "of",
        "good", "bad", "great", "huge", "serious", "terrible", "quick", "new", "real", "much",
        "more", "many", "several", "two", "three", "every", "all", "own", "important", "difficult",
        "hard", "final", "wrong", "right", "silly", "stupid", "careful", "slow", "weekly", "daily",
        "enough", "extra", "such", "same", "other", "another", "first", "last", "next", "whole",
        "me", "him", "us", "them",
    ]
    /// say / tell also take "you" ("tell you a secret") and story words ("a funny story").
    private static let tellFillers: Set<String> = fillers.union([
        "you", "funny", "true", "long", "short", "sad", "white", "interesting", "scary",
    ])
    /// The most small words between a verb and its partner.
    private static let maxFillers = 4

    private static let auxiliaries: Set<String> = ["do", "does", "did"]
    private static let questionWords: Set<String> = ["what", "why", "how", "when", "where", "who", "which"]
    /// Collocations written with a placeholder are no question ("make sb angry").
    private static let placeholders: Set<String> = ["sb", "sth", "someone", "somebody", "something", "smth"]
    /// Before "made" (and "said", "told"), these ask for the participle: "have made" → "done".
    private static let haveForms: Set<String> = [
        "have", "has", "had", "having", "haven't", "hasn't", "hadn't",
        "i've", "you've", "we've", "they've", "i'd", "you'd", "we'd", "they'd", "he'd", "she'd",
        "he's", "she's", "it's", "that's", "who's", "there's",
    ]
    /// Words that may stand between a "have" and the participle: "Have you ever made…".
    private static let betweenHaveAndVerb: Set<String> = [
        "i", "you", "we", "they", "he", "she", "it", "ever", "never", "already", "just", "not",
        "also", "always", "recently", "all", "both",
    ]

    // MARK: Matching

    /// A word without the punctuation around it, and that punctuation.
    private struct Core {
        let leading: String
        let text: String
        let trailing: String

        /// No punctuation after the word: the phrase goes on.
        var isBare: Bool {
            return trailing.isEmpty
        }
    }

    private static func core(of word: Substring) -> Core {
        var text = word
        var leading = ""
        var trailing = ""
        while let first = text.first, !first.isLetter, !first.isNumber {
            leading.append(first)
            text.removeFirst()
        }
        while let last = text.last, !last.isLetter, !last.isNumber {
            trailing.insert(last, at: trailing.startIndex)
            text.removeLast()
        }
        return Core(leading: leading, text: String(text), trailing: trailing)
    }

    /// The place of the verb's partner after `index`: only fillers between, no punctuation after
    /// the verb or a filler, and a partner of this verb that the other verb does not take.
    private static func partnerPlace(after index: Int, verb: String, keys: [String], cores: [Core]) -> Int? {
        let own = partners[verb] ?? []
        let allowed = verb == "say" || verb == "tell" ? tellFillers : fillers
        var place = index + 1
        while place < keys.count && place - index - 1 <= maxFillers {
            if own.contains(keys[place]) {
                if let blockers = partnerBlockers[keys[place]], place + 1 < keys.count, blockers.contains(keys[place + 1]) {
                    return nil
                }
                return place
            }
            guard allowed.contains(keys[place]), cores[place].isBare else {
                return nil
            }
            place += 1
        }
        return nil
    }

    /// The form of the verb at `index`. "made", "said" and "told" are past or participle: right
    /// after a "have" ("I've made", "has made"), or with at most two words such as "you ever"
    /// between ("Have you ever made…"), the participle; otherwise the past ("We had lunch and
    /// made…" → "did").
    private static func form(of written: String, verb: Verb, keys: [String], at index: Int) -> Form {
        let forms = verb.forms.filter { $0.value == written }.map { $0.key }
        guard forms.count > 1 else {
            return forms.first ?? .base
        }
        var place = index - 1
        while place >= 0 && index - 1 - place < 2 && betweenHaveAndVerb.contains(keys[place]) {
            place -= 1
        }
        return place >= 0 && haveForms.contains(keys[place]) ? .participle : .past
    }

    private static func capitalized(_ word: String) -> String {
        guard let first = word.first else {
            return word
        }
        return first.uppercased() + word.dropFirst()
    }
}
