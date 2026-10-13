import Foundation
import WidgetKit
import CoreModels
import Scheduler
import SharedState

/// Classic timeline provider. The rotation interval is global (from the plan), so every widget
/// instance, home screen or Lock Screen, shows the same word at the same time.
struct WordProvider: TimelineProvider {
    typealias Entry = WordEntry

    // Placeholder and snapshot are instant and static: no file or database access.
    func placeholder(in context: Context) -> WordEntry {
        return WordEntry.sample()
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        completion(WordEntry.sample())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let now = Date()
        let input = WordDataSource.load(store: WordDataSource.makeStore())
        let entries = WordProvider.makeEntries(input: input, now: now)

        if entries.isEmpty {
            // No plan and no seed file: show the static sample and look again in an hour.
            let fallback = Timeline(
                entries: [WordEntry.sample(at: now)],
                policy: TimelineReloadPolicy.after(now.addingTimeInterval(3600))
            )
            completion(fallback)
            return
        }
        completion(Timeline(entries: entries, policy: TimelineReloadPolicy.atEnd))
    }

    static func makeEntries(input: RotationInput, now: Date) -> [WordEntry] {
        let offset = TimelinePlanner.localAlignmentOffset(for: now)
        var planned = TimelinePlanner.plan(
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            now: now,
            interval: input.interval,
            alignmentOffset: offset
        )
        if planned.isEmpty {
            // Every queued word is marked known: keep showing words rather than a blank widget.
            planned = TimelinePlanner.plan(
                queue: input.queue,
                knownIDs: [],
                cursorOffset: input.cursorOffset,
                cursorAnchor: input.cursorAnchor,
                now: now,
                interval: input.interval,
                alignmentOffset: offset
            )
        }

        var entries: [WordEntry] = []
        for (index, item) in planned.enumerated() {
            let following: Date? = index + 1 < planned.count ? planned[index + 1].date : nil
            entries.append(WordEntry(date: item.date, word: item.word, nextChange: following))
        }
        return entries
    }
}
