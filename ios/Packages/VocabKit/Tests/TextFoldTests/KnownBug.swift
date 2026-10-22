import XCTest

/// Marks a known bug: `actual` should equal `expected` but does not yet.
///
/// Apple XCTest: `XCTExpectFailure` (strict), so the run stays green while the bug is there and
/// fails with "expected failure did not occur" once it is fixed; then delete the marker.
/// swift-corelibs-xctest (Linux CI) has no `XCTExpectFailure`
/// (https://github.com/swiftlang/swift-corelibs-xctest/issues/438): the test is reported as
/// skipped with the reason while the bug is there, and fails once it is fixed.
func expectKnownBug<T: Equatable>(
    _ reason: String,
    actual: T,
    expected: T,
    file: StaticString = #filePath,
    line: UInt = #line
) throws {
    #if canImport(Darwin)
    XCTExpectFailure(reason) {
        XCTAssertEqual(actual, expected, reason, file: file, line: line)
    }
    #else
    if actual == expected {
        XCTFail("Known bug seems fixed, remove expectKnownBug: \(reason)", file: file, line: line)
    } else {
        throw XCTSkip("Known bug: \(reason). Expected \(expected), got \(actual).", file: file, line: line)
    }
    #endif
}
