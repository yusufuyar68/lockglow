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
/// it is on screen. Words the learner has met (seen on a widget, or answered) come first: the quiz
/// is a short recall of them; new words follow, a guess whose answer comes at once.
///
/// **Options** (2.3, "Türkçe şık kuralı"): like "Hatırla"'s "Anlamını seç" (`ReviewPlanner`), other
/// cards' Turkish meanings, first of the same part of speech sharing a topic, then of the same part
/// of speech and level. Never another sense of the same headword, never two options with a common
/// meaning (a common comma- or slash-separated part counts, short forms too), never a personal-topic
/// card, and never a confusable partner of the word (either direction), whatever its box: the widget
/// has no room to explain the pair, so it would only teach the mix-up.
///
/// **Order:** mixed per word and attempt (`ReviewPlanner.mixedOptions`); the app passes the word's
/// exposures + 1, so each new set of questions after an answer puts it in another place.
///
/// Seeing the answer is not a review: the app records an answer as an exposure only
/// (`WidgetEventType.quiz`, `ProgressIngest`), never as a grade, so "Tekrar" keeps its schedule.
public enum QuizWidgetQuestions {
    /// Options of a question, the answer included.
    public static let optionCount = 3
    /// Questions in one file: about a day of answers; the app writes new ones on every plan.
    public static let limit = 24

    /// The words to ask, best first: met words, then new ones, each in queue order; no repeats.
    public static func words(
        from queue: [WidgetWord],
        progress: [Int: WordProgress],
        now: Date,
        calendar: Calendar = .current
    ) -> [WidgetWord] {
        var met: [WidgetWord] = []
        var fresh: [WidgetWord] = []
        var seen = Set<Int>()
        for word in queue where seen.insert(word.id).inserted {
            let p = progress[word.id]
            guard isAsked(word, progress: p, now: now, calendar: calendar) else {
                continue
            }
            if let p = p, p.state != .new || p.exposures > 0 || p.reviews > 0 {
                met.append(word)
            } else {
                fresh.append(word)
            }
        }
        return met + fresh
    }

    /// Whether the quiz may ask `word` at `now`: it has a word and a Turkish meaning, is not a
    /// personal-topic card, and "Tekrar" does not ask it soon (the same rule as `QueueComposer`):
    /// a learning word is asked when it was answered today or falls due after
    /// `QueueComposer.hiddenBeforeDue`; a known word when it waits for no "Biliyorum" check and
    /// its refresher is not due by then.
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
        let hideUntil = now.addingTimeInterval(QueueComposer.hiddenBeforeDue)
        switch p.state {
        case .new:
            return true
        case .learning:
            if let answer = QueueComposer.lastAnswer(of: p), answer.at >= calendar.startOfDay(for: now), answer.at <= now {
                return true
            }
            return (p.dueAt ?? .distantFuture) > hideUntil
        case .known:
            return !p.knownOverride && (p.dueAt ?? .distantFuture) > hideUntil
        }
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
        let partners = Set(word.confusableIDs ?? [])
        let allowed = candidates.filter { candidate in
            !candidate.isSensitive
                && !partners.contains(candidate.id)
                && !(candidate.confusableIDs ?? []).contains(word.id)
        }
        let pool = ReviewPlanner.optionPool(for: word, candidates: allowed, topicsOf: topicsOf, excludedIDs: [])

        let answerShort = shortForm(of: word, gloss: answer)
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
            guard candidateParts.isDisjoint(with: taken) else {
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
        let options = ReviewPlanner.mixedOptions([answer] + wrong, answer: answer, seed: word.id, attempt: max(attempt, 1))
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

    // MARK: Helpers

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
