import Foundation
import CoreModels
import Learning

// "İlerleme" (ProgressOverviewView, docs/ozellik_planlari/ilerleme_ekrani.md): what the screen
// reads from the model. Apart from AppModel.swift, which other work changes often. Foundation
// only, so it joins the Linux compile check (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// With "Tümü" (no topic chosen), "İlerleme" lists the started topics, at most this many.
    static let progressTopicLimit = 8

    /// At least one word is on the shelves (answered, or marked "Biliyorum"): "Kitaplığın" is
    /// offered on the "Tekrar" start screen only then.
    var hasLibrary: Bool {
        return progress.values.contains { $0.state != .new }
    }

    /// Loaded words by id: headwords, meanings and examples on "İlerleme".
    var wordsByID: [Int: WidgetWord] {
        return Dictionary(words.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    /// What "İlerleme" shows now (`ProgressSummary`). Topics: the chosen ones; with "Tümü", the
    /// started ones (at least one word met), at most `progressTopicLimit`. Both in content order:
    /// no ranking by progress.
    func progressSummary(now: Date = Date()) -> ProgressSummary {
        let chosen = activeTopicIDs
        let shown = (chosen.isEmpty ? choosableTopics : topics.filter { chosen.contains($0.id) })
            .sorted { $0.sort < $1.sort }
        var groups = ProgressSummary.WordGroup.topics(shown, topicsOf: topicsOf, words: words)
        if chosen.isEmpty {
            let started = groups.filter { group in
                group.wordIDs.contains { (progress[$0]?.state ?? .new) != .new }
            }
            groups = Array(started.prefix(AppModel.progressTopicLimit))
        }
        return ProgressSummary.make(
            progress: progress,
            now: now,
            wordIDs: Set(words.map { $0.id }),
            topics: groups,
            recapShownForWeek: AppPreferences.progressRecapWeek
        )
    }

    /// Monday's recap of last week has been on screen: it does not come again.
    func markProgressRecapShown(weekStart: Date) {
        AppPreferences.progressRecapWeek = weekStart
    }
}

extension AppPreferences {
    private static let progressRecapWeekKey = "lockglow.progressRecapWeek"

    /// Monday of the last week whose recap "İlerleme" showed (ogrenme_ilkeleri 2.5: only once).
    static var progressRecapWeek: Date? {
        get {
            let stored = UserDefaults.standard.double(forKey: progressRecapWeekKey)
            return stored > 0 ? Date(timeIntervalSince1970: stored) : nil
        }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: progressRecapWeekKey)
            } else {
                UserDefaults.standard.removeObject(forKey: progressRecapWeekKey)
            }
        }
    }
}
