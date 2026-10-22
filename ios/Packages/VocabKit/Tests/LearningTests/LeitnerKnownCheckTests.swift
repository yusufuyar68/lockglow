import XCTest
import CoreModels
import Learning

/// The slip rule (a wrong answer drops two boxes, a wrong refresher to box 3) and the one check
/// 3 days after "Biliyorum" (docs/tasarim/ogrenme_ilkeleri.md 2.2 and 2.3).
final class LeitnerKnownCheckTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let hour: TimeInterval = 3600
    private let day: TimeInterval = 86_400

    /// A word that sits in `box` (learning), reached by correct answers.
    private func word(inBox box: Int) -> WordProgress {
        var p = WordProgress(wordID: 1)
        for _ in 0..<box {
            p = Leitner.review(p, grade: .good, at: now)
        }
        XCTAssertEqual(p.box, box)
        return p
    }

    private func card(_ id: Int) -> WidgetWord {
        return WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e")
    }

    // MARK: slips

    func testAWrongAnswerDropsTwoBoxesNeverBelowOne() {
        let landing = [1: 1, 2: 1, 3: 1, 4: 2, 5: 3]
        for (box, expected) in landing.sorted(by: { $0.key < $1.key }) {
            let start = word(inBox: box)
            let p = Leitner.review(start, grade: .again, at: now)
            XCTAssertEqual(p.box, expected, "from box \(box)")
            XCTAssertEqual(p.state, .learning)
            XCTAssertEqual(p.lapses, 1)
            XCTAssertEqual(p.reviews, start.reviews + 1)
            // Asked again in the next round.
            XCTAssertEqual(p.dueAt, now.addingTimeInterval(10 * 60), "from box \(box)")
        }
    }

    func testAfterASlipTheWordClimbsOnFromItsNewBox() {
        var p = Leitner.review(word(inBox: 5), grade: .again, at: now)
        XCTAssertEqual(p.box, 3)
        p = Leitner.review(p, grade: .good, at: now)
        XCTAssertEqual(p.box, 4)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(8 * day))
    }

    func testAWrongRefresherDropsAGraduatedWordToBoxThree() {
        var p = Leitner.review(word(inBox: 5), grade: .good, at: now)
        XCTAssertEqual(p.state, .known)
        XCTAssertFalse(p.awaitsKnownCheck)
        let later = now.addingTimeInterval(30 * day)
        p = Leitner.review(p, grade: .again, at: later)
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.box, 3)
        XCTAssertEqual(p.lapses, 1)
        XCTAssertEqual(p.dueAt, later.addingTimeInterval(10 * 60))
    }

    // MARK: "Biliyorum"

    func testBiliyorumWaitsThreeDaysForOneCheck() {
        let start = word(inBox: 2)
        let p = Leitner.markKnown(start, at: now)
        XCTAssertEqual(p.state, .known)
        XCTAssertTrue(p.awaitsKnownCheck)
        XCTAssertEqual(p.box, 2, "kept for an undo")
        XCTAssertEqual(p.reviews, start.reviews, "a claim is not a review")
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(3 * day))
        XCTAssertFalse(p.isDue(at: now.addingTimeInterval(3 * day - 1)))
        XCTAssertTrue(p.isDue(at: now.addingTimeInterval(3 * day)))
        // Asked with the recall question, never with four options.
        XCTAssertEqual(ReviewPlanner.questionKind(for: p, hasCloze: true), .recall)
    }

    func testTappingBiliyorumAgainDoesNotPutTheCheckOff() {
        let first = Leitner.markKnown(WordProgress(wordID: 1), at: now)
        let second = Leitner.markKnown(first, at: now.addingTimeInterval(2 * day))
        XCTAssertEqual(second.dueAt, now.addingTimeInterval(3 * day))
        XCTAssertEqual(second.lastSeenAt, now.addingTimeInterval(2 * day))
        XCTAssertTrue(second.awaitsKnownCheck)
    }

    func testPassingTheCheckMakesTheWordKnown() {
        let check = now.addingTimeInterval(3 * day)
        let waits: [(ReviewGrade, TimeInterval)] = [(.good, 30 * day), (.easy, 30 * day), (.hard, 15 * day)]
        for (grade, wait) in waits {
            let p = Leitner.review(Leitner.markKnown(word(inBox: 1), at: now), grade: grade, at: check)
            XCTAssertEqual(p.state, .known, "\(grade)")
            XCTAssertFalse(p.knownOverride, "\(grade)")
            XCTAssertFalse(p.awaitsKnownCheck, "\(grade)")
            XCTAssertEqual(p.dueAt, check.addingTimeInterval(wait), "\(grade)")
            XCTAssertEqual(p.lapses, 0)
        }
    }

    func testFailingTheCheckSendsTheWordBackToTanis() {
        let start = word(inBox: 2)
        let check = now.addingTimeInterval(3 * day)
        let failed = Leitner.review(Leitner.markKnown(start, at: now), grade: .again, at: check)
        XCTAssertEqual(failed.state, .new)
        XCTAssertEqual(failed.box, 0)
        XCTAssertNil(failed.dueAt)
        XCTAssertFalse(failed.knownOverride)
        XCTAssertTrue(failed.returnsToIntro)
        XCTAssertEqual(failed.lapses, 1)
        XCTAssertEqual(failed.reviews, start.reviews + 1)
        XCTAssertFalse(failed.isDue(at: check.addingTimeInterval(day)), "not a due word: it waits for Tanış")

        // The next "Tanış" takes it first, before the deck's new words.
        let feed = [card(5), card(6), card(1)]
        let intro = ReviewPlanner.introWords(feed: feed, all: feed, progress: [1: failed], limit: 2)
        XCTAssertEqual(intro.map { $0.id }, [1, 5])

        // Its "Hatırla" gives it a box again.
        let relearned = Leitner.review(failed, grade: IntroRound.Result.firstTry.grade, at: check)
        XCTAssertEqual(relearned.state, .learning)
        XCTAssertEqual(relearned.box, 1)
        XCTAssertEqual(relearned.dueAt, check.addingTimeInterval(day))
        XCTAssertFalse(relearned.returnsToIntro)
    }

    func testAWordMarkedBeforeTheCheckExistedGetsItOnItsDueDate() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("KnownCheck-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        // Written by the earlier build: "Biliyorum" on 1_700_000_000, kept for 30 days, never
        // checked. No key was added since.
        let legacy = """
        [{"word_id":8,"state":"known","box":0,"due_at":1702592000,"exposures":2,"last_seen_at":1700000000,\
        "reviews":0,"lapses":0,"known_override":true,"saved":false}]
        """
        let store = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
        try Data(legacy.utf8).write(to: store.fileURL)
        let loaded = try store.load()
        XCTAssertEqual(loaded.outcome, .loaded)
        let p = try XCTUnwrap(loaded.progress[8])
        XCTAssertTrue(p.awaitsKnownCheck)
        let due = Date(timeIntervalSince1970: 1_702_592_000)
        XCTAssertFalse(p.isDue(at: due.addingTimeInterval(-1)))
        XCTAssertTrue(p.isDue(at: due))
        XCTAssertEqual(ReviewPlanner.questionKind(for: p, hasCloze: true), .recall)

        // "Biliyorum" again does not move the old date either.
        XCTAssertEqual(Leitner.markKnown(p, at: now.addingTimeInterval(day)).dueAt, due)

        // "Bulamadım" sends it back to "Tanış", "Buldum" keeps it known.
        XCTAssertTrue(Leitner.review(p, grade: .again, at: due).returnsToIntro)
        let found = Leitner.review(p, grade: .good, at: due)
        XCTAssertEqual(found.state, .known)
        XCTAssertFalse(found.awaitsKnownCheck)

        // The new states save and load like any other.
        var progress = loaded.progress
        progress[8] = Leitner.review(p, grade: .again, at: due)
        progress[9] = Leitner.markKnown(WordProgress(wordID: 9), at: now)
        try store.save(progress)
        XCTAssertEqual(try store.load().progress, progress)
    }
}
