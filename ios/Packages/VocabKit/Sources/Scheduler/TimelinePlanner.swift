import Foundation
import CoreModels

/// Pure, deterministic word rotation, shared by the widget (timeline) and the app (plan rewrite).
///
/// Model: the rotation starts at queue index `cursorOffset` at time `cursorAnchor`. `R` is one
/// lap of the queue from that index with known ids removed. Time moves the rotation on by one
/// word per interval boundary: the word shown at time `t` is
/// `R[elapsed(cursorAnchor, t) mod R.count]`, where `elapsed` counts the interval boundaries
/// crossed between the anchor and `t` (never negative). Boundaries are
/// `floor((unixTime + alignmentOffset) / interval)`, so every widget instance changes word at
/// the same instants, and a timeline regenerated later continues instead of restarting.
public enum TimelinePlanner {
    public typealias PlannedEntry = (date: Date, word: WidgetWord)

    /// WidgetKit entries should be at least about 5 minutes apart.
    public static let minimumInterval: TimeInterval = 300
    public static let defaultHorizon: TimeInterval = 48 * 3600
    public static let defaultMaxEntries = 96
    /// 2026-01-01T00:00:00Z. Fixed anchor for the seed rotation (no plan yet), so the seed
    /// words rotate deterministically with time.
    public static let seedAnchor = Date(timeIntervalSince1970: 1_767_225_600)

    /// Timeline for the widget: entry 0 at `now`, then one entry per later interval boundary.
    /// Every entry shows the word `wordAt` returns for that entry's own date; for an anchor that
    /// is not in the future, entry `i` is `R[(elapsed(cursorAnchor, now) + i) mod R.count]`.
    ///
    /// - Parameters:
    ///   - queue: Words in plan order.
    ///   - knownIDs: Word ids to skip.
    ///   - cursorOffset: Queue index the rotation started from at `cursorAnchor`. Any integer; it wraps.
    ///   - cursorAnchor: Moment the rotation was at `cursorOffset`.
    ///   - now: Date of the first entry.
    ///   - interval: Seconds between word changes. Clamped to `minimumInterval`.
    ///   - horizon: How far past `now` entries may reach. Negative or NaN: nothing after `now`.
    ///   - maxEntries: Hard cap on the number of entries.
    ///   - alignmentOffset: Seconds added to UTC before aligning boundaries. Pass
    ///     `localAlignmentOffset(for:)` so daily boundaries fall on local midnight.
    /// - Returns: Entries in date order. Empty when the queue is empty or every word is known.
    ///   Only the entry at `now` when `now` is off the boundary grid (not finite, or more than
    ///   1e15 intervals from 1970; also for a non-finite or huge `alignmentOffset`).
    public static func plan(
        queue: [WidgetWord],
        knownIDs: Set<Int>,
        cursorOffset: Int,
        cursorAnchor: Date,
        now: Date,
        interval: TimeInterval,
        horizon: TimeInterval = defaultHorizon,
        maxEntries: Int = defaultMaxEntries,
        alignmentOffset: TimeInterval = 0
    ) -> [PlannedEntry] {
        guard maxEntries > 0 else {
            return []
        }
        let lap = playableWords(queue: queue, knownIDs: knownIDs, cursorOffset: cursorOffset)
        guard !lap.isEmpty else {
            return []
        }

        let step = clampedInterval(interval)
        let gridIndex = exactBoundaryIndex(of: now, step: step, alignmentOffset: alignmentOffset)
        let nowIndex = gridIndex ?? 0
        let anchorIndex = boundaryIndex(of: cursorAnchor, step: step, alignmentOffset: alignmentOffset)

        // Same formula as `wordAt`: R[max(0, boundaryIndex - anchorIndex) mod R.count].
        var entries: [PlannedEntry] = []
        entries.append((date: now, word: lap[max(0, nowIndex - anchorIndex) % lap.count]))

        // Off the grid no boundary date after `now` can be computed: the loop would never find one.
        guard gridIndex != nil else {
            return entries
        }
        let horizonEnd = now.addingTimeInterval(horizon.isNaN ? 0 : max(horizon, 0))

        // Boundary `nowIndex + 1` is after `now` except through rounding, so `maxEntries` steps
        // always fill the timeline; the bound keeps the loop finite whatever the inputs.
        for boundariesAhead in 1...maxEntries {
            if entries.count >= maxEntries {
                break
            }
            let index = nowIndex + boundariesAhead
            let date = boundaryDate(index: index, step: step, alignmentOffset: alignmentOffset)
            if date > horizonEnd {
                break
            }
            if date > now {
                entries.append((date: date, word: lap[max(0, index - anchorIndex) % lap.count]))
            }
        }
        return entries
    }

    /// The word the rotation shows at `date`. Uses the same helpers as `plan`.
    /// Nil when the queue is empty or every word is known.
    public static func wordAt(
        _ date: Date,
        queue: [WidgetWord],
        knownIDs: Set<Int>,
        cursorOffset: Int,
        cursorAnchor: Date,
        interval: TimeInterval,
        alignmentOffset: TimeInterval = 0
    ) -> WidgetWord? {
        let lap = playableWords(queue: queue, knownIDs: knownIDs, cursorOffset: cursorOffset)
        guard !lap.isEmpty else {
            return nil
        }
        let elapsed = elapsedBoundaries(
            from: cursorAnchor,
            to: date,
            interval: interval,
            alignmentOffset: alignmentOffset
        )
        return lap[elapsed % lap.count]
    }

    /// Interval boundaries crossed between `anchor` and `date`. Zero if `date` is not after
    /// the anchor's boundary (so an anchor in the future never gives a negative count).
    public static func elapsedBoundaries(
        from anchor: Date,
        to date: Date,
        interval: TimeInterval,
        alignmentOffset: TimeInterval = 0
    ) -> Int {
        let step = clampedInterval(interval)
        let toIndex = boundaryIndex(of: date, step: step, alignmentOffset: alignmentOffset)
        let fromIndex = boundaryIndex(of: anchor, step: step, alignmentOffset: alignmentOffset)
        return max(0, toIndex - fromIndex)
    }

    /// Date of the last entry: the fallback reload date for policy `.atEnd`.
    public static func reloadDate(for entries: [PlannedEntry]) -> Date? {
        return entries.last?.date
    }

    public static func clampedInterval(_ interval: TimeInterval) -> TimeInterval {
        if !interval.isFinite {
            return minimumInterval
        }
        return max(interval, minimumInterval)
    }

    /// UTC offset of the current time zone at `date`, in seconds. The ONE place the widget and
    /// the app get their `alignmentOffset` from.
    public static func localAlignmentOffset(for date: Date, timeZone: TimeZone = TimeZone.current) -> TimeInterval {
        return TimeInterval(timeZone.secondsFromGMT(for: date))
    }

    /// Anchors and plan dates are stored as ISO 8601 (whole seconds). Boundaries sit on whole
    /// seconds (integer interval, integer offset), so rounding down to a whole second never
    /// changes which boundary a date falls in: the stored value behaves exactly like the original.
    /// Callers round before using a date for both the computation and the stored value.
    public static func roundedDownToWholeSecond(_ date: Date) -> Date {
        let seconds = date.timeIntervalSince1970
        if !seconds.isFinite {
            return date
        }
        return Date(timeIntervalSince1970: seconds.rounded(.down))
    }

    // MARK: Shared helpers

    /// One lap of the queue starting at the cursor, with known words removed.
    static func playableWords(
        queue: [WidgetWord],
        knownIDs: Set<Int>,
        cursorOffset: Int
    ) -> [WidgetWord] {
        let count = queue.count
        if count == 0 {
            return []
        }
        let start = positiveModulo(cursorOffset, count)
        var result: [WidgetWord] = []
        result.reserveCapacity(count)
        for step in 0..<count {
            let word = queue[(start + step) % count]
            if !knownIDs.contains(word.id) {
                result.append(word)
            }
        }
        return result
    }

    static func positiveModulo(_ value: Int, _ modulus: Int) -> Int {
        return ((value % modulus) + modulus) % modulus
    }

    /// Off-grid dates count as index 0, so `wordAt` still answers for them.
    private static func boundaryIndex(of date: Date, step: TimeInterval, alignmentOffset: TimeInterval) -> Int {
        return exactBoundaryIndex(of: date, step: step, alignmentOffset: alignmentOffset) ?? 0
    }

    /// Nil when the date is off the grid: the index is not finite or more than 1e15 from 0.
    private static func exactBoundaryIndex(of date: Date, step: TimeInterval, alignmentOffset: TimeInterval) -> Int? {
        let value = ((date.timeIntervalSince1970 + alignmentOffset) / step).rounded(.down)
        if !value.isFinite || abs(value) > 1e15 {
            return nil
        }
        return Int(value)
    }

    private static func boundaryDate(index: Int, step: TimeInterval, alignmentOffset: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: Double(index) * step - alignmentOffset)
    }
}
