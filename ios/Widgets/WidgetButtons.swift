import SwiftUI
import WidgetKit
import AppIntents
import CoreModels

// Interactive buttons (iOS 17 `Button(intent:)`). Used on the home screen families only;
// accessory (Lock Screen) widgets could show buttons, but they do not work while the device is
// locked, so those families have none.
// The small widget has two buttons, speaker and Next, in its bottom corners: three 44 pt buttons
// do not fit an iPhone SE's 116 pt with room between them (docs/tasarim/ogrenme_ilkeleri.md 2.1).
// The medium widget's column keeps Know, speaker, Next (README "Widget'lar"). Next sits in the
// easy corner (bottom right of the small widget, bottom of the medium widget's column); Know,
// which marks a word known without a test, is the farthest from it, and the harmless speaker sits
// between the two buttons that change state.
// The buttons are icon-only with a Turkish label for VoiceOver ("Kelimeyi dinle", "Sonraki
// kelime", "Biliyorum") and the short names of docs/tasarim/terimler.md §3 for Voice Control
// ("Dinle", "Sonraki"); meaning never depends on color. Each one is a 34 pt circle (mockup `.wb`)
// centred in a hit area of exactly 44 x 44 pt, so the views can keep the buttons' place free of
// text (HomeWordViews.swift).
// The glyphs share one font size and weight; Next is the filled one (mockup `.wb`), one image
// scale smaller (`WidgetButtonFace.filledScale`): at the same scale the solid, wide forward.fill
// looked heavier than the outlined speaker beside it.
// Next and Know run in the widget extension (`WordActions`); the speaker button runs in the app's
// process (`SpeakWordIntent` is an `AudioPlaybackIntent`).

struct NextWordButton: View {
    let wordID: Int
    let source: WidgetEventSource
    /// The widget's colors for its rendering mode (HomeWordViews.swift).
    var colors = WidgetColors.tokens

    var body: some View {
        Button(intent: NextWordIntent(wordID: wordID, source: source.rawValue)) {
            WidgetButtonFace(title: "Sonraki kelime", systemImage: "forward.fill", scale: WidgetButtonFace.filledScale, colors: colors)
        }
        .buttonStyle(.plain)
        .accessibilityInputLabels([Text("Sonraki kelime"), Text("Sonraki")])
    }
}

/// "Biliyorum" (medium widget): the word leaves the widget and the app asks it once 3 days later;
/// a word known then comes back every 30 days (`Leitner.knownCheckDelay`, `refresherDelay`,
/// ogrenme_ilkeleri 2.2). The hint says so, as the app's "Biliyorum" does.
struct KnowWordButton: View {
    let wordID: Int
    let source: WidgetEventSource
    /// The widget's colors for its rendering mode (HomeWordViews.swift).
    var colors = WidgetColors.tokens

    /// The VoiceOver hint; the widget cannot read the two waits from `Leitner`.
    static let hint = "Kelime widget'tan çıkar. 3 gün sonra bir kez sorarız; bilirsen 30 günde bir yine sorarız."

    var body: some View {
        Button(intent: KnowWordIntent(wordID: wordID, source: source.rawValue)) {
            WidgetButtonFace(title: "Biliyorum", systemImage: "checkmark", colors: colors)
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text(KnowWordButton.hint))
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
        .accessibilityInputLabels([Text("Kelimeyi dinle"), Text("Dinle")])
        // VoiceOver stays quiet while the word is being read.
        .accessibilityAddTraits(.startsMediaSession)
    }
}

/// A widget button's look: the icon in a 34 pt circle (`surface2` in full color, a faint wash
/// when the system removes the paper, a dark gray disc in StandBy at night, a 1.5 pt outline on
/// the tinted and Liquid Glass Home Screens: `WidgetColors`), centred in a 44 x 44 pt hit area
/// that is all tappable. The title is VoiceOver's name for the button, a verbatim Turkish text
/// read with the widget's Turkish voice (`widgetTurkishVoice()`).
struct WidgetButtonFace: View {
    let title: String
    let systemImage: String
    /// The glyph's image scale: `.medium`, `filledScale` for the filled Next glyph.
    var scale: Image.Scale = .medium
    let colors: WidgetColors

    /// The filled Next glyph's scale, so it weighs as much as the outlined glyphs beside it.
    static let filledScale = Image.Scale.small

    var body: some View {
        Label {
            Text(verbatim: title)
        } icon: {
            Image(systemName: systemImage)
        }
        .labelStyle(.iconOnly)
        .font(.subheadline.weight(.semibold))
        .imageScale(scale)
        .foregroundStyle(colors.ink)
        .frame(width: 34, height: 34)
        .background(colors.buttonFill, in: Circle())
        .overlay {
            if let edge = colors.buttonEdge {
                Circle()
                    .strokeBorder(edge, lineWidth: 1.5)
            }
        }
        .frame(width: Theme.minHitSize, height: Theme.minHitSize)
        .contentShape(Rectangle())
    }
}
