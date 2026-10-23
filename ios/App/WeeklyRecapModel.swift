import Foundation
import CoreModels
import Learning

// is5-haftalik: what Monday's "Geçen hafta" (WeeklyRecapView.swift) reads from the model. Apart
// from AppModel.swift, which other work changes often. Foundation only, so it joins the Linux
// compile check (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// Monday, last week left a trace and its look back was not shown yet (`WeeklyRecap.isDue`):
    /// the summary to make the recap from; nil otherwise. Cheap, no file is read: the opening asks
    /// this first. "Once" holds both ways: "İlerleme"'s Monday note of last week (seen before a
    /// free opening came) counts as the look back too.
    func weeklyRecapSummary(now: Date = Date()) -> ProgressSummary? {
        let calendar = Calendar.current
        // Not Monday: nothing to make (the other six days ask this at every opening).
        guard !words.isEmpty, calendar.isDate(now, inSameDayAs: ProgressSummary.weekStart(containing: now, calendar: calendar)) else {
            return nil
        }
        let summary = ProgressSummary.make(
            progress: progress,
            now: now,
            calendar: calendar,
            wordIDs: Set(words.map { $0.id })
        )
        guard WeeklyRecap.isDue(summary: summary, calendar: calendar, shownForWeek: AppPreferences.weeklyRecapWeek),
              WeeklyRecap.isDue(summary: summary, calendar: calendar, shownForWeek: AppPreferences.progressRecapWeek) else {
            return nil
        }
        return summary
    }

    /// The recap of the week before `summary.now` (`summary` from `weeklyRecapSummary`); nil when
    /// that week has no word to show. The review log is read off the main thread. Its "Tekrar"
    /// answers give the hard words and the exact study days (`ProgressSummary.StudyHistory`; from
    /// `progress.json` alone a day whose words were all answered again later is missed). A log
    /// that cannot be read leaves both to `progress.json`.
    func weeklyRecap(for summary: ProgressSummary) async -> WeeklyRecap? {
        let start = summary.lastWeek.start
        let end = summary.lastWeek.end
        let url = try? ReviewLog.defaultURL()
        let entries: [ReviewLogEntry] = await Task.detached(priority: .utility) {
            guard let url = url, let all = try? ReviewLog(fileURL: url).entries() else {
                return []
            }
            return all.filter { $0.at >= start && $0.at < end }
        }.value
        let wordIDs = Set(words.map { $0.id })
        let studied = entries.filter { $0.source == .review }.map { $0.at }
        let exact = ProgressSummary.make(
            progress: progress,
            now: summary.now,
            wordIDs: wordIDs,
            history: ProgressSummary.StudyHistory(studyDays: studied)
        )
        let due = ReviewPlanner.dueWords(feed: words, progress: progress, now: summary.now, limit: Int.max).count
        return WeeklyRecap.make(
            summary: exact,
            progress: progress,
            log: entries,
            dueCount: due,
            wordIDs: wordIDs
        )
    }

    /// The recap is on screen: it does not come again for that week. "İlerleme" then shows this
    /// week instead of the same look back (its Monday note, `markProgressRecapShown`).
    func markWeeklyRecapShown(_ recap: WeeklyRecap) {
        AppPreferences.weeklyRecapWeek = recap.weekStart
        markProgressRecapShown(weekStart: recap.weekStart)
    }
}

extension AppPreferences {
    private static let weeklyRecapWeekKey = "lockglow.weeklyRecapWeek"

    /// Monday of the last week whose "Geçen hafta" recap was shown (ogrenme_ilkeleri 2.5: once).
    static var weeklyRecapWeek: Date? {
        get {
            let stored = UserDefaults.standard.double(forKey: weeklyRecapWeekKey)
            return stored > 0 ? Date(timeIntervalSince1970: stored) : nil
        }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: weeklyRecapWeekKey)
            } else {
                UserDefaults.standard.removeObject(forKey: weeklyRecapWeekKey)
            }
        }
    }
}
