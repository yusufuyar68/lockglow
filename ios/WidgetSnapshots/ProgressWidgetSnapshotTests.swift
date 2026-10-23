import XCTest
import SwiftUI
import UIKit
import WidgetKit
import SharedState

/// The Lock Screen progress widget (Widgets/Progress*.swift): its words for every state, its
/// timeline, and its three families rendered at real sizes (attachments `ilerleme-…`), as
/// `WidgetSnapshotTests` does for the word widget: opaque grays on a dark wallpaper, darker on the
/// Always-On display (`-aod`), and on the iPhone SE at three larger text sizes.
@MainActor
final class ProgressWidgetSnapshotTests: XCTestCase {
    /// Istanbul (no daylight saving), so the texts do not depend on the simulator's time zone.
    private static let istanbul: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Istanbul")!
        return calendar
    }()

    /// 23 October 2026 at `hour:minute` (Istanbul), plus `days`.
    private func date(_ hour: Int, _ minute: Int = 0, days: Int = 0) -> Date {
        let components = DateComponents(year: 2026, month: 10, day: 23 + days, hour: hour, minute: minute)
        return ProgressWidgetSnapshotTests.istanbul.date(from: components)!
    }

    // MARK: Words

    func testCounts() {
        XCTAssertEqual(ProgressText.count(1), "1")
        XCTAssertEqual(ProgressText.count(10), "10")
        XCTAssertEqual(ProgressText.count(11), "10+")
        XCTAssertEqual(ProgressText.count(87), "10+")
        XCTAssertEqual(ProgressText.spokenWords(6), "6 kelime")
        XCTAssertEqual(ProgressText.spokenWords(87), "10'dan fazla kelime")
    }

    func testWhen() {
        let calendar = ProgressWidgetSnapshotTests.istanbul
        let today = ProgressText.when(date(21, 40), now: date(10), calendar: calendar)
        XCTAssertEqual([today.day, today.time], ["bugün", "21:40"])
        let tomorrow = ProgressText.when(date(9, 15, days: 1), now: date(10), calendar: calendar)
        XCTAssertEqual([tomorrow.day, tomorrow.time], ["yarın", "09:15"])
        let later = ProgressText.when(date(9, days: 3), now: date(10), calendar: calendar)
        XCTAssertEqual([later.day, later.time], ["26 Ekim", "09:00"])
        // Just before midnight, a review just after it is "yarın".
        let night = ProgressText.when(date(0, 10, days: 1), now: date(23, 50), calendar: calendar)
        XCTAssertEqual([night.day, night.time], ["yarın", "00:10"])
    }

    func testRectangularRows() {
        let calendar = ProgressWidgetSnapshotTests.istanbul
        let cases = statuses(now: date(10), calendar: calendar)

        let due = ProgressText.rectangular(cases["bekliyor"]!, calendar: calendar)
        XCTAssertEqual(due.first, ["Tekrar zamanı"])
        XCTAssertEqual(due.second, ["Bugün: 6 kelime"])
        XCTAssertEqual(due.spoken, "Tekrar zamanı. Bugün 6 kelime tekrar edilecek.")

        let later = ProgressText.rectangular(cases["sirada"]!, calendar: calendar)
        XCTAssertEqual(later.first, [
            "Sıradaki tekrar: bugün 21:40",
            "Sıradaki tekrar: 21:40",
            "Tekrar: bugün 21:40",
            "Tekrar: 21:40",
            "21:40",
        ])
        XCTAssertEqual(later.second, ["Bugün: 6 kelime"])
        XCTAssertEqual(later.spoken, "Sıradaki tekrar: bugün 21:40. Bugün 6 kelime tekrar edilecek.")

        let tomorrow = ProgressText.rectangular(cases["yarin"]!, calendar: calendar)
        XCTAssertEqual(tomorrow.first, ["Sıradaki tekrar: yarın 09:15", "Tekrar: yarın 09:15", "yarın 09:15"])
        XCTAssertEqual(tomorrow.second, ["Bugün tekrar yok"])
        XCTAssertEqual(tomorrow.spoken, "Sıradaki tekrar: yarın 09:15. Bugün tekrar yok.")

        let farther = ProgressText.rectangular(cases["ileri"]!, calendar: calendar)
        XCTAssertEqual(farther.first.first, "Sıradaki tekrar: 26 Ekim 09:00")

        let fresh = ProgressText.rectangular(cases["yeni"]!, calendar: calendar)
        XCTAssertEqual(fresh.first, ["Henüz tekrar yok"])
        XCTAssertEqual(fresh.second, ["Günlük hedef: 5 yeni kelime", "Hedef: 5 yeni kelime", "Hedef: 5 kelime"])
        XCTAssertEqual(fresh.spoken, "Henüz tekrar yok. Günlük hedef 5 yeni kelime.")

        // After a break: never the backlog's size (37 now, 42 today).
        let backlog = ProgressText.rectangular(cases["ara"]!, calendar: calendar)
        XCTAssertEqual(backlog.second, ["Bugün: 10+ kelime"])
        XCTAssertEqual(backlog.spoken, "Tekrar zamanı. Bugün 10'dan fazla kelime tekrar edilecek.")

        let none = ProgressText.rectangular(nil, calendar: calendar)
        XCTAssertEqual(none.first, ["Lockglow"])
        XCTAssertEqual(none.second, ["Uygulamayı bir kez aç"])
    }

    func testInlineLines() {
        let calendar = ProgressWidgetSnapshotTests.istanbul
        let cases = statuses(now: date(10), calendar: calendar)
        XCTAssertEqual(ProgressText.inline(cases["bekliyor"]!, calendar: calendar).versions, ["Tekrar zamanı"])
        XCTAssertEqual(ProgressText.inline(cases["sirada"]!, calendar: calendar).spoken, "Sıradaki tekrar: bugün 21:40.")
        XCTAssertEqual(ProgressText.inline(cases["yarin"]!, calendar: calendar).versions.first, "Sıradaki tekrar: yarın 09:15")
        XCTAssertEqual(ProgressText.inline(cases["yeni"]!, calendar: calendar).versions.first, "Günlük hedef: 5 yeni kelime")
        XCTAssertEqual(ProgressText.inline(nil, calendar: calendar).versions, ["Lockglow"])

        // A new user who already met some new words today: the visible counter, words for VoiceOver.
        let started = ProgressStatus(date: date(10), dailyGoal: 5, newWordsToday: 3, dueNow: 0, dueToday: 0, nextDue: nil)
        let line = ProgressText.inline(started, calendar: calendar)
        XCTAssertEqual(line.versions, ["Günlük hedef: 3 / 5", "Hedef: 3 / 5"])
        XCTAssertEqual(line.spoken, "Günlük hedef 5 yeni kelime. Bugün 3 tanesini çalıştın.")
        let met = ProgressStatus(date: date(10), dailyGoal: 5, newWordsToday: 6, dueNow: 0, dueToday: 0, nextDue: nil)
        XCTAssertEqual(ProgressText.inline(met, calendar: calendar).versions, ["Bugünlük tamam"])
        let noGoal = ProgressStatus(date: date(10), dailyGoal: 0, newWordsToday: 0, dueNow: 0, dueToday: 0, nextDue: nil)
        XCTAssertEqual(ProgressText.inline(noGoal, calendar: calendar).versions, ["Henüz tekrar yok"])
    }

    func testGoalRingWords() {
        let calendar = ProgressWidgetSnapshotTests.istanbul
        let cases = statuses(now: date(10), calendar: calendar)
        XCTAssertEqual(ProgressText.goalSpoken(cases["sirada"]!), "Günlük hedef 5 yeni kelime. Bugün 3 tanesini çalıştın.")
        // No "0 tanesini" before the first word.
        XCTAssertEqual(ProgressText.goalSpoken(cases["yeni"]!), "Günlük hedef 5 yeni kelime.")
        XCTAssertEqual(ProgressText.goalSymbol(cases["sirada"]!), "character.book.closed")
        XCTAssertEqual(ProgressText.goalSymbol(cases["yarin"]!), "checkmark")
        XCTAssertEqual(ProgressText.goalSymbol(nil), "character.book.closed")
        XCTAssertNotNil(UIImage(systemName: "character.book.closed"))
        XCTAssertNotNil(UIImage(systemName: "checkmark"))
    }

    /// The tone rules over every state: no exclamation mark, no "…", no suffix after a number or a
    /// time on screen, no "/" read aloud, no number above 10 except times and dates.
    func testCalmWordsInEveryState() {
        let calendar = ProgressWidgetSnapshotTests.istanbul
        let all: [ProgressStatus?] = Array(statuses(now: date(10), calendar: calendar).values) + [nil]
        for status in all {
            let rows = ProgressText.rectangular(status, calendar: calendar)
            let line = ProgressText.inline(status, calendar: calendar)
            let shown = rows.first + rows.second + line.versions
            let spoken = [rows.spoken, line.spoken, ProgressText.goalSpoken(status)]
            for text in shown + spoken {
                XCTAssertFalse(text.contains("!"), text)
                XCTAssertFalse(text.contains("…"), text)
                XCTAssertFalse(text.contains("37") || text.contains("42"), text)
            }
            for text in shown {
                XCTAssertFalse(text.contains("'"), text)
            }
            for text in spoken {
                XCTAssertFalse(text.contains("/"), text)
            }
        }
    }

    // MARK: Timeline

    func testEntriesFollowTheSnapshot() throws {
        let calendar = ProgressWidgetSnapshotTests.istanbul
        let snapshot = ProgressSnapshot(
            writtenAt: date(10),
            dailyGoal: 5,
            newWordsToday: 3,
            dueDates: [date(21, 40), date(11, days: 1)]
        )
        let entries = ProgressProvider.makeEntries(snapshot: snapshot, now: date(10), calendar: calendar)
        XCTAssertEqual(entries.map(\.date), [date(10), date(21, 40), date(0, days: 1), date(0, days: 2)])
        let first = try XCTUnwrap(entries.first?.status)
        XCTAssertEqual(first.dueNow, 0)
        XCTAssertEqual(first.nextDue, date(21, 40))
        XCTAssertEqual(first.newWordsToday, 3)
        XCTAssertEqual(entries[1].status?.dueNow, 1)
        // A new day: today's new words start again; yesterday's review is still waiting.
        XCTAssertEqual(entries[2].status?.newWordsToday, 0)
        XCTAssertEqual(entries[2].status?.dueToday, 2)

        let empty = ProgressProvider.makeEntries(snapshot: nil, now: date(10), calendar: calendar)
        XCTAssertEqual(empty.count, 1)
        XCTAssertNil(empty.first?.status)
        XCTAssertLessThanOrEqual(entries.count, ProgressProvider.maxEntries)
    }

    // MARK: Images

    private enum Kind {
        case circular
        case rectangular
        case inline
    }

    private struct Family {
        let name: String
        let kind: Kind
        let size: CGSize
        /// Also rendered at larger text sizes: the SE sizes.
        var textSizes = false
    }

    // Point sizes from the HIG widget size table: a 393 pt wide iPhone and the 375 x 667 pt SE.
    private let families = [
        Family(name: "daire", kind: .circular, size: CGSize(width: 72, height: 72)),
        Family(name: "daire-se", kind: .circular, size: CGSize(width: 68, height: 68), textSizes: true),
        Family(name: "rect", kind: .rectangular, size: CGSize(width: 160, height: 72)),
        Family(name: "rect-se", kind: .rectangular, size: CGSize(width: 153, height: 68), textSizes: true),
        Family(name: "inline", kind: .inline, size: CGSize(width: 234, height: 26)),
        Family(name: "inline-se", kind: .inline, size: CGSize(width: 225, height: 26), textSizes: true),
    ]

    private let textSizes: [(suffix: String, size: DynamicTypeSize)] = [
        ("-xxxl", .xxxLarge),
        ("-ax1", .accessibility1),
        ("-ax3", .accessibility3),
    ]

    func testRenderProgressFamilies() {
        // The simulator's own time zone, as on a device: the images show "21:40" wherever CI runs.
        let calendar = Calendar.current
        let now = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date(timeIntervalSince1970: 1_800_000_000))!
        var cases = statuses(now: now, calendar: calendar).map { ($0.key, Optional($0.value)) }
        cases.append(("veri-yok", nil))
        for (name, status) in cases.sorted(by: { $0.0 < $1.0 }) {
            let entry = ProgressEntry(date: now, status: status)
            for family in families {
                render(family: family, entry: entry, calendar: calendar, name: "ilerleme-\(family.name)-\(name)")
                if family.kind != .inline {
                    render(family: family, entry: entry, calendar: calendar, luminanceReduced: true,
                           name: "ilerleme-\(family.name)-\(name)-aod")
                }
                if family.textSizes {
                    for textSize in textSizes {
                        render(family: family, entry: entry, calendar: calendar, dynamicTypeSize: textSize.size,
                               name: "ilerleme-\(family.name)-\(name)\(textSize.suffix)")
                    }
                }
            }
        }
    }

    // MARK: Helpers

    /// One status per state, at `now`: a review due ("bekliyor"), the next one later today
    /// ("sirada"), tomorrow with the goal met ("yarin"), in three days ("ileri"), a new user
    /// ("yeni") and a long break ("ara").
    private func statuses(now: Date, calendar: Calendar) -> [String: ProgressStatus] {
        func at(_ hour: Int, _ minute: Int, days: Int) -> Date {
            let day = calendar.date(byAdding: .day, value: days, to: now)!
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
        }
        return [
            "bekliyor": ProgressStatus(date: now, dailyGoal: 5, newWordsToday: 3, dueNow: 4, dueToday: 6, nextDue: at(21, 40, days: 0)),
            "sirada": ProgressStatus(date: now, dailyGoal: 5, newWordsToday: 3, dueNow: 0, dueToday: 6, nextDue: at(21, 40, days: 0)),
            "yarin": ProgressStatus(date: now, dailyGoal: 10, newWordsToday: 10, dueNow: 0, dueToday: 0, nextDue: at(9, 15, days: 1)),
            "ileri": ProgressStatus(date: now, dailyGoal: 5, newWordsToday: 1, dueNow: 0, dueToday: 0, nextDue: at(9, 0, days: 3)),
            "yeni": ProgressStatus(date: now, dailyGoal: 5, newWordsToday: 0, dueNow: 0, dueToday: 0, nextDue: nil),
            "ara": ProgressStatus(date: now, dailyGoal: 5, newWordsToday: 1, dueNow: 37, dueToday: 42, nextDue: nil),
        ]
    }

    @ViewBuilder
    private func view(for family: Family, entry: ProgressEntry, calendar: Calendar) -> some View {
        switch family.kind {
        case .circular:
            ProgressCircularView(entry: entry)
        case .rectangular:
            ProgressRectangularView(entry: entry, calendar: calendar)
        case .inline:
            ProgressInlineView(entry: entry, calendar: calendar)
        }
    }

    private func render(
        family: Family,
        entry: ProgressEntry,
        calendar: Calendar,
        luminanceReduced: Bool = false,
        dynamicTypeSize: DynamicTypeSize = .large,
        name: String
    ) {
        let content = view(for: family, entry: entry, calendar: calendar)
            .frame(width: family.size.width, height: family.size.height)
            .background {
                // The wallpaper: the system draws no plate on the Lock Screen.
                Color(white: luminanceReduced ? 0.04 : 0.16)
            }
            .clipShape(RoundedRectangle(cornerRadius: family.kind == .circular ? family.size.width / 2 : 8, style: .continuous))
            .environment(\.colorScheme, .dark)
            .environment(\.dynamicTypeSize, dynamicTypeSize)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        guard let image = renderer.uiImage else {
            XCTFail("could not render \(name)")
            return
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
