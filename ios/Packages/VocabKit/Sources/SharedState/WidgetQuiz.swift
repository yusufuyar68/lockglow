import Foundation

// The quiz widget ("Bu kelime ne demek?", ios/Widgets/QuizWidget.swift): an English word and
// three Turkish options on the Home Screen. Two App Group files, with the same single-writer rule
// as the word widget (contract section 6):
// - `widget_quiz.json` (`WidgetQuizPlan`): the questions. Written ONLY by the app, every time it
//   writes the widget plan (App/AppModel+QuizWidget.swift).
// - `widget_quiz_state.json` (`WidgetQuizState`): the question on screen and its answer. Written
//   ONLY by the quiz widget's buttons (ios/Widgets/QuizActions.swift).
// An answer also appends a `quiz` event to the mailbox. Seeing the answer is not a review: the
// app counts it as an exposure only (`ProgressIngest`), never as a grade.
// `WidgetQuizRotation` is the pure logic both sides share.

/// `widget_quiz.json`. Written ONLY by the app, read by the quiz widget.
public struct WidgetQuizPlan: Codable, Equatable, Sendable {
    public static let currentVersion = 1

    public var version: Int
    /// Changes every time the app writes the file. A state of an older file still counts for its
    /// word when that word is the first question (`WidgetQuizRotation`).
    public var quizID: String
    /// The word widget's change interval (`interval_seconds` of the widget plan): an answer stays
    /// this long before the next question comes by itself (at least
    /// `WidgetQuizRotation.minimumHoldSeconds`).
    public var intervalSeconds: Int
    /// The questions in the order they are asked. The first is the question that was on screen
    /// when the app wrote the file, while it is still asked.
    public var items: [WidgetQuizItem]
    public var updatedAt: Date

    public init(
        version: Int = WidgetQuizPlan.currentVersion,
        quizID: String,
        intervalSeconds: Int,
        items: [WidgetQuizItem],
        updatedAt: Date = Date()
    ) {
        self.version = version
        self.quizID = quizID
        self.intervalSeconds = intervalSeconds
        self.items = items
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case version
        case quizID = "quiz_id"
        case intervalSeconds = "interval_seconds"
        case items
        case updatedAt = "updated_at"
    }
}

/// One question: an English word and its Turkish options, ready to draw. The widget never builds
/// options itself: they come from the app, which knows the cards, the topics and the progress.
public struct WidgetQuizItem: Codable, Equatable, Sendable {
    public var wordID: Int
    public var lemma: String
    public var ipaUS: String?
    /// A sentence with the word, shown after the answer where there is room (large widget).
    public var exampleEN: String?
    /// The Turkish options in the order shown: the word's own meaning and other cards' meanings.
    public var options: [String]
    /// The index of the word's own meaning in `options`.
    public var answerIndex: Int
    /// The short form of each option (`gloss_short`), for a widget that has no room for the whole
    /// one. Nil, or a nil entry, when an option has none.
    public var shortOptions: [String?]?
    /// The English word each option is the meaning of (the word itself for the answer), for
    /// "Senin seçtiğin: izin vermek = allow". Nil, or a nil entry, when it is not known.
    public var optionWords: [String?]?

    public init(
        wordID: Int,
        lemma: String,
        ipaUS: String? = nil,
        exampleEN: String? = nil,
        options: [String],
        answerIndex: Int,
        shortOptions: [String?]? = nil,
        optionWords: [String?]? = nil
    ) {
        self.wordID = wordID
        self.lemma = lemma
        self.ipaUS = ipaUS
        self.exampleEN = exampleEN
        self.options = options
        self.answerIndex = answerIndex
        self.shortOptions = shortOptions
        self.optionWords = optionWords
    }

    /// A word, at least two options, the answer among them and no empty option. The widget asks
    /// only such questions; a damaged one is passed over.
    public var isUsable: Bool {
        return !lemma.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && options.count >= 2
            && options.indices.contains(answerIndex)
            && options.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    /// The word's own meaning.
    public var answer: String? {
        return options.indices.contains(answerIndex) ? options[answerIndex] : nil
    }

    /// The short form of option `index`, nil when it has none or it is the whole option.
    public func shortOption(at index: Int) -> String? {
        guard let shorts = shortOptions, shorts.indices.contains(index),
              let short = shorts[index]?.trimmingCharacters(in: .whitespacesAndNewlines), !short.isEmpty,
              options.indices.contains(index), short != options[index] else {
            return nil
        }
        return short
    }

    /// The English word of option `index`, nil when it is not known.
    public func optionWord(at index: Int) -> String? {
        guard let words = optionWords, words.indices.contains(index),
              let word = words[index]?.trimmingCharacters(in: .whitespacesAndNewlines), !word.isEmpty else {
            return nil
        }
        return word
    }

    enum CodingKeys: String, CodingKey {
        case wordID = "word_id"
        case lemma
        case ipaUS = "ipa_us"
        case exampleEN = "example_en"
        case options
        case answerIndex = "answer_index"
        case shortOptions = "short_options"
        case optionWords = "option_words"
    }
}

/// `widget_quiz_state.json`. Written ONLY by the quiz widget's buttons, read by the widget and
/// the app (which keeps the question on screen first when it writes new questions).
public struct WidgetQuizState: Codable, Equatable, Sendable {
    public static let currentVersion = 1

    public var version: Int
    /// The `quizID` of the file the buttons acted on.
    public var quizID: String
    /// The question on screen (its word id): the questions rotate by word, so a new file that
    /// still asks this word in first place keeps it on screen.
    public var wordID: Int
    /// The option chosen for that question; nil before the answer.
    public var answer: WidgetQuizAnswer?
    public var updatedAt: Date

    public init(
        version: Int = WidgetQuizState.currentVersion,
        quizID: String,
        wordID: Int,
        answer: WidgetQuizAnswer? = nil,
        updatedAt: Date = Date()
    ) {
        self.version = version
        self.quizID = quizID
        self.wordID = wordID
        self.answer = answer
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case version
        case quizID = "quiz_id"
        case wordID = "word_id"
        case answer
        case updatedAt = "updated_at"
    }
}

/// The first option chosen for a question, and when.
public struct WidgetQuizAnswer: Codable, Equatable, Sendable {
    /// Index into the question's `options`.
    public var choice: Int
    /// Whole seconds, like every date in the App Group files.
    public var at: Date

    public init(choice: Int, at: Date) {
        self.choice = choice
        self.at = at
    }
}

/// What the quiz widget shows at one moment.
public struct WidgetQuizScreen: Equatable, Sendable {
    public let item: WidgetQuizItem
    /// The option chosen; nil while the question waits for an answer.
    public let choice: Int?

    public init(item: WidgetQuizItem, choice: Int?) {
        self.item = item
        self.choice = choice
    }

    public var isAnswered: Bool {
        return choice != nil
    }

    public var isRight: Bool {
        return choice == item.answerIndex
    }
}

/// The quiz widget's rotation. Pure and deterministic, shared by the widget (timeline, buttons)
/// and the app (which keeps the question on screen when it writes new questions).
///
/// - A question stays until it is answered: time alone never changes an unanswered question.
/// - The first answer stands: the right option is marked, and a chosen wrong one too, until
///   "Devam" or until the hold (`intervalSeconds`) is over; then the next question comes.
/// - The question the word widget shows at the same moment (`avoiding`) is passed over for the
///   one after it, so the two widgets never show a word and its own question side by side.
///   An answer on screen is never passed over: it already shows the meaning.
/// - The state belongs to one file (`quizID`). With a newer file it still counts when its word is
///   that file's first question: the app puts the question that was on screen first, the very
///   same item, so a rewrite never changes the question or its answer under the finger.
public enum WidgetQuizRotation {
    /// The shortest time an answer stays on screen.
    public static let minimumHoldSeconds = 300

    /// The usable questions of `plan`, in order (`WidgetQuizItem.isUsable`).
    public static func questions(of plan: WidgetQuizPlan?) -> [WidgetQuizItem] {
        return plan?.items.filter { $0.isUsable } ?? []
    }

    /// How long an answer stays before the next question comes by itself.
    public static func holdSeconds(of plan: WidgetQuizPlan) -> TimeInterval {
        return TimeInterval(max(plan.intervalSeconds, minimumHoldSeconds))
    }

    /// The screen at `date`; nil when there is no usable question.
    public static func screen(
        plan: WidgetQuizPlan?,
        state: WidgetQuizState?,
        at date: Date,
        avoiding avoidedWordID: Int? = nil
    ) -> WidgetQuizScreen? {
        guard let plan = plan else {
            return nil
        }
        let items = questions(of: plan)
        guard !items.isEmpty else {
            return nil
        }
        var (index, answer) = position(in: items, quizID: plan.quizID, state: state)
        if let given = answer, !stands(given, at: date, hold: holdSeconds(of: plan)) {
            index = (index + 1) % items.count
            answer = nil
        }
        if answer == nil, let avoided = avoidedWordID, items.count > 1, items[index].wordID == avoided {
            index = (index + 1) % items.count
        }
        return WidgetQuizScreen(item: items[index], choice: answer?.choice)
    }

    /// When the answer on screen gives way to the next question; nil without one.
    public static func answerExpiry(plan: WidgetQuizPlan?, state: WidgetQuizState?) -> Date? {
        guard let plan = plan else {
            return nil
        }
        let items = questions(of: plan)
        guard !items.isEmpty, let given = position(in: items, quizID: plan.quizID, state: state).answer else {
            return nil
        }
        return given.at.addingTimeInterval(holdSeconds(of: plan))
    }

    /// The state after option `choice` of the question about `wordID` is chosen at `date`; nil
    /// when nothing changes: the word is not asked, the option does not exist, or this question's
    /// first answer is still on screen (a second tap neither changes it nor counts again).
    public static func stateAfterAnswer(
        wordID: Int,
        choice: Int,
        plan: WidgetQuizPlan?,
        state: WidgetQuizState?,
        at date: Date
    ) -> WidgetQuizState? {
        guard let plan = plan else {
            return nil
        }
        let items = questions(of: plan)
        guard let item = items.first(where: { $0.wordID == wordID }), item.options.indices.contains(choice) else {
            return nil
        }
        let (index, answer) = position(in: items, quizID: plan.quizID, state: state)
        if let given = answer, items[index].wordID == wordID, stands(given, at: date, hold: holdSeconds(of: plan)) {
            return nil
        }
        return WidgetQuizState(
            quizID: plan.quizID,
            wordID: wordID,
            answer: WidgetQuizAnswer(choice: choice, at: date),
            updatedAt: date
        )
    }

    /// The state after "Devam" on the question about `wordID` at `date`: the question after it,
    /// not answered yet (after the last one the first). When that word is no longer asked, the
    /// question after the one the state points at. Nil without a usable question.
    public static func stateAfterNext(
        wordID: Int,
        plan: WidgetQuizPlan?,
        state: WidgetQuizState?,
        at date: Date
    ) -> WidgetQuizState? {
        guard let plan = plan else {
            return nil
        }
        let items = questions(of: plan)
        guard !items.isEmpty else {
            return nil
        }
        let current = items.firstIndex(where: { $0.wordID == wordID })
            ?? position(in: items, quizID: plan.quizID, state: state).index
        let next = items[(current + 1) % items.count]
        return WidgetQuizState(quizID: plan.quizID, wordID: next.wordID, answer: nil, updatedAt: date)
    }

    /// The questions of a new file: the question on screen (`shown`) first while it is still asked
    /// (`askedIDs`), the very same item so its options and its answer stay; then `items` without
    /// it, at most `limit` in all. When `items` has a question about the same word whose word or
    /// meaning changed (the user edited their own word), that one goes first instead.
    public static func keepingShown(
        _ shown: WidgetQuizItem?,
        before items: [WidgetQuizItem],
        askedIDs: Set<Int>,
        limit: Int
    ) -> [WidgetQuizItem] {
        guard limit > 0 else {
            return []
        }
        var result: [WidgetQuizItem] = []
        if let shown = shown, shown.isUsable, askedIDs.contains(shown.wordID) {
            if let fresh = items.first(where: { $0.wordID == shown.wordID }),
               fresh.lemma != shown.lemma || fresh.answer != shown.answer {
                result.append(fresh)
            } else {
                result.append(shown)
            }
        }
        var used = Set(result.map { $0.wordID })
        for item in items where result.count < limit {
            if used.insert(item.wordID).inserted {
                result.append(item)
            }
        }
        return result
    }

    // MARK: Helpers

    /// The question the state points at and its answer, before the hold and the avoided word are
    /// applied. Without a state, or with one for a word that is not asked, the first question.
    static func position(
        in items: [WidgetQuizItem],
        quizID: String,
        state: WidgetQuizState?
    ) -> (index: Int, answer: WidgetQuizAnswer?) {
        guard let state = state, let index = items.firstIndex(where: { $0.wordID == state.wordID }) else {
            return (0, nil)
        }
        // A state of an older file counts only for its first question (see the type's comment).
        guard state.quizID == quizID || index == 0 else {
            return (0, nil)
        }
        let answer = state.answer.flatMap { given in
            items[index].options.indices.contains(given.choice) ? given : nil
        }
        return (index, answer)
    }

    /// Whether an answer is still on screen at `date`. A date long before the answer (the clock
    /// was set back) ends it too, so an answer never stays for days.
    static func stands(_ answer: WidgetQuizAnswer, at date: Date, hold: TimeInterval) -> Bool {
        let elapsed = date.timeIntervalSince(answer.at)
        return elapsed < hold && elapsed > -hold
    }
}

// MARK: - Files

extension AppGroupStore {
    public static let quizPlanFileName = "widget_quiz.json"
    public static let quizStateFileName = "widget_quiz_state.json"

    public var quizPlanURL: URL {
        return containerURL.appendingPathComponent(AppGroupStore.quizPlanFileName)
    }

    public var quizStateURL: URL {
        return containerURL.appendingPathComponent(AppGroupStore.quizStateFileName)
    }

    /// The questions (app writes); nil when the file is missing or cannot be decoded.
    public func readQuizPlan() -> WidgetQuizPlan? {
        return readQuizFile(WidgetQuizPlan.self, from: quizPlanURL)
    }

    public func writeQuizPlan(_ plan: WidgetQuizPlan) throws {
        try writeQuizFile(plan, to: quizPlanURL)
    }

    /// The question on screen and its answer (quiz widget writes); nil when missing or damaged.
    public func readQuizState() -> WidgetQuizState? {
        return readQuizFile(WidgetQuizState.self, from: quizStateURL)
    }

    public func writeQuizState(_ state: WidgetQuizState) throws {
        try writeQuizFile(state, to: quizStateURL)
    }

    // The same conventions as the plan and state files (`JSONCoding`, `AtomicFile`).
    private func readQuizFile<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONCoding.makeDecoder().decode(type, from: data)
    }

    private func writeQuizFile<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try JSONCoding.makeEncoder().encode(value)
        try AtomicFile.write(data, to: url)
    }
}
