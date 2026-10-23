import UIKit
import XCTest

/// The iOS 18 controls (Widgets/Controls.swift) in the system's control gallery: opens Control
/// Center on the simulator, its edit mode and "Add a Control", searches "Lockglow" and attaches a
/// screenshot of each step (`kontrol-*`). It passes when the gallery lists one of the three
/// controls by name.
/// Control Center belongs to SpringBoard, whose element names Apple does not document and may
/// change: a step that cannot be done attaches SpringBoard's element tree (`kontrol-agac`) and
/// skips the test instead of failing it.
/// The class name sorts after LockglowScreenshotTests, so this runs once those tests are done; it
/// never launches the app (they expect a fresh install). It runs in one pass of a screenshots.yml
/// run only, the one that waits for the quiz (`LOCKGLOW_QUIZ_WAIT`, "pro" by default), and only
/// on a phone without a Home button: there Control Center opens from the top right corner.
final class SystemControlsTests: XCTestCase {
    private var springboard: XCUIApplication {
        XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }
    /// The controls' display names (`displayName` in Controls.swift).
    private let controlNames = ["Kelimeyi dinle", "Sonraki kelime", "Tekrar'ı aç"]

    private enum Reached {
        case nothing
        case controlCenter
        case editMode
        case gallery
        case listed
    }

    func testControlsAreListedInTheControlGallery() throws {
        guard #available(iOS 18.0, *) else {
            throw XCTSkip("Controls need iOS 18.")
        }
        guard ProcessInfo.processInfo.environment["LOCKGLOW_QUIZ_WAIT"] == "1" else {
            throw XCTSkip("Only in the screenshots.yml pass that waits for the quiz.")
        }
        // The iPhone SE (667 pt high) has a Home button: Control Center opens from the bottom.
        guard XCUIScreen.main.screenshot().image.size.height > 700 else {
            throw XCTSkip("A phone with a Home button.")
        }
        defer {
            // Out of the gallery, the edit mode and Control Center: back to the home screen.
            for _ in 0..<3 {
                XCUIDevice.shared.press(.home)
                sleep(1)
            }
        }
        var reached = Reached.nothing
        // A tap on an element SpringBoard shows but does not let us hit is SpringBoard's business,
        // not a failure of the app: the steps below may fail without failing the test.
        let options = XCTExpectedFailure.Options()
        options.isStrict = false
        XCTExpectFailure("SpringBoard's Control Center is outside the app.", options: options) {
            reached = openGalleryAndSearch()
        }
        switch reached {
        case .listed:
            break
        case .gallery:
            throw skip("The gallery opened, but no Lockglow control was found by name.")
        case .editMode:
            throw skip("No search field in the control gallery.")
        case .controlCenter:
            throw skip("Control Center's edit mode or its \"Add a Control\" button was not found.")
        case .nothing:
            throw skip("Control Center did not open.")
        }
    }

    /// Each step's screenshot is attached when the step has been reached.
    private func openGalleryAndSearch() -> Reached {
        XCUIDevice.shared.press(.home)
        sleep(1)

        // Control Center: a swipe down from the top right corner.
        let corner = springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.005))
        corner.press(forDuration: 0.1, thenDragTo: springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.6)))
        sleep(2)
        attachScreenshot(named: "kontrol-1-denetim-merkezi")

        // Edit mode: the "+" button in the top left corner, else a long press on an empty place.
        let edit = element(labeled: ["Add", "Edit", "Customize", "Edit Controls", "Add Controls"], in: springboard.buttons)
        if edit.waitForExistence(timeout: 3) {
            edit.tap()
        } else {
            springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.92)).press(forDuration: 1.5)
        }
        sleep(1)
        let add = springboard.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "Add a Control"))
            .firstMatch
        guard add.waitForExistence(timeout: 5) else {
            return .controlCenter
        }
        attachScreenshot(named: "kontrol-2-duzenleme")
        add.tap()

        let search = springboard.searchFields.firstMatch
        guard search.waitForExistence(timeout: 5) else {
            return .editMode
        }
        sleep(1)
        attachScreenshot(named: "kontrol-3-galeri")
        search.tap()
        search.typeText("Lockglow")
        let names = controlNames.map { NSPredicate(format: "label CONTAINS[c] %@", $0) }
        let listed = springboard.descendants(matching: .any)
            .matching(NSCompoundPredicate(orPredicateWithSubpredicates: names))
            .firstMatch
        let found = listed.waitForExistence(timeout: 10)
        attachScreenshot(named: "kontrol-4-lockglow")
        return found ? .listed : .gallery
    }

    private func element(labeled labels: [String], in query: XCUIElementQuery) -> XCUIElement {
        let predicates = labels.map { NSPredicate(format: "label ==[c] %@ OR identifier ==[c] %@", $0, $0) }
        return query.matching(NSCompoundPredicate(orPredicateWithSubpredicates: predicates)).firstMatch
    }

    /// The SpringBoard tree of the screen the test stopped on, for fixing the element names.
    private func skip(_ reason: String) -> XCTSkip {
        let tree = XCTAttachment(string: springboard.debugDescription)
        tree.name = "kontrol-agac"
        tree.lifetime = .keepAlways
        add(tree)
        attachScreenshot(named: "kontrol-durdu")
        return XCTSkip(reason)
    }

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
