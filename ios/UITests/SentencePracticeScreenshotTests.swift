import XCTest

/// "Cümle kur" (SentencePracticeView), opened from Ayarlar' İlerleme group, for the screenshot
/// review (`.github/workflows/screenshots.yml`). It only checks that the screens can be reached.
///
/// Test classes share one install and run in alphabetical order, so this one comes after
/// `LockglowScreenshotTests`, whose Tekrar round has put words in the learning boxes. Run alone
/// it finds no word to practice and captures the empty screen.
final class SentencePracticeScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureSentencePractice() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Ayarlar"].waitForExistence(timeout: 30), "no tabs")
        app.tabBars.buttons["Ayarlar"].tap()
        let row = app.buttons["Cümle kur"]
        XCTAssertTrue(row.waitForExistence(timeout: 5), "no Cümle kur row in Ayarlar")
        for _ in 0..<6 where !(row.exists && row.isHittable) {
            app.swipeUp()
        }
        row.tap()
        guard app.navigationBars["Cümle kur"].waitForExistence(timeout: 10) else {
            XCTFail("Cümle kur did not open")
            return
        }
        sleep(1)
        attachScreenshot(of: app, named: "40-cumle-kur")
        if app.staticTexts["Şimdilik cümle yok"].exists {
            XCTContext.runActivity(named: "No word to practice: empty screen only") { _ in }
            return
        }

        // A round has at most 5 questions and a wrong one comes once more: at most 10 steps.
        for step in 1...10 {
            if app.staticTexts["Pratik bitti"].exists {
                break
            }
            let check = app.buttons["Kontrol et"]
            if check.exists {
                // Every free tile in turn: each tap puts it at the end of the sentence.
                let free = app.buttons.matching(identifier: "practice.tile")
                for _ in 0..<12 where free.count > 0 {
                    free.element(boundBy: 0).tap()
                }
                if step <= 2 {
                    attachScreenshot(of: app, named: "41-cumle-kur-\(step)-dizildi")
                }
                check.tap()
            } else {
                let option = app.buttons.matching(identifier: "practice.option").firstMatch
                guard option.waitForExistence(timeout: 3) else {
                    XCTFail("step \(step): neither tiles nor options")
                    return
                }
                attachScreenshot(of: app, named: "43-cumle-kur-\(step)-esdizim")
                option.tap()
            }
            let next = app.buttons["Devam"]
            XCTAssertTrue(next.waitForExistence(timeout: 5), "step \(step): no Devam after the answer")
            sleep(1)
            if step <= 3 {
                attachScreenshot(of: app, named: "42-cumle-kur-\(step)-cevap")
            }
            next.tap()
        }
        XCTAssertTrue(app.staticTexts["Pratik bitti"].waitForExistence(timeout: 5), "no summary after the round")
        sleep(1)
        attachScreenshot(of: app, named: "45-cumle-kur-ozet")
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
