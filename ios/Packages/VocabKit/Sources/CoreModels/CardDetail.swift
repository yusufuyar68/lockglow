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

        /// The answer and the distractors in a stable mixed order: the same `seed` (the word id)
        /// always gives the same order, on every device and launch. Duplicates are dropped.
        public func options(seed: Int) -> [String] {
            var seen = Set<String>()
            let all = ([answer] + distractors).filter { seen.insert($0).inserted }
            return all.sorted { Quiz.mixKey(seed: seed, $0) < Quiz.mixKey(seed: seed, $1) }
        }

        /// FNV-1a over "seed|option": deterministic, unlike Swift's per-process `Hasher`.
        static func mixKey(seed: Int, _ option: String) -> UInt64 {
            var hash: UInt64 = 0xcbf2_9ce4_8422_2325
            for byte in "\(seed)|\(option)".utf8 {
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
