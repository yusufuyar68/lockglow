import Foundation
import Learning

/// "Saati benim için seç" (Ayarlar, `ReminderTimeRows`): the reminder moves to a little before
/// the time the user usually starts studying (`ReminderTiming`). The study times stay on the
/// phone (`StudyTimeRecorder`), the setting and the last decision in UserDefaults
/// (`ReminderTimingStore`). In AppModel.swift: `recordReview` notes each answer, `reminderPlan`
/// asks `reminderTimes`, `setReminderMinuteOfDay` (a time the user picks) ends the option and
/// `resetProgress` forgets the times.
extension AppModel {
    /// "Saati benim için seç" is on (off by default).
    var reminderAutoTime: Bool {
        return ReminderTimingStore.isOn()
    }

    /// On: the user's time is kept and the time moves from tomorrow on (`reminderTimeDecision`).
    /// Off: the user's time comes back. The caller plans the reminders again.
    func setReminderAutoTime(_ isOn: Bool) {
        guard isOn != reminderAutoTime else {
            return
        }
        if isOn {
            ReminderTimingStore.turnOn(chosenMinute: reminderMinuteOfDay)
        } else {
            let chosen = ReminderTimingStore.chosenMinute() ?? reminderMinuteOfDay
            ReminderTimingStore.turnOff()
            applyReminderMinute(chosen)
        }
    }

    /// A time the user picked ("Saati değiştir", the first reminder question): their time wins,
    /// the option is turned off and the picked time is kept.
    func endReminderAutoTime() {
        if reminderAutoTime {
            ReminderTimingStore.turnOff()
        }
    }

    /// Today's reminder time and the next days' (the saved time both, with the option off).
    func reminderTimes(now: Date = Date()) -> (today: Int, later: Int) {
        guard let decision = reminderTimeDecision(now: now) else {
            return (reminderMinuteOfDay, reminderMinuteOfDay)
        }
        return (decision.today, decision.later)
    }

    /// The option's decision at `now`, kept for the next one; nil while the option is off.
    /// Today's time becomes the saved reminder time, so every screen that shows it
    /// ("Hatırlatma: 20:00") shows this one. Never call it while a view is drawn.
    @discardableResult
    func reminderTimeDecision(now: Date = Date()) -> ReminderTiming.Decision? {
        guard reminderAutoTime else {
            return nil
        }
        let decision = ReminderTiming.decide(
            previous: ReminderTimingStore.state(),
            chosenMinute: reminderMinuteOfDay,
            starts: StudyTimeRecorder.shared.snapshot().starts,
            now: now,
            calendar: .current
        )
        ReminderTimingStore.save(decision.state)
        if decision.today != reminderMinuteOfDay {
            applyReminderMinute(decision.today)
        }
        return decision
    }

    /// An answer in "Tekrar": the first one after a break is the start of a stretch of studying.
    /// Whether a reminder came just before is read only then.
    func noteStudyTime(at now: Date = Date()) {
        StudyTimeRecorder.shared.recordAnswer(at: now) {
            ReminderLog.recentlySent(now: now).last?.fireDate
        }
    }

    /// "İlerlemeyi sıfırla" forgets the study times too (like the local metrics).
    func forgetStudyTimes() {
        StudyTimeRecorder.shared.reset()
    }
}
