import Foundation
import WidgetKit
import CoreModels

struct WordEntry: TimelineEntry {
    let date: Date
    let word: WidgetWord
    /// Date of the following timeline entry, if any (shown on the medium widget).
    let nextChange: Date?

    /// Static sample for the placeholder, the gallery snapshot and last-resort fallbacks. No I/O.
    static func sample(at date: Date = Date()) -> WordEntry {
        return WordEntry(date: date, word: WidgetWord.sample, nextChange: nil)
    }
}
