import Foundation

/// FSRS-6 (`FSRS`) with Lockglow's rules, behind "Yeni zamanlama" (fsrs.md 4.3).
///
/// FSRS sets the wait from the word's memory (`WordProgress.fsrs`: stability and difficulty).
/// Everything else stays in Leitner's terms (`ReviewScheduler`), so the screens, the widget queue
/// and the reminder read the words the same way, and switching back to Leitner needs no change.
///
/// **Basamak** (the "box" on screen) is the Leitner step whose wait the FSRS wait has reached:
/// stability below 2 days is basamak 1, from 2 days 2, from 4 days 3, from 8 days 4, from 16 days
/// 5 (`Leitner.intervalDays`). With the target 0.9 the wait is the stability, so a word in
/// basamak 3 comes back in 4 to 8 days, as with Leitner. From `knownStability` (30 days, Leitner's
/// first refresher) the word is known: "Yerleşti", basamak 5. Three rules keep the steps as the
/// screens and the learning rules describe them:
/// - a new word starts on basamak 1, whatever its first wait: its first real question is the
///   written fill-in-the-blank one (ogrenme_ilkeleri 1.2, 2.4), and İlerleme says that the first
///   round's words come to the first step;
/// - only a word on basamak 4 or 5 (`ReviewPlanner.recallFromBox`) graduates: "Yerleşti" is
///   reached through the recall question, never through a 4-option guess (2.4). A lower word
///   whose stability already reached `knownStability` climbs to basamak 5 and comes back within
///   16 days (`unprovenMaximumWait`) for that question;
/// - a right answer never takes a word down a step, and never takes a known word off
///   "Yerleşti" (`ProgressSummary`: only a forgotten word moves down);
/// - "Bilemedim" never takes a word up a step.
///
/// Lockglow's other rules stay as with Leitner:
/// - "Zor" in a same-day step (FSRS: 15 minutes) waits at least 12 hours, Leitner's "Zor" in
///   basamak 1: the first real question still comes on another day (ogrenme_ilkeleri 1.2), and
///   no answer button promises a time in minutes;
/// - "Biliyorum" is a claim, checked once 3 days later (`Leitner.markKnown`). A right check makes
///   the word known: its stability is raised to `knownStability` (ogrenme_ilkeleri 2.2: the next
///   question 30 days later). A wrong one sends it back to "Tanış", its FSRS memory kept.
/// - `lapses` counts a "Bilemedim" after the word was on a step, as `Leitner.review` does.
/// - A known word's `refresherStep` follows its stability (60 days and up: step 1, 120 and up:
///   step 2), so Leitner goes on with a similar wait after a switch back.
public struct FSRSScheduler: ReviewScheduler {
    /// A word whose stability reaches this many days is known ("Yerleşti"): Leitner's first refresher.
    public static let knownStability = Leitner.refresherDays[0]
    /// The longest wait. Leitner's longest is 120 days; FSRS may go on to a year, never further.
    public static let maximumIntervalDays = 365
    /// The shortest wait after "Zor": Leitner's in basamak 1.
    public static let hardStepWait: TimeInterval = Leitner.intervalDays[0] * Leitner.hardFactor * 86_400
    /// The longest wait of a word that is not known yet: Leitner's basamak 5.
    public static let unprovenMaximumWait: TimeInterval = (Leitner.intervalDays.last ?? 16) * 86_400
    private static let day: TimeInterval = 86_400

    public let fsrs: FSRS

    /// Weights that `FSRS.areValid(weights:)` rejects (a damaged setting) fall back to the defaults.
    public init(weights: [Double] = FSRS.defaultWeights) {
        let valid = FSRS.areValid(weights: weights) ? weights : FSRS.defaultWeights
        self.fsrs = FSRS.lockglowSettings(weights: valid)
    }

    public var kind: SchedulerKind {
        return .fsrs
    }

    public func review(_ progress: WordProgress, grade: ReviewGrade, at now: Date) -> WordProgress {
        let before = progress
        var card = fsrs.review(self.card(of: before, at: now), grade: grade, at: now)
        if before.awaitsKnownCheck && grade != .again {
            card = provenKnown(card, at: now)
        }
        guard let stability = card.memory?.stability, stability.isFinite, let due = card.dueAt else {
            // Not reachable with valid weights; Leitner rather than a schedule that cannot be saved.
            return Leitner.review(before, grade: grade, at: now)
        }

        var p = before
        p.reviews += 1
        p.lastSeenAt = now
        p.lastReviewedAt = now
        p.lastGrade = grade
        if before.reviews == 0 {
            p.firstReviewedAt = now
        }
        if grade == .again {
            if before.box > 0 || before.state == .known {
                p.lapses += 1
            }
            p.knownOverride = false
            p.refresherStep = nil
            if before.awaitsKnownCheck {
                // The "Biliyorum" check failed: new again, first in the next "Tanış"
                // (`WordProgress.returnsToIntro`). FSRS keeps the memory of this answer.
                p.state = .new
                p.box = 0
                p.dueAt = nil
            } else {
                p.state = .learning
                p.box = before.box > 0 ? min(Self.box(forStability: stability), before.box) : 1
                p.dueAt = due
            }
        } else if before.state == .known || (before.box >= ReviewPlanner.recallFromBox && Self.isKnown(card)) {
            if before.state != .known {
                // Graduated: the top step, as a Leitner word leaves box 5.
                p.box = Leitner.maxBox
            }
            p.state = .known
            p.knownOverride = false
            p.refresherStep = Self.refresherStep(forStability: stability)
            p.dueAt = due
        } else {
            p.state = .learning
            p.box = before.box > 0 ? max(Self.box(forStability: stability), before.box) : 1
            p.refresherStep = nil
            var wait = due.timeIntervalSince(now)
            if grade == .hard && card.phase != .review {
                wait = max(wait, Self.hardStepWait)
            }
            p.dueAt = now.addingTimeInterval(min(wait, Self.unprovenMaximumWait))
        }
        p.fsrs = FSRSState(card: card, reviews: p.reviews, shelfBefore: ProgressSummary.Shelf.of(before)?.rawValue ?? 0)
        return p
    }

    // MARK: Memory

    /// The word's FSRS card now: its memory when it includes every answer (`FSRSState.reviews`),
    /// otherwise an estimate from its Leitner schedule (`estimatedCard`).
    public func card(of progress: WordProgress, at now: Date) -> FSRSCard {
        if let state = progress.fsrs, state.reviews == progress.reviews {
            return state.card
        }
        return estimatedCard(of: progress, at: now)
    }

    /// A memory estimated from what Leitner left (fsrs.md 4.2 step 2, `FSRS.seededCard`): the
    /// box's wait as stability (a known word's refresher wait, 30, 60 or 120 days), "Bildim"
    /// difficulty with one "Bilemedim" step per lapse, and the last answer at `lastReviewedAt`
    /// (or the wait before `dueAt`). A word never answered, a "Biliyorum" not checked yet and a
    /// word sent back to "Tanış" get a new card: their next answer is their first for FSRS.
    public func estimatedCard(of progress: WordProgress, at now: Date) -> FSRSCard {
        guard progress.reviews > 0 else {
            return FSRSCard()
        }
        var card = fsrs.seededCard(ReviewLogEntry.Seed(progress), firstAnswerAt: now)
        guard var memory = card.memory else {
            return card
        }
        if progress.state == .known, let step = progress.refresherStep, step > 0 {
            memory.stability = Leitner.refresherWait(step: step) / Self.day
            card.memory = memory
        }
        let lastAnswer = progress.lastReviewedAt ?? (progress.dueAt ?? now).addingTimeInterval(-memory.stability * Self.day)
        card.lastReviewAt = min(lastAnswer, now)
        return card
    }

    /// FSRS over the review log with Lockglow's rules: what this scheduler would have made of
    /// every logged answer (`FSRSMigration`). Like `FSRS.replay`, but a right "Biliyorum" check
    /// (`ReviewLogEntry.knownCheck`) makes the word known, as in `review`.
    public func replay(_ log: [ReviewLogEntry]) -> FSRSReplay {
        return fsrs.replay(log) { card, entry in
            let next = fsrs.review(card, grade: entry.grade, at: entry.at)
            return entry.knownCheck == true && entry.grade != .again ? provenKnown(next, at: entry.at) : next
        }
    }

    /// A right "Biliyorum" check: at least `knownStability`, in whole-day waits from `now`.
    private func provenKnown(_ card: FSRSCard, at now: Date) -> FSRSCard {
        guard var memory = card.memory else {
            return card
        }
        var c = card
        memory.stability = max(memory.stability, Self.knownStability)
        c.memory = memory
        c.phase = .review
        c.step = nil
        c.dueAt = now.addingTimeInterval(Double(fsrs.scheduledDays(stability: memory.stability)) * Self.day)
        return c
    }

    // MARK: Steps

    /// Basamak 1...5 for a stability: the last Leitner wait (1, 2, 4, 8, 16 days) it has reached.
    public static func box(forStability stability: Double) -> Int {
        let reached = Leitner.intervalDays.filter { $0 <= stability }.count
        return min(max(reached, 1), Leitner.maxBox)
    }

    /// Known: in whole-day waits with a stability of `knownStability` or more.
    public static func isKnown(_ card: FSRSCard) -> Bool {
        return card.phase == .review && (card.memory?.stability ?? 0) >= knownStability
    }

    /// A known word's step in `Leitner.refresherDays` for its stability; nil is step 0.
    public static func refresherStep(forStability stability: Double) -> Int? {
        let step = Leitner.refresherDays.lastIndex { $0 <= stability } ?? 0
        return step > 0 ? step : nil
    }

    // MARK: Reading

    /// What the word's last answer did on the steps (`ProgressSummary.lastAnswer`), when FSRS
    /// made it; nil otherwise (Leitner's reading then applies). An FSRS "Bildim" does not always
    /// reach the next step, so the step before the answer (`FSRSState.shelfBefore`) decides:
    /// - "Bilemedim": `.forgot`;
    /// - a learning word now on a higher step than before: `.movedUp`; on the same step, or met
    ///   again after "Tanış": `.stayed` (no step was climbed);
    /// - a word that reached "Yerleşti" from steps 1–4: `.movedUp`; one remembered on step 5 or
    ///   "Yerleşti", or a right "Biliyorum" check: `.recalledOnTop` (`ProgressSummary` counts it
    ///   on the top step only, as with Leitner).
    public static func lastAnswer(of progress: WordProgress) -> ProgressSummary.LastAnswer? {
        guard let state = progress.fsrs, state.reviews == progress.reviews, progress.reviews > 0,
              let before = state.shelfBefore, let at = progress.lastReviewedAt, let grade = progress.lastGrade else {
            return nil
        }
        switch progress.state {
        case .new:
            return nil
        case .learning:
            if grade == .again {
                return ProgressSummary.LastAnswer(date: at, kind: .forgot)
            }
            let climbed = (1...Leitner.maxBox).contains(before) && progress.box > before
            return ProgressSummary.LastAnswer(date: at, kind: climbed ? .movedUp : .stayed)
        case .known:
            if progress.knownOverride || grade == .again {
                return nil
            }
            let jumped = (1..<Leitner.maxBox).contains(before)
            return ProgressSummary.LastAnswer(date: at, kind: jumped ? .movedUp : .recalledOnTop)
        }
    }
}

/// One word's FSRS memory in `progress.json` (key `fsrs`, fsrs.md 4.1). Only `FSRSScheduler`
/// and `FSRSMigration` write it; nil until FSRS has a memory for the word.
public struct FSRSState: Codable, Equatable, Sendable {
    /// Days until the chance of recall falls to 90%.
    public var stability: Double
    /// 1...10.
    public var difficulty: Double
    public var phase: FSRSCard.Phase
    /// Index into the same-day steps; nil in `review`.
    public var step: Int?
    /// FSRS's last answer: exact for its own answers, estimated for a word it took over.
    public var lastReviewAt: Date
    /// The `WordProgress.reviews` this memory includes. Any other count means answers FSRS never
    /// saw (Leitner while "Yeni zamanlama" was off, or an earlier build): the memory is out of
    /// date, and the next switch to FSRS, or the next FSRS answer, rebuilds it.
    public var reviews: Int
    /// The word's shelf (`ProgressSummary.Shelf` raw value, 0 for none) just before FSRS's own
    /// last answer; nil when the memory was rebuilt from older answers (`FSRSMigration`).
    public var shelfBefore: Int?

    public init(
        stability: Double,
        difficulty: Double,
        phase: FSRSCard.Phase,
        step: Int?,
        lastReviewAt: Date,
        reviews: Int,
        shelfBefore: Int?
    ) {
        self.stability = stability
        self.difficulty = difficulty
        self.phase = phase
        self.step = step
        self.lastReviewAt = lastReviewAt
        self.reviews = reviews
        self.shelfBefore = shelfBefore
    }

    /// Nil for a card without a memory (never answered).
    public init?(card: FSRSCard, reviews: Int, shelfBefore: Int?) {
        guard let memory = card.memory, let last = card.lastReviewAt else {
            return nil
        }
        self.init(
            stability: memory.stability,
            difficulty: memory.difficulty,
            phase: card.phase,
            step: card.step,
            lastReviewAt: last,
            reviews: reviews,
            shelfBefore: shelfBefore
        )
    }

    /// The card `FSRS.review` takes. Its `dueAt` is not kept here: the word's own `dueAt` is.
    public var card: FSRSCard {
        var c = FSRSCard()
        c.phase = phase
        c.step = step
        c.memory = FSRSMemory(stability: stability, difficulty: difficulty)
        c.lastReviewAt = lastReviewAt
        return c
    }

    /// Values a build can read but FSRS cannot use (out of range, not finite) make the whole
    /// memory unreadable: `WordProgress` then drops it, and an estimate takes its place.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        stability = try c.decode(Double.self, forKey: .stability)
        difficulty = try c.decode(Double.self, forKey: .difficulty)
        phase = try c.decode(FSRSCard.Phase.self, forKey: .phase)
        step = try c.decodeIfPresent(Int.self, forKey: .step)
        lastReviewAt = try c.decode(Date.self, forKey: .lastReviewAt)
        reviews = try c.decode(Int.self, forKey: .reviews)
        shelfBefore = try c.decodeIfPresent(Int.self, forKey: .shelfBefore)
        guard stability.isFinite, stability >= FSRS.minimumStability, difficulty.isFinite,
              FSRS.difficultyRange.contains(difficulty), reviews >= 0, (step ?? 0) >= 0 else {
            throw DecodingError.dataCorruptedError(forKey: .stability, in: c, debugDescription: "FSRS memory out of range")
        }
    }

    enum CodingKeys: String, CodingKey {
        case stability
        case difficulty
        case phase
        case step
        case lastReviewAt = "last_review_at"
        case reviews
        case shelfBefore = "shelf_before"
    }
}
