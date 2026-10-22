/// Ids of the words the user adds ("Kendi kelimeni ekle", Learning/CustomWords.swift). Card ids
/// come from content-pipeline/data/id_registry.json and count up from 1 (`next_id` was 1069 on
/// 2026-10-22); the user's words start far above them, so the progress file, the widget plan and
/// widget events keep one id space without the two ever meeting. In CoreModels so the widget
/// extension can tell the user's words apart too.
public enum CustomWordID {
    public static let first = 1_000_000

    public static func contains(_ id: Int) -> Bool {
        return id >= first
    }
}

extension WidgetWord {
    /// A word the user added: no card detail (no quiz, notes or translations), no level, no part
    /// of speech and no English definition (`level`, `pos`, `defMicro` and `defShort` are empty).
    public var isUserAdded: Bool {
        return CustomWordID.contains(id)
    }
}
