import XCTest
import SharedState

final class AppGroupLocatorTests: XCTestCase {
    private var directory: URL!
    private let key = AppGroupLocator.infoPlistKey

    override func setUpWithError() throws {
        directory = try makeTemporaryDirectory("AppGroupLocatorTests")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    /// A flat bundle (Info.plist at the top, like an iOS app) with the given Info.plist entries.
    /// Each call uses a new folder because bundles are cached by path.
    private func bundle(_ info: [String: Any] = [:]) throws -> Bundle {
        let folder = directory.appendingPathComponent("\(UUID().uuidString).bundle", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        var plist = info
        plist["CFBundleIdentifier"] = "test.\(UUID().uuidString)"
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: folder.appendingPathComponent("Info.plist"))
        return try XCTUnwrap(Bundle(path: folder.path))
    }

    func testAnExpandedIdentifierIsReturnedTrimmed() throws {
        XCTAssertEqual(
            AppGroupLocator.groupIdentifier(bundle: try bundle([key: "group.com.example.vocabwidget"])),
            "group.com.example.vocabwidget"
        )
        XCTAssertEqual(
            AppGroupLocator.groupIdentifier(bundle: try bundle([key: "  group.com.example.vocabwidget\n"])),
            "group.com.example.vocabwidget"
        )
    }

    func testUnexpandedBlankOrNonStringValuesAreRejected() throws {
        // The xcconfig was not applied: the build setting is still in the plist literally.
        for value in ["$(APP_GROUP_ID)", "group.$(BUNDLE_ID_PREFIX).vocabwidget", "", " \t\n"] {
            XCTAssertNil(AppGroupLocator.groupIdentifier(bundle: try bundle([key: value])), "value \(value)")
        }
        XCTAssertNil(AppGroupLocator.groupIdentifier(bundle: try bundle([key: 42])))
        XCTAssertNil(AppGroupLocator.groupIdentifier(bundle: try bundle()))
        XCTAssertNil(AppGroupLocator.groupIdentifier(bundle: try bundle(["OtherKey": "group.x"])))
    }

    func testNoIdentifierMeansNoContainer() throws {
        XCTAssertNil(AppGroupLocator.containerURL(bundle: try bundle()))
        XCTAssertNil(AppGroupLocator.containerURL(bundle: try bundle([key: "$(APP_GROUP_ID)"])))
    }
}
