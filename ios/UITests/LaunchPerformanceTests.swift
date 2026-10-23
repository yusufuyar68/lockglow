import XCTest

/// Launch timings and memory of the app. They run only when the test runner has LOCKGLOW_PERF=1
/// (screenshots.yml, input "olcum": on their own, on an erased simulator). Each launches the app
/// several times, which would change the fresh install the screenshot tests expect, and XCTest
/// runs this class before `LockglowScreenshotTests` (alphabetical order).
///
/// Simulator numbers on a CI Mac, not iPhone numbers: they are for comparing builds.
final class LaunchPerformanceTests: XCTestCase {
    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["LOCKGLOW_PERF"] == "1",
            "launch timings run only in the measuring pass (LOCKGLOW_PERF=1)"
        )
        continueAfterFailure = false
    }

    /// Cold launch until the app answers a touch (the system's launch metric).
    func testLaunchUntilResponsive() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
            app.launch()
        }
    }

    /// Launch until the feed shows a card with its speaker button: the content is loaded and the
    /// deck is built (`AppModel.start`).
    func testLaunchUntilTheFirstCard() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        options.invocationOptions = [.manuallyStop]
        measure(metrics: [XCTClockMetric()], options: options) {
            app.launch()
            let speaker = app.buttons["Kelimeyi dinle"].firstMatch
            XCTAssertTrue(speaker.waitForExistence(timeout: 30), "the feed did not show a card")
            stopMeasuring()
            app.terminate()
        }
    }

    /// The running app's memory while the feed turns a few cards (the app is launched first: the
    /// memory metric reads a process that is already running).
    func testMemoryWhileTurningFeedCards() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()
        XCTAssertTrue(app.buttons["Kelimeyi dinle"].firstMatch.waitForExistence(timeout: 30), "the feed did not show a card")
        let options = XCTMeasureOptions()
        options.iterationCount = 3
        measure(metrics: [XCTMemoryMetric(application: app)], options: options) {
            for _ in 0..<3 {
                app.swipeUp()
            }
        }
    }
}
