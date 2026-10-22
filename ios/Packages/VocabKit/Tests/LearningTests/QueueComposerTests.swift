import XCTest
import CoreModels
import Learning

final class QueueComposerTests: XCTestCase {
    /// 2023-11-14 22:13:20 UTC. "Today" (UTC) began 22 h 13 min 20 s earlier.
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let minute: TimeInterval = 60
    private let hour: TimeInterval = 3600
    private let day: TimeInterval = 86_400

    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func words(_ ids: ClosedRange<Int>) -> [WidgetWord] {
        return ids.map { id in
            WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: "B1", defMicro: "m", defShort: "s", exampleEN: "e")
        }
    }

    /// A learning word that was not answered today (no answer on record): only its due date counts.
    private func learning(_ id: Int, due: Date) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = 2
        p.dueAt = due
        return p
    }

    private func known(_ id: Int, due: Date, override: Bool = false) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .known
        p.box = 5
        p.knownOverride = override
        p.dueAt = due
        return p
    }

    /// A word studied before (in `box`, due long ago), answered with `grade` at `at` by the real
    /// `Leitner.review`, as "Tekrar" does.
    private func answer(_ id: Int, _ grade: ReviewGrade, at: Date, box: Int = 1) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = box
        p.reviews = 1
        p.dueAt = at.addingTimeInterval(-3 * day)
        p.lastSeenAt = at.addingTimeInterval(-4 * day)
        return Leitner.review(p, grade: grade, at: at)
    }

    /// 1: learning, overdue, not answered (hidden). 2: learning, due in 2 h, not answered (hidden).
    /// 3: refresher overdue by a day (hidden). 4: learning, due in 3 days. 5: known, refresher in
    /// 20 days (never queued). 6: refresher due in 12 h. 7: answered "Bildim" 1 h ago. 8: answered
    /// "Bilemedim" 30 min ago (missed today). 9 and up: new.
    private func mixedProgress() -> [Int: WordProgress] {
        return [
            1: learning(1, due: now.addingTimeInterval(-1 * hour)),
            2: learning(2, due: now.addingTimeInterval(2 * hour)),
            3: known(3, due: now.addingTimeInterval(-1 * day)),
            4: learning(4, due: now.addingTimeInterval(3 * day)),
            5: known(5, due: now.addingTimeInterval(20 * day), override: true),
            6: known(6, due: now.addingTimeInterval(12 * hour)),
            7: answer(7, .good, at: now.addingTimeInterval(-1 * hour)),
            8: answer(8, .again, at: now.addingTimeInterval(-30 * minute)),
        ]
    }

    private func ids(_ list: [WidgetWord]) -> [Int] {
        return list.map { $0.id }
    }

    // MARK: Hiding: the widget does not answer before "Tekrar" asks

    func testWordsDueSoonAreHiddenUntilAnswered() {
        // 1 (overdue) and 2 (due in 2 h) are learning words "Tekrar" asks within 6 h; 4 (due
        // in 1 h) and 5 (overdue) are refreshers "Tekrar" asks within 6 h. All four are hidden.
        // 3 is due in 7 h and 6 in 10 h: both may show. 7...10 are new (maxNew 4).
        let progress = [
            1: learning(1, due: now.addingTimeInterval(-1 * day)),
            2: learning(2, due: now.addingTimeInterval(2 * hour)),
            3: learning(3, due: now.addingTimeInterval(7 * hour)),
            4: known(4, due: now.addingTimeInterval(1 * hour)),
            5: known(5, due: now.addingTimeInterval(-2 * day)),
            6: known(6, due: now.addingTimeInterval(10 * hour)),
        ]
        // Pattern N L R L N L F ...: N→7, L→3 (due in 7 h), R→6, L→(no learning) new 8, N→9,
        // L→(no learning) new 10, F→ every list empty: the queue ends.
        let queue = QueueComposer.compose(feed: words(1...10), progress: progress, now: now, horizon: 2 * day, maxNew: 4, limit: 20, calendar: utc)
        XCTAssertEqual(ids(queue), [7, 3, 6, 8, 9, 10])
    }

    func testSixHourEdge() {
        // Due exactly 6 h from now: hidden. One second later: shown.
        let progress = [
            1: learning(1, due: now.addingTimeInterval(6 * hour)),
            2: learning(2, due: now.addingTimeInterval(6 * hour + 1)),
        ]
        let queue = QueueComposer.compose(feed: words(1...2), progress: progress, now: now, horizon: 2 * day, maxNew: 0, limit: 5, calendar: utc)
        XCTAssertEqual(ids(queue), [2])
    }

    func testWordsAnsweredTodayMayShowAgain() {
        // 1: "Bildim" 3 h ago, box 1 → 2, due in 2 days less 3 h. Answered today.
        // 2: "Bilemedim" 1 h ago: back in 10 min, so already due again, but answered (missed) today.
        // 3: "Zor" 2 h ago in box 1: due in 12 h less 2 h. Answered today.
        // 4: "Bildim" 47 h ago (yesterday), box 2 → due 2 days later = in 1 h. Not today: hidden.
        // 5: "Bilemedim" 2 h ago, then "Sonraki" tapped on the widget 30 min ago: the tap moves
        //    only the "last seen" time, so the answer can no longer be read back. It counts as
        //    not answered and, being overdue, is hidden (the safe side).
        // 6: "Bilemedim" 23 h ago (yesterday, 23:13): overdue, not answered today. Hidden.
        var tapped = answer(5, .again, at: now.addingTimeInterval(-2 * hour))
        tapped = Leitner.markExposure(tapped, at: now.addingTimeInterval(-30 * minute))
        let progress = [
            1: answer(1, .good, at: now.addingTimeInterval(-3 * hour)),
            2: answer(2, .again, at: now.addingTimeInterval(-1 * hour), box: 2),
            3: answer(3, .hard, at: now.addingTimeInterval(-2 * hour)),
            4: answer(4, .good, at: now.addingTimeInterval(-47 * hour)),
            5: tapped,
            6: answer(6, .again, at: now.addingTimeInterval(-23 * hour)),
        ]
        // Answered (correct), earliest answer first: 1 (3 h ago), 3 (2 h ago). Missed: 2.
        // New (maxNew 3): 7, 8, 9.
        // N→7, L→1, R→(no refresher) learning 3, L→(no correct left) missed 2, N→8,
        // L→(no learning) new 9, F→ every list empty: the queue ends.
        let queue = QueueComposer.compose(feed: words(1...9), progress: progress, now: now, horizon: 2 * day, maxNew: 3, limit: 20, calendar: utc)
        XCTAssertEqual(ids(queue), [7, 1, 3, 2, 8, 9])
    }

    func testMissedTodayGoesToTheFreeSlotFirst() {
        // Correct answers today: 11...14 (4 h, 3 h, 2 h, 1 h ago). Missed today: 15 (30 min ago).
        // Refresher: 20 (due in 12 h). New: 1...3 (maxNew 3).
        // N→1, L→11, R→20, L→12, N→2, L→13, F→15 (the missed word), L→14, N→3,
        // L→ every list empty: the queue ends.
        let queue = QueueComposer.compose(
            feed: missedFixtureFeed(),
            progress: missedFixtureProgress(),
            now: now,
            horizon: 2 * day,
            maxNew: 3,
            limit: 20,
            calendar: utc
        )
        XCTAssertEqual(ids(queue), [1, 11, 20, 12, 2, 13, 15, 14, 3])
        XCTAssertEqual(QueueComposer.pattern[6], .free)
    }

    private func missedFixtureFeed() -> [WidgetWord] {
        return words(1...3) + words(11...15) + words(20...20)
    }

    private func missedFixtureProgress() -> [Int: WordProgress] {
        return [
            11: answer(11, .good, at: now.addingTimeInterval(-4 * hour)),
            12: answer(12, .good, at: now.addingTimeInterval(-3 * hour)),
            13: answer(13, .good, at: now.addingTimeInterval(-2 * hour)),
            14: answer(14, .good, at: now.addingTimeInterval(-1 * hour)),
            15: answer(15, .again, at: now.addingTimeInterval(-30 * minute)),
            20: known(20, due: now.addingTimeInterval(12 * hour)),
        ]
    }

    // MARK: Slot budget

    func testPatternIsThreeNewFiveLearningOneRefresherOneFree() {
        let pattern = QueueComposer.pattern
        XCTAssertEqual(pattern.count, 10)
        XCTAssertEqual(pattern.filter { $0 == .new }.count, 3)
        XCTAssertEqual(pattern.filter { $0 == .learning }.count, 5)
        XCTAssertEqual(pattern.filter { $0 == .refresher }.count, 1)
        XCTAssertEqual(pattern.filter { $0 == .free }.count, 1)
    }

    func testSlotsPerDayFollowTheDesignTable() {
        // 16 waking hours: 960 min / 30 = 32, / 60 = 16, / 120 = 8, / 240 = 4.
        XCTAssertEqual(QueueComposer.slotsPerDay(rotation: 30 * minute), 32)
        XCTAssertEqual(QueueComposer.slotsPerDay(rotation: 1 * hour), 16)
        XCTAssertEqual(QueueComposer.slotsPerDay(rotation: 2 * hour), 8)
        XCTAssertEqual(QueueComposer.slotsPerDay(rotation: 4 * hour), 4)
        XCTAssertEqual(QueueComposer.slotsPerDay(rotation: 0), 0)
    }

    /// Plenty of every kind, so every slot gets a word of its own kind:
    /// 1...40 new, 101...140 answered correctly today, 201...210 refreshers due in 7–8 h,
    /// 301...310 missed today. The kind of each queued word is read back from its id.
    private func budgetFixture() -> (feed: [WidgetWord], progress: [Int: WordProgress]) {
        var progress: [Int: WordProgress] = [:]
        for id in 101...140 {
            progress[id] = answer(id, .good, at: now.addingTimeInterval(-Double(id - 100) * minute))
        }
        for id in 201...210 {
            progress[id] = known(id, due: now.addingTimeInterval(7 * hour + Double(id - 200) * minute))
        }
        for id in 301...310 {
            progress[id] = answer(id, .again, at: now.addingTimeInterval(-Double(id - 200) * minute))
        }
        let feed = words(1...40) + words(101...140) + words(201...210) + words(301...310)
        return (feed, progress)
    }

    private struct Budget: Equatable {
        var new = 0
        var learning = 0
        var refresher = 0
        var free = 0
    }

    private func budget(_ queue: ArraySlice<WidgetWord>) -> Budget {
        var b = Budget()
        for word in queue {
            switch word.id {
            case 1...99: b.new += 1
            case 101...199: b.learning += 1
            case 201...299: b.refresher += 1
            default: b.free += 1
            }
        }
        return b
    }

    func testDailyTableFromTheDesignNote() {
        let fixture = budgetFixture()
        let queue = QueueComposer.compose(feed: fixture.feed, progress: fixture.progress, now: now, horizon: 2 * day, maxNew: 40, limit: 32, calendar: utc)
        XCTAssertEqual(queue.count, 32)
        // Pattern N L R L N L F L N L. The table in docs/tasarim/ogrenme_ilkeleri.md 2.1:
        // 30 min, 32 slots = 3 full patterns (9 N, 15 L, 3 R, 3 F) + "N L" → 10, 16, 3, 3.
        XCTAssertEqual(budget(queue[0..<32]), Budget(new: 10, learning: 16, refresher: 3, free: 3))
        // 1 h, 16 slots = 1 pattern (3, 5, 1, 1) + "N L R L N L" (2, 3, 1, 0) → 5, 8, 2, 1.
        XCTAssertEqual(budget(queue[0..<16]), Budget(new: 5, learning: 8, refresher: 2, free: 1))
        // 2 h, 8 slots = "N L R L N L F L" → 2, 4, 1, 1.
        XCTAssertEqual(budget(queue[0..<8]), Budget(new: 2, learning: 4, refresher: 1, free: 1))
        // 4 h, 4 slots = "N L R L" → 1, 2, 1, 0.
        XCTAssertEqual(budget(queue[0..<4]), Budget(new: 1, learning: 2, refresher: 1, free: 0))
        // 4 h over five days (20 slots, 2 patterns) → 6, 10, 2, 2: two learning words every day;
        // the refresher on days 1 and 4, the free slot on days 2 and 5 (the table's "gün aşırı").
        XCTAssertEqual(budget(queue[0..<20]), Budget(new: 6, learning: 10, refresher: 2, free: 2))
        let days = stride(from: 0, to: 20, by: 4).map { budget(queue[$0..<($0 + 4)]) }
        XCTAssertEqual(days.map { $0.learning }, [2, 2, 2, 2, 2])
        XCTAssertEqual(days.map { $0.refresher }, [1, 0, 0, 1, 0])
        XCTAssertEqual(days.map { $0.free }, [0, 1, 0, 0, 1])
    }

    func testPatternOffsetContinuesThePatternAcrossRewrites() {
        // The same words as the free-slot test, starting at pattern index 6 (F):
        // F→15, L→11, N→1, L→12, N→2 (index 0), L→13, R→20, L→14, N→3,
        // L→ every list empty: the queue ends.
        let expected = [15, 11, 1, 12, 2, 13, 20, 14, 3]
        for offset in [6, 16, -4] {
            let queue = QueueComposer.compose(
                feed: missedFixtureFeed(),
                progress: missedFixtureProgress(),
                now: now,
                horizon: 2 * day,
                maxNew: 3,
                limit: 20,
                calendar: utc,
                patternOffset: offset
            )
            XCTAssertEqual(ids(queue), expected, "offset \(offset)")
        }
    }

    // MARK: Order, fallbacks and continuity

    func testOnlyNewWordsKeepsFeedOrder() {
        // N→1, L→(no learning) new 2, R→(no refresher, no learning) new 3, then every list is
        // empty and extra new words follow in feed order: 4...10.
        let queue = QueueComposer.compose(feed: words(1...20), progress: [:], now: now, horizon: 0, maxNew: 3, limit: 10, calendar: utc)
        XCTAssertEqual(ids(queue), Array(1...10))
    }

    func testMixFollowsThePatternAndFallbacks() {
        // Lists (horizon 48 h): answered [7], missed [8], refresher [6], new [9, 10] (maxNew 2),
        // top-up [4] (due in 3 days, after the horizon), extra new [11...14].
        // N→9, L→7, R→6, L→(no correct answer left) missed 8, N→10,
        // L→(learning, new, refresher empty) top-up 4, F→ extra 11, L→12, N→13, L→14.
        // 1, 2 and 3 are due soon in "Tekrar"; 5 is known and not due.
        let queue = QueueComposer.compose(feed: words(1...14), progress: mixedProgress(), now: now, horizon: 2 * day, maxNew: 2, limit: 12, calendar: utc)
        XCTAssertEqual(ids(queue), [9, 7, 6, 8, 10, 4, 11, 12, 13, 14])
    }

    func testHorizonMakesUpcomingLearningWordsFillTheirSlots() {
        // maxNew 5: new [9...13]. With a 48 h horizon, word 4 (due in 3 days) is a top-up, so the
        // 6th slot (L) falls back to a new word: N→9, L→7, R→6, L→8, N→10, L→11.
        let short = QueueComposer.compose(feed: words(1...14), progress: mixedProgress(), now: now, horizon: 2 * day, maxNew: 5, limit: 6, calendar: utc)
        XCTAssertEqual(ids(short), [9, 7, 6, 8, 10, 11])
        // With a 4-day horizon, word 4 is an upcoming learning word and takes that slot.
        let long = QueueComposer.compose(feed: words(1...14), progress: mixedProgress(), now: now, horizon: 4 * day, maxNew: 5, limit: 6, calendar: utc)
        XCTAssertEqual(ids(long), [9, 7, 6, 8, 10, 4])
    }

    func testPinnedWordStaysFirstEvenWhenDueSoon() {
        // Word 2 is due in 2 h, so it would be hidden, but it is on screen: a plan rewrite must
        // not change the visible word. It stays first, once; the rest is the plain queue
        // (testMixFollowsThePatternAndFallbacks) without 2.
        let pinned = words(2...2)[0]
        let queue = QueueComposer.compose(feed: words(1...14), progress: mixedProgress(), now: now, horizon: 2 * day, maxNew: 2, limit: 12, pinFirst: pinned, calendar: utc)
        XCTAssertEqual(ids(queue), [2, 9, 7, 6, 8, 10, 4, 11, 12, 13, 14])
    }

    func testPinnedWordIsTakenOutOfItsList() {
        // Pinned 7 (answered today) leaves the answered list empty:
        // N→9, L→missed 8, R→6, L→(no learning) new 10, N→(new, learning, refresher empty) top-up 4,
        // then extra new 11...14.
        let pinned = words(7...7)[0]
        let queue = QueueComposer.compose(feed: words(1...14), progress: mixedProgress(), now: now, horizon: 2 * day, maxNew: 2, limit: 12, pinFirst: pinned, calendar: utc)
        XCTAssertEqual(ids(queue), [7, 9, 8, 6, 10, 4, 11, 12, 13, 14])
    }

    func testKnownPinnedWordIsNotPinned() {
        let pinned = words(5...5)[0]
        let queue = QueueComposer.compose(feed: words(1...14), progress: mixedProgress(), now: now, horizon: 2 * day, maxNew: 2, limit: 12, pinFirst: pinned, calendar: utc)
        XCTAssertEqual(ids(queue), [9, 7, 6, 8, 10, 4, 11, 12, 13, 14])
    }

    func testNoDuplicatesAndFeedShorterThanLimit() {
        var feed = words(1...14)
        feed.append(contentsOf: words(1...3)) // duplicated ids in the feed
        let queue = QueueComposer.compose(feed: feed, progress: mixedProgress(), now: now, horizon: 2 * day, maxNew: 2, limit: 50, calendar: utc)
        XCTAssertEqual(Set(ids(queue)).count, queue.count)
        // Everything except the hidden 1, 2, 3 and the known, not-due 5.
        XCTAssertEqual(Set(ids(queue)), Set([4, 6, 7, 8, 9, 10, 11, 12, 13, 14]))
    }

    // MARK: Deck (topic choice)

    func testDeckQueueKeepsThePinnedWordThenUsesOnlyTheDeck() {
        // The word on screen (15) is outside the chosen deck (1...10): it stays first, the rest
        // come from the deck. N→1, L→(no learning) new 2, R→new 3, then extra new 4 and 5.
        let pinned = words(15...15)[0]
        let queue = QueueComposer.compose(deck: words(1...10), fallbackFeed: words(1...20), progress: [:], now: now, horizon: 0, maxNew: 3, limit: 6, pinFirst: pinned, calendar: utc)
        XCTAssertEqual(ids(queue), [15, 1, 2, 3, 4, 5])
    }

    func testDeckWithNothingLeftFallsBackToEveryWord() {
        // Every deck word (1...3) is known and not due. The pinned word (7) stays first, then
        // the new words of the whole feed: N→4, L→new 5 (maxNew 2), then extra new 6, 8.
        var progress: [Int: WordProgress] = [:]
        for id in 1...3 {
            progress[id] = known(id, due: now.addingTimeInterval(20 * day))
        }
        let pinned = words(7...7)[0]
        let queue = QueueComposer.compose(deck: words(1...3), fallbackFeed: words(1...10), progress: progress, now: now, horizon: 0, maxNew: 2, limit: 5, pinFirst: pinned, calendar: utc)
        XCTAssertEqual(ids(queue), [7, 4, 5, 6, 8])

        let unpinned = QueueComposer.compose(deck: words(1...3), fallbackFeed: words(1...10), progress: progress, now: now, horizon: 0, maxNew: 2, limit: 5, calendar: utc)
        XCTAssertEqual(ids(unpinned), [4, 5, 6, 7, 8])
    }

    func testDeckWhoseWordsAreAllDueSoonFallsBackToEveryTopic() {
        // The deck (1, 2) has no new word and both words are due in "Tekrar" within the hour:
        // hidden. New words come from every topic, so the widget is not left empty:
        // N→3, L→new 4 (maxNew 2), then extra new 5, 6.
        let progress = [
            1: learning(1, due: now.addingTimeInterval(1 * hour)),
            2: learning(2, due: now.addingTimeInterval(-1 * hour)),
        ]
        let queue = QueueComposer.compose(deck: words(1...2), fallbackFeed: words(1...6), progress: progress, now: now, horizon: 2 * day, maxNew: 2, limit: 4, calendar: utc)
        XCTAssertEqual(ids(queue), [3, 4, 5, 6])
    }

    func testFinishedDeckBorrowsNewWordsFromEveryTopic() {
        // The deck (1...2) has no new word left: word 1 is learning (due in 3 days), word 2 is
        // known. Like "Tekrar", new words now come from every topic (3, 4, ...), and word 1 still
        // rotates as a top-up; the known, not-due word 2 does not.
        // N→3, L→new 4, R→(nothing of its own) top-up 1, then extra new 5, 6.
        let progress = [
            1: learning(1, due: now.addingTimeInterval(3 * day)),
            2: known(2, due: now.addingTimeInterval(20 * day)),
        ]
        let queue = QueueComposer.compose(deck: words(1...2), fallbackFeed: words(1...10), progress: progress, now: now, horizon: 0, maxNew: 2, limit: 5, calendar: utc)
        XCTAssertEqual(ids(queue), [3, 4, 1, 5, 6])
    }

    func testDeckWithNewWordsDoesNotBorrow() {
        // Word 3 of the deck is still new: nothing outside the deck (4...10) enters the queue.
        let progress = [
            1: learning(1, due: now.addingTimeInterval(3 * day)),
            2: known(2, due: now.addingTimeInterval(20 * day)),
        ]
        let queue = QueueComposer.compose(deck: words(1...3), fallbackFeed: words(1...10), progress: progress, now: now, horizon: 0, maxNew: 2, limit: 5, calendar: utc)
        XCTAssertTrue(Set(ids(queue)).isSubset(of: [1, 3]))
    }

    func testDeckQueueEqualsThePlainQueueWhenTheDeckIsEverything() {
        let plain = QueueComposer.compose(feed: words(1...30), progress: mixedProgress(), now: now, horizon: day, maxNew: 5, limit: 20, pinFirst: words(4...4)[0], calendar: utc)
        let deck = QueueComposer.compose(deck: words(1...30), fallbackFeed: words(1...30), progress: mixedProgress(), now: now, horizon: day, maxNew: 5, limit: 20, pinFirst: words(4...4)[0], calendar: utc)
        XCTAssertEqual(ids(deck), ids(plain))
    }

    func testZeroLimitAndDeterminism() {
        XCTAssertTrue(QueueComposer.compose(feed: words(1...5), progress: [:], now: now, horizon: 0, maxNew: 2, limit: 0).isEmpty)
        let first = QueueComposer.compose(feed: words(1...30), progress: mixedProgress(), now: now, horizon: day, maxNew: 5, limit: 20, calendar: utc)
        let second = QueueComposer.compose(feed: words(1...30), progress: mixedProgress(), now: now, horizon: day, maxNew: 5, limit: 20, calendar: utc)
        XCTAssertEqual(ids(first), ids(second))
    }
}
