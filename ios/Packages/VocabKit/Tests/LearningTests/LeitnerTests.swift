import XCTest
import Learning

final class LeitnerTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let day: TimeInterval = 86_400

    func testNewWordStartsInBoxZero() {
        let p = WordProgress(wordID: 7)
        XCTAssertEqual(p.state, .new)
        XCTAssertEqual(p.box, 0)
        XCTAssertNil(p.dueAt)
        XCTAssertFalse(p.isDue(at: now))
    }

    func testCorrectAnswersClimbTheBoxes() {
        var p = WordProgress(wordID: 1)
        let expectedDays: [Double] = [1, 2, 4, 8, 16]
        for (index, days) in expectedDays.enumerated() {
            p = Leitner.review(p, grade: .good, at: now)
            XCTAssertEqual(p.box, index + 1)
            XCTAssertEqual(p.state, .learning)
            XCTAssertEqual(p.dueAt, now.addingTimeInterval(days * day))
        }
        XCTAssertEqual(p.reviews, 5)
        XCTAssertEqual(p.lapses, 0)
    }

    func testCorrectAnswerInTheLastBoxGraduates() {
        var p = WordProgress(wordID: 1)
        for _ in 0..<5 {
            p = Leitner.review(p, grade: .good, at: now)
        }
        p = Leitner.review(p, grade: .good, at: now)
        XCTAssertEqual(p.state, .known)
        XCTAssertEqual(p.box, 5)
        XCTAssertFalse(p.knownOverride)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(Leitner.refresherDelay))
    }

    func testWrongAnswerGoesBackToBoxOneSoon() {
        var p = WordProgress(wordID: 1)
        p = Leitner.review(p, grade: .good, at: now)
        p = Leitner.review(p, grade: .good, at: now)
        p = Leitner.review(p, grade: .good, at: now)
        XCTAssertEqual(p.box, 3)
        p = Leitner.review(p, grade: .again, at: now)
        XCTAssertEqual(p.box, 1)
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.lapses, 1)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(10 * 60))
        XCTAssertTrue(p.isDue(at: now.addingTimeInterval(10 * 60)))
        XCTAssertFalse(p.isDue(at: now.addingTimeInterval(9 * 60)))
    }

    func testWrongAnswerOnANewWordIsNotALapse() {
        let p = Leitner.review(WordProgress(wordID: 1), grade: .again, at: now)
        XCTAssertEqual(p.lapses, 0)
        XCTAssertEqual(p.box, 1)
    }

    func testMarkKnownThenRefreshers() {
        var p = Leitner.markKnown(WordProgress(wordID: 1), at: now)
        XCTAssertEqual(p.state, .known)
        XCTAssertTrue(p.knownOverride)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(30 * day))
        XCTAssertFalse(p.isDue(at: now.addingTimeInterval(29 * day)))
        XCTAssertTrue(p.isDue(at: now.addingTimeInterval(30 * day)))

        // A correct refresher keeps a self-declared word known, whatever its box.
        let later = now.addingTimeInterval(30 * day)
        p = Leitner.review(p, grade: .good, at: later)
        XCTAssertEqual(p.state, .known)
        XCTAssertEqual(p.dueAt, later.addingTimeInterval(30 * day))

        // A wrong refresher puts it back into learning.
        p = Leitner.review(p, grade: .again, at: later)
        XCTAssertEqual(p.state, .learning)
        XCTAssertFalse(p.knownOverride)
        XCTAssertEqual(p.box, 1)
        XCTAssertEqual(p.lapses, 1)
    }

    func testUndoKnown() {
        let fresh = Leitner.undoKnown(Leitner.markKnown(WordProgress(wordID: 1), at: now), at: now)
        XCTAssertEqual(fresh.state, .new)
        XCTAssertNil(fresh.dueAt)
        XCTAssertFalse(fresh.knownOverride)

        var reviewed = Leitner.review(WordProgress(wordID: 2), grade: .good, at: now)
        reviewed = Leitner.undoKnown(Leitner.markKnown(reviewed, at: now), at: now)
        XCTAssertEqual(reviewed.state, .learning)
        XCTAssertEqual(reviewed.box, 1)
        XCTAssertEqual(reviewed.dueAt, now)
    }

    func testExposureIsNotAReview() {
        var p = WordProgress(wordID: 1)
        p = Leitner.markExposure(p, at: now)
        p = Leitner.markExposure(p, at: now)
        XCTAssertEqual(p.exposures, 2)
        XCTAssertEqual(p.lastSeenAt, now)
        XCTAssertEqual(p.state, .new)
        XCTAssertEqual(p.box, 0)
        XCTAssertEqual(p.reviews, 0)
        XCTAssertNil(p.dueAt)
    }
}
