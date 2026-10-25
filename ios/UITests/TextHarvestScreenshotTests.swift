import XCTest

/// "Metinden kelime bul" (TextHarvestView) for the screenshot review
/// (`.github/workflows/screenshots.yml`): Sözlük's row, the empty page, a short English paragraph,
/// the words found, the new words and the add form of one of them. Like the other classes it
/// mostly checks that the screens can be reached; it also checks that a name is not offered as
/// a new word. Nothing is saved ("Vazgeç" on the form), so it leaves the install as it was.
///
/// The paragraph has card words ("tired", "breakfast", "weekend"), an inflected form
/// ("borrowed"), two phrases of the cards with an inflected first word ("woke up",
/// "looking forward to"), a word on no card ("serendipity") and names ("Mehmet", "Saturday").
/// Only the page's own identifiers are used (TextHarvestView.swift).
final class TextHarvestScreenshotTests: XCTestCase {
    private static let paragraph = "On Saturday morning Mehmet woke up tired. He borrowed his sister's bike and we had breakfast by the river. I am looking forward to the weekend. What a lovely serendipity!"

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureTextHarvest() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()

        let tab = app.tabBars.buttons["Sözlük"]
        XCTAssertTrue(tab.waitForExistence(timeout: 30), "no tabs")
        tab.tap()
        let entry = app.buttons["sozluk.textHarvest"]
        guard entry.waitForExistence(timeout: 10) else {
            XCTFail("no Metinden kelime bul row on Sözlük's start page")
            return
        }
        scrollToHittable(entry, in: app)
        sleep(1)
        attachScreenshot(of: app, named: "18a-sozluk-metinden-kelime")
        entry.tap()

        let field = app.textViews["textHarvest.text"]
        guard field.waitForExistence(timeout: 10) else {
            XCTFail("Metinden kelime bul did not open")
            return
        }
        sleep(1)
        attachScreenshot(of: app, named: "18b-metinden-kelime-bos")
        field.tap()
        field.typeText(TextHarvestScreenshotTests.paragraph)
        sleep(1)
        attachScreenshot(of: app, named: "18c-metinden-kelime-metin")

        // Above the keyboard (the page's bottom bar), so it can be tapped while typing.
        let find = app.buttons["textHarvest.find"]
        XCTAssertTrue(find.waitForExistence(timeout: 5), "no Kelimeleri bul button")
        find.tap()
        let cards = element("textHarvest.cards", in: app)
        guard cards.waitForExistence(timeout: 10) else {
            XCTFail("Kelimeleri bul found no card words in the paragraph")
            return
        }
        sleep(1)
        attachScreenshot(of: app, named: "18d-metinden-kelime-sonuc")

        let newWords = element("textHarvest.new", in: app)
        XCTAssertTrue(newWords.waitForExistence(timeout: 5), "no Yeni kelimeler group")
        scrollToHittable(newWords, in: app)
        sleep(1)
        attachScreenshot(of: app, named: "18e-metinden-kelime-yeni")
        XCTAssertFalse(app.buttons["textHarvest.new.mehmet"].exists, "a name is offered as a new word")
        XCTAssertFalse(app.buttons["textHarvest.new.saturday"].exists, "a name is offered as a new word")

        // The rows are in a lazy stack: one exists once it is near the screen.
        let unknown = app.buttons["textHarvest.new.serendipity"]
        scrollToHittable(unknown, in: app)
        guard unknown.waitForExistence(timeout: 5) else {
            XCTFail("serendipity is not among the new words")
            return
        }
        // The list runs under the "Kelimeleri bul" bar, where a row still counts as hittable:
        // the row has to be wholly above the bar, or the tap finds the words again.
        let bar = app.buttons["textHarvest.find"]
        for _ in 0..<4 where unknown.exists && bar.exists && unknown.frame.maxY > bar.frame.minY {
            app.swipeUp()
        }
        unknown.tap()
        // The add form with the word filled in; the Turkish meaning is the user's to write.
        let save = app.buttons["Kelimeyi ekle"]
        if save.waitForExistence(timeout: 10) {
            sleep(2)
            attachScreenshot(of: app, named: "18f-metinden-kelime-ekle")
            app.buttons["Vazgeç"].firstMatch.tap()
        } else {
            XCTFail("a new word did not open the add form")
        }
    }

    // MARK: Helpers

    /// The first element with this identifier, whatever its kind (a section heading is a combined
    /// element).
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
