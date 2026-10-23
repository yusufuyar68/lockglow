import XCTest
import CoreModels
import Learning

/// The readers of `WordProgress` with progress that `FSRSScheduler` wrote (fsrs.md 4.3 step 2):
/// `ProgressIngest`, `ReviewPlanner` ("Tekrar"), `QueueComposer`, `ReminderPlanner` and
/// `ProgressSummary` read the same Leitner-style fields, so FSRS's waits and steps reach them
/// without any change of their own.
///
/// Dates are October 2026, UTC: Monday 12 starts the week of most summaries.
final class FSRSConsumersTests: XCTestCase {
    private let minute: TimeInterval = 60
    private let hour: TimeInterval = 3600
    private let day: TimeInterval = 86_400
    private let fsrs = FSRSScheduler()
    private let grades: [ReviewGrade] = [.again, .hard, .good, .easy]

    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func date(month: Int = 10, day: Int, hour: Int, minute: Int = 0) -> Date {
        return utc.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
    }

    /// Letters instead of digits ("w12" would be "wbc"), as in `ReminderPlannerTests`.
    private func name(_ id: Int) -> String {
        let letters = Array("abcdefghij")
        return "w" + String(String(id).map { letters[Int(String($0))!] })
    }

    private func word(_ id: Int) -> WidgetWord {
        let lemma = name(id)
        return WidgetWord(
            id: id, lemma: lemma, pos: "n", level: "A1", defMicro: "m", defShort: "s",
            exampleEN: "I like the \(lemma) a lot.", glossTR: "anlam \(lemma)"
        )
    }

    private func feed(_ ids: ClosedRange<Int>) -> [WidgetWord] {
        return ids.map { word($0) }
    }

    private func ids(_ list: [WidgetWord]) -> [Int] {
        return list.map { $0.id }
    }

    /// A new word answered by FSRS with `answers`, in order.
    private func answered(_ id: Int, _ answers: [(ReviewGrade, Date)]) -> WordProgress {
        return answers.reduce(WordProgress(wordID: id)) { p, answer in
            fsrs.review(p, grade: answer.0, at: answer.1)
        }
    }

    /// "Bildim", then "Bildim" on its due date 2 days later: basamak 4 (stability about 10.8).
    private func onStep4(_ id: Int, from first: Date) -> WordProgress {
        return answered(id, [(.good, first), (.good, first.addingTimeInterval(2 * day))])
    }

    /// A word taken through right FSRS answers, each on its due date, until it is known.
    private func graduated(_ id: Int, from first: Date) throws -> (progress: WordProgress, lastAnswer: Date) {
        var at = first
        var p = fsrs.review(WordProgress(wordID: id), grade: .good, at: at)
        var answers = 0
        while p.state != .known && answers < 20 {
            at = try XCTUnwrap(p.dueAt)
            p = fsrs.review(p, grade: .good, at: at)
            answers += 1
        }
        XCTAssertEqual(p.state, .known)
        XCTAssertFalse(p.knownOverride)
        return (p, at)
    }

    // MARK: ProgressIngest: the widget's "Bilmiyorum"

    func testWidgetUnknownIsAnFSRSAnswer() throws {
        let at = date(day: 12, hour: 9)
        let events = [LearningEvent(type: .unknown, wordID: 1, at: at)]
        let result = ProgressIngest.applyLogged(events, to: [:], scheduler: fsrs)
        let p = try XCTUnwrap(result.progress[1])
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.box, 1)
        XCTAssertEqual(p.reviews, 1)
        XCTAssertEqual(p.lapses, 0)
        XCTAssertEqual(p.lastGrade, .again)
        XCTAssertEqual(p.lastReviewedAt, at)
        XCTAssertEqual(p.dueAt, at.addingTimeInterval(10 * minute))
        let state = try XCTUnwrap(p.fsrs)
        XCTAssertEqual(state.reviews, 1)
        XCTAssertEqual(state.phase, .learning)
        XCTAssertEqual(state.step, 0)
        XCTAssertEqual(state.stability, fsrs.fsrs.initialMemory(.again).stability)
        XCTAssertEqual(state.lastReviewAt, at)
        XCTAssertEqual(state.shelfBefore, 0)
        XCTAssertEqual(p, fsrs.review(WordProgress(wordID: 1), grade: .again, at: at))
        XCTAssertEqual(result.answers, [ReviewLogEntry(wordID: 1, at: at, grade: .again, source: .widget, reviews: 1)])
        XCTAssertEqual(ProgressIngest.apply(events, to: [:], scheduler: fsrs), result.progress)

        // Without a scheduler: Leitner, as before FSRS.
        let leitner = ProgressIngest.applyLogged(events, to: [:])
        XCTAssertEqual(leitner.progress[1], Leitner.review(WordProgress(wordID: 1), grade: .again, at: at))
        XCTAssertNil(leitner.progress[1]?.fsrs)
        XCTAssertEqual(leitner.answers, result.answers)
        XCTAssertEqual(ProgressIngest.apply(events, to: [:]), leitner.progress)
    }

    func testWidgetUnknownOnAnFSRSStep() throws {
        let start = onStep4(1, from: date(day: 10, hour: 9))
        XCTAssertEqual(start.box, 4)
        let at = date(day: 14, hour: 9)
        let events = [LearningEvent(type: .unknown, wordID: 1, at: at)]

        let withFSRS = ProgressIngest.applyLogged(events, to: [1: start], scheduler: fsrs)
        let p = try XCTUnwrap(withFSRS.progress[1])
        XCTAssertEqual(p, fsrs.review(start, grade: .again, at: at))
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.lapses, 1)
        XCTAssertGreaterThanOrEqual(p.box, 1)
        XCTAssertLessThanOrEqual(p.box, start.box) // "Bilemedim" never raises the step
        XCTAssertEqual(p.dueAt, at.addingTimeInterval(10 * minute))
        XCTAssertEqual(p.fsrs?.phase, .relearning)
        XCTAssertEqual(p.fsrs?.reviews, 3)
        XCTAssertEqual(withFSRS.answers.count, 1)
        XCTAssertEqual(withFSRS.answers.first?.reviews, 3)
        XCTAssertEqual(withFSRS.answers.first?.source, .widget)

        // Leitner from the same word: two boxes down, FSRS's memory left as it was.
        let withLeitner = try XCTUnwrap(ProgressIngest.apply(events, to: [1: start])[1])
        XCTAssertEqual(withLeitner, Leitner.review(start, grade: .again, at: at))
        XCTAssertEqual(withLeitner.box, 2)
        XCTAssertEqual(withLeitner.fsrs, start.fsrs)
    }

    func testKnownAndSeenEventsAreTheSameWithFSRS() throws {
        let one = answered(1, [(.good, date(day: 10, hour: 9))])
        let two = answered(2, [(.again, date(day: 12, hour: 8))])
        let progress = [1: one, 2: two]
        let events = [
            LearningEvent(type: .next, wordID: 1, at: date(day: 12, hour: 10)),
            LearningEvent(type: .reveal, wordID: 1, at: date(day: 12, hour: 10, minute: 1)),
            LearningEvent(type: .known, wordID: 2, at: date(day: 12, hour: 10, minute: 2)),
            LearningEvent(type: .next, wordID: 3, at: date(day: 12, hour: 10, minute: 3)),
        ]
        let withFSRS = ProgressIngest.applyLogged(events, to: progress, scheduler: fsrs)
        let withLeitner = ProgressIngest.applyLogged(events, to: progress)
        XCTAssertEqual(withFSRS.progress, withLeitner.progress)
        XCTAssertTrue(withFSRS.answers.isEmpty)
        XCTAssertTrue(withLeitner.answers.isEmpty)

        let seen = try XCTUnwrap(withFSRS.progress[1])
        XCTAssertEqual(seen.exposures, 2)
        XCTAssertEqual(seen.reviews, 1)
        XCTAssertEqual(seen.dueAt, one.dueAt)
        XCTAssertEqual(seen.fsrs, one.fsrs)

        let claimed = try XCTUnwrap(withFSRS.progress[2])
        XCTAssertTrue(claimed.awaitsKnownCheck)
        XCTAssertEqual(claimed.dueAt, date(day: 12, hour: 10, minute: 2).addingTimeInterval(3 * day))
        XCTAssertEqual(claimed.box, two.box)
        XCTAssertEqual(claimed.fsrs, two.fsrs)

        XCTAssertEqual(withFSRS.progress[3]?.exposures, 1)
        XCTAssertNil(withFSRS.progress[3]?.fsrs)
    }

    // MARK: ReviewPlanner ("Tekrar")

    func testFirstBildimIsDueInTwoDaysNotTomorrow() {
        let answeredAt = date(day: 12, hour: 9)
        let p = fsrs.review(WordProgress(wordID: 1), grade: .good, at: answeredAt)
        let leitner = Leitner.review(WordProgress(wordID: 1), grade: .good, at: answeredAt)
        XCTAssertEqual(p.dueAt, date(day: 14, hour: 9))
        XCTAssertEqual(leitner.dueAt, date(day: 13, hour: 9))

        let tomorrow = date(day: 13, hour: 12)
        XCTAssertEqual(ids(ReviewPlanner.dueWords(feed: feed(1...1), progress: [1: p], now: tomorrow, limit: 10)), [])
        XCTAssertEqual(ids(ReviewPlanner.dueWords(feed: feed(1...1), progress: [1: leitner], now: tomorrow, limit: 10)), [1])
        XCTAssertEqual(ids(ReviewPlanner.dueWords(feed: feed(1...1), progress: [1: p], now: date(day: 14, hour: 9), limit: 10)), [1])

        let endOfTomorrow = date(day: 14, hour: 0)
        XCTAssertEqual(ReviewPlanner.counts(feed: feed(1...1), progress: [1: p], dueBy: endOfTomorrow), ProgressCounts(learning: 1, dueToday: 0))
        XCTAssertEqual(ReviewPlanner.counts(feed: feed(1...1), progress: [1: leitner], dueBy: endOfTomorrow), ProgressCounts(learning: 1, dueToday: 1))
        XCTAssertEqual(ReviewPlanner.counts(feed: feed(1...1), progress: [1: p], dueBy: date(day: 15, hour: 0)), ProgressCounts(learning: 1, dueToday: 1))
    }

    func testDueWordsWithFSRSWaits() {
        // 1: "Bildim" on the 12th (due the 14th). 2: "Bilemedim" at 11:00 (due 11:10).
        // 3: "Kolay" on the 12th (due the 20th). 4: "Zor" at 11:30 (due 11:45).
        let progress = [
            1: answered(1, [(.good, date(day: 12, hour: 9))]),
            2: answered(2, [(.again, date(day: 13, hour: 11))]),
            3: answered(3, [(.easy, date(day: 12, hour: 9))]),
            4: answered(4, [(.hard, date(day: 13, hour: 11, minute: 30))]),
        ]
        XCTAssertEqual(progress[3]?.dueAt, date(day: 20, hour: 9))
        XCTAssertEqual(progress[4]?.dueAt, date(day: 13, hour: 11, minute: 45))
        let now = date(day: 13, hour: 12)
        XCTAssertEqual(ids(ReviewPlanner.dueWords(feed: feed(1...4), progress: progress, now: now, limit: 10)), [2, 4])
        XCTAssertEqual(
            ReviewPlanner.counts(feed: feed(1...4), progress: progress, dueBy: date(day: 14, hour: 0)),
            ProgressCounts(learning: 4, dueToday: 2)
        )
    }

    func testEveryFirstAnswerIsAskedWithTheClozeNextTime() throws {
        let at = date(day: 12, hour: 9)
        for grade in grades {
            let p = fsrs.review(WordProgress(wordID: 1), grade: grade, at: at)
            XCTAssertEqual(p.box, 1, "\(grade)")
            XCTAssertEqual(ReviewPlanner.questionKind(for: p, hasCloze: true), .cloze, "\(grade)")
            let due = try XCTUnwrap(p.dueAt, "\(grade)")
            XCTAssertEqual(ids(ReviewPlanner.dueWords(feed: feed(1...1), progress: [1: p], now: due, limit: 1)), [1], "\(grade)")
        }
        // "Kolay" waits 8 days, and still comes back with the written question.
        let easy = fsrs.review(WordProgress(wordID: 1), grade: .easy, at: at)
        XCTAssertEqual(easy.dueAt, at.addingTimeInterval(8 * day))
        XCTAssertEqual(ReviewPlanner.questionKind(for: easy, hasCloze: true), .cloze)
        XCTAssertEqual(ReviewPlanner.questionKind(for: easy, hasCloze: false), .recall)
    }

    func testAWordFSRSPutOnStep4IsRecalled() {
        let first = answered(1, [(.good, date(day: 10, hour: 9))])
        XCTAssertEqual(ReviewPlanner.questionKind(for: first, hasCloze: true), .cloze)
        let p = onStep4(1, from: date(day: 10, hour: 9))
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.box, 4)
        XCTAssertGreaterThanOrEqual(p.box, ReviewPlanner.recallFromBox)
        XCTAssertEqual(ReviewPlanner.questionKind(for: p, hasCloze: true), .recall)
    }

    func testAWordFSRSKnowsIsRecalled() throws {
        let (p, _) = try graduated(1, from: date(day: 1, hour: 9))
        XCTAssertEqual(p.box, Leitner.maxBox)
        XCTAssertEqual(ReviewPlanner.questionKind(for: p, hasCloze: true), .recall)
        let due = try XCTUnwrap(p.dueAt)
        XCTAssertEqual(ids(ReviewPlanner.dueWords(feed: feed(1...1), progress: [1: p], now: due, limit: 1)), [1])
        XCTAssertEqual(ReviewPlanner.counts(feed: feed(1...1), progress: [1: p], dueBy: due.addingTimeInterval(-1)), ProgressCounts(known: 1))

        // A "Biliyorum" that FSRS checked: known, asked with the recall screen from then on.
        let claimed = Leitner.markKnown(WordProgress(wordID: 2), at: date(day: 9, hour: 9))
        let checked = fsrs.review(claimed, grade: .good, at: date(day: 12, hour: 9))
        XCTAssertEqual(checked.state, .known)
        XCTAssertFalse(checked.knownOverride)
        XCTAssertEqual(ReviewPlanner.questionKind(for: checked, hasCloze: true), .recall)
    }

    // MARK: QueueComposer (the widget)

    func testAWordFSRSAnsweredTodayIsReinforcement() throws {
        let now = date(day: 14, hour: 15)
        // 1: "Zor" 1 h ago: due again 15 min later, so already due, but answered today.
        // 2: "Bildim" 2 h ago. 3: "Zor" yesterday at 22:00: overdue, not answered today (hidden).
        let progress = [
            1: answered(1, [(.hard, now.addingTimeInterval(-1 * hour))]),
            2: answered(2, [(.good, now.addingTimeInterval(-2 * hour))]),
            3: answered(3, [(.hard, date(day: 13, hour: 22))]),
        ]
        XCTAssertLessThan(try XCTUnwrap(progress[1]?.dueAt), now)
        let queue = QueueComposer.compose(feed: feed(1...3), progress: progress, now: now, horizon: 2 * day, maxNew: 0, limit: 10, calendar: utc)
        XCTAssertEqual(ids(queue), [2, 1])
    }

    func testAWordFSRSMissedTodayGoesToTheFreeSlot() {
        let now = date(day: 14, hour: 15)
        var progress: [Int: WordProgress] = [:]
        for (id, hoursAgo) in [(11, 4.0), (12, 3.0), (13, 2.0), (14, 1.0)] {
            progress[id] = answered(id, [(.good, now.addingTimeInterval(-hoursAgo * hour))])
        }
        progress[15] = answered(15, [(.again, now.addingTimeInterval(-30 * minute))])
        var refresher = WordProgress(wordID: 20)
        refresher.state = .known
        refresher.box = 5
        refresher.dueAt = now.addingTimeInterval(12 * hour)
        progress[20] = refresher
        // N→1, L→11, R→20, L→12, N→2, L→13, F→15 (missed today), L→14, N→3, then nothing left.
        let queue = QueueComposer.compose(
            feed: feed(1...3) + feed(11...15) + feed(20...20),
            progress: progress,
            now: now,
            horizon: 2 * day,
            maxNew: 3,
            limit: 20,
            calendar: utc
        )
        XCTAssertEqual(ids(queue), [1, 11, 20, 12, 2, 13, 15, 14, 3])
        XCTAssertEqual(QueueComposer.pattern[6], .free)
    }

    func testAWordFSRSKnowsFillsTheRefresherSlot() throws {
        let (known, _) = try graduated(1, from: date(day: 1, hour: 9))
        let due = try XCTUnwrap(known.dueAt)
        let now = due.addingTimeInterval(-1 * day)
        // N→2, L→(no learning word) 3, R→1.
        let queue = QueueComposer.compose(feed: feed(1...3), progress: [1: known], now: now, horizon: 2 * day, maxNew: 2, limit: 10, calendar: utc)
        XCTAssertEqual(ids(queue), [2, 3, 1])
        // Beyond the horizon: not on the widget.
        let later = QueueComposer.compose(feed: feed(1...3), progress: [1: known], now: now, horizon: 12 * hour, maxNew: 2, limit: 10, calendar: utc)
        XCTAssertEqual(ids(later), [2, 3])
    }

    func testAWordFSRSAsksWithinSixHoursStaysOffTheWidget() {
        let now = date(day: 14, hour: 15)
        // 1: "Bildim" on the 12th at 18:00, due today at 18:00 (in 3 h): hidden.
        // 2: "Bildim" on the 13th at 01:00, due tomorrow at 01:00 (in 10 h): on the widget.
        // 3: "Bilemedim" yesterday at 22:00, due 10 min later: overdue, hidden.
        let progress = [
            1: answered(1, [(.good, date(day: 12, hour: 18))]),
            2: answered(2, [(.good, date(day: 13, hour: 1))]),
            3: answered(3, [(.again, date(day: 13, hour: 22))]),
        ]
        XCTAssertEqual(progress[1]?.dueAt, now.addingTimeInterval(3 * hour))
        XCTAssertEqual(progress[2]?.dueAt, now.addingTimeInterval(10 * hour))
        let queue = QueueComposer.compose(feed: feed(1...3), progress: progress, now: now, horizon: 2 * day, maxNew: 0, limit: 10, calendar: utc)
        XCTAssertEqual(ids(queue), [2])
    }

    // MARK: ReminderPlanner

    private func plan(_ progress: [Int: WordProgress], feed: [WidgetWord], now: Date, days: Int) -> [Reminder] {
        return ReminderPlanner.plan(
            feed: feed,
            progress: progress,
            now: now,
            minuteOfDay: 20 * 60,
            days: days,
            dailyNewGoal: 5,
            newStudiedToday: 0,
            calendar: utc
        )
    }

    func testTomorrowsReminderMayNameAWordWhoseFirstBildimWaitsTwoDays() {
        let answeredAt = date(day: 12, hour: 9)
        let now = date(day: 12, hour: 21)
        // Words 2-6 are the next round's new words; word 1 is the only one to name.

        // Leitner: due tomorrow at 9:00, before tomorrow's reminder. Not its word.
        let leitner = Leitner.review(WordProgress(wordID: 1), grade: .good, at: answeredAt)
        let withLeitner = plan([1: leitner], feed: feed(1...6), now: now, days: 2).first
        XCTAssertEqual(withLeitner?.fireDate, date(day: 13, hour: 20))
        XCTAssertEqual(withLeitner?.dueCount, 1)
        XCTAssertNil(withLeitner?.wordID)
        XCTAssertEqual(withLeitner?.kind, .plain)

        // FSRS: due on the 14th at 9:00, after the quiet window of tomorrow's reminder.
        let withFSRS = plan([1: fsrs.review(WordProgress(wordID: 1), grade: .good, at: answeredAt)], feed: feed(1...6), now: now, days: 2).first
        XCTAssertEqual(withFSRS?.fireDate, date(day: 13, hour: 20))
        XCTAssertEqual(withFSRS?.dueCount, 0)
        XCTAssertEqual(withFSRS?.newCount, 5)
        XCTAssertEqual(withFSRS?.wordID, 1)
        XCTAssertEqual(withFSRS?.kind, .meaning)
        XCTAssertEqual(withFSRS?.title, "\(name(1)) = anlam \(name(1))")
    }

    func testNeverNamesAWordFSRSAsksWithinTheQuietWindow() throws {
        // 1: due on the 14th at 9:00. 2: "Bildim" on the 11th at 23:00, due on the 13th at 23:00
        // (3 h after tomorrow's reminder). 3: "Bilemedim" at 19:00, due 10 min later.
        let progress = [
            1: answered(1, [(.good, date(day: 12, hour: 9))]),
            2: answered(2, [(.good, date(day: 11, hour: 23))]),
            3: answered(3, [(.again, date(day: 12, hour: 19))]),
        ]
        XCTAssertEqual(progress[2]?.dueAt, date(day: 13, hour: 23))
        let reminders = plan(progress, feed: feed(1...8), now: date(day: 12, hour: 21), days: 3)
        XCTAssertEqual(reminders.first?.fireDate, date(day: 13, hour: 20))
        XCTAssertEqual(reminders.first?.dueCount, 1)
        XCTAssertEqual(reminders.first?.wordID, 1)
        for reminder in reminders {
            guard let id = reminder.wordID else {
                continue
            }
            let due = try XCTUnwrap(progress[id]?.dueAt, "\(reminder.fireDate)")
            XCTAssertGreaterThan(due, reminder.fireDate.addingTimeInterval(ReminderPlanner.quietWindow), "\(reminder.fireDate)")
        }
        XCTAssertFalse(reminders.contains { $0.wordID == 2 || $0.wordID == 3 })
    }

    // MARK: ProgressSummary ("İlerleme")

    private func summary(_ progress: [Int: WordProgress]) -> ProgressSummary {
        return ProgressSummary.make(progress: progress, now: date(day: 16, hour: 12), calendar: utc)
    }

    func testAnFSRSRightAnswerCountsAsAMoveOnlyWhenItClimbsAStep() {
        // 1: basamak 4 on the 12th at 9:00, then "Bildim" again at 15:00: same stability, same step.
        // 2: basamak 1 → 4 with its second answer on the 12th.
        let first = date(day: 10, hour: 9)
        let climbed = onStep4(2, from: first)
        let stayed = fsrs.review(onStep4(1, from: first), grade: .good, at: date(day: 12, hour: 15))
        XCTAssertEqual(stayed.box, 4)
        XCTAssertEqual(stayed.fsrs?.shelfBefore, ProgressSummary.Shelf.box4.rawValue)
        XCTAssertEqual(climbed.fsrs?.shelfBefore, ProgressSummary.Shelf.box1.rawValue)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: stayed)?.kind, .stayed)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: climbed)?.kind, .movedUp)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: climbed)?.date, date(day: 12, hour: 9))

        let week = summary([1: stayed, 2: climbed]).thisWeek
        XCTAssertEqual(week.movedUpWordIDs, [2])
        XCTAssertTrue(week.recalledAfterLongGapWordIDs.isEmpty)
    }

    func testAnFSRSJumpFromStep3ToYerlestiIsAMoveUp() throws {
        var p = WordProgress(wordID: 3)
        p.state = .learning
        p.box = 3
        p.reviews = 3
        p.firstReviewedAt = date(month: 9, day: 1, hour: 9)
        p.lastReviewedAt = date(month: 9, day: 23, hour: 9)
        p.lastSeenAt = p.lastReviewedAt
        p.lastGrade = .good
        p.dueAt = date(month: 9, day: 28, hour: 9)
        p.fsrs = FSRSState(
            stability: 5,
            difficulty: 2,
            phase: .review,
            step: nil,
            lastReviewAt: date(month: 9, day: 23, hour: 9),
            reviews: 3,
            shelfBefore: ProgressSummary.Shelf.box2.rawValue
        )
        // "Kolay" 20 days later: the stability passes 30 days.
        let jumped = fsrs.review(p, grade: .easy, at: date(day: 13, hour: 9))
        XCTAssertEqual(jumped.state, .known)
        XCTAssertEqual(jumped.box, Leitner.maxBox)
        XCTAssertGreaterThanOrEqual(try XCTUnwrap(jumped.fsrs?.stability), FSRSScheduler.knownStability)
        XCTAssertEqual(jumped.fsrs?.shelfBefore, ProgressSummary.Shelf.box3.rawValue)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: jumped)?.kind, .movedUp)

        let week = summary([3: jumped]).thisWeek
        XCTAssertEqual(week.movedUpWordIDs, [3])
        XCTAssertTrue(week.recalledAfterLongGapWordIDs.isEmpty)
    }

    func testAnFSRSRefresherOnTheTopStepIsALongGapRecall() {
        var p = WordProgress(wordID: 4)
        p.state = .known
        p.box = 5
        p.reviews = 6
        p.firstReviewedAt = date(month: 8, day: 1, hour: 9)
        p.lastReviewedAt = date(month: 9, day: 10, hour: 9)
        p.lastSeenAt = p.lastReviewedAt
        p.lastGrade = .good
        p.dueAt = date(day: 13, hour: 9)
        p.fsrs = FSRSState(
            stability: 33,
            difficulty: 3,
            phase: .review,
            step: nil,
            lastReviewAt: date(month: 9, day: 10, hour: 9),
            reviews: 6,
            shelfBefore: ProgressSummary.Shelf.box5.rawValue
        )
        let refreshed = fsrs.review(p, grade: .good, at: date(day: 13, hour: 9))
        XCTAssertEqual(refreshed.state, .known)
        XCTAssertEqual(refreshed.box, 5)
        XCTAssertEqual(refreshed.fsrs?.shelfBefore, ProgressSummary.Shelf.settled.rawValue)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: refreshed)?.kind, .recalledOnTop)

        let week = summary([4: refreshed]).thisWeek
        XCTAssertEqual(week.recalledAfterLongGapWordIDs, [4])
        XCTAssertTrue(week.movedUpWordIDs.isEmpty)
    }

    func testAnFSRSBiliyorumCheckOfANewWordIsNoLongGapRecall() {
        let claimed = Leitner.markKnown(WordProgress(wordID: 5), at: date(day: 10, hour: 9))
        let checked = fsrs.review(claimed, grade: .good, at: date(day: 13, hour: 9))
        XCTAssertEqual(checked.state, .known)
        XCTAssertFalse(checked.knownOverride)
        XCTAssertEqual(checked.box, 0)
        XCTAssertEqual(ProgressSummary.Shelf.of(checked), .settled)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: checked)?.kind, .recalledOnTop)

        let week = summary([5: checked]).thisWeek
        XCTAssertTrue(week.recalledAfterLongGapWordIDs.isEmpty)
        XCTAssertTrue(week.movedUpWordIDs.isEmpty)
        XCTAssertEqual(week.metWordIDs, [5])
    }

    func testAnFSRSBilemedimIsNeitherAMoveNorARecall() {
        let forgot = fsrs.review(onStep4(6, from: date(day: 10, hour: 9)), grade: .again, at: date(day: 14, hour: 9))
        XCTAssertEqual(forgot.state, .learning)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: forgot)?.kind, .forgot)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: forgot)?.date, date(day: 14, hour: 9))

        let week = summary([6: forgot]).thisWeek
        XCTAssertTrue(week.movedUpWordIDs.isEmpty)
        XCTAssertTrue(week.recalledAfterLongGapWordIDs.isEmpty)
    }

    func testALeitnerAnswerAfterFSRSIsReadAsLeitner() {
        // Basamak 4 by FSRS, an FSRS "Bildim" that stayed, then a Leitner "Bildim": box 5.
        let stayed = fsrs.review(onStep4(7, from: date(day: 10, hour: 9)), grade: .good, at: date(day: 12, hour: 15))
        XCTAssertEqual(ProgressSummary.lastAnswer(of: stayed)?.kind, .stayed)
        let leitner = LeitnerScheduler().review(stayed, grade: .good, at: date(day: 14, hour: 9))
        XCTAssertEqual(leitner.box, 5)
        XCTAssertEqual(leitner.fsrs, stayed.fsrs) // Leitner leaves the memory; its count is now behind
        XCTAssertNil(FSRSScheduler.lastAnswer(of: leitner))
        XCTAssertEqual(ProgressSummary.lastAnswer(of: leitner)?.kind, .movedUp)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: leitner)?.date, date(day: 14, hour: 9))

        let hard = LeitnerScheduler().review(stayed, grade: .hard, at: date(day: 14, hour: 9))
        XCTAssertEqual(ProgressSummary.lastAnswer(of: hard)?.kind, .stayed)

        let week = summary([7: leitner]).thisWeek
        XCTAssertEqual(week.movedUpWordIDs, [7])
    }

    func testLastAnswerOfLeitnerOnlyProgressIsTheExactGradeReading() {
        let climb: [(ReviewGrade, Date)] = [(.good, date(day: 10, hour: 9)), (.good, date(day: 11, hour: 9))]
        let onBox2 = climb.reduce(WordProgress(wordID: 1)) { p, answer in
            Leitner.review(p, grade: answer.0, at: answer.1)
        }
        XCTAssertEqual(onBox2.box, 2)
        let at = date(day: 13, hour: 9)
        let expected: [ReviewGrade: ProgressSummary.LastAnswer.Kind] = [
            .again: .forgot, .hard: .stayed, .good: .movedUp, .easy: .movedUp,
        ]
        for grade in grades {
            for start in [WordProgress(wordID: 1), onBox2] {
                let p = Leitner.review(start, grade: grade, at: at)
                let label = "\(grade) from box \(start.box)"
                XCTAssertNil(p.fsrs, label)
                XCTAssertNil(FSRSScheduler.lastAnswer(of: p), label)
                XCTAssertEqual(ProgressSummary.lastAnswer(of: p)?.kind, expected[grade], label)
                XCTAssertEqual(ProgressSummary.lastAnswer(of: p)?.date, at, label)
            }
        }

        // A known word: a right refresher is on the top step; a wrong one leaves it learning.
        var known = WordProgress(wordID: 2)
        known.state = .known
        known.box = 5
        known.reviews = 6
        known.dueAt = at
        known.lastReviewedAt = date(month: 9, day: 13, hour: 9)
        known.lastGrade = .good
        XCTAssertEqual(ProgressSummary.lastAnswer(of: Leitner.review(known, grade: .good, at: at))?.kind, .recalledOnTop)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: Leitner.review(known, grade: .again, at: at))?.kind, .forgot)
        XCTAssertNil(ProgressSummary.lastAnswer(of: Leitner.markKnown(WordProgress(wordID: 3), at: at)))

        // Answered before the answer time was recorded: read from the gap, as before.
        var legacy = Leitner.review(onBox2, grade: .good, at: at)
        legacy.lastReviewedAt = nil
        legacy.lastGrade = nil
        XCTAssertEqual(ProgressSummary.lastAnswer(of: legacy)?.kind, .movedUp)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: legacy)?.date, at)
    }
}
