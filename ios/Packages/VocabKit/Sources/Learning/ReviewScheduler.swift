import Foundation

/// Which scheduler times the reviews: Leitner, or FSRS behind "Yeni zamanlama (deneme)" in
/// "Ayarlar" (off by default; docs/ozellik_planlari/fsrs.md 4.3 step 2).
public enum SchedulerKind: String, Codable, CaseIterable, Sendable {
    case leitner
    case fsrs
}

/// The one entry point for an answer (fsrs.md 4.3 step 2). "Tekrar", the recall screen, the
/// "Biliyorum" check, the widget's "Bilmiyorum" (`ProgressIngest`) and the times on the answer
/// buttons all go through the selected scheduler.
///
/// Every scheduler keeps the same fields in Leitner's terms, so every other reader works the same
/// with either one and a switch never has to convert anything:
/// - `state`, `box` (the "basamak" on screen) and `dueAt`; `refresherStep` for a known word;
/// - `reviews`, `lapses`, `lastSeenAt`, `lastReviewedAt`, `lastGrade`, `firstReviewedAt`, as
///   `Leitner.review` writes them, so the review log (`ReviewLogEntry(before:after:source:)`)
///   gets every answer from either;
/// - `knownOverride`: a right answer proves a "Biliyorum", a wrong one sends the word back to
///   "Tanış" (docs/tasarim/ogrenme_ilkeleri.md 2.2).
///
/// `QueueComposer`, `ReminderPlanner`, `ReviewPlanner` and `ProgressSummary` read only these
/// fields. Where a reading depends on who made the last answer ("bir basamak çıktı" after an FSRS
/// answer, `ProgressSummary.lastAnswer`), the word's own record says so (`WordProgress.fsrs`),
/// not a setting: a switch can never make a reader misread older answers.
///
/// Seeing a word, "Biliyorum" and its undo are no answers: `Leitner.markExposure`,
/// `Leitner.markKnown` and `Leitner.undoKnown` serve both schedulers.
public protocol ReviewScheduler: Sendable {
    var kind: SchedulerKind { get }

    /// One answer at `now`. Pure: the caller saves the result and logs it.
    func review(_ progress: WordProgress, grade: ReviewGrade, at now: Date) -> WordProgress
}

/// `Leitner.review` behind `ReviewScheduler`: the default, and what "Yeni zamanlama" off gives.
///
/// After FSRS it goes on from what FSRS left: the word's box, due date and refresher step. The
/// FSRS memory (`WordProgress.fsrs`) is left as it was; its answer count no longer matches once
/// Leitner answers, and the next switch to FSRS rebuilds it (`FSRSMigration`).
public struct LeitnerScheduler: ReviewScheduler {
    public init() {}

    public var kind: SchedulerKind {
        return .leitner
    }

    public func review(_ progress: WordProgress, grade: ReviewGrade, at now: Date) -> WordProgress {
        return Leitner.review(progress, grade: grade, at: now)
    }
}
