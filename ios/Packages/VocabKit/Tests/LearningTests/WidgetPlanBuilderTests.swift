import XCTest
import CoreModels
import SharedState
import Scheduler
import Learning

/// `WidgetPlanBuilder` is the plan rewrite that `AppModel.refreshWidgetPlan` ran on the main thread
/// until it moved to a background queue (is5-performans). It must write the same plan: these
/// tests compare it with that code, copied line for line (`mainThreadPlan`).
final class WidgetPlanBuilderTests: XCTestCase {
    /// 2023-11-14 22:13:20 UTC, a whole second.
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let day: TimeInterval = 86_400

    private func card(_ id: Int, level: String = "A2", example: String? = nil, sensitivity: Int? = nil) -> WidgetWord {
        return WidgetWord(
            id: id,
            lemma: "word\(id)",
            pos: "noun",
            level: level,
            defMicro: "micro \(id)",
            defShort: "short definition \(id)",
            exampleEN: example ?? "A long first example sentence with word\(id) in the middle of it.",
            glossTR: "anlam \(id)",
            sensitivity: sensitivity,
            confusableIDs: id % 7 == 0 ? [id + 1] : nil
        )
    }

    private func custom(_ id: Int, lemma: String, example: String?) -> WidgetWord {
        return WidgetWord(id: CustomWordID.first + id, lemma: lemma, pos: "", level: "", defMicro: "", defShort: "", exampleEN: example ?? "", glossTR: "kendi \(id)")
    }

    /// Card details as content.sqlite has them: the card's own example and a shorter one with the word.
    private func detail(of word: WidgetWord, customWords: [WidgetWord]) -> CardDetail? {
        if word.isUserAdded {
            // `CustomWord.cardDetail`: the word's own example, if any.
            guard let current = customWords.first(where: { $0.id == word.id }) else {
                return nil
            }
            return CardDetail(examples: current.exampleEN.isEmpty ? [] : [CardDetail.Example(en: current.exampleEN)])
        }
        switch word.id % 4 {
        case 0:
            return nil
        case 1:
            return CardDetail(
                examples: [CardDetail.Example(en: word.exampleEN), CardDetail.Example(en: "Short \(word.lemma)."), CardDetail.Example(en: "Another \(word.lemma) here.")],
                mistakes: [CardDetail.Mistake(wrong: "I did \(word.lemma).", right: "I had \(word.lemma).", why: "had")]
            )
        case 2:
            return CardDetail(examples: [CardDetail.Example(en: word.exampleEN)])
        default:
            return CardDetail(examples: [CardDetail.Example(en: "No match here.")])
        }
    }

    /// What `WidgetPlanWriter` passes: `detail(for:)` of the queued word.
    private func planDetail(customWords: [WidgetWord]) -> (WidgetWord) -> CardDetail? {
        return { word in
            self.detail(of: word, customWords: customWords)
        }
    }

    private func makeInput(
        deck: [WidgetWord],
        fallback: [WidgetWord],
        progress: [Int: WordProgress],
        rotationMinutes: Int = 60,
        daily: Int = 5,
        customWords: [WidgetWord] = []
    ) -> WidgetPlanBuilder.Input {
        return WidgetPlanBuilder.Input(
            deck: deck,
            fallbackFeed: fallback,
            progress: progress,
            rotationMinutes: rotationMinutes,
            dailyNewWords: daily,
            limit: 96,
            horizon: 48 * 3600,
            customWords: Dictionary(customWords.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        )
    }

    /// `AppModel.refreshWidgetPlan` before is5-performans (main cb3cf7a, from `let rotation =` to
    /// the plan; `writeProgressSnapshot` and the hooks after the write stay in AppModel),
    /// with the model's state as parameters: `detail(for:)` and `pinnedWord(_:)` as closures.
    private func mainThreadPlan(
        _ input: WidgetPlanBuilder.Input,
        rewriteTime: Date,
        plan oldPlan: WidgetPlan?,
        state: WidgetState?,
        planID: String,
        customWords: [WidgetWord]
    ) -> WidgetPlan? {
        func detail(for word: WidgetWord) -> CardDetail? {
            return self.detail(of: word, customWords: customWords)
        }
        func pinnedWord(_ current: WidgetWord?) -> WidgetWord? {
            guard let current = current, current.isUserAdded else {
                return current
            }
            return customWords.first { $0.id == current.id }
        }
        let rotation = RotationInput.resolve(plan: oldPlan, state: state, seedWords: [])
        let currentWord = TimelinePlanner.wordAt(
            rewriteTime,
            queue: rotation.queue,
            knownIDs: rotation.knownIDs,
            cursorOffset: rotation.cursorOffset,
            cursorAnchor: rotation.cursorAnchor,
            interval: rotation.interval,
            alignmentOffset: TimelinePlanner.localAlignmentOffset(for: rewriteTime)
        )
        let queue = QueueComposer.compose(
            deck: input.deck,
            fallbackFeed: input.fallbackFeed,
            progress: input.progress,
            now: rewriteTime,
            horizon: input.horizon,
            maxNew: input.dailyNewWords * 2,
            limit: input.limit,
            pinFirst: pinnedWord(currentWord),
            patternOffset: TimelinePlanner.elapsedBoundaries(
                from: Date(timeIntervalSince1970: 0),
                to: rewriteTime,
                interval: TimeInterval(input.rotationMinutes * 60),
                alignmentOffset: TimelinePlanner.localAlignmentOffset(for: rewriteTime)
            ) + 1
        )
        if queue.isEmpty {
            return nil
        }
        let planQueue = queue.map { word -> WidgetWord in
            guard let shortest = detail(for: word)?.shortestExample(containing: word.lemma),
                  shortest != word.exampleEN else {
                return word
            }
            return WidgetWord(
                id: word.id,
                lemma: word.lemma,
                pos: word.pos,
                level: word.level,
                ipaUS: word.ipaUS,
                ipaUK: word.ipaUK, // is5-ses: the widget's IPA follows "Ses ve aksan"
                defMicro: word.defMicro,
                defShort: word.defShort,
                exampleEN: shortest,
                glossTR: word.glossTR,
                glossShortTR: word.glossShortTR,
                sensitivity: word.sensitivity,
                confusableIDs: word.confusableIDs
            )
        }
        // is5-w-buyuk: the large widget's second example and warning (CoreModels/WidgetWarning.swift).
        .map { $0.addingLargeWidgetDetails(from: detail(for: $0)) }
        return WidgetPlan(
            planID: planID,
            isPremium: false,
            intervalSeconds: input.rotationMinutes * 60,
            queue: planQueue,
            updatedAt: rewriteTime
        )
    }

    private func assertSamePlan(
        _ input: WidgetPlanBuilder.Input,
        at time: Date,
        plan: WidgetPlan?,
        state: WidgetState?,
        customWords: [WidgetWord] = [],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expected = mainThreadPlan(input, rewriteTime: time, plan: plan, state: state, planID: "new", customWords: customWords)
        let built = WidgetPlanBuilder.makePlan(
            input,
            at: time,
            previousPlan: plan,
            state: state,
            planID: "new",
            planDetail: planDetail(customWords: customWords)
        )
        XCTAssertEqual(built, expected, file: file, line: line)
    }

    private func learning(_ id: Int, box: Int, due: Date, answeredAt: Date? = nil, grade: ReviewGrade? = nil) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = box
        p.reviews = 1
        p.dueAt = due
        p.lastSeenAt = answeredAt ?? due.addingTimeInterval(-day)
        p.lastReviewedAt = answeredAt
        p.lastGrade = grade
        return p
    }

    // MARK: Cases

    func testFirstPlanWithoutAnOldOneStartsAtTheDeck() throws {
        let deck = (1...40).map { card($0) }
        let input = makeInput(deck: deck, fallback: deck, progress: [:])
        assertSamePlan(input, at: now, plan: nil, state: nil)
        let plan = try XCTUnwrap(WidgetPlanBuilder.makePlan(input, at: now, previousPlan: nil, state: nil, planDetail: { _ in nil }))
        XCTAssertEqual(plan.queue.first?.id, 1)
        XCTAssertEqual(plan.updatedAt, now)
        XCTAssertEqual(plan.intervalSeconds, 3600)
        XCTAssertFalse(plan.isPremium)
        XCTAssertLessThanOrEqual(plan.queue.count, 96)
    }

    func testTheVisibleWordStaysFirstEvenWithAnotherInterval() throws {
        let deck = (1...40).map { card($0) }
        let oldPlan = WidgetPlan(planID: "old", isPremium: false, intervalSeconds: 3600, queue: Array(deck[10..<20]), updatedAt: now.addingTimeInterval(-3 * 3600))
        let state = WidgetState(planID: "old", cursorOffset: 4, cursorAnchor: now.addingTimeInterval(-3600), knownIDs: [15], updatedAt: now)
        let visible = try XCTUnwrap(WidgetPlanBuilder.visibleWord(at: now, plan: oldPlan, state: state))
        for minutes in [30, 60, 120, 240] {
            let input = makeInput(deck: deck, fallback: deck, progress: [:], rotationMinutes: minutes)
            assertSamePlan(input, at: now, plan: oldPlan, state: state)
            let plan = try XCTUnwrap(WidgetPlanBuilder.makePlan(input, at: now, previousPlan: oldPlan, state: state, planDetail: { _ in nil }))
            XCTAssertEqual(plan.queue.first?.id, visible.id, "\(minutes) min")
            XCTAssertEqual(plan.intervalSeconds, minutes * 60)
        }
    }

    func testAStateOfAnotherPlanIsIgnored() {
        let deck = (1...30).map { card($0) }
        let oldPlan = WidgetPlan(planID: "old", isPremium: false, intervalSeconds: 1800, queue: Array(deck[5..<15]), updatedAt: now.addingTimeInterval(-7200))
        let foreign = WidgetState(planID: "other", cursorOffset: 7, cursorAnchor: now, knownIDs: [6, 7], updatedAt: now)
        assertSamePlan(makeInput(deck: deck, fallback: deck, progress: [:]), at: now, plan: oldPlan, state: foreign)
    }

    func testAKnownVisibleWordIsNotPinned() throws {
        let deck = (1...30).map { card($0) }
        let oldPlan = WidgetPlan(planID: "old", isPremium: false, intervalSeconds: 3600, queue: [deck[2]], updatedAt: now.addingTimeInterval(-60))
        let progress = [3: Leitner.markKnown(WordProgress(wordID: 3), at: now.addingTimeInterval(-30))]
        let input = makeInput(deck: deck, fallback: deck, progress: progress)
        assertSamePlan(input, at: now, plan: oldPlan, state: nil)
        let plan = try XCTUnwrap(WidgetPlanBuilder.makePlan(input, at: now, previousPlan: oldPlan, state: nil, planDetail: { _ in nil }))
        XCTAssertFalse(plan.queue.contains { $0.id == 3 })
    }

    func testAnEditedUserWordIsPinnedWithItsNewTextAndADeletedOneNotAtAll() throws {
        let deck = (1...20).map { card($0) }
        let before = custom(1, lemma: "awkward", example: "An awkward moment.")
        let oldPlan = WidgetPlan(planID: "old", isPremium: false, intervalSeconds: 3600, queue: [before], updatedAt: now.addingTimeInterval(-60))

        let edited = custom(1, lemma: "awkward", example: "It was an awkward silence.")
        let withEdit = makeInput(deck: [edited] + deck, fallback: [edited] + deck, progress: [:], customWords: [edited])
        assertSamePlan(withEdit, at: now, plan: oldPlan, state: nil, customWords: [edited])
        let plan = try XCTUnwrap(WidgetPlanBuilder.makePlan(withEdit, at: now, previousPlan: oldPlan, state: nil, planDetail: planDetail(customWords: [edited])))
        XCTAssertEqual(plan.queue.first, edited)

        let deleted = makeInput(deck: deck, fallback: deck, progress: [:], customWords: [])
        assertSamePlan(deleted, at: now, plan: oldPlan, state: nil)
        let afterDelete = try XCTUnwrap(WidgetPlanBuilder.makePlan(deleted, at: now, previousPlan: oldPlan, state: nil, planDetail: { _ in nil }))
        XCTAssertFalse(afterDelete.queue.contains { $0.isUserAdded })
        XCTAssertEqual(afterDelete.queue.first?.id, 1)
    }

    func testTheShortestExampleWithTheWordReplacesTheTextOnly() throws {
        let deck = (1...12).map { card($0) }
        let input = makeInput(deck: deck, fallback: deck, progress: [:])
        assertSamePlan(input, at: now, plan: nil, state: nil)
        let plan = try XCTUnwrap(WidgetPlanBuilder.makePlan(input, at: now, previousPlan: nil, state: nil, planDetail: planDetail(customWords: [])))
        for word in plan.queue {
            let original = try XCTUnwrap(deck.first { $0.id == word.id })
            if word.id % 4 == 1 {
                XCTAssertEqual(word.exampleEN, "Short \(word.lemma).")
            } else {
                XCTAssertEqual(word.exampleEN, original.exampleEN)
            }
            XCTAssertEqual(word.lemma, original.lemma)
            XCTAssertEqual(word.glossTR, original.glossTR)
            XCTAssertEqual(word.confusableIDs, original.confusableIDs)
        }
    }

    /// The large widget's second example and warning come from the same details.
    func testLargeWidgetDetailsAreWritten() throws {
        let deck = (1...8).map { card($0) }
        let input = makeInput(deck: deck, fallback: deck, progress: [:])
        assertSamePlan(input, at: now, plan: nil, state: nil)
        let plan = try XCTUnwrap(WidgetPlanBuilder.makePlan(input, at: now, previousPlan: nil, state: nil, planDetail: planDetail(customWords: [])))
        let withDetails = plan.queue.filter { $0.id % 4 == 1 }
        XCTAssertFalse(withDetails.isEmpty)
        for word in withDetails {
            XCTAssertNotNil(word.secondExampleEN, word.lemma)
            XCTAssertNotEqual(word.secondExampleEN, word.exampleEN)
        }
        XCTAssertTrue(plan.queue.filter { $0.id % 4 == 0 }.allSatisfy { $0.secondExampleEN == nil && $0.warning == nil })
    }

    func testNoWordsNoPlan() {
        let input = makeInput(deck: [], fallback: [], progress: [:])
        XCTAssertNil(WidgetPlanBuilder.makePlan(input, at: now, previousPlan: nil, state: nil, planDetail: { _ in nil }))
        assertSamePlan(input, at: now, plan: nil, state: nil)
        // Only personal-topic cards: never on the widget.
        let personal = (1...5).map { card($0, sensitivity: 1) }
        XCTAssertNil(WidgetPlanBuilder.makePlan(self.makeInput(deck: personal, fallback: personal, progress: [:]), at: now, previousPlan: nil, state: nil, planDetail: { _ in nil }))
    }

    /// Many random decks, progress, old plans and widget states: always the plan the main thread wrote.
    func testRandomRewritesGiveTheMainThreadPlan() {
        var generator = SplitMix(seed: 20_261_023)
        let all = (1...300).map { card($0, level: ["A1", "A2", "B1", "B2"][$0 % 4], sensitivity: $0 % 37 == 0 ? 1 : nil) }
        let customs = (1...4).map { custom($0, lemma: "own\($0)", example: $0 % 2 == 0 ? "I use own\($0) daily." : nil) }
        for round in 0..<150 {
            let deckSize = Int(generator.next(upTo: 300)) + 1
            let deck = Array(all.shuffled(using: &generator).prefix(deckSize))
            var progress: [Int: WordProgress] = [:]
            for word in all where generator.next(upTo: 3) == 0 {
                let id = word.id
                switch generator.next(upTo: 5) {
                case 0:
                    progress[id] = Leitner.markKnown(WordProgress(wordID: id), at: now.addingTimeInterval(-Double(generator.next(upTo: 10)) * day))
                case 1:
                    progress[id] = learning(id, box: 1, due: now.addingTimeInterval(600), answeredAt: now.addingTimeInterval(-300), grade: .again)
                case 2:
                    progress[id] = learning(id, box: 2, due: now.addingTimeInterval(2 * day), answeredAt: now.addingTimeInterval(-3600), grade: .good)
                default:
                    let offset = Double(generator.next(upTo: 20)) - 5
                    progress[id] = learning(id, box: Int(generator.next(upTo: 5)) + 1, due: now.addingTimeInterval(offset * day))
                }
            }
            let liveCustoms = customs.filter { _ in generator.next(upTo: 2) == 0 }
            let oldQueue = Array((all + customs).shuffled(using: &generator).prefix(Int(generator.next(upTo: 40))))
            let oldPlan: WidgetPlan? = oldQueue.isEmpty ? nil : WidgetPlan(
                planID: "old\(round)",
                isPremium: false,
                intervalSeconds: [1800, 3600, 7200, 14_400][Int(generator.next(upTo: 4))],
                queue: oldQueue,
                updatedAt: now.addingTimeInterval(-Double(generator.next(upTo: 200_000)))
            )
            let state: WidgetState? = generator.next(upTo: 2) == 0 ? nil : WidgetState(
                planID: generator.next(upTo: 4) == 0 ? "other" : "old\(round)",
                cursorOffset: Int(generator.next(upTo: 60)),
                cursorAnchor: now.addingTimeInterval(-Double(generator.next(upTo: 100_000))),
                knownIDs: oldQueue.filter { _ in generator.next(upTo: 6) == 0 }.map { $0.id },
                updatedAt: now
            )
            let time = now.addingTimeInterval(Double(generator.next(upTo: 86_400)))
            let input = makeInput(
                deck: liveCustoms + deck,
                fallback: liveCustoms + all,
                progress: progress,
                rotationMinutes: [30, 60, 120, 240][Int(generator.next(upTo: 4))],
                daily: [5, 10, 15, 20][Int(generator.next(upTo: 4))],
                customWords: liveCustoms
            )
            assertSamePlan(input, at: time, plan: oldPlan, state: state, customWords: liveCustoms)
        }
    }
}

/// A small seeded generator: the random cases are the same on every run.
private struct SplitMix: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    mutating func next(upTo bound: UInt64) -> UInt64 {
        return next() % bound
    }
}
