import Foundation

/// Whether the onboarding opens by itself at launch. Pure; the app gathers the evidence.
public enum OnboardingGate {
    /// - Parameters:
    ///   - storedCompleted: The saved flag; nil when it was never written.
    ///   - hasWidgetPlan: `widget_plan.json` exists (every earlier build writes one at launch).
    ///   - hasProgress: the progress file exists, or the old build's known words are still stored.
    /// - Returns: the saved flag decides when there is one. Without a flag, any sign of an
    ///   earlier install means an update: the onboarding does not open (it stays in "Ayarlar").
    public static func shouldShow(storedCompleted: Bool?, hasWidgetPlan: Bool, hasProgress: Bool) -> Bool {
        if let completed = storedCompleted {
            return !completed
        }
        return !(hasWidgetPlan || hasProgress)
    }
}
