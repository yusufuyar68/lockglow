import Foundation
import CoreModels

/// A widget event reduced to what progress tracking needs. The app builds it from the
/// `WidgetEvent` files in the mailbox (`Learning` does not depend on `SharedState`).
public struct LearningEvent: Equatable, Sendable {
    public var type: WidgetEventType
    public var wordID: Int
    public var at: Date

    public init(type: WidgetEventType, wordID: Int, at: Date) {
        self.type = type
        self.wordID = wordID
        self.at = at
    }
}

/// Turns widget events into progress updates. Pure: the app loads the progress, calls this,
/// then saves the result.
///
/// - `known` -> `Leitner.markKnown` ("I know this" on the widget: asked once in 3 days). Events
///   written by older widget builds mean the same and get the same check.
/// - `next`, `reveal` -> `Leitner.markExposure` (the word was seen; seeing is not a review)
/// - `unknown` -> `Leitner.review(.again)` (two boxes down; a word waiting for its "Biliyorum"
///   check goes back to "Tanış")
public enum ProgressIngest {
    /// Applies the events oldest first. Events with the same timestamp keep their input order.
    /// Words without progress start as new. Input is not modified; words without events are untouched.
    public static func apply(
        _ events: [LearningEvent],
        to progress: [Int: WordProgress]
    ) -> [Int: WordProgress] {
        return applyLogged(events, to: progress).progress
    }

    /// `apply`, plus the review-log entry of every answer among the events (`unknown`), in the
    /// order they were applied (`ReviewLog`).
    public static func applyLogged(
        _ events: [LearningEvent],
        to progress: [Int: WordProgress]
    ) -> (progress: [Int: WordProgress], answers: [ReviewLogEntry]) {
        let ordered = events.enumerated().sorted { lhs, rhs in
            if lhs.element.at != rhs.element.at {
                return lhs.element.at < rhs.element.at
            }
            return lhs.offset < rhs.offset
        }
        var result = progress
        var answers: [ReviewLogEntry] = []
        for item in ordered {
            let event = item.element
            let current = result[event.wordID] ?? WordProgress(wordID: event.wordID)
            let updated = update(current, with: event)
            result[event.wordID] = updated
            if let answer = ReviewLogEntry(before: current, after: updated, source: .widget) {
                answers.append(answer)
            }
        }
        return (result, answers)
    }

    private static func update(_ progress: WordProgress, with event: LearningEvent) -> WordProgress {
        switch event.type {
        case .known:
            return Leitner.markKnown(progress, at: event.at)
        case .next, .reveal:
            return Leitner.markExposure(progress, at: event.at)
        case .unknown:
            return Leitner.review(progress, grade: .again, at: event.at)
        }
    }
}
