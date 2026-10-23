import XCTest
import CoreModels
import Learning

/// The quiz widget's questions (`QuizWidgetQuestions`) and its answers as progress: an answer is an
/// exposure, never a grade (`ProgressIngest`, `WidgetEventType.quiz`).
final class QuizWidgetQuestionsTests: XCTestCase {
    /// 2023-11-14T22:13:20Z; `utc` makes "today" start at 00:00 UTC whatever the test machine's zone.
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let day: TimeInterval = 86_400
    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func card(
        _ id: Int,
        _ lemma: String,
        _ gloss: String?,
        pos: String = "verb",
        level: String = "A2",
        short: String? = nil,
        sensitivity: Int? = nil,
        confusable: [Int]? = nil
    ) -> WidgetWord {
        return WidgetWord(
            id: id, lemma: lemma, pos: pos, level: level, defMicro: "m", defShort: "s", exampleEN: "e",
            glossTR: gloss, glossShortTR: short, sensitivity: sensitivity, confusableIDs: confusable
        )
    }

    private lazy var borrow = card(1, "borrow", "ödünç almak", confusable: [2])
    private lazy var cards: [WidgetWord] = [
        borrow,
        card(2, "lend", "ödünç vermek", confusable: [1]),
        card(3, "buy", "satın almak, almak", short: "satın almak"),
        card(4, "pay", "ödemek"),
        card(5, "sell", "satmak"),
        card(6, "borrow", "alıntı yapmak"), // another sense of the same headword
        card(7, "spoon", "kaşık", pos: "noun"),
        card(8, "get", "almak"),
        card(9, "cook", "pişirmek"),
        card(10, "swim", "yüzmek", level: "B1"),
        card(11, "divorce", "boşanmak", sensitivity: 1), // a personal-topic card
        card(12, "save", "biriktirmek"),
    ]
    private let topics: [Int: Set<String>] = [
        1: ["money"], 2: ["money"], 3: ["money", "shopping"], 4: ["money"], 5: ["shopping"],
        6: ["school"], 7: ["kitchen"], 8: ["daily"], 9: ["food"], 10: ["sport"], 11: ["money"], 12: ["money"],
    ]

    private func question(_ word: WidgetWord, attempt: Int = 1, candidates: [WidgetWord]? = nil) -> MeaningChoice? {
        return QuizWidgetQuestions.question(for: word, attempt: attempt, candidates: candidates ?? cards, topicsOf: topics)
    }

    // MARK: An answer is an exposure

    func testAQuizAnswerIsAnExposureOnly() throws {
        let reviewed = Leitner.review(WordProgress(wordID: 3), grade: .good, at: now.addingTimeInterval(-day))
        let events = [
            LearningEvent(type: .quiz, wordID: 1, at: now),
            LearningEvent(type: .quiz, wordID: 3, at: now.addingTimeInterval(5)),
        ]
        let (result, answers) = ProgressIngest.applyLogged(events, to: [3: reviewed])
        // Never an answer in the review log, whatever was chosen on the widget.
        XCTAssertTrue(answers.isEmpty)
        let fresh = try XCTUnwrap(result[1])
        XCTAssertEqual(fresh.state, .new)
        XCTAssertEqual(fresh.exposures, 1)
        XCTAssertEqual(fresh.lastSeenAt, now)
        XCTAssertEqual(fresh.reviews, 0)
        XCTAssertNil(fresh.dueAt)
        let learning = try XCTUnwrap(result[3])
        XCTAssertEqual(learning.exposures, reviewed.exposures + 1)
        XCTAssertEqual(learning.lastSeenAt, now.addingTimeInterval(5))
        // "Tekrar" keeps its schedule: box, due date and the last answer are untouched.
        XCTAssertEqual(learning.state, reviewed.state)
        XCTAssertEqual(learning.box, reviewed.box)
        XCTAssertEqual(learning.dueAt, reviewed.dueAt)
        XCTAssertEqual(learning.reviews, reviewed.reviews)
        XCTAssertEqual(learning.lastReviewedAt, reviewed.lastReviewedAt)
        XCTAssertEqual(learning.lastGrade, reviewed.lastGrade)
    }

    // MARK: Options

    func testThreeTurkishOptionsFromOtherCardsOfTheSameTopic() throws {
        let q = try XCTUnwrap(question(borrow))
        XCTAssertEqual(q.wordID, 1)
        XCTAssertEqual(q.options.count, QuizWidgetQuestions.optionCount)
        XCTAssertEqual(q.options[q.answerIndex], "ödünç almak")
        XCTAssertEqual(Set(q.options).count, 3)
        // Same part of speech sharing the topic "money"; never the confusable partner "lend",
        // never the personal-topic "divorce", never another sense of "borrow".
        XCTAssertTrue(Set(q.options).isSubset(of: ["ödünç almak", "satın almak, almak", "ödemek", "biriktirmek"]), "\(q.options)")
        XCTAssertEqual(q.optionWords[q.answerIndex], "borrow")
        for (index, option) in q.options.enumerated() where index != q.answerIndex {
            XCTAssertNotEqual(q.optionWords[index], "", option)
        }
        XCTAssertEqual(q.shortOptions.count, 3)
        if let buy = q.options.firstIndex(of: "satın almak, almak") {
            XCTAssertEqual(q.shortOptions[buy], "satın almak")
            XCTAssertEqual(q.optionWords[buy], "buy")
        }
    }

    func testAConfusablePartnerIsNeverAnOptionInEitherDirection() throws {
        // Only "lend" names the pair here.
        let plainBorrow = card(1, "borrow", "ödünç almak")
        for attempt in 1...4 {
            let q = try XCTUnwrap(question(plainBorrow, attempt: attempt))
            XCTAssertFalse(q.options.contains("ödünç vermek"), "attempt \(attempt): \(q.options)")
        }
        let lend = try XCTUnwrap(question(cards[1]))
        XCTAssertFalse(lend.options.contains("ödünç almak"), "\(lend.options)")
    }

    func testPersonalTopicCardsNeverGiveAnOption() throws {
        // Only "divorce" shares the topic: the options come from the same level instead.
        let topics: [Int: Set<String>] = [1: ["love"], 11: ["love"]]
        let q = try XCTUnwrap(QuizWidgetQuestions.question(for: borrow, attempt: 1, candidates: cards, topicsOf: topics))
        XCTAssertFalse(q.options.contains("boşanmak"))
    }

    func testNoTwoOptionsShareAMeaning() throws {
        // "get" = "almak": "buy" ("satın almak, almak") names it too and is left out.
        for attempt in 1...4 {
            let q = try XCTUnwrap(question(cards[7], attempt: attempt))
            XCTAssertEqual(q.options[q.answerIndex], "almak")
            XCTAssertFalse(q.options.contains("satın almak, almak"), "\(q.options)")
        }
        // A short form counts as well: an option whose short form is the answer is left out.
        let pick = card(20, "pick", "seçmek", level: "B1")
        let choose = card(21, "choose", "seçim yapmak", level: "B1", short: "seçmek")
        let others = [pick, choose, card(22, "win", "kazanmak", level: "B1"), card(23, "lose", "kaybetmek", level: "B1")]
        let q = try XCTUnwrap(QuizWidgetQuestions.question(for: pick, attempt: 1, candidates: others, topicsOf: [:]))
        XCTAssertFalse(q.options.contains("seçim yapmak"), "\(q.options)")
    }

    func testTooFewOptionsGiveNoQuestion() {
        // Only one other verb of the same level: two options are not enough.
        let few = [borrow, card(4, "pay", "ödemek"), card(7, "spoon", "kaşık", pos: "noun")]
        XCTAssertNil(question(borrow, candidates: few))
        XCTAssertNil(question(card(30, "empty", nil)))
        XCTAssertNil(question(card(31, " ", "boş")))
    }

    func testTheAnswerMovesFromOneAttemptToTheNext() throws {
        for attempt in 1...6 {
            let first = try XCTUnwrap(question(borrow, attempt: attempt))
            let second = try XCTUnwrap(question(borrow, attempt: attempt + 1))
            XCTAssertEqual(Set(first.options), Set(second.options))
            XCTAssertNotEqual(first.answerIndex, second.answerIndex, "attempt \(attempt)")
        }
        // Over three attempts in a row the answer stands once in each place.
        for attempt in 1...4 {
            let places = try (attempt..<(attempt + 3)).map { try XCTUnwrap(question(borrow, attempt: $0)).answerIndex }
            XCTAssertEqual(Set(places), [0, 1, 2], "from attempt \(attempt)")
        }
        // The same attempt is the same question on every device and launch.
        XCTAssertEqual(question(borrow, attempt: 3), question(borrow, attempt: 3))
    }

    func testAWordTooLongForTheNarrowBoxIsNeitherAnOptionNorAsked() throws {
        // "dolandırıcılık" (14 letters) has no shorter form: never an option, never asked.
        let scam = card(50, "scam", "dolandırıcılık", pos: "noun")
        let nouns = [
            card(51, "spoon", "kaşık", pos: "noun"), card(52, "fork", "çatal", pos: "noun"),
            scam, card(53, "plate", "tabak", pos: "noun"), card(54, "cup", "fincan", pos: "noun"),
        ]
        for attempt in 1...3 {
            let q = try XCTUnwrap(QuizWidgetQuestions.question(for: nouns[0], attempt: attempt, candidates: nouns, topicsOf: [:]))
            XCTAssertFalse(q.options.contains("dolandırıcılık"), "\(q.options)")
        }
        XCTAssertNil(QuizWidgetQuestions.question(for: scam, attempt: 1, candidates: nouns, topicsOf: [:]))
        // A long meaning with a short form that fits, or a first sense that fits, is fine.
        XCTAssertTrue(QuizWidgetQuestions.fitsNarrowBox("kendini pek iyi hissetmemek", short: "biraz rahatsız"))
        XCTAssertTrue(QuizWidgetQuestions.fitsNarrowBox("aslında, gerçekte", short: nil))
        XCTAssertTrue(QuizWidgetQuestions.fitsNarrowBox("sabırsızlanıyorum", short: "iple çekiyorum"))
        XCTAssertFalse(QuizWidgetQuestions.fitsNarrowBox("sabırsızlanıyorum", short: nil))
        XCTAssertFalse(QuizWidgetQuestions.fitsNarrowBox("fotoğrafçılık", short: nil))
    }

    // MARK: Which words

    func testOnlyMetWordsTheOneMetLongestAgoFirstAndTekrarIsNeverAnsweredEarly() throws {
        let newWord = card(40, "window", "pencere", pos: "noun")
        let answeredToday = card(41, "door", "kapı", pos: "noun")
        let personal = card(42, "crush", "hoşlanmak", sensitivity: 1)
        let dueSoon = card(43, "chair", "sandalye", pos: "noun")
        let claimed = card(44, "table", "masa", pos: "noun")
        let seenOnWidget = card(45, "floor", "zemin", pos: "noun")
        let dueLater = card(46, "wall", "duvar", pos: "noun")
        let noMeaning = card(47, "roof", nil, pos: "noun")
        let refresher = card(48, "garden", "bahçe", pos: "noun")
        let queue = [newWord, answeredToday, personal, dueSoon, claimed, seenOnWidget, dueLater, noMeaning, refresher, newWord]

        var progress: [Int: WordProgress] = [:]
        // A wrong answer 30 minutes ago: due again in "Tekrar" now, but answered today.
        progress[41] = Leitner.review(WordProgress(wordID: 41), grade: .again, at: now.addingTimeInterval(-1800))
        // Answered yesterday, due in an hour: "Tekrar" asks it soon.
        progress[43] = Leitner.review(WordProgress(wordID: 43), grade: .good, at: now.addingTimeInterval(-23 * 3600))
        // "Biliyorum" yesterday: waits for its one check.
        progress[44] = Leitner.markKnown(WordProgress(wordID: 44), at: now.addingTimeInterval(-day))
        // Seen on the widget only: still a new word, but met.
        progress[45] = Leitner.markExposure(WordProgress(wordID: 45), at: now.addingTimeInterval(-3600))
        var later = WordProgress(wordID: 46)
        later.state = .learning
        later.box = 2
        later.reviews = 3
        later.dueAt = now.addingTimeInterval(2 * day)
        later.lastReviewedAt = now.addingTimeInterval(-2 * day)
        later.lastSeenAt = now.addingTimeInterval(-2 * day)
        later.lastGrade = .good
        progress[46] = later
        var known = WordProgress(wordID: 48)
        known.state = .known
        known.box = 5
        known.reviews = 6
        known.dueAt = now.addingTimeInterval(10 * day)
        known.lastSeenAt = now.addingTimeInterval(-20 * day)
        progress[48] = known

        // Never seen: "window" is not asked (its meaning comes first on the widget and in "Tanış").
        let words = QuizWidgetQuestions.words(from: queue, progress: progress, now: now, calendar: utc)
        XCTAssertEqual(words.map { $0.lemma }, ["garden", "wall", "floor", "door"])
        XCTAssertFalse(QuizWidgetQuestions.isMet(WordProgress(wordID: 40)))
        XCTAssertTrue(QuizWidgetQuestions.isMet(try XCTUnwrap(progress[45])))

        // The moment each question stops being asked: six hours before "Tekrar" asks the word; a
        // word answered today until the end of the day.
        let endOfToday = try XCTUnwrap(utc.date(from: DateComponents(year: 2023, month: 11, day: 15)))
        XCTAssertEqual(QuizWidgetQuestions.askUntil(of: try XCTUnwrap(progress[41]), now: now, calendar: utc), endOfToday)
        XCTAssertEqual(QuizWidgetQuestions.askUntil(of: later, now: now, calendar: utc), now.addingTimeInterval(2 * day - 6 * 3600))
        XCTAssertEqual(QuizWidgetQuestions.askUntil(of: known, now: now, calendar: utc), now.addingTimeInterval(10 * day - 6 * 3600))
        XCTAssertNil(QuizWidgetQuestions.askUntil(of: try XCTUnwrap(progress[45]), now: now, calendar: utc))

        XCTAssertTrue(QuizWidgetQuestions.isAsked(answeredToday, progress: progress[41], now: now, calendar: utc))
        XCTAssertFalse(QuizWidgetQuestions.isAsked(dueSoon, progress: progress[43], now: now, calendar: utc))
        // Six hours earlier its review was seven hours away: then it could be asked.
        XCTAssertTrue(QuizWidgetQuestions.isAsked(dueSoon, progress: progress[43], now: now.addingTimeInterval(-6 * 3600), calendar: utc))
        XCTAssertFalse(QuizWidgetQuestions.isAsked(claimed, progress: progress[44], now: now, calendar: utc))
        XCTAssertFalse(QuizWidgetQuestions.isAsked(personal, progress: nil, now: now, calendar: utc))
        XCTAssertFalse(QuizWidgetQuestions.isAsked(noMeaning, progress: nil, now: now, calendar: utc))
        // A refresher due within six hours waits for "Tekrar" too.
        var soonRefresher = known
        soonRefresher.dueAt = now.addingTimeInterval(3600)
        XCTAssertFalse(QuizWidgetQuestions.isAsked(refresher, progress: soonRefresher, now: now, calendar: utc))
    }
}
