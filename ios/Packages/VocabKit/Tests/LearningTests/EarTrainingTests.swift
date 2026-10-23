import XCTest
import CoreModels
import Learning

/// SplitMix64: the same numbers on every platform, so a seed gives the same round.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

final class EarTrainingTests: XCTestCase {
    // MARK: Fixtures

    private func word(_ text: String) -> EarTrainingWord {
        return EarTrainingWord(word: text, ipa: .init(us: "/\(text)/", uk: "/\(text)/"), tr: "tr-\(text)", level: "A2")
    }

    private func group(_ id: String, pairs: [(String, String)]) -> EarTrainingGroup {
        return EarTrainingGroup(
            id: id,
            title: "\(pairs[0].0) / \(pairs[0].1)",
            nameTR: "ad-\(id)",
            sounds: [
                EarTrainingSound(ipa: "1", nameTR: "birinci", howTR: "nasıl 1"),
                EarTrainingSound(ipa: "2", nameTR: "ikinci", howTR: "nasıl 2"),
            ],
            pairs: pairs.map { EarTrainingPair(a: word($0.0), b: word($0.1)) }
        )
    }

    /// Eight groups of five pairs, all words different ("g3a2" is group 3, pair 2, side a).
    private func content(groups count: Int = 8, pairs: Int = 5) -> EarTrainingContent {
        let groups = (0..<count).map { g in
            group("g\(g)", pairs: (0..<pairs).map { p in ("g\(g)a\(p)", "g\(g)b\(p)") })
        }
        return EarTrainingContent(version: "test", groups: groups)
    }

    // MARK: Decoding

    private let sampleJSON = """
    {
      "format": 1,
      "version": "2026.10.23-kulak-1",
      "groups": [
        {
          "id": "ih-ee",
          "title": "ship / sheep",
          "name_tr": "Kısa i ve uzun i",
          "sounds": [
            {"ipa": "ɪ", "name_tr": "kısa i", "how_tr": "Kısa ve gevşek."},
            {"ipa": "iː", "name_tr": "uzun i", "how_tr": "Uzun, dudaklar gerili."}
          ],
          "tip_tr": "Türkçedeki i uzun sese yakındır.",
          "pairs": [
            {"a": {"word": "ship", "ipa": {"us": "/ʃɪp/", "uk": "/ʃɪp/"}, "tr": "gemi", "level": "A2"},
             "b": {"word": "sheep", "ipa": {"us": "/ʃiːp/"}, "tr": "koyun", "level": "A1"}},
            {"a": {"word": "sit", "ipa": {"us": "/sɪt/"}, "tr": "oturmak", "level": "A1"},
             "b": {"word": "Sit ", "ipa": {"us": "/sɪt/"}, "tr": "oturmak", "level": "A1"}}
          ]
        },
        {
          "id": "ed-cluster",
          "title": "ask / asked",
          "name_tr": "Sondaki -ed",
          "sounds": [
            {"ipa": null, "name_tr": "ek yok", "how_tr": "Kelime k ile biter."},
            {"ipa": "t", "name_tr": "-ed eki", "how_tr": "Sona t ekle."}
          ],
          "pairs": [
            {"a": {"word": "ask", "ipa": {"us": "/æsk/"}, "tr": "sormak"},
             "b": {"word": "asked", "ipa": {"us": "/æskt/"}, "tr": "sordu"}}
          ]
        },
        {
          "id": "broken",
          "title": "x / y",
          "name_tr": "Tek sesli",
          "sounds": [{"ipa": "x", "name_tr": "x", "how_tr": "x"}],
          "pairs": [
            {"a": {"word": "x", "ipa": {"us": "/x/"}, "tr": "x"},
             "b": {"word": "y", "ipa": {"us": "/y/"}, "tr": "y"}}
          ]
        }
      ]
    }
    """

    func testDecodesTheFileAndLeavesOutWhatCannotBeAsked() throws {
        let content = try EarTrainingContent.decode(Data(sampleJSON.utf8))
        XCTAssertEqual(content.version, "2026.10.23-kulak-1")
        // "broken" has one sound only.
        XCTAssertEqual(content.groups.map(\.id), ["ih-ee", "ed-cluster"])
        let first = try XCTUnwrap(content.group(id: "ih-ee"))
        XCTAssertEqual(first.nameTR, "Kısa i ve uzun i")
        XCTAssertEqual(first.tipTR, "Türkçedeki i uzun sese yakındır.")
        XCTAssertEqual(first.sound(.a).ipa, "ɪ")
        XCTAssertEqual(first.sound(.b).howTR, "Uzun, dudaklar gerili.")
        // The pair whose two words are the same ("sit" / "Sit ") is dropped.
        XCTAssertEqual(first.pairs.count, 1)
        XCTAssertEqual(first.pairs[0][.a].word, "ship")
        XCTAssertEqual(first.pairs[0][.b].ipa.us, "/ʃiːp/")
        XCTAssertNil(first.pairs[0][.b].ipa.uk)
        let second = try XCTUnwrap(content.group(id: "ed-cluster"))
        XCTAssertNil(second.sound(.a).ipa)
        XCTAssertNil(second.tipTR)
        XCTAssertNil(second.pairs[0].a.level)
    }

    func testANewerFormatIsRefused() {
        let json = #"{"format": 2, "version": "x", "groups": []}"#
        XCTAssertThrowsError(try EarTrainingContent.decode(Data(json.utf8))) { error in
            XCTAssertEqual(error as? EarTrainingContent.DecodeError, .unsupportedFormat(2))
        }
    }

    /// The real file of the app, when this checkout has it (macOS CI runs the tests in place; the
    /// Linux check copies the package alone and skips this; content-pipeline/tests/test_kulak.py
    /// checks the file there).
    func testTheAppFileDecodesAndEveryGroupMakesARound() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // LearningTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // VocabKit
            .deletingLastPathComponent() // Packages
            .deletingLastPathComponent() // ios
            .appendingPathComponent("App/Resources/minimal_pairs.json")
        guard let data = try? Data(contentsOf: url) else {
            throw XCTSkip("minimal_pairs.json is not next to this package copy")
        }
        let content = try EarTrainingContent.decode(data)
        XCTAssertGreaterThanOrEqual(content.groups.count, 14)
        var rng = SeededGenerator(seed: 7)
        for group in content.groups {
            XCTAssertTrue((4...8).contains(group.pairs.count), group.id)
            let round = EarTrainingRound.make(content: content, tally: EarTrainingTally(), focus: group.id, using: &rng)
            XCTAssertEqual(round.count, 10, group.id)
        }
        let mixed = EarTrainingRound.make(content: content, tally: EarTrainingTally(), using: &rng)
        XCTAssertEqual(mixed.count, 10)
        XCTAssertEqual(Set(mixed.map(\.groupID)).count, 5)
    }

    // MARK: Mixed rounds

    func testAMixedRoundHasTenQuestionsFromFiveGroupsTwoEach() {
        var rng = SeededGenerator(seed: 1)
        let round = EarTrainingRound.make(content: content(), tally: EarTrainingTally(), using: &rng)
        XCTAssertEqual(round.count, 10)
        let perGroup = Dictionary(grouping: round, by: \.groupID).mapValues(\.count)
        XCTAssertEqual(perGroup.count, 5)
        XCTAssertTrue(perGroup.values.allSatisfy { $0 == 2 })
    }

    func testTheSameGroupNeverComesTwiceInARow() {
        for seed in 1...50 {
            var rng = SeededGenerator(seed: UInt64(seed))
            let round = EarTrainingRound.make(content: content(), tally: EarTrainingTally(), using: &rng)
            for (lhs, rhs) in zip(round, round.dropFirst()) {
                XCTAssertNotEqual(lhs.groupID, rhs.groupID, "seed \(seed)")
            }
        }
    }

    func testHalfTheQuestionsReadEachSide() {
        for seed in 1...50 {
            var rng = SeededGenerator(seed: UInt64(seed))
            let round = EarTrainingRound.make(content: content(), tally: EarTrainingTally(), using: &rng)
            XCTAssertEqual(round.filter { $0.answerSide == .a }.count, 5, "seed \(seed)")
        }
    }

    func testAnOddCountIsBalancedToOne() {
        var rng = SeededGenerator(seed: 3)
        let round = EarTrainingRound.make(content: content(), tally: EarTrainingTally(), count: 7, using: &rng)
        XCTAssertEqual(round.count, 7)
        let a = round.filter { $0.answerSide == .a }.count
        XCTAssertTrue(a == 3 || a == 4)
    }

    func testTheShownOrderChangesAndAlwaysHoldsBothWords() {
        var seenFirst = Set<EarTrainingSide>()
        for seed in 1...20 {
            var rng = SeededGenerator(seed: UInt64(seed))
            for question in EarTrainingRound.make(content: content(), tally: EarTrainingTally(), using: &rng) {
                XCTAssertEqual(Set(question.shownOrder), [.a, .b])
                XCTAssertEqual(question.options, question.shownOrder.map { question.pair[$0] })
                XCTAssertTrue(question.options.contains(question.answer))
                seenFirst.insert(question.shownOrder[0])
            }
        }
        // The answer's place is not fixed: both sides are shown first sometimes.
        XCTAssertEqual(seenFirst, [.a, .b])
    }

    func testAWordIsInOneQuestionOfARound() {
        for seed in 1...30 {
            var rng = SeededGenerator(seed: UInt64(seed))
            let round = EarTrainingRound.make(content: content(), tally: EarTrainingTally(), using: &rng)
            let words = round.flatMap { [$0.pair.a.word, $0.pair.b.word] }
            XCTAssertEqual(Set(words).count, words.count, "seed \(seed)")
        }
    }

    func testAWordSharedByTwoGroupsIsNotAskedTwiceWhenAvoidable() {
        // "three" is in both groups; each group has other pairs to use instead.
        let a = group("th-t", pairs: [("three", "tree"), ("thin", "tin"), ("thank", "tank")])
        let b = group("th-f", pairs: [("three", "free"), ("thirst", "first"), ("death", "deaf")])
        let content = EarTrainingContent(version: "t", groups: [a, b])
        for seed in 1...40 {
            var rng = SeededGenerator(seed: UInt64(seed))
            let round = EarTrainingRound.make(content: content, tally: EarTrainingTally(), count: 4, using: &rng)
            let threes = round.filter { $0.pair.a.word == "three" }.count
            XCTAssertLessThanOrEqual(threes, 1, "seed \(seed)")
        }
    }

    func testGroupsThatAreOftenMixedUpComeMoreOften() {
        let content = self.content(groups: 10)
        var tally = EarTrainingTally()
        // g0 always mixed up, g1 always heard right.
        for _ in 0..<10 {
            tally.add(groupID: "g0", isRight: false)
            tally.add(groupID: "g1", isRight: true)
        }
        var hard = 0
        var easy = 0
        for seed in 1...300 {
            var rng = SeededGenerator(seed: UInt64(seed))
            let groups = Set(EarTrainingRound.make(content: content, tally: tally, using: &rng).map(\.groupID))
            hard += groups.contains("g0") ? 1 : 0
            easy += groups.contains("g1") ? 1 : 0
        }
        XCTAssertGreaterThan(hard, easy * 2, "hard \(hard), easy \(easy)")
        // Even a group always heard right still comes now and then.
        XCTAssertGreaterThan(easy, 0)
    }

    func testFewerGroupsThanARoundNeedsShareTheTenQuestions() {
        var rng = SeededGenerator(seed: 5)
        let round = EarTrainingRound.make(content: content(groups: 3), tally: EarTrainingTally(), using: &rng)
        XCTAssertEqual(round.count, 10)
        let counts = Dictionary(grouping: round, by: \.groupID).mapValues(\.count).values.sorted()
        XCTAssertEqual(counts, [3, 3, 4])
    }

    func testTheSameSeedGivesTheSameRound() {
        var first = SeededGenerator(seed: 42)
        var second = SeededGenerator(seed: 42)
        let a = EarTrainingRound.make(content: content(), tally: EarTrainingTally(), using: &first)
        let b = EarTrainingRound.make(content: content(), tally: EarTrainingTally(), using: &second)
        XCTAssertEqual(a, b)
    }

    func testNothingToAsk() {
        var rng = SeededGenerator(seed: 1)
        let empty = EarTrainingContent(version: "t", groups: [])
        XCTAssertTrue(EarTrainingRound.make(content: empty, tally: EarTrainingTally(), using: &rng).isEmpty)
        XCTAssertTrue(EarTrainingRound.make(content: content(), tally: EarTrainingTally(), count: 0, using: &rng).isEmpty)
        XCTAssertTrue(EarTrainingRound.make(content: content(), tally: EarTrainingTally(), focus: "nope", using: &rng).isEmpty)
    }

    // MARK: Focus rounds

    func testAFocusRoundAsksOnlyThatGroupAndEveryPairBeforeARepeat() {
        for seed in 1...30 {
            var rng = SeededGenerator(seed: UInt64(seed))
            let round = EarTrainingRound.make(content: content(pairs: 6), tally: EarTrainingTally(), focus: "g2", using: &rng)
            XCTAssertEqual(round.count, 10)
            XCTAssertTrue(round.allSatisfy { $0.groupID == "g2" })
            XCTAssertEqual(Set(round.prefix(6).map(\.pairIndex)).count, 6, "seed \(seed)")
            for (lhs, rhs) in zip(round, round.dropFirst()) {
                XCTAssertNotEqual(lhs.pairIndex, rhs.pairIndex, "seed \(seed)")
            }
            XCTAssertEqual(round.filter { $0.answerSide == .a }.count, 5, "seed \(seed)")
        }
    }

    func testARepeatedPairIsReadFromItsOtherSide() {
        for seed in 1...30 {
            var rng = SeededGenerator(seed: UInt64(seed))
            let round = EarTrainingRound.make(content: content(pairs: 5), tally: EarTrainingTally(), focus: "g0", using: &rng)
            let byPair = Dictionary(grouping: round, by: \.pairIndex)
            XCTAssertEqual(byPair.count, 5)
            for (index, questions) in byPair {
                XCTAssertEqual(questions.count, 2, "seed \(seed) pair \(index)")
                XCTAssertNotEqual(questions[0].answerSide, questions[1].answerSide, "seed \(seed) pair \(index)")
            }
        }
    }

    func testAFocusGroupWithOnePairAlternates() {
        let single = EarTrainingContent(version: "t", groups: [group("one", pairs: [("ship", "sheep")])])
        var rng = SeededGenerator(seed: 9)
        let round = EarTrainingRound.make(content: single, tally: EarTrainingTally(), focus: "one", count: 4, using: &rng)
        XCTAssertEqual(round.count, 4)
        XCTAssertEqual(round.filter { $0.answerSide == .a }.count, 2)
        for (lhs, rhs) in zip(round, round.dropFirst()) {
            XCTAssertNotEqual(lhs.answerSide, rhs.answerSide)
        }
    }

    // MARK: Questions

    func testTheAnswerIsTheSideReadAloud() {
        let pair = EarTrainingPair(a: word("ship"), b: word("sheep"))
        let question = EarTrainingQuestion(groupID: "ih-ee", pairIndex: 0, pair: pair, answerSide: .b, shownOrder: [.b, .a])
        XCTAssertEqual(question.answer.word, "sheep")
        XCTAssertEqual(question.options.map(\.word), ["sheep", "ship"])
        XCTAssertTrue(question.isRight(.b))
        XCTAssertFalse(question.isRight(.a))
        XCTAssertEqual(EarTrainingSide.a.other, .b)
    }

    func testTheIPAFollowsTheAccent() {
        let both = EarTrainingWord.IPA(us: "/wɜːrk/", uk: "/wɜːk/")
        XCTAssertEqual(both.text(for: .american), "/wɜːrk/")
        XCTAssertEqual(both.text(for: .british), "/wɜːk/")
        // No British transcription: the American one.
        XCTAssertEqual(EarTrainingWord.IPA(us: "/ʃɪp/").text(for: .british), "/ʃɪp/")
    }

    // MARK: Tally

    func testTheTallyCountsAndKeepsTheLastTen() {
        var tally = EarTrainingTally()
        XCTAssertTrue(tally.isEmpty)
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        for index in 0..<12 {
            tally.add(groupID: "ih-ee", isRight: index >= 3, at: start.addingTimeInterval(Double(index)))
        }
        let record = try? XCTUnwrap(tally.record(for: "ih-ee"))
        XCTAssertEqual(record?.heard, 12)
        XCTAssertEqual(record?.right, 9)
        // The first two (wrong) fell out; one wrong and nine right are left.
        XCTAssertEqual(record?.recent.count, 10)
        XCTAssertEqual(record?.recentRight, 9)
        XCTAssertEqual(record?.lastAnsweredAt, start.addingTimeInterval(11))
        XCTAssertNil(tally.record(for: "th-t"))
    }

    func testNeedFollowsTheRecentMisses() {
        var tally = EarTrainingTally()
        XCTAssertEqual(tally.need(groupID: "new"), 2, accuracy: 0.0001)
        for _ in 0..<10 {
            tally.add(groupID: "easy", isRight: true)
            tally.add(groupID: "hard", isRight: false)
        }
        XCTAssertEqual(tally.need(groupID: "easy"), 0.75, accuracy: 0.0001)
        XCTAssertEqual(tally.need(groupID: "hard"), 3.25, accuracy: 0.0001)
        // One answer moves a new group a little, not to an end.
        tally.add(groupID: "once", isRight: true)
        XCTAssertEqual(tally.need(groupID: "once"), 1.5, accuracy: 0.0001)
    }

    func testTheGroupLineHasNoZeroAndNoPercent() {
        var tally = EarTrainingTally()
        XCTAssertNil(tally.line(for: "ih-ee"))
        tally.add(groupID: "ih-ee", isRight: false)
        XCTAssertEqual(tally.line(for: "ih-ee"), "Son 1 soruyu dinledin.")
        tally.add(groupID: "ih-ee", isRight: true)
        tally.add(groupID: "ih-ee", isRight: true)
        XCTAssertEqual(tally.line(for: "ih-ee"), "Son 3 soruda 2 tanesini ayırdın.")
        for text in [tally.line(for: "ih-ee"), EarTrainingSummary.line(asked: 10, right: 0)].compactMap({ $0 }) {
            XCTAssertFalse(text.contains("%"))
            XCTAssertFalse(text.contains(" 0 "))
        }
    }

    func testTheRoundSummary() {
        XCTAssertNil(EarTrainingSummary.line(asked: 0, right: 0))
        XCTAssertEqual(EarTrainingSummary.line(asked: 10, right: 7), "10 soru dinledin, 7 tanesini ayırdın.")
        XCTAssertEqual(EarTrainingSummary.line(asked: 10, right: 0), "10 soru dinledin.")
        XCTAssertEqual(EarTrainingSummary.line(asked: 4, right: 4), "4 soru dinledin, 4 tanesini ayırdın.")
    }

    // MARK: Store

    private func temporaryURL() -> URL {
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("ear-\(UUID().uuidString)")
            .appendingPathComponent("ear_training.json")
    }

    func testTheStoreSavesAndLoads() throws {
        let store = EarTrainingStore(fileURL: temporaryURL())
        XCTAssertEqual(try store.load(), EarTrainingTally())
        var tally = EarTrainingTally()
        let when = Date(timeIntervalSince1970: 1_800_000_000)
        tally.add(groupID: "ih-ee", isRight: true, at: when)
        tally.add(groupID: "th-t", isRight: false, at: when)
        try store.save(tally)
        XCTAssertEqual(try store.load(), tally)
        try store.remove()
        XCTAssertEqual(try store.load(), EarTrainingTally())
        // Removing twice is fine.
        try store.remove()
    }

    func testADamagedFileGivesAnEmptyCounter() throws {
        let url = temporaryURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: url)
        let store = EarTrainingStore(fileURL: url)
        XCTAssertEqual(try store.load(), EarTrainingTally())
        try Data(#"{"format": 9, "groups": {}}"#.utf8).write(to: url)
        XCTAssertEqual(try store.load(), EarTrainingTally())
    }

    func testTheFileKeepsTheKeysOfTheFormat() throws {
        let url = temporaryURL()
        let store = EarTrainingStore(fileURL: url)
        var tally = EarTrainingTally()
        tally.add(groupID: "ih-ee", isRight: true, at: Date(timeIntervalSince1970: 1_800_000_000))
        try store.save(tally)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(text.contains(#""format":1"#), text)
        XCTAssertTrue(text.contains(#""last_answered_at":"2027-01-15T08:00:00Z""#), text)
        XCTAssertTrue(text.contains(#""recent":[true]"#), text)
    }
}
