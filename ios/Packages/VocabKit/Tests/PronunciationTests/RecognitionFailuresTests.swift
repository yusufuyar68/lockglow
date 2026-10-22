import XCTest
import Pronunciation

final class RecognitionFailuresTests: XCTestCase {
    func testNoSpeechAndCancelAreNotFailures() {
        XCTAssertFalse(RecognitionFailures.isFailure(domain: "kAFAssistantErrorDomain", code: 1110))
        XCTAssertFalse(RecognitionFailures.isFailure(domain: "kAFAssistantErrorDomain", code: 216))
        XCTAssertFalse(RecognitionFailures.isFailure(domain: "kLSRErrorDomain", code: 301))
    }

    func testOtherErrorsAreFailures() {
        XCTAssertTrue(RecognitionFailures.isFailure(domain: "kAFAssistantErrorDomain", code: 1101))
        XCTAssertTrue(RecognitionFailures.isFailure(domain: "kLSRErrorDomain", code: 201))
        XCTAssertTrue(RecognitionFailures.isFailure(domain: "SFSpeechErrorDomain", code: 12))
        // The code alone is not enough: 1110 in another domain is a failure.
        XCTAssertTrue(RecognitionFailures.isFailure(domain: "kLSRErrorDomain", code: 1110))
    }

    func testSetUpHintAfterTwoFailuresInARow() {
        var streak = RecognitionFailureStreak()
        XCTAssertFalse(streak.recordFailure())
        XCTAssertTrue(streak.recordFailure())
        // It stays until something is heard.
        XCTAssertTrue(streak.recordFailure())
        XCTAssertEqual(streak.count, 3)
    }

    func testSomethingHeardResetsTheStreak() {
        var streak = RecognitionFailureStreak()
        XCTAssertFalse(streak.recordFailure())
        streak.recordHeard()
        XCTAssertEqual(streak.count, 0)
        XCTAssertFalse(streak.recordFailure())
    }
}
