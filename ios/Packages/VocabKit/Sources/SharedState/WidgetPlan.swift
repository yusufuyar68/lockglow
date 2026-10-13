import Foundation
import CoreModels

/// `widget_plan.json`. Written ONLY by the app, read by the widget (contract section 6).
public struct WidgetPlan: Codable, Equatable, Sendable {
    public static let currentVersion = 1

    public var version: Int
    /// Changes every time the app writes a new plan; the widget resets its cursor when it differs.
    public var planID: String
    public var isPremium: Bool
    public var intervalSeconds: Int
    public var queue: [WidgetWord]
    public var updatedAt: Date

    public init(
        version: Int = WidgetPlan.currentVersion,
        planID: String,
        isPremium: Bool,
        intervalSeconds: Int,
        queue: [WidgetWord],
        updatedAt: Date = Date()
    ) {
        self.version = version
        self.planID = planID
        self.isPremium = isPremium
        self.intervalSeconds = intervalSeconds
        self.queue = queue
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case version
        case planID = "plan_id"
        case isPremium = "is_premium"
        case intervalSeconds = "interval_seconds"
        case queue
        case updatedAt = "updated_at"
    }
}
