import XCTest

/// Behaviour and screenshots of the actual A card. Runs on fresh simulators in
/// native-transfer.yml. Does not replace physical-device audio/widget checks.
final class NativeTransferTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        executionTimeAllowance = 150
    }

    func testFeedReadingOrderAndUndo() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-lockglow.onboardingCompleted", "YES",
            "-lockglow.startLevel", "A1",
            "-lockglow.feedHintSeen", "YES"
        ]
        let isAX = ProcessInfo.processInfo.environment["LOCKGLOW_NATIVE_AX"] == "1"
        if isAX {
            app.launchArguments += [
                "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"
            ]
        }
        app.launch()

        let word = app.staticTexts.matching(NSPredicate(format: "label == %@", "breakfast")).firstMatch
        XCTAssertTrue(word.waitForExistence(timeout: 30), "A1's first card did not load")
        let meaning = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "kahvaltı")).firstMatch
        XCTAssertTrue(meaning.waitForExistence(timeout: 5), "Turkish meaning is missing")
        let listen = app.buttons["Kelimeyi dinle"].firstMatch
        XCTAssertTrue(listen.waitForExistence(timeout: 5), "Listen control is missing")
        // Frames retain content coordinates in the natural AX scroll. Compare reading
        // order before scrolling: word, Turkish meaning, then the controls.
        XCTAssertLessThanOrEqual(word.frame.minY, meaning.frame.minY)
        XCTAssertLessThanOrEqual(meaning.frame.minY, listen.frame.minY)
        XCTAssertGreaterThanOrEqual(word.frame.minX, app.frame.minX - 1)
        XCTAssertLessThanOrEqual(word.frame.maxX, app.frame.maxX + 1)
        capture(app, "native-a-feed")

        let know = app.buttons["feed.known.1"]
        reach(know, app: app)
        XCTAssertTrue(know.isHittable, "Known control is unreachable")
        XCTAssertFalse(know.isSelected, "Fresh word should not be marked known")
        XCTAssertGreaterThanOrEqual(know.frame.width, 43)
        XCTAssertGreaterThanOrEqual(know.frame.height, 43)
        know.tap()
        waitForSelection(true, on: know)
        capture(app, "native-a-known")
        reach(know, app: app)
        XCTAssertTrue(know.isHittable, "Undo control is unreachable")
        know.tap()
        waitForSelection(false, on: know)
        capture(app, "native-a-undo")
        XCTAssertEqual(app.state, .runningForeground)
    }

    func testOversizedCardScrollAndWhySheet() throws {
        executionTimeAllowance = 240
        let app = XCUIApplication()
        app.launchArguments = ["-lockglow.nativeOversizedCard"]
        app.launch()
        defer { app.terminate() }

        let inner = app.scrollViews["feed.content-scroll.900002"].firstMatch
        let pager = app.scrollViews["native-harness.pager"].firstMatch
        let secondPage = app.descendants(matching: .any)["native-harness.second-page"].firstMatch
        XCTAssertTrue(inner.waitForExistence(timeout: 10), "The fixture must use the real card's inner scrolling fallback.")
        XCTAssertTrue(pager.waitForExistence(timeout: 5), "The inner scroll must remain inside a vertical pager.")
        XCTAssertGreaterThan(inner.frame.height, 0)
        XCTAssertLessThanOrEqual(inner.frame.width, app.frame.width + 1)
        capture(app, "native-a-oversized-top")

        let why = app.buttons["Neden?"].firstMatch
        for _ in 0..<20 {
            assertSecondPageHidden(secondPage, pager: pager)
            if why.isHittable { break }
            // Only the real inner scroll receives the gesture; the outer pager must stay put.
            inner.swipeUp()
            assertSecondPageHidden(secondPage, pager: pager)
        }
        XCTAssertTrue(why.waitForExistence(timeout: 5), "The warning action must remain in the long card.")
        XCTAssertTrue(why.isHittable, "Twenty inner swipes must reach the final warning action.")
        assertSecondPageHidden(secondPage, pager: pager)
        capture(app, "native-a-oversized-bottom")

        why.tap()
        let close = app.buttons["Kapat"].firstMatch
        XCTAssertTrue(close.waitForExistence(timeout: 5), "The real explanation sheet must open.")
        XCTAssertTrue(app.navigationBars["Neden?"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Sahte dost"].firstMatch.waitForExistence(timeout: 5))
        let correctWord = app.staticTexts["current"].firstMatch
        XCTAssertTrue(correctWord.waitForExistence(timeout: 5), "The sheet must contain the actual false-friend explanation.")
        XCTAssertTrue(correctWord.isHittable, "The explanation content must be visible, rather than a blank sheet with a close button.")
        capture(app, "native-a-oversized-why")
        close.tap()

        let returned = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            !close.exists && why.isHittable
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [returned], timeout: 5), .completed, "Closing the sheet must return to the reachable card action.")
        XCTAssertTrue(inner.exists)
        assertSecondPageHidden(secondPage, pager: pager)
        capture(app, "native-a-oversized-return")
        XCTAssertEqual(app.state, .runningForeground)
    }

    private func assertSecondPageHidden(_ marker: XCUIElement, pager: XCUIElement) {
        XCTAssertFalse(marker.isHittable, "An inner swipe must not turn the outer pager to its second page.")
        if marker.exists {
            let overlap = marker.frame.intersection(pager.frame)
            XCTAssertTrue(overlap.isNull || overlap.height <= 1,
                          "No part of the second page may enter the pager viewport during inner scrolling.")
        }
    }

    private func reach(_ element: XCUIElement, app: XCUIApplication) {
        for _ in 0..<6 where !element.isHittable {
            app.swipeUp()
        }
    }

    private func waitForSelection(_ selected: Bool, on element: XCUIElement) {
        let predicate = NSPredicate { _, _ in element.exists && element.isSelected == selected }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
