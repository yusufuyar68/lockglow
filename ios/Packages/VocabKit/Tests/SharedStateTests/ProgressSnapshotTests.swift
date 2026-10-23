import XCTest
import SharedState

/// `progress_snapshot.json` for the Lock Screen progress widget: the file, and what the widget
/// works out from it at a given moment.
final class ProgressSnapshotTests: XCTestCase {
    private var directory: URL!
    private var calendar = Calendar(identifier: .gregorian)

    override func setUpWithError() throws {
        directory = try makeTemporaryDirectory("ProgressSnapshotTests")
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "Europe/Istanbul"))
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    /// 23 October 2026 (Istanbul, no daylight saving) at `hour:minute`, plus `days`.
    private func date(_ hour: Int, _ minute: Int = 0, days: Int = 0) -> Date {
        let components = DateComponents(year: 2026, month: 10, day: 23 + days, hour: hour, minute: minute)
        return calendar.date(from: components)!
    }

    // MARK: File

    func testRoundTripAndContractKeys() throws {
        let store = AppGroupStore(containerURL: directory)
        XCTAssertNil(store.readProgressSnapshot())

        let snapshot = ProgressSnapshot(
            writtenAt: date(10),
            dailyGoal: 5,
            newWordsToday: 3,
            dueDates: [date(21, 40), date(9), date(9, 15, days: 1)]
        )
        try store.writeProgressSnapshot(snapshot)
        XCTAssertEqual(store.readProgressSnapshot(), snapshot)
        XCTAssertEqual(store.progressSnapshotURL.lastPathComponent, "progress_snapshot.json")

        let data = try Data(contentsOf: store.progressSnapshotURL)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(Set(object.keys), ["version", "written_at", "daily_goal", "new_words_today", "due_dates"])
        XCTAssertEqual(object["version"] as? Int, 1)
    }

    func testMissingOrDamagedFileReadsAsNil() throws {
        let store = AppGroupStore(containerURL: directory)
        try Data("{\"version\": 1".utf8).write(to: store.progressSnapshotURL)
        XCTAssertNil(store.readProgressSnapshot())
    }

    /// No word ids or words: only dates and counts leave the app.
    func testHoldsNoWords() throws {
        let snapshot = ProgressSnapshot(writtenAt: date(10), dailyGoal: 5, newWordsToday: 1, dueDates: [date(12)])
        let data = try JSONEncoder().encode(snapshot)
        let text = String(decoding: data, as: UTF8.self)
        for key in ["\"id\"", "word_id", "lemma", "gloss"] {
            XCTAssertFalse(text.contains(key), key)
        }
    }

    func testInitializerSortsAndKeepsTheEarliestDates() {
        let many = (0..<150).reversed().map { date(0, days: 1).addingTimeInterval(Double($0) * 60) }
        let snapshot = ProgressSnapshot(writtenAt: date(10), dailyGoal: -2, newWordsToday: -1, dueDates: many)
        XCTAssertEqual(snapshot.dueDates.count, ProgressSnapshot.dueDateLimit)
        XCTAssertEqual(snapshot.dueDates, snapshot.dueDates.sorted())
        XCTAssertEqual(snapshot.dueDates.first, date(0, days: 1))
        XCTAssertEqual(snapshot.dailyGoal, 0)
        XCTAssertEqual(snapshot.newWordsToday, 0)
    }

    // MARK: Status

    func testDueNowTodayAndNext() {
        // Two overdue (yesterday and this morning), two later today, one tomorrow.
        let snapshot = ProgressSnapshot(
            writtenAt: date(10),
            dailyGoal: 5,
            newWordsToday: 3,
            dueDates: [date(18, days: -1), date(9), date(21, 40), date(23, 59), date(9, 15, days: 1)]
        )
        let morning = snapshot.status(at: date(10), calendar: calendar)
        XCTAssertEqual(morning.dueNow, 2)
        XCTAssertEqual(morning.dueToday, 4)
        XCTAssertEqual(morning.nextDue, date(21, 40))
        XCTAssertEqual(morning.newWordsToday, 3)
        XCTAssertEqual(morning.dailyGoal, 5)

        let evening = snapshot.status(at: date(22), calendar: calendar)
        XCTAssertEqual(evening.dueNow, 3)
        XCTAssertEqual(evening.dueToday, 4)
        XCTAssertEqual(evening.nextDue, date(23, 59))
    }

    /// At midnight the day's new words start again from 0 and tomorrow's reviews are today's.
    func testNewDayRestartsTodaysCounts() {
        let snapshot = ProgressSnapshot(
            writtenAt: date(22),
            dailyGoal: 5,
            newWordsToday: 5,
            dueDates: [date(9, 15, days: 1), date(20, days: 1), date(8, days: 2)]
        )
        let tonight = snapshot.status(at: date(23, 30), calendar: calendar)
        XCTAssertTrue(tonight.goalReached)
        XCTAssertEqual(tonight.goalFraction, 1)
        XCTAssertEqual(tonight.dueToday, 0)

        let tomorrow = snapshot.status(at: date(0, days: 1), calendar: calendar)
        XCTAssertEqual(tomorrow.newWordsToday, 0)
        XCTAssertFalse(tomorrow.goalReached)
        XCTAssertEqual(tomorrow.goalFraction, 0)
        XCTAssertEqual(tomorrow.dueNow, 0)
        XCTAssertEqual(tomorrow.dueToday, 2)
        XCTAssertEqual(tomorrow.nextDue, date(9, 15, days: 1))
    }

    /// A file written by hand or by another version may be unsorted: the next due date is still
    /// the earliest.
    func testUnsortedDecodedDates() throws {
        let json = """
        {"version": 1, "written_at": "2026-10-23T07:00:00Z", "daily_goal": 10, "new_words_today": 12,
         "due_dates": ["2026-10-23T18:40:00Z", "2026-10-23T12:00:00Z", "2026-10-22T08:00:00Z"]}
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let snapshot = try decoder.decode(ProgressSnapshot.self, from: Data(json.utf8))
        let status = snapshot.status(at: date(10), calendar: calendar)
        XCTAssertEqual(status.dueNow, 1)
        XCTAssertEqual(status.nextDue, date(15))
        XCTAssertEqual(status.goalFraction, 1)
        XCTAssertTrue(status.goalReached)
    }

    func testNoGoalNeverFillsTheRing() {
        let status = ProgressStatus(date: date(10), dailyGoal: 0, newWordsToday: 3, dueNow: 0, dueToday: 0, nextDue: nil)
        XCTAssertFalse(status.goalReached)
        XCTAssertEqual(status.goalFraction, 0)
    }

    // MARK: Timeline

    /// The first review falling due, then midnight; later reviews of the same day add nothing, and
    /// a review left unanswered keeps "Tekrar zamanı" over the next day too.
    func testTimelineDatesFollowTheFirstDueAndMidnights() {
        let snapshot = ProgressSnapshot(
            writtenAt: date(10),
            dailyGoal: 5,
            newWordsToday: 0,
            dueDates: [date(21, 40), date(22), date(11, days: 1)]
        )
        let dates = snapshot.timelineDates(after: date(10), until: date(10, days: 2), limit: 10, calendar: calendar)
        XCTAssertEqual(dates, [date(21, 40), date(0, days: 1), date(0, days: 2)])
    }

    /// Nothing due today: midnight first ("yarın 09:15" becomes "09:15"), then the review itself.
    func testTimelineDatesForTomorrowsFirstReview() {
        let snapshot = ProgressSnapshot(
            writtenAt: date(10),
            dailyGoal: 5,
            newWordsToday: 0,
            dueDates: [date(9, 15, days: 1), date(11, days: 1)]
        )
        let dates = snapshot.timelineDates(after: date(10), until: date(10, days: 2), limit: 10, calendar: calendar)
        XCTAssertEqual(dates, [date(0, days: 1), date(9, 15, days: 1), date(0, days: 2)])
    }

    /// While something is due, only midnights change what is shown.
    func testTimelineWhileDueHasOnlyMidnights() {
        let snapshot = ProgressSnapshot(writtenAt: date(10), dailyGoal: 5, newWordsToday: 0, dueDates: [date(9), date(12)])
        let dates = snapshot.timelineDates(after: date(10), until: date(10, days: 2), limit: 10, calendar: calendar)
        XCTAssertEqual(dates, [date(0, days: 1), date(0, days: 2)])
    }

    func testTimelineRespectsEndAndLimit() {
        let snapshot = ProgressSnapshot(writtenAt: date(10), dailyGoal: 5, newWordsToday: 0, dueDates: [date(21, 40)])
        XCTAssertEqual(
            snapshot.timelineDates(after: date(10), until: date(20), limit: 10, calendar: calendar),
            []
        )
        XCTAssertEqual(
            snapshot.timelineDates(after: date(10), until: date(10, days: 5), limit: 2, calendar: calendar),
            [date(21, 40), date(0, days: 1)]
        )
        XCTAssertEqual(
            snapshot.timelineDates(after: date(10), until: date(10, days: 5), limit: 0, calendar: calendar),
            []
        )
    }

    /// A review due exactly at midnight gives one entry, not two, and belongs to the next day (the
    /// widget calls it "yarın 00:00", so it is not counted today).
    func testDueAtMidnightIsOneEntry() {
        let snapshot = ProgressSnapshot(writtenAt: date(10), dailyGoal: 5, newWordsToday: 0, dueDates: [date(0, days: 1)])
        let dates = snapshot.timelineDates(after: date(10), until: date(1, days: 1), limit: 10, calendar: calendar)
        XCTAssertEqual(dates, [date(0, days: 1)])
        XCTAssertEqual(snapshot.status(at: date(23), calendar: calendar).dueToday, 0)
        XCTAssertEqual(snapshot.status(at: date(0, days: 1), calendar: calendar).dueToday, 1)
    }
}
