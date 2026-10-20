import Foundation

/// Answer quality from a quiz, a flashcard or a widget self-check, worst to best. Not stored:
/// only the resulting `WordProgress` is written to `progress.json`.
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
/// - `again`: the word goes back to box 1 and comes back after `relearnDelay`.
/// - `good` or `easy` in the last box graduates the word to `known`; it then returns every
///   `refresherDelay` as a refresher. A correct refresher keeps it known (`hard` halves the wait).
/// - Seeing a word (widget, feed) is an exposure, never a review.
public enum Leitner {
    public static let maxBox = 5
    public static let intervalDays: [Double] = [1, 2, 4, 8, 16]
    public static let relearnDelay: TimeInterval = 10 * 60
    public static let refresherDelay: TimeInterval = 30 * 86_400
    /// A `hard` answer waits this fraction of the interval a `good` answer would wait in the same box.
    public static let hardFactor: Double = 0.5
    private static let day: TimeInterval = 86_400

    public static func review(_ progress: WordProgress, grade: ReviewGrade, at now: Date) -> WordProgress {
        var p = progress
        p.reviews += 1
        p.lastSeenAt = now
        switch grade {
        case .again:
            if p.box > 0 || p.state == .known {
                p.lapses += 1
            }
            p.box = 1
            p.state = .learning
            p.knownOverride = false
            p.dueAt = now.addingTimeInterval(relearnDelay)
        case .hard:
            if p.state == .known {
                p.dueAt = now.addingTimeInterval(refresherDelay * hardFactor)
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
    /// already in the last box graduates the word.
    private static func advance(_ p: inout WordProgress, boxes: Int, at now: Date) {
        if p.state == .known {
            p.dueAt = now.addingTimeInterval(refresherDelay)
        } else if p.box >= maxBox {
            p.state = .known
            p.dueAt = now.addingTimeInterval(refresherDelay)
        } else {
            p.box = min(max(p.box, 0) + boxes, maxBox)
            p.state = .learning
            p.dueAt = now.addingTimeInterval(intervalDays[p.box - 1] * day)
        }
    }

    /// "I know this": the word leaves the rotation and only returns as a refresher.
    public static func markKnown(_ progress: WordProgress, at now: Date) -> WordProgress {
        var p = progress
        p.state = .known
        p.knownOverride = true
        p.lastSeenAt = now
        p.dueAt = now.addingTimeInterval(refresherDelay)
        return p
    }

    /// Undo of `markKnown` (the 5-second "Undo" toast). Box and counters are kept.
    public static func undoKnown(_ progress: WordProgress, at now: Date) -> WordProgress {
        var p = progress
        p.knownOverride = false
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
