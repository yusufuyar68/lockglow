import Foundation

/// `seed_words.json` (contract section 5).
public struct SeedWordsFile: Codable, Sendable {
    public let schemaVersion: Int
    public let contentVersion: String
    public let words: [WidgetWord]

    public init(schemaVersion: Int, contentVersion: String, words: [WidgetWord]) {
        self.schemaVersion = schemaVersion
        self.contentVersion = contentVersion
        self.words = words
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contentVersion = "content_version"
        case words
    }
}

public enum SeedWords {
    public static let resourceName = "seed_words"
    public static let resourceExtension = "json"

    public static func decode(_ data: Data) throws -> SeedWordsFile {
        return try JSONDecoder().decode(SeedWordsFile.self, from: data)
    }

    /// Loads the seed words bundled with the running target. Returns an empty array when
    /// the file is missing or unreadable (callers must handle that).
    public static func load(bundle: Bundle = .main) -> [WidgetWord] {
        guard let url = bundle.url(forResource: resourceName, withExtension: resourceExtension),
              let data = try? Data(contentsOf: url),
              let file = try? decode(data)
        else {
            return []
        }
        return file.words
    }
}
