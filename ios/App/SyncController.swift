import Combine
import Foundation
import os
import CoreModels
import Learning

// "iCloud ile eşitle" (docs/ozellik_planlari/icloud_esitleme.md): the switch, the status line and
// the talk with iCloud and the state file. The merge itself is `SyncMerge` (Learning, tested on
// Linux); AppModel+Sync.swift feeds it the progress and the user's words and saves the result.
// Foundation, Combine and os only, so it joins the Linux compile check of the app's logic
// (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`); the iCloud store itself is iOS only.

/// Where the iCloud copy lives (`SyncKeyValueCloud` on the iPhone).
protocol SyncCloud: AnyObject {
    /// False when this build has no iCloud key-value entitlement: sync stays off, quietly.
    var isAvailable: Bool { get }
    /// iCloud's copy as JSON; nil when there is none. Throws `SyncCloudError.unreadable`.
    func read() throws -> Data?
    /// Throws `SyncCloudError.tooLarge` when the copy does not fit.
    func write(_ json: Data) throws
    func remove()
    /// What iCloud reports, on the main thread.
    var onChange: ((SyncCloudChange) -> Void)? { get set }
}

enum SyncCloudChange: Equatable {
    /// Another device wrote a new copy.
    case otherDevice
    /// The first download from iCloud on this device (or after an account change) is done; what
    /// this device wrote before it was dropped by iCloud.
    case firstDownload
    /// iCloud's limit for the app was reached.
    case quotaExceeded
    /// The iPhone signed in to another iCloud account.
    case accountChanged
}

enum SyncCloudError: Error, Equatable {
    case unreadable
    case tooLarge(bytes: Int)

    var isTooLarge: Bool {
        if case .tooLarge = self {
            return true
        }
        return false
    }
}

/// The iCloud sync of this app: one for the app (`shared`). Off by default; turned on and off on
/// the "iCloud ile eşitle" screen (SyncSettingsView). Keeps no learning data itself.
@MainActor
final class SyncController: ObservableObject {
    static let shared = SyncController()

    /// What the status line says when a sync could not finish. Calm, no technical names.
    enum Problem: String, Equatable {
        case cloudUnreadable
        case newerFormat
        case tooLarge
        case notSaved
        case accountChanged

        var message: String {
            switch self {
            case .cloudUnreadable:
                return "iCloud'daki kopya okunamadı. Bu telefondaki bilgiler duruyor."
            case .newerFormat:
                return "iCloud'daki kopyayı Lockglow'un daha yeni bir sürümü yazmış. Uygulamayı güncelle."
            case .tooLarge:
                return "Kopya iCloud'un sınırını aştı. Bu telefondaki bilgiler duruyor."
            case .notSaved:
                return "Bu telefona kaydedilemedi. Biraz sonra yeniden deneriz."
            case .accountChanged:
                return "iCloud hesabı değişti. Eşitlemeyi kapattık; istersen yeniden aç."
            }
        }
    }

    /// The switch, as the user left it. Always false without iCloud in this build.
    @Published private(set) var isEnabled: Bool
    /// The last sync that reached both this device and iCloud's copy on this device. iCloud
    /// sends it on to the other devices by itself, when it can.
    @Published private(set) var lastSyncAt: Date?
    /// Why the last sync could not finish; nil after a good one.
    @Published private(set) var problem: Problem?

    /// AppModel+Sync: runs one sync now (another device wrote, sync was turned on).
    var requestSync: (() -> Void)?

    private let cloud: SyncCloud?
    private let stateStore: SyncStateStore?
    /// The file recovery (`localMayBeOld`) whose first sync is done: later syncs use the base again.
    private var handledRecovery: String?
    /// Lifecycle observers (AppModel+Sync), kept for the app's lifetime.
    private var observers: [NSObjectProtocol] = []
    private let defaults = UserDefaults.standard
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "Sync"
    )

    private static let enabledKey = "lockglow.icloudSync.enabled"
    private static let lastSyncKey = "lockglow.icloudSync.lastSyncAt"
    private static let problemKey = "lockglow.icloudSync.problem"

    init(cloud: SyncCloud?, stateStore: SyncStateStore?) {
        self.cloud = cloud
        self.stateStore = stateStore
        let stored = UserDefaults.standard
        isEnabled = (cloud?.isAvailable ?? false) && stored.bool(forKey: SyncController.enabledKey)
        let lastSync = stored.double(forKey: SyncController.lastSyncKey)
        lastSyncAt = lastSync > 0 ? Date(timeIntervalSince1970: lastSync) : nil
        problem = stored.string(forKey: SyncController.problemKey).flatMap(Problem.init(rawValue:))
        cloud?.onChange = { [weak self] change in
            self?.cloudChanged(change)
        }
    }

    /// iCloud's key-value store on the iPhone; nothing elsewhere (the Linux check).
    convenience init() {
        let stateStore = (try? SyncStateStore.defaultURL()).map { SyncStateStore(fileURL: $0) }
        #if os(iOS)
        self.init(cloud: SyncKeyValueCloud(), stateStore: stateStore)
        #else
        self.init(cloud: nil, stateStore: stateStore)
        #endif
    }

    /// This build can sync: the iCloud key-value entitlement is there (docs: "Apple tarafı").
    var isAvailable: Bool {
        return cloud?.isAvailable ?? false
    }

    // MARK: The switch

    /// Turning sync on starts like a first sync (`SyncState.leaving`): it only adds, nothing on
    /// this device is deleted or reset by it. Turning it off stops syncing; iCloud's copy stays
    /// until "iCloud'daki kopyayı sil".
    func setEnabled(_ enabled: Bool) {
        guard enabled != isEnabled else {
            return
        }
        if enabled {
            guard isAvailable, let stateStore = stateStore else {
                return
            }
            do {
                let state = try stateStore.load()
                try stateStore.save(state.leaving())
            } catch {
                logger.error("sync state not saved: \(error.localizedDescription, privacy: .public)")
                report(.notSaved)
                return
            }
        }
        isEnabled = enabled
        defaults.set(enabled, forKey: SyncController.enabledKey)
        report(nil)
        if enabled {
            requestSync?()
        }
    }

    /// "iCloud'daki kopyayı sil": iCloud's copy goes and sync turns off. This device keeps
    /// everything. Another device that still syncs writes its copy again.
    func deleteCloudCopy() {
        cloud?.remove()
        isEnabled = false
        defaults.set(false, forKey: SyncController.enabledKey)
        lastSyncAt = nil
        defaults.removeObject(forKey: SyncController.lastSyncKey)
        report(nil)
    }

    /// Keeps a lifecycle observer for the app's lifetime (AppModel+Sync).
    func keep(_ observer: NSObjectProtocol) {
        observers.append(observer)
    }

    // MARK: One sync (AppModel+Sync)

    /// Whether this sync must treat this device's files as possibly old (`SyncMerge`): only the
    /// first sync after a file was restored from a backup (`recovery`, nil: no recovery).
    func mayBeOld(recovery: String?) -> Bool {
        return recovery != nil && recovery != handledRecovery
    }

    /// The merge of this device's progress and words with iCloud's copy. Nil when sync is off,
    /// the state file cannot be read now (a locked device: the next sync tries again) or
    /// iCloud's copy cannot be used (`problem` says why; it is never overwritten then).
    func merge(progress: [Int: WordProgress], words: CustomWordList, localMayBeOld: Bool) -> SyncMerge.Result? {
        guard isEnabled, let cloud = cloud, let stateStore = stateStore else {
            return nil
        }
        let state: SyncState
        do {
            state = try stateStore.load()
        } catch {
            logger.notice("sync state unreadable, will retry: \(error.localizedDescription, privacy: .public)")
            return nil
        }
        let remote: SyncSnapshot?
        do {
            remote = try cloud.read().map { try SyncSnapshot.decode($0) }
        } catch SyncSnapshot.DecodeError.newerFormat(let format) {
            logger.error("iCloud copy has format \(format); this build reads \(SyncSnapshot.currentFormat)")
            report(.newerFormat)
            return nil
        } catch {
            logger.error("iCloud copy unreadable: \(String(describing: error), privacy: .public)")
            report(.cloudUnreadable)
            return nil
        }
        return SyncMerge.sync(progress: progress, words: words, remote: remote, state: state, localMayBeOld: localMayBeOld)
    }

    /// This device saved the merge's progress and words: upload, then remember the sync.
    /// `recovery` is marked as handled once all went well.
    func finish(_ result: SyncMerge.Result, recovery: String?, now: Date = Date()) {
        if let upload = result.upload {
            do {
                try cloud?.write(upload.encoded())
            } catch {
                logger.error("iCloud copy not written: \(String(describing: error), privacy: .public)")
                saveState(result.stateIfUploadFails)
                report((error as? SyncCloudError)?.isTooLarge == true ? .tooLarge : .notSaved)
                return
            }
        }
        saveState(result.state)
        handledRecovery = recovery
        lastSyncAt = now
        defaults.set(now.timeIntervalSince1970, forKey: SyncController.lastSyncKey)
        report(nil)
    }

    /// Saving the words or the progress here failed. Nothing goes to iCloud; when the words were
    /// saved (`wordsSaved`), their uuids are kept so the next sync knows them.
    func localSaveFailed(_ result: SyncMerge.Result, wordsSaved: Bool) {
        logger.error("synced words or progress not saved; will retry")
        if wordsSaved, let stateStore = stateStore, var state = try? stateStore.load() {
            state.uuids = result.state.uuids
            saveState(state)
        }
        report(.notSaved)
    }

    /// "İlerlemeyi sıfırla" while syncing: the next sync removes older progress from iCloud and
    /// from the other devices (`SyncState.resetting`).
    func progressWasReset(at date: Date) {
        guard isEnabled, let stateStore = stateStore else {
            return
        }
        do {
            let state = try stateStore.load()
            try stateStore.save(state.resetting(at: date))
        } catch {
            // The reset stays on this device only; the next sync brings the older progress back.
            logger.error("reset not recorded for iCloud: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: Private

    private func cloudChanged(_ change: SyncCloudChange) {
        switch change {
        case .otherDevice:
            requestSync?()
        case .firstDownload:
            // iCloud dropped what this device wrote before: the base is not iCloud's copy.
            if let stateStore = stateStore, var state = try? stateStore.load() {
                state.base = nil
                saveState(state)
            }
            requestSync?()
        case .quotaExceeded:
            report(.tooLarge)
        case .accountChanged:
            // Another person's iCloud must not get this device's words: stop until turned on again.
            guard isEnabled else {
                return
            }
            isEnabled = false
            defaults.set(false, forKey: SyncController.enabledKey)
            report(.accountChanged)
        }
    }

    private func saveState(_ state: SyncState) {
        do {
            try stateStore?.save(state)
        } catch {
            logger.error("sync state not saved: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func report(_ newProblem: Problem?) {
        problem = newProblem
        if let newProblem {
            defaults.set(newProblem.rawValue, forKey: SyncController.problemKey)
        } else {
            defaults.removeObject(forKey: SyncController.problemKey)
        }
    }
}
