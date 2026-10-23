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
    /// Due words per "Tekrar" round, at most 10 questions (ogrenme_ilkeleri 1b); more wait for
    /// "Bir tur daha" or the next days.
    static let reviewSessionLimit = 10
    /// New words per "Tanış + Hatırla" round; a larger daily goal comes in more rounds ("Bir tur
    /// daha"): short parts at one's own pace teach better than one long one.
    static let introRoundLimit = 5
    /// A topic needs this many cards to be offered on its own (`choosableTopics`).
    static let minimumTopicCards = 5

    /// Every loaded word: the dictionary, the progress counts, known words and due reviews.
    @Published private(set) var words: [WidgetWord] = []
    /// The user's deck (`DeckFilter.feed` of `words`): "Akış", the widget queue and the new words
    /// of "Tekrar". Same words as `words` when no topic is chosen; never empty unless `words` is.
    @Published private(set) var feedWords: [WidgetWord] = []
    /// Topics the user can choose (from content.sqlite; empty with seed words only).
    @Published private(set) var topics: [ContentTopic] = []
    /// Chosen topics and start level ("Ayarlar" and the onboarding).
    @Published private(set) var deckChoice = DeckChoice(
        topicIDs: AppPreferences.selectedTopicIDs,
        startLevel: AppPreferences.startLevel
    )
    /// The onboarding is on screen: on a fresh install until finished or skipped, and when opened
    /// again from "Ayarlar". Never by itself after an update (`shouldShowOnboardingAtLaunch`).
    @Published private(set) var showsOnboarding = AppModel.shouldShowOnboardingAtLaunch()
    @Published private(set) var contentSource: ContentSource = .loading
    @Published private(set) var cardCount = 0
    @Published private(set) var contentVersion: String?
    @Published private(set) var health = WidgetHealthSnapshot()
    /// The word every Lock Screen widget shows as of the last check (same pure rotation as the
    /// widget). Nil without a plan.
    @Published private(set) var lockScreenWordID: Int?
    /// Learning progress by word id. Single writer: this model (widget events, reviews, reset).
    @Published private(set) var progress: [Int: WordProgress] = [:]
    /// The last "Biliyorum" tapped in the app while "Geri al" can still take it back exactly; nil
    /// after the undo window (`markKnown`), an undo or another "Biliyorum".
    @Published private(set) var knownUndo: KnownUndo?
    /// Minutes between word changes on the widget (global; written into every plan).
    @Published private(set) var rotationMinutes = AppPreferences.rotationMinutes
    /// Daily goal of new words; the widget queue holds twice as many (48 h horizon).
    @Published private(set) var dailyNewWords = AppPreferences.dailyNewWords
    @Published private(set) var reminderEnabled = AppPreferences.reminderEnabled
    /// Minutes after local midnight.
    @Published private(set) var reminderMinuteOfDay = AppPreferences.reminderMinuteOfDay
    /// Set when the progress file was damaged at launch and the backup was used or progress
    /// started over; "Ayarlar" shows it until the user dismisses it.
    @Published private(set) var progressRecovery: ProgressStore.LoadOutcome?

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "AppModel"
    )
    private var store: AppGroupStore?
    /// Nil until the progress file has been loaded (or when its folder is unavailable).
    private var progressStore: ProgressStore?
    /// Every answer, for FSRS later (`ReviewLog`). Best effort: a failed write loses that line only.
    private let reviewLog = (try? ReviewLog.defaultURL()).map { ReviewLog(fileURL: $0) }
    private var hasStarted = false
    private var lastReloadRequestedAt: Date?
    /// Every topic of each word (`card_category`), for the deck filter and "İlerleme".
    private(set) var topicsOf: [Int: Set<String>] = [:]
    /// Every word in the chosen level order: the widget's fallback and where new words come from
    /// once the chosen topics have none left.
    private(set) var allTopicsFeed: [WidgetWord] = []
    /// Opened on first use for card details; stays nil when only seed words are available.
    private lazy var detailStore: ContentStore? = ContentLoader.openStore()
    /// Not published: filling it while a view is being drawn must not trigger a redraw.
    private var detailCache: [Int: CardDetail] = [:]
    /// Loaded words by lowercased headword (`lookup(lemma:)`); the first card of a headword wins.
    private var wordsByLemma: [String: WidgetWord] = [:]
    /// The user's own words ("Kendi kelimelerin"), in front of every deck (AppModel+CustomWords.swift).
    let customWordLibrary = CustomWordLibrary()
    /// The loaded cards (content.sqlite or the seed) without the user's words; `words` is both.
    private var contentWords: [WidgetWord] = []

    // MARK: Lifecycle

    /// Launch: load progress and content, write the first widget plan, refresh the health screen.
    func start() async {
        if hasStarted {
            return
        }
        hasStarted = true
        // Today's time of "Saati benim için seç" before any screen shows it (AppModel+ReminderTiming.swift).
        reminderTimeDecision()

        let container = AppGroupLocator.containerURL()
        store = container.map { AppGroupStore(containerURL: $0) }
        if store == nil {
            logger.error("App Group container unavailable: check APP_GROUP_ID and the entitlements")
        }

        // Progress is loaded before the first suspension point: a scene-phase callback that
        // arrives while the content loads must never ingest events into an empty dictionary.
        loadProgress()
        // The user's words too: the first deck and the first plan include them.
        customWordLibrary.onChange = { [weak self] _ in
            self?.customWordsDidChange()
        }
        customWordLibrary.load()
        customWordLibrary.reserveIDs(progress.keys)

        let limit = AppModel.feedLimit
        let loaded = await Task.detached(priority: .userInitiated) {
            ContentLoader.load(feedLimit: limit)
        }.value

        contentWords = loaded.words
        words = withCustomWords(loaded.words)
        // Cards only: the form's "kartlarda zaten var" must not find the user's own word.
        wordsByLemma = AppModel.lemmaIndex(loaded.words)
        topics = loaded.topics
        topicsOf = loaded.topicsOf
        rebuildFeed()
        contentSource = loaded.source
        cardCount = loaded.cardCount
        contentVersion = loaded.contentVersion

        // First launch: no plan yet, and the onboarding is about to choose the deck. Its choice
        // writes the first plan, so the widget starts with the chosen words instead of keeping
        // a default word on screen until the next boundary. Leaving the app before that writes
        // a plan anyway (`sceneDidEnterBackground`).
        if !showsOnboarding || store?.readPlan() != nil {
            refreshWidgetPlan()
        }
        await refreshHealth()
    }

    /// Called when the scene goes to the background: one last plan write and reload.
    func sceneDidEnterBackground() {
        LocalMetricsRecorder.shared.appDidEnterBackground()
        if !hasStarted {
            return
        }
        LocalMetricsRecorder.shared.recordBoxes(progress)
        refreshWidgetPlan()
        Task {
            await self.refreshHealth()
        }
    }

    /// Called when the scene becomes active again: taps made on the widget while the app was
    /// away reach the progress now (no plan rewrite; that happens when the app goes to the background).
    func sceneDidBecomeActive() {
        // Counted from the first launch on, before the content is ready.
        LocalMetricsRecorder.shared.appDidBecomeActive()
        // A new day: today's time of "Saati benim için seç" (AppModel+ReminderTiming.swift).
        reminderTimeDecision()
        if !hasStarted {
            return
        }
        if progressStore == nil {
            // The file could not be read at launch (for example a locked device): try again.
            loadProgress()
            customWordLibrary.reserveIDs(progress.keys)
        }
        // The same for the user's words: once readable, the deck and the queue get them.
        if customWordLibrary.load() {
            customWordLibrary.reserveIDs(progress.keys)
            customWordsDidChange()
        }
        ingestWidgetEvents()
        // Time and widget taps ("Sonraki", "Biliyorum") may have moved the rotation on.
        updateLockScreenWord()
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

    // MARK: Deck

    /// Topics and start level of the feed. Like every setting, the plan is rewritten at once
    /// and the word on the widget stays until the next boundary; the chosen words follow.
    func setDeckChoice(_ choice: DeckChoice) {
        guard choice != deckChoice else {
            return
        }
        deckChoice = choice
        AppPreferences.selectedTopicIDs = choice.topicIDs
        AppPreferences.startLevel = choice.startLevel
        // A goal the user never chose follows the level (`SettingsRules`): A1–A2 5, B1 10.
        dailyNewWords = AppPreferences.dailyNewWords
        rebuildFeed()
        refreshWidgetPlan()
    }

    func setSelectedTopics(_ topicIDs: Set<String>) {
        var choice = deckChoice
        choice.topicIDs = topicIDs
        setDeckChoice(choice)
    }

    func setStartLevel(_ level: Level?) {
        var choice = deckChoice
        choice.startLevel = level
        setDeckChoice(choice)
    }

    /// The chosen topics that still exist in the content (a content update may drop one).
    var activeTopicIDs: Set<String> {
        return deckChoice.topicIDs.intersection(topics.map { $0.id })
    }

    /// Topics offered for choosing. One with only a handful of cards would make the widget
    /// repeat the same few words; its cards still come with "Tümü".
    var choosableTopics: [ContentTopic] {
        return topics.filter { $0.cardCount >= AppModel.minimumTopicCards }
    }

    /// New words for "Tekrar" and the reminder: the deck's while it has any, then every topic's.
    private var newWordFeed: [WidgetWord] {
        return DeckFilter.newWordFeed(deck: feedWords, fallback: allTopicsFeed, progress: progress)
    }

    /// Every new word of the chosen topics was studied: new words now come from every topic
    /// ("Ayarlar" says so). False when no topic is chosen.
    var newWordsComeFromAllTopics: Bool {
        return feedWords.count < allTopicsFeed.count && !DeckFilter.hasNewWords(feedWords, progress: progress)
    }

    /// Words and new words of a topic choice (the summary line). Topics no longer in the
    /// content are dropped first, as in the feed.
    func deckSummary(for topicIDs: Set<String>) -> DeckSummary {
        let live = topicIDs.intersection(topics.map { $0.id })
        return DeckFilter.summary(contentWords, topicsOf: topicsOf, topicIDs: live, progress: progress)
    }

    /// A loaded word by id (a widget tap on a word outside the deck).
    func word(id: Int) -> WidgetWord? {
        return words.first { $0.id == id }
    }

    private func rebuildFeed() {
        feedWords = withCustomWords(DeckFilter.feed(contentWords, topicsOf: topicsOf, choice: deckChoice))
        allTopicsFeed = withCustomWords(DeckFilter.ordered(contentWords, startingAt: deckChoice.startLevel))
    }

    /// "Kendi kelimelerin" saved a change: the deck, the counts and the widget queue follow at
    /// once. Before the content has loaded nothing is built yet; `start` adds the words then.
    private func customWordsDidChange() {
        guard contentSource != .loading else {
            return
        }
        words = withCustomWords(contentWords)
        rebuildFeed()
        refreshWidgetPlan()
    }

    // MARK: Onboarding

    /// Whether the onboarding opens by itself (`OnboardingGate`). An update from a build before
    /// the onboarding (a widget plan or progress on disk, no flag) gets the flag written as done;
    /// a fresh install gets it written as not done, so the plan written when the app is left half
    /// way through does not count as an earlier install on the next launch.
    nonisolated static func shouldShowOnboardingAtLaunch() -> Bool {
        let stored = AppPreferences.onboardingCompletedStored
        if let completed = stored {
            return !completed
        }
        let hasWidgetPlan = AppGroupLocator.containerURL()
            .map { AppGroupStore(containerURL: $0).readPlan() != nil } ?? false
        let progressFile = try? ProgressStore.defaultURL()
        let hasProgress = progressFile.map { FileManager.default.fileExists(atPath: $0.path) } ?? false
        let shows = OnboardingGate.shouldShow(
            storedCompleted: stored,
            hasWidgetPlan: hasWidgetPlan,
            hasProgress: hasProgress || !AppPreferences.knownWordIDs.isEmpty
        )
        AppPreferences.onboardingCompleted = !shows
        return shows
    }

    func showOnboarding() {
        showsOnboarding = true
    }

    /// Finished or skipped: it does not open by itself again. The plan is written now (the
    /// first one on a fresh install, see `start`).
    func finishOnboarding() {
        AppPreferences.onboardingCompleted = true
        showsOnboarding = false
        refreshWidgetPlan()
    }

    /// The first card the user will study: the first new word of the deck (what "Tekrar" offers
    /// first), or the deck's first word when every word was already studied.
    func firstDeckWord() -> WidgetWord? {
        return ReviewPlanner.newWords(feed: feedWords, progress: progress, limit: 1).first ?? feedWords.first
    }

    // MARK: Reminder

    /// Only the setting; the caller schedules the notifications (`ReminderScheduler`).
    func setReminderEnabled(_ enabled: Bool) {
        reminderEnabled = enabled
        AppPreferences.reminderEnabled = enabled
    }

    /// A time the user picks. It ends "Saati benim için seç" (AppModel+ReminderTiming.swift).
    func setReminderMinuteOfDay(_ minute: Int) {
        guard (0..<1440).contains(minute) else {
            return
        }
        endReminderAutoTime()
        applyReminderMinute(minute)
    }

    /// Saves the time; also how "Saati benim için seç" sets today's time.
    func applyReminderMinute(_ minute: Int) {
        guard (0..<1440).contains(minute) else {
            return
        }
        reminderMinuteOfDay = minute
        AppPreferences.reminderMinuteOfDay = minute
    }

    /// The next week's reminders from the current progress; empty when reminders are off or
    /// the content has not loaded yet.
    func reminderPlan(now: Date = Date()) -> [Reminder] {
        guard reminderEnabled, !words.isEmpty else {
            return []
        }
        // "Saati benim için seç" moves the next days' time (AppModel+ReminderTiming.swift).
        let times = reminderTimes(now: now)
        return ReminderPlanner.plan(
            feed: words,
            newWordFeed: newWordFeed,
            progress: progress,
            now: now,
            minuteOfDay: times.today,
            laterMinuteOfDay: times.later,
            days: 7,
            dailyNewGoal: dailyNewWords,
            newStudiedToday: AppPreferences.newWordsStudiedToday(now: now),
            calendar: .current,
            recent: ReminderLog.recentlySent(now: now),
            detail: { self.detail(for: $0) },
            confusables: confusables,
            all: words
        )
    }

    // MARK: Card details

    /// Every example with its Turkish translation and the Turkish learner notes of a card, read
    /// once from content.sqlite (one row by id) and cached. Nil for seed words or an unreadable card.
    func detail(for word: WidgetWord) -> CardDetail? {
        // A user's word: its own example and note, no quiz (`CustomWord.cardDetail`).
        if word.isUserAdded {
            return customWordLibrary.word(id: word.id)?.cardDetail
        }
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

    /// The Turkish meaning of the loaded card whose headword is `lemma` ("lend" → "ödünç vermek"),
    /// for the quiz's "Senin seçtiğin" line. Case and surrounding spaces are ignored; nil when no
    /// card has that headword (a distractor such as "owe" or "lent") or the card has no gloss.
    func lookup(lemma: String) -> String? {
        let key = lemma.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return wordsByLemma[key]?.glossTR
    }

    private static func lemmaIndex(_ words: [WidgetWord]) -> [String: WidgetWord] {
        var index: [String: WidgetWord] = [:]
        for word in words {
            let key = word.lemma.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if index[key] == nil {
                index[key] = word
            }
        }
        return index
    }

    /// Words whose headword or Turkish gloss starts with the typed text (Turkish letters and
    /// accents folded, so "kahv" finds "kahvaltı"). Uses the database's full-text index; without a
    /// database (seed words only) a plain prefix match over the loaded words.
    func search(_ query: String, limit: Int = 50) -> [WidgetWord] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return []
        }
        if contentSource == .database, let store = detailStore {
            do {
                let cards = try store.search(trimmed, limit: limit)
                // The index has only the cards; the user's words come first.
                return Array((customWordMatches(trimmed, limit: limit) + cards).prefix(limit))
            } catch {
                logger.error("search failed: \(error.localizedDescription, privacy: .public)")
                return []
            }
        }
        let needle = trimmed.lowercased()
        return Array(words.filter { word in
            word.lemma.lowercased().hasPrefix(needle) || (word.glossTR?.lowercased().hasPrefix(needle) ?? false)
        }.prefix(limit))
    }

    // MARK: Learning

    /// Known / learning / due-today counts for "Ayarlar" ("today" = until the end of the local day).
    func progressCounts(now: Date = Date()) -> ProgressCounts {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now
        return ReviewPlanner.counts(feed: words, progress: progress, dueBy: endOfToday)
    }

    /// The next "Tekrar" round: due words first (at most `reviewSessionLimit`, from every word
    /// whatever the deck); when nothing is due, a "Tanış + Hatırla" round of at most
    /// `introRoundLimit` new words, up to what is left of today's goal: first the words a failed
    /// "Biliyorum" check sent back, then the deck's new words (of every topic once the deck has
    /// none left). A new round's `totalCount` is what is left of today's goal. `extraNew` skips
    /// the due check and the daily limit ("N more new words" after the goal is reached). Nil when
    /// there is nothing to offer.
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
        let fresh = ReviewPlanner.introWords(
            feed: newWordFeed,
            all: words,
            progress: progress,
            limit: allowance,
            confusables: confusables
        )
        if fresh.isEmpty {
            return nil
        }
        return ReviewSession(
            kind: .new,
            words: Array(fresh.prefix(AppModel.introRoundLimit)),
            totalCount: fresh.count
        )
    }

    /// Records one answer and saves the progress right away. Returns the word's new progress (the
    /// round summary shows when it comes back). A new word counts for today's goal only when it
    /// was recalled: a "Hatırla" missed twice (`again`) leaves room for another new word.
    ///
    /// The local metrics (`LocalMetricsRecorder`) get the answer too: `firstTryCorrect` is the
    /// first pick of a question with options (nil: `grade != .again`), `seconds` the time from
    /// the question to the answer.
    @discardableResult
    func recordReview(
        _ word: WidgetWord,
        grade: ReviewGrade,
        firstTryCorrect: Bool? = nil,
        seconds: TimeInterval? = nil
    ) -> WordProgress {
        let now = Date()
        let current = progress[word.id] ?? WordProgress(wordID: word.id)
        let wasNew = current.state == .new
        let updated = Leitner.review(current, grade: grade, at: now)
        progress[word.id] = updated
        if persistProgress(progress) {
            try? reviewLog?.append(before: current, after: updated, source: .review)
        }
        let metrics = LocalMetricsRecorder.shared
        // A word sent back to "Tanış" by a failed "Biliyorum" check is new again but was answered
        // before: the metrics count only a word's very first question as new.
        metrics.recordAnswer(isNew: current.reviews == 0, firstTryCorrect: firstTryCorrect ?? (grade != .again), seconds: seconds, at: now)
        if current.awaitsKnownCheck {
            metrics.recordKnownCheck(passed: grade != .again, at: now)
        }
        // When the user studies, for "Saati benim için seç" (AppModel+ReminderTiming.swift).
        noteStudyTime(at: now)
        if wasNew {
            if grade != .again {
                AppPreferences.addNewWordsStudied(1, now: now)
            }
        } else {
            AppPreferences.addReviewsDone(1, now: now)
        }
        return updated
    }

    /// The answer of the recall screen (boxes 4–5, refreshers, the "Biliyorum" check): "Buldum"
    /// is `good`, "Bulamadım" `again`. A failed check sends the word back to "Tanış"
    /// (`WordProgress.returnsToIntro` on the result).
    @discardableResult
    func recordRecall(_ word: WidgetWord, found: Bool, seconds: TimeInterval? = nil) -> WordProgress {
        return recordReview(word, grade: found ? .good : .again, seconds: seconds)
    }

    /// How a due word is asked (`ReviewPlanner.questionKind`): its fill-in-the-blank question in
    /// boxes 1–3, the recall screen in boxes 4–5, for refreshers and for the "Biliyorum" check,
    /// and for a card without a usable question (seed words).
    func questionKind(for word: WidgetWord) -> QuestionKind {
        let hasCloze = !(detail(for: word)?.quiz?.distractors.isEmpty ?? true)
        return ReviewPlanner.questionKind(for: progress[word.id], hasCloze: hasCloze)
    }

    /// The "Hatırla" question of a new word (`ReviewPlanner.introQuestion`): English options from
    /// the card's written distractors, Turkish options from other cards' meanings (same part of
    /// speech and topic, then level). Nil when there are too few cards for options; the caller
    /// then asks with the recall screen.
    func introQuestion(for word: WidgetWord, direction: IntroRound.Direction, attempt: Int) -> ChoiceQuestion? {
        return ReviewPlanner.introQuestion(
            for: word,
            direction: direction,
            attempt: attempt,
            writtenDistractors: detail(for: word)?.quiz?.distractors ?? [],
            candidates: introCandidates(for: word),
            topicsOf: topicsOf,
            excludedIDs: unsettledConfusables(of: word)
        )
    }

    /// Confusable words by word id (`WidgetWord.confusableIDs`, both directions in the content):
    /// "Tanış" never puts two of them in one round.
    private var confusables: [Int: Set<Int>] {
        var result: [Int: Set<Int>] = [:]
        for word in words {
            if let ids = word.confusableIDs, !ids.isEmpty {
                result[word.id] = Set(ids)
            }
        }
        return result
    }

    /// The confusable partners of `word` the user has not settled yet (new, or still in box 1):
    /// they are kept out of its "Hatırla" options and its fill-in-the-blank question
    /// (`clozeQuiz`, AppModel+Review.swift), where the pair would only teach the mix-up.
    func unsettledConfusables(of word: WidgetWord) -> Set<Int> {
        let partners = word.confusableIDs ?? []
        return Set(partners.filter { id in
            guard let p = progress[id] else {
                return true
            }
            return p.state == .new || p.box < 2
        })
    }

    /// Whether the user already met `word` on the widget: a widget tap on it, or it is on the
    /// Lock Screen now. "Tanış" then asks "Widget'ta gördün. Hatırlıyor musun?".
    func wasSeenOnWidget(_ word: WidgetWord) -> Bool {
        return (progress[word.id]?.exposures ?? 0) > 0 || lockScreenWordID == word.id
    }

    /// When `word` would come back if it were answered with `grade` at `now`: the same
    /// `Leitner.review` that `recordReview` runs, on a copy of the progress (the times on the
    /// answer buttons, README point 8). Nothing is saved.
    func dueDate(ifAnswering grade: ReviewGrade, for word: WidgetWord, now: Date = Date()) -> Date? {
        let current = progress[word.id] ?? WordProgress(wordID: word.id)
        return Leitner.review(current, grade: grade, at: now).dueAt
    }

    /// The earliest review or refresher of a loaded word that falls due after `now` ("Sıradaki
    /// tekrar" on the done screen); nil when nothing is scheduled.
    func nextReviewDate(after now: Date = Date()) -> Date? {
        var earliest: Date?
        for word in words {
            guard let p = progress[word.id], p.state != .new, let due = p.dueAt, due > now else {
                continue
            }
            if earliest.map({ due < $0 }) ?? true {
                earliest = due
            }
        }
        return earliest
    }

    /// New words studied today (the ring on the "Tekrar" start screen).
    func newWordsStudiedToday(now: Date = Date()) -> Int {
        return AppPreferences.newWordsStudiedToday(now: now)
    }

    /// Reviews of already-studied words today ("Bugün: … tekrar" on the "Tekrar" screens).
    func reviewsDoneToday(now: Date = Date()) -> Int {
        return AppPreferences.reviewsDoneToday(now: now)
    }

    /// A flashcard round ended (`endedEarly`: by "Bitir" before its last card): the queue changes
    /// with the new progress, and the round's length goes to the local metrics.
    func finishReviewSession(endedEarly: Bool = false) {
        LocalMetricsRecorder.shared.finishRound(endedEarly: endedEarly)
        refreshWidgetPlan()
    }

    /// Known words (marked with "Biliyorum" or graduated), the most recently changed first.
    func knownWords() -> [WidgetWord] {
        let known = words.enumerated().filter { progress[$0.element.id]?.state == .known }
        return known.sorted { lhs, rhs in
            let left = progress[lhs.element.id]?.lastSeenAt ?? .distantPast
            let right = progress[rhs.element.id]?.lastSeenAt ?? .distantPast
            return left != right ? left > right : lhs.offset < rhs.offset
        }.map { $0.element }
    }

    func learningState(of word: WidgetWord) -> LearningState {
        return progress[word.id]?.state ?? .new
    }

    /// "Biliyorum" in the app (feed, dictionary, "Bunu zaten biliyorum" in "Tanış"): the same as
    /// the widget button. The word leaves the rotation and is asked once in 3 days
    /// (`Leitner.markKnown`). For `undoWindow` seconds `knownUndo` holds the tap, and "Geri al"
    /// (`undoKnown`) restores the word exactly as it was; the screen shows `KnownUndo.message`
    /// beside it. Pass a longer window while VoiceOver is on. No change for a known word.
    func markKnown(_ word: WidgetWord, undoWindow: TimeInterval = KnownUndo.window) {
        guard let change = updateProgress(of: word, { current, now in
            current.state == .known ? nil : Leitner.markKnown(current, at: now)
        }) else {
            return
        }
        let undo = KnownUndo(
            word: word,
            previous: change.previous,
            marked: change.updated,
            expiresAt: Date().addingTimeInterval(undoWindow)
        )
        knownUndo = undo
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(0, undoWindow) * 1_000_000_000))
            if self?.knownUndo == undo {
                self?.knownUndo = nil
            }
        }
    }

    /// "Geri al" and "Öğrenmeye geri al". Within the undo window of this word's last "Biliyorum"
    /// (`knownUndo`), and while nothing else changed the word since, it is restored exactly: box
    /// and due date as before the tap. Otherwise a known word returns to the rotation (due now if
    /// it was ever answered, otherwise new again); this also undoes a widget "Biliyorum".
    func undoKnown(_ word: WidgetWord) {
        let undo = knownUndo.flatMap { $0.word.id == word.id && Date() < $0.expiresAt ? $0 : nil }
        if knownUndo?.word.id == word.id {
            knownUndo = nil
        }
        updateProgress(of: word) { current, now in
            if let undo = undo, current == undo.marked {
                return undo.previous ?? WordProgress(wordID: word.id)
            }
            return current.state == .known ? Leitner.undoKnown(current, at: now) : nil
        }
    }

    /// The "Geri al" note was closed before its time.
    func dismissKnownUndo() {
        knownUndo = nil
    }

    /// "Vazgeç" after "Geri al" in "Bildiğin kelimeler": the word's progress is `previous` again
    /// (box, due date and check exactly as before), while it still is `undone` (nothing changed it
    /// since). Not `markKnown`, which would turn a learned word into an unchecked "Biliyorum".
    /// False when the word changed meanwhile or the save failed.
    @discardableResult
    func restoreProgress(of word: WidgetWord, to previous: WordProgress, ifStill undone: WordProgress) -> Bool {
        return updateProgress(of: word) { current, _ in
            current == undone ? previous : nil
        } != nil
    }

    /// The screen's "Geri al" for `word` is still showing (for example VoiceOver is on it): the
    /// exact undo of its last "Biliyorum" lasts until `date`. No change once the window has ended
    /// or another tap replaced it.
    func extendKnownUndo(of word: WidgetWord, until date: Date) {
        guard let undo = knownUndo, undo.word.id == word.id, Date() < undo.expiresAt, date > undo.expiresAt else {
            return
        }
        let extended = KnownUndo(word: undo.word, previous: undo.previous, marked: undo.marked, expiresAt: date)
        knownUndo = extended
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(0, date.timeIntervalSinceNow) * 1_000_000_000))
            if self?.knownUndo == extended {
                self?.knownUndo = nil
            }
        }
    }

    /// Applies pending widget taps first (a "known" tap still in the mailbox must not undo this
    /// change later), saves, then rewrites the widget queue. `change` returns nil for no change.
    /// Returns the word's progress before (nil: it had none) and after the change; nil when
    /// nothing changed or the save failed.
    @discardableResult
    private func updateProgress(
        of word: WidgetWord,
        _ change: (WordProgress, Date) -> WordProgress?
    ) -> (previous: WordProgress?, updated: WordProgress)? {
        ingestWidgetEvents()
        let previous = progress[word.id]
        let current = previous ?? WordProgress(wordID: word.id)
        guard let changed = change(current, Date()) else {
            return nil
        }
        var updated = progress
        updated[word.id] = changed
        guard persistProgress(updated) else {
            return nil
        }
        progress = updated
        refreshWidgetPlan()
        return (previous, changed)
    }

    func dismissProgressRecovery() {
        progressRecovery = nil
    }

    /// "İlerlemeyi sıfırla": forgets all progress. Unprocessed widget events are discarded first,
    /// otherwise they would be applied right after the reset. The visible widget word stays.
    func resetProgress() {
        discardPendingEvents()
        knownUndo = nil
        progress = [:]
        if persistProgress(progress) {
            try? reviewLog?.removeAll()
        }
        AppPreferences.clearKnownWordIDs()
        AppPreferences.resetNewWordsStudied()
        AppPreferences.resetReviewsDone()
        LocalMetricsRecorder.shared.reset()
        forgetStudyTimes()
        AppPreferences.clearFeedFirstSeen()
        AppModel.clearRecentSearches()
        // The words "Tekrar" listed as today's new words (`ReviewView.newWordsTodayLog`) are new again.
        UserDefaults.standard.removeObject(forKey: "lockglow.reviewNewWordsToday")
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
        var loaded: [Int: WordProgress]
        do {
            let result = try fileStore.load()
            loaded = result.progress
            switch result.outcome {
            case .fresh, .loaded:
                break
            case let .restoredFromBackup(setAside, backupDate):
                logger.error("progress file damaged (moved to \(setAside?.lastPathComponent ?? "-", privacy: .public)); restored the backup from \(backupDate?.description ?? "?", privacy: .public)")
                progressRecovery = result.outcome
            case let .startedOver(setAside):
                logger.error("progress file damaged (moved to \(setAside.lastPathComponent, privacy: .public)); no backup, progress starts over")
                progressRecovery = result.outcome
            }
        } catch {
            // No store: nothing is saved over the file, and widget events wait in the mailbox.
            // The next activation tries again.
            logger.error("progress file unreadable, will retry: \(String(describing: error), privacy: .public)")
            return
        }

        // One-time migration: ids the old build kept in UserDefaults become known words, checked
        // once in 3 days like any "Biliyorum". A word that already has progress is newer than
        // that list and is left alone. Words marked in progress.json before the check existed
        // need no rewrite: they get the same check on their due date (`awaitsKnownCheck`).
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
            let (updated, answers) = ProgressIngest.applyLogged(events, to: progress)
            if !persistProgress(updated) {
                return
            }
            progress = updated
            try? reviewLog?.append(answers)
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
    /// plan_id) composed by `QueueComposer` from the user's deck, and asks WidgetKit to reload.
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
        // The Lock Screen progress widget's numbers (AppModel+ProgressSnapshot.swift): written even
        // when no plan is, so they never go stale with an empty queue.
        writeProgressSnapshot(to: store, now: rewriteTime)
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

        // The deck first; if it has nothing left to rotate, every topic (same level order).
        let queue = QueueComposer.compose(
            deck: feedWords,
            fallbackFeed: allTopicsFeed,
            progress: progress,
            now: rewriteTime,
            horizon: AppModel.queueHorizon,
            maxNew: dailyNewWords * 2,
            limit: AppModel.queueLimit,
            pinFirst: pinnedWord(currentWord),
            // The slot pattern is tied to the clock (boundaries since 1970), so a rewrite on every
            // trip to the background does not start it again; +1: the slot after the pinned word.
            patternOffset: TimelinePlanner.elapsedBoundaries(
                from: Date(timeIntervalSince1970: 0),
                to: rewriteTime,
                interval: TimeInterval(rotationMinutes * 60),
                alignmentOffset: TimelinePlanner.localAlignmentOffset(for: rewriteTime)
            ) + 1
        )
        if queue.isEmpty {
            logger.notice("no words for a plan; the widget keeps its current data or the bundled seed")
            return
        }

        // The medium widget's example is the card's shortest example that contains the word
        // (docs/tasarim/README.md "Widget'lar"), not always its first. Only the text changes: the
        // queue and the pinned word stay id-based. Seed words have no detail and keep theirs.
        let planQueue = queue.map { word -> WidgetWord in
            guard let shortest = detail(for: word)?.shortestExample(containing: word.lemma),
                  shortest != word.exampleEN else {
                return word
            }
            return WidgetWord(
                id: word.id,
                lemma: word.lemma,
                pos: word.pos,
                level: word.level,
                ipaUS: word.ipaUS,
                ipaUK: word.ipaUK, // is5-ses: the widget's IPA follows "Ses ve aksan"
                defMicro: word.defMicro,
                defShort: word.defShort,
                exampleEN: shortest,
                glossTR: word.glossTR,
                glossShortTR: word.glossShortTR,
                sensitivity: word.sensitivity,
                confusableIDs: word.confusableIDs
            )
        }
        // is5-w-buyuk: the large widget's second example and warning (CoreModels/WidgetWarning.swift).
        .map { $0.addingLargeWidgetDetails(from: detail(for: $0)) }

        // The interval is global (all widget instances). The app owns it; changing it keeps the
        // visible word, because `currentWord` above was computed with the OLD plan's interval.
        let plan = WidgetPlan(
            planID: UUID().uuidString,
            isPremium: false,
            intervalSeconds: rotationMinutes * 60,
            queue: planQueue,
            updatedAt: rewriteTime
        )
        do {
            try store.writePlan(plan)
        } catch {
            logger.error("could not write the widget plan: \(error.localizedDescription, privacy: .public)")
            return
        }
        // The rewrite pins the visible word, so this is the same word as before, now from the new plan.
        updateLockScreenWord()
        reloadWidgets()
    }

    /// Works out `lockScreenWordID` from the plan and the widget's state on disk, with the same
    /// function the widget's timeline uses.
    private func updateLockScreenWord() {
        guard let store = store else {
            lockScreenWordID = nil
            return
        }
        let now = Date()
        let rotation = RotationInput.resolve(plan: store.readPlan(), state: store.readState(), seedWords: [])
        lockScreenWordID = TimelinePlanner.wordAt(
            now,
            queue: rotation.queue,
            knownIDs: rotation.knownIDs,
            cursorOffset: rotation.cursorOffset,
            cursorAnchor: rotation.cursorAnchor,
            interval: rotation.interval,
            alignmentOffset: TimelinePlanner.localAlignmentOffset(for: now)
        )?.id
    }

    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        lastReloadRequestedAt = Date()
    }

    // MARK: Health

    /// A Lockglow widget is on the Lock Screen (an accessory family) as of the last health check:
    /// only then do screens say the Lock Screen keeps showing words.
    var hasLockScreenWidget: Bool {
        return health.instances.contains { $0.family.hasPrefix("accessory") }
    }

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
            if let plan = plan, !plan.queue.isEmpty {
                // The widget's next entry date: boundaries depend only on the interval and the
                // local offset, so the cursor and the known ids do not matter here.
                let now = Date()
                let planned = TimelinePlanner.plan(
                    queue: plan.queue,
                    knownIDs: [],
                    cursorOffset: 0,
                    cursorAnchor: plan.updatedAt,
                    now: now,
                    interval: TimeInterval(plan.intervalSeconds),
                    maxEntries: 2,
                    alignmentOffset: TimelinePlanner.localAlignmentOffset(for: now)
                )
                snapshot.nextChangeAt = planned.count > 1 ? planned[1].date : nil
            }
            let state = store.readState()
            snapshot.cursorOffset = state?.cursorOffset
            snapshot.knownCount = state?.knownIDs.count
            snapshot.pendingEventCount = (try? store.eventMailbox.list().count) ?? 0
        }
        health = snapshot
        updateLockScreenWord()
    }
}

/// A "Biliyorum" that "Geri al" can still take back exactly (`AppModel.knownUndo`).
struct KnownUndo: Equatable {
    /// How long "Geri al" can take it back (`AppModel.markKnown`).
    static let window: TimeInterval = 5
    /// Shown with "Geri al" (docs/tasarim/ogrenme_ilkeleri.md 2.2).
    static let message = "Tamam. 3 gün sonra bir kez soracağız."

    let word: WidgetWord
    /// The word's progress before the tap; nil when it had none.
    let previous: WordProgress?
    /// What the tap wrote: the undo restores `previous` only while the word still has this.
    let marked: WordProgress
    let expiresAt: Date
}
