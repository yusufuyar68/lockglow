import XCTest
import CoreModels
import Learning

final class ProgressIngestTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let day: TimeInterval = 86_400

    private func event(_ type: WidgetEventType, _ wordID: Int, at offset: TimeInterval = 0) -> LearningEvent {
        return LearningEvent(type: type, wordID: wordID, at: now.addingTimeInterval(offset))
    }

    func testKnownMarksTheWordKnown() throws {
        let result = ProgressIngest.apply([event(.known, 1, at: 5)], to: [:])
        let p = try XCTUnwrap(result[1])
        XCTAssertEqual(p.state, .known)
        XCTAssertTrue(p.knownOverride)
        XCTAssertEqual(p.lastSeenAt, now.addingTimeInterval(5))
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(5 + 30 * day))
        XCTAssertEqual(p.reviews, 0)
    }

    func testNextAndRevealAreExposuresOnly() throws {
        let result = ProgressIngest.apply([event(.next, 1, at: 1), event(.reveal, 1, at: 2)], to: [:])
        let p = try XCTUnwrap(result[1])
        XCTAssertEqual(p.exposures, 2)
        XCTAssertEqual(p.lastSeenAt, now.addingTimeInterval(2))
        XCTAssertEqual(p.state, .new)
        XCTAssertEqual(p.box, 0)
        XCTAssertEqual(p.reviews, 0)
        XCTAssertNil(p.dueAt)
    }

    func testExposureKeepsAnExistingSchedule() throws {
        let reviewed = Leitner.review(WordProgress(wordID: 3), grade: .good, at: now)
        let result = ProgressIngest.apply([event(.next, 3, at: 60)], to: [3: reviewed])
        let p = try XCTUnwrap(result[3])
        XCTAssertEqual(p.exposures, 1)
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.box, 1)
        XCTAssertEqual(p.dueAt, reviewed.dueAt)
        XCTAssertEqual(p.reviews, 1)
    }

    func testUnknownIsAWrongAnswer() throws {
        let result = ProgressIngest.apply([event(.unknown, 1, at: 10)], to: [:])
        let p = try XCTUnwrap(result[1])
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.box, 1)
        XCTAssertEqual(p.reviews, 1)
        XCTAssertEqual(p.lapses, 0) // a first wrong answer on a new word is not a lapse
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(10 + 10 * 60))
    }

    func testUnknownAfterKnownIsALapse() throws {
        let result = ProgressIngest.apply([event(.known, 1, at: 0), event(.unknown, 1, at: 60)], to: [:])
        let p = try XCTUnwrap(result[1])
        XCTAssertEqual(p.state, .learning)
        XCTAssertFalse(p.knownOverride)
        XCTAssertEqual(p.box, 1)
        XCTAssertEqual(p.lapses, 1)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(60 + 10 * 60))
    }

    func testEventsAreAppliedOldestFirst() throws {
        // Given newest first: the older "unknown" must run before the newer "known".
        let events = [event(.known, 1, at: 100), event(.unknown, 1, at: 10)]
        let result = ProgressIngest.apply(events, to: [:])
        let p = try XCTUnwrap(result[1])
        XCTAssertEqual(p.state, .known)
        XCTAssertTrue(p.knownOverride)
        XCTAssertEqual(p.box, 1) // left over from the earlier wrong answer
        XCTAssertEqual(p.reviews, 1)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(100 + 30 * day))
    }

    func testEqualTimestampsKeepInputOrder() throws {
        let knownThenUnknown = ProgressIngest.apply([event(.known, 1), event(.unknown, 1)], to: [:])
        XCTAssertEqual(try XCTUnwrap(knownThenUnknown[1]).state, .learning)

        let unknownThenKnown = ProgressIngest.apply([event(.unknown, 1), event(.known, 1)], to: [:])
        XCTAssertEqual(try XCTUnwrap(unknownThenKnown[1]).state, .known)
    }

    func testOtherWordsAndTheInputAreUntouched() throws {
        let existing = Leitner.markKnown(WordProgress(wordID: 5), at: now)
        let input: [Int: WordProgress] = [5: existing]
        let result = ProgressIngest.apply([event(.next, 9)], to: input)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[5], existing)
        XCTAssertEqual(try XCTUnwrap(result[9]).exposures, 1)
        XCTAssertEqual(input.count, 1) // the argument is a value; the caller's copy is unchanged
    }

    func testNoEventsReturnsTheInput() {
        let input: [Int: WordProgress] = [1: WordProgress(wordID: 1)]
        XCTAssertEqual(ProgressIngest.apply([], to: input), input)
    }
}
