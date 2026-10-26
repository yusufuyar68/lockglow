import XCTest

/// The real opening journey, on a disposable simulator; no fake content or storage reset.
final class NativeOnboardingTests: XCTestCase {
    private var app: XCUIApplication?

    override func setUpWithError() throws {
        guard ProcessInfo.processInfo.environment["LOCKGLOW_NATIVE_UI_TESTS"] == "1" else {
            throw XCTSkip("Requires the disposable native-transfer CI simulator")
        }
        #if !targetEnvironment(simulator)
        throw XCTSkip("Native transfer fixtures never modify physical-device data")
        #endif
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
        let start = app.buttons["onboarding.start"]
        let reveal = app.buttons["onboarding.reveal"]
        // The real A1 food fixture is spoon (2). The card exposes its visible Turkish
        // meaning through this accessibility label; start already existed before reveal.
        let meaning = app.staticTexts.matching(NSPredicate(format: "label == %@", "Türkçesi: kaşık")).firstMatch
        waitUntil("The real meaning must appear and the outgoing guess card must leave") {
            app.state == .runningForeground && start.exists && meaning.exists && !reveal.exists
        }
        let firstWordScroll = app.scrollViews.firstMatch
        reachFirstWordMeaning(meaning, in: firstWordScroll, app: app)
        // The current reveal crossfade is 0.25 s. Require a longer visible plateau,
        // measured between completed samples rather than counting slow XCTest queries.
        waitForStableFrames(of: [start, meaning]) {
            app.state == .runningForeground && !reveal.exists
                && self.isFullyVisible(meaning, in: firstWordScroll, app: app)
        }
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
        let cardID = "feed.card.\(knownID.dropFirst("feed.known.".count))"
        let retainedCard = app.descendants(matching: .any)[cardID].firstMatch
        let feedScroll = app.scrollViews.firstMatch
        let tabBar = app.tabBars.firstMatch
        let toastUndo = app.buttons["Geri al"].firstMatch
        waitUntil("The transient undo notice must leave before checking the retained card") {
            !toastUndo.exists
        }
        // A known-state label can grow to two AX lines and move the controls. Wait for
        // the same selected button to settle fully in the same card, without another tap
        // or a post-claim gesture that could hide an unintended move to a different card.
        waitForStableFrames(of: [known]) {
            guard app.state == .runningForeground, !toastUndo.exists,
                  retainedCard.exists, tabBar.exists, known.isSelected,
                  self.isFullyVisible(known, in: feedScroll, app: app) else { return false }
            let cardFrame = retainedCard.frame
            let knownFrame = known.frame
            return !cardFrame.isNull && !cardFrame.isEmpty
                && cardFrame.insetBy(dx: -1, dy: -1).contains(knownFrame)
                && knownFrame.maxY <= tabBar.frame.minY + 1
        }
        XCTAssertTrue(app.buttons[knownID].isHittable, "A normal claim must keep the current card in place")
        capture(app, "native-onboarding-known-in-feed")

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

    /// Scroll the real opening content toward the meaning's measured frame. A revealed
    /// card can grow above or below the old scroll position, especially at AX sizes.
    private func reachFirstWordMeaning(_ meaning: XCUIElement, in scroll: XCUIElement, app: XCUIApplication) {
        XCTAssertTrue(scroll.waitForExistence(timeout: 15), "The opening's real scroll must exist")
        for _ in 0..<10 {
            if isFullyVisible(meaning, in: scroll, app: app) { return }
            let viewport = scroll.frame.intersection(app.frame)
            let frame = meaning.frame
            guard !viewport.isNull, !viewport.isEmpty, !frame.isNull, !frame.isEmpty else {
                XCTFail("The meaning and its scroll must have measurable frames")
                return
            }
            let above = frame.minY < viewport.minY - 1
            let below = frame.maxY > viewport.maxY + 1
            guard above != below else {
                XCTFail("The meaning is occluded or too tall; no safe scroll direction can be inferred")
                return
            }
            let from = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: above ? 0.38 : 0.72))
            let to = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: above ? 0.72 : 0.38))
            from.press(forDuration: 0.1, thenDragTo: to)
        }
        XCTAssertTrue(isFullyVisible(meaning, in: scroll, app: app), "The actual Turkish meaning must be fully reachable")
    }

    private func isFullyVisible(_ element: XCUIElement, in scroll: XCUIElement, app: XCUIApplication) -> Bool {
        guard element.exists, element.isHittable else { return false }
        let viewport = scroll.frame.intersection(app.frame)
        let frame = element.frame
        return !viewport.isNull && !viewport.isEmpty && !frame.isNull && !frame.isEmpty
            && viewport.insetBy(dx: -1, dy: -1).contains(frame)
    }

    /// Same slow-query-safe plateau rule as NativeTransferTests.waitForStableFrames.
    /// Public XCUITest exposes frames and hit testing, not a SwiftUI opacity value.
    private func waitForStableFrames(of elements: [XCUIElement], whileReady ready: @escaping () -> Bool) {
        var previousFrames: [CGRect]?
        var stableSince: TimeInterval?
        let predicate = NSPredicate { _, _ in
            let sampleStarted = ProcessInfo.processInfo.systemUptime
            guard ready(), elements.allSatisfy({ $0.exists && $0.isHittable }) else {
                previousFrames = nil
                stableSince = nil
                return false
            }
            let frames = elements.map { $0.frame }
            guard frames.allSatisfy({ !$0.isNull && !$0.isEmpty }) else {
                previousFrames = nil
                stableSince = nil
                return false
            }
            guard let previous = previousFrames, previous == frames, let since = stableSince else {
                previousFrames = frames
                stableSince = ProcessInfo.processInfo.systemUptime
                return false
            }
            return sampleStarted - since >= 0.35
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 15), .completed,
                       "The visible meaning and start control must remain stable for at least 0.35 seconds before capture")
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
        XCTAssertEqual(app.state, .runningForeground)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
