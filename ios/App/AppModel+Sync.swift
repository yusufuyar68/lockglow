import Foundation
#if canImport(UIKit)
import UIKit
#endif
import CoreModels
import Learning

// "iCloud ile eşitle" (docs/ozellik_planlari/icloud_esitleme.md): the progress and the user's own
// words on every device of the same Apple account. Off by default (SyncSettingsView). AppModel.swift
// keeps three small hooks: `startCloudSync` at the end of `start`, `cloudSyncProgressWasReset` in
// `resetProgress`, and `adoptSyncedProgress` (it needs the private save). Compiled into the Linux
// check of the app's logic too (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    var cloudSync: SyncController {
        return SyncController.shared
    }

    /// End of `start`: the first sync, then one each time the app comes back or goes to the
    /// background, and when iCloud brings another device's copy. Nothing while sync is off or
    /// this build has no iCloud.
    func startCloudSync() {
        let sync = cloudSync
        sync.requestSync = { [weak self] in
            self?.syncWithCloud()
        }
        #if canImport(UIKit)
        let center = NotificationCenter.default
        for name in [UIApplication.didBecomeActiveNotification, UIApplication.didEnterBackgroundNotification] {
            let observer = center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                // After the scene's own handlers (widget taps, a late load of the words).
                Task { @MainActor in
                    self?.syncWithCloud()
                }
            }
            sync.keep(observer)
        }
        #endif
        syncWithCloud()
    }

    /// One sync now (`SyncMerge`): this device's progress and words merged with iCloud's copy,
    /// saved here first, then uploaded. Waits (does nothing) until the content, the progress and
    /// the words are loaded; a file that cannot be saved stops it before anything is uploaded.
    func syncWithCloud() {
        let sync = cloudSync
        guard sync.isEnabled,
              contentSource != .loading,
              isProgressReadyForSync,
              customWordLibrary.status == .ready else {
            return
        }
        // Widget taps waiting in the mailbox belong to this device's progress.
        ingestWidgetEvents()
        let recovery = syncRecovery
        guard let result = sync.merge(
            progress: progress,
            words: customWordLibrary.currentList,
            localMayBeOld: sync.mayBeOld(recovery: recovery)
        ) else {
            return
        }
        // The words first: the merged progress may belong to a word new on this device.
        if let words = result.words {
            do {
                try customWordLibrary.replaceAll(with: words)
            } catch {
                sync.localSaveFailed(result, wordsSaved: false)
                return
            }
        }
        if let merged = result.progress, !adoptSyncedProgress(merged) {
            sync.localSaveFailed(result, wordsSaved: result.words != nil)
            return
        }
        sync.finish(result, recovery: recovery)
    }

    /// "İlerlemeyi sıfırla" (`resetProgress`): while syncing, the reset reaches iCloud and the
    /// other devices now; their progress from before it goes too.
    func cloudSyncProgressWasReset() {
        cloudSync.progressWasReset(at: Date())
        syncWithCloud()
    }

    /// The progress or the words file was restored from a backup at launch (the notices of
    /// "Ayarlar" and "Kendi kelimelerin"). Then the first sync may not take a missing word for a
    /// deletion, nor an older record for a change (`SyncMerge`'s `localMayBeOld`). Nil: no recovery.
    private var syncRecovery: String? {
        guard progressRecovery != nil || customWordLibrary.recovery != nil else {
            return nil
        }
        return "\(String(describing: progressRecovery)) | \(String(describing: customWordLibrary.recovery))"
    }
}
