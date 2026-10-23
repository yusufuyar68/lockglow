import SwiftUI
import Learning

/// The reminder time rows of "Ayarlar", under "Her gün hatırlat": the time, then "Saati benim için
/// seç" (off by default; AppModel+ReminderTiming.swift). While the option is on, the time is
/// shown instead of picked, and one line under the switch says why it is that time
/// (`ReminderTiming.explanation`).
struct ReminderTimeRows: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.scenePhase) private var scenePhase
    /// "Ayarlar"' own picker binding: a picked time is saved and the reminders are planned again.
    let time: Binding<Date>

    /// Follows the setting wherever it changes (a time picked in "Saati değiştir" turns it off).
    @AppStorage(ReminderTimingStore.isOnKey) private var isAuto = false
    /// The latest decision's line; refreshed when the rows appear and when the switch changes.
    @State private var explanation: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isAuto {
                HStack(spacing: 12) {
                    Text("Saat")
                        .settingsRowTitle()
                    Spacer(minLength: 8)
                    // A value that is shown, not picked: `ink2`, like the values of the other rows.
                    Text(verbatim: ReminderTiming.clock(model.reminderMinuteOfDay))
                        .font(.body.monospacedDigit())
                        .foregroundStyle(Theme.ink2)
                }
                .settingsRowPadding()
                .accessibilityElement(children: .combine)
            } else {
                DatePicker(selection: time, displayedComponents: .hourAndMinute) {
                    Text("Saat")
                        .settingsRowTitle()
                }
                // 24-hour "20:00" like the app's other times (clockTime, README point 13), whatever the region.
                .environment(\.locale, Locale(identifier: "tr_TR"))
                .settingsRowPadding()
            }
            SettingsDivider()
            VStack(alignment: .leading, spacing: 4) {
                Toggle(isOn: autoBinding) {
                    Text("Saati benim için seç")
                        .settingsRowTitle()
                }
                // A switch is on in `good` green, as in iOS (never yellow, never ink).
                .tint(Theme.good)
                // VoiceOver reads the reason with the switch, not as a separate line.
                .accessibilityHint(Text(verbatim: isAuto ? explanation ?? "" : ""))
                if isAuto, let explanation = explanation {
                    Text(explanation)
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityHidden(true)
                }
            }
            .settingsRowPadding()
        }
        .onAppear {
            refresh()
        }
        // Back from the background, perhaps on a new day.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                refresh()
            }
        }
    }

    private var autoBinding: Binding<Bool> {
        return Binding(
            get: { isAuto },
            set: { isOn in
                model.setReminderAutoTime(isOn)
                isAuto = model.reminderAutoTime
                refresh()
                let reminders = model.reminderPlan()
                Task {
                    await ReminderScheduler.replace(with: reminders)
                }
            }
        )
    }

    /// Decides now (at most once a day it moves) and shows why.
    private func refresh() {
        explanation = model.reminderTimeDecision().map { ReminderTiming.explanation($0.reason) }
    }
}
