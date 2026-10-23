import Foundation

/// FSRS's weights fitted to the user's own review log ("Yeni zamanlama", docs/ozellik_planlari/fsrs.md
/// 4.3 step 9). Pure, no I/O: `AppModel` reads the log and stores the result.
///
/// Only w0...w3 are fitted: the stability after a word's first answer, one per grade. They matter
/// most for a learner who meets many new words, they can be read straight off the log, and they
/// need no gradient descent. A simplified version of fsrs-rs's "pretrain" step:
/// - A sample is a word whose first answer ever is in the log (`reviews == 1`, no `seed`, not the
///   "Biliyorum" check) and whose next answer (`reviews == 2`) came at least one whole day later:
///   (first grade, t = whole days between them, recalled = the next answer was not "Bilemedim").
///   A second answer on the same day says nothing about the forgetting curve; that word is left out.
/// - Per grade, the stability S that maximises the Bernoulli log-likelihood of the samples under
///   FSRS's forgetting curve R(t, S) = (1 + f · t / S)^(−w20), f = 0.9^(−1/w20) − 1, with w20 from
///   `base`, corrected for guessing: a sample counts as recalled with p = g + (1 − g) · R(t, S),
///   g = `guessChance`, clipped to [1e-4, 1 − 1e-4]. S is searched in 0.1...100 days on a log
///   grid, then refined by golden section: deterministic, the same log always gives the same weights.
/// - Shrinkage toward `base`: ln S = (n · ln S_fit + k · ln S_base) / (n + k), n samples,
///   k = `priorWeight`. A few samples move the weight a little, many move it close to the fit.
/// - Clamped to `FSRS.weightBounds`, then made monotonic (w0 ≤ w1 ≤ w2 ≤ w3: an easier first
///   answer never means a shorter memory) by pooling adjacent violators, weighted n + k, at their
///   geometric mean.
///
/// Thresholds: below `minimumAnswers` log entries nothing is fitted (the Anki manual: optimizing
/// works poorly with less than "a few hundred reviews"); a grade with fewer than `minimumSamples`
/// samples keeps its `base` weight. w4...w20 always stay as in `base`. A result that fails
/// `FSRS.areValid(weights:)` falls back to `base`.
public struct FSRSParameterFit: Equatable, Sendable {
    /// 21 valid weights: `base` with w0...w3 (first stabilities) replaced where fitted.
    public let weights: [Double]
    /// True when at least one of w0...w3 differs from `base`.
    public let isPersonal: Bool
    /// Entries in the log given to `fit`.
    public let answerCount: Int
    /// 4 counts (again, hard, good, easy): first answers with a usable next answer.
    public let samples: [Int]

    /// Below this many log entries: `base` unchanged.
    public static let minimumAnswers = 400
    /// Per grade, below this many samples: that grade keeps `base`.
    public static let minimumSamples = 16
    /// Pseudo-count pulling a fit toward `base` in log space.
    public static let priorWeight: Double = 32
    /// The chance that a sample's second answer is right without remembering the word. After
    /// Tanış, Lockglow's first real question is the 4-option fill-in-the-blank one
    /// (ogrenme_ilkeleri 1.2, 2.4), so a learner who has forgotten the word still picks the right
    /// option about one time in four. A recall-screen answer would have no such chance (g = 0),
    /// but the log does not record the question type, and a word on basamak 1 is always asked with
    /// the cloze when it has one; 1/4 is used for every sample. Ignoring it would read those lucky
    /// picks as memory and inflate the fitted first stabilities.
    public static let guessChance = 0.25

    /// The stabilities the search looks at, in days.
    private static let searchRange: ClosedRange<Double> = 0.1...100
    private static let gridSteps = 240
    private static let refineSteps = 80
    private static let day: TimeInterval = 86_400
    private static let longestGapDays = 36_500

    private struct Bucket {
        var count: Int
        var recalled: Int
    }

    /// `base` with w0...w3 fitted to `entries` (in the order written, as `ReviewLog.entries`).
    public static func fit(_ entries: [ReviewLogEntry], base: [Double] = FSRS.defaultWeights) -> FSRSParameterFit {
        let buckets = firstIntervals(entries)
        let samples = buckets.map { grade in grade.values.reduce(0) { $0 + $1.count } }
        let unchanged = FSRSParameterFit(weights: base, isPersonal: false, answerCount: entries.count, samples: samples)
        guard entries.count >= minimumAnswers, FSRS.areValid(weights: base) else {
            return unchanged
        }
        let decay = base.count > 20 ? base[20] : 0.5

        var stabilities: [Double] = []
        var masses: [Double] = []
        for index in 0..<4 {
            let baseStability = base[index]
            guard samples[index] >= minimumSamples else {
                stabilities.append(baseStability)
                masses.append(priorWeight)
                continue
            }
            let points = buckets[index].keys.sorted().map { t -> (t: Double, count: Double, recalled: Double) in
                let bucket = buckets[index][t] ?? Bucket(count: 0, recalled: 0)
                return (Double(t), Double(bucket.count), Double(bucket.recalled))
            }
            let fitted = bestLogStability(points, decay: decay)
            let n = Double(samples[index])
            let shrunk = (n * fitted + priorWeight * log(baseStability)) / (n + priorWeight)
            stabilities.append(clamp(exp(shrunk), index: index))
            masses.append(n + priorWeight)
        }

        let monotonic = poolAdjacentViolators(stabilities, masses: masses)
        var weights = base
        for index in 0..<4 {
            weights[index] = monotonic[index]
        }
        guard FSRS.areValid(weights: weights) else {
            return unchanged
        }
        let isPersonal = (0..<4).contains { weights[$0] != base[$0] }
        return FSRSParameterFit(weights: weights, isPersonal: isPersonal, answerCount: entries.count, samples: samples)
    }

    /// Per grade (again, hard, good, easy): whole days to the next answer → samples and recalls.
    private static func firstIntervals(_ entries: [ReviewLogEntry]) -> [[Int: Bucket]] {
        var result = [[Int: Bucket]](repeating: [:], count: 4)
        var firsts: [Int: ReviewLogEntry] = [:]
        for entry in entries {
            if entry.reviews == 1 {
                if entry.seed == nil && entry.knownCheck != true {
                    firsts[entry.wordID] = entry
                } else {
                    firsts[entry.wordID] = nil
                }
                continue
            }
            guard entry.reviews == 2, let first = firsts.removeValue(forKey: entry.wordID) else {
                continue
            }
            let days = (entry.at.timeIntervalSince(first.at) / day).rounded(.down)
            guard days.isFinite, days >= 1 else {
                continue
            }
            let t = Int(min(days, Double(longestGapDays)))
            let index = gradeIndex(first.grade)
            var bucket = result[index][t] ?? Bucket(count: 0, recalled: 0)
            bucket.count += 1
            if entry.grade != .again {
                bucket.recalled += 1
            }
            result[index][t] = bucket
        }
        return result
    }

    private static func gradeIndex(_ grade: ReviewGrade) -> Int {
        switch grade {
        case .again: return 0
        case .hard: return 1
        case .good: return 2
        case .easy: return 3
        }
    }

    /// ln S of the most likely stability within `searchRange`, recall corrected for `guessChance`.
    private static func bestLogStability(_ points: [(t: Double, count: Double, recalled: Double)], decay: Double) -> Double {
        let factor = pow(0.9, -1 / decay) - 1
        func likelihood(_ logStability: Double) -> Double {
            let stability = exp(logStability)
            var sum = 0.0
            for point in points {
                let r = pow(1 + factor * point.t / stability, -decay)
                let p = min(max(guessChance + (1 - guessChance) * r, 1e-4), 1 - 1e-4)
                sum += point.recalled * log(p) + (point.count - point.recalled) * log(1 - p)
            }
            return sum
        }

        let low = log(searchRange.lowerBound)
        let high = log(searchRange.upperBound)
        let width = (high - low) / Double(gridSteps)
        var best = 0
        var bestValue = -Double.infinity
        for step in 0...gridSteps {
            let value = likelihood(low + Double(step) * width)
            if value > bestValue {
                bestValue = value
                best = step
            }
        }

        var a = low + Double(max(best - 1, 0)) * width
        var b = low + Double(min(best + 1, gridSteps)) * width
        let ratio = (sqrt(5.0) - 1) / 2
        var c = b - ratio * (b - a)
        var d = a + ratio * (b - a)
        var fc = likelihood(c)
        var fd = likelihood(d)
        for _ in 0..<refineSteps {
            if fc >= fd {
                b = d
                d = c
                fd = fc
                c = b - ratio * (b - a)
                fc = likelihood(c)
            } else {
                a = c
                c = d
                fc = fd
                d = a + ratio * (b - a)
                fd = likelihood(d)
            }
        }
        let refined = (a + b) / 2
        let gridBest = low + Double(best) * width
        return likelihood(refined) >= bestValue ? min(max(refined, low), high) : gridBest
    }

    private static func clamp(_ value: Double, index: Int) -> Double {
        let bounds = FSRS.weightBounds[index]
        return min(max(value, bounds.lowerBound), bounds.upperBound)
    }

    /// Non-decreasing values: each run of adjacent violators becomes its weighted geometric mean.
    /// A value no run took in stays exactly as it was.
    private static func poolAdjacentViolators(_ values: [Double], masses: [Double]) -> [Double] {
        struct Block {
            var weightedLog: Double
            var mass: Double
            var members: [Int]

            var mean: Double {
                return weightedLog / mass
            }
        }
        var blocks: [Block] = []
        for index in values.indices {
            blocks.append(Block(weightedLog: masses[index] * log(values[index]), mass: masses[index], members: [index]))
            while blocks.count > 1 {
                let last = blocks[blocks.count - 1]
                let previous = blocks[blocks.count - 2]
                guard previous.mean > last.mean else {
                    break
                }
                blocks.removeLast(2)
                blocks.append(Block(
                    weightedLog: previous.weightedLog + last.weightedLog,
                    mass: previous.mass + last.mass,
                    members: previous.members + last.members
                ))
            }
        }
        var result = values
        for block in blocks where block.members.count > 1 {
            let pooled = exp(block.mean)
            for index in block.members {
                result[index] = clamp(pooled, index: index)
            }
        }
        return result
    }
}
