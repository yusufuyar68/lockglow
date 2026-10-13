import Foundation

/// `vocabwidget://word/<id>`, opened by tapping a widget.
/// The scheme is also listed under `CFBundleURLSchemes` in project.yml; keep the two in sync.
/// It is brand-neutral on purpose, so renaming the app never breaks widget links.
public enum DeepLink {
    public static let scheme = "vocabwidget"

    public static func wordURL(id: Int) -> URL? {
        return URL(string: "\(scheme)://word/\(id)")
    }

    public static func wordID(from url: URL) -> Int? {
        guard url.scheme?.lowercased() == scheme, url.host == "word" else {
            return nil
        }
        return Int(url.lastPathComponent)
    }
}
