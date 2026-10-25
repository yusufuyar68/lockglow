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
