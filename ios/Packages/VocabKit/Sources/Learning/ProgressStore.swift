import Foundation

/// App-private progress file (JSON array sorted by word id). Single writer: the app.
/// CloudKit sync replaces this in v1.2; until then it lives in Application Support.
///
/// Progress is never lost silently:
/// - a file that exists but cannot be read (for example while the device is locked) is left
///   alone and `load` throws, so the caller does not save over it;
/// - a file that cannot be decoded (damaged, or written by a format this build does not know) is
///   moved aside under a new name, never overwritten, and the daily backup is used instead;
/// - `save` copies the file to the backup once per day before overwriting it, so a damaged
///   file costs at most that day's changes.
public struct ProgressStore: Sendable {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Default location: Application Support/progress.json (created on first save).
    public static func defaultURL() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base.appendingPathComponent("progress.json")
    }

    /// The file as it was at the first save of the current day (progress.backup.json).
    public var backupURL: URL {
        return fileURL.deletingPathExtension().appendingPathExtension("backup.json")
    }

    public enum LoadOutcome: Equatable, Sendable {
        /// No file yet: every word is new.
        case fresh
        case loaded
        /// The file could not be decoded (it was moved to `setAside`; nil when it was missing) and
        /// the backup taken on `backupDate` was used: changes made after that are lost.
        case restoredFromBackup(setAside: URL?, backupDate: Date?)
        /// The file could not be decoded and there is no usable backup: progress starts over.
        /// The file was moved to `setAside`, so a later build can still read it.
        case startedOver(setAside: URL)
    }

    public struct LoadResult: Sendable {
        public let progress: [Int: WordProgress]
        public let outcome: LoadOutcome
    }

    public enum LoadError: Error, Equatable {
        /// The file exists but could not be read, or a damaged file could not be moved aside.
        /// Nothing was changed: try again later and do not save in the meantime.
        case unreadable(String)
    }

    /// Reads the progress, falling back to the backup when the file is damaged (see the type
    /// comment). `now` names the file a damaged one is moved to.
    public func load(now: Date = Date()) throws -> LoadResult {
        let fileManager = FileManager.default
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            if fileManager.fileExists(atPath: fileURL.path) {
                throw LoadError.unreadable(error.localizedDescription)
            }
            // No file: the backup, if there is one, is the newest copy left.
            if let backup = readBackup() {
                return LoadResult(
                    progress: backup.progress,
                    outcome: .restoredFromBackup(setAside: nil, backupDate: backup.date)
                )
            }
            return LoadResult(progress: [:], outcome: .fresh)
        }

        if let progress = ProgressStore.decode(data) {
            return LoadResult(progress: progress, outcome: .loaded)
        }

        let setAside = setAsideURL(now: now)
        do {
            try fileManager.moveItem(at: fileURL, to: setAside)
        } catch {
            throw LoadError.unreadable("damaged progress file could not be moved aside: \(error.localizedDescription)")
        }
        if let backup = readBackup() {
            return LoadResult(
                progress: backup.progress,
                outcome: .restoredFromBackup(setAside: setAside, backupDate: backup.date)
            )
        }
        return LoadResult(progress: [:], outcome: .startedOver(setAside: setAside))
    }

    /// Writes the progress atomically. If the backup is missing or was taken on an earlier day
    /// (by `calendar`), the file on disk is first copied to it, provided it decodes.
    public func save(_ progress: [Int: WordProgress], now: Date = Date(), calendar: Calendar = .current) throws {
        let list = progress.values.sorted { $0.wordID < $1.wordID }
        let data = try ProgressStore.makeEncoder().encode(list)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        refreshBackupIfNeeded(now: now, calendar: calendar)
        try data.write(to: fileURL, options: [.atomic])
    }

    /// Best effort: a failed backup never blocks the save itself.
    private func refreshBackupIfNeeded(now: Date, calendar: Calendar) {
        let fileManager = FileManager.default
        if let taken = ProgressStore.modificationDate(of: backupURL), calendar.isDate(taken, inSameDayAs: now) {
            return
        }
        guard let current = try? Data(contentsOf: fileURL), ProgressStore.decode(current) != nil else {
            return
        }
        do {
            try current.write(to: backupURL, options: [.atomic])
            // The backup's date is the caller's clock, so "taken today" follows the same clock.
            try fileManager.setAttributes([.modificationDate: now], ofItemAtPath: backupURL.path)
        } catch {
            return
        }
    }

    private func readBackup() -> (progress: [Int: WordProgress], date: Date?)? {
        guard let data = try? Data(contentsOf: backupURL), let progress = ProgressStore.decode(data) else {
            return nil
        }
        return (progress, ProgressStore.modificationDate(of: backupURL))
    }

    /// progress-unreadable-<seconds since 1970>.json next to the file; a suffix keeps it unique.
    private func setAsideURL(now: Date) -> URL {
        let folder = fileURL.deletingLastPathComponent()
        let base = fileURL.deletingPathExtension().lastPathComponent
        let stamp = Int(now.timeIntervalSince1970)
        var candidate = folder.appendingPathComponent("\(base)-unreadable-\(stamp).json")
        var suffix = 2
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = folder.appendingPathComponent("\(base)-unreadable-\(stamp)-\(suffix).json")
            suffix += 1
        }
        return candidate
    }

    private static func decode(_ data: Data) -> [Int: WordProgress]? {
        guard let list = try? makeDecoder().decode([WordProgress].self, from: data) else {
            return nil
        }
        var result: [Int: WordProgress] = [:]
        for item in list {
            result[item.wordID] = item
        }
        return result
    }

    private static func modificationDate(of url: URL) -> Date? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.modificationDate] as? Date
    }

    // Seconds since 1970 as a Double: exact round trip (ISO 8601 would drop fractions of a second).
    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
}
