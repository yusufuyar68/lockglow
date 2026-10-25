import XCTest

/// The FSRS wording ("Yeni zamanlama" on, the default of a fresh install) for the screenshot
/// review (`.github/workflows/screenshots.yml`): Ayarlar, "Kitaplığın ve bu hafta" (the İlerleme
/// page) and "Nasıl öğrenirim?". It only checks that the pages can be reached.
///
/// The launch argument sets the scheduler for this run only (UserDefaults' argument domain). Test
/// classes share one install and run in alphabetical order: this one comes after
/// `LockglowScreenshotTests`, whose first launch has already written the fresh install's FSRS, and
/// whose Tekrar round has put words on the shelves. Run first, its argument would stop that first
/// launch from writing the default (`AppModel.settleSchedulerAtLaunch`). Only identifiers the
/// pages set for the tests are used (SettingsView, ProgressOverviewView, LearningGuideView).
final class SchedulerFSRSScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureFSRSWording() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES", "-lockglow.scheduler", "fsrs"]
        app.launch()

        let tab = app.tabBars.buttons["Ayarlar"]
        XCTAssertTrue(tab.waitForExistence(timeout: 30), "no tabs")
        tab.tap()

        let library = app.buttons["settings.library"]
        guard library.waitForExistence(timeout: 5) else {
            XCTFail("no Kitaplığın ve bu hafta row in Ayarlar")
            return
        }
        scrollToHittable(library, in: app)
        sleep(1)
        attachScreenshot(of: app, named: "19a-fsrs-ayarlar")
        library.tap()
        guard element("progress.page", in: app).waitForExistence(timeout: 10) else {
            XCTFail("Kitaplığın ve bu hafta did not open İlerleme")
            return
        }
        sleep(1)
        attachScreenshot(of: app, named: "19b-fsrs-ilerleme")
        app.swipeUp()
        sleep(1)
        attachScreenshot(of: app, named: "19c-fsrs-ilerleme-alt")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let guide = app.buttons["settings.learningGuide"]
        guard guide.waitForExistence(timeout: 5) else {
            XCTFail("no Nasıl öğrenirim? row in Ayarlar")
            return
        }
        scrollToHittable(guide, in: app)
        guide.tap()
        guard element("learningGuide.page", in: app).waitForExistence(timeout: 10) else {
            XCTFail("Nasıl öğrenirim? did not open")
            return
        }
        sleep(1)
        attachScreenshot(of: app, named: "19d-fsrs-nasil-ogrenirim")
        app.swipeUp()
        sleep(1)
        attachScreenshot(of: app, named: "19e-fsrs-nasil-ogrenirim-devam")
        app.swipeUp()
        sleep(1)
        attachScreenshot(of: app, named: "19f-fsrs-nasil-ogrenirim-son")
    }

    // MARK: Helpers

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        return app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    /// Swipes up until the element can be tapped, at most `swipes` times.
    private func scrollToHittable(_ element: XCUIElement, in app: XCUIApplication, swipes: Int = 6) {
        for _ in 0..<swipes where !(element.exists && element.isHittable) {
            app.swipeUp()
        }
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
