import Combine
import Foundation
import Learning

/// "Kulak alıştırması" state: the minimal pairs from the app bundle (`minimal_pairs.json`, built
/// from content/kulak/) and the local counter per sound pair (Application Support/
/// ear_training.json). Owned by `EarTrainingView` while the screen is open; it never touches
/// `AppModel`, the Leitner progress or the widget plan.
@MainActor
final class EarTrainingModel: ObservableObject {
    /// Nil when the file is missing or cannot be read (`loadFailed`).
    @Published private(set) var content: EarTrainingContent?
    @Published private(set) var loadFailed = false
    @Published private(set) var tally = EarTrainingTally()

    private let store: EarTrainingStore?
    /// False when the counter file exists but could not be read (before the first unlock): the
    /// answers then count for this screen only and the file is left alone.
    private var canSave = true

    init(bundle: Bundle = .main) {
        // Every stored property first: the @Published ones below are set through `self`.
        store = (try? EarTrainingStore.defaultURL()).map(EarTrainingStore.init(fileURL:))
        if let url = bundle.url(forResource: "minimal_pairs", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? EarTrainingContent.decode(data),
           !decoded.groups.isEmpty {
            content = decoded
        } else {
            loadFailed = true
        }
        reloadTally()
    }

    /// Reads the counter file; while it cannot be read (before the first unlock) nothing is saved.
    private func reloadTally() {
        guard let store = store else {
            return
        }
        do {
            tally = try store.load()
            canSave = true
        } catch {
            canSave = false
        }
    }

    var groups: [EarTrainingGroup] {
        return content?.groups ?? []
    }

    func group(id: String) -> EarTrainingGroup? {
        return content?.group(id: id)
    }

    /// A new round: mixed (`focus` nil) or one sound pair; empty without content.
    func makeRound(focus: String?) -> [EarTrainingQuestion] {
        guard let content = content else {
            return []
        }
        var rng = SystemRandomNumberGenerator()
        return EarTrainingRound.make(content: content, tally: tally, focus: focus, using: &rng)
    }

    /// One answer, saved right away (a round left halfway keeps what was answered).
    func record(_ question: EarTrainingQuestion, isRight: Bool) {
        tally.add(groupID: question.groupID, isRight: isRight)
        save()
    }

    /// "Sayaçları sıfırla": the counter of every sound pair starts again.
    /// The file is removed even when it could not be read at the start (the phone is unlocked
    /// by now), so the counters do not come back on the next visit.
    func resetTally() {
        tally = EarTrainingTally()
        guard let store = store else {
            return
        }
        if (try? store.remove()) != nil {
            canSave = true
        }
    }

    private func save() {
        guard canSave, let store = store else {
            return
        }
        try? store.save(tally)
    }
}
