import XCTest

/// Behaviour and screenshots of the actual A card. Runs on fresh simulators in
/// native-transfer.yml. Does not replace physical-device audio/widget checks.
final class NativeTransferTests: XCTestCase {
    private var launchedApp: XCUIApplication?

    override func setUpWithError() throws {
        continueAfterFailure = false
        executionTimeAllowance = 300
    }

    override func tearDownWithError() throws {
        guard let app = launchedApp else { return }
        defer {
            if app.state != .notRunning { app.terminate() }
            launchedApp = nil
        }
        if (testRun?.failureCount ?? 0) > 0 && app.state == .runningForeground {
            capture(app, "native-a-failure")
            attachText(app.debugDescription, name: "native-a-failure-hierarchy")
            let known = app.buttons["feed.known.1"]
            let exists = known.exists
            let state = exists ? "selected=\(known.isSelected), frame=\(known.frame)" : "button missing"
            let knownLabels = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Bildiğin kelime"))
                .allElementsBoundByIndex.map { $0.label }
            attachText("exists=\(exists), \(state), knownLabels=\(knownLabels)", name: "native-a-failure-known-state")
        }
    }

    func testFeedReadingOrderAndUndo() throws {
        let app = XCUIApplication()
        launchedApp = app
        app.launchArguments = [
            "-lockglow.onboardingCompleted", "YES",
            "-lockglow.startLevel", "A1",
            "-lockglow.feedHintSeen", "YES",
            "-lockglow.nativeDiagnostics"
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
        if isAX {
            XCTAssertGreaterThan(word.frame.height, 60, "The accessibility variant must actually render enlarged word text.")
        }
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
        capture(app, "native-a-known-transition")
        waitForSelection(true, on: know)
        let knownState = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Bildiğin kelime")).firstMatch
        XCTAssertTrue(knownState.waitForExistence(timeout: 15), "The visible word state must also become known.")
        reach(know, app: app)
        XCTAssertTrue(know.isHittable, "Undo control is unreachable")
        if !isAX {
            let visibleKnownState = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
                knownState.exists && knownState.isHittable
            }, object: nil)
            XCTAssertEqual(XCTWaiter.wait(for: [visibleKnownState], timeout: 15), .completed,
                           "The known word state must be visible before its stable capture.")
        }
        let toastUndo = app.buttons["Geri al"].firstMatch
        let toastGone = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            !toastUndo.exists
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [toastGone], timeout: 15), .completed,
                       "The transient undo notice must leave before the stable known-state capture.")
        waitForStableFrames(of: [know, knownState])
        capture(app, "native-a-known-stable")
        know.tap()
        capture(app, "native-a-undo-transition")
        waitForSelection(false, on: know)
        let knownStateGone = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            !knownState.exists
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [knownStateGone], timeout: 15), .completed,
                       "The known label must disappear after returning the word to learning.")
        waitForStableFrames(of: [know, listen])
        capture(app, "native-a-undo-stable")
        XCTAssertEqual(app.state, .runningForeground)
    }

    func testOversizedCardScrollAndWhySheet() throws {
        executionTimeAllowance = 300
        let app = XCUIApplication()
        launchedApp = app
        app.launchArguments = ["-lockglow.nativeOversizedCard"]
        app.launch()

        let inner = app.scrollViews["feed.card.900002"].firstMatch
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
        capture(app, "native-a-oversized-why")
        // The background card also contains "current". Select the actual visible modal text,
        // rather than the first matching (dimmed background) element in the whole app.
        let currentWords = app.staticTexts.matching(NSPredicate(format: "label == %@", "current"))
        let sheetTop = app.navigationBars["Neden?"].frame.maxY
        let visibleExplanation = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            currentWords.allElementsBoundByIndex.contains { element in
                element.exists && element.isHittable && element.frame.minY >= sheetTop - 2
            }
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [visibleExplanation], timeout: 15), .completed,
                       "The visible sheet must contain the actual false-friend explanation.")
        close.tap()

        let returned = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            !close.exists && why.isHittable
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [returned], timeout: 5), .completed, "Closing the sheet must return to the reachable card action.")
        XCTAssertTrue(inner.exists)
        assertSecondPageHidden(secondPage, pager: pager)
        capture(app, "native-a-oversized-return")

        // Reading the whole card must still allow the next word: start inside the inner scroll,
        // then continue normal gestures in the same viewport without setting offsets or tapping.
        for attempt in 0..<6 {
            if isSecondPageSettled(secondPage, pager: pager) && !why.isHittable { break }
            if attempt == 0 {
                inner.swipeUp()
            } else {
                pager.swipeUp()
            }
        }
        let nextPage = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            self.isSecondPageSettled(secondPage, pager: pager) && !why.isHittable
        }, object: nil)
        let nextResult = XCTWaiter.wait(for: [nextPage], timeout: 5)
        capture(app, "native-a-oversized-next")
        XCTAssertEqual(nextResult, .completed, "Six normal swipes must leave the finished card and reach the next page.")
        XCTAssertTrue(secondPage.exists, "The positive control must find the second page's actual identifier.")
        XCTAssertTrue(secondPage.isHittable)
        XCTAssertTrue(pager.frame.insetBy(dx: -2, dy: -2).contains(secondPage.frame),
                      "The entire second page must fit inside the pager viewport, including its safe-area allowance.")
        XCTAssertEqual(secondPage.frame.width, pager.frame.width, accuracy: 2)
        XCTAssertEqual(secondPage.frame.height, 500, accuracy: 2)
        XCTAssertFalse(why.isHittable, "The previous card's warning action must no longer be reachable on the next page.")
        XCTAssertEqual(app.state, .runningForeground)
    }

    private func isSecondPageSettled(_ marker: XCUIElement, pager: XCUIElement) -> Bool {
        guard marker.exists && marker.isHittable else { return false }
        let page = marker.frame
        let viewport = pager.frame
        return viewport.width > 0 && viewport.height > 0
            && viewport.insetBy(dx: -2, dy: -2).contains(page)
            && abs(page.width - viewport.width) <= 2 && abs(page.height - 500) <= 2
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
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 15), .completed)
    }

    private func waitForStableFrames(of elements: [XCUIElement]) {
        var previousFrames: [CGRect]?
        var stableSince: TimeInterval?
        let predicate = NSPredicate { _, _ in
            let sampleStarted = ProcessInfo.processInfo.systemUptime
            guard elements.allSatisfy({ $0.exists }) else {
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
                // XCTest queries can be slow. Start the plateau after the whole sample, and
                // measure to the next sample's start so query time cannot satisfy it by itself.
                stableSince = ProcessInfo.processInfo.systemUptime
                return false
            }
            return sampleStarted - since >= 0.35
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 15), .completed,
                       "Visible-state frames must remain unchanged for at least 0.35 seconds before capture.")
    }

    private func attachText(_ text: String, name: String) {
        let attachment = XCTAttachment(string: text)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
