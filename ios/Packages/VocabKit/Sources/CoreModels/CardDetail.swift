/// The parts of a full card (the `card.json` column, contract section 3) that the app shows on a
/// card's detail: every example with its Turkish translation, and the Turkish learner notes.
/// Decoding is lenient: a missing field is empty or nil, so an older or partial card still decodes.
public struct CardDetail: Decodable, Equatable, Sendable {
    public struct Example: Decodable, Equatable, Sendable {
        public let en: String
        public let tr: String?

        public init(en: String, tr: String? = nil) {
            self.en = en
            self.tr = tr
        }
    }

    /// A typical Turkish-speaker error: the wrong sentence, the right one, and why (in Turkish).
    public struct Mistake: Decodable, Equatable, Sendable {
        public let wrong: String
        public let right: String
        public let why: String

        public init(wrong: String, right: String, why: String) {
            self.wrong = wrong
            self.right = right
            self.why = why
        }
    }

    /// A Turkish look-alike word that means something else.
    public struct FalseFriend: Decodable, Equatable, Sendable {
        public let trWord: String
        public let trMeans: String
        public let enForThat: String

        public init(trWord: String, trMeans: String, enForThat: String) {
            self.trWord = trWord
            self.trMeans = trMeans
            self.enForThat = enForThat
        }

        enum CodingKeys: String, CodingKey {
            case trWord = "tr_word"
            case trMeans = "tr_means"
            case enForThat = "en_for_that"
        }
    }

    /// The card's fill-in-the-blank question: `cloze` contains a blank ("______"), `answer` fills
    /// it, the distractors do not.
    public struct Quiz: Decodable, Equatable, Sendable {
        public let cloze: String
        public let answer: String
        public let distractors: [String]

        public init(cloze: String, answer: String, distractors: [String]) {
            self.cloze = cloze
            self.answer = answer
            self.distractors = distractors
        }

        /// The answer and the distractors in a mixed order; duplicates are dropped. `seed` is the
        /// word id, `attempt` how many times the word was answered before (`WordProgress.reviews`).
        /// The same seed and attempt always give the same order, on every device and launch, so a
        /// question keeps its order while it is on screen.
        ///
        /// Each next attempt moves the answer to another place and mixes the distractors anew, so
        /// the place cannot stand in for the word (learning principles 2.4): over any `count`
        /// attempts in a row the answer sits once in every place, in a cycle of places of its own
        /// for each word. Attempt 0 gives the order this method gave before it took an attempt.
        public func options(seed: Int, attempt: Int = 0) -> [String] {
            var seen = Set<String>()
            let all = ([answer] + distractors).filter { seen.insert($0).inserted }
            let firstOrder = all.sorted { Quiz.mixKey(seed: seed, $0) < Quiz.mixKey(seed: seed, $1) }
            guard all.count > 1, let firstPlace = firstOrder.firstIndex(of: answer) else {
                return firstOrder
            }
            let places = Quiz.answerPlaces(seed: seed, first: firstPlace, count: all.count)
            // Never negative, even for a negative attempt.
            let place = places[(attempt % places.count + places.count) % places.count]
            var order = all.dropFirst().sorted {
                Quiz.mixKey(seed: seed, attempt: attempt, $0) < Quiz.mixKey(seed: seed, attempt: attempt, $1)
            }
            order.insert(answer, at: place)
            return order
        }

        /// The sentence with the answer in the blank (the first run of three or more
        /// underscores), shown and read aloud after the question is answered. A blank at the very
        /// start gets a capital letter. Without a blank the cloze is returned unchanged.
        public var filledSentence: String {
            guard let blank = cloze.range(of: "_{3,}", options: .regularExpression) else {
                return cloze
            }
            var filler = answer
            if blank.lowerBound == cloze.startIndex, let first = filler.first {
                filler = first.uppercased() + filler.dropFirst()
            }
            return cloze.replacingCharacters(in: blank, with: filler)
        }

        /// The answer's place for attempts 0, 1, 2, … as a repeating cycle: `first` (the place of
        /// attempt 0), then every other place in an order mixed by `seed`.
        static func answerPlaces(seed: Int, first: Int, count: Int) -> [Int] {
            let others = (0..<count)
                .filter { $0 != first }
                .sorted { mixKey(seed: seed, "place \($0)") < mixKey(seed: seed, "place \($1)") }
            return [first] + others
        }

        /// FNV-1a over "seed|option" (attempt 0, the key from before attempts) or
        /// "seed|attempt|option": deterministic, unlike Swift's per-process `Hasher`.
        static func mixKey(seed: Int, attempt: Int = 0, _ option: String) -> UInt64 {
            let text = attempt == 0 ? "\(seed)|\(option)" : "\(seed)|\(attempt)|\(option)"
            var hash: UInt64 = 0xcbf2_9ce4_8422_2325
            for byte in text.utf8 {
                hash ^= UInt64(byte)
                hash = hash &* 0x0000_0100_0000_01b3
            }
            return hash
        }
    }

    public let examples: [Example]
    public let collocations: [String]
    /// Other Turkish equivalents besides the gloss (`l1.tr.alt`).
    public let glossAlternatives: [String]
    public let noteTR: String?
    public let mistakes: [Mistake]
    public let falseFriend: FalseFriend?
    public let mnemonicTR: String?
    public let quiz: Quiz?

    public init(
        examples: [Example] = [],
        collocations: [String] = [],
        glossAlternatives: [String] = [],
        noteTR: String? = nil,
        mistakes: [Mistake] = [],
        falseFriend: FalseFriend? = nil,
        mnemonicTR: String? = nil,
        quiz: Quiz? = nil
    ) {
        self.examples = examples
        self.collocations = collocations
        self.glossAlternatives = glossAlternatives
        self.noteTR = noteTR
        self.mistakes = mistakes
        self.falseFriend = falseFriend
        self.mnemonicTR = mnemonicTR
        self.quiz = quiz
    }

    enum CodingKeys: String, CodingKey {
        case examples
        case collocations
        case l1
        case quiz
    }

    private struct TurkishLayer: Decodable {
        let alt: [String]?
        let note: String?
        let mistakes: [Mistake]?
        let falseFriend: FalseFriend?
        let mnemonic: String?

        enum CodingKeys: String, CodingKey {
            case alt
            case note
            case mistakes
            case falseFriend = "false_friend"
            case mnemonic
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        examples = try container.decodeIfPresent([Example].self, forKey: .examples) ?? []
        collocations = try container.decodeIfPresent([String].self, forKey: .collocations) ?? []
        let layers = try container.decodeIfPresent([String: TurkishLayer].self, forKey: .l1) ?? [:]
        let turkish = layers["tr"]
        glossAlternatives = turkish?.alt ?? []
        noteTR = turkish?.note
        mistakes = turkish?.mistakes ?? []
        falseFriend = turkish?.falseFriend
        mnemonicTR = turkish?.mnemonic
        quiz = try container.decodeIfPresent(Quiz.self, forKey: .quiz)
    }
}
