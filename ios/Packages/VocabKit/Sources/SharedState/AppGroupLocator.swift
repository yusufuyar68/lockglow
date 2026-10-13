import Foundation

/// Finds the App Group container. The identifier is injected into each target's Info.plist
/// (key `WGAppGroupID`, value `$(APP_GROUP_ID)` from Config/Base.xcconfig), never hardcoded.
public enum AppGroupLocator {
    public static let infoPlistKey = "WGAppGroupID"

    public static func groupIdentifier(bundle: Bundle = .main) -> String? {
        guard let raw = bundle.object(forInfoDictionaryKey: infoPlistKey) as? String else {
            return nil
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        // An unexpanded "$(APP_GROUP_ID)" means the xcconfig was not applied.
        if trimmed.isEmpty || trimmed.contains("$(") {
            return nil
        }
        return trimmed
    }

    public static func containerURL(bundle: Bundle = .main) -> URL? {
        guard let identifier = groupIdentifier(bundle: bundle) else {
            return nil
        }
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
}
