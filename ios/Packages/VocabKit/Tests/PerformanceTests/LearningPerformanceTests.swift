import XCTest
import CoreModels
import SharedState
import Learning

/// The learning work the app does on the main thread or at launch, over the whole content:
/// the widget queue (`QueueComposer`), the deck (`DeckFilter`), "Tekrar" (`ReviewPlanner`), the
/// progress file (`ProgressStore`, saved after every answer) and the widget's taps
/// (`EventMailbox` + `ProgressIngest`, on every return to the app). One `measure` per test.
final class LearningPerformanceTests: XCTestCase {
    private let now = PerfFixtures.now
    private var cards: [WidgetWord] = []
    private var topicsOf: [Int: Set<String>] = [:]
    private var directory: URL!

    override func setUpWithError() throws {
        cards = PerfFixtures.cards()
        topicsOf = PerfFixtures.topicsOf(cards)
        directory = try PerfFixtures.temporaryDirectory("learning")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    // MARK: QueueComposer

    private func measureCompose(_ user: PerfFixtures.User) {
        let progress = PerfFixtures.progress(user, cards: cards)
        let deck = DeckFilter.ordered(cards, startingAt: .a2)
        var count = 0
        measureReporting("QueueComposer.compose, \(user.rawValue)", budget: 0.25) {
            count = QueueComposer.compose(
                deck: deck,
                fallbackFeed: deck,
                progress: progress,
                now: self.now,
                horizon: 48 * 3600,
                maxNew: 20,
                limit: 96,
                pinFirst: deck[42],
                patternOffset: 7
            ).count
        }
        XCTAssertEqual(count, 96)
    }

    func testQueueComposerFreshUser() {
        measureCompose(.fresh)
    }

    func testQueueComposerMonthUser() {
        measureCompose(.month)
    }

    func testQueueComposerHeavyUser() {
        measureCompose(.heavy)
    }

    // MARK: Deck

    /// At launch and on every topic or level change (`AppModel.rebuildFeed`).
    func testDeckFilterFeedAndOrder() {
        let choice = DeckChoice(topicIDs: ["t1", "t5", "t9", "t20"], startLevel: .b1)
        var sizes = (0, 0)
        measureReporting("DeckFilter.feed + ordered (1.203 kart, 4 konu)", budget: 0.25) {
            let feed = DeckFilter.feed(self.cards, topicsOf: self.topicsOf, choice: choice)
            let all = DeckFilter.ordered(self.cards, startingAt: choice.startLevel)
            sizes = (feed.count, all.count)
        }
        XCTAssertGreaterThan(sizes.0, 0)
        XCTAssertEqual(sizes.1, cards.count)
    }

    // MARK: Tekrar

    /// "Tekrar" start screen: every due word, then today's new words.
    func testReviewPlannerDueAndIntroWords() {
        let progress = PerfFixtures.progress(.heavy, cards: cards)
        var confusables: [Int: Set<Int>] = [:]
        for card in cards {
            if let ids = card.confusableIDs, !ids.isEmpty {
                confusables[card.id] = Set(ids)
            }
        }
        var due = 0
        measureReporting("ReviewPlanner.dueWords + introWords (yoğun kullanıcı)", budget: 0.25) {
            due = ReviewPlanner.dueWords(feed: self.cards, progress: progress, now: self.now, limit: Int.max).count
            _ = ReviewPlanner.introWords(feed: self.cards, all: self.cards, progress: progress, limit: 10, confusables: confusables)
        }
        XCTAssertGreaterThan(due, 0)
    }

    // MARK: progress.json

    /// Saved after every answer and every "Biliyorum" (`AppModel.persistProgress`, main thread).
    func testProgressSaveHeavyUser() throws {
        let store = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
        let progress = PerfFixtures.progress(.heavy, cards: cards)
        try store.save(progress, now: now)
        measureReporting("progress.json kaydet (1.150 kelime)", budget: 0.5) {
            try store.save(progress, now: self.now)
        }
        let bytes = try Data(contentsOf: store.fileURL).count
        PerfReport.bytes("progress.json (yoğun kullanıcı)", bytes)
    }

    /// Read once at launch (`AppModel.loadProgress`, main thread, before the content loads).
    func testProgressLoadHeavyUser() throws {
        let store = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
        let progress = PerfFixtures.progress(.heavy, cards: cards)
        try store.save(progress, now: now)
        var loaded = 0
        measureReporting("progress.json oku (1.150 kelime)", budget: 0.5) {
            loaded = try store.load(now: self.now).progress.count
        }
        XCTAssertEqual(loaded, progress.count)
    }

    // MARK: Widget taps

    /// A day of widget taps waiting for the app: list the event files and apply them (the app does
    /// this on every return to the foreground and before every plan rewrite).
    func testIngestOfTwoHundredWidgetTaps() throws {
        let mailbox = EventMailbox(directory: directory.appendingPathComponent("events", isDirectory: true))
        for index in 0..<200 {
            let type: WidgetEventType = index % 10 == 0 ? .known : .next
            try mailbox.append(WidgetEvent(type: type, wordID: cards[index % cards.count].id, at: now.addingTimeInterval(Double(index) * 60), source: .systemSmall))
        }
        let progress = PerfFixtures.progress(.month, cards: cards)
        var applied: [Int: WordProgress] = [:]
        var listed = 0
        measureReporting("200 widget dokunuşunu oku ve işle", budget: 1.0) {
            let stored = try mailbox.list()
            listed = stored.count
            let events = stored.map { LearningEvent(type: $0.event.type, wordID: $0.event.wordID, at: $0.event.at) }
            applied = ProgressIngest.applyLogged(events, to: progress).progress
        }
        XCTAssertEqual(listed, 200)
        // Card 1 got "Biliyorum" (event 0), card 2 a "Sonraki" (event 1): both changed.
        XCTAssertEqual(applied[cards[0].id]?.state, .known)
        XCTAssertNotEqual(applied[cards[1].id], progress[cards[1].id])
    }

    // MARK: İlerleme

    func testProgressSummaryHeavyUser() {
        let progress = PerfFixtures.progress(.heavy, cards: cards)
        let topics = (0..<8).map { ContentTopic(id: "t\($0)", group: "A", nameEN: "Topic \($0)", nameTR: "Konu \($0)", sort: $0, cardCount: 40) }
        measureReporting("ProgressSummary.make (yoğun kullanıcı, 8 konu)", budget: 0.25) {
            let groups = ProgressSummary.WordGroup.topics(topics, topicsOf: self.topicsOf, words: self.cards)
            _ = ProgressSummary.make(progress: progress, now: self.now, wordIDs: Set(self.cards.map { $0.id }), topics: groups)
        }
    }
}
