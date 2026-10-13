import Foundation

/// Answer quality from a quiz or a widget self-check. The MVP uses two grades; FSRS (v1.2)
/// will add "hard" and "easy" without changing callers that only use these two.
public enum ReviewGrade: String, Codable, Sendable {
    case again
    case good
}

/// Leitner scheduling, plan item M9 (FSRS-6 replaces it in v1.2 behind the same calls).
///
/// - A correct answer moves the word up one box; the next review is `intervalDays[box - 1]` days later.
/// - A correct answer in the last box graduates the word to `known`; it then returns every
///   `refresherDelay` as a refresher. A correct refresher keeps it known.
/// - A wrong answer sends the word back to box 1 and brings it back after `relearnDelay`.
/// - Seeing a word (widget, feed) is an exposure, never a review.
public enum Leitner {
    public static let maxBox = 5
    public static let intervalDays: [Double] = [1, 2, 4, 8, 16]
    public static let relearnDelay: TimeInterval = 10 * 60
    public static let refresherDelay: TimeInterval = 30 * 86_400
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
        case .good:
            if p.state == .known {
                p.dueAt = now.addingTimeInterval(refresherDelay)
            } else if p.box >= maxBox {
                p.state = .known
                p.dueAt = now.addingTimeInterval(refresherDelay)
            } else {
                p.box = max(p.box, 0) + 1
                p.state = .learning
                p.dueAt = now.addingTimeInterval(intervalDays[p.box - 1] * day)
            }
        }
        return p
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
