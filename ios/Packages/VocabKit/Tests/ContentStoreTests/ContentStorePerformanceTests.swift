import XCTest
import CoreModels
import SharedState
import Learning
import ContentStore

/// The bundled content.sqlite of this checkout (`ios/App/Resources`), read-only.
enum RealContent {
    static var url: URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 {
            url.deleteLastPathComponent()
        }
        return url.appendingPathComponent("App/Resources/content.sqlite")
    }

    static func path() throws -> String {
        let path = url.path
        guard FileManager.default.fileExists(atPath: path) else {
            throw XCTSkip("no content.sqlite in this checkout")
        }
        return path
    }
}

/// Timings of the real content (1.203 cards, macOS only: GRDB): what the app reads at launch
/// (`ContentLoader.load`, off the main thread), the dictionary search (`AppModel.search`, main
/// thread, every keystroke) and the details of the first widget plan (`WidgetPlanWriter`).
/// One `measure` per test; each prints an "[ölçüm]" line (PerformanceTests/PerfFixtures.swift has
/// the same helper for the targets that run on Linux too).
final class ContentStorePerformanceTests: XCTestCase {
    private func measureReporting(_ label: String, budget: TimeInterval, _ block: () throws -> Void) {
        var durations: [Double] = []
        measure {
            let start = DispatchTime.now().uptimeNanoseconds
            do {
                try block()
            } catch {
                XCTFail("\(label): \(error)")
            }
            durations.append(Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000_000)
        }
        let sorted = durations.sorted()
        guard !sorted.isEmpty else {
            return
        }
        let median = sorted[sorted.count / 2]
        print("[ölçüm] \(label): " + String(format: "ortanca %.2f ms, en yavaş %.2f ms", median * 1000, sorted[sorted.count - 1] * 1000) + " (\(sorted.count) çalıştırma)")
        XCTAssertLessThan(median, budget, "\(label) is much slower than expected")
    }

    /// `ContentLoader.load`: open, the free cards, the count, the version, the topics.
    func testLoaderSequence() throws {
        let path = try RealContent.path()
        var count = 0
        measureReporting("içerik yükleme (ContentLoader sırası, gerçek DB)", budget: 1.0) {
            let store = try ContentStore(path: path)
            let words = try store.freeCards(maxLevelRank: 7, limit: 5000)
            _ = try store.cardCount()
            _ = try store.meta("content_version")
            _ = try store.topics()
            _ = try store.topicsByCard()
            count = words.count
        }
        XCTAssertGreaterThanOrEqual(count, 1200)
        print("[ölçüm] content.sqlite: \(count) ücretsiz kart, \((try? FileManager.default.attributesOfItem(atPath: path)[.size] as? Int) ?? 0) bayt")
    }

    func testFreeCards() throws {
        let store = try ContentStore(path: try RealContent.path())
        measureReporting("ContentStore.freeCards (1.203 kart)", budget: 0.5) {
            _ = try store.freeCards(maxLevelRank: 7, limit: 5000)
        }
    }

    func testTopics() throws {
        let store = try ContentStore(path: try RealContent.path())
        measureReporting("ContentStore.topics + topicsByCard", budget: 0.5) {
            _ = try store.topics()
            _ = try store.topicsByCard()
        }
    }

    /// Sözlük: one search per keystroke on the main thread. Short prefixes match the most cards.
    func testDictionarySearch() throws {
        let store = try ContentStore(path: try RealContent.path())
        let queries = ["a", "ka", "kahv", "be", "look up", "ev", "zor", "ç"]
        var hits = 0
        measureReporting("Sözlük araması (8 sorgu, 50 sonuç sınırı)", budget: 0.25) {
            hits = 0
            for query in queries {
                hits += try store.search(query, limit: 50).count
            }
        }
        XCTAssertGreaterThan(hits, 0)
        for query in queries {
            let start = DispatchTime.now().uptimeNanoseconds
            let found = try store.search(query, limit: 50).count
            let ms = Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000
            print("[ölçüm] Sözlük araması \"\(query)\": \(found) sonuç, " + String(format: "%.2f ms", ms))
        }
    }

    /// The first plan of a launch looks up the details of its 96 words (`WidgetPlanWriter`).
    func testCardDetailsOfAPlan() throws {
        let store = try ContentStore(path: try RealContent.path())
        let words = try store.freeCards(maxLevelRank: 7, limit: 96)
        var found = 0
        var shorter = 0
        measureReporting("96 kart ayrıntısı (JSON çöz + en kısa örnek)", budget: 0.5) {
            found = 0
            shorter = 0
            for word in words {
                guard let detail = try store.cardDetail(id: word.id) else {
                    continue
                }
                found += 1
                if let example = detail.shortestExample(containing: word.lemma), example != word.exampleEN {
                    shorter += 1
                }
            }
        }
        XCTAssertEqual(found, words.count)
        print("[ölçüm] ilk 96 kartın \(shorter) tanesinde widget için daha kısa örnek var")
    }

    /// The first plan from the real content as the app writes it: the deck, the queue, the
    /// examples, the file. Its size is what the widget reads on every timeline request.
    func testFirstPlanFromTheRealContent() throws {
        let store = try ContentStore(path: try RealContent.path())
        let words = try store.freeCards(maxLevelRank: 7, limit: 5000)
        let topicsOf = try store.topicsByCard()
        let input = WidgetPlanBuilder.Input(
            deck: DeckFilter.feed(words, topicsOf: topicsOf, choice: DeckChoice(startLevel: .a2)),
            fallbackFeed: DeckFilter.ordered(words, startingAt: .a2),
            progress: [:],
            rotationMinutes: 60,
            dailyNewWords: 5,
            limit: 96,
            horizon: 48 * 3600
        )
        let now = TimelinePlannerTime.wholeSecond(Date())
        var plan: WidgetPlan?
        measureReporting("ilk plan, gerçek içerik (kuyruk + 96 örnek, önbelleksiz)", budget: 1.0) {
            plan = WidgetPlanBuilder.makePlan(input, at: now, previousPlan: nil, state: nil) { word in
                (try? store.cardDetail(id: word.id))?.shortestExample(containing: word.lemma)
            }
        }
        let written = try XCTUnwrap(plan)
        XCTAssertEqual(written.queue.count, 96)

        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("real-plan-\(UUID().uuidString)", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        let appGroup = AppGroupStore(containerURL: directory)
        try appGroup.writePlan(written)
        let bytes = try Data(contentsOf: appGroup.planURL).count
        print("[ölçüm] widget_plan.json, gerçek içerik: \(bytes) bayt (" + String(format: "%.1f", Double(bytes) / 1024) + " KB), \(written.queue.count) kelime")
        XCTAssertLessThan(bytes, 96 * 1024)
    }
}

/// Whole seconds, as `AppModel.refreshWidgetPlan` passes the rewrite time (no Scheduler import here).
private enum TimelinePlannerTime {
    static func wholeSecond(_ date: Date) -> Date {
        return Date(timeIntervalSince1970: date.timeIntervalSince1970.rounded(.down))
    }
}
