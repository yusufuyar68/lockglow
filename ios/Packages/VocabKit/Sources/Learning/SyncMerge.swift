import Foundation
import CoreModels

/// One iCloud sync of this device (docs/ozellik_planlari/icloud_esitleme.md): this device's
/// progress and words, iCloud's copy and what the last sync left (`SyncState`) give the new
/// progress and words of this device and the new copy for iCloud. Pure; the app saves and uploads
/// the result (ios/App/AppModel+Sync.swift).
///
/// The device's own files stay the truth: iCloud is where devices meet. So nothing on this device
/// is ever removed because iCloud lacks it; only an explicit deletion (`SyncSnapshot.deleted`) or
/// a reset (`SyncSnapshot.resetAt`) removes something.
///
/// **Clock.** Every record that changes in iCloud gets this sync's time (`clock`): now, but always
/// after every time already in iCloud's copy and in the base, so a device whose clock is behind
/// still stamps its change as newer. A record in iCloud with an older time than the same record
/// in the base is an older copy that won a race in iCloud (two devices wrote at once), not a
/// change made since.
///
/// **Progress, per word:**
/// 1. Equal on both sides: kept.
/// 2. Only one side changed it since the last sync (`SyncState.base`): that side. This keeps
///    changes without a new date, such as "Öğrenmeye geri al" or the 5-second "Geri al", on every
///    device. iCloud's side counts as changed only when its time is not older than the base's.
/// 3. Both changed it: the later answer wins (`lastReviewedAt`), then the later `lastSeenAt`, the
///    more answers and the more widget views; a full tie goes to the same record on every device.
///
/// **The user's words** are matched by uuid (`SyncState.uuids`). A remembered uuid whose iCloud
/// word was made at another time (a backup brought an old id back) is not used. A word without a
/// uuid takes the uuid of an unmatched iCloud word with exactly the same text, otherwise a new
/// one: two different texts are never merged into one. Each device keeps its own ids, so ids never
/// clash. Text: like progress, with `updatedAt` as the date. A word deleted here since the last
/// sync is deleted everywhere, unless another device edited it since: then the edit wins and the
/// word comes back here. A word deleted elsewhere is deleted here, unless it was edited (or
/// brought back with "Vazgeç") here since.
///
/// **Reset:** "İlerlemeyi sıfırla" while sync is on sets `SyncState.resetAt`. The newer reset
/// wins: the other side's progress from before it is dropped, later progress stays.
///
/// **Turning sync on** (`SyncState.joined` false) only adds: the first meeting with iCloud's copy
/// deletes or resets nothing on this device, and every word of this device stays.
public enum SyncMerge {
    public struct Result: Equatable, Sendable {
        /// This device's new progress; nil when it stays as it is.
        public var progress: [Int: WordProgress]?
        /// This device's new list of words; nil when it stays as it is.
        public var words: CustomWordList?
        /// The copy to write to iCloud; nil when iCloud already has it.
        public var upload: SyncSnapshot?
        /// iCloud's copy once the upload is done.
        public var merged: SyncSnapshot
        /// To save once `progress`, `words` and `upload` are all saved.
        public var state: SyncState
        /// To save when everything here was saved but the upload failed: the base stays the old
        /// one, because iCloud still has what it had.
        public var stateIfUploadFails: SyncState
    }

    /// Merges this device's `progress` and `words` with iCloud's `remote` (nil: no copy has
    /// reached this device yet). `localMayBeOld`: this device's progress or words file was
    /// restored from a backup at launch, so a word missing here may have been lost, not deleted,
    /// and an old record may look like a change; the base is not used this time.
    public static func sync(
        progress inputProgress: [Int: WordProgress],
        words inputWords: CustomWordList,
        remote: SyncSnapshot?,
        state inputState: SyncState,
        localMayBeOld: Bool = false,
        now: Date = Date(),
        makeUUID: () -> String = { UUID().uuidString }
    ) -> Result {
        // Dates as a JSON round trip gives them: a fresh `Date()` must not look like a change.
        let progress = canonicalProgress(inputProgress)
        let words = CustomWordList(words: SyncCoding.canonical(inputWords.words), nextID: inputWords.nextID)
        let state = SyncCoding.canonical(inputState)
        let joined = state.joined
        let base = joined && !localMayBeOld ? state.base : nil
        let tick = clock(now: now, after: [remote?.latestChange, state.base?.latestChange])

        // 1. A uuid for every word of this device.
        var madeAt: [String: Date] = [:]
        for entry in (state.base?.words ?? []) + (remote?.words ?? []) {
            madeAt[entry.uuid] = entry.createdAt
        }
        var uuids = state.uuids
        var uuidOfWord: [Int: String] = [:]
        var taken = Set<String>()
        var unmatched: [CustomWord] = []
        for word in words.words {
            if let uuid = uuids[word.id],
               madeAt[uuid].map({ $0 == word.createdAt }) ?? true,
               taken.insert(uuid).inserted {
                uuidOfWord[word.id] = uuid
            } else {
                // No uuid yet, or the remembered one is another word's (an old id came back).
                uuids.removeValue(forKey: word.id)
                unmatched.append(word)
            }
        }
        let remembered = Set(uuids.values)
        // iCloud's words no id here knows yet, by their whole text; the smallest uuid first.
        var unclaimed: [String: String] = [:]
        for entry in remote?.words ?? [] where !remembered.contains(entry.uuid) {
            let key = textKey(lemma: entry.lemma, meaning: entry.meaningTR, example: entry.exampleEN, note: entry.note)
            if unclaimed[key] == nil {
                unclaimed[key] = entry.uuid
            }
        }
        for word in unmatched {
            let key = textKey(lemma: word.lemma, meaning: word.meaningTR, example: word.exampleEN, note: word.note)
            var uuid = unclaimed.removeValue(forKey: key) ?? makeUUID()
            while taken.contains(uuid) {
                uuid = makeUUID()
            }
            uuids[word.id] = uuid
            uuidOfWord[word.id] = uuid
            taken.insert(uuid)
        }
        // This device's id of each uuid: its current word, else the id of a word deleted here.
        var localID: [String: Int] = [:]
        for (id, uuid) in uuidOfWord {
            localID[uuid] = id
        }
        for (id, uuid) in uuids.sorted(by: { $0.key < $1.key }) where localID[uuid] == nil {
            localID[uuid] = id
        }

        // 2. Which reset each side's progress belongs to.
        let localReset = state.resetAt
        let remoteReset = remote?.resetAt
        let mergedReset: Date?
        var localCutoff: Date?
        var remoteCutoff: Date?
        if localReset == remoteReset {
            mergedReset = localReset
        } else if isLater(localReset, than: remoteReset) {
            mergedReset = localReset
            remoteCutoff = localReset
        } else {
            mergedReset = remoteReset
            // Turning sync on: this device keeps all its progress and joins iCloud's reset.
            localCutoff = joined ? remoteReset : nil
        }

        // 3. Cards.
        var localCards: [Int: WordProgress] = [:]
        for (id, record) in progress where !CustomWordID.contains(id) {
            if let kept = surviving(record, cutoff: localCutoff) {
                localCards[id] = kept.wordID == id ? kept : kept.reidentified(id)
            }
        }
        var remoteCards: [Int: SyncCard] = [:]
        for card in remote?.cards ?? [] where surviving(card.progress, cutoff: remoteCutoff) != nil {
            remoteCards[card.progress.wordID] = card
        }
        var baseCards: [Int: SyncCard] = [:]
        for card in base?.cards ?? [] {
            baseCards[card.progress.wordID] = card
        }
        var mergedCards: [SyncCard] = []
        for id in Set(localCards.keys).union(remoteCards.keys).sorted() {
            if let card = pickRecord(local: localCards[id], remote: remoteCards[id], base: baseCards[id], now: tick) {
                mergedCards.append(card)
            }
        }

        // 4. The user's words.
        var localEntries: [String: SyncWord] = [:]
        for word in words.words {
            guard let uuid = uuidOfWord[word.id] else {
                continue
            }
            localEntries[uuid] = SyncWord(uuid: uuid, word: word, changedAt: tick, progress: surviving(progress[word.id], cutoff: localCutoff))
        }
        var remoteLive: [String: SyncWord] = [:]
        for entry in remote?.words ?? [] {
            var copy = entry
            if surviving(entry.progress, cutoff: remoteCutoff) == nil {
                copy.progress = nil
                copy.progressChangedAt = nil
            }
            remoteLive[entry.uuid] = copy
        }
        var remoteGone: [String: Date] = [:]
        for deletion in remote?.deleted ?? [] {
            remoteGone[deletion.uuid] = deletion.deletedAt
        }
        var baseLive: [String: SyncWord] = [:]
        for entry in base?.words ?? [] {
            baseLive[entry.uuid] = entry
        }
        var baseGone: [String: Date] = [:]
        for deletion in base?.deleted ?? [] {
            baseGone[deletion.uuid] = deletion.deletedAt
        }

        var mergedWords: [SyncWord] = []
        var deletions: [SyncDeletion] = []
        let allUUIDs = Set(localEntries.keys)
            .union(remoteLive.keys)
            .union(remoteGone.keys)
            .union(baseLive.keys)
            .union(baseGone.keys)
        for uuid in allUUIDs.sorted() {
            let mine = localEntries[uuid]
            let theirs = remoteLive[uuid]
            let last = baseLive[uuid]
            var kept: SyncWord?
            var goneAt: Date?
            var localProgress = mine?.progress
            if let mine = mine {
                if let theirs = theirs {
                    kept = pickContent(local: mine, remote: theirs, base: last, now: tick)
                } else if let deletedAt = remoteGone[uuid] {
                    if let last = last, mine.hasSameContent(as: last), deletedAt >= last.changedAt {
                        // Deleted on another device, not changed here since.
                        goneAt = deletedAt
                    } else {
                        // Edited here, back with "Vazgeç", new here, or sync was just turned on.
                        kept = mine
                    }
                } else {
                    kept = mine
                    if let last = last, mine.hasSameContent(as: last) {
                        kept?.changedAt = last.changedAt
                    }
                }
            } else {
                // The progress left here under the id of a word deleted here, if any.
                localProgress = localID[uuid].flatMap { surviving(progress[$0], cutoff: localCutoff) }?.reidentified(0)
                if let last = last {
                    // Deleted here since the last sync: deleted everywhere, unless another device
                    // edited it since (the edit wins over the deletion).
                    if let theirs = theirs, !theirs.hasSameContent(as: last), theirs.changedAt >= last.changedAt {
                        kept = theirs
                    } else {
                        goneAt = theirs == nil ? (remoteGone[uuid] ?? tick) : tick
                    }
                } else if let theirs = theirs {
                    if let deletedAt = baseGone[uuid], theirs.changedAt < deletedAt {
                        // An older copy of a word deleted before won a race in iCloud.
                        goneAt = tick
                    } else {
                        kept = theirs
                    }
                } else {
                    goneAt = remoteGone[uuid] ?? baseGone[uuid]
                }
            }
            if var entry = kept {
                let record = pickRecord(
                    local: localProgress,
                    remote: progressCard(of: theirs),
                    base: progressCard(of: last),
                    now: tick
                )
                entry.progress = record?.progress
                entry.progressChangedAt = record?.changedAt
                mergedWords.append(entry)
            } else if let deletedAt = goneAt {
                deletions.append(SyncDeletion(uuid: uuid, deletedAt: deletedAt))
            }
        }

        let merged = SyncSnapshot(resetAt: mergedReset, cards: mergedCards, words: mergedWords, deleted: deletions)

        // 5. This device's new words: its own ids; a word new here gets the next id, in the order
        // the words were made (the list stays oldest first).
        var nextID = max(words.nextID, (uuids.keys.max() ?? 0) + 1)
        var newWords: [CustomWord] = []
        let byAge = merged.words.sorted { lhs, rhs in
            lhs.createdAt != rhs.createdAt ? lhs.createdAt < rhs.createdAt : lhs.uuid < rhs.uuid
        }
        for entry in byAge {
            let id: Int
            if let known = localID[entry.uuid] {
                id = known
            } else {
                id = nextID
                nextID += 1
                uuids[id] = entry.uuid
                localID[entry.uuid] = id
            }
            newWords.append(entry.customWord(id: id))
        }
        let newList = CustomWordList(words: newWords, nextID: nextID)

        // 6. This device's new progress. Records of words deleted here stay, as after a deletion
        // in the app (an id is never reused).
        var newProgress = progress
        if let cutoff = localCutoff {
            newProgress = newProgress.filter { surviving($0.value, cutoff: cutoff) != nil }
        }
        for card in merged.cards {
            newProgress[card.progress.wordID] = card.progress
        }
        for entry in merged.words {
            guard let id = localID[entry.uuid] else {
                continue
            }
            if let record = entry.progress {
                newProgress[id] = record.reidentified(id)
            } else {
                newProgress.removeValue(forKey: id)
            }
        }

        let upload: SyncSnapshot?
        if let remote = remote {
            upload = merged == remote ? nil : merged
        } else {
            upload = merged.isEmpty ? nil : merged
        }
        // Joined once a copy from iCloud was met: before that, a copy still on its way must be
        // met like the first one.
        let nowJoined = joined || remote != nil
        return Result(
            progress: newProgress == progress ? nil : newProgress,
            words: newList == words ? nil : newList,
            upload: upload,
            merged: merged,
            state: SyncState(joined: nowJoined, resetAt: mergedReset, uuids: uuids, base: merged),
            stateIfUploadFails: SyncState(joined: nowJoined, resetAt: mergedReset, uuids: uuids, base: state.base)
        )
    }

    // MARK: Rules

    /// The progress record both sides keep (rules 1–3 in the type comment), with its iCloud time:
    /// iCloud's own when iCloud already has this version, `now` when it is new there. Nil when
    /// neither side has one. Also used for a word's progress (`wordID` 0).
    public static func pickRecord(local: WordProgress?, remote: SyncCard?, base: SyncCard?, now: Date) -> SyncCard? {
        guard let local = local else {
            return remote
        }
        guard let remote = remote else {
            if let base = base, base.progress == local {
                return base
            }
            return SyncCard(progress: local, changedAt: now)
        }
        if local == remote.progress {
            return remote
        }
        let keepsLocal: Bool
        if let base = base, remote.progress == base.progress {
            keepsLocal = true
        } else if let base = base, local == base.progress {
            // Only iCloud changed it, unless iCloud's copy is older than the base.
            keepsLocal = remote.changedAt < base.changedAt
        } else {
            keepsLocal = laterWins(local, over: remote.progress)
        }
        return keepsLocal ? SyncCard(progress: local, changedAt: now) : remote
    }

    /// Whether `local` wins over `remote` when both changed: last answer, then last view or
    /// "Biliyorum", then more answers, then more views; a full tie the same on every device.
    static func laterWins(_ local: WordProgress, over remote: WordProgress) -> Bool {
        switch order(local, remote) {
        case .orderedDescending:
            return true
        case .orderedAscending:
            return false
        case .orderedSame:
            return sameOnEveryDevice(local, remote) == local
        }
    }

    /// The later of two records. A missing date is the earliest.
    static func order(_ lhs: WordProgress, _ rhs: WordProgress) -> ComparisonResult {
        let past = Date.distantPast
        let keys: [(Date, Date)] = [
            (lhs.lastReviewedAt ?? past, rhs.lastReviewedAt ?? past),
            (lhs.lastSeenAt ?? past, rhs.lastSeenAt ?? past),
        ]
        for (left, right) in keys where left != right {
            return left > right ? .orderedDescending : .orderedAscending
        }
        if lhs.reviews != rhs.reviews {
            return lhs.reviews > rhs.reviews ? .orderedDescending : .orderedAscending
        }
        if lhs.exposures != rhs.exposures {
            return lhs.exposures > rhs.exposures ? .orderedDescending : .orderedAscending
        }
        return .orderedSame
    }

    /// The text both sides keep, by the same rules with `updatedAt` as the date. Its `changedAt`
    /// is iCloud's when iCloud keeps its text, otherwise `now`. The progress is chosen apart.
    static func pickContent(local: SyncWord, remote: SyncWord, base: SyncWord?, now: Date) -> SyncWord {
        if local.hasSameContent(as: remote) {
            return remote
        }
        let keepsLocal: Bool
        if let base = base, remote.hasSameContent(as: base) {
            keepsLocal = true
        } else if let base = base, local.hasSameContent(as: base) {
            keepsLocal = remote.changedAt < base.changedAt
        } else if local.updatedAt != remote.updatedAt {
            keepsLocal = local.updatedAt > remote.updatedAt
        } else {
            let left = [local.lemma, local.meaningTR, local.exampleEN ?? "", local.note ?? "", "\(local.createdAt.timeIntervalSince1970)"]
            let right = [remote.lemma, remote.meaningTR, remote.exampleEN ?? "", remote.note ?? "", "\(remote.createdAt.timeIntervalSince1970)"]
            keepsLocal = right.lexicographicallyPrecedes(left)
        }
        guard keepsLocal else {
            return remote
        }
        var entry = local
        entry.changedAt = now
        return entry
    }

    /// This sync's time: `now`, but after every time already seen (`after`), so a change made
    /// here is newer than everything this device has met even when its clock is behind.
    static func clock(now: Date, after seen: [Date?]) -> Date {
        let candidate = seen.compactMap { $0 }.max().map { max(now, $0.addingTimeInterval(0.001)) } ?? now
        return SyncCoding.canonical([candidate]).first ?? candidate
    }

    /// The same English word (case ignored) with the same meaning, example and note.
    private static func textKey(lemma: String, meaning: String, example: String?, note: String?) -> String {
        return [CustomWordText.duplicateKey(lemma), meaning, example ?? "", note ?? ""].joined(separator: "\u{1F}")
    }

    /// A word's progress with its iCloud time.
    private static func progressCard(of entry: SyncWord?) -> SyncCard? {
        guard let entry = entry, let record = entry.progress else {
            return nil
        }
        return SyncCard(progress: record, changedAt: entry.progressChangedAt ?? entry.changedAt)
    }

    /// Two different records the rules cannot order: the one with the larger encoding, so every
    /// device picks the same one.
    private static func sameOnEveryDevice(_ lhs: WordProgress, _ rhs: WordProgress) -> WordProgress {
        let encoder = SyncCoding.encoder()
        guard let left = try? encoder.encode(lhs), let right = try? encoder.encode(rhs) else {
            return lhs
        }
        return right.lexicographicallyPrecedes(left) ? lhs : rhs
    }

    /// `record`, unless a reset at `cutoff` removed it (nothing dated after the reset).
    static func surviving(_ record: WordProgress?, cutoff: Date?) -> WordProgress? {
        guard let record = record else {
            return nil
        }
        guard let cutoff = cutoff else {
            return record
        }
        guard let changed = record.lastChange, changed > cutoff else {
            return nil
        }
        return record
    }

    /// `lhs` is a reset after `rhs` (nil: never reset).
    private static func isLater(_ lhs: Date?, than rhs: Date?) -> Bool {
        guard let lhs = lhs else {
            return false
        }
        guard let rhs = rhs else {
            return true
        }
        return lhs > rhs
    }

    /// `progress` with dates as a JSON round trip gives them.
    private static func canonicalProgress(_ progress: [Int: WordProgress]) -> [Int: WordProgress] {
        let keys = progress.keys.sorted()
        let values = SyncCoding.canonical(keys.compactMap { progress[$0] })
        guard values.count == keys.count else {
            return progress
        }
        var result: [Int: WordProgress] = [:]
        for (key, value) in zip(keys, values) {
            result[key] = value
        }
        return result
    }
}
