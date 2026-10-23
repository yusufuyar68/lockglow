import XCTest
import CoreModels
import Learning

final class ReminderTimingTests: XCTestCase {
    private typealias State = ReminderTiming.State
    private var calendar: Calendar!
    private let minute: TimeInterval = 60

    override func setUp() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        calendar = utc
    }

    private func date(month: Int = 10, day: Int, hour: Int, minute: Int = 0, in other: Calendar? = nil) -> Date {
        return (other ?? calendar).date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
    }

    /// One start a day on `days` (October) at `hour:minute`.
    private func starts(_ days: ClosedRange<Int>, hour: Int, minute: Int = 0, afterReminder: Bool = false) -> [StudyStart] {
        return days.map { day in
            StudyStart(at: date(day: day, hour: hour, minute: minute), minute: hour * 60 + minute, afterReminder: afterReminder)
        }
    }

    private func decide(_ previous: State?, chosen: Int, _ starts: [StudyStart], now: Date, in other: Calendar? = nil) -> ReminderTiming.Decision {
        return ReminderTiming.decide(previous: previous, chosenMinute: chosen, starts: starts, now: now, calendar: other ?? calendar)
    }

    private func hourMinute(_ date: Date, in other: Calendar) -> Int {
        let parts = other.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }

    private func word(_ id: Int) -> WidgetWord {
        let letters = Array("abcdefghij")
        let lemma = "w" + String(String(id).map { letters[Int(String($0))!] })
        return WidgetWord(
            id: id, lemma: lemma, pos: "n", level: "A1", defMicro: "m", defShort: "s",
            exampleEN: "I like the \(lemma) a lot.", glossTR: "anlam \(lemma)"
        )
    }

    private func freshDefaults() throws -> UserDefaults {
        let name = "ReminderTimingTests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        addTeardownBlock {
            defaults.removePersistentDomain(forName: name)
        }
        return defaults
    }

    // MARK: Choosing the time

    func testFewDaysKeepTheTime() {
        let decision = decide(nil, chosen: 20 * 60, starts(18...19, hour: 19), now: date(day: 20, hour: 10))
        XCTAssertEqual(decision.reason, .learning)
        XCTAssertEqual(decision.today, 20 * 60)
        XCTAssertEqual(decision.later, 20 * 60)
    }

    func testMovesHalfAnHourADayToABitBeforeTheUsualTime() {
        let studied = starts(15...19, hour: 19, minute: 2)
        var state: State?
        var times: [(Int, Int)] = []
        var reasons: [ReminderTiming.Reason] = []
        for day in 20...24 {
            let decision = decide(state, chosen: 20 * 60, studied, now: date(day: day, hour: 10))
            state = decision.state
            times.append((decision.today, decision.later))
            reasons.append(decision.reason)
        }
        XCTAssertEqual(times.map { $0.0 }, [1200, 1170, 1140, 1110, 1110], "today keeps what was planned for it")
        XCTAssertEqual(times.map { $0.1 }, [1170, 1140, 1110, 1110, 1110])
        XCTAssertEqual(reasons.first, .moving(usual: 19 * 60, aim: 18 * 60 + 30))
        XCTAssertEqual(reasons.last, .settled(usual: 19 * 60))
    }

    func testPlanningAgainTheSameDayMovesOnce() {
        let studied = starts(15...19, hour: 19)
        let morning = decide(nil, chosen: 20 * 60, studied, now: date(day: 20, hour: 10))
        let evening = decide(morning.state, chosen: 20 * 60, studied, now: date(day: 20, hour: 22))
        XCTAssertEqual(evening, morning)
        XCTAssertEqual(evening.later, 1170)
    }

    func testDaysWithoutPlanningDoNotAddUp() {
        // Decided on the 10th; the app was not opened again until the 15th: one step only.
        let old = State(minute: 1200, next: 1170, decidedOn: "2026-10-10")
        let decision = decide(old, chosen: 1170, starts(11...14, hour: 19), now: date(day: 15, hour: 10))
        XCTAssertEqual(decision.today, 1170)
        XCTAssertEqual(decision.later, 1140)
    }

    func testEveryDayDiffersByHalfAnHourAtMost() {
        // The user's hour jumps around; the reminder never jumps.
        var studied: [StudyStart] = []
        var state: State?
        var previousLater: Int?
        let hours = [8, 21, 13, 22, 9, 19, 23, 7, 18, 12, 20, 10, 21, 8, 17, 22, 9, 19, 11, 20]
        for (offset, hour) in hours.enumerated() {
            let day = offset + 1
            studied.append(StudyStart(at: date(day: day, hour: hour), minute: hour * 60, afterReminder: false))
            let decision = decide(state, chosen: 20 * 60, studied, now: date(day: day, hour: 23, minute: 50))
            if let yesterday = previousLater {
                XCTAssertEqual(decision.today, yesterday, "day \(day)")
            }
            XCTAssertLessThanOrEqual(abs(decision.later - decision.today), ReminderTiming.maxDailyStep, "day \(day)")
            XCTAssertTrue((ReminderTiming.earliestMinute...ReminderTiming.latestMinute).contains(decision.later), "day \(day)")
            state = decision.state
            previousLater = decision.later
        }
    }

    func testTheBusiestHourWins() {
        let studied = starts(10...12, hour: 8, minute: 30) + starts(13...17, hour: 20)
        let decision = decide(nil, chosen: 21 * 60, studied, now: date(day: 18, hour: 10))
        XCTAssertEqual(decision.reason, .moving(usual: 20 * 60, aim: 19 * 60 + 30))
        XCTAssertEqual(decision.later, 20 * 60 + 30)
    }

    func testTheUsualTimeIsTheMiddleOfEachDaysFirstStart() {
        // Two starts on the 13th: its first one counts. Middle of 18:50, 19:00, 19:10, 19:20: 19:00.
        let studied = starts(11...11, hour: 18, minute: 50) + starts(12...12, hour: 19)
            + starts(13...13, hour: 19, minute: 10) + starts(13...13, hour: 19, minute: 40)
            + starts(14...14, hour: 19, minute: 20)
        XCTAssertEqual(decide(nil, chosen: 18 * 60 + 30, studied, now: date(day: 15, hour: 10)).reason, .settled(usual: 19 * 60))
    }

    func testATieGoesToTheHourNearestTheCurrentTime() {
        let studied = starts(10...12, hour: 9) + starts(13...15, hour: 19)
        XCTAssertEqual(decide(nil, chosen: 20 * 60, studied, now: date(day: 16, hour: 10)).later, 19 * 60 + 30)
        XCTAssertEqual(decide(nil, chosen: 9 * 60, studied, now: date(day: 16, hour: 10)).later, 8 * 60 + 30)
    }

    func testASmallDifferenceDoesNotMoveTheTime() {
        // The aim is 18:30; 18:37 is close enough.
        let decision = decide(nil, chosen: 18 * 60 + 37, starts(10...14, hour: 19), now: date(day: 15, hour: 10))
        XCTAssertEqual(decision.later, 18 * 60 + 37)
        XCTAssertEqual(decision.reason, .settled(usual: 19 * 60))
    }

    func testOnlyTheLastFourteenDaysCount() {
        let old = starts(1...5, hour: 19)
        XCTAssertEqual(decide(nil, chosen: 20 * 60, old, now: date(day: 19, hour: 10)).reason, .learning)
        // The 6th is the oldest of the 14 days up to the 19th.
        let kept = starts(4...6, hour: 19)
        XCTAssertEqual(decide(nil, chosen: 20 * 60, kept, now: date(day: 19, hour: 10)).reason, .learning)
        XCTAssertEqual(decide(nil, chosen: 20 * 60, starts(6...8, hour: 19), now: date(day: 19, hour: 10)).later, 19 * 60 + 30)
    }

    func testScatteredHoursKeepTheTime() {
        let studied = starts(10...10, hour: 8) + starts(11...11, hour: 12) + starts(12...12, hour: 16) + starts(13...13, hour: 20)
        let decision = decide(nil, chosen: 20 * 60, studied, now: date(day: 14, hour: 10))
        XCTAssertEqual(decision.reason, .varied)
        XCTAssertEqual(decision.later, 20 * 60)
    }

    // MARK: The night and the edges

    func testNeverAtNight() {
        XCTAssertEqual(ReminderTiming.allowed(22 * 60 + 30), 22 * 60 + 30)
        XCTAssertEqual(ReminderTiming.allowed(22 * 60 + 31), 22 * 60 + 30)
        XCTAssertEqual(ReminderTiming.allowed(8 * 60), 8 * 60)
        XCTAssertEqual(ReminderTiming.allowed(7 * 60 + 59), 8 * 60)
        // The night's middle is 03:15: before it the evening edge, after it the morning edge.
        XCTAssertEqual(ReminderTiming.allowed(0), 22 * 60 + 30)
        XCTAssertEqual(ReminderTiming.allowed(3 * 60 + 15), 22 * 60 + 30)
        XCTAssertEqual(ReminderTiming.allowed(3 * 60 + 16), 8 * 60)
        XCTAssertEqual(ReminderTiming.allowed(-30), 22 * 60 + 30)
        XCTAssertEqual(ReminderTiming.allowed(1440 + 9 * 60), 9 * 60)
    }

    func testANightOwlGetsTheLatestTime() {
        // Studies at 23:30: the aim 23:00 is night, so 22:30, reached half an hour a day.
        var state: State?
        var later: [Int] = []
        var reason: ReminderTiming.Reason?
        for day in 15...20 {
            let decision = decide(state, chosen: 21 * 60, starts(10...14, hour: 23, minute: 30), now: date(day: day, hour: 10))
            state = decision.state
            later.append(decision.later)
            reason = decision.reason
        }
        XCTAssertEqual(later, [1290, 1320, 1350, 1350, 1350, 1350])
        XCTAssertEqual(reason, .latestLimit(usual: 23 * 60 + 30))
    }

    func testStudyAcrossMidnightIsOneHour() {
        // 23:50 on two days and 00:10 on two others: one hour across midnight, four days.
        let studied = starts(10...11, hour: 23, minute: 50) + starts(12...13, hour: 0, minute: 10)
        let decision = decide(nil, chosen: 22 * 60, studied, now: date(day: 14, hour: 10))
        XCTAssertEqual(decision.reason, .latestLimit(usual: 23 * 60 + 50))
        XCTAssertEqual(decision.later, 22 * 60 + 30)
    }

    func testAnEarlyBirdGetsTheEarliestTime() {
        let decision = decide(nil, chosen: 8 * 60 + 20, starts(10...14, hour: 7, minute: 15), now: date(day: 15, hour: 10))
        XCTAssertEqual(decision.reason, .earliestLimit(usual: 7 * 60 + 15))
        XCTAssertEqual(decision.later, 8 * 60)
    }

    func testANightTimeIsMovedOutAtOnce() {
        // The user had chosen 23:30 before turning the option on: the night rule comes first.
        let decision = decide(nil, chosen: 23 * 60 + 30, [], now: date(day: 15, hour: 10))
        XCTAssertEqual(decision.today, 22 * 60 + 30)
        XCTAssertEqual(decision.later, 22 * 60 + 30)
        XCTAssertEqual(decide(nil, chosen: 5 * 60, [], now: date(day: 15, hour: 10)).today, 8 * 60)
    }

    func testABrokenDecisionStartsFromTheChosenTime() {
        let broken = State(minute: 2000, next: 1170, decidedOn: "2026-10-14")
        XCTAssertEqual(decide(broken, chosen: 20 * 60, [], now: date(day: 15, hour: 10)).today, 20 * 60)
    }

    // MARK: Reminders do not pull the time

    func testStudyRightAfterAReminderDoesNotCount() {
        let decision = decide(nil, chosen: 18 * 60 + 30, starts(10...14, hour: 18, minute: 35, afterReminder: true), now: date(day: 15, hour: 10))
        XCTAssertEqual(decision.reason, .followsReminder)
        XCTAssertEqual(decision.later, 18 * 60 + 30)
    }

    func testAHabitTheReminderServesIsNotOutvoted() {
        // Reminder at 20:00: on ten days the user studied 40 minutes after it, on four days at
        // 10:00 on their own. The four days do not pull the reminder to the morning.
        let studied = starts(5...14, hour: 20, minute: 40, afterReminder: true) + starts(15...18, hour: 10)
        let decision = decide(nil, chosen: 20 * 60, studied, now: date(day: 18, hour: 23))
        XCTAssertEqual(decision.reason, .followsReminder)
        XCTAssertEqual(decision.later, 20 * 60)
        // Once the other hour holds more days than the reminder's, the time moves toward it.
        let changed = starts(13...14, hour: 20, minute: 40, afterReminder: true) + starts(15...18, hour: 10)
        XCTAssertEqual(decide(nil, chosen: 20 * 60, changed, now: date(day: 18, hour: 23)).later, 19 * 60 + 30)
    }

    func testFollowedRemindersNeverDriftEarlier() {
        // The user studies 5 minutes after every reminder for six weeks, after a first week of
        // studying at 21:30 on their own (the reminder was at 20:00 then).
        var times = StudyTimes()
        var state: State?
        var reminder = 20 * 60
        var history: [Int] = []
        for offset in 0..<42 {
            let midnight = calendar.date(byAdding: .day, value: offset, to: date(day: 1, hour: 0))!
            let fire = midnight.addingTimeInterval(TimeInterval(reminder) * minute)
            if offset < 5 {
                times.recordStart(at: midnight.addingTimeInterval(TimeInterval(21 * 60 + 30) * minute), lastReminder: fire, calendar: calendar)
            } else {
                times.recordStart(at: fire.addingTimeInterval(5 * minute), lastReminder: fire, calendar: calendar)
            }
            let decision = ReminderTiming.decide(previous: state, chosenMinute: reminder, starts: times.starts, now: midnight.addingTimeInterval(23 * 3600), calendar: calendar)
            XCTAssertEqual(decision.today, reminder)
            state = decision.state
            reminder = decision.later
            history.append(reminder)
        }
        XCTAssertEqual(Array(history.prefix(5)), [1200, 1200, 1230, 1260, 1260], "the first three days teach 21:30, the aim is 21:00")
        XCTAssertTrue(history[5...].allSatisfy { $0 == 1260 }, "from the sixth day the reminder's days outvote the old ones: \(history)")
        XCTAssertTrue(history.allSatisfy { $0 >= 1200 }, "\(history)")
        XCTAssertEqual(history.last, 1260)
    }

    // MARK: Summer time

    func testSummerTimeEndKeepsTheLocalTime() throws {
        var berlin = Calendar(identifier: .gregorian)
        berlin.timeZone = try XCTUnwrap(TimeZone(identifier: "Europe/Berlin"))
        // Summer time ends on Sunday 25 October 2026 (03:00 becomes 02:00): the day has 25 hours.
        var times = StudyTimes()
        for day in 21...27 {
            times.recordStart(at: date(day: day, hour: 19, in: berlin), lastReminder: nil, calendar: berlin)
        }
        XCTAssertEqual(Set(times.starts.map(\.minute)), [19 * 60], "19:00 on the clock, before and after")

        var state: State?
        var plans: [[Date]] = []
        for day in 24...27 {
            let now = date(day: day, hour: 10, in: berlin)
            let decision = decide(state, chosen: 20 * 60, times.starts, now: now, in: berlin)
            state = decision.state
            let reminders = ReminderPlanner.plan(
                feed: (1...50).map(word),
                progress: [:],
                now: now,
                minuteOfDay: decision.today,
                laterMinuteOfDay: decision.later,
                days: 2,
                dailyNewGoal: 5,
                newStudiedToday: 0,
                calendar: berlin
            )
            plans.append(reminders.map(\.fireDate))
        }
        XCTAssertEqual(plans.map { $0.map { hourMinute($0, in: berlin) } }, [
            [1200, 1170],
            [1170, 1140],
            [1140, 1110],
            [1110, 1110],
        ])
        // Saturday 20:00 to Sunday 19:30: 23.5 hours on the clock, 24.5 really (the clock went back).
        XCTAssertEqual(plans[1][0].timeIntervalSince(plans[0][0]), 24.5 * 3600)
        XCTAssertEqual(state?.decidedOn, "2026-10-27")
    }

    func testSummerTimeStartKeepsTheLocalTimeAndTheFourteenDays() throws {
        var berlin = Calendar(identifier: .gregorian)
        berlin.timeZone = try XCTUnwrap(TimeZone(identifier: "Europe/Berlin"))
        // Summer time starts on Sunday 29 March 2026 (02:00 becomes 03:00): the day has 23 hours.
        let now = date(month: 4, day: 7, hour: 0, minute: 10, in: berlin)
        let edge = [
            StudyStart(at: date(month: 3, day: 24, hour: 23, minute: 30, in: berlin), minute: 23 * 60 + 30, afterReminder: false),
            StudyStart(at: date(month: 3, day: 25, hour: 0, minute: 30, in: berlin), minute: 30, afterReminder: false),
        ]
        // By calendar days: 25 March is the oldest kept day, 24 March is not (13 × 24 hours would keep it).
        XCTAssertEqual(StudyTimes(starts: edge).recent(now: now, calendar: berlin).map(\.minute), [30])

        let reminders = ReminderPlanner.plan(
            feed: (1...50).map(word),
            progress: [:],
            now: date(month: 3, day: 28, hour: 10, in: berlin),
            minuteOfDay: 18 * 60 + 30,
            laterMinuteOfDay: 18 * 60,
            days: 3,
            dailyNewGoal: 5,
            newStudiedToday: 0,
            calendar: berlin
        )
        XCTAssertEqual(reminders.map { hourMinute($0.fireDate, in: berlin) }, [1110, 1080, 1080])
        XCTAssertEqual(reminders[1].fireDate.timeIntervalSince(reminders[0].fireDate), 22.5 * 3600)
    }

    // MARK: Backing off still holds

    func testBackingOffStillHoldsWhileTheTimeMoves() throws {
        let defaults = try freshDefaults()
        let words = (1...200).map(word)
        // The user studies at 21:00 on their own: the aim is 20:30, the start 18:00.
        let studied = starts(5...9, hour: 21)
        var state: State?
        func leave(_ now: Date) {
            ReminderLog.recordUse(at: now, defaults: defaults)
            let decision = ReminderTiming.decide(previous: state, chosenMinute: 18 * 60, starts: studied, now: now, calendar: calendar)
            state = decision.state
            let reminders = ReminderPlanner.plan(
                feed: words,
                progress: [:],
                now: now,
                minuteOfDay: decision.today,
                laterMinuteOfDay: decision.later,
                days: 7,
                dailyNewGoal: 5,
                newStudiedToday: 0,
                calendar: calendar,
                recent: ReminderLog.recentlySent(now: now, defaults: defaults)
            )
            XCTAssertLessThanOrEqual(reminders.count, ReminderBackoff.pauseAfter)
            ReminderLog.replaceScheduled(with: reminders.map(\.sent), now: now, defaults: defaults)
        }
        func opening(_ now: Date) -> ReminderBackoff.Action {
            return ReminderLog.openingFollowUp(isActive: true, widgetUse: nil, now: now, calendar: calendar, defaults: defaults)
        }

        XCTAssertEqual(opening(date(day: 11, hour: 9)), .nothing)
        leave(date(day: 12, hour: 10))
        XCTAssertEqual(
            ReminderLog.recentlySent(now: date(day: 14, hour: 21), defaults: defaults).map(\.fireDate),
            [date(day: 12, hour: 18), date(day: 13, hour: 18, minute: 30), date(day: 14, hour: 18, minute: 30)]
        )
        // Three ignored, whatever their times: the question.
        XCTAssertEqual(opening(date(day: 15, hour: 9)), .askForTime)
        leave(date(day: 15, hour: 9, minute: 10))
        // A whole plan ignored (18:30, then 19:00 every day): the pause.
        XCTAssertEqual(opening(date(day: 23, hour: 12)), .pause)
        XCTAssertEqual(ReminderLog.recentlySent(now: date(day: 23, hour: 12), defaults: defaults).count, ReminderBackoff.pauseAfter)
    }

    // MARK: The record

    func testStartsAreKeptForFourteenDays() {
        var times = StudyTimes(starts: starts(1...3, hour: 19))
        times.recordStart(at: date(day: 16, hour: 20, minute: 15), lastReminder: nil, calendar: calendar)
        XCTAssertEqual(times.starts.map(\.at), [date(day: 3, hour: 19), date(day: 16, hour: 20, minute: 15)])
        XCTAssertEqual(times.starts.last?.minute, 20 * 60 + 15)
    }

    func testAStartWithinAnHourOfAReminderIsTheReminders() {
        var times = StudyTimes()
        let fire = date(day: 12, hour: 18, minute: 30)
        times.recordStart(at: date(day: 12, hour: 19, minute: 30), lastReminder: fire, calendar: calendar)
        times.recordStart(at: date(day: 12, hour: 19, minute: 31), lastReminder: fire, calendar: calendar)
        times.recordStart(at: date(day: 12, hour: 18, minute: 20), lastReminder: fire, calendar: calendar)
        XCTAssertEqual(times.starts.map(\.afterReminder), [false, true, false], "sorted by time; one hour is the reminder's, a start before it is not")
    }

    func testTheRecorderWritesOneStartPerStretch() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("ReminderTimingTests-\(UUID().uuidString)")
        addTeardownBlock {
            try? FileManager.default.removeItem(at: folder)
        }
        let url = folder.appendingPathComponent("study_times.json")
        let recorder = StudyTimeRecorder(fileURL: url, calendar: calendar)
        let fire = date(day: 12, hour: 18, minute: 30)
        var asked = 0
        func answer(_ at: Date) {
            recorder.recordAnswer(at: at) {
                asked += 1
                return fire
            }
        }
        answer(date(day: 12, hour: 18, minute: 45))
        answer(date(day: 12, hour: 18, minute: 50))
        answer(date(day: 12, hour: 19, minute: 15))
        answer(date(day: 12, hour: 19, minute: 50))
        XCTAssertEqual(asked, 2, "the reminder is looked up only when a stretch starts")
        let kept = recorder.snapshot()
        XCTAssertEqual(kept.starts.map(\.minute), [18 * 60 + 45, 19 * 60 + 50])
        XCTAssertEqual(kept.starts.map(\.afterReminder), [true, false])
        XCTAssertEqual(StudyTimeRecorder(fileURL: url, calendar: calendar).snapshot(), kept, "kept in the file")

        recorder.reset()
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        XCTAssertTrue(recorder.snapshot().starts.isEmpty)
        answer(date(day: 12, hour: 19, minute: 55))
        XCTAssertEqual(recorder.snapshot().starts.count, 1, "after a reset the next answer starts a stretch")
    }

    func testADamagedFileIsReplaced() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("ReminderTimingTests-\(UUID().uuidString)")
        addTeardownBlock {
            try? FileManager.default.removeItem(at: folder)
        }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("study_times.json")
        try Data("not json".utf8).write(to: url)
        let recorder = StudyTimeRecorder(fileURL: url, calendar: calendar)
        XCTAssertTrue(recorder.snapshot().starts.isEmpty)
        recorder.recordAnswer(at: date(day: 12, hour: 19)) { nil }
        XCTAssertEqual(StudyTimeRecorder(fileURL: url, calendar: calendar).snapshot().starts.count, 1)
    }

    func testTheSettingKeepsTheUsersTime() throws {
        let defaults = try freshDefaults()
        XCTAssertFalse(ReminderTimingStore.isOn(defaults: defaults), "off by default")
        ReminderTimingStore.turnOn(chosenMinute: 20 * 60, defaults: defaults)
        XCTAssertTrue(ReminderTimingStore.isOn(defaults: defaults))
        XCTAssertEqual(ReminderTimingStore.chosenMinute(defaults: defaults), 20 * 60)
        XCTAssertNil(ReminderTimingStore.state(defaults: defaults))
        let state = State(minute: 1200, next: 1170, decidedOn: "2026-10-23")
        ReminderTimingStore.save(state, defaults: defaults)
        XCTAssertEqual(ReminderTimingStore.state(defaults: defaults), state)
        ReminderTimingStore.turnOff(defaults: defaults)
        XCTAssertFalse(ReminderTimingStore.isOn(defaults: defaults))
        XCTAssertNil(ReminderTimingStore.chosenMinute(defaults: defaults))
        XCTAssertNil(ReminderTimingStore.state(defaults: defaults))
    }

    // MARK: The line in "Ayarlar"

    func testExplanationsArePlainTurkish() {
        let reasons: [ReminderTiming.Reason] = [
            .learning, .followsReminder, .varied, .settled(usual: 1140), .moving(usual: 1140, aim: 1110),
            .latestLimit(usual: 1410), .earliestLimit(usual: 435),
        ]
        for reason in reasons {
            let text = ReminderTiming.explanation(reason)
            XCTAssertFalse(text.contains("!"), text)
            XCTAssertNil(text.range(of: #"\d\d:\d\d['’]"#, options: .regularExpression), "no suffix after a time: \(text)")
            let sentences = text.split(separator: ".").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            XCTAssertLessThanOrEqual(sentences.count, 2, text)
            for sentence in sentences {
                XCTAssertLessThanOrEqual(sentence.split(separator: " ").count, 12, sentence)
            }
        }
        XCTAssertEqual(
            ReminderTiming.explanation(.moving(usual: 1140, aim: 1110)),
            "Genelde 19:00 civarında çalışıyorsun. Saati her gün biraz 18:30 saatine yaklaştırıyoruz."
        )
        XCTAssertEqual(
            ReminderTiming.explanation(.latestLimit(usual: 1410)),
            "Genelde 23:30 civarında çalışıyorsun. Geceleri hatırlatmıyoruz, en geç 22:30."
        )
    }

    func testClock() {
        XCTAssertEqual(ReminderTiming.clock(0), "00:00")
        XCTAssertEqual(ReminderTiming.clock(9 * 60 + 5), "09:05")
        XCTAssertEqual(ReminderTiming.clock(23 * 60 + 59), "23:59")
    }
}
