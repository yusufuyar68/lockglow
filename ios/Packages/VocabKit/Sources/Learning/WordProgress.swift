import Foundation

/// Where a word stands for this user.
public enum LearningState: String, Codable, Sendable {
    /// Never reviewed (it may have been seen on a widget; seeing is not reviewing).
    case new
    /// In the Leitner boxes.
    case learning
    /// Graduated from the last box, or the user said "I know this". Comes back rarely as a refresher.
    case known
}

/// Per-word learning record. App-private (never shared with the widget extension).
public struct WordProgress: Codable, Equatable, Sendable {
    public let wordID: Int
    public var state: LearningState
    /// Leitner box: 0 = never reviewed, otherwise 1...`Leitner.maxBox`.
    public var box: Int
    /// When the word should be reviewed next. Nil for words that were never reviewed.
    public var dueAt: Date?
    /// Passive views (widget, feed). Not reviews: they never move the word between boxes.
    public var exposures: Int
    public var lastSeenAt: Date?
    public var reviews: Int
    /// Wrong answers after the word had been reviewed at least once.
    public var lapses: Int
    /// The user tapped "I know this" (self-declared, not proven by a review).
    public var knownOverride: Bool
    public var saved: Bool

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
    }
}
