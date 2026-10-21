import Foundation
import WidgetKit

struct WidgetInstance: Hashable, Sendable {
    let kind: String
    let family: String
}

/// Everything the "Widget Sağlığı" screen shows.
struct WidgetHealthSnapshot {
    var appGroupAvailable = false
    var instances: [WidgetInstance] = []
    var planID: String?
    var planUpdatedAt: Date?
    /// The next interval boundary, when the widget shows a new word. Nil without a plan.
    var nextChangeAt: Date?
    var queueSize = 0
    var cursorOffset: Int?
    var knownCount: Int?
    var pendingEventCount = 0
    var lastReloadRequestedAt: Date?
}

enum WidgetProbe {
    /// Widgets the user has currently placed (home screen, Lock Screen, StandBy).
    static func currentInstances() async -> [WidgetInstance] {
        return await withCheckedContinuation { (continuation: CheckedContinuation<[WidgetInstance], Never>) in
            WidgetCenter.shared.getCurrentConfigurations { result in
                switch result {
                case .success(let infos):
                    let mapped = infos.map { info in
                        WidgetInstance(kind: info.kind, family: String(describing: info.family))
                    }
                    continuation.resume(returning: mapped)
                case .failure:
                    continuation.resume(returning: [])
                }
            }
        }
    }
}
