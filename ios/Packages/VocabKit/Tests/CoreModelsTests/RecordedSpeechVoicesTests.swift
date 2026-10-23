import XCTest
import CoreModels

final class RecordedSpeechVoicesTests: XCTestCase {
    /// The pipeline's `clip_key` gives the same names (`test_recorded_speech.py`).
    func testKeysMatchThePipeline() {
        XCTAssertEqual(RecordedSpeechVoices.key(for: "breakfast"), "9e3a8225470fb3b9")
        XCTAssertEqual(RecordedSpeechVoices.key(for: "  I usually have breakfast at seven. "), "bb790f10e2d68902")
        XCTAssertEqual(RecordedSpeechVoices.key(for: "Ayşe"), "fddca89b15ddb988")
        // SHA-1 of the empty text and of a text longer than one 64-byte block.
        XCTAssertEqual(RecordedSpeechVoices.key(for: ""), "da39a3ee5e6b4b0d")
        XCTAssertEqual(
            RecordedSpeechVoices.key(for: "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.\n"),
            "8eb09e076e6afa8a"
        )
        XCTAssertEqual(RecordedSpeechVoices.key(for: "The quick brown fox jumps over the lazy dog"), "2fd4e1c67a2d28fc")
    }

    func testManifestKeepsVoicesWithClips() throws {
        let json = """
        {"format": 1, "voices": {
          "us-female": {"provider": "openai", "name": "nova", "ext": "m4a", "clips": 11358},
          "us-male": {"provider": "openai", "name": "onyx", "ext": "m4a", "clips": 0},
          "uk-female": {"provider": "google", "name": "x", "ext": "mp3", "clips": 12}
        }}
        """
        let voices = try XCTUnwrap(RecordedSpeechVoices(json: Data(json.utf8)))
        XCTAssertEqual(voices.extensions, ["us-female": "m4a", "uk-female": "mp3"])
        XCTAssertNil(RecordedSpeechVoices(json: Data("{\"format\": 2, \"voices\": {}}".utf8)))
        XCTAssertNil(RecordedSpeechVoices(json: Data("nope".utf8)))
    }

    func testTheSettingsPickTheRecordedVoice() {
        let voices = RecordedSpeechVoices(extensions: ["us-female": "m4a", "us-male": "m4a"])
        var settings = SpeechSettings.standard
        XCTAssertEqual(voices.voice(for: settings)?.key, "us-female")
        settings.gender = .male
        XCTAssertEqual(voices.voice(for: settings)?.key, "us-male")
        // Nothing recorded in British: the device's voice reads.
        settings.accent = .british
        XCTAssertNil(voices.voice(for: settings))
        // A device voice chosen by name is heard instead of the recording.
        settings.accent = .american
        settings.voiceIdentifiers[.american] = "com.apple.voice.premium.en-US.Ava"
        XCTAssertNil(voices.voice(for: settings))
        settings.voiceIdentifiers[.british] = "x"
        settings.voiceIdentifiers[.american] = nil
        XCTAssertEqual(voices.voice(for: settings)?.key, "us-male")
    }

    func testPlaybackRateFollowsTheSpeed() {
        XCTAssertEqual(RecordedSpeechVoices.playbackRate(SpeechRate.fast.defaultRateMultiplier), 1, accuracy: 0.0001)
        XCTAssertEqual(RecordedSpeechVoices.playbackRate(SpeechRate.normal.defaultRateMultiplier), 0.9, accuracy: 0.0001)
        XCTAssertEqual(RecordedSpeechVoices.playbackRate(0.1), 0.5, accuracy: 0.0001)
    }
}
