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

        // Sözlük: a Turkish prefix without Turkish letters must find the English word.
        app.tabBars.buttons["Sözlük"].tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "no search field")
        field.tap()
        field.typeText("kahv")
        let hit = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "breakfast"))
            .firstMatch
        XCTAssertTrue(hit.waitForExistence(timeout: 5), "searching 'kahv' did not find breakfast")
        attachScreenshot(of: app, named: "7-sozluk-arama")
        hit.tap()
        sleep(1)
        attachScreenshot(of: app, named: "8-sozluk-kart")

        // "Biliyorum" on the card, then the word shows up under Ayarlar > Bildiğim kelime and
        // "Öğrenmeye geri al" takes it back out.
        let know = app.buttons["Biliyorum"]
        XCTAssertTrue(know.waitForExistence(timeout: 5), "no Biliyorum button on the card")
        know.tap()
        XCTAssertTrue(app.buttons["Öğrenmeye geri al"].waitForExistence(timeout: 5), "card did not switch to known")

        app.tabBars.buttons["Ayarlar"].tap()
        let knownRow = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Bildiğim kelime")).firstMatch
        XCTAssertTrue(knownRow.waitForExistence(timeout: 5), "no known-words row in Ayarlar")
        knownRow.tap()
        let knownWord = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "breakfast"))
            .firstMatch
        XCTAssertTrue(knownWord.waitForExistence(timeout: 5), "breakfast is not in the known words")
        attachScreenshot(of: app, named: "9-bildiklerim")
        knownWord.tap()
        let undo = app.buttons["Öğrenmeye geri al"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5), "no undo button on the known word")
        undo.tap()
        XCTAssertTrue(app.buttons["Biliyorum"].waitForExistence(timeout: 5), "undo did not take the word back")
        attachScreenshot(of: app, named: "10-geri-alindi")
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
