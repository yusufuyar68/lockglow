import Foundation
import CoreModels

/// A three-option "Bu kelime ne demek?" question of the quiz widget (`QuizWidgetQuestions`).
/// The arrays run in the order the options are shown.
public struct MeaningChoice: Equatable, Sendable {
    public let wordID: Int
    /// The word's own meaning and other cards' meanings.
    public let options: [String]
    public let answerIndex: Int
    /// The card's short meaning (`gloss_short`) behind each option; nil when it has none.
    public let shortOptions: [String?]
    /// The English word each option is the meaning of; the word itself for the answer.
    public let optionWords: [String]

    public init(wordID: Int, options: [String], answerIndex: Int, shortOptions: [String?], optionWords: [String]) {
        self.wordID = wordID
        self.options = options
        self.answerIndex = answerIndex
        self.shortOptions = shortOptions
        self.optionWords = optionWords
    }
}

/// The questions of the quiz widget (ios/Widgets/QuizWidget.swift). Pure: the app writes the result
/// into `widget_quiz.json` together with the widget plan (App/AppModel+QuizWidget.swift).
///
/// **Which words** (docs/tasarim/ogrenme_ilkeleri.md 2.1): those of the widget queue, so the quiz
/// follows the word widget's rules: the user's deck, no personal-topic card, never a word "Tekrar"
/// asks within `QueueComposer.hiddenBeforeDue` before it is answered (the quiz shows the answer at
/// once, so it would turn the coming recall into recognition), no "Biliyorum" word waiting for its
/// check. The queue's first word is kept to the same rule, although the word widget keeps it while
/// it is on screen. The rule also holds after the file is written: each question carries the moment
/// it may no longer be asked (`askUntil`), and the widget passes it over from then on.
/// Only words the learner has met: answered in "Tekrar" (learning or known), or seen on a widget
/// with a tap (`exposures`). A new word is first seen with its meaning, on the widget and in
/// "Tanış" (2.1 rule b); guessing a meaning never seen helps little (2.3, Grimaldi and Karpicke
/// 2012). The word met longest ago comes first (`lastSeenAt`): a recall after a longer gap teaches
/// more, and a word just answered on the quiz goes to the end of the next file.
///
/// **Options** (2.3, "Türkçe şık kuralı"): like "Hatırla"'s "Anlamını seç" (`ReviewPlanner`), other
/// cards' Turkish meanings, first of the same part of speech sharing a topic, then of the same part
/// of speech and level. Never another sense of the same headword, never two options with a common
/// meaning (a common comma- or slash-separated part counts, short forms too), never a personal-topic
/// card, and never a confusable partner of the word (either direction), whatever its box: the widget
/// has no room to explain the pair, so it would only teach the mix-up. An option needs a form (the
/// whole meaning, the short one or the first sense) without a word longer than `maxWordLength`
/// letters: the medium widget's option boxes are about 80 pt wide on an iPhone SE, and a word is
/// never broken or cut. Only 3 of 1,203 cards have none ("fotoğrafçılık", "yakınlaştırmak",
/// "dolandırıcılık"); they are neither options nor asked.
///
/// **Order:** the wrong options are mixed per word and attempt; the answer moves one place on with
/// every attempt, so over three attempts it stands once in each place (ogrenme_ilkeleri.md §1 item
/// 4: the place is never what is learned). The app passes the word's exposures + 1, which every
/// answer on the widget raises.
///
/// Seeing the answer is not a review: the app records an answer as an exposure only
/// (`WidgetEventType.quiz`, `ProgressIngest`), never as a grade, so "Tekrar" keeps its schedule.
public enum QuizWidgetQuestions {
    /// Options of a question, the answer included.
    public static let optionCount = 3
    /// Questions in one file: about a day of answers; the app writes new ones on every plan.
    public static let limit = 24
    /// The longest word an option may need (see the type's comment).
    public static let maxWordLength = 12

    /// The words to ask, best first: met words that may be asked (`isAsked`), the one met longest
    /// ago first, then in queue order; no repeats.
    public static func words(
        from queue: [WidgetWord],
        progress: [Int: WordProgress],
        now: Date,
        calendar: Calendar = .current
    ) -> [WidgetWord] {
        var met: [(word: WidgetWord, seen: Date, order: Int)] = []
        var listed = Set<Int>()
        for (order, word) in queue.enumerated() where listed.insert(word.id).inserted {
            guard let p = progress[word.id], isMet(p), isAsked(word, progress: p, now: now, calendar: calendar) else {
                continue
            }
            met.append((word, p.lastSeenAt ?? .distantPast, order))
        }
        return met.sorted { a, b in
            a.seen != b.seen ? a.seen < b.seen : a.order < b.order
        }.map { $0.word }
    }

    /// Answered in "Tekrar", or seen on a widget with a tap.
    public static func isMet(_ progress: WordProgress) -> Bool {
        return progress.state != .new || progress.exposures > 0 || progress.reviews > 0
    }

    /// Whether the quiz may ask `word` at `now`: it has a word and a Turkish meaning, is not a
    /// personal-topic card, waits for no "Biliyorum" check, and "Tekrar" does not ask it soon
    /// (`askUntil`).
    public static func isAsked(
        _ word: WidgetWord,
        progress: WordProgress?,
        now: Date,
        calendar: Calendar = .current
    ) -> Bool {
        guard !word.isSensitive, cleaned(word.lemma) != nil, cleaned(word.glossTR) != nil else {
            return false
        }
        guard let p = progress else {
            return true
        }
        if p.state == .known && p.knownOverride {
            return false
        }
        return askUntil(of: p, now: now, calendar: calendar).map { now < $0 } ?? true
    }

    /// The moment from which the quiz may no longer ask the word, the same rule as
    /// `QueueComposer`: `QueueComposer.hiddenBeforeDue` before its review or refresher is due; a
    /// learning word answered today may be asked until the end of the day even when due sooner
    /// (a word just answered may show again). Nil: no limit (a new word, or nothing scheduled).
    public static func askUntil(of progress: WordProgress, now: Date, calendar: Calendar = .current) -> Date? {
        guard progress.state != .new, let due = progress.dueAt else {
            return nil
        }
        let hidden = due.addingTimeInterval(-QueueComposer.hiddenBeforeDue)
        if progress.state == .learning, let answer = QueueComposer.lastAnswer(of: progress),
           answer.at >= calendar.startOfDay(for: now), answer.at <= now,
           let endOfToday = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) {
            return max(hidden, endOfToday)
        }
        return hidden
    }

    /// The question about `word`, or nil when its meaning is missing or fewer than
    /// `optionCount - 1` wrong options can be found. `candidates` are the cards options may come
    /// from (every loaded word); `attempt` 1 or more.
    public static func question(
        for word: WidgetWord,
        attempt: Int,
        candidates: [WidgetWord],
        topicsOf: [Int: Set<String>]
    ) -> MeaningChoice? {
        guard let answer = cleaned(word.glossTR), let headword = cleaned(word.lemma) else {
            return nil
        }
        let answerShort = shortForm(of: word, gloss: answer)
        guard fitsNarrowBox(answer, short: answerShort) else {
            return nil
        }
        let partners = Set(word.confusableIDs ?? [])
        let allowed = candidates.filter { candidate in
            !candidate.isSensitive
                && !partners.contains(candidate.id)
                && !(candidate.confusableIDs ?? []).contains(word.id)
        }
        let pool = ReviewPlanner.optionPool(for: word, candidates: allowed, topicsOf: topicsOf, excludedIDs: [])

        var taken = parts(answer, short: answerShort)
        var shortOf: [String: String] = [:]
        var wordOf: [String: String] = [answer: headword]
        if let answerShort = answerShort {
            shortOf[answer] = answerShort
        }
        var wrong: [String] = []
        for candidate in pool {
            if wrong.count == optionCount - 1 {
                break
            }
            guard let gloss = cleaned(candidate.glossTR), let lemma = cleaned(candidate.lemma) else {
                continue
            }
            let short = shortForm(of: candidate, gloss: gloss)
            let candidateParts = parts(gloss, short: short)
            guard candidateParts.isDisjoint(with: taken), fitsNarrowBox(gloss, short: short) else {
                continue
            }
            taken.formUnion(candidateParts)
            wrong.append(gloss)
            wordOf[gloss] = lemma
            if let short = short {
                shortOf[gloss] = short
            }
        }
        guard wrong.count == optionCount - 1 else {
            return nil
        }
        let options = arranged(answer: answer, wrong: wrong, seed: word.id, attempt: max(attempt, 1))
        guard let answerIndex = options.firstIndex(of: answer) else {
            return nil
        }
        return MeaningChoice(
            wordID: word.id,
            options: options,
            answerIndex: answerIndex,
            shortOptions: options.map { shortOf[$0] },
            optionWords: options.map { wordOf[$0] ?? "" }
        )
    }

    /// The options in the order shown: the wrong ones in a stable mixed order for `seed` and
    /// `attempt`, the answer at place `(start + attempt) mod count`, where `start` is fixed per
    /// word. The same on every device and launch.
    static func arranged(answer: String, wrong: [String], seed: Int, attempt: Int) -> [String] {
        let salt = seed &* 31 &+ attempt
        var result = wrong
            .map { (text: $0, key: StableMix.key(salt, $0)) }
            .sorted { a, b in
                a.key != b.key ? a.key < b.key : a.text < b.text
            }
            .map { $0.text }
        let count = result.count + 1
        let start = Int(StableMix.key(seed, "answer") % UInt64(count))
        let place = ((start + attempt % count) % count + count) % count
        result.insert(answer, at: place)
        return result
    }

    // MARK: Helpers

    /// Whether an option has a form without a word longer than `maxWordLength`: the whole
    /// meaning, its short form, or its first sense (what the widget shows without a short form).
    public static func fitsNarrowBox(_ gloss: String, short: String?) -> Bool {
        let firstSense = gloss.split(whereSeparator: { ",;".contains($0) }).first.map(String.init) ?? gloss
        return [gloss, short ?? firstSense, firstSense].contains { form in
            !form.split(separator: " ").contains { $0.count > maxWordLength }
        }
    }

    /// The card's short meaning when it differs from the whole one.
    private static func shortForm(of word: WidgetWord, gloss: String) -> String? {
        guard let short = cleaned(word.glossShortTR), short != gloss else {
            return nil
        }
        return short
    }

    /// The meanings an option names, its short form's too (`ReviewPlanner.meaningParts`).
    private static func parts(_ gloss: String, short: String?) -> Set<String> {
        var result = ReviewPlanner.meaningParts(gloss)
        if let short = short {
            result.formUnion(ReviewPlanner.meaningParts(short))
        }
        return result
    }

    private static func cleaned(_ text: String?) -> String? {
        guard let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}
