import Foundation
import CoreModels
import SharedState
import Learning

// "Verilerin" (DataControlsView): export, import and "Hepsini sil". The formats and the import
// rules are pure and tested in Learning (DataExport.swift, DataImport.swift, DataErase.swift);
// this file reads and saves through the model's existing hooks (`adoptSyncedProgress`,
// `CustomWordLibrary.replaceAll`, `resetProgress`). Foundation only, so it joins the Linux
// check of the app's logic (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// The temporary folder the export writes to; emptied before each export and by "Hepsini sil".
    nonisolated static var exportFolder: URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent("lockglow-disa-aktarim", isDirectory: true)
    }

    // MARK: Export

    /// Everything the app keeps about the user's learning now (`DataArchive`).
    func makeDataArchive(now: Date = Date()) -> DataArchive {
        // Widget taps still in the mailbox belong to the progress.
        ingestWidgetEvents()
        let byID = wordsByID
        let log = (try? dataControlsReviewLog()?.entries()) ?? []
        let minute = AppPreferences.reminderMinuteOfDay
        let settings = DataArchive.Settings(
            startLevel: AppPreferences.startLevel?.rawValue,
            topicIDs: AppPreferences.selectedTopicIDs.sorted(),
            dailyNewWords: dailyNewWords,
            rotationMinutes: rotationMinutes,
            reminderEnabled: reminderEnabled,
            reminderTime: AppModel.clockText(minute)
        )
        let searches = (UserDefaults.standard.string(forKey: AppModel.recentSearchesKey) ?? "")
            .split(separator: "\n").map(String.init)
        return DataArchive.make(
            progress: progress,
            customWords: customWordLibrary.currentList,
            reviewLog: log,
            localMetrics: LocalMetricsRecorder.shared.snapshot(),
            settings: settings,
            recentSearches: searches,
            appVersion: AppModel.appVersionText,
            contentVersion: contentVersion,
            now: now,
            word: { id in
                if let custom = self.customWordLibrary.word(id: id) {
                    return (custom.lemma, custom.meaningTR)
                }
                return byID[id].map { ($0.lemma, $0.glossTR) }
            }
        )
    }

    /// Writes the backup and the four tables into `exportFolder` (emptied first) for the share
    /// sheet. Throws when a file cannot be written.
    func writeExportFiles(now: Date = Date()) throws -> (backup: URL, tables: [URL]) {
        // A copy made while the files could not be read would look complete and be nearly empty.
        guard canImportData else {
            throw DataImportFailure.notReady
        }
        if let log = dataControlsReviewLog() {
            _ = try log.entries()
        }
        let archive = makeDataArchive(now: now)
        let folder = AppModel.exportFolder
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: folder)
        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        func write(_ file: DataExportFile) throws -> URL {
            let url = folder.appendingPathComponent(file.name)
            #if canImport(Darwin)
            try file.data.write(to: url, options: [.atomic, .completeFileProtection])
            #else
            try file.data.write(to: url, options: [.atomic])
            #endif
            return url
        }
        let backup = try write(try archive.backupFile(calendar: .current))
        let tables = try archive.tableFiles(calendar: .current).map(write)
        return (backup, tables)
    }

    // MARK: Import

    /// Reads a backup the user picked in the file picker. At most `DataArchive.maxBytes` + 1
    /// bytes are read, and no file metadata (dates, size) is asked for.
    nonisolated static func readBackup(at url: URL) throws -> DataArchive.Reading {
        #if canImport(Darwin)
        let scoped = url.startAccessingSecurityScopedResource()
        defer {
            if scoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
        #endif
        let data: Data
        do {
            let handle = try FileHandle(forReadingFrom: url)
            defer {
                try? handle.close()
            }
            data = try handle.read(upToCount: DataArchive.maxBytes + 1) ?? Data()
        } catch {
            throw DataImportFailure.unreadable
        }
        do {
            return try DataArchive.read(data)
        } catch let error as DataArchive.ReadError {
            throw DataImportFailure.refused(error)
        }
    }

    /// Whether an import can be saved now: the progress and the own words are loaded.
    var canImportData: Bool {
        return isProgressReadyForSync && customWordLibrary.status == .ready && contentSource != .loading
    }

    /// What importing `reading` would do now (the confirmation sheet). Nil when it cannot be saved now.
    func importSummary(_ reading: DataArchive.Reading, now: Date = Date()) -> DataImport.Summary? {
        guard canImportData else {
            return nil
        }
        return DataImport.plan(reading, progress: progress, customWords: customWordLibrary.currentList, cardIDs: importableCardIDs, now: now).summary
    }

    /// Imports `reading` (DataImport's rules): the own words first (the progress may belong to
    /// a word new on this phone), then the progress, then the answers. Nothing on the phone is
    /// deleted; a failed save stops before the next part, and importing again finishes the job.
    func importData(_ reading: DataArchive.Reading, now: Date = Date()) -> Result<DataImport.Summary, DataImportFailure> {
        guard canImportData else {
            return .failure(.notReady)
        }
        ingestWidgetEvents()
        // The log is read before anything changes: if it cannot be read, nothing is imported.
        let log = dataControlsReviewLog()
        let logBefore: [ReviewLogEntry]
        let keptLines: [Data]
        do {
            logBefore = try log?.entries() ?? []
            keptLines = try log?.unreadableLines() ?? []
        } catch {
            return .failure(.notSaved)
        }
        let before = progress
        let plan = DataImport.plan(reading, progress: before, customWords: customWordLibrary.currentList, cardIDs: importableCardIDs, now: now)
        if plan.summary.changesNothing {
            return .success(plan.summary)
        }
        // Imported records are not proof of an initial choice made on this installation.
        guard invalidateInitialKnownProvenance() else {
            return .failure(.notSaved)
        }
        if plan.customWords != customWordLibrary.currentList {
            do {
                try customWordLibrary.replaceAll(with: plan.customWords)
            } catch {
                return .failure(.notSaved)
            }
        }
        // Saving the words may have applied a widget tap: merge with the progress as it is now.
        let device = progress
        let merged = DataImport.mergedProgress(device: device, incoming: plan.incomingProgress)
        if merged != device {
            guard adoptSyncedProgress(merged) else {
                return .failure(.notSaved)
            }
        }
        if let log = log {
            // Answers a widget tap added while saving (the plan rewrite applies pending taps) stay.
            let current = (try? log.entries()) ?? logBefore
            let added = current.count > logBefore.count ? Array(current[logBefore.count...]) : []
            let merged = plan.log(device: logBefore, deviceProgress: device) + added
            // Best effort, like every log write: a failure loses only FSRS history.
            try? log.replaceAll(with: merged, keeping: keptLines)
        }
        customWordLibrary.reserveIDs(progress.keys)
        LocalMetricsRecorder.shared.recordBoxes(progress)
        // While iCloud sync is on, the other devices get the import too.
        syncAfterDataImport()
        return .success(plan.summary)
    }

    /// The card ids an import may bring progress for: the loaded cards. Nil with seed words only
    /// (the backup's cards are then unknown here, not wrong), so nothing is left out for it.
    private var importableCardIDs: Set<Int>? {
        guard contentSource == .database else {
            return nil
        }
        return Set(words.lazy.filter { !$0.isUserAdded }.map { $0.id })
    }

    // MARK: Erase

    /// "Hepsini sil": every local file and setting of the app, as on a new install. iCloud's copy
    /// stays (sync turns off first, so nothing reaches the other devices); the view removes the
    /// reminders (UserNotifications). Returns the items that could not be removed.
    @discardableResult
    func eraseAllLocalData() -> [URL] {
        guard invalidateInitialKnownProvenance() else {
            return initialKnownStore.map { [$0.fileURL] } ?? []
        }
        cloudSync.setEnabled(false)
        if customWordLibrary.status == .ready {
            try? customWordLibrary.replaceAll(with: CustomWordList())
        }
        customWordLibrary.dismissRecovery()
        resetProgress()
        dismissProgressRecovery()
        // The defaults of a new install, in memory (the files go below).
        setDeckChoice(DeckChoice())
        setRotationMinutes(AppPreferences.defaultRotationMinutes)
        setDailyNewWords(SettingsRules.defaultDailyNewWords(startLevel: nil))
        setReminderEnabled(false)
        setReminderMinuteOfDay(AppPreferences.defaultReminderMinuteOfDay)

        // Items the system holds in the temporary folder or the caches may refuse; they are not ours.
        let fileManager = FileManager.default
        let systemFolders = [fileManager.temporaryDirectory] + fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let failed = DataErase.empty(AppModel.eraseFolders()).filter { item in
            !systemFolders.contains { item.standardizedFileURL.path.hasPrefix($0.standardizedFileURL.path) }
        }
        // Read after `resetProgress` moved it on: a refit that read the erased log stays dropped.
        let fitGeneration = AppPreferences.fsrsFitGeneration
        AppModel.eraseSettings()
        LocalMetricsRecorder.shared.reset()
        AppPreferences.onboardingCompleted = false
        AppPreferences.startSchedulerOver(after: fitGeneration)
        showOnboarding()
        // A fresh plan of the default deck: the widgets and the Watch drop the old words now
        // (the Watch gets every plan the app writes).
        refreshWidgetPlan()
        reloadWidgets()
        return failed
    }

    /// Application Support, Documents, Caches and the temporary folder of the app, and the App
    /// Group container shared with the widget (its `Library` stays: system folders).
    nonisolated static func eraseFolders() -> [DataErase.Folder] {
        let fileManager = FileManager.default
        var folders: [DataErase.Folder] = []
        for directory in [FileManager.SearchPathDirectory.applicationSupportDirectory, .documentDirectory, .cachesDirectory] {
            if let url = fileManager.urls(for: directory, in: .userDomainMask).first {
                folders.append(DataErase.Folder(url))
            }
        }
        folders.append(DataErase.Folder(fileManager.temporaryDirectory))
        if let group = AppGroupLocator.containerURL() {
            folders.append(DataErase.Folder(group, keeping: DataErase.appGroupKeeping))
        }
        return folders
    }

    /// Every key of the app's own UserDefaults and of the App Group's ("Ses ve aksan"). Key by key,
    /// so screens bound to a key (`@AppStorage`) see the change.
    nonisolated static func eraseSettings() {
        let defaults = UserDefaults.standard
        if let domain = Bundle.main.bundleIdentifier, let stored = defaults.persistentDomain(forName: domain) {
            for key in stored.keys {
                defaults.removeObject(forKey: key)
            }
        }
        if let group = AppGroupLocator.groupIdentifier(), let shared = UserDefaults(suiteName: group) {
            for key in shared.dictionaryRepresentation().keys where shared.object(forKey: key) != nil {
                shared.removeObject(forKey: key)
            }
        }
    }

    // MARK: Text

    /// "1.0 (31)"; nil without a bundle version.
    nonisolated static var appVersionText: String? {
        let info = Bundle.main.infoDictionary
        guard let version = info?["CFBundleShortVersionString"] as? String else {
            return nil
        }
        if let build = info?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return version
    }

    /// "20:00".
    nonisolated static func clockText(_ minuteOfDay: Int) -> String {
        let hour = minuteOfDay / 60
        let minute = minuteOfDay % 60
        return (hour < 10 ? "0" : "") + "\(hour):" + (minute < 10 ? "0" : "") + "\(minute)"
    }
}

/// Why an import did not happen. `message` is the plain Turkish sentence the screen shows.
enum DataImportFailure: Error, Equatable {
    case unreadable
    case refused(DataArchive.ReadError)
    /// The progress or the own words are not loaded yet (for example right after launch).
    case notReady
    case notSaved

    var message: String {
        switch self {
        case .unreadable:
            return "Dosya açılamadı. Dosyayı yeniden seç."
        case let .refused(error):
            return error.message
        case .notReady:
            return "Verilerin henüz hazır değil. Biraz sonra yeniden dene."
        case .notSaved:
            return "Kaydedilemedi. Telefonunda yer olduğundan emin ol, sonra yeniden dene."
        }
    }
}
