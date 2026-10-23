import Foundation
import CoreModels

/// Apple Watch sync (is5-watch): the formats the phone app and the watch app exchange. The
/// transport is WatchConnectivity (phone: `App/WatchBridge.swift`, watch: `Watch/App/WatchSession.swift`).
///
/// - Phone to watch: the widget plan, the same `WidgetPlan` JSON as `widget_plan.json`, trimmed for
///   the watch (`watchPlan(from:)`). It goes in the application context (the newest one wins) and,
///   while a Lockglow complication is on the watch face, also as complication user info, which
///   wakes the watch app so the face gets the new words.
/// - Watch to phone: one `WidgetEvent` per "Biliyorum" or "Sonraki kelime" tap, as user info (the
///   system keeps it until it is delivered). The phone writes it into its own App Group `events/`
///   mailbox (`phoneMailboxEvent(from:)`), so the app's usual event ingest applies it. The watch
///   never grades a word: it only reports what was tapped, like the phone widget.
public enum WatchSync {
    /// Key of the encoded plan in the application context and in complication user info.
    public static let planKey = "lockglow_plan"
    /// Key of one encoded event in a user info transfer.
    public static let eventKey = "lockglow_event"
    /// Words sent to the watch: two days at one word per hour (`WatchRotation`).
    public static let maxWords = 48
    /// WatchConnectivity limits the application context to about 65 KB; stay well below it.
    public static let maxPayloadBytes = 48_000
    /// At most one complication transfer in this time. The system allows about 50 a day, and the
    /// app rewrites the plan every time it goes to the background.
    public static let complicationTransferSpacing: TimeInterval = 2 * 3600

    // MARK: Phone to watch

    /// The plan for the watch: personal-topic words removed (others can see a watch face, as they
    /// can see the Lock Screen), at most `maxWords` words in plan order, and no confusable ids (the
    /// watch does not use them). Nil when no word is left.
    public static func watchPlan(from plan: WidgetPlan, maxWords: Int = WatchSync.maxWords) -> WidgetPlan? {
        guard maxWords > 0 else {
            return nil
        }
        var queue: [WidgetWord] = []
        for word in plan.queue where !word.isSensitive {
            queue.append(withoutConfusables(word))
            if queue.count == maxWords {
                break
            }
        }
        if queue.isEmpty {
            return nil
        }
        return WidgetPlan(
            version: plan.version,
            planID: plan.planID,
            isPremium: plan.isPremium,
            intervalSeconds: plan.intervalSeconds,
            queue: queue,
            updatedAt: plan.updatedAt
        )
    }

    /// The plan's JSON, at most `maxBytes` long: while it is longer, the queue is halved (the first
    /// words stay). Nil when not even one word fits or encoding fails.
    public static func encodePlan(_ plan: WidgetPlan, maxBytes: Int = WatchSync.maxPayloadBytes) -> Data? {
        var current = plan
        while true {
            guard let data = try? JSONCoding.makeEncoder().encode(current) else {
                return nil
            }
            if data.count <= maxBytes {
                return data
            }
            if current.queue.count <= 1 {
                return nil
            }
            current.queue = Array(current.queue.prefix(current.queue.count / 2))
        }
    }

    /// The application context (or complication user info) for `plan`: the trimmed, encoded plan
    /// under `planKey`. Nil when the plan has no word the watch may show.
    public static func planPayload(for plan: WidgetPlan) -> [String: Any]? {
        guard let watchPlan = watchPlan(from: plan), let data = encodePlan(watchPlan) else {
            return nil
        }
        return [planKey: data]
    }

    /// The plan in a received application context or user info. Nil when there is none, it does not
    /// decode, or its queue is empty.
    public static func plan(from payload: [String: Any]) -> WidgetPlan? {
        guard let data = payload[planKey] as? Data,
              let plan = try? JSONCoding.makeDecoder().decode(WidgetPlan.self, from: data),
              !plan.queue.isEmpty
        else {
            return nil
        }
        return plan
    }

    /// Whether the watch should replace `current` with `incoming`. The same plan again (the
    /// application context is handed over again at every activation) and an older plan (a
    /// complication transfer delivered after a newer context) are ignored. A current plan dated more
    /// than a day after `now` (a wrong clock since corrected) never blocks a new one.
    public static func isNewer(_ incoming: WidgetPlan, than current: WidgetPlan?, now: Date = Date()) -> Bool {
        guard let current = current else {
            return true
        }
        if incoming.planID == current.planID {
            return false
        }
        if current.updatedAt.timeIntervalSince(now) > 24 * 3600 {
            return true
        }
        return incoming.updatedAt >= current.updatedAt
    }

    /// Whether the phone may spend one complication transfer now: one in `complicationTransferSpacing`
    /// at most, and never the last one of the day's budget. A last transfer dated in the future (the
    /// clock was set back) does not block.
    public static func shouldSendComplicationUpdate(lastSentAt: Date?, now: Date, remainingTransfers: Int) -> Bool {
        guard remainingTransfers > 1 else {
            return false
        }
        guard let last = lastSentAt else {
            return true
        }
        let elapsed = now.timeIntervalSince(last)
        return elapsed >= complicationTransferSpacing || elapsed < 0
    }

    // MARK: Watch to phone

    /// The user info for one watch tap: the event's JSON under `eventKey`.
    public static func eventPayload(_ event: WidgetEvent) -> [String: Any]? {
        guard let data = try? JSONCoding.makeEncoder().encode(event) else {
            return nil
        }
        return [eventKey: data]
    }

    /// The event in a received user info, as sent (no checks). Nil when there is none.
    public static func event(from payload: [String: Any]) -> WidgetEvent? {
        guard let data = payload[eventKey] as? Data else {
            return nil
        }
        return try? JSONCoding.makeDecoder().decode(WidgetEvent.self, from: data)
    }

    /// The event the phone writes into its App Group mailbox for a received user info: only the two
    /// watch buttons ("Biliyorum" is `known`, "Sonraki kelime" is `next`) for a real word id, with
    /// the source set to `.watch`. Anything else, such as a grade (`unknown`), is dropped: the watch
    /// does not grade words.
    public static func phoneMailboxEvent(from payload: [String: Any]) -> WidgetEvent? {
        guard let event = event(from: payload), event.wordID > 0 else {
            return nil
        }
        switch event.type {
        case .known, .next:
            return WidgetEvent(type: event.type, wordID: event.wordID, at: event.at, source: .watch)
        default:
            return nil
        }
    }

    private static func withoutConfusables(_ word: WidgetWord) -> WidgetWord {
        return WidgetWord(
            id: word.id,
            lemma: word.lemma,
            pos: word.pos,
            level: word.level,
            ipaUS: word.ipaUS,
            defMicro: word.defMicro,
            defShort: word.defShort,
            exampleEN: word.exampleEN,
            glossTR: word.glossTR,
            glossShortTR: word.glossShortTR,
            sensitivity: word.sensitivity,
            confusableIDs: nil
        )
    }
}

/// Words marked known on the watch in the last days (watch only: `watch_known.json` in the watch's
/// App Group container, written by the watch app). The phone hears of a "Biliyorum" only when the
/// event reaches it, so a plan it wrote before that may still hold the word: the watch removes
/// these words from every plan it receives meanwhile (`filter(_:now:)`).
public struct WatchKnownLedger: Codable, Equatable, Sendable {
    public static let fileName = "watch_known.json"
    /// The phone asks a "Biliyorum" word once 3 days later and may queue it again after that, so a
    /// mark is kept no longer.
    public static let keepFor: TimeInterval = 3 * 24 * 3600

    public struct Mark: Codable, Equatable, Sendable {
        public var wordID: Int
        public var at: Date

        public init(wordID: Int, at: Date) {
            self.wordID = wordID
            self.at = at
        }

        enum CodingKeys: String, CodingKey {
            case wordID = "word_id"
            case at
        }
    }

    public var marks: [Mark]

    public init(marks: [Mark] = []) {
        self.marks = marks
    }

    /// Adds a mark for `wordID` at `date`, replacing an earlier mark of the same word.
    public mutating func record(_ wordID: Int, at date: Date) {
        marks.removeAll { $0.wordID == wordID }
        marks.append(Mark(wordID: wordID, at: date))
    }

    /// The marks less than `keepFor` away from `now`, in either direction (a mark far in the future
    /// comes from a clock that was wrong).
    public func pruned(now: Date) -> WatchKnownLedger {
        return WatchKnownLedger(marks: marks.filter { abs(now.timeIntervalSince($0.at)) < WatchKnownLedger.keepFor })
    }

    public func activeIDs(now: Date) -> Set<Int> {
        return Set(pruned(now: now).marks.map { $0.wordID })
    }

    /// `plan` without the words marked recently. Unchanged when that would leave no word: the watch
    /// keeps showing words rather than nothing.
    public func filter(_ plan: WidgetPlan, now: Date) -> WidgetPlan {
        let hidden = activeIDs(now: now)
        if hidden.isEmpty {
            return plan
        }
        let queue = plan.queue.filter { !hidden.contains($0.id) }
        if queue.isEmpty {
            return plan
        }
        var result = plan
        result.queue = queue
        return result
    }

    // MARK: File (watch App Group container)

    public static func url(in containerURL: URL) -> URL {
        return containerURL.appendingPathComponent(fileName)
    }

    /// The ledger in `containerURL`; empty when the file is missing or does not decode.
    public static func read(from containerURL: URL) -> WatchKnownLedger {
        guard let data = try? Data(contentsOf: url(in: containerURL)),
              let ledger = try? JSONCoding.makeDecoder().decode(WatchKnownLedger.self, from: data)
        else {
            return WatchKnownLedger()
        }
        return ledger
    }

    public func write(to containerURL: URL) throws {
        let data = try JSONCoding.makeEncoder().encode(self)
        try AtomicFile.write(data, to: WatchKnownLedger.url(in: containerURL))
    }
}
