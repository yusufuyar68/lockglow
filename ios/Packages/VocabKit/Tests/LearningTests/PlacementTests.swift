import XCTest
import CoreModels
@testable import Learning

/// "Seviye testi" (`PlacementTest`): length, the adaptive order and the start level it gives.
/// `bank` has no B2 words, so most tests here run on A1–B1 (the fallback);
/// the four-level test is under "B2".
final class PlacementTests: XCTestCase {
    /// 60 words per level: A1 1–60, A2 101–160, B1 201–260.
    private let bank: [Level: [Int]] = [
        .a1: Array(1...60),
        .a2: Array(101...160),
        .b1: Array(201...260),
    ]

    /// `bank` and 60 B2 words, 301–360.
    private var bankWithB2: [Level: [Int]] {
        var result = bank
        result[.b2] = Array(301...360)
        return result
    }

    /// Runs a whole test, answering with `knows`; returns the test and the levels asked in order.
    private func take(seed: Int = 7, _ knows: (Level, Int) -> Bool) -> PlacementTest {
        return take(bank: bank, seed: seed, knows)
    }

    private func take(bank: [Level: [Int]], seed: Int = 7, _ knows: (Level, Int) -> Bool) -> PlacementTest {
        var test = PlacementTest(bank: bank, seed: seed)
        var guardCount = 0
        while let question = test.current, guardCount < 100 {
            test.answer(right: knows(question.level, test.answers.count))
            guardCount += 1
        }
        return test
    }

    // MARK: Result

    func testKnowingEverythingGivesB1() {
        let test = take { _, _ in true }
        XCTAssertTrue(test.isFinished)
        XCTAssertEqual(test.result, .b1)
    }

    func testKnowingNothingGivesA1() {
        let test = take { _, _ in false }
        XCTAssertEqual(test.result, .a1)
    }

    /// The start level is the first level not mostly known: all of A1 and none of A2 is A2.
    func testKnowingOnlyA1GivesA2() {
        let test = take { level, _ in level == .a1 }
        XCTAssertEqual(test.result, .a2)
    }

    func testKnowingA1AndA2GivesB1() {
        let test = take { level, _ in level != .b1 }
        XCTAssertEqual(test.result, .b1)
    }

    func testKnowingAllOfA1AndHalfOfA2GivesA2() {
        var a2Asked = 0
        let test = take { level, _ in
            if level == .a2 {
                a2Asked += 1
                return a2Asked % 2 == 0
            }
            return level == .a1
        }
        XCTAssertEqual(test.result, .a2)
    }

    func testKnowingHalfOfA1GivesA1() {
        var a1Asked = 0
        let test = take { level, _ in
            guard level == .a1 else {
                return false
            }
            a1Asked += 1
            return a1Asked % 2 == 0
        }
        XCTAssertEqual(test.result, .a1)
    }

    // MARK: Length

    func testTheTestHasTwentyToTwentyFiveWords() {
        let answerers: [(Level, Int) -> Bool] = [
            { _, _ in true },
            { _, _ in false },
            { level, _ in level == .a1 },
            { level, index in level == .a1 || index % 3 == 0 },
            { _, index in index % 2 == 0 },
        ]
        for (n, knows) in answerers.enumerated() {
            for seed in 0..<5 {
                let test = take(seed: seed, knows)
                XCTAssertGreaterThanOrEqual(test.answers.count, PlacementTest.minimumQuestions, "answerer \(n)")
                XCTAssertLessThanOrEqual(test.answers.count, PlacementTest.maximumQuestions, "answerer \(n)")
            }
        }
    }

    func testAClearResultStopsAtTwentyWords() {
        XCTAssertEqual(take { _, _ in false }.answers.count, PlacementTest.minimumQuestions)
        XCTAssertEqual(take { _, _ in true }.answers.count, PlacementTest.minimumQuestions)
    }

    func testNoWordIsAskedTwice() {
        let test = take { _, index in index % 3 != 0 }
        let ids = test.answers.map { $0.wordID }
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testTheAskedWordComesFromItsLevel() {
        let test = take { _, index in index % 2 == 0 }
        for answer in test.answers {
            XCTAssertTrue(bank[answer.level]?.contains(answer.wordID) ?? false)
        }
    }

    // MARK: Adaptive order

    /// A known word is never followed by an easier one, an unknown word never by a harder one.
    func testAKnownWordLeadsUpAndAnUnknownWordDown() {
        let answerers: [(Level, Int) -> Bool] = [
            { _, index in index % 2 == 0 },
            { _, index in index % 3 != 0 },
            { level, index in level == .a1 || index % 4 == 0 },
            { level, _ in level != .b1 },
        ]
        for knows in answerers {
            for seed in 0..<5 {
                let answers = take(seed: seed, knows).answers
                for (previous, next) in zip(answers, answers.dropFirst()) {
                    if previous.right {
                        XCTAssertGreaterThanOrEqual(next.level, previous.level)
                    } else {
                        XCTAssertLessThanOrEqual(next.level, previous.level)
                    }
                }
            }
        }
    }

    func testAKnownWordSoonLeadsToHarderWords() {
        let levels = take { _, _ in true }.answers.map { $0.level }
        XCTAssertEqual(levels.first, .a1)
        XCTAssertTrue(levels.prefix(10).contains(.b1), "\(levels)")
    }

    func testKnowingNothingStaysOnA1() {
        XCTAssertTrue(take { _, _ in false }.answers.allSatisfy { $0.level == .a1 })
    }

    // MARK: Words

    func testTheSeedMixesTheWords() {
        let first = PlacementTest(bank: bank, seed: 1).current
        XCTAssertEqual(first, PlacementTest(bank: bank, seed: 1).current)
        let firsts = Set((0..<20).compactMap { PlacementTest(bank: bank, seed: $0).current?.wordID })
        XCTAssertGreaterThan(firsts.count, 1)
    }

    func testASkippedWordIsNotCounted() {
        var test = PlacementTest(bank: bank, seed: 3)
        let skipped = test.current
        test.skipCurrent()
        XCTAssertNotEqual(test.current?.wordID, skipped?.wordID)
        XCTAssertEqual(test.current?.level, skipped?.level)
        XCTAssertTrue(test.answers.isEmpty)
    }

    func testAnEmptyLevelGivesWayToTheNearestOne() {
        var test = PlacementTest(bank: [.a1: [], .a2: [5, 6], .b1: [7]], seed: 0)
        XCTAssertEqual(test.current?.level, .a2)
        test.answer(right: false)
        XCTAssertEqual(test.current?.level, .a2)
        test.answer(right: false)
        XCTAssertEqual(test.current?.level, .b1)
        test.answer(right: false)
        XCTAssertTrue(test.isFinished, "no word left")
    }

    func testCanRunNeedsEnoughWordsInEveryLevel() {
        XCTAssertTrue(PlacementTest.canRun(bank: bank))
        XCTAssertFalse(PlacementTest.canRun(bank: [.a1: Array(1...60), .a2: Array(101...160), .b1: []]))
        XCTAssertFalse(PlacementTest.canRun(bank: [.a1: [1, 2], .a2: [3, 4], .b1: [5, 6]]))
    }

    func testTheResultIsConfidentOnceFinishedClearly() {
        let test = take { _, _ in false }
        XCTAssertGreaterThanOrEqual(test.confidence, PlacementTest.confidenceToStop)
    }

    // MARK: B2

    func testABankWithB2WordsTestsFourLevels() {
        XCTAssertEqual(PlacementTest.levels(for: bankWithB2), [.a1, .a2, .b1, .b2])
        XCTAssertEqual(PlacementTest(bank: bankWithB2, seed: 1).levels, [.a1, .a2, .b1, .b2])
        XCTAssertEqual(PlacementTest(bank: bank, seed: 1).levels, [.a1, .a2, .b1])
    }

    /// Too few B2 words (e.g. a content DB without B2 cards): the test stays on A1–B1 and never
    /// gives B2, even to someone who knows every word.
    func testTooFewB2WordsFallBackToThreeLevels() {
        var few = bank
        few[.b2] = Array(301..<(301 + PlacementTest.minimumWordsForB2 - 1))
        XCTAssertEqual(PlacementTest.levels(for: few), [.a1, .a2, .b1])
        let test = take(bank: few) { _, _ in true }
        XCTAssertEqual(test.result, .b1)
        XCTAssertFalse(test.answers.contains { $0.level == .b2 })
        XCTAssertTrue(PlacementTest.canRun(bank: few))

        // A B2 id that is also an easier level's word does not count.
        var shared = bank
        shared[.b2] = Array(1...PlacementTest.minimumWordsForB2)
        XCTAssertEqual(PlacementTest.levels(for: shared), [.a1, .a2, .b1])

        var enough = bank
        enough[.b2] = Array(301..<(301 + PlacementTest.minimumWordsForB2))
        XCTAssertEqual(PlacementTest.levels(for: enough), [.a1, .a2, .b1, .b2])

        // B2 is never needed; A1–B1 still are.
        XCTAssertTrue(PlacementTest.canRun(bank: [.a1: Array(1...60), .a2: Array(101...160), .b1: Array(201...260), .b2: []]))
        XCTAssertFalse(PlacementTest.canRun(bank: [.a1: Array(1...60), .a2: [], .b1: Array(201...260), .b2: Array(301...360)]))
    }

    func testKnowingEverythingGivesB2() {
        let test = take(bank: bankWithB2) { _, _ in true }
        XCTAssertTrue(test.isFinished)
        XCTAssertEqual(test.result, .b2)
        XCTAssertGreaterThanOrEqual(test.confidence, PlacementTest.confidenceToStop)
        XCTAssertLessThanOrEqual(test.answers.count, PlacementTest.maximumQuestions)
    }

    /// The start level is the first level not mostly known: A1–B1 known and B2 not is B2.
    func testKnowingA1ToB1GivesB2() {
        XCTAssertEqual(take(bank: bankWithB2) { level, _ in level != .b2 }.result, .b2)
    }

    func testFourLevelsKeepTheEasierResults() {
        let nothing = take(bank: bankWithB2) { _, _ in false }
        XCTAssertEqual(nothing.result, .a1)
        XCTAssertEqual(nothing.answers.count, PlacementTest.minimumQuestions)
        XCTAssertTrue(nothing.answers.allSatisfy { $0.level == .a1 })
        XCTAssertEqual(take(bank: bankWithB2) { level, _ in level == .a1 }.result, .a2)
        XCTAssertEqual(take(bank: bankWithB2) { level, _ in level <= .a2 }.result, .b1)
    }

    func testFourLevelsKeepTheLengthAndTheOrder() {
        let answerers: [(Level, Int) -> Bool] = [
            { _, _ in true },
            { _, index in index % 2 == 0 },
            { _, index in index % 3 != 0 },
            { level, index in level == .a1 || index % 4 == 0 },
            { level, _ in level != .b2 },
        ]
        let fullBank = bankWithB2
        for (n, knows) in answerers.enumerated() {
            for seed in 0..<3 {
                let test = take(bank: fullBank, seed: seed, knows)
                XCTAssertGreaterThanOrEqual(test.answers.count, PlacementTest.minimumQuestions, "answerer \(n)")
                XCTAssertLessThanOrEqual(test.answers.count, PlacementTest.maximumQuestions, "answerer \(n)")
                let ids = test.answers.map { $0.wordID }
                XCTAssertEqual(Set(ids).count, ids.count, "answerer \(n)")
                for answer in test.answers {
                    XCTAssertTrue(fullBank[answer.level]?.contains(answer.wordID) ?? false, "answerer \(n)")
                }
                for (previous, next) in zip(test.answers, test.answers.dropFirst()) {
                    if previous.right {
                        XCTAssertGreaterThanOrEqual(next.level, previous.level, "answerer \(n)")
                    } else {
                        XCTAssertLessThanOrEqual(next.level, previous.level, "answerer \(n)")
                    }
                }
            }
        }
    }

    /// Someone who knows every word climbs from A1 to B2 within the test and ends on B2.
    func testAKnownWordLeadsUpToB2() {
        let levels = take(bank: bankWithB2) { _, _ in true }.answers.map { $0.level }
        XCTAssertEqual(levels.first, .a1)
        XCTAssertTrue(levels.prefix(15).contains(.b2), "\(levels)")
        XCTAssertEqual(levels.last, .b2)
    }

    func testEveryLevelHasAMasteryChance() {
        let test = PlacementTest(bank: bankWithB2, seed: 0)
        let mastery = test.masteryProbabilities()
        XCTAssertEqual(mastery.count, 4)
        // Before any answer an easier level is the likelier to be mostly known.
        XCTAssertGreaterThan(mastery[0], mastery[1])
        XCTAssertGreaterThan(mastery[1], mastery[2])
        XCTAssertGreaterThan(mastery[2], mastery[3])
        XCTAssertEqual(test.current?.level, .a1, "the test starts with an A1 word")
    }

    // MARK: Share grid

    func testTheGridHoldsEveryMonotoneCombination() {
        let three = ShareGrid.states(count: 3)
        let four = ShareGrid.states(count: 4)
        // Combinations with repetition of 20 steps: C(22, 3) and C(23, 4).
        XCTAssertEqual(three.count, 1_540)
        XCTAssertEqual(four.count, 8_855)
        for state in four {
            XCTAssertEqual(state.count, 4)
            XCTAssertTrue(zip(state, state.dropFirst()).allSatisfy { $0 >= $1 }, "\(state)")
            XCTAssertTrue(state.allSatisfy { $0 > 0 && $0 < 1 }, "no share is ever 0 or 1")
        }
        let distinct = Set(four.map { state in state.map { Int(($0 * 40).rounded()) } })
        XCTAssertEqual(distinct.count, four.count)
    }

    func testTheStartLevelOfACombination() {
        // Four levels: A1, A2, B1, B2.
        XCTAssertEqual(ShareGrid.startLevelIndex(of: [0.5, 0.4, 0.3, 0.2]), 0)
        XCTAssertEqual(ShareGrid.startLevelIndex(of: [0.9, 0.5, 0.3, 0.2]), 1)
        XCTAssertEqual(ShareGrid.startLevelIndex(of: [0.9, 0.85, 0.6, 0.2]), 2)
        XCTAssertEqual(ShareGrid.startLevelIndex(of: [0.9, 0.9, 0.85, 0.3]), 3)
        // A strong B2 learner: B2 is the top level, so it is the start.
        XCTAssertEqual(ShareGrid.startLevelIndex(of: [0.975, 0.975, 0.975, 0.925]), 3)
        // Three levels: B1 at the top.
        XCTAssertEqual(ShareGrid.startLevelIndex(of: [0.9, 0.9, 0.2]), 2)
        XCTAssertEqual(ShareGrid.startLevelIndex(of: [0.9, 0.5, 0.2]), 1)
    }
}
