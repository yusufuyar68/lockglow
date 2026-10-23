import Foundation
import Learning

// "Yeni zamanlama (deneme)" (SchedulerSettingsView, docs/ozellik_planlari/fsrs.md): which
// scheduler times the answers, the switch to FSRS and back, and FSRS's weights fitted to the
// review log. Apart from AppModel.swift, which other work changes often. Foundation only, so it
// joins the Linux compile check (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// FSRS fits its weights to the review log again after this long (`refreshFSRSIfDue`).
    static let fsrsRefitInterval: TimeInterval = 7 * 86_400

    /// The scheduler every answer goes through: "Tekrar" (`recordReview`), the times on the
    /// answer buttons (`dueDate(ifAnswering:for:now:)`) and the widget's "Bilmiyorum"
    /// (`ingestWidgetEvents`). Leitner unless "Yeni zamanlama" is on.
    var reviewScheduler: ReviewScheduler {
        switch AppPreferences.schedulerKind {
        case .leitner:
            return LeitnerScheduler()
        case .fsrs:
            return FSRSScheduler(weights: AppPreferences.fsrsWeights ?? FSRS.defaultWeights)
        }
    }

    /// "Yeni zamanlama (deneme)" is on.
    var usesFSRS: Bool {
        return AppPreferences.schedulerKind == .fsrs
    }

    /// Turns "Yeni zamanlama" on or off; false when it could not be turned on.
    ///
    /// On: pending widget taps are applied first; then every answered word gets its FSRS memory
    /// (`FSRSMigration.takeOver`: from the review log, estimated where the log lacks answers),
    /// with weights fitted to the log (`FSRSParameterFit`, the defaults while it is short). The
    /// progress is saved before the setting changes: if the save fails, Leitner keeps scheduling.
    /// No due date, step or known word changes.
    ///
    /// Off: pending widget taps are applied by FSRS first; due dates beyond Leitner's longest wait
    /// come earlier (`FSRSMigration.handBack`), and Leitner goes on from the steps FSRS left.
    @discardableResult
    func setFSRSEnabled(_ enabled: Bool, now: Date = Date()) -> Bool {
        guard enabled != usesFSRS else {
            return true
        }
        ingestWidgetEvents()
        if !enabled {
            let handed = FSRSMigration.handBack(progress)
            if handed != progress {
                guard replaceProgress(handed) else {
                    return false
                }
            }
        } else {
            let log = AppModel.readReviewLog()
            let fit = FSRSParameterFit.fit(log)
            let migrated = FSRSMigration.takeOver(progress, log: log, scheduler: FSRSScheduler(weights: fit.weights), now: now)
            guard replaceProgress(migrated.progress) else {
                return false
            }
            AppPreferences.storeFSRSFit(fit, at: now)
        }
        AppPreferences.schedulerKind = enabled ? .fsrs : .leitner
        return true
    }

    /// While FSRS is on, at most once every `fsrsRefitInterval`: the weights are fitted to the
    /// review log again. Words whose memory is out of date (an earlier build answered them) get
    /// it rebuilt too, at once. The log is read off the main thread; nothing changes for a word
    /// FSRS answered meanwhile (its memory is up to date). Due dates never move.
    func refreshFSRSIfDue(now: Date = Date()) {
        guard usesFSRS else {
            return
        }
        let refitDue = AppPreferences.fsrsFittedAt.map { now.timeIntervalSince($0) >= AppModel.fsrsRefitInterval || $0 > now } ?? true
        guard refitDue || FSRSMigration.outdatedCount(progress) > 0 else {
            return
        }
        let generation = AppPreferences.fsrsFitGeneration
        Task { @MainActor [weak self] in
            let log = await Task.detached(priority: .utility) {
                AppModel.readReviewLog()
            }.value
            // "İlerlemeyi sıfırla" meanwhile: this log is gone, and so is its fit.
            guard let self = self, self.usesFSRS, AppPreferences.fsrsFitGeneration == generation else {
                return
            }
            let fit = FSRSParameterFit.fit(log)
            AppPreferences.storeFSRSFit(fit, at: now)
            let migrated = FSRSMigration.takeOver(self.progress, log: log, scheduler: FSRSScheduler(weights: fit.weights), now: Date())
            if migrated.progress != self.progress {
                self.replaceProgress(migrated.progress)
            }
        }
    }

    /// What the settings screen says about FSRS's weights: how many answers the log holds and
    /// whether the weights are the user's own yet.
    var fsrsFitSummary: (answers: Int, isPersonal: Bool)? {
        return AppPreferences.fsrsFitSummary
    }

    /// Every readable answer in the review log; empty when there is none or it cannot be read
    /// (FSRS then estimates every memory from the Leitner schedule).
    nonisolated static func readReviewLog() -> [ReviewLogEntry] {
        guard let url = try? ReviewLog.defaultURL() else {
            return []
        }
        return (try? ReviewLog(fileURL: url).entries()) ?? []
    }
}

extension AppPreferences {
    private static let schedulerKey = "lockglow.scheduler"
    private static let fsrsWeightsKey = "lockglow.fsrsWeights"
    private static let fsrsFittedAtKey = "lockglow.fsrsFittedAt"
    private static let fsrsFitAnswersKey = "lockglow.fsrsFitAnswers"
    private static let fsrsFitPersonalKey = "lockglow.fsrsFitPersonal"
    private static let fsrsFitGenerationKey = "lockglow.fsrsFitGeneration"

    /// Counts "İlerlemeyi sıfırla": a refit that read the log before a reset is dropped.
    static var fsrsFitGeneration: Int {
        return UserDefaults.standard.integer(forKey: fsrsFitGenerationKey)
    }

    /// Leitner unless "Yeni zamanlama (deneme)" was turned on; an unknown value is Leitner.
    static var schedulerKind: SchedulerKind {
        get {
            return UserDefaults.standard.string(forKey: schedulerKey).flatMap(SchedulerKind.init(rawValue:)) ?? .leitner
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: schedulerKey)
        }
    }

    /// FSRS's weights as last fitted; nil (the defaults) when never fitted or not valid.
    static var fsrsWeights: [Double]? {
        guard let stored = UserDefaults.standard.array(forKey: fsrsWeightsKey) as? [Double],
              FSRS.areValid(weights: stored) else {
            return nil
        }
        return stored
    }

    /// When the weights were last fitted.
    static var fsrsFittedAt: Date? {
        let stored = UserDefaults.standard.double(forKey: fsrsFittedAtKey)
        return stored > 0 ? Date(timeIntervalSince1970: stored) : nil
    }

    static var fsrsFitSummary: (answers: Int, isPersonal: Bool)? {
        guard fsrsFittedAt != nil else {
            return nil
        }
        let defaults = UserDefaults.standard
        return (defaults.integer(forKey: fsrsFitAnswersKey), defaults.bool(forKey: fsrsFitPersonalKey))
    }

    static func storeFSRSFit(_ fit: FSRSParameterFit, at date: Date) {
        let defaults = UserDefaults.standard
        defaults.set(fit.weights, forKey: fsrsWeightsKey)
        defaults.set(date.timeIntervalSince1970, forKey: fsrsFittedAtKey)
        defaults.set(fit.answerCount, forKey: fsrsFitAnswersKey)
        defaults.set(fit.isPersonal, forKey: fsrsFitPersonalKey)
    }

    /// "İlerlemeyi sıfırla": the answers the weights came from are gone; the defaults again, and
    /// the next refit comes at once. "Yeni zamanlama" itself stays as it was.
    static func clearFSRSFit() {
        let defaults = UserDefaults.standard
        for key in [fsrsWeightsKey, fsrsFittedAtKey, fsrsFitAnswersKey, fsrsFitPersonalKey] {
            defaults.removeObject(forKey: key)
        }
        defaults.set(fsrsFitGeneration &+ 1, forKey: fsrsFitGenerationKey)
    }
}
