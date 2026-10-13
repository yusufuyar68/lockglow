import Combine
import Foundation
import os
import WidgetKit
import CoreModels
import SharedState
import Scheduler
import Learning
import ContentStore

@MainActor
final class AppModel: ObservableObject {
    static let feedLimit = 5000
    static let queueLimit = 96
    /// The widget queue covers this far ahead: reviews that fall due within it are queued now.
    static let queueHorizon: TimeInterval = 48 * 3600
    /// Cards per "Tekrar" round; more due cards wait for the next round.
    static let reviewSessionLimit = 20

    @Published private(set) var words: [WidgetWord] = []
    @Published private(set) var contentSource: ContentSource = .loading
    @Published private(set) var cardCount = 0
    @Published private(set) var contentVersion: String?
    @Published private(set) var health = WidgetHealthSnapshot()
    /// Learning progress by word id. Single writer: this model (widget events, reviews, reset).
    @Published private(set) var progress: [Int: WordProgress] = [:]
    /// Minutes between word changes on the widget (global; written into every plan).
    @Published private(set) var rotationMinutes = AppPreferences.rotationMinutes
    /// Daily goal of new words; the widget queue holds twice as many (48 h horizon).
    @Published private(set) var dailyNewWords = AppPreferences.dailyNewWords

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "AppModel"
    )
    private var store: AppGroupStore?
    /// Nil until the progress file has been loaded (or when its folder is unavailable).
    private var progressStore: ProgressStore?
    private var hasStarted = false
    private var lastReloadRequestedAt: Date?
    /// Opened on first use for card details; stays nil when only seed words are available.
    private lazy var detailStore: ContentStore? = ContentLoader.openStore()
    /// Not published: filling it while a view is being drawn must not trigger a redraw.
    private var detailCache: [Int: CardDetail] = [:]

    // MARK: Lifecycle

    /// Launch: load progress and content, write the first widget plan, refresh the health screen.
    func start() async {
        if hasStarted {
            return
        }
        hasStarted = true

        let container = AppGroupLocator.containerURL()
        store = container.map { AppGroupStore(containerURL: $0) }
        if store == nil {
            logger.error("App Group container unavailable: check APP_GROUP_ID and the entitlements")
        }

        // Progress is loaded before the first suspension point: a scene-phase callback that
        // arrives while the content loads must never ingest events into an empty dictionary.
        loadProgress()

        let limit = AppModel.feedLimit
        let loaded = await Task.detached(priority: .userInitiated) {
            ContentLoader.load(feedLimit: limit)
        }.value

        words = loaded.words
        contentSource = loaded.source
        cardCount = loaded.cardCount
        contentVersion = loaded.contentVersion

        refreshWidgetPlan()
        await refreshHealth()
    }

    /// Called when the scene goes to the background: one last plan write and reload.
    func sceneDidEnterBackground() {
        if !hasStarted {
            return
        }
        refreshWidgetPlan()
        Task {
            await self.refreshHealth()
        }
    }

    /// Called when the scene becomes active again: taps made on the widget while the app was
    /// away reach the progress now (no plan rewrite; that happens when the app goes to the background).
    func sceneDidBecomeActive() {
        if !hasStarted {
            return
        }
        ingestWidgetEvents()
    }

    // MARK: Settings

    func setRotationMinutes(_ minutes: Int) {
        guard AppPreferences.rotationMinuteChoices.contains(minutes), minutes != rotationMinutes else {
            return
        }
        rotationMinutes = minutes
        AppPreferences.rotationMinutes = minutes
        refreshWidgetPlan()
    }

    func setDailyNewWords(_ count: Int) {
        guard AppPreferences.dailyNewWordChoices.contains(count), count != dailyNewWords else {
            return
        }
        dailyNewWords = count
        AppPreferences.dailyNewWords = count
        refreshWidgetPlan()
    }

    // MARK: Card details

    /// Every example with its Turkish translation and the Turkish learner notes of a card, read
    /// once from content.sqlite (one row by id) and cached. Nil for seed words or an unreadable card.
    func detail(for word: WidgetWord) -> CardDetail? {
        if let cached = detailCache[word.id] {
            return cached
        }
        guard contentSource == .database, let store = detailStore else {
            return nil
        }
        do {
            guard let detail = try store.cardDetail(id: word.id) else {
                return nil
            }
            detailCache[word.id] = detail
            return detail
        } catch {
            logger.error("card \(word.id) detail unreadable: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    // MARK: Learning

    /// Known / learning / due-today counts for "Ayarlar" ("today" = until the end of the local day).
    func progressCounts(now: Date = Date()) -> ProgressCounts {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now
        return ReviewPlanner.counts(feed: words, progress: progress, dueBy: endOfToday)
    }

    /// The next flashcard round: due words first (at most `reviewSessionLimit`); when nothing is
    /// due, the first new words in feed order, up to what is left of today's goal. `extraNew`
    /// skips the due check and the daily limit ("N more new words" after the goal is reached).
    /// Nil when there is nothing to offer.
    func nextReviewSession(extraNew: Bool = false, now: Date = Date()) -> ReviewSession? {
        if !extraNew {
            let due = ReviewPlanner.dueWords(feed: words, progress: progress, now: now, limit: Int.max)
            if !due.isEmpty {
                return ReviewSession(
                    kind: .due,
                    words: Array(due.prefix(AppModel.reviewSessionLimit)),
                    totalCount: due.count
                )
            }
        }
        let allowance = extraNew
            ? dailyNewWords
            : max(0, dailyNewWords - AppPreferences.newWordsStudiedToday(now: now))
        let fresh = ReviewPlanner.newWords(feed: words, progress: progress, limit: allowance)
        if fresh.isEmpty {
            return nil
        }
        return ReviewSession(kind: .new, words: fresh, totalCount: fresh.count)
    }

    /// Records one flashcard answer and saves the progress right away.
    func recordReview(_ word: WidgetWord, grade: ReviewGrade) {
        let now = Date()
        let current = progress[word.id] ?? WordProgress(wordID: word.id)
        let wasNew = current.state == .new
        progress[word.id] = Leitner.review(current, grade: grade, at: now)
        persistProgress(progress)
        if wasNew {
            AppPreferences.addNewWordsStudied(1, now: now)
        }
    }

    /// A flashcard round ended (or was ended early): the queue changes with the new progress.
    func finishReviewSession() {
        refreshWidgetPlan()
    }

    /// "İlerlemeyi sıfırla": forgets all progress. Unprocessed widget events are discarded first,
    /// otherwise they would be applied right after the reset. The visible widget word stays.
    func resetProgress() {
        discardPendingEvents()
        progress = [:]
        persistProgress(progress)
        AppPreferences.clearKnownWordIDs()
        AppPreferences.resetNewWordsStudied()
        refreshWidgetPlan()
    }

    private func loadProgress() {
        let url: URL
        do {
            url = try ProgressStore.defaultURL()
        } catch {
            logger.error("progress file location unavailable: \(error.localizedDescription, privacy: .public)")
            return
        }
        let fileStore = ProgressStore(fileURL: url)
        var loaded = fileStore.load()

        // One-time migration: ids the old build kept in UserDefaults become known words. A word
        // that already has progress is newer than that list and is left alone.
        let legacy = AppPreferences.knownWordIDs
        if !legacy.isEmpty {
            let now = Date()
            for id in legacy.sorted() where loaded[id] == nil {
                loaded[id] = Leitner.markKnown(WordProgress(wordID: id), at: now)
            }
            do {
                try fileStore.save(loaded)
                AppPreferences.clearKnownWordIDs()
            } catch {
                // The legacy ids stay in UserDefaults; the migration runs again next launch.
                logger.error("could not save migrated progress: \(error.localizedDescription, privacy: .public)")
            }
        }

        progress = loaded
        progressStore = fileStore
    }

    /// Writes the given progress to disk. The caller decides whether to adopt it in memory.
    @discardableResult
    private func persistProgress(_ snapshot: [Int: WordProgress]) -> Bool {
        guard let progressStore = progressStore else {
            logger.error("progress store unavailable; progress not saved")
            return false
        }
        do {
            try progressStore.save(snapshot)
            return true
        } catch {
            logger.error("could not save progress: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    // MARK: Widget events

    /// Reads the widget's event files, applies them to the progress (oldest first), saves, and only
    /// then deletes the files. If the save fails the files stay and are applied again next time.
    /// Files that cannot be decoded are removed; unreadable ones are left alone.
    func ingestWidgetEvents() {
        guard let store = store, progressStore != nil else {
            return
        }
        let mailbox = store.eventMailbox
        let stored: [StoredEvent]
        do {
            stored = try mailbox.list()
        } catch {
            logger.error("could not read the event mailbox: \(error.localizedDescription, privacy: .public)")
            return
        }

        if !stored.isEmpty {
            var events: [LearningEvent] = []
            for item in stored {
                let event = item.event
                logger.info("widget event \(event.type.rawValue, privacy: .public) word=\(event.wordID) source=\(event.source.rawValue, privacy: .public)")
                events.append(LearningEvent(type: event.type, wordID: event.wordID, at: event.at))
            }
            let updated = ProgressIngest.apply(events, to: progress)
            if !persistProgress(updated) {
                return
            }
            progress = updated
        }

        for item in stored {
            do {
                try mailbox.delete(item)
            } catch {
                logger.error("could not delete event file: \(error.localizedDescription, privacy: .public)")
            }
        }
        mailbox.deleteUndecodableFiles()
    }

    /// Deletes every pending event file without applying it (used by the progress reset).
    private func discardPendingEvents() {
        guard let store = store else {
            return
        }
        let mailbox = store.eventMailbox
        do {
            for item in try mailbox.list() {
                try? mailbox.delete(item)
            }
        } catch {
            logger.error("could not read the event mailbox: \(error.localizedDescription, privacy: .public)")
        }
        mailbox.deleteUndecodableFiles()
    }

    // MARK: Widget plan

    /// Ingests widget events into the progress, then writes a new `widget_plan.json` (fresh
    /// plan_id) composed by `QueueComposer`, and asks WidgetKit to reload.
    ///
    /// The new queue STARTS AT the word the old plan shows right now, so the visible word does
    /// not change and the rotation carries on from it. "Right now" is computed by the same pure
    /// function the widget uses, from the old plan and the widget's state.
    func refreshWidgetPlan() {
        guard let store = store else {
            return
        }

        ingestWidgetEvents()

        // Content not loaded yet (a background event during launch): QueueComposer would still
        // pin the visible word and write a one-word plan over a good one.
        if words.isEmpty {
            logger.notice("content not loaded yet; widget plan left unchanged")
            return
        }

        // Whole seconds: this date is stored as the plan's updated_at, which becomes the new
        // rotation anchor, and it is also the instant the current word is evaluated at.
        let rewriteTime = TimelinePlanner.roundedDownToWholeSecond(Date())
        let rotation = RotationInput.resolve(plan: store.readPlan(), state: store.readState(), seedWords: [])
        let currentWord = TimelinePlanner.wordAt(
            rewriteTime,
            queue: rotation.queue,
            knownIDs: rotation.knownIDs,
            cursorOffset: rotation.cursorOffset,
            cursorAnchor: rotation.cursorAnchor,
            interval: rotation.interval,
            alignmentOffset: TimelinePlanner.localAlignmentOffset(for: rewriteTime)
        )

        let queue = QueueComposer.compose(
            feed: words,
            progress: progress,
            now: rewriteTime,
            horizon: AppModel.queueHorizon,
            maxNew: dailyNewWords * 2,
            limit: AppModel.queueLimit,
            pinFirst: currentWord
        )
        if queue.isEmpty {
            logger.notice("no words for a plan; the widget keeps its current data or the bundled seed")
            return
        }

        // The interval is global (all widget instances). The app owns it; changing it keeps the
        // visible word, because `currentWord` above was computed with the OLD plan's interval.
        let plan = WidgetPlan(
            planID: UUID().uuidString,
            isPremium: false,
            intervalSeconds: rotationMinutes * 60,
            queue: queue,
            updatedAt: rewriteTime
        )
        do {
            try store.writePlan(plan)
        } catch {
            logger.error("could not write the widget plan: \(error.localizedDescription, privacy: .public)")
            return
        }
        reloadWidgets()
    }

    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        lastReloadRequestedAt = Date()
    }

    // MARK: Health

    func refreshHealth() async {
        let instances = await WidgetProbe.currentInstances()

        var snapshot = WidgetHealthSnapshot()
        snapshot.instances = instances
        snapshot.lastReloadRequestedAt = lastReloadRequestedAt
        if let store = store {
            snapshot.appGroupAvailable = true
            let plan = store.readPlan()
            snapshot.planID = plan?.planID
            snapshot.planUpdatedAt = plan?.updatedAt
            snapshot.queueSize = plan?.queue.count ?? 0
            let state = store.readState()
            snapshot.cursorOffset = state?.cursorOffset
            snapshot.knownCount = state?.knownIDs.count
            snapshot.pendingEventCount = (try? store.eventMailbox.list().count) ?? 0
        }
        health = snapshot
    }
}
