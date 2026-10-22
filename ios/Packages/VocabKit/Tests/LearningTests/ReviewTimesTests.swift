import XCTest
import Learning

/// The exact answer times on `WordProgress` (`lastReviewedAt`, `lastGrade`, `firstReviewedAt`,
/// `refresherStep`): who writes them, progress files written before them, a file read back by an
/// earlier build, and their size.
final class ReviewTimesTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000.25)
    private let day: TimeInterval = 86_400
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("ReviewTimes-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func makeStore() -> ProgressStore {
        return ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
    }

    /// progress.json as the builds before these fields wrote it: a learning word, a new word and a
    /// graduated word.
    private let legacyFile = """
    [{"box":2,"due_at":1700086400,"exposures":3,"known_override":false,"lapses":0,"last_seen_at":1700000000,\
    "reviews":2,"saved":false,"state":"learning","word_id":5},\
    {"box":0,"exposures":1,"known_override":false,"lapses":0,"reviews":0,"saved":true,"state":"new","word_id":6},\
    {"box":5,"due_at":1702592000,"exposures":0,"known_override":false,"lapses":1,"last_seen_at":1700000000,\
    "reviews":9,"saved":false,"state":"known","word_id":7}]
    """

    /// `WordProgress` as the builds before these fields declared it (synthesized decoding).
    private struct EarlierWordProgress: Decodable {
        let wordID: Int
        let state: LearningState
        let box: Int
        let dueAt: Date?
        let exposures: Int
        let lastSeenAt: Date?
        let reviews: Int
        let lapses: Int
        let knownOverride: Bool
        let saved: Bool

        enum CodingKeys: String, CodingKey {
            case wordID = "word_id"
            case state
            case box
            case dueAt = "due_at"
            case exposures
            case lastSeenAt = "last_seen_at"
            case reviews
            case lapses
            case knownOverride = "known_override"
            case saved
        }
    }

    // MARK: Who writes them

    func testEveryAnswerRecordsItsTimeAndGrade() {
        let first = Leitner.review(WordProgress(wordID: 1), grade: .hard, at: now)
        XCTAssertEqual(first.lastReviewedAt, now)
        XCTAssertEqual(first.lastGrade, .hard)
        XCTAssertEqual(first.firstReviewedAt, now)

        let later = now.addingTimeInterval(day)
        let second = Leitner.review(first, grade: .again, at: later)
        XCTAssertEqual(second.lastReviewedAt, later)
        XCTAssertEqual(second.lastGrade, .again)
        XCTAssertEqual(second.firstReviewedAt, now, "only the first answer sets it")
        XCTAssertEqual(second.lastSeenAt, later)
    }

    func testTapsAndClaimsAreNotAnswers() {
        let answered = Leitner.review(WordProgress(wordID: 1), grade: .good, at: now)
        let tapped = Leitner.markExposure(answered, at: now.addingTimeInterval(60))
        let claimed = Leitner.markKnown(tapped, at: now.addingTimeInterval(120))
        let undone = Leitner.undoKnown(claimed, at: now.addingTimeInterval(180))
        for p in [tapped, claimed, undone] {
            XCTAssertEqual(p.lastReviewedAt, now)
            XCTAssertEqual(p.lastGrade, .good)
            XCTAssertEqual(p.firstReviewedAt, now)
        }
        XCTAssertEqual(tapped.lastSeenAt, now.addingTimeInterval(60))
        XCTAssertEqual(claimed.lastSeenAt, now.addingTimeInterval(120))

        // Never answered: nothing on record.
        let claimedOnly = Leitner.markKnown(Leitner.markExposure(WordProgress(wordID: 2), at: now), at: now)
        XCTAssertNil(claimedOnly.lastReviewedAt)
        XCTAssertNil(claimedOnly.lastGrade)
        XCTAssertNil(claimedOnly.firstReviewedAt)
    }

    func testAWordFirstAnsweredBeforeTheFieldsExistedGetsNoFirstAnswerDate() {
        var old = WordProgress(wordID: 1)
        old.state = .learning
        old.box = 2
        old.reviews = 2
        old.dueAt = now
        old.lastSeenAt = now.addingTimeInterval(-2 * day)
        let p = Leitner.review(old, grade: .good, at: now)
        XCTAssertEqual(p.lastReviewedAt, now)
        XCTAssertEqual(p.lastGrade, .good)
        XCTAssertNil(p.firstReviewedAt, "its first answer came earlier, at a time nobody knows")
    }

    // MARK: Files written before

    func testAFileWrittenBeforeLoadsAndIsWrittenBackInItsOldShape() throws {
        let store = makeStore()
        try Data(legacyFile.utf8).write(to: store.fileURL)
        let loaded = try store.load()
        XCTAssertEqual(loaded.outcome, .loaded)
        XCTAssertEqual(loaded.progress.count, 3)
        for p in loaded.progress.values {
            XCTAssertNil(p.lastReviewedAt)
            XCTAssertNil(p.lastGrade)
            XCTAssertNil(p.firstReviewedAt)
            XCTAssertNil(p.refresherStep)
        }
        XCTAssertEqual(loaded.progress[5]?.dueAt, Date(timeIntervalSince1970: 1_700_086_400))
        XCTAssertEqual(loaded.progress[7]?.state, .known)

        // Saved again without an answer: no key appears that the earlier file did not have.
        try store.save(loaded.progress)
        let saved = try XCTUnwrap(try JSONSerialization.jsonObject(with: Data(contentsOf: store.fileURL)) as? [[String: Any]])
        let earlier = try XCTUnwrap(try JSONSerialization.jsonObject(with: Data(legacyFile.utf8)) as? [[String: Any]])
        XCTAssertEqual(saved.map { Set($0.keys) }, earlier.map { Set($0.keys) })
        XCTAssertEqual(try store.load().progress, loaded.progress)
    }

    func testTheNextAnswerAddsTheFieldsAndTheyRoundTrip() throws {
        let store = makeStore()
        try Data(legacyFile.utf8).write(to: store.fileURL)
        var progress = try store.load().progress
        progress[5] = Leitner.review(try XCTUnwrap(progress[5]), grade: .good, at: now)
        progress[6] = Leitner.review(try XCTUnwrap(progress[6]), grade: .easy, at: now)
        // A refresher of the earlier build's graduated word: the second wait, 60 days.
        progress[7] = Leitner.review(try XCTUnwrap(progress[7]), grade: .good, at: now)
        try store.save(progress)

        let reloaded = try store.load().progress
        XCTAssertEqual(reloaded, progress)
        XCTAssertEqual(reloaded[5]?.lastReviewedAt, now, "fractions of a second survive")
        XCTAssertEqual(reloaded[5]?.box, 3)
        XCTAssertNil(reloaded[5]?.firstReviewedAt)
        XCTAssertEqual(reloaded[6]?.firstReviewedAt, now)
        XCTAssertEqual(reloaded[6]?.lastGrade, .easy)
        XCTAssertEqual(reloaded[7]?.refresherStep, 1)
        XCTAssertEqual(reloaded[7]?.dueAt, now.addingTimeInterval(60 * day))
    }

    // MARK: Read back by an earlier build

    func testAnEarlierBuildStillReadsANewFile() throws {
        var known = WordProgress(wordID: 3)
        var at = now
        for _ in 0..<7 {
            known = Leitner.review(known, grade: .good, at: at)
            at = known.dueAt ?? at
        }
        XCTAssertEqual(known.refresherStep, 1)
        let progress = [
            1: Leitner.review(WordProgress(wordID: 1), grade: .hard, at: now),
            2: Leitner.review(Leitner.markKnown(WordProgress(wordID: 2), at: now), grade: .again, at: now),
            3: known,
            4: Leitner.markExposure(WordProgress(wordID: 4), at: now),
        ]
        let store = makeStore()
        try store.save(progress)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let earlier = try decoder.decode([EarlierWordProgress].self, from: Data(contentsOf: store.fileURL))
        XCTAssertEqual(earlier.map { $0.wordID }, [1, 2, 3, 4])
        for old in earlier {
            let p = try XCTUnwrap(progress[old.wordID])
            XCTAssertEqual(old.state, p.state)
            XCTAssertEqual(old.box, p.box)
            XCTAssertEqual(old.dueAt, p.dueAt)
            XCTAssertEqual(old.lastSeenAt, p.lastSeenAt)
            XCTAssertEqual(old.reviews, p.reviews)
            XCTAssertEqual(old.lapses, p.lapses)
            XCTAssertEqual(old.knownOverride, p.knownOverride)
            XCTAssertEqual(old.exposures, p.exposures)
        }
    }

    // MARK: Values this build cannot read

    func testALaterFieldThisBuildCannotReadIsDroppedNotTheFile() throws {
        let store = makeStore()
        let text = """
        [{"box":1,"due_at":1700086400,"exposures":0,"first_reviewed_at":"yesterday","known_override":false,"lapses":0,\
        "last_grade":"perfect","last_reviewed_at":1700000000,"last_seen_at":1700000000,"refresher_step":"two",\
        "reviews":1,"saved":false,"state":"learning","word_id":5}]
        """
        try Data(text.utf8).write(to: store.fileURL)
        let loaded = try store.load()
        XCTAssertEqual(loaded.outcome, .loaded)
        let p = try XCTUnwrap(loaded.progress[5])
        XCTAssertEqual(p.box, 1)
        XCTAssertEqual(p.lastReviewedAt, Date(timeIntervalSince1970: 1_700_000_000))
        XCTAssertNil(p.lastGrade)
        XCTAssertNil(p.firstReviewedAt)
        XCTAssertNil(p.refresherStep)

        // The fields every build wrote stay strict, as before: a broken one still sets the file
        // aside (and nothing is saved over it).
        try Data(text.replacingOccurrences(of: "\"box\":1", with: "\"box\":\"one\"").utf8).write(to: store.fileURL)
        let broken = try store.load()
        guard case .startedOver = broken.outcome else {
            return XCTFail("expected the damaged file to be set aside, got \(broken.outcome)")
        }
    }

    // MARK: Size

    func testTheNewFieldsCostAboutAHundredBytesAWord() throws {
        // Dates with a full fraction, as `Date()` gives them; every field filled: graduated,
        // refreshed twice (step 2), tapped on the widget since, saved.
        let start = Date(timeIntervalSince1970: 1_792_700_000.123_456_7)
        var p = WordProgress(wordID: 12_345)
        var at = start
        for _ in 0..<8 {
            p = Leitner.review(p, grade: .good, at: at)
            at = (p.dueAt ?? at).addingTimeInterval(3_600.987_654_3)
        }
        p = Leitner.markExposure(p, at: at)
        p.saved = true
        XCTAssertEqual(p.refresherStep, 2)
        XCTAssertNotNil(p.firstReviewedAt)

        let store = makeStore()
        try store.save([p.wordID: p])
        let full = try Data(contentsOf: store.fileURL).count
        var earlier = p
        earlier.lastReviewedAt = nil
        earlier.lastGrade = nil
        earlier.firstReviewedAt = nil
        earlier.refresherStep = nil
        try store.save([earlier.wordID: earlier])
        let before = try Data(contentsOf: store.fileURL).count

        XCTAssertLessThanOrEqual(full - before, 130, "four fields")
        // The whole file is written on every answer: 1,000 such words stay under 400 KB.
        XCTAssertLessThanOrEqual(full, 400)
    }
}
