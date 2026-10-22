import XCTest
import Learning

final class OnboardingGateTests: XCTestCase {
    func testTheSavedFlagDecides() {
        // Finished or skipped: never again by itself, whatever is on disk.
        XCTAssertFalse(OnboardingGate.shouldShow(storedCompleted: true, hasWidgetPlan: false, hasProgress: false))
        XCTAssertFalse(OnboardingGate.shouldShow(storedCompleted: true, hasWidgetPlan: true, hasProgress: true))
        // Shown once and left half way (the plan written on the way out does not count).
        XCTAssertTrue(OnboardingGate.shouldShow(storedCompleted: false, hasWidgetPlan: true, hasProgress: false))
        XCTAssertTrue(OnboardingGate.shouldShow(storedCompleted: false, hasWidgetPlan: true, hasProgress: true))
    }

    func testWithoutAFlagAnEarlierInstallSkipsIt() {
        XCTAssertFalse(OnboardingGate.shouldShow(storedCompleted: nil, hasWidgetPlan: true, hasProgress: false))
        XCTAssertFalse(OnboardingGate.shouldShow(storedCompleted: nil, hasWidgetPlan: false, hasProgress: true))
        XCTAssertFalse(OnboardingGate.shouldShow(storedCompleted: nil, hasWidgetPlan: true, hasProgress: true))
    }

    func testAFreshInstallShowsIt() {
        XCTAssertTrue(OnboardingGate.shouldShow(storedCompleted: nil, hasWidgetPlan: false, hasProgress: false))
    }
}
