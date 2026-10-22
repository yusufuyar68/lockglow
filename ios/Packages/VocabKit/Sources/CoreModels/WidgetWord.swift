/// The small payload the widget (and the app feed) renders. Same fields as the
/// `seed_words.json` words and `widget_plan.json` queue entries (contract sections 5 and 6).
/// `sensitivity` and `confusableIDs` come only from the database (the seed has neither); every
/// field added after schema 1 is optional, so older JSON still decodes.
public struct WidgetWord: Codable, Hashable, Sendable, Identifiable {
    public let id: Int
    public let lemma: String
    public let pos: String
    public let level: String
    public let ipaUS: String?
    public let defMicro: String
    public let defShort: String
    public let exampleEN: String
    public let glossTR: String?
    /// Turkish meaning of at most 16 characters (`card_l1.gloss_short`), for widgets where
    /// `glossTR` does not fit. Shown instead of cutting `glossTR`, never cut itself. Nil when
    /// `glossTR` is already short.
    public let glossShortTR: String?
    /// `card.sensitivity`: nil or 0 for everyday cards, 1 for personal topics (relationships,
    /// break-ups, body matters, losing a job or money) that the lock screen and medium widget
    /// hide by default.
    public let sensitivity: Int?
    /// Ids of the cards a learner mixes up with this one (`card_confusable`, both directions).
    public let confusableIDs: [Int]?

    public init(
        id: Int,
        lemma: String,
        pos: String,
        level: String,
        ipaUS: String? = nil,
        defMicro: String,
        defShort: String,
        exampleEN: String,
        glossTR: String? = nil,
        glossShortTR: String? = nil,
        sensitivity: Int? = nil,
        confusableIDs: [Int]? = nil
    ) {
        self.id = id
        self.lemma = lemma
        self.pos = pos
        self.level = level
        self.ipaUS = ipaUS
        self.defMicro = defMicro
        self.defShort = defShort
        self.exampleEN = exampleEN
        self.glossTR = glossTR
        self.glossShortTR = glossShortTR
        self.sensitivity = sensitivity
        self.confusableIDs = confusableIDs
    }

    enum CodingKeys: String, CodingKey {
        case id
        case lemma
        case pos
        case level
        case ipaUS = "ipa_us"
        case defMicro = "def_micro"
        case defShort = "def_short"
        case exampleEN = "example_en"
        case glossTR = "gloss_tr"
        case glossShortTR = "gloss_short_tr"
        case sensitivity
        case confusableIDs = "confusable_ids"
    }
}

extension WidgetWord {
    /// Parsed `level`, or nil if the string is not a known level.
    public var levelValue: Level? {
        return Level(rawValue: level)
    }

    /// True for a personal-topic card (`sensitivity` 1 or more).
    public var isSensitive: Bool {
        return (sensitivity ?? 0) > 0
    }

    /// Static sample for placeholders and last-resort fallbacks. No I/O.
    public static let sample = WidgetWord(
        id: 0,
        lemma: "resilient",
        pos: "adj",
        level: "C1",
        ipaUS: "/rɪˈzɪliənt/",
        defMicro: "quick to recover",
        defShort: "able to recover quickly after something difficult",
        exampleEN: "Children are often more resilient than adults.",
        glossTR: "dirençli, çabuk toparlanan",
        glossShortTR: "dirençli"
    )
}
