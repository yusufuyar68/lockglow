import Foundation
import CoreModels

/// "Seviye testi": about two minutes, 20–25 real cards, each asked with four Turkish meanings and
/// "Emin değilim". The result is only a start level (A1, A2, B1 or B2): nothing is marked known and
/// no progress is written. Pure and deterministic: the view asks `current`, shows its question and
/// calls `answer(right:)` (or `skipCurrent()` when the word has no usable question).
///
/// How the level is found
/// - The levels are A1, A2, B1 and B2 (`allLevels`); B2 joins only when the bank has at least
///   `minimumWordsForB2` B2 words, otherwise the test runs on A1–B1 alone (`levels(for:)`).
/// - The unknown is how much of each level the user knows: a share per level, never more for a
///   harder level than for an easier one. Every monotone combination on a 20-step grid is equally
///   likely at the start; each answer reweighs them. A right pick may be a lucky guess
///   (`guessRate`); "Emin değilim" and a wrong pick both say the word is not known.
/// - The start level is the first level the user does not mostly know (`mastery`, 80 %): A1 when
///   A1 is not mostly known, A2 when A1 is and A2 is not, and so on; the top level when all the
///   others are. `result` is the most likely of them.
/// - The next word comes from the level whose "mostly known" is least certain among the levels
///   that decide (every level but the top one: A1–B1 with B2, A1–A2 without); once the result is
///   clear, from the result's level. A known word never leads to an easier word and an unknown
///   one never to a harder word; a known word of a level that now looks mostly known leads one
///   level up. The test starts with an A1 word.
/// - The test ends after `minimumQuestions` once the result holds `confidenceToStop` of the
///   weight, and always after `maximumQuestions` (or when no word is left).
///
/// Checked with simulated learners (gradual and sharp, guessing or not): on three levels the
/// result was the right level for 79–93 % of them and never two levels off. Four levels in the
/// same 20–25 words (2026-10-26, 400 learners, 100 of each kind): right for 93–96 % of sharp learners and 67–77 %
/// of gradual ones; up to 10 % of the gradual ones, whose shares sit near 80 % on two levels,
/// were two levels off. A longer test (28 or 30 words) did not do better, so the length stays.
public struct PlacementTest: Equatable, Sendable {
    /// Every level the test can give, easiest first.
    public static let allLevels: [Level] = [.a1, .a2, .b1, .b2]
    /// The levels every test has; each needs at least one word (`canRun`).
    public static let coreLevels: [Level] = [.a1, .a2, .b1]
    /// B2 words a bank needs before the test asks B2 at all. Someone who knows A1–B1 is asked up
    /// to about 10 B2 words; 15 leave room for words without a usable question (`skipCurrent`).
    /// With fewer the test stays on A1–B1 and never gives B2.
    public static let minimumWordsForB2 = 15
    public static let minimumQuestions = 20
    public static let maximumQuestions = 25
    /// "Mostly known": the share of a level's words the user knows before the next level starts.
    public static let mastery = 0.8
    /// How often a right pick is only a guess (four options, and "Emin değilim" for the rest).
    public static let guessRate = 0.2
    public static let confidenceToStop = 0.85
    /// Fewer words than this in the bank and the test is not offered (`canRun`).
    public static let minimumBankSize = maximumQuestions

    public struct Answer: Equatable, Sendable {
        public let wordID: Int
        public let level: Level
        public let right: Bool
    }

    /// The word to ask now.
    public struct Question: Equatable, Sendable {
        public let wordID: Int
        public let level: Level
    }

    /// The levels this test asks and can give, easiest first (`levels(for:)`).
    public let levels: [Level]
    /// Every word asked so far, in order.
    public private(set) var answers: [Answer] = []
    public private(set) var current: Question?
    /// Words of each level in the order they are asked, mixed by the seed.
    private let queues: [Level: [Int]]
    private var nextIndex: [Level: Int] = [:]
    /// The share combinations for `levels` (`ShareGrid.states(count:)`).
    private let states: [[Double]]
    /// Log weight of each combination in `states`.
    private var logWeights: [Double]
    /// `logWeights` made to sum to 1, kept after every answer (it is read several times).
    private var weights: [Double]

    /// `bank`: word ids by level (other levels are ignored, each id once). `seed` mixes the order,
    /// so a second test asks other words.
    public init(bank: [Level: [Int]], seed: Int) {
        let levels = PlacementTest.levels(for: bank)
        var queues: [Level: [Int]] = [:]
        var seen = Set<Int>()
        for level in levels {
            let ids = (bank[level] ?? []).filter { seen.insert($0).inserted }
            queues[level] = ids
                .map { (id: $0, key: StableMix.key(seed, "placement|\($0)")) }
                .sorted { $0.key != $1.key ? $0.key < $1.key : $0.id < $1.id }
                .map { $0.id }
        }
        self.levels = levels
        self.queues = queues
        let states = ShareGrid.states(count: levels.count)
        let logWeights = Array(repeating: 0.0, count: states.count)
        self.states = states
        self.logWeights = logWeights
        weights = ShareGrid.normalized(logWeights)
        current = nil
        current = pickNext()
    }

    /// The levels a test on `bank` asks: A1–B1, and B2 when the bank has at least
    /// `minimumWordsForB2` B2 words (a word already in an easier level does not count).
    public static func levels(for bank: [Level: [Int]]) -> [Level] {
        let easier = Set(coreLevels.flatMap { bank[$0] ?? [] })
        let b2 = Set((bank[.b2] ?? []).filter { !easier.contains($0) })
        return b2.count >= minimumWordsForB2 ? allLevels : coreLevels
    }

    /// Whether a bank has enough words for a whole test: every level of A1–B1 has some.
    public static func canRun(bank: [Level: [Int]]) -> Bool {
        let ids = levels(for: bank).flatMap { bank[$0] ?? [] }
        return Set(ids).count >= minimumBankSize && coreLevels.allSatisfy { !(bank[$0] ?? []).isEmpty }
    }

    public var isFinished: Bool {
        return current == nil
    }

    /// The answer to `current`: the right meaning was picked, or not ("Emin değilim" is not).
    public mutating func answer(right: Bool) {
        guard let question = current else {
            return
        }
        consume(question)
        answers.append(Answer(wordID: question.wordID, level: question.level, right: right))
        let index = levels.firstIndex(of: question.level) ?? 0
        let g = PlacementTest.guessRate
        for (i, state) in states.enumerated() {
            let p = g + (1 - g) * state[index]
            logWeights[i] += log(right ? p : 1 - p)
        }
        weights = ShareGrid.normalized(logWeights)
        current = shouldStop ? nil : pickNext()
    }

    /// `current` has no usable question (too few options): the next word of the same level comes
    /// instead, and nothing is counted.
    public mutating func skipCurrent() {
        guard let question = current else {
            return
        }
        consume(question)
        current = pickNext()
    }

    /// The most likely start level so far; read it once `isFinished`.
    public var result: Level {
        let weights = classWeights
        var best = 0
        for k in 1..<weights.count where weights[k] > weights[best] {
            best = k
        }
        return levels[best]
    }

    /// The share of the weight that `result` holds, 0...1.
    public var confidence: Double {
        return classWeights.max() ?? 0
    }

    /// How likely each of `levels` is "mostly known".
    func masteryProbabilities() -> [Double] {
        var result = Array(repeating: 0.0, count: levels.count)
        for (state, w) in zip(states, weights) {
            for k in 0..<levels.count where state[k] >= PlacementTest.mastery {
                result[k] += w
            }
        }
        return result
    }

    // MARK: Inside

    /// Weight of each of `levels` as the start level.
    private var classWeights: [Double] {
        var result = Array(repeating: 0.0, count: levels.count)
        for (state, w) in zip(states, weights) {
            result[ShareGrid.startLevelIndex(of: state)] += w
        }
        return result
    }

    private var shouldStop: Bool {
        if answers.count >= PlacementTest.maximumQuestions {
            return true
        }
        return answers.count >= PlacementTest.minimumQuestions && confidence >= PlacementTest.confidenceToStop
    }

    private mutating func consume(_ question: Question) {
        nextIndex[question.level, default: 0] += 1
    }

    private func hasWords(_ level: Level) -> Bool {
        return (nextIndex[level] ?? 0) < (queues[level]?.count ?? 0)
    }

    /// The level to ask next (see the type's comment), then its next word; a level without words
    /// left gives way to the nearest one that has some. Nil when no word is left.
    private func pickNext() -> Question? {
        let mastery = masteryProbabilities()
        var target = 0
        if !answers.isEmpty && confidence >= PlacementTest.confidenceToStop {
            target = levels.firstIndex(of: result) ?? 1
        } else {
            // The deciding levels are all but the top one; a tie goes to the easier level.
            for k in 0..<max(1, levels.count - 1) where abs(mastery[k] - 0.5) < abs(mastery[target] - 0.5) {
                target = k
            }
        }
        if let last = answers.last, let lastIndex = levels.firstIndex(of: last.level) {
            if last.right {
                // A known word of a level that now looks mostly known: one level harder.
                if mastery[lastIndex] >= 0.5 {
                    target = max(target, min(levels.count - 1, lastIndex + 1))
                }
                target = max(target, lastIndex)
            } else {
                target = min(target, lastIndex)
            }
        }
        let order = levels.indices.sorted { a, b in
            let da = abs(a - target)
            let db = abs(b - target)
            return da != db ? da < db : a < b
        }
        guard let index = order.first(where: { hasWords(levels[$0]) }) else {
            return nil
        }
        let level = levels[index]
        guard let id = queues[level]?[nextIndex[level] ?? 0] else {
            return nil
        }
        return Question(wordID: id, level: level)
    }
}

/// Every combination of known shares (A1 ≥ A2 ≥ B1, and ≥ B2 on four levels) on a 20-step grid of
/// midpoints (0.025 … 0.975), so no answer is ever impossible. Three levels give 1,540
/// combinations, four give 8,855; an answer walks them about eight times (some 70,000 simple
/// steps: about a millisecond on a phone, more in a debug build), so four levels keep the 20
/// steps. A 10-step grid (715 combinations) would be coarser than the 80 % line it decides on.
enum ShareGrid {
    static let steps: [Double] = (0..<20).map { (Double($0) + 0.5) / 20 }

    private static let three = make(count: 3)
    private static let four = make(count: 4)

    /// The combinations for `count` levels (3 and 4 are made once; another count on the spot).
    static func states(count: Int) -> [[Double]] {
        switch count {
        case 3: return three
        case 4: return four
        default: return make(count: count)
        }
    }

    /// Every non-increasing sequence of `count` steps, easiest level first.
    private static func make(count: Int) -> [[Double]] {
        guard count > 0 else {
            return []
        }
        var result: [[Double]] = [[]]
        for _ in 0..<count {
            var longer: [[Double]] = []
            for prefix in result {
                for step in steps where step <= (prefix.last ?? 1) {
                    longer.append(prefix + [step])
                }
            }
            result = longer
        }
        return result
    }

    /// The start level of a combination: the first level not mostly known, the top level when
    /// every other one is.
    static func startLevelIndex(of state: [Double]) -> Int {
        for k in 0..<max(0, state.count - 1) where state[k] < PlacementTest.mastery {
            return k
        }
        return max(0, state.count - 1)
    }

    /// Log weights made to sum to 1.
    static func normalized(_ logWeights: [Double]) -> [Double] {
        let top = logWeights.max() ?? 0
        let raw = logWeights.map { exp($0 - top) }
        let sum = raw.reduce(0, +)
        return sum > 0 ? raw.map { $0 / sum } : raw
    }
}
