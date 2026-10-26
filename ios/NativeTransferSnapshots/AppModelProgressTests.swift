import XCTest
import Foundation
import CoreModels
import Learning
@testable import Lockglow

/// Runs the real AppModel on an explicitly disposable CI simulator. It never calls `start()`.
/// The shared metrics recorders have caches as well as files, so these tests must not run in a
/// simulator containing somebody's data. CI opts in before any defaults, files or caches change.
final class AppModelProgressTests: XCTestCase {
    private var defaultsSnapshot: [String: Any]?
    private var directory: URL?
    private let directoryPrefix = "Lockglow-AppModelProgressTests-"
    // Binary fractions survive both Date's reference epoch and the file's Unix epoch exactly.
    private let fixtureTime = Date(timeIntervalSince1970: 1_760_011_200.375)

    override func setUpWithError() throws {
        guard ProcessInfo.processInfo.environment["LOCKGLOW_NATIVE_MODEL_TESTS"] == "1" else {
            throw XCTSkip("Requires LOCKGLOW_NATIVE_MODEL_TESTS=1 in a disposable CI simulator")
        }
        #if !targetEnvironment(simulator)
        throw XCTSkip("AppModel progress tests may only run in a disposable simulator")
        #endif

        try super.setUpWithError()
        defaultsSnapshot = lockglowDefaults()
        clearLockglowDefaults()
        // Avoid the launch gate probing App Group files when the test model is constructed.
        AppPreferences.onboardingCompleted = true
        AppPreferences.schedulerKind = .leitner
        LocalMetricsRecorder.shared.reset()
        StudyTimeRecorder.shared.reset()

        let root = FileManager.default.temporaryDirectory.resolvingSymlinksInPath()
        let target = root.appendingPathComponent(directoryPrefix + UUID().uuidString, isDirectory: true)
        directory = target
        try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        // A skipped setUp must not reset or write anything either.
        if let snapshot = defaultsSnapshot {
            LocalMetricsRecorder.shared.reset()
            StudyTimeRecorder.shared.reset()
            clearLockglowDefaults()
            for (key, value) in snapshot {
                UserDefaults.standard.set(value, forKey: key)
            }
            defaultsSnapshot = nil
        }
        if let directory = directory {
            let target = directory.resolvingSymlinksInPath().standardizedFileURL
            let root = FileManager.default.temporaryDirectory.resolvingSymlinksInPath().standardizedFileURL
            guard target.deletingLastPathComponent() == root,
                  target.lastPathComponent.hasPrefix(directoryPrefix) else {
                XCTFail("Refusing to remove a directory outside this test's temporary root")
                return
            }
            try FileManager.default.removeItem(at: target)
            self.directory = nil
        }
        try super.tearDownWithError()
    }

    @MainActor
    func testKnownUndoRestoresEveryFieldAndDisk() throws {
        let word = makeWord(id: 900_101)
        let sibling = richProgress(wordID: 900_199)
        let cases: [(String, WordProgress?, TimeInterval)] = [
            ("fresh", nil, KnownUndo.window),
            ("previously-studied", richProgress(wordID: word.id), 10),
        ]

        for (name, previous, window) in cases {
            let (store, log) = try persistence(named: name)
            let model = AppModel(progressStore: store, reviewLog: log)
            defer { model.dismissKnownUndo() }
            var initial = [sibling.wordID: sibling]
            initial[word.id] = previous
            XCTAssertTrue(model.replaceProgress(initial), "Fixture save failed: \(name)")
            XCTAssertEqual(model.progress, initial)
            try assertPersisted(initial, in: store, exactDates: true)

            let oldEntry = ReviewLogEntry(
                wordID: sibling.wordID, at: fixtureTime, grade: .hard,
                source: .review, reviews: sibling.reviews
            )
            try log.append([oldEntry])
            let logBefore = try Data(contentsOf: log.fileURL)
            let countsBefore = answerCounts()
            let studyBefore = StudyTimeRecorder.shared.snapshot()

            let beforeTap = Date()
            model.markKnown(word, undoWindow: window)
            let afterTap = Date()
            let marked = try XCTUnwrap(model.progress[word.id])
            let undo = try XCTUnwrap(model.knownUndo)
            XCTAssertEqual(undo.word, word)
            XCTAssertEqual(undo.previous, previous)
            XCTAssertEqual(undo.marked, marked)
            XCTAssertGreaterThanOrEqual(undo.expiresAt, beforeTap.addingTimeInterval(window))
            XCTAssertLessThanOrEqual(undo.expiresAt, afterTap.addingTimeInterval(window))
            XCTAssertEqual(marked.state, .known)
            XCTAssertTrue(marked.knownOverride)
            let markedAt = try XCTUnwrap(marked.lastSeenAt)
            let due = try XCTUnwrap(marked.dueAt)
            XCTAssertGreaterThanOrEqual(markedAt, beforeTap)
            XCTAssertLessThanOrEqual(markedAt, afterTap)
            XCTAssertEqual(due.timeIntervalSince(markedAt), 3 * 86_400)

            // Only the claim's four fields change; all counters and optional memory survive.
            var expectedMarked = previous ?? WordProgress(wordID: word.id)
            expectedMarked.state = .known
            expectedMarked.knownOverride = true
            expectedMarked.lastSeenAt = markedAt
            expectedMarked.dueAt = due
            XCTAssertEqual(marked, expectedMarked)
            XCTAssertEqual(model.progress[sibling.wordID], sibling)
            try assertPersisted(model.progress, in: store)
            XCTAssertEqual(try Data(contentsOf: log.fileURL), logBefore)
            XCTAssertEqual(answerCounts(), countsBefore, "A claim must not count as an answer")

            model.undoKnown(word)
            // A previously absent word becomes a zero progress record, as the real API specifies.
            var restored = initial
            restored[word.id] = previous ?? WordProgress(wordID: word.id)
            XCTAssertNil(model.knownUndo)
            XCTAssertEqual(model.progress, restored)
            try assertPersisted(restored, in: store, exactDates: true)
            XCTAssertEqual(try log.entries(), [oldEntry])
            XCTAssertEqual(try Data(contentsOf: log.fileURL), logBefore)
            XCTAssertEqual(answerCounts(), countsBefore, "A claim or undo must not count as an answer")
            XCTAssertEqual(StudyTimeRecorder.shared.snapshot(), studyBefore)
        }
    }

    @MainActor
    func testNewAnswerSurvivesStaleKnownUndo() throws {
        let word = makeWord(id: 900_102)
        let before = richProgress(wordID: word.id)
        let sibling = richProgress(wordID: 900_199)
        let (store, log) = try persistence(named: "answer-after-claim")
        let model = AppModel(progressStore: store, reviewLog: log)
        defer { model.dismissKnownUndo() }
        XCTAssertTrue(model.replaceProgress([word.id: before, sibling.wordID: sibling]))
        let countsBefore = answerCounts()

        model.markKnown(word, undoWindow: 60)
        let marked = try XCTUnwrap(model.progress[word.id])
        XCTAssertEqual(model.knownUndo?.previous, before)
        XCTAssertTrue(marked.awaitsKnownCheck)
        let answered = model.recordReview(word, grade: .again, firstTryCorrect: false, seconds: 2.5)
        let answeredAt = try XCTUnwrap(answered.lastReviewedAt)
        XCTAssertEqual(answered.state, .new)
        XCTAssertEqual(answered.box, 0)
        XCTAssertNil(answered.dueAt)
        XCTAssertFalse(answered.knownOverride)
        XCTAssertEqual(answered.reviews, before.reviews + 1)
        XCTAssertEqual(answered.lapses, before.lapses + 1)
        XCTAssertEqual(answered.lastGrade, .again)
        XCTAssertEqual(answered.firstReviewedAt, before.firstReviewedAt)
        XCTAssertEqual(answered.fsrs, before.fsrs)
        XCTAssertEqual(answered.saved, before.saved)
        // The old memento still exists, so this really exercises stale undo rather than no undo.
        XCTAssertEqual(model.knownUndo?.marked, marked)
        XCTAssertEqual(model.progress, [word.id: answered, sibling.wordID: sibling])
        try assertPersisted(model.progress, in: store)

        let entries = try log.entries()
        let entry = try XCTUnwrap(entries.first)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entry.wordID, word.id)
        XCTAssertEqual(entry.grade, .again)
        XCTAssertEqual(entry.source, .review)
        XCTAssertEqual(entry.reviews, before.reviews + 1)
        XCTAssertEqual(entry.knownCheck, true)
        XCTAssertNil(entry.seed)
        let expectedEntry = ReviewLogEntry(
            wordID: word.id, at: answeredAt, grade: .again, source: .review,
            reviews: before.reviews + 1, knownCheck: true
        )
        XCTAssertEqual(try ReviewLog.line(entry), try ReviewLog.line(expectedEntry))
        var expectedCounts = countsBefore
        expectedCounts.reviews += 1
        expectedCounts.firstTryAnswers += 1
        expectedCounts.timedAnswers += 1
        expectedCounts.knownChecksFailed += 1
        XCTAssertEqual(answerCounts(), expectedCounts)
        XCTAssertEqual(model.newWordsStudiedToday(now: answeredAt), 0)
        XCTAssertEqual(model.reviewsDoneToday(now: answeredAt), 1)
        let bytesAfterAnswer = try Data(contentsOf: store.fileURL)
        let logAfterAnswer = try Data(contentsOf: log.fileURL)
        let studyAfterAnswer = StudyTimeRecorder.shared.snapshot()

        model.undoKnown(word)
        XCTAssertNil(model.knownUndo)
        XCTAssertEqual(model.progress, [word.id: answered, sibling.wordID: sibling])
        XCTAssertEqual(try Data(contentsOf: store.fileURL), bytesAfterAnswer)
        try assertPersisted(model.progress, in: store)
        XCTAssertEqual(try Data(contentsOf: log.fileURL), logAfterAnswer)
        XCTAssertEqual(answerCounts(), expectedCounts)
        XCTAssertEqual(StudyTimeRecorder.shared.snapshot(), studyAfterAnswer)
    }

    private func lockglowDefaults() -> [String: Any] {
        return UserDefaults.standard.dictionaryRepresentation().filter { $0.key.hasPrefix("lockglow.") }
    }

    private func clearLockglowDefaults() {
        for key in lockglowDefaults().keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private func persistence(named name: String) throws -> (ProgressStore, ReviewLog) {
        let folder = try XCTUnwrap(directory).appendingPathComponent(name, isDirectory: true)
        return (
            ProgressStore(fileURL: folder.appendingPathComponent("progress.json")),
            ReviewLog(fileURL: folder.appendingPathComponent("review_log.jsonl"))
        )
    }

    /// Date() can lose one reference-epoch ULP on a Unix-epoch round trip. Compare the exact
    /// canonical file form for live timestamps; exact struct equality is reserved for fixtures.
    private func assertPersisted(
        _ expected: [Int: WordProgress], in store: ProgressStore, exactDates: Bool = false,
        file: StaticString = #filePath, line: UInt = #line
    ) throws {
        let bytes = try Data(contentsOf: store.fileURL)
        XCTAssertEqual(bytes, try canonicalProgress(expected), file: file, line: line)
        let loaded = try store.load()
        XCTAssertEqual(loaded.outcome, .loaded, file: file, line: line)
        XCTAssertEqual(try canonicalProgress(loaded.progress), bytes, file: file, line: line)
        if exactDates {
            XCTAssertEqual(loaded.progress, expected, file: file, line: line)
        }
    }

    private func canonicalProgress(_ progress: [Int: WordProgress]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(progress.values.sorted { $0.wordID < $1.wordID })
    }

    private func makeWord(id: Int) -> WidgetWord {
        return WidgetWord(
            id: id, lemma: "test word", pos: "n", level: "A1", defMicro: "a fixture",
            defShort: "A word for an isolated progress test.", exampleEN: "This is a test word."
        )
    }

    private func richProgress(wordID: Int) -> WordProgress {
        var p = WordProgress(wordID: wordID)
        p.state = .learning
        p.box = 4
        p.dueAt = fixtureTime.addingTimeInterval(8 * 86_400 + 0.125)
        p.exposures = 7
        p.lastSeenAt = fixtureTime.addingTimeInterval(0.25)
        p.reviews = 13
        p.lapses = 2
        p.saved = true
        p.lastReviewedAt = fixtureTime.addingTimeInterval(-86_400)
        p.lastGrade = .hard
        p.firstReviewedAt = fixtureTime.addingTimeInterval(-90 * 86_400)
        p.refresherStep = 1
        p.fsrs = FSRSState(
            stability: 3.25, difficulty: 4.5, phase: .relearning, step: 1,
            lastReviewAt: fixtureTime.addingTimeInterval(-86_400), reviews: 12, shelfBefore: 3
        )
        return p
    }

    // Count only learning events: host scene/box snapshots may add a zero-answer day.
    private struct AnswerCounts: Equatable {
        var newWords = 0
        var reviews = 0
        var firstTryAnswers = 0
        var firstTryCorrect = 0
        var timedAnswers = 0
        var knownChecksPassed = 0
        var knownChecksFailed = 0
    }

    private func answerCounts() -> AnswerCounts {
        return LocalMetricsRecorder.shared.snapshot().days.reduce(into: AnswerCounts()) { total, day in
            total.newWords += day.newWords
            total.reviews += day.reviews
            total.firstTryAnswers += day.firstTryAnswers
            total.firstTryCorrect += day.firstTryCorrect
            total.timedAnswers += day.timedAnswers
            total.knownChecksPassed += day.knownChecksPassed
            total.knownChecksFailed += day.knownChecksFailed
        }
    }
}
