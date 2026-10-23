import SwiftUI
import WidgetKit

/// The second widget kind, Lock Screen only: today's new-word goal (circular), the next review
/// and today's count ("Sıradaki", rectangular) and a short status (inline). It reads the numbers
/// the app writes with every widget plan (`progress_snapshot.json`, AppModel+ProgressSnapshot.swift)
/// and writes nothing. No buttons: they do not work while the device is locked. Tapping opens the
/// app.
struct ProgressWidget: Widget {
    static let kind = "ProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: ProgressWidget.kind, provider: ProgressProvider()) { entry in
            ProgressWidgetView(entry: entry)
        }
        .configurationDisplayName("Tekrar")
        // "kilitli ekran", Apple's Turkish name (docs/tasarim/terimler.md §5).
        .description("Kilitli ekranda günlük hedef ve sıradaki tekrar.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

/// Picks the layout for the family. `containerBackground` is required on every family; on the
/// Lock Screen the system draws the background, so the widget brings none.
struct ProgressWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ProgressEntry

    var body: some View {
        content
            .containerBackground(for: .widget) {
                Color.clear
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular:
            ProgressCircularView(entry: entry)
        case .accessoryInline:
            ProgressInlineView(entry: entry)
        default:
            ProgressRectangularView(entry: entry)
        }
    }
}
