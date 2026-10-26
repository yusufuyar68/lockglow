import XCTest
import Learning

/// The scheduler a device starts with (`SchedulerDefault`): FSRS on a fresh install only.
final class SchedulerDefaultTests: XCTestCase {
    func testAFreshInstallStartsWithFSRS() {
        XCTAssertEqual(SchedulerDefault.initialKind(storedRawValue: nil, isFreshInstall: true), .fsrs)
    }

    func testAnUpdateKeepsLeitner() {
        // Words timed by Leitner, no setting written by the earlier build: nobody is moved silently.
        XCTAssertEqual(SchedulerDefault.initialKind(storedRawValue: nil, isFreshInstall: false), .leitner)
    }

    func testTheSavedSettingDecides() {
        for fresh in [true, false] {
            XCTAssertEqual(SchedulerDefault.initialKind(storedRawValue: "leitner", isFreshInstall: fresh), .leitner)
            XCTAssertEqual(SchedulerDefault.initialKind(storedRawValue: "fsrs", isFreshInstall: fresh), .fsrs)
        }
    }

    func testAnUnknownValueIsLeitner() {
        // A damaged setting or a later build's scheduler: Leitner, even on a fresh install.
        for stored in ["", "FSRS", "fsrs7", "sm2"] {
            XCTAssertEqual(SchedulerDefault.initialKind(storedRawValue: stored, isFreshInstall: true), .leitner, stored)
            XCTAssertEqual(SchedulerDefault.initialKind(storedRawValue: stored, isFreshInstall: false), .leitner, stored)
        }
    }

    func testEveryKindSurvivesItsOwnRawValue() {
        // What the launch writes reads back as itself on the next launch.
        for kind in SchedulerKind.allCases {
            XCTAssertEqual(SchedulerDefault.initialKind(storedRawValue: kind.rawValue, isFreshInstall: true), kind)
            XCTAssertEqual(SchedulerDefault.initialKind(storedRawValue: kind.rawValue, isFreshInstall: false), kind)
        }
    }
}
