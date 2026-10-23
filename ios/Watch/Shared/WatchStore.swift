import Foundation
import CoreModels
import SharedState
import Scheduler

/// Where the watch keeps the phone's words (is5-watch). Compiled into the watch app and its
/// complications (Watch/Shared in project.yml).
///
/// The watch's App Group container holds the phone's own file formats (SharedState):
/// - `widget_plan.json`: the plan the phone sent (`WatchSync`), written by the watch app only;
/// - `widget_state.json`: the watch's own cursor and "Biliyorum" words, written by the watch app only;
/// - `events/`: taps not yet handed to WatchConnectivity (the watch app's outbox, `EventMailbox`);
/// - `watch_known.json`: words marked known on the watch lately (`WatchKnownLedger`).
/// The complications only read the first two. Nothing here touches SQLite or the network.
enum WatchStore {
    /// The store the complications read: the App Group container, or nil when it is unavailable
    /// (no entitlement); the complications then rotate the bundled seed words.
    static func sharedStore() -> AppGroupStore? {
        return AppGroupLocator.containerURL().map { AppGroupStore(containerURL: $0) }
    }

    /// The store the watch app writes: the App Group container, or its own Application Support
    /// folder when there is none (the app still works; its complications then show the seed words).
    static func appStore() -> AppGroupStore? {
        if let shared = sharedStore() {
            return shared
        }
        guard let support = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return nil
        }
        return AppGroupStore(containerURL: support.appendingPathComponent("Lockglow", isDirectory: true))
    }

    /// The rotation input: two small JSON files and, without a plan, the bundled seed words.
    static func loadInput(store: AppGroupStore?) -> RotationInput {
        let plan = store?.readPlan()
        let state = store?.readState()
        let hasPlan = !(plan?.queue.isEmpty ?? true)
        let seedWords: [WidgetWord] = hasPlan ? [] : SeedWords.load()
        return WatchRotation.input(plan: plan, state: state, seedWords: seedWords)
    }

    /// The one place the watch gets its alignment offset: words change on the local hour.
    static func alignmentOffset(for date: Date) -> TimeInterval {
        return TimelinePlanner.localAlignmentOffset(for: date)
    }
}

/// The Turkish meaning's forms, fullest first: the whole meaning, then one shorter form (the
/// editor's `gloss_short`, or else the meaning up to its first comma or semicolon outside brackets).
/// The same rule as the phone widgets (`WidgetGloss` in Widgets/HomeWordViews.swift): a form is
/// never cut; when none fits, the meaning is left out.
enum WatchGloss {
    static func forms(of word: WidgetWord) -> [String] {
        guard let gloss = word.glossTR else {
            return []
        }
        let editorShort = word.glossShortTR?.trimmingCharacters(in: .whitespaces) ?? ""
        let shorter = editorShort.isEmpty ? firstSense(of: gloss) : editorShort
        var result: [String] = []
        for candidate in [gloss, shorter] {
            let form = candidate.trimmingCharacters(in: .whitespaces)
            guard !form.isEmpty, !result.contains(form) else {
                continue
            }
            result.append(form)
        }
        return result
    }

    static func firstSense(of gloss: String) -> String {
        var depth = 0
        var end = gloss.endIndex
        scan: for index in gloss.indices {
            let character = gloss[index]
            if character == "(" {
                depth += 1
            } else if character == ")" {
                depth = max(depth - 1, 0)
            } else if depth == 0 && (character == "," || character == ";") {
                end = index
                break scan
            }
        }
        let trimmed = gloss[..<end].trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? gloss : trimmed
    }
}
