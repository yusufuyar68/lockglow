import Foundation

/// Answer quality from a quiz, a flashcard or a widget self-check, worst to best. A word keeps
/// only its last one (`WordProgress.lastGrade`); every answer goes to the review log
/// (`ReviewLog`).
public enum ReviewGrade: String, Codable, Sendable {
    /// Wrong or forgotten ("Bilemedim").
    case again
    /// Remembered, but with effort ("Zor").
    case hard
    /// Remembered ("Bildim").
    case good
    /// Remembered without thinking ("Kolay").
    case easy
}

/// Leitner scheduling, plan item M9 (FSRS-6 replaces it in v1.2 behind the same calls).
///
/// - `good`: the word moves up one box; the next review is `intervalDays[box - 1]` days later.
/// - `easy`: like `good`, but two boxes up (never past the last box).
/// - `hard`: the word stays in its box (a new word enters box 1) and comes back after
///   `hardFactor` of that box's interval.
/// - `again`: the word drops `lapseDrop` boxes (never below box 1) and comes back after
///   `relearnDelay`, in practice the next round; a known word whose refresher was wrong drops to
///   `refresherLapseBox`. One slip no longer restarts the whole 1-2-4-8-16 path
///   (docs/tasarim/ogrenme_ilkeleri.md 2.3, a product choice until FSRS).
/// - `good` or `easy` in the last box graduates the word to `known`; it then comes back as a
///   refresher after `refresherDays`: 30 days, then each correct refresher one step longer, 60 and
///   120 days, and 120 from then on (ogrenme_ilkeleri 2.3, until FSRS). `hard` keeps the step
///   and halves its wait.
/// - "Biliyorum" (`markKnown`) is a claim, not a review: the word leaves the rotation and comes
///   back once, `knownCheckDelay` later, as a check (`WordProgress.awaitsKnownCheck`). A right
///   answer makes it known like a graduated word; a wrong one sends it back to the new words, to
///   be met again in "Tanış" (ogrenme_ilkeleri 2.2).
/// - Seeing a word (widget, feed) is an exposure, never a review.
/// - Every answer records its time and grade (`WordProgress.lastReviewedAt`, `lastGrade`, and
///   `firstReviewedAt` for the first one); nothing else reads them to schedule.
public enum Leitner {
    public static let maxBox = 5
    public static let intervalDays: [Double] = [1, 2, 4, 8, 16]
    public static let relearnDelay: TimeInterval = 10 * 60
    /// Days a known word waits for its refresher at each `WordProgress.refresherStep`; the last
    /// step repeats.
    public static let refresherDays: [Double] = [30, 60, 120]
    /// The first refresher wait (`refresherDays[0]`): after graduating or passing the check.
    public static let refresherDelay: TimeInterval = refresherDays[0] * 86_400
    /// A `hard` answer waits this fraction of the interval a `good` answer would wait in the same box.
    public static let hardFactor: Double = 0.5
    /// "Biliyorum" is checked once after this wait. A judgement made a while later is far more
    /// accurate than one made on the spot (Nelson and Dunlosky 1991).
    public static let knownCheckDelay: TimeInterval = 3 * 86_400
    /// A wrong answer drops a learning word this many boxes, never below box 1.
    public static let lapseDrop = 2
    /// The box of a known word whose refresher was answered wrong.
    public static let refresherLapseBox = 3
    private static let day: TimeInterval = 86_400

    /// The refresher wait at `step` of `refresherDays` (clamped to the list).
    public static func refresherWait(step: Int) -> TimeInterval {
        return refresherDays[clampedRefresherStep(step)] * day
    }

    public static func review(_ progress: WordProgress, grade: ReviewGrade, at now: Date) -> WordProgress {
        var p = progress
        p.reviews += 1
        p.lastSeenAt = now
        p.lastReviewedAt = now
        p.lastGrade = grade
        if progress.reviews == 0 {
            p.firstReviewedAt = now
        }
        switch grade {
        case .again:
            if p.awaitsKnownCheck {
                // The "Biliyorum" check failed: the word is new again and comes first in the next
                // "Tanış" (`WordProgress.returnsToIntro`); its first box comes from that round.
                p.lapses += 1
                p.box = 0
                p.state = .new
                p.dueAt = nil
            } else {
                if p.box > 0 || p.state == .known {
                    p.lapses += 1
                }
                p.box = p.state == .known ? refresherLapseBox : max(1, p.box - lapseDrop)
                p.state = .learning
                p.dueAt = now.addingTimeInterval(relearnDelay)
            }
            p.knownOverride = false
            p.refresherStep = nil
        case .hard:
            if p.state == .known {
                // Remembered: a "Biliyorum" check counts as passed. The step stays.
                let step = nextRefresherStep(of: p, grows: false)
                p.knownOverride = false
                p.refresherStep = step > 0 ? step : nil
                p.dueAt = now.addingTimeInterval(refresherWait(step: step) * hardFactor)
            } else {
                p.box = max(p.box, 1)
                p.state = .learning
                p.dueAt = now.addingTimeInterval(intervalDays[p.box - 1] * hardFactor * day)
            }
        case .good:
            advance(&p, boxes: 1, at: now)
        case .easy:
            advance(&p, boxes: 2, at: now)
        }
        return p
    }

    /// A correct answer: up `boxes` boxes (never past the last one); a correct answer while
    /// already in the last box graduates the word. A known word stays known: a refresher, one
    /// step longer next time, or the "Biliyorum" check, which the word has now passed.
    private static func advance(_ p: inout WordProgress, boxes: Int, at now: Date) {
        if p.state == .known {
            let step = nextRefresherStep(of: p, grows: true)
            p.knownOverride = false
            p.refresherStep = step > 0 ? step : nil
            p.dueAt = now.addingTimeInterval(refresherWait(step: step))
        } else if p.box >= maxBox {
            p.state = .known
            p.refresherStep = nil
            p.dueAt = now.addingTimeInterval(refresherDelay)
        } else {
            p.box = min(max(p.box, 0) + boxes, maxBox)
            p.state = .learning
            p.dueAt = now.addingTimeInterval(intervalDays[p.box - 1] * day)
        }
    }

    /// The refresher step after a known word was remembered. A refresher moves one step on when
    /// it `grows` ("Bildim", "Kolay"), never past the last; "Zor" keeps the step. The "Biliyorum"
    /// check keeps the step too: it comes days, not weeks, after the claim. A word that was never
    /// known before the claim is on step 0; one that was (a widget "Biliyorum" on a refresher)
    /// keeps the step it had reached.
    private static func nextRefresherStep(of p: WordProgress, grows: Bool) -> Int {
        let current = clampedRefresherStep(p.refresherStep ?? 0)
        if p.awaitsKnownCheck || !grows {
            return current
        }
        return clampedRefresherStep(current + 1)
    }

    private static func clampedRefresherStep(_ step: Int) -> Int {
        return min(max(step, 0), refresherDays.count - 1)
    }

    /// "I know this": the word leaves the rotation and is asked once after `knownCheckDelay`
    /// (`WordProgress.awaitsKnownCheck`). A word that already waits for its check keeps its date,
    /// so tapping again never puts the check off; words marked before the check existed (30 days)
    /// get it on that date. Box, counters and refresher step are kept for `undoKnown`.
    public static func markKnown(_ progress: WordProgress, at now: Date) -> WordProgress {
        var p = progress
        let keepsCheckDate = p.awaitsKnownCheck && p.dueAt != nil
        p.state = .known
        p.knownOverride = true
        p.lastSeenAt = now
        if !keepsCheckDate {
            p.dueAt = now.addingTimeInterval(knownCheckDelay)
        }
        return p
    }

    /// Undo of `markKnown` when the earlier progress is gone ("Öğrenmeye geri al"; the app's
    /// 5-second "Geri al" restores the earlier progress itself). Box and counters are kept.
    public static func undoKnown(_ progress: WordProgress, at now: Date) -> WordProgress {
        var p = progress
        p.knownOverride = false
        p.refresherStep = nil
        if p.box > 0 {
            p.state = .learning
            p.dueAt = now
        } else {
            p.state = .new
            p.dueAt = nil
        }
        return p
    }

    /// The word was on screen (widget or feed). Counted, but the schedule does not change.
    public static func markExposure(_ progress: WordProgress, at now: Date) -> WordProgress {
        var p = progress
        p.exposures += 1
        p.lastSeenAt = now
        return p
    }
}
