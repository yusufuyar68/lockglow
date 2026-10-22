import Foundation
import CoreModels

/// What a reminder's text is built around (`ReminderText`). The planner turns the kinds from day
/// to day, so one kind does not come back within `ReminderPlanner.repeatGapDays` days.
public enum ReminderKind: String, Codable, CaseIterable, Sendable {
    /// "borrow = ödünç almak" · an example sentence.
    case meaning
    /// "Bugünün kelimesi: break" · "mola · take a break".
    case wordOfTheDay
    /// "Dikkat: listen" · why a typical Turkish-speaker mistake is one (the wrong sentence never).
    case mistake
    /// "Yeni kelime: spoon" · "kaşık · Can I have a spoon, please?" (new words only).
    case newWord
    /// "Örnek cümle: borrow" · a sentence and its Turkish translation.
    case example
    /// "Sahte dost: actually" · what it means and what its Turkish look-alike is in English.
    case falseFriend
    /// "Hafıza ipucu: borrow" · the card's memory hint.
    case mnemonic
    /// No word fits: a calm line without counts.
    case plain

    /// The kinds that carry a word, in the order the days turn them.
    public static let rotation: [ReminderKind] = [.meaning, .wordOfTheDay, .mistake, .newWord, .example, .falseFriend, .mnemonic]
}

/// One daily reminder: when it fires, the word it teaches and its text.
public struct Reminder: Equatable, Sendable {
    public let fireDate: Date
    /// Reviews due by `fireDate` if nothing is studied before then. Not in the text (2.10).
    public let dueCount: Int
    /// New words that day's goal offers. Not in the text.
    public let newCount: Int
    /// The word the text is about; nil for `.plain`. A tap opens its card when nothing is due.
    public let wordID: Int?
    public let kind: ReminderKind
    /// Notification title, one line (`ReminderText.maxTitleLength`).
    public let title: String
    /// Notification body, one paragraph (`ReminderText.maxBodyLength`).
    public let body: String

    public init(
        fireDate: Date,
        dueCount: Int,
        newCount: Int,
        wordID: Int? = nil,
        kind: ReminderKind = .plain,
        message: ReminderText.Message = ReminderText.plain
    ) {
        self.fireDate = fireDate
        self.dueCount = dueCount
        self.newCount = newCount
        self.wordID = wordID
        self.kind = kind
        self.title = message.title
        self.body = message.body
    }

    /// What is remembered of it once it was delivered.
    public var sent: SentReminder {
        return SentReminder(fireDate: fireDate, kind: kind, wordID: wordID)
    }
}

/// A reminder that was scheduled or delivered: the kind and word of its day, so neither comes
/// back too soon (`ReminderPlanner.repeatGapDays`), and its time, for `ReminderBackoff`.
public struct SentReminder: Codable, Equatable, Sendable {
    public let fireDate: Date
    public let kind: ReminderKind
    public let wordID: Int?

    public init(fireDate: Date, kind: ReminderKind, wordID: Int?) {
        self.fireDate = fireDate
        self.kind = kind
        self.wordID = wordID
    }

    enum CodingKeys: String, CodingKey {
        case fireDate = "fire_date"
        case kind
        case wordID = "word_id"
    }
}

/// Plans the daily reminders (ogrenme_ilkeleri 2.10). Pure; the app turns the result into local
/// notifications.
///
/// The text teaches a word ("borrow = ödünç almak") instead of naming a task or a count. That
/// word is never one "Tekrar" asks soon (2.1 rule a): the text shows the meaning, so it would give
/// the answer away. It comes from the studied words (learning first, then known) that are not
/// due within `quietWindow` of the reminder, which are the words answered that day and those in
/// box 2 and up; or, for `.newWord`, from the deck's new words after the ones the next days'
/// rounds offer (seen on the widget first).
public enum ReminderPlanner {
    /// A word due in "Tekrar" before this long after the reminder is never its word. The widget's
    /// window (rule a, `QueueComposer.hiddenBeforeDue`): one constant for both (ogrenme_ilkeleri 2.10).
    public static let quietWindow: TimeInterval = QueueComposer.hiddenBeforeDue
    /// The same kind of text and the same word do not come back within this many days.
    public static let repeatGapDays = 5
    /// Words tried per kind and day; each may read one card from the database (`detail`).
    public static let lookupsPerKind = 12

    /// One reminder a day for `days` days at `minuteOfDay` (minutes after local midnight by
    /// `calendar`), starting today if that time is still ahead, and never more than
    /// `ReminderBackoff.pauseAfter` reminders: when that many go unanswered, reminders pause
    /// without the app having to run. A day with nothing to do (no review due, no new word
    /// offered) gets no reminder; that is how today's reminder disappears once the round is done.
    ///
    /// Words and counts come from the current progress, as if nothing were studied until then;
    /// the app plans again each time it goes to the background.
    ///
    /// - Parameters:
    ///   - newWordFeed: the user's deck (`DeckFilter.feed`), where new words come from, as in
    ///     "Tekrar". Nil means `feed`. Reviews come from `feed` (every word).
    ///   - recent: reminders already sent (`ReminderLog.recentlySent`); their kinds and words wait
    ///     `repeatGapDays` days.
    ///   - detail: a word's full card (examples, mistakes, memory hint...). Without it only the
    ///     kinds `WidgetWord` can fill are used (`.meaning`, `.newWord`).
    ///   - confusables: when given, new words come in the order "Tanış" offers them
    ///     (`ReviewPlanner.introWords` over `all`, which keeps confusable partners apart and puts
    ///     words a failed "Biliyorum" check sent back first). Nil: the deck's new words in order.
    ///   - all: every loaded word (`introWords`' returning words); nil means `feed`.
    public static func plan(
        feed: [WidgetWord],
        newWordFeed: [WidgetWord]? = nil,
        progress: [Int: WordProgress],
        now: Date,
        minuteOfDay: Int,
        days: Int,
        dailyNewGoal: Int,
        newStudiedToday: Int,
        calendar: Calendar,
        recent: [SentReminder] = [],
        detail: (WidgetWord) -> CardDetail? = { _ in nil },
        confusables: [Int: Set<Int>]? = nil,
        all: [WidgetWord]? = nil
    ) -> [Reminder] {
        guard days > 0, (0..<1440).contains(minuteOfDay) else {
            return []
        }
        let goal = max(dailyNewGoal, 0)
        let deck = newWordFeed ?? feed
        let upcoming = confusables.map {
            ReviewPlanner.introWords(feed: deck, all: all ?? feed, progress: progress, limit: Int.max, confusables: $0)
        } ?? ReviewPlanner.newWords(feed: deck, progress: progress, limit: Int.max)
        let newWords = upcoming.prefix(goal)
        let startOfToday = calendar.startOfDay(for: now)
        var picker = WordPicker(feed: feed, upcoming: upcoming, progress: progress, goal: goal, calendar: calendar, history: recent)

        var result: [Reminder] = []
        for offset in 0..<days where result.count < ReminderBackoff.pauseAfter {
            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday),
                  let fireDate = calendar.date(
                      bySettingHour: minuteOfDay / 60,
                      minute: minuteOfDay % 60,
                      second: 0,
                      of: day
                  ),
                  fireDate > now
            else {
                continue
            }
            let dueWords = ReviewPlanner.dueWords(feed: feed, progress: progress, now: fireDate, limit: Int.max)
            let offered = offset == 0 ? min(newWords.count, max(goal - newStudiedToday, 0)) : newWords.count
            if dueWords.isEmpty && offered == 0 {
                continue
            }
            let choice = picker.choose(fireDate: fireDate, dayOffset: offset, detail: detail)
            let reminder = Reminder(
                fireDate: fireDate,
                dueCount: dueWords.count,
                newCount: offered,
                wordID: choice.wordID,
                kind: choice.kind,
                message: choice.message
            )
            result.append(reminder)
            picker.history.append(reminder.sent)
        }
        return result
    }

    /// Calendar days from a fixed day to `date`'s local day: turns the kinds and the word order.
    public static func dayNumber(for date: Date, calendar: Calendar) -> Int {
        let anchor = calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: 0))
        return calendar.dateComponents([.day], from: anchor, to: calendar.startOfDay(for: date)).day ?? 0
    }

    /// The order the kinds are tried in on day `day`: the day's turn of `ReminderKind.rotation`,
    /// kinds used within `repeatGapDays` days last (the longest unused first).
    static func kindOrder(day: Int, lastUsedDay: [ReminderKind: Int]) -> [ReminderKind] {
        let rotation = ReminderKind.rotation
        let start = ((day % rotation.count) + rotation.count) % rotation.count
        let turned = Array(rotation[start...] + rotation[..<start])
        let isRecent = { (kind: ReminderKind) -> Bool in
            guard let used = lastUsedDay[kind] else {
                return false
            }
            return day - used <= repeatGapDays
        }
        let unused = turned.filter { !isRecent($0) }
        let recent = turned.filter(isRecent).enumerated().sorted { a, b in
            let left = lastUsedDay[a.element] ?? 0
            let right = lastUsedDay[b.element] ?? 0
            return left != right ? left < right : a.offset < b.offset
        }
        return unused + recent.map { $0.element }
    }
}

/// Picks each day's word and kind for `ReminderPlanner.plan`.
private struct WordPicker {
    struct Choice {
        let kind: ReminderKind
        let wordID: Int?
        let message: ReminderText.Message
    }

    /// Learning and known words, each once, in feed order.
    let studied: [WidgetWord]
    /// The deck's new words in the order "Tekrar" offers them.
    let upcoming: [WidgetWord]
    let progress: [Int: WordProgress]
    let goal: Int
    let calendar: Calendar
    var history: [SentReminder]
    private var details: [Int: CardDetail?] = [:]

    init(feed: [WidgetWord], upcoming: [WidgetWord], progress: [Int: WordProgress], goal: Int, calendar: Calendar, history: [SentReminder]) {
        var seen = Set<Int>()
        studied = feed.filter { word in
            guard seen.insert(word.id).inserted, let state = progress[word.id]?.state else {
                return false
            }
            return state != .new
        }
        self.upcoming = upcoming
        self.progress = progress
        self.goal = goal
        self.calendar = calendar
        self.history = history
    }

    mutating func choose(fireDate: Date, dayOffset: Int, detail: (WidgetWord) -> CardDetail?) -> Choice {
        let day = ReminderPlanner.dayNumber(for: fireDate, calendar: calendar)
        var lastUsedDay: [ReminderKind: Int] = [:]
        var recentWords = Set<Int>()
        for sent in history {
            let sentDay = ReminderPlanner.dayNumber(for: sent.fireDate, calendar: calendar)
            guard sentDay < day else {
                continue
            }
            lastUsedDay[sent.kind] = max(lastUsedDay[sent.kind] ?? sentDay, sentDay)
            if day - sentDay <= ReminderPlanner.repeatGapDays, let id = sent.wordID {
                recentWords.insert(id)
            }
        }

        // Studied words "Tekrar" does not ask soon: learning words first, then known ones.
        let quietUntil = fireDate.addingTimeInterval(ReminderPlanner.quietWindow)
        let studiedPool = studied
            .filter { !recentWords.contains($0.id) && progress[$0.id]?.isDue(at: quietUntil) != true }
            .map { (word: $0, learning: progress[$0.id]?.state == .learning, key: WordPicker.mixKey(day: day, $0.id)) }
            .sorted { a, b in a.learning != b.learning ? a.learning : a.key < b.key }
            .map { $0.word }
        // New words after the ones offered until that day (each day as if the day before was
        // studied, or not): words seen on the widget first, then the nearest in the deck.
        let later = upcoming.dropFirst((dayOffset + 1) * goal).filter { !recentWords.contains($0.id) }
        let seen = later
            .filter { (progress[$0.id]?.exposures ?? 0) > 0 }
            .map { (word: $0, key: WordPicker.mixKey(day: day, $0.id)) }
            .sorted { $0.key < $1.key }
            .map { $0.word }
        let freshPool = seen + later.filter { (progress[$0.id]?.exposures ?? 0) == 0 }

        for kind in ReminderPlanner.kindOrder(day: day, lastUsedDay: lastUsedDay) {
            let pool = kind == .newWord ? freshPool : studiedPool
            for word in pool.prefix(ReminderPlanner.lookupsPerKind) {
                let card = cachedDetail(of: word, detail: detail)
                if let message = ReminderText.message(kind, word: word, detail: card) {
                    return Choice(kind: kind, wordID: word.id, message: message)
                }
            }
        }
        return Choice(kind: .plain, wordID: nil, message: ReminderText.plain)
    }

    private mutating func cachedDetail(of word: WidgetWord, detail: (WidgetWord) -> CardDetail?) -> CardDetail? {
        if let cached = details[word.id] {
            return cached
        }
        let card = detail(word)
        details[word.id] = .some(card)
        return card
    }

    /// FNV-1a over "day|id": a different word order each day, the same on every planning.
    static func mixKey(day: Int, _ id: Int) -> UInt64 {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in "\(day)|\(id)".utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
        return hash
    }
}

/// What a reminder says: a title that carries the word and a body that teaches something about
/// it. No counts, no tasks, no guilt, no streaks, no emoji, no imperative; the English word stands
/// alone, never with a Turkish suffix (2.10).
public enum ReminderText {
    public struct Message: Equatable, Sendable {
        public let title: String
        public let body: String

        public init(title: String, body: String) {
            self.title = title
            self.body = body
        }
    }

    /// Longer words and meanings are left out (content max: 28).
    public static let maxShownLength = 32
    /// A title longer than this may not fit on one line of the Lock Screen.
    public static let maxTitleLength = 40
    /// About three lines of a notification.
    public static let maxBodyLength = 120

    /// When no word fits (a deck with every word due soon and no new word left).
    public static let plain = Message(title: "Kelimeler hazır", body: "Birkaç dakikan olduğunda bakabilirsin.")

    /// The text of `kind` about `word`, or nil when the word lacks what the kind needs, the text
    /// does not fit, or it touches a private topic (shown on the Lock Screen): a personal-topic
    /// card (`WidgetWord.isSensitive`: divorce, crush, get fired…) is never named, whatever its
    /// text. `detail` is the word's full card; without it only `.meaning` and `.newWord` can be
    /// written.
    public static func message(_ kind: ReminderKind, word: WidgetWord, detail: CardDetail?) -> Message? {
        if kind == .plain {
            return plain
        }
        guard !word.isSensitive, let lemma = shownWord(word.lemma) else {
            return nil
        }
        let gloss = shownWord(word.glossTR)
        let written: Message?
        switch kind {
        case .meaning:
            written = gloss.flatMap { gloss in
                example(of: word, detail: detail, preferring: 0).map { Message(title: "\(lemma) = \(gloss)", body: $0.en) }
            }
        case .wordOfTheDay:
            let collocation = detail?.collocations.lazy
                .compactMap { shownWord($0) }
                .first { $0.lowercased() != lemma.lowercased() }
            written = gloss.flatMap { gloss in
                collocation.map { Message(title: "Bugünün kelimesi: \(lemma)", body: "\(gloss) · \($0)") }
            }
        case .mistake:
            written = mistakeLine(detail).map { Message(title: "Dikkat: \(lemma)", body: $0) }
        case .newWord:
            written = gloss.flatMap { gloss in
                example(of: word, detail: detail, preferring: 0).map { Message(title: "Yeni kelime: \(lemma)", body: "\(gloss) · \($0.en)") }
            }
        case .example:
            written = example(of: word, detail: detail, preferring: 1, translated: true).flatMap { pair in
                pair.tr.map { Message(title: "Örnek cümle: \(lemma)", body: "\(pair.en) Türkçesi: \($0)") }
            }
        case .falseFriend:
            written = gloss.flatMap { falseFriendLine(gloss: $0, detail: detail) }.map { Message(title: "Sahte dost: \(lemma)", body: $0) }
        case .mnemonic:
            let hint = detail?.mnemonicTR.map(oneLine) ?? ""
            written = hint.isEmpty ? nil : Message(title: "Hafıza ipucu: \(lemma)", body: hint)
        case .plain:
            return plain
        }
        guard let message = written,
              message.title.count <= maxTitleLength,
              message.body.count <= maxBodyLength,
              !isPrivate(message.title + " " + message.body)
        else {
            return nil
        }
        return message
    }

    /// `text` on one line, or nil when it is empty or too long for a notification line.
    public static func shownWord(_ text: String?) -> String? {
        guard let text = text else {
            return nil
        }
        let line = oneLine(text)
        guard !line.isEmpty, line.count <= maxShownLength else {
            return nil
        }
        return line
    }

    /// Words of a personal topic a Lock Screen should not show by default (2.1). The cards carry
    /// `sensitivity` now (`message` checks it first); this text filter still catches the same
    /// topics in other cards' examples and in the user's own words, which have no sensitivity.
    public static func isPrivate(_ text: String) -> Bool {
        let words = text.lowercased().split { !$0.isLetter }.map(String.init)
        let flagged: Set<String> = ["ex", "crush", "divorce", "divorced", "breakup", "drunk"]
        if words.contains(where: flagged.contains) {
            return true
        }
        let breaking: Set<String> = ["break", "breaks", "broke", "broken", "breaking"]
        return zip(words, words.dropFirst()).contains { breaking.contains($0) && $1 == "up" }
    }

    /// An example of the card, `preferring` that index (0: the card's first sentence, its fixed
    /// context; 1: a second one). Never the quiz sentence: a later question may use it.
    private static func example(
        of word: WidgetWord,
        detail: CardDetail?,
        preferring index: Int,
        translated: Bool = false
    ) -> (en: String, tr: String?)? {
        var candidates: [(en: String, tr: String?)] = []
        if let examples = detail?.examples, !examples.isEmpty {
            let start = min(index, examples.count - 1)
            for example in examples[start...] + examples[..<start] {
                let tr = example.tr.map(oneLine).flatMap { $0.isEmpty ? nil : $0 }
                candidates.append((oneLine(example.en), tr))
            }
        } else if !translated {
            candidates.append((oneLine(word.exampleEN), nil))
        }
        let quiz = detail?.quiz.map { normalized($0.filledSentence) }
        return candidates.first { candidate in
            !candidate.en.isEmpty
                && normalized(candidate.en) != quiz
                && (!translated || candidate.tr != nil)
        }
    }

    /// Why a typical mistake is one, after the right sentence when both fit. The wrong sentence is
    /// never shown on its own (2.2).
    private static func mistakeLine(_ detail: CardDetail?) -> String? {
        let mistakes = detail?.mistakes ?? []
        for mistake in mistakes {
            let line = "Doğrusu: \(oneLine(mistake.right)) \(oneLine(mistake.why))"
            if line.count <= maxBodyLength {
                return line
            }
        }
        return mistakes.lazy.map { oneLine($0.why) }.first { !$0.isEmpty && $0.count <= maxBodyLength }
    }

    /// "aslında, gerçekte demek; aktüel değil. "güncel" için current / currently."
    private static func falseFriendLine(gloss: String, detail: CardDetail?) -> String? {
        guard let friend = detail?.falseFriend else {
            return nil
        }
        let lookAlike = oneLine(friend.trWord)
        let means = oneLine(friend.trMeans).split(separator: ",").first.map { $0.trimmingCharacters(in: .whitespaces) } ?? ""
        let english = oneLine(friend.enForThat)
        // A look-alike spelled like the meaning itself would read "not demek; not değil".
        guard !lookAlike.isEmpty, !means.isEmpty, !english.isEmpty,
              lookAlike.lowercased() != gloss.lowercased()
        else {
            return nil
        }
        return "\(gloss) demek; \(lookAlike) değil. \"\(means)\" için \(english)."
    }

    private static func oneLine(_ text: String) -> String {
        return text.split(whereSeparator: \.isNewline).joined(separator: " ").trimmingCharacters(in: .whitespaces)
    }

    private static func normalized(_ sentence: String) -> String {
        return sentence.lowercased().split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }
}

/// Backing off when the reminder is ignored (2.10). A reminder counts as ignored when its day
/// ends without the app being opened and without a widget button ("Sonraki", "Biliyorum")
/// being used after it; every such use starts the count again. Measured on the phone only, from
/// two times: the scheduled reminder times and the last use (`ReminderScheduler`).
///
/// - `askAfter` ignored in a row: at the next opening, one card asks to change the time.
/// - `pauseAfter` in a row: reminders pause and the next opening says so; that note replaces
///   the question. The plan never holds more than `pauseAfter` reminders, so the pause holds even
///   if the app is not opened again.
public enum ReminderBackoff {
    public static let askAfter = 3
    public static let pauseAfter = 7
    /// A reminder late in the evening still gets this long to be answered.
    public static let minimumAnswerTime: TimeInterval = 3 * 3600
    /// After "Böyle kalsın" or a new time, the time question waits this long.
    public static let questionQuietPeriod: TimeInterval = 14 * 86_400

    public enum Action: Equatable, Sendable {
        case nothing
        /// "Hatırlatma saatini değiştirelim mi?"
        case askForTime
        /// Turn reminders off and say so.
        case pause
    }

    /// Reminders delivered after `lastUse` (by `now`) whose day ended without a use. One still
    /// within its day is answered by this opening, so it does not count. Nil `lastUse` (no record
    /// yet) counts nothing.
    public static func ignoredCount(fireDates: [Date], lastUse: Date?, now: Date, calendar: Calendar) -> Int {
        guard let lastUse = lastUse else {
            return 0
        }
        return fireDates.filter { fire in
            fire > lastUse && answerDeadline(for: fire, calendar: calendar) <= now
        }.count
    }

    /// The end of the reminder's local day, or `minimumAnswerTime` after it if that is later.
    public static func answerDeadline(for fireDate: Date, calendar: Calendar) -> Date {
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: fireDate)) ?? fireDate
        return max(endOfDay, fireDate.addingTimeInterval(minimumAnswerTime))
    }

    /// What an opening does about `ignored` reminders in a row. `questionAnsweredAt`: when the
    /// time question was last answered ("Saati değiştir" or "Böyle kalsın").
    public static func action(ignored: Int, questionAnsweredAt: Date?, now: Date) -> Action {
        if ignored >= pauseAfter {
            return .pause
        }
        guard ignored >= askAfter else {
            return .nothing
        }
        if let answered = questionAnsweredAt, now.timeIntervalSince(answered) < questionQuietPeriod {
            return .nothing
        }
        return .askForTime
    }
}

/// The phone's record behind backing off and the five-day rule, in UserDefaults (it never leaves
/// the phone): the reminders scheduled and sent (time, kind, word), the last use of the app, the
/// pause and the answer to the time question. The app's `ReminderScheduler` writes it; the plan
/// reads `recentlySent` (`ReminderPlanner.plan(recent:)`).
public enum ReminderLog {
    private static let scheduledKey = "lockglow.reminder.scheduled"
    private static let sentKey = "lockglow.reminder.sent"
    private static let lastUseKey = "lockglow.reminder.lastUse"
    private static let pausedAtKey = "lockglow.reminder.pausedAt"
    private static let pauseNoteKey = "lockglow.reminder.pauseNotePending"
    private static let questionAnsweredKey = "lockglow.reminder.timeQuestionAnsweredAt"
    /// Sent reminders older than this are forgotten (the plan looks back 5 days, backing off 7).
    static let keptFor: TimeInterval = 8 * 86_400

    // MARK: Sent reminders

    /// Reminders sent (scheduled ones whose time has come), oldest first: those of the last
    /// `keptFor`, and every one since the last use however long ago (at most one plan's).
    public static func recentlySent(now: Date = Date(), defaults: UserDefaults = .standard) -> [SentReminder] {
        let all = load(sentKey, defaults) + load(scheduledKey, defaults).filter { $0.fireDate <= now }
        let lastUse = date(lastUseKey, defaults) ?? now
        var seen = Set<Date>()
        return all
            .filter { sent in
                (now.timeIntervalSince(sent.fireDate) < keptFor || sent.fireDate > lastUse)
                    && seen.insert(sent.fireDate).inserted
            }
            .sorted { $0.fireDate < $1.fireDate }
    }

    /// A new plan replaced the pending reminders: the ones whose time has come stay as sent,
    /// `scheduled` (empty when nothing could be scheduled) waits.
    public static func replaceScheduled(with scheduled: [SentReminder], now: Date = Date(), defaults: UserDefaults = .standard) {
        save(recentlySent(now: now, defaults: defaults), sentKey, defaults)
        save(scheduled, scheduledKey, defaults)
    }

    // MARK: Uses and backing off

    /// A use of the app (an opening, or leaving it): ignored reminders count from here.
    public static func recordUse(at date: Date = Date(), defaults: UserDefaults = .standard) {
        defaults.set(date.timeIntervalSince1970, forKey: lastUseKey)
    }

    /// The last use of the app, or of a widget button (`widgetUse`) when that came later. Nil
    /// before the app recorded one: a widget use alone would count every older reminder.
    public static func lastUse(widgetUse: Date?, defaults: UserDefaults = .standard) -> Date? {
        guard let app = date(lastUseKey, defaults) else {
            return nil
        }
        return max(app, widgetUse ?? app)
    }

    /// What an opening does about ignored reminders (`ReminderBackoff`); the opening then counts
    /// as a use. `isActive`: reminders are on and allowed (otherwise none were sent to ignore).
    public static func openingFollowUp(
        isActive: Bool,
        widgetUse: Date?,
        now: Date = Date(),
        calendar: Calendar = .current,
        defaults: UserDefaults = .standard
    ) -> ReminderBackoff.Action {
        defer {
            recordUse(at: now, defaults: defaults)
        }
        guard isActive else {
            return .nothing
        }
        let ignored = ReminderBackoff.ignoredCount(
            fireDates: recentlySent(now: now, defaults: defaults).map(\.fireDate),
            lastUse: lastUse(widgetUse: widgetUse, defaults: defaults),
            now: now,
            calendar: calendar
        )
        return ReminderBackoff.action(ignored: ignored, questionAnsweredAt: timeQuestionAnsweredAt(defaults: defaults), now: now)
    }

    /// When the time question was last answered ("Saati değiştir" or "Böyle kalsın").
    public static func timeQuestionAnsweredAt(defaults: UserDefaults = .standard) -> Date? {
        return date(questionAnsweredKey, defaults)
    }

    public static func noteTimeQuestionAnswered(at date: Date = Date(), defaults: UserDefaults = .standard) {
        defaults.set(date.timeIntervalSince1970, forKey: questionAnsweredKey)
    }

    // MARK: Pause

    /// When reminders were paused after a week of ignored ones; nil once they are on again.
    /// "Ayarlar" may show it ("Hatırlatmalar duraklatıldı · Aç").
    public static func pausedAt(defaults: UserDefaults = .standard) -> Date? {
        return date(pausedAtKey, defaults)
    }

    /// The pause note waits for an opening without another system card.
    public static func pauseNotePending(defaults: UserDefaults = .standard) -> Bool {
        return defaults.bool(forKey: pauseNoteKey)
    }

    /// Records the pause; the app turns the setting off and removes the pending reminders.
    public static func pause(at date: Date = Date(), defaults: UserDefaults = .standard) {
        defaults.set(date.timeIntervalSince1970, forKey: pausedAtKey)
        defaults.set(true, forKey: pauseNoteKey)
    }

    public static func pauseNoteShown(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: pauseNoteKey)
    }

    /// Reminders were turned on again.
    public static func clearPause(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: pausedAtKey)
        defaults.removeObject(forKey: pauseNoteKey)
    }

    // MARK: Storage

    private static func load(_ key: String, _ defaults: UserDefaults) -> [SentReminder] {
        guard let data = defaults.data(forKey: key) else {
            return []
        }
        return (try? JSONDecoder().decode([SentReminder].self, from: data)) ?? []
    }

    private static func save(_ reminders: [SentReminder], _ key: String, _ defaults: UserDefaults) {
        if let data = try? JSONEncoder().encode(reminders) {
            defaults.set(data, forKey: key)
        }
    }

    private static func date(_ key: String, _ defaults: UserDefaults) -> Date? {
        guard defaults.object(forKey: key) != nil else {
            return nil
        }
        return Date(timeIntervalSince1970: defaults.double(forKey: key))
    }
}
