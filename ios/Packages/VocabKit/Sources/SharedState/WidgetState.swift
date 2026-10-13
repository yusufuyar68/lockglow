import Foundation

/// `widget_state.json`. Written ONLY by the widget extension (intents), read by the widget
/// and the app (contract section 6).
///
/// The pair (`cursorOffset`, `cursorAnchor`) pins the rotation: at time `cursorAnchor` the
/// rotation was at queue index `cursorOffset`. Time then advances it (see `TimelinePlanner`).
public struct WidgetState: Codable, Equatable, Sendable {
    public static let currentVersion = 1

    public var version: Int
    public var planID: String
    /// Queue index the rotation started from at `cursorAnchor`.
    public var cursorOffset: Int
    /// Moment `cursorOffset` was set (a tap on "next" / "know"). Whole seconds.
    public var cursorAnchor: Date
    public var knownIDs: [Int]
    public var updatedAt: Date

    public init(
        version: Int = WidgetState.currentVersion,
        planID: String,
        cursorOffset: Int,
        cursorAnchor: Date,
        knownIDs: [Int],
        updatedAt: Date = Date()
    ) {
        self.version = version
        self.planID = planID
        self.cursorOffset = cursorOffset
        self.cursorAnchor = cursorAnchor
        self.knownIDs = knownIDs
        self.updatedAt = updatedAt
    }

    public mutating func markKnown(_ wordID: Int) {
        if !knownIDs.contains(wordID) {
            knownIDs.append(wordID)
        }
    }

    enum CodingKeys: String, CodingKey {
        case version
        case planID = "plan_id"
        case cursorOffset = "cursor_offset"
        case cursorAnchor = "cursor_anchor"
        case knownIDs = "known_ids"
        case updatedAt = "updated_at"
    }
}
