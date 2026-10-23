import XCTest
import CoreModels

final class CardDetailTests: XCTestCase {
    private func decode(_ json: String) throws -> CardDetail {
        return try JSONDecoder().decode(CardDetail.self, from: Data(json.utf8))
    }

    private let spoon = CardDetail.Quiz(
        cloze: "I eat soup with a ______, not with a fork.", answer: "spoon", distractors: ["knife", "plate", "cup"]
    )

    func testFullCardJSONDecodesTheFieldsTheAppShows() throws {
        // Trimmed copy of a real card as build_db stores it in `card.json` (unused fields kept
        // to make sure they are ignored).
        let json = """
        {"id":"en.breakfast.n.1","lemma":"breakfast","type":"word","pos":"n","sense_no":1,
         "def":{"micro":"first meal of the day","short":"the first meal of the day","long":"The first meal."},
         "examples":[
           {"en":"I usually have breakfast at seven.","tr":"Genellikle yedide kahvaltı yaparım.","register":"neutral","focus":"breakfast"},
           {"en":"Breakfast is included.","tr":null,"register":"neutral","focus":"Breakfast"}],
         "collocations":["have breakfast","skip breakfast"],
         "etymology":{"text":"break + fast","origin":"English","confidence":"high"},
         "l1":{"tr":{"gloss":"kahvaltı","alt":["sabah kahvaltısı"],"equivalence":"full","false_friend":null,
           "note":"Öğün adlarından önce 'the' gelmez.",
           "mistakes":[{"wrong":"I did breakfast.","right":"I had breakfast.","why":"'have breakfast' denir."}],
           "mnemonic":"Break + fast"}},
         "meta":{"status":"draft","qa_flags":[]}}
        """
        let detail = try decode(json)
        XCTAssertEqual(detail.examples, [
            CardDetail.Example(en: "I usually have breakfast at seven.", tr: "Genellikle yedide kahvaltı yaparım."),
            CardDetail.Example(en: "Breakfast is included.", tr: nil),
        ])
        XCTAssertEqual(detail.collocations, ["have breakfast", "skip breakfast"])
        XCTAssertEqual(detail.glossAlternatives, ["sabah kahvaltısı"])
        XCTAssertEqual(detail.noteTR, "Öğün adlarından önce 'the' gelmez.")
        XCTAssertEqual(detail.mistakes, [CardDetail.Mistake(wrong: "I did breakfast.", right: "I had breakfast.", why: "'have breakfast' denir.")])
        XCTAssertNil(detail.falseFriend)
        XCTAssertEqual(detail.mnemonicTR, "Break + fast")
    }

    func testFalseFriendUsesSnakeCaseKeys() throws {
        let json = """
        {"l1":{"tr":{"false_friend":{"tr_word":"aktüel","tr_means":"güncel","en_for_that":"current"}}}}
        """
        let detail = try decode(json)
        XCTAssertEqual(detail.falseFriend, CardDetail.FalseFriend(trWord: "aktüel", trMeans: "güncel", enForThat: "current"))
    }

    func testQuizDecodesAndMixesOptionsStably() throws {
        let json = """
        {"quiz":{"cloze":"I eat soup with a ______, not with a fork.","answer":"spoon","distractors":["knife","plate","cup"]}}
        """
        let quiz = try XCTUnwrap(try decode(json).quiz)
        XCTAssertEqual(quiz.answer, "spoon")
        XCTAssertEqual(quiz.distractors, ["knife", "plate", "cup"])

        let options = quiz.options(seed: 2)
        XCTAssertEqual(Set(options), ["spoon", "knife", "plate", "cup"])
        XCTAssertEqual(quiz.options(seed: 2), options, "same seed, same order")
        // Across many seeds the answer must not sit in one fixed position.
        let positions = Set((1...40).map { quiz.options(seed: $0).firstIndex(of: "spoon") ?? -1 })
        XCTAssertGreaterThan(positions.count, 2)
    }

    func testQuizOptionsDropDuplicates() {
        let quiz = CardDetail.Quiz(cloze: "a ______", answer: "x", distractors: ["y", "x", "y"])
        XCTAssertEqual(Set(quiz.options(seed: 7)), ["x", "y"])
        XCTAssertEqual(quiz.options(seed: 7).count, 2)
    }

    func testQuizOptionsWithoutAnAttemptKeepTheEarlierOrder() {
        // The orders `options(seed:)` gave before it took an attempt (the snapshot cases).
        XCTAssertEqual(spoon.options(seed: 2), ["knife", "cup", "plate", "spoon"])
        let lyrics = CardDetail.Quiz(cloze: "the ______", answer: "lyrics", distractors: ["tickets", "trailers", "playlists"])
        XCTAssertEqual(lyrics.options(seed: 452), ["playlists", "trailers", "tickets", "lyrics"])
        for seed in -5...50 {
            XCTAssertEqual(spoon.options(seed: seed), spoon.options(seed: seed, attempt: 0))
        }
    }

    func testQuizOptionsAreStableWithinAnAttempt() {
        for seed in [2, 452, -7] {
            for attempt in 0..<6 {
                let options = spoon.options(seed: seed, attempt: attempt)
                XCTAssertEqual(options.count, 4)
                XCTAssertEqual(Set(options), ["spoon", "knife", "plate", "cup"])
                XCTAssertEqual(spoon.options(seed: seed, attempt: attempt), options, "same seed and attempt, same order")
            }
        }
        // Pinned, so a change of the mixing (or a per-process hash) shows up here: every device
        // must give the same order.
        XCTAssertEqual(spoon.options(seed: 2, attempt: 1), ["plate", "knife", "spoon", "cup"])
    }

    func testQuizAnswerMovesOnEveryNextAttempt() {
        for seed in 1...200 {
            for attempt in 0..<20 {
                let now = spoon.options(seed: seed, attempt: attempt).firstIndex(of: "spoon")
                let next = spoon.options(seed: seed, attempt: attempt + 1).firstIndex(of: "spoon")
                XCTAssertNotEqual(now, next, "seed \(seed), attempt \(attempt)")
            }
        }
    }

    func testQuizAnswerIsSpreadOverThePlaces() {
        // One word over time: any four attempts in a row put the answer once in each place.
        for seed in 1...200 {
            for start in 0..<12 {
                let places = (start..<start + 4).compactMap { spoon.options(seed: seed, attempt: $0).firstIndex(of: "spoon") }
                XCTAssertEqual(places.sorted(), [0, 1, 2, 3], "seed \(seed), attempts from \(start)")
            }
        }
        // Many words at the same attempt: about a quarter in each place (100 of 400 expected).
        for attempt in 0..<4 {
            var counts = [0, 0, 0, 0]
            for seed in 1...400 {
                if let place = spoon.options(seed: seed, attempt: attempt).firstIndex(of: "spoon") {
                    counts[place] += 1
                }
            }
            for count in counts {
                XCTAssertGreaterThan(count, 60, "attempt \(attempt): \(counts)")
                XCTAssertLessThan(count, 140, "attempt \(attempt): \(counts)")
            }
        }
    }

    func testQuizDistractorsAreMixedAnewToo() {
        for seed in [2, 452] {
            let orders = Set((0..<24).map { attempt in
                spoon.options(seed: seed, attempt: attempt).filter { $0 != "spoon" }
            })
            XCTAssertGreaterThan(orders.count, 2, "seed \(seed)")
        }
    }

    func testQuizOptionsWithFewOptions() {
        // Two options (after dropping duplicates): the answer switches sides every attempt.
        let two = CardDetail.Quiz(cloze: "a ______", answer: "x", distractors: ["y", "x", "y"])
        XCTAssertEqual(Set(two.options(seed: 7, attempt: 3)), ["x", "y"])
        XCTAssertNotEqual(two.options(seed: 7, attempt: 0), two.options(seed: 7, attempt: 1))
        XCTAssertEqual(two.options(seed: 7, attempt: 0), two.options(seed: 7, attempt: 2))
        let one = CardDetail.Quiz(cloze: "a ______", answer: "x", distractors: ["x"])
        XCTAssertEqual(one.options(seed: 3, attempt: 5), ["x"])
        // The app never passes a negative attempt; it still gives every option once.
        XCTAssertEqual(Set(spoon.options(seed: 5, attempt: -3)), ["spoon", "knife", "plate", "cup"])
        XCTAssertEqual(spoon.options(seed: 5, attempt: -3).count, 4)
    }

    func testFilledSentencePutsTheAnswerInTheBlank() {
        let middle = CardDetail.Quiz(cloze: "We usually eat ______ at 7 a.m.", answer: "breakfast", distractors: ["x"])
        XCTAssertEqual(middle.filledSentence, "We usually eat breakfast at 7 a.m.")
        let start = CardDetail.Quiz(cloze: "___ is my favourite meal.", answer: "breakfast", distractors: ["x"])
        XCTAssertEqual(start.filledSentence, "Breakfast is my favourite meal.")
        let noBlank = CardDetail.Quiz(cloze: "No blank here.", answer: "x", distractors: ["y"])
        XCTAssertEqual(noBlank.filledSentence, "No blank here.")
    }

    func testShortestExampleContainingTheWord() {
        let shorterLater = CardDetail(examples: [
            CardDetail.Example(en: "Can I borrow your pen for a minute, please?"),
            CardDetail.Example(en: "She borrowed my car."),
            CardDetail.Example(en: "We borrow books."),
        ])
        XCTAssertEqual(shorterLater.shortestExample(containing: "borrow"), "We borrow books.")

        // The first example does not use the word: a later one that does is chosen.
        let firstWithout = CardDetail(examples: [
            CardDetail.Example(en: "Hi."),
            CardDetail.Example(en: "I look forward to the trip."),
        ])
        XCTAssertEqual(firstWithout.shortestExample(containing: "look forward to"), "I look forward to the trip.")

        // Equal length: the earlier sentence wins.
        let tie = CardDetail(examples: [
            CardDetail.Example(en: "I lend pens."),
            CardDetail.Example(en: "I lend cash."),
        ])
        XCTAssertEqual(tie.shortestExample(containing: "lend"), "I lend pens.")

        let none = CardDetail(examples: [CardDetail.Example(en: "My teeth hurt.")])
        XCTAssertNil(none.shortestExample(containing: "tooth"))
        XCTAssertNil(CardDetail().shortestExample(containing: "tooth"))
    }

    func testLemmaMatchFindsWholeWordsWithEndings() {
        let sentence = "She borrowed my car."
        let found = LemmaMatch.range(of: "borrow", in: sentence)
        XCTAssertEqual(found.map { String(sentence[$0]) }, "borrowed")
        XCTAssertNil(LemmaMatch.range(of: "row", in: sentence), "not inside another word")
        XCTAssertNil(LemmaMatch.range(of: "", in: sentence))
    }

    func testLemmaMatchFindsPhraseWithoutBe() {
        let sentence = "I'm fed up with this rain."
        XCTAssertEqual(LemmaMatch.range(of: "be fed up with", in: sentence).map { String(sentence[$0]) }, "fed up with")
        XCTAssertNil(LemmaMatch.range(of: "be late", in: "The bus was on time."))
    }

    func testMissingFieldsDecodeAsEmpty() throws {
        XCTAssertEqual(try decode("{}"), CardDetail())
        XCTAssertEqual(try decode(#"{"l1":{"en":{"alt":["x"]}}}"#), CardDetail())
    }
}
