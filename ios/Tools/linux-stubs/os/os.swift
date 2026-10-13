// Linux compile-check stub of os.Logger (string interpolation with privacy:).
public struct OSLogPrivacy: Sendable {
    public static let `public` = OSLogPrivacy()
    public static let `private` = OSLogPrivacy()
    public static let auto = OSLogPrivacy()
}

public struct OSLogMessage: ExpressibleByStringInterpolation {
    public struct StringInterpolation: StringInterpolationProtocol {
        public init(literalCapacity: Int, interpolationCount: Int) {}
        public mutating func appendLiteral(_ literal: String) {}
        public mutating func appendInterpolation<T>(_ value: @autoclosure @escaping () -> T, privacy: OSLogPrivacy = .auto) {}
    }
    public init(stringLiteral value: String) {}
    public init(stringInterpolation: StringInterpolation) {}
}

public struct Logger: Sendable {
    public init(subsystem: String, category: String) {}
    public func info(_ message: OSLogMessage) {}
    public func notice(_ message: OSLogMessage) {}
    public func error(_ message: OSLogMessage) {}
    public func debug(_ message: OSLogMessage) {}
    public func fault(_ message: OSLogMessage) {}
}
