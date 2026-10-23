import Foundation

/// When the "Tekrar" round's Live Activity (Lock Screen and Dynamic Island) starts, changes and
/// closes. Pure; `ReviewLiveActivity` (App) keeps one and does what it returns with ActivityKit.
///
/// - It starts with a round, while the app is in front (ActivityKit starts one only then; the
///   system does not show it in the Dynamic Island while the app is open), and follows the
///   round's "Kart 4 / 10" (`roundChanged(to:enabled:)`).
/// - It closes at once when the round ends: the last card, or "Bitir".
/// - It closes `timeout` after the user left the app in the middle of a round: Apple keeps Live
///   Activities for a task that is really going on. A suspended app cannot close it on time, so
///   the activity is stale from then on (`staleDate(from:)`: its views drop the counter and the
///   button) and the app closes it when it comes back (`didBecomeActive(at:)`) or at its next
///   launch.
/// - Closed by the timeout, it comes back when the user goes on with the round (the next card).
///   Closed by the user (swiped away), by iOS, by the switch in "Ayarlar" or by a start that did
///   not work, it does not come back in the same round; the next round starts a new one.
public struct ReviewActivityTracker: Equatable, Sendable {
    /// "Kart 4 / 10": the card on screen, from 1, and the round's cards.
    public struct Progress: Equatable, Sendable {
        public let card: Int
        public let total: Int

        public init(card: Int, total: Int) {
            self.card = card
            self.total = total
        }

        /// From the round's counter, `done` cards out of `total`: the card on screen is the next
        /// one, never past the last (ReviewView's "Kart 3 / 10").
        public init(done: Int, total: Int) {
            self.init(card: min(done + 1, max(total, 1)), total: total)
        }
    }

    public enum Action: Equatable, Sendable {
        case none
        /// Start an activity that shows this progress.
        case start(Progress)
        /// Show this progress; the stale date moves to `timeout` from now.
        case update(Progress)
        /// Close the activity at once (it leaves the Lock Screen too).
        case end
    }

    /// A round left alone this long is over for the Lock Screen.
    public static let timeout: TimeInterval = 30 * 60

    /// The running round's progress; nil when no round runs.
    public private(set) var progress: Progress?
    /// An activity shows the running round.
    public private(set) var isShowing = false
    /// The round's activity was closed before the round ended: none comes back in this round.
    public private(set) var isClosedForRound = false
    /// When the app went to the background with the activity showing; nil while in front.
    public private(set) var leftAt: Date?

    public init() {}

    /// The round's counter changed; nil when the round ended (or none started). `enabled` is the
    /// switch in "Ayarlar".
    public mutating func roundChanged(to newProgress: Progress?, enabled: Bool) -> Action {
        let old = progress
        progress = newProgress
        guard let newProgress = newProgress else {
            // The round ended: the next one may show an activity again.
            isClosedForRound = false
            leftAt = nil
            if isShowing {
                isShowing = false
                return .end
            }
            return .none
        }
        if isShowing {
            return newProgress == old ? .none : .update(newProgress)
        }
        guard enabled, !isClosedForRound else {
            return .none
        }
        isShowing = true
        return .start(newProgress)
    }

    /// The start did not work (Live Activities off in iOS Settings, too many running): the round
    /// goes on without one.
    public mutating func startFailed() {
        isShowing = false
        isClosedForRound = progress != nil
    }

    /// The activity ended without the app: swiped away on the Lock Screen, or ended by iOS (after
    /// 8 hours, or Live Activities turned off).
    public mutating func endedOutside() {
        guard isShowing else {
            return
        }
        isShowing = false
        isClosedForRound = progress != nil
        leftAt = nil
    }

    /// The app went to the background: the user left the round, the `timeout` starts now. The
    /// update moves the stale date.
    public mutating func didEnterBackground(at date: Date) -> Action {
        guard isShowing, let progress = progress else {
            return .none
        }
        leftAt = date
        return .update(progress)
    }

    /// The app is in front again: the activity closes when the user was away `timeout` or longer.
    /// The round is not closed for it: going on with it (the next card) shows it again.
    public mutating func didBecomeActive(at date: Date) -> Action {
        guard let left = leftAt else {
            return .none
        }
        leftAt = nil
        guard isShowing, date.timeIntervalSince(left) >= ReviewActivityTracker.timeout else {
            return .none
        }
        isShowing = false
        return .end
    }

    /// The switch in "Ayarlar": off closes the activity now, for the rest of the round. On starts
    /// nothing by itself: the next round (or the next card of a round that never had one) does.
    public mutating func settingChanged(enabled: Bool) -> Action {
        guard !enabled, isShowing else {
            return .none
        }
        isShowing = false
        isClosedForRound = true
        leftAt = nil
        return .end
    }

    /// The activity is stale (no counter, no button) from `timeout` after `date` on.
    public static func staleDate(from date: Date) -> Date {
        return date.addingTimeInterval(timeout)
    }
}
