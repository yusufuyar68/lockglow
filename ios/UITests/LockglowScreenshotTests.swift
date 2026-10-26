import XCTest

/// Walks through the main screens and attaches a screenshot of each, so the layout can be
/// reviewed on several screen sizes in CI (`.github/workflows/screenshots.yml`).
/// It only checks that the screens can be reached; it is not a behaviour test.
///
/// The tests share one install and XCTest runs them in alphabetical order. The names keep the
/// state each one expects: first the captures of a fresh install (learning guide, long lemma and
/// Söyle, the main screens with the first card "breakfast" still new, the onboarding), then the
/// Tekrar round (its words become "learning"), the user's own word, the dictionary browse (its
/// filters then have learning words), the quiz that waits for the word missed in the round, and
/// last the onboarding skip.
final class LockglowScreenshotTests: XCTestCase {
    /// The word `testCaptureTekrarIntroRound` answered wrong twice, and when its round ended. It
    /// comes back in Tekrar 10 minutes later (`Leitner.relearnDelay`) as a gap-fill quiz.
    private static var missedWord: (lemma: String, at: Date)?

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
        // First encounter: the card's one warning line ("I did breakfast" → "I had breakfast")
        // with "Neden?", which opens the explanation sheet. A small screen may leave the line out
        // to fit the card on one page.
        let why = app.buttons["Neden?"].firstMatch
        if why.waitForExistence(timeout: 3) && why.isHittable {
            why.tap()
            let close = app.buttons["Kapat"].firstMatch
            XCTAssertTrue(close.waitForExistence(timeout: 5), "Neden? did not open its sheet")
            sleep(1)
            attachScreenshot(of: app, named: "1b-akis-neden")
            close.tap()
            sleep(1)
        } else {
            XCTContext.runActivity(named: "No Neden? button on the first card") { _ in }
        }
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
        // The row's VoiceOver form is an `accessibilityRepresentation`: tap the visible row there.
        hit.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
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
        knownWord.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        let undo = app.buttons["Öğrenmeye geri al"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5), "no undo button on the known word")
        undo.tap()
        XCTAssertTrue(app.buttons["Biliyorum"].waitForExistence(timeout: 5), "undo did not take the word back")
        attachScreenshot(of: app, named: "10-geri-alindi")
    }

    /// The six onboarding pages. Chooses A1 and every topic, leaves the daily goal untouched,
    /// and selects no known words, so later tests still start with a new "breakfast" card.
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

        let daily = app.buttons["onboarding.daily.5"]
        XCTAssertTrue(daily.waitForExistence(timeout: 5), "no daily goal page")
        attachScreenshot(of: app, named: "0b1-acilis-gunluk")
        app.buttons["onboarding.next"].tap()

        let knownTitle = app.staticTexts["Bildiğin kelimeler var mı?"]
        XCTAssertTrue(knownTitle.waitForExistence(timeout: 5), "no optional known-word page")
        attachScreenshot(of: app, named: "0b2-acilis-bilinenler")
        // This suite shares progress: exercise the optional zero-selection route here.
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

    /// One "Tanış + Hatırla" round to its summary, the reminder question that follows the first
    /// "Tamam", then "Kitaplığın" and the İlerleme page. The word of the first question is
    /// answered wrong both times: the summary shows a missed word, and the word comes back as a
    /// quiz in `testCaptureWaitedQuiz`.
    func testCaptureTekrarIntroRound() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Tekrar"].waitForExistence(timeout: 30), "no tabs")
        app.tabBars.buttons["Tekrar"].tap()
        let start = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Başla")).firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: 10), "no Başla button in Tekrar")
        start.tap()
        let missed = playRound(app, named: "13-tekrar", missingTheFirstQuestion: true)
        XCTAssertTrue(app.navigationBars["Tur bitti"].waitForExistence(timeout: 5), "the round has no summary")
        if let missed = missed {
            LockglowScreenshotTests.missedWord = (missed, Date())
        } else {
            XCTContext.runActivity(named: "No word was missed on purpose: no quiz later") { _ in }
        }
        sleep(1)
        attachScreenshot(of: app, named: "13-tekrar-tur-ozeti")
        app.swipeUp()
        sleep(1)
        attachScreenshot(of: app, named: "13-tekrar-tur-ozeti-alt")
        let done = app.buttons["Tamam"]
        XCTAssertTrue(done.waitForExistence(timeout: 5), "no Tamam on the summary")
        done.tap()

        // The first "Tamam" asks once for a daily reminder ("Her gün 1 hatırlatma gönderelim mi?",
        // `ReminderOfferSheet` in ReviewView, 2.8). The sheet covers the start screen: the 22 Oct
        // run could not tap "Kitaplığın" under it. "Şimdi değil" closes it without iOS's
        // permission alert; the question never comes again on this install.
        let notNow = app.buttons["Şimdi değil"]
        if notNow.waitForExistence(timeout: 5) {
            sleep(1)
            attachScreenshot(of: app, named: "13-tekrar-hatirlatma-sorusu")
            notNow.tap()
            waitForDisappearance(of: notNow)
        } else {
            XCTContext.runActivity(named: "No reminder question after the round") { _ in }
        }

        // "Kitaplığın" on the start screen, once a word is on the shelves.
        let library = app.buttons["Kitaplığın"]
        XCTAssertTrue(library.waitForExistence(timeout: 5), "no Kitaplığın link after the round")
        scrollToHittable(library, in: app)
        sleep(1)
        attachScreenshot(of: app, named: "13-tekrar-baslangic-kitaplik")
        library.tap()
        // `ProgressScreen` (ProgressOverviewView) has the large title "İlerleme". Without it the
        // pictures below would show the wrong screen, and there is no back button to tap.
        guard app.navigationBars["İlerleme"].waitForExistence(timeout: 10) else {
            XCTFail("Kitaplığın did not open İlerleme")
            return
        }
        sleep(1)
        attachScreenshot(of: app, named: "14a-ilerleme")
        app.swipeUp()
        sleep(1)
        attachScreenshot(of: app, named: "14b-ilerleme-alt")
        app.swipeUp()
        sleep(1)
        attachScreenshot(of: app, named: "14c-ilerleme-son")
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    /// Ayarlar > "Kendi kelimelerin": the empty list, the add form (with the note for a word that
    /// is on the cards), the list with the new word, and its edit form.
    func testCaptureUserWords() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Ayarlar"].waitForExistence(timeout: 30), "no tabs")
        app.tabBars.buttons["Ayarlar"].tap()
        // The row's label is "Kendi kelimelerin, 0", under the İlerleme section.
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Kendi kelimelerin")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5), "no Kendi kelimelerin row in Ayarlar")
        scrollToHittable(row, in: app)
        sleep(1)
        attachScreenshot(of: app, named: "15-ayarlar-ilerleme")
        row.tap()

        let addFirst = app.buttons["İlk kelimeni ekle"]
        XCTAssertTrue(addFirst.waitForExistence(timeout: 5), "no empty list with İlk kelimeni ekle")
        attachScreenshot(of: app, named: "15a-kendi-kelime-bos")
        addFirst.tap()

        let save = app.buttons["Kelimeyi ekle"]
        if !save.waitForExistence(timeout: 10) {
            print("Kendi kelime: no form after İlk kelimeni ekle:\n\(app.debugDescription)")
            XCTFail("the add form did not open")
            return
        }
        // The form focuses the word field by itself after a moment, and return moves on to the
        // meaning and then the example: the text goes in through the keyboard focus. Without a
        // keyboard the word field is tapped by its identifier (`customWord.lemma`; the 22 Oct run
        // found no text field labelled "İngilizce kelime"; the labels are logged here).
        sleep(2)
        print("Kendi kelime form fields: \(app.textFields.allElementsBoundByIndex.map { "\($0.label) | \($0.placeholderValue ?? "")" })")
        if !app.keyboards.firstMatch.exists {
            let lemmaField = app.textFields["customWord.lemma"]
            (lemmaField.exists ? lemmaField : app.textFields.firstMatch).tap()
        }
        // A word that is on a card: the form says so and still lets it be added.
        app.typeText("breakfast")
        let onCards = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label BEGINSWITH %@", "Bu kelime kartlarda zaten var"))
            .firstMatch
        XCTAssertTrue(onCards.waitForExistence(timeout: 5), "no note for a word that is on the cards")
        attachScreenshot(of: app, named: "15b-kendi-kelime-kartlarda-var")
        app.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: "breakfast".count))
        // Not on any card; plain a-z text, so typing needs no Turkish keyboard.
        app.typeText("binge-watch\n")
        app.typeText("dizi maratonu yapmak\n")
        app.typeText("We binge-watched the whole series this weekend.")
        sleep(1)
        attachScreenshot(of: app, named: "15c-kendi-kelime-form")
        save.tap()

        let added = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "binge-watch")).firstMatch
        XCTAssertTrue(added.waitForExistence(timeout: 5), "the new word is not in the list")
        // With the "eklendi" note, which stays 4 seconds.
        attachScreenshot(of: app, named: "15d-kendi-kelime-liste")
        added.tap()
        if app.buttons["Kaydet"].waitForExistence(timeout: 5) {
            sleep(1)
            attachScreenshot(of: app, named: "15e-kendi-kelime-duzenle")
            app.buttons["Vazgeç"].firstMatch.tap()
        } else {
            XCTFail("the word did not open its edit form")
        }
    }

    /// Sözlük without a query (recent searches, topics), a topic page with its filter, "kahvalti"
    /// without "ı" with the filter above the results, an empty filter, and another word's card.
    func testCaptureVocabularyBrowse() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Sözlük"].waitForExistence(timeout: 30), "no tabs")
        app.tabBars.buttons["Sözlük"].tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "no search field")
        // The earlier tests opened cards found with "kahv" and "look forward": recent searches.
        // If they did not get that far, one search is sent here (return records it) and the app
        // starts again on an empty Sözlük.
        let recent = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Sil: ")).firstMatch
        if !recent.waitForExistence(timeout: 5) {
            field.tap()
            field.typeText("kahv\n")
            sleep(1)
            app.terminate()
            app.launch()
            XCTAssertTrue(app.tabBars.buttons["Sözlük"].waitForExistence(timeout: 30), "no tabs")
            app.tabBars.buttons["Sözlük"].tap()
        }
        XCTAssertTrue(recent.waitForExistence(timeout: 5), "nothing under Son aramalar")
        sleep(1)
        attachScreenshot(of: app, named: "16a-sozluk-baslangic")

        // "Konuya göre göz at": the capsule label is "Yemek ve içecek, 67 kelime" (ContentTopic.displayName).
        var topic = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Yemek ve içecek")).firstMatch
        if !topic.waitForExistence(timeout: 3) {
            topic = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", " kelime")).firstMatch
        }
        XCTAssertTrue(topic.waitForExistence(timeout: 5), "no topic capsule in Sözlük")
        scrollToHittable(topic, in: app)
        topic.tap()
        // On a topic page the filter labels carry the count: "Öğreniyorsun: 3" (SozlukFilterBar).
        let learning = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Öğreniyorsun")).firstMatch
        XCTAssertTrue(learning.waitForExistence(timeout: 10), "the topic page has no filter")
        sleep(1)
        attachScreenshot(of: app, named: "16b-sozluk-konu")
        learning.tap()
        sleep(1)
        attachScreenshot(of: app, named: "16c-sozluk-konu-ogreniyorum")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(1)

        // "ı" typed as "i" still finds the word; the filter sits above the results.
        XCTAssertTrue(field.waitForExistence(timeout: 5), "no search field after the topic page")
        field.tap()
        field.typeText("kahvalti")
        let breakfast = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "breakfast"))
            .firstMatch
        XCTAssertTrue(breakfast.waitForExistence(timeout: 5), "searching 'kahvalti' did not find breakfast")
        attachScreenshot(of: app, named: "16d-sozluk-kahvalti")
        // The filter's name is "Bildiğin kelime" ("Bildiğin kelime: N" where it shows counts).
        let known = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Bildiğin kelime")).firstMatch
        XCTAssertTrue(known.waitForExistence(timeout: 5), "no filter above the results")
        known.tap()
        sleep(1)
        attachScreenshot(of: app, named: "16e-sozluk-suzgec-bos")
        let showAll = app.buttons["Tümünü göster"]
        if showAll.exists {
            showAll.tap()
        }

        // Another word than breakfast for the card: "kasik" (kaşık) finds spoon.
        field.tap()
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 12))
        field.typeText("kasik")
        let spoon = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "spoon"))
            .firstMatch
        if spoon.waitForExistence(timeout: 5) {
            spoon.tap()
            sleep(1)
            attachScreenshot(of: app, named: "16f-sozluk-kart-kasik")
        } else {
            XCTContext.runActivity(named: "'kasik' did not find spoon") { _ in }
        }
    }

    /// The word missed in `testCaptureTekrarIntroRound` is due 10 minutes after its round, and
    /// Tekrar asks it as a gap-fill quiz (the App Store's "Boşluğu doldur" screen). It waits for
    /// that, so it runs only when the workflow sets `TEST_RUNNER_LOCKGLOW_QUIZ_WAIT=1`.
    func testCaptureWaitedQuiz() throws {
        guard ProcessInfo.processInfo.environment["LOCKGLOW_QUIZ_WAIT"] == "1" else {
            throw XCTSkip("LOCKGLOW_QUIZ_WAIT is not set")
        }
        guard let missed = LockglowScreenshotTests.missedWord else {
            throw XCTSkip("the Tekrar round missed no word")
        }
        executionTimeAllowance = 30 * 60
        // A little over Leitner.relearnDelay: the answer was recorded before the summary.
        let due = missed.at.addingTimeInterval(10 * 60 + 20)
        while Date() < due {
            sleep(10)
        }

        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Tekrar"].waitForExistence(timeout: 30), "no tabs")
        app.tabBars.buttons["Tekrar"].tap()
        // "Başla (1 kart)": a due word comes before new ones.
        let start = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Başla")).firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: 10), "no Başla button in Tekrar")
        sleep(1)
        attachScreenshot(of: app, named: "17-tekrar-bekleyen")
        start.tap()
        playRound(app, named: "17-tekrar", quizAnswer: missed.lemma)
        XCTAssertTrue(app.navigationBars["Tur bitti"].waitForExistence(timeout: 5), "the quiz round has no summary")
        sleep(1)
        attachScreenshot(of: app, named: "17-tekrar-tur-ozeti")
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

    // MARK: Tekrar round

    /// Buttons of a round that are not answer options.
    private static let roundControls: Set<String> = [
        "Bitir", "Kelimeyi dinle", "Cümleyi dinle", "Dinle", "Durdur", "Devam", "Geri al", "Neden?",
        "Zordu", "Kolaydı", "Anlamını göster", "Sonraki", "Bunu zaten biliyorum", "Göster", "Buldum",
        "Bulamadım", "Akış", "Tekrar", "Sözlük", "Ayarlar", "Sözlük'te ara",
    ]

    /// Plays a started Tekrar round up to its summary and attaches the first screen of each kind,
    /// named `name` + "-tanis-on", "-tanis-arka", "-hatirla-soru", "-hatirla-yanlis",
    /// "-hatirla-dogru", "-quiz-soru", "-quiz-cevap", "-hatirlama-soru", "-hatirlama-cevap".
    /// "Hatırla" is answered from the meanings read on the "Tanış" backs. With
    /// `missingTheFirstQuestion`, the word of the first question is answered wrong both times.
    /// A gap-fill quiz is answered with the option closest to `quizAnswer`.
    /// Returns the word answered wrong twice.
    @discardableResult
    private func playRound(
        _ app: XCUIApplication,
        named name: String,
        missingTheFirstQuestion: Bool = false,
        quizAnswer: String? = nil
    ) -> String? {
        var meaningOf: [String: String] = [:]
        var wordOf: [String: String] = [:]
        var frontWord: String?
        var missTarget: String?
        var misses = 0
        var missed: String?
        var taken = Set<String>()
        func shot(_ step: String) {
            if taken.insert(step).inserted {
                attachScreenshot(of: app, named: "\(name)-\(step)")
            }
        }
        let reveal = app.buttons["Anlamını göster"]
        let next = app.buttons["Sonraki"]
        let goOn = app.buttons["Devam"]
        let recallHeading = app.descendants(matching: .any)["Şimdi hatırla"]
        let quizHeading = app.descendants(matching: .any)["Boşluğa hangisi gelir?"]
        let show = app.buttons["Göster"]
        let found = app.buttons["Buldum"]
        for _ in 0..<60 {
            if app.navigationBars["Tur bitti"].exists {
                return missed
            }
            if goOn.exists {
                goOn.tap()
                sleep(1)
            } else if reveal.exists {
                // The front: the word, then its "Kelimeyi dinle".
                frontWord = nil
                let labels = screenElements(of: app).map { $0.label }
                if let listen = labels.firstIndex(of: "Kelimeyi dinle"), listen > 0 {
                    frontWord = labels[listen - 1]
                }
                shot("tanis-on")
                reveal.tap()
                _ = next.waitForExistence(timeout: 5)
            } else if next.exists {
                if let word = frontWord, let meaning = shownMeaning(in: app) {
                    meaningOf[word] = meaning
                    wordOf[meaning] = word
                }
                shot("tanis-arka")
                next.tap()
                sleep(1)
            } else if quizHeading.exists {
                let options = answerOptions(in: app)
                shot("quiz-soru")
                let target = quizAnswer?.lowercased() ?? ""
                let choice = options.max { commonPrefixLength($0.lowercased(), target) < commonPrefixLength($1.lowercased(), target) }
                guard let pick = choice else {
                    XCTFail("the quiz has no options")
                    return missed
                }
                app.buttons[pick].firstMatch.tap()
                _ = goOn.waitForExistence(timeout: 5)
                sleep(1)
                shot("quiz-cevap")
            } else if recallHeading.exists {
                // "İngilizcesini seç" shows the meaning ("Türkçesi: …"), "Anlamını seç" the word.
                let word: String?
                let answer: String?
                if let meaning = shownMeaning(in: app) {
                    word = wordOf[meaning]
                    answer = word
                } else {
                    let labels = Set(screenElements(of: app).map { $0.label })
                    word = meaningOf.keys.first { labels.contains($0) }
                    answer = word.flatMap { meaningOf[$0] }
                }
                if missingTheFirstQuestion && missTarget == nil, let word = word {
                    missTarget = word
                }
                let options = answerOptions(in: app)
                let wrongOnPurpose = word != nil && word == missTarget && misses < 2
                let pick: String?
                if wrongOnPurpose {
                    pick = options.first { $0 != answer }
                } else if let answer = answer, options.contains(answer) {
                    pick = answer
                } else {
                    pick = options.first
                }
                guard let choice = pick else {
                    XCTFail("the Hatırla question has no options")
                    return missed
                }
                shot("hatirla-soru")
                app.buttons[choice].firstMatch.tap()
                _ = goOn.waitForExistence(timeout: 5)
                sleep(1)
                if wrongOnPurpose {
                    misses += 1
                    if misses == 2 {
                        missed = word
                    }
                    shot("hatirla-yanlis")
                } else if choice == answer {
                    shot("hatirla-dogru")
                }
            } else if show.exists {
                shot("hatirlama-soru")
                show.tap()
                sleep(1)
            } else if found.exists {
                shot("hatirlama-cevap")
                found.tap()
                sleep(1)
            } else {
                sleep(1)
            }
        }
        XCTFail("the Tekrar round did not reach its summary")
        return missed
    }

    /// The Turkish meaning on a card back or a question ("Türkçesi: kahvaltı" → "kahvaltı").
    private func shownMeaning(in app: XCUIApplication) -> String? {
        let prefix = "Türkçesi: "
        guard let label = screenElements(of: app).map({ $0.label }).first(where: { $0.hasPrefix(prefix) }) else {
            return nil
        }
        return label.dropFirst(prefix.count).trimmingCharacters(in: .whitespaces)
    }

    /// Labels of the round's answer options, in screen order.
    private func answerOptions(in app: XCUIApplication) -> [String] {
        return screenElements(of: app)
            .filter { $0.type == .button && !LockglowScreenshotTests.roundControls.contains($0.label) }
            .map { $0.label }
    }

    private func commonPrefixLength(_ a: String, _ b: String) -> Int {
        return zip(a, b).prefix { $0 == $1 }.count
    }

    // MARK: Helpers

    /// Every labelled element on screen in reading order, from one snapshot (one query instead of
    /// one per element).
    private func screenElements(of app: XCUIApplication) -> [(type: XCUIElement.ElementType, label: String)] {
        guard let root = try? app.snapshot() else {
            return []
        }
        var elements: [(type: XCUIElement.ElementType, label: String)] = []
        func collect(_ element: XCUIElementSnapshot) {
            if !element.label.isEmpty {
                elements.append((element.elementType, element.label))
            }
            element.children.forEach(collect)
        }
        collect(root)
        return elements
    }

    /// Waits until the element is gone (a sheet closing), at most `timeout` seconds. It does not
    /// fail: the next step checks what it needs.
    private func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval = 5) {
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)
        _ = XCTWaiter.wait(for: [gone], timeout: timeout)
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
