import XCTest
import SharedState

/// A bundle whose Info.plist values the test chooses.
private final class FakeInfoBundle: Bundle {
    private let strings: [String: String]
    private let numbers: [String: Int]

    /// `path` must be an existing, unused folder (bundles are cached by path).
    init?(path: String, strings: [String: String] = [:], numbers: [String: Int] = [:]) {
        self.strings = strings
        self.numbers = numbers
        super.init(path: path)
    }

    override func object(forInfoDictionaryKey key: String) -> Any? {
        if let string = strings[key] {
            return string
        }
        return numbers[key]
    }
}

final class AppGroupLocatorTests: XCTestCase {
    private var directory: URL!
    private let key = AppGroupLocator.infoPlistKey

    override func setUpWithError() throws {
        directory = try makeTemporaryDirectory("AppGroupLocatorTests")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func bundle(strings: [String: String] = [:], numbers: [String: Int] = [:]) throws -> Bundle {
        let folder = directory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return try XCTUnwrap(FakeInfoBundle(path: folder.path, strings: strings, numbers: numbers))
    }

    func testAnExpandedIdentifierIsReturnedTrimmed() throws {
        XCTAssertEqual(
            AppGroupLocator.groupIdentifier(bundle: try bundle(strings: [key: "group.com.example.vocabwidget"])),
            "group.com.example.vocabwidget"
        )
        XCTAssertEqual(
            AppGroupLocator.groupIdentifier(bundle: try bundle(strings: [key: "  group.com.example.vocabwidget\n"])),
            "group.com.example.vocabwidget"
        )
    }

    func testUnexpandedBlankOrNonStringValuesAreRejected() throws {
        // The xcconfig was not applied: the build setting is still in the plist literally.
        for value in ["$(APP_GROUP_ID)", "group.$(BUNDLE_ID_PREFIX).vocabwidget", "", " \t\n"] {
            XCTAssertNil(AppGroupLocator.groupIdentifier(bundle: try bundle(strings: [key: value])), "value \(value)")
        }
        XCTAssertNil(AppGroupLocator.groupIdentifier(bundle: try bundle(numbers: [key: 42])))
        XCTAssertNil(AppGroupLocator.groupIdentifier(bundle: try bundle()))
        XCTAssertNil(AppGroupLocator.groupIdentifier(bundle: try bundle(strings: ["OtherKey": "group.x"])))
    }

    func testNoIdentifierMeansNoContainer() throws {
        XCTAssertNil(AppGroupLocator.containerURL(bundle: try bundle()))
        XCTAssertNil(AppGroupLocator.containerURL(bundle: try bundle(strings: [key: "$(APP_GROUP_ID)"])))
    }
}
