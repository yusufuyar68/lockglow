import XCTest
import CoreModels
import Learning

final class DataExportTests: XCTestCase {
    /// 2025-10-09 12:00 UTC: whole seconds, as the backup writes them.
    private let now = Date(timeIntervalSince1970: 1_760_011_200)
    private let day: TimeInterval = 86_400

    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func learning(_ id: Int, box: Int = 2, reviews: Int = 3) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = box
        p.reviews = reviews
        p.lapses = 1
        p.exposures = 4
        p.dueAt = now.addingTimeInterval(2 * day)
        p.lastSeenAt = now.addingTimeInterval(-day)
        p.lastReviewedAt = now.addingTimeInterval(-day)
        p.lastGrade = .good
        p.firstReviewedAt = now.addingTimeInterval(-10 * day)
        p.fsrs = FSRSState(stability: 3.25, difficulty: 5.5, phase: .review, step: nil, lastReviewAt: now.addingTimeInterval(-day), reviews: reviews, shelfBefore: nil)
        return p
    }

    private func knownByTap(_ id: Int) -> WordProgress {
        return Leitner.markKnown(WordProgress(wordID: id), at: now.addingTimeInterval(-3600))
    }

    private func sampleArchive() throws -> DataArchive {
        var graduated = learning(20, box: 5, reviews: 6)
        graduated.state = .known
        graduated.refresherStep = 1
        var custom = CustomWordList()
        try custom.add(CustomWordDraft(lemma: "awkward", meaningTR: "garip; tuhaf", exampleEN: "That was \"awkward\".", note: "Dizide duydum\nikinci satır"), now: now.addingTimeInterval(-2 * day))
        var metrics = LocalMetrics()
        metrics.recordAnswer(isNew: true, firstTryCorrect: true, seconds: 7.5, at: now, calendar: utc)
        metrics.recordRound(seconds: 95.5, endedEarly: true, at: now, calendar: utc)
        metrics.recordNewWord(taps: 3, at: now, calendar: utc)
        metrics.recordReminderPlan([now.addingTimeInterval(day)], now: now, calendar: utc)
        let log = [
            ReviewLogEntry(wordID: 10, at: now.addingTimeInterval(-day), grade: .good, source: .review, reviews: 3),
            ReviewLogEntry(wordID: 10, at: now.addingTimeInterval(-2 * day), grade: .again, source: .widget, reviews: 2, knownCheck: true),
        ]
        let names: [Int: (lemma: String, meaningTR: String?)] = [10: ("borrow", "ödünç almak"), 20: ("lend", "ödünç vermek"), 30: ("spoon", "kaşık")]
        return DataArchive.make(
            progress: [10: learning(10), 20: graduated, 30: knownByTap(30), 40: WordProgress(wordID: 40)],
            customWords: custom,
            reviewLog: log,
            localMetrics: metrics,
            settings: DataArchive.Settings(startLevel: "A2", topicIDs: ["food"], dailyNewWords: 5, rotationMinutes: 60, reminderEnabled: true, reminderTime: "20:00"),
            recentSearches: ["kahv", "borrow"],
            appVersion: "1.0 (31)",
            contentVersion: "2026.10.22-kisisel-9",
            now: now,
            word: { names[$0] }
        )
    }

    // MARK: JSON

    func testBackupReadsBackExactly() throws {
        let archive = try sampleArchive()
        let reading = try DataArchive.read(try archive.encoded())
        XCTAssertEqual(reading.unreadableRecords, 0)
        XCTAssertEqual(reading.archive, archive)
        XCTAssertEqual(reading.archive.progress.map { $0.progress.wordID }, [10, 20, 30, 40], "sorted by word id")
        XCTAssertEqual(reading.archive.progress.first?.lemma, "borrow")
        XCTAssertNil(reading.archive.progress.last?.lemma, "a word the app cannot name has no lemma")
    }

    func testBackupIsReadableJSON() throws {
        let data = try sampleArchive().encoded()
        let text = String(decoding: data, as: UTF8.self)
        XCTAssertTrue(text.contains("\n"), "indented")
        XCTAssertTrue(text.contains("ödünç almak"), "Turkish letters as they are, not escaped")
        XCTAssertTrue(text.contains("2025-10-08T12:00:00Z"), "ISO 8601 dates")

        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["format"] as? String, "lockglow-yedek")
        XCTAssertEqual(object["format_version"] as? Int, 1)
        XCTAssertEqual(object["about"] as? String, DataArchive.aboutText)
        let progress = try XCTUnwrap(object["progress"] as? [[String: Any]])
        XCTAssertEqual(progress.first?["word_id"] as? Int, 10)
        XCTAssertEqual(progress.first?["meaning_tr"] as? String, "ödünç almak")
        XCTAssertEqual(progress.first?["box"] as? Int, 2, "the progress keys of progress.json")
        XCTAssertNotNil(progress.first?["fsrs"] as? [String: Any], "FSRS memory comes along")
        let known = try XCTUnwrap(object["known_words"] as? [[String: Any]])
        XCTAssertEqual(known.map { $0["lemma"] as? String }, ["lend", "spoon"], "by English word")
        XCTAssertEqual(known.map { $0["how"] as? String }, ["Tekrar'da öğrendin", "Biliyorum dedin"])
        let custom = try XCTUnwrap(object["custom_words"] as? [String: Any])
        XCTAssertEqual(custom["next_id"] as? Int, CustomWordID.first + 1)
        XCTAssertNotNil(object["review_log"] as? [[String: Any]])
        XCTAssertNotNil(object["local_metrics"] as? [String: Any])
        let settings = try XCTUnwrap(object["settings"] as? [String: Any])
        XCTAssertEqual(settings["reminder_time"] as? String, "20:00")
        XCTAssertEqual(object["recent_searches"] as? [String], ["kahv", "borrow"])
    }

    func testEmptyArchiveReadsBack() throws {
        let archive = DataArchive(exportedAt: now)
        let reading = try DataArchive.read(try archive.encoded())
        XCTAssertEqual(reading.archive, archive)
        XCTAssertTrue(reading.archive.knownWords.isEmpty)
    }

    // MARK: Refused files

    func testOtherFilesAreRefused() {
        let samples: [Data] = [
            Data(),
            Data("not json".utf8),
            Data("[1, 2]".utf8),
            Data("{\"words\": []}".utf8),
            Data("{\"format\": \"something-else\", \"format_version\": 1}".utf8),
            Data("{\"format\": \"lockglow-yedek\", \"format_version\": 0}".utf8),
            Data("{\"format\": \"lockglow-yedek\"}".utf8),
        ]
        for data in samples {
            XCTAssertThrowsError(try DataArchive.read(data), String(decoding: data, as: UTF8.self)) { error in
                XCTAssertEqual(error as? DataArchive.ReadError, .notBackup)
            }
        }
    }

    func testNewerFormatIsRefusedWithItsVersion() {
        let data = Data("{\"format\": \"lockglow-yedek\", \"format_version\": 2, \"progress\": []}".utf8)
        XCTAssertThrowsError(try DataArchive.read(data)) { error in
            XCTAssertEqual(error as? DataArchive.ReadError, .newerVersion(2))
        }
        XCTAssertTrue(DataArchive.ReadError.newerVersion(2).message.contains("güncelle"))
    }

    func testTooLargeFileIsRefusedBeforeReading() throws {
        let data = try sampleArchive().encoded()
        XCTAssertThrowsError(try DataArchive.read(data, maxBytes: data.count - 1)) { error in
            XCTAssertEqual(error as? DataArchive.ReadError, .tooLarge)
        }
        XCTAssertNoThrow(try DataArchive.read(data, maxBytes: data.count))
    }

    func testDamagedRecordsAreCountedAndTheRestIsRead() throws {
        let json = """
        {
          "format": "lockglow-yedek",
          "format_version": 1,
          "exported_at": "2025-10-09T12:00:00Z",
          "progress": [
            {"word_id": 1, "state": "new", "box": 0, "exposures": 2, "reviews": 0, "lapses": 0, "known_override": false, "saved": false},
            {"word_id": 2, "state": "someday", "box": 0, "exposures": 0, "reviews": 0, "lapses": 0, "known_override": false, "saved": false},
            {"word_id": 3, "box": "x"}
          ],
          "custom_words": {"next_id": 1000002, "words": [
            {"id": 1000000, "lemma": "awkward", "meaning_tr": "garip", "created_at": "2025-10-01T08:00:00Z", "updated_at": "2025-10-01T08:00:00Z"},
            {"id": 1000001, "lemma": "broken"}
          ]},
          "review_log": [
            {"word_id": 1, "at": "2025-10-08T12:00:00Z", "grade": "good", "source": "review", "reviews": 1},
            {"word_id": 1, "at": "yesterday", "grade": "good", "source": "review", "reviews": 2}
          ],
          "local_metrics": "not an object",
          "an_unknown_part": {"from": "a later build"}
        }
        """
        let reading = try DataArchive.read(Data(json.utf8))
        XCTAssertEqual(reading.unreadableRecords, 4)
        XCTAssertEqual(reading.archive.progress.map { $0.progress.wordID }, [1])
        XCTAssertEqual(reading.archive.customWords.map { $0.lemma }, ["awkward"])
        XCTAssertEqual(reading.archive.customNextID, 1_000_002)
        XCTAssertEqual(reading.archive.reviewLog.count, 1)
        XCTAssertEqual(reading.archive.localMetrics, LocalMetrics(), "a part that cannot be read is empty")
        XCTAssertEqual(reading.archive.exportedAt, now)
    }

    // MARK: CSV

    func testFieldQuotesAndGuardsFormulas() {
        XCTAssertEqual(DataCSV.field("borrow"), "borrow")
        XCTAssertEqual(DataCSV.field("garip; tuhaf"), "\"garip; tuhaf\"")
        XCTAssertEqual(DataCSV.field("That was \"awkward\"."), "\"That was \"\"awkward\"\".\"")
        XCTAssertEqual(DataCSV.field("satır\nsatır"), "\"satır\nsatır\"")
        XCTAssertEqual(DataCSV.field(" boşluk"), "\" boşluk\"")
        XCTAssertEqual(DataCSV.field("garip, tuhaf"), "garip, tuhaf", "a comma needs no quotes with ;")
        XCTAssertEqual(DataCSV.field("=HYPERLINK(\"x\")"), "\"'=HYPERLINK(\"\"x\"\")\"")
        XCTAssertEqual(DataCSV.field("+90"), "'+90")
        XCTAssertEqual(DataCSV.field("-den beri"), "'-den beri")
        XCTAssertEqual(DataCSV.field("@here"), "'@here")
        XCTAssertEqual(DataCSV.field(""), "")
    }

    func testDocumentHasByteOrderMarkAndCRLF() {
        let data = DataCSV.document(header: ["Kelime", "Türkçe"], rows: [["spoon", "kaşık"]])
        XCTAssertEqual(Array(data.prefix(3)), [0xEF, 0xBB, 0xBF])
        XCTAssertEqual(String(decoding: data.dropFirst(3), as: UTF8.self), "Kelime;Türkçe\r\nspoon;kaşık\r\n")
    }

    func testDateTimeIsLocal() {
        XCTAssertEqual(DataCSV.dateTime(now, calendar: utc), "2025-10-09 12:00")
        var istanbul = utc
        istanbul.timeZone = TimeZone(secondsFromGMT: 3 * 3600)!
        XCTAssertEqual(DataCSV.dateTime(now.addingTimeInterval(-5 * 60), calendar: istanbul), "2025-10-09 14:55")
        XCTAssertEqual(DataCSV.dateTime(nil, calendar: utc), "")
    }

    private func lines(_ file: DataExportFile) -> [String] {
        let text = String(decoding: file.data.dropFirst(3), as: UTF8.self)
        return text.components(separatedBy: "\r\n").filter { !$0.isEmpty }
    }

    func testTablesNameTheirFilesAndRows() throws {
        let archive = try sampleArchive()
        let files = archive.tableFiles(calendar: utc)
        XCTAssertEqual(files.map { $0.name }, [
            "lockglow-ilerleme-2025-10-09.csv",
            "lockglow-bildigin-kelimeler-2025-10-09.csv",
            "lockglow-kendi-kelimeler-2025-10-09.csv",
            "lockglow-olcumler-2025-10-09.csv",
        ])
        XCTAssertEqual(try archive.backupFile(calendar: utc).name, "lockglow-yedek-2025-10-09.json")

        let progress = lines(files[0])
        XCTAssertEqual(progress.first, "Kelime;Türkçe;Durum;Basamak;Sıradaki tekrar;Cevap sayısı;Bilemediğin;Son cevap;Widget'ta görülme;Kelime no")
        XCTAssertEqual(progress.count, 5)
        XCTAssertEqual(progress[1], "borrow;ödünç almak;Öğreniyorsun;2;2025-10-11 12:00;3;1;2025-10-08 12:00;4;10")
        XCTAssertTrue(progress[2].hasPrefix("lend;ödünç vermek;Bildiğin kelime;;"), "no step for a known word")
        XCTAssertTrue(progress[3].hasPrefix("spoon;kaşık;Bildiğin kelime;"))
        XCTAssertEqual(progress[4], ";;Yeni kelime;;;0;0;;0;40", "a word without a name comes last")

        XCTAssertEqual(lines(files[1]), [
            "Kelime;Türkçe;Nasıl;Tarih;Kelime no",
            "lend;ödünç vermek;Tekrar'da öğrendin;2025-10-08 12:00;20",
            "spoon;kaşık;Biliyorum dedin;2025-10-09 11:00;30",
        ])

        let custom = String(decoding: files[2].data.dropFirst(3), as: UTF8.self)
        XCTAssertEqual(custom, "Kelime;Türkçe;Örnek cümle;Not;Eklendiği gün;Durum;Kelime no\r\n"
            + "awkward;\"garip; tuhaf\";\"That was \"\"awkward\"\".\";\"Dizide duydum\nikinci satır\";2025-10-07 12:00;Yeni kelime;1000000\r\n")

        let metrics = lines(files[3])
        XCTAssertEqual(metrics.count, 3, "header, today, and tomorrow's reminder")
        XCTAssertEqual(metrics[1], "2025-10-09;0;1;1;1;8;1;1;96;1;1;3;0;0;0;0")
        XCTAssertEqual(metrics[2], "2025-10-10;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0")
    }
}
