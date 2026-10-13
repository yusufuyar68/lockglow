import Foundation

/// App-private progress file (JSON array sorted by word id). Single writer: the app.
/// CloudKit sync replaces this in v1.2; until then it lives in Application Support.
public struct ProgressStore: Sendable {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Default location: Application Support/progress.json (created on first save).
    public static func defaultURL() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base.appendingPathComponent("progress.json")
    }

    /// Missing or unreadable file: empty progress (every word is new).
    public func load() -> [Int: WordProgress] {
        guard let data = try? Data(contentsOf: fileURL),
              let list = try? ProgressStore.makeDecoder().decode([WordProgress].self, from: data)
        else {
            return [:]
        }
        var result: [Int: WordProgress] = [:]
        for item in list {
            result[item.wordID] = item
        }
        return result
    }

    public func save(_ progress: [Int: WordProgress]) throws {
        let list = progress.values.sorted { $0.wordID < $1.wordID }
        let data = try ProgressStore.makeEncoder().encode(list)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: [.atomic])
    }

    // Seconds since 1970 as a Double: exact round trip (ISO 8601 would drop fractions of a second).
    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
}
