import SwiftUI
import WidgetKit
import AppIntents
import CoreModels

// Interactive buttons (iOS 17 `Button(intent:)`). Used on the home screen families only;
// accessory (Lock Screen) widgets are not interactive while the device is locked.
// Both buttons are icon-only with a text label for VoiceOver; meaning never depends on color.
// Each one has a hit area of at least 44 x 44 pt.

struct NextWordButton: View {
    let wordID: Int
    let source: WidgetEventSource

    var body: some View {
        Button(intent: NextWordIntent(wordID: wordID, source: source.rawValue)) {
            Label("Sonraki kelime", systemImage: "forward.fill")
                .labelStyle(.iconOnly)
                .font(.subheadline)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct KnowWordButton: View {
    let wordID: Int
    let source: WidgetEventSource

    var body: some View {
        Button(intent: KnowWordIntent(wordID: wordID, source: source.rawValue)) {
            Label("Biliyorum", systemImage: "checkmark.circle")
                .labelStyle(.iconOnly)
                .font(.subheadline)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
