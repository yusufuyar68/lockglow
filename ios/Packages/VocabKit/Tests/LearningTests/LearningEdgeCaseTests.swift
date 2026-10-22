import XCTest
import CoreModels
import Learning

/// Known edge cases of the learning engine: time zones, daylight saving time, two answers on one
/// day, and a wrong answer while a "Biliyorum" check waits.
///
/// Waits are whole multiples of 24 hours (`Leitner`, `FSRS`), so a clock change moves a due time
/// by an hour on the clock. "Today" and the weeks follow the calendar the caller passes
/// (`QueueComposer`, `ProgressSummary`).
final class LearningEdgeCaseTests: XCTestCase {
    private let minute: TimeInterval = 60
    private let hour: TimeInterval = 3600
    private let day: TimeInterval = 86_400

    private func calendar(_ zone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        return calendar
    }

    private func berlinCalendar() throws -> Calendar {
        return calendar(try XCTUnwrap(TimeZone(identifier: "Europe/Berlin")))
    }

    private var utc: Calendar {
        return calendar(TimeZone(secondsFromGMT: 0)!)
    }

    private func date(_ calendar: Calendar, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        return calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
    }

    private func words(_ ids: ClosedRange<Int>) -> [WidgetWord] {
        return ids.map { id in
            WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: "A2", defMicro: "m", defShort: "s", exampleEN: "e")
        }
    }

    private func queue(_ progress: [Int: WordProgress], ids: ClosedRange<Int>, now: Date, calendar: Calendar, maxNew: Int = 0, patternOffset: Int = 0) -> [Int] {
        return QueueComposer.compose(
            feed: words(ids), progress: progress, now: now, horizon: 2 * day, maxNew: maxNew, limit: 10,
            calendar: calendar, patternOffset: patternOffset
        ).map { $0.id }
    }

    // MARK: Daylight saving time

    func testAWaitIsWholeDaysOfTwentyFourHoursAcrossAClockChange() throws {
        let berlin = try berlinCalendar()
        // Clocks go forward on Sunday 29 March 2026 (02:00 → 03:00) and back on Sunday 25
        // October (03:00 → 02:00).
        XCTAssertEqual(berlin.timeZone.secondsFromGMT(for: date(berlin, 3, 28, 12)), 3600)
        XCTAssertEqual(berlin.timeZone.secondsFromGMT(for: date(berlin, 3, 29, 12)), 7200)

        // "Bildim" at 09:00 on Saturday: due 24 hours later, at 10:00 by Sunday's clock.
        let saturday = date(berlin, 3, 28, 9)
        let p = Leitner.review(WordProgress(wordID: 1), grade: .good, at: saturday)
        let due = try XCTUnwrap(p.dueAt)
        XCTAssertEqual(due.timeIntervalSince(saturday), day)
        XCTAssertEqual(berlin.component(.hour, from: due), 10)
        let feed = words(1...1)
        XCTAssertTrue(ReviewPlanner.dueWords(feed: feed, progress: [1: p], now: date(berlin, 3, 29, 9, 30), limit: 5).isEmpty)
        XCTAssertEqual(ReviewPlanner.dueWords(feed: feed, progress: [1: p], now: date(berlin, 3, 29, 10), limit: 5).map { $0.id }, [1])
        // The day's count has it from the morning on.
        let endOfSunday = try XCTUnwrap(berlin.date(byAdding: .day, value: 1, to: berlin.startOfDay(for: due)))
        XCTAssertEqual(ReviewPlanner.counts(feed: feed, progress: [1: p], dueBy: endOfSunday).dueToday, 1)

        // In autumn the clock goes back: due at 08:00 by the clock.
        let autumn = Leitner.review(WordProgress(wordID: 2), grade: .good, at: date(berlin, 10, 24, 9))
        XCTAssertEqual(berlin.component(.hour, from: try XCTUnwrap(autumn.dueAt)), 8)
    }

    func testTodayFollowsTheLocalCalendarOnAClockChangeDay() throws {
        let berlin = try berlinCalendar()
        // Sunday 25 October 2026 has 25 hours in Berlin. "Bildim" at 00:30, before the clocks
        // go back; the widget plan is written at 23:30 the same day, exactly 24 hours later,
        // when the word is due again.
        let answered = date(berlin, 10, 25, 0, 30)
        let now = date(berlin, 10, 25, 23, 30)
        XCTAssertEqual(now.timeIntervalSince(answered), day)
        let progress = [1: Leitner.review(WordProgress(wordID: 1), grade: .good, at: answered)]
        // Answered today in Berlin: it may show again. In UTC the answer was yesterday (22:30 on
        // Saturday), so the due word stays hidden until "Tekrar" asks it.
        XCTAssertEqual(queue(progress, ids: 1...1, now: now, calendar: berlin), [1])
        XCTAssertEqual(queue(progress, ids: 1...1, now: now, calendar: utc), [])

        // Sunday 29 March has 23 hours: 00:30 and 23:30 are 22 hours apart, still one day.
        let springAnswer = date(berlin, 3, 29, 0, 30)
        let springNow = date(berlin, 3, 29, 23, 30)
        XCTAssertEqual(springNow.timeIntervalSince(springAnswer), 22 * hour)
        let spring = [1: Leitner.review(WordProgress(wordID: 1), grade: .again, at: springAnswer)]
        XCTAssertEqual(queue(spring, ids: 1...1, now: springNow, calendar: berlin), [1])
    }

    func testWeeksAcrossClockChanges() throws {
        let berlin = try berlinCalendar()
        // The week of the spring change is 167 hours long.
        let spring = ProgressSummary.make(
            progress: [
                1: Leitner.review(WordProgress(wordID: 1), grade: .good, at: date(berlin, 3, 23, 0, 10)),
                2: Leitner.review(WordProgress(wordID: 2), grade: .good, at: date(berlin, 3, 29, 23, 0)),
            ],
            now: date(berlin, 3, 29, 23, 30),
            calendar: berlin
        )
        XCTAssertEqual(spring.thisWeek.start, date(berlin, 3, 23, 0))
        XCTAssertEqual(spring.thisWeek.end, date(berlin, 3, 30, 0))
        XCTAssertEqual(spring.thisWeek.end.timeIntervalSince(spring.thisWeek.start), 167 * hour)
        XCTAssertEqual(spring.thisWeek.metWordIDs, [1, 2])
        XCTAssertEqual(spring.thisWeek.studyDays, 2)

        // The autumn one is 169 hours: 23:50 on its Sunday is still in it, 00:10 on Monday is not.
        let autumn = ProgressSummary.make(
            progress: [
                1: Leitner.review(WordProgress(wordID: 1), grade: .good, at: date(berlin, 10, 25, 23, 50)),
                2: Leitner.review(WordProgress(wordID: 2), grade: .good, at: date(berlin, 10, 26, 0, 10)),
            ],
            now: date(berlin, 10, 26, 0, 30),
            calendar: berlin
        )
        XCTAssertEqual(autumn.lastWeek.start, date(berlin, 10, 19, 0))
        XCTAssertEqual(autumn.lastWeek.end.timeIntervalSince(autumn.lastWeek.start), 169 * hour)
        XCTAssertEqual(autumn.lastWeek.metWordIDs, [1])
        XCTAssertEqual(autumn.thisWeek.metWordIDs, [2])
        XCTAssertEqual(autumn.lastWeek.studyDays, 1)
        XCTAssertEqual(autumn.thisWeek.studyDays, 1)
    }

    // MARK: Time zones

    func testTravellingMovesTodayWithTheClock() throws {
        let istanbul = calendar(try XCTUnwrap(TimeZone(secondsFromGMT: 3 * 3600)))
        // "Bilemedim" at 23:30 in Istanbul (20:30 UTC); the plan is written 90 minutes later.
        let answered = date(istanbul, 10, 27, 23, 30)
        let now = answered.addingTimeInterval(90 * minute)
        let progress = [1: Leitner.review(WordProgress(wordID: 1), grade: .again, at: answered)]
        // In Istanbul it is the next day already: the due word is hidden until "Tekrar" asks it.
        // In London the answer was today: it may show again.
        XCTAssertEqual(queue(progress, ids: 1...1, now: now, calendar: istanbul), [])
        XCTAssertEqual(queue(progress, ids: 1...1, now: now, calendar: utc), [1])
        // The answer itself is one moment, wherever it is read.
        XCTAssertEqual(ProgressSummary.lastAnswer(of: try XCTUnwrap(progress[1]))?.date, answered)
        XCTAssertEqual(try XCTUnwrap(progress[1]).dueAt, answered.addingTimeInterval(10 * minute))
    }

    // MARK: Two answers on one day

    func testTwoAnswersOnOneDay() {
        let morning = date(utc, 10, 27, 9)
        func inBox(_ id: Int, _ box: Int) -> WordProgress {
            var p = WordProgress(wordID: id)
            var at = morning.addingTimeInterval(-40 * day)
            for _ in 0..<box {
                p = Leitner.review(p, grade: .good, at: at)
                at = at.addingTimeInterval(day)
            }
            return p
        }
        // 1: "Bilemedim" at 09:00, "Bildim" at 09:12. 2: "Bildim" at 09:05, "Bilemedim" at 09:15.
        var one = Leitner.review(inBox(1, 3), grade: .again, at: morning)
        one = Leitner.review(one, grade: .good, at: morning.addingTimeInterval(12 * minute))
        var two = Leitner.review(inBox(2, 2), grade: .good, at: morning.addingTimeInterval(5 * minute))
        two = Leitner.review(two, grade: .again, at: morning.addingTimeInterval(15 * minute))

        XCTAssertEqual(one.box, 2, "3 → 1 → 2")
        XCTAssertEqual(one.lapses, 1)
        XCTAssertEqual(one.lastReviewedAt, morning.addingTimeInterval(12 * minute))
        XCTAssertEqual(one.lastGrade, .good)
        XCTAssertEqual(one.firstReviewedAt, morning.addingTimeInterval(-40 * day))
        XCTAssertEqual(one.dueAt, morning.addingTimeInterval(12 * minute + 2 * day))
        XCTAssertEqual(two.box, 1, "2 → 3 → 1")
        XCTAssertEqual(two.dueAt, morning.addingTimeInterval(25 * minute))

        // The widget at noon goes by the last answer: starting at the free slot, the word missed
        // last comes first, then the one answered right last, then the new word.
        let noon = date(utc, 10, 27, 12)
        let progress = [1: one, 2: two]
        XCTAssertEqual(queue(progress, ids: 1...3, now: noon, calendar: utc, maxNew: 1, patternOffset: 6), [2, 1, 3])

        // "İlerleme": one study day; 1 moved up a shelf, 2 did not.
        let summary = ProgressSummary.make(progress: progress, now: noon, calendar: utc)
        XCTAssertEqual(summary.thisWeek.studyDays, 1)
        XCTAssertEqual(summary.thisWeek.movedUpWordIDs, [1])
        XCTAssertTrue(summary.thisWeek.metWordIDs.isEmpty)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: two)?.kind, .forgot)
    }

    func testAnswersEitherSideOfMidnight() {
        // Met at 23:50 on Monday ("Bilemedim"), answered "Zor" at 00:10 on Tuesday: due at
        // 12:10, within the widget's 6 hours.
        let monday = date(utc, 10, 26, 23, 50)
        let tuesday = date(utc, 10, 27, 0, 10)
        var p = Leitner.review(WordProgress(wordID: 1), grade: .again, at: monday)
        p = Leitner.review(p, grade: .hard, at: tuesday)
        let noon = date(utc, 10, 27, 12)
        // Both days count: the first answer and the last are on record.
        let summary = ProgressSummary.make(progress: [1: p], now: noon, calendar: utc)
        XCTAssertEqual(summary.thisWeek.studyDays, 2)
        XCTAssertEqual(summary.thisWeek.metWordIDs, [1])
        // The widget's today is Tuesday: answered today, so it may show although it is due soon.
        XCTAssertEqual(queue([1: p], ids: 1...1, now: noon, calendar: utc), [1])
    }

    // MARK: "Biliyorum" check

    func testAWrongAnswerWhileTheBiliyorumCheckWaits() throws {
        let claimedAt = date(utc, 10, 26, 9)
        // Word 1 was learning (box 2) when "Biliyorum" was tapped; word 2 was new.
        var learning = Leitner.review(WordProgress(wordID: 1), grade: .good, at: claimedAt.addingTimeInterval(-3 * day))
        learning = Leitner.review(learning, grade: .good, at: claimedAt.addingTimeInterval(-2 * day))
        let progress = [
            1: Leitner.markKnown(learning, at: claimedAt),
            2: Leitner.markKnown(WordProgress(wordID: 2), at: claimedAt),
        ]
        // A day later, before the check is due, "Bilmiyorum" on the widget for both.
        let tap = claimedAt.addingTimeInterval(day)
        let ingested = ProgressIngest.applyLogged(
            [LearningEvent(type: .unknown, wordID: 1, at: tap), LearningEvent(type: .unknown, wordID: 2, at: tap.addingTimeInterval(1))],
            to: progress
        )
        for id in [1, 2] {
            let p = try XCTUnwrap(ingested.progress[id])
            XCTAssertEqual(p.state, .new, "\(id)")
            XCTAssertTrue(p.returnsToIntro, "\(id)")
            XCTAssertFalse(p.knownOverride, "\(id)")
            XCTAssertNil(p.dueAt, "\(id)")
            XCTAssertEqual(p.box, 0, "\(id)")
            XCTAssertEqual(p.lapses, 1, "\(id)")
            XCTAssertEqual(p.lastGrade, .again, "\(id)")
        }
        XCTAssertEqual(ingested.progress[2]?.firstReviewedAt, tap.addingTimeInterval(1), "the failed check was its first answer")
        XCTAssertEqual(ingested.answers.map { $0.knownCheck }, [true, true])
        XCTAssertEqual(ingested.answers.map { $0.source }, [.widget, .widget])

        // "Tanış" takes them first, the longest waiting first; the widget shows them as new words.
        let feed = words(1...5)
        XCTAssertEqual(ReviewPlanner.introWords(feed: feed, all: feed, progress: ingested.progress, limit: 3).map { $0.id }, [1, 2, 3])
        let later = tap.addingTimeInterval(2 * hour)
        XCTAssertEqual(queue(ingested.progress, ids: 1...2, now: later, calendar: utc, maxNew: 5), [1, 2])

        // "İlerleme": they leave "Kendin işaretlediklerin"; the day of the answer still counts.
        XCTAssertEqual(ProgressSummary.make(progress: progress, now: later, calendar: utc).words(on: .selfMarked), [1, 2])
        let after = ProgressSummary.make(progress: ingested.progress, now: later, calendar: utc)
        XCTAssertEqual(after.libraryCount, 0)
        XCTAssertEqual(after.thisWeek.studyDays, 1)
        XCTAssertNil(ProgressSummary.lastAnswer(of: try XCTUnwrap(ingested.progress[1])))

        // Its next "Hatırla" gives it box 1 again.
        let relearned = Leitner.review(try XCTUnwrap(ingested.progress[1]), grade: .good, at: tap.addingTimeInterval(3 * hour))
        XCTAssertEqual(relearned.state, .learning)
        XCTAssertEqual(relearned.box, 1)

        // Wrong in the same round as the tap: the same.
        let sameMinute = Leitner.review(Leitner.markKnown(WordProgress(wordID: 3), at: claimedAt), grade: .again, at: claimedAt.addingTimeInterval(30))
        XCTAssertTrue(sameMinute.returnsToIntro)
    }

    func testARightAnswerBeforeTheCheckDatePassesTheCheck() {
        let claimedAt = date(utc, 10, 26, 9)
        let early = claimedAt.addingTimeInterval(day)
        let p = Leitner.review(Leitner.markKnown(WordProgress(wordID: 1), at: claimedAt), grade: .good, at: early)
        XCTAssertEqual(p.state, .known)
        XCTAssertFalse(p.awaitsKnownCheck)
        XCTAssertEqual(p.dueAt, early.addingTimeInterval(30 * day))
        XCTAssertEqual(ProgressSummary.Shelf.of(p), .settled)
    }
}
