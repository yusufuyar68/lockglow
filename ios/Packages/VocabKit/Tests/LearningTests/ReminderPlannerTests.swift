import XCTest
import CoreModels
import Learning

final class ReminderPlannerTests: XCTestCase {
    private var calendar: Calendar!
    private let evening = 20 * 60
    private let hour: TimeInterval = 3600

    override func setUp() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        calendar = utc
    }

    private func date(day: Int, hour: Int, minute: Int = 0) -> Date {
        return calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
    }

    /// Letters instead of digits ("w12" would be "wbc"), so a text with a digit is a count.
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
        return ids.map(word)
    }

    /// A card with everything every kind needs.
    private func fullDetail(_ word: WidgetWord) -> CardDetail {
        let lemma = word.lemma
        return CardDetail(
            examples: [
                CardDetail.Example(en: "I like the \(lemma) a lot.", tr: "Bunu çok seviyorum."),
                CardDetail.Example(en: "The \(lemma) is on the table.", tr: "Masanın üstünde duruyor."),
            ],
            collocations: ["a big \(lemma)"],
            mistakes: [CardDetail.Mistake(wrong: "I like \(lemma).", right: "I like the \(lemma).", why: "Burada 'the' gerekir.")],
            falseFriend: CardDetail.FalseFriend(trWord: "benzer", trMeans: "başka bir şey, öteki", enForThat: "other"),
            mnemonicTR: "Sesini düşün, anlamı aklına gelir."
        )
    }

    private func learning(_ id: Int, due: Date, box: Int = 2) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = box
        p.dueAt = due
        return p
    }

    private func known(_ id: Int, at date: Date) -> WordProgress {
        return Leitner.markKnown(WordProgress(wordID: id), at: date)
    }

    private func seen(_ id: Int) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.exposures = 1
        return p
    }

    private func plan(
        feed: [WidgetWord],
        newWordFeed: [WidgetWord]? = nil,
        progress: [Int: WordProgress] = [:],
        now: Date,
        days: Int = 3,
        goal: Int = 5,
        studiedToday: Int = 0,
        recent: [SentReminder] = [],
        details: Bool = false
    ) -> [Reminder] {
        return ReminderPlanner.plan(
            feed: feed,
            newWordFeed: newWordFeed,
            progress: progress,
            now: now,
            minuteOfDay: evening,
            days: days,
            dailyNewGoal: goal,
            newStudiedToday: studiedToday,
            calendar: calendar,
            recent: recent,
            detail: { details ? self.fullDetail($0) : nil }
        )
    }

    // MARK: Days and counts

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
            progress[id] = known(id, at: date(day: 12, hour: 9))
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
        let reminders = plan(
            feed: feed(1...20),
            newWordFeed: feed(11...12),
            progress: [1: learning(1, due: date(day: 12, hour: 9))],
            now: date(day: 12, hour: 10),
            days: 2
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

    func testNeverMoreRemindersThanThePauseLimit() {
        // Unanswered, the plan simply runs out: the pause holds without the app running.
        let reminders = plan(feed: feed(1...200), now: date(day: 12, hour: 10), days: 14)
        XCTAssertEqual(reminders.count, ReminderBackoff.pauseAfter)
        XCTAssertEqual(reminders.last?.fireDate, date(day: 18, hour: 20))
    }

    func testTheNextDaysMayHaveAnotherTime() {
        // "Saati benim için seç": today keeps 20:00, the next days come at 19:30.
        func times(now: Date, later: Int) -> [Date] {
            return ReminderPlanner.plan(
                feed: feed(1...20), progress: [:], now: now, minuteOfDay: evening, laterMinuteOfDay: later,
                days: 3, dailyNewGoal: 5, newStudiedToday: 0, calendar: calendar
            ).map(\.fireDate)
        }
        XCTAssertEqual(times(now: date(day: 12, hour: 10), later: evening - 30), [
            date(day: 12, hour: 20), date(day: 13, hour: 19, minute: 30), date(day: 14, hour: 19, minute: 30),
        ])
        XCTAssertEqual(times(now: date(day: 12, hour: 20, minute: 5), later: evening - 30), [
            date(day: 13, hour: 19, minute: 30), date(day: 14, hour: 19, minute: 30),
        ])
        XCTAssertTrue(times(now: date(day: 12, hour: 10), later: 1440).isEmpty)
        XCTAssertTrue(times(now: date(day: 12, hour: 10), later: -1).isEmpty)
    }

    func testADayWhoseReminderCameGetsNoSecondOne() {
        // Today's came at 19:30, then the time was set to 20:00 (by hand, or the option turned off).
        let came = [SentReminder(fireDate: date(day: 12, hour: 19, minute: 30), kind: .meaning, wordID: 1)]
        XCTAssertEqual(plan(feed: feed(1...20), now: date(day: 12, hour: 19, minute: 45), recent: came).first?.fireDate, date(day: 13, hour: 20))
        // One that has not come yet does not count.
        let ahead = [SentReminder(fireDate: date(day: 12, hour: 21), kind: .meaning, wordID: 1)]
        XCTAssertEqual(plan(feed: feed(1...20), now: date(day: 12, hour: 19, minute: 45), recent: ahead).first?.fireDate, date(day: 12, hour: 20))
        // Yesterday's does not keep today's away.
        let yesterday = [SentReminder(fireDate: date(day: 11, hour: 20), kind: .meaning, wordID: 1)]
        XCTAssertEqual(plan(feed: feed(1...20), now: date(day: 12, hour: 10), recent: yesterday).first?.fireDate, date(day: 12, hour: 20))
    }

    // MARK: Which word (2.1 rule a)

    func testNeverNamesAWordTekrarAsksSoon() {
        let progress = [
            1: learning(1, due: date(day: 12, hour: 19)),  // due before the reminder
            2: learning(2, due: date(day: 12, hour: 23)),  // asked within 6 hours of it
            3: learning(3, due: date(day: 13, hour: 9)),   // asked 13 hours later
        ]
        let reminder = plan(feed: feed(1...3), progress: progress, now: date(day: 12, hour: 10), days: 1).first
        XCTAssertEqual(reminder?.dueCount, 1)
        XCTAssertEqual(reminder?.wordID, 3)
        XCTAssertEqual(reminder?.title, "\(name(3)) = anlam \(name(3))")
        XCTAssertEqual(reminder?.body, "I like the \(name(3)) a lot.")
    }

    func testEveryDayOfTheWeekKeepsTheRule() throws {
        // Boxes 1 to 5 due on different days: no day names a word due within 6 hours of it.
        var progress: [Int: WordProgress] = [:]
        for id in 1...40 {
            progress[id] = learning(id, due: date(day: 12, hour: 8).addingTimeInterval(Double(id) * 5 * hour), box: id % 5 + 1)
        }
        let reminders = plan(feed: feed(1...40), progress: progress, now: date(day: 12, hour: 7), days: 7, details: true)
        XCTAssertEqual(reminders.count, 7)
        for reminder in reminders {
            let id = try XCTUnwrap(reminder.wordID)
            let due = try XCTUnwrap(progress[id]?.dueAt)
            XCTAssertGreaterThan(due, reminder.fireDate.addingTimeInterval(ReminderPlanner.quietWindow), "\(reminder.fireDate)")
        }
    }

    func testAWordAnsweredTodayMayBeTonightsWord() {
        let answered = Leitner.review(WordProgress(wordID: 1), grade: .good, at: date(day: 12, hour: 9))
        XCTAssertEqual(answered.dueAt, date(day: 13, hour: 9))
        // Words 2-6 are tonight's new words (left out); word 1 is the only one to name.
        let reminder = plan(feed: feed(1...6), progress: [1: answered], now: date(day: 12, hour: 10), days: 1).first
        XCTAssertEqual(reminder?.newCount, 5)
        XCTAssertEqual(reminder?.wordID, 1)
        XCTAssertEqual(reminder?.kind, .meaning)
        // Tomorrow the same word is due at 9:00, before the reminder: it is not tomorrow's word.
        let tomorrow = plan(feed: feed(1...6), progress: [1: answered], now: date(day: 12, hour: 21), days: 2).first
        XCTAssertEqual(tomorrow?.fireDate, date(day: 13, hour: 20))
        XCTAssertEqual(tomorrow?.dueCount, 1)
        XCTAssertNil(tomorrow?.wordID)
        XCTAssertEqual(tomorrow?.kind, .plain)
    }

    func testLearningWordsComeBeforeKnownWords() {
        let progress = [
            1: known(1, at: date(day: 10, hour: 9)),
            2: learning(2, due: date(day: 16, hour: 9)),
            3: learning(3, due: date(day: 12, hour: 9)),  // due: tonight's reminder is for it
        ]
        let reminder = plan(feed: feed(1...3), progress: progress, now: date(day: 12, hour: 10), days: 1).first
        XCTAssertEqual(reminder?.wordID, 2)
    }

    func testNeverNamesANewWordTheNextRoundsOffer() {
        // Nothing studied: tonight's 5 new words and tomorrow's next 5 are left out; tonight's
        // word is the first after them, tomorrow's the first after its own two rounds.
        let reminders = plan(feed: feed(1...30), now: date(day: 12, hour: 10), days: 2)
        XCTAssertEqual(reminders.map(\.wordID), [6, 11])
        XCTAssertEqual(reminders.map(\.kind), [.newWord, .newWord])
        XCTAssertEqual(reminders.first?.title, "Yeni kelime: \(name(6))")
        XCTAssertEqual(reminders.first?.body, "anlam \(name(6)) · I like the \(name(6)) a lot.")
    }

    func testANewWordSeenOnTheWidgetComesFirst() {
        let reminder = plan(feed: feed(1...30), progress: [20: seen(20), 3: seen(3)], now: date(day: 12, hour: 10), days: 1).first
        // Word 3 was seen too, but tonight's round offers it.
        XCTAssertEqual(reminder?.wordID, 20)
    }

    func testNoFittingWordGivesACalmTextWithoutCounts() {
        // Every word is due: none may be named.
        var progress: [Int: WordProgress] = [:]
        for id in 1...12 {
            progress[id] = learning(id, due: date(day: 12, hour: 9))
        }
        let reminder = plan(feed: feed(1...12), progress: progress, now: date(day: 12, hour: 10), days: 1).first
        XCTAssertEqual(reminder?.dueCount, 12)
        XCTAssertEqual(reminder?.kind, .plain)
        XCTAssertNil(reminder?.wordID)
        XCTAssertEqual(reminder?.title, "Kelimeler hazır")
        XCTAssertEqual(reminder?.body, "Birkaç dakikan olduğunda bakabilirsin.")
    }

    // MARK: Kinds turn (2.10: at least 6, none twice within 5 days)

    private func studiedFeed() -> (feed: [WidgetWord], progress: [Int: WordProgress]) {
        var progress: [Int: WordProgress] = [:]
        for id in 1...20 {
            progress[id] = learning(id, due: date(day: 30, hour: 9))
        }
        return (feed(1...40), progress)
    }

    func testAWeekUsesSevenDifferentKinds() {
        let (words, progress) = studiedFeed()
        let reminders = plan(feed: words, progress: progress, now: date(day: 12, hour: 10), days: 7, goal: 2, details: true)
        XCTAssertEqual(reminders.count, 7)
        XCTAssertEqual(Set(reminders.map(\.kind)), Set(ReminderKind.rotation))
        // No word twice within five days.
        for (i, earlier) in reminders.enumerated() {
            for later in reminders[(i + 1)...].prefix(ReminderPlanner.repeatGapDays) {
                XCTAssertNotEqual(earlier.wordID, later.wordID, "\(earlier.fireDate) \(later.fireDate)")
            }
        }
        // Each day starts at its own turn of the rotation.
        for reminder in reminders {
            let day = ReminderPlanner.dayNumber(for: reminder.fireDate, calendar: calendar)
            XCTAssertEqual(reminder.kind, ReminderKind.rotation[day % ReminderKind.rotation.count])
        }
    }

    func testDeliveredRemindersCountAgainstRepeats() throws {
        let (words, progress) = studiedFeed()
        let fresh = plan(feed: words, progress: progress, now: date(day: 12, hour: 10), days: 1, goal: 2, details: true).first
        let todaysKind = try XCTUnwrap(fresh?.kind)
        let todaysWord = try XCTUnwrap(fresh?.wordID)
        // The same kind and word went out four days ago: tonight takes another of each.
        let recent = [SentReminder(fireDate: date(day: 8, hour: 20), kind: todaysKind, wordID: todaysWord)]
        let reminder = plan(feed: words, progress: progress, now: date(day: 12, hour: 10), days: 1, goal: 2, recent: recent, details: true).first
        XCTAssertNotEqual(reminder?.kind, todaysKind)
        XCTAssertNotEqual(reminder?.wordID, todaysWord)
        // Six days ago is long enough.
        let older = [SentReminder(fireDate: date(day: 6, hour: 20), kind: todaysKind, wordID: todaysWord)]
        XCTAssertEqual(plan(feed: words, progress: progress, now: date(day: 12, hour: 10), days: 1, goal: 2, recent: older, details: true).first, fresh)
    }

    func testWhenKindsRunOutTheLongestUnusedComesBack() {
        // Without card details only "meaning" and "newWord" can be written.
        let (words, progress) = studiedFeed()
        let reminders = plan(feed: words, progress: progress, now: date(day: 12, hour: 10), days: 4, goal: 2)
        XCTAssertTrue(reminders.allSatisfy { [.meaning, .newWord].contains($0.kind) })
        for (yesterday, today) in zip(reminders, reminders.dropFirst()) {
            XCTAssertNotEqual(yesterday.kind, today.kind, "\(today.fireDate)")
        }
    }

    func testPlanningAgainKeepsADaysText() {
        // The app plans again every time it goes to the background: day 14 keeps its text while
        // the progress stays the same and the delivered days are the planned ones. (No new-word
        // goal: which new words are left out depends on how many days ahead a day is.)
        var (words, progress) = studiedFeed()
        words.append(word(41))
        progress[41] = learning(41, due: date(day: 12, hour: 9))
        let early = plan(feed: words, progress: progress, now: date(day: 12, hour: 10), days: 4, goal: 0, details: true)
        let later = plan(feed: words, progress: progress, now: date(day: 13, hour: 21), days: 4, goal: 0, recent: early.prefix(2).map(\.sent), details: true)
        let first = early.first { $0.fireDate == date(day: 14, hour: 20) }
        let second = later.first { $0.fireDate == date(day: 14, hour: 20) }
        XCTAssertNotNil(first)
        XCTAssertEqual(first, second)
    }

    func testDayNumberFollowsTheLocalDay() {
        var istanbul = Calendar(identifier: .gregorian)
        istanbul.timeZone = TimeZone(secondsFromGMT: 3 * 3600)!
        // 01:00 and 23:30 local time are the same day, 23:30 and 00:30 are not (by UTC it is the
        // other way round).
        let morning = istanbul.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 1))!
        let night = istanbul.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 23, minute: 30))!
        let afterMidnight = istanbul.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: 0, minute: 30))!
        XCTAssertEqual(ReminderPlanner.dayNumber(for: morning, calendar: istanbul), ReminderPlanner.dayNumber(for: night, calendar: istanbul))
        XCTAssertEqual(ReminderPlanner.dayNumber(for: afterMidnight, calendar: istanbul), ReminderPlanner.dayNumber(for: night, calendar: istanbul) + 1)
    }

    // MARK: Texts

    private let borrow = WidgetWord(
        id: 1, lemma: "borrow", pos: "v", level: "A2", defMicro: "take and give back later",
        defShort: "s", exampleEN: "Can I borrow your pen for a minute?", glossTR: "ödünç almak"
    )

    private let borrowCard = CardDetail(
        examples: [
            CardDetail.Example(en: "Can I borrow your pen for a minute?", tr: "Kalemini bir dakikalığına ödünç alabilir miyim?"),
            CardDetail.Example(en: "She borrowed some money from her brother.", tr: "Kardeşinden biraz para ödünç aldı."),
        ],
        collocations: ["borrow money", "borrow a book"],
        mistakes: [CardDetail.Mistake(
            wrong: "Can you borrow me your pen?",
            right: "Can you lend me your pen?",
            why: "'Borrow' yalnızca alan kişi için; veren kişi 'lend' kullanır."
        )],
        mnemonicTR: "Borrow ≈ BORÇ alırım. Borç alan 'borrow' der, borç veren 'lend'.",
        quiz: CardDetail.Quiz(cloze: "Could I ______ your charger? Mine is dead.", answer: "borrow", distractors: ["lend", "give", "owe"])
    )

    private func text(_ kind: ReminderKind, _ word: WidgetWord, _ detail: CardDetail?) -> [String]? {
        return ReminderText.message(kind, word: word, detail: detail).map { [$0.title, $0.body] }
    }

    func testExampleTexts() {
        XCTAssertEqual(text(.meaning, borrow, borrowCard), ["borrow = ödünç almak", "Can I borrow your pen for a minute?"])
        XCTAssertEqual(text(.wordOfTheDay, borrow, borrowCard), ["Bugünün kelimesi: borrow", "ödünç almak · borrow money"])
        XCTAssertEqual(text(.mistake, borrow, borrowCard), [
            "Dikkat: borrow",
            "Doğrusu: Can you lend me your pen? 'Borrow' yalnızca alan kişi için; veren kişi 'lend' kullanır.",
        ])
        XCTAssertEqual(text(.example, borrow, borrowCard), [
            "Örnek cümle: borrow",
            "She borrowed some money from her brother. Türkçesi: Kardeşinden biraz para ödünç aldı.",
        ])
        XCTAssertEqual(text(.mnemonic, borrow, borrowCard), [
            "Hafıza ipucu: borrow",
            "Borrow ≈ BORÇ alırım. Borç alan 'borrow' der, borç veren 'lend'.",
        ])
        XCTAssertNil(text(.falseFriend, borrow, borrowCard), "borrow has no false friend")

        let breakWord = WidgetWord(id: 2, lemma: "break", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "Let's take a short break.", glossTR: "mola")
        let breakCard = CardDetail(collocations: ["take a break", "lunch break"])
        XCTAssertEqual(text(.wordOfTheDay, breakWord, breakCard), ["Bugünün kelimesi: break", "mola · take a break"])

        let actually = WidgetWord(id: 4, lemma: "actually", pos: "adv", level: "A2", defMicro: "m", defShort: "s", exampleEN: "Actually, I like it.", glossTR: "aslında, gerçekte")
        let actuallyCard = CardDetail(falseFriend: CardDetail.FalseFriend(trWord: "aktüel", trMeans: "güncel, şu anki", enForThat: "current / currently"))
        XCTAssertEqual(text(.falseFriend, actually, actuallyCard), [
            "Sahte dost: actually",
            "aslında, gerçekte demek; aktüel değil. \"güncel\" için current / currently.",
        ])

        let spoon = WidgetWord(id: 5, lemma: "spoon", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "Can I have a spoon, please?", glossTR: "kaşık")
        XCTAssertEqual(text(.newWord, spoon, nil), ["Yeni kelime: spoon", "kaşık · Can I have a spoon, please?"])
        XCTAssertEqual(text(.meaning, spoon, nil), ["spoon = kaşık", "Can I have a spoon, please?"])
        XCTAssertEqual(text(.plain, spoon, nil), ["Kelimeler hazır", "Birkaç dakikan olduğunda bakabilirsin."])
    }

    func testWithoutTheCardOnlyMeaningAndNewWord() {
        for kind in ReminderKind.rotation where ![.meaning, .newWord].contains(kind) {
            XCTAssertNil(text(kind, borrow, nil), "\(kind)")
        }
    }

    func testTheQuizSentenceIsNeverShown() {
        // The first example is the quiz sentence with the answer filled in: the next one is used.
        let card = CardDetail(
            examples: [
                CardDetail.Example(en: "Could I borrow your charger? Mine is dead.", tr: "a"),
                CardDetail.Example(en: "She borrowed some money.", tr: "b"),
            ],
            quiz: borrowCard.quiz
        )
        XCTAssertEqual(text(.meaning, borrow, card)?.last, "She borrowed some money.")
        XCTAssertEqual(text(.example, borrow, card)?.last, "She borrowed some money. Türkçesi: b")
        let only = CardDetail(examples: [CardDetail.Example(en: "could i borrow your charger?  mine is dead.", tr: "a")], quiz: borrowCard.quiz)
        XCTAssertNil(text(.meaning, borrow, only))
    }

    func testTheWrongSentenceIsNeverShown() {
        let long = String(repeating: "uzun açıklama ", count: 9)
        let card = CardDetail(mistakes: [CardDetail.Mistake(wrong: "I listen music.", right: "I listen to music every single day of the week.", why: long + "kısa değil.")])
        // Right sentence and why do not fit together, why alone does not fit either.
        XCTAssertNil(text(.mistake, borrow, card))
        let fits = CardDetail(mistakes: [CardDetail.Mistake(
            wrong: "I listen music every day.",
            right: "I listen to music every day of the week, from morning until late at night, always.",
            why: "Türkçede 'müzik dinlemek' deriz ama İngilizcede 'listen' + to + isim gerekir."
        )])
        let listen = WidgetWord(id: 3, lemma: "listen", pos: "v", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e", glossTR: "dinlemek")
        XCTAssertEqual(text(.mistake, listen, fits), ["Dikkat: listen", "Türkçede 'müzik dinlemek' deriz ama İngilizcede 'listen' + to + isim gerekir."])
        XCTAssertFalse(text(.mistake, listen, fits)!.joined().contains("I listen music"))
    }

    func testAFalseFriendSpelledLikeTheMeaningIsLeftOut() {
        let grade = WidgetWord(id: 6, lemma: "grade", pos: "n", level: "A2", defMicro: "m", defShort: "s", exampleEN: "e", glossTR: "not")
        let card = CardDetail(falseFriend: CardDetail.FalseFriend(trWord: "not", trMeans: "okul notu, puan", enForThat: "grade"))
        XCTAssertNil(text(.falseFriend, grade, card))
    }

    func testTooLongTextsAreLeftOut() {
        let long = WidgetWord(id: 7, lemma: "Could you tell me the way to", pos: "phr", level: "A2", defMicro: "m", defShort: "s", exampleEN: "Could you tell me the way to the station?", glossTR: "bana yolu tarif eder misiniz")
        // 28 + 3 + 28 characters: too long for a title, the meaning kind skips the word.
        XCTAssertNil(text(.meaning, long, nil))
        XCTAssertNil(text(.newWord, long, nil), "\"Yeni kelime: \" + 28 characters is too long as well")
        XCTAssertNil(ReminderText.shownWord(String(repeating: "a", count: ReminderText.maxShownLength + 1)))
        XCTAssertEqual(ReminderText.shownWord("  look\nafter "), "look after")
        XCTAssertNil(ReminderText.shownWord("   "))
        XCTAssertNil(ReminderText.shownWord(nil))
    }

    func testPrivateTopicsStayOffTheLockScreen() {
        XCTAssertTrue(ReminderText.isPrivate("I saw my ex at the party."))
        XCTAssertTrue(ReminderText.isPrivate("They broke up last year."))
        XCTAssertTrue(ReminderText.isPrivate("He was drunk."))
        XCTAssertTrue(ReminderText.isPrivate("my ex-wife"))
        XCTAssertFalse(ReminderText.isPrivate("Break the glass up there? No, break it."), "\"up\" after another word")
        XCTAssertFalse(ReminderText.isPrivate("An excellent example."))
        let ex = WidgetWord(id: 8, lemma: "party", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "I saw my ex at the party.", glossTR: "parti")
        XCTAssertNil(text(.meaning, ex, nil))
        // The planner moves on to the next word (word 10 is due: tonight's reminder is for it).
        let words = [ex, word(9), word(10)]
        let progress = [
            8: learning(8, due: date(day: 20, hour: 9)),
            9: learning(9, due: date(day: 20, hour: 9)),
            10: learning(10, due: date(day: 12, hour: 9)),
        ]
        let reminder = plan(feed: words, progress: progress, now: date(day: 12, hour: 10), days: 1, goal: 0).first
        XCTAssertEqual(reminder?.wordID, 9)
    }

    func testPersonalTopicCardsAreNeverNamed() {
        // "divorce" itself says nothing the text filter knows; its sensitivity does.
        let divorce = WidgetWord(id: 8, lemma: "divorce", pos: "n", level: "B1", defMicro: "m", defShort: "s", exampleEN: "They got a divorce.", glossTR: "boşanma", sensitivity: 1)
        for kind in [ReminderKind.meaning, .newWord, .wordOfTheDay, .mistake, .example, .falseFriend, .mnemonic] {
            XCTAssertNil(ReminderText.message(kind, word: divorce, detail: fullDetail(divorce)), "\(kind)")
        }
        XCTAssertEqual(ReminderText.message(.plain, word: divorce, detail: nil), ReminderText.plain)
        // A learning personal card is passed over like a private text: the next word is named.
        let words = [divorce, word(9), word(10)]
        let progress = [
            8: learning(8, due: date(day: 20, hour: 9)),
            9: learning(9, due: date(day: 20, hour: 9)),
            10: learning(10, due: date(day: 12, hour: 9)),
        ]
        let reminder = plan(feed: words, progress: progress, now: date(day: 12, hour: 10), days: 1, goal: 0).first
        XCTAssertEqual(reminder?.wordID, 9)
        // As a new word too: word 9 is tonight's new word, the reminder names word 10, not 8.
        let fresh = plan(feed: [word(9), divorce, word(10), word(11)], progress: [:], now: date(day: 12, hour: 10), days: 1, goal: 1)
        XCTAssertEqual(fresh.first?.kind, .newWord)
        XCTAssertEqual(fresh.first?.wordID, 10)
    }

    func testNewWordsFollowTheIntroOrderWithConfusables() {
        // Words 1 and 2 are confusable partners: "Tanış" offers 1, 3, 4, 5, 6 tonight and keeps 2
        // apart, so the new-word reminder never picks one of those five.
        let words = feed(1...12)
        let pairs: [Int: Set<Int>] = [1: [2], 2: [1]]
        let reminders = ReminderPlanner.plan(
            feed: words,
            progress: [:],
            now: date(day: 12, hour: 10),
            minuteOfDay: evening,
            days: 1,
            dailyNewGoal: 5,
            newStudiedToday: 0,
            calendar: calendar,
            confusables: pairs,
            all: words
        )
        let tonight = Set(ReviewPlanner.introWords(feed: words, all: words, progress: [:], limit: 5, confusables: pairs).map { $0.id })
        XCTAssertEqual(tonight, [1, 3, 4, 5, 6])
        for reminder in reminders where reminder.kind == .newWord {
            XCTAssertFalse(tonight.contains(reminder.wordID ?? -1), "\(reminder.wordID ?? -1)")
        }
    }

    func testNoTextHasACountATaskOrPressure() {
        var progress: [Int: WordProgress] = [:]
        for id in 1...30 {
            // Half due (counts 15 on the first day), half studied and quiet.
            progress[id] = learning(id, due: id <= 15 ? date(day: 12, hour: 9) : date(day: 25, hour: 9))
        }
        for details in [false, true] {
            let reminders = plan(feed: feed(1...60), progress: progress, now: date(day: 12, hour: 10), days: 7, details: details)
            XCTAssertEqual(reminders.count, 7)
            for reminder in reminders {
                let all = reminder.title + " " + reminder.body
                let label = "\(reminder.kind) \(all)"
                XCTAssertFalse(reminder.title.isEmpty, label)
                XCTAssertFalse(reminder.body.isEmpty, label)
                XCTAssertLessThanOrEqual(reminder.title.count, ReminderText.maxTitleLength, label)
                XCTAssertLessThanOrEqual(reminder.body.count, ReminderText.maxBodyLength, label)
                XCTAssertFalse(all.contains { $0.isNewline }, label)
                XCTAssertFalse(all.contains { $0.isNumber }, "no counts: \(label)")
                XCTAssertFalse(all.unicodeScalars.contains { $0.properties.isEmojiPresentation }, label)
                // No task, no pressure, no streak.
                for phrase in ["!", "tekrar", "hazır", "seri", "üst üste", "kaçır", "hemen", "unutma"] {
                    XCTAssertFalse(all.lowercased().contains(phrase), "\(label): \(phrase)")
                }
                XCTAssertNotEqual(reminder.kind, .plain, label)
            }
        }
    }

    // MARK: Ignored reminders (3 and 7 days)

    func testIgnoredRemindersAreThoseWhoseDayEndedWithoutAUse() {
        let fires = (10...16).map { date(day: $0, hour: 20) }
        let lastUse = date(day: 10, hour: 18)
        func count(at now: Date, lastUse: Date? = lastUse) -> Int {
            return ReminderBackoff.ignoredCount(fireDates: fires, lastUse: lastUse, now: now, calendar: calendar)
        }
        XCTAssertEqual(count(at: date(day: 10, hour: 21)), 0, "the evening's reminder is answered by opening the app that day")
        XCTAssertEqual(count(at: date(day: 11, hour: 8)), 1)
        XCTAssertEqual(count(at: date(day: 12, hour: 21)), 2)
        XCTAssertEqual(count(at: date(day: 13, hour: 9)), 3)
        XCTAssertEqual(count(at: date(day: 20, hour: 9)), 7)
        // A use on day 12 (the app, or a widget button) starts again from there.
        XCTAssertEqual(count(at: date(day: 13, hour: 9), lastUse: date(day: 12, hour: 21)), 0)
        XCTAssertEqual(count(at: date(day: 14, hour: 9), lastUse: date(day: 12, hour: 10)), 2)
        // No record yet (first launch of this version): nothing counts.
        XCTAssertEqual(count(at: date(day: 20, hour: 9), lastUse: nil), 0)
    }

    func testALateReminderGetsThreeHours() {
        let fire = date(day: 12, hour: 23)
        XCTAssertEqual(ReminderBackoff.answerDeadline(for: fire, calendar: calendar), date(day: 13, hour: 2))
        XCTAssertEqual(ReminderBackoff.answerDeadline(for: date(day: 12, hour: 8), calendar: calendar), date(day: 13, hour: 0))
        XCTAssertEqual(ReminderBackoff.ignoredCount(fireDates: [fire], lastUse: date(day: 12, hour: 9), now: date(day: 13, hour: 1), calendar: calendar), 0)
        XCTAssertEqual(ReminderBackoff.ignoredCount(fireDates: [fire], lastUse: date(day: 12, hour: 9), now: date(day: 13, hour: 2), calendar: calendar), 1)
    }

    func testThreeDaysAskSevenDaysPause() {
        let now = date(day: 20, hour: 9)
        let actions = (0...8).map { ReminderBackoff.action(ignored: $0, questionAnsweredAt: nil, now: now) }
        XCTAssertEqual(actions, [.nothing, .nothing, .nothing, .askForTime, .askForTime, .askForTime, .askForTime, .pause, .pause])
        // Answered ("Böyle kalsın") ten days ago: no question, but the pause still comes.
        let answered = date(day: 10, hour: 9)
        XCTAssertEqual(ReminderBackoff.action(ignored: 3, questionAnsweredAt: answered, now: now), .nothing)
        XCTAssertEqual(ReminderBackoff.action(ignored: 7, questionAnsweredAt: answered, now: now), .pause)
        XCTAssertEqual(ReminderBackoff.action(ignored: 3, questionAnsweredAt: date(day: 5, hour: 9), now: now), .askForTime)
    }

    func testAWeekOfIgnoredRemindersEndsInAPause() {
        // The plan written when the app was last left; nobody opens the app for nine days.
        let left = date(day: 12, hour: 10)
        let reminders = plan(feed: feed(1...200), now: left, days: 7)
        let fires = reminders.map(\.fireDate)
        let after = { (now: Date) in
            ReminderBackoff.action(
                ignored: ReminderBackoff.ignoredCount(fireDates: fires, lastUse: left, now: now, calendar: self.calendar),
                questionAnsweredAt: nil,
                now: now
            )
        }
        XCTAssertEqual(after(date(day: 14, hour: 21)), .nothing, "two ignored, the third still has its evening")
        XCTAssertEqual(after(date(day: 15, hour: 9)), .askForTime)
        XCTAssertEqual(after(date(day: 18, hour: 21)), .askForTime, "six ignored, the seventh still has its evening")
        XCTAssertEqual(after(date(day: 19, hour: 9)), .pause)
        XCTAssertEqual(after(date(day: 25, hour: 9)), .pause)
        XCTAssertEqual(fires.last, date(day: 18, hour: 20), "nothing was planned after the seventh")
    }

    // MARK: The record on the phone (ReminderLog)

    private func freshDefaults() throws -> UserDefaults {
        let name = "ReminderLogTests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        addTeardownBlock {
            defaults.removePersistentDomain(forName: name)
        }
        return defaults
    }

    func testTheLogAsksAfterThreeDaysAndPausesAfterSeven() throws {
        let defaults = try freshDefaults()
        func opening(_ now: Date, widgetUse: Date? = nil) -> ReminderBackoff.Action {
            return ReminderLog.openingFollowUp(isActive: true, widgetUse: widgetUse, now: now, calendar: calendar, defaults: defaults)
        }
        func leave(_ now: Date) {
            // What RootView does when the app goes to the background.
            ReminderLog.recordUse(at: now, defaults: defaults)
            let reminders = plan(feed: feed(1...200), now: now, days: 7)
            ReminderLog.replaceScheduled(with: reminders.map(\.sent), now: now, defaults: defaults)
        }

        // First launch of this version: no record, nothing counts.
        XCTAssertEqual(opening(date(day: 11, hour: 9)), .nothing)
        leave(date(day: 12, hour: 10))
        XCTAssertTrue(ReminderLog.recentlySent(now: date(day: 12, hour: 10), defaults: defaults).isEmpty, "nothing sent yet")
        XCTAssertEqual(
            ReminderLog.recentlySent(now: date(day: 14, hour: 21), defaults: defaults).map(\.fireDate),
            [date(day: 12, hour: 20), date(day: 13, hour: 20), date(day: 14, hour: 20)]
        )
        // A widget button counts as a use only when it came after the app's last use.
        XCTAssertEqual(ReminderLog.lastUse(widgetUse: date(day: 13, hour: 8), defaults: defaults), date(day: 13, hour: 8))
        XCTAssertEqual(ReminderLog.lastUse(widgetUse: date(day: 11, hour: 8), defaults: defaults), date(day: 12, hour: 10))
        XCTAssertEqual(opening(date(day: 15, hour: 9), widgetUse: date(day: 14, hour: 7)), .nothing, "used the widget on day 14")

        // Three evenings ignored: the question. The opening is a use, so the next one is quiet.
        leave(date(day: 15, hour: 9, minute: 10))
        XCTAssertEqual(opening(date(day: 18, hour: 9)), .askForTime)
        XCTAssertEqual(opening(date(day: 18, hour: 9, minute: 5)), .nothing)
        // "Böyle kalsın": no question for two weeks.
        ReminderLog.noteTimeQuestionAnswered(at: date(day: 18, hour: 9, minute: 6), defaults: defaults)
        leave(date(day: 18, hour: 9, minute: 10))
        XCTAssertEqual(opening(date(day: 22, hour: 9)), .nothing)

        // A whole plan ignored, opened long after: the pause, however old the reminders.
        leave(date(day: 22, hour: 9, minute: 10))
        XCTAssertEqual(opening(date(day: 30, hour: 12)), .pause)
        XCTAssertEqual(ReminderLog.recentlySent(now: date(day: 30, hour: 12), defaults: defaults).count, 7)

        ReminderLog.pause(at: date(day: 30, hour: 12), defaults: defaults)
        XCTAssertEqual(ReminderLog.pausedAt(defaults: defaults), date(day: 30, hour: 12))
        XCTAssertTrue(ReminderLog.pauseNotePending(defaults: defaults))
        ReminderLog.pauseNoteShown(defaults: defaults)
        XCTAssertFalse(ReminderLog.pauseNotePending(defaults: defaults))
        XCTAssertNotNil(ReminderLog.pausedAt(defaults: defaults))
        ReminderLog.clearPause(defaults: defaults)
        XCTAssertNil(ReminderLog.pausedAt(defaults: defaults))
    }

    func testOffRemindersAreNeverIgnored() throws {
        let defaults = try freshDefaults()
        ReminderLog.recordUse(at: date(day: 12, hour: 10), defaults: defaults)
        let reminders = plan(feed: feed(1...200), now: date(day: 12, hour: 10), days: 7)
        ReminderLog.replaceScheduled(with: reminders.map(\.sent), now: date(day: 12, hour: 10), defaults: defaults)
        let off = ReminderLog.openingFollowUp(isActive: false, widgetUse: nil, now: date(day: 25, hour: 9), calendar: calendar, defaults: defaults)
        XCTAssertEqual(off, .nothing)
        // Turned off: the pending ones are gone, the sent ones stay for the five-day rule.
        ReminderLog.replaceScheduled(with: [], now: date(day: 14, hour: 21), defaults: defaults)
        XCTAssertEqual(ReminderLog.recentlySent(now: date(day: 20, hour: 9), defaults: defaults).count, 3)
    }
}
