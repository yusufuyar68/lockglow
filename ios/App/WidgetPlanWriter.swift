import Foundation
import os
import CoreModels
import SharedState
import Learning
import ContentStore

/// Writes `widget_plan.json` on one serial background queue, so the main thread does not read
/// the old plan and the widget's state, compose the queue (`WidgetPlanBuilder`), look up the
/// medium widget's examples in content.sqlite or write the file.
///
/// Rewrites run one at a time in the order they were asked for: each one reads the plan the one
/// before it wrote, exactly as when they ran on the main thread. Only `AppModel` writes the plan
/// (single-writer rule), and only through this queue.
final class WidgetPlanWriter: @unchecked Sendable {
    /// What one rewrite needs, copied on the main thread when it is asked for.
    struct Request: Sendable {
        let store: AppGroupStore
        let input: WidgetPlanBuilder.Input
        /// The rewrite's instant in whole seconds (`WidgetPlanBuilder.makePlan(at:)`).
        let time: Date
        /// content.sqlite for the examples; nil with seed words only.
        let contentStore: ContentStore?
    }

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "widgetPlan"
    )
    private let queue = DispatchQueue(label: "lockglow.widget-plan", qos: .userInitiated)
    /// The medium widget's example by card id, `.some(nil)` when no example contains the word.
    /// Only touched on `queue`. A card's examples do not change while the app runs.
    private var examples: [Int: String?] = [:]

    /// Queues one rewrite; `completion` runs on the main thread with whether a new plan was
    /// written. With `waitUntilWritten` the caller waits until the file is on disk and
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
            planExample: { self.example(for: $0, in: request.contentStore) }
        )
        guard let plan = plan else {
            logger.notice("no words for a plan; the widget keeps its current data or the bundled seed")
            return false
        }
        do {
            try request.store.writePlan(plan)
            return true
        } catch {
            logger.error("could not write the widget plan: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    /// The card's shortest example that contains the word, read once from content.sqlite. A
    /// user's word has one example, its own (`CustomWord.cardDetail`), so it keeps it. Nil for
    /// seed words and an unreadable card (tried again on the next rewrite).
    private func example(for word: WidgetWord, in store: ContentStore?) -> String? {
        if word.isUserAdded {
            return nil
        }
        if let cached = examples[word.id] {
            return cached
        }
        guard let store = store else {
            return nil
        }
        do {
            guard let detail = try store.cardDetail(id: word.id) else {
                return nil
            }
            let shortest = detail.shortestExample(containing: word.lemma)
            examples[word.id] = .some(shortest)
            return shortest
        } catch {
            logger.error("card \(word.id) detail unreadable: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}
