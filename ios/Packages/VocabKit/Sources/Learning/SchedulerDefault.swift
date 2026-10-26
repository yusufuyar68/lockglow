import Foundation

/// Which scheduler a device starts with (docs/ozellik_planlari/fsrs.md 4.3 step 2). Pure; the app
/// gathers the evidence at launch (`OnboardingGate`'s) and writes the answer once, so no later
/// launch depends on a fallback.
///
/// FSRS is the default for a fresh install only. An update keeps Leitner: its words were timed by
/// Leitner, and nobody is moved to FSRS without turning "Yeni zamanlama" on (`FSRSMigration`).
public enum SchedulerDefault {
    /// - Parameters:
    ///   - storedRawValue: The saved `SchedulerKind` raw value; nil when it was never written.
    ///   - isFreshInstall: No earlier install left anything behind (no onboarding flag, no widget
    ///     plan, no progress).
    /// - Returns: a saved value decides when there is one; one this build does not know (garbage,
    ///   or a later build's) is Leitner. Without one: FSRS on a fresh install, Leitner on an update.
    public static func initialKind(storedRawValue: String?, isFreshInstall: Bool) -> SchedulerKind {
        if let stored = storedRawValue {
            return SchedulerKind(rawValue: stored) ?? .leitner
        }
        return isFreshInstall ? .fsrs : .leitner
    }
}
