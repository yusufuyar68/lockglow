import XCTest
import CoreModels
import Learning

final class SettingsRulesTests: XCTestCase {
    // MARK: Daily goal

    func testTheGoalNobodyChoseFollowsTheLevel() {
        XCTAssertEqual(SettingsRules.defaultDailyNewWords(startLevel: .a1), 5)
        XCTAssertEqual(SettingsRules.defaultDailyNewWords(startLevel: .a2), 5)
        XCTAssertEqual(SettingsRules.defaultDailyNewWords(startLevel: .b1), 10)
        // No level (onboarding skipped, or a build before it): the words start at A1.
        XCTAssertEqual(SettingsRules.defaultDailyNewWords(startLevel: nil), 5)

        XCTAssertEqual(SettingsRules.dailyNewWords(stored: nil, startLevel: .a2), 5)
        XCTAssertEqual(SettingsRules.dailyNewWords(stored: nil, startLevel: .b1), 10)
    }

    func testAChosenGoalStaysWhateverTheLevel() {
        XCTAssertEqual(SettingsRules.dailyNewWords(stored: 20, startLevel: .a1), 20)
        XCTAssertEqual(SettingsRules.dailyNewWords(stored: 15, startLevel: nil), 15)
        // The old default, chosen by hand in an earlier build, is kept too.
        XCTAssertEqual(SettingsRules.dailyNewWords(stored: 10, startLevel: .a1), 10)
        XCTAssertEqual(SettingsRules.dailyNewWords(stored: 5, startLevel: .b1), 5)
        XCTAssertEqual(SettingsRules.chosenDailyNewWords(stored: 5), 5)
    }

    func testANumberThatIsNotOfferedIsNoChoice() {
        // 0 is what UserDefaults reads for a key that was never written.
        for stored in [0, 7, 30, -5] {
            XCTAssertNil(SettingsRules.chosenDailyNewWords(stored: stored), "\(stored)")
            XCTAssertEqual(SettingsRules.dailyNewWords(stored: stored, startLevel: .b1), 10, "\(stored)")
            XCTAssertEqual(SettingsRules.dailyNewWords(stored: stored, startLevel: .a1), 5, "\(stored)")
        }
        XCTAssertNil(SettingsRules.chosenDailyNewWords(stored: nil))
    }

    func testEveryLevelDefaultIsOffered() {
        let levels: [Level?] = [nil, .a1, .a2, .b1]
        for level in levels {
            XCTAssertTrue(SettingsRules.dailyNewWordChoices.contains(SettingsRules.defaultDailyNewWords(startLevel: level)))
        }
    }

    // MARK: Rotation

    func testTheIntervalsOnOffer() {
        XCTAssertEqual(SettingsRules.rotationMinuteChoices, [30, 60, 120, 240])
        XCTAssertEqual(SettingsRules.defaultRotationMinutes, 60)
        XCTAssertTrue(SettingsRules.rotationMinuteChoices.contains(SettingsRules.legacyRotationTarget))
        XCTAssertTrue(SettingsRules.legacyRotationMinutes.isDisjoint(with: SettingsRules.rotationMinuteChoices))
    }

    func testFiveAndFifteenMinutesMoveToThirty() {
        XCTAssertEqual(SettingsRules.rotationMinutes(stored: 5), 30)
        XCTAssertEqual(SettingsRules.rotationMinutes(stored: 15), 30)
    }

    func testAnOfferedIntervalStays() {
        for minutes in [30, 60, 120, 240] {
            XCTAssertEqual(SettingsRules.rotationMinutes(stored: minutes), minutes)
        }
    }

    func testNoOrAnUnknownIntervalIsTheHour() {
        XCTAssertEqual(SettingsRules.rotationMinutes(stored: nil), 60)
        XCTAssertEqual(SettingsRules.rotationMinutes(stored: 0), 60)
        XCTAssertEqual(SettingsRules.rotationMinutes(stored: 45), 60)
        XCTAssertEqual(SettingsRules.rotationMinutes(stored: 1440), 60)
    }

    // MARK: Cost of the goal

    func testTheMinutesOfDesignNoteTwoNine() {
        XCTAssertEqual(SettingsRules.minimumMinutesPerDay(dailyNewWords: 5), 7)
        XCTAssertEqual(SettingsRules.minimumMinutesPerDay(dailyNewWords: 10), 13)
        XCTAssertEqual(SettingsRules.minimumMinutesPerDay(dailyNewWords: 15), 19)
        XCTAssertEqual(SettingsRules.minimumMinutesPerDay(dailyNewWords: 20), 25)
    }

    func testMoreWordsNeverCostLess() {
        var previous = SettingsRules.minimumMinutesPerDay(dailyNewWords: 0)
        XCTAssertEqual(previous, 1)
        for goal in 1...30 {
            let minutes = SettingsRules.minimumMinutesPerDay(dailyNewWords: goal)
            XCTAssertGreaterThanOrEqual(minutes, previous)
            previous = minutes
        }
        XCTAssertEqual(SettingsRules.minimumMinutesPerDay(dailyNewWords: -3), 1)
    }
}
