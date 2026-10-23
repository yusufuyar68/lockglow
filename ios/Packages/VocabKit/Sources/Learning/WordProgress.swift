import Foundation

/// Where a word stands for this user.
public enum LearningState: String, Codable, Sendable {
    /// Never reviewed (it may have been seen on a widget; seeing is not reviewing), or sent back
    /// by a failed "Biliyorum" check to be met again (`WordProgress.returnsToIntro`).
    case new
    /// In the Leitner boxes.
    case learning
    /// Graduated from the last box, or the user said "I know this" (asked once after
    /// `Leitner.knownCheckDelay`, see `WordProgress.awaitsKnownCheck`). Comes back rarely as a refresher.
    case known
}

/// Per-word learning record. App-private (never shared with the widget extension).
///
/// The last six fields came later. They are optional, so a progress file written before them
/// loads with nil, and they are left out of the file while nil, so such a file is written back
/// in its old shape. An earlier build ignores them when it reads a newer file.
public struct WordProgress: Codable, Equatable, Sendable {
    public let wordID: Int
    public var state: LearningState
    /// Leitner box: 0 = never reviewed (or back to "Tanış"), otherwise 1...`Leitner.maxBox`.
    public var box: Int
    /// When the word should be reviewed next. Nil for words that were never reviewed.
    public var dueAt: Date?
    /// Passive views (widget, feed). Not reviews: they never move the word between boxes.
    public var exposures: Int
    /// The last answer, widget tap or "Biliyorum", whichever came last.
    public var lastSeenAt: Date?
    public var reviews: Int
    /// Wrong answers after the word had been reviewed at least once.
    public var lapses: Int
    /// The user tapped "I know this" (self-declared, not proven by a review). Cleared once a
    /// review proves it, or proves it wrong.
    public var knownOverride: Bool
    public var saved: Bool
    /// When the word was last answered, exactly (`Leitner.review`). Unlike `lastSeenAt`, widget
    /// taps and "Biliyorum" never move it. Nil for a word not answered since this field exists.
    /// It is the answer applied last, like `dueAt`: a widget "Bilmiyorum" that reaches the app
    /// after a later answer in "Tekrar" brings its own, earlier time.
    public var lastReviewedAt: Date?
    /// The grade of that last answer; nil exactly when `lastReviewedAt` is.
    public var lastGrade: ReviewGrade?
    /// When the word was answered for the first time. Only a first answer sets it, so it stays
    /// nil for a word first answered before this field existed.
    public var firstReviewedAt: Date?
    /// A known word's step in `Leitner.refresherDays`: one step on after each correct refresher.
    /// Nil is step 0, the first refresher wait (and every word that is not known).
    public var refresherStep: Int?
    /// The word's FSRS memory (`FSRSScheduler`); nil until FSRS has one. Leitner leaves it as it
    /// was: once Leitner answers, its answer count no longer matches and it is rebuilt.
    public var fsrs: FSRSState?

    public init(wordID: Int) {
        self.wordID = wordID
        self.state = .new
        self.box = 0
        self.dueAt = nil
        self.exposures = 0
        self.lastSeenAt = nil
        self.reviews = 0
        self.lapses = 0
        self.knownOverride = false
        self.saved = false
        self.lastReviewedAt = nil
        self.lastGrade = nil
        self.firstReviewedAt = nil
        self.refresherStep = nil
        self.fsrs = nil
    }

    /// The fields every build wrote are read strictly, as before. A later field whose value this
    /// build cannot read (a grade a newer build added, say) becomes nil: losing it only brings
    /// back an estimate, while a throw here would set the whole file aside (`ProgressStore`).
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        wordID = try c.decode(Int.self, forKey: .wordID)
        state = try c.decode(LearningState.self, forKey: .state)
        box = try c.decode(Int.self, forKey: .box)
        dueAt = try c.decodeIfPresent(Date.self, forKey: .dueAt)
        exposures = try c.decode(Int.self, forKey: .exposures)
        lastSeenAt = try c.decodeIfPresent(Date.self, forKey: .lastSeenAt)
        reviews = try c.decode(Int.self, forKey: .reviews)
        lapses = try c.decode(Int.self, forKey: .lapses)
        knownOverride = try c.decode(Bool.self, forKey: .knownOverride)
        saved = try c.decode(Bool.self, forKey: .saved)
        lastReviewedAt = try? c.decodeIfPresent(Date.self, forKey: .lastReviewedAt)
        lastGrade = try? c.decodeIfPresent(ReviewGrade.self, forKey: .lastGrade)
        firstReviewedAt = try? c.decodeIfPresent(Date.self, forKey: .firstReviewedAt)
        refresherStep = try? c.decodeIfPresent(Int.self, forKey: .refresherStep)
        fsrs = try? c.decodeIfPresent(FSRSState.self, forKey: .fsrs)
    }

    /// True when the word should come back now: a learning word whose review is due, or a
    /// known word whose refresher is due.
    public func isDue(at date: Date) -> Bool {
        guard let due = dueAt else {
            return false
        }
        switch state {
        case .learning, .known:
            return due <= date
        case .new:
            return false
        }
    }

    /// "Biliyorum" was tapped and the one check after it has not been answered yet: the word's
    /// next due date asks it with the recall question, and a wrong answer sends it back to
    /// "Tanış". Also true for words marked before the check existed (they waited 30 days): their
    /// next due date brings the same check (docs/tasarim/ogrenme_ilkeleri.md 2.2, rule 4).
    public var awaitsKnownCheck: Bool {
        return state == .known && knownOverride
    }

    /// A failed "Biliyorum" check sent the word back: new again, but already reviewed. It comes
    /// first in the next "Tanış" (`ReviewPlanner.introWords`).
    public var returnsToIntro: Bool {
        return state == .new && reviews > 0
    }

    enum CodingKeys: String, CodingKey {
        case wordID = "word_id"
        case state
        case box
        case dueAt = "due_at"
        case exposures
        case lastSeenAt = "last_seen_at"
        case reviews
        case lapses
        case knownOverride = "known_override"
        case saved
        case lastReviewedAt = "last_reviewed_at"
        case lastGrade = "last_grade"
        case firstReviewedAt = "first_reviewed_at"
        case refresherStep = "refresher_step"
        case fsrs
    }
}
