import Foundation
import CoreModels

/// Word counts shown on the settings screen.
public struct ProgressCounts: Equatable, Sendable {
    public var known: Int
    public var learning: Int
    public var dueToday: Int

    public init(known: Int = 0, learning: Int = 0, dueToday: Int = 0) {
        self.known = known
        self.learning = learning
        self.dueToday = dueToday
    }
}

/// Picks the words for a flashcard round and counts progress. Pure and deterministic; all
/// functions only look at words that are in `feed` (each id once, first occurrence wins).
public enum ReviewPlanner {
    /// Words whose review is due at `now`, most overdue first (ties keep feed order).
    /// Includes known words whose refresher is due.
    public static func dueWords(
        feed: [WidgetWord],
        progress: [Int: WordProgress],
        now: Date,
        limit: Int
    ) -> [WidgetWord] {
        guard limit > 0 else {
            return []
        }
        var due: [(word: WidgetWord, at: Date, order: Int)] = []
        var seen = Set<Int>()
        for (order, word) in feed.enumerated() {
            if !seen.insert(word.id).inserted {
                continue
            }
            guard let p = progress[word.id], let dueAt = p.dueAt, p.isDue(at: now) else {
                continue
            }
            due.append((word, dueAt, order))
        }
        due.sort { a, b in
            if a.at != b.at {
                return a.at < b.at
            }
            return a.order < b.order
        }
        return due.prefix(limit).map { $0.word }
    }

    /// The first `limit` words in feed order that were never reviewed (a word that was only
    /// seen on the widget is still new).
    public static func newWords(
        feed: [WidgetWord],
        progress: [Int: WordProgress],
        limit: Int
    ) -> [WidgetWord] {
        guard limit > 0 else {
            return []
        }
        var result: [WidgetWord] = []
        var seen = Set<Int>()
        for word in feed {
            if !seen.insert(word.id).inserted {
                continue
            }
            let state = progress[word.id]?.state ?? .new
            if state == .new {
                result.append(word)
                if result.count == limit {
                    break
                }
            }
        }
        return result
    }

    /// `dueToday` counts reviews and refreshers due at or before `dueBy` (pass the end of the local day).
    public static func counts(
        feed: [WidgetWord],
        progress: [Int: WordProgress],
        dueBy: Date
    ) -> ProgressCounts {
        var counts = ProgressCounts()
        var seen = Set<Int>()
        for word in feed {
            if !seen.insert(word.id).inserted {
                continue
            }
            guard let p = progress[word.id] else {
                continue
            }
            switch p.state {
            case .known:
                counts.known += 1
            case .learning:
                counts.learning += 1
            case .new:
                break
            }
            if p.isDue(at: dueBy) {
                counts.dueToday += 1
            }
        }
        return counts
    }
}

// MARK: - Question kind and new words

/// How a due word is asked in "Tekrar" (docs/tasarim/ogrenme_ilkeleri.md 2.4). A new word is
/// asked in its "Tanış + Hatırla" round instead (`IntroRound`).
public enum QuestionKind: Equatable, Sendable {
    /// Boxes 1–3: the card's written fill-in-the-blank question with four options.
    case cloze
    /// Boxes 4–5, refreshers and the "Biliyorum" check: the Turkish meaning is shown, the
    /// English word is recalled from memory, then "Göster" and "Bulamadım / Buldum".
    case recall
}

extension ReviewPlanner {
    /// From this box on a learning word is recalled, not picked from options.
    public static let recallFromBox = 4

    /// The question for a due word. `hasCloze`: the card has a usable fill-in-the-blank question;
    /// a word without one is recalled whatever its box.
    public static func questionKind(for progress: WordProgress?, hasCloze: Bool) -> QuestionKind {
        if let p = progress, p.state == .known || p.box >= recallFromBox {
            return .recall
        }
        return hasCloze ? .cloze : .recall
    }

    /// The words of the next "Tanış + Hatırla" round, at most `limit`: first the words a failed
    /// "Biliyorum" check sent back (`WordProgress.returnsToIntro`; from `all`, whatever the deck,
    /// the longest waiting first), then the never-reviewed words of `feed` in feed order.
    ///
    /// `confusables`: each card's confusable partners (borrow → lend). Words that are easily mixed
    /// up are not learned together (docs/tasarim/ogrenme_ilkeleri.md 1.8, 2.3): a new word waits
    /// while a partner is in this round already or is still learning below box 2.
    public static func introWords(
        feed: [WidgetWord],
        all: [WidgetWord],
        progress: [Int: WordProgress],
        limit: Int,
        confusables: [Int: Set<Int>] = [:]
    ) -> [WidgetWord] {
        guard limit > 0 else {
            return []
        }
        var returning: [(word: WidgetWord, at: Date, order: Int)] = []
        var seen = Set<Int>()
        for (order, word) in all.enumerated() where seen.insert(word.id).inserted {
            if let p = progress[word.id], p.returnsToIntro {
                returning.append((word, p.lastSeenAt ?? .distantPast, order))
            }
        }
        returning.sort { a, b in
            if a.at != b.at {
                return a.at < b.at
            }
            return a.order < b.order
        }
        var result = returning.prefix(limit).map { $0.word }
        var used = Set(result.map { $0.id })
        var chosen = used
        func waitsForPartner(_ id: Int) -> Bool {
            return (confusables[id] ?? []).contains { partner in
                if chosen.contains(partner) {
                    return true
                }
                guard let p = progress[partner] else {
                    return false
                }
                return p.state == .learning && p.box < 2
            }
        }
        for word in feed {
            if result.count == limit {
                break
            }
            guard used.insert(word.id).inserted, (progress[word.id]?.state ?? .new) == .new else {
                continue
            }
            if waitsForPartner(word.id) {
                continue
            }
            result.append(word)
            chosen.insert(word.id)
        }
        return result
    }
}

// MARK: - Tanış + Hatırla

/// A new-word round, "Tanış + Hatırla" (docs/tasarim/ogrenme_ilkeleri.md 2.3). Every word is met
/// first ("Tanış": the word, then its meaning); then each is asked once with a four-option
/// question, in a mixed order ("Hatırla"), alternating "Anlamını seç" and "İngilizcesini seç".
/// A wrong answer gets one more try `retryGap` cards later (at the end when fewer are left), with
/// the same kind of question and the options mixed again; a second wrong answer ends the word's
/// round, so the loop never runs forever. The grade comes from the answers (`Result.grade`),
/// never from a self-rating. Pure and deterministic: the view drives it and records each word's
/// `Result` as soon as it is decided.
public struct IntroRound: Equatable, Sendable {
    public enum Direction: Equatable, Sendable {
        /// "Anlamını seç": the English word, four Turkish meanings.
        case pickMeaning
        /// "İngilizcesini seç": the Turkish meaning, four English words.
        case pickEnglish
    }

    public enum Step: Equatable, Sendable {
        /// "Tanış": the word's front, then its meaning.
        case meet(wordID: Int)
        /// "Hatırla": the word's question; `attempt` is 1, or 2 for the try after a wrong answer.
        case recall(wordID: Int, attempt: Int)

        public var wordID: Int {
            switch self {
            case let .meet(id), let .recall(id, _):
                return id
            }
        }
    }

    /// How a word's "Hatırla" went.
    public enum Result: Equatable, Sendable {
        case firstTry
        /// Right after one wrong answer.
        case secondTry
        /// Wrong twice (or wrong once and the round was ended before the second try).
        case missed

        /// First try "Bildim" (box 1, tomorrow), second try "Zor" (12 hours), missed "Bilemedim"
        /// (box 1, next round).
        public var grade: ReviewGrade {
            switch self {
            case .firstTry:
                return .good
            case .secondTry:
                return .hard
            case .missed:
                return .again
            }
        }

        /// Counts for today's new-word goal: only a word that was recalled.
        public var passed: Bool {
            return self != .missed
        }
    }

    /// Cards between a wrong answer and its second try.
    public static let retryGap = 3
    public static let maxAttempts = 2

    public private(set) var steps: [Step]
    /// Index of the current step in `steps`; `steps.count` when the round is over.
    public private(set) var position = 0
    /// Decided words.
    public private(set) var results: [Int: Result] = [:]
    /// Words taken out with "Bunu zaten biliyorum".
    public private(set) var skipped: Set<Int> = []
    /// The kind of question of each word; its second try keeps it.
    public let directions: [Int: Direction]

    /// `seed` mixes the order of the questions (the same seed gives the same round).
    public init(wordIDs: [Int], seed: Int) {
        var ids: [Int] = []
        var seen = Set<Int>()
        for id in wordIDs where seen.insert(id).inserted {
            ids.append(id)
        }
        let order = IntroRound.questionOrder(ids, seed: seed)
        var directions: [Int: Direction] = [:]
        for (index, id) in order.enumerated() {
            directions[id] = index % 2 == 0 ? .pickMeaning : .pickEnglish
        }
        self.directions = directions
        steps = ids.map { Step.meet(wordID: $0) } + order.map { Step.recall(wordID: $0, attempt: 1) }
    }

    public var current: Step? {
        return steps.indices.contains(position) ? steps[position] : nil
    }

    public var isFinished: Bool {
        return position >= steps.count
    }

    /// Words answered wrong once whose second try has not come yet: "Bitir" records them as
    /// missed.
    public var awaitingRetry: [Int] {
        return steps[min(position, steps.count)...].compactMap { step -> Int? in
            if case let .recall(id, attempt) = step, attempt > 1 {
                return id
            }
            return nil
        }
    }

    /// "Sonraki" on a "Tanış" card.
    public mutating func next() {
        guard case .meet? = current else {
            return
        }
        position += 1
    }

    /// "Bunu zaten biliyorum" on the current "Tanış" card: the word leaves the round and gets no
    /// question (its check comes in 3 days, `Leitner.markKnown`).
    public mutating func skipCurrent() {
        guard case let .meet(id)? = current else {
            return
        }
        skipped.insert(id)
        steps.remove(at: position)
        steps.removeAll { $0 == .recall(wordID: id, attempt: 1) }
    }

    /// "Geri al" after `skipCurrent`: the word's "Tanış" card comes back, now when `showNow`
    /// (the card on screen was not touched yet), otherwise right after it; its question goes to
    /// the end.
    public mutating func restore(_ wordID: Int, showNow: Bool) {
        guard skipped.remove(wordID) != nil else {
            return
        }
        let at = min(showNow ? position : position + 1, steps.count)
        steps.insert(.meet(wordID: wordID), at: at)
        steps.append(.recall(wordID: wordID, attempt: 1))
    }

    /// The answer to the current "Hatırla" question. Returns the word's result once it is decided
    /// (right, or wrong on the last try); nil after a first wrong answer, whose second try is
    /// then scheduled.
    @discardableResult
    public mutating func answer(right: Bool) -> Result? {
        guard case let .recall(id, attempt)? = current else {
            return nil
        }
        position += 1
        let result: Result
        if right {
            result = attempt == 1 ? .firstTry : .secondTry
        } else if attempt < IntroRound.maxAttempts {
            let left = steps.count - position
            let at = left >= IntroRound.retryGap ? position + IntroRound.retryGap : steps.count
            steps.insert(.recall(wordID: id, attempt: attempt + 1), at: at)
            return nil
        } else {
            result = .missed
        }
        results[id] = result
        return result
    }

    /// The question order: mixed by `seed`, but never the word met last first, which would be
    /// asked right after its meaning was shown.
    static func questionOrder(_ ids: [Int], seed: Int) -> [Int] {
        var order = ids
            .map { (id: $0, key: StableMix.key(seed, String($0))) }
            .sorted { a, b in
                a.key != b.key ? a.key < b.key : a.id < b.id
            }
            .map { $0.id }
        if order.count > 1, order.first == ids.last {
            order.swapAt(0, 1)
        }
        return order
    }
}

// MARK: - Hatırla questions

/// A four-option "Hatırla" question (`ReviewPlanner.introQuestion`).
public struct ChoiceQuestion: Equatable, Sendable {
    public let wordID: Int
    public let direction: IntroRound.Direction
    /// What is asked about: the English word ("Anlamını seç") or its Turkish meaning
    /// ("İngilizcesini seç").
    public let prompt: String
    public let answer: String
    /// The answer and the wrong options, mixed.
    public let options: [String]
    /// The other side of a wrong option when a card has it, for "Senin seçtiğin": the Turkish
    /// meaning of an English option ("lend" → "ödünç vermek"), the English word of a Turkish one.
    public let counterparts: [String: String]

    public init(
        wordID: Int,
        direction: IntroRound.Direction,
        prompt: String,
        answer: String,
        options: [String],
        counterparts: [String: String]
    ) {
        self.wordID = wordID
        self.direction = direction
        self.prompt = prompt
        self.answer = answer
        self.options = options
        self.counterparts = counterparts
    }
}

extension ReviewPlanner {
    /// Options of a "Hatırla" question, the answer included.
    public static let choiceCount = 4
    /// With fewer options than this, the other kind of question is tried.
    public static let minimumChoiceCount = 3

    /// The "Hatırla" question of `word` in `direction`, or in the other direction when this one
    /// cannot get enough options; nil when neither can (the caller then asks with the recall
    /// screen). Rules (docs/tasarim/ogrenme_ilkeleri.md 2.3):
    /// - "Anlamını seç": the wrong options are other cards' Turkish meanings, because the written
    ///   distractors are English. First cards of the same part of speech sharing a topic, then of
    ///   the same part of speech and level.
    /// - "İngilizcesini seç": the card's written distractors (`quiz.distractors`), topped up with
    ///   headwords chosen the same way. A distractor whose card means the same is left out.
    /// - Never another sense of the same headword, never two options with the same meaning (a
    ///   common comma- or slash-separated part counts), never a card in `excludedIDs` (a
    ///   confusable partner not learned yet).
    /// - `attempt` 2 mixes the same options again, with the answer in another place.
    public static func introQuestion(
        for word: WidgetWord,
        direction: IntroRound.Direction,
        attempt: Int,
        writtenDistractors: [String],
        candidates: [WidgetWord],
        topicsOf: [Int: Set<String>],
        excludedIDs: Set<Int> = []
    ) -> ChoiceQuestion? {
        let pool = optionPool(for: word, candidates: candidates, topicsOf: topicsOf, excludedIDs: excludedIDs)
        let other: IntroRound.Direction = direction == .pickMeaning ? .pickEnglish : .pickMeaning
        for kind in [direction, other] {
            let question: ChoiceQuestion?
            switch kind {
            case .pickMeaning:
                question = meaningQuestion(word, attempt: attempt, pool: pool)
            case .pickEnglish:
                question = englishQuestion(
                    word,
                    attempt: attempt,
                    written: writtenDistractors,
                    pool: pool,
                    candidates: candidates,
                    excludedIDs: excludedIDs
                )
            }
            if let question = question {
                return question
            }
        }
        return nil
    }

    /// Cards that may give a wrong option, best first: same part of speech with a shared topic,
    /// then same part of speech and level, each group in a stable mixed order.
    static func optionPool(
        for word: WidgetWord,
        candidates: [WidgetWord],
        topicsOf: [Int: Set<String>],
        excludedIDs: Set<Int>
    ) -> [WidgetWord] {
        let headword = foldKey(word.lemma)
        let topics = topicsOf[word.id] ?? []
        var sameTopic: [(word: WidgetWord, key: UInt64)] = []
        var sameLevel: [(word: WidgetWord, key: UInt64)] = []
        var seen = Set<Int>()
        for candidate in candidates where candidate.pos == word.pos && candidate.id != word.id {
            guard !excludedIDs.contains(candidate.id),
                  seen.insert(candidate.id).inserted,
                  foldKey(candidate.lemma) != headword else {
                continue
            }
            let entry = (word: candidate, key: StableMix.key(word.id, String(candidate.id)))
            if !topics.isDisjoint(with: topicsOf[candidate.id] ?? []) {
                sameTopic.append(entry)
            } else if candidate.level == word.level {
                sameLevel.append(entry)
            }
        }
        let mixed: ([(word: WidgetWord, key: UInt64)]) -> [WidgetWord] = { list in
            list.sorted { a, b in
                a.key != b.key ? a.key < b.key : a.word.id < b.word.id
            }.map { $0.word }
        }
        return mixed(sameTopic) + mixed(sameLevel)
    }

    private static func meaningQuestion(_ word: WidgetWord, attempt: Int, pool: [WidgetWord]) -> ChoiceQuestion? {
        guard let answer = cleaned(word.glossTR), let headword = cleaned(word.lemma) else {
            return nil
        }
        var taken = meaningParts(answer)
        var wrong: [String] = []
        var counterparts: [String: String] = [:]
        for candidate in pool {
            if wrong.count == choiceCount - 1 {
                break
            }
            guard let gloss = cleaned(candidate.glossTR) else {
                continue
            }
            let parts = meaningParts(gloss)
            guard parts.isDisjoint(with: taken) else {
                continue
            }
            taken.formUnion(parts)
            wrong.append(gloss)
            counterparts[gloss] = candidate.lemma
        }
        guard wrong.count + 1 >= minimumChoiceCount else {
            return nil
        }
        return ChoiceQuestion(
            wordID: word.id,
            direction: .pickMeaning,
            prompt: headword,
            answer: answer,
            options: mixedOptions([answer] + wrong, answer: answer, seed: word.id, attempt: attempt),
            counterparts: counterparts
        )
    }

    private static func englishQuestion(
        _ word: WidgetWord,
        attempt: Int,
        written: [String],
        pool: [WidgetWord],
        candidates: [WidgetWord],
        excludedIDs: Set<Int>
    ) -> ChoiceQuestion? {
        guard let prompt = cleaned(word.glossTR), let answer = cleaned(word.lemma) else {
            return nil
        }
        let promptParts = meaningParts(prompt)
        // The Turkish meaning of each headword (its first card): for "Senin seçtiğin", and to leave
        // out a distractor that would be a second right answer.
        var meaningOf: [String: String] = [:]
        var excludedHeadwords = Set<String>()
        for candidate in candidates {
            let key = foldKey(candidate.lemma)
            if excludedIDs.contains(candidate.id) {
                excludedHeadwords.insert(key)
            }
            if meaningOf[key] == nil, let gloss = cleaned(candidate.glossTR) {
                meaningOf[key] = gloss
            }
        }
        var used: Set<String> = [foldKey(answer)]
        var wrong: [String] = []
        var counterparts: [String: String] = [:]
        for option in written + pool.map({ $0.lemma }) {
            if wrong.count == choiceCount - 1 {
                break
            }
            guard let text = cleaned(option), used.insert(foldKey(text)).inserted else {
                continue
            }
            if excludedHeadwords.contains(foldKey(text)) {
                continue
            }
            let meaning = meaningOf[foldKey(text)]
            if let meaning = meaning, !meaningParts(meaning).isDisjoint(with: promptParts) {
                continue
            }
            wrong.append(text)
            counterparts[text] = meaning
        }
        guard wrong.count + 1 >= minimumChoiceCount else {
            return nil
        }
        return ChoiceQuestion(
            wordID: word.id,
            direction: .pickEnglish,
            prompt: prompt,
            answer: answer,
            options: mixedOptions([answer] + wrong, answer: answer, seed: word.id, attempt: attempt),
            counterparts: counterparts
        )
    }

    /// The options in a stable mixed order; a second attempt mixes them again with the answer in
    /// another place, so the place is never what is learned.
    static func mixedOptions(_ options: [String], answer: String, seed: Int, attempt: Int) -> [String] {
        func order(_ attempt: Int) -> [String] {
            let salt = seed &* 31 &+ attempt
            return options
                .map { (text: $0, key: StableMix.key(salt, $0)) }
                .sorted { a, b in
                    a.key != b.key ? a.key < b.key : a.text < b.text
                }
                .map { $0.text }
        }
        var result = order(attempt)
        if attempt > 1, result.count > 1,
           let before = order(attempt - 1).firstIndex(of: answer),
           result.firstIndex(of: answer) == before {
            result.append(result.removeFirst())
        }
        return result
    }

    /// The meanings a Turkish gloss names: "durmak, durdurmak" gives "durmak", "durdurmak" and the
    /// whole gloss; "/" and ";" separate too. Two glosses with a common part are the same option.
    static func meaningParts(_ gloss: String) -> Set<String> {
        var parts = Set(gloss.split(whereSeparator: { ",/;".contains($0) }).map { foldKey(String($0)) })
        parts.insert(foldKey(gloss))
        parts.remove("")
        return parts
    }

    static func foldKey(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func cleaned(_ text: String?) -> String? {
        guard let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}

/// FNV-1a over "seed|text": a stable mix, the same on every device and launch (unlike Swift's
/// per-process `Hasher`). The same scheme as `CardDetail.Quiz.options(seed:)`.
enum StableMix {
    static func key(_ seed: Int, _ text: String) -> UInt64 {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in "\(seed)|\(text)".utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
        return hash
    }
}
