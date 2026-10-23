import XCTest
import CoreModels
@testable import Learning

/// "Seviye testi" (`PlacementTest`): length, the adaptive order and the start level it gives.
final class PlacementTests: XCTestCase {
    /// 60 words per level: A1 1–60, A2 101–160, B1 201–260.
    private let bank: [Level: [Int]] = [
        .a1: Array(1...60),
        .a2: Array(101...160),
        .b1: Array(201...260),
    ]

    /// Runs a whole test, answering with `knows`; returns the test and the levels asked in order.
    private func take(seed: Int = 7, _ knows: (Level, Int) -> Bool) -> PlacementTest {
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
}
