import XCTest
@testable import Learning

final class CollocationChoiceTests: XCTestCase {
    func testMakeAMistakeInASentence() throws {
        let choice = try XCTUnwrap(CollocationChoice.find(in: "I made a big mistake at work today."))
        XCTAssertEqual(choice.pair, .makeDo)
        XCTAssertEqual(choice.answer, "made")
        XCTAssertEqual(choice.distractor, "did")
        XCTAssertEqual(choice.before, "I ")
        XCTAssertEqual(choice.after, " a big mistake at work today.")
        XCTAssertEqual(choice.phrase, "make a big mistake")
        XCTAssertEqual(choice.filled, "I made a big mistake at work today.")
    }

    func testDoTheDishesAndOtherForms() throws {
        let past = try XCTUnwrap(CollocationChoice.find(in: "He did the dishes while I cooked."))
        XCTAssertEqual([past.answer, past.distractor, past.phrase], ["did", "made", "do the dishes"])
        let third = try XCTUnwrap(CollocationChoice.find(in: "Mia does some gardening every Saturday morning."))
        XCTAssertEqual([third.answer, third.distractor], ["does", "makes"])
        let ing = try XCTUnwrap(CollocationChoice.find(in: "I hate doing housework on weekends."))
        XCTAssertEqual([ing.answer, ing.distractor], ["doing", "making"])
        let base = try XCTUnwrap(CollocationChoice.find(in: "Everyone makes mistakes."))
        XCTAssertEqual([base.answer, base.distractor, base.phrase], ["makes", "does", "make mistakes"])
    }

    /// "made" is past or participle: after a "have" the other option is "done", not "did".
    func testParticipleAfterHave() throws {
        XCTAssertEqual(CollocationChoice.find(in: "Have you ever made a decision so fast?")?.distractor, "done")
        XCTAssertEqual(CollocationChoice.find(in: "I've made a mistake in my email.")?.distractor, "done")
        XCTAssertEqual(CollocationChoice.find(in: "Sorry, I made a mistake.")?.distractor, "did")
        let done = try XCTUnwrap(CollocationChoice.find(in: "Have you done your homework yet?"))
        XCTAssertEqual([done.answer, done.distractor, done.phrase], ["done", "made", "do your homework"])
    }

    /// The options keep the sentence's capital, and the blank may come first.
    func testCapitalIsKept() throws {
        let choice = try XCTUnwrap(CollocationChoice.find(in: "Make sure you lock the door."))
        XCTAssertEqual(choice.answer, "Make")
        XCTAssertEqual(choice.distractor, "Do")
        XCTAssertEqual(choice.before, "")
        XCTAssertEqual(choice.phrase, "make sure")
    }

    func testSayAndTell() throws {
        let said = try XCTUnwrap(CollocationChoice.find(in: "The nurse smiled and said hello."))
        XCTAssertEqual(said.pair, .sayTell)
        XCTAssertEqual([said.answer, said.distractor, said.phrase], ["said", "told", "say hello"])
        let told = try XCTUnwrap(CollocationChoice.find(in: "He told us a funny story."))
        XCTAssertEqual([told.answer, told.distractor, told.phrase], ["told", "said", "tell us a funny story"])
        XCTAssertEqual(CollocationChoice.find(in: "Please tell me the truth.")?.distractor, "say")
        XCTAssertEqual(CollocationChoice.find(in: "Jonas called his brother to say sorry.")?.distractor, "tell")
    }

    /// "Did" and "Do" that ask are no "do the shopping" or "do exercise".
    func testAskingDoIsNotUsed() {
        XCTAssertNil(CollocationChoice.find(in: "Did the shopping take long?"))
        XCTAssertNil(CollocationChoice.find(in: "Why did the shopping take so long?"))
        XCTAssertNil(CollocationChoice.find(in: "Do you exercise every day?"))
        XCTAssertNotNil(CollocationChoice.find(in: "Did you do your homework?"))
        XCTAssertEqual(CollocationChoice.find(in: "Did you do your homework?")?.answer, "do")
        XCTAssertEqual(CollocationChoice.find(in: "Do your homework before dinner.")?.answer, "Do")
    }

    /// The other option must be wrong: words that take both verbs, or that start a longer noun,
    /// give no question.
    func testWordsThatTakeBothVerbsAreNotUsed() {
        XCTAssertNil(CollocationChoice.find(in: "We did a puzzle together."))
        XCTAssertNil(CollocationChoice.find(in: "Mia did a cooking course last year."))
        XCTAssertNil(CollocationChoice.find(in: "Let's make lunch at home."))
        XCTAssertNil(CollocationChoice.find(in: "I made a shopping list."))
        XCTAssertNil(CollocationChoice.find(in: "Did you sleep well?"))
        XCTAssertNil(CollocationChoice.find(in: "I told no one about it."))
    }

    /// The phrase ends at punctuation, and at most four small words stand between.
    func testPunctuationAndDistanceEndThePhrase() {
        XCTAssertNil(CollocationChoice.find(in: "What did you make, a mistake?"))
        XCTAssertNotNil(CollocationChoice.find(in: "We made a lot of progress."))
        XCTAssertNil(CollocationChoice.find(in: "We made the very big and serious mistake."))
    }

    /// A card's collocation: the verb must come first, and a placeholder makes no question.
    func testCollocations() throws {
        let choice = try XCTUnwrap(CollocationChoice.find(in: "make a mistake", verbFirst: true))
        XCTAssertEqual([choice.answer, choice.distractor, choice.before, choice.after], ["make", "do", "", " a mistake"])
        XCTAssertEqual(CollocationChoice.find(in: "do the laundry", verbFirst: true)?.distractor, "make")
        XCTAssertNil(CollocationChoice.find(in: "make sb angry", verbFirst: true))
        XCTAssertNil(CollocationChoice.find(in: "promise to do something", verbFirst: true))
        XCTAssertNil(CollocationChoice.find(in: "kiss and make up", verbFirst: true))
        XCTAssertNil(CollocationChoice.find(in: "how do you say it", verbFirst: true))
    }

    /// The punctuation before the verb stays in front of the blank.
    func testTextAroundTheBlankIsExact() throws {
        let choice = try XCTUnwrap(CollocationChoice.find(in: "Okay, “make sure” you call."))
        XCTAssertEqual(choice.before, "Okay, “")
        XCTAssertEqual(choice.after, " sure” you call.")
        XCTAssertEqual(choice.filled, "Okay, “make sure” you call.")
    }

    func testOptionsHoldBothVerbsAndMoveTheAnswer() throws {
        let choice = try XCTUnwrap(CollocationChoice.find(in: "Sorry, I made a mistake."))
        for seed in 0..<20 {
            let first = choice.options(seed: seed)
            XCTAssertEqual(Set(first), ["made", "did"])
            XCTAssertEqual(first, choice.options(seed: seed))
            XCTAssertNotEqual(first.firstIndex(of: "made"), choice.options(seed: seed, attempt: 1).firstIndex(of: "made"))
        }
    }

    /// A word that goes with both verbs of a pair would make both options right.
    func testPartnerListsDoNotOverlapWithinAPair() {
        let partners = CollocationChoice.partners
        XCTAssertTrue(partners["make", default: []].isDisjoint(with: partners["do", default: []]))
        XCTAssertTrue(partners["say", default: []].isDisjoint(with: partners["tell", default: []]))
    }

    /// "Türkçede ikisine de yapmak deriz" holds for "hata yapmak", not for "arkadaş edinmek".
    func testTurkishVerbIsSharedOnlyForSomePartners() throws {
        XCTAssertEqual(CollocationChoice.find(in: "Sorry, I made a mistake.")?.partner, "mistake")
        XCTAssertEqual(CollocationChoice.find(in: "Sorry, I made a mistake.")?.sharesTurkishVerb, true)
        XCTAssertEqual(CollocationChoice.find(in: "I do my homework after dinner.")?.sharesTurkishVerb, true)
        XCTAssertEqual(CollocationChoice.find(in: "Please tell me the truth.")?.sharesTurkishVerb, true)
        XCTAssertEqual(CollocationChoice.find(in: "Children make friends quickly.")?.sharesTurkishVerb, false)
        XCTAssertEqual(CollocationChoice.find(in: "He told us a funny story.")?.sharesTurkishVerb, false)
        XCTAssertEqual(CollocationChoice.find(in: "Jonas called his brother to say sorry.")?.sharesTurkishVerb, false)
        XCTAssertEqual(CollocationChoice.find(in: "Make sure you lock the door.")?.sharesTurkishVerb, false)
        XCTAssertTrue(CollocationChoice.oneTurkishVerb.isSubset(of: CollocationChoice.partners.values.reduce(Set<String>()) { $0.union($1) }))
    }

    /// "make fun" is "make fun of".
    func testFunGoesOnWithOf() {
        XCTAssertEqual(CollocationChoice.find(in: "The kids made fun of Emre's big hat.")?.phrase, "make fun of")
        XCTAssertEqual(CollocationChoice.find(in: "Don't make fun!")?.phrase, "make fun")
    }

    /// Only a "have" right before the verb (or two small words before it) asks for the participle.
    func testAHaveFurtherBackIsNoParticiple() {
        XCTAssertEqual(CollocationChoice.find(in: "We had lunch and made a reservation.")?.distractor, "did")
        XCTAssertEqual(CollocationChoice.find(in: "Maria's brother made a mess.")?.distractor, "did")
        XCTAssertEqual(CollocationChoice.find(in: "She has already made a decision.")?.distractor, "done")
        XCTAssertEqual(CollocationChoice.find(in: "They haven't made a reservation.")?.distractor, "done")
    }

    /// "say no one" or "say no more" is no "say no".
    func testNoBeforeOneOrMoreIsNoPartner() {
        XCTAssertNil(CollocationChoice.find(in: "They say no one knows the answer."))
        XCTAssertNil(CollocationChoice.find(in: "Say no more."))
        XCTAssertEqual(CollocationChoice.find(in: "It is hard to say no.")?.phrase, "say no")
    }
}
