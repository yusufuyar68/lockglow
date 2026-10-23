import XCTest
import CoreModels
import Learning

/// Switching "Yeni zamanlama (deneme)" on and off (`FSRSMigration`, fsrs.md 4.2): only the FSRS
/// memory changes, a second switch changes nothing, and Leitner goes on from what FSRS left.
final class FSRSMigrationTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_700_000_000)
    private let minute: TimeInterval = 60
    private let day: TimeInterval = 86_400
    private let scheduler = FSRSScheduler()
    private var now: Date { at(days: 20) }

    /// The words of `makeFixture`, one of each kind.
    private enum W {
        /// Every answer in the log.
        static let complete = 1
        /// Every answer in the log, with a "Bilemedim".
        static let lapsed = 2
        /// Answered before the log began; its first logged answer carries a seed.
        static let beforeLog = 3
        /// Its second answer is missing from the log.
        static let gap = 4
        /// Its last answer is missing from the log.
        static let missingLast = 5
        /// Answered only before the log began.
        static let noLog = 6
        /// "Biliyorum" on a word answered before the log; not checked yet.
        static let claim = 7
        /// Sent back to "Tanış" by a wrong check; its answers are not in the log.
        static let backToIntro = 8
        /// Only seen on the widget.
        static let seenOnly = 9
        /// "Biliyorum" on a word never answered.
        static let claimedNew = 10
        /// Already answered with FSRS.
        static let upToDate = 11
        /// Known, on refresher step 1, answered only before the log began.
        static let knownNoLog = 12
        /// "Biliyorum" on a word whose answers are all in the log.
        static let claimLogged = 13

        static let all = [complete, lapsed, beforeLog, gap, missingLast, noLog, claim, backToIntro, seenOnly,
                          claimedNew, upToDate, knownNoLog, claimLogged]
        static let replayed = [complete, lapsed, beforeLog, claimLogged]
        static let estimated = [gap, missingLast, noLog, knownNoLog]
        static let withoutMemory = [claim, backToIntro]
        static let neverAnswered = [seenOnly, claimedNew]
    }

    private func at(days: Double, minutes: Double = 0) -> Date {
        return start.addingTimeInterval(days * day + minutes * minute)
    }

    /// Answers `p` as the app does (Leitner unless told otherwise) and logs the answer.
    private func answer(
        _ p: inout WordProgress,
        _ grade: ReviewGrade,
        at date: Date,
        by reviewer: any ReviewScheduler = LeitnerScheduler(),
        into log: inout [ReviewLogEntry]
    ) {
        let before = p
        p = reviewer.review(p, grade: grade, at: date)
        guard let entry = ReviewLogEntry(before: before, after: p, source: .review) else {
            return XCTFail("an answer always makes an entry")
        }
        log.append(entry)
    }

    /// A word as an earlier build left it: answered, but without an answer time.
    private func answeredBeforeLog(
        _ id: Int,
        state: LearningState,
        box: Int,
        reviews: Int,
        lapses: Int = 0,
        dueAt: Date,
        refresherStep: Int? = nil
    ) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = state
        p.box = box
        p.reviews = reviews
        p.lapses = lapses
        p.dueAt = dueAt
        p.lastSeenAt = dueAt.addingTimeInterval(-2 * day)
        p.refresherStep = refresherStep
        p.exposures = 3
        return p
    }

    private func makeFixture() -> (progress: [Int: WordProgress], log: [ReviewLogEntry]) {
        var log: [ReviewLogEntry] = []
        var lost: [ReviewLogEntry] = []
        var progress: [Int: WordProgress] = [:]

        var complete = WordProgress(wordID: W.complete)
        answer(&complete, .good, at: at(days: 0), into: &log)
        answer(&complete, .good, at: at(days: 2), into: &log)
        answer(&complete, .hard, at: at(days: 6), into: &log)
        progress[W.complete] = complete

        var lapsed = WordProgress(wordID: W.lapsed)
        answer(&lapsed, .good, at: at(days: 0, minutes: 1), into: &log)
        answer(&lapsed, .again, at: at(days: 1), into: &log)
        answer(&lapsed, .good, at: at(days: 1, minutes: 10), into: &log)
        progress[W.lapsed] = lapsed

        var beforeLog = answeredBeforeLog(W.beforeLog, state: .learning, box: 3, reviews: 4, lapses: 1, dueAt: start)
        answer(&beforeLog, .good, at: at(days: 1), into: &log)
        answer(&beforeLog, .good, at: at(days: 9), into: &log)
        progress[W.beforeLog] = beforeLog

        var gap = WordProgress(wordID: W.gap)
        var gapLog: [ReviewLogEntry] = []
        answer(&gap, .good, at: at(days: 0, minutes: 2), into: &gapLog)
        answer(&gap, .good, at: at(days: 1), into: &gapLog)
        answer(&gap, .good, at: at(days: 3), into: &gapLog)
        gapLog.remove(at: 1)
        log += gapLog
        progress[W.gap] = gap

        var missingLast = WordProgress(wordID: W.missingLast)
        var missingLastLog: [ReviewLogEntry] = []
        answer(&missingLast, .good, at: at(days: 0, minutes: 3), into: &missingLastLog)
        answer(&missingLast, .easy, at: at(days: 1), into: &missingLastLog)
        answer(&missingLast, .good, at: at(days: 5), into: &missingLastLog)
        missingLastLog.removeLast()
        log += missingLastLog
        progress[W.missingLast] = missingLast

        progress[W.noLog] = answeredBeforeLog(W.noLog, state: .learning, box: 2, reviews: 3, dueAt: at(days: -1))

        let claimed = answeredBeforeLog(W.claim, state: .learning, box: 2, reviews: 3, dueAt: at(days: 1))
        progress[W.claim] = Leitner.markKnown(claimed, at: at(days: -1))

        var back = WordProgress(wordID: W.backToIntro)
        answer(&back, .good, at: at(days: 0), into: &lost)
        back = Leitner.markKnown(back, at: at(days: 1))
        answer(&back, .again, at: at(days: 4), into: &lost)
        progress[W.backToIntro] = back

        let seen = Leitner.markExposure(WordProgress(wordID: W.seenOnly), at: at(days: 1))
        progress[W.seenOnly] = Leitner.markExposure(seen, at: at(days: 2))

        progress[W.claimedNew] = Leitner.markKnown(WordProgress(wordID: W.claimedNew), at: at(days: 2))

        var upToDate = WordProgress(wordID: W.upToDate)
        answer(&upToDate, .good, at: at(days: 3), by: scheduler, into: &log)
        progress[W.upToDate] = upToDate

        progress[W.knownNoLog] = answeredBeforeLog(
            W.knownNoLog, state: .known, box: 5, reviews: 9, lapses: 2, dueAt: at(days: 30), refresherStep: 1
        )

        var claimLogged = WordProgress(wordID: W.claimLogged)
        answer(&claimLogged, .good, at: at(days: 0, minutes: 4), into: &log)
        answer(&claimLogged, .good, at: at(days: 1, minutes: 4), into: &log)
        progress[W.claimLogged] = Leitner.markKnown(claimLogged, at: at(days: 2))

        return (progress, log)
    }

    private func report(replayed: Int, estimated: Int, kept: Int, withoutMemory: Int) -> FSRSMigration.Report {
        var r = FSRSMigration.Report()
        r.replayed = replayed
        r.estimated = estimated
        r.kept = kept
        r.withoutMemory = withoutMemory
        return r
    }

    private func count(_ state: LearningState, in progress: [Int: WordProgress]) -> Int {
        return progress.values.filter { $0.state == state }.count
    }

    // MARK: Switching on

    func testTheFixtureHasEveryKind() {
        let fixture = makeFixture()
        XCTAssertEqual(Set(fixture.progress.keys), Set(W.all))
        XCTAssertNotNil(fixture.log.first { $0.wordID == W.beforeLog }?.seed)
        XCTAssertTrue(fixture.progress[W.claim]?.awaitsKnownCheck ?? false)
        XCTAssertTrue(fixture.progress[W.claimLogged]?.awaitsKnownCheck ?? false)
        XCTAssertTrue(fixture.progress[W.backToIntro]?.returnsToIntro ?? false)
        XCTAssertEqual(fixture.progress[W.seenOnly]?.exposures, 2)
        XCTAssertEqual(fixture.progress[W.claimedNew]?.reviews, 0)
        XCTAssertEqual(fixture.progress[W.upToDate]?.fsrs?.reviews, 1)
        XCTAssertNil(fixture.progress[W.complete]?.fsrs)
    }

    func testOnlyTheMemoryChanges() throws {
        let fixture = makeFixture()
        let result = FSRSMigration.takeOver(fixture.progress, log: fixture.log, scheduler: scheduler, now: now)
        XCTAssertEqual(Set(result.progress.keys), Set(fixture.progress.keys))
        for (id, before) in fixture.progress {
            let after = try XCTUnwrap(result.progress[id])
            // Due date, state, box, lapses, "Biliyorum", counters, dates: all as they were.
            var withoutMemory = after
            withoutMemory.fsrs = before.fsrs
            XCTAssertEqual(withoutMemory, before, "word \(id)")
            XCTAssertEqual(after.dueAt, before.dueAt, "word \(id)")
            XCTAssertEqual(after.state, before.state, "word \(id)")
            XCTAssertEqual(after.box, before.box, "word \(id)")
            XCTAssertEqual(after.lapses, before.lapses, "word \(id)")
            XCTAssertEqual(after.knownOverride, before.knownOverride, "word \(id)")
            XCTAssertEqual(after.refresherStep, before.refresherStep, "word \(id)")
        }
        for id in W.neverAnswered {
            XCTAssertEqual(result.progress[id], fixture.progress[id], "word \(id)")
        }
        for state in [LearningState.new, .learning, .known] {
            XCTAssertEqual(count(state, in: result.progress), count(state, in: fixture.progress), "\(state)")
        }
    }

    func testTheReportCountsEveryWay() {
        let fixture = makeFixture()
        XCTAssertEqual(FSRSMigration.outdatedCount(fixture.progress), W.replayed.count - 1 + W.estimated.count)
        let result = FSRSMigration.takeOver(fixture.progress, log: fixture.log, scheduler: scheduler, now: now)
        XCTAssertEqual(result.report, report(replayed: 4, estimated: 4, kept: 1, withoutMemory: 2))
        XCTAssertEqual(FSRSMigration.outdatedCount(result.progress), 0)
        for id in W.replayed + W.estimated + [W.upToDate] {
            XCTAssertEqual(result.progress[id]?.fsrs?.reviews, result.progress[id]?.reviews, "word \(id)")
        }
    }

    func testReplayedMemoryIsTheReplay() throws {
        let fixture = makeFixture()
        let result = FSRSMigration.takeOver(fixture.progress, log: fixture.log, scheduler: scheduler, now: now)
        let replay = scheduler.replay(fixture.log)
        for id in W.replayed {
            let p = try XCTUnwrap(result.progress[id])
            let card = try XCTUnwrap(replay.cards[id], "word \(id)")
            let state = try XCTUnwrap(p.fsrs, "word \(id)")
            XCTAssertEqual(replay.reviews[id], p.reviews, "word \(id)")
            XCTAssertEqual(state.card.memory, card.memory, "word \(id)")
            XCTAssertEqual(state.lastReviewAt, card.lastReviewAt, "word \(id)")
            XCTAssertEqual(state.phase, card.phase, "word \(id)")
            XCTAssertEqual(state.step, card.step, "word \(id)")
            XCTAssertEqual(state.reviews, p.reviews, "word \(id)")
            XCTAssertNil(state.shelfBefore, "word \(id)")
        }
        XCTAssertEqual(result.progress[W.complete]?.fsrs?.lastReviewAt, at(days: 6))
    }

    func testEstimatedMemoryIsTheEstimate() throws {
        let fixture = makeFixture()
        let result = FSRSMigration.takeOver(fixture.progress, log: fixture.log, scheduler: scheduler, now: now)
        for id in W.estimated {
            let before = try XCTUnwrap(fixture.progress[id])
            let card = scheduler.estimatedCard(of: before, at: now)
            XCTAssertEqual(result.progress[id]?.fsrs, FSRSState(card: card, reviews: before.reviews, shelfBefore: nil), "word \(id)")
            XCTAssertNotNil(card.memory, "word \(id)")
        }
        // A known word on refresher step 1 is estimated at its 60-day wait.
        XCTAssertEqual(result.progress[W.knownNoLog]?.fsrs?.stability, Leitner.refresherDays[1])
    }

    func testWordsWithoutMemoryStayWithoutOne() {
        let fixture = makeFixture()
        let result = FSRSMigration.takeOver(fixture.progress, log: fixture.log, scheduler: scheduler, now: now)
        for id in W.withoutMemory + W.neverAnswered {
            XCTAssertNil(result.progress[id]?.fsrs, "word \(id)")
        }
        XCTAssertTrue(result.progress[W.claim]?.awaitsKnownCheck ?? false)
        XCTAssertTrue(result.progress[W.backToIntro]?.returnsToIntro ?? false)
        // A claim whose earlier answers are all in the log keeps their memory.
        XCTAssertNotNil(result.progress[W.claimLogged]?.fsrs)
    }

    func testTakingOverTwiceIsTakingOverOnce() {
        let fixture = makeFixture()
        let once = FSRSMigration.takeOver(fixture.progress, log: fixture.log, scheduler: scheduler, now: now)
        let twice = FSRSMigration.takeOver(once.progress, log: fixture.log, scheduler: scheduler, now: now)
        XCTAssertEqual(twice.progress, once.progress)
        XCTAssertEqual(twice.report, report(replayed: 0, estimated: 0, kept: 9, withoutMemory: 2))

        // Without claims or words back in "Tanış", everything is kept.
        let answered = fixture.progress.filter { !W.withoutMemory.contains($0.key) }
        let first = FSRSMigration.takeOver(answered, log: fixture.log, scheduler: scheduler, now: now)
        let second = FSRSMigration.takeOver(first.progress, log: fixture.log, scheduler: scheduler, now: now)
        XCTAssertEqual(second.progress, first.progress)
        XCTAssertEqual(second.report, report(replayed: 0, estimated: 0, kept: 9, withoutMemory: 0))
    }

    func testAnEmptyLogEstimatesEveryWord() throws {
        let fixture = makeFixture()
        let result = FSRSMigration.takeOver(fixture.progress, log: [], scheduler: scheduler, now: now)
        // The claim with logged answers has nothing left to estimate from either.
        XCTAssertEqual(result.report, report(replayed: 0, estimated: 7, kept: 1, withoutMemory: 3))
        for id in W.replayed + W.estimated where id != W.claimLogged {
            let before = try XCTUnwrap(fixture.progress[id])
            let card = scheduler.estimatedCard(of: before, at: now)
            XCTAssertEqual(result.progress[id]?.fsrs, FSRSState(card: card, reviews: before.reviews, shelfBefore: nil), "word \(id)")
        }
        XCTAssertNil(result.progress[W.claimLogged]?.fsrs)
        XCTAssertEqual(FSRSMigration.outdatedCount(result.progress), 0)
    }

    func testAMissingLastAnswerIsEstimatedNotReplayed() throws {
        let fixture = makeFixture()
        let p = try XCTUnwrap(fixture.progress[W.missingLast])
        let replay = scheduler.replay(fixture.log)
        // The log's answers are a complete run, but one short of the word's.
        XCTAssertNotNil(replay.cards[W.missingLast])
        XCTAssertEqual(replay.reviews[W.missingLast], p.reviews - 1)
        XCTAssertTrue(replay.incomplete.contains(W.gap))

        let result = FSRSMigration.takeOver([W.missingLast: p], log: fixture.log, scheduler: scheduler, now: now)
        XCTAssertEqual(result.report, report(replayed: 0, estimated: 1, kept: 0, withoutMemory: 0))
        let estimate = FSRSState(card: scheduler.estimatedCard(of: p, at: now), reviews: p.reviews, shelfBefore: nil)
        XCTAssertEqual(result.progress[W.missingLast]?.fsrs, estimate)
        XCTAssertEqual(result.progress[W.missingLast]?.fsrs?.lastReviewAt, at(days: 5))
    }

    // MARK: Switching off and on again

    func testLeitnerGoesOnAfterFSRS() throws {
        let fixture = makeFixture()
        var log = fixture.log
        var progress = FSRSMigration.takeOver(fixture.progress, log: log, scheduler: scheduler, now: now).progress

        // FSRS answers.
        var word = try XCTUnwrap(progress[W.complete])
        answer(&word, .good, at: at(days: 21), by: scheduler, into: &log)
        answer(&word, .good, at: at(days: 25), by: scheduler, into: &log)
        XCTAssertEqual(word.fsrs?.reviews, word.reviews)
        progress[W.complete] = word
        var claim = try XCTUnwrap(progress[W.claimLogged])
        answer(&claim, .good, at: at(days: 21), by: scheduler, into: &log)
        XCTAssertEqual(claim.state, .known)
        XCTAssertFalse(claim.knownOverride)
        progress[W.claimLogged] = claim
        XCTAssertEqual(FSRSMigration.outdatedCount(progress), 0)

        // "Yeni zamanlama" off: Leitner goes on from the box, due date and refresher step.
        let leitnerDay = at(days: 30)
        for id in [W.complete, W.knownNoLog] {
            var p = try XCTUnwrap(progress[id])
            let memory = p.fsrs
            XCTAssertNotNil(memory, "word \(id)")
            answer(&p, .good, at: leitnerDay, into: &log)
            XCTAssertEqual(p.fsrs, memory, "word \(id)")
            XCTAssertNotEqual(p.fsrs?.reviews, p.reviews, "word \(id)")
            XCTAssertNotEqual(p.state, .new, "word \(id)")
            XCTAssertGreaterThan(p.dueAt ?? .distantPast, leitnerDay, "word \(id)")
            if p.state == .learning {
                XCTAssertTrue((1...Leitner.maxBox).contains(p.box), "word \(id)")
            } else {
                XCTAssertEqual(p.box, Leitner.maxBox, "word \(id)")
            }
            progress[id] = p
        }
        XCTAssertEqual(progress[W.knownNoLog]?.refresherStep, 2)
        XCTAssertEqual(FSRSMigration.outdatedCount(progress), 2)

        // On again: rebuilt from a log that has the Leitner answers too.
        let later = at(days: 31)
        let again = FSRSMigration.takeOver(progress, log: log, scheduler: scheduler, now: later)
        XCTAssertEqual(again.report, report(replayed: 2, estimated: 0, kept: 7, withoutMemory: 2))
        let replay = scheduler.replay(log)
        for id in [W.complete, W.knownNoLog] {
            let p = try XCTUnwrap(again.progress[id])
            let card = try XCTUnwrap(replay.cards[id], "word \(id)")
            XCTAssertEqual(replay.reviews[id], p.reviews, "word \(id)")
            XCTAssertEqual(p.fsrs, FSRSState(card: card, reviews: p.reviews, shelfBefore: nil), "word \(id)")
            XCTAssertEqual(p.fsrs?.lastReviewAt, leitnerDay, "word \(id)")
            var unchanged = p
            unchanged.fsrs = progress[id]?.fsrs
            XCTAssertEqual(unchanged, progress[id], "word \(id)")
        }
        XCTAssertEqual(FSRSMigration.outdatedCount(again.progress), 0)
    }

    func testOnOffOnWithoutAnswersChangesNothing() throws {
        let fixture = makeFixture()
        var log = fixture.log
        let on = FSRSMigration.takeOver(fixture.progress, log: log, scheduler: scheduler, now: now)
        XCTAssertEqual(FSRSMigration.outdatedCount(on.progress), 0)

        // Off, then on again days later: nothing to do.
        let onAgain = FSRSMigration.takeOver(on.progress, log: log, scheduler: scheduler, now: at(days: 40))
        XCTAssertEqual(onAgain.progress, on.progress)
        XCTAssertEqual(onAgain.report.replayed + onAgain.report.estimated, 0)

        // The same after FSRS answers.
        var progress = on.progress
        var p = try XCTUnwrap(progress[W.lapsed])
        answer(&p, .good, at: at(days: 21), by: scheduler, into: &log)
        progress[W.lapsed] = p
        let afterAnswers = FSRSMigration.takeOver(progress, log: log, scheduler: scheduler, now: at(days: 41))
        XCTAssertEqual(afterAnswers.progress, progress)
        XCTAssertEqual(afterAnswers.report, report(replayed: 0, estimated: 0, kept: 9, withoutMemory: 2))
    }

    func testFSRSAnswersAreLogged() throws {
        let fixture = makeFixture()
        var log = fixture.log
        var progress = FSRSMigration.takeOver(fixture.progress, log: log, scheduler: scheduler, now: now).progress
        let answerDay = at(days: 21)
        for id in W.all {
            var p = try XCTUnwrap(progress[id])
            let before = p
            let logged = log.count
            answer(&p, .good, at: answerDay, by: scheduler, into: &log)
            XCTAssertEqual(log.count, logged + 1, "word \(id)")
            let entry = try XCTUnwrap(log.last)
            XCTAssertEqual(entry.wordID, id)
            XCTAssertEqual(entry.reviews, p.reviews, "word \(id)")
            XCTAssertEqual(entry.grade, .good, "word \(id)")
            XCTAssertEqual(entry.at, answerDay, "word \(id)")
            XCTAssertEqual(entry.knownCheck, before.awaitsKnownCheck ? true : nil, "word \(id)")
            // A word answered before the log carries its seed with its first logged answer.
            XCTAssertEqual(entry.seed != nil, before.reviews > 0 && before.lastReviewedAt == nil, "word \(id)")
            XCTAssertEqual(p.fsrs?.reviews, p.reviews, "word \(id)")
            progress[id] = p
        }
        // Every word whose earlier answers are all in the log, or came before it, has no gap.
        let replay = scheduler.replay(log)
        for id in [W.complete, W.lapsed, W.beforeLog, W.noLog, W.claim, W.seenOnly, W.claimedNew, W.upToDate,
                   W.knownNoLog, W.claimLogged] {
            XCTAssertEqual(replay.reviews[id], progress[id]?.reviews, "word \(id)")
        }
        XCTAssertEqual(replay.incomplete, [W.gap, W.missingLast, W.backToIntro])
        XCTAssertEqual(FSRSMigration.outdatedCount(progress), 0)
    }

    // MARK: Switching off: handBack

    /// A word whose last answer was FSRS's (`shelfBefore` set), last answered at `start`.
    private func answeredByFSRS(
        _ id: Int,
        state: LearningState,
        box: Int,
        dueAt: Date,
        refresherStep: Int? = nil,
        stability: Double,
        shelfBefore: Int? = ProgressSummary.Shelf.box5.rawValue
    ) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = state
        p.box = box
        p.reviews = 7
        p.lapses = 1
        p.exposures = 4
        p.saved = true
        p.dueAt = dueAt
        p.refresherStep = refresherStep
        p.firstReviewedAt = at(days: -90)
        p.lastSeenAt = start
        p.lastReviewedAt = start
        p.lastGrade = .good
        p.fsrs = FSRSState(
            stability: stability, difficulty: 4, phase: .review, step: nil, lastReviewAt: start, reviews: 7, shelfBefore: shelfBefore
        )
        return p
    }

    func testHandBackBringsFSRSWaitsWithinLeitners() throws {
        // FSRS gave a known word on refresher step 1 200 days; Leitner gives that step 60.
        let known = answeredByFSRS(1, state: .known, box: 5, dueAt: at(days: 200), refresherStep: 1, stability: 210)
        // A known word on step 0 whose wait is 46 days: Leitner's 30.
        let fresh = answeredByFSRS(2, state: .known, box: 5, dueAt: at(days: 46), stability: 46)
        // A learning word on basamak 1 with FSRS's first "Bildim" wait of 2 days: Leitner's 1 day.
        let firstGood = scheduler.review(WordProgress(wordID: 3), grade: .good, at: start)
        XCTAssertEqual(firstGood.box, 1)
        XCTAssertEqual(firstGood.dueAt, at(days: 2))
        // A learning word on basamak 4 that FSRS gave 11 days: Leitner's 8.
        let step4 = answeredByFSRS(4, state: .learning, box: 4, dueAt: at(days: 11), stability: 11, shelfBefore: 1)

        let progress = [1: known, 2: fresh, 3: firstGood, 4: step4]
        let result = FSRSMigration.handBack(progress)
        XCTAssertEqual(Set(result.keys), Set(progress.keys))
        XCTAssertEqual(result[1]?.dueAt, start.addingTimeInterval(Leitner.refresherWait(step: 1)))
        XCTAssertEqual(result[1]?.dueAt, at(days: 60))
        XCTAssertEqual(result[2]?.dueAt, start.addingTimeInterval(Leitner.refresherWait(step: 0)))
        XCTAssertEqual(result[3]?.dueAt, at(days: 1))
        XCTAssertEqual(result[4]?.dueAt, at(days: 8))

        // Only the due date changes.
        for (id, before) in progress {
            var after = try XCTUnwrap(result[id], "word \(id)")
            XCTAssertLessThan(after.dueAt ?? .distantFuture, before.dueAt ?? .distantPast, "word \(id)")
            after.dueAt = before.dueAt
            XCTAssertEqual(after, before, "word \(id)")
        }
    }

    func testHandBackNeverPutsADateOff() {
        // Within Leitner's wait, or already overdue: as they were.
        let missed = scheduler.review(WordProgress(wordID: 1), grade: .again, at: start)
        let hard = scheduler.review(WordProgress(wordID: 2), grade: .hard, at: start)
        XCTAssertEqual(hard.dueAt, start.addingTimeInterval(FSRSScheduler.hardStepWait))
        let soon = answeredByFSRS(3, state: .known, box: 5, dueAt: at(days: 25), stability: 25)
        let overdue = answeredByFSRS(4, state: .learning, box: 2, dueAt: at(days: -3), stability: 2, shelfBefore: 1)
        let exact = answeredByFSRS(5, state: .learning, box: 3, dueAt: at(days: 4), stability: 4, shelfBefore: 2)
        let progress = [1: missed, 2: hard, 3: soon, 4: overdue, 5: exact]
        XCTAssertEqual(FSRSMigration.handBack(progress), progress)
    }

    func testHandBackLeavesWhatFSRSDidNotScheduleLast() {
        // A memory rebuilt by `takeOver` (no `shelfBefore`): Leitner set that date.
        let migrated = answeredByFSRS(1, state: .known, box: 5, dueAt: at(days: 200), refresherStep: 1, stability: 210, shelfBefore: nil)
        // Answered by Leitner after FSRS: the memory is behind.
        var stale = answeredByFSRS(2, state: .known, box: 5, dueAt: at(days: 200), refresherStep: 1, stability: 210)
        stale.reviews += 1
        // A pending "Biliyorum" check, days after FSRS's last answer: its check date stays.
        let claimed = Leitner.markKnown(scheduler.review(WordProgress(wordID: 3), grade: .good, at: start), at: at(days: 40))
        XCTAssertTrue(claimed.awaitsKnownCheck)
        XCTAssertEqual(claimed.dueAt, at(days: 43))
        // Sent back to "Tanış" by FSRS: no due date.
        let backToIntro = scheduler.review(Leitner.markKnown(WordProgress(wordID: 4), at: start), grade: .again, at: at(days: 3))
        XCTAssertTrue(backToIntro.returnsToIntro)
        XCTAssertNotNil(backToIntro.fsrs)
        // Never answered by FSRS.
        var leitner = WordProgress(wordID: 5)
        leitner = Leitner.review(leitner, grade: .good, at: start)
        let progress = [1: migrated, 2: stale, 3: claimed, 4: backToIntro, 5: leitner]
        XCTAssertEqual(FSRSMigration.handBack(progress), progress)
        XCTAssertEqual(FSRSMigration.handBack([:]), [:])
    }

    func testHandingBackTwiceIsHandingBackOnce() {
        var progress = makeFixture().progress
        progress[20] = answeredByFSRS(20, state: .known, box: 5, dueAt: at(days: 200), refresherStep: 2, stability: 300)
        progress[21] = scheduler.review(WordProgress(wordID: 21), grade: .good, at: start)
        let once = FSRSMigration.handBack(progress)
        XCTAssertNotEqual(once, progress)
        XCTAssertEqual(FSRSMigration.handBack(once), once)
        XCTAssertEqual(once[20]?.dueAt, at(days: 120))
        XCTAssertEqual(once[21]?.dueAt, at(days: 1))
        // FSRS's "Bildim" on the 3rd day (due on the 5th): Leitner's 1 day.
        XCTAssertEqual(once[W.upToDate]?.dueAt, at(days: 4))
        // The words Leitner answered last are untouched.
        for id in W.all where id != W.upToDate {
            XCTAssertEqual(once[id], progress[id], "word \(id)")
        }
    }

    func testLeitnerGoesOnAfterHandBack() throws {
        let known = answeredByFSRS(1, state: .known, box: 5, dueAt: at(days: 200), refresherStep: 1, stability: 210)
        let firstGood = scheduler.review(WordProgress(wordID: 2), grade: .good, at: start)
        let handedBack = FSRSMigration.handBack([1: known, 2: firstGood])

        // The known word: its refresher on step 1's date, then step 2's wait.
        let refresherDay = at(days: 60)
        let knownBack = try XCTUnwrap(handedBack[1])
        XCTAssertEqual(knownBack.dueAt, refresherDay)
        let refreshed = Leitner.review(knownBack, grade: .good, at: refresherDay)
        XCTAssertEqual(refreshed.state, .known)
        XCTAssertEqual(refreshed.box, 5)
        XCTAssertEqual(refreshed.refresherStep, 2)
        XCTAssertEqual(refreshed.dueAt, refresherDay.addingTimeInterval(Leitner.refresherWait(step: 2)))
        XCTAssertEqual(refreshed.fsrs, known.fsrs)
        XCTAssertNotEqual(refreshed.fsrs?.reviews, refreshed.reviews)

        // The learning word: due tomorrow as with Leitner, then basamak 2.
        let tomorrow = at(days: 1)
        let word = try XCTUnwrap(handedBack[2])
        XCTAssertEqual(word.dueAt, tomorrow)
        let next = LeitnerScheduler().review(word, grade: .good, at: tomorrow)
        XCTAssertEqual(next, Leitner.review(word, grade: .good, at: tomorrow))
        XCTAssertEqual(next.state, .learning)
        XCTAssertEqual(next.box, 2)
        XCTAssertEqual(next.dueAt, tomorrow.addingTimeInterval(2 * day))

        // A Leitner answer makes the memory stale: a second handBack leaves the word alone.
        XCTAssertEqual(FSRSMigration.handBack([2: next]), [2: next])
    }

    // MARK: The file

    /// `WordProgress` as a build before FSRS knew it.
    private struct EarlierWordProgress: Codable, Equatable {
        let wordID: Int
        let state: String
        let box: Int
        let dueAt: Date?
        let exposures: Int
        let lastSeenAt: Date?
        let reviews: Int
        let lapses: Int
        let knownOverride: Bool
        let saved: Bool

        enum CodingKeys: String, CodingKey {
            case wordID = "word_id"
            case state
            case box
            case dueAt = "due_at"
            case exposures
            case lastSeenAt = "last_seen_at"
            case reviews
            case lapses
            case knownOverride = "known_override"
            case saved
        }
    }

    func testAnEarlierBuildIgnoresTheMemory() throws {
        let fixture = makeFixture()
        let progress = FSRSMigration.takeOver(fixture.progress, log: fixture.log, scheduler: scheduler, now: now).progress
        let list = progress.values.sorted { $0.wordID < $1.wordID }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(list)

        let rows = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        XCTAssertEqual(rows.filter { $0["fsrs"] != nil }.count, 9)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let earlier = try decoder.decode([EarlierWordProgress].self, from: data)
        XCTAssertEqual(earlier.count, list.count)
        for (old, p) in zip(earlier, list) {
            XCTAssertEqual(old.wordID, p.wordID)
            XCTAssertEqual(old.state, p.state.rawValue)
            XCTAssertEqual(old.box, p.box)
            XCTAssertEqual(old.dueAt, p.dueAt)
            XCTAssertEqual(old.exposures, p.exposures)
            XCTAssertEqual(old.lastSeenAt, p.lastSeenAt)
            XCTAssertEqual(old.reviews, p.reviews)
            XCTAssertEqual(old.lapses, p.lapses)
            XCTAssertEqual(old.knownOverride, p.knownOverride)
            XCTAssertEqual(old.saved, p.saved)
        }
        // This build reads its own file back whole.
        XCTAssertEqual(try decoder.decode([WordProgress].self, from: data), list)
    }

    func testProgressStoreKeepsTheMemory() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("FSRSMigrationTests-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))

        let fixture = makeFixture()
        let progress = FSRSMigration.takeOver(fixture.progress, log: fixture.log, scheduler: scheduler, now: now).progress
        try store.save(progress, now: now)
        let loaded = try store.load(now: now)
        XCTAssertEqual(loaded.outcome, .loaded)
        XCTAssertEqual(loaded.progress, progress)
        for id in W.replayed + W.estimated + [W.upToDate] {
            XCTAssertNotNil(loaded.progress[id]?.fsrs, "word \(id)")
        }
        // Nothing left to rebuild after loading.
        XCTAssertEqual(FSRSMigration.outdatedCount(loaded.progress), 0)
        let again = FSRSMigration.takeOver(loaded.progress, log: fixture.log, scheduler: scheduler, now: now)
        XCTAssertEqual(again.progress, progress)
    }
}
