import XCTest
import CoreModels
import Learning

final class ReminderPlannerTests: XCTestCase {
    private var calendar: Calendar!
    private let evening = 20 * 60

    override func setUp() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        calendar = utc
    }

    private func date(day: Int, hour: Int, minute: Int = 0) -> Date {
        return calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
    }

    private func feed(_ ids: ClosedRange<Int>) -> [WidgetWord] {
        return ids.map { id in
            WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e")
        }
    }

    private func learning(_ id: Int, due: Date) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = 1
        p.dueAt = due
        return p
    }

    private func plan(
        feed: [WidgetWord],
        progress: [Int: WordProgress] = [:],
        now: Date,
        days: Int = 3,
        goal: Int = 5,
        studiedToday: Int = 0
    ) -> [Reminder] {
        return ReminderPlanner.plan(
            feed: feed,
            progress: progress,
            now: now,
            minuteOfDay: evening,
            days: days,
            dailyNewGoal: goal,
            newStudiedToday: studiedToday,
            calendar: calendar
        )
    }

    func testStartsTodayWhileTheTimeIsAhead() {
        let reminders = plan(feed: feed(1...20), now: date(day: 12, hour: 10))
        XCTAssertEqual(reminders.map(\.fireDate), [date(day: 12, hour: 20), date(day: 13, hour: 20), date(day: 14, hour: 20)])
        XCTAssertEqual(reminders.map(\.newCount), [5, 5, 5])
        XCTAssertEqual(reminders.map(\.dueCount), [0, 0, 0])
    }

    func testStartsTomorrowOnceTheTimeHasPassed() {
        let reminders = plan(feed: feed(1...20), now: date(day: 12, hour: 20, minute: 1))
        XCTAssertEqual(reminders.first?.fireDate, date(day: 13, hour: 20))
        XCTAssertEqual(reminders.count, 2, "today's slot is gone, so 3 days give 2 reminders")
    }

    func testDoneForTodaySkipsTodaysReminder() {
        // Goal reached and nothing due: no reminder tonight, tomorrow offers new words again.
        let reminders = plan(feed: feed(1...20), now: date(day: 12, hour: 10), studiedToday: 5)
        XCTAssertEqual(reminders.first?.fireDate, date(day: 13, hour: 20))
        XCTAssertEqual(reminders.first?.newCount, 5)
    }

    func testPartlyDoneTodayOffersTheRest() {
        let reminders = plan(feed: feed(1...20), now: date(day: 12, hour: 10), studiedToday: 3)
        XCTAssertEqual(reminders.first?.newCount, 2)
    }

    func testReviewsCountOnTheDayTheyFallDue() {
        let progress = [
            1: learning(1, due: date(day: 12, hour: 9)),   // already due
            2: learning(2, due: date(day: 13, hour: 8)),   // due tomorrow morning
            3: learning(3, due: date(day: 13, hour: 21)),  // after tomorrow's reminder
        ]
        // Only those three words exist, so no new words are offered.
        let reminders = plan(feed: feed(1...3), progress: progress, now: date(day: 12, hour: 10))
        XCTAssertEqual(reminders.map(\.dueCount), [1, 2, 3])
        XCTAssertEqual(reminders.map(\.newCount), [0, 0, 0])
    }

    func testNothingToDoMeansNoReminders() {
        var progress: [Int: WordProgress] = [:]
        for id in 1...3 {
            progress[id] = Leitner.markKnown(WordProgress(wordID: id), at: date(day: 12, hour: 9))
        }
        XCTAssertTrue(plan(feed: feed(1...3), progress: progress, now: date(day: 12, hour: 10)).isEmpty)
        XCTAssertTrue(plan(feed: [], now: date(day: 12, hour: 10)).isEmpty)
    }

    func testNewCountIsLimitedByTheWordsLeft() {
        let reminders = plan(feed: feed(1...2), now: date(day: 12, hour: 10), goal: 10)
        XCTAssertEqual(reminders.map(\.newCount), [2, 2, 2])
    }

    func testInvalidInputGivesNoReminders() {
        XCTAssertTrue(plan(feed: feed(1...5), now: date(day: 12, hour: 10), days: 0).isEmpty)
        let late = ReminderPlanner.plan(
            feed: feed(1...5), progress: [:], now: date(day: 12, hour: 10), minuteOfDay: 1440,
            days: 3, dailyNewGoal: 5, newStudiedToday: 0, calendar: calendar
        )
        XCTAssertTrue(late.isEmpty)
    }
}
