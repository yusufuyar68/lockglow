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
        // Straight to the tabs: the onboarding has its own test below.
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()

        // Feed: the first card is "breakfast" (A1, it has a Turkish example and a mistake box).
        let firstCard = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "breakfast"))
            .firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 30), "feed did not show the first card")
        attachScreenshot(of: app, named: "1-akis")
        // The speaker reads the word aloud; the app must survive it (CI simulators may be silent).
        let listen = app.buttons["Kelimeyi dinle"].firstMatch
        XCTAssertTrue(listen.waitForExistence(timeout: 5), "no speaker button on the feed card")
        listen.tap()
        sleep(1)
        XCTAssertEqual(app.state, .runningForeground, "the app stopped after the speaker tap")
        app.swipeUp()
        sleep(1)
        attachScreenshot(of: app, named: "2-akis-ikinci-kart")

        app.tabBars.buttons["Tekrar"].tap()
        let start = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Başla")).firstMatch
        if start.waitForExistence(timeout: 10) {
            attachScreenshot(of: app, named: "3-tekrar-baslangic")
            start.tap()
            // A fresh install has no due word: the round is "Tanış + Hatırla" and starts with a
            // word's front.
            let reveal = app.buttons["Anlamını göster"]
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

        // Konular: the topic list with its summary line, then back to Ayarlar without choosing
        // anything (the choice is kept in UserDefaults). The row's label is "Konular, Tümü".
        let topicsRow = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Konular")).firstMatch
        XCTAssertTrue(topicsRow.waitForExistence(timeout: 5), "no Konular row in Ayarlar")
        topicsRow.tap()
        XCTAssertTrue(app.buttons["topics.all"].waitForExistence(timeout: 5), "no topic list")
        attachScreenshot(of: app, named: "6b-konular")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(1)

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

        // "Biliyorum" on the card, then the word shows up under Ayarlar > Bildiğin kelime and
        // "Öğrenmeye geri al" takes it back out.
        let know = app.buttons["Biliyorum"]
        XCTAssertTrue(know.waitForExistence(timeout: 5), "no Biliyorum button on the card")
        know.tap()
        XCTAssertTrue(app.buttons["Öğrenmeye geri al"].waitForExistence(timeout: 5), "card did not switch to known")

        app.tabBars.buttons["Ayarlar"].tap()
        let knownRow = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Bildiğin kelime")).firstMatch
        if !knownRow.waitForExistence(timeout: 2) {
            // Below the "Öğrenme" and widget sections on a small screen.
            app.swipeUp()
        }
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

    /// The four onboarding pages. Chooses A1 and every topic, which keeps the curriculum order,
    /// so the feed of the other test still starts with "breakfast" whatever order they run in.
    func testCaptureOnboarding() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "NO"]
        app.launch()

        let a1 = app.buttons["onboarding.level.A1"]
        XCTAssertTrue(a1.waitForExistence(timeout: 30), "the onboarding did not open")
        attachScreenshot(of: app, named: "0a-acilis-seviye")
        a1.tap()
        app.buttons["onboarding.next"].tap()

        let everything = app.buttons["topics.all"]
        XCTAssertTrue(everything.waitForExistence(timeout: 30), "no topic list")
        let food = app.buttons["topics.food_drink"]
        if food.waitForExistence(timeout: 2) {
            food.tap()
        }
        attachScreenshot(of: app, named: "0b-acilis-konular")
        everything.tap()
        app.buttons["onboarding.next"].tap()

        let homeScreen = app.buttons["Ana ekran"]
        XCTAssertTrue(homeScreen.waitForExistence(timeout: 5), "no widget guide")
        attachScreenshot(of: app, named: "0c-acilis-widget-kilit")
        homeScreen.tap()
        sleep(1)
        attachScreenshot(of: app, named: "0d-acilis-widget-ana")
        app.buttons["onboarding.next"].tap()

        let start = app.buttons["onboarding.start"]
        XCTAssertTrue(start.waitForExistence(timeout: 5), "no first word page")
        let firstWord = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "breakfast"))
            .firstMatch
        XCTAssertTrue(firstWord.waitForExistence(timeout: 5), "the first word is not breakfast")
        attachScreenshot(of: app, named: "0e-acilis-ilk-kelime")
        start.tap()
        XCTAssertTrue(app.tabBars.buttons["Akış"].waitForExistence(timeout: 5), "the onboarding did not close")
    }

    /// A long phrase in Sözlük (the card title on a small screen) and the "Söyle" page.
    /// The speech permission alert may cover the Söyle page on a fresh simulator; the
    /// screenshot is taken either way.
    func testCaptureLongLemmaAndSoyle() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Sözlük"].waitForExistence(timeout: 30), "no tabs")
        app.tabBars.buttons["Sözlük"].tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "no search field")
        field.tap()
        field.typeText("look forward")
        let hit = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "look forward"))
            .firstMatch
        XCTAssertTrue(hit.waitForExistence(timeout: 5), "searching 'look forward' found nothing")
        hit.tap()
        sleep(1)
        attachScreenshot(of: app, named: "11-sozluk-uzun-lemma")

        let say = app.buttons["Söyle: telaffuzunu dene"].firstMatch
        if !say.waitForExistence(timeout: 3) {
            app.swipeUp()
        }
        XCTAssertTrue(say.waitForExistence(timeout: 5), "no Söyle button on the card")
        say.tap()
        sleep(2)
        attachScreenshot(of: app, named: "8b-soyle-sayfasi")
    }

    /// Ayarlar > Yardım > "Nasıl öğrenirim?" (the learning guide).
    func testCaptureLearningGuide() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Ayarlar"].waitForExistence(timeout: 30), "no tabs")
        app.tabBars.buttons["Ayarlar"].tap()
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Nasıl öğrenirim")).firstMatch
        for _ in 0..<4 where !(row.exists && row.isHittable) {
            app.swipeUp()
        }
        XCTAssertTrue(row.waitForExistence(timeout: 5), "no learning guide row in Ayarlar")
        row.tap()
        sleep(1)
        attachScreenshot(of: app, named: "12-nasil-ogrenirim")
        app.swipeUp()
        sleep(1)
        attachScreenshot(of: app, named: "12b-nasil-ogrenirim-devam")
    }

    /// "Atla" on the first page closes the onboarding without a level.
    func testSkipOnboarding() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "NO"]
        app.launch()

        let skip = app.buttons["onboarding.skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 30), "the onboarding did not open")
        skip.tap()
        XCTAssertTrue(app.tabBars.buttons["Akış"].waitForExistence(timeout: 5), "no tabs after Atla")
        sleep(1)
        XCTAssertFalse(skip.exists, "Atla did not close the onboarding")
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
