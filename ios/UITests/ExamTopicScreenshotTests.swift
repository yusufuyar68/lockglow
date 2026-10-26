import XCTest

/// The exam words ("YDS / YÖKDİL Çekirdek", B2 and C1), for the screenshot review
/// (`.github/workflows/screenshots.yml`): "Ayarlar > Konular" scrolled to the "Sınavlar" group,
/// and an exam word opened from Sözlük's search. Nothing is chosen or stored: the topic list is
/// left without a tap, so the other tests keep "Tümü".
final class ExamTopicScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureTopicPickerExamGroup() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()
        let tab = app.tabBars.buttons["Ayarlar"]
        XCTAssertTrue(tab.waitForExistence(timeout: 30), "no tabs")
        tab.tap()
        sleep(1)
        // The row's label is "Konular, Tümü"; on an iPhone SE it may sit under the fold.
        let topicsRow = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Konular")).firstMatch
        for _ in 0..<4 where !(topicsRow.exists && topicsRow.isHittable) {
            app.swipeUp()
            sleep(1)
        }
        XCTAssertTrue(topicsRow.waitForExistence(timeout: 5), "no Konular row in Ayarlar")
        topicsRow.tap()
        XCTAssertTrue(app.buttons["topics.all"].waitForExistence(timeout: 5), "no topic list")

        // "Sınavlar" is the last group: scroll until its chip is above the pinned summary line.
        let chip = app.buttons["topics.yds_yokdil_core"]
        let header = app.staticTexts["Sınavlar"]
        for _ in 0..<8 where !(chip.exists && chip.isHittable) {
            app.swipeUp()
            sleep(1)
        }
        XCTAssertTrue(header.exists, "no Sınavlar group in the topic list")
        XCTAssertTrue(chip.exists, "no YDS / YÖKDİL Çekirdek chip (fewer than 5 cards?)")
        if chip.exists {
            XCTAssertTrue(chip.label.hasPrefix("YDS / YÖKDİL Çekirdek"), "chip label: \(chip.label)")
        }
        attachScreenshot(of: app, named: "23a-konular-sinavlar")
    }

    /// "albeit" (C1) from the exam plan; "whereas" (B2) if a content build has no albeit card.
    func testCaptureSozlukExamWord() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()
        let tab = app.tabBars.buttons["Sözlük"]
        XCTAssertTrue(tab.waitForExistence(timeout: 30), "no tabs")
        tab.tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "no search field")

        var opened = false
        for lemma in ["albeit", "whereas"] where !opened {
            field.tap()
            clear(field)
            field.typeText(lemma)
            if let row = onScreenElement(labelled: lemma, in: app) {
                // The row's VoiceOver form is an `accessibilityRepresentation`: tap the visible row.
                row.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                sleep(1)
                opened = true
            }
        }
        guard opened else {
            XCTFail("searching 'albeit' and 'whereas' found nothing")
            return
        }
        attachScreenshot(of: app, named: "23b-sozluk-sinav-kelimesi")
    }

    // MARK: Steps

    /// Empties the search field (the second word is typed only when the first found nothing).
    private func clear(_ field: XCUIElement) {
        guard let text = field.value as? String, !text.isEmpty, text != field.placeholderValue else {
            return
        }
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: text.count))
    }

    /// The first element labelled exactly `label` whose middle is on screen, waiting up to
    /// `timeout` seconds; nil when there is none.
    private func onScreenElement(labelled label: String, in app: XCUIApplication, timeout: TimeInterval = 5) -> XCUIElement? {
        let query = app.descendants(matching: .any).matching(NSPredicate(format: "label ==[c] %@", label))
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            let screen = app.frame
            let match = query.allElementsBoundByIndex.first { candidate in
                let frame = candidate.frame
                return candidate.exists && !frame.isEmpty && screen.contains(CGPoint(x: frame.midX, y: frame.midY))
            }
            if let match = match {
                return match
            }
            sleep(1)
        } while Date() < deadline
        return nil
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
