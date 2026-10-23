import SwiftUI
import UniformTypeIdentifiers
import UserNotifications
import Learning

/// "Verilerin" (Ayarlar, İlerleme): a copy of everything to share (`ShareLink`), a backup from
/// another phone to join this one, and "Hepsini sil". The work is in AppModel+DataControls.swift;
/// the formats and rules are in Learning (DataExport, DataImport, DataErase).
struct DataControlsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    /// The files of the last export, ready for the share sheet; nil until written.
    @State private var exported: (backup: URL, tables: [URL])?
    @State private var exportFailed = false
    @State private var showsImporter = false
    /// The backup picked, read and checked, waiting for "İçe aktar".
    @State private var pending: PendingImport?
    @State private var importMessage: String?
    @State private var showsEraseConfirmation = false
    @State private var eraseFailed = false

    private struct PendingImport: Identifiable {
        let id = UUID()
        let reading: DataArchive.Reading
        let summary: DataImport.Summary
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Verilerin bu telefonda durur. iCloud ile eşitle açıksa iCloud hesabında da durur. Buradan bir kopyasını alabilir, başka telefona taşıyabilir ya da hepsini silebilirsin.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                exportSection
                importSection
                eraseSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Verilerin")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            prepareExport()
        }
        // The copies in the temporary folder go when the page closes (the share sheet keeps it open).
        .onDisappear {
            try? FileManager.default.removeItem(at: AppModel.exportFolder)
        }
        .fileImporter(isPresented: $showsImporter, allowedContentTypes: [.json]) { result in
            picked(result)
        }
        .sheet(item: $pending) { item in
            ImportConfirmationSheet(summary: item.summary) {
                pending = nil
                runImport(item.reading)
            } cancel: {
                pending = nil
            }
        }
        .alert("Bütün veriler silinsin mi?", isPresented: $showsEraseConfirmation) {
            Button("Hepsini sil", role: .destructive) {
                eraseAll()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("İlerlemen, bildiğin kelimeler, kendi eklediğin kelimeler, ayarların, ölçümler ve yedek kopyalar bu telefondan silinir. Uygulama ilk günkü gibi açılır. Bu işlem geri alınamaz.")
        }
    }

    // MARK: Export

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Dışa aktar")
            if let files = exported {
                SettingsGroup {
                    ShareLink(item: files.backup) {
                        SettingsRow("Yedek dosyasını paylaş", systemImage: "square.and.arrow.up", showsChevron: false) {
                            EmptyView()
                        }
                    }
                    .buttonStyle(SettingsRowButtonStyle())
                    SettingsDivider()
                    ShareLink(items: files.tables) {
                        SettingsRow("Tablo dosyalarını paylaş", systemImage: "tablecells", showsChevron: false) {
                            EmptyView()
                        }
                    }
                    .buttonStyle(SettingsRowButtonStyle())
                }
            } else if exportFailed {
                Text("Dosyalar şu an hazırlanamadı. Biraz sonra bu sayfayı yeniden aç.")
                    .settingsFootnote()
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
            Text("Dosyaya ilerlemen, cevap geçmişin, bildiğin kelimeler, kendi kelimelerin, ölçümler, ayarların ve son aramaların yazılır. Dosyayı nereye göndereceğini sen seçersin. Yeni telefona taşımak için yedek dosyasını kullan. Tablo dosyaları Numbers ya da Excel'de açılır.")
                .settingsFootnote()
        }
    }

    private func prepareExport() {
        do {
            exported = try model.writeExportFiles()
            exportFailed = false
        } catch {
            exported = nil
            exportFailed = true
        }
    }

    // MARK: Import

    private var importSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("İçe aktar")
            SettingsGroup {
                Button {
                    importMessage = nil
                    showsImporter = true
                } label: {
                    SettingsRow("Yedek dosyası seç", systemImage: "square.and.arrow.down", showsChevron: false) {
                        EmptyView()
                    }
                }
                .buttonStyle(SettingsRowButtonStyle())
            }
            if let message = importMessage {
                Text(verbatim: message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
            }
            Text("Başka telefondan aldığın yedek dosyasını seç. İkisi birleşir. Bir kelime iki yerde de varsa daha çok cevap verdiğin kayıt kalır. Ayarlar ve ölçümler bu telefondaki gibi kalır.")
                .settingsFootnote()
        }
    }

    private func picked(_ result: Result<URL, Error>) {
        guard case let .success(url) = result else {
            return
        }
        do {
            let reading = try AppModel.readBackup(at: url)
            guard let summary = model.importSummary(reading) else {
                show(DataImportFailure.notReady.message)
                return
            }
            if summary.isEmpty {
                show("Bu yedekte alınacak bir şey yok.")
                return
            }
            pending = PendingImport(reading: reading, summary: summary)
        } catch let failure as DataImportFailure {
            show(failure.message)
        } catch {
            show(DataImportFailure.unreadable.message)
        }
    }

    private func runImport(_ reading: DataArchive.Reading) {
        switch model.importData(reading) {
        case let .success(summary):
            if summary.changesNothing {
                show("Bu yedekteki her şey bu telefonda zaten var.")
            } else {
                show("İçe aktarma bitti. Yeni ya da güncellenen kelime: \(summary.wordsAdded + summary.wordsReplaced). Yeni kendi kelime: \(summary.customWordsAdded).")
            }
            prepareExport()
        case let .failure(failure):
            show(failure.message)
        }
    }

    private func show(_ message: String) {
        importMessage = message
        AccessibilityNotification.Announcement(AttributedString(message)).post()
    }

    // MARK: Erase

    private var eraseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Hepsini sil")
            Text("Bu telefondaki bütün Lockglow verisini siler: ilerleme, kendi kelimelerin, ayarlar, ölçümler ve yedek kopyalar. İlerlemeyi sıfırla bunlardan yalnız ilerlemeyi siler. İlerlemeni saklamak istersen önce yedek dosyasını paylaş.")
                .settingsFootnote()
            Text("iCloud'daki kopya ve telefonun eski yedekleri bundan etkilenmez. iCloud'daki kopyayı iCloud ile eşitle sayfasından silebilirsin.")
                .settingsFootnote()
            Button(role: .destructive) {
                showsEraseConfirmation = true
            } label: {
                Label("Hepsini sil", systemImage: "trash")
                    .foregroundStyle(Theme.bad)
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
            .padding(.top, 8)
            if eraseFailed {
                Text("Bazı dosyalar silinemedi. Hepsini sil düğmesine yeniden dokun.")
                    .settingsFootnote()
            }
        }
    }

    private func eraseAll() {
        let failed = model.eraseAllLocalData()
        // A "Tekrar" round on the Lock Screen ends too.
        ReviewLiveActivity.shared.roundChanged(to: nil)
        ReviewLiveActivity.shared.endLeftovers()
        // Reminders already planned or on screen go too.
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        if !failed.isEmpty {
            eraseFailed = true
            AccessibilityNotification.Announcement(AttributedString("Bazı dosyalar silinemedi.")).post()
            return
        }
        AccessibilityNotification.Announcement(AttributedString("Bütün veriler silindi.")).post()
        dismiss()
    }
}

/// What importing the picked backup would do, then "İçe aktar" or "Vazgeç".
private struct ImportConfirmationSheet: View {
    let summary: DataImport.Summary
    let confirm: () -> Void
    let cancel: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let date = summary.exportedAt {
                        Text(verbatim: "Yedeğin tarihi: \(date.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "tr_TR"))))")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                    }
                    ForEach(summary.lines, id: \.self) { line in
                        Text(verbatim: line)
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text("Bu telefondaki kelimelerin kalır. İki yerde de olan kelimede daha çok cevaplı kayıt seçilir.")
                        .settingsFootnote()
                        .padding(.top, 4)
                    Button("İçe aktar", action: confirm)
                        .buttonStyle(PrimaryCapsuleButtonStyle())
                        .padding(.top, 8)
                        .disabled(summary.changesNothing)
                    if summary.changesNothing {
                        Text("Bu yedekteki her şey bu telefonda zaten var.")
                            .settingsFootnote()
                    }
                }
                .padding(16)
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Yedeği içe aktar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç", action: cancel)
                }
            }
        }
    }
}
