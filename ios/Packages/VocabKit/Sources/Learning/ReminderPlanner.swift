import Foundation
import CoreModels

/// One daily reminder: when it fires and what it says.
public struct Reminder: Equatable, Sendable {
    public let fireDate: Date
    /// Reviews due by `fireDate` if nothing is studied before then.
    public let dueCount: Int
    /// New words that day's goal offers.
    public let newCount: Int

    public init(fireDate: Date, dueCount: Int, newCount: Int) {
        self.fireDate = fireDate
        self.dueCount = dueCount
        self.newCount = newCount
    }
}

/// Plans the daily "Tekrar" reminders. Pure; the app turns the result into local notifications.
public enum ReminderPlanner {
    /// One reminder a day for `days` days at `minuteOfDay` (minutes after local midnight by
    /// `calendar`), starting today if that time is still ahead. A day with nothing to do (no
    /// review due, no new word offered) gets no reminder; that is how today's reminder disappears
    /// once the round is done.
    ///
    /// Counts come from the current progress, as if nothing were studied until then. Studying
    /// only lowers them, so the app plans again each time it goes to the background.
    ///
    /// Reviews come from `feed` (every word); new words from `newWordFeed`, the user's deck
    /// (`DeckFilter.feed`), as in "Tekrar". Nil means `feed`.
    public static func plan(
        feed: [WidgetWord],
        newWordFeed: [WidgetWord]? = nil,
        progress: [Int: WordProgress],
        now: Date,
        minuteOfDay: Int,
        days: Int,
        dailyNewGoal: Int,
        newStudiedToday: Int,
        calendar: Calendar
    ) -> [Reminder] {
        guard days > 0, (0..<1440).contains(minuteOfDay) else {
            return []
        }
        let goal = max(dailyNewGoal, 0)
        let newLeft = ReviewPlanner.newWords(feed: newWordFeed ?? feed, progress: progress, limit: goal).count
        let startOfToday = calendar.startOfDay(for: now)

        var result: [Reminder] = []
        for offset in 0..<days {
            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday),
                  let fireDate = calendar.date(
                      bySettingHour: minuteOfDay / 60,
                      minute: minuteOfDay % 60,
                      second: 0,
                      of: day
                  ),
                  fireDate > now
            else {
                continue
            }
            let due = ReviewPlanner.dueWords(feed: feed, progress: progress, now: fireDate, limit: Int.max).count
            let offered = offset == 0 ? min(newLeft, max(goal - newStudiedToday, 0)) : newLeft
            if due == 0 && offered == 0 {
                continue
            }
            result.append(Reminder(fireDate: fireDate, dueCount: due, newCount: offered))
        }
        return result
    }
}
