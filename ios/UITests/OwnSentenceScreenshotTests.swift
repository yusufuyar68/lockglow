import UIKit
import XCTest

/// "Kendi cümleni yaz" (OwnSentenceView) for the screenshot review
/// (`.github/workflows/screenshots.yml`): Sözlük → "umbrella" → "Cümle yaz", a sentence without a
/// capital letter or an end mark (the rules' notes), the same sentence written well (the good
/// verdict), and the page at accessibility size L. The simulators of the CI have no Apple
/// Intelligence: the "Öneri · cihazda" panel must not appear there, and the test says so if a
/// runner ever has it. Nothing is stored; the practice count goes up by two on the fresh install.
final class OwnSentenceScreenshotTests: XCTestCase {
    private static let sloppy = "i forgot my umbrella at home"
    private static let good = "I forgot my umbrella at home."

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureOwnSentence() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()
        guard openOwnSentence(for: "umbrella", in: app) else {
            return
        }
        let field = element("ownSentence.field", in: app)

        // 1. No capital letter, no end mark.
        enter(OwnSentenceScreenshotTests.sloppy, into: field, in: app)
        let typed = (field.value as? String) ?? ""
        tapCheck(in: app)
        XCTAssertTrue(element("ownSentence.verdict.caution", in: app).waitForExistence(timeout: 5), "no notes for a sentence without an end mark")
        XCTAssertTrue(element("ownSentence.issue.noEndPunctuation", in: app).exists, "no end mark note")
        XCTAssertFalse(element("ownSentence.issue.missingWord", in: app).exists, "umbrella was not found in the sentence")
        if typed.hasPrefix("i ") {
            XCTAssertTrue(element("ownSentence.issue.noCapital", in: app).exists, "no capital letter note")
        } else {
            // The keyboard wrote the capital letter itself (automatic capitals).
            XCTContext.runActivity(named: "The field holds '\(typed)': the capital letter note is not expected") { _ in }
        }
        assertNoAdvicePanel(in: app)
        attachScreenshot(of: app, named: "21a-kendi-cumlen-notlar")

        // 2. The same sentence, written well.
        clear(field, in: app)
        enter(OwnSentenceScreenshotTests.good, into: field, in: app)
        tapCheck(in: app)
        XCTAssertTrue(element("ownSentence.verdict.good", in: app).waitForExistence(timeout: 5), "a good sentence got notes")
        XCTAssertFalse(element("ownSentence.issue.noEndPunctuation", in: app).exists)
        assertNoAdvicePanel(in: app)
        attachScreenshot(of: app, named: "21b-kendi-cumlen-iyi")
    }

    /// Accessibility size L: the word, the field, the panel and the footer wrap, nothing is cut.
    func testCaptureOwnSentenceLargeText() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-lockglow.onboardingCompleted", "YES",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityL",
        ]
        app.launch()
        guard openOwnSentence(for: "umbrella", in: app) else {
            return
        }
        let field = element("ownSentence.field", in: app)
        enter(OwnSentenceScreenshotTests.sloppy, into: field, in: app)
        tapCheck(in: app)
        XCTAssertTrue(element("ownSentence.verdict.caution", in: app).waitForExistence(timeout: 5), "no notes at accessibility size L")
        assertNoAdvicePanel(in: app)
        attachScreenshot(of: app, named: "21c-kendi-cumlen-buyuk-yazi")
    }

    // MARK: Steps

    /// Sözlük, `lemma` searched, its page, then "Cümle yaz"; false (and a failure) when a step
    /// is missing.
    private func openOwnSentence(for lemma: String, in app: XCUIApplication) -> Bool {
        let tab = app.tabBars.buttons["Sözlük"]
        XCTAssertTrue(tab.waitForExistence(timeout: 30), "no tabs")
        tab.tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5), "no search field")
        search.tap()
        search.typeText(lemma)
        guard let row = onScreenElement(labelled: lemma, in: app) else {
            XCTFail("searching '\(lemma)' found nothing")
            return false
        }
        // The row's VoiceOver form is an `accessibilityRepresentation`: tap the visible row there.
        row.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        let button = app.buttons["sozluk.ownSentence"]
        guard button.waitForExistence(timeout: 10) else {
            XCTFail("no Cümle yaz button on the \(lemma) page")
            return false
        }
        for _ in 0..<4 where !button.isHittable {
            app.swipeUp()
        }
        button.tap()
        let field = element("ownSentence.field", in: app)
        guard field.waitForExistence(timeout: 10) else {
            XCTFail("Cümle yaz did not open the page")
            return false
        }
        sleep(1)
        return true
    }

    /// Puts `text` into the field. Pasted when the edit menu offers "Paste", so the keyboard's
    /// automatic capital letter does not change the first word; typed otherwise.
    private func enter(_ text: String, into field: XCUIElement, in app: XCUIApplication) {
        UIPasteboard.general.string = text
        field.press(forDuration: 1.2)
        if let paste = menuItem(named: ["Paste", "Yapıştır"], in: app, timeout: 3) {
            paste.tap()
        } else {
            field.tap()
            field.typeText(text)
        }
        sleep(1)
    }

    /// The first edit-menu item with one of `names`, waiting up to `timeout` seconds.
    private func menuItem(named names: [String], in app: XCUIApplication, timeout: TimeInterval) -> XCUIElement? {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            for name in names where app.menuItems[name].exists {
                return app.menuItems[name]
            }
            usleep(250_000)
        } while Date() < deadline
        return nil
    }

    /// Empties the field: the cursor at its end, then one delete per character and a few more.
    private func clear(_ field: XCUIElement, in app: XCUIApplication) {
        // The result scrolled the page: a tap brings the field back into view first.
        field.tap()
        sleep(1)
        field.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9)).tap()
        sleep(1)
        let count = ((field.value as? String) ?? "").count + 5
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: count))
    }

    /// "Kontrol et" is in the bottom bar, above the keyboard too.
    private func tapCheck(in app: XCUIApplication) {
        let check = app.buttons["ownSentence.check"]
        XCTAssertTrue(check.waitForExistence(timeout: 5), "no Kontrol et button")
        check.tap()
        // The keyboard goes down and the result scrolls into view.
        sleep(2)
    }

    /// No Apple Intelligence on the CI simulators: no suggestion panel, not even its spinner.
    private func assertNoAdvicePanel(in app: XCUIApplication) {
        XCTAssertFalse(element("ownSentence.advice", in: app).exists, "the Öneri panel appeared: this runner has Apple Intelligence")
        XCTAssertFalse(app.staticTexts["Öneri · cihazda"].exists, "the Öneri panel appeared: this runner has Apple Intelligence")
    }

    // MARK: Helpers

    /// The first element with this identifier, whatever its kind (a vertical text field is a
    /// text view; a panel's verdict is a combined element).
    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        return app.descendants(matching: .any).matching(identifier: identifier).firstMatch
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
