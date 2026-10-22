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

/// Why the widget cannot get the user's words.
enum WidgetPlanProblem: Equatable {
    /// The App Group container is unavailable: app and widget cannot share files.
    case noSharedContainer
    /// The app has not written a plan yet.
    case noPlan
    /// The plan has no words to rotate.
    case emptyQueue
}

extension WidgetHealthSnapshot {
    /// Nil when the plan holds words the widget can rotate. Its age does not matter: the queue
    /// wraps, so an old plan still changes the word (the app rewrites it at launch and whenever
    /// it goes to the background).
    var planProblem: WidgetPlanProblem? {
        if !appGroupAvailable {
            return .noSharedContainer
        }
        if planID == nil {
            return .noPlan
        }
        if queueSize == 0 {
            return .emptyQueue
        }
        return nil
    }
}

/// The one-line verdict on the widget ("Ayarlar" and the top of "Widget sağlığı"), read from the
/// last `WidgetHealthSnapshot`. Only a placed widget can fail to update: with none placed the
/// verdict is a calm "not added", never a warning.
enum WidgetHealthStatus: Equatable {
    /// The content is still loading: no health check has run yet.
    case checking
    /// A Lockglow widget is placed and the shared plan holds the user's words.
    case working
    /// A Lockglow widget is placed but cannot get the user's words (`planProblem`).
    case notUpdating
    /// iOS reports no Lockglow widget.
    case notAdded
    /// iOS reports no widget, but that proves nothing here: Debug builds and the simulator may
    /// return an empty list while a widget is placed (ios/README point 21), or the query failed.
    case unknown

    init(_ health: WidgetHealthSnapshot, isLoading: Bool, emptyListIsReliable: Bool) {
        if isLoading {
            self = .checking
        } else if health.instances.isEmpty {
            self = emptyListIsReliable ? .notAdded : .unknown
        } else if health.planProblem != nil {
            self = .notUpdating
        } else {
            self = .working
        }
    }
}

enum WidgetProbe {
    /// The last `currentInstances()` call got an error from iOS instead of a list.
    @MainActor private(set) static var lastQueryFailed = false

    /// An empty list from the last query means no widget is placed. Not in Debug builds or the
    /// simulator (ios/README point 21), and not after a failed query.
    @MainActor static var emptyListIsReliable: Bool {
        #if DEBUG || targetEnvironment(simulator)
        return false
        #else
        return !lastQueryFailed
        #endif
    }

    /// Widgets the user has currently placed (home screen, Lock Screen, StandBy). Empty when the
    /// query fails; `lastQueryFailed` tells the two apart.
    static func currentInstances() async -> [WidgetInstance] {
        let instances = await withCheckedContinuation { (continuation: CheckedContinuation<[WidgetInstance]?, Never>) in
            WidgetCenter.shared.getCurrentConfigurations { result in
                switch result {
                case .success(let infos):
                    let mapped = infos.map { info in
                        WidgetInstance(kind: info.kind, family: String(describing: info.family))
                    }
                    continuation.resume(returning: mapped)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
        await MainActor.run {
            WidgetProbe.lastQueryFailed = instances == nil
        }
        return instances ?? []
    }
}
