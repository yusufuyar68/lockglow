import XCTest
import Learning

final class LocalMetricsTests: XCTestCase {
    private var directory: URL!
    private var utc: Calendar!
    /// Noon (UTC), far from midnight.
    private let noon = Date(timeIntervalSince1970: 1_760_011_200)

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("LocalMetricsTests-\(UUID().uuidString)")
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        utc = calendar
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    /// `offset` days after `noon`, at `hour` (UTC).
    private func day(_ offset: Int, hour: Double = 12) -> Date {
        return noon.addingTimeInterval(Double(offset) * 86_400 + (hour - 12) * 3_600)
    }

    private func makeRecorder() -> LocalMetricsRecorder {
        return LocalMetricsRecorder(fileURL: directory.appendingPathComponent("local_metrics.json"), calendar: utc)
    }

    private func check(_ goal: AcceptanceCheck.Goal, in metrics: LocalMetrics, dailyNewWords: Int = 5, now: Date? = nil) -> AcceptanceCheck? {
        let report = metrics.report(dailyNewWords: dailyNewWords, now: now ?? day(0), calendar: utc)
        return report.acceptance.first { $0.goal == goal }
    }

    // MARK: Days

    func testDayKeyIsTheZeroPaddedLocalDay() {
        XCTAssertEqual(LocalMetrics.dayKey(Date(timeIntervalSince1970: 0), calendar: utc), "1970-01-01")
        var istanbul = Calendar(identifier: .gregorian)
        istanbul.timeZone = TimeZone(secondsFromGMT: 3 * 3_600)!
        // 22:30 UTC is already the next day in Istanbul.
        let late = Date(timeIntervalSince1970: 22.5 * 3_600)
        XCTAssertEqual(LocalMetrics.dayKey(late, calendar: utc), "1970-01-01")
        XCTAssertEqual(LocalMetrics.dayKey(late, calendar: istanbul), "1970-01-02")
    }

    func testAnswersAreCountedPerDayWithTheFirstTryRate() {
        var metrics = LocalMetrics()
        metrics.recordAnswer(isNew: true, firstTryCorrect: true, seconds: 8, at: day(0), calendar: utc)
        metrics.recordAnswer(isNew: false, firstTryCorrect: false, seconds: 12, at: day(0, hour: 13), calendar: utc)
        metrics.recordAnswer(isNew: false, firstTryCorrect: nil, seconds: nil, at: day(0, hour: 14), calendar: utc)
        metrics.recordAnswer(isNew: false, firstTryCorrect: true, seconds: 10, at: day(1), calendar: utc)

        XCTAssertEqual(metrics.days.count, 2)
        let first = metrics.days[0]
        XCTAssertEqual(first.newWords, 1)
        XCTAssertEqual(first.reviews, 2)
        XCTAssertEqual(first.firstTryAnswers, 2)
        XCTAssertEqual(first.firstTryCorrect, 1)
        XCTAssertEqual(first.timedAnswers, 2)
        XCTAssertEqual(first.answerSeconds, 20, accuracy: 0.001)

        let report = metrics.report(dailyNewWords: 5, now: day(1), calendar: utc)
        XCTAssertEqual(report.studyDays, 2)
        XCTAssertEqual(report.firstTryAnswers, 3)
        XCTAssertEqual(report.firstTryCorrectRate ?? -1, 2.0 / 3.0, accuracy: 0.001)
        // 3 answers on the first day, 1 on the second.
        XCTAssertEqual(report.medianDailyAnswers, 2)
        XCTAssertEqual(report.medianDailyNewWords, 0.5)
        XCTAssertEqual(report.meanSecondsPerAnswer ?? -1, 10, accuracy: 0.001)
    }

    func testSlowAnswerCountsButItsTimeIsLeftOut() {
        var metrics = LocalMetrics()
        metrics.recordAnswer(isNew: false, firstTryCorrect: true, seconds: 600, at: day(0), calendar: utc)
        XCTAssertEqual(metrics.days[0].reviews, 1)
        XCTAssertEqual(metrics.days[0].timedAnswers, 0)
        XCTAssertNil(metrics.report(dailyNewWords: 5, now: day(0), calendar: utc).meanSecondsPerAnswer)
    }

    func testReportCoversOnlyTheWindow() {
        var metrics = LocalMetrics()
        metrics.recordAnswer(isNew: true, firstTryCorrect: true, seconds: 5, at: day(0), calendar: utc)
        metrics.recordAnswer(isNew: true, firstTryCorrect: false, seconds: 5, at: day(10), calendar: utc)
        let report = metrics.report(dailyNewWords: 5, windowDays: 7, now: day(10), calendar: utc)
        XCTAssertEqual(report.studyDays, 1)
        XCTAssertEqual(report.firstTryCorrectRate, 0)
    }

    func testDaysOlderThanTheKeptPeriodAreDropped() {
        var metrics = LocalMetrics()
        let later = day(LocalMetrics.keptDays + 1)
        metrics.recordAnswer(isNew: true, firstTryCorrect: true, seconds: 5, at: day(0), calendar: utc)
        metrics.recordReminderPlan([day(0, hour: 20)], now: day(0), calendar: utc)
        metrics.recordAnswer(isNew: true, firstTryCorrect: true, seconds: 5, at: later, calendar: utc)
        XCTAssertEqual(metrics.days.map(\.day), [LocalMetrics.dayKey(later, calendar: utc)])
        XCTAssertTrue(metrics.reminders.isEmpty)
    }

    // MARK: Rounds and targets

    func testRoundTimeLeavesOutTheBackground() {
        let recorder = makeRecorder()
        let start = day(0)
        recorder.startRound(at: start)
        recorder.appDidEnterBackground(at: start.addingTimeInterval(60))
        recorder.appDidBecomeActive(at: start.addingTimeInterval(3_660))
        recorder.finishRound(endedEarly: true, at: start.addingTimeInterval(3_690))
        let recorded = recorder.snapshot().days[0]
        XCTAssertEqual(recorded.roundSeconds.count, 1)
        XCTAssertEqual(recorded.roundSeconds[0], 90, accuracy: 0.001)
        XCTAssertEqual(recorded.roundsEndedEarly, 1)
        // No round is open any more: nothing is added.
        recorder.finishRound(endedEarly: false, at: start.addingTimeInterval(4_000))
        XCTAssertEqual(recorder.snapshot().days[0].roundSeconds.count, 1)
    }

    func testEarlyEndRateMustStayUnderAQuarter() {
        var metrics = LocalMetrics()
        for index in 0..<4 {
            metrics.recordRound(seconds: 120, endedEarly: index == 0, at: day(0), calendar: utc)
        }
        var result = check(.earlyEndRate, in: metrics)
        XCTAssertEqual(result?.value, 0.25)
        XCTAssertEqual(result?.status, .missed)

        metrics.recordRound(seconds: 120, endedEarly: false, at: day(0), calendar: utc)
        result = check(.earlyEndRate, in: metrics)
        XCTAssertEqual(result?.value ?? -1, 0.2, accuracy: 0.0001)
        XCTAssertEqual(result?.status, .met)
    }

    func testTapsPerNewWordNeedFiveWordsAndAMedianOfAtMostFour() {
        var metrics = LocalMetrics()
        for taps in [3, 4, 6, 4] {
            metrics.recordNewWord(taps: taps, at: day(0), calendar: utc)
        }
        XCTAssertEqual(check(.tapsPerNewWord, in: metrics)?.status, .tooFewSamples)

        metrics.recordNewWord(taps: 5, at: day(0), calendar: utc)
        XCTAssertEqual(check(.tapsPerNewWord, in: metrics)?.value, 4)
        XCTAssertEqual(check(.tapsPerNewWord, in: metrics)?.status, .met)

        metrics.recordNewWord(taps: 7, at: day(0), calendar: utc)
        XCTAssertEqual(check(.tapsPerNewWord, in: metrics)?.value, 4.5)
        XCTAssertEqual(check(.tapsPerNewWord, in: metrics)?.status, .missed)
    }

    func testKnownCheckFailuresAboveThirtyPercentMissTheTarget() {
        var metrics = LocalMetrics()
        for passed in [true, true, true, false, false] {
            metrics.recordKnownCheck(passed: passed, at: day(0), calendar: utc)
        }
        XCTAssertEqual(check(.knownCheckFailRate, in: metrics)?.value ?? -1, 0.4, accuracy: 0.0001)
        XCTAssertEqual(check(.knownCheckFailRate, in: metrics)?.status, .missed)

        metrics.recordKnownCheck(passed: true, at: day(0), calendar: utc)
        metrics.recordKnownCheck(passed: true, at: day(0), calendar: utc)
        XCTAssertEqual(check(.knownCheckFailRate, in: metrics)?.value ?? -1, 2.0 / 7.0, accuracy: 0.0001)
        XCTAssertEqual(check(.knownCheckFailRate, in: metrics)?.status, .met)
    }

    func testShownDailyMinutesFollowTheSettingsLabels() {
        let minutes = [5, 10, 15, 20].map { LocalMetricsTargets.shownDailyMinutes(dailyNewWords: $0) }
        XCTAssertEqual(minutes, [7, 13, 19, 25])
    }

    func testDailyMinutesAreJudgedAgainstTheGoalsLabel() {
        var metrics = LocalMetrics()
        // Study days of 6, 8 and 10 minutes (two rounds on the last one).
        metrics.recordRound(seconds: 360, endedEarly: false, at: day(0), calendar: utc)
        metrics.recordRound(seconds: 480, endedEarly: false, at: day(1), calendar: utc)
        metrics.recordRound(seconds: 300, endedEarly: false, at: day(2), calendar: utc)
        metrics.recordRound(seconds: 300, endedEarly: false, at: day(2, hour: 18), calendar: utc)

        let five = check(.dailyMinutes, in: metrics, dailyNewWords: 5, now: day(2))
        XCTAssertEqual(five?.value, 8)
        XCTAssertEqual(five?.limit, 7)
        XCTAssertEqual(five?.status, .missed)
        let ten = check(.dailyMinutes, in: metrics, dailyNewWords: 10, now: day(2))
        XCTAssertEqual(ten?.limit, 13)
        XCTAssertEqual(ten?.status, .met)
        // Rounds of 6, 8, 5 and 5 minutes.
        XCTAssertEqual(metrics.report(dailyNewWords: 5, now: day(2), calendar: utc).medianRoundMinutes, 5.5)
    }

    func testEmptyReportJudgesNothing() {
        let report = LocalMetrics().report(dailyNewWords: 10, now: noon, calendar: utc)
        XCTAssertEqual(report.studyDays, 0)
        XCTAssertNil(report.firstTryCorrectRate)
        XCTAssertNil(report.reminderOpenRate)
        XCTAssertNil(report.boxes)
        XCTAssertEqual(report.acceptance.map(\.goal), AcceptanceCheck.Goal.allCases)
        XCTAssertEqual(report.acceptance.map(\.status), Array(repeating: AcceptanceCheck.Status.tooFewSamples, count: 4))
    }

    // MARK: Reminders

    func testReminderPlanKeepsFiredRemindersAndReplacesTheRest() {
        var metrics = LocalMetrics()
        let evening = (0..<4).map { day($0, hour: 20) }
        metrics.recordReminderPlan(Array(evening[0...2]), now: day(0), calendar: utc)
        XCTAssertEqual(metrics.reminders.map(\.fireDate), Array(evening[0...2]))

        // Day 1 at 21:00: two reminders fired; day 2's work is already done.
        metrics.recordReminderPlan([evening[3]], now: day(1, hour: 21), calendar: utc)
        XCTAssertEqual(metrics.reminders.map(\.fireDate), [evening[0], evening[1], evening[3]])

        // Reminders turned off.
        metrics.recordReminderPlan([], now: day(1, hour: 22), calendar: utc)
        XCTAssertEqual(metrics.reminders.map(\.fireDate), [evening[0], evening[1]])
    }

    func testReminderOpenRateAndIgnoredReminders() {
        var metrics = LocalMetrics()
        let evening = (0..<4).map { day($0, hour: 20) }
        metrics.recordReminderPlan(evening, now: day(0), calendar: utc)
        // Day 0: tapped. Day 1: the app was opened later that evening. Day 2: opened only in the
        // morning, before the reminder. Day 3: today, nothing yet.
        metrics.recordReminderOpened(deliveredAt: evening[0].addingTimeInterval(2), calendar: utc)
        metrics.recordAppActive(at: day(1, hour: 21), calendar: utc)
        metrics.recordAppActive(at: day(2, hour: 9), calendar: utc)

        let report = metrics.report(dailyNewWords: 5, now: day(3, hour: 21), calendar: utc)
        XCTAssertEqual(report.remindersFired, 4)
        XCTAssertEqual(report.remindersOpened, 1)
        XCTAssertEqual(report.reminderOpenRate, 0.25)
        XCTAssertEqual(report.remindersIgnored, 1)
    }

    func testReminderThatFiresWhileTheAppIsOpenIsNotIgnored() {
        let recorder = makeRecorder()
        let reminder = day(0, hour: 20)
        recorder.recordReminderPlan([reminder], now: day(0))
        // Opened before the reminder, left after it: the user was in the app when it fired.
        recorder.appDidBecomeActive(at: reminder.addingTimeInterval(-600))
        recorder.appDidEnterBackground(at: reminder.addingTimeInterval(600))
        let report = recorder.report(dailyNewWords: 5, now: day(1, hour: 21))
        XCTAssertEqual(report.remindersFired, 1)
        XCTAssertEqual(report.remindersIgnored, 0)
    }

    func testOpenedReminderScheduledBeforeMeasuringIsAdded() {
        var metrics = LocalMetrics()
        metrics.recordReminderOpened(deliveredAt: day(0, hour: 20), calendar: utc)
        XCTAssertEqual(metrics.reminders.count, 1)
        XCTAssertEqual(metrics.reminders.first?.opened, true)
    }

    // MARK: Boxes

    func testBoxCountsLeaveOutWordsNeverAnswered() {
        var progress: [Int: WordProgress] = [:]
        progress[1] = WordProgress(wordID: 1)
        for (id, box) in [(2, 1), (3, 3)] {
            var word = WordProgress(wordID: id)
            word.state = .learning
            word.box = box
            progress[id] = word
        }
        var graduated = WordProgress(wordID: 4)
        graduated.state = .known
        graduated.box = Leitner.maxBox
        progress[4] = graduated
        progress[5] = Leitner.markKnown(WordProgress(wordID: 5), at: noon)

        let counts = BoxCounts(progress: progress)
        XCTAssertEqual(counts.boxes, [1, 0, 1, 0, 0])
        XCTAssertEqual(counts.graduated, 1)
        XCTAssertEqual(counts.markedKnown, 1)

        let recorder = makeRecorder()
        recorder.recordBoxes(progress, at: day(0))
        XCTAssertEqual(recorder.snapshot().days.first?.boxes, counts)
        XCTAssertEqual(recorder.report(dailyNewWords: 5, now: day(0)).boxes, counts)
    }

    // MARK: File

    func testRecorderKeepsTheFileAndResetDeletesIt() throws {
        let recorder = makeRecorder()
        recorder.recordAnswer(isNew: true, firstTryCorrect: true, seconds: 7.25, at: day(0))
        recorder.recordNewWord(taps: 3, at: day(0))
        recorder.recordReminderPlan([day(0, hour: 20.5)], now: day(0))
        let url = try XCTUnwrap(recorder.fileURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

        // The next launch reads what was written.
        let reread = makeRecorder().snapshot()
        XCTAssertEqual(reread, recorder.snapshot())
        XCTAssertEqual(reread.days.first?.newWordTaps, [3])
        XCTAssertEqual(reread.reminders.first?.fireDate, day(0, hour: 20.5))

        recorder.reset()
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        XCTAssertEqual(recorder.snapshot(), LocalMetrics())
        XCTAssertEqual(makeRecorder().snapshot(), LocalMetrics())
    }

    func testFileUsesSnakeCaseKeys() throws {
        let recorder = makeRecorder()
        recorder.recordRound(seconds: 60, endedEarly: false, at: day(0))
        let data = try Data(contentsOf: XCTUnwrap(recorder.fileURL))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let days = try XCTUnwrap(object["days"] as? [[String: Any]])
        XCTAssertNotNil(days.first?["round_seconds"])
        XCTAssertNotNil(days.first?["rounds_ended_early"])
        XCTAssertNotNil(object["reminders"])
    }

    func testDamagedFileIsReplaced() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: directory.appendingPathComponent("local_metrics.json"))
        let recorder = makeRecorder()
        XCTAssertEqual(recorder.snapshot(), LocalMetrics())
        recorder.recordNewWord(taps: 2, at: day(0))
        XCTAssertEqual(makeRecorder().snapshot().days.first?.newWordTaps, [2])
    }

    func testOlderFileWithFewerKeysStillReads() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let json = #"{"days":[{"day":"2025-10-09","reviews":4}],"reminders":[{"fire_date":1760032800}]}"#
        try Data(json.utf8).write(to: directory.appendingPathComponent("local_metrics.json"))
        let metrics = makeRecorder().snapshot()
        XCTAssertEqual(metrics.days.first?.reviews, 4)
        XCTAssertEqual(metrics.days.first?.newWords, 0)
        XCTAssertEqual(metrics.days.first?.roundSeconds, [])
        XCTAssertNil(metrics.days.first?.boxes)
        XCTAssertEqual(metrics.reminders.first?.fireDate, Date(timeIntervalSince1970: 1_760_032_800))
        XCTAssertEqual(metrics.reminders.first?.opened, false)
    }

    func testMedian() {
        XCTAssertNil(LocalMetrics.median([]))
        XCTAssertEqual(LocalMetrics.median([3]), 3)
        XCTAssertEqual(LocalMetrics.median([5, 1, 3]), 3)
        XCTAssertEqual(LocalMetrics.median([4, 1, 3, 2]), 2.5)
    }
}
