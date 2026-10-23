import XCTest
import CoreModels
import SharedState
import Scheduler

/// The widget extension's own timeline code (`WordDataSource.load` + `WordProvider.makeEntries`,
/// compiled into this bundle from Widgets/) on plan files like the ones the app writes: time and
/// the memory it adds. A widget extension may use about 30 MB in all; WidgetKit and SwiftUI take
/// most of it, this is our part. They run only with LOCKGLOW_PERF=1 (screenshots.yml "olcum").
final class WidgetPerformanceTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["LOCKGLOW_PERF"] == "1",
            "widget timings run only in the measuring pass (LOCKGLOW_PERF=1)"
        )
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WidgetPerformanceTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let directory = directory {
            try? FileManager.default.removeItem(at: directory)
        }
    }

    /// Words with the field lengths of real cards (a long definition and example).
    private func words(_ count: Int) -> [WidgetWord] {
        return (1...count).map { id in
            WidgetWord(
                id: id,
                lemma: "headword\(id)",
                pos: "noun",
                level: "B1",
                ipaUS: "/ˈhɛdwɝd/",
                defMicro: "a short meaning of the word",
                defShort: "a definition of about ten words that explains the meaning",
                exampleEN: "This is an example sentence with headword\(id) in it.",
                glossTR: "kelimenin Türkçe anlamı",
                glossShortTR: "kısa anlam",
                sensitivity: 0,
                confusableIDs: id % 4 == 0 ? [id + 1] : nil
            )
        }
    }

    private func measureTimeline(queue count: Int, interval: Int, expectedEntries: Int) throws {
        let store = AppGroupStore(containerURL: directory)
        let now = Date()
        try store.writePlan(WidgetPlan(planID: "perf", isPremium: false, intervalSeconds: interval, queue: words(count), updatedAt: now))
        try store.writeState(WidgetState(planID: "perf", cursorOffset: 3, cursorAnchor: now, knownIDs: [2, 5], updatedAt: now))
        let bytes = (try? Data(contentsOf: store.planURL).count) ?? 0
        print("[ölçüm] widget, \(count) kelimelik plan: \(bytes) bayt")
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()], options: options) {
            let input = WordDataSource.load(store: store)
            let entries = WordProvider.makeEntries(input: input, now: Date())
            XCTAssertEqual(entries.count, expectedEntries)
        }
    }

    /// The plan the app writes: 96 words, 30 minutes (the most entries).
    func testTimelineFromTheAppsPlan() throws {
        try measureTimeline(queue: 96, interval: 1800, expectedEntries: 96)
    }

    /// A plan 50 times larger than the app writes (a damaged or future plan): still 96 entries.
    func testTimelineFromAnOversizedPlan() throws {
        try measureTimeline(queue: 5000, interval: 300, expectedEntries: 96)
    }
}
