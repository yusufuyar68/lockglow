// Linux compile-check stub with the SAME public signatures as the real GRDB-backed ContentStore.
// linux_check_prepare.py stops the Linux check when the public declarations differ.
import CoreModels

public final class ContentStore: @unchecked Sendable {
    public init(path: String) throws {}
    public func cardCount() throws -> Int { 0 }
    public func meta(_ key: String) throws -> String? { nil }
    public func freeCards(maxLevelRank: Int, limit: Int) throws -> [WidgetWord] { [] }
    public func topics() throws -> [ContentTopic] { [] }
    public func topicsByCard() throws -> [Int: Set<String>] { [:] }
    public func cardDetail(id: Int) throws -> CardDetail? { nil }
    public func search(_ query: String, limit: Int) throws -> [WidgetWord] { [] }
    public static func ftsMatchExpression(for query: String) -> String? { nil }
}
