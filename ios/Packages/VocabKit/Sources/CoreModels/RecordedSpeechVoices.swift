import Foundation

/// The recorded clips in the app bundle (`RecordedSpeech/`, made once by the content pipeline,
/// `vocabpipe.recorded_speech`): a natural AI voice for each accent and character
/// ("us-female", "us-male"), one file per English text of the content. "Dinle" plays a clip when
/// there is one for the text and the settings; otherwise the device's voice reads (`WordSpeech`).
///
/// `voices.json` names the voices and their file type; a clip is
/// `RecordedSpeech/<voice>/<key>.<ext>`, `key` from the text (`key(for:)`, the pipeline's
/// `clip_key`).
public struct RecordedSpeechVoices: Equatable, Sendable {
    /// Voice ("us-female") → file extension ("m4a"), only voices with clips.
    public let extensions: [String: String]

    public init(extensions: [String: String]) {
        self.extensions = extensions
    }

    /// `voices.json`; nil when it is not one.
    public init?(json data: Data) {
        struct Manifest: Decodable {
            struct Voice: Decodable {
                let ext: String
                let clips: Int?
            }
            let format: Int
            let voices: [String: Voice]
        }
        guard let manifest = try? JSONDecoder().decode(Manifest.self, from: data), manifest.format == 1 else {
            return nil
        }
        var extensions: [String: String] = [:]
        for (key, voice) in manifest.voices where (voice.clips ?? 1) > 0 && !voice.ext.isEmpty {
            extensions[key] = voice.ext
        }
        self.init(extensions: extensions)
    }

    /// "us-female": the folder of the accent's and the character's voice.
    public static func voiceKey(accent: SpeechAccent, gender: SpeechVoiceGender) -> String {
        return "\(accent.rawValue)-\(gender.rawValue)"
    }

    /// The recorded voice for `settings` and its file extension. None while a device voice is
    /// chosen by name (the user wants to hear that one) or nothing was recorded in the accent and
    /// the character (then the device's voice of the character reads, not the other recording).
    public func voice(for settings: SpeechSettings) -> (key: String, ext: String)? {
        guard settings.voiceIdentifier == nil else {
            return nil
        }
        let key = Self.voiceKey(accent: settings.accent, gender: settings.gender)
        guard let ext = extensions[key] else {
            return nil
        }
        return (key, ext)
    }

    /// The file name of `text`'s clip: the first 16 hex digits of the SHA-1 of the text without
    /// the spaces and line breaks around it, in UTF-8.
    public static func key(for text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let digest = SHA1.hash(Array(trimmed.utf8))
        return digest.prefix(8).map { byte in
            let hex = String(byte, radix: 16)
            return byte < 16 ? "0" + hex : hex
        }.joined()
    }

    /// The clips are read at a natural pace: the speed of a reading (`SpeechRules.rateMultiplier`,
    /// 1 = the system's default rate) is the clip's playback rate, as `AVAudioPlayer.rate` takes
    /// it (it keeps the pitch), within what it accepts.
    public static func playbackRate(_ rateMultiplier: Float) -> Float {
        return min(2, max(0.5, rateMultiplier))
    }
}

/// SHA-1 for the clip names only (no security role): CryptoKit is not on Linux, where this is tested.
enum SHA1 {
    static func hash(_ message: [UInt8]) -> [UInt8] {
        var h: [UInt32] = [0x6745_2301, 0xEFCD_AB89, 0x98BA_DCFE, 0x1032_5476, 0xC3D2_E1F0]
        var bytes = message
        let bitLength = UInt64(message.count) * 8
        bytes.append(0x80)
        while bytes.count % 64 != 56 {
            bytes.append(0)
        }
        for shift in stride(from: 56, through: 0, by: -8) {
            bytes.append(UInt8(truncatingIfNeeded: bitLength >> UInt64(shift)))
        }
        var w = [UInt32](repeating: 0, count: 80)
        for chunk in stride(from: 0, to: bytes.count, by: 64) {
            for i in 0..<16 {
                let j = chunk + i * 4
                w[i] = UInt32(bytes[j]) << 24 | UInt32(bytes[j + 1]) << 16 | UInt32(bytes[j + 2]) << 8 | UInt32(bytes[j + 3])
            }
            for i in 16..<80 {
                w[i] = rotate(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1)
            }
            var a = h[0], b = h[1], c = h[2], d = h[3], e = h[4]
            for i in 0..<80 {
                let f: UInt32
                let k: UInt32
                switch i {
                case 0..<20:
                    f = (b & c) | (~b & d)
                    k = 0x5A82_7999
                case 20..<40:
                    f = b ^ c ^ d
                    k = 0x6ED9_EBA1
                case 40..<60:
                    f = (b & c) | (b & d) | (c & d)
                    k = 0x8F1B_BCDC
                default:
                    f = b ^ c ^ d
                    k = 0xCA62_C1D6
                }
                let temp = rotate(a, 5) &+ f &+ e &+ k &+ w[i]
                e = d
                d = c
                c = rotate(b, 30)
                b = a
                a = temp
            }
            h[0] = h[0] &+ a
            h[1] = h[1] &+ b
            h[2] = h[2] &+ c
            h[3] = h[3] &+ d
            h[4] = h[4] &+ e
        }
        return h.flatMap { word in
            [UInt8(word >> 24), UInt8(truncatingIfNeeded: word >> 16), UInt8(truncatingIfNeeded: word >> 8), UInt8(truncatingIfNeeded: word)]
        }
    }

    private static func rotate(_ value: UInt32, _ count: UInt32) -> UInt32 {
        return value << count | value >> (32 - count)
    }
}
