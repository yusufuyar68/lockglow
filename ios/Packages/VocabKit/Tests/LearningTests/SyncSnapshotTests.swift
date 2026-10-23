import XCTest
import CoreModels
@testable import Learning

/// The iCloud copy's format and this device's sync state file (Learning/SyncSnapshot.swift).
final class SyncSnapshotTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_760_011_200)

    private func fullRecord(_ id: Int) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .known
        p.box = 5
        p.dueAt = now.addingTimeInterval(86_400)
        p.exposures = 4
        p.lastSeenAt = now.addingTimeInterval(-60)
        p.reviews = 7
        p.lapses = 2
        p.knownOverride = true
        p.saved = true
        p.lastReviewedAt = now.addingTimeInterval(-120)
        p.lastGrade = .easy
        p.firstReviewedAt = now.addingTimeInterval(-9_000)
        p.refresherStep = 2
        return p
    }

    private func word(_ id: Int, _ lemma: String) -> CustomWord {
        return CustomWord(id: id, lemma: lemma, meaningTR: "anlam", exampleEN: "An \(lemma) day.", note: "not", createdAt: now)
    }

    private var tempFolder: URL!

    override func setUpWithError() throws {
        tempFolder = FileManager.default.temporaryDirectory.appendingPathComponent("SyncSnapshotTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempFolder)
    }

    // MARK: Format guards

    /// A new `WordProgress` field must be copied by `reidentified`, and the iCloud format must go
    /// up (`SyncSnapshot.currentFormat`): an older build would drop the field from every record it
    /// writes back. Update both, then this count.
    func testWordProgressFieldsAreAllKnownToSync() {
        XCTAssertEqual(Mirror(reflecting: WordProgress(wordID: 1)).children.count, 14, "WordProgress gained a field: copy it in reidentified(_:) and raise SyncSnapshot.currentFormat")
    }

    /// The same for `CustomWord` and `SyncWord` (its text in iCloud).
    func testCustomWordFieldsAreAllKnownToSync() {
        XCTAssertEqual(Mirror(reflecting: word(CustomWordID.first, "awkward")).children.count, 7, "CustomWord gained a field: add it to SyncWord and raise SyncSnapshot.currentFormat")
    }

    func testReidentifiedCopiesEveryField() {
        let record = fullRecord(12)
        let moved = record.reidentified(CustomWordID.first + 3)
        XCTAssertEqual(moved.wordID, CustomWordID.first + 3)
        XCTAssertEqual(moved.reidentified(12), record)
    }

    // MARK: Encoding

    func testSnapshotRoundTripsExactly() throws {
        let snapshot = SyncSnapshot(
            resetAt: now,
            cards: [fullRecord(30), fullRecord(4)],
            words: [SyncWord(uuid: "b", word: word(CustomWordID.first, "awkward"), progress: fullRecord(CustomWordID.first))],
            deleted: ["z", "a"]
        )
        let decoded = try SyncSnapshot.decode(snapshot.encoded())
        XCTAssertEqual(decoded, snapshot)
        XCTAssertEqual(decoded.cards.map { $0.wordID }, [4, 30], "sorted by id")
        XCTAssertEqual(decoded.deleted, ["a", "z"])
        XCTAssertEqual(decoded.words.first?.progress?.wordID, 0, "a word's progress is stored without this device's id")
        XCTAssertEqual(try decoded.encoded(), try snapshot.encoded(), "equal snapshots give equal bytes")
    }

    func testNewerFormatIsNeverRead() {
        let data = Data(#"{"format": 2, "cards": [], "words": [], "deleted": [], "new_field": 1}"#.utf8)
        XCTAssertThrowsError(try SyncSnapshot.decode(data)) { error in
            XCTAssertEqual(error as? SyncSnapshot.DecodeError, .newerFormat(2))
        }
    }

    func testDamagedCopyIsUnreadable() {
        for text in ["", "not json", #"{"cards": []}"#, #"{"format": 0}"#, #"{"format": 1, "cards": [{"word_id": 1}], "words": [], "deleted": []}"#] {
            XCTAssertThrowsError(try SyncSnapshot.decode(Data(text.utf8)), text) { error in
                XCTAssertEqual(error as? SyncSnapshot.DecodeError, .unreadable, text)
            }
        }
    }

    func testDecodeNormalizes() throws {
        let card = fullRecord(5)
        let custom = fullRecord(CustomWordID.first + 1)
        var messy = SyncSnapshot()
        messy.cards = [card, card, custom]
        let entry = SyncWord(uuid: "u", word: word(CustomWordID.first, "awkward"), progress: nil)
        messy.words = [entry, entry]
        messy.deleted = ["u", "gone", "gone"]
        let decoded = try SyncSnapshot.decode(SyncCoding.encoder().encode(messy))
        XCTAssertEqual(decoded.cards, [card], "one record per card; ids of user words are not cards")
        XCTAssertEqual(decoded.words, [entry])
        XCTAssertEqual(decoded.deleted, ["gone"], "a word that is also deleted stays a word")
    }

    func testUnknownKeysOfTheSameFormatAreIgnored() throws {
        let data = Data(#"{"format": 1, "cards": [], "words": [], "deleted": [], "later": true}"#.utf8)
        XCTAssertEqual(try SyncSnapshot.decode(data), SyncSnapshot())
    }

    func testCanonicalDatesAreAFixedPoint() {
        let fresh = Date(timeIntervalSinceReferenceDate: 812_345_678.123_456_7)
        var record = WordProgress(wordID: 1)
        record.lastReviewedAt = fresh
        let once = SyncCoding.canonical(record)
        XCTAssertEqual(SyncCoding.canonical(once), once)
        XCTAssertEqual(once.lastReviewedAt!.timeIntervalSince1970, fresh.timeIntervalSince1970, accuracy: 0.000_001)
    }

    // MARK: State

    func testStateRoundTripsWithItsUuids() throws {
        let store = SyncStateStore(fileURL: tempFolder.appendingPathComponent("sync_state.json"))
        let state = SyncState(
            joined: true,
            resetAt: now,
            uuids: [CustomWordID.first: "a", CustomWordID.first + 4: "b"],
            base: SyncSnapshot(cards: [fullRecord(3)])
        )
        try store.save(state)
        XCTAssertEqual(try store.load(), state)
    }

    func testMissingOrDamagedStateStartsLikeTurningSyncOn() throws {
        let url = tempFolder.appendingPathComponent("sync_state.json")
        let store = SyncStateStore(fileURL: url)
        XCTAssertEqual(try store.load(), SyncState())
        try Data("{".utf8).write(to: url)
        XCTAssertEqual(try store.load(), SyncState())
        try Data(#"{"format": 9, "joined": true, "uuids": {}}"#.utf8).write(to: url)
        XCTAssertEqual(try store.load(), SyncState(), "a newer build's state is not used")
    }

    func testUnreadableStateThrows() throws {
        let url = tempFolder.appendingPathComponent("sync_state.json")
        // A folder where the file should be: it exists but cannot be read as a file.
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        XCTAssertThrowsError(try SyncStateStore(fileURL: url).load())
    }

    func testLeavingKeepsOnlyTheUuids() {
        let state = SyncState(joined: true, resetAt: now, uuids: [CustomWordID.first: "a"], base: SyncSnapshot(cards: [fullRecord(3)]))
        XCTAssertEqual(state.leaving(), SyncState(uuids: [CustomWordID.first: "a"]))
    }

    func testResetIsRememberedOnlyWhileSyncing() {
        XCTAssertNil(SyncState().resetting(at: now).resetAt, "sync just turned on: nothing to reset in iCloud yet")
        XCTAssertEqual(SyncState(joined: true).resetting(at: now).resetAt, now)
    }
}
