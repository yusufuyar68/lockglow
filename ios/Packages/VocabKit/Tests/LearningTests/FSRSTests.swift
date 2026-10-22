import XCTest
import Learning

/// FSRS-6 against the official implementations' own test values:
/// - py-fsrs 6.3.2, tests/test_basic.py:
///   https://github.com/open-spaced-repetition/py-fsrs/blob/v6.3.2/tests/test_basic.py
/// - fsrs-rs 6.6.2 (the version Anki ships), src/inference.rs tests:
///   https://github.com/open-spaced-repetition/fsrs-rs/blob/v6.6.2/src/inference.rs
/// The same numbers are checked in Python by `docs/ozellik_planlari/araclar/fsrs_sim.py --dogrula`,
/// which also printed the intermediate values in the comments below.
final class FSRSTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_669_725_000)  // 2022-11-29 12:30 UTC, as in py-fsrs
    private let minute: TimeInterval = 60
    private let day: TimeInterval = 86_400

    private func daysUntilDue(_ card: FSRSCard) -> Int {
        let seconds = card.dueAt!.timeIntervalSince(card.lastReviewAt!)
        return Int((seconds / day).rounded(.down))
    }

    // MARK: Memory model

    /// D0(rating) = w4 − e^(w5 · (rating − 1)) + 1, clamped to 1...10; S0(rating) = w[rating − 1]:
    /// Again 6.4133 − 1 + 1 = 6.4133; Hard 7.4133 − e^0.8334 = 5.112171; Good 7.4133 − e^1.6668
    /// = 2.118104; Easy 7.4133 − e^2.5002 = −4.771631, clamped to 1.
    func testFirstAnswerSetsStabilityAndDifficultyPerGrade() {
        let fsrs = FSRS()
        let expected: [(ReviewGrade, Double, Double)] = [
            (.again, 0.212, 6.4133),
            (.hard, 1.2931, 5.112171),
            (.good, 2.3065, 2.118104),
            (.easy, 8.2956, 1.0),
        ]
        for (grade, stability, difficulty) in expected {
            let memory = fsrs.initialMemory(grade)
            XCTAssertEqual(memory.stability, stability, accuracy: 1e-9, "\(grade)")
            XCTAssertEqual(memory.difficulty, difficulty, accuracy: 1e-6, "\(grade)")
        }
    }

    /// R(t, S) = (1 + factor · t / S)^−w20 with factor = 0.9^(−1 / w20) − 1, so R(S, S) = 0.9 for
    /// any decay: FSRS-6 (w20 = 0.1542, factor 0.980346) and FSRS-5 (decay 0.5, factor 19/81).
    func testRetrievabilityIsNinetyPercentAfterStabilityDays() {
        let fsrs6 = FSRS()
        let fsrs5 = FSRS(weights: Array(FSRS.defaultWeights.prefix(19)))
        for stability in [0.5, 3.0, 40.0] {
            XCTAssertEqual(fsrs6.retrievability(elapsedDays: stability, stability: stability), 0.9, accuracy: 1e-12)
            XCTAssertEqual(fsrs5.retrievability(elapsedDays: stability, stability: stability), 0.9, accuracy: 1e-12)
            XCTAssertEqual(fsrs6.retrievability(elapsedDays: 0, stability: stability), 1)
        }
        // A tenth of a day after a 1-day stability: (1 + 0.980346 · 0.1)^−0.1542 = 0.985682.
        XCTAssertEqual(fsrs6.retrievability(elapsedDays: 0.1, stability: 1), 0.985682, accuracy: 1e-6)
    }

    /// FSRS-5 weights get w19 = 0 and decay 0.5 (fsrs-rs `check_and_fill_parameters`).
    func testNineteenWeightsAreFilledUpAsFSRS5() {
        let fsrs = FSRS(weights: Array(FSRS.defaultWeights.prefix(19)))
        XCTAssertEqual(fsrs.weights.count, 21)
        XCTAssertEqual(Array(fsrs.weights.suffix(2)), [0, 0.5])
    }

    /// fsrs-rs `test_next_interval`: stability 1, desired retention 0.1 ... 1.0, interval rounded and
    /// at least 1. fsrs-rs computes in 32 bits; at 0.1 this 64-bit port gets 3,116,769 instead of
    /// 3,116,766 (one part in a million), hence the relative tolerance.
    func testIntervalForEachDesiredRetentionMatchesFsrsRs() {
        let fsrs = FSRS()
        let expected: [Double] = [3_116_766, 34_793, 2_508, 387, 90, 27, 9, 3, 1, 1]
        for (index, want) in expected.enumerated() {
            let retention = Double(index + 1) / 10
            let days = max(fsrs.intervalDays(stability: 1, retention: retention).rounded(), 1)
            XCTAssertEqual(days, want, accuracy: want * 1e-5, "retention \(retention)")
        }
        // At 0.9 the interval is the stability itself.
        XCTAssertEqual(fsrs.intervalDays(stability: 17.5), 17.5, accuracy: 1e-9)
    }

    /// fsrs-rs `test_memory_state` and py-fsrs `test_memo_state`: Again, then Good five times,
    /// 0, 0, 1, 3, 8 and 21 days apart, ends at S = 53.62691, D = 6.3574867 (both test to 1e-4).
    func testMemoryAfterAReviewHistoryMatchesBothImplementations() {
        let fsrs = FSRS()
        var memory: FSRSMemory?
        let history: [(ReviewGrade, Int)] = [(.again, 0), (.good, 0), (.good, 1), (.good, 3), (.good, 8), (.good, 21)]
        for (grade, days) in history {
            memory = memory.map { fsrs.nextMemory($0, elapsedDays: days, grade: grade) } ?? fsrs.initialMemory(grade)
        }
        XCTAssertEqual(memory!.stability, 53.62691, accuracy: 1e-4)
        XCTAssertEqual(memory!.difficulty, 6.3574867, accuracy: 1e-4)

        // The same history through the scheduler (py-fsrs reviews on the card).
        var card = FSRSCard()
        var now = start
        for (grade, days) in history {
            now = now.addingTimeInterval(Double(days) * day)
            card = fsrs.review(card, grade: grade, at: now)
        }
        XCTAssertEqual(card.memory!.stability, 53.62691, accuracy: 1e-4)
        XCTAssertEqual(card.memory!.difficulty, 6.3574867, accuracy: 1e-4)
    }

    /// fsrs-rs `test_next_states`: FSRS-5 weights fitted to a real collection, history Again (first),
    /// Good after 1, 3 and 8 days, then each grade after 21 days. fsrs-rs's 32-bit values agree
    /// with this port to about 1e-5.
    func testNextMemoryForEachGradeMatchesFsrsRsWithFSRS5Weights() {
        let fsrs = FSRS(weights: [
            0.6845422, 1.6790825, 4.7349424, 10.042885, 7.4410233, 0.64219797, 1.071918, 0.0025195254,
            1.432437, 0.1544, 0.8692766, 2.0696752, 0.0953, 0.2975, 2.4691248, 0.19542035, 3.201072,
            0.18046261, 0.121442534,
        ])
        var memory = fsrs.initialMemory(.again)
        for days in [1, 3, 8] {
            memory = fsrs.nextMemory(memory, elapsedDays: days, grade: .good)
        }
        let expected: [(ReviewGrade, Double, Double)] = [
            (.again, 2.9691455, 8.000659),
            (.hard, 17.091452, 7.6913934),
            (.good, 31.722992, 7.382128),
            (.easy, 71.7502, 7.0728626),
        ]
        for (grade, stability, difficulty) in expected {
            let next = fsrs.nextMemory(memory, elapsedDays: 21, grade: grade)
            XCTAssertEqual(next.stability, stability, accuracy: 1e-3, "\(grade)")
            XCTAssertEqual(next.difficulty, difficulty, accuracy: 1e-4, "\(grade)")
        }
        // At 0.9 the interval equals the stability (fsrs-rs: next_interval(121.01552) = 121.01551).
        XCTAssertEqual(fsrs.intervalDays(stability: 121.01552), 121.01551, accuracy: 1e-3)
    }

    // MARK: Scheduler

    /// py-fsrs `test_review_card`: steps 1 and 10 minutes, relearning 10 minutes, no fuzz; each answer
    /// on its due date. Good ×6, Again ×2, Good ×5 gives the days below. The port's trace:
    ///
    ///     grade  phase after   S          D          days
    ///     Good   learning 1    2.306500   2.118104   0   (step 2 in 10 minutes)
    ///     Good   review        2.306500   2.111214   2   (same day: S·e^(w17·w18)·S^−w19 < 1, kept)
    ///     Good   review        10.971048  2.104331   11
    ///     Good   review        46.316858  2.097455   46
    ///     Good   review        162.999816 2.090586   163
    ///     Good   review        497.876555 2.083724   498
    ///     Again  relearning 0  6.890413   7.383202   0   (lapse: w11·D^−w12·((S+1)^w13 − 1)·e^(w14·(1 − R)))
    ///     Again  relearning 0  2.154598   9.125105   0   (same day: S·e^(w17·(1 − 3 + w18))·S^−w19)
    ///     Good   review        2.154598   9.111208   2
    ///     Good   review        3.983123   9.097325   4
    ///     Good   review        7.236254   9.083456   7
    ///     Good   review        12.483044  9.069601   12
    ///     Good   review        20.770357  9.055760   21
    func testIntervalsMatchPyFSRSReviewCard() {
        let fsrs = FSRS()
        let grades: [ReviewGrade] = Array(repeating: .good, count: 6) + [.again, .again] + Array(repeating: .good, count: 5)
        var card = FSRSCard()
        var now = start
        var days: [Int] = []
        for grade in grades {
            card = fsrs.review(card, grade: grade, at: now)
            days.append(daysUntilDue(card))
            now = card.dueAt!
        }
        XCTAssertEqual(days, [0, 2, 11, 46, 163, 498, 0, 0, 2, 4, 7, 12, 21])
        XCTAssertEqual(card.phase, .review)
        XCTAssertEqual(card.memory!.stability, 20.770357, accuracy: 1e-5)
        XCTAssertEqual(card.memory!.difficulty, 9.055760, accuracy: 1e-5)
    }

    /// py-fsrs `test_good/again/hard/easy_learning_steps` with the default steps (1 and 10 minutes).
    func testLearningStepsMatchPyFSRS() {
        let fsrs = FSRS()
        let new = FSRSCard()

        let good = fsrs.review(new, grade: .good, at: start)
        XCTAssertEqual(good.phase, .learning)
        XCTAssertEqual(good.step, 1)
        XCTAssertEqual(good.dueAt, start.addingTimeInterval(10 * minute))
        let graduated = fsrs.review(good, grade: .good, at: good.dueAt!)
        XCTAssertEqual(graduated.phase, .review)
        XCTAssertNil(graduated.step)
        XCTAssertEqual(daysUntilDue(graduated), 2)

        let again = fsrs.review(new, grade: .again, at: start)
        XCTAssertEqual(again.phase, .learning)
        XCTAssertEqual(again.step, 0)
        XCTAssertEqual(again.dueAt, start.addingTimeInterval(minute))

        // Hard on the first of two steps waits halfway between them: (1 + 10) / 2 = 5.5 minutes.
        let hard = fsrs.review(new, grade: .hard, at: start)
        XCTAssertEqual(hard.phase, .learning)
        XCTAssertEqual(hard.step, 0)
        XCTAssertEqual(hard.dueAt, start.addingTimeInterval(330))

        // Easy skips the steps: S0(Easy) = 8.2956 days, rounded to 8.
        let easy = fsrs.review(new, grade: .easy, at: start)
        XCTAssertEqual(easy.phase, .review)
        XCTAssertNil(easy.step)
        XCTAssertEqual(easy.dueAt, start.addingTimeInterval(8 * day))
    }

    /// py-fsrs `test_review_state` and `test_relearning`: Again on a graduated word starts the
    /// 10-minute relearning step (again on Again); Good leaves it for at least a day.
    func testAgainOnAGraduatedWordRelearnsForTenMinutes() {
        let fsrs = FSRS()
        var card = FSRSCard()
        for _ in 0..<3 {
            card = fsrs.review(card, grade: .good, at: card.dueAt ?? start)
        }
        XCTAssertEqual(card.phase, .review)

        let due = card.dueAt!
        card = fsrs.review(card, grade: .again, at: due)
        XCTAssertEqual(card.phase, .relearning)
        XCTAssertEqual(card.step, 0)
        XCTAssertEqual(card.dueAt, due.addingTimeInterval(10 * minute))

        card = fsrs.review(card, grade: .again, at: card.dueAt!)
        XCTAssertEqual(card.phase, .relearning)
        XCTAssertEqual(card.step, 0)

        let relearnedAt = card.dueAt!
        card = fsrs.review(card, grade: .good, at: relearnedAt)
        XCTAssertEqual(card.phase, .review)
        XCTAssertNil(card.step)
        XCTAssertGreaterThanOrEqual(card.dueAt!.timeIntervalSince(relearnedAt), day)
    }

    /// py-fsrs `test_same_day_hard_review_does_not_decrease_stability`: no learning steps, Good, then
    /// Hard a minute later. The same-day factor e^(w17 · (2 − 3 + w18)) · S^−w19 = 0.578 is raised to 1.
    func testSameDayHardKeepsStability() {
        let fsrs = FSRS(learningSteps: [])
        let first = fsrs.review(FSRSCard(), grade: .good, at: start)
        XCTAssertEqual(first.phase, .review)
        let second = fsrs.review(first, grade: .hard, at: start.addingTimeInterval(minute))
        XCTAssertEqual(second.memory!.stability, first.memory!.stability)
    }

    /// py-fsrs `test_repeated_correct_reviews`: ten Easy answers a microsecond apart end at the
    /// lowest difficulty, exactly 1.
    func testRepeatedEasyReachesTheLowestDifficulty() {
        let fsrs = FSRS()
        var card = FSRSCard()
        for i in 0..<10 {
            card = fsrs.review(card, grade: .easy, at: start.addingTimeInterval(Double(i) * 1e-6))
        }
        XCTAssertEqual(card.memory!.difficulty, 1.0)
    }

    /// py-fsrs `test_stability_lower_bound`: a thousand lapses, each a day after the due date,
    /// never take the stability below 0.001.
    func testStabilityNeverFallsBelowTheMinimum() {
        let fsrs = FSRS()
        var card = FSRSCard()
        var now = start
        for _ in 0..<1000 {
            card = fsrs.review(card, grade: .again, at: now)
            XCTAssertGreaterThanOrEqual(card.memory!.stability, FSRS.minimumStability)
            now = card.dueAt!.addingTimeInterval(day)
        }
    }

    func testScheduledDaysStayBetweenOneDayAndTheMaximum() {
        let fsrs = FSRS(maximumIntervalDays: 365)
        XCTAssertEqual(fsrs.scheduledDays(stability: FSRS.minimumStability), 1)
        XCTAssertEqual(fsrs.scheduledDays(stability: 10.4), 10)
        XCTAssertEqual(fsrs.scheduledDays(stability: 1_000_000), 365)
    }

    func testRetrievabilityOfACard() {
        let fsrs = FSRS()
        XCTAssertEqual(fsrs.retrievability(of: FSRSCard(), at: start), 0, "never answered")
        let card = fsrs.review(FSRSCard(), grade: .easy, at: start)
        // Whole days only, like py-fsrs: 8 days and 20 hours count as 8 = round(S0(Easy)) days.
        let later = start.addingTimeInterval(8 * day + 20 * 3600)
        XCTAssertEqual(
            fsrs.retrievability(of: card, at: later),
            fsrs.retrievability(elapsedDays: 8, stability: 8.2956),
            accuracy: 1e-12
        )
    }

    // MARK: Lockglow's four answers

    /// A new word's first answer with the steps docs/ozellik_planlari/fsrs.md proposes (one 10-minute
    /// learning step, like `Leitner.relearnDelay`), next to today's Leitner: Bilemedim 10 minutes
    /// (Leitner 10 minutes), Zor 1.5 × 10 = 15 minutes (12 hours), Bildim round(2.3065) = 2 days
    /// (1 day), Kolay round(8.2956) = 8 days (2 days).
    func testFirstAnswerOfANewWordWithLockglowSteps() {
        let fsrs = FSRS(learningSteps: [10 * minute], relearningSteps: [10 * minute])
        let expected: [(ReviewGrade, FSRSCard.Phase, TimeInterval)] = [
            (.again, .learning, 10 * minute),
            (.hard, .learning, 15 * minute),
            (.good, .review, 2 * day),
            (.easy, .review, 8 * day),
        ]
        for (grade, phase, wait) in expected {
            let card = fsrs.review(FSRSCard(), grade: grade, at: start)
            XCTAssertEqual(card.phase, phase, "\(grade)")
            XCTAssertEqual(card.dueAt, start.addingTimeInterval(wait), "\(grade)")
            XCTAssertEqual(card.lastReviewAt, start)
        }
    }
}
