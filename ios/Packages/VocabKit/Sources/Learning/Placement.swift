import Foundation
import CoreModels

/// "Seviye testi": about two minutes, 20–25 real cards, each asked with four Turkish meanings and
/// "Emin değilim". The result is only a start level (A1, A2 or B1): nothing is marked known and no
/// progress is written. Pure and deterministic: the view asks `current`, shows its question and
/// calls `answer(right:)` (or `skipCurrent()` when the word has no usable question).
///
/// How the level is found
/// - The unknown is how much of each level the user knows: a share for A1, A2 and B1, never more
///   for a harder level than for an easier one. Every monotone combination on a 20-step grid is
///   equally likely at the start; each answer reweighs them. A right pick may be a lucky guess
///   (`guessRate`); "Emin değilim" and a wrong pick both say the word is not known.
/// - The start level is the first level the user does not mostly know (`mastery`, 80 %): A1 when
///   A1 is not mostly known, A2 when A1 is and A2 is not, B1 when both are. `result` is the most
///   likely of the three.
/// - The next word comes from the level whose "mostly known" is least certain, A1 or A2 (the two
///   that decide); once the result is clear, from the result's level. A known word never leads to
///   an easier word and an unknown one never to a harder word; a known word of a level that now
///   looks mostly known leads one level up. The test starts with an A1 word.
/// - The test ends after `minimumQuestions` once the result holds `confidenceToStop` of the
///   weight, and always after `maximumQuestions` (or when no word is left).
///
/// Checked with simulated learners (gradual and sharp, guessing or not): the result was the right
/// level for 79–93 % of them and never two levels off.
public struct PlacementTest: Equatable, Sendable {
    /// The levels the test can give, easiest first (the content has A1–B1 cards).
    public static let levels: [Level] = [.a1, .a2, .b1]
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

    /// Every word asked so far, in order.
    public private(set) var answers: [Answer] = []
    public private(set) var current: Question?
    /// Words of each level in the order they are asked, mixed by the seed.
    private let queues: [Level: [Int]]
    private var nextIndex: [Level: Int] = [:]
    /// Log weight of each share combination in `ShareGrid.states`.
    private var logWeights: [Double]

    /// `bank`: word ids by level (other levels are ignored, each id once). `seed` mixes the order,
    /// so a second test asks other words.
    public init(bank: [Level: [Int]], seed: Int) {
        var queues: [Level: [Int]] = [:]
        var seen = Set<Int>()
        for level in PlacementTest.levels {
            let ids = (bank[level] ?? []).filter { seen.insert($0).inserted }
            queues[level] = ids
                .map { (id: $0, key: StableMix.key(seed, "placement|\($0)")) }
                .sorted { $0.key != $1.key ? $0.key < $1.key : $0.id < $1.id }
                .map { $0.id }
        }
        self.queues = queues
        logWeights = Array(repeating: 0, count: ShareGrid.states.count)
        current = nil
        current = pickNext()
    }

    /// Whether a bank has enough words for a whole test.
    public static func canRun(bank: [Level: [Int]]) -> Bool {
        let ids = levels.flatMap { bank[$0] ?? [] }
        return Set(ids).count >= minimumBankSize && levels.allSatisfy { !(bank[$0] ?? []).isEmpty }
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
        let index = ShareGrid.index(of: question.level)
        let g = PlacementTest.guessRate
        for (i, state) in ShareGrid.states.enumerated() {
            let p = g + (1 - g) * state[index]
            logWeights[i] += log(right ? p : 1 - p)
        }
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
        return PlacementTest.levels[best]
    }

    /// The share of the weight that `result` holds, 0...1.
    public var confidence: Double {
        return classWeights.max() ?? 0
    }

    /// How likely each level is "mostly known" (A1, A2, B1).
    func masteryProbabilities() -> [Double] {
        let weights = normalizedWeights
        var result = [0.0, 0.0, 0.0]
        for (state, w) in zip(ShareGrid.states, weights) {
            for k in 0..<3 where state[k] >= PlacementTest.mastery {
                result[k] += w
            }
        }
        return result
    }

    // MARK: Inside

    private var normalizedWeights: [Double] {
        let top = logWeights.max() ?? 0
        let raw = logWeights.map { exp($0 - top) }
        let sum = raw.reduce(0, +)
        return raw.map { $0 / sum }
    }

    /// Weight of A1, A2, B1 as the start level.
    private var classWeights: [Double] {
        var result = [0.0, 0.0, 0.0]
        for (state, w) in zip(ShareGrid.states, normalizedWeights) {
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
        let levels = PlacementTest.levels
        let mastery = masteryProbabilities()
        var target: Int
        if !answers.isEmpty && confidence >= PlacementTest.confidenceToStop {
            target = levels.firstIndex(of: result) ?? 1
        } else {
            target = abs(mastery[1] - 0.5) < abs(mastery[0] - 0.5) ? 1 : 0
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

/// Every combination of known shares (A1 ≥ A2 ≥ B1) on a 20-step grid of midpoints (0.025 …
/// 0.975), so no answer is ever impossible.
enum ShareGrid {
    static let steps: [Double] = (0..<20).map { (Double($0) + 0.5) / 20 }

    static let states: [[Double]] = {
        var result: [[Double]] = []
        for a1 in steps {
            for a2 in steps where a2 <= a1 {
                for b1 in steps where b1 <= a2 {
                    result.append([a1, a2, b1])
                }
            }
        }
        return result
    }()

    static func index(of level: Level) -> Int {
        return PlacementTest.levels.firstIndex(of: level) ?? 0
    }

    /// The start level of a combination: the first level not mostly known, B1 at the top.
    static func startLevelIndex(of state: [Double]) -> Int {
        if state[0] < PlacementTest.mastery {
            return 0
        }
        if state[1] < PlacementTest.mastery {
            return 1
        }
        return 2
    }
}
