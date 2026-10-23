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
/// **Progress, per word:**
/// 1. Equal on both sides: kept.
/// 2. Only one side changed it since the last sync (`SyncState.base`): that side. This keeps
///    changes without a new date, such as "Öğrenmeye geri al" or the 5-second "Geri al".
/// 3. Both changed it: the later answer wins (`lastReviewedAt`), then the later `lastSeenAt`, the
///    more answers and the more widget views; a full tie goes to the side that changed it, or
///    to the same record on every device.
///
/// **The user's words** are matched by uuid (`SyncState.uuids`); a word without a uuid yet takes
/// the uuid of an unmatched iCloud word with the same English word, otherwise a new one. Each
/// device keeps its own ids, so ids never clash. Text: like progress, with `updatedAt` as the date.
/// A word deleted here since the last sync is deleted everywhere, unless another device edited it
/// since: then the edit wins and the word comes back here. A word deleted elsewhere is deleted
/// here, unless it was edited here since.
///
/// **Reset:** "İlerlemeyi sıfırla" while syncing sets `SyncState.resetAt`. The newer reset wins:
/// the other side's progress from before it is dropped, later progress stays.
///
/// **Turning sync on** (`SyncState.joined` false) only adds: nothing on this device is deleted
/// or reset by the first sync, and every word of this device stays.
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

    /// Merges this device's `progress` and `words` with iCloud's `remote` (nil: iCloud has no
    /// copy yet). `localMayBeOld`: this device's progress or words file was restored from a
    /// backup at launch, so a word missing here may have been lost, not deleted, and an old
    /// record may look like a change; the base is not used this time.
    public static func sync(
        progress inputProgress: [Int: WordProgress],
        words inputWords: CustomWordList,
        remote: SyncSnapshot?,
        state inputState: SyncState,
        localMayBeOld: Bool = false,
        makeUUID: () -> String = { UUID().uuidString }
    ) -> Result {
        // Dates as a JSON round trip gives them: a fresh `Date()` must not look like a change.
        let progress = canonicalProgress(inputProgress)
        let words = CustomWordList(words: SyncCoding.canonical(inputWords.words), nextID: inputWords.nextID)
        let state = SyncCoding.canonical(inputState)
        let joined = state.joined
        let base = joined && !localMayBeOld ? state.base : nil

        // 1. A uuid for every word of this device.
        var uuids = state.uuids
        var uuidOfWord: [Int: String] = [:]
        var taken = Set<String>()
        var unmatched: [CustomWord] = []
        for word in words.words {
            if let uuid = uuids[word.id], taken.insert(uuid).inserted {
                uuidOfWord[word.id] = uuid
            } else {
                unmatched.append(word)
            }
        }
        let remembered = Set(uuids.values)
        // iCloud's words no id here knows yet, by English word (case ignored); the smallest uuid first.
        var unclaimed: [String: String] = [:]
        for entry in remote?.words ?? [] where !remembered.contains(entry.uuid) {
            let key = CustomWordText.duplicateKey(entry.lemma)
            if unclaimed[key] == nil {
                unclaimed[key] = entry.uuid
            }
        }
        for word in unmatched {
            var uuid = unclaimed.removeValue(forKey: CustomWordText.duplicateKey(word.lemma)) ?? makeUUID()
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
        let localReset = joined ? state.resetAt : nil
        let remoteReset = remote?.resetAt
        let mergedReset: Date?
        var localCutoff: Date?
        var remoteCutoff: Date?
        if !joined {
            // Turning sync on: this device keeps all its progress and joins iCloud's reset.
            mergedReset = remoteReset
        } else if localReset == remoteReset {
            mergedReset = localReset
        } else if isLater(localReset, than: remoteReset) {
            mergedReset = localReset
            remoteCutoff = localReset
        } else {
            mergedReset = remoteReset
            localCutoff = remoteReset
        }

        // 3. Cards.
        var localCards: [Int: WordProgress] = [:]
        for (id, record) in progress where !CustomWordID.contains(id) {
            if let kept = surviving(record, cutoff: localCutoff) {
                localCards[id] = kept.wordID == id ? kept : kept.reidentified(id)
            }
        }
        var remoteCards: [Int: WordProgress] = [:]
        for record in remote?.cards ?? [] {
            if let kept = surviving(record, cutoff: remoteCutoff) {
                remoteCards[record.wordID] = kept
            }
        }
        var baseCards: [Int: WordProgress] = [:]
        for record in base?.cards ?? [] {
            baseCards[record.wordID] = record
        }
        var mergedCards: [WordProgress] = []
        for id in Set(localCards.keys).union(remoteCards.keys).sorted() {
            if let record = pickProgress(local: localCards[id], remote: remoteCards[id], base: baseCards[id]) {
                mergedCards.append(record)
            }
        }

        // 4. The user's words.
        var localEntries: [String: SyncWord] = [:]
        for word in words.words {
            guard let uuid = uuidOfWord[word.id] else {
                continue
            }
            localEntries[uuid] = SyncWord(uuid: uuid, word: word, progress: surviving(progress[word.id], cutoff: localCutoff))
        }
        var remoteEntries: [String: SyncWord] = [:]
        for entry in remote?.words ?? [] {
            var copy = entry
            copy.progress = surviving(entry.progress, cutoff: remoteCutoff)
            remoteEntries[entry.uuid] = copy
        }
        var baseEntries: [String: SyncWord] = [:]
        for entry in base?.words ?? [] {
            baseEntries[entry.uuid] = entry
        }
        let remoteDeleted = Set(remote?.deleted ?? [])
        var deleted = remoteDeleted
        var mergedEntries: [SyncWord] = []

        /// A word iCloud brings back to this device: the progress left here under its old id, if
        /// it had one, counts too.
        func returning(_ entry: SyncWord, base: SyncWord?) -> SyncWord {
            guard let id = localID[entry.uuid], let left = surviving(progress[id], cutoff: localCutoff) else {
                return entry
            }
            var copy = entry
            copy.progress = pickProgress(local: left.reidentified(0), remote: entry.progress, base: base?.progress)
            return copy
        }

        let allUUIDs = Set(localEntries.keys)
            .union(remoteEntries.keys)
            .union(remoteDeleted)
            .union(baseEntries.keys)
        for uuid in allUUIDs.sorted() {
            let mine = localEntries[uuid]
            let theirs = remoteEntries[uuid]
            let last = baseEntries[uuid]
            var kept: SyncWord?
            switch (mine, theirs) {
            case let (mine?, theirs?):
                var entry = pickContent(local: mine, remote: theirs, base: last)
                entry.progress = pickProgress(local: mine.progress, remote: theirs.progress, base: last?.progress)
                kept = entry
            case let (mine?, nil):
                if remoteDeleted.contains(uuid), let last = last, mine.hasSameContent(as: last) {
                    // Deleted on another device, not edited here since.
                    kept = nil
                } else {
                    // New here, edited here after a deletion elsewhere, back with "Vazgeç", or sync
                    // was just turned on: it stays.
                    kept = mine
                }
            case let (nil, theirs?):
                if let last = last {
                    // Deleted here since the last sync: deleted everywhere, unless another device
                    // edited it since (the edit wins over the deletion).
                    kept = theirs.hasSameContent(as: last) ? nil : returning(theirs, base: last)
                } else {
                    kept = returning(theirs, base: nil)
                }
            case (nil, nil):
                // Deleted (here since the last sync, or earlier anywhere).
                kept = nil
            }
            if let entry = kept {
                deleted.remove(uuid)
                mergedEntries.append(entry)
            } else {
                deleted.insert(uuid)
            }
        }

        let merged = SyncSnapshot(resetAt: mergedReset, cards: mergedCards, words: mergedEntries, deleted: Array(deleted))

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
        for record in merged.cards {
            newProgress[record.wordID] = record
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
        return Result(
            progress: newProgress == progress ? nil : newProgress,
            words: newList == words ? nil : newList,
            upload: upload,
            merged: merged,
            state: SyncState(joined: true, resetAt: mergedReset, uuids: uuids, base: merged),
            stateIfUploadFails: SyncState(joined: true, resetAt: mergedReset, uuids: uuids, base: joined ? state.base : nil)
        )
    }

    // MARK: Rules

    /// The progress record both sides keep (rules 1–3 in the type comment); nil when neither has one.
    public static func pickProgress(local: WordProgress?, remote: WordProgress?, base: WordProgress?) -> WordProgress? {
        guard let local = local else {
            return remote
        }
        guard let remote = remote else {
            return local
        }
        if local == remote {
            return local
        }
        if let base = base {
            if remote == base {
                return local
            }
            if local == base {
                // Only iCloud changed it, unless iCloud's copy is older than this one (two
                // devices wrote at once and the older copy won in iCloud).
                return order(local, remote) == .orderedDescending ? local : remote
            }
        }
        switch order(local, remote) {
        case .orderedDescending:
            return local
        case .orderedAscending:
            return remote
        case .orderedSame:
            return sameOnEveryDevice(local, remote)
        }
    }

    /// The later of two records: last answer, then last view or "Biliyorum", then more answers,
    /// then more views. A missing date is the earliest.
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

    /// The text both sides keep, by the same rules with `updatedAt` as the date.
    static func pickContent(local: SyncWord, remote: SyncWord, base: SyncWord?) -> SyncWord {
        if local.hasSameContent(as: remote) {
            return local
        }
        if let base = base {
            if remote.hasSameContent(as: base) {
                return local
            }
            if local.hasSameContent(as: base) {
                return local.updatedAt > remote.updatedAt ? local : remote
            }
        }
        if local.updatedAt != remote.updatedAt {
            return local.updatedAt > remote.updatedAt ? local : remote
        }
        let left = [local.lemma, local.meaningTR, local.exampleEN ?? "", local.note ?? "", "\(local.createdAt.timeIntervalSince1970)"]
        let right = [remote.lemma, remote.meaningTR, remote.exampleEN ?? "", remote.note ?? "", "\(remote.createdAt.timeIntervalSince1970)"]
        return right.lexicographicallyPrecedes(left) ? local : remote
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
        let values = SyncCoding.canonical(keys.map { progress[$0]! })
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
