// Linux compile-check stub with the SAME public signatures as the real GRDB-backed ContentStore.
import CoreModels

public final class ContentStore {
    public init(path: String) throws {}
    public func cardCount() throws -> Int { 0 }
    public func meta(_ key: String) throws -> String? { nil }
    public func freeCards(maxLevelRank: Int, limit: Int) throws -> [WidgetWord] { [] }
    public func cardDetail(id: Int) throws -> CardDetail? { nil }
    public func search(_ query: String, limit: Int) throws -> [WidgetWord] { [] }
    public static func ftsMatchExpression(for query: String) -> String? { nil }
}
