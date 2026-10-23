import Foundation
import CoreModels

/// "Cümle kur": practice with the example sentences of the words the learner is learning or knows.
/// Mostly "put the words in order" (`SentenceTiles`), now and then "which verb goes with it?"
/// (`CollocationChoice`).
///
/// **Practice only.** Nothing here is a review: no grade, no box, no due date, nothing in the
/// review log or in "Bugün: … tekrar" (ogrenme_ilkeleri 3: seeing is not reviewing, and a
/// sentence built with the word in view is not a recall). The only record is a count of its own
/// (`PracticeTally`).
///
/// **Never before "Tekrar".** Like the widget (`QueueComposer`), a word "Tekrar" asks within
/// `QueueComposer.hiddenBeforeDue` is left out until it is answered: the sentence and its Turkish
/// would give the answer away. A "Biliyorum" word waiting for its check stays out as well.
public enum SentencePractice {
    /// One question of a round.
    public enum Item: Equatable, Sendable {
        /// Put the tiles in order; `translation` is the sentence's Turkish, the prompt.
        case build(wordID: Int, tiles: SentenceTiles, translation: String?)
        /// Pick the verb; `translation` is the sentence's Turkish (nil for a bare collocation).
        case collocation(wordID: Int, choice: CollocationChoice, translation: String?)

        public var wordID: Int {
            switch self {
            case let .build(wordID, _, _), let .collocation(wordID, _, _):
                return wordID
            }
        }
    }

    /// What a round can use of one word: its examples and its collocations.
    public struct Source: Equatable, Sendable {
        public let wordID: Int
        public let examples: [CardDetail.Example]
        public let collocations: [String]

        public init(wordID: Int, examples: [CardDetail.Example], collocations: [String] = []) {
            self.wordID = wordID
            self.examples = examples
            self.collocations = collocations
        }
    }

    /// Questions in a round: short, like a "Tanış + Hatırla" round.
    public static let roundSize = 5
    /// "Which verb?" questions in a round, at most; the rest are sentences to build.
    public static let collocationsPerRound = 2
    /// Words looked at for one round, at most (each is one card read from the database).
    public static let maxScannedWords = 60
    /// Once the sentences to build are found, words looked at in all before the search for a
    /// "which verb?" question stops: such pairs are rare (about one card in 14), and every word
    /// is a card read on the main thread.
    public static let scanWithBuildsFull = 25

    /// The words practice may use, in id order: being learned or known, and not about to be
    /// asked in "Tekrar" (see the type's note). A word answered today may come, even when it is
    /// due again soon: the answer has been given.
    public static func wordIDs(progress: [Int: WordProgress], now: Date, calendar: Calendar = .current) -> [Int] {
        let hideUntil = now.addingTimeInterval(QueueComposer.hiddenBeforeDue)
        let startOfToday = calendar.startOfDay(for: now)
        return progress.values.filter { p in
            switch p.state {
            case .new:
                return false
            case .learning:
                if let answer = QueueComposer.lastAnswer(of: p), answer.at >= startOfToday, answer.at <= now {
                    return true
                }
                return (p.dueAt ?? .distantFuture) > hideUntil
            case .known:
                return !p.knownOverride && (p.dueAt ?? .distantFuture) > hideUntil
            }
        }
        .map(\.wordID)
        .sorted()
    }

    /// A round of at most `size` questions, each from another word: the words in an order mixed
    /// by `seed`, one example sentence of each (also mixed by `seed`). Up to `collocations`
    /// "which verb?" questions (at most half the round) come between the sentences to build, from
    /// an example when one has a listed pair, otherwise from a collocation of the card. Such
    /// pairs are rare, so up to `maxScannedWords` words are looked at for them. Words without a
    /// usable sentence are skipped; `source` gives a word's examples (nil: none). Deterministic.
    /// Fewer than `collocations` choices may come when the first `scanWithBuildsFull` words
    /// already give every sentence to build.
    public static func round(
        wordIDs: [Int],
        seed: Int,
        size: Int = roundSize,
        collocations: Int = collocationsPerRound,
        source: (Int) -> Source?
    ) -> [Item] {
        guard size > 0 else {
            return []
        }
        var generator = PracticeRandom(seed: seed)
        let order = generator.shuffled(wordIDs)
        let choiceLimit = min(max(collocations, 0), size / 2)
        var builds: [Item] = []
        var choices: [Item] = []
        for (scanned, wordID) in order.prefix(maxScannedWords).enumerated() {
            if builds.count >= size - choices.count && (choices.count >= choiceLimit || scanned >= scanWithBuildsFull) {
                break
            }
            guard let words = source(wordID) else {
                continue
            }
            let pick = PracticeRandom(seed: seed, salt: wordID)
            if choices.count < choiceLimit, let choice = collocationItem(of: words, generator: pick) {
                choices.append(choice)
            } else if builds.count < size, let build = buildItem(of: words, generator: pick) {
                builds.append(build)
            }
        }
        let built = Array(builds.prefix(size - choices.count))
        var result: [Item] = []
        var builtIterator = built.makeIterator()
        var chosenIterator = choices.makeIterator()
        // Build, choice, build, choice, build: a "which verb?" opens the round only when there
        // is no sentence to build.
        while result.count < built.count + choices.count {
            if let item = builtIterator.next() {
                result.append(item)
            }
            if let item = chosenIterator.next() {
                result.append(item)
            }
        }
        return result
    }

    /// A sentence to build from one of the word's examples, picked by `generator`.
    private static func buildItem(of source: Source, generator: PracticeRandom) -> Item? {
        var generator = generator
        let usable = source.examples.compactMap { example in
            SentenceTiles(example.en).map { (tiles: $0, translation: example.tr) }
        }
        guard !usable.isEmpty else {
            return nil
        }
        let picked = usable[generator.next(below: usable.count)]
        return .build(wordID: source.wordID, tiles: picked.tiles, translation: picked.translation)
    }

    /// A "which verb?" question: from an example when one has a listed pair (with its Turkish),
    /// otherwise from a collocation of the card.
    private static func collocationItem(of source: Source, generator: PracticeRandom) -> Item? {
        var generator = generator
        let fromExamples = source.examples.compactMap { example in
            CollocationChoice.find(in: example.en).map { (choice: $0, translation: example.tr) }
        }
        if !fromExamples.isEmpty {
            let picked = fromExamples[generator.next(below: fromExamples.count)]
            return .collocation(wordID: source.wordID, choice: picked.choice, translation: picked.translation)
        }
        let fromCollocations = source.collocations.compactMap { CollocationChoice.find(in: $0, verbFirst: true) }
        guard !fromCollocations.isEmpty else {
            return nil
        }
        let picked = fromCollocations[generator.next(below: fromCollocations.count)]
        return .collocation(wordID: source.wordID, choice: picked, translation: nil)
    }

    // MARK: Round

    /// A running round: the questions in order, and a wrong one once more two questions later
    /// (with the tiles or options mixed anew), never right after itself. Not saved anywhere.
    public struct Round: Equatable, Sendable {
        public struct Step: Equatable, Sendable {
            public let item: Item
            /// 0 for the first try, 1 for the one more try.
            public let attempt: Int
        }

        public private(set) var steps: [Step]
        /// The step on screen.
        public private(set) var index = 0
        /// Questions of the round (not counting the second tries).
        public let questionCount: Int
        /// Questions answered right on the first try.
        public private(set) var rightFirstTime = 0

        public init(items: [Item]) {
            steps = items.map { Step(item: $0, attempt: 0) }
            questionCount = items.count
        }

        public var current: Step? {
            return steps.indices.contains(index) ? steps[index] : nil
        }

        public var isFinished: Bool {
            return index >= steps.count
        }

        /// Steps done so far, out of `steps.count` (which grows by one for each second try).
        public var progress: (done: Int, total: Int) {
            return (min(index, steps.count), steps.count)
        }

        /// The step on screen was answered. A wrong first try comes once more after two other
        /// steps (after one when only one is left); after the last step there is no other step
        /// to put between, so it does not come again: the right answer has just been shown.
        public mutating func answer(isRight: Bool) {
            guard let step = current else {
                return
            }
            if isRight && step.attempt == 0 {
                rightFirstTime += 1
            }
            if !isRight && step.attempt == 0 && index + 1 < steps.count {
                steps.insert(Step(item: step.item, attempt: 1), at: min(index + 3, steps.count))
            }
            index += 1
        }
    }
}

/// How many practice questions were answered: today and in all. A count of its own, never mixed
/// with the reviews ("Bugün: … tekrar") or the daily goal. Kept on the phone only; "İlerlemeyi
/// sıfırla" clears it.
public struct PracticeTally: Codable, Equatable, Sendable {
    /// The local day of `today`, "2026-10-23".
    public var day: String
    public var today: Int
    public var total: Int

    public static let empty = PracticeTally(day: "", today: 0, total: 0)

    public init(day: String, today: Int, total: Int) {
        self.day = day
        self.today = today
        self.total = total
    }

    /// Questions answered on `now`'s local day.
    public func todayCount(now: Date, calendar: Calendar = .current) -> Int {
        return day == PracticeTally.dayKey(now, calendar: calendar) ? today : 0
    }

    /// The tally after `count` more answers on `now`'s day; a new day starts again from them.
    public func adding(_ count: Int, now: Date, calendar: Calendar = .current) -> PracticeTally {
        let key = PracticeTally.dayKey(now, calendar: calendar)
        let added = max(0, count)
        return PracticeTally(day: key, today: (day == key ? today : 0) + added, total: total + added)
    }

    /// "2026-10-23" in `calendar`'s time zone; independent of the language setting.
    static func dayKey(_ date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        func padded(_ value: Int?, _ width: Int) -> String {
            let digits = String(value ?? 0)
            return String(repeating: "0", count: max(0, width - digits.count)) + digits
        }
        return padded(parts.year, 4) + "-" + padded(parts.month, 2) + "-" + padded(parts.day, 2)
    }
}
