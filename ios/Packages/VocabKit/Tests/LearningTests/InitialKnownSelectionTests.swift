import Foundation
import XCTest
@testable import Learning

final class InitialKnownSelectionTests: XCTestCase {
    private typealias Progress = [Int: WordProgress]
    private var directory: URL!
    private let instant = Date(timeIntervalSince1970: 1_760_011_200.375)

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("InitialKnownSelectionTests-\(UUID().uuidString)")
    }

    override func tearDownWithError() throws {
        if let directory = directory { try? FileManager.default.removeItem(at: directory) }
    }

    func testSelectionUsesNativeThreeDayClaimAndDoesNotCountAReview() throws {
        var before = WordProgress(wordID: 1)
        before.exposures = 2
        before.saved = true
        before.lastSeenAt = instant.addingTimeInterval(-60)
        let original: Progress = [1: before]
        let result = plan(baseline: original, current: original)
        let marked = try XCTUnwrap(result.updatedProgress[1])
        XCTAssertEqual(marked, Leitner.markKnown(before, at: instant))
        XCTAssertEqual(marked.dueAt, instant.addingTimeInterval(3 * 86_400))
        XCTAssertEqual(marked.reviews, 0)
        XCTAssertNil(marked.lastReviewedAt)
        XCTAssertNil(marked.firstReviewedAt)
        XCTAssertNil(marked.lastGrade)
        XCTAssertEqual(marked.exposures, 2)
        XCTAssertTrue(marked.saved)
        XCTAssertEqual(result.claims[1]?.previous, before)
        XCTAssertTrue(result.protectedIDs.isEmpty)
        XCTAssertEqual(original[1], before, "Planning must not mutate its input.")
    }

    func testRemovingAClaimWithNoPreviousRecordDeletesTheDictionaryEntry() throws {
        let added = plan()
        let removed = plan(baseline: added.updatedProgress, selected: [], current: added.updatedProgress, claims: added.claims)
        XCTAssertNil(removed.updatedProgress[1])
        XCTAssertEqual(removed.claims, added.claims, "A removal retains its inactive receipt.")
        XCTAssertTrue(removed.protectedIDs.isEmpty)
    }

    func testRemovingAClaimRestoresTheWholePreviousRecord() throws {
        var before = WordProgress(wordID: 1)
        before.exposures = 8
        before.saved = true
        before.lastSeenAt = instant.addingTimeInterval(-3_600.125)
        let added = plan(baseline: [1: before], current: [1: before])
        let removed = plan(baseline: added.updatedProgress, selected: [], current: added.updatedProgress, claims: added.claims)
        XCTAssertEqual(removed.updatedProgress, [1: before])
        XCTAssertEqual(removed.claims, added.claims)
    }

    func testActiveSelectionAndRepeatedRemovalAreIdempotent() throws {
        let added = plan()
        let repeated = plan(baseline: [:], current: added.updatedProgress, claims: added.claims, now: instant.addingTimeInterval(86_400))
        XCTAssertEqual(repeated, added, "An active claim must not acquire a later timestamp or due date.")
        let removed = plan(selected: [], current: added.updatedProgress, claims: added.claims)
        let removedAgain = plan(selected: [], current: removed.updatedProgress, claims: removed.claims, now: instant.addingTimeInterval(99_000))
        XCTAssertEqual(removedAgain, removed)
    }

    func testSelectionOutsideOfferedIDsAndOtherProgressAreUntouched() throws {
        let receipt = claim(9)
        let reviewed = Leitner.review(WordProgress(wordID: 7), grade: .good, at: instant)
        let current: Progress = [9: receipt.marked, 7: reviewed]
        let result = plan(selected: [1, 9, 99], current: current, claims: [9: receipt])
        XCTAssertEqual(result.updatedProgress[9], receipt.marked)
        XCTAssertEqual(result.updatedProgress[7], reviewed)
        XCTAssertEqual(result.claims[9], receipt)
        XCTAssertNil(result.updatedProgress[99])
        XCTAssertNil(result.claims[99])
    }

    func testNewSelectionProtectsAnyChangeSinceTheOfferedBaseline() throws {
        let before = WordProgress(wordID: 1)
        let changes: [(String, WordProgress)] = [
            ("review", Leitner.review(before, grade: .good, at: instant)),
            ("manual", Leitner.markKnown(before, at: instant)),
            ("exposure", Leitner.markExposure(before, at: instant)),
        ]
        for (name, changed) in changes {
            let result = plan(baseline: [1: before], current: [1: changed])
            XCTAssertEqual(result.updatedProgress, [1: changed], name)
            XCTAssertTrue(result.claims.isEmpty, name)
            XCTAssertEqual(result.protectedIDs, [1], name)
        }
    }

    func testPreexistingReviewOrManualKnownStateCannotBeTakenOver() throws {
        let prior = [
            Leitner.review(WordProgress(wordID: 1), grade: .good, at: instant),
            Leitner.markKnown(WordProgress(wordID: 1), at: instant),
        ]
        for value in prior {
            let result = plan(baseline: [1: value], current: [1: value])
            XCTAssertEqual(result.updatedProgress, [1: value])
            XCTAssertTrue(result.claims.isEmpty)
            XCTAssertEqual(result.protectedIDs, [1])
        }
    }

    func testRemovalProtectsReviewManualExposureAndSavedChangesAfterClaim() throws {
        let added = plan()
        let marked = try XCTUnwrap(added.updatedProgress[1])
        var saved = marked
        saved.saved = true
        let later = instant.addingTimeInterval(60)
        let changes: [(String, WordProgress)] = [
            ("review", Leitner.review(marked, grade: .good, at: later)),
            ("manual", Leitner.markKnown(marked, at: later)),
            ("exposure", Leitner.markExposure(marked, at: later)),
            ("saved", saved),
        ]
        for (name, changed) in changes {
            let result = plan(baseline: added.updatedProgress, selected: [], current: [1: changed], claims: added.claims)
            XCTAssertEqual(result.updatedProgress, [1: changed], name)
            XCTAssertEqual(result.claims, added.claims, name)
            XCTAssertEqual(result.protectedIDs, [1], name)
        }
    }

    func testSelectingAnInactiveReceiptAgainUsesTheNewDeclarationTime() throws {
        let first = plan()
        let removed = plan(selected: [], current: first.updatedProgress, claims: first.claims)
        let later = instant.addingTimeInterval(5 * 86_400)
        let again = plan(current: removed.updatedProgress, claims: removed.claims, now: later)
        XCTAssertEqual(again.updatedProgress[1]?.lastSeenAt, later)
        XCTAssertEqual(again.updatedProgress[1]?.dueAt, later.addingTimeInterval(Leitner.knownCheckDelay))
        XCTAssertNil(again.claims[1]?.previous)
    }

    func testMetadataSavedBeforePrimaryAddDoesNotCreateKnownProgress() throws {
        let added = plan()
        let store = makeStore()
        try store.load()
        try store.saveBeforeProgress(added.claims)
        // Simulate termination before the primary write: progress still has no record.
        let reopened = try makeStore().load()
        let reconciled = plan(selected: [], current: [:], claims: reopened)
        XCTAssertTrue(reconciled.updatedProgress.isEmpty)
        XCTAssertTrue(reconciled.protectedIDs.isEmpty)
        XCTAssertEqual(reconciled.claims, reopened)
        let retry = plan(current: [:], claims: reopened)
        XCTAssertEqual(retry.updatedProgress, added.updatedProgress)
        XCTAssertEqual(retry.claims, added.claims)
    }

    func testMetadataSavedBeforePrimaryRemovalKeepsTheActualKnownStateUntilRetried() throws {
        let store = makeStore()
        let primary = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
        let added = plan()
        try store.load()
        try store.saveBeforeProgress(added.claims)
        try primary.save(added.updatedProgress)
        let removal = plan(selected: [], current: added.updatedProgress, claims: added.claims)
        try store.saveBeforeProgress(removal.claims)
        // Simulate termination before primary replacement: the receipt is still active.
        let reopenedClaims = try makeStore().load()
        let actual = try primary.load().progress
        XCTAssertEqual(actual[1], reopenedClaims[1]?.marked)
        let retry = plan(baseline: actual, selected: [], current: actual, claims: reopenedClaims)
        XCTAssertNil(retry.updatedProgress[1])
        try primary.save(retry.updatedProgress)
        let committed = try primary.load().progress
        let repeated = plan(selected: [], current: committed, claims: reopenedClaims)
        XCTAssertTrue(repeated.updatedProgress.isEmpty)
        XCTAssertTrue(repeated.protectedIDs.isEmpty)
        XCTAssertEqual(repeated.claims, reopenedClaims)
    }

    func testLiveCacheAndTwoFilesReopenedWithTheSameDateEpoch() throws {
        let store = makeStore()
        let primary = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
        var before = WordProgress(wordID: 1)
        before.exposures = 3
        before.lastSeenAt = Date(timeIntervalSinceReferenceDate: 799_000_000.123456)
        let time = Date(timeIntervalSinceReferenceDate: 800_000_000.1234567)
        let added = plan(baseline: [1: before], current: [1: before], now: time)
        try store.load()
        try store.saveBeforeProgress(added.claims)
        XCTAssertEqual(store.claims, added.claims, "The live cache must contain raw snapshots, not their decoded replacements.")
        try primary.save(added.updatedProgress)
        let diskClaims = try makeStore().load()
        let diskProgress = try primary.load().progress
        XCTAssertEqual(diskClaims[1]?.marked, diskProgress[1])
        let removal = plan(selected: [], current: diskProgress, claims: diskClaims)
        XCTAssertEqual(removal.updatedProgress[1], diskClaims[1]?.previous)
        XCTAssertTrue(removal.protectedIDs.isEmpty)
        let primaryRoot = try JSONSerialization.jsonObject(with: Data(contentsOf: primary.fileURL))
        XCTAssertTrue(primaryRoot is [[String: Any]], "The existing primary progress array format must remain unchanged.")
        let metadataRoot = try XCTUnwrap(try JSONSerialization.jsonObject(with: Data(contentsOf: store.fileURL)) as? [String: Any])
        XCTAssertEqual(metadataRoot["version"] as? Int, 1)
    }

    func testStoreRequiresSuccessfulLoadAndMissingFileIsFreshWithoutWriting() throws {
        let store = makeStore()
        XCTAssertEqual(store.maxBytes, 8 * 1024 * 1024)
        XCTAssertFalse(store.isReady)
        XCTAssertNil(store.claims)
        expect(.notLoaded) { try store.saveBeforeProgress([:]) }
        XCTAssertEqual(try store.load(), [:])
        XCTAssertTrue(store.isReady)
        XCTAssertEqual(store.claims, [:])
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.fileURL.path))
    }

    func testCorruptUnknownVersionAndOversizedLoadsNeverPermitOverwrite() throws {
        let cases: [(String, Data, Int, InitialKnownStoreError)] = [
            ("corrupt", Data("not json".utf8), 1_024, .corrupt),
            ("version", Data(#"{"version":2,"claims":[]}"#.utf8), 1_024, .unsupportedVersion(2)),
            ("oversize", Data(repeating: 32, count: 129), 128, .oversized),
        ]
        for (name, original, limit, error) in cases {
            let url = directory.appendingPathComponent("\(name).json")
            try write(original, to: url)
            let store = InitialKnownSelectionStore(fileURL: url, maxBytes: limit)
            expect(error) { _ = try store.load() }
            XCTAssertFalse(store.isReady, name)
            XCTAssertNil(store.claims, name)
            expect(.notLoaded) { try store.saveBeforeProgress([:]) }
            XCTAssertEqual(try Data(contentsOf: url), original, name)
        }
    }

    func testUnreadableDirectoryIsLeftAloneAndCannotBeOverwrittenOrCleared() throws {
        let store = makeStore()
        try FileManager.default.createDirectory(at: store.fileURL, withIntermediateDirectories: true)
        let child = store.fileURL.appendingPathComponent("keep.txt")
        try Data("keep".utf8).write(to: child)
        expect(.unreadable) { _ = try store.load() }
        XCTAssertFalse(store.isReady)
        XCTAssertNil(store.claims)
        expect(.notLoaded) { try store.saveBeforeProgress([:]) }
        expect(.writeFailed) { try store.clear() }
        XCTAssertEqual(try String(contentsOf: child, encoding: .utf8), "keep")
    }

    func testFailedReloadClosesPreviouslyReadyStore() throws {
        let store = makeStore()
        try store.load()
        try store.saveBeforeProgress([1: claim(1)])
        let bad = Data(#"{"version":7}"#.utf8)
        try bad.write(to: store.fileURL)
        expect(.unsupportedVersion(7)) { _ = try store.load() }
        XCTAssertFalse(store.isReady)
        XCTAssertNil(store.claims)
        expect(.notLoaded) { try store.saveBeforeProgress([:]) }
        XCTAssertEqual(try Data(contentsOf: store.fileURL), bad)
    }

    func testAFileChangedAfterLoadCannotBeSilentlyOverwritten() throws {
        let store = makeStore()
        let original: InitialKnownClaims = [1: claim(1)]
        try store.load()
        try store.saveBeforeProgress(original)
        let changed = Data("external damage".utf8)
        try changed.write(to: store.fileURL)
        expect(.changedSinceLoad) { try store.saveBeforeProgress([:]) }
        XCTAssertEqual(store.claims, original)
        XCTAssertEqual(try Data(contentsOf: store.fileURL), changed)
    }

    func testWriteFailurePreservesOldFileAndRawCache() throws {
        let original: InitialKnownClaims = [1: claim(1)]
        let store = makeStore()
        try store.load()
        try store.saveBeforeProgress(original)
        let bytes = try Data(contentsOf: store.fileURL)
        enum Failure: Error { case injected }
        let failing = InitialKnownSelectionStore(fileURL: store.fileURL, maxBytes: store.maxBytes, atomicWrite: { _, _ in
            throw Failure.injected
        })
        try failing.load()
        let previousCache = failing.claims
        expect(.writeFailed) { try failing.saveBeforeProgress([1: self.claim(1), 2: self.claim(2)]) }
        XCTAssertTrue(failing.isReady)
        XCTAssertEqual(failing.claims, previousCache)
        XCTAssertEqual(try Data(contentsOf: store.fileURL), bytes)
    }

    func testOversizedOrInvalidSaveDoesNotCreateAFileOrChangeCache() throws {
        let small = InitialKnownSelectionStore(fileURL: directory.appendingPathComponent("small.json"), maxBytes: 64)
        try small.load()
        expect(.oversized) { try small.saveBeforeProgress([1: self.claim(1)]) }
        XCTAssertEqual(small.claims, [:])
        XCTAssertFalse(FileManager.default.fileExists(atPath: small.fileURL.path))
        let store = makeStore()
        try store.load()
        let invalid = InitialKnownClaim(previous: nil, marked: WordProgress(wordID: 1))
        expect(.corrupt) { try store.saveBeforeProgress([1: invalid]) }
        expect(.corrupt) { try store.saveBeforeProgress([2: self.claim(1)]) }
        XCTAssertEqual(store.claims, [:])
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.fileURL.path))
    }

    func testDuplicateReceiptsAndMalformedOptionalSnapshotFieldsAreCorrupt() throws {
        let store = makeStore()
        try store.load()
        try store.saveBeforeProgress([1: claim(1)])
        let bytes = try Data(contentsOf: store.fileURL)
        let root = try XCTUnwrap(try JSONSerialization.jsonObject(with: bytes) as? [String: Any])
        let rows = try XCTUnwrap(root["claims"] as? [[String: Any]])
        var duplicate = root
        duplicate["claims"] = rows + rows
        let duplicateBytes = try JSONSerialization.data(withJSONObject: duplicate)
        try duplicateBytes.write(to: store.fileURL)
        expect(.corrupt) { _ = try self.makeStore().load() }
        XCTAssertEqual(try Data(contentsOf: store.fileURL), duplicateBytes)
        var badRow = rows[0]
        var marked = try XCTUnwrap(badRow["marked"] as? [String: Any])
        marked["last_reviewed_at"] = "invalid date"
        badRow["marked"] = marked
        var malformed = root
        malformed["claims"] = [badRow]
        let malformedBytes = try JSONSerialization.data(withJSONObject: malformed)
        try malformedBytes.write(to: store.fileURL)
        expect(.corrupt) { _ = try self.makeStore().load() }
        XCTAssertEqual(try Data(contentsOf: store.fileURL), malformedBytes)
    }

    func testExplicitClearRemovesCorruptMetadataAndPreservesPrimaryProgress() throws {
        let primary = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
        try primary.save([9: WordProgress(wordID: 9)])
        let primaryBytes = try Data(contentsOf: primary.fileURL)
        let store = makeStore()
        try write(Data("damaged".utf8), to: store.fileURL)
        expect(.corrupt) { _ = try store.load() }
        try store.clear()
        XCTAssertTrue(store.isReady)
        XCTAssertEqual(store.claims, [:])
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.fileURL.path))
        XCTAssertEqual(try Data(contentsOf: primary.fileURL), primaryBytes)
        try store.saveBeforeProgress([1: claim(1)])
        try store.clear()
        try store.clear()
        XCTAssertEqual(store.claims, [:])
        XCTAssertEqual(try Data(contentsOf: primary.fileURL), primaryBytes)
    }

    private func plan(
        offered: Set<Int> = [1],
        baseline: Progress = [:],
        selected: Set<Int> = [1],
        current: Progress = [:],
        claims: InitialKnownClaims = [:],
        now: Date? = nil
    ) -> InitialKnownSelectionPlan {
        InitialKnownSelectionPlanner.plan(
            offeredIDs: offered, baselineProgress: baseline, selectedIDs: selected,
            currentProgress: current, claims: claims, now: now ?? instant
        )
    }

    private func claim(_ id: Int) -> InitialKnownClaim {
        InitialKnownClaim(previous: nil, marked: Leitner.markKnown(WordProgress(wordID: id), at: instant))
    }

    private func makeStore() -> InitialKnownSelectionStore {
        InitialKnownSelectionStore(fileURL: directory.appendingPathComponent("initial-known.json"))
    }

    private func write(_ data: Data, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url)
    }

    private func expect(
        _ expected: InitialKnownStoreError, file: StaticString = #filePath, line: UInt = #line,
        _ action: () throws -> Void
    ) {
        XCTAssertThrowsError(try action(), file: file, line: line) { error in
            XCTAssertEqual(error as? InitialKnownStoreError, expected, file: file, line: line)
        }
    }
}
