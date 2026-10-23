import XCTest
import CoreModels
import Learning

final class DataImportTests: XCTestCase {
    /// 2025-10-09 12:00 UTC.
    private let now = Date(timeIntervalSince1970: 1_760_011_200)
    private let day: TimeInterval = 86_400
    private let first = CustomWordID.first

    // MARK: Helpers

    /// A learning word answered `reviews` times, the last time `answeredDaysAgo` days ago.
    private func studied(_ id: Int, reviews: Int, box: Int = 2, answeredDaysAgo: Double = 1) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = box
        p.reviews = reviews
        p.lastReviewedAt = now.addingTimeInterval(-answeredDaysAgo * day)
        p.lastSeenAt = p.lastReviewedAt
        p.lastGrade = .good
        p.firstReviewedAt = now.addingTimeInterval(-30 * day)
        p.dueAt = now.addingTimeInterval(day)
        p.fsrs = FSRSState(stability: 3.25, difficulty: 5.5, phase: .review, step: nil, lastReviewAt: now.addingTimeInterval(-day), reviews: reviews, shelfBefore: nil)
        return p
    }

    private func seen(_ id: Int, daysAgo: Double = 1) -> WordProgress {
        return Leitner.markExposure(WordProgress(wordID: id), at: now.addingTimeInterval(-daysAgo * day))
    }

    private func word(_ id: Int, _ lemma: String, _ meaning: String = "anlam", daysAgo: Double = 5) -> CustomWord {
        return CustomWord(id: id, lemma: lemma, meaningTR: meaning, createdAt: now.addingTimeInterval(-daysAgo * day))
    }

    private func entry(_ id: Int, daysAgo: Double, reviews: Int, grade: ReviewGrade = .good) -> ReviewLogEntry {
        return ReviewLogEntry(wordID: id, at: now.addingTimeInterval(-daysAgo * day), grade: grade, source: .review, reviews: reviews)
    }

    private func reading(
        progress: [WordProgress] = [],
        words: [CustomWord] = [],
        nextID: Int? = nil,
        log: [ReviewLogEntry] = [],
        unreadable: Int = 0
    ) throws -> DataArchive.Reading {
        let archive = DataArchive(
            exportedAt: now.addingTimeInterval(-3600),
            progress: progress.map { DataArchive.Word(progress: $0) },
            customWords: words,
            customNextID: nextID ?? ((words.map { $0.id }.max() ?? first - 1) + 1),
            reviewLog: log
        )
        // Through the file, as the app reads it.
        let read = try DataArchive.read(try archive.encoded())
        XCTAssertEqual(read.unreadableRecords, 0)
        return DataArchive.Reading(archive: read.archive, unreadableRecords: unreadable)
    }

    private func plan(
        _ reading: DataArchive.Reading,
        progress: [Int: WordProgress] = [:],
        words: CustomWordList = CustomWordList()
    ) -> DataImport.Plan {
        return DataImport.plan(reading, progress: progress, customWords: words, now: now)
    }

    // MARK: Empty phone

    func testEverythingJoinsAnEmptyPhone() throws {
        let file = try reading(
            progress: [studied(10, reviews: 3), Leitner.markKnown(WordProgress(wordID: 11), at: now), seen(12), studied(first, reviews: 1)],
            words: [word(first, "awkward"), word(first + 1, "look up")],
            log: [entry(10, daysAgo: 2, reviews: 2), entry(10, daysAgo: 1, reviews: 3), entry(first, daysAgo: 1, reviews: 1)]
        )
        let result = plan(file)
        XCTAssertEqual(result.progress, file.archive.progress.reduce(into: [:]) { $0[$1.progress.wordID] = $1.progress })
        XCTAssertEqual(result.customWords.words, file.archive.customWords, "numbers kept: this phone never gave them out")
        XCTAssertEqual(result.customWords.nextID, first + 2)
        XCTAssertEqual(result.log(device: [], deviceProgress: [:]), file.archive.reviewLog, "each word's answers in the file's order")

        let summary = result.summary
        XCTAssertEqual(summary.wordsInFile, 4)
        XCTAssertEqual(summary.knownInFile, 1)
        XCTAssertEqual(summary.customWordsInFile, 2)
        XCTAssertEqual(summary.wordsAdded, 4)
        XCTAssertEqual(summary.wordsReplaced + summary.wordsKept, 0)
        XCTAssertEqual(summary.customWordsAdded, 2)
        XCTAssertEqual(summary.skipped, 0)
        XCTAssertFalse(summary.changesNothing)
        XCTAssertEqual(summary.exportedAt, now.addingTimeInterval(-3600))
    }

    func testEmptyFileChangesNothing() throws {
        let device = [10: studied(10, reviews: 2)]
        let result = plan(try reading(), progress: device)
        XCTAssertTrue(result.summary.isEmpty)
        XCTAssertTrue(result.summary.changesNothing)
        XCTAssertEqual(result.progress, device)
    }

    // MARK: Conflicts (rule 3)

    func testMoreAnswersWinEitherWay() {
        XCTAssertTrue(DataImport.prefersIncoming(studied(1, reviews: 5, answeredDaysAgo: 20), over: studied(1, reviews: 2, answeredDaysAgo: 0)))
        XCTAssertFalse(DataImport.prefersIncoming(studied(1, reviews: 2, answeredDaysAgo: 0), over: studied(1, reviews: 5, answeredDaysAgo: 20)))
    }

    func testSameAnswersTheLastAnsweredWins() {
        XCTAssertTrue(DataImport.prefersIncoming(studied(1, reviews: 3, answeredDaysAgo: 1), over: studied(1, reviews: 3, answeredDaysAgo: 4)))
        XCTAssertFalse(DataImport.prefersIncoming(studied(1, reviews: 3, answeredDaysAgo: 4), over: studied(1, reviews: 3, answeredDaysAgo: 1)))
    }

    func testNeverAnsweredBiliyorumWinsOverSeen() {
        let tapped = Leitner.markKnown(WordProgress(wordID: 1), at: now.addingTimeInterval(-5 * day))
        let seenLater = seen(1, daysAgo: 0)
        XCTAssertTrue(DataImport.prefersIncoming(tapped, over: seenLater), "seeing is not a review; Biliyorum is a choice")
        XCTAssertFalse(DataImport.prefersIncoming(seenLater, over: tapped))
        XCTAssertTrue(DataImport.prefersIncoming(seen(1, daysAgo: 0), over: seen(1, daysAgo: 3)), "then the one seen last")
    }

    func testFullTieKeepsThePhone() {
        let record = studied(1, reviews: 3)
        XCTAssertFalse(DataImport.prefersIncoming(record, over: record))
        XCTAssertFalse(DataImport.prefersIncoming(WordProgress(wordID: 1), over: WordProgress(wordID: 1)))
    }

    func testRecordsAreNeverMixed() throws {
        var phone = studied(10, reviews: 2, answeredDaysAgo: 0)
        phone.exposures = 9
        let file = studied(10, reviews: 6, box: 4, answeredDaysAgo: 3)
        let result = plan(try reading(progress: [file]), progress: [10: phone, 20: seen(20)])
        XCTAssertEqual(result.progress[10], file, "the whole record of the side that stays")
        XCTAssertEqual(result.progress[20], seen(20), "a word on the phone only stays")
        XCTAssertEqual(result.summary.wordsReplaced, 1)
        XCTAssertEqual(result.summary.wordsKept, 0)
        XCTAssertEqual(result.summary.wordsAdded, 0)
    }

    func testPhoneRecordStaysWhenItHasMore() throws {
        let phone = studied(10, reviews: 8)
        let result = plan(try reading(progress: [studied(10, reviews: 3)]), progress: [10: phone])
        XCTAssertEqual(result.progress[10], phone)
        XCTAssertEqual(result.summary.wordsKept, 1)
        XCTAssertTrue(result.summary.changesNothing)
    }

    // MARK: Twice

    func testImportingTheSameFileTwiceChangesNothing() throws {
        let file = try reading(
            progress: [studied(10, reviews: 4), studied(11, reviews: 1), studied(first, reviews: 2), studied(first + 1, reviews: 1)],
            words: [word(first, "awkward"), word(first + 1, "look up")],
            log: [entry(10, daysAgo: 1, reviews: 4), entry(first, daysAgo: 1, reviews: 2), entry(first + 1, daysAgo: 2, reviews: 1)]
        )
        var phoneWords = CustomWordList()
        try phoneWords.add(CustomWordDraft(lemma: "tiny", meaningTR: "minicik"), now: now) // takes `first`
        let phoneProgress = [10: studied(10, reviews: 2), first: studied(first, reviews: 1, answeredDaysAgo: 0)]
        let phoneLog = [entry(10, daysAgo: 0, reviews: 2), entry(first, daysAgo: 0, reviews: 1)]

        let once = plan(file, progress: phoneProgress, words: phoneWords)
        let onceLog = once.log(device: phoneLog, deviceProgress: phoneProgress)
        let twice = plan(file, progress: once.progress, words: once.customWords)
        XCTAssertTrue(twice.summary.changesNothing)
        XCTAssertEqual(twice.summary.customWordsMatched, 2)
        XCTAssertEqual(twice.progress, once.progress)
        XCTAssertEqual(twice.customWords, once.customWords)
        XCTAssertEqual(twice.log(device: onceLog, deviceProgress: once.progress), onceLog)
    }

    // MARK: Own words (rule 4)

    func testSameEnglishWordIsTheSameWord() throws {
        var phoneWords = CustomWordList()
        let mine = try phoneWords.add(CustomWordDraft(lemma: "Awkward", meaningTR: "tuhaf"), now: now)
        let phoneProgress = [mine.id: studied(mine.id, reviews: 1)]
        let file = try reading(
            progress: [studied(first + 5, reviews: 4)],
            words: [word(first + 5, "awkward", "garip")],
            log: [entry(first + 5, daysAgo: 2, reviews: 4)]
        )
        let result = plan(file, progress: phoneProgress, words: phoneWords)
        XCTAssertEqual(result.customWords.words, [mine], "the phone's text stays; no second awkward")
        XCTAssertEqual(result.summary.customWordsMatched, 1)
        XCTAssertEqual(result.summary.customWordsAdded, 0)
        XCTAssertEqual(result.progress[mine.id]?.reviews, 4, "the file's record has more answers")
        XCTAssertEqual(result.progress[mine.id]?.wordID, mine.id)
        XCTAssertNil(result.progress[first + 5])
        XCTAssertEqual(result.log(device: [], deviceProgress: phoneProgress).map { $0.wordID }, [mine.id])
    }

    func testTakenNumbersAreRenumberedWithTheirProgressAndAnswers() throws {
        var phoneWords = CustomWordList()
        try phoneWords.add(CustomWordDraft(lemma: "tiny", meaningTR: "minicik"), now: now)   // first
        let deleted = try phoneWords.add(CustomWordDraft(lemma: "gone", meaningTR: "gitti"), now: now) // first + 1
        phoneWords.remove(id: deleted.id)
        // A deleted word's progress keeps its number taken; first + 2 was never given out but has progress.
        let phoneProgress = [deleted.id: studied(deleted.id, reviews: 1), first + 2: seen(first + 2)]

        let file = try reading(
            progress: [studied(first, reviews: 3), studied(first + 1, reviews: 2), studied(first + 7, reviews: 1)],
            words: [word(first, "awkward"), word(first + 1, "look up"), word(first + 7, "ripe")],
            log: [entry(first, daysAgo: 1, reviews: 3), entry(first + 1, daysAgo: 1, reviews: 2), entry(first + 7, daysAgo: 1, reviews: 1)]
        )
        let result = plan(file, progress: phoneProgress, words: phoneWords)
        let byLemma = Dictionary(result.customWords.words.map { ($0.lemma, $0.id) }, uniquingKeysWith: { a, _ in a })
        XCTAssertEqual(byLemma["tiny"], first)
        XCTAssertEqual(byLemma["ripe"], first + 7, "free number kept")
        XCTAssertEqual(byLemma["awkward"], first + 8, "taken numbers move above every number in use")
        XCTAssertEqual(byLemma["look up"], first + 9)
        XCTAssertEqual(result.customWords.nextID, first + 10)
        XCTAssertNil(result.customWords.word(id: deleted.id), "a deleted word does not come back")

        XCTAssertEqual(result.progress[first + 8]?.reviews, 3, "awkward's progress moved with it")
        XCTAssertEqual(result.progress[first + 8]?.wordID, first + 8)
        XCTAssertEqual(result.progress[first + 8]?.fsrs, studied(first, reviews: 3).fsrs, "every field moves, FSRS too")
        XCTAssertEqual(result.progress[first + 9]?.reviews, 2)
        XCTAssertEqual(result.progress[first + 7]?.reviews, 1)
        XCTAssertEqual(result.progress[deleted.id], phoneProgress[deleted.id], "the phone's own records are untouched")
        XCTAssertEqual(result.progress[first + 2], phoneProgress[first + 2])
        XCTAssertNil(result.progress[first], "awkward's progress never lands on tiny's number")

        let log = result.log(device: [], deviceProgress: phoneProgress)
        XCTAssertEqual(Set(log.map { $0.wordID }), [first + 7, first + 8, first + 9])
        XCTAssertEqual(log.first { $0.wordID == first + 8 }?.reviews, 3)
    }

    func testProgressOfAnOwnWordTheFileNoLongerHasIsLeftOut() throws {
        let file = try reading(
            progress: [studied(first + 3, reviews: 2), studied(10, reviews: 1)],
            words: [],
            nextID: first + 4,
            log: [entry(first + 3, daysAgo: 1, reviews: 2)]
        )
        let result = plan(file)
        XCTAssertNil(result.progress[first + 3])
        XCTAssertEqual(Set(result.progress.keys), [10])
        XCTAssertEqual(result.summary.skipped, 0, "not damaged: the word was deleted on the other phone")
        XCTAssertTrue(result.log(device: [], deviceProgress: [:]).isEmpty)
    }

    func testOwnWordTextIsCleanedAsTheFormWould() throws {
        let file = try reading(words: [CustomWord(id: first, lemma: "  don\u{2019}t  give up ", meaningTR: " bak \n", exampleEN: "  ", note: " not ", createdAt: now)])
        let saved = try XCTUnwrap(plan(file).customWords.words.first)
        XCTAssertEqual(saved.lemma, "don't give up")
        XCTAssertEqual(saved.meaningTR, "bak")
        XCTAssertNil(saved.exampleEN)
        XCTAssertEqual(saved.note, "not")
    }

    // MARK: Checks (rule 1)

    func testRecordsBreakingARuleAreSkippedAndCounted() throws {
        var badBox = studied(1, reviews: 2)
        badBox.box = 9
        var moreLapsesThanAnswers = studied(2, reviews: 1)
        moreLapsesThanAnswers.lapses = 3
        var learningInBoxZero = studied(3, reviews: 1)
        learningInBoxZero.box = 0
        var answeredInTheFuture = studied(4, reviews: 1)
        answeredInTheFuture.lastReviewedAt = now.addingTimeInterval(3 * day)
        var dueInTenYears = studied(5, reviews: 1)
        dueInTenYears.dueAt = now.addingTimeInterval(3650 * day)
        var before2020 = seen(6)
        before2020.lastSeenAt = Date(timeIntervalSince1970: 1_000_000_000)
        let badWordID = WordProgress(wordID: -4)
        let fine = studied(7, reviews: 1)
        var clockAhead = studied(8, reviews: 1)
        clockAhead.lastReviewedAt = now.addingTimeInterval(3600)

        let file = try reading(
            progress: [badBox, moreLapsesThanAnswers, learningInBoxZero, answeredInTheFuture, dueInTenYears, before2020, badWordID, fine, clockAhead, studied(first, reviews: 1)],
            words: [
                word(first, "şarj"),                                   // Turkish letter (its progress below)
                word(first + 1, "a1"),                                  // not speakable
                word(first + 2, String(repeating: "a", count: 40)),     // too long
                word(first + 3, "awkward", ""),                         // no meaning
                word(first + 4, "ripe"),
                word(first + 5, "RIPE"),                                // same English word twice
                word(5, "card"),                                        // not an own-word number
            ],
            log: [entry(7, daysAgo: 1, reviews: 0), entry(7, daysAgo: -5, reviews: 1), entry(7, daysAgo: 1, reviews: 1)],
            unreadable: 2
        )
        let result = plan(file)
        XCTAssertEqual(Set(result.progress.keys), [7, 8], "a clock a little ahead is fine")
        XCTAssertEqual(result.customWords.words.map { $0.lemma }, ["ripe"])
        XCTAssertEqual(result.log(device: [], deviceProgress: [:]).count, 1)
        // 7 progress + 6 own words + the refused word's progress + 2 answers + 2 unreadable.
        XCTAssertEqual(result.summary.skipped, 18)
        XCTAssertTrue(result.summary.lines.contains("Okunamayan kayıt: 18. Bunlar alınmaz."))
    }

    func testRepeatedWordInTheFileIsReadOnce() throws {
        let file = try reading(progress: [studied(10, reviews: 1), studied(10, reviews: 9)])
        let result = plan(file)
        XCTAssertEqual(result.summary.wordsInFile, 1)
        XCTAssertEqual(result.summary.skipped, 1)
        XCTAssertNotNil(result.progress[10])
    }

    func testHugeNumbersAndUnknownCardsAreSkipped() throws {
        var countless = studied(9, reviews: 1)
        countless.exposures = DataImport.maxCount + 1
        let file = try reading(
            progress: [studied(10, reviews: 1), studied(99, reviews: 1), countless],
            words: [word(Int.max, "awkward"), word(DataImport.maxCustomWordID, "ripe")],
            nextID: first,
            log: [entry(Int.max, daysAgo: 1, reviews: 1)]
        )
        let result = DataImport.plan(file, progress: [:], customWords: CustomWordList(), cardIDs: [9, 10], now: now)
        XCTAssertEqual(Set(result.progress.keys), [10], "card 99 is not on this phone")
        XCTAssertTrue(result.customWords.isEmpty, "no number near Int.max: the renumbering cannot overflow")
        // 99, countless, two own words, one answer.
        XCTAssertEqual(result.summary.skipped, 5)
    }

    // MARK: Answers (rule 5)

    func testEachWordKeepsTheAnswersOfTheSideThatStayed() throws {
        let phoneProgress = [10: studied(10, reviews: 1), 20: studied(20, reviews: 5), 30: studied(30, reviews: 1)]
        let phoneLog = [entry(10, daysAgo: 0, reviews: 1), entry(20, daysAgo: 0, reviews: 5), entry(30, daysAgo: 0, reviews: 1)]
        let file = try reading(
            progress: [studied(10, reviews: 3), studied(20, reviews: 2), studied(40, reviews: 1)],
            log: [entry(10, daysAgo: 3, reviews: 1), entry(10, daysAgo: 2, reviews: 3), entry(20, daysAgo: 2, reviews: 2), entry(40, daysAgo: 2, reviews: 1), entry(50, daysAgo: 2, reviews: 1)]
        )
        let result = plan(file, progress: phoneProgress)
        let log = result.log(device: phoneLog, deviceProgress: phoneProgress)
        XCTAssertEqual(log, [
            entry(20, daysAgo: 0, reviews: 5),   // the phone's 20 stayed
            entry(30, daysAgo: 0, reviews: 1),   // the phone's only
            entry(10, daysAgo: 3, reviews: 1),   // the file's 10 won: its answers, in its order
            entry(10, daysAgo: 2, reviews: 3),
            entry(40, daysAgo: 2, reviews: 1),   // the file's only
        ])
        XCTAssertFalse(log.contains { $0.wordID == 50 }, "answers without a record are left out")
    }

    func testReplacedLogReadsBack() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("DataImportTests-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: folder) }
        let log = ReviewLog(fileURL: folder.appendingPathComponent("review_log.jsonl"))
        try log.append([entry(1, daysAgo: 1, reviews: 1)])
        let merged = [entry(2, daysAgo: 2, reviews: 1), entry(2, daysAgo: 1, reviews: 2, grade: .again)]
        try log.replaceAll(with: merged)
        XCTAssertEqual(try log.entries(), merged)
        try log.append([entry(3, daysAgo: 0, reviews: 1)])
        XCTAssertEqual(try log.entries().count, 3, "appending after a replace still works")

        // A line this build cannot read (a later build's) survives the next replace.
        let later = Data("{\"word_id\": 4, \"from\": \"a later build\"}".utf8)
        var bytes = try Data(contentsOf: log.fileURL)
        bytes.append(later)
        bytes.append(0x0A)
        try bytes.write(to: log.fileURL)
        let kept = try log.unreadableLines()
        XCTAssertEqual(kept, [later])
        try log.replaceAll(with: merged, keeping: kept)
        XCTAssertEqual(try log.entries(), merged)
        XCTAssertEqual(try log.unreadableLines(), [later])
    }

    // MARK: Summary text

    func testSummaryLinesPutNumbersAfterAColon() throws {
        var phoneWords = CustomWordList()
        try phoneWords.add(CustomWordDraft(lemma: "awkward", meaningTR: "garip"), now: now)
        let file = try reading(
            progress: [studied(10, reviews: 3), Leitner.markKnown(WordProgress(wordID: 11), at: now), studied(12, reviews: 1)],
            words: [word(first, "awkward"), word(first + 1, "ripe")],
            unreadable: 1
        )
        let result = plan(file, progress: [12: studied(12, reviews: 4)], words: phoneWords)
        XCTAssertEqual(result.summary.lines, [
            "Dosyadaki kelime kaydı: 3",
            "Bunlardan bildiğin kelime: 1",
            "Kendi kelimen: 2",
            "Bu telefona eklenecek kelime: 2",
            "İki yerde de olan kelime: 1. Daha çok cevap verdiğin kayıt kalır.",
            "Bu telefonda zaten olan kendi kelime: 1",
            "Okunamayan kayıt: 1. Bunlar alınmaz.",
        ])
    }
}
