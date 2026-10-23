import XCTest
import CoreModels
import Learning

/// FSRS's first stabilities (w0...w3) fitted to the review log (`FSRSParameterFit`,
/// docs/ozellik_planlari/fsrs.md 4.3 step 9), on synthetic logs.
final class FSRSParameterFitTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_700_000_000)
    private let day: TimeInterval = 86_400
    private let base = FSRS.defaultWeights

    /// Builds a log word by word: each word's answers in order, one word after another.
    private struct LogBuilder {
        var entries: [ReviewLogEntry] = []
        var nextID = 1
        let start: Date
        let day: TimeInterval = 86_400

        init(start: Date) {
            self.start = start
        }

        /// `count` words answered `first`, then again `days` later; `recalled` of them not "Bilemedim".
        mutating func words(_ first: ReviewGrade, days: Double, count: Int, recalled: Int) {
            for index in 0..<count {
                let id = nextID
                nextID += 1
                let firstAt = start.addingTimeInterval(Double(id) * 60)
                entries.append(ReviewLogEntry(wordID: id, at: firstAt, grade: first, source: .review, reviews: 1))
                let second: ReviewGrade = index < recalled ? .good : .again
                entries.append(ReviewLogEntry(
                    wordID: id, at: firstAt.addingTimeInterval(days * day), grade: second, source: .review, reviews: 2
                ))
            }
        }

        /// Words whose recall `days` after a first `first` follows p = g + (1 − g) · R(t, stability)
        /// at each t (g = `FSRSParameterFit.guessChance`: a forgotten word's 4-option cloze is
        /// still right one time in four): `perDay` words per t, the recalled count rounded from p.
        mutating func population(_ first: ReviewGrade, stability: Double, days: [Int], perDay: Int, scale: Int = 1) {
            let fsrs = FSRS()
            let guess = FSRSParameterFit.guessChance
            for t in days {
                let r = fsrs.retrievability(elapsedDays: Double(t), stability: stability)
                let recalled = Int((Double(perDay) * (guess + (1 - guess) * r)).rounded())
                words(first, days: Double(t), count: perDay * scale, recalled: recalled * scale)
            }
        }
    }

    private func builder() -> LogBuilder {
        return LogBuilder(start: start)
    }

    /// The stability a fit without guessing would find (p = R(t, S)): the best of a fine log grid
    /// over 0.1...100 days, then shrunk toward `baseStability` as `FSRSParameterFit` does.
    private func noGuessStability(_ entries: [ReviewLogEntry], baseStability: Double) -> Double {
        var points: [(t: Double, count: Double, recalled: Double)] = []
        var firsts: [Int: ReviewLogEntry] = [:]
        for entry in entries {
            if entry.reviews == 1 {
                firsts[entry.wordID] = entry
            } else if entry.reviews == 2, let first = firsts[entry.wordID] {
                let t = (entry.at.timeIntervalSince(first.at) / day).rounded(.down)
                points.append((t: t, count: 1, recalled: entry.grade == .again ? 0.0 : 1.0))
            }
        }
        let fsrs = FSRS()
        let low = log(0.1)
        let high = log(100.0)
        let steps = 2000
        var bestLog = low
        var bestValue = -Double.infinity
        for step in 0...steps {
            let logStability = low + (high - low) * Double(step) / Double(steps)
            var sum = 0.0
            for point in points {
                let r = fsrs.retrievability(elapsedDays: point.t, stability: exp(logStability))
                let p = min(max(r, 1e-4), 1 - 1e-4)
                sum += point.recalled * log(p) + (point.count - point.recalled) * log(1 - p)
            }
            if sum > bestValue {
                bestValue = sum
                bestLog = logStability
            }
        }
        let n = Double(points.count)
        let k = FSRSParameterFit.priorWeight
        return exp((n * bestLog + k * log(baseStability)) / (n + k))
    }

    /// Entries nobody can use: answers of words whose first answers are not in the log.
    private func padding(_ count: Int, firstID: Int) -> [ReviewLogEntry] {
        return (0..<count).map { index in
            ReviewLogEntry(
                wordID: firstID + index, at: start.addingTimeInterval(Double(index) * day), grade: .good,
                source: .review, reviews: 5
            )
        }
    }

    // MARK: Thresholds

    func testBelowMinimumAnswersReturnsBaseButCountsSamples() {
        var log = builder()
        log.population(.good, stability: 6, days: [2, 6, 18], perDay: 50)
        XCTAssertLessThan(log.entries.count, FSRSParameterFit.minimumAnswers)

        let fit = FSRSParameterFit.fit(log.entries)
        XCTAssertEqual(fit.weights, base)
        XCTAssertFalse(fit.isPersonal)
        XCTAssertEqual(fit.answerCount, log.entries.count)
        XCTAssertEqual(fit.samples, [0, 0, 150, 0])
    }

    func testEmptyLogReturnsBase() {
        let fit = FSRSParameterFit.fit([])
        XCTAssertEqual(fit.weights, base)
        XCTAssertFalse(fit.isPersonal)
        XCTAssertEqual(fit.answerCount, 0)
        XCTAssertEqual(fit.samples, [0, 0, 0, 0])
    }

    func testSamplesAreCountedPerGrade() {
        var log = builder()
        log.words(.again, days: 1, count: 3, recalled: 1)
        log.words(.hard, days: 2, count: 5, recalled: 4)
        log.words(.good, days: 3, count: 7, recalled: 7)
        log.words(.easy, days: 8, count: 2, recalled: 2)

        XCTAssertEqual(FSRSParameterFit.fit(log.entries).samples, [3, 5, 7, 2])
    }

    func testUnusableFirstAnswersAreIgnored() {
        var log = builder()
        log.population(.good, stability: 6, days: [2, 6, 18, 45], perDay: 100)
        let usable = log.entries
        var id = 100_000
        var ignored: [ReviewLogEntry] = []
        let seed = ReviewLogEntry.Seed(state: .learning, box: 2, lapses: 0, dueAt: start, knownOverride: false)
        for index in 0..<40 {
            let at = start.addingTimeInterval(Double(index) * 60)
            let later = at.addingTimeInterval(5 * day)
            // A seeded first answer: the word had answers before the log began.
            ignored.append(ReviewLogEntry(wordID: id, at: at, grade: .easy, source: .review, reviews: 1, seed: seed))
            ignored.append(ReviewLogEntry(wordID: id, at: later, grade: .again, source: .review, reviews: 2))
            id += 1
            // The "Biliyorum" check as the first answer.
            ignored.append(ReviewLogEntry(wordID: id, at: at, grade: .easy, source: .review, reviews: 1, knownCheck: true))
            ignored.append(ReviewLogEntry(wordID: id, at: later, grade: .again, source: .review, reviews: 2))
            id += 1
            // The second answer the same day (23 hours later), then a third 5 days later.
            ignored.append(ReviewLogEntry(wordID: id, at: at, grade: .hard, source: .review, reviews: 1))
            ignored.append(ReviewLogEntry(wordID: id, at: at.addingTimeInterval(23 * 3600), grade: .again, source: .review, reviews: 2))
            ignored.append(ReviewLogEntry(wordID: id, at: later, grade: .again, source: .review, reviews: 3))
            id += 1
            // An incomplete word: its first answer went before the log.
            ignored.append(ReviewLogEntry(wordID: id, at: at, grade: .again, source: .review, reviews: 2))
            ignored.append(ReviewLogEntry(wordID: id, at: later, grade: .again, source: .review, reviews: 3))
            id += 1
        }

        let clean = FSRSParameterFit.fit(usable)
        let mixed = FSRSParameterFit.fit(usable + ignored)
        XCTAssertEqual(mixed.samples, [0, 0, 400, 0])
        XCTAssertEqual(mixed.samples, clean.samples)
        XCTAssertEqual(mixed.weights, clean.weights)
        XCTAssertEqual(mixed.answerCount, usable.count + ignored.count)
    }

    // MARK: Fitting

    /// Recall follows g + (1 − g) · R(t, 6) after a first "Bildim": w2 moves from 2.3065 toward 6
    /// (about 5.60), closer with four times the samples (about 5.84; same proportions, so the same
    /// unshrunk fit, about 5.93).
    func testGradeWithManySamplesMovesTowardItsTrueStability() {
        let trueStability = 6.0
        let days = [2, 5, 15, 40, 100]
        var small = builder()
        small.population(.good, stability: trueStability, days: days, perDay: 100)
        var large = builder()
        large.population(.good, stability: trueStability, days: days, perDay: 100, scale: 4)

        let smallFit = FSRSParameterFit.fit(small.entries)
        let largeFit = FSRSParameterFit.fit(large.entries)
        XCTAssertEqual(smallFit.samples[2], 500)
        XCTAssertEqual(largeFit.samples[2], 2000)
        XCTAssertTrue(smallFit.isPersonal)

        let smallW2 = smallFit.weights[2]
        let largeW2 = largeFit.weights[2]
        XCTAssertGreaterThan(smallW2, base[2])
        XCTAssertLessThan(smallW2, trueStability)
        XCTAssertGreaterThan(largeW2, smallW2)
        XCTAssertLessThan(abs(log(largeW2) - log(trueStability)), abs(log(smallW2) - log(trueStability)))
        XCTAssertEqual(largeW2, trueStability, accuracy: 0.5)

        // The grades without samples keep their weights exactly.
        XCTAssertEqual(smallFit.weights[0], base[0])
        XCTAssertEqual(smallFit.weights[1], base[1])
        XCTAssertEqual(smallFit.weights[3], base[3])
    }

    /// The same population with guessing: the fit lands near 6 (about 5.84), a fit that read every
    /// lucky cloze pick as memory would land near 10.5 (unshrunk about 10.8).
    func testGuessingCorrectionRecoversTrueStability() {
        let trueStability = 6.0
        var log = builder()
        log.population(.good, stability: trueStability, days: [2, 5, 15, 40, 100], perDay: 100, scale: 4)

        let fitted = FSRSParameterFit.fit(log.entries).weights[2]
        let noGuess = noGuessStability(log.entries, baseStability: base[2])
        XCTAssertEqual(fitted, trueStability, accuracy: 0.5)
        XCTAssertGreaterThan(noGuess, 1.5 * trueStability)
        XCTAssertLessThan(abs(Foundation.log(fitted / trueStability)), abs(Foundation.log(noGuess / trueStability)))
    }

    /// Nothing remembered at all, below even the guessing rate: every first stability falls, the
    /// result stays valid and monotonic.
    func testAllForgottenStillGivesValidWeights() {
        var log = builder()
        for grade in [ReviewGrade.again, .hard, .good, .easy] {
            for t in [1, 5, 20, 60] {
                log.words(grade, days: Double(t), count: 100, recalled: 0)
            }
        }

        let fit = FSRSParameterFit.fit(log.entries)
        let w = fit.weights
        XCTAssertEqual(fit.samples, [400, 400, 400, 400])
        XCTAssertTrue(fit.isPersonal)
        XCTAssertTrue(FSRS.areValid(weights: w), "\(w)")
        for index in 0..<4 {
            XCTAssertTrue(w[index].isFinite)
            XCTAssertLessThan(w[index], base[index])
            XCTAssertGreaterThanOrEqual(w[index], FSRS.weightBounds[index].lowerBound)
        }
        XCTAssertLessThanOrEqual(w[0], w[1])
        XCTAssertLessThanOrEqual(w[1], w[2])
        XCTAssertLessThanOrEqual(w[2], w[3])
        XCTAssertEqual(Array(w[4...]), Array(base[4...]))
    }

    func testGradeBelowMinimumSamplesKeepsBase() {
        var log = builder()
        log.population(.good, stability: 6, days: [2, 6, 18, 45], perDay: 100)
        let few = FSRSParameterFit.minimumSamples - 1
        log.words(.hard, days: 30, count: few, recalled: 0)

        let fit = FSRSParameterFit.fit(log.entries)
        XCTAssertEqual(fit.samples[1], few)
        XCTAssertEqual(fit.weights[1], base[1])
        XCTAssertNotEqual(fit.weights[2], base[2])
    }

    func testLaterWeightsStayAsInBase() {
        var log = builder()
        log.population(.again, stability: 0.5, days: [1, 2, 4], perDay: 100)
        log.population(.easy, stability: 40, days: [5, 20, 40, 90], perDay: 100)

        let fit = FSRSParameterFit.fit(log.entries)
        XCTAssertEqual(fit.weights.count, base.count)
        XCTAssertEqual(Array(fit.weights[4...]), Array(base[4...]))
        XCTAssertNotEqual(fit.weights[0], base[0])
        XCTAssertNotEqual(fit.weights[3], base[3])
    }

    func testResultIsAlwaysValid() {
        var cases: [[ReviewLogEntry]] = [[]]
        var forgotten = builder()
        for grade in [ReviewGrade.again, .hard, .good, .easy] {
            forgotten.words(grade, days: 200, count: 200, recalled: 0)
        }
        cases.append(forgotten.entries)
        var remembered = builder()
        for grade in [ReviewGrade.again, .hard, .good, .easy] {
            remembered.words(grade, days: 1, count: 200, recalled: 200)
        }
        cases.append(remembered.entries)
        var mixed = builder()
        mixed.population(.hard, stability: 6, days: [2, 6, 18], perDay: 100)
        mixed.population(.good, stability: 1, days: [1, 2, 5], perDay: 100)
        cases.append(mixed.entries)

        for entries in cases {
            let fit = FSRSParameterFit.fit(entries)
            XCTAssertTrue(FSRS.areValid(weights: fit.weights), "\(fit.weights)")
        }
    }

    /// "Zor" words remembered far longer than "Bildim" words: the two are pooled, never inverted.
    func testFirstStabilitiesStayMonotonic() {
        var log = builder()
        log.population(.hard, stability: 6, days: [2, 6, 18, 45], perDay: 100)
        log.population(.good, stability: 1.5, days: [1, 2, 5, 10], perDay: 100)

        let fit = FSRSParameterFit.fit(log.entries)
        let w = fit.weights
        XCTAssertLessThanOrEqual(w[0], w[1])
        XCTAssertLessThanOrEqual(w[1], w[2])
        XCTAssertLessThanOrEqual(w[2], w[3])
        XCTAssertEqual(w[1], w[2])
        XCTAssertGreaterThan(w[1], 1.5)
        XCTAssertLessThan(w[1], 6)
        XCTAssertTrue(FSRS.areValid(weights: w))
    }

    func testAllRecalledStaysWithinUpperBound() {
        var log = builder()
        log.words(.easy, days: 3, count: 5000, recalled: 5000)

        let fit = FSRSParameterFit.fit(log.entries)
        XCTAssertGreaterThan(fit.weights[3], base[3])
        XCTAssertLessThanOrEqual(fit.weights[3], FSRS.weightBounds[3].upperBound)
        XCTAssertTrue(FSRS.areValid(weights: fit.weights))
    }

    func testFitIsDeterministic() {
        var log = builder()
        log.population(.again, stability: 0.4, days: [1, 2, 3], perDay: 60)
        log.population(.hard, stability: 2, days: [1, 3, 7], perDay: 60)
        log.population(.good, stability: 5, days: [2, 6, 18], perDay: 60)
        log.population(.easy, stability: 20, days: [5, 20, 60], perDay: 60)

        let first = FSRSParameterFit.fit(log.entries)
        XCTAssertEqual(FSRSParameterFit.fit(log.entries), first)

        // The same words in the other order: the same counts, the same weights.
        var reordered: [ReviewLogEntry] = []
        var index = log.entries.count
        while index >= 2 {
            reordered.append(log.entries[index - 2])
            reordered.append(log.entries[index - 1])
            index -= 2
        }
        XCTAssertEqual(FSRSParameterFit.fit(reordered), first)
        XCTAssertTrue(first.isPersonal)
    }

    func testFittedWeightsDriveTheScheduler() {
        var log = builder()
        log.population(.good, stability: 6, days: [2, 6, 18, 45], perDay: 100)
        let fit = FSRSParameterFit.fit(log.entries + padding(50, firstID: 900_000))

        let scheduler = FSRSScheduler(weights: fit.weights)
        XCTAssertEqual(scheduler.fsrs.weights, fit.weights)
        XCTAssertEqual(scheduler.fsrs.initialMemory(.good).stability, fit.weights[2], accuracy: 1e-12)
        XCTAssertNotEqual(scheduler.fsrs.weights, FSRSScheduler().fsrs.weights)
    }
}
