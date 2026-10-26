import XCTest
import Foundation
import CoreModels
import Learning
@testable import Lockglow

/// Real import orchestration on disposable CI only. No start(), App Group, loader or cloud.
/// Each backup is encoded, written to a file and read through AppModel.readBackup.
final class AppModelDataControlsTests: XCTestCase {
    private var defaultsSnapshot: [String: Any]?
    private var directory: URL?
    private let directoryPrefix = "Lockglow-AppModelDataControlsTests-"
    // Whole seconds also survive DataArchive's intentionally whole-second ISO dates exactly.
    private let instant = Date(timeIntervalSince1970: 1_760_011_200)
    private let pendingKey = "lockglow.initialKnownInvalidationPending"

    override func setUpWithError() throws {
        guard ProcessInfo.processInfo.environment["LOCKGLOW_NATIVE_MODEL_TESTS"] == "1" else {
            throw XCTSkip("Requires LOCKGLOW_NATIVE_MODEL_TESTS=1 in a disposable CI simulator")
        }
        #if !targetEnvironment(simulator)
        throw XCTSkip("Data controls tests require a disposable simulator")
        #endif

        try super.setUpWithError()
        defaultsSnapshot = ownDefaults()
        clearDefaults()
        // Prevent the launch gate from probing App Group or settling a different scheduler.
        AppPreferences.onboardingCompleted = true
        AppPreferences.schedulerKind = .leitner
        AppPreferences.startLevel = .a2
        AppPreferences.selectedTopicIDs = ["food_drink"]
        AppPreferences.chooseDailyNewWords(15)
        AppPreferences.rotationMinutes = 60
        AppPreferences.reminderEnabled = false
        AppPreferences.reminderMinuteOfDay = 19 * 60
        UserDefaults.standard.set("local lookup", forKey: AppModel.recentSearchesKey)
        LocalMetricsRecorder.shared.reset()
        StudyTimeRecorder.shared.reset()

        let root = FileManager.default.temporaryDirectory.resolvingSymlinksInPath()
        let target = root.appendingPathComponent(directoryPrefix + UUID().uuidString, isDirectory: true)
        directory = target
        try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        // A skipped setup must not touch caches, defaults or files.
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
            guard target.deletingLastPathComponent() == root,
                  target.lastPathComponent.hasPrefix(directoryPrefix) else {
                XCTFail("Refusing cleanup outside this test's unique temporary directory")
                return
            }
            try FileManager.default.removeItem(at: target)
            self.directory = nil
        }
        try super.tearDownWithError()
    }

    @MainActor
    func testNoOpImportPreservesInitialClaimAndEveryFile() throws {
        let fixture = try makeFixture()
        let model = fixture.model
        defer { model.dismissKnownUndo() }
        let archive = model.makeDataArchive(now: instant)
        XCTAssertEqual(archive.reviewLog, [fixture.localEntry], "Export must use the injected real log")
        let reading = try readBackup(archive, named: "same-phone.json")
        let progressBefore = model.progress
        let claimsBefore = model.initialKnownClaims
        let defaultsBefore = ownDefaults() as NSDictionary
        let filesBefore = try fileSnapshot()

        let preview = try XCTUnwrap(model.importSummary(reading, now: instant))
        XCTAssertTrue(preview.changesNothing)
        XCTAssertEqual(preview.skipped, 0)
        XCTAssertEqual(model.progress, progressBefore)
        XCTAssertEqual(model.initialKnownClaims, claimsBefore)
        XCTAssertEqual(ownDefaults() as NSDictionary, defaultsBefore)
        XCTAssertEqual(try fileSnapshot(), filesBefore, "Preview must not write any fixture file")

        let result = try model.importData(reading, now: instant).get()
        XCTAssertEqual(result, preview)
        XCTAssertTrue(result.changesNothing)
        XCTAssertEqual(model.progress, progressBefore)
        XCTAssertEqual(model.initialKnownClaims, claimsBefore)
        XCTAssertEqual(model.initialKnownWordIDs, [fixture.initialWord.id])
        XCTAssertEqual(fixture.metadata.claims, claimsBefore)
        XCTAssertEqual(try fileSnapshot(), filesBefore, "No-op must preserve primary, backups, provenance and log bytes")
        XCTAssertEqual(try fixture.customStore.load(now: instant).list, fixture.localWords)
        XCTAssertEqual(try fixture.log.entries(), [fixture.localEntry])
        XCTAssertEqual(ownDefaults() as NSDictionary, defaultsBefore)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: pendingKey))
        try assertDisk(progressBefore, store: fixture.progressStore)
    }

    @MainActor
    func testChangedImportInvalidatesInitialClaimAndKeepsLocalChoices() throws {
        let fixture = try makeFixture()
        let model = fixture.model
        defer { model.dismissKnownUndo() }
        let archive = try changedArchive(fixture)
        let reading = try readBackup(archive, named: "changed-phone.json")
        let progressBefore = model.progress
        let claimsBefore = model.initialKnownClaims
        let defaultsBefore = ownDefaults() as NSDictionary
        let filesBefore = try fileSnapshot()
        let choiceBefore = model.deckChoice
        let customBytesBefore = try Data(contentsOf: fixture.customStore.fileURL)
        let logBytesBefore = try Data(contentsOf: fixture.log.fileURL)
        let preview = try XCTUnwrap(model.importSummary(reading, now: instant))
        XCTAssertEqual(preview.wordsAdded, 1)
        XCTAssertEqual(preview.wordsReplaced, 1)
        XCTAssertEqual(preview.customWordsAdded, 0)
        XCTAssertEqual(preview.skipped, 0)
        XCTAssertFalse(preview.changesNothing)
        XCTAssertEqual(model.progress, progressBefore)
        XCTAssertEqual(model.initialKnownClaims, claimsBefore)
        XCTAssertEqual(ownDefaults() as NSDictionary, defaultsBefore)
        XCTAssertEqual(try fileSnapshot(), filesBefore, "Preview must preserve source authority too")

        let result = try model.importData(reading, now: instant).get()
        XCTAssertEqual(result, preview)
        let expected = Dictionary(uniqueKeysWithValues: reading.archive.progress.map { ($0.progress.wordID, $0.progress) })
        XCTAssertEqual(model.progress, expected, "The actual model must adopt the read archive's new and newer records")
        XCTAssertEqual(model.progress[fixture.initialWord.id], progressBefore[fixture.initialWord.id],
                       "Invalidation discards source authority, never the known learning record")
        XCTAssertTrue(model.initialKnownWordIDs.isEmpty)
        XCTAssertEqual(model.initialKnownClaims, [:])
        XCTAssertEqual(fixture.metadata.claims, [:])
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.metadata.fileURL.path))
        XCTAssertFalse(UserDefaults.standard.bool(forKey: pendingKey))
        try assertDisk(expected, store: fixture.progressStore)
        XCTAssertEqual(try fixture.log.entries(), reading.archive.reviewLog)
        XCTAssertNotEqual(try Data(contentsOf: fixture.log.fileURL), logBytesBefore)
        XCTAssertEqual(model.makeDataArchive(now: instant).reviewLog, reading.archive.reviewLog)
        XCTAssertEqual(try Data(contentsOf: fixture.customStore.fileURL), customBytesBefore)
        XCTAssertEqual(try fixture.customStore.load(now: instant).list, fixture.localWords)
        XCTAssertEqual(model.customWordLibrary.currentList, fixture.localWords)
        XCTAssertEqual(model.deckChoice, choiceBefore)
        XCTAssertEqual(model.dailyNewWords, 15)
        XCTAssertEqual(model.rotationMinutes, 60)
        XCTAssertFalse(model.reminderEnabled)
        XCTAssertEqual(model.reminderMinuteOfDay, 19 * 60)
        XCTAssertEqual(AppPreferences.chosenDailyNewWords, 15)
        XCTAssertEqual(AppPreferences.schedulerKind, .leitner)
        XCTAssertEqual(ownDefaults() as NSDictionary, defaultsBefore, "Foreign settings and recent searches are descriptive only")
        XCTAssertEqual(try Data(contentsOf: try XCTUnwrap(directory).appendingPathComponent("changed-phone.json")),
                       try archive.encoded(), "Import must not rewrite its source backup")
    }

    @MainActor
    func testProvenanceClearFailureStopsBeforeAnyImportWrite() throws {
        let fixture = try makeFixture()
        let model = fixture.model
        defer { model.dismissKnownUndo() }
        var archive = try changedArchive(fixture)
        let ownWord = CustomWord(
            id: CustomWordID.first + 1, lemma: "turn up", meaningTR: "ortaya cikmak",
            createdAt: instant.addingTimeInterval(-86_400)
        )
        let ownProgress = Leitner.review(WordProgress(wordID: ownWord.id), grade: .good,
                                        at: instant.addingTimeInterval(-3600))
        archive.customWords.append(ownWord)
        archive.customNextID = ownWord.id + 1
        archive.progress.append(DataArchive.Word(progress: ownProgress))
        archive.reviewLog.append(try XCTUnwrap(ReviewLogEntry(
            before: WordProgress(wordID: ownWord.id), after: ownProgress, source: .review
        )))
        let reading = try readBackup(archive, named: "refused-phone.json")
        XCTAssertEqual(model.initialKnownWordIDs, [fixture.initialWord.id])

        // A deterministic cross-platform clear failure: the metadata path is a directory.
        // The production clear guard must retain it rather than recursively deleting it.
        try FileManager.default.removeItem(at: fixture.metadata.fileURL)
        try FileManager.default.createDirectory(at: fixture.metadata.fileURL, withIntermediateDirectories: true)
        let marker = fixture.metadata.fileURL.appendingPathComponent("do-not-delete.txt")
        try Data("test-owned marker".utf8).write(to: marker)
        let progressBefore = model.progress
        let claimsBefore = model.initialKnownClaims
        let defaultsBefore = ownDefaults()
        let filesBefore = try fileSnapshot()
        let preview = try XCTUnwrap(model.importSummary(reading, now: instant))
        XCTAssertEqual(preview.wordsAdded, 2)
        XCTAssertEqual(preview.wordsReplaced, 1)
        XCTAssertEqual(preview.customWordsAdded, 1, "This payload would write all three import stores")
        XCTAssertEqual(preview.skipped, 0)
        XCTAssertEqual(model.initialKnownClaims, claimsBefore)
        XCTAssertEqual(model.progress, progressBefore)
        XCTAssertEqual(ownDefaults() as NSDictionary, defaultsBefore as NSDictionary)
        XCTAssertEqual(try fileSnapshot(), filesBefore)

        switch model.importData(reading, now: instant) {
        case .failure(let failure):
            XCTAssertEqual(failure, .notSaved)
        case .success:
            XCTFail("A source-clear failure must refuse the import")
        }
        XCTAssertEqual(model.progress, progressBefore)
        XCTAssertEqual(model.customWordLibrary.currentList, fixture.localWords)
        XCTAssertEqual(try fixture.customStore.load(now: instant).list, fixture.localWords)
        XCTAssertEqual(try fixture.log.entries(), [fixture.localEntry])
        XCTAssertEqual(try fileSnapshot(), filesBefore, "No primary, word, log or backup write may precede source invalidation")
        try assertDisk(progressBefore, store: fixture.progressStore)
        XCTAssertTrue(model.isProgressReadyForSync, "An optional source failure must not disable normal progress persistence")
        XCTAssertTrue(model.initialKnownWordIDs.isEmpty)
        XCTAssertNil(model.initialKnownClaims)
        XCTAssertTrue(model.initialKnownRequiresInvalidation)
        XCTAssertNotNil(model.onboardingChoiceError)
        var expectedDefaults = defaultsBefore
        expectedDefaults[pendingKey] = true
        XCTAssertEqual(ownDefaults() as NSDictionary, expectedDefaults as NSDictionary,
                       "Only the conservative pending-invalidation flag changes")
        XCTAssertEqual(try Data(contentsOf: marker), Data("test-owned marker".utf8))
    }

    private struct Fixture {
        let model: AppModel
        let progressStore: ProgressStore
        let customStore: CustomWordStore
        let log: ReviewLog
        let metadata: InitialKnownSelectionStore
        let initialWord: WidgetWord
        let localWord: WidgetWord
        let incomingWord: WidgetWord
        let localWords: CustomWordList
        let localEntry: ReviewLogEntry
    }

    @MainActor
    private func makeFixture() throws -> Fixture {
        let folder = try XCTUnwrap(directory)
        let progressStore = ProgressStore(fileURL: folder.appendingPathComponent("progress.json"))
        let customStore = CustomWordStore(fileURL: folder.appendingPathComponent("custom_words.json"))
        let log = ReviewLog(fileURL: folder.appendingPathComponent("review_log.jsonl"))
        let metadata = InitialKnownSelectionStore(fileURL: folder.appendingPathComponent("initial_known_claims.json"))
        let a = word(930_001, "breakfast"), b = word(930_002, "journey"), c = word(930_003, "quiet")
        let localWords = CustomWordList(words: [CustomWord(
            id: CustomWordID.first, lemma: "take turns", meaningTR: "sirayla yapmak",
            createdAt: instant.addingTimeInterval(-5 * 86_400)
        )])
        try customStore.save(localWords, now: instant)
        let local = Leitner.review(WordProgress(wordID: b.id), grade: .good,
                                   at: instant.addingTimeInterval(-2 * 86_400))
        let entry = try XCTUnwrap(ReviewLogEntry(before: WordProgress(wordID: b.id), after: local, source: .review))
        try log.append([entry])
        let content = LoadedContent(
            words: [a, b, c], source: .seed, cardCount: 3, contentVersion: "native-import-fixture",
            topics: [], topicsOf: [a.id: ["food_drink"], b.id: ["food_drink"], c.id: ["food_drink"]]
        )
        let model = AppModel(
            progressStore: progressStore, reviewLog: log, initialKnownStore: metadata,
            customWordStore: customStore, loadedContent: content
        )
        // Readiness follows real file loading and loaded content; no ready flag is overridden.
        XCTAssertEqual(model.customWordLibrary.status, .ready)
        XCTAssertEqual(model.contentSource, .seed)
        XCTAssertEqual(model.words.count, 4)
        XCTAssertTrue(model.canImportData)
        XCTAssertTrue(model.replaceProgress([b.id: local]))
        let session = model.onboardingKnownSession(for: model.deckChoice)
        XCTAssertTrue(session.candidateIDs.contains(a.id))
        XCTAssertTrue(model.applyOnboardingChoices(
            choice: model.deckChoice, explicitDailyChoice: nil, knownSelection: [a.id],
            session: session, now: instant
        ))
        XCTAssertEqual(model.initialKnownWordIDs, [a.id])
        XCTAssertFalse(UserDefaults.standard.bool(forKey: pendingKey))
        return Fixture(model: model, progressStore: progressStore, customStore: customStore,
                       log: log, metadata: metadata, initialWord: a, localWord: b, incomingWord: c,
                       localWords: localWords, localEntry: entry)
    }

    @MainActor
    private func changedArchive(_ fixture: Fixture) throws -> DataArchive {
        var archive = fixture.model.makeDataArchive(now: instant)
        let localBefore = try XCTUnwrap(fixture.model.progress[fixture.localWord.id])
        let localAfter = Leitner.review(localBefore, grade: .good, at: instant.addingTimeInterval(-3600))
        let incoming = Leitner.review(WordProgress(wordID: fixture.incomingWord.id), grade: .good,
                                      at: instant.addingTimeInterval(-1800))
        archive.progress.removeAll { $0.progress.wordID == fixture.localWord.id }
        archive.progress.append(DataArchive.Word(progress: localAfter))
        archive.progress.append(DataArchive.Word(progress: incoming))
        archive.reviewLog.append(try XCTUnwrap(ReviewLogEntry(before: localBefore, after: localAfter, source: .review)))
        archive.reviewLog.append(try XCTUnwrap(ReviewLogEntry(
            before: WordProgress(wordID: fixture.incomingWord.id), after: incoming, source: .review
        )))
        archive.settings = DataArchive.Settings(
            startLevel: "B2", topicIDs: ["travel"], dailyNewWords: 5,
            rotationMinutes: 240, reminderEnabled: true, reminderTime: "08:30"
        )
        archive.recentSearches = ["foreign lookup"]
        return archive
    }

    private func readBackup(_ archive: DataArchive, named name: String) throws -> DataArchive.Reading {
        let url = try XCTUnwrap(directory).appendingPathComponent(name)
        try archive.encoded().write(to: url, options: [.atomic])
        let reading = try AppModel.readBackup(at: url)
        XCTAssertEqual(reading.unreadableRecords, 0)
        XCTAssertEqual(try reading.archive.encoded(), try archive.encoded(),
                       "The complete backup must survive its canonical ISO date encoding")
        return reading
    }

    private func word(_ id: Int, _ lemma: String) -> WidgetWord {
        return WidgetWord(id: id, lemma: lemma, pos: "n", level: "A2", defMicro: "test",
                          defShort: "A test word.", exampleEN: "This is a test word.")
    }

    /// Capture all fixture bytes, including daily backups and the picked source JSON.
    private func fileSnapshot() throws -> [String: Data] {
        let root = try XCTUnwrap(directory).standardizedFileURL
        let entries = try XCTUnwrap(FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: [.isRegularFileKey], options: []
        ))
        let pathPrefix = root.path + "/"
        var result: [String: Data] = [:]
        for case let file as URL in entries {
            guard try file.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else { continue }
            guard file.path.hasPrefix(pathPrefix) else {
                XCTFail("Enumerator escaped the temporary fixture root")
                continue
            }
            result[String(file.path.dropFirst(pathPrefix.count))] = try Data(contentsOf: file)
        }
        return result
    }

    private func assertDisk(
        _ expected: [Int: WordProgress], store: ProgressStore,
        file: StaticString = #filePath, line: UInt = #line
    ) throws {
        func encoded(_ records: [Int: WordProgress]) throws -> Data {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            encoder.outputFormatting = [.sortedKeys]
            return try encoder.encode(records.values.sorted { $0.wordID < $1.wordID })
        }
        let bytes = try Data(contentsOf: store.fileURL)
        XCTAssertEqual(bytes, try encoded(expected), file: file, line: line)
        let loaded = try store.load()
        XCTAssertEqual(loaded.outcome, .loaded, file: file, line: line)
        XCTAssertEqual(try encoded(loaded.progress), bytes, file: file, line: line)
        XCTAssertEqual(loaded.progress, expected, file: file, line: line)
    }

    private func ownDefaults() -> [String: Any] {
        return UserDefaults.standard.dictionaryRepresentation().filter { $0.key.hasPrefix("lockglow.") }
    }

    private func clearDefaults() {
        for key in ownDefaults().keys { UserDefaults.standard.removeObject(forKey: key) }
    }
}
