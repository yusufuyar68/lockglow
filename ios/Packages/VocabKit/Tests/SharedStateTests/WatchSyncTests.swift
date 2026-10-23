import XCTest
import CoreModels
import SharedState

/// The Apple Watch sync formats (`WatchSync`, `WatchKnownLedger`): what the phone sends, what the
/// watch accepts, and which watch events reach the phone's mailbox.
final class WatchSyncTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_699_999_200)

    private func word(_ id: Int, sensitivity: Int? = nil, confusables: [Int]? = nil) -> WidgetWord {
        return WidgetWord(
            id: id,
            lemma: "word\(id)",
            pos: "n",
            level: "A2",
            ipaUS: "/w/",
            defMicro: "micro",
            defShort: "short",
            exampleEN: "An example with word\(id).",
            glossTR: "anlam \(id)",
            glossShortTR: "kısa",
            sensitivity: sensitivity,
            confusableIDs: confusables
        )
    }

    private func plan(_ words: [WidgetWord], id: String = "p1", at date: Date? = nil) -> WidgetPlan {
        return WidgetPlan(
            planID: id,
            isPremium: false,
            intervalSeconds: 1800,
            queue: words,
            updatedAt: date ?? t0
        )
    }

    // MARK: watchPlan

    func testWatchPlanDropsPersonalWordsAndConfusablesAndKeepsTheRest() throws {
        let source = plan([word(1, confusables: [9]), word(2, sensitivity: 1), word(3, sensitivity: 0)])
        let result = try XCTUnwrap(WatchSync.watchPlan(from: source))
        XCTAssertEqual(result.queue.map { $0.id }, [1, 3])
        XCTAssertNil(result.queue[0].confusableIDs)
        XCTAssertEqual(result.queue[0].glossTR, "anlam 1")
        XCTAssertEqual(result.queue[0].exampleEN, "An example with word1.")
        XCTAssertEqual(result.planID, "p1")
        XCTAssertEqual(result.intervalSeconds, 1800)
        XCTAssertEqual(result.updatedAt, t0)
    }

    func testWatchPlanKeepsThePlanOrderUpToTheLimit() throws {
        let source = plan((1...100).map { word($0) })
        let result = try XCTUnwrap(WatchSync.watchPlan(from: source))
        XCTAssertEqual(result.queue.map { $0.id }, Array(1...WatchSync.maxWords))
        XCTAssertEqual(try XCTUnwrap(WatchSync.watchPlan(from: source, maxWords: 3)).queue.map { $0.id }, [1, 2, 3])
    }

    func testWatchPlanIsNilWithoutAWordToShow() {
        XCTAssertNil(WatchSync.watchPlan(from: plan([])))
        XCTAssertNil(WatchSync.watchPlan(from: plan([word(1, sensitivity: 1)])))
        XCTAssertNil(WatchSync.watchPlan(from: plan([word(1)]), maxWords: 0))
    }

    // MARK: encodePlan

    func testASmallPlanIsEncodedWhole() throws {
        let source = plan((1...10).map { word($0) })
        let data = try XCTUnwrap(WatchSync.encodePlan(source))
        let decoded = try XCTUnwrap(WatchSync.plan(from: [WatchSync.planKey: data]))
        XCTAssertEqual(decoded, source)
    }

    func testALongPlanIsHalvedUntilItFits() throws {
        let source = plan((1...40).map { word($0) })
        let whole = try XCTUnwrap(WatchSync.encodePlan(source, maxBytes: .max))
        // Room for a bit more than a quarter of the plan: 40 -> 20 -> 10 words.
        let limit = whole.count * 3 / 10
        let data = try XCTUnwrap(WatchSync.encodePlan(source, maxBytes: limit))
        XCTAssertLessThanOrEqual(data.count, limit)
        let decoded = try XCTUnwrap(WatchSync.plan(from: [WatchSync.planKey: data]))
        XCTAssertEqual(decoded.queue.map { $0.id }, Array(1...10))
        XCTAssertEqual(decoded.planID, source.planID)
    }

    func testAPlanIsNotEncodedWhenNotEvenOneWordFits() {
        XCTAssertNil(WatchSync.encodePlan(plan([word(1), word(2)]), maxBytes: 20))
    }

    func testTheRealPlanSizeFitsTheApplicationContext() throws {
        // 96 words is the app's queue limit (AppModel.queueLimit); long texts on every word.
        let long = String(repeating: "x", count: 120)
        let words = (1...96).map { id in
            WidgetWord(
                id: id, lemma: "lemma\(id)", pos: "phrase", level: "B1", ipaUS: "/\(long.prefix(20))/",
                defMicro: long, defShort: long, exampleEN: long, glossTR: long, glossShortTR: "kısa",
                sensitivity: 0, confusableIDs: [1, 2, 3, 4]
            )
        }
        let payload = try XCTUnwrap(WatchSync.planPayload(for: plan(words)))
        let data = try XCTUnwrap(payload[WatchSync.planKey] as? Data)
        XCTAssertLessThanOrEqual(data.count, WatchSync.maxPayloadBytes)
        XCTAssertGreaterThan(try XCTUnwrap(WatchSync.plan(from: payload)).queue.count, 10)
    }

    // MARK: plan(from:)

    func testPlanFromPayloadRejectsMissingGarbageAndEmptyPlans() throws {
        XCTAssertNil(WatchSync.plan(from: [:]))
        XCTAssertNil(WatchSync.plan(from: [WatchSync.planKey: "not data"]))
        XCTAssertNil(WatchSync.plan(from: [WatchSync.planKey: Data("{".utf8)]))
        let empty = try XCTUnwrap(WatchSync.encodePlan(plan([])))
        XCTAssertNil(WatchSync.plan(from: [WatchSync.planKey: empty]))
        XCTAssertNil(WatchSync.planPayload(for: plan([word(1, sensitivity: 2)])))
    }

    // MARK: isNewer

    func testOnlyANewerOtherPlanReplacesTheCurrentOne() {
        let current = plan([word(1)], id: "a", at: t0)
        XCTAssertTrue(WatchSync.isNewer(current, than: nil, now: t0))
        XCTAssertFalse(WatchSync.isNewer(current, than: current, now: t0))
        XCTAssertFalse(WatchSync.isNewer(plan([word(2)], id: "a", at: t0.addingTimeInterval(60)), than: current, now: t0))
        XCTAssertFalse(WatchSync.isNewer(plan([word(2)], id: "b", at: t0.addingTimeInterval(-1)), than: current, now: t0))
        XCTAssertTrue(WatchSync.isNewer(plan([word(2)], id: "b", at: t0), than: current, now: t0))
        XCTAssertTrue(WatchSync.isNewer(plan([word(2)], id: "b", at: t0.addingTimeInterval(60)), than: current, now: t0))
    }

    func testAPlanFromAWrongClockDoesNotBlockNewPlans() {
        let future = plan([word(1)], id: "a", at: t0.addingTimeInterval(30 * 24 * 3600))
        XCTAssertTrue(WatchSync.isNewer(plan([word(2)], id: "b", at: t0), than: future, now: t0))
        // An hour ahead is within a day: still the newer plan.
        let soon = plan([word(1)], id: "a", at: t0.addingTimeInterval(3600))
        XCTAssertFalse(WatchSync.isNewer(plan([word(2)], id: "b", at: t0), than: soon, now: t0))
    }

    func testANewApplicationContextWinsWhateverTheClocksSay() {
        // The phone clock ran 5 hours fast when it wrote plan a, then was corrected.
        let current = plan([word(1)], id: "a", at: t0.addingTimeInterval(5 * 3600))
        let next = plan([word(2)], id: "b", at: t0)
        XCTAssertTrue(WatchSync.shouldAccept(next, current: current, isApplicationContext: true, lastContextPlanID: "a", now: t0))
        // The same context handed over again at the next activation: nothing to do.
        XCTAssertFalse(WatchSync.shouldAccept(next, current: current, isApplicationContext: true, lastContextPlanID: "b", now: t0))
        XCTAssertFalse(WatchSync.shouldAccept(current, current: current, isApplicationContext: true, lastContextPlanID: "x", now: t0))
        // Complication user info keeps the date rule: an older plan does not replace a newer one.
        XCTAssertFalse(WatchSync.shouldAccept(next, current: current, isApplicationContext: false, lastContextPlanID: "a", now: t0))
        // Without a marker (first launch, file lost) the date rule decides for a context too.
        XCTAssertFalse(WatchSync.shouldAccept(next, current: current, isApplicationContext: true, lastContextPlanID: nil, now: t0))
        XCTAssertTrue(WatchSync.shouldAccept(next, current: nil, isApplicationContext: true, lastContextPlanID: nil, now: t0))
    }

    func testAnOldContextHandedOverAgainDoesNotUndoANewerComplicationPlan() {
        // Context a was handled; then complication user info brought plan b; at the next activation
        // the system hands context a over again (context b has not arrived yet).
        let a = plan([word(1)], id: "a", at: t0)
        let b = plan([word(2)], id: "b", at: t0.addingTimeInterval(600))
        XCTAssertTrue(WatchSync.shouldAccept(b, current: a, isApplicationContext: false, lastContextPlanID: "a", now: t0))
        XCTAssertFalse(WatchSync.shouldAccept(a, current: b, isApplicationContext: true, lastContextPlanID: "a", now: t0))
        // Context b arriving later is the plan on the watch already.
        XCTAssertFalse(WatchSync.shouldAccept(b, current: b, isApplicationContext: true, lastContextPlanID: "a", now: t0))
    }

    func testTheContextMarkerFileRoundTrips() throws {
        let directory = try makeTemporaryDirectory("WatchSyncTests")
        defer { try? FileManager.default.removeItem(at: directory) }
        XCTAssertNil(WatchContextMarker.read(from: directory))
        try WatchContextMarker(planID: "p9").write(to: directory)
        XCTAssertEqual(WatchContextMarker.read(from: directory), WatchContextMarker(planID: "p9"))
    }

    // MARK: shouldSendComplicationUpdate

    func testComplicationTransfersAreSpacedAndKeepTheLastOne() {
        XCTAssertTrue(WatchSync.shouldSendComplicationUpdate(lastSentAt: nil, now: t0, remainingTransfers: 50))
        XCTAssertFalse(WatchSync.shouldSendComplicationUpdate(lastSentAt: nil, now: t0, remainingTransfers: 1))
        XCTAssertFalse(WatchSync.shouldSendComplicationUpdate(lastSentAt: nil, now: t0, remainingTransfers: 0))
        XCTAssertFalse(WatchSync.shouldSendComplicationUpdate(lastSentAt: t0, now: t0.addingTimeInterval(3600), remainingTransfers: 50))
        XCTAssertTrue(WatchSync.shouldSendComplicationUpdate(
            lastSentAt: t0, now: t0.addingTimeInterval(WatchSync.complicationTransferSpacing), remainingTransfers: 50
        ))
        XCTAssertTrue(WatchSync.shouldSendComplicationUpdate(lastSentAt: t0, now: t0.addingTimeInterval(-60), remainingTransfers: 50))
    }

    // MARK: Events

    func testTheWatchSourceHasItsOwnName() {
        XCTAssertEqual(WidgetEventSource.watch.rawValue, "watch")
    }

    func testAWatchTapReachesThePhoneMailboxWithTheWatchSource() throws {
        for type in [WidgetEventType.known, .next] {
            let sent = WidgetEvent(type: type, wordID: 42, at: t0, source: .watch)
            let payload = try XCTUnwrap(WatchSync.eventPayload(sent))
            XCTAssertEqual(WatchSync.event(from: payload), sent)
            XCTAssertEqual(WatchSync.phoneMailboxEvent(from: payload), sent)
        }
        // Whatever source the watch wrote, the phone files it under the watch.
        let other = try XCTUnwrap(WatchSync.eventPayload(WidgetEvent(type: .known, wordID: 7, at: t0, source: .systemSmall)))
        XCTAssertEqual(WatchSync.phoneMailboxEvent(from: other)?.source, .watch)
    }

    func testTheWatchCannotGradeOrSendFakeWords() throws {
        for type in [WidgetEventType.unknown, .reveal] {
            let payload = try XCTUnwrap(WatchSync.eventPayload(WidgetEvent(type: type, wordID: 42, at: t0, source: .watch)))
            XCTAssertNil(WatchSync.phoneMailboxEvent(from: payload), "\(type)")
        }
        let sample = try XCTUnwrap(WatchSync.eventPayload(WidgetEvent(type: .known, wordID: 0, at: t0, source: .watch)))
        XCTAssertNil(WatchSync.phoneMailboxEvent(from: sample))
        XCTAssertNil(WatchSync.phoneMailboxEvent(from: [:]))
        XCTAssertNil(WatchSync.phoneMailboxEvent(from: [WatchSync.eventKey: Data("[]".utf8)]))
        XCTAssertNil(WatchSync.phoneMailboxEvent(from: [WatchSync.planKey: Data()]))
    }

    // MARK: WatchKnownLedger

    func testTheLedgerKeepsOneMarkPerWordForThreeDays() {
        var ledger = WatchKnownLedger()
        ledger.record(1, at: t0)
        ledger.record(2, at: t0.addingTimeInterval(3600))
        ledger.record(1, at: t0.addingTimeInterval(7200))
        XCTAssertEqual(ledger.marks.count, 2)
        XCTAssertEqual(ledger.activeIDs(now: t0.addingTimeInterval(7200)), [1, 2])

        let later = t0.addingTimeInterval(3600 + WatchKnownLedger.keepFor)
        // Word 2 was marked exactly `keepFor` earlier: gone. Word 1's newer mark stays.
        XCTAssertEqual(ledger.activeIDs(now: later), [1])
        XCTAssertEqual(ledger.pruned(now: later).marks, [WatchKnownLedger.Mark(wordID: 1, at: t0.addingTimeInterval(7200))])
        XCTAssertEqual(ledger.activeIDs(now: t0.addingTimeInterval(30 * 24 * 3600)), [])
        // A mark far in the future comes from a wrong clock.
        XCTAssertEqual(ledger.activeIDs(now: t0.addingTimeInterval(-30 * 24 * 3600)), [])
    }

    func testTheLedgerRemovesItsWordsFromANewPlanButNeverEmptiesIt() {
        var ledger = WatchKnownLedger()
        ledger.record(2, at: t0)
        let filtered = ledger.filter(plan([word(1), word(2), word(3)]), now: t0.addingTimeInterval(60))
        XCTAssertEqual(filtered.queue.map { $0.id }, [1, 3])
        XCTAssertEqual(filtered.planID, "p1")

        let only = plan([word(2)])
        XCTAssertEqual(ledger.filter(only, now: t0), only)
        let expired = t0.addingTimeInterval(WatchKnownLedger.keepFor + 1)
        XCTAssertEqual(ledger.filter(plan([word(1), word(2)]), now: expired).queue.map { $0.id }, [1, 2])
    }

    func testTheLedgerFileRoundTrips() throws {
        let directory = try makeTemporaryDirectory("WatchSyncTests")
        defer { try? FileManager.default.removeItem(at: directory) }
        XCTAssertEqual(WatchKnownLedger.read(from: directory), WatchKnownLedger())

        var ledger = WatchKnownLedger()
        ledger.record(5, at: t0)
        try ledger.write(to: directory)
        XCTAssertEqual(WatchKnownLedger.read(from: directory), ledger)

        try Data("not json".utf8).write(to: WatchKnownLedger.url(in: directory))
        XCTAssertEqual(WatchKnownLedger.read(from: directory), WatchKnownLedger())
    }
}
