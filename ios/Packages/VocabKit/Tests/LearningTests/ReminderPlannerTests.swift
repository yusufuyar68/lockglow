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
            WidgetWord(
                id: id, lemma: "w\(id)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e",
                glossTR: "anlam\(id)"
            )
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

    func testNewWordsComeFromTheDeckAndReviewsFromEveryWord() {
        // Word 1 is outside the chosen deck (words 11 and 12) but due: it still counts.
        let reminders = ReminderPlanner.plan(
            feed: feed(1...20),
            newWordFeed: feed(11...12),
            progress: [1: learning(1, due: date(day: 12, hour: 9))],
            now: date(day: 12, hour: 10),
            minuteOfDay: evening,
            days: 2,
            dailyNewGoal: 5,
            newStudiedToday: 0,
            calendar: calendar
        )
        XCTAssertEqual(reminders.map(\.dueCount), [1, 1])
        XCTAssertEqual(reminders.map(\.newCount), [2, 2])
    }

    func testInvalidInputGivesNoReminders() {
        XCTAssertTrue(plan(feed: feed(1...5), now: date(day: 12, hour: 10), days: 0).isEmpty)
        let late = ReminderPlanner.plan(
            feed: feed(1...5), progress: [:], now: date(day: 12, hour: 10), minuteOfDay: 1440,
            days: 3, dailyNewGoal: 5, newStudiedToday: 0, calendar: calendar
        )
        XCTAssertTrue(late.isEmpty)
    }

    func testAWeekAheadGivesOneReminderADay() {
        let reminders = plan(feed: feed(1...20), now: date(day: 12, hour: 10), days: 7)
        XCTAssertEqual(reminders.map(\.fireDate), (12...18).map { date(day: $0, hour: 20) })
    }

    // MARK: Text

    func testReviewReminderNamesTheMostOverdueWordWithoutItsMeaning() {
        let progress = [
            1: learning(1, due: date(day: 12, hour: 9)),
            2: learning(2, due: date(day: 11, hour: 9)),  // most overdue
        ]
        // New words are offered too, but the text calls to the reviews.
        let reminder = plan(feed: feed(1...20), progress: progress, now: date(day: 12, hour: 10)).first
        XCTAssertEqual(reminder?.dueCount, 2)
        XCTAssertEqual(reminder?.newCount, 5)
        XCTAssertEqual(reminder?.word, "w2")
        XCTAssertNil(reminder?.meaning, "a review's meaning would give the answer away")
        for variant in 0..<ReminderText.variantCount {
            let message = ReminderText.message(dueCount: 2, newCount: 5, word: "w2", meaning: nil, variant: variant)
            XCTAssertTrue(message.title.contains("w2") || message.body.contains("w2"), "variant \(variant)")
            XCTAssertFalse((message.title + message.body).lowercased().contains("yeni"), "variant \(variant)")
        }
    }

    func testNewWordReminderNamesTheNextNewWordWithItsMeaning() {
        let progress = [1: Leitner.markKnown(WordProgress(wordID: 1), at: date(day: 12, hour: 9))]
        let reminder = plan(feed: feed(1...20), progress: progress, now: date(day: 12, hour: 10)).first
        XCTAssertEqual(reminder?.dueCount, 0)
        XCTAssertEqual(reminder?.word, "w2")
        XCTAssertEqual(reminder?.meaning, "anlam2")
        XCTAssertTrue(reminder.map { $0.title.contains("w2") || $0.body.contains("w2") } ?? false)
    }

    func testExampleTexts() {
        func text(_ due: Int, _ new: Int, _ word: String?, _ meaning: String?, _ variant: Int) -> [String] {
            let message = ReminderText.message(dueCount: due, newCount: new, word: word, meaning: meaning, variant: variant)
            return [message.title, message.body]
        }
        XCTAssertEqual(text(4, 5, "breakfast", nil, 0), ["Hatırlıyor musun: breakfast?", "Önce kendin hatırla, sonra anlamına bak."])
        XCTAssertEqual(text(4, 5, "breakfast", nil, 1), ["breakfast ne demekti?", "Unuttuysan sorun değil, tekrar bunun için var."])
        XCTAssertEqual(text(4, 5, "breakfast", nil, 2), ["Kısa bir tekrar", "breakfast ve 3 kelime daha hazır."])
        XCTAssertEqual(text(1, 0, "breakfast", nil, 2), ["Kısa bir tekrar", "Bugün yalnızca breakfast var."])
        XCTAssertEqual(text(0, 5, "spoon", "kaşık", 0), ["Sıradaki kelime: spoon", "Örnek cümlesiyle öğren, daha kolay akılda kalır."])
        XCTAssertEqual(text(0, 5, "spoon", "kaşık", 1), ["Yeni kelimeler hazır", "Sırada spoon var. Sesli söylemek akılda tutmaya yardım eder."])
        XCTAssertEqual(text(0, 5, "spoon", "kaşık", 2), ["Yeni bir kelime: spoon", "Anlamı: kaşık. Örnek cümlesi uygulamada."])
        XCTAssertEqual(text(0, 5, "how about", "ne dersin?", 2), ["Yeni bir kelime: how about", "Anlamı: ne dersin? Örnek cümlesi uygulamada."])
        XCTAssertEqual(text(0, 5, "spoon", nil, 2), ["Yeni bir kelime: spoon", "Bugün 5 yeni kelime var, istersen bir göz at."])
        // Without a word: the counts only.
        XCTAssertEqual(text(1, 5, nil, nil, 0), ["Tekrar zamanı", "Bir kelime tekrar için hazır."])
        XCTAssertEqual(text(12, 5, nil, nil, 1), ["Tekrar zamanı", "12 kelime tekrar için hazır."])
        XCTAssertEqual(text(0, 5, nil, nil, 2), ["Yeni kelimeler hazır", "Bugün 5 yeni kelime var, istersen bir göz at."])
        // Any variant number wraps around.
        XCTAssertEqual(text(4, 5, "breakfast", nil, 5), text(4, 5, "breakfast", nil, 2))
        XCTAssertEqual(text(4, 5, "breakfast", nil, -1), text(4, 5, "breakfast", nil, 2))
    }

    func testEveryTextIsShortCalmAndOneLine() {
        let longest = String(repeating: "a", count: ReminderText.maxShownLength)
        for due in [0, 1, 4, 250] {
            for new in [0, 1, 5] where due + new > 0 {
                for word in ["breakfast", "Could you tell me the way to", longest, nil] {
                    for meaning in ["kahvaltı", "ne dersin?", longest, nil] {
                        for variant in 0..<ReminderText.variantCount {
                            let m = ReminderText.message(dueCount: due, newCount: new, word: word, meaning: meaning, variant: variant)
                            let label = "\(due) \(new) \(word ?? "-") \(meaning ?? "-") \(variant)"
                            XCTAssertFalse(m.title.isEmpty, label)
                            XCTAssertFalse(m.body.isEmpty, label)
                            XCTAssertLessThanOrEqual(m.title.count, 52, label)
                            XCTAssertLessThanOrEqual(m.body.count, 90, label)
                            let all = m.title + " " + m.body
                            XCTAssertFalse(all.contains { $0.isNewline }, label)
                            XCTAssertFalse(all.unicodeScalars.contains { $0.properties.isEmojiPresentation }, label)
                            // No pressure, streaks or guilt.
                            for phrase in ["!", "seri", "üst üste", "kaçır", "hemen", "unutma"] {
                                XCTAssertFalse(all.lowercased().contains(phrase), "\(label): \(phrase)")
                            }
                        }
                    }
                }
            }
        }
    }

    func testTextTurnsFromDayToDay() {
        let reminders = plan(feed: feed(1...20), now: date(day: 12, hour: 10), days: 4)
        XCTAssertEqual(reminders.count, 4)
        XCTAssertEqual(Set(reminders.prefix(3).map(\.variant)), Set(0..<ReminderText.variantCount))
        XCTAssertEqual(Set(reminders.prefix(3).map(\.title)).count, 3, "three days in a row read differently")
        XCTAssertEqual(reminders[3].variant, reminders[0].variant)
    }

    func testPlanningAgainKeepsADaysText() {
        // The app plans again every time it goes to the background: day 14 must not change its text.
        let early = plan(feed: feed(1...20), now: date(day: 12, hour: 10))
        let later = plan(feed: feed(1...20), now: date(day: 13, hour: 21))
        let first = early.first { $0.fireDate == date(day: 14, hour: 20) }
        let second = later.first { $0.fireDate == date(day: 14, hour: 20) }
        XCTAssertNotNil(first)
        XCTAssertEqual(first?.variant, second?.variant)
        XCTAssertEqual(first?.title, second?.title)
        XCTAssertEqual(first?.body, second?.body)
    }

    func testVariantFollowsTheLocalDay() {
        var istanbul = Calendar(identifier: .gregorian)
        istanbul.timeZone = TimeZone(secondsFromGMT: 3 * 3600)!
        // 01:00 and 23:30 local time are the same day, 23:30 and 00:30 are not (by UTC it is the
        // other way round).
        let morning = istanbul.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 1))!
        let night = istanbul.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 23, minute: 30))!
        let afterMidnight = istanbul.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: 0, minute: 30))!
        XCTAssertEqual(ReminderText.variant(for: morning, calendar: istanbul), ReminderText.variant(for: night, calendar: istanbul))
        XCTAssertNotEqual(ReminderText.variant(for: night, calendar: istanbul), ReminderText.variant(for: afterMidnight, calendar: istanbul))
    }

    func testWordsUnfitForANotificationAreLeftOut() {
        XCTAssertEqual(ReminderText.shownWord("  breakfast \n"), "breakfast")
        XCTAssertEqual(ReminderText.shownWord("look\nafter"), "look after")
        XCTAssertNil(ReminderText.shownWord(nil))
        XCTAssertNil(ReminderText.shownWord("   "))
        XCTAssertNil(ReminderText.shownWord(String(repeating: "a", count: ReminderText.maxShownLength + 1)))

        // A lemma too long for the line: the text falls back to the count.
        let long = String(repeating: "a", count: 40)
        let words = [WidgetWord(id: 1, lemma: long, pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e", glossTR: "anlam")]
        let review = plan(feed: words, progress: [1: learning(1, due: date(day: 12, hour: 9))], now: date(day: 12, hour: 10), days: 1)
        XCTAssertNil(review.first?.word)
        XCTAssertNil(review.first?.meaning)
        XCTAssertEqual(review.first?.title, "Tekrar zamanı")
        XCTAssertEqual(review.first?.body, "Bir kelime tekrar için hazır.")
        let fresh = plan(feed: words, now: date(day: 12, hour: 10), days: 1)
        XCTAssertEqual(fresh.first?.newCount, 1)
        XCTAssertNil(fresh.first?.word)
        XCTAssertFalse((fresh.first?.body ?? "").contains("anlam"))
    }
}
