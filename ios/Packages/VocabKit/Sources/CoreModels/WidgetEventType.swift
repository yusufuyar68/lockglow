/// `type` of an event file in the App Group `events/` mailbox (contract section 6).
public enum WidgetEventType: String, Codable, Sendable {
    case next
    case known
    case unknown
    case reveal
}

/// `source` of an event file: the widget family the tap came from.
public enum WidgetEventSource: String, Codable, Sendable {
    case systemSmall = "system_small"
    case systemMedium = "system_medium"
    case systemLarge = "system_large"
    case accessoryRectangular = "accessory_rectangular"
    case accessoryInline = "accessory_inline"
}
