import Foundation
import CoreModels

/// One file in `events/`. Written ONLY by the widget, one new file per event (contract section 6).
public struct WidgetEvent: Codable, Equatable, Sendable {
    public var type: WidgetEventType
    public var wordID: Int
    public var at: Date
    public var source: WidgetEventSource

    public init(type: WidgetEventType, wordID: Int, at: Date = Date(), source: WidgetEventSource) {
        self.type = type
        self.wordID = wordID
        self.at = at
        self.source = source
    }

    enum CodingKeys: String, CodingKey {
        case type
        case wordID = "word_id"
        case at
        case source
    }
}
