import Foundation

/// An event file that was read from the mailbox, kept together with its location so it can be deleted.
public struct StoredEvent: Equatable, Sendable {
    public let fileURL: URL
    public let event: WidgetEvent
}

/// Directory of one-file-per-event JSON files, named `<unix_ms>-<uuid>.json`.
/// The widget appends; the app lists, processes, then deletes.
public struct EventMailbox: Sendable {
    public let directory: URL

    public init(directory: URL) {
        self.directory = directory
    }

    @discardableResult
    public func append(_ event: WidgetEvent) throws -> URL {
        let data = try JSONCoding.makeEncoder().encode(event)
        let millis = Int64((event.at.timeIntervalSince1970 * 1000).rounded())
        let fileName = "\(millis)-\(UUID().uuidString).json"
        let url = directory.appendingPathComponent(fileName)
        try AtomicFile.write(data, to: url)
        return url
    }

    /// Decodable events, oldest first (file names start with the timestamp).
    /// Files that cannot be read or decoded are skipped, not deleted.
    public func list() throws -> [StoredEvent] {
        let decoder = JSONCoding.makeDecoder()
        var result: [StoredEvent] = []
        for url in try eventFileURLs() {
            guard let data = try? Data(contentsOf: url),
                  let event = try? decoder.decode(WidgetEvent.self, from: data)
            else {
                continue
            }
            result.append(StoredEvent(fileURL: url, event: event))
        }
        return result
    }

    public func delete(_ stored: StoredEvent) throws {
        try FileManager.default.removeItem(at: stored.fileURL)
    }

    /// Removes files whose bytes are readable but are not a valid event. Unreadable files
    /// (for example while the device is locked) are left alone. Returns the number removed.
    @discardableResult
    public func deleteUndecodableFiles() -> Int {
        guard let urls = try? eventFileURLs() else {
            return 0
        }
        let decoder = JSONCoding.makeDecoder()
        var removed = 0
        for url in urls {
            guard let data = try? Data(contentsOf: url) else {
                continue
            }
            if (try? decoder.decode(WidgetEvent.self, from: data)) != nil {
                continue
            }
            do {
                try FileManager.default.removeItem(at: url)
                removed += 1
            } catch {
                continue
            }
        }
        return removed
    }

    private func eventFileURLs() throws -> [URL] {
        guard FileManager.default.fileExists(atPath: directory.path) else {
            return []
        }
        let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        return urls
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
