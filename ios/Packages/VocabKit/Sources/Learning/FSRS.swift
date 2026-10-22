import Foundation

/// FSRS-6 scheduling (Free Spaced Repetition Scheduler), plan item v1.2. Not wired into the app
/// yet: `Leitner` still schedules every review (docs/ozellik_planlari/fsrs.md has the comparison
/// and the migration plan).
///
/// A word's memory is two numbers: stability (days until the chance of recall falls to 90%) and
/// difficulty (1...10). Retrievability, the chance of recalling the word now, follows from the
/// stability and the days since the last answer. The next review is set for the day
/// retrievability falls to `desiredRetention`.
///
/// A port of py-fsrs 6.3.2 (`fsrs/scheduler.py`, the official Python implementation) without
/// fuzz; FSRS-5 weights (19 numbers) are filled up as fsrs-rs does. Formulas:
/// https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm (FSRS-6 section).
///
/// Lockglow's four answers are FSRS's four ratings: Bilemedim = Again, Zor = Hard, Bildim = Good,
/// Kolay = Easy (`ReviewGrade`). "Zor" is a pass: a forgotten word must be answered "Bilemedim".
public struct FSRS: Sendable {
    /// FSRS-6 defaults, fitted to the average Anki user (py-fsrs `DEFAULT_PARAMETERS`, fsrs-rs
    /// 6.6.2 `DEFAULT_PARAMETERS`). w0...w3: first stability per rating; w4, w5: first difficulty;
    /// w6, w7: difficulty change and mean reversion; w8...w10: stability after a pass; w11...w14:
    /// stability after a lapse; w15, w16: Hard penalty and Easy bonus; w17...w19: same-day
    /// reviews; w20: decay of the forgetting curve.
    public static let defaultWeights: [Double] = [
        0.212, 1.2931, 2.3065, 8.2956, 6.4133, 0.8334, 3.0194, 0.001, 1.8722, 0.1666,
        0.796, 1.4835, 0.0614, 0.2629, 1.6483, 0.6014, 1.8729, 0.5425, 0.0912, 0.0658,
        0.1542,
    ]
    public static let minimumStability = 0.001
    public static let difficultyRange: ClosedRange<Double> = 1...10
    private static let day: TimeInterval = 86_400

    public let weights: [Double]
    /// Chance of recall the schedule aims for at each review. Higher means more reviews.
    public let desiredRetention: Double
    /// Same-day steps for a new word; Good moves one step on, the last step graduates it.
    public let learningSteps: [TimeInterval]
    /// Same-day steps after a lapse.
    public let relearningSteps: [TimeInterval]
    public let maximumIntervalDays: Int
    private let decay: Double
    private let factor: Double

    /// The defaults are py-fsrs's (steps 1 and 10 minutes, relearning 10 minutes). 19 weights are
    /// FSRS-5: w19 = 0 and the decay 0.5 are added.
    public init(
        weights: [Double] = FSRS.defaultWeights,
        desiredRetention: Double = 0.9,
        learningSteps: [TimeInterval] = [60, 600],
        relearningSteps: [TimeInterval] = [600],
        maximumIntervalDays: Int = 36_500
    ) {
        let filled = weights.count == 19 ? weights + [0, 0.5] : weights
        precondition(filled.count == 21, "FSRS needs 19 (FSRS-5) or 21 (FSRS-6) weights")
        precondition(desiredRetention > 0 && desiredRetention <= 1, "desired retention is a probability")
        self.weights = filled
        self.desiredRetention = desiredRetention
        self.learningSteps = learningSteps
        self.relearningSteps = relearningSteps
        self.maximumIntervalDays = maximumIntervalDays
        let decay = -filled[20]
        self.decay = decay
        // Chosen so that retrievability is exactly 0.9 when the elapsed days equal the stability.
        self.factor = pow(0.9, 1 / decay) - 1
    }

    // MARK: Memory model

    /// R(t, S) = (1 + factor · t / S)^decay: the chance of recall `elapsedDays` after the last answer.
    public func retrievability(elapsedDays: Double, stability: Double) -> Double {
        return pow(1 + factor * elapsedDays / stability, decay)
    }

    /// Days until retrievability falls to `retention` (`desiredRetention` when nil), unrounded.
    public func intervalDays(stability: Double, retention: Double? = nil) -> Double {
        let r = retention ?? desiredRetention
        return stability / factor * (pow(r, 1 / decay) - 1)
    }

    /// The review interval in whole days: rounded half to even like py-fsrs, at least 1 day,
    /// at most `maximumIntervalDays`.
    public func scheduledDays(stability: Double) -> Int {
        let days = intervalDays(stability: stability).rounded(.toNearestOrEven)
        return Int(min(max(days, 1), Double(maximumIntervalDays)))
    }

    /// The memory after a word's first answer: S0 = w[rating - 1], D0 = w4 − e^(w5 · (rating − 1)) + 1.
    public func initialMemory(_ grade: ReviewGrade) -> FSRSMemory {
        return FSRSMemory(
            stability: max(weights[grade.rating - 1], Self.minimumStability),
            difficulty: clampDifficulty(initialDifficulty(grade.rating))
        )
    }

    /// The memory after an answer `elapsedDays` whole days after the previous one (fsrs-rs `step`).
    /// Under a day uses the same-day formula; otherwise a pass or a lapse at the current
    /// retrievability. Difficulty moves either way.
    public func nextMemory(_ memory: FSRSMemory, elapsedDays: Int, grade: ReviewGrade) -> FSRSMemory {
        let s = memory.stability
        let d = memory.difficulty
        let newStability: Double
        if elapsedDays < 1 {
            newStability = shortTermStability(s, grade)
        } else {
            let r = retrievability(elapsedDays: Double(elapsedDays), stability: s)
            newStability = grade == .again ? lapseStability(d, s, r) : passStability(d, s, r, grade)
        }
        return FSRSMemory(
            stability: max(newStability, Self.minimumStability),
            difficulty: nextDifficulty(d, grade)
        )
    }

    private func initialDifficulty(_ rating: Int) -> Double {
        return weights[4] - exp(weights[5] * Double(rating - 1)) + 1
    }

    private func clampDifficulty(_ d: Double) -> Double {
        return min(max(d, Self.difficultyRange.lowerBound), Self.difficultyRange.upperBound)
    }

    /// ΔD = −w6 · (rating − 3), damped by (10 − D) / 9, then pulled back toward D0(Easy) by w7.
    private func nextDifficulty(_ d: Double, _ grade: ReviewGrade) -> Double {
        let delta = -weights[6] * Double(grade.rating - 3)
        let damped = d + (10 - d) * delta / 9
        let reverted = weights[7] * initialDifficulty(4) + (1 - weights[7]) * damped
        return clampDifficulty(reverted)
    }

    /// S' = S · e^(w17 · (rating − 3 + w18)) · S^−w19; a pass never lowers it.
    private func shortTermStability(_ s: Double, _ grade: ReviewGrade) -> Double {
        var increase = exp(weights[17] * (Double(grade.rating) - 3 + weights[18])) * pow(s, -weights[19])
        if grade != .again {
            increase = max(increase, 1)
        }
        return s * increase
    }

    /// S' = S · (1 + e^w8 · (11 − D) · S^−w9 · (e^(w10 · (1 − R)) − 1) · w15 if Hard · w16 if Easy).
    private func passStability(_ d: Double, _ s: Double, _ r: Double, _ grade: ReviewGrade) -> Double {
        let hardPenalty = grade == .hard ? weights[15] : 1
        let easyBonus = grade == .easy ? weights[16] : 1
        return s * (1 + exp(weights[8]) * (11 - d) * pow(s, -weights[9])
            * (exp((1 - r) * weights[10]) - 1) * hardPenalty * easyBonus)
    }

    /// S' = w11 · D^−w12 · ((S + 1)^w13 − 1) · e^(w14 · (1 − R)), never above S / e^(w17 · w18).
    private func lapseStability(_ d: Double, _ s: Double, _ r: Double) -> Double {
        let longTerm = weights[11] * pow(d, -weights[12]) * (pow(s + 1, weights[13]) - 1)
            * exp((1 - r) * weights[14])
        return min(longTerm, s / exp(weights[17] * weights[18]))
    }

    // MARK: Scheduler

    /// The chance of recalling the word at `date`, counting whole days like py-fsrs. 0 for a word
    /// that was never answered.
    public func retrievability(of card: FSRSCard, at date: Date) -> Double {
        guard let memory = card.memory, let last = card.lastReviewAt else {
            return 0
        }
        return retrievability(elapsedDays: Double(Self.elapsedDays(from: last, to: date)), stability: memory.stability)
    }

    /// One answer (py-fsrs `Scheduler.review_card`). A word in a learning or relearning step comes
    /// back after that step; otherwise after `scheduledDays` of the new stability.
    public func review(_ card: FSRSCard, grade: ReviewGrade, at now: Date) -> FSRSCard {
        var c = card
        let memory: FSRSMemory
        if let previous = c.memory, let last = c.lastReviewAt {
            memory = nextMemory(previous, elapsedDays: Self.elapsedDays(from: last, to: now), grade: grade)
        } else {
            memory = initialMemory(grade)
        }
        c.memory = memory
        let reviewInterval = Double(scheduledDays(stability: memory.stability)) * Self.day

        let interval: TimeInterval
        switch c.phase {
        case .review:
            if grade == .again, let first = relearningSteps.first {
                c.phase = .relearning
                c.step = 0
                interval = first
            } else {
                interval = reviewInterval
            }
        case .learning, .relearning:
            let steps = c.phase == .learning ? learningSteps : relearningSteps
            let step = c.step ?? 0
            if steps.isEmpty || (step >= steps.count && grade != .again) {
                c.phase = .review
                c.step = nil
                interval = reviewInterval
            } else {
                switch grade {
                case .again:
                    c.step = 0
                    interval = steps[0]
                case .hard:
                    if step == 0 {
                        interval = steps.count == 1 ? steps[0] * 1.5 : (steps[0] + steps[1]) / 2
                    } else {
                        interval = steps[step]
                    }
                case .good where step + 1 < steps.count:
                    c.step = step + 1
                    interval = steps[step + 1]
                case .good, .easy:
                    c.phase = .review
                    c.step = nil
                    interval = reviewInterval
                }
            }
        }
        c.dueAt = now.addingTimeInterval(interval)
        c.lastReviewAt = now
        return c
    }

    /// Whole days between two answers, rounded down (py-fsrs `timedelta.days`); never negative.
    private static func elapsedDays(from last: Date, to now: Date) -> Int {
        return max(0, Int((now.timeIntervalSince(last) / day).rounded(.down)))
    }
}

/// Stability (days until recall falls to 90%) and difficulty (1...10) of one word.
public struct FSRSMemory: Equatable, Sendable {
    public var stability: Double
    public var difficulty: Double

    public init(stability: Double, difficulty: Double) {
        self.stability = stability
        self.difficulty = difficulty
    }
}

/// One word's FSRS schedule (py-fsrs `Card`). A new word starts in the first learning step.
public struct FSRSCard: Equatable, Sendable {
    public enum Phase: String, Sendable {
        /// New, in the same-day learning steps.
        case learning
        /// Scheduled in whole days.
        case review
        /// Answered "Bilemedim" after graduating, in the same-day relearning steps.
        case relearning
    }

    public var phase: Phase
    /// Index into the learning or relearning steps; nil in `review`.
    public var step: Int?
    /// Nil until the first answer.
    public var memory: FSRSMemory?
    public var dueAt: Date?
    public var lastReviewAt: Date?

    public init() {
        self.phase = .learning
        self.step = 0
        self.memory = nil
        self.dueAt = nil
        self.lastReviewAt = nil
    }
}

private extension ReviewGrade {
    /// FSRS rating: Again 1, Hard 2, Good 3, Easy 4.
    var rating: Int {
        switch self {
        case .again: return 1
        case .hard: return 2
        case .good: return 3
        case .easy: return 4
        }
    }
}
