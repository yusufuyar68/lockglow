import Foundation

/// Keeps `LocalMetrics` in Application Support/local_metrics.json. The app uses the one shared
/// recorder (`LocalMetricsRecorder.shared`) and calls it where things happen; it needs no setup.
///
/// - Safe from any thread; every call is short and writes the small file right away.
/// - Best effort: measurements are not progress. A file that exists but cannot be read now (for
///   example before the first unlock) is left alone and the change is dropped; a damaged file is
///   replaced. Nothing is ever shown as an error.
/// - Rounds are timed here (`startRound` / `finishRound`) and only while the app is in front
///   (`appDidEnterBackground` / `appDidBecomeActive`), so a round left open overnight stays short.
public final class LocalMetricsRecorder: @unchecked Sendable {
    public static let shared = LocalMetricsRecorder(fileURL: LocalMetricsRecorder.defaultURL())

    /// Nil when Application Support is not available: the measurements then live in memory only.
    public let fileURL: URL?
    private let fixedCalendar: Calendar?
    private let lock = NSLock()
    private var cache: LocalMetrics?
    /// The round being timed: active seconds so far, and since when it runs again (nil while the
    /// app is in the background).
    private var openRound: (activeSeconds: TimeInterval, runningSince: Date?)?

    /// `calendar` nil: the phone's current calendar at each call (it follows time zone changes).
    public init(fileURL: URL?, calendar: Calendar? = nil) {
        self.fileURL = fileURL
        self.fixedCalendar = calendar
    }

    /// Application Support/local_metrics.json, next to progress.json.
    public static func defaultURL() -> URL? {
        guard let base = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return nil
        }
        return base.appendingPathComponent("local_metrics.json")
    }

    private var calendar: Calendar {
        return fixedCalendar ?? .current
    }

    // MARK: Events

    /// One answered question in "Tekrar" (see `LocalMetrics.recordAnswer`).
    public func recordAnswer(isNew: Bool, firstTryCorrect: Bool?, seconds: TimeInterval?, at now: Date = Date()) {
        let calendar = self.calendar
        change { $0.recordAnswer(isNew: isNew, firstTryCorrect: firstTryCorrect, seconds: seconds, at: now, calendar: calendar) }
    }

    /// A "Tekrar" round starts (its first card is on screen). A round still open is dropped.
    public func startRound(at now: Date = Date()) {
        lock.lock()
        openRound = (activeSeconds: 0, runningSince: now)
        lock.unlock()
    }

    /// The open round ended: by its last card, or by "Bitir" (`endedEarly`). Nothing happens
    /// when no round is open.
    public func finishRound(endedEarly: Bool, at now: Date = Date()) {
        lock.lock()
        let pending = openRound
        openRound = nil
        lock.unlock()
        guard let round = pending else {
            return
        }
        var seconds = round.activeSeconds
        if let since = round.runningSince {
            seconds += max(0, now.timeIntervalSince(since))
        }
        recordRound(seconds: seconds, endedEarly: endedEarly, at: now)
    }

    /// A round timed by the caller.
    public func recordRound(seconds: TimeInterval, endedEarly: Bool, at now: Date = Date()) {
        let calendar = self.calendar
        change { $0.recordRound(seconds: seconds, endedEarly: endedEarly, at: now, calendar: calendar) }
    }

    /// A new word was introduced: the taps from its first card to the next word.
    public func recordNewWord(taps: Int, at now: Date = Date()) {
        let calendar = self.calendar
        change { $0.recordNewWord(taps: taps, at: now, calendar: calendar) }
    }

    /// The 3-day check of a word marked "Biliyorum" or "Bunu zaten biliyorum" was answered.
    public func recordKnownCheck(passed: Bool, at now: Date = Date()) {
        let calendar = self.calendar
        change { $0.recordKnownCheck(passed: passed, at: now, calendar: calendar) }
    }

    /// The Leitner boxes now (one snapshot a day is kept, the last one).
    public func recordBoxes(_ progress: [Int: WordProgress], at now: Date = Date()) {
        let counts = BoxCounts(progress: progress)
        let calendar = self.calendar
        change { $0.recordBoxes(counts, at: now, calendar: calendar) }
    }

    /// The reminders just scheduled, the whole plan (empty when none is scheduled).
    public func recordReminderPlan(_ fireDates: [Date], now: Date = Date()) {
        let calendar = self.calendar
        change { $0.recordReminderPlan(fireDates, now: now, calendar: calendar) }
    }

    /// A reminder was tapped; `deliveredAt` is the notification's date.
    public func recordReminderOpened(deliveredAt: Date) {
        let calendar = self.calendar
        change { $0.recordReminderOpened(deliveredAt: deliveredAt, calendar: calendar) }
    }

    /// The app came to the front: an open round runs again, and today's reminder (if it fired)
    /// was not ignored.
    public func appDidBecomeActive(at now: Date = Date()) {
        lock.lock()
        if var round = openRound, round.runningSince == nil {
            round.runningSince = now
            openRound = round
        }
        lock.unlock()
        let calendar = self.calendar
        change { $0.recordAppActive(at: now, calendar: calendar) }
    }

    /// The app went to the background: an open round stops counting time. The app was in use
    /// until now, so a reminder that fired while it was on screen was not ignored either (like
    /// `ReminderLog.recordUse`, which counts leaving the app as a use).
    public func appDidEnterBackground(at now: Date = Date()) {
        lock.lock()
        if var round = openRound, let since = round.runningSince {
            round.activeSeconds += max(0, now.timeIntervalSince(since))
            round.runningSince = nil
            openRound = round
        }
        lock.unlock()
        let calendar = self.calendar
        change { $0.recordAppActive(at: now, calendar: calendar) }
    }

    // MARK: Reading and reset

    /// Everything measured so far (empty while the file cannot be read).
    public func snapshot() -> LocalMetrics {
        lock.lock()
        defer { lock.unlock() }
        return loaded() ?? LocalMetrics()
    }

    /// The last `windowDays` days against the §2.13 targets (`LocalMetrics.report`).
    public func report(dailyNewWords: Int, windowDays: Int = 28, now: Date = Date()) -> LocalMetricsReport {
        return snapshot().report(dailyNewWords: dailyNewWords, windowDays: windowDays, now: now, calendar: calendar)
    }

    /// "İlerlemeyi sıfırla": deletes the file and forgets the open round.
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        if let fileURL = fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        cache = LocalMetrics()
        openRound = nil
    }

    // MARK: File

    private func change(_ apply: (inout LocalMetrics) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        guard var metrics = loaded() else {
            return
        }
        apply(&metrics)
        cache = metrics
        write(metrics)
    }

    /// The metrics in memory, read from the file the first time. Nil while the file exists but
    /// cannot be read: it must not be written over. Call with the lock held.
    private func loaded() -> LocalMetrics? {
        if let cache = cache {
            return cache
        }
        guard let fileURL = fileURL else {
            cache = LocalMetrics()
            return cache
        }
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return nil
            }
            cache = LocalMetrics()
            return cache
        }
        // A damaged file is replaced by the next write.
        cache = (try? LocalMetricsRecorder.makeDecoder().decode(LocalMetrics.self, from: data)) ?? LocalMetrics()
        return cache
    }

    /// Call with the lock held. A failed write is dropped; the next change tries again.
    private func write(_ metrics: LocalMetrics) {
        guard let fileURL = fileURL, let data = try? LocalMetricsRecorder.makeEncoder().encode(metrics) else {
            return
        }
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            return
        }
        LocalMetricsRecorder.excludeFromBackup(fileURL)
    }

    /// Measurements stay on this phone: not in iCloud or computer backups.
    private static func excludeFromBackup(_ url: URL) {
        #if canImport(Darwin)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var target = url
        try? target.setResourceValues(values)
        #endif
    }

    // Seconds since 1970, like progress.json.
    static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
}
