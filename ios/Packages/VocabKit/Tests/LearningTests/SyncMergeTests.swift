import XCTest
import CoreModels
@testable import Learning

/// iCloud sync between devices (Learning/SyncMerge.swift). Each test plays devices that sync
/// one after another through one iCloud copy, as the app does: the device saves what the merge
/// gives it, and the upload goes through real JSON.
final class SyncMergeTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_760_011_200)

    private func at(_ minutes: Double) -> Date {
        return start.addingTimeInterval(minutes * 60)
    }

    /// One device: its files (progress.json, custom_words.json) and its sync state.
    private struct Device {
        let name: String
        var progress: [Int: WordProgress] = [:]
        var words = CustomWordList()
        var state = SyncState()

        init(_ name: String) {
            self.name = name
        }
    }

    /// iCloud's copy, as the last upload left it.
    private var cloud: SyncSnapshot?
    private var minted: [String: Int] = [:]

    override func setUp() {
        super.setUp()
        cloud = nil
        minted = [:]
    }

    /// Uuids "a-1", "a-2", … for device "a".
    private func mint(_ name: String) -> String {
        minted[name, default: 0] += 1
        return "\(name)-\(minted[name] ?? 0)"
    }

    @discardableResult
    private func sync(_ device: inout Device, localMayBeOld: Bool = false) throws -> SyncMerge.Result {
        let name = device.name
        let result = SyncMerge.sync(
            progress: device.progress,
            words: device.words,
            remote: cloud,
            state: device.state,
            localMayBeOld: localMayBeOld,
            makeUUID: { self.mint(name) }
        )
        if let progress = result.progress {
            device.progress = progress
        }
        if let words = result.words {
            device.words = words
        }
        if let upload = result.upload {
            cloud = try SyncSnapshot.decode(upload.encoded())
        }
        device.state = result.state
        return result
    }

    private func answer(_ device: inout Device, _ id: Int, _ grade: ReviewGrade = .good, at date: Date) {
        let current = device.progress[id] ?? WordProgress(wordID: id)
        device.progress[id] = Leitner.review(current, grade: grade, at: date)
    }

    @discardableResult
    private func add(_ device: inout Device, _ lemma: String, _ meaning: String = "anlam", at date: Date) throws -> CustomWord {
        return try device.words.add(CustomWordDraft(lemma: lemma, meaningTR: meaning), now: date)
    }

    private func word(_ device: Device, _ lemma: String) -> CustomWord? {
        return device.words.words.first(where: { $0.lemma == lemma })
    }

    // MARK: First sync

    func testFirstSyncUploadsThisDevice() throws {
        var a = Device("a")
        answer(&a, 7, at: at(1))
        let w = try add(&a, "awkward", "garip", at: at(2))
        answer(&a, w.id, at: at(3))

        let result = try sync(&a)

        XCTAssertNil(result.progress, "nothing changes on the first device")
        XCTAssertNil(result.words)
        let copy = try XCTUnwrap(cloud)
        XCTAssertEqual(copy.cards.map { $0.wordID }, [7])
        XCTAssertEqual(copy.words.map { $0.lemma }, ["awkward"])
        XCTAssertEqual(copy.words.first?.uuid, "a-1")
        XCTAssertEqual(copy.words.first?.progress?.reviews, 1)
        XCTAssertEqual(a.state.uuids, [w.id: "a-1"])
        XCTAssertTrue(a.state.joined)
        XCTAssertEqual(a.state.base, copy)
    }

    // MARK: Ids of the user's words

    /// Both devices numbered their first word 1 000 000. Each keeps its own ids; the other's word
    /// gets the next free id, and its progress goes with it.
    func testTwoDevicesNeverShareAnId() throws {
        var a = Device("a")
        var b = Device("b")
        let awkward = try add(&a, "awkward", "garip", at: at(1))
        answer(&a, awkward.id, .easy, at: at(2))
        let fancy = try add(&b, "fancy", "süslü", at: at(3))
        answer(&b, fancy.id, .again, at: at(4))
        XCTAssertEqual(awkward.id, fancy.id)

        try sync(&a)
        try sync(&b)
        try sync(&a)

        XCTAssertEqual(word(a, "awkward")?.id, CustomWordID.first)
        XCTAssertEqual(word(a, "fancy")?.id, CustomWordID.first + 1)
        XCTAssertEqual(word(b, "fancy")?.id, CustomWordID.first)
        XCTAssertEqual(word(b, "awkward")?.id, CustomWordID.first + 1)
        XCTAssertEqual(a.progress[CustomWordID.first]?.lastGrade, .easy)
        XCTAssertEqual(a.progress[CustomWordID.first + 1]?.lastGrade, .again)
        XCTAssertEqual(b.progress[CustomWordID.first]?.lastGrade, .again)
        XCTAssertEqual(b.progress[CustomWordID.first + 1]?.lastGrade, .easy)
        XCTAssertEqual(a.words.nextID, CustomWordID.first + 2)
        XCTAssertEqual(cloud?.words.count, 2)
    }

    /// The same English word added on two devices becomes one word, not two.
    func testSameWordAddedOnTwoDevicesBecomesOne() throws {
        var a = Device("a")
        var b = Device("b")
        try add(&a, "awkward", "garip", at: at(1))
        try sync(&a)
        try add(&b, "Awkward", "tuhaf", at: at(2))

        try sync(&b)

        XCTAssertEqual(b.words.words.count, 1)
        XCTAssertEqual(b.state.uuids[CustomWordID.first], "a-1")
        XCTAssertEqual(cloud?.words.count, 1)
        XCTAssertEqual(cloud?.words.first?.meaningTR, "tuhaf", "the later text")
        try sync(&a)
        XCTAssertEqual(a.words.words.map { $0.meaningTR }, ["tuhaf"])
    }

    // MARK: Progress rules

    func testLaterAnswerWinsWhenBothDevicesAnswered() throws {
        var a = Device("a")
        var b = Device("b")
        answer(&a, 7, at: at(1))
        try sync(&a)
        try sync(&b)
        answer(&a, 7, .again, at: at(20))
        answer(&b, 7, .easy, at: at(10))

        try sync(&b)
        try sync(&a)
        try sync(&b)

        XCTAssertEqual(a.progress[7]?.lastReviewedAt, at(20))
        XCTAssertEqual(a.progress[7], b.progress[7])
        XCTAssertEqual(cloud?.cards.first?.lastGrade, .again)
    }

    /// "Öğrenmeye geri al" changes a word without a new date: with only one device changing it,
    /// that change wins on both devices.
    func testChangeWithoutANewDateWinsWhenOnlyOneDeviceMadeIt() throws {
        var a = Device("a")
        var b = Device("b")
        answer(&a, 7, at: at(1))
        let answered = try XCTUnwrap(a.progress[7])
        a.progress[7] = Leitner.markKnown(answered, at: at(2))
        try sync(&a)
        try sync(&b)
        let known = try XCTUnwrap(a.progress[7])
        a.progress[7] = Leitner.undoKnown(known, at: at(3))
        XCTAssertEqual(a.progress[7]?.lastSeenAt, b.progress[7]?.lastSeenAt)

        try sync(&a)
        XCTAssertEqual(a.progress[7]?.state, .learning, "iCloud's older copy does not undo the change")
        try sync(&b)
        XCTAssertEqual(b.progress[7]?.state, .learning)
        XCTAssertEqual(a.progress[7], b.progress[7])
    }

    /// "Geri al" within 5 seconds brings back the older record; a sync in between must not undo it.
    func testGeriAlToAnOlderRecordIsKept() throws {
        var a = Device("a")
        answer(&a, 7, at: at(1))
        let before = try XCTUnwrap(a.progress[7])
        try sync(&a)
        a.progress[7] = Leitner.markKnown(before, at: at(2))
        try sync(&a)
        a.progress[7] = before

        try sync(&a)

        XCTAssertEqual(a.progress[7], before)
        XCTAssertEqual(cloud?.cards, [before])
    }

    func testRuleOrder() {
        var answered = WordProgress(wordID: 4)
        answered.lastReviewedAt = at(1)
        answered.lastSeenAt = at(1)
        answered.reviews = 1
        var viewed = WordProgress(wordID: 4)
        viewed.lastSeenAt = at(9)
        viewed.exposures = 5
        XCTAssertEqual(SyncMerge.pickProgress(local: viewed, remote: answered, base: nil), answered, "an answer beats a later widget view")
        var later = answered
        later.lastReviewedAt = at(2)
        XCTAssertEqual(SyncMerge.pickProgress(local: answered, remote: later, base: nil), later)
        XCTAssertEqual(SyncMerge.pickProgress(local: nil, remote: later, base: nil), later)
        XCTAssertEqual(SyncMerge.pickProgress(local: later, remote: nil, base: answered), later)
        XCTAssertNil(SyncMerge.pickProgress(local: nil, remote: nil, base: answered))
    }

    func testRulesPickTheSameRecordOnBothDevices() {
        var records: [WordProgress] = []
        for answeredAt in [nil, 1.0, 2.0] as [Double?] {
            for seenAt in [nil, 1.0, 3.0] as [Double?] {
                for reviews in [0, 2] {
                    var p = WordProgress(wordID: 4)
                    p.lastReviewedAt = answeredAt.map { at($0) }
                    p.lastSeenAt = seenAt.map { at($0) }
                    p.reviews = reviews
                    p.box = reviews
                    records.append(p)
                }
            }
        }
        // The same on every key the rules look at, different elsewhere.
        var one = WordProgress(wordID: 4)
        one.box = 2
        var other = one
        other.box = 3
        records += [one, other]
        for x in records {
            for y in records {
                XCTAssertEqual(
                    SyncMerge.pickProgress(local: x, remote: y, base: nil),
                    SyncMerge.pickProgress(local: y, remote: x, base: nil)
                )
            }
        }
    }

    /// Two devices wrote at the same moment and iCloud kept the one made from an older copy: the
    /// newer answer of this device is not lost.
    func testOlderCopyWinningARaceDoesNotUndoANewerAnswer() throws {
        var a = Device("a")
        var b = Device("b")
        answer(&a, 7, at: at(1))
        try sync(&a)
        try sync(&b)
        let older = cloud
        answer(&a, 7, .easy, at: at(2))
        try sync(&a)
        answer(&b, 9, at: at(2))
        let race = SyncMerge.sync(progress: b.progress, words: b.words, remote: older, state: b.state)
        cloud = try SyncSnapshot.decode(XCTUnwrap(race.upload).encoded())
        b.state = race.state

        try sync(&a)

        XCTAssertEqual(cloud?.cards.map { $0.wordID }, [7, 9])
        XCTAssertEqual(cloud?.cards.first?.lastGrade, .easy)
    }

    // MARK: Deleting and editing words

    func testDeletionReachesTheOtherDevice() throws {
        var a = Device("a")
        var b = Device("b")
        let w = try add(&a, "awkward", at: at(1))
        try sync(&a)
        try sync(&b)
        answer(&b, CustomWordID.first, at: at(2))
        try sync(&b)
        try sync(&a)
        XCTAssertEqual(a.progress[w.id]?.reviews, 1, "B's answer reached A")

        a.words.remove(id: w.id)
        try sync(&a)
        XCTAssertEqual(cloud?.deleted, ["a-1"])
        XCTAssertEqual(cloud?.words, [])
        try sync(&b)

        XCTAssertTrue(b.words.isEmpty)
        XCTAssertNotNil(b.progress[CustomWordID.first], "its progress stays, as after a deletion in the app")
        XCTAssertEqual(b.words.nextID, CustomWordID.first + 1, "the id is not given again")
    }

    func testEditOnOneDeviceWinsOverDeletionOnTheOther() throws {
        for deleterSyncsFirst in [true, false] {
            cloud = nil
            var a = Device("a")
            var b = Device("b")
            let w = try add(&a, "awkward", "garip", at: at(1))
            answer(&a, w.id, at: at(2))
            try sync(&a)
            try sync(&b)
            a.words.remove(id: w.id)
            try b.words.update(id: CustomWordID.first, with: CustomWordDraft(lemma: "awkward", meaningTR: "tuhaf"), now: at(3))

            if deleterSyncsFirst {
                try sync(&a)
                try sync(&b)
                try sync(&a)
            } else {
                try sync(&b)
                try sync(&a)
                try sync(&b)
            }

            XCTAssertEqual(a.words.words.map { $0.meaningTR }, ["tuhaf"], "deleter first: \(deleterSyncsFirst)")
            XCTAssertEqual(a.words.words.first?.id, w.id, "back under its old id")
            XCTAssertEqual(a.progress[w.id]?.reviews, 1, "with its progress")
            XCTAssertEqual(b.words.words.map { $0.meaningTR }, ["tuhaf"])
            XCTAssertEqual(cloud?.deleted, [])
        }
    }

    /// "Vazgeç" after a deletion that already reached iCloud: the word comes back everywhere.
    func testRestoreAfterASyncedDeletionKeepsTheWord() throws {
        var a = Device("a")
        var b = Device("b")
        let w = try add(&a, "awkward", at: at(1))
        try sync(&a)
        try sync(&b)
        let removed = try XCTUnwrap(a.words.remove(id: w.id))
        try sync(&a)
        try sync(&b)
        XCTAssertTrue(b.words.isEmpty)

        try a.words.restore(removed)
        try sync(&a)

        XCTAssertEqual(a.words.words.map { $0.lemma }, ["awkward"])
        XCTAssertEqual(cloud?.deleted, [])
        try sync(&b)
        XCTAssertEqual(b.words.words.map { $0.lemma }, ["awkward"])
        XCTAssertEqual(b.words.words.first?.id, CustomWordID.first, "back under B's old id")
    }

    // MARK: Files restored from a backup

    func testWordsRestoredFromABackupAreNotDeletedEverywhere() throws {
        var a = Device("a")
        try add(&a, "awkward", at: at(1))
        try add(&a, "fancy", at: at(2))
        try sync(&a)
        // custom_words.json was damaged; the backup from before "fancy" came back.
        a.words = CustomWordList(words: [a.words.words[0]], nextID: CustomWordID.first + 1)
        let unguarded = SyncMerge.sync(progress: a.progress, words: a.words, remote: cloud, state: a.state)
        XCTAssertEqual(unguarded.merged.deleted, ["a-2"], "without the flag this looks like a deletion")

        let result = try sync(&a, localMayBeOld: true)

        XCTAssertEqual(a.words.words.map { $0.lemma }, ["awkward", "fancy"])
        XCTAssertEqual(a.words.words.map { $0.id }, [CustomWordID.first, CustomWordID.first + 1])
        XCTAssertNil(result.upload, "nothing was deleted in iCloud")
    }

    func testOlderBackupDoesNotUndoNewerProgress() throws {
        var a = Device("a")
        answer(&a, 7, at: at(1))
        let old = a.progress
        try sync(&a)
        answer(&a, 7, .easy, at: at(2))
        try sync(&a)
        // progress.json was damaged; yesterday's backup came back.
        a.progress = old

        try sync(&a, localMayBeOld: true)

        XCTAssertEqual(a.progress[7]?.lastReviewedAt, at(2))
    }

    // MARK: Reset and turning sync on

    func testResetReachesOtherDevicesAndKeepsLaterProgress() throws {
        var a = Device("a")
        var b = Device("b")
        answer(&a, 1, at: at(1))
        answer(&a, 2, at: at(1))
        let w = try add(&a, "awkward", at: at(1))
        answer(&a, w.id, at: at(1))
        try sync(&a)
        try sync(&b)

        a.progress = [:]
        a.state = a.state.resetting(at: at(5))
        try sync(&a)
        XCTAssertEqual(cloud?.resetAt, at(5))
        XCTAssertEqual(cloud?.cards, [])
        // B answered a card after the reset, before it heard of it.
        answer(&b, 3, at: at(6))
        try sync(&b)

        XCTAssertEqual(Set(b.progress.keys), [3], "older progress is gone here too; the later answer stays")
        XCTAssertEqual(b.words.words.map { $0.lemma }, ["awkward"], "a reset keeps the user's words")
        XCTAssertEqual(cloud?.cards.map { $0.wordID }, [3])
        XCTAssertNil(cloud?.words.first?.progress)
        XCTAssertEqual(b.state.resetAt, at(5))
        try sync(&a)
        XCTAssertEqual(Set(a.progress.keys), [3])
    }

    /// Sync turned off on C, a deletion and a reset on A, then sync on again on C: C loses nothing.
    func testTurningSyncOnOnlyAdds() throws {
        var a = Device("a")
        var c = Device("c")
        let w = try add(&a, "awkward", at: at(1))
        answer(&a, 7, at: at(1))
        try sync(&a)
        try sync(&c)
        c.state = c.state.leaving()
        answer(&c, 8, at: at(2))
        a.words.remove(id: w.id)
        a.progress = [:]
        a.state = a.state.resetting(at: at(5))
        try sync(&a)
        XCTAssertEqual(cloud?.deleted, ["a-1"])

        try sync(&c)

        XCTAssertEqual(c.words.words.map { $0.lemma }, ["awkward"], "turning sync on deletes nothing here")
        XCTAssertEqual(Set(c.progress.keys), [7, 8])
        XCTAssertEqual(cloud?.cards.map { $0.wordID }, [7, 8])
        XCTAssertEqual(cloud?.deleted, [])
        XCTAssertEqual(cloud?.resetAt, at(5))
    }

    // MARK: Nothing to do

    /// A fresh `Date()` comes back from JSON a tiny bit different: that is not a change.
    func testNothingChangesOnASecondRun() throws {
        var a = Device("a")
        let fresh = Date(timeIntervalSinceReferenceDate: 812_345_678.123_456_7)
        answer(&a, 7, at: fresh)
        let w = try add(&a, "awkward", "garip", at: fresh)
        answer(&a, w.id, at: fresh.addingTimeInterval(0.25))
        try sync(&a)

        let again = try sync(&a)

        XCTAssertNil(again.progress)
        XCTAssertNil(again.words)
        XCTAssertNil(again.upload)
    }

    func testFailedUploadKeepsTheOldBase() throws {
        var a = Device("a")
        answer(&a, 7, at: at(1))
        try sync(&a)
        let base = a.state.base
        answer(&a, 7, .easy, at: at(2))

        let result = SyncMerge.sync(progress: a.progress, words: a.words, remote: cloud, state: a.state)

        XCTAssertNotNil(result.upload)
        XCTAssertEqual(result.stateIfUploadFails.base, base)
        XCTAssertEqual(result.state.base, result.merged)
        a.state = result.stateIfUploadFails
        try sync(&a)
        XCTAssertEqual(cloud?.cards.first?.lastGrade, .easy, "the next sync still sends the answer")
    }

    /// "iCloud'daki kopyayı sil" on another device: the next sync writes this device's copy again.
    func testRemovedCopyIsWrittenAgain() throws {
        var a = Device("a")
        answer(&a, 7, at: at(1))
        try add(&a, "awkward", at: at(1))
        try sync(&a)
        let full = cloud
        cloud = nil

        let result = try sync(&a)

        XCTAssertNil(result.progress)
        XCTAssertNil(result.words)
        XCTAssertEqual(cloud, full)
    }

    // MARK: Random use

    /// A small deterministic random source (the same numbers on every run and platform).
    private struct Dice {
        var state: UInt64

        mutating func next(_ count: Int) -> Int {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Int((state >> 33) % UInt64(count))
        }
    }

    /// Three devices answer, mark, add, edit and delete in random order and sync now and then.
    /// Once all have synced, they hold the same cards and words as iCloud, and the newest answer
    /// to every card is the one kept.
    func testDevicesAgreeAfterRandomUse() throws {
        let grades: [ReviewGrade] = [.again, .hard, .good, .easy]
        let lemmas = ["awkward", "fancy", "brave", "calm", "eager"]
        for seed in 1...20 {
            cloud = nil
            var dice = Dice(state: UInt64(seed))
            var devices = [Device("a\(seed)"), Device("b\(seed)"), Device("c\(seed)")]
            var newestAnswer: [Int: Date] = [:]
            for step in 1...120 {
                let now = at(Double(step))
                let d = dice.next(devices.count)
                let list = devices[d].words.words
                switch dice.next(8) {
                case 0, 1:
                    let id = 1 + dice.next(6)
                    answer(&devices[d], id, grades[dice.next(grades.count)], at: now)
                    newestAnswer[id] = now
                case 2:
                    let id = 1 + dice.next(6)
                    if let p = devices[d].progress[id] {
                        devices[d].progress[id] = p.state == .known ? Leitner.undoKnown(p, at: now) : Leitner.markKnown(p, at: now)
                    }
                case 3:
                    let lemma = lemmas[dice.next(lemmas.count)]
                    _ = try? devices[d].words.add(CustomWordDraft(lemma: lemma, meaningTR: "anlam \(step)"), now: now)
                case 4:
                    if !list.isEmpty {
                        let word = list[dice.next(list.count)]
                        _ = try? devices[d].words.update(id: word.id, with: CustomWordDraft(lemma: word.lemma, meaningTR: "yeni \(step)"), now: now)
                    }
                case 5:
                    if !list.isEmpty {
                        devices[d].words.remove(id: list[dice.next(list.count)].id)
                    }
                default:
                    try sync(&devices[d])
                }
            }
            for _ in 0..<3 {
                for index in devices.indices {
                    try sync(&devices[index])
                }
            }

            guard let copy = cloud else {
                continue
            }
            let cloudWords = copy.words.map { "\($0.lemma)=\($0.meaningTR)" }.sorted()
            for device in devices {
                let cards = device.progress.values.filter { !CustomWordID.contains($0.wordID) }.sorted { $0.wordID < $1.wordID }
                XCTAssertEqual(cards, copy.cards, "seed \(seed), \(device.name)")
                XCTAssertEqual(device.words.words.map { "\($0.lemma)=\($0.meaningTR)" }.sorted(), cloudWords, "seed \(seed), \(device.name)")
            }
            for (id, date) in newestAnswer {
                XCTAssertEqual(copy.cards.first(where: { $0.wordID == id })?.lastReviewedAt, date, "seed \(seed): the newest answer to card \(id)")
            }
            let again = try sync(&devices[0])
            XCTAssertNil(again.upload, "seed \(seed): settled")
        }
    }
}
