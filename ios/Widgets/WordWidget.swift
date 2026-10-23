import SwiftUI
import WidgetKit
import CoreModels

struct WordWidget: Widget {
    static let kind = "WordWidget"

    var body: some WidgetConfiguration {
        // "Widget'ı Düzenle" (WidgetConfigurationOptions.swift). The kind is the one the earlier
        // StaticConfiguration had, so widgets already on a screen stay where they are; they get
        // the intent's defaults, which draw them as before. The rotation is still WordProvider's.
        AppIntentConfiguration(
            kind: WordWidget.kind,
            intent: WordWidgetConfigurationIntent.self,
            provider: ConfiguredWordProvider()
        ) { entry in
            WordWidgetView(entry: entry.base, options: entry.options)
        }
        .configurationDisplayName("Kelime")
        // "kilitli ekran", Apple's Turkish name (docs/tasarim/terimler.md §5).
        .description("Ana ekranda ve kilitli ekranda yeni kelimeler.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge, // is5-w-buyuk (LargeWordView.swift)
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
/// the system removes or replaces it in tinted, vibrant and StandBy rendering. StandBy shows the
/// small widget without its paper on a black screen (in vibrant mode at night); the home views
/// then switch to the system's text styles (`WidgetColors`, `showsWidgetContainerBackground`).
/// On the Lock Screen the system draws the background; the widget brings only its gray levels.
/// Content margins are disabled (see `WordWidget`): the home families place them themselves
/// (HomeWordViews.swift), the Lock Screen families get them back as plain padding.
/// Tapping anywhere outside a button opens the app on this word (`widgetURL`); the word itself is
/// not a button. The widget's choices (`options`) reach the Home Screen views only; the Lock Screen
/// views ignore them, and StandBy never hides the meaning (WidgetConfigurationOptions.swift).
struct WordWidgetView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetContentMargins) private var margins
    @Environment(\.showsWidgetContainerBackground) private var showsBackground
    let entry: WordEntry
    var options = WidgetDisplayOptions.standard

    private var homeOptions: WidgetDisplayOptions {
        return options.forContainer(showsBackground: showsBackground)
    }

    var body: some View {
        content
            .widgetURL(DeepLink.wordURL(id: entry.word.id))
            .containerBackground(for: .widget) {
                containerFill
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            SmallWordView(entry: entry, margins: margins, options: homeOptions)
        case .systemMedium:
            MediumWordView(entry: entry, margins: margins, options: homeOptions)
        case .systemLarge:
            LargeWordView(entry: entry, margins: margins)
        case .accessoryRectangular:
            RectangularWordView(entry: entry, margins: margins)
        case .accessoryInline:
            InlineWordView(entry: entry)
                .padding(margins)
        default:
            SmallWordView(entry: entry, margins: margins, options: homeOptions)
        }
    }

    /// Paper for the home widgets (mockup `.mode-color .wg`: `surface`, white by day and
    /// near-black at night). The Lock Screen families draw none: the system draws their
    /// background (docs/tasarim/ogrenme_ilkeleri.md 2.1).
    @ViewBuilder
    private var containerFill: some View {
        switch family {
        case .accessoryRectangular, .accessoryInline:
            Color.clear
        default:
            Theme.surface
        }
    }
}
