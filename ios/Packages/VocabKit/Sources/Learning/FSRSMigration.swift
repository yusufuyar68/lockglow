import Foundation

/// Switching "Yeni zamanlama" on and off (fsrs.md 4.2). Pure: the app saves the result
/// before it changes the setting, so a failed save leaves Leitner scheduling as before.
///
/// **On** (`takeOver`): every answered word gets an FSRS memory, and nothing else changes. No due
/// date moves (no pile-up on the switch day), no step or "Yerleşti" changes (the counts on screen
/// stay), and the review log is only read. FSRS times each word from its next answer on.
///
/// **Off** (`handBack`): FSRS keeps `state`, `box`, `dueAt` and `refresherStep` in Leitner's
/// terms (`ReviewScheduler`), so Leitner goes on from the step and refresher wait FSRS left; only
/// due dates beyond Leitner's longest wait for that step come earlier. The memories stay in the
/// file; once Leitner answers a word, its memory no longer counts all answers
/// (`FSRSState.reviews`) and the next `takeOver` rebuilds it from the log.
///
/// Running `takeOver` again changes nothing: a word whose memory is up to date is kept.
public enum FSRSMigration {
    /// How the words got their memory.
    public struct Report: Equatable, Sendable {
        /// Rebuilt exactly from the review log (`FSRSScheduler.replay`).
        public var replayed = 0
        /// Estimated from the Leitner schedule: answers missing from the log (before the log
        /// began, trimmed or lost lines; fsrs.md 4.2 step 2).
        public var estimated = 0
        /// Already up to date.
        public var kept = 0
        /// No memory to estimate: a "Biliyorum" not checked yet, or a word sent back to "Tanış".
        /// Its next answer is its first for FSRS (4.2 step 3).
        public var withoutMemory = 0

        public init() {}
    }

    /// `progress` with an FSRS memory for every answered word whose memory is missing or out of
    /// date: from the log when it holds all of the word's answers, otherwise estimated. Only
    /// `WordProgress.fsrs` changes. Words never answered are left as they are.
    public static func takeOver(
        _ progress: [Int: WordProgress],
        log: [ReviewLogEntry],
        scheduler: FSRSScheduler,
        now: Date
    ) -> (progress: [Int: WordProgress], report: Report) {
        let replay = scheduler.replay(log)
        var result = progress
        var report = Report()
        for (id, p) in progress where p.reviews > 0 {
            if let state = p.fsrs, state.reviews == p.reviews {
                report.kept += 1
                continue
            }
            var q = p
            if replay.reviews[id] == p.reviews, let card = replay.cards[id],
               let state = FSRSState(card: card, reviews: p.reviews, shelfBefore: nil) {
                q.fsrs = state
                report.replayed += 1
            } else if let state = FSRSState(card: scheduler.estimatedCard(of: p, at: now), reviews: p.reviews, shelfBefore: nil) {
                q.fsrs = state
                report.estimated += 1
            } else {
                q.fsrs = nil
                report.withoutMemory += 1
            }
            result[id] = q
        }
        return (result, report)
    }

    /// Switch-off: Leitner's longest waits for the dates FSRS set. A word whose last answer was
    /// FSRS's and whose due date lies beyond the wait Leitner gives its step (a learning word's
    /// `Leitner.intervalDays`, a known word's `Leitner.refresherWait`) comes back after that wait
    /// instead (FSRS may wait up to a year, Leitner 120 days). Dates only move earlier; a pending
    /// "Biliyorum" check and every other field stay. Running it again changes nothing.
    public static func handBack(_ progress: [Int: WordProgress]) -> [Int: WordProgress] {
        var result = progress
        for (id, p) in progress {
            guard let state = p.fsrs, state.reviews == p.reviews, state.shelfBefore != nil,
                  !p.awaitsKnownCheck, let last = p.lastReviewedAt, let due = p.dueAt else {
                continue
            }
            let limit: TimeInterval
            switch p.state {
            case .new:
                continue
            case .learning:
                limit = Leitner.intervalDays[min(max(p.box, 1), Leitner.maxBox) - 1] * 86_400
            case .known:
                limit = Leitner.refresherWait(step: p.refresherStep ?? 0)
            }
            let latest = last.addingTimeInterval(limit)
            if due > latest {
                var q = p
                q.dueAt = latest
                result[id] = q
            }
        }
        return result
    }

    /// Progress from elsewhere (an iCloud sync, an import) as this device's scheduler may keep it.
    /// The scheduler setting is not synced, so another device may run FSRS while this one runs
    /// Leitner: Leitner then gets `handBack`'s dates, never FSRS's long waits (up to a year). FSRS
    /// takes the records as they are; a memory Leitner left out of date is rebuilt by the next
    /// refit (`outdatedCount`). Running it again changes nothing.
    public static func adopted(_ progress: [Int: WordProgress], by kind: SchedulerKind) -> [Int: WordProgress] {
        switch kind {
        case .leitner:
            return handBack(progress)
        case .fsrs:
            return progress
        }
    }

    /// One iCloud sync (`SyncMerge.Result`) as this device's scheduler may keep it. On Leitner the
    /// new progress gets `adopted`'s dates, and so does the sync's base (`SyncState.base`): the
    /// earlier dates then count as iCloud's version, not as a change made here, so they are never
    /// uploaded and a device on FSRS keeps its own waits. Each later sync takes iCloud's version
    /// again and shortens it the same way; `progress` is nil when that leaves `local` as it is
    /// (nothing to save). The state kept when the upload fails gets the same base, so a failed
    /// upload does not send the earlier dates on the next sync either. The copy for iCloud
    /// (`upload`, `merged`) is never touched. FSRS takes the result as it is.
    public static func adopted(_ result: SyncMerge.Result, local: [Int: WordProgress], by kind: SchedulerKind) -> SyncMerge.Result {
        guard kind == .leitner else {
            return result
        }
        var kept = result
        if let merged = result.progress {
            let shortened = adopted(merged, by: kind)
            kept.progress = shortened == local ? nil : shortened
        }
        kept.state.base = kept.state.base.map(handedBack)
        kept.stateIfUploadFails.base = kept.stateIfUploadFails.base.map(handedBack)
        return kept
    }

    /// A sync base with every record through `handBack`.
    private static func handedBack(_ base: SyncSnapshot) -> SyncSnapshot {
        var copy = base
        copy.cards = base.cards.map { card in
            var kept = card
            kept.progress = handedBack(card.progress)
            return kept
        }
        copy.words = base.words.map { entry in
            var kept = entry
            kept.progress = entry.progress.map(handedBack)
            return kept
        }
        return copy
    }

    /// One record through `handBack`.
    private static func handedBack(_ p: WordProgress) -> WordProgress {
        return handBack([p.wordID: p])[p.wordID] ?? p
    }

    /// Words whose memory is missing or out of date: `takeOver` would change them. Cheap, so the
    /// log is read only when this is not zero.
    public static func outdatedCount(_ progress: [Int: WordProgress]) -> Int {
        return progress.values.filter { p in
            p.reviews > 0 && p.fsrs?.reviews != p.reviews && !(p.fsrs == nil && hasNoMemoryToEstimate(p))
        }.count
    }

    /// A claim not checked yet or a word back in "Tanış", without any memory: `takeOver` leaves
    /// it without one, so it never counts as out of date.
    private static func hasNoMemoryToEstimate(_ p: WordProgress) -> Bool {
        return p.state == .new || p.awaitsKnownCheck
    }
}
