import XCTest
import Learning

final class SystemCardsTests: XCTestCase {
    /// A slot with its first opening started; `slot.opening` is what RootView passes to `decide`.
    private func opened() -> SystemCardSlot {
        var slot = SystemCardSlot()
        XCTAssertEqual(slot.beginOpening(stillShown: nil), 1)
        return slot
    }

    // MARK: Priority

    func testThePriorityOrderOfDesignNoteTwoTen() {
        XCTAssertEqual(
            SystemCard.allCases.sorted(),
            [.progressRecovered, .remindersPaused, .reminderTime, .widgetTip, .breakStart, .dayEnd]
        )
        // §2.10: the pause note > the time question > "Ara verdin" > the end-of-day card.
        XCTAssertLessThan(SystemCard.remindersPaused, .reminderTime)
        XCTAssertLessThan(SystemCard.reminderTime, .breakStart)
        XCTAssertLessThan(SystemCard.breakStart, .dayEnd)
    }

    func testOnlyTheTwoScreenCardsAreClaimed() {
        XCTAssertEqual(SystemCard.allCases.filter(\.isScreenCard), [.breakStart, .dayEnd])
    }

    func testTheMostImportantSheetWins() {
        var slot = opened()
        let number = slot.opening
        let shown = slot.decide(from: [.widgetTip, .reminderTime, .progressRecovered, .remindersPaused], opening: number)
        XCTAssertEqual(shown, .progressRecovered)
        XCTAssertEqual(slot.current, .progressRecovered)
        XCTAssertTrue(slot.isDecided)
    }

    func testThePauseNoteComesBeforeTheTimeQuestion() {
        var slot = opened()
        let number = slot.opening
        XCTAssertEqual(slot.decide(from: [.reminderTime, .remindersPaused, .widgetTip], opening: number), .remindersPaused)
    }

    func testScreenCardsAreNeverTheSheet() {
        var slot = opened()
        let number = slot.opening
        XCTAssertNil(slot.decide(from: [.breakStart, .dayEnd], opening: number))
        XCTAssertTrue(slot.isDecided)
        XCTAssertNil(slot.current)
        XCTAssertTrue(slot.claim(.dayEnd))
    }

    // MARK: Claims

    func testNoClaimBeforeTheSheetIsDecided() {
        var slot = opened()
        let number = slot.opening
        XCTAssertFalse(slot.claim(.breakStart))
        // The refused claim took nothing: the sheet still comes first.
        XCTAssertEqual(slot.decide(from: [.widgetTip], opening: number), .widgetTip)
        XCTAssertFalse(slot.claim(.breakStart))
    }

    func testAFreeOpeningGoesToTheFirstScreenThatClaims() {
        var slot = opened()
        let number = slot.opening
        XCTAssertNil(slot.decide(from: [], opening: number))
        XCTAssertTrue(slot.claim(.breakStart))
        // Asking again (the screen appears again) keeps it; the other screen waits for the next opening.
        XCTAssertTrue(slot.claim(.breakStart))
        XCTAssertFalse(slot.claim(.dayEnd))
        XCTAssertEqual(slot.current, .breakStart)
    }

    func testTheEndOfDayCardCanComeFirst() {
        var slot = opened()
        let number = slot.opening
        slot.decide(from: [], opening: number)
        XCTAssertTrue(slot.claim(.dayEnd))
        // "Ara verdin" stays only "Başla (10 kelime)" in this opening.
        XCTAssertFalse(slot.claim(.breakStart))
    }

    func testASheetLeavesNothingForTheScreens() {
        for sheet in SystemCard.allCases where !sheet.isScreenCard {
            var slot = opened()
            let number = slot.opening
            XCTAssertEqual(slot.decide(from: [sheet], opening: number), sheet)
            XCTAssertFalse(slot.claim(.breakStart), "\(sheet)")
            XCTAssertFalse(slot.claim(.dayEnd), "\(sheet)")
        }
    }

    func testASheetCardCannotBeClaimed() {
        var slot = opened()
        let number = slot.opening
        slot.decide(from: [], opening: number)
        XCTAssertFalse(slot.claim(.widgetTip))
        XCTAssertNil(slot.current)
        XCTAssertTrue(slot.claim(.breakStart))
    }

    // MARK: Openings

    func testTheSecondStartOfTheSameOpeningIsIgnored() {
        var slot = opened()
        let number = slot.opening
        // The launch task and the first activation both start the opening.
        XCTAssertNil(slot.beginOpening(stillShown: nil))
        XCTAssertEqual(slot.decide(from: [.widgetTip], opening: number), .widgetTip)
        XCTAssertNil(slot.beginOpening(stillShown: .widgetTip))
        XCTAssertEqual(slot.current, .widgetTip)
    }

    func testOneDecisionPerOpening() {
        var slot = opened()
        let number = slot.opening
        XCTAssertNil(slot.decide(from: [], opening: number))
        XCTAssertNil(slot.decide(from: [.progressRecovered], opening: number))
        XCTAssertNil(slot.current)
    }

    func testANewOpeningIsFreeAgain() {
        var slot = opened()
        let first = slot.opening
        slot.decide(from: [], opening: first)
        XCTAssertTrue(slot.claim(.breakStart))
        slot.endOpening()
        XCTAssertFalse(slot.isDecided)
        XCTAssertNil(slot.current)
        XCTAssertFalse(slot.claim(.breakStart), "no claim in the background")

        guard let second = slot.beginOpening(stillShown: nil) else {
            return XCTFail("a new opening must start")
        }
        XCTAssertGreaterThan(second, first)
        slot.decide(from: [], opening: second)
        // The end-of-day card kept for this opening gets it.
        XCTAssertTrue(slot.claim(.dayEnd))
    }

    func testAScreenCardStillShownMustBeClaimedAgain() {
        var slot = opened()
        let first = slot.opening
        slot.decide(from: [], opening: first)
        XCTAssertTrue(slot.claim(.breakStart))
        slot.endOpening()
        guard let second = slot.beginOpening(stillShown: nil) else {
            return XCTFail("a new opening must start")
        }
        // A sheet of the new opening comes first: the screen shows its plain version then.
        XCTAssertEqual(slot.decide(from: [.widgetTip], opening: second), .widgetTip)
        XCTAssertFalse(slot.claim(.breakStart))
    }

    func testASheetStillOpenIsTheNewOpeningsCard() {
        var slot = opened()
        let first = slot.opening
        XCTAssertEqual(slot.decide(from: [.reminderTime], opening: first), .reminderTime)
        slot.endOpening()
        XCTAssertNil(slot.beginOpening(stillShown: .reminderTime))
        XCTAssertTrue(slot.isOpen)
        XCTAssertTrue(slot.isDecided)
        XCTAssertEqual(slot.current, .reminderTime)
        XCTAssertFalse(slot.claim(.breakStart))
        XCTAssertFalse(slot.claim(.dayEnd))
    }

    func testADecisionAfterTheOpeningEndedIsDropped() {
        var slot = opened()
        let first = slot.opening
        // The app went to the background while RootView was still gathering its candidates.
        slot.endOpening()
        XCTAssertNil(slot.decide(from: [.widgetTip], opening: first))
        XCTAssertFalse(slot.isDecided)
        XCTAssertNil(slot.current)

        guard let second = slot.beginOpening(stillShown: nil) else {
            return XCTFail("a new opening must start")
        }
        // The late answer of the first opening cannot take the second one either.
        XCTAssertNil(slot.decide(from: [.widgetTip], opening: first))
        XCTAssertFalse(slot.isDecided)
        XCTAssertEqual(slot.decide(from: [.remindersPaused], opening: second), .remindersPaused)
    }

    func testNothingIsDecidedOutsideAnOpening() {
        var slot = SystemCardSlot()
        XCTAssertFalse(slot.isOpen)
        XCTAssertNil(slot.decide(from: [.widgetTip], opening: 0))
        XCTAssertFalse(slot.claim(.dayEnd))
    }
}
