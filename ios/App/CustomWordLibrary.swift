import Combine
import Foundation
import os
import CoreModels
import Learning

/// The user's own words ("Kendi kelimeni ekle") for the screens: the list in memory, saved to
/// custom_words.json (`CustomWordStore`) after every change. It does not know `AppModel`: the
/// owner reads `widgetWords` after `load` and is told about every saved change through
/// `onChange`, to rebuild the deck and rewrite the widget plan
/// (docs/ozellik_planlari/kendi_kelime.md).
///
/// Uses Foundation, Combine and os only, so it can join the Linux compile check of the app's
/// logic (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).
@MainActor
final class CustomWordLibrary: ObservableObject {
    enum Status: Equatable {
        case notLoaded
        case ready
        /// The file exists but could not be read (for example while the device is locked), or
        /// Application Support is unavailable. Nothing is shown or saved; `load` tries again.
        case unavailable
    }

    enum SaveError: Error, Equatable {
        /// Not loaded, or the file could not be read: saving now could overwrite the user's words.
        case unavailable
        /// The change was valid but the file could not be written; nothing changed.
        case notSaved(String)
    }

    /// Oldest first, as stored and as they enter the deck. The list screen shows `newestFirst`.
    @Published private(set) var words: [CustomWord] = []
    @Published private(set) var status: Status = .notLoaded
    /// Set when the file was damaged at load and the backup was used or the list started over;
    /// the list screen shows it until the user dismisses it.
    @Published private(set) var recovery: CustomWordStore.LoadOutcome?

    /// Called after every saved change (add, edit, delete, restore) with the new list.
    var onChange: (([CustomWord]) -> Void)?

    private let store: CustomWordStore?
    private var list = CustomWordList()
    /// Ids reserved before the file was loaded (`reserveIDs`).
    private var reservedIDs: [Int] = []
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "CustomWords"
    )

    /// `store` nil: the file has no location (the library stays `unavailable`).
    init(store: CustomWordStore?) {
        self.store = store
    }

    /// Application Support/custom_words.json.
    convenience init() {
        self.init(store: (try? CustomWordStore.defaultURL()).map { CustomWordStore(fileURL: $0) })
    }

    // MARK: Reading

    var newestFirst: [CustomWord] {
        return words.reversed()
    }

    /// Every word as the widget, "Akış" and "Tekrar" show it, oldest first.
    var widgetWords: [WidgetWord] {
        return list.widgetWords
    }

    func word(id: Int) -> CustomWord? {
        return list.word(id: id)
    }

    /// The draft's problems against the current list (`editing`: the word being edited).
    func problems(for draft: CustomWordDraft, editing id: Int? = nil) -> [CustomWordProblem] {
        return list.problems(for: draft, editing: id)
    }

    // MARK: Loading

    /// Reads the file once; does nothing when already loaded. Returns true when the words became
    /// available just now (the owner then rebuilds the deck if it was built without them).
    @discardableResult
    func load(now: Date = Date()) -> Bool {
        if status == .ready {
            return false
        }
        guard let store = store else {
            logger.error("custom words file location unavailable")
            status = .unavailable
            return false
        }
        do {
            let result = try store.load(now: now)
            var loaded = result.list
            loaded.reserveIDs(reservedIDs)
            list = loaded
            words = loaded.words
            status = .ready
            switch result.outcome {
            case .fresh, .loaded:
                break
            case let .restoredFromBackup(setAside, backupDate):
                logger.error("custom words file damaged (moved to \(setAside?.lastPathComponent ?? "-", privacy: .public)); restored the backup from \(backupDate?.description ?? "?", privacy: .public)")
                recovery = result.outcome
            case let .startedOver(setAside):
                logger.error("custom words file damaged (moved to \(setAside.lastPathComponent, privacy: .public)); no backup, the list starts empty")
                recovery = result.outcome
            }
            return true
        } catch {
            // Nothing is saved over the file; the next `load` tries again.
            logger.error("custom words file unreadable, will retry: \(String(describing: error), privacy: .public)")
            status = .unavailable
            return false
        }
    }

    /// Keeps new words off ids that already have progress (pass the ids in progress.json). A
    /// damaged file replaced by an older backup loses the words added since, not their
    /// progress; a new word must not take over such an id. Works before and after `load`.
    func reserveIDs<S: Sequence>(_ ids: S) where S.Element == Int {
        let custom = ids.filter { CustomWordID.contains($0) }
        reservedIDs.append(contentsOf: custom)
        list.reserveIDs(custom)
    }

    func dismissRecovery() {
        recovery = nil
    }

    // MARK: Changes

    /// Throws `CustomWordList.ChangeError.invalid` for a draft with problems, `SaveError`
    /// when the file cannot be written. Nothing changes when it throws.
    @discardableResult
    func add(_ draft: CustomWordDraft, now: Date = Date()) throws -> CustomWord {
        return try commit { list in
            try list.add(draft, now: now)
        }
    }

    /// Same id, so the word keeps its progress.
    @discardableResult
    func update(id: Int, with draft: CustomWordDraft, now: Date = Date()) throws -> CustomWord {
        return try commit { list in
            try list.update(id: id, with: draft, now: now)
        }
    }

    /// The removed word (for "Vazgeç"), or nil when there was none. Its progress stays in
    /// progress.json: the id is never given to another word, and `restore` finds it again.
    @discardableResult
    func remove(id: Int) throws -> CustomWord? {
        guard list.word(id: id) != nil else {
            return nil
        }
        return try commit { list in
            list.remove(id: id)
        }
    }

    /// "Vazgeç" after a delete: the word comes back with its id and place.
    func restore(_ word: CustomWord) throws {
        try commit { list in
            try list.restore(word)
        }
    }

    // MARK: iCloud (is5-icloud, AppModel+Sync.swift)

    /// The list with its next id, for the iCloud merge (`SyncMerge`).
    var currentList: CustomWordList {
        return list
    }

    /// The iCloud merge's list replaces this one: saved first, then shown and passed to
    /// `onChange`, like any change. Throws `SaveError` like `add`.
    func replaceAll(with merged: CustomWordList) throws {
        try commit { list in
            list = merged
        }
    }

    /// Applies `change` to a copy, saves the copy, and only then adopts it.
    private func commit<T>(_ change: (inout CustomWordList) throws -> T) throws -> T {
        guard status == .ready, let store = store else {
            throw SaveError.unavailable
        }
        var updated = list
        let result = try change(&updated)
        do {
            try store.save(updated)
        } catch {
            logger.error("could not save custom words: \(error.localizedDescription, privacy: .public)")
            throw SaveError.notSaved(error.localizedDescription)
        }
        list = updated
        words = updated.words
        onChange?(updated.words)
        return result
    }
}
