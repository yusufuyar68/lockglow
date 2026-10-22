import XCTest
import CoreModels
import Learning

/// "Tanış + Hatırla" (docs/tasarim/ogrenme_ilkeleri.md 2.3): the round, its two tries, the words
/// it takes and the options of its questions; and which question a due word gets (2.4).
final class IntroRoundTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let day: TimeInterval = 86_400

    private func meets(_ ids: [Int]) -> [IntroRound.Step] {
        return ids.map { .meet(wordID: $0) }
    }

    /// The round after every "Tanış" card was turned and passed.
    private func recalling(_ ids: [Int], seed: Int = 3) -> IntroRound {
        var round = IntroRound(wordIDs: ids, seed: seed)
        for _ in ids {
            round.next()
        }
        return round
    }

    private func currentID(_ round: IntroRound) -> Int? {
        return round.current?.wordID
    }

    // MARK: the round

    func testEveryWordIsMetThenAskedOnceInAMixedOrder() {
        for seed in 0..<40 {
            let round = IntroRound(wordIDs: [1, 2, 3, 4, 5], seed: seed)
            XCTAssertEqual(Array(round.steps.prefix(5)), meets([1, 2, 3, 4, 5]))
            let questions = Array(round.steps.dropFirst(5))
            XCTAssertEqual(questions.count, 5)
            XCTAssertEqual(Set(questions.map { $0.wordID }), [1, 2, 3, 4, 5])
            XCTAssertTrue(questions.allSatisfy { step in
                if case .recall(_, 1) = step {
                    return true
                }
                return false
            })
            // The word met last is never asked first, right after its meaning.
            XCTAssertNotEqual(questions.first?.wordID, 5, "seed \(seed)")
        }
        let orders = Set((0..<40).map { IntroRound(wordIDs: [1, 2, 3, 4, 5], seed: $0).steps.map { $0.wordID } })
        XCTAssertGreaterThan(orders.count, 1, "the order is mixed, not fixed")
    }

    func testTheKindOfQuestionAlternates() {
        let round = IntroRound(wordIDs: [1, 2, 3, 4, 5], seed: 11)
        let kinds = round.steps.dropFirst(5).compactMap { round.directions[$0.wordID] }
        XCTAssertEqual(kinds, [.pickMeaning, .pickEnglish, .pickMeaning, .pickEnglish, .pickMeaning])
    }

    func testTheSameSeedGivesTheSameRoundAndDuplicatesAreDropped() {
        XCTAssertEqual(IntroRound(wordIDs: [4, 8, 15], seed: 9), IntroRound(wordIDs: [4, 8, 15], seed: 9))
        let round = IntroRound(wordIDs: [4, 8, 4, 15], seed: 9)
        XCTAssertEqual(round.steps.count, 6)
        XCTAssertEqual(Array(round.steps.prefix(3)), meets([4, 8, 15]))
    }

    func testRightFirstTimeEndsTheRound() {
        var round = recalling([1, 2, 3])
        XCTAssertEqual(round.position, 3)
        var decided: [IntroRound.Result] = []
        while round.current != nil {
            if let result = round.answer(right: true) {
                decided.append(result)
            }
        }
        XCTAssertEqual(decided, [.firstTry, .firstTry, .firstTry])
        XCTAssertEqual(round.results, [1: .firstTry, 2: .firstTry, 3: .firstTry])
        XCTAssertTrue(round.isFinished)
        XCTAssertEqual(round.steps.count, 6)
    }

    func testAWrongAnswerComesBackThreeCardsLaterAndIsRightTheSecondTime() throws {
        var round = recalling([1, 2, 3, 4, 5])
        let first = try XCTUnwrap(currentID(round))
        XCTAssertNil(round.answer(right: false), "not decided yet")
        XCTAssertEqual(round.awaitingRetry, [first])
        XCTAssertEqual(round.steps[round.position + 3], .recall(wordID: first, attempt: 2))
        for _ in 0..<3 {
            XCTAssertNotEqual(currentID(round), first, "never right after the wrong answer")
            round.answer(right: true)
        }
        XCTAssertEqual(round.current, .recall(wordID: first, attempt: 2))
        XCTAssertEqual(round.answer(right: true), .secondTry)
        XCTAssertEqual(round.awaitingRetry, [])
        while round.current != nil {
            round.answer(right: true)
        }
        XCTAssertEqual(round.results[first], .secondTry)
        XCTAssertEqual(round.steps.count, 11)
    }

    func testASecondWrongAnswerEndsTheWordsRound() throws {
        var round = recalling([1, 2, 3, 4, 5])
        let first = try XCTUnwrap(currentID(round))
        round.answer(right: false)
        while round.current != .recall(wordID: first, attempt: 2) {
            round.answer(right: true)
        }
        XCTAssertEqual(round.answer(right: false), .missed)
        XCTAssertFalse(round.steps.contains(.recall(wordID: first, attempt: 3)), "at most two tries")
        while round.current != nil {
            round.answer(right: true)
        }
        XCTAssertTrue(round.isFinished)
        XCTAssertEqual(round.results[first], .missed)
        XCTAssertEqual(round.steps.count, 11)
    }

    func testTheRetryGoesLastWhenFewerThanThreeCardsAreLeft() throws {
        var round = recalling([1, 2, 3, 4, 5])
        for _ in 0..<3 {
            round.answer(right: true)
        }
        let fourth = try XCTUnwrap(currentID(round))
        round.answer(right: false)
        XCTAssertEqual(round.steps.last, .recall(wordID: fourth, attempt: 2))
        XCTAssertNotEqual(currentID(round), fourth)
        round.answer(right: true)
        XCTAssertEqual(round.current, .recall(wordID: fourth, attempt: 2))
    }

    func testTheOnlyWordIsAskedAgainRightAway() {
        var round = recalling([9])
        XCTAssertNil(round.answer(right: false))
        XCTAssertEqual(round.current, .recall(wordID: 9, attempt: 2))
        XCTAssertEqual(round.answer(right: false), .missed)
        XCTAssertTrue(round.isFinished)
    }

    func testEveryWrongAnswerEndsWithinTwoTries() {
        var round = recalling([1, 2, 3, 4, 5, 6, 7])
        var answers = 0
        while round.current != nil {
            round.answer(right: false)
            answers += 1
            XCTAssertLessThanOrEqual(answers, 14)
        }
        XCTAssertEqual(answers, 14)
        XCTAssertTrue(round.results.values.allSatisfy { $0 == .missed })
        XCTAssertEqual(round.results.count, 7)
    }

    func testStepsOnlyMoveWithTheirOwnButton() {
        var round = IntroRound(wordIDs: [1, 2], seed: 1)
        XCTAssertNil(round.answer(right: true), "a Tanış card has no answer")
        XCTAssertEqual(round.position, 0)
        round.next()
        round.next()
        XCTAssertEqual(round.position, 2)
        round.next()
        XCTAssertEqual(round.position, 2, "a question needs an answer, not Sonraki")
    }

    func testBunuZatenBiliyorumTakesTheWordOut() {
        var round = IntroRound(wordIDs: [1, 2, 3], seed: 5)
        round.next()
        round.skipCurrent()
        XCTAssertEqual(round.skipped, [2])
        XCTAssertEqual(round.current, .meet(wordID: 3))
        XCTAssertFalse(round.steps.contains { $0.wordID == 2 }, "no question for a skipped word")
        XCTAssertEqual(round.steps.count, 4)

        // "Geri al" while the next card is untouched: the word's card comes back at once.
        round.restore(2, showNow: true)
        XCTAssertEqual(round.current, .meet(wordID: 2))
        XCTAssertEqual(round.steps.last, .recall(wordID: 2, attempt: 1))
        XCTAssertEqual(round.skipped, [])
        XCTAssertEqual(round.steps.count, 6)
    }

    func testGeriAlAfterTheNextCardWasTouchedComesRightAfterIt() {
        var round = IntroRound(wordIDs: [1, 2, 3], seed: 5)
        round.skipCurrent()
        XCTAssertEqual(round.current, .meet(wordID: 2))
        round.restore(1, showNow: false)
        XCTAssertEqual(round.current, .meet(wordID: 2))
        XCTAssertEqual(round.steps[round.position + 1], .meet(wordID: 1))
        round.restore(1, showNow: true)
        XCTAssertEqual(round.steps.filter { $0 == .meet(wordID: 1) }.count, 1, "restored once")
    }

    func testSkippingTheLastWordEndsTheRound() {
        var round = IntroRound(wordIDs: [7], seed: 0)
        round.skipCurrent()
        XCTAssertTrue(round.isFinished)
        XCTAssertTrue(round.results.isEmpty)
        round.restore(7, showNow: true)
        XCTAssertEqual(round.current, .meet(wordID: 7))
        XCTAssertEqual(round.steps, [.meet(wordID: 7), .recall(wordID: 7, attempt: 1)])
    }

    func testTheGradeComesFromTheAnswers() {
        XCTAssertEqual(IntroRound.Result.firstTry.grade, .good)
        XCTAssertEqual(IntroRound.Result.secondTry.grade, .hard)
        XCTAssertEqual(IntroRound.Result.missed.grade, .again)
        XCTAssertTrue(IntroRound.Result.secondTry.passed)
        XCTAssertFalse(IntroRound.Result.missed.passed)

        let new = WordProgress(wordID: 1)
        let first = Leitner.review(new, grade: IntroRound.Result.firstTry.grade, at: now)
        XCTAssertEqual(first.box, 1)
        XCTAssertEqual(first.dueAt, now.addingTimeInterval(day))
        let second = Leitner.review(new, grade: IntroRound.Result.secondTry.grade, at: now)
        XCTAssertEqual(second.box, 1)
        XCTAssertEqual(second.dueAt, now.addingTimeInterval(day / 2))
        let missed = Leitner.review(new, grade: IntroRound.Result.missed.grade, at: now)
        XCTAssertEqual(missed.box, 1)
        XCTAssertEqual(missed.lapses, 0)
        XCTAssertEqual(missed.dueAt, now.addingTimeInterval(10 * 60))
    }

    // MARK: which words, which question

    private func word(_ id: Int) -> WidgetWord {
        return WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e")
    }

    func testIntroWordsTakeReturnedWordsFirstThenTheFeedsNewWords() {
        var returned = Leitner.review(Leitner.markKnown(WordProgress(wordID: 2), at: now), grade: .again, at: now)
        XCTAssertTrue(returned.returnsToIntro)
        returned.lastSeenAt = now
        var older = Leitner.review(Leitner.markKnown(WordProgress(wordID: 9), at: now), grade: .again, at: now)
        older.lastSeenAt = now.addingTimeInterval(-day)
        var learning = WordProgress(wordID: 3)
        learning.state = .learning
        learning.box = 1
        let progress = [2: returned, 9: older, 3: learning, 4: Leitner.markKnown(WordProgress(wordID: 4), at: now)]
        let feed = (1...6).map { word($0) }
        let all = (1...10).map { word($0) }

        // 9 is outside the deck but was sent back by its check: it still comes, first.
        let ids = ReviewPlanner.introWords(feed: feed, all: all, progress: progress, limit: 4).map { $0.id }
        XCTAssertEqual(ids, [9, 2, 1, 5])
        XCTAssertEqual(ReviewPlanner.introWords(feed: feed, all: all, progress: progress, limit: 10).map { $0.id }, [9, 2, 1, 5, 6])
        XCTAssertTrue(ReviewPlanner.introWords(feed: feed, all: all, progress: progress, limit: 0).isEmpty)
        XCTAssertEqual(ReviewPlanner.introWords(feed: feed, all: all, progress: [:], limit: 3).map { $0.id }, [1, 2, 3])
    }

    func testConfusableWordsAreNotLearnedTogether() {
        let feed = (1...5).map { word($0) }
        let pairs: [Int: Set<Int>] = [1: [3], 3: [1]]
        func ids(_ progress: [Int: WordProgress]) -> [Int] {
            return ReviewPlanner.introWords(feed: feed, all: feed, progress: progress, limit: 3, confusables: pairs).map { $0.id }
        }
        // Never both in one round.
        XCTAssertEqual(ids([:]), [1, 2, 4])
        // Not while the first is still learning below box 2 (the same day, the next days).
        var first = Leitner.review(WordProgress(wordID: 1), grade: .good, at: now)
        XCTAssertEqual(ids([1: first]), [2, 4, 5])
        // Once it reached box 2, the second comes.
        first = Leitner.review(first, grade: .good, at: now.addingTimeInterval(day))
        XCTAssertEqual(first.box, 2)
        XCTAssertEqual(ids([1: first]), [2, 3, 4])
        // A known partner does not hold it back either.
        XCTAssertEqual(ids([1: Leitner.markKnown(WordProgress(wordID: 1), at: now)]), [2, 3, 4])
    }

    func testQuestionKindFollowsTheBox() {
        XCTAssertEqual(ReviewPlanner.questionKind(for: nil, hasCloze: true), .cloze)
        for box in 1...3 {
            var p = WordProgress(wordID: 1)
            p.state = .learning
            p.box = box
            XCTAssertEqual(ReviewPlanner.questionKind(for: p, hasCloze: true), .cloze, "box \(box)")
            XCTAssertEqual(ReviewPlanner.questionKind(for: p, hasCloze: false), .recall, "box \(box) without a cloze")
        }
        for box in 4...5 {
            var p = WordProgress(wordID: 1)
            p.state = .learning
            p.box = box
            XCTAssertEqual(ReviewPlanner.questionKind(for: p, hasCloze: true), .recall, "box \(box)")
        }
        var graduated = WordProgress(wordID: 1)
        graduated.state = .known
        graduated.box = 5
        XCTAssertEqual(ReviewPlanner.questionKind(for: graduated, hasCloze: true), .recall, "refresher")
        let claimed = Leitner.markKnown(WordProgress(wordID: 1), at: now)
        XCTAssertEqual(ReviewPlanner.questionKind(for: claimed, hasCloze: true), .recall, "Biliyorum check")
    }

    // MARK: the options of "Hatırla"

    private func card(_ id: Int, _ lemma: String, _ gloss: String?, pos: String = "verb", level: String = "A2") -> WidgetWord {
        return WidgetWord(id: id, lemma: lemma, pos: pos, level: level, defMicro: "m", defShort: "s", exampleEN: "e", glossTR: gloss)
    }

    private lazy var borrow = card(1, "borrow", "ödünç almak")
    private lazy var cards: [WidgetWord] = [
        borrow,
        card(2, "lend", "ödünç vermek"),
        card(3, "buy", "satın almak, almak"),
        card(4, "pay", "ödemek"),
        card(5, "sell", "satmak"),
        card(6, "borrow", "alıntı yapmak"), // another sense of the same headword
        card(7, "spoon", "kaşık", pos: "noun"),
        card(8, "get", "almak"),
        card(9, "cook", "pişirmek"),
        card(10, "swim", "yüzmek", level: "B1"),
    ]
    private let topics: [Int: Set<String>] = [
        1: ["money"], 2: ["money"], 3: ["money", "shopping"], 4: ["money"], 5: ["shopping"],
        6: ["school"], 7: ["kitchen"], 8: ["daily"], 9: ["food"], 10: ["sport"],
    ]

    private func question(
        _ word: WidgetWord,
        _ direction: IntroRound.Direction,
        attempt: Int = 1,
        written: [String] = [],
        candidates: [WidgetWord]? = nil,
        excluded: Set<Int> = []
    ) -> ChoiceQuestion? {
        return ReviewPlanner.introQuestion(
            for: word,
            direction: direction,
            attempt: attempt,
            writtenDistractors: written,
            candidates: candidates ?? cards,
            topicsOf: topics,
            excludedIDs: excluded
        )
    }

    func testTurkishOptionsComeFromOtherCardsOfTheSameTopicAndPartOfSpeech() throws {
        let q = try XCTUnwrap(question(borrow, .pickMeaning))
        XCTAssertEqual(q.direction, .pickMeaning)
        XCTAssertEqual(q.prompt, "borrow")
        XCTAssertEqual(q.answer, "ödünç almak")
        XCTAssertEqual(q.options.count, 4)
        XCTAssertTrue(q.options.contains("ödünç almak"))
        // Same topic ("money", "shopping" shares none with borrow) and part of speech.
        XCTAssertTrue(Set(q.options).isSubset(of: ["ödünç almak", "ödünç vermek", "satın almak, almak", "ödemek"]), "\(q.options)")
        XCTAssertEqual(q.counterparts["ödünç vermek"], "lend")
        XCTAssertNil(q.counterparts["ödünç almak"])
    }

    func testTurkishOptionsFallBackToTheSameLevelAndNeverRepeatAMeaning() throws {
        // cook shares no topic with any card: same part of speech and level (A2) instead.
        let q = try XCTUnwrap(question(cards[8], .pickMeaning))
        XCTAssertEqual(q.options.count, 4)
        XCTAssertFalse(q.options.contains("yüzmek"), "B1")
        XCTAssertFalse(q.options.contains("kaşık"), "a noun")
        XCTAssertFalse(q.options.contains("almak") && q.options.contains("satın almak, almak"), "same meaning")
        XCTAssertEqual(Set(q.options).count, 4)
    }

    func testAnotherSenseOfTheHeadwordIsNeverAnOption() {
        for direction in [IntroRound.Direction.pickMeaning, .pickEnglish] {
            let options = question(borrow, direction)?.options ?? []
            XCTAssertFalse(options.contains("alıntı yapmak"))
            XCTAssertEqual(options.filter { $0 == "borrow" }.count, direction == .pickEnglish ? 1 : 0)
        }
    }

    func testEnglishOptionsAreTheWrittenDistractorsFirst() throws {
        let q = try XCTUnwrap(question(borrow, .pickEnglish, written: ["lend", "owe", "Borrow", "rent", "hire"]))
        XCTAssertEqual(q.direction, .pickEnglish)
        XCTAssertEqual(q.prompt, "ödünç almak")
        XCTAssertEqual(q.answer, "borrow")
        XCTAssertEqual(Set(q.options), ["borrow", "lend", "owe", "rent"])
        XCTAssertEqual(q.counterparts["lend"], "ödünç vermek")
        XCTAssertNil(q.counterparts["owe"], "no card")
    }

    func testAnEnglishOptionThatMeansTheSameIsLeftOut() throws {
        // get = "almak"; buy's card also says "almak": a second right answer.
        let get = cards[7]
        let q = try XCTUnwrap(question(get, .pickEnglish, written: ["buy", "take", "give"]))
        XCTAssertFalse(q.options.contains("buy"))
        XCTAssertTrue(q.options.contains("take"))
        XCTAssertTrue(q.options.contains("give"))
        XCTAssertEqual(q.options.count, 4, "topped up from other cards")
    }

    func testTheOtherKindOfQuestionIsUsedWhenOneHasTooFewOptions() throws {
        // Three cards with one headword: three Turkish meanings, but one English word.
        let meeting = card(20, "meeting", "toplantı", pos: "noun")
        let dates = [
            meeting,
            card(21, "date", "tarih", pos: "noun"),
            card(22, "date", "randevu", pos: "noun"),
            card(23, "date", "hurma", pos: "noun"),
        ]
        let q = try XCTUnwrap(question(meeting, .pickEnglish, candidates: dates))
        XCTAssertEqual(q.direction, .pickMeaning)
        XCTAssertEqual(q.options.count, 4)

        // No other card and no written distractor: no question (the recall screen asks instead).
        XCTAssertNil(question(meeting, .pickMeaning, candidates: [meeting]))
        // No Turkish meaning: nothing to ask about.
        XCTAssertNil(question(card(30, "thing", nil), .pickEnglish, written: ["a", "b", "c"]))
    }

    func testExcludedCardsGiveNoOption() {
        let meaning = question(borrow, .pickMeaning, excluded: [2])
        XCTAssertFalse(meaning?.options.contains("ödünç vermek") ?? true)
        let english = question(borrow, .pickEnglish, written: ["lend", "owe", "rent", "hire"], excluded: [2])
        XCTAssertFalse(english?.options.contains("lend") ?? true)
    }

    func testTheSecondTryMixesTheSameOptionsWithTheAnswerElsewhere() throws {
        for word in cards where word.pos == "verb" {
            for direction in [IntroRound.Direction.pickMeaning, .pickEnglish] {
                let first = try XCTUnwrap(question(word, direction, written: ["lend", "owe", "rent"]))
                let second = try XCTUnwrap(question(word, direction, attempt: 2, written: ["lend", "owe", "rent"]))
                XCTAssertEqual(Set(first.options), Set(second.options), "\(word.lemma)")
                XCTAssertNotEqual(
                    first.options.firstIndex(of: first.answer),
                    second.options.firstIndex(of: second.answer),
                    "\(word.lemma) \(direction)"
                )
                XCTAssertEqual(first, question(word, direction, written: ["lend", "owe", "rent"]), "stable")
            }
        }
    }
}
