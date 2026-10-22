import Foundation
import CoreModels

/// Collects problems seen on background threads; the test asserts on the main thread afterwards.
final class ConcurrentLog: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String] = []

    func add(_ item: String) {
        lock.lock()
        storage.append(item)
        lock.unlock()
    }

    var items: [String] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }
}

/// A fresh, empty folder under the system temporary directory (the "App Group container" of a test).
func makeTemporaryDirectory(_ name: String) throws -> URL {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("\(name)-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}

func makeTestWord(_ id: Int) -> WidgetWord {
    return WidgetWord(
        id: id,
        lemma: "word\(id)",
        pos: "n",
        level: "A1",
        ipaUS: nil,
        defMicro: "micro",
        defShort: "short",
        exampleEN: "example",
        glossTR: "tr"
    )
}
