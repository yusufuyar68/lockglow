import XCTest
import UIKit

/// A key on a hardware keyboard, called by its Objective-C name: some SDKs mark the Swift
/// `typeKey(_:modifierFlags:)` as macOS-only, while the method exists on iPadOS (WebDriverAgent
/// uses it there). `LockglowIPadTests.press` checks that it does before calling it.
@objc private protocol HardwareKeyTyping {
    @objc(typeKey:modifierFlags:)
    func lockglowTypeKey(_ key: String, modifierFlags: UInt)
}

/// The iPad layout (WideLayout.swift) in landscape and portrait: the tabs in a readable column,
/// Sözlük with its list on the left and the word on the right, and the keys of a hardware
/// keyboard: ⌘F opens Sözlük's search, Space shows the meaning and goes on, 1–4 answer.
/// Screenshots for review, like `LockglowScreenshotTests`; not a behaviour test beyond the
/// keys. Runs in the `ipad` pass of screenshots.yml and is skipped on an iPhone. The tests share
/// one install and run in alphabetical order.
final class LockglowIPadTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad, "iPad only")
    }

    /// Akış in landscape, ⌘F to Sözlük, a search and its word on the right; then portrait.
    func testA1SozlukSideBySide() throws {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = launchedApp()
        let firstCard = element(in: app, containing: "breakfast")
        XCTAssertTrue(firstCard.waitForExistence(timeout: 30), "feed did not show the first card")
        sleep(1)
        attach(app, "ipad-1-akis-yatay")

        let field = app.searchFields.firstMatch
        // ⌘F under a sheet does nothing: the tab must not change unseen behind it.
        let why = app.buttons["Neden?"].firstMatch
        if app.responds(to: NSSelectorFromString("typeKey:modifierFlags:")) && why.waitForExistence(timeout: 3) && why.isHittable {
            why.tap()
            let close = app.buttons["Kapat"].firstMatch
            if close.waitForExistence(timeout: 5) {
                _ = press(app, "f", command: true)
                sleep(1)
                attach(app, "ipad-1b-akis-neden-yatay")
                close.tap()
                sleep(1)
                XCTAssertFalse(field.exists, "⌘F changed the tab under the Neden? sheet")
            }
        } else {
            note("no Neden? on the first card: ⌘F under a sheet not tested")
        }
        if press(app, "f", command: true) {
            XCTAssertTrue(field.waitForExistence(timeout: 5), "⌘F did not open Sözlük")
            sleep(1)
            if let focused = hasKeyboardFocus(field) {
                XCTAssertTrue(focused, "⌘F did not put the cursor in the search field")
            } else {
                note("hasKeyboardFocus cannot be read: the field's focus after ⌘F is not checked")
            }
        } else {
            note("typeKey is not available: ⌘F not tested")
            tab(app, "Sözlük").tap()
        }
        XCTAssertTrue(field.waitForExistence(timeout: 5), "no search field")
        if hasKeyboardFocus(field) != true {
            field.tap()
        }
        field.typeText("kahv")
        let hit = element(in: app, containing: "breakfast")
        XCTAssertTrue(hit.waitForExistence(timeout: 5), "searching 'kahv' did not find breakfast")
        sleep(1)
        attach(app, "ipad-2-sozluk-arama-yatay")
        // The row's VoiceOver form is an `accessibilityRepresentation`: tap the visible row there.
        hit.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        // Side by side: the word's page on the right, the search and its list still on the left.
        XCTAssertTrue(app.buttons["Biliyorum"].waitForExistence(timeout: 5), "the word page did not open")
        XCTAssertTrue(field.exists, "the search left the screen: Sözlük is not in two columns")
        sleep(1)
        attach(app, "ipad-3-sozluk-kelime-yatay")

        XCUIDevice.shared.orientation = .portrait
        sleep(2)
        XCTAssertTrue(field.exists, "no search field in portrait")
        attach(app, "ipad-4-sozluk-kelime-dikey")
    }

    /// Tekrar's "Tanış + Hatırla" round with the keys: Space shows the meaning and goes on, 1
    /// answers the first "Hatırla" question, Space is "Devam".
    func testA2TekrarKeys() throws {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = launchedApp()
        let tekrar = tab(app, "Tekrar")
        XCTAssertTrue(tekrar.waitForExistence(timeout: 30), "no tabs")
        tekrar.tap()
        let start = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Başla")).firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: 10), "no Başla button in Tekrar")
        sleep(1)
        attach(app, "ipad-5-tekrar-baslangic-yatay")
        start.tap()

        let reveal = app.buttons["Anlamını göster"]
        let next = app.buttons["Sonraki"]
        let goOn = app.buttons["Devam"]
        let recallHeading = app.descendants(matching: .any)["Şimdi hatırla"]
        XCTAssertTrue(reveal.waitForExistence(timeout: 5), "the round did not start with a word's front")
        attach(app, "ipad-6-tekrar-on-yatay")
        guard press(app, " ") else {
            note("typeKey is not available: Tekrar's keys not tested")
            return
        }
        XCTAssertTrue(next.waitForExistence(timeout: 5), "Space did not show the meaning")
        sleep(1)
        attach(app, "ipad-7-tekrar-arka-yatay")

        // Space through the rest of the "Tanış" cards to the first "Hatırla" question.
        var reachedQuestion = false
        for _ in 0..<30 {
            if recallHeading.exists {
                reachedQuestion = true
                break
            }
            if reveal.exists || next.exists {
                _ = press(app, " ")
            }
            sleep(1)
        }
        XCTAssertTrue(reachedQuestion, "Space did not lead to the first Hatırla question")
        guard reachedQuestion else {
            attach(app, "ipad-8-tekrar-takildi")
            return
        }
        attach(app, "ipad-8-tekrar-hatirla-yatay")
        _ = press(app, "1")
        XCTAssertTrue(goOn.waitForExistence(timeout: 5), "1 did not answer the question")
        sleep(1)
        attach(app, "ipad-9-tekrar-cevap-yatay")

        XCUIDevice.shared.orientation = .portrait
        sleep(2)
        attach(app, "ipad-10-tekrar-cevap-dikey")
        _ = press(app, " ")
        sleep(1)
        XCTAssertFalse(goOn.exists, "Space did not press Devam")
        let finish = app.buttons["Bitir"]
        if finish.exists {
            finish.tap()
        }
    }

    /// The onboarding's first page and Ayarlar in landscape, Ayarlar in portrait.
    func testA3OnboardingAndSettings() throws {
        XCUIDevice.shared.orientation = .landscapeLeft
        let onboarding = XCUIApplication()
        onboarding.launchArguments += ["-lockglow.onboardingCompleted", "NO"]
        onboarding.launch()
        XCTAssertTrue(onboarding.buttons["onboarding.level.A1"].waitForExistence(timeout: 30), "the onboarding did not open")
        sleep(1)
        attach(onboarding, "ipad-11-acilis-yatay")
        onboarding.terminate()

        let app = launchedApp()
        let ayarlar = tab(app, "Ayarlar")
        XCTAssertTrue(ayarlar.waitForExistence(timeout: 30), "no tabs")
        ayarlar.tap()
        sleep(1)
        attach(app, "ipad-12-ayarlar-yatay")
        XCUIDevice.shared.orientation = .portrait
        sleep(2)
        attach(app, "ipad-13-ayarlar-dikey")
    }

    // MARK: Helpers

    private func launchedApp() -> XCUIApplication {
        let app = XCUIApplication()
        // Straight to the tabs.
        app.launchArguments += ["-lockglow.onboardingCompleted", "YES"]
        app.launch()
        return app
    }

    /// A tab: in the tab bar at the bottom (iOS 17) or at the top (iPadOS 18 and later), which
    /// may not be reported as a tab bar.
    private func tab(_ app: XCUIApplication, _ name: String) -> XCUIElement {
        let inTabBar = app.tabBars.buttons[name]
        return inTabBar.exists ? inTabBar : app.buttons[name].firstMatch
    }

    private func element(in app: XCUIApplication, containing text: String) -> XCUIElement {
        return app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", text))
            .firstMatch
    }

    /// Types `key` on the hardware keyboard (with ⌘ when `command`); false when this XCTest
    /// cannot.
    private func press(_ app: XCUIApplication, _ key: String, command: Bool = false) -> Bool {
        guard app.responds(to: NSSelectorFromString("typeKey:modifierFlags:")) else {
            return false
        }
        // XCUIKeyModifierFlags: Command is 1 << 4.
        (app as AnyObject).lockglowTypeKey?(key, modifierFlags: command ? 1 << 4 : 0)
        return true
    }

    /// Whether `element` has the keyboard focus; nil when XCTest does not say.
    private func hasKeyboardFocus(_ element: XCUIElement) -> Bool? {
        guard element.responds(to: NSSelectorFromString("hasKeyboardFocus")) else {
            return nil
        }
        return element.value(forKey: "hasKeyboardFocus") as? Bool
    }

    private func note(_ text: String) {
        XCTContext.runActivity(named: text) { _ in }
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
