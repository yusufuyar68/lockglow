import XCTest

/// Sözlük's word page after the redesign (mockup A4-A6): "borrow" shows "Karıştırma" with
/// "lend", the lend page links back to borrow, and the page at an accessibility text size. Like
/// `LockglowScreenshotTests` it only checks that the screens can be reached and attaches a
/// screenshot of each (`.github/workflows/screenshots.yml`). It needs nothing of the install but
/// the content, so it does not mind running after the other class.
final class SozlukLinkScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureConfusableLink() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()
        try openWord("borrow", in: app)
        attachScreenshot(of: app, named: "17a-sozluk-karistirma")

        // The "Karıştırma" row's English part is an element of its own, labelled with the word
        // alone (`SozlukRowSpeech`); the Dikkat sentences that mention "lend" are longer labels.
        var lend = onScreenElement(labelled: "lend", in: app, timeout: 3)
        if lend == nil {
            app.swipeUp()
            lend = onScreenElement(labelled: "lend", in: app)
        }
        guard let lendRow = lend else {
            XCTFail("no Karıştırma row for lend on the borrow page")
            return
        }
        lendRow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        sleep(1)
        attachScreenshot(of: app, named: "17b-sozluk-karistirma-lend")

        // The lend page links back to borrow: the link goes one step back. The borrow page stays
        // on the stack, off screen, with its own "borrow" heading: only an element on screen counts.
        guard let borrowRow = onScreenElement(labelled: "borrow", in: app) else {
            XCTFail("no Karıştırma row for borrow on the lend page")
            return
        }
        borrowRow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        sleep(1)
        attachScreenshot(of: app, named: "17c-sozluk-karistirma-geri")
    }

    /// The word page at accessibility size L: the facts wrap, the example speakers go under their
    /// sentences, the Dikkat labels above theirs.
    func testCaptureWordPageLargeText() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-lockglow.onboardingCompleted", "YES",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityL",
        ]
        app.launch()
        try openWord("borrow", in: app)
        attachScreenshot(of: app, named: "17d-sozluk-buyuk-yazi")
        app.swipeUp()
        sleep(1)
        attachScreenshot(of: app, named: "17e-sozluk-buyuk-yazi-alt")
    }

    /// Sözlük, `lemma` typed in the field, its result row opened.
    private func openWord(_ lemma: String, in app: XCUIApplication) throws {
        let tab = app.tabBars.buttons["Sözlük"]
        XCTAssertTrue(tab.waitForExistence(timeout: 30), "no tabs")
        tab.tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "no search field")
        field.tap()
        field.typeText(lemma)
        guard let row = onScreenElement(labelled: lemma, in: app) else {
            XCTFail("searching '\(lemma)' found nothing")
            throw XCTSkip("no result for \(lemma)")
        }
        // The row's VoiceOver form is an `accessibilityRepresentation`: tap the visible row there.
        row.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        sleep(1)
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
