/// The small payload the widget (and the app feed) renders. Same fields as the
/// `seed_words.json` words and `widget_plan.json` queue entries (contract sections 5 and 6).
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

    public init(
        id: Int,
        lemma: String,
        pos: String,
        level: String,
        ipaUS: String? = nil,
        defMicro: String,
        defShort: String,
        exampleEN: String,
        glossTR: String? = nil
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
    }
}

extension WidgetWord {
    /// Parsed `level`, or nil if the string is not a known level.
    public var levelValue: Level? {
        return Level(rawValue: level)
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
        glossTR: "dirençli, çabuk toparlanan"
    )
}
