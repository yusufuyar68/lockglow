import XCTest

/// The real opening journey, on a disposable simulator; no fake content or storage reset.
final class NativeOnboardingTests: XCTestCase {
    private var app: XCUIApplication?

    override func setUpWithError() throws {
        continueAfterFailure = false
        executionTimeAllowance = 900
    }

    override func tearDownWithError() throws {
        guard let app = app else { return }
        if (testRun?.failureCount ?? 0) > 0, app.state == .runningForeground {
            capture(app, "native-onboarding-failure")
            let attachment = XCTAttachment(string: app.debugDescription)
            attachment.name = "native-onboarding-failure-hierarchy"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        if app.state != .notRunning { app.terminate() }
        self.app = nil
    }

    func testChoicesFilterAndPersist() throws {
        let app = launchOpening()
        tap(app.buttons["onboarding.level.A1"], app: app)
        tap(app.buttons["onboarding.next"], app: app)
        tap(app.buttons["topics.food_drink"], app: app)
        tap(app.buttons["onboarding.next"], app: app)
        let daily = app.buttons["onboarding.daily.15"]
        tap(daily, app: app)
        selected(daily, true)
        capture(app, "native-onboarding-daily")
        tap(app.buttons["onboarding.next"], app: app)

        let breakfast = app.buttons["onboarding.known.1"]
        tap(breakfast, app: app)
        selected(breakfast, true)
        let other = app.buttons.matching(NSPredicate(format:
            "identifier BEGINSWITH %@ AND identifier != %@", "onboarding.known.", "onboarding.known.1"))
            .firstMatch
        XCTAssertTrue(other.waitForExistence(timeout: 10), "The real food deck must provide more than one candidate")
        let otherID = other.identifier
        tap(other, app: app)
        selected(other, true)
        tap(other, app: app)
        selected(other, false)
        capture(app, "native-onboarding-known")

        tap(app.buttons["onboarding.back"], app: app)
        selected(daily, true)
        tap(app.buttons["onboarding.next"], app: app)
        selected(breakfast, true)
        selected(app.buttons[otherID], false)
        tap(app.buttons["onboarding.next"], app: app)
        XCTAssertTrue(app.buttons["Ana ekran"].waitForExistence(timeout: 15))
        capture(app, "native-onboarding-widget")

        // A committed selection must be reversible when returning from the live widget guide.
        tap(app.buttons["onboarding.back"], app: app)
        tap(breakfast, app: app)
        selected(breakfast, false)
        tap(app.buttons["onboarding.next"], app: app)
        let preview = app.descendants(matching: .any)["widget.guide.preview"].firstMatch
        waitUntil("Removing the opening claim must restore breakfast to the live guide") {
            preview.exists && (preview.value as? String)?.contains("breakfast") == true
        }
        tap(app.buttons["onboarding.back"], app: app)
        tap(breakfast, app: app)
        selected(breakfast, true)
        tap(app.buttons["onboarding.next"], app: app)
        tap(app.buttons["onboarding.next"], app: app)
        tap(app.buttons["onboarding.reveal"], app: app)
        XCTAssertTrue(app.buttons["onboarding.start"].exists)
        capture(app, "native-onboarding-first-word")
        tap(app.buttons["onboarding.start"], app: app)
        XCTAssertTrue(app.tabBars.buttons["Akış"].waitForExistence(timeout: 15))
        openingWordIsExcluded(app)
        openingStartsAtHeading(app)
        capture(app, "native-onboarding-feed")

        // Normal Biliyorum must retain the visible card, independently of opening exclusions.
        let firstKnown = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "feed.known.")).firstMatch
        XCTAssertTrue(firstKnown.waitForExistence(timeout: 15))
        // Pin identity before scrolling: a lazy feed's firstMatch can change during a gesture.
        let knownID = firstKnown.identifier
        let known = app.buttons[knownID]
        for _ in 0..<12 where !known.isHittable {
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.72))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.42))
            start.press(forDuration: 0.1, thenDragTo: end)
        }
        XCTAssertTrue(known.isHittable, "The pinned current-card control must be reachable")
        known.tap()
        selected(app.buttons[knownID], true)
        XCTAssertTrue(app.buttons[knownID].isHittable, "A normal claim must keep the current card in place")

        app.terminate()
        app.launchArguments = ["-lockglow.feedHintSeen", "YES"]
        addAccessibilityArguments(app)
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Akış"].waitForExistence(timeout: 30))
        XCTAssertFalse(app.buttons["onboarding.level.A1"].exists, "A completed opening must stay completed after relaunch")
        openingWordIsExcluded(app)
        openingStartsAtHeading(app)
        XCTAssertTrue(app.buttons[knownID].waitForExistence(timeout: 15),
                      "A normal manual claim must not become an opening exclusion on relaunch")
        capture(app, "native-onboarding-relaunch")

        // Reopening reads the persisted goal rather than forced daily/level launch arguments.
        app.terminate()
        app.launchArguments = ["-lockglow.onboardingCompleted", "NO"]
        addAccessibilityArguments(app)
        app.launch()
        XCTAssertTrue(app.buttons["onboarding.level.A1"].waitForExistence(timeout: 30))
        tap(app.buttons["onboarding.next"], app: app)
        tap(app.buttons["onboarding.next"], app: app)
        selected(app.buttons["onboarding.daily.15"], true)
        capture(app, "native-onboarding-persisted-goal")
        tap(app.buttons["onboarding.skip"], app: app)
        XCTAssertTrue(app.tabBars.buttons["Akış"].waitForExistence(timeout: 15))
    }

    func testSkipDoesNotRequireKnownSelection() throws {
        let app = launchOpening()
        XCTAssertTrue(app.buttons["onboarding.skip"].waitForExistence(timeout: 30))
        tap(app.buttons["onboarding.skip"], app: app)
        XCTAssertTrue(app.tabBars.buttons["Akış"].waitForExistence(timeout: 15))
        XCTAssertFalse(app.buttons["onboarding.known.1"].exists)
        capture(app, "native-onboarding-skip")
    }

    private func launchOpening() -> XCUIApplication {
        let app = XCUIApplication()
        self.app = app
        app.launchArguments = ["-lockglow.onboardingCompleted", "NO", "-lockglow.feedHintSeen", "YES"]
        addAccessibilityArguments(app)
        app.launch()
        return app
    }

    private func addAccessibilityArguments(_ app: XCUIApplication) {
        if ProcessInfo.processInfo.environment["LOCKGLOW_NATIVE_AX"] == "1" {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        }
    }

    private func tap(_ element: XCUIElement, app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: 30), file: file, line: line)
        waitUntil("Control must become enabled", file: file, line: line) { element.isEnabled }
        for _ in 0..<10 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.isHittable, "Control is outside the reachable scroll", file: file, line: line)
        element.tap()
    }

    private func selected(_ element: XCUIElement, _ value: Bool, file: StaticString = #filePath, line: UInt = #line) {
        waitUntil("Selection must become \(value)", file: file, line: line) { element.exists && element.isSelected == value }
    }

    private func openingWordIsExcluded(_ app: XCUIApplication) {
        let loadedCard = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "feed.known.")).firstMatch
        waitUntil("The selected opening word must leave the feed") {
            loadedCard.exists && !app.descendants(matching: .any)["feed.card.1"].exists
        }
    }

    private func openingStartsAtHeading(_ app: XCUIApplication) {
        // In the real A1 food deck, spoon (2) follows the excluded breakfast (1).
        // A passing exclusion assertion alone must not hide a tall card opened at its bottom.
        let heading = app.staticTexts.matching(NSPredicate(format: "label == %@", "spoon")).firstMatch
        waitUntil("The first remaining card must open with its whole heading visible") {
            guard heading.exists, heading.isHittable else { return false }
            return heading.frame.minY >= app.frame.minY
                && heading.frame.maxY <= app.tabBars.firstMatch.frame.minY
        }
    }

    private func waitUntil(_ message: String, file: StaticString = #filePath, line: UInt = #line, condition: @escaping () -> Bool) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in condition() }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 15), .completed, message, file: file, line: line)
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
