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
        // Every family applies the system's default margins itself (`widgetContentMargins`), so
        // the home widgets' button group can reach into them and still stay inside the widget's
        // root view (Apple's documented way to apply the margins selectively).
        .contentMarginsDisabled()
    }
}

/// Picks the layout for the widget family. `containerBackground` is required on every family;
/// the system removes or replaces it in tinted, vibrant and StandBy rendering.
/// Content margins are disabled (see `WordWidget`): the Lock Screen families get the default
/// margins back as plain padding, the home families place them themselves (HomeWordViews.swift).
struct WordWidgetView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetContentMargins) private var margins
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
            SmallWordView(entry: entry, margins: margins)
        case .systemMedium:
            MediumWordView(entry: entry, margins: margins)
        case .accessoryRectangular:
            RectangularWordView(entry: entry)
                .padding(margins)
        case .accessoryInline:
            InlineWordView(entry: entry)
                .padding(margins)
        default:
            SmallWordView(entry: entry, margins: margins)
        }
    }
}
