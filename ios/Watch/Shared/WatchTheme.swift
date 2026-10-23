import SwiftUI

/// Lockglow's colors and type on the watch (is5-watch). The watch is always dark, so these are the
/// night ("Gece") values of `Theme` in ios/Shared/LockglowTheme.swift, which is not compiled for
/// watchOS (it builds its colors with UIKit's dynamic providers). Yellow stays on the English word
/// alone (rule 1); English is serif, Turkish and the interface are SF Pro.
enum WatchTheme {
    static let band = tone(0xE9E040)
    static let ink = tone(0xF3F4F0)
    static let ink2 = tone(0xB7BDC2)
    static let ink3 = tone(0x8E959B)
    /// The Smart Stack card behind the rectangular complication (the face itself draws none).
    static let surface = tone(0x191C20)

    enum Fonts {
        /// The English word in the app.
        static let word = Font.system(.title3, design: .serif).weight(.bold)
        /// The Turkish meaning in the app: right under the word, before the example.
        static let meaning = Font.headline
        /// The English example sentence.
        static let example = Font.system(.footnote, design: .serif)
        /// Helper lines (the seed note, "Tamam").
        static let helper = Font.footnote
    }

    private static func tone(_ hex: UInt32) -> Color {
        return Color(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension View {
    /// English text: VoiceOver reads it with an English voice (the same rule as `englishVoice()` on
    /// the phone). On the English Text itself, never on a container with Turkish text in it.
    func watchEnglishVoice() -> some View {
        environment(\.locale, Locale(identifier: "en_US"))
    }

    /// Turkish text and controls: set on each screen and complication as a whole, so VoiceOver reads
    /// the meaning, the buttons and the hints with a Turkish voice (the app is not localized).
    func watchTurkishVoice() -> some View {
        environment(\.locale, Locale(identifier: "tr_TR"))
    }
}
