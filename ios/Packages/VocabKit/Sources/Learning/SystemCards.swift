import Foundation

/// System cards (`docs/tasarim/ogrenme_ilkeleri.md` §2.10): notes at an opening that teach no
/// word. After a long break up to six could pile up in one opening; at most one is shown.
public enum SystemCard: Int, CaseIterable, Comparable, Identifiable, Sendable {
    // In priority order, the most important first (§2.10: the pause note > the time question >
    // "Ara verdin" > the end-of-day card; the recovery warning and the widget tip around them).

    /// The progress file was damaged and recovered (`AppModel.progressRecovery`).
    case progressRecovered
    /// "Hatırlatmaları duraklattık." after a week of ignored reminders.
    case remindersPaused
    /// "Hatırlatma saatini değiştirelim mi?" after three days of ignored reminders.
    case reminderTime
    /// No widget yet: how to add one.
    case widgetTip
    /// "Ara verdin, sorun değil." at the start of "Tekrar" after a break (shown by ReviewView).
    case breakStart
    /// "Bugünlük yeter." at the end of the day's new words in "Akış" (shown by FeedView).
    case dayEnd
    /// is5-haftalik: "Geçen hafta" on Monday, once (`WeeklyRecap`; shown by WeeklyRecapView's
    /// presenter on RootView after a claim, like the screens' cards).
    case weeklyRecap

    public var id: Int {
        return rawValue
    }

    /// A screen shows this card itself after `SystemCardSlot.claim(_:)`; the others are the
    /// opening's sheet, chosen by `SystemCardSlot.decide(from:opening:)`.
    public var isScreenCard: Bool {
        switch self {
        case .breakStart, .dayEnd, .weeklyRecap:
            return true
        case .progressRecovered, .remindersPaused, .reminderTime, .widgetTip:
            return false
        }
    }

    public static func < (lhs: SystemCard, rhs: SystemCard) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Which system card an opening shows: at most one. An opening lasts from coming to the
/// foreground until going to the background. Pure; `SystemCardQueue` (RootView) keeps one and
/// publishes it to the screens.
///
/// 1. `beginOpening(stillShown:)` when the app comes to the foreground. It returns the opening's
///    number when the sheet's candidates should be gathered.
/// 2. `decide(from:opening:)` with those candidates: the first by priority is this opening's card.
///    The sheet cards always come before the screens' cards, which can only be claimed from now on.
/// 3. `claim(_:)` by a screen about to show its own card: true while no other card has this
///    opening. Only one tab is on screen at a time, so between the two screen cards the first
///    claim wins. A card that is not chosen is not shown in this opening.
/// 4. `endOpening()` when the app goes to the background.
public struct SystemCardSlot: Equatable, Sendable {
    /// The number of the latest opening; 0 before the first.
    public private(set) var opening = 0
    /// An opening is running (between `beginOpening` and `endOpening`).
    public private(set) var isOpen = false
    /// This opening's sheet card has been decided (or none): screens may claim from now on.
    public private(set) var isDecided = false
    /// This opening's card: the sheet's, or the one a screen claimed. Nil while it is free.
    public private(set) var current: SystemCard?

    public init() {}

    /// Starts an opening. Returns its number when the candidates should be gathered and passed to
    /// `decide(from:opening:)`; nil when an opening is already running (the launch and the first
    /// activation both start one) or when `stillShown`, the sheet left open from before the
    /// background, is on screen: that card is this opening's and nothing else is decided.
    public mutating func beginOpening(stillShown: SystemCard?) -> Int? {
        if isOpen {
            return nil
        }
        isOpen = true
        opening += 1
        if let card = stillShown {
            current = card
            isDecided = true
            return nil
        }
        current = nil
        isDecided = false
        return opening
    }

    public mutating func endOpening() {
        isOpen = false
        isDecided = false
        current = nil
    }

    /// The sheet for `opening`: the first of `candidates` by priority (screen cards are never a
    /// sheet and are left out). Nil when there is none, when this opening was already decided, or
    /// when `opening` is over: the app went to the background while the candidates were being
    /// gathered, and a card chosen then would land in the next opening unasked.
    @discardableResult
    public mutating func decide(from candidates: Set<SystemCard>, opening: Int) -> SystemCard? {
        guard isOpen, opening == self.opening, !isDecided else {
            return nil
        }
        isDecided = true
        guard current == nil, let first = candidates.filter({ !$0.isScreenCard }).min() else {
            return nil
        }
        current = first
        return first
    }

    /// A screen's own card (`isScreenCard`): true when it is this opening's card, because the slot
    /// was free or the screen already has it (asking again is harmless). False before the sheet is
    /// decided, outside an opening, for a sheet card, and when another card has this opening.
    public mutating func claim(_ card: SystemCard) -> Bool {
        guard isOpen, isDecided, card.isScreenCard else {
            return false
        }
        if current == nil {
            current = card
        }
        return current == card
    }
}
