import XCTest
import CoreModels
import Learning

final class DataEraseTests: XCTestCase {
    private var root: URL!
    private let now = Date(timeIntervalSince1970: 1_760_011_200)

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("DataEraseTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: root)
    }

    private func folder(_ name: String) throws -> URL {
        let url = root.appendingPathComponent(name, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func touch(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("{}".utf8).write(to: url)
    }

    private func names(_ url: URL) throws -> [String] {
        return try FileManager.default.contentsOfDirectory(atPath: url.path).sorted()
    }

    func testEmptiesEveryFolderButKeepsTheAppGroupLibrary() throws {
        let support = try folder("Application Support")
        for name in ["progress.json", "progress.backup.json", "progress-unreadable-1.json", "custom_words.json",
                     "custom_words.backup.json", "review_log.jsonl", "local_metrics.json", ".hidden"] {
            try touch(support.appendingPathComponent(name))
        }
        try touch(support.appendingPathComponent("later-feature/state.json"))
        let tmp = try folder("tmp")
        try touch(tmp.appendingPathComponent("lockglow-disa-aktarim/lockglow-yedek-2025-10-09.json"))
        let group = try folder("group")
        try touch(group.appendingPathComponent("widget_plan.json"))
        try touch(group.appendingPathComponent("widget_state.json"))
        try touch(group.appendingPathComponent("events/1-a.json"))
        try touch(group.appendingPathComponent("Library/Caches/system.db"))

        let failed = DataErase.empty([
            DataErase.Folder(support),
            DataErase.Folder(tmp),
            DataErase.Folder(group, keeping: DataErase.appGroupKeeping),
            DataErase.Folder(root.appendingPathComponent("missing")),
        ])
        XCTAssertEqual(failed, [])
        XCTAssertEqual(try names(support), [], "hidden files and folders too")
        XCTAssertEqual(try names(tmp), [])
        XCTAssertEqual(try names(group), ["Library"])
        XCTAssertEqual(try names(group.appendingPathComponent("Library/Caches")), ["system.db"], "system folders stay")
        XCTAssertTrue(FileManager.default.fileExists(atPath: support.path), "the folder itself stays")
    }

    /// The backups go too: after an erase the stores start fresh instead of bringing back a backup.
    func testStoresStartFreshAfterAnErase() throws {
        let support = try folder("Application Support")
        let progressStore = ProgressStore(fileURL: support.appendingPathComponent("progress.json"))
        let wordStore = CustomWordStore(fileURL: support.appendingPathComponent("custom_words.json"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var list = CustomWordList()
        try list.add(CustomWordDraft(lemma: "awkward", meaningTR: "garip"), now: now)
        // Two days, so each store also keeps a daily backup.
        for offset in [0.0, 86_400] {
            try progressStore.save([1: WordProgress(wordID: 1)], now: now.addingTimeInterval(offset), calendar: calendar)
            try wordStore.save(list, now: now.addingTimeInterval(offset), calendar: calendar)
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: progressStore.backupURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: wordStore.backupURL.path))

        DataErase.empty([DataErase.Folder(support)])
        XCTAssertEqual(try progressStore.load(now: now).outcome, .fresh)
        XCTAssertEqual(try wordStore.load(now: now).outcome, .fresh)
    }
}
