import SwiftUI
import WidgetKit
import AppIntents
import CoreModels

// Interactive buttons (iOS 17 `Button(intent:)`). Used on the home screen families only;
// accessory (Lock Screen) widgets could show buttons, but they do not work while the device is
// locked, so those families have none.
// Order in both home families: Know, speaker, Next (README "Widget'lar"). Next sits in the easy
// corner (bottom right of the small widget, bottom of the medium widget's column); Know, which
// marks a word known without a test, is the farthest from it, and the harmless speaker sits
// between the two buttons that change state.
// All three buttons are icon-only with a text label for VoiceOver; meaning never depends on color.
// Each one is a 34 pt circle (mockup `.wb`) centred in a hit area of at least 44 x 44 pt.
// Next and Know run in the widget extension (`WordActions`); the speaker button runs in the app's
// process (`SpeakWordIntent` is an `AudioPlaybackIntent`).

struct NextWordButton: View {
    let wordID: Int
    let source: WidgetEventSource
    /// The widget's colors for its rendering mode (HomeWordViews.swift).
    var colors = WidgetColors.tokens

    var body: some View {
        Button(intent: NextWordIntent(wordID: wordID, source: source.rawValue)) {
            WidgetButtonFace(title: "Sonraki kelime", systemImage: "forward.fill", colors: colors)
        }
        .buttonStyle(.plain)
    }
}

struct KnowWordButton: View {
    let wordID: Int
    let source: WidgetEventSource
    /// The widget's colors for its rendering mode (HomeWordViews.swift).
    var colors = WidgetColors.tokens

    var body: some View {
        Button(intent: KnowWordIntent(wordID: wordID, source: source.rawValue)) {
            WidgetButtonFace(title: "Biliyorum", systemImage: "checkmark", colors: colors)
        }
        .buttonStyle(.plain)
    }
}

/// Says the word aloud without opening the app. Pass the headword (`WidgetWord.lemma`).
struct SpeakWordButton: View {
    let text: String
    /// The widget's colors for its rendering mode (HomeWordViews.swift).
    var colors = WidgetColors.tokens

    var body: some View {
        Button(intent: SpeakWordIntent(text: text)) {
            WidgetButtonFace(title: "Kelimeyi dinle", systemImage: "speaker.wave.2", colors: colors)
        }
        .buttonStyle(.plain)
        // VoiceOver stays quiet while the word is being read.
        .accessibilityAddTraits(.startsMediaSession)
    }
}

/// A widget button's look: the icon in a 34 pt circle (`surface2` in full color, a faint wash
/// when the system tints the widget), centred in a 44 x 44 pt hit area that is all tappable.
private struct WidgetButtonFace: View {
    let title: LocalizedStringKey
    let systemImage: String
    let colors: WidgetColors

    var body: some View {
        Label(title, systemImage: systemImage)
            .labelStyle(.iconOnly)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(colors.ink)
            .frame(width: 34, height: 34)
            .background(colors.buttonFill, in: Circle())
            .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
            .contentShape(Rectangle())
    }
}
