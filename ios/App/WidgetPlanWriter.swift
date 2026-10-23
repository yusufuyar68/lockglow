import Foundation
import os
import CoreModels
import SharedState
import Learning
import ContentStore

/// Writes `widget_plan.json` on one serial background queue, so the main thread does not read
/// the old plan and the widget's state, compose the queue (`WidgetPlanBuilder`), look up the
/// card details of the queued words in content.sqlite or write the file.
///
/// Rewrites run one at a time in the order they were asked for: each one reads the plan the one
/// before it wrote. The widget's state is read when the rewrite runs (milliseconds after it was
/// asked for, as before, unless rewrites are queued). Only `AppModel` writes the plan
/// (single-writer rule), and only through this queue.
///
/// The writer opens its own read-only connection to content.sqlite, so a dictionary search on
/// the main thread never waits behind the plan's card reads.
final class WidgetPlanWriter: @unchecked Sendable {
    /// What one rewrite needs, copied on the main thread when it is asked for.
    struct Request: Sendable {
        let store: AppGroupStore
        let input: WidgetPlanBuilder.Input
        /// The rewrite's instant in whole seconds (`WidgetPlanBuilder.makePlan(at:)`).
        let time: Date
        /// The words come from content.sqlite (not the seed): cards have details there.
        let usesDatabase: Bool
        /// The details of the user's own words (`CustomWord.cardDetail`), by id.
        let customDetails: [Int: CardDetail]
    }

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "widgetPlan"
    )
    private let queue = DispatchQueue(label: "lockglow.widget-plan", qos: .userInitiated)
    /// Card details read for the last plan, by card id: the next rewrite mostly queues the same
    /// words. Only touched on `queue`; a card does not change while the app runs.
    private var details: [Int: CardDetail] = [:]
    /// The writer's own connection, opened on `queue` at the first rewrite that needs it.
    private var contentStore: ContentStore?
    private var triedOpeningStore = false

    /// Queues one rewrite; `completion` gets whether a new plan was written, on the main thread
    /// once the file is on disk. With `waitUntilWritten` the caller waits for that and
    /// `completion` runs before this returns (the app is leaving the foreground and may be
    /// suspended right after).
    @MainActor
    func write(
        _ request: Request,
        waitUntilWritten: Bool = false,
        completion: @escaping @MainActor @Sendable (Bool) -> Void
    ) {
        if waitUntilWritten {
            completion(writeNow(request))
        } else {
            enqueue(request, completion: completion)
        }
    }

    /// Returns once every rewrite asked for so far has finished.
    func waitUntilIdle() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async {
                continuation.resume()
            }
        }
    }

    private func writeNow(_ request: Request) -> Bool {
        return queue.sync {
            self.perform(request)
        }
    }

    private func enqueue(_ request: Request, completion: @escaping @MainActor @Sendable (Bool) -> Void) {
        queue.async {
            let written = self.perform(request)
            DispatchQueue.main.async {
                MainActor.assumeIsolated {
                    completion(written)
                }
            }
        }
    }

    /// Runs on `queue`.
    private func perform(_ request: Request) -> Bool {
        let plan = WidgetPlanBuilder.makePlan(
            request.input,
            at: request.time,
            previousPlan: request.store.readPlan(),
            state: request.store.readState(),
            planDetail: { self.detail(for: $0, request: request) }
        )
        guard let plan = plan else {
            logger.notice("no words for a plan; the widget keeps its current data or the bundled seed")
            return false
        }
        // Only this plan's words stay cached: the cache never grows past a plan.
        let queued = Set(plan.queue.map { $0.id })
        details = details.filter { queued.contains($0.key) }
        do {
            try request.store.writePlan(plan)
            return true
        } catch {
            logger.error("could not write the widget plan: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    /// `AppModel.detail(for:)` off the main thread: a user's word's own details, a card's read
    /// once from content.sqlite. Nil for seed words and an unreadable card (tried again next time).
    private func detail(for word: WidgetWord, request: Request) -> CardDetail? {
        if word.isUserAdded {
            return request.customDetails[word.id]
        }
        if let cached = details[word.id] {
            return cached
        }
        guard request.usesDatabase, let store = openedStore() else {
            return nil
        }
        do {
            guard let detail = try store.cardDetail(id: word.id) else {
                return nil
            }
            details[word.id] = detail
            return detail
        } catch {
            logger.error("card \(word.id) detail unreadable: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private func openedStore() -> ContentStore? {
        if !triedOpeningStore {
            triedOpeningStore = true
            contentStore = ContentLoader.openStore()
        }
        return contentStore
    }
}
