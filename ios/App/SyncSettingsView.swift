import SwiftUI

/// "iCloud ile eşitle" (Ayarlar, İlerleme): the switch (off by default), when it last synced or
/// what went wrong, what is synced, and deleting iCloud's copy
/// (docs/ozellik_planlari/icloud_esitleme.md). Without iCloud in this build (no entitlement yet)
/// the switch cannot be turned on and one calm line says so.
struct SyncSettingsView: View {
    @EnvironmentObject private var model: AppModel
    @ObservedObject var sync: SyncController
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                switchSection
                if sync.isEnabled {
                    statusSection
                }
                aboutSection
                if sync.isAvailable {
                    deleteSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("iCloud ile eşitle")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "iCloud'daki kopya silinsin mi?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("iCloud'daki kopyayı sil", role: .destructive) {
                sync.deleteCloudCopy()
                AccessibilityNotification.Announcement(AttributedString("iCloud'daki kopya silindi.")).post()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Bu telefondaki ilerleme ve kelimeler kalır, eşitleme kapanır. Başka bir cihazda eşitleme açıksa kopya yeniden yüklenir; önce orada kapat.")
        }
    }

    private var enabledBinding: Binding<Bool> {
        return Binding(
            get: { sync.isEnabled },
            set: { sync.setEnabled($0) }
        )
    }

    // MARK: Sections

    private var switchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsGroup {
                Toggle(isOn: enabledBinding) {
                    Text("iCloud ile eşitle")
                        .settingsRowTitle()
                }
                // A switch is on in `good` green, as in iOS (never yellow, never ink).
                .tint(Theme.good)
                .disabled(!sync.isAvailable)
                .settingsRowPadding()
                if let problem = sync.problem {
                    SettingsDivider()
                    ProblemLine(text: problem.message)
                }
            }
            Text(sync.isAvailable
                 ? "Açınca ilerlemen ve kendi kelimelerin iCloud'da saklanır. Aynı Apple hesabını kullanan diğer cihazlarında da aynı olur."
                 : "iCloud ile eşitleme bu sürümde henüz hazır değil.")
                .settingsFootnote()
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Durum")
            SettingsGroup {
                SettingsRow("Son eşitleme", showsChevron: false) {
                    Text(verbatim: sync.lastSyncAt.map { SyncSettingsView.dayAndTime($0) } ?? "Henüz yok")
                }
                SettingsDivider()
                Button {
                    model.syncWithCloud()
                    if sync.problem == nil {
                        AccessibilityNotification.Announcement(AttributedString("Eşitlendi.")).post()
                    }
                } label: {
                    SettingsRow("Şimdi eşitle", systemImage: "arrow.triangle.2.circlepath", showsChevron: false)
                }
                .buttonStyle(SettingsRowButtonStyle())
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Ne eşitlenir?")
            VStack(alignment: .leading, spacing: 10) {
                AboutLine(symbol: "checkmark", text: "Kelimelerdeki ilerlemen: ne zaman gördüğün ve cevapladığın, bildiğin kelimeler.")
                AboutLine(symbol: "checkmark", text: "Kendi eklediğin kelimeler, anlamları, örnekleri ve notları.")
                AboutLine(symbol: "minus", text: "Ayarların, günlük sayıların ve son aramaların eşitlenmez.")
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .settingsGroupBackground()
            Text("Bir kelimeyi iki cihazda cevapladıysan son cevap geçerli olur. Bu bir yedek değil: bir cihazda sildiğin ya da sıfırladığın şey diğerlerinde de gider.")
                .settingsFootnote()
            Text("Bilgiler Apple'ın sunucularında, senin iCloud hesabında durur. Biz bunları göremeyiz.")
                .settingsFootnote()
        }
    }

    /// Apart from the rest and last, like "İlerlemeyi sıfırla": a calm bordered capsule.
    private var deleteSection: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("iCloud'daki kopyayı sil", systemImage: "icloud.slash")
                .foregroundStyle(Theme.bad)
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
        .padding(.top, 8)
    }

    // MARK: Text

    /// "bugün 14:32", "dün 09:15", otherwise "24 Ekim 09:00" (no Turkish suffix after the time).
    static func dayAndTime(_ date: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        let time = clockFormatter.string(from: date)
        if calendar.isDate(date, inSameDayAs: now) {
            return "bugün " + time
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now), calendar.isDate(date, inSameDayAs: yesterday) {
            return "dün " + time
        }
        return dayFormatter.string(from: date) + " " + time
    }

    private static let clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
}

/// "Açık" / "Kapalı" on the "iCloud ile eşitle" row of "Ayarlar"; follows the switch.
struct SyncSwitchValue: View {
    @ObservedObject var sync: SyncController

    var body: some View {
        Text(sync.isEnabled ? "Açık" : "Kapalı")
    }
}

/// Why the last sync could not finish, under the switch: the icon and the sentence together, the
/// color only repeats them.
private struct ProblemLine: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.caution)
                .accessibilityHidden(true)
            Text(verbatim: text)
                .font(.subheadline)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// One line of "Ne eşitlenir?".
private struct AboutLine: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .frame(minWidth: 18)
                .accessibilityHidden(true)
            Text(verbatim: text)
                .font(.subheadline)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
