import Foundation
import CoreModels
import SharedState

/// Everything the rotation needs, resolved from the plan and the widget-written state.
/// Used identically by the widget and the app.
public struct RotationInput: Equatable, Sendable {
    /// `plan_id` used while there is no plan: the widget rotates the bundled seed words.
    public static let seedPlanID = "seed"
    /// Seed rotation interval (no plan, so no `interval_seconds`).
    public static let seedIntervalSeconds = 3600

    public let planID: String
    public let queue: [WidgetWord]
    public let knownIDs: Set<Int>
    /// Queue index the rotation started from at `cursorAnchor`.
    public let cursorOffset: Int
    public let cursorAnchor: Date
    /// Global rotation interval in seconds (unclamped; the planner clamps).
    public let interval: TimeInterval
    public let isSeed: Bool

    public init(
        planID: String,
        queue: [WidgetWord],
        knownIDs: Set<Int>,
        cursorOffset: Int,
        cursorAnchor: Date,
        interval: TimeInterval,
        isSeed: Bool
    ) {
        self.planID = planID
        self.queue = queue
        self.knownIDs = knownIDs
        self.cursorOffset = cursorOffset
        self.cursorAnchor = cursorAnchor
        self.interval = interval
        self.isSeed = isSeed
    }

    /// Base (b, d) of the rotation:
    /// - A plan with a non-empty queue is used as is. If `state` has the same `plan_id`,
    ///   b = state.cursorOffset and d = state.cursorAnchor; otherwise b = 0 and d = plan.updatedAt.
    /// - Without a usable plan the seed words are used: b and d come from a state with
    ///   plan_id "seed" if there is one, otherwise b = 0 and d = `TimelinePlanner.seedAnchor`.
    public static func resolve(
        plan: WidgetPlan?,
        state: WidgetState?,
        seedWords: [WidgetWord]
    ) -> RotationInput {
        let planID: String
        let queue: [WidgetWord]
        let interval: TimeInterval
        let defaultAnchor: Date
        let isSeed: Bool
        if let plan = plan, !plan.queue.isEmpty {
            planID = plan.planID
            queue = plan.queue
            interval = TimeInterval(plan.intervalSeconds)
            defaultAnchor = plan.updatedAt
            isSeed = false
        } else {
            planID = RotationInput.seedPlanID
            queue = seedWords
            interval = TimeInterval(RotationInput.seedIntervalSeconds)
            defaultAnchor = TimelinePlanner.seedAnchor
            isSeed = true
        }

        // A state from another plan is meaningless: a new plan_id resets cursor and known ids.
        let matching: WidgetState? = (state?.planID == planID) ? state : nil
        return RotationInput(
            planID: planID,
            queue: queue,
            knownIDs: Set(matching?.knownIDs ?? []),
            cursorOffset: matching?.cursorOffset ?? 0,
            cursorAnchor: matching?.cursorAnchor ?? defaultAnchor,
            interval: interval,
            isSeed: isSeed
        )
    }
}
