import SwiftUI
import Learning

/// The "Alıştırma" group of Ayarlar: one row to "Kulak alıştırması". SettingsView shows it with a
/// single line, so the whole entry lives here.
struct EarTrainingSettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Alıştırma")
            SettingsGroup {
                NavigationLink {
                    EarTrainingView()
                } label: {
                    SettingsRow("Kulak alıştırması", systemImage: "ear")
                }
                .buttonStyle(SettingsRowButtonStyle())
            }
            Text("Birbirine benzeyen İngilizce sesleri dinleyip ayırırsın. Tekrar'daki kelimelerini etkilemez.")
                .settingsFootnote()
        }
    }
}

/// What a round is asked for: mixed (`focus` nil) or one sound pair. A new id every time, so
/// the same choice twice starts a new round.
struct EarTrainingRoundRequest: Hashable, Identifiable {
    let id = UUID()
    let focus: String?
}

/// "Kulak alıştırması": what the mode does, a mixed round of 10 questions, and the sound pairs
/// (each opens a round of its own) with their calm counter line ("Son 10 soruda 7 tanesini
/// ayırdın."). No percentage, no streak, no score (learning principles 2.5). The counter can be
/// reset here; it is not part of "İlerlemeyi sıfırla" and never touches the Leitner progress.
struct EarTrainingView: View {
    @StateObject private var model = EarTrainingModel()
    @State private var request: EarTrainingRoundRequest?
    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                intro
                if model.loadFailed {
                    Text("Kulak alıştırması şu an açılamadı. Uygulamayı güncelleyince düzelir.")
                        .font(.body)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    startSection
                    groupsSection
                    resetSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Kulak alıştırması")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(item: $request) { request in
            EarTrainingRoundView(model: model, focus: request.focus)
        }
        .confirmationDialog(
            "Sayaçlar sıfırlansın mı?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sayaçları sıfırla", role: .destructive) {
                model.resetTally()
                AccessibilityNotification.Announcement(AttributedString("Sayaçlar sıfırlandı.")).post()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Ses çiftlerinin sayaçları silinir. Kelimelerin ve Tekrar etkilenmez.")
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Telefon bir kelime okur. İki kelimeden hangisini duyduğunu seç.")
                .font(.body)
                .foregroundStyle(Theme.ink)
            // Subheadline like the pair names below: three sizes on the page (body, subheadline,
            // footnote), Apple's type scale.
            Text("Sonra ağzın ve dilin o sesleri nasıl çıkardığını okursun.")
                .font(.subheadline)
                .foregroundStyle(Theme.ink2)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var startSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                request = EarTrainingRoundRequest(focus: nil)
            } label: {
                Text("Karışık tur (\(EarTrainingRound.questionCount) soru)")
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            Text("Karışık turda sık karıştırdığın sesler daha çok gelir.")
                .settingsFootnote()
        }
    }

    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Ses çiftleri")
            SettingsGroup {
                ForEach(Array(model.groups.enumerated()), id: \.element.id) { index, group in
                    if index > 0 {
                        SettingsDivider()
                    }
                    groupRow(group)
                }
            }
            Text("Bir çifte dokununca yalnız o seslerden \(EarTrainingRound.questionCount) soru gelir.")
                .settingsFootnote()
        }
    }

    /// The pair's best-known words in serif (they are English), its Turkish name and the
    /// counter line: an iOS list row (body title, subheadline and footnote under it, 16 pt
    /// inset like `SettingsRow`). VoiceOver: the English words are an element of their own in an
    /// English voice (a button merges its texts into one voice), the Turkish part a second element.
    private func groupRow(_ group: EarTrainingGroup) -> some View {
        let line = model.tally.line(for: group.id) ?? "Henüz dinlemedin."
        return Button {
            request = EarTrainingRoundRequest(focus: group.id)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: group.title)
                        .font(Theme.Fonts.example.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    Text(verbatim: group.nameTR)
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink2)
                    Text(verbatim: line)
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink3)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsRowButtonStyle())
        .accessibilityRepresentation {
            Button {
                request = EarTrainingRoundRequest(focus: group.id)
            } label: {
                Text(verbatim: group.title)
                    .englishVoice()
            }
            Text(verbatim: "\(group.nameTR). \(line)")
        }
    }

    @ViewBuilder
    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !model.tally.isEmpty {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Sayaçları sıfırla", systemImage: "arrow.counterclockwise")
                        .foregroundStyle(Theme.bad)
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
            }
            Text("Sayaçlar yalnız bu telefonda tutulur.")
                .settingsFootnote()
        }
    }
}
