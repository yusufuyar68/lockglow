import Foundation
import Learning

// "Yeni zamanlama" (SchedulerSettingsView, docs/ozellik_planlari/fsrs.md): which scheduler times
// the answers (FSRS on a fresh install since 2026-10-25, Leitner kept on an update), the switch to
// FSRS and back, and FSRS's weights fitted to the review log. Apart from AppModel.swift, which
// other work changes often. Foundation only, so it joins the Linux compile check
// (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// FSRS fits its weights to the review log again after this long (`refreshFSRSIfDue`).
    static let fsrsRefitInterval: TimeInterval = 7 * 86_400

    /// The scheduler every answer goes through: "Tekrar" (`recordReview`), the times on the
    /// answer buttons (`dueDate(ifAnswering:for:now:)`) and the widget's "Bilmiyorum"
    /// (`ingestWidgetEvents`). FSRS while "Yeni zamanlama" is on, otherwise Leitner.
    var reviewScheduler: ReviewScheduler {
        switch AppPreferences.schedulerKind {
        case .leitner:
            return LeitnerScheduler()
        case .fsrs:
            return FSRSScheduler(weights: AppPreferences.fsrsWeights ?? FSRS.defaultWeights)
        }
    }

    /// "Yeni zamanlama" is on.
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

    /// First launch of this build (`shouldShowOnboardingAtLaunch`): the scheduler is written once
    /// (`SchedulerDefault`), FSRS on a fresh install and Leitner on an update, so no later launch
    /// depends on the getter's fallback. A fresh install has no answers: nothing to take over, and
    /// the weights are the defaults until the log is long enough (`refreshFSRSIfDue`). A stored
    /// value stays, even one this build does not know (the getter reads it as Leitner; a later
    /// build that wrote it gets it back).
    nonisolated static func settleSchedulerAtLaunch(isFreshInstall: Bool) {
        let stored = AppPreferences.storedSchedulerValue
        guard stored == nil else {
            return
        }
        AppPreferences.schedulerKind = SchedulerDefault.initialKind(storedRawValue: stored, isFreshInstall: isFreshInstall)
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

    /// FSRS or Leitner as written at the first launch (`AppModel.settleSchedulerAtLaunch`) or by
    /// the switch; nothing stored and an unknown value are Leitner, as in every earlier build.
    static var schedulerKind: SchedulerKind {
        get {
            return UserDefaults.standard.string(forKey: schedulerKey).flatMap(SchedulerKind.init(rawValue:)) ?? .leitner
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: schedulerKey)
        }
    }

    /// The setting as stored, nil when it was never written (`SchedulerDefault`).
    static var storedSchedulerValue: String? {
        return UserDefaults.standard.string(forKey: schedulerKey)
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

    /// "Tüm verileri sil" (after every key was removed): a fresh install's scheduler
    /// (`SchedulerDefault`), and the fit counter past `generation`, read before the erase, so a
    /// refit that read the erased log never stores its weights.
    static func startSchedulerOver(after generation: Int) {
        UserDefaults.standard.set(generation &+ 1, forKey: fsrsFitGenerationKey)
        schedulerKind = SchedulerDefault.initialKind(storedRawValue: nil, isFreshInstall: true)
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
