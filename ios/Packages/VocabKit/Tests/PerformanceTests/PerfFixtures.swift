import Foundation
import XCTest
import CoreModels
import Learning

/// Data the size of the real content (1.203 cards, 2026.10.22-kisisel-9) without content.sqlite,
/// so the timings run on Linux too: the field lengths, topic memberships and confusable pairs are
/// close to the real cards'. The real database is measured on macOS
/// (`ContentStoreTests/ContentStorePerformanceTests`).
enum PerfFixtures {
    static let cardCount = 1203
    /// 2026-10-23 10:00:00 UTC, a whole second.
    static let now = Date(timeIntervalSince1970: 1_792_749_600)
    static let day: TimeInterval = 86_400

    static let levels = ["A1", "A2", "B1", "B2", "C1"]

    /// Cards in the feed's order (level, then frequency), ids 1...count.
    static func cards(_ count: Int = cardCount) -> [WidgetWord] {
        var generator = PerfRandom(seed: 1203)
        return (1...count).map { id in
            let level = levels[min(levels.count - 1, (id - 1) * levels.count / count)]
            let lemma = generator.word(minLength: 3, maxLength: 11) + (id % 9 == 0 ? " " + generator.word(minLength: 2, maxLength: 5) : "")
            return WidgetWord(
                id: id,
                lemma: lemma,
                pos: ["noun", "verb", "adjective", "adverb", "phrase"][id % 5],
                level: level,
                ipaUS: "/\(generator.word(minLength: 4, maxLength: 9))/",
                defMicro: generator.sentence(words: 4),
                defShort: generator.sentence(words: 10),
                exampleEN: generator.sentence(words: 9, containing: lemma),
                glossTR: generator.sentence(words: 2),
                glossShortTR: id % 11 == 0 ? generator.word(minLength: 4, maxLength: 9) : nil,
                sensitivity: id % 130 == 0 ? 1 : 0,
                confusableIDs: id % 4 == 0 && id < count ? [id + 1] : nil
            )
        }
    }

    /// 36 topics; every card belongs to one to three of them (1.905 memberships in the real content).
    static func topicsOf(_ cards: [WidgetWord]) -> [Int: Set<String>] {
        var result: [Int: Set<String>] = [:]
        for card in cards {
            var topics: Set<String> = ["t\(card.id % 36)"]
            if card.id % 2 == 0 {
                topics.insert("t\((card.id / 2) % 36)")
            }
            if card.id % 5 == 0 {
                topics.insert("t\((card.id / 5) % 36)")
            }
            result[card.id] = topics
        }
        return result
    }

    enum User: String, CaseIterable {
        /// First week: nothing studied yet.
        case fresh = "yeni kullanıcı"
        /// About a month: 320 learning (40 answered today, 8 of them missed), 120 known.
        case month = "bir ay"
        /// Most of the content met: 850 learning, 300 known.
        case heavy = "yoğun kullanıcı"
    }

    /// Progress of `user` over `cards` at `now`: due dates spread over the past and the coming weeks.
    static func progress(_ user: User, cards: [WidgetWord]) -> [Int: WordProgress] {
        let (learningCount, knownCount, answeredToday): (Int, Int, Int)
        switch user {
        case .fresh:
            return [:]
        case .month:
            (learningCount, knownCount, answeredToday) = (320, 120, 40)
        case .heavy:
            (learningCount, knownCount, answeredToday) = (850, 300, 60)
        }
        var generator = PerfRandom(seed: UInt64(learningCount))
        var result: [Int: WordProgress] = [:]
        for (index, card) in cards.prefix(learningCount + knownCount).enumerated() {
            var p = WordProgress(wordID: card.id)
            p.reviews = 1 + Int(generator.next(upTo: 6))
            p.exposures = Int(generator.next(upTo: 9))
            if index < learningCount {
                p.state = .learning
                p.box = 1 + Int(generator.next(upTo: 5))
                if index < answeredToday {
                    let answeredAt = now.addingTimeInterval(-Double(generator.next(upTo: 30_000)))
                    let missed = index % 5 == 0
                    p.lastReviewedAt = answeredAt
                    p.lastSeenAt = answeredAt
                    p.lastGrade = missed ? .again : .good
                    p.dueAt = answeredAt.addingTimeInterval(missed ? Leitner.relearnDelay : Double(p.box) * day)
                } else {
                    let due = now.addingTimeInterval((Double(generator.next(upTo: 30)) - 8) * day)
                    p.dueAt = due
                    p.lastSeenAt = due.addingTimeInterval(-Double(p.box) * day)
                    p.lastReviewedAt = p.lastSeenAt
                    p.lastGrade = .good
                }
                p.firstReviewedAt = now.addingTimeInterval(-30 * day)
            } else {
                p.state = .known
                p.box = Leitner.maxBox
                p.knownOverride = index % 7 == 0
                p.dueAt = now.addingTimeInterval((Double(generator.next(upTo: 120)) - 10) * day)
                p.refresherStep = Int(generator.next(upTo: 3))
            }
            result[card.id] = p
        }
        return result
    }

    /// A new, empty folder for one test.
    static func temporaryDirectory(_ name: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("lockglow-perf-\(name)-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// `ios/` of this checkout (tests read the bundled seed words from there).
    static var iosDirectory: URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 {
            url.deleteLastPathComponent()
        }
        return url
    }

    static var seedWordsURL: URL {
        return iosDirectory.appendingPathComponent("Widgets/Resources/seed_words.json")
    }
}

/// Measured values for the notes (`is5-performans.md`): one greppable line each, "[ölçüm] ...".
enum PerfReport {
    static func value(_ label: String, _ value: String) {
        print("[ölçüm] \(label): \(value)")
    }

    static func bytes(_ label: String, _ count: Int) {
        value(label, "\(count) bayt (\(String(format: "%.1f", Double(count) / 1024)) KB)")
    }
}

extension XCTestCase {
    /// `measure` and one "[ölçüm]" line with the median and the slowest run. `budget` is a
    /// generous ceiling for the median, at least 2 s (shared CI machines vary, the macOS run is a
    /// debug build on Intel): only a large regression fails, the numbers are for the notes.
    func measureReporting(
        _ label: String,
        budget: TimeInterval,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ block: () throws -> Void
    ) {
        var durations: [Double] = []
        measure {
            let start = DispatchTime.now().uptimeNanoseconds
            do {
                try block()
            } catch {
                XCTFail("\(label): \(error)", file: file, line: line)
            }
            durations.append(Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000_000)
        }
        guard !durations.isEmpty else {
            return
        }
        let sorted = durations.sorted()
        let median = sorted[sorted.count / 2]
        let slowest = sorted[sorted.count - 1]
        PerfReport.value(label, String(format: "ortanca %.2f ms, en yavaş %.2f ms", median * 1000, slowest * 1000) + " (\(sorted.count) çalıştırma)")
        XCTAssertLessThan(median, max(budget, 2.0), "\(label) is much slower than expected", file: file, line: line)
    }
}

/// Seeded and the same on every platform, so every run measures the same data.
struct PerfRandom: RandomNumberGenerator {
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

    mutating func word(minLength: Int, maxLength: Int) -> String {
        let letters = Array("abcdefghiklmnoprstuvwyeaio")
        let length = minLength + Int(next(upTo: UInt64(maxLength - minLength + 1)))
        return String((0..<length).map { _ in letters[Int(next(upTo: UInt64(letters.count)))] })
    }

    mutating func sentence(words: Int, containing phrase: String? = nil) -> String {
        var parts = (0..<words).map { _ in word(minLength: 2, maxLength: 8) }
        if let phrase = phrase {
            parts.insert(phrase, at: Int(next(upTo: UInt64(parts.count + 1))))
        }
        let text = parts.joined(separator: " ")
        return String(text.prefix(1)).uppercased() + String(text.dropFirst()) + "."
    }
}
