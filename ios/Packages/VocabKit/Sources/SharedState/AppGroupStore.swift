import Foundation

/// Atomic JSON files in the App Group container.
///
/// Single-writer rule (contract section 6): the app calls `writePlan`, the widget calls
/// `writeState`, and only the widget appends to `eventMailbox`. Nobody writes the other
/// side's file. Reads are best effort and return nil for missing or undecodable files.
public struct AppGroupStore: Sendable {
    public static let planFileName = "widget_plan.json"
    public static let stateFileName = "widget_state.json"
    public static let eventsDirectoryName = "events"

    public let containerURL: URL

    public init(containerURL: URL) {
        self.containerURL = containerURL
    }

    public var planURL: URL {
        return containerURL.appendingPathComponent(AppGroupStore.planFileName)
    }

    public var stateURL: URL {
        return containerURL.appendingPathComponent(AppGroupStore.stateFileName)
    }

    public var eventsDirectoryURL: URL {
        return containerURL.appendingPathComponent(AppGroupStore.eventsDirectoryName, isDirectory: true)
    }

    public var eventMailbox: EventMailbox {
        return EventMailbox(directory: eventsDirectoryURL)
    }

    // MARK: Plan (app writes)

    public func readPlan() -> WidgetPlan? {
        return read(WidgetPlan.self, from: planURL)
    }

    public func writePlan(_ plan: WidgetPlan) throws {
        try write(plan, to: planURL)
    }

    // MARK: State (widget writes)

    public func readState() -> WidgetState? {
        return read(WidgetState.self, from: stateURL)
    }

    public func writeState(_ state: WidgetState) throws {
        try write(state, to: stateURL)
    }

    // MARK: Helpers

    private func read<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONCoding.makeDecoder().decode(type, from: data)
    }

    private func write<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try JSONCoding.makeEncoder().encode(value)
        try AtomicFile.write(data, to: url)
    }
}
