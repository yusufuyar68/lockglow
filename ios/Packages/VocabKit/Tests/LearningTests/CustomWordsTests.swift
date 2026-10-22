import XCTest
import CoreModels
import Learning

final class CustomWordsTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_760_011_200)

    private func draft(_ lemma: String, _ meaning: String = "anlam", example: String = "", note: String = "") -> CustomWordDraft {
        return CustomWordDraft(lemma: lemma, meaningTR: meaning, exampleEN: example, note: note)
    }

    private func list(_ lemmas: String...) throws -> CustomWordList {
        var result = CustomWordList()
        for lemma in lemmas {
            try result.add(draft(lemma), now: now)
        }
        return result
    }

    // MARK: Text

    func testLemmaNormalizesKeyboardPunctuationAndSpaces() {
        XCTAssertEqual(CustomWordText.lemma("don\u{2019}t"), "don't")
        XCTAssertEqual(CustomWordText.lemma("rock \u{2018}n\u{2019} roll"), "rock 'n' roll")
        XCTAssertEqual(CustomWordText.lemma("well\u{2014}known"), "well-known")
        XCTAssertEqual(CustomWordText.lemma("well\u{2011}known"), "well-known")
        XCTAssertEqual(CustomWordText.lemma("  look \t  up\n"), "look up")
        XCTAssertEqual(CustomWordText.lemma("Awkward"), "Awkward", "case stays as typed")
    }

    func testSpeakableMatchesThePipelineRule() {
        // validate.py SPEAKABLE_LEMMA: [A-Za-z]+(?:[ '\-][A-Za-z]+)*
        for lemma in ["awkward", "I", "look up", "don't", "well-known", "mother-in-law", "Monday"] {
            XCTAssertTrue(CustomWordText.isSpeakable(lemma), lemma)
        }
        for lemma in ["", " ", "sb/sth", "rock 'n' roll", "a1", "-up", "up-", "it's'", "'em", "a  b", "a -b", "café", "naïve", "e.g", "şarj", "x\u{301}"] {
            XCTAssertFalse(CustomWordText.isSpeakable(lemma), lemma)
        }
    }

    // MARK: Problems

    func testEmptyDraftMissesWordAndMeaning() {
        let problems = CustomWordDraft().problems()
        XCTAssertEqual(problems, [.lemmaMissing, .meaningMissing])
        XCTAssertEqual(problems.map { $0.field }, [.lemma, .meaning])
        XCTAssertTrue(problems.allSatisfy { $0.isMissingField })
        XCTAssertEqual(draft("   ", " \n ").problems(), [.lemmaMissing, .meaningMissing], "spaces only count as empty")
    }

    func testValidDraftHasNoProblems() {
        XCTAssertEqual(draft("awkward", "garip, tuhaf", example: "That was awkward.", note: "Dizide duydum").problems(), [])
    }

    func testTurkishLetterIsNamed() {
        XCTAssertEqual(draft("şarj").problems(), [.lemmaHasTurkishLetter("ş")])
        XCTAssertEqual(draft("thınk").problems(), [.lemmaHasTurkishLetter("ı")])
        XCTAssertEqual(draft("İce").problems(), [.lemmaHasTurkishLetter("İ")])
        XCTAssertTrue(CustomWordProblem.lemmaHasTurkishLetter("ş").message.contains("ş"))
    }

    func testUnspeakableLemma() {
        XCTAssertEqual(draft("sb/sth").problems(), [.lemmaNotSpeakable])
        XCTAssertEqual(draft("covid19").problems(), [.lemmaNotSpeakable])
        XCTAssertEqual(draft("café").problems(), [.lemmaNotSpeakable])
        XCTAssertFalse(CustomWordProblem.lemmaNotSpeakable.isMissingField)
    }

    func testLimitsCountGraphemesOfTheNormalizedText() {
        let longest = String(repeating: "a", count: CustomWordDraft.lemmaLimit)
        XCTAssertEqual(draft(longest).problems(), [])
        XCTAssertEqual(draft(longest + "a").problems(), [.lemmaTooLong])
        XCTAssertEqual(draft("  " + longest + "  ").problems(), [], "trimmed spaces do not count")

        let meaning = String(repeating: "ğ", count: CustomWordDraft.meaningLimit)
        XCTAssertEqual(draft("word", meaning).problems(), [])
        XCTAssertEqual(draft("word", meaning + "ş").problems(), [.meaningTooLong])

        let example = String(repeating: "b", count: CustomWordDraft.exampleLimit)
        XCTAssertEqual(draft("word", example: example).problems(), [])
        XCTAssertEqual(draft("word", example: example + "b").problems(), [.exampleTooLong])

        let note = String(repeating: "n", count: CustomWordDraft.noteLimit)
        XCTAssertEqual(draft("word", note: note).problems(), [])
        XCTAssertEqual(draft("word", note: note + "n").problems(), [.noteTooLong])
    }

    func testProblemsComeInFormOrder() {
        let problems = CustomWordDraft(
            lemma: "",
            meaningTR: String(repeating: "x", count: 40),
            exampleEN: String(repeating: "y", count: 200),
            note: String(repeating: "z", count: 300)
        ).problems()
        XCTAssertEqual(problems, [.lemmaMissing, .meaningTooLong, .exampleTooLong, .noteTooLong])
        XCTAssertEqual(problems.map { $0.field }, [.lemma, .meaning, .example, .note])
    }

    func testDuplicateIgnoresCaseButNotTheEditedWord() throws {
        let words = try list("Awkward", "look up")
        let awkward = try XCTUnwrap(words.words.first)
        XCTAssertEqual(words.problems(for: draft("awkward")), [.lemmaAlreadyAdded(id: awkward.id)])
        XCTAssertEqual(words.problems(for: draft(" LOOK  UP ")), [.lemmaAlreadyAdded(id: awkward.id + 1)])
        XCTAssertEqual(words.problems(for: draft("awkward"), editing: awkward.id), [], "its own lemma is no duplicate")
        XCTAssertEqual(words.problems(for: draft("look up"), editing: awkward.id), [.lemmaAlreadyAdded(id: awkward.id + 1)])
    }

    func testEveryProblemHasAMessage() {
        let all: [CustomWordProblem] = [
            .lemmaMissing, .lemmaTooLong, .lemmaHasTurkishLetter("ç"), .lemmaNotSpeakable, .lemmaAlreadyAdded(id: 1),
            .meaningMissing, .meaningTooLong, .exampleTooLong, .noteTooLong,
        ]
        for problem in all {
            XCTAssertFalse(problem.message.isEmpty, "\(problem)")
        }
        XCTAssertTrue(CustomWordProblem.lemmaTooLong.message.contains("\(CustomWordDraft.lemmaLimit)"))
    }

    // MARK: List

    func testAddGivesIDsFromTheCustomRangeAndSavesNormalizedFields() throws {
        var words = CustomWordList()
        XCTAssertEqual(words.nextID, CustomWordID.first)
        let first = try words.add(
            CustomWordDraft(lemma: "  don\u{2019}t  mind ", meaningTR: " fark etmez ", exampleEN: " I don't\nmind. ", note: "\n işte duydum \n"),
            now: now
        )
        XCTAssertEqual(first.id, 1_000_000)
        XCTAssertEqual(first.lemma, "don't mind")
        XCTAssertEqual(first.meaningTR, "fark etmez")
        XCTAssertEqual(first.exampleEN, "I don't mind.")
        XCTAssertEqual(first.note, "işte duydum")
        XCTAssertEqual(first.createdAt, now)
        XCTAssertEqual(first.updatedAt, now)

        let second = try words.add(draft("awkward"), now: now)
        XCTAssertEqual(second.id, 1_000_001)
        XCTAssertNil(second.exampleEN, "an empty example is nil")
        XCTAssertNil(second.note)
        XCTAssertEqual(words.words.map { $0.id }, [1_000_000, 1_000_001], "oldest first")
        XCTAssertEqual(words.nextID, 1_000_002)
    }

    func testInvalidAddChangesNothing() throws {
        var words = try list("awkward")
        let before = words
        XCTAssertThrowsError(try words.add(draft("awkward"))) { error in
            XCTAssertEqual(error as? CustomWordList.ChangeError, .invalid([.lemmaAlreadyAdded(id: 1_000_000)]))
        }
        XCTAssertThrowsError(try words.add(CustomWordDraft()))
        XCTAssertEqual(words, before)
    }

    func testIDsAreNeverReused() throws {
        var words = try list("one", "two")
        XCTAssertEqual(words.remove(id: 1_000_001)?.lemma, "two")
        XCTAssertNil(words.remove(id: 1_000_001), "already gone")
        let three = try words.add(draft("three"), now: now)
        XCTAssertEqual(three.id, 1_000_002, "the deleted word's id stays unused")
    }

    func testUpdateKeepsIDAndCreationDate() throws {
        var words = try list("awkard", "nice")
        let later = now.addingTimeInterval(3_600)
        let fixed = try words.update(id: 1_000_000, with: draft("awkward", "garip"), now: later)
        XCTAssertEqual(fixed.id, 1_000_000)
        XCTAssertEqual(fixed.lemma, "awkward")
        XCTAssertEqual(fixed.meaningTR, "garip")
        XCTAssertEqual(fixed.createdAt, now)
        XCTAssertEqual(fixed.updatedAt, later)
        XCTAssertEqual(words.word(id: 1_000_000), fixed)
        XCTAssertEqual(words.words.map { $0.lemma }, ["awkward", "nice"], "same place")

        let before = words
        XCTAssertThrowsError(try words.update(id: 1_000_000, with: draft("nice"))) { error in
            XCTAssertEqual(error as? CustomWordList.ChangeError, .invalid([.lemmaAlreadyAdded(id: 1_000_001)]))
        }
        XCTAssertThrowsError(try words.update(id: 42, with: draft("other"))) { error in
            XCTAssertEqual(error as? CustomWordList.ChangeError, .notFound(id: 42))
        }
        XCTAssertEqual(words, before)
    }

    func testRestorePutsAWordBackInItsPlace() throws {
        var words = try list("one", "two", "three")
        let two = try XCTUnwrap(words.remove(id: 1_000_001))
        try words.restore(two)
        XCTAssertEqual(words.words.map { $0.lemma }, ["one", "two", "three"])
        XCTAssertEqual(words.word(id: 1_000_001), two)
        XCTAssertEqual(words.nextID, 1_000_003)

        XCTAssertThrowsError(try words.restore(two)) { error in
            XCTAssertEqual(error as? CustomWordList.ChangeError, .idUnavailable(id: 1_000_001), "id in use")
        }
        let never = CustomWord(id: 1_000_050, lemma: "never", meaningTR: "asla", createdAt: now)
        XCTAssertThrowsError(try words.restore(never)) { error in
            XCTAssertEqual(error as? CustomWordList.ChangeError, .idUnavailable(id: 1_000_050), "never given out")
        }
    }

    func testRestoreFailsWhenTheSameWordWasAddedAgain() throws {
        var words = try list("awkward")
        let old = try XCTUnwrap(words.remove(id: 1_000_000))
        let again = try words.add(draft("Awkward"), now: now)
        XCTAssertThrowsError(try words.restore(old)) { error in
            XCTAssertEqual(error as? CustomWordList.ChangeError, .invalid([.lemmaAlreadyAdded(id: again.id)]))
        }
    }

    func testReserveIDsSkipsIDsWithProgress() throws {
        var words = try list("one")
        words.reserveIDs([5, 900, 1_000_000])
        XCTAssertEqual(words.nextID, 1_000_001, "card ids and lower ids change nothing")
        words.reserveIDs([1_000_007, 12, 1_000_003])
        XCTAssertEqual(words.nextID, 1_000_008)
        XCTAssertEqual(try words.add(draft("two"), now: now).id, 1_000_008)
    }

    func testInitDropsIDsOutsideTheRangeAndRepeats() {
        let words = CustomWordList(
            words: [
                CustomWord(id: 1_000_004, lemma: "four", meaningTR: "dört", createdAt: now),
                CustomWord(id: 12, lemma: "card", meaningTR: "kart", createdAt: now),
                CustomWord(id: 1_000_001, lemma: "one", meaningTR: "bir", createdAt: now),
                CustomWord(id: 1_000_004, lemma: "again", meaningTR: "yine", createdAt: now),
            ],
            nextID: 3
        )
        XCTAssertEqual(words.words.map { $0.lemma }, ["one", "four"])
        XCTAssertEqual(words.nextID, 1_000_005)
    }

    // MARK: Conversion

    func testWidgetWordLeavesCardFieldsEmpty() {
        let word = CustomWord(id: 1_000_003, lemma: "awkward", meaningTR: "garip", exampleEN: "That was awkward.", note: "dizi", createdAt: now)
        let widget = word.widgetWord
        XCTAssertEqual(widget.id, 1_000_003)
        XCTAssertEqual(widget.lemma, "awkward")
        XCTAssertEqual(widget.glossTR, "garip")
        XCTAssertEqual(widget.exampleEN, "That was awkward.")
        XCTAssertEqual(widget.pos, "")
        XCTAssertEqual(widget.level, "")
        XCTAssertNil(widget.levelValue)
        XCTAssertNil(widget.ipaUS)
        XCTAssertEqual(widget.defMicro, "")
        XCTAssertEqual(widget.defShort, "")
        XCTAssertTrue(widget.isUserAdded)
        XCTAssertFalse(WidgetWord.sample.isUserAdded)

        let bare = CustomWord(id: 1_000_004, lemma: "nice", meaningTR: "hoş", createdAt: now)
        XCTAssertEqual(bare.widgetWord.exampleEN, "")
    }

    func testWidgetWordSurvivesThePlanCoding() throws {
        // The widget reads it back from widget_plan.json (contract section 6).
        let widget = CustomWord(id: 1_000_000, lemma: "don't mind", meaningTR: "fark etmez", createdAt: now).widgetWord
        let decoded = try JSONDecoder().decode(WidgetWord.self, from: JSONEncoder().encode(widget))
        XCTAssertEqual(decoded, widget)
    }

    func testCardDetailHasTheExampleAndTheNoteButNoQuiz() {
        let word = CustomWord(id: 1_000_000, lemma: "awkward", meaningTR: "garip", exampleEN: "That was awkward.", note: "Toplantıda duydum", createdAt: now)
        let detail = word.cardDetail
        XCTAssertEqual(detail.examples, [CardDetail.Example(en: "That was awkward.")])
        XCTAssertNil(detail.examples.first?.tr)
        XCTAssertEqual(detail.noteTR, "Toplantıda duydum")
        XCTAssertNil(detail.quiz, "Tekrar asks it as a flashcard")
        XCTAssertTrue(detail.mistakes.isEmpty)
        XCTAssertTrue(CustomWord(id: 1_000_001, lemma: "nice", meaningTR: "hoş", createdAt: now).cardDetail.examples.isEmpty)
    }

    func testCustomIDRange() {
        XCTAssertFalse(CustomWordID.contains(1))
        XCTAssertFalse(CustomWordID.contains(1_068))
        XCTAssertFalse(CustomWordID.contains(999_999))
        XCTAssertTrue(CustomWordID.contains(1_000_000))
    }

    // MARK: Deck

    func testPrependingPutsTheUsersWordsFirstOnce() throws {
        let custom = try list("one", "two").widgetWords
        let card = WidgetWord(id: 7, lemma: "spoon", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e")
        let merged = DeckFilter.prepending(custom + [custom[0]], to: [card, custom[1]])
        XCTAssertEqual(merged.map { $0.id }, [1_000_000, 1_000_001, 7])
        XCTAssertEqual(DeckFilter.prepending([], to: [card]), [card])
    }

    func testUsersWordsAreTheFirstNewWords() throws {
        let custom = try list("awkward").widgetWords
        let cards = (1...5).map { WidgetWord(id: $0, lemma: "w\($0)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e") }
        let feed = DeckFilter.prepending(custom, to: cards)
        XCTAssertEqual(ReviewPlanner.newWords(feed: feed, progress: [:], limit: 2).map { $0.id }, [1_000_000, 1])
    }
}

final class CustomWordStoreTests: XCTestCase {
    private var directory: URL!
    private var calendar: Calendar!
    /// Noon on two consecutive days (UTC), far from midnight.
    private let day1 = Date(timeIntervalSince1970: 1_760_011_200)
    private var day2: Date { day1.addingTimeInterval(86_400) }

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("CustomWordStoreTests-\(UUID().uuidString)")
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        calendar = utc
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func makeStore() -> CustomWordStore {
        return CustomWordStore(fileURL: directory.appendingPathComponent("custom_words.json"))
    }

    private func list(_ lemmas: String...) throws -> CustomWordList {
        var result = CustomWordList()
        for lemma in lemmas {
            try result.add(CustomWordDraft(lemma: lemma, meaningTR: "anlam"), now: day1)
        }
        return result
    }

    private func writeRaw(_ text: String, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(text.utf8).write(to: url)
    }

    private func unreadableFiles() throws -> [URL] {
        let names = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        return names.filter { $0.hasPrefix("custom_words-unreadable-") }.sorted().map { directory.appendingPathComponent($0) }
    }

    func testMissingFileIsAnEmptyList() throws {
        let result = try makeStore().load()
        XCTAssertTrue(result.list.isEmpty)
        XCTAssertEqual(result.list.nextID, CustomWordID.first)
        XCTAssertEqual(result.outcome, .fresh)
    }

    func testRoundTripKeepsWordsDatesAndNextID() throws {
        let store = CustomWordStore(fileURL: directory.appendingPathComponent("nested/custom_words.json"))
        var words = CustomWordList()
        try words.add(
            CustomWordDraft(lemma: "awkward", meaningTR: "garip, tuhaf", exampleEN: "That was awkward.", note: "Dizide duydum"),
            now: Date(timeIntervalSince1970: 1_700_000_000.375)
        )
        try words.add(CustomWordDraft(lemma: "deleted", meaningTR: "silindi"), now: day1)
        words.remove(id: 1_000_001)
        try store.save(words)

        let loaded = try store.load()
        XCTAssertEqual(loaded.outcome, .loaded)
        XCTAssertEqual(loaded.list, words)
        XCTAssertEqual(loaded.list.nextID, 1_000_002, "the deleted word's id stays used after a reload")
        XCTAssertEqual(loaded.list.words.first?.createdAt, Date(timeIntervalSince1970: 1_700_000_000.375))
    }

    func testFileFormat() throws {
        let store = makeStore()
        try store.save(try list("awkward"))
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: store.fileURL)) as? [String: Any]
        let body = try XCTUnwrap(object)
        XCTAssertEqual(body["format"] as? Int, 1)
        XCTAssertEqual(body["next_id"] as? Int, 1_000_001)
        let rows = try XCTUnwrap(body["words"] as? [[String: Any]])
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0]["id"] as? Int, 1_000_000)
        XCTAssertEqual(rows[0]["lemma"] as? String, "awkward")
        XCTAssertEqual(rows[0]["meaning_tr"] as? String, "anlam")
        XCTAssertNotNil(rows[0]["created_at"])
        XCTAssertNotNil(rows[0]["updated_at"])
    }

    func testDamagedFileIsSetAsideNotOverwritten() throws {
        let store = makeStore()
        try writeRaw("not json", to: store.fileURL)

        let result = try store.load(now: day1)
        XCTAssertTrue(result.list.isEmpty)
        let aside = try XCTUnwrap(try unreadableFiles().first)
        XCTAssertEqual(result.outcome, .startedOver(setAside: aside))
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.fileURL.path))

        // Saving afterwards writes a new file and leaves the damaged one as it was.
        try store.save(try list("new"), now: day1, calendar: calendar)
        XCTAssertEqual(try String(contentsOf: aside, encoding: .utf8), "not json")
        XCTAssertEqual(try store.load().list.words.map { $0.lemma }, ["new"])
    }

    func testNewerFormatIsSetAsideForALaterBuild() throws {
        let store = makeStore()
        try writeRaw("{\"format\": 2, \"next_id\": 1000001, \"words\": []}", to: store.fileURL)

        let result = try store.load(now: day1)
        let aside = try XCTUnwrap(try unreadableFiles().first)
        XCTAssertEqual(result.outcome, .startedOver(setAside: aside))
    }

    func testDamagedFileRestoresFromBackup() throws {
        let store = makeStore()
        try store.save(try list("one"), now: day1, calendar: calendar)
        try store.save(try list("one", "two"), now: day1, calendar: calendar)  // backup = [one]
        try writeRaw("{\"broken\"", to: store.fileURL)

        let result = try store.load(now: day2)
        XCTAssertEqual(result.list.words.map { $0.lemma }, ["one"])
        guard case let .restoredFromBackup(setAside, backupDate) = result.outcome else {
            return XCTFail("expected a restore, got \(result.outcome)")
        }
        XCTAssertEqual(setAside, try unreadableFiles().first)
        let taken = try XCTUnwrap(backupDate)
        XCTAssertTrue(calendar.isDate(taken, inSameDayAs: day1))
    }

    func testMissingFileWithBackupRestoresBackup() throws {
        let store = makeStore()
        try store.save(try list("one"), now: day1, calendar: calendar)
        try store.save(try list("one", "two"), now: day1, calendar: calendar)
        try FileManager.default.removeItem(at: store.fileURL)

        let result = try store.load(now: day2)
        XCTAssertEqual(result.list.words.map { $0.lemma }, ["one"])
        guard case .restoredFromBackup(setAside: nil, backupDate: _) = result.outcome else {
            return XCTFail("expected a restore without a set-aside file, got \(result.outcome)")
        }
    }

    func testBackupIsTakenOncePerDay() throws {
        let store = makeStore()
        func backupLemmas() throws -> [String] {
            return try CustomWordStore(fileURL: store.backupURL).load().list.words.map { $0.lemma }
        }

        try store.save(try list("a"), now: day1, calendar: calendar)
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.backupURL.path), "nothing to back up before the first file")
        try store.save(try list("a", "b"), now: day1, calendar: calendar)
        try store.save(try list("a", "b", "c"), now: day1, calendar: calendar)
        XCTAssertEqual(try backupLemmas(), ["a"], "the backup keeps the day's first state")

        try store.save(try list("a", "b", "c", "d"), now: day2, calendar: calendar)
        XCTAssertEqual(try backupLemmas(), ["a", "b", "c"], "a new day backs up the last state of the previous one")
        XCTAssertEqual(try store.load().list.words.map { $0.lemma }, ["a", "b", "c", "d"])
        XCTAssertEqual(store.backupURL.lastPathComponent, "custom_words.backup.json")
    }

    func testDamagedFileIsNotCopiedToBackup() throws {
        let store = makeStore()
        try store.save(try list("one"), now: day1, calendar: calendar)
        try store.save(try list("one", "two"), now: day1, calendar: calendar)  // backup = [one], taken on day 1
        try writeRaw("garbage", to: store.fileURL)

        // A save on a new day would normally refresh the backup; a damaged file must not replace it.
        try store.save(try list("nine"), now: day2, calendar: calendar)
        XCTAssertEqual(try CustomWordStore(fileURL: store.backupURL).load().list.words.map { $0.lemma }, ["one"])
    }

    func testUnreadableFileThrowsAndIsLeftAlone() throws {
        let store = makeStore()
        // A folder where the file should be: it exists but cannot be read as data.
        try FileManager.default.createDirectory(at: store.fileURL, withIntermediateDirectories: true)

        XCTAssertThrowsError(try store.load()) { error in
            guard case CustomWordStore.LoadError.unreadable = error else {
                return XCTFail("unexpected error \(error)")
            }
        }
        var isFolder: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.fileURL.path, isDirectory: &isFolder))
        XCTAssertTrue(isFolder.boolValue)
        XCTAssertTrue(try unreadableFiles().isEmpty)
    }

    func testDecodingDropsWordsOutsideTheRange() throws {
        let store = makeStore()
        try writeRaw(
            "{\"format\": 1, \"next_id\": 5, \"words\": [{\"id\": 3, \"lemma\": \"card\", \"meaning_tr\": \"kart\", \"created_at\": 0, \"updated_at\": 0}, {\"id\": 1000002, \"lemma\": \"mine\", \"meaning_tr\": \"benim\", \"created_at\": 0, \"updated_at\": 0}]}",
            to: store.fileURL
        )
        let result = try store.load()
        XCTAssertEqual(result.outcome, .loaded)
        XCTAssertEqual(result.list.words.map { $0.id }, [1_000_002])
        XCTAssertEqual(result.list.nextID, 1_000_003)
    }
}
