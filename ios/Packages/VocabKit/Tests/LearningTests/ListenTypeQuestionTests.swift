import XCTest
import CoreModels
@testable import Learning

/// "Dinle ve seç" and "İngilizcesini yaz" (docs/tasarim/ogrenme_ilkeleri.md 2.4, "Dinle ve seç,
/// Yaz"): when they come, their options, and how a typed answer is compared.
final class ListenTypeQuestionTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let day: TimeInterval = 86_400

    private func learning(_ id: Int, box: Int, reviews: Int) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = box
        p.reviews = reviews
        return p
    }

    private func kind(_ p: WordProgress?, cloze: Bool = true, listen: Bool = true, type: Bool = true) -> QuestionKind {
        return ReviewPlanner.questionKind(for: p, hasCloze: cloze, canListen: listen, canType: type)
    }

    // MARK: which question

    func testBoxesTwoAndThreeTakeTurnsByTheReviewCount() {
        for box in 2...3 {
            for reviews in [1, 3, 5, 7] {
                XCTAssertEqual(kind(learning(1, box: box, reviews: reviews)), .cloze, "box \(box), reviews \(reviews)")
            }
            // Even counts: one of the new kinds, by the word's id, and the other one next time.
            XCTAssertEqual(kind(learning(1, box: box, reviews: 2)), .listen)
            XCTAssertEqual(kind(learning(1, box: box, reviews: 4)), .typing)
            XCTAssertEqual(kind(learning(1, box: box, reviews: 6)), .listen)
            XCTAssertEqual(kind(learning(2, box: box, reviews: 2)), .typing)
            XCTAssertEqual(kind(learning(2, box: box, reviews: 4)), .listen)
        }
    }

    func testBothNewKindsComeAboutAsOften() {
        let kinds = (1...100).map { kind(learning($0, box: 2, reviews: 2)) }
        XCTAssertEqual(kinds.filter { $0 == .listen }.count, 50)
        XCTAssertEqual(kinds.filter { $0 == .typing }.count, 50)
    }

    func testTheStraightWayUp() {
        // "Hatırla" right on the first try, then every review right.
        var p = Leitner.review(WordProgress(wordID: 7), grade: .good, at: now)
        var kinds: [QuestionKind] = []
        var at = now
        while p.state == .learning && p.box <= 4 {
            kinds.append(kind(p))
            at = at.addingTimeInterval(20 * day)
            p = Leitner.review(p, grade: .good, at: at)
        }
        XCTAssertEqual(kinds.count, 4)
        XCTAssertEqual(kinds[0], .cloze, "box 1")
        XCTAssertTrue([QuestionKind.listen, .typing].contains(kinds[1]), "box 2: \(kinds[1])")
        XCTAssertEqual(kinds[2], .cloze, "box 3")
        XCTAssertEqual(kinds[3], .recall, "box 4")
    }

    func testTwoQuestionsInARowInBoxesTwoAndThreeAreNeverTheSameKind() {
        for id in 1...4 {
            for grades in [[ReviewGrade.hard, .hard, .hard, .hard, .hard], [.hard, .good, .hard, .hard], [.good, .hard, .hard, .hard]] {
                var p = learning(id, box: 2, reviews: 2)
                var at = now
                var kinds = [kind(p)]
                for grade in grades {
                    at = at.addingTimeInterval(20 * day)
                    p = Leitner.review(p, grade: grade, at: at)
                    guard ReviewPlanner.mixedQuestionBoxes.contains(p.box), p.state == .learning else {
                        break
                    }
                    kinds.append(kind(p))
                }
                XCTAssertGreaterThan(kinds.count, 2)
                for (a, b) in zip(kinds, kinds.dropFirst()) {
                    XCTAssertNotEqual(a, b, "word \(id), \(grades): \(kinds)")
                }
                XCTAssertTrue(kinds.contains(.cloze))
            }
        }
    }

    func testAKindTheWordCannotHaveGivesWayToTheNextInTurn() {
        let listenTurn = learning(1, box: 2, reviews: 2)
        XCTAssertEqual(kind(listenTurn, listen: false), .typing, "sound off or VoiceOver on")
        XCTAssertEqual(kind(listenTurn, listen: false, type: false), .cloze)
        XCTAssertEqual(kind(listenTurn, cloze: false, listen: false, type: false), .recall)
        let typingTurn = learning(2, box: 3, reviews: 2)
        XCTAssertEqual(kind(typingTurn, type: false), .listen, "a long phrase or no meaning")
        // The fill-in-the-blank turn without one (a user's own word): a new kind instead of recall.
        let clozeTurn = learning(1, box: 2, reviews: 3)
        XCTAssertEqual(kind(clozeTurn, cloze: false), .listen)
        XCTAssertEqual(kind(clozeTurn, cloze: false, listen: false), .typing)
        XCTAssertEqual(kind(clozeTurn, cloze: false, listen: false, type: false), .recall)
    }

    func testOtherBoxesKeepTheirQuestion() {
        XCTAssertEqual(kind(nil), .cloze)
        XCTAssertEqual(kind(learning(1, box: 1, reviews: 2)), .cloze, "box 1")
        XCTAssertEqual(kind(learning(1, box: 1, reviews: 2), cloze: false), .recall, "box 1 without a cloze")
        for box in 4...5 {
            XCTAssertEqual(kind(learning(1, box: box, reviews: 2)), .recall, "box \(box)")
        }
        var known = learning(1, box: 3, reviews: 2)
        known.state = .known
        XCTAssertEqual(kind(known), .recall, "refresher")
        XCTAssertEqual(kind(Leitner.markKnown(WordProgress(wordID: 1), at: now)), .recall, "Biliyorum check")
        // The callers that do not know the new kinds get the old rule.
        XCTAssertEqual(ReviewPlanner.questionKind(for: learning(1, box: 2, reviews: 2), hasCloze: true), .cloze)
        XCTAssertEqual(ReviewPlanner.questionKind(for: learning(1, box: 2, reviews: 2), hasCloze: false), .recall)
    }

    // MARK: "Dinle ve seç"

    private func spoken(_ id: Int, _ lemma: String, _ ipa: String?, gloss: String? = nil, confusables: [Int]? = nil) -> WidgetWord {
        return WidgetWord(
            id: id, lemma: lemma, pos: "n", level: "A2", ipaUS: ipa,
            defMicro: "m", defShort: "s", exampleEN: "e", glossTR: gloss, confusableIDs: confusables
        )
    }

    private lazy var borrow = spoken(1, "borrow", "/ˈbɑroʊ/", gloss: "ödünç almak", confusables: [2])
    private lazy var sounds: [WidgetWord] = [
        borrow,
        spoken(2, "lend", "/lɛnd/", gloss: "ödünç vermek", confusables: [1]),
        spoken(3, "meet", "/mit/", gloss: "buluşmak"),
        spoken(4, "meat", "/miːt/", gloss: "et"),
        // One sound away from borrow: only when nothing else is left.
        spoken(5, "sorrow", "/ˈsɑroʊ/", gloss: "üzüntü"),
        spoken(6, "barrel", "/ˈbærəl/", gloss: "fıçı"),
        spoken(7, "arrow", "/ˈæroʊ/", gloss: "ok"),
        spoken(8, "tomorrow", "/təˈmɑroʊ/", gloss: "yarın"),
        // A user's own word has no pronunciation.
        spoken(9, "phone", nil, gloss: "telefon"),
        // Another sense of borrow.
        spoken(10, "Borrow", "/ˈbɑroʊ/", gloss: "alıntı yapmak"),
    ]

    func testListeningOptionsTakeASettledPartnerFirstThenSimilarSounds() throws {
        let question = try XCTUnwrap(ReviewPlanner.listenQuestion(for: borrow, attempt: 0, candidates: sounds))
        XCTAssertEqual(question.answer, "borrow")
        XCTAssertEqual(question.options.count, ReviewPlanner.choiceCount)
        XCTAssertEqual(Set(question.options).count, question.options.count)
        XCTAssertTrue(question.options.contains("borrow"))
        XCTAssertTrue(question.options.contains("lend"), "the confusable partner")
        XCTAssertTrue(question.options.contains("arrow"), "two sounds away: the closest allowed")
        XCTAssertFalse(question.options.contains("sorrow"), "one sound away comes last")
        XCTAssertFalse(question.options.contains("phone"), "no pronunciation to compare")
        XCTAssertFalse(question.options.contains("Borrow"), "the same headword")
        XCTAssertEqual(question.meanings["lend"], "ödünç vermek")
        XCTAssertNil(question.meanings["borrow"])
    }

    func testAPartnerNotSettledIsNeverAnOption() throws {
        let question = try XCTUnwrap(ReviewPlanner.listenQuestion(for: borrow, attempt: 0, candidates: sounds, excludedIDs: [2]))
        XCTAssertFalse(question.options.contains("lend"))
        XCTAssertEqual(question.options.count, ReviewPlanner.choiceCount)
    }

    func testWordsThatSoundTheSameAreNeverOptionsTogether() throws {
        let meet = sounds[2]
        let forMeet = try XCTUnwrap(ReviewPlanner.listenQuestion(for: meet, attempt: 0, candidates: sounds))
        XCTAssertFalse(forMeet.options.contains("meat"), "meet and meat sound the same")

        let bird = spoken(20, "bird", "/bɝd/")
        let pool = [
            bird,
            spoken(21, "board", "/bɔrd/"),
            spoken(22, "bored", "/bɔːrd/"),
            spoken(23, "bed", "/bɛd/"),
            spoken(24, "bad", "/bæd/"),
            spoken(25, "bud", "/bʌd/"),
        ]
        for attempt in 0..<5 {
            let question = try XCTUnwrap(ReviewPlanner.listenQuestion(for: bird, attempt: attempt, candidates: pool))
            XCTAssertEqual(question.options.count, ReviewPlanner.choiceCount)
            XCTAssertEqual(question.options.filter { ["board", "bored"].contains($0) }.count, 1, "\(question.options)")
        }
    }

    func testNoListeningWithoutAPronunciationOrEnoughOptions() {
        XCTAssertNil(ReviewPlanner.listenQuestion(for: sounds[8], attempt: 0, candidates: sounds), "no IPA")
        XCTAssertNil(ReviewPlanner.listenQuestion(for: borrow, attempt: 0, candidates: Array(sounds.prefix(2))), "one wrong option")
        XCTAssertNotNil(ReviewPlanner.listenQuestion(for: borrow, attempt: 0, candidates: Array(sounds.prefix(3))), "three options are enough")
    }

    func testTheAnswerMovesFromOneReviewToTheNext() throws {
        var places: [Int] = []
        for attempt in 1...8 {
            let question = try XCTUnwrap(ReviewPlanner.listenQuestion(for: borrow, attempt: attempt, candidates: sounds))
            places.append(try XCTUnwrap(question.options.firstIndex(of: "borrow")))
        }
        for (a, b) in zip(places, places.dropFirst()) {
            XCTAssertNotEqual(a, b, "\(places)")
        }
    }

    func testSoundKeysAndEditDistance() {
        XCTAssertEqual(ReviewPlanner.soundKey("/ˈbɔːrd/"), ReviewPlanner.soundKey("/bɔrd/"))
        XCTAssertEqual(ReviewPlanner.soundKey("/ˈbɔːrd/"), "bɔrd")
        XCTAssertEqual(ReviewPlanner.soundKey(nil), "")
        XCTAssertEqual(EditDistance.between(Array("borrow"), Array("borow")), 1)
        XCTAssertEqual(EditDistance.between(Array("borrow"), Array("borrwo")), 1, "two swapped neighbours")
        XCTAssertEqual(EditDistance.between(Array("kitten"), Array("sitting")), 3)
        XCTAssertEqual(EditDistance.between(Array(""), Array("abc")), 3)
        XCTAssertEqual(EditDistance.between(Array("abc"), Array("abc")), 0)
        XCTAssertEqual(EditDistance.between(Array("ab"), Array("ba")), 1)
    }

    // MARK: "İngilizcesini yaz"

    private func meaning(_ id: Int, _ lemma: String, _ gloss: String?, pos: String = "v") -> WidgetWord {
        return WidgetWord(id: id, lemma: lemma, pos: pos, level: "A2", defMicro: "m", defShort: "s", exampleEN: "e", glossTR: gloss)
    }

    private lazy var glossed: [WidgetWord] = [
        meaning(1, "borrow", "ödünç almak"),
        meaning(2, "lend", "ödünç vermek"),
        meaning(3, "say", "söylemek, demek"),
        meaning(4, "tell", "söylemek, anlatmak"),
        meaning(5, "spoon", "kaşık", pos: "n"),
        meaning(6, "I'd love to", "çok isterim", pos: "phr"),
        meaning(7, "second-hand", "ikinci el", pos: "adj"),
        meaning(8, "Could you tell me the way to", "… yolunu tarif eder misiniz?", pos: "phr"),
        meaning(9, "dinner", "akşam yemeği", pos: "n"),
        meaning(10, "cat", "kedi", pos: "n"),
        meaning(11, "then", "sonra", pos: "adv"),
        meaning(12, "than", "-den daha", pos: "adv"),
        meaning(13, "information", "bilgi", pos: "n"),
        meaning(14, "look after", "bakmak, ilgilenmek", pos: "phv"),
        meaning(15, "whatever", nil, pos: "pron"),
    ]

    private func typing(_ index: Int, example: String? = nil) throws -> TypeQuestion {
        return try XCTUnwrap(ReviewPlanner.typeQuestion(for: glossed[index], candidates: glossed, exampleTranslation: example))
    }

    func testTheWordIsRightWhateverTheCaseSpacesAndEndPunctuation() throws {
        let borrow = try typing(0)
        XCTAssertEqual(borrow.prompt, "ödünç almak")
        XCTAssertEqual(borrow.answer, "borrow")
        for typed in ["borrow", "Borrow", "  BORROW ", "borrow.", "to borrow", "To   borrow"] {
            XCTAssertEqual(borrow.check(typed), .right, typed)
        }
        let spoon = try typing(4)
        for typed in ["a spoon", "The spoon", "an spoon"] {
            XCTAssertEqual(spoon.check(typed), .right, "an article before a noun: \(typed)")
        }
        XCTAssertEqual(try typing(9).check("Cat"), .right)
    }

    func testATurkishKeyboardIsNeverAMistake() throws {
        let dinner = try typing(8)
        for typed in ["dınner", "DİNNER", "Dinner", "dınnér"] {
            XCTAssertEqual(dinner.check(typed), .right, typed)
        }
        let love = try typing(5)
        for typed in ["I'd love to", "İ'd love to", "ı'd love to", "I’d love to", "Id love to", "i'd LOVE to!"] {
            XCTAssertEqual(love.check(typed), .right, typed)
        }
        let secondHand = try typing(6)
        for typed in ["second-hand", "second hand", "Second–hand"] {
            XCTAssertEqual(secondHand.check(typed), .right, typed)
        }
        XCTAssertEqual(TypeQuestion.key("  İ’d   LOVE-to?! "), "id love to")
    }

    func testASmallSpellingMistakeIsAlmost() throws {
        let borrow = try typing(0)
        for typed in ["borow", "borrwo", "barrow", "to borow"] {
            XCTAssertEqual(borrow.check(typed), .almost, typed)
        }
        XCTAssertEqual(borrow.check("brrw"), .wrong, "two mistakes in six letters")
        XCTAssertEqual(try typing(4).check("spoons"), .almost)
        XCTAssertEqual(try typing(6).check("secondhand"), .almost)
        XCTAssertEqual(try typing(13).check("lookafter"), .almost)
        XCTAssertEqual(try typing(13).check("to look after"), .right)
        let information = try typing(12)
        XCTAssertEqual(information.check("infromation"), .almost)
        XCTAssertEqual(information.check("infomatoin"), .almost, "two mistakes from eight letters on")
        XCTAssertEqual(information.check("infrmatn"), .wrong)
        // In three letters one change is another word (cat, car, cut).
        XCTAssertEqual(try typing(9).check("cta"), .wrong)
        XCTAssertEqual(try typing(9).check("car"), .wrong)
    }

    func testAnotherCardsWordIsWrongButOneWithTheSameMeaningIsNot() throws {
        let borrow = try typing(0)
        XCTAssertEqual(borrow.check("lend"), .otherWord("lend", meaning: "ödünç vermek"))
        XCTAssertEqual(borrow.check("to lend"), .otherWord("lend", meaning: "ödünç vermek"))
        // One letter away, but a real word: not a spelling mistake.
        XCTAssertEqual(try typing(10).check("than"), .otherWord("than", meaning: "-den daha"))
        let say = try typing(2)
        XCTAssertEqual(say.check("tell"), .sameMeaning("tell"))
        XCTAssertEqual(say.check("to tell"), .sameMeaning("tell"))
        XCTAssertEqual(say.check("say"), .right)
        XCTAssertEqual(borrow.check(""), .wrong)
        XCTAssertEqual(borrow.check("   "), .wrong)
        XCTAssertEqual(borrow.check("xyz"), .wrong)
    }

    func testTheExampleIsShownOnlyWhenAnotherCardMeansTheSame() throws {
        XCTAssertEqual(try typing(2, example: "Ne dediğini duymadım.").context, "Ne dediğini duymadım.")
        XCTAssertNil(try typing(0, example: "Kalemini ödünç alabilir miyim?").context)
        XCTAssertNil(try typing(2).context)
    }

    func testNoTypingForLongPhrasesOrWithoutAMeaning() {
        XCTAssertNil(ReviewPlanner.typeQuestion(for: glossed[7], candidates: glossed), "seven words")
        XCTAssertNil(ReviewPlanner.typeQuestion(for: glossed[14], candidates: glossed), "no Turkish meaning")
        XCTAssertNotNil(ReviewPlanner.typeQuestion(for: glossed[13], candidates: glossed), "look after")
    }

    func testLetterHints() throws {
        let borrow = try typing(0)
        XCTAssertEqual(borrow.letterCount, 6)
        XCTAssertEqual(borrow.maxHints, 3)
        XCTAssertEqual(borrow.hint(letters: 0), "______")
        XCTAssertEqual(borrow.hint(letters: 2), "bo____")
        let lookAfter = try typing(13)
        XCTAssertEqual(lookAfter.maxHints, 4)
        XCTAssertEqual(lookAfter.hint(letters: 3), "loo_ _____")
        let love = try typing(5)
        XCTAssertEqual(love.maxHints, 4)
        XCTAssertEqual(love.hint(letters: 1), "I'_ ____ __")
        XCTAssertEqual(try typing(9).maxHints, 1, "cat")
    }

    func testTypoAllowanceGrowsWithTheWord() {
        XCTAssertEqual(TypeQuestion.typoAllowance(letters: 3), 0)
        XCTAssertEqual(TypeQuestion.typoAllowance(letters: 4), 1)
        XCTAssertEqual(TypeQuestion.typoAllowance(letters: 7), 1)
        XCTAssertEqual(TypeQuestion.typoAllowance(letters: 8), 2)
        XCTAssertEqual(TypeQuestion.typoAllowance(letters: 15), 2)
    }
}
