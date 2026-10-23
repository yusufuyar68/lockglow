import Foundation
import WidgetKit
import SharedState

struct ProgressEntry: TimelineEntry {
    let date: Date
    /// The numbers at `date`; nil until the app has written `progress_snapshot.json`.
    let status: ProgressStatus?

    /// Static sample for the placeholder and the gallery: 3 of 5 new words, 6 words today, the
    /// next review in two hours. No I/O.
    static func sample(at date: Date = Date()) -> ProgressEntry {
        let status = ProgressStatus(
            date: date,
            dailyGoal: 5,
            newWordsToday: 3,
            dueNow: 0,
            dueToday: 6,
            nextDue: date.addingTimeInterval(2 * 3600)
        )
        return ProgressEntry(date: date, status: status)
    }
}

/// The progress widget's timeline. It only reads `progress_snapshot.json` (the app is its single
/// writer) and never touches the plan, the widget state or the event mailbox: looking at the Lock
/// Screen is not a review (ogrenme_ilkeleri 2.1). Entries are made only for the moments the shown
/// numbers change (`ProgressSnapshot.timelineDates`); the app reloads the timeline whenever it
/// writes new numbers.
struct ProgressProvider: TimelineProvider {
    typealias Entry = ProgressEntry

    /// How far ahead the timeline reaches, and its most entries (two days: a first review and a
    /// midnight each, with room to spare).
    static let horizon: TimeInterval = 48 * 3600
    static let maxEntries = 8

    func placeholder(in context: Context) -> ProgressEntry {
        return ProgressEntry.sample()
    }

    /// The gallery shows the sample; on the Lock Screen the real numbers (one small file).
    func getSnapshot(in context: Context, completion: @escaping (ProgressEntry) -> Void) {
        let now = Date()
        if context.isPreview {
            completion(ProgressEntry.sample(at: now))
            return
        }
        let snapshot = WordDataSource.makeStore()?.readProgressSnapshot()
        completion(ProgressEntry(date: now, status: snapshot?.status(at: now)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgressEntry>) -> Void) {
        let now = Date()
        let snapshot = WordDataSource.makeStore()?.readProgressSnapshot()
        let entries = ProgressProvider.makeEntries(snapshot: snapshot, now: now, calendar: .current)
        // Without numbers yet ("Uygulamayı bir kez aç"), look again in an hour; the app's first
        // plan reloads it sooner.
        let policy: TimelineReloadPolicy = snapshot == nil ? .after(now.addingTimeInterval(3600)) : .atEnd
        completion(Timeline(entries: entries, policy: policy))
    }

    /// The entry for `now`, then one for each moment the shown numbers change, within `horizon`.
    static func makeEntries(snapshot: ProgressSnapshot?, now: Date, calendar: Calendar) -> [ProgressEntry] {
        guard let snapshot = snapshot else {
            return [ProgressEntry(date: now, status: nil)]
        }
        let later = snapshot.timelineDates(
            after: now,
            until: now.addingTimeInterval(horizon),
            limit: maxEntries - 1,
            calendar: calendar
        )
        return ([now] + later).map { date in
            ProgressEntry(date: date, status: snapshot.status(at: date, calendar: calendar))
        }
    }
}
