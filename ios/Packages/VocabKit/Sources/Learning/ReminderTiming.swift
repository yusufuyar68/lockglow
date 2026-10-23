import Foundation

/// The start of a stretch of studying in "Tekrar" (`StudyTimes`): when it began, and whether a
/// reminder had just come.
public struct StudyStart: Codable, Equatable, Sendable {
    public let at: Date
    /// Minutes after local midnight when it began, by the phone's clock at that moment: a summer
    /// time change or a trip later does not move it.
    public let minute: Int
    /// A reminder had come at most `StudyTimes.reminderEffect` before: the reminder chose this
    /// time, so it says nothing about the user's own time (`ReminderTiming`).
    public let afterReminder: Bool

    public init(at: Date, minute: Int, afterReminder: Bool) {
        self.at = at
        self.minute = minute
        self.afterReminder = afterReminder
    }

    enum CodingKeys: String, CodingKey {
        case at
        case minute
        case afterReminder = "after_reminder"
    }
}

/// When the user starts studying, for "Saati benim için seç" (`ReminderTiming`): the starts of the
/// last `keptDays` days. Only times, no words and no answers. `StudyTimeRecorder` keeps it on the
/// phone.
public struct StudyTimes: Codable, Equatable, Sendable {
    /// Starts older than this many local days (today included) are dropped.
    public static let keptDays = 14
    /// Answers closer than this belong to one stretch of studying; a longer break starts a new one.
    public static let sessionGap: TimeInterval = 30 * 60
    /// Studying that starts this long after a reminder came, or sooner, is the reminder's doing.
    public static let reminderEffect: TimeInterval = 60 * 60

    /// Oldest first.
    public var starts: [StudyStart]

    public init(starts: [StudyStart] = []) {
        self.starts = starts
    }

    /// A stretch of studying began at `now`. `lastReminder`: the latest reminder delivered by then.
    public mutating func recordStart(at now: Date, lastReminder: Date?, calendar: Calendar) {
        let parts = calendar.dateComponents([.hour, .minute], from: now)
        let minute = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
        let afterReminder = lastReminder.map { now >= $0 && now.timeIntervalSince($0) <= StudyTimes.reminderEffect } ?? false
        starts.append(StudyStart(at: now, minute: minute, afterReminder: afterReminder))
        starts.sort { $0.at < $1.at }
        if let first = StudyTimes.firstKeptDay(now: now, calendar: calendar) {
            starts.removeAll { $0.at < first }
        }
    }

    /// The starts of the last `keptDays` local days, today included, up to `now`.
    public func recent(now: Date, calendar: Calendar) -> [StudyStart] {
        let first = StudyTimes.firstKeptDay(now: now, calendar: calendar) ?? .distantPast
        return starts.filter { $0.at >= first && $0.at <= now }
    }

    /// Midnight starting the oldest kept day: by calendar days, so a 23- or 25-hour day counts once.
    static func firstKeptDay(now: Date, calendar: Calendar) -> Date? {
        return calendar.date(byAdding: .day, value: -(keptDays - 1), to: calendar.startOfDay(for: now))
    }
}

/// Keeps `StudyTimes` in Application Support/study_times.json, like `LocalMetricsRecorder`: it
/// stays on the phone (no network, not in the App Group, not in device backups), is best effort
/// and safe from any thread. "İlerlemeyi sıfırla" deletes it.
public final class StudyTimeRecorder: @unchecked Sendable {
    public static let shared = StudyTimeRecorder(fileURL: StudyTimeRecorder.defaultURL())

    /// Nil when Application Support is not available: the times then live in memory only.
    public let fileURL: URL?
    private let fixedCalendar: Calendar?
    private let lock = NSLock()
    private var cache: StudyTimes?
    /// The last answer, in memory only: after a relaunch the next answer starts a stretch again,
    /// which at worst adds a later start to the same day.
    private var lastAnswer: Date?

    /// `calendar` nil: the phone's current calendar at each call (it follows time zone changes).
    public init(fileURL: URL?, calendar: Calendar? = nil) {
        self.fileURL = fileURL
        self.fixedCalendar = calendar
    }

    /// Application Support/study_times.json, next to local_metrics.json.
    public static func defaultURL() -> URL? {
        guard let base = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return nil
        }
        return base.appendingPathComponent("study_times.json")
    }

    /// An answer in "Tekrar" at `now`. The first one after a break longer than
    /// `StudyTimes.sessionGap` starts a stretch and is written down; only then is `lastReminder`
    /// (the latest reminder delivered by `now`) asked for.
    public func recordAnswer(at now: Date = Date(), lastReminder: () -> Date?) {
        lock.lock()
        defer { lock.unlock() }
        let startsStretch = lastAnswer.map { now < $0 || now.timeIntervalSince($0) > StudyTimes.sessionGap } ?? true
        lastAnswer = now
        guard startsStretch, var times = loaded() else {
            return
        }
        times.recordStart(at: now, lastReminder: lastReminder(), calendar: fixedCalendar ?? .current)
        cache = times
        write(times)
    }

    /// Everything kept (empty while the file cannot be read).
    public func snapshot() -> StudyTimes {
        lock.lock()
        defer { lock.unlock() }
        return loaded() ?? StudyTimes()
    }

    /// "İlerlemeyi sıfırla": deletes the file and forgets the stretch in progress.
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        if let fileURL = fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        cache = StudyTimes()
        lastAnswer = nil
    }

    /// The times in memory, read from the file the first time. Nil while the file exists but
    /// cannot be read (before the first unlock): it must not be written over. Lock held.
    private func loaded() -> StudyTimes? {
        if let cache = cache {
            return cache
        }
        guard let fileURL = fileURL else {
            cache = StudyTimes()
            return cache
        }
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return nil
            }
            cache = StudyTimes()
            return cache
        }
        // A damaged file is replaced by the next write.
        cache = (try? LocalMetricsRecorder.makeDecoder().decode(StudyTimes.self, from: data)) ?? StudyTimes()
        return cache
    }

    /// Lock held. A failed write is dropped; the next start tries again.
    private func write(_ times: StudyTimes) {
        guard let fileURL = fileURL, let data = try? LocalMetricsRecorder.makeEncoder().encode(times) else {
            return
        }
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            return
        }
        #if canImport(Darwin)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var target = fileURL
        try? target.setResourceValues(values)
        #endif
    }
}

/// "Saati benim için seç" (Ayarlar): the daily reminder moves to a little before the time the user
/// usually starts studying on their own (`StudyTimes`), slowly, and never at night. Pure; the app
/// keeps the decision (`ReminderTimingStore`) and plans with it (`ReminderPlanner.plan`).
///
/// - **Usual time:** of the last 14 days' own starts (not those right after a reminder: they only
///   echo the reminder's time, and counting them would pull the reminder earlier every day), the
///   hour that holds the most days (`windowMinutes`, across midnight too); in it, the middle one
///   of each day's first start. Fewer than `minimumDays` days in that hour: no usual time.
/// - **Aim:** `leadMinutes` before it, on a 5-minute grid, from `earliestMinute` (08:00) to
///   `latestMinute` (22:30), the edges of the first reminder question's times; a time in the
///   night goes to the nearer edge.
/// - **Slowly:** today's reminder keeps its time; the next days' time is at most `maxDailyStep`
///   minutes from it, and an aim less than `deadBand` away counts as reached. Every planning on
///   the same day starts again from today's time, so the time moves once a day at most.
public enum ReminderTiming {
    public static let earliestMinute = 8 * 60
    public static let latestMinute = 22 * 60 + 30
    /// The hour in which the usual start is looked for.
    public static let windowMinutes = 60
    public static let minimumDays = 3
    public static let leadMinutes = 30
    public static let maxDailyStep = 30
    public static let deadBand = 10
    public static let grid = 5

    /// The last decision: `minute` on `decidedOn`, `next` from the day after.
    public struct State: Codable, Equatable, Sendable {
        public let minute: Int
        public let next: Int
        /// "2026-10-23" (`LocalMetrics.dayKey`).
        public let decidedOn: String

        public init(minute: Int, next: Int, decidedOn: String) {
            self.minute = minute
            self.next = next
            self.decidedOn = decidedOn
        }

        var isValid: Bool {
            return (0..<1440).contains(minute) && (0..<1440).contains(next) && !decidedOn.isEmpty
        }

        enum CodingKeys: String, CodingKey {
            case minute
            case next
            case decidedOn = "decided_on"
        }
    }

    /// Why the time is what it is (`explanation`). `usual` is on the 5-minute grid.
    public enum Reason: Equatable, Sendable {
        /// Fewer than `minimumDays` days of studying yet.
        case learning
        /// Most days the studying came right after a reminder: nothing to move toward.
        case followsReminder
        /// Days enough, but no hour holds `minimumDays` of them.
        case varied
        /// At the aim, or less than `deadBand` from it.
        case settled(usual: Int)
        /// On the way to `aim`.
        case moving(usual: Int, aim: Int)
        /// The aim fell in the night, nearer its start: `latestMinute`.
        case latestLimit(usual: Int)
        /// The aim fell in the night, nearer its end: `earliestMinute`.
        case earliestLimit(usual: Int)
    }

    public struct Decision: Equatable, Sendable {
        /// Today's reminder time: what was planned for today, kept.
        public let today: Int
        /// The time from tomorrow on.
        public let later: Int
        public let reason: Reason
        /// To keep for the next decision.
        public let state: State
    }

    /// The decision at `now`. `chosenMinute`: the reminder time in use, the start when there is no
    /// valid `previous` decision (the option was just turned on). `starts`: `StudyTimes.starts`.
    public static func decide(
        previous: State?,
        chosenMinute: Int,
        starts: [StudyStart],
        now: Date,
        calendar: Calendar
    ) -> Decision {
        let todayKey = LocalMetrics.dayKey(now, calendar: calendar)
        var base = chosenMinute
        if let previous = previous, previous.isValid {
            base = previous.decidedOn < todayKey ? previous.next : previous.minute
        }
        let today = allowed(base)
        let recent = StudyTimes(starts: starts).recent(now: now, calendar: calendar)
        let own = recent.filter { !$0.afterReminder }

        guard let usual = usualMinute(own, calendar: calendar, near: today) else {
            let ownDays = days(own, calendar: calendar)
            let echoDays = days(recent.filter(\.afterReminder), calendar: calendar)
            let reason: Reason
            if ownDays.union(echoDays).count < minimumDays {
                reason = .learning
            } else if echoDays.count >= ownDays.count {
                reason = .followsReminder
            } else {
                reason = .varied
            }
            return Decision(today: today, later: today, reason: reason, state: State(minute: today, next: today, decidedOn: todayKey))
        }

        let shown = usual - usual % grid
        let wanted = (shown - leadMinutes + 1440) % 1440
        let aim = allowed(wanted)
        let later = step(from: today, toward: aim)
        let reason: Reason
        if aim != wanted {
            reason = aim == latestMinute ? .latestLimit(usual: shown) : .earliestLimit(usual: shown)
        } else if abs(aim - later) < deadBand {
            reason = .settled(usual: shown)
        } else {
            reason = .moving(usual: shown, aim: aim)
        }
        return Decision(today: today, later: later, reason: reason, state: State(minute: today, next: later, decidedOn: todayKey))
    }

    /// The usual start in minutes after midnight, or nil when no hour holds `minimumDays` days.
    /// Every start is tried as the beginning of the hour; the busiest hour wins (most days, then
    /// most starts, then the one whose aim is nearest `current`, then the earliest).
    static func usualMinute(_ starts: [StudyStart], calendar: Calendar, near current: Int) -> Int? {
        var byDay: [String: [Int]] = [:]
        for start in starts where (0..<1440).contains(start.minute) {
            byDay[LocalMetrics.dayKey(start.at, calendar: calendar), default: []].append(start.minute)
        }
        var best: (key: (Int, Int, Int, Int), usual: Int)?
        for candidate in Set(byDay.values.joined()).sorted() {
            var firsts: [Int] = []
            var count = 0
            for minutes in byDay.values {
                let offsets = minutes.map { ($0 - candidate + 1440) % 1440 }.filter { $0 < windowMinutes }
                count += offsets.count
                if let first = offsets.min() {
                    firsts.append(first)
                }
            }
            guard firsts.count >= minimumDays else {
                continue
            }
            firsts.sort()
            let usual = (candidate + firsts[(firsts.count - 1) / 2]) % 1440
            let shown = usual - usual % grid
            let distance = abs(allowed(shown - leadMinutes) - current)
            let key = (firsts.count, count, -distance, -candidate)
            if best.map({ key > $0.key }) ?? true {
                best = (key, usual)
            }
        }
        return best?.usual
    }

    /// `minute` (any number of minutes after midnight) moved out of the night: from
    /// `earliestMinute` to `latestMinute` it stays; otherwise the nearer edge.
    public static func allowed(_ minute: Int) -> Int {
        let time = ((minute % 1440) + 1440) % 1440
        if (earliestMinute...latestMinute).contains(time) {
            return time
        }
        let sinceLatest = (time - latestMinute + 1440) % 1440
        let untilEarliest = (earliestMinute - time + 1440) % 1440
        return sinceLatest <= untilEarliest ? latestMinute : earliestMinute
    }

    /// At most `maxDailyStep` from `today` toward `aim`; no move when it is less than `deadBand`
    /// away. Both are day times (`allowed`), so the step never crosses the night.
    static func step(from today: Int, toward aim: Int) -> Int {
        let gap = aim - today
        if abs(gap) < deadBand {
            return today
        }
        return today + max(-maxDailyStep, min(maxDailyStep, gap))
    }

    private static func days(_ starts: [StudyStart], calendar: Calendar) -> Set<String> {
        return Set(starts.map { LocalMetrics.dayKey($0.at, calendar: calendar) })
    }

    /// "09:05": two digits each, 24 hours (terimler: no suffix after a time).
    public static func clock(_ minuteOfDay: Int) -> String {
        let time = ((minuteOfDay % 1440) + 1440) % 1440
        let hour = time / 60
        let minute = time % 60
        return (hour < 10 ? "0" : "") + "\(hour):" + (minute < 10 ? "0" : "") + "\(minute)"
    }

    /// One line for "Ayarlar" on why the time is what it is: plain Turkish, at most two short
    /// sentences, no suffix after a time (docs/tasarim/terimler.md).
    public static func explanation(_ reason: Reason) -> String {
        switch reason {
        case .learning:
            return "Birkaç gün çalışınca saati sana göre seçeceğiz. Şimdilik aynı kalıyor."
        case .followsReminder:
            return "Çoğu gün hatırlatma gelince çalışıyorsun. Bu yüzden saat aynı kalıyor."
        case .varied:
            return "Çalıştığın saat her gün değişiyor. Bu yüzden saat aynı kalıyor."
        case .settled(let usual):
            return "Genelde \(clock(usual)) civarında çalışıyorsun. Hatırlatma biraz önce geliyor."
        case .moving(let usual, let aim):
            return "Genelde \(clock(usual)) civarında çalışıyorsun. Saat her gün biraz değişip \(clock(aim)) olacak."
        case .latestLimit(let usual):
            return "Genelde \(clock(usual)) civarında çalışıyorsun. Geceleri hatırlatmıyoruz, en geç \(clock(latestMinute))."
        case .earliestLimit(let usual):
            return "Genelde \(clock(usual)) civarında çalışıyorsun. Sabah erken hatırlatmıyoruz, en erken \(clock(earliestMinute))."
        }
    }
}

/// "Saati benim için seç" in UserDefaults (it never leaves the phone): on or off (off by
/// default), the user's own time to go back to when it is turned off, and the last decision.
public enum ReminderTimingStore {
    /// Also read by the "Ayarlar" rows (`@AppStorage`), so they follow every change.
    public static let isOnKey = "lockglow.reminderAuto.isOn"
    private static let chosenKey = "lockglow.reminderAuto.chosenMinute"
    private static let stateKey = "lockglow.reminderAuto.state"

    public static func isOn(defaults: UserDefaults = .standard) -> Bool {
        return defaults.bool(forKey: isOnKey)
    }

    /// The time the user had chosen before turning it on.
    public static func chosenMinute(defaults: UserDefaults = .standard) -> Int? {
        guard let minute = defaults.object(forKey: chosenKey) as? Int, (0..<1440).contains(minute) else {
            return nil
        }
        return minute
    }

    public static func state(defaults: UserDefaults = .standard) -> ReminderTiming.State? {
        guard let data = defaults.data(forKey: stateKey) else {
            return nil
        }
        return try? JSONDecoder().decode(ReminderTiming.State.self, from: data)
    }

    /// On, starting from the user's time (`chosenMinute`); an earlier decision is forgotten.
    public static func turnOn(chosenMinute: Int, defaults: UserDefaults = .standard) {
        defaults.set(chosenMinute, forKey: chosenKey)
        defaults.removeObject(forKey: stateKey)
        defaults.set(true, forKey: isOnKey)
    }

    /// Off: the decision and the kept time are forgotten (the caller puts the time back).
    public static func turnOff(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: stateKey)
        defaults.removeObject(forKey: chosenKey)
        defaults.set(false, forKey: isOnKey)
    }

    public static func save(_ state: ReminderTiming.State, defaults: UserDefaults = .standard) {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: stateKey)
        }
    }
}
