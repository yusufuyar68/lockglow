import ActivityKit
import SwiftUI
import UIKit
import Learning

/// The running "Tekrar" round on the Lock Screen and in the Dynamic Island: "Kart 4 / 10" and
/// "Devam et", which opens "Tekrar" where the user left (`ReviewActivityAttributes.continueURL`,
/// RootView). When it starts, changes and closes is `ReviewActivityTracker` (Learning, tested on
/// Linux); this object does it with ActivityKit. The views are in Widgets/LiveActivity*.swift.
///
/// - ReviewView reports its counter (`roundChanged(to:)`), nil when no round runs.
/// - The app's background and activation reach it from the notification center: the 30 minutes
///   count from the moment the user leaves (`ReviewActivityTracker.timeout`).
/// - RootView calls `endLeftovers()` at launch: a new run has no round, so an activity left by
///   the last one (the app was closed in the middle of a round) goes.
/// - "Ayarlar" has a switch, on by default (`ReviewLiveActivitySection`).
@MainActor
final class ReviewLiveActivity {
    static let shared = ReviewLiveActivity()

    /// The switch in "Ayarlar"; on when never set.
    static let enabledKey = "lockglow.reviewLiveActivity"

    static var isEnabled: Bool {
        return UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true
    }

    private var tracker = ReviewActivityTracker()
    private var activity: Activity<ReviewActivityAttributes>?
    /// ActivityKit's calls run one after another, in the order they were made.
    private var lastCall: Task<Void, Never>?
    /// Asked when the app goes to the background, so the stale date moves before iOS suspends it.
    private var backgroundTask = UIBackgroundTaskIdentifier.invalid
    private var observers: [NSObjectProtocol] = []

    private init() {
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            MainActor.assumeIsolated {
                ReviewLiveActivity.shared.appDidEnterBackground()
            }
        })
        observers.append(center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            MainActor.assumeIsolated {
                ReviewLiveActivity.shared.appDidBecomeActive()
            }
        })
    }

    /// The round's counter changed; nil: the round ended ("Bitir" or the last card), or none runs.
    func roundChanged(to progress: ReviewActivityTracker.Progress?) {
        perform(tracker.roundChanged(to: progress, enabled: ReviewLiveActivity.isEnabled))
    }

    /// The switch in "Ayarlar" changed.
    func settingChanged(enabled: Bool) {
        perform(tracker.settingChanged(enabled: enabled))
    }

    /// Closes every activity of this kind but the running round's: at launch, the ones the last
    /// run left; before a start, any other one.
    func endLeftovers() {
        for leftover in Activity<ReviewActivityAttributes>.activities where leftover.id != activity?.id {
            enqueue {
                await leftover.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    private func appDidEnterBackground() {
        let action = tracker.didEnterBackground(at: Date())
        guard action != .none, activity != nil else {
            return
        }
        holdBackgroundTime()
        perform(action)
        enqueue {
            ReviewLiveActivity.shared.releaseBackgroundTime()
        }
    }

    private func appDidBecomeActive() {
        perform(tracker.didBecomeActive(at: Date()))
    }

    private func perform(_ action: ReviewActivityTracker.Action) {
        switch action {
        case .none:
            break
        case let .start(progress):
            start(progress)
        case let .update(progress):
            guard let running = activity else {
                return
            }
            let content = ReviewLiveActivity.content(progress)
            enqueue {
                await running.update(content)
            }
        case .end:
            guard let running = activity else {
                return
            }
            activity = nil
            enqueue {
                await running.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    private func start(_ progress: ReviewActivityTracker.Progress) {
        // Turned off for Lockglow in iOS Settings: the round goes on without one.
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            tracker.startFailed()
            return
        }
        endLeftovers()
        do {
            let started = try Activity<ReviewActivityAttributes>.request(
                attributes: ReviewActivityAttributes(),
                content: ReviewLiveActivity.content(progress),
                pushType: nil
            )
            activity = started
            watch(started)
        } catch {
            // Too many activities running, or the app was no longer in front.
            tracker.startFailed()
        }
    }

    /// Swiped away on the Lock Screen, or ended by iOS (after 8 hours, or Live Activities turned
    /// off): it does not come back in this round. An activity the app ended itself is no longer
    /// `activity` by then and is left alone.
    private func watch(_ watched: Activity<ReviewActivityAttributes>) {
        Task { [self] in
            for await state in watched.activityStateUpdates {
                guard self.activity?.id == watched.id else {
                    return
                }
                if state == .dismissed || state == .ended {
                    self.activity = nil
                    self.tracker.endedOutside()
                    return
                }
            }
        }
    }

    /// The counter, stale `ReviewActivityTracker.timeout` from now: then the views show no
    /// counter and no button until the app closes the activity.
    private static func content(_ progress: ReviewActivityTracker.Progress) -> ActivityContent<ReviewActivityAttributes.ContentState> {
        return ActivityContent(
            state: ReviewActivityAttributes.ContentState(card: progress.card, total: progress.total),
            staleDate: ReviewActivityTracker.staleDate(from: Date())
        )
    }

    private func enqueue(_ call: @escaping @MainActor () async -> Void) {
        let previous = lastCall
        lastCall = Task {
            await previous?.value
            await call()
        }
    }

    private func holdBackgroundTime() {
        guard backgroundTask == .invalid else {
            return
        }
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "Lockglow.reviewLiveActivity") {
            MainActor.assumeIsolated {
                ReviewLiveActivity.shared.releaseBackgroundTime()
            }
        }
    }

    private func releaseBackgroundTime() {
        guard backgroundTask != .invalid else {
            return
        }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}

// MARK: - Ayarlar

/// "Ayarlar": the switch of the round's Live Activity, on by default (Apple: make it easy to turn
/// off in the app). One line in SettingsView adds this section. When Live Activities are off for
/// Lockglow in iOS Settings, a row says so and opens them.
struct ReviewLiveActivitySection: View {
    @AppStorage(ReviewLiveActivity.enabledKey) private var isOn = true
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    /// Live Activities are off for Lockglow in iOS Settings.
    @State private var isOffInSystem = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Apple's Turkish name, as on Lockglow's row in iPhone Ayarları.
            SettingsSectionHeader("Canlı Etkinlikler")
            SettingsGroup {
                Toggle(isOn: $isOn) {
                    Text("Turu kilitli ekranda göster")
                        .settingsRowTitle()
                }
                // A switch is on in `good` green, as in iOS (never yellow, never ink).
                .tint(Theme.good)
                .settingsRowPadding()
                if isOn && isOffInSystem {
                    SettingsDivider()
                    VStack(alignment: .leading, spacing: 10) {
                        Text("iPhone Ayarları'nda Lockglow için Canlı Etkinlikler kapalı.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                openURL(url)
                            }
                        } label: {
                            Label("iPhone Ayarları'nı aç", systemImage: "gearshape")
                        }
                        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
                    }
                    .padding(14)
                }
            }
            // No time promise (terimler §1): a suspended app cannot close it at the 30th minute.
            Text("Turdan çıkınca kilitli ekranda hangi kartta olduğun görünür. Tur bitince kapanır.")
                .settingsFootnote()
        }
        .onAppear {
            refreshSystemSwitch()
        }
        // Back from iOS Settings.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                refreshSystemSwitch()
            }
        }
        .onChange(of: isOn) { _, enabled in
            ReviewLiveActivity.shared.settingChanged(enabled: enabled)
        }
    }

    private func refreshSystemSwitch() {
        isOffInSystem = !ActivityAuthorizationInfo().areActivitiesEnabled
    }
}
