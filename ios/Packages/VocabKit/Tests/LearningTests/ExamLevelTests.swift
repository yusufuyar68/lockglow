import XCTest
import CoreModels
import SharedState
@testable import Learning

/// C1 and the exam topic ("YDS / YÖKDİL Çekirdek", `yds_yokdil_core`, B2 and C1 cards): C1 is no
/// start level and the level test never gives it, but a B2 learner's deck reaches it right after
/// B2, the map and İlerleme count it once it has words, and a deck of the exam topic alone works.
final class ExamLevelTests: XCTestCase {
    private let exam = "yds_yokdil_core"
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    private func word(_ id: Int, _ level: String) -> WidgetWord {
        return WidgetWord(
            id: id,
            lemma: "w\(id)",
            pos: "n",
            level: level,
            defMicro: "m\(id)",
            defShort: "s\(id)",
            exampleEN: "An example with w\(id) in it.",
            glossTR: "anlam \(id)"
        )
    }

    private func ids(_ list: [WidgetWord]) -> [Int] {
        return list.map { $0.id }
    }

    private func met(_ id: Int) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = 1
        return p
    }

    /// The curriculum as `ContentStore.freeCards` gives it (level, then frequency): A1–B2 words in
    /// everyday topics, then the exam topic's B2 (40–43) and C1 (50–54) words.
    private var curriculum: [WidgetWord] {
        return [word(1, "A1"), word(2, "A2"), word(3, "B1"), word(4, "B2"), word(5, "B2"),
                word(40, "B2"), word(41, "B2"), word(42, "B2"), word(43, "B2"),
                word(50, "C1"), word(51, "C1"), word(52, "C1"), word(53, "C1"), word(54, "C1")]
    }

    private var topicsOf: [Int: Set<String>] {
        var result: [Int: Set<String>] = [1: ["food_drink"], 2: ["shopping_money"], 3: ["travel_tourism"], 4: ["society_media"], 5: ["business_management"]]
        for id in [40, 41, 42, 43, 50, 51, 52, 53, 54] {
            result[id] = [exam]
        }
        // One exam word is also a business word: it counts once.
        result[41] = [exam, "business_management"]
        return result
    }

    // MARK: Deck order

    /// A B2 learner: B2 first, then C1, then the easier levels closest first.
    func testC1ComesRightAfterB2ForAB2Learner() {
        let ordered = DeckFilter.ordered(curriculum, startingAt: .b2)
        XCTAssertEqual(ids(ordered), [4, 5, 40, 41, 42, 43, 50, 51, 52, 53, 54, 3, 2, 1])
        let levels = ordered.compactMap { $0.levelValue }
        let firstC1 = levels.firstIndex(of: .c1)
        let lastB2 = levels.lastIndex(of: .b2)
        XCTAssertNotNil(firstC1)
        XCTAssertLessThan(lastB2 ?? .max, firstC1 ?? .min)
    }

    /// An A1 learner meets C1 last of the levels above, before nothing easier is left.
    func testC1ComesAfterB2FromEveryStartLevel() {
        for start in SettingsRules.startLevelChoices {
            let levels = DeckFilter.ordered(curriculum, startingAt: start).compactMap { $0.levelValue }
            let b2 = levels.firstIndex(of: .b2) ?? -1
            let c1 = levels.firstIndex(of: .c1) ?? -1
            XCTAssertLessThan(b2, c1, "start \(start)")
        }
    }

    // MARK: A deck of the exam topic alone

    /// Only "YDS / YÖKDİL Çekirdek" chosen, whatever the start level: the deck is the exam words
    /// (B2 then C1), never empty, and every word is new, so the widget plan and "Tekrar" have
    /// words.
    func testTheExamTopicAloneGivesAWorkingDeck() throws {
        let starts: [Level?] = [nil] + SettingsRules.startLevelChoices.map { Optional($0) }
        for start in starts {
            let choice = DeckChoice(topicIDs: [exam], startLevel: start)
            let deck = DeckFilter.feed(curriculum, topicsOf: topicsOf, choice: choice)
            XCTAssertEqual(Set(ids(deck)), [40, 41, 42, 43, 50, 51, 52, 53, 54], "start \(String(describing: start))")
            XCTAssertEqual(ids(deck).prefix(4).sorted(), [40, 41, 42, 43], "B2 before C1")
            XCTAssertTrue(DeckFilter.hasNewWords(deck, progress: [:]))
            let summary = DeckFilter.summary(curriculum, topicsOf: topicsOf, topicIDs: [exam], progress: [:])
            XCTAssertEqual(summary, DeckSummary(wordCount: 9, newCount: 9))

            let fallback = DeckFilter.ordered(curriculum, startingAt: start)
            XCTAssertEqual(ids(DeckFilter.newWordFeed(deck: deck, fallback: fallback, progress: [:])), ids(deck))
            let input = WidgetPlanBuilder.Input(
                deck: deck,
                fallbackFeed: fallback,
                progress: [:],
                rotationMinutes: 60,
                dailyNewWords: 10,
                limit: 96,
                horizon: 48 * 3600
            )
            let plan = try XCTUnwrap(WidgetPlanBuilder.makePlan(input, at: now, previousPlan: nil, state: nil, planDetail: { _ in nil }))
            XCTAssertFalse(plan.queue.isEmpty)
            XCTAssertTrue(plan.queue.allSatisfy { topicsOf[$0.id]?.contains(exam) ?? false }, "the widget shows exam words")
        }
    }

    /// Every exam word studied: new words come from every topic, the daily goal goes on.
    func testAFinishedExamDeckFallsBackToEveryTopic() {
        let deck = DeckFilter.feed(curriculum, topicsOf: topicsOf, choice: DeckChoice(topicIDs: [exam], startLevel: .b2))
        var progress: [Int: WordProgress] = [:]
        for id in ids(deck) {
            progress[id] = met(id)
        }
        let fallback = DeckFilter.ordered(curriculum, startingAt: .b2)
        XCTAssertEqual(ids(DeckFilter.newWordFeed(deck: deck, fallback: fallback, progress: progress)), ids(fallback))
    }

    // MARK: Yol haritası and İlerleme

    func testTheMapCountsC1AfterB2() {
        XCTAssertEqual(LevelMap.shownLevels, [.a1, .a2, .b1, .b2, .c1])
        XCTAssertEqual(LevelMap.alwaysShownUpTo, .b1)
        XCTAssertEqual(Array(LevelMap.shownLevels.prefix(SettingsRules.startLevelChoices.count)), SettingsRules.startLevelChoices)
        let map = LevelMap.make(
            levels: LevelMap.shownLevels,
            words: curriculum,
            upcoming: DeckFilter.ordered(curriculum, startingAt: .b2),
            progress: [4: met(4), 5: met(5), 40: met(40), 41: met(41), 42: met(42), 43: met(43)],
            topicsOf: topicsOf,
            topicOrder: ["food_drink": 0, "business_management": 30, exam: 90],
            startLevel: .b2,
            hidingEmptyLevelsAbove: LevelMap.alwaysShownUpTo
        )
        XCTAssertEqual(map.stops.map { $0.level }, [.a1, .a2, .b1, .b2, .c1])
        XCTAssertEqual(map.stops.map { $0.total }, [1, 1, 1, 6, 5])
        XCTAssertTrue(map.stops[3].everyWordMet)
        XCTAssertEqual(map.stops[4].met, 0)
        // Every B2 word met: new words now come from C1, the exam topic.
        XCTAssertEqual(map.currentLevel, .c1)
        XCTAssertEqual(map.stops[4].nextTopicIDs, [exam])
        XCTAssertEqual(map.startLevel, .b2)
    }

    /// A content DB without exam words: no empty C1 stop (B2 likewise).
    func testAMapWithoutC1WordsHasNoC1Stop() {
        let everyday = Array(curriculum.prefix(5))
        let map = LevelMap.make(
            levels: LevelMap.shownLevels,
            words: everyday,
            upcoming: everyday,
            progress: [:],
            topicsOf: topicsOf,
            topicOrder: [:],
            startLevel: .a1,
            hidingEmptyLevelsAbove: LevelMap.alwaysShownUpTo
        )
        XCTAssertEqual(map.stops.map { $0.level }, [.a1, .a2, .b1, .b2])
        let none = LevelMap.make(
            levels: LevelMap.shownLevels,
            words: [word(1, "A1")],
            upcoming: [],
            progress: [:],
            topicsOf: [:],
            topicOrder: [:],
            startLevel: nil,
            hidingEmptyLevelsAbove: LevelMap.alwaysShownUpTo
        )
        XCTAssertEqual(none.stops.map { $0.level }, [.a1, .a2, .b1])
    }

    // MARK: Start level and the level test

    func testC1IsNoStartLevel() {
        XCTAssertEqual(SettingsRules.startLevelChoices, [.a1, .a2, .b1, .b2])
        XCTAssertFalse(SettingsRules.startLevelChoices.contains(.c1))
        XCTAssertEqual(PlacementTest.allLevels, SettingsRules.startLevelChoices)
    }

    /// A stored level always reads as an offered one: C1 and above become B2, nil stays nil.
    func testAStoredLevelBecomesAnOfferedOne() {
        for level in SettingsRules.startLevelChoices {
            XCTAssertEqual(SettingsRules.offeredStartLevel(level), level)
        }
        XCTAssertEqual(SettingsRules.offeredStartLevel(.c1), .b2)
        XCTAssertEqual(SettingsRules.offeredStartLevel(.c2), .b2)
        XCTAssertEqual(SettingsRules.offeredStartLevel(.s), .b2)
        XCTAssertNil(SettingsRules.offeredStartLevel(nil))
        // A C1 setting keeps the B1–B2 daily goal.
        XCTAssertEqual(SettingsRules.defaultDailyNewWords(startLevel: SettingsRules.offeredStartLevel(.c1)), 10)
    }

    /// A bank with C1 words (as `placementBank` would make without its level filter): the test
    /// still asks A1–B2 only and never gives C1, also to someone who knows every word.
    func testThePlacementTestNeverGivesC1() {
        let bank: [Level: [Int]] = [
            .a1: Array(1...60),
            .a2: Array(101...160),
            .b1: Array(201...260),
            .b2: Array(301...360),
            .c1: Array(401...460),
        ]
        XCTAssertEqual(PlacementTest.levels(for: bank), [.a1, .a2, .b1, .b2])
        let answerers: [(Level) -> Bool] = [{ _ in true }, { $0 <= .b1 }, { _ in false }]
        for (n, knows) in answerers.enumerated() {
            for seed in 0..<4 {
                var test = PlacementTest(bank: bank, seed: seed)
                XCTAssertEqual(test.levels, [.a1, .a2, .b1, .b2])
                var guardCount = 0
                while let question = test.current, guardCount < 100 {
                    test.answer(right: knows(question.level))
                    guardCount += 1
                }
                XCTAssertTrue(test.isFinished, "answerer \(n)")
                XCTAssertTrue(test.answers.allSatisfy { $0.level != .c1 && $0.wordID < 400 }, "answerer \(n) was asked a C1 word")
                XCTAssertNotEqual(test.result, .c1, "answerer \(n)")
                XCTAssertLessThanOrEqual(test.result, .b2, "answerer \(n)")
            }
        }
        XCTAssertEqual({ () -> Level in
            var test = PlacementTest(bank: bank, seed: 1)
            while test.current != nil {
                test.answer(right: true)
            }
            return test.result
        }(), .b2)
    }
}
