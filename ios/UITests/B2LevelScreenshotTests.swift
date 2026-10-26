import XCTest

/// B2 as a start level, for the screenshot review (`.github/workflows/screenshots.yml`): the
/// onboarding's level page with B2 chosen (four rows, four dots), the same page at the largest
/// text size, and "Ayarlar" with B2 as the start level (the level choice and its footnote).
/// Nothing is stored: the onboarding is left on its first page, and "Ayarlar" reads B2 from a
/// launch argument (`-lockglow.startLevel B2`), so the other tests still start on A1.
final class B2LevelScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureOnboardingLevelB2() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "NO"]
        app.launch()
        chooseB2(in: app)
        attachScreenshot(of: app, named: "22a-acilis-seviye-b2")
    }

    /// AX5 (the largest accessibility size): every row wraps, nothing is cut.
    func testCaptureOnboardingLevelB2LargeText() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-lockglow.onboardingCompleted", "NO",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL",
        ]
        app.launch()
        chooseB2(in: app)
        attachScreenshot(of: app, named: "22c-acilis-seviye-b2-buyuk-yazi")
    }

    func testCaptureSettingsLevelB2() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-lockglow.onboardingCompleted", "YES",
            "-lockglow.startLevel", "B2",
        ]
        app.launch()
        let tab = app.tabBars.buttons["Ayarlar"]
        XCTAssertTrue(tab.waitForExistence(timeout: 30), "no tabs")
        tab.tap()
        sleep(1)
        let footnote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Haberler, iş ve fikirler")).firstMatch
        for _ in 0..<4 where !(footnote.exists && footnote.isHittable) {
            app.swipeUp()
            sleep(1)
        }
        XCTAssertTrue(footnote.exists, "no B2 footnote in Ayarlar")
        XCTAssertTrue(app.buttons["B2"].exists, "no B2 in the level choice")
        attachScreenshot(of: app, named: "22b-ayarlar-seviye-b2")
    }

    // MARK: Steps

    /// The level page, scrolled to the B2 row, which is then chosen.
    private func chooseB2(in app: XCUIApplication) {
        let a1 = app.buttons["onboarding.level.A1"]
        XCTAssertTrue(a1.waitForExistence(timeout: 30), "the onboarding did not open")
        let b2 = app.buttons["onboarding.level.B2"]
        XCTAssertTrue(b2.waitForExistence(timeout: 5), "no B2 row on the level page")
        for _ in 0..<4 where !b2.isHittable {
            app.swipeUp()
            sleep(1)
        }
        b2.tap()
        sleep(1)
        // B2 gives the B1 goal: "Günde 10 yeni kelimeyle başlarsın."
        let goal = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Günde 10 yeni kelime")).firstMatch
        XCTAssertTrue(goal.waitForExistence(timeout: 5), "no daily goal line for B2")
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
