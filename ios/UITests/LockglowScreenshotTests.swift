import XCTest

/// Walks through the main screens and attaches a screenshot of each, so the layout can be
/// reviewed on several screen sizes in CI (`.github/workflows/screenshots.yml`).
/// It only checks that the screens can be reached; it is not a behaviour test.
final class LockglowScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureMainScreens() throws {
        let app = XCUIApplication()
        app.launch()

        // Feed: the first card is "breakfast" (A1, it has a Turkish example and a mistake box).
        let firstCard = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "breakfast"))
            .firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 30), "feed did not show the first card")
        attachScreenshot(of: app, named: "1-akis")
        app.swipeUp()
        sleep(1)
        attachScreenshot(of: app, named: "2-akis-ikinci-kart")

        app.tabBars.buttons["Tekrar"].tap()
        let start = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Başla")).firstMatch
        if start.waitForExistence(timeout: 10) {
            attachScreenshot(of: app, named: "3-tekrar-baslangic")
            start.tap()
            let reveal = app.buttons["Anlamı göster"]
            if reveal.waitForExistence(timeout: 5) {
                attachScreenshot(of: app, named: "4-tekrar-kart-on")
                reveal.tap()
                sleep(1)
                attachScreenshot(of: app, named: "5-tekrar-kart-arka")
            }
            let finish = app.buttons["Bitir"]
            if finish.exists {
                finish.tap()
            }
        }

        app.tabBars.buttons["Ayarlar"].tap()
        sleep(1)
        attachScreenshot(of: app, named: "6-ayarlar")

        app.tabBars.buttons["Widget Sağlığı"].tap()
        sleep(1)
        attachScreenshot(of: app, named: "7-widget-sagligi")
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
