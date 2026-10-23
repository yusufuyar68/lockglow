/// `type` of an event file in the App Group `events/` mailbox (contract section 6).
public enum WidgetEventType: String, Codable, Sendable {
    case next
    case known
    case unknown
    case reveal
    /// A Turkish option chosen on the quiz widget ("Bu kelime ne demek?"). Seeing the answer is
    /// not a review: the app counts it as an exposure only (`ProgressIngest`).
    case quiz
}

/// `source` of an event file: the widget family the tap came from.
public enum WidgetEventSource: String, Codable, Sendable {
    case systemSmall = "system_small"
    case systemMedium = "system_medium"
    case accessoryRectangular = "accessory_rectangular"
    case accessoryInline = "accessory_inline"
    case systemLarge = "system_large"
}
