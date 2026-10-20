/// One topic the user can choose to study: a `category` row (contract section 3) that is the
/// primary topic (`card.primary_topic`) of at least one card the app shows.
public struct ContentTopic: Hashable, Sendable, Identifiable {
    /// `category.id`, for example "travel_tourism".
    public let id: String
    /// `category.grp`, "A" ... "I" (everyday life, travel, people, work, ...).
    public let group: String
    public let nameEN: String
    public let nameTR: String
    /// `category.sort`: display order.
    public let sort: Int
    /// Free, non-sensitive cards whose primary topic this is.
    public let cardCount: Int

    public init(id: String, group: String, nameEN: String, nameTR: String, sort: Int, cardCount: Int) {
        self.id = id
        self.group = group
        self.nameEN = nameEN
        self.nameTR = nameTR
        self.sort = sort
        self.cardCount = cardCount
    }
}
