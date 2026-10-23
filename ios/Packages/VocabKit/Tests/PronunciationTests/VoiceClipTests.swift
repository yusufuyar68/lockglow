import XCTest
import Pronunciation

/// "Kendi sesini dinle": which part of the take is played back, and how much louder.
final class VoiceClipTests: XCTestCase {
    /// 1 000 samples a second: a 20-sample window, 150 samples before, 300 after.
    private let rate = 1_000.0

    private func take(seconds: Double, loud: Range<Int>, level: Float = 0.5) -> [Float] {
        var samples = Array(repeating: Float(0), count: Int(seconds * rate))
        for k in loud {
            samples[k] = k % 2 == 0 ? level : -level
        }
        return samples
    }

    func testSilenceHasNothingToPlay() {
        XCTAssertNil(VoiceClip.speechRange(Array(repeating: 0.001, count: 2_000), sampleRate: rate, threshold: 0.02))
        XCTAssertNil(VoiceClip.speechRange([], sampleRate: rate, threshold: 0.02))
        XCTAssertNil(VoiceClip.speechRange([0.5, 0.5], sampleRate: 0, threshold: 0.02))
    }

    func testKeepsALittleBeforeAndAfterTheSpeech() {
        let samples = take(seconds: 2, loud: 400..<600)
        XCTAssertEqual(VoiceClip.speechRange(samples, sampleRate: rate, threshold: 0.02), 250..<900)
    }

    func testRangeStaysInsideTheTake() {
        let samples = take(seconds: 1, loud: 0..<100)
        XCTAssertEqual(VoiceClip.speechRange(samples, sampleRate: rate, threshold: 0.02), 0..<400)
        let end = take(seconds: 1, loud: 900..<1_000)
        XCTAssertEqual(VoiceClip.speechRange(end, sampleRate: rate, threshold: 0.02), 750..<1_000)
    }

    func testPausesInsideASentenceAreKept() {
        var samples = take(seconds: 3, loud: 200..<400)
        for k in 1_800..<2_000 {
            samples[k] = 0.4
        }
        XCTAssertEqual(VoiceClip.speechRange(samples, sampleRate: rate, threshold: 0.02), 50..<2_300)
    }

    func testQuietTakeIsMadeLouderUpToALimit() {
        XCTAssertEqual(VoiceClip.gain([0.45, -0.3]), 2, accuracy: 0.0001)
        XCTAssertEqual(VoiceClip.gain([0.01, -0.02]), VoiceClip.maxGain)
    }

    func testLoudTakeIsNeverMadeQuieter() {
        XCTAssertEqual(VoiceClip.gain([1, -1]), 1)
        XCTAssertEqual(VoiceClip.gain([0, 0]), 1)
        XCTAssertEqual(VoiceClip.gain([]), 1)
    }
}
