import XCTest
import CoreModels
import Learning

final class WordLinksTests: XCTestCase {
    private func word(_ id: Int, _ lemma: String, _ pos: String = "v", gloss: String? = nil, confusables: [Int]? = nil) -> WidgetWord {
        return WidgetWord(
            id: id, lemma: lemma, pos: pos, level: "A2", defMicro: "m", defShort: "s", exampleEN: "e",
            glossTR: gloss, confusableIDs: confusables
        )
    }

    private func index(_ words: [WidgetWord]) -> [Int: WidgetWord] {
        return Dictionary(uniqueKeysWithValues: words.map { ($0.id, $0) })
    }

    /// borrow ↔ lend: each page links to the other.
    func testPairLinksBothWays() {
        let borrow = word(52, "borrow", gloss: "ödünç almak", confusables: [172])
        let lend = word(172, "lend", gloss: "ödünç vermek", confusables: [52])
        let words = index([borrow, lend])
        XCTAssertEqual(WordLinks.confusables(of: borrow, in: words).map { $0.id }, [172])
        XCTAssertEqual(WordLinks.confusables(of: lend, in: words).map { $0.id }, [52])
    }

    /// "wear" → "put on" has two senses; the one that shares "giymek" stays.
    func testSenseSharingTheMeaningIsKept() {
        let wear = word(1, "wear", gloss: "giymek", confusables: [2, 3])
        let putOnClothes = word(2, "put on", "phv", gloss: "giymek")
        let putOnMusic = word(3, "put on", "phv", gloss: "açmak")
        let found = WordLinks.confusables(of: wear, in: index([wear, putOnClothes, putOnMusic]))
        XCTAssertEqual(found.map { $0.id }, [2])
    }

    /// "polite" → "kind": no shared Turkish word, so the adjective sense stays, not the noun "tür".
    func testSamePartOfSpeechWhenNoMeaningIsShared() {
        let polite = word(1, "polite", "adj", gloss: "kibar", confusables: [2, 3])
        let kindNoun = word(2, "kind", "n", gloss: "tür")
        let kindAdjective = word(3, "kind", "adj", gloss: "iyi kalpli, nazik")
        let found = WordLinks.confusables(of: polite, in: index([polite, kindNoun, kindAdjective]))
        XCTAssertEqual(found.map { $0.id }, [3])
    }

    /// A helper verb both meanings end in ("etmek") is no shared meaning: the part of speech
    /// decides.
    func testHelperVerbIsNoSharedMeaning() {
        let help = word(1, "help", "v", gloss: "yardım etmek", confusables: [2, 3])
        let checkNoun = word(2, "check", "n", gloss: "kontrol etmek")
        let checkVerb = word(3, "check", "v", gloss: "denetlemek")
        let found = WordLinks.confusables(of: help, in: index([help, checkNoun, checkVerb]))
        XCTAssertEqual(found.map { $0.id }, [3])
    }

    /// Nothing narrows the senses down: all of them stay.
    func testAllSensesWhenNothingNarrows() {
        let a = word(1, "a", "adj", gloss: "bir", confusables: [2, 3])
        let b1 = word(2, "b", "n", gloss: "iki")
        let b2 = word(3, "b", "v", gloss: "üç")
        XCTAssertEqual(WordLinks.confusables(of: a, in: index([a, b1, b2])).map { $0.id }, [2, 3])
    }

    /// Unknown ids, duplicates and the word itself are dropped; partners sort by headword.
    func testMissingDuplicateAndSelfAreDropped() {
        let nervous = word(10, "nervous", "adj", gloss: "gergin", confusables: [12, 10, 99, 11, 12])
        let excited = word(11, "excited", "adj", gloss: "heyecanlı")
        let angry = word(12, "angry", "adj", gloss: "kızgın")
        let found = WordLinks.confusables(of: nervous, in: index([nervous, excited, angry]))
        XCTAssertEqual(found.map { $0.lemma }, ["angry", "excited"])
    }

    func testNoConfusablesGivesNothing() {
        let breakfast = word(1, "breakfast", "n", gloss: "kahvaltı")
        XCTAssertTrue(WordLinks.confusables(of: breakfast, in: index([breakfast])).isEmpty)
    }

    /// "break": the noun page links to the verb and back; case and spaces do not matter.
    func testOtherSensesOfTheHeadword() {
        let pause = word(474, "break", "n", gloss: "mola")
        let crack = word(692, "Break ", "v", gloss: "kırmak")
        let other = word(1, "breakfast", "n", gloss: "kahvaltı")
        let words = [other, pause, crack]
        XCTAssertEqual(WordLinks.otherSenses(of: pause, in: words).map { $0.id }, [692])
        XCTAssertEqual(WordLinks.otherSenses(of: crack, in: words).map { $0.id }, [474])
        XCTAssertTrue(WordLinks.otherSenses(of: other, in: words).isEmpty)
    }
}
