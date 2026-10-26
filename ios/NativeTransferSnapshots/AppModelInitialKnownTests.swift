import XCTest
import Foundation
import CoreModels
import Learning
@testable import Lockglow

/// Real AppModel batches, isolated from content loading, App Group and cloud startup.
final class AppModelInitialKnownTests: XCTestCase {
    private var defaultsSnapshot: [String: Any]?
    private var directory: URL?
    private let prefix = "Lockglow-AppModelInitialKnownTests-"
    private let instant = Date(timeIntervalSince1970: 1_760_011_200.375)

    override func setUpWithError() throws {
        guard ProcessInfo.processInfo.environment["LOCKGLOW_NATIVE_MODEL_TESTS"] == "1" else {
            throw XCTSkip("Requires LOCKGLOW_NATIVE_MODEL_TESTS=1 in a disposable CI simulator")
        }
        #if !targetEnvironment(simulator)
        throw XCTSkip("Initial selection tests require a disposable simulator")
        #endif
        try super.setUpWithError()
        defaultsSnapshot = ownDefaults()
        clearDefaults()
        AppPreferences.onboardingCompleted = true
        AppPreferences.schedulerKind = .leitner
        LocalMetricsRecorder.shared.reset()
        StudyTimeRecorder.shared.reset()
        let folder = FileManager.default.temporaryDirectory.resolvingSymlinksInPath()
            .appendingPathComponent(prefix + UUID().uuidString, isDirectory: true)
        directory = folder
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let snapshot = defaultsSnapshot {
            LocalMetricsRecorder.shared.reset()
            StudyTimeRecorder.shared.reset()
            clearDefaults()
            for (key, value) in snapshot { UserDefaults.standard.set(value, forKey: key) }
            defaultsSnapshot = nil
        }
        if let directory = directory {
            let target = directory.resolvingSymlinksInPath().standardizedFileURL
            let root = FileManager.default.temporaryDirectory.resolvingSymlinksInPath().standardizedFileURL
            guard target.deletingLastPathComponent() == root, target.lastPathComponent.hasPrefix(prefix) else {
                XCTFail("Refusing cleanup outside the unique test directory")
                return
            }
            try FileManager.default.removeItem(at: target)
            self.directory = nil
        }
        try super.tearDownWithError()
    }

    @MainActor
    func testBatchFailurePreservesProgressAndPreferences() throws {
        let a = word(910_001), b = word(910_002)
        let initial = [910_099: studied(910_099)]
        let folder = try location("metadata-refused")
        let store = ProgressStore(fileURL: folder.appendingPathComponent("progress.json"))
        let metadata = InitialKnownSelectionStore(fileURL: folder.appendingPathComponent("claims.json"), maxBytes: 1)
        let log = ReviewLog(fileURL: folder.appendingPathComponent("review_log.jsonl"))
        let model = AppModel(progressStore: store, reviewLog: log, initialKnownStore: metadata)
        defer { model.dismissKnownUndo() }
        XCTAssertTrue(model.replaceProgress(initial))
        model.setDeckChoice(DeckChoice(topicIDs: ["food_drink"], startLevel: .a1))
        AppPreferences.chooseDailyNewWords(5)
        model.setDailyNewWords(5)
        model.showOnboarding()
        let beforeChoice = model.deckChoice
        let beforeDefaults = ownDefaults() as NSDictionary
        let beforeBytes = try Data(contentsOf: store.fileURL)
        let session = selection([a, b], baseline: initial)
        let targetChoice = DeckChoice(topicIDs: ["travel"], startLevel: .b1)

        XCTAssertFalse(model.applyOnboardingChoices(
            choice: targetChoice, explicitDailyChoice: 15, knownSelection: [a.id, b.id],
            session: session, now: instant
        ))
        XCTAssertEqual(model.progress, initial)
        XCTAssertEqual(try Data(contentsOf: store.fileURL), beforeBytes)
        XCTAssertEqual(model.deckChoice, beforeChoice)
        XCTAssertEqual(ownDefaults() as NSDictionary, beforeDefaults)
        XCTAssertEqual(model.dailyNewWords, 5)
        XCTAssertTrue(model.showsOnboarding)
        XCTAssertNotNil(model.onboardingChoiceError)
        XCTAssertTrue(model.initialKnownWordIDs.isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: metadata.fileURL.path))
        XCTAssertTrue(try log.entries().isEmpty)

        // Skipping the optional feature does not touch learning or its refused metadata file.
        XCTAssertTrue(model.applyOnboardingChoices(
            choice: targetChoice, explicitDailyChoice: 15, knownSelection: nil, session: nil, now: instant
        ))
        XCTAssertEqual(model.progress, initial)
        XCTAssertEqual(try Data(contentsOf: store.fileURL), beforeBytes)
        XCTAssertFalse(FileManager.default.fileExists(atPath: metadata.fileURL.path))
        XCTAssertEqual(model.dailyNewWords, 15)
        XCTAssertEqual(AppPreferences.chosenDailyNewWords, 15)
        XCTAssertEqual(model.deckChoice, targetChoice)

        // A deterministic primary failure after metadata succeeds: its parent is a regular file.
        let blockedFolder = try location("primary-refused")
        try FileManager.default.createDirectory(at: blockedFolder, withIntermediateDirectories: true)
        let blocker = blockedFolder.appendingPathComponent("primary-parent")
        let blockerBytes = Data("test-owned file".utf8)
        try blockerBytes.write(to: blocker)
        let blocked = ProgressStore(fileURL: blocker.appendingPathComponent("progress.json"))
        let pendingMetadata = InitialKnownSelectionStore(fileURL: blockedFolder.appendingPathComponent("claims.json"))
        let pendingModel = AppModel(progressStore: blocked, initialKnownStore: pendingMetadata)
        defer { pendingModel.dismissKnownUndo() }
        let fresh = selection([a, b], baseline: [:])
        let preferencesBeforePrimary = ownDefaults() as NSDictionary
        XCTAssertFalse(pendingModel.applyOnboardingChoices(
            choice: targetChoice, explicitDailyChoice: 20, knownSelection: [a.id, b.id],
            session: fresh, now: instant
        ))
        XCTAssertTrue(pendingModel.progress.isEmpty)
        XCTAssertTrue(pendingModel.initialKnownWordIDs.isEmpty)
        XCTAssertEqual(try Data(contentsOf: blocker), blockerBytes)
        XCTAssertEqual(pendingMetadata.claims?.count, 2, "Metadata must be written before the failed primary")
        XCTAssertEqual(ownDefaults() as NSDictionary, preferencesBeforePrimary)

        // Repair only the test-owned blocker, then retry the same logical batch.
        try FileManager.default.removeItem(at: blocker)
        try FileManager.default.createDirectory(at: blocker, withIntermediateDirectories: true)
        XCTAssertTrue(pendingModel.applyOnboardingChoices(
            choice: targetChoice, explicitDailyChoice: 20, knownSelection: [a.id, b.id],
            session: fresh, now: instant
        ))
        XCTAssertEqual(pendingModel.initialKnownWordIDs, [a.id, b.id])
        XCTAssertEqual(pendingModel.progress.count, 2)
        XCTAssertEqual(pendingModel.progress[a.id]?.dueAt, instant.addingTimeInterval(3 * 86_400))
        XCTAssertEqual(pendingModel.progress[b.id]?.dueAt, instant.addingTimeInterval(3 * 86_400))
        try assertDisk(pendingModel.progress, store: blocked, exact: true)
    }

    @MainActor
    func testReopenAndConditionalRestore() throws {
        let a = word(910_011), b = word(910_012), c = word(910_013)
        var exposed = WordProgress(wordID: b.id)
        exposed.exposures = 4
        exposed.saved = true
        exposed.lastSeenAt = instant.addingTimeInterval(-0.125)
        let initial = [b.id: exposed, c.id: studied(c.id)]
        let folder = try location("reopen")
        let store = ProgressStore(fileURL: folder.appendingPathComponent("progress.json"))
        let metadataURL = folder.appendingPathComponent("claims.json")
        let log = ReviewLog(fileURL: folder.appendingPathComponent("review_log.jsonl"))
        let model = AppModel(progressStore: store, reviewLog: log, initialKnownStore: InitialKnownSelectionStore(fileURL: metadataURL))
        defer { model.dismissKnownUndo() }
        XCTAssertTrue(model.replaceProgress(initial))
        let b1 = DeckChoice(startLevel: .b1)
        XCTAssertTrue(model.applyOnboardingChoices(choice: b1, explicitDailyChoice: nil, knownSelection: nil, session: nil))
        XCTAssertNil(AppPreferences.chosenDailyNewWords)
        XCTAssertEqual(model.dailyNewWords, 10)
        let session = selection([a, b, c], baseline: initial)
        let a1 = DeckChoice(startLevel: .a1)
        let counters = counts()
        XCTAssertTrue(model.applyOnboardingChoices(
            choice: a1, explicitDailyChoice: 5, knownSelection: [a.id, b.id], session: session, now: instant
        ))
        let marked = model.progress
        XCTAssertEqual(model.initialKnownWordIDs, [a.id, b.id])
        XCTAssertEqual(marked[c.id], initial[c.id])
        XCTAssertEqual(counts(), counters)
        XCTAssertTrue(try log.entries().isEmpty)
        let firstBytes = try Data(contentsOf: store.fileURL)
        let firstMetadata = try Data(contentsOf: metadataURL)
        XCTAssertTrue(model.applyOnboardingChoices(
            choice: a1, explicitDailyChoice: nil, knownSelection: [a.id, b.id],
            session: session, now: instant.addingTimeInterval(2 * 86_400)
        ))
        XCTAssertEqual(model.progress, marked)
        XCTAssertEqual(try Data(contentsOf: store.fileURL), firstBytes)
        XCTAssertEqual(try Data(contentsOf: metadataURL), firstMetadata)

        // The seam stays unstarted: load the actual files and seed through the real persistence API.
        let reopenedMetadata = InitialKnownSelectionStore(fileURL: metadataURL)
        let reopened = AppModel(progressStore: store, reviewLog: log, initialKnownStore: reopenedMetadata)
        defer { reopened.dismissKnownUndo() }
        XCTAssertTrue(reopened.replaceProgress(try store.load().progress))
        XCTAssertEqual(reopened.initialKnownWordIDs, [a.id, b.id])
        let edit = selection([a, b, c], baseline: reopened.progress, selected: reopened.initialKnownWordIDs)
        XCTAssertTrue(reopened.applyOnboardingChoices(
            choice: b1, explicitDailyChoice: nil, knownSelection: [b.id], session: edit,
            now: instant.addingTimeInterval(4 * 86_400)
        ))
        var onlyB = marked
        onlyB.removeValue(forKey: a.id)
        XCTAssertEqual(reopened.progress, onlyB)
        XCTAssertEqual(reopened.initialKnownWordIDs, [b.id])
        XCTAssertEqual(reopened.dailyNewWords, 5, "The explicit choice survives a later level change")
        XCTAssertTrue(reopened.applyOnboardingChoices(
            choice: b1, explicitDailyChoice: nil, knownSelection: [], session: edit,
            now: instant.addingTimeInterval(5 * 86_400)
        ))
        XCTAssertEqual(reopened.progress, initial)
        XCTAssertTrue(reopened.initialKnownWordIDs.isEmpty)
        try assertDisk(initial, store: store, exact: true)
        XCTAssertEqual(counts(), counters)
        XCTAssertTrue(try log.entries().isEmpty)

        let newSession = selection([a, b], baseline: initial)
        XCTAssertTrue(reopened.applyOnboardingChoices(
            choice: b1, explicitDailyChoice: nil, knownSelection: [b.id], session: newSession,
            now: instant.addingTimeInterval(10 * 86_400)
        ))
        XCTAssertEqual(reopened.progress[b.id]?.dueAt, instant.addingTimeInterval(13 * 86_400))
        let beforeRecovery = reopened.progress
        XCTAssertTrue(reopened.loadInitialKnownProvenance(
            progressURL: store.fileURL, outcome: .restoredFromBackup(setAside: nil, backupDate: instant)
        ))
        XCTAssertTrue(reopened.initialKnownWordIDs.isEmpty)
        XCTAssertEqual(reopened.progress, beforeRecovery)
        XCTAssertTrue(reopened.isProgressReadyForSync)
        XCTAssertEqual(reopenedMetadata.claims, [:])
        XCTAssertFalse(FileManager.default.fileExists(atPath: metadataURL.path))
        try assertDisk(beforeRecovery, store: store, exact: true)
    }

    @MainActor
    func testNewReviewProtectsInitialClaim() throws {
        let a = word(910_021), b = word(910_022)
        let folder = try location("review-protection")
        let store = ProgressStore(fileURL: folder.appendingPathComponent("progress.json"))
        let metadataURL = folder.appendingPathComponent("claims.json")
        let metadata = InitialKnownSelectionStore(fileURL: metadataURL)
        let log = ReviewLog(fileURL: folder.appendingPathComponent("review_log.jsonl"))
        let model = AppModel(progressStore: store, reviewLog: log, initialKnownStore: metadata)
        defer { model.dismissKnownUndo() }
        XCTAssertTrue(model.replaceProgress([:]))
        let session = selection([a, b], baseline: [:])
        let choice = DeckChoice(startLevel: .a1)
        XCTAssertTrue(model.applyOnboardingChoices(
            choice: choice, explicitDailyChoice: nil, knownSelection: [a.id], session: session, now: instant
        ))
        let answer = model.recordReview(a, grade: .again, firstTryCorrect: false, seconds: 2)
        XCTAssertEqual(answer.reviews, 1)
        XCTAssertEqual(answer.lapses, 1)
        XCTAssertTrue(model.initialKnownWordIDs.isEmpty)
        let logAfterAnswer = try Data(contentsOf: log.fileURL)
        let countsAfterAnswer = counts()
        XCTAssertTrue(model.applyOnboardingChoices(
            choice: choice, explicitDailyChoice: nil, knownSelection: [], session: session,
            now: instant.addingTimeInterval(4 * 86_400)
        ))
        XCTAssertEqual(model.progress[a.id], answer)
        XCTAssertNotNil(model.onboardingChoiceNotice)
        XCTAssertTrue(model.applyOnboardingChoices(
            choice: choice, explicitDailyChoice: nil, knownSelection: [a.id, b.id], session: session,
            now: instant.addingTimeInterval(4 * 86_400)
        ))
        XCTAssertEqual(model.progress[a.id], answer)
        XCTAssertEqual(model.initialKnownWordIDs, [b.id])
        XCTAssertEqual(try Data(contentsOf: log.fileURL), logAfterAnswer)
        XCTAssertEqual(counts(), countsAfterAnswer)
        try assertDisk(model.progress, store: store)

        // Damaged optional metadata does not damage or overwrite the primary or block a skip.
        let primary = try Data(contentsOf: store.fileURL)
        let corrupt = Data("broken metadata".utf8)
        try corrupt.write(to: metadataURL)
        let reopened = AppModel(progressStore: store, reviewLog: log, initialKnownStore: InitialKnownSelectionStore(fileURL: metadataURL))
        defer { reopened.dismissKnownUndo() }
        XCTAssertTrue(reopened.replaceProgress(try store.load().progress))
        XCTAssertTrue(reopened.initialKnownWordIDs.isEmpty)
        let unavailable = reopened.onboardingKnownSession(for: choice)
        XCTAssertTrue(unavailable.candidateIDs.isEmpty)
        XCTAssertNotNil(reopened.onboardingChoiceError)
        XCTAssertTrue(reopened.applyOnboardingChoices(
            choice: choice, explicitDailyChoice: nil, knownSelection: nil, session: nil
        ))
        XCTAssertEqual(try Data(contentsOf: store.fileURL), primary)
        XCTAssertEqual(try Data(contentsOf: metadataURL), corrupt)

        // A failed recovery invalidation stays durable, while core review persistence remains ready.
        try FileManager.default.removeItem(at: metadataURL)
        try FileManager.default.createDirectory(at: metadataURL, withIntermediateDirectories: true)
        XCTAssertFalse(reopened.loadInitialKnownProvenance(
            progressURL: store.fileURL, outcome: .restoredFromBackup(setAside: nil, backupDate: instant)
        ))
        XCTAssertTrue(reopened.initialKnownWordIDs.isEmpty)
        XCTAssertTrue(reopened.isProgressReadyForSync)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "lockglow.initialKnownInvalidationPending"))
        let beforeReset = reopened.progress
        let beforeResetBytes = try Data(contentsOf: store.fileURL)
        let beforeResetPreferences = ownDefaults() as NSDictionary
        let beforeResetCounts = counts()
        XCTAssertFalse(reopened.resetProgress())
        XCTAssertEqual(reopened.progress, beforeReset)
        XCTAssertEqual(try Data(contentsOf: store.fileURL), beforeResetBytes)
        XCTAssertEqual(ownDefaults() as NSDictionary, beforeResetPreferences)
        XCTAssertEqual(counts(), beforeResetCounts)
        let nextAnswer = reopened.recordReview(b, grade: .good)
        XCTAssertEqual(nextAnswer.reviews, 1)
        try assertDisk(reopened.progress, store: store)
        let stillReady = AppModel(progressStore: store, initialKnownStore: InitialKnownSelectionStore(fileURL: metadataURL))
        defer { stillReady.dismissKnownUndo() }
        XCTAssertTrue(stillReady.replaceProgress(try store.load().progress))
        XCTAssertTrue(stillReady.onboardingKnownSession(for: choice).candidateIDs.isEmpty)
        XCTAssertTrue(stillReady.isProgressReadyForSync)
        let preserved = stillReady.progress
        try FileManager.default.removeItem(at: metadataURL)
        XCTAssertTrue(stillReady.loadInitialKnownProvenance(progressURL: store.fileURL, outcome: .loaded))
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "lockglow.initialKnownInvalidationPending"))
        XCTAssertEqual(stillReady.progress, preserved)
    }

    @MainActor
    func testB2DefaultsKeepExplicitTargetAndScheduler() throws {
        for kind in [SchedulerKind.leitner, .fsrs] {
            UserDefaults.standard.removeObject(forKey: "lockglow.dailyNewWords")
            AppPreferences.schedulerKind = kind
            let folder = try location("b2-" + kind.rawValue)
            let store = ProgressStore(fileURL: folder.appendingPathComponent("progress.json"))
            let model = AppModel(progressStore: store)
            defer { model.dismissKnownUndo() }
            XCTAssertTrue(model.replaceProgress([:]))
            let bytes = try Data(contentsOf: store.fileURL)
            let beforeCounts = counts()
            let b2 = DeckChoice(startLevel: .b2)

            XCTAssertTrue(model.applyOnboardingChoices(
                choice: b2, explicitDailyChoice: nil, knownSelection: nil, session: nil, now: instant))
            XCTAssertEqual(model.dailyNewWords, 10)
            XCTAssertNil(AppPreferences.chosenDailyNewWords)
            XCTAssertTrue(model.applyOnboardingChoices(
                choice: b2, explicitDailyChoice: 5, knownSelection: nil, session: nil, now: instant))
            for choice in [DeckChoice(startLevel: .a1), b2] {
                XCTAssertTrue(model.applyOnboardingChoices(
                    choice: choice, explicitDailyChoice: nil, knownSelection: nil, session: nil, now: instant))
                XCTAssertEqual(model.dailyNewWords, 5)
                XCTAssertEqual(AppPreferences.chosenDailyNewWords, 5)
                XCTAssertEqual(AppPreferences.schedulerKind, kind)
            }
            XCTAssertTrue(model.progress.isEmpty)
            XCTAssertEqual(try Data(contentsOf: store.fileURL), bytes)
            XCTAssertEqual(counts(), beforeCounts)
        }
    }

    private func ownDefaults() -> [String: Any] {
        return UserDefaults.standard.dictionaryRepresentation().filter { $0.key.hasPrefix("lockglow.") }
    }

    private func clearDefaults() {
        for key in ownDefaults().keys { UserDefaults.standard.removeObject(forKey: key) }
    }

    private func location(_ name: String) throws -> URL {
        return try XCTUnwrap(directory).appendingPathComponent(name, isDirectory: true)
    }

    private func word(_ id: Int) -> WidgetWord {
        return WidgetWord(id: id, lemma: "fixture \(id)", pos: "n", level: "A1", defMicro: "test",
                          defShort: "A test word.", exampleEN: "This is a test word.")
    }

    private func studied(_ id: Int) -> WordProgress {
        var p = Leitner.review(WordProgress(wordID: id), grade: .good, at: instant.addingTimeInterval(-86_400))
        p.saved = true
        p.exposures = 3
        return p
    }

    private func selection(
        _ words: [WidgetWord], baseline: [Int: WordProgress], selected: Set<Int> = []
    ) -> OnboardingKnownSession {
        return OnboardingKnownSession(words: words, baselineProgress: baseline,
                                      candidateIDs: Set(words.map(\.id)), selectedIDs: selected)
    }

    private func assertDisk(
        _ expected: [Int: WordProgress], store: ProgressStore, exact: Bool = false,
        file: StaticString = #filePath, line: UInt = #line
    ) throws {
        func encode(_ records: [Int: WordProgress]) throws -> Data {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            encoder.outputFormatting = [.sortedKeys]
            return try encoder.encode(records.values.sorted { $0.wordID < $1.wordID })
        }
        let data = try Data(contentsOf: store.fileURL)
        XCTAssertEqual(data, try encode(expected), file: file, line: line)
        let loaded = try store.load()
        XCTAssertEqual(loaded.outcome, .loaded, file: file, line: line)
        XCTAssertEqual(try encode(loaded.progress), data, file: file, line: line)
        if exact { XCTAssertEqual(loaded.progress, expected, file: file, line: line) }
    }

    private func counts() -> [Int] {
        return LocalMetricsRecorder.shared.snapshot().days.reduce(into: [0, 0, 0]) { result, day in
            result[0] += day.newWords + day.reviews
            result[1] += day.knownChecksPassed
            result[2] += day.knownChecksFailed
        }
    }
}
