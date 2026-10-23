import Foundation
import os
import SharedState
import Learning

// The Lock Screen progress widget (Widgets/ProgressWidget.swift) reads `progress_snapshot.json`,
// which the app writes with every widget plan (`refreshWidgetPlan`). Apart from AppModel.swift,
// which other work changes often. Foundation only, so it joins the Linux compile check
// (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

private let progressSnapshotLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
    category: "ProgressSnapshot"
)

extension AppModel {
    /// Writes the progress widget's numbers: today's new-word goal and count (the "Tekrar" ring)
    /// and the due dates of the loaded words' reviews and refreshers (the words `progressCounts`
    /// and `nextReviewDate` look at). The widget reloads with the plan (`reloadWidgets`). A
    /// failed write is only logged: the widget keeps the last snapshot.
    func writeProgressSnapshot(to store: AppGroupStore, now: Date = Date()) {
        let snapshot = ProgressSnapshot(
            writtenAt: now,
            dailyGoal: dailyNewWords,
            newWordsToday: newWordsStudiedToday(now: now),
            dueDates: progressSnapshotDueDates()
        )
        do {
            try store.writeProgressSnapshot(snapshot)
        } catch {
            progressSnapshotLogger.error("could not write the progress snapshot: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Due dates of the loaded words that come back in "Tekrar" (learning words and known words'
    /// refreshers, as `WordProgress.isDue`), each word once. New words have none.
    private func progressSnapshotDueDates() -> [Date] {
        var seen = Set<Int>()
        var dates: [Date] = []
        for word in words {
            if !seen.insert(word.id).inserted {
                continue
            }
            guard let p = progress[word.id], p.state != .new, let due = p.dueAt else {
                continue
            }
            dates.append(due)
        }
        return dates
    }
}
