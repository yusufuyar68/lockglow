import Foundation

/// "Hepsini sil" (Ayarlar, İlerleme, Verilerin): empties the folders the app writes to. Unlike
/// "İlerlemeyi sıfırla", nothing is kept: progress and its backup, own words and their backup,
/// damaged files set aside, the review log, the local metrics, earlier exports, and the App
/// Group files the widget shares (plan, state, pending taps). The app clears its settings
/// (UserDefaults) and reminders itself (ios/App/AppModel+DataControls.swift).
///
/// Whole folders are emptied rather than a list of names, so a file a later build adds goes too.
/// Only names are listed (no dates or sizes are read).
public enum DataErase {
    /// One folder to empty. The folder itself stays; so do the names in `keeping`.
    public struct Folder: Equatable, Sendable {
        public let url: URL
        public let keeping: Set<String>

        public init(_ url: URL, keeping: Set<String> = []) {
            self.url = url
            self.keeping = keeping
        }
    }

    /// The App Group container's `Library` holds the system's own folders (Caches, and
    /// Preferences for a shared UserDefaults suite, which the app would clear through
    /// UserDefaults); the app's files sit beside it.
    public static let appGroupKeeping: Set<String> = ["Library"]

    /// Removes everything inside each folder except its `keeping` names. A missing folder is
    /// fine. Returns the items that could not be removed (empty when all went); the rest is
    /// removed anyway, so a second run can finish the job.
    @discardableResult
    public static func empty(_ folders: [Folder]) -> [URL] {
        let fileManager = FileManager.default
        var failed: [URL] = []
        for folder in folders {
            guard let items = try? fileManager.contentsOfDirectory(at: folder.url, includingPropertiesForKeys: nil, options: []) else {
                continue
            }
            // iOS keeps its own container metadata there (".com.apple.mobile_container_manager…").
            for item in items where !folder.keeping.contains(item.lastPathComponent)
                && !item.lastPathComponent.hasPrefix(".com.apple.") {
                do {
                    try fileManager.removeItem(at: item)
                } catch {
                    failed.append(item)
                }
            }
        }
        return failed
    }
}
