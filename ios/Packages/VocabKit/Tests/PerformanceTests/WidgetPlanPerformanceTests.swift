import XCTest
import CoreModels
import SharedState
import Scheduler
import Learning

/// The widget plan rewrite (`WidgetPlanBuilder`, run by the app on a background queue), the size
/// of `widget_plan.json` and `seed_words.json`, and what the widget does with them on every
/// timeline request (`WordDataSource.load` + `WordProvider.makeEntries`).
final class WidgetPlanPerformanceTests: XCTestCase {
    private let now = PerfFixtures.now
    private var cards: [WidgetWord] = []
    private var directory: URL!

    override func setUpWithError() throws {
        cards = PerfFixtures.cards()
        directory = try PerfFixtures.temporaryDirectory("plan")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func makeInput(for user: PerfFixtures.User, topics: Set<String> = []) -> WidgetPlanBuilder.Input {
        let topicsOf = PerfFixtures.topicsOf(cards)
        let choice = DeckChoice(topicIDs: topics, startLevel: .a2)
        return WidgetPlanBuilder.Input(
            deck: DeckFilter.feed(cards, topicsOf: topicsOf, choice: choice),
            fallbackFeed: DeckFilter.ordered(cards, startingAt: .a2),
            progress: PerfFixtures.progress(user, cards: cards),
            rotationMinutes: 60,
            dailyNewWords: 10,
            limit: 96,
            horizon: 48 * 3600
        )
    }

    /// Half of the cards have a shorter example with the word, as content.sqlite's cards often do.
    private func example(_ word: WidgetWord) -> String? {
        return word.id % 2 == 0 ? "We \(word.lemma) it." : nil
    }

    private func firstPlan(_ input: WidgetPlanBuilder.Input) throws -> WidgetPlan {
        return try XCTUnwrap(WidgetPlanBuilder.makePlan(input, at: now.addingTimeInterval(-5400), previousPlan: nil, state: nil, planExample: example))
    }

    // MARK: The rewrite

    /// One rewrite as the app's background queue runs it (XCTest allows one `measure` per test).
    private func measureRewrite(_ user: PerfFixtures.User, topics: Set<String> = []) throws {
        let input = makeInput(for: user, topics: topics)
        let oldPlan = try firstPlan(input)
        let state = WidgetState(planID: oldPlan.planID, cursorOffset: 3, cursorAnchor: now.addingTimeInterval(-1800), knownIDs: [oldPlan.queue[1].id], updatedAt: now)
        var queued = 0
        let label = "plan yeniden yazımı, \(user.rawValue), " + (topics.isEmpty ? "tüm konular" : "3 konu")
        measureReporting(label, budget: 0.5) {
            let plan = WidgetPlanBuilder.makePlan(input, at: self.now, previousPlan: oldPlan, state: state, planExample: self.example)
            queued = plan?.queue.count ?? 0
        }
        XCTAssertGreaterThan(queued, 0, label)
        XCTAssertLessThanOrEqual(queued, 96, label)
        PerfReport.value(label + ", kuyruk", "\(queued) kelime")
    }

    func testPlanRewriteFreshUser() throws {
        try measureRewrite(.fresh)
    }

    func testPlanRewriteMonthUser() throws {
        try measureRewrite(.month)
    }

    func testPlanRewriteHeavyUser() throws {
        try measureRewrite(.heavy)
    }

    func testPlanRewriteHeavyUserThreeTopics() throws {
        try measureRewrite(.heavy, topics: ["t1", "t5", "t9"])
    }

    // MARK: widget_plan.json

    private func writtenPlan() throws -> (AppGroupStore, WidgetPlan) {
        let store = AppGroupStore(containerURL: directory)
        let plan = try firstPlan(makeInput(for: .month))
        XCTAssertEqual(plan.queue.count, 96)
        try store.writePlan(plan)
        return (store, plan)
    }

    func testPlanFileSizeAndWrite() throws {
        let (store, plan) = try writtenPlan()
        let bytes = try Data(contentsOf: store.planURL).count
        PerfReport.bytes("widget_plan.json, 96 kelime (sentetik kartlar)", bytes)
        // About 400 bytes a word; the widget reads the file on every timeline request.
        XCTAssertLessThan(bytes, 96 * 1024, "widget_plan.json grew past 1 KB a word")
        measureReporting("widget_plan.json yaz (atomik)", budget: 0.25) {
            try store.writePlan(plan)
        }
    }

    func testPlanFileRead() throws {
        let (store, _) = try writtenPlan()
        measureReporting("widget_plan.json oku ve çöz", budget: 0.25) {
            XCTAssertEqual(store.readPlan()?.queue.count, 96)
        }
    }

    /// What the widget extension does for every timeline: read two small files, resolve the
    /// rotation, plan the entries (and once more without the known words if all were known).
    func testWidgetTimelineFromThePlanFiles() throws {
        let store = AppGroupStore(containerURL: directory)
        let plan = try firstPlan(makeInput(for: .heavy))
        try store.writePlan(plan)
        try store.writeState(WidgetState(planID: plan.planID, cursorOffset: 5, cursorAnchor: now.addingTimeInterval(-600), knownIDs: plan.queue.prefix(3).map { $0.id }, updatedAt: now))

        var entryCount = 0
        measureReporting("widget zaman çizelgesi (dosyalardan 96 girişe)", budget: 0.25) {
            let input = RotationInput.resolve(plan: store.readPlan(), state: store.readState(), seedWords: [])
            let entries = TimelinePlanner.plan(
                queue: input.queue,
                knownIDs: input.knownIDs,
                cursorOffset: input.cursorOffset,
                cursorAnchor: input.cursorAnchor,
                now: self.now,
                interval: input.interval,
                alignmentOffset: TimelinePlanner.localAlignmentOffset(for: self.now)
            )
            entryCount = entries.count
        }
        // 1 h interval: the entry now and the boundaries of the next 48 h.
        XCTAssertGreaterThanOrEqual(entryCount, 48)
        XCTAssertLessThanOrEqual(entryCount, TimelinePlanner.defaultMaxEntries)
        PerfReport.value("widget zaman çizelgesi, 60 dk", "\(entryCount) giriş")
    }

    /// WidgetKit gives a widget a limited number of reloads a day. The timeline asks for one at
    /// its end (`.atEnd`): never more than 96 entries over at most 48 h, so for every interval
    /// the timeline itself needs at most one reload a day; the app's plan rewrites add the rest.
    func testTimelineBudgetForEveryInterval() throws {
        let queue = Array(cards.prefix(96))
        let onBoundary = TimelinePlanner.roundedDownToWholeSecond(now)
        for minutes in [30, 60, 120, 240] {
            let interval = TimeInterval(minutes * 60)
            let entries = TimelinePlanner.plan(
                queue: queue,
                knownIDs: [],
                cursorOffset: 0,
                cursorAnchor: onBoundary.addingTimeInterval(-86_400),
                now: onBoundary.addingTimeInterval(7),
                interval: interval,
                alignmentOffset: TimelinePlanner.localAlignmentOffset(for: onBoundary)
            )
            let span = try XCTUnwrap(entries.last).date.timeIntervalSince(try XCTUnwrap(entries.first).date)
            XCTAssertLessThanOrEqual(entries.count, TimelinePlanner.defaultMaxEntries, "\(minutes) min")
            XCTAssertLessThanOrEqual(span, TimelinePlanner.defaultHorizon, "\(minutes) min")
            XCTAssertGreaterThanOrEqual(span, 24 * 3600, "\(minutes) min: the timeline must last a day")
            PerfReport.value(
                "zaman çizelgesi bütçesi, \(minutes) dk",
                "\(entries.count) giriş, \(String(format: "%.1f", span / 3600)) saat; çizelge sonu yenilemesi günde ≤ \(String(format: "%.2f", 86_400 / span))"
            )
        }
    }

    // MARK: seed_words.json

    func testSeedWordsSizeDecodeAndTimeline() throws {
        let url = PerfFixtures.seedWordsURL
        guard let data = try? Data(contentsOf: url) else {
            throw XCTSkip("seed_words.json is not in this checkout (the Linux check copies only VocabKit)")
        }
        PerfReport.bytes("seed_words.json", data.count)
        // content-pipeline/vocabpipe/build_db.py SEED_MAX_BYTES.
        XCTAssertLessThanOrEqual(data.count, 300_000)
        var words: [WidgetWord] = []
        measureReporting("seed_words.json çöz", budget: 0.5) {
            words = try SeedWords.decode(data).words
        }
        XCTAssertFalse(words.isEmpty)
        PerfReport.value("seed_words.json", "\(words.count) kelime")

        // No plan yet (first launch, the app not opened): the widget rotates the seed words.
        let input = RotationInput.resolve(plan: nil, state: nil, seedWords: words)
        XCTAssertTrue(input.isSeed)
        let entries = TimelinePlanner.plan(
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            now: now,
            interval: input.interval
        )
        XCTAssertGreaterThanOrEqual(entries.count, 48)
        XCTAssertLessThanOrEqual(entries.count, TimelinePlanner.defaultMaxEntries)
    }
}
