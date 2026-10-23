import XCTest
import CoreModels
import Learning

final class SentencePracticeTests: XCTestCase {
    /// 2023-11-14 22:13:20 UTC.
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let hour: TimeInterval = 3600
    private let day: TimeInterval = 86_400

    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func learning(_ id: Int, due: Date?) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = 2
        p.reviews = 1
        p.dueAt = due
        return p
    }

    private func known(_ id: Int, due: Date?, override: Bool = false) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .known
        p.box = 5
        p.knownOverride = override
        p.dueAt = due
        return p
    }

    // MARK: Which words

    /// Learning and known words, but never one "Tekrar" asks within six hours (unless it was
    /// answered today), never a "Biliyorum" waiting for its check, never a new word.
    func testWordsThatTekrarAsksSoonAreLeftOut() {
        var answeredToday = WordProgress(wordID: 7)
        answeredToday.state = .learning
        answeredToday.box = 1
        answeredToday.reviews = 2
        answeredToday = Leitner.review(answeredToday, grade: .again, at: now.addingTimeInterval(-hour))
        let progress: [Int: WordProgress] = [
            1: learning(1, due: now.addingTimeInterval(3 * day)),
            2: learning(2, due: now.addingTimeInterval(2 * hour)),
            3: learning(3, due: now.addingTimeInterval(-hour)),
            4: known(4, due: now.addingTimeInterval(20 * day)),
            5: known(5, due: now.addingTimeInterval(20 * day), override: true),
            6: known(6, due: now.addingTimeInterval(hour)),
            7: answeredToday,
            8: WordProgress(wordID: 8),
            9: learning(9, due: nil),
        ]
        XCTAssertEqual(SentencePractice.wordIDs(progress: progress, now: now, calendar: utc), [1, 4, 7, 9])
        XCTAssertEqual(SentencePractice.wordIDs(progress: [:], now: now, calendar: utc), [])
    }

    // MARK: Rounds

    private let examples: [Int: [CardDetail.Example]] = [
        1: [CardDetail.Example(en: "Can I have a spoon, please?", tr: "Bir kaşık alabilir miyim lütfen?")],
        2: [CardDetail.Example(en: "I eat breakfast at seven.", tr: "Yedide kahvaltı yaparım.")],
        3: [CardDetail.Example(en: "The bus is full. We have to wait.", tr: "Otobüs dolu. Beklemek zorundayız.")],
        4: [CardDetail.Example(en: "Sorry, I made a mistake.", tr: "Özür dilerim, bir hata yaptım.")],
        5: [CardDetail.Example(en: "My brother lives in Izmir.", tr: "Kardeşim İzmir'de yaşıyor.")],
        6: [CardDetail.Example(en: "We walk to school every day.", tr: "Her gün okula yürürüz.")],
        7: [CardDetail.Example(en: "He did the dishes while I cooked.", tr: "Ben yemek yaparken o bulaşıkları yıkadı.")],
        8: [CardDetail.Example(en: "This soup is very hot.", tr: "Bu çorba çok sıcak.")],
    ]

    private func source(_ id: Int) -> SentencePractice.Source? {
        guard let examples = examples[id] else {
            return nil
        }
        return SentencePractice.Source(wordID: id, examples: examples)
    }

    func testARoundHasOneQuestionPerWordAndTheChoicesBetweenTheBuilds() {
        let round = SentencePractice.round(wordIDs: Array(1...8), seed: 3, source: source)
        XCTAssertEqual(round.count, 5)
        XCTAssertEqual(Set(round.map(\.wordID)).count, 5)
        XCTAssertFalse(round.map(\.wordID).contains(3), "two sentences in one: no question")
        let kinds = round.map { item -> String in
            if case .build = item { return "b" }
            return "c"
        }
        // Words 4 and 7 have a listed pair: two choices, second and fourth.
        XCTAssertEqual(kinds, ["b", "c", "b", "c", "b"])
        if case let .collocation(_, choice, translation) = round[1] {
            XCTAssertTrue(["made", "did"].contains(choice.answer))
            XCTAssertNotNil(translation)
        } else {
            XCTFail("the second question is a choice")
        }
        if case let .build(_, tiles, translation) = round[0] {
            XCTAssertGreaterThanOrEqual(tiles.tiles.count, 3)
            XCTAssertNotNil(translation)
        } else {
            XCTFail("the first question is a build")
        }
    }

    func testRoundsAreDeterministicAndMixedBySeed() {
        let first = SentencePractice.round(wordIDs: Array(1...8), seed: 11, source: source)
        XCTAssertEqual(first, SentencePractice.round(wordIDs: Array(1...8), seed: 11, source: source))
        let orders = Set((0..<8).map { seed in
            SentencePractice.round(wordIDs: Array(1...8), seed: seed, source: source).map(\.wordID)
        })
        XCTAssertGreaterThan(orders.count, 1)
    }

    func testSmallPoolsGiveShortRounds() {
        XCTAssertEqual(SentencePractice.round(wordIDs: [1, 2], seed: 0, source: source).count, 2)
        XCTAssertEqual(SentencePractice.round(wordIDs: [3], seed: 0, source: source), [])
        XCTAssertEqual(SentencePractice.round(wordIDs: [], seed: 0, source: source), [])
        XCTAssertEqual(SentencePractice.round(wordIDs: [99], seed: 0, source: source), [])
        XCTAssertEqual(SentencePractice.round(wordIDs: [1, 2], seed: 0, size: 0, source: source), [])
        // A pair only: the choice opens the round, as there is nothing to build.
        let only = SentencePractice.round(wordIDs: [4], seed: 0, source: source)
        XCTAssertEqual(only.count, 1)
        if case .collocation = only.first {} else {
            XCTFail("a lone word with a pair is a choice")
        }
    }

    /// Without "which verb?" questions every question is a build; a round of one never has a
    /// choice (at most half the round).
    func testChoiceLimits() {
        let none = SentencePractice.round(wordIDs: Array(1...8), seed: 2, collocations: 0, source: source)
        XCTAssertEqual(none.count, 5)
        XCTAssertTrue(none.allSatisfy { if case .build = $0 { return true } else { return false } })
        let one = SentencePractice.round(wordIDs: Array(1...8), seed: 2, size: 1, source: source)
        XCTAssertEqual(one.count, 1)
        if case .build = one.first {} else {
            XCTFail("a round of one is a build")
        }
    }

    /// A card's collocation is used when no example has a pair.
    func testCollocationOfTheCardWhenNoExampleHasAPair() {
        let only = SentencePractice.round(wordIDs: [1], seed: 0, size: 2) { id in
            SentencePractice.Source(
                wordID: id,
                examples: [CardDetail.Example(en: "Can I have a spoon, please?", tr: nil)],
                collocations: ["wooden spoon", "do the dishes"]
            )
        }
        XCTAssertEqual(only.count, 1)
        if case let .collocation(_, choice, translation) = only.first {
            XCTAssertEqual(choice.answer, "do")
            XCTAssertNil(translation)
        } else {
            XCTFail("the card's collocation makes a choice")
        }
    }

    // MARK: Running a round

    private func items(_ count: Int) -> [SentencePractice.Item] {
        return (0..<count).map { index in
            .build(wordID: index, tiles: SentenceTiles("I like tea number \(index).")!, translation: nil)
        }
    }

    func testAWrongQuestionComesOnceMoreTwoQuestionsLater() {
        var round = SentencePractice.Round(items: items(5))
        XCTAssertEqual(round.questionCount, 5)
        XCTAssertEqual(round.current?.item.wordID, 0)
        round.answer(isRight: false)
        XCTAssertEqual(round.steps.map(\.item.wordID), [0, 1, 2, 0, 3, 4])
        XCTAssertEqual(round.steps[3].attempt, 1)
        round.answer(isRight: true)
        round.answer(isRight: true)
        XCTAssertEqual(round.current?.item.wordID, 0)
        // The second try is not tried again.
        round.answer(isRight: false)
        XCTAssertEqual(round.steps.count, 6)
        round.answer(isRight: true)
        round.answer(isRight: true)
        XCTAssertTrue(round.isFinished)
        XCTAssertNil(round.current)
        XCTAssertEqual(round.rightFirstTime, 4)
        XCTAssertEqual(round.progress.done, 6)
        XCTAssertEqual(round.progress.total, 6)
    }

    /// Never right after itself: near the end it comes after the one step left, after the last
    /// step not at all.
    func testNearTheEndTheSecondTryNeverFollowsItself() {
        var round = SentencePractice.Round(items: items(3))
        round.answer(isRight: true)
        round.answer(isRight: false)
        XCTAssertEqual(round.steps.map(\.item.wordID), [0, 1, 2, 1])
        round.answer(isRight: true)
        round.answer(isRight: false)
        XCTAssertEqual(round.steps.map(\.item.wordID), [0, 1, 2, 1])
        XCTAssertTrue(round.isFinished)
        var last = SentencePractice.Round(items: items(2))
        last.answer(isRight: true)
        last.answer(isRight: false)
        XCTAssertEqual(last.steps.map(\.item.wordID), [0, 1])
        XCTAssertTrue(last.isFinished)
        var single = SentencePractice.Round(items: items(1))
        single.answer(isRight: false)
        XCTAssertTrue(single.isFinished)
        XCTAssertEqual(single.rightFirstTime, 0)
    }

    // MARK: Tally

    func testTallyCountsTodayAndInAll() {
        let tally = PracticeTally.empty.adding(5, now: now, calendar: utc)
        XCTAssertEqual(tally.day, "2023-11-14")
        XCTAssertEqual(tally.todayCount(now: now, calendar: utc), 5)
        let later = tally.adding(3, now: now.addingTimeInterval(hour), calendar: utc)
        XCTAssertEqual(later.todayCount(now: now, calendar: utc), 8)
        XCTAssertEqual(later.total, 8)
        // 22:13 UTC + 2 h is the next day in UTC.
        let tomorrow = now.addingTimeInterval(2 * hour)
        XCTAssertEqual(later.todayCount(now: tomorrow, calendar: utc), 0)
        let next = later.adding(2, now: tomorrow, calendar: utc)
        XCTAssertEqual(next.todayCount(now: tomorrow, calendar: utc), 2)
        XCTAssertEqual(next.total, 10)
        XCTAssertEqual(next.adding(-4, now: tomorrow, calendar: utc), next)
    }

    func testTallyRoundTripsAsJSON() throws {
        let tally = PracticeTally(day: "2026-10-23", today: 4, total: 31)
        let data = try JSONEncoder().encode(tally)
        XCTAssertEqual(try JSONDecoder().decode(PracticeTally.self, from: data), tally)
    }

    /// Once the sentences to build are found, the search for a "which verb?" question stops after
    /// `scanWithBuildsFull` words: every word is a card read.
    func testTheSearchForAChoiceStopsSoon() {
        var looked: [Int] = []
        let round = SentencePractice.round(wordIDs: Array(1...200), seed: 5) { id in
            looked.append(id)
            return SentencePractice.Source(wordID: id, examples: [CardDetail.Example(en: "I like green tea number \(id).", tr: nil)])
        }
        XCTAssertEqual(round.count, 5)
        XCTAssertEqual(looked.count, SentencePractice.scanWithBuildsFull)
        var all = 0
        _ = SentencePractice.round(wordIDs: Array(1...200), seed: 5, collocations: 0) { id in
            all += 1
            return SentencePractice.Source(wordID: id, examples: [CardDetail.Example(en: "I like green tea number \(id).", tr: nil)])
        }
        XCTAssertEqual(all, 5, "without choices the round stops at its fifth word")
    }
}
