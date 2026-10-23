import Foundation
import os
import WatchKit
import WidgetKit
import CoreModels
import SharedState
import Scheduler

/// The watch app's state (is5-watch): the rotation from the watch's files, and the two buttons.
///
/// "Biliyorum" and "Sonraki kelime" move the watch's own rotation (its `widget_state.json`, the
/// phone widget's format) and leave one event for the phone in the outbox. The phone's app turns
/// the event into progress, as it does for a widget tap: the watch never grades a word, and seeing
/// a word is not a review.
@MainActor
final class WatchModel: ObservableObject {
    /// How long "Tamam. 3 gün sonra bir kez soracağız." stays after "Biliyorum".
    static let knownNoticeSeconds: UInt64 = 4

    @Published private(set) var input: RotationInput
    @Published private(set) var showsKnownNotice = false

    let speaker = WatchSpeaker()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow.watch",
        category: "model"
    )
    private let store = WatchStore.appStore()
    private var planObserver: NSObjectProtocol?
    private var noticeTask: Task<Void, Never>?

    init() {
        input = WatchStore.loadInput(store: store)
        planObserver = NotificationCenter.default.addObserver(
            forName: .lockglowWatchPlanDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.reload()
            }
        }
    }

    /// Reads the plan and the watch's state again (a new plan, the app coming to the front).
    func reload() {
        input = WatchStore.loadInput(store: store)
    }

    /// The word the watch shows at `date`: the same one as the watch face.
    func word(at date: Date) -> WidgetWord? {
        return WatchRotation.word(at: date, input: input, alignmentOffset: WatchStore.alignmentOffset(for: date))
    }

    /// "Sonraki kelime": the rotation goes on at the word after `word`.
    func next(_ word: WidgetWord) {
        record(.next, word: word)
        WKInterfaceDevice.current().play(.click)
    }

    /// "Biliyorum": the word leaves the watch; the phone asks it once 3 days later.
    func know(_ word: WidgetWord) {
        record(.known, word: word)
        WKInterfaceDevice.current().play(.success)
        showsKnownNotice = true
        noticeTask?.cancel()
        noticeTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: WatchModel.knownNoticeSeconds * 1_000_000_000)
            if Task.isCancelled {
                return
            }
            self?.showsKnownNotice = false
        }
    }

    private func record(_ type: WidgetEventType, word: WidgetWord) {
        speaker.stop()
        if type != .known {
            showsKnownNotice = false
        }
        let now = Date()
        let offset = WatchStore.alignmentOffset(for: now)
        let wordID = word.id
        let logger = self.logger
        // On the sync queue, after any plan received so far: the state is computed from the files
        // as they are then, and nothing else writes them meanwhile.
        WatchSession.shared.update({ store in
            let current = WatchStore.loadInput(store: store)
            let state: WidgetState
            if type == .known {
                state = WatchRotation.stateAfterKnow(shownWordID: wordID, input: current, now: now, alignmentOffset: offset)
            } else {
                state = WatchRotation.stateAfterNext(shownWordID: wordID, input: current, now: now, alignmentOffset: offset)
            }
            do {
                try store.writeState(state)
            } catch {
                logger.error("state not saved: \(error.localizedDescription, privacy: .public)")
            }
            if type == .known {
                var ledger = WatchKnownLedger.read(from: store.containerURL).pruned(now: now)
                ledger.record(wordID, at: now)
                try? ledger.write(to: store.containerURL)
            }
            do {
                try store.eventMailbox.append(WidgetEvent(type: type, wordID: wordID, at: now, source: .watch))
            } catch {
                logger.error("tap not saved for the phone: \(error.localizedDescription, privacy: .public)")
            }
        }, then: { [weak self] in
            self?.reload()
            WidgetCenter.shared.reloadAllTimelines()
            WatchSession.shared.flushOutbox()
        })
    }
}
