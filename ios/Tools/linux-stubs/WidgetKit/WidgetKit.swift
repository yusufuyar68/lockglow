// Linux compile-check stub: WidgetCenter as used by the app.
public enum WidgetFamily: Sendable { case systemSmall, systemMedium, accessoryRectangular, accessoryInline }

public struct WidgetInfo: Sendable {
    public let kind: String
    public let family: WidgetFamily
}

public final class WidgetCenter: @unchecked Sendable {
    public static let shared = WidgetCenter()
    public func reloadAllTimelines() {}
    public func getCurrentConfigurations(_ completion: @escaping (Result<[WidgetInfo], Error>) -> Void) {}
}
