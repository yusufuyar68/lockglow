import SwiftUI
import WidgetKit
import CoreModels

struct WordWidget: Widget {
    static let kind = "WordWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WordWidget.kind, provider: WordProvider()) { entry in
            WordWidgetView(entry: entry)
        }
        .configurationDisplayName("Kelime")
        .description("Ana ekranda ve kilit ekranında yeni kelimeler.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

/// Picks the layout for the widget family. `containerBackground` is required on every family;
/// the system removes or replaces it in tinted, vibrant and StandBy rendering.
struct WordWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WordEntry

    var body: some View {
        content
            .widgetURL(DeepLink.wordURL(id: entry.word.id))
            .containerBackground(.fill.tertiary, for: .widget)
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            SmallWordView(entry: entry)
        case .systemMedium:
            MediumWordView(entry: entry)
        case .accessoryRectangular:
            RectangularWordView(entry: entry)
        case .accessoryInline:
            InlineWordView(entry: entry)
        default:
            SmallWordView(entry: entry)
        }
    }
}
