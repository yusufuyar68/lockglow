import Foundation
import WidgetKit

/// A timeline entry of the configurable word widget: the rotation's entry (`WordEntry`, from
/// `WordProvider`) and what this widget shows of it (`WidgetDisplayOptions`).
struct ConfiguredWordEntry: TimelineEntry {
    let base: WordEntry
    let options: WidgetDisplayOptions

    var date: Date {
        return base.date
    }
}

/// The word widget's provider since "Widget'ı Düzenle" (iOS 17 `AppIntentConfiguration`). The
/// words, their dates and the reload policy are `WordProvider`'s, unchanged: every widget shows
/// the same word at the same time, whatever its choices (one queue, one rotation). This provider
/// only adds each widget's choices and, with "Anlamı gizle", whether "Göster" was tapped for the
/// word an entry shows (`WidgetMeaningReveal`).
struct ConfiguredWordProvider: AppIntentTimelineProvider {
    typealias Entry = ConfiguredWordEntry
    typealias Intent = WordWidgetConfigurationIntent

    func placeholder(in context: Context) -> ConfiguredWordEntry {
        return ConfiguredWordEntry(base: WordProvider().placeholder(in: context), options: .standard)
    }

    func snapshot(for configuration: WordWidgetConfigurationIntent, in context: Context) async -> ConfiguredWordEntry {
        let base: WordEntry = await withCheckedContinuation { continuation in
            WordProvider().getSnapshot(in: context) { entry in
                continuation.resume(returning: entry)
            }
        }
        return ConfiguredWordEntry(base: base, options: WidgetDisplayOptions(configuration))
    }

    func timeline(for configuration: WordWidgetConfigurationIntent, in context: Context) async -> Timeline<ConfiguredWordEntry> {
        let base: Timeline<WordEntry> = await withCheckedContinuation { continuation in
            WordProvider().getTimeline(in: context) { timeline in
                continuation.resume(returning: timeline)
            }
        }
        let options = WidgetDisplayOptions(configuration)
        let reveal = options.hidesMeaning ? WidgetMeaningReveal.load() : nil
        return Timeline(
            entries: ConfiguredWordProvider.configure(base.entries, options: options, reveal: reveal),
            policy: base.policy
        )
    }

    /// `entries` with the widget's choices; with "Anlamı gizle" the meaning is open only in the
    /// leading entries `reveal` covers: the word on screen when "Göster" was tapped, until it
    /// changes. A later turn of the same word comes hidden again, also when the reveal's end is
    /// only the 4-hour fallback.
    static func configure(
        _ entries: [WordEntry],
        options: WidgetDisplayOptions,
        reveal: WidgetMeaningReveal?
    ) -> [ConfiguredWordEntry] {
        var stillOnScreen = options.hidesMeaning
        return entries.map { entry in
            stillOnScreen = stillOnScreen && (reveal?.covers(entry) ?? false)
            var shown = options
            shown.meaningRevealed = stillOnScreen
            return ConfiguredWordEntry(base: entry, options: shown)
        }
    }
}
