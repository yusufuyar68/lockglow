import SwiftUI

extension WidgetHealthStatus {
    /// The verdict on the model's last health check, as "Ayarlar" and "Widget sağlığı" show it.
    @MainActor
    init(of model: AppModel) {
        self.init(
            model.health,
            isLoading: model.contentSource == .loading,
            emptyListIsReliable: WidgetProbe.emptyListIsReliable
        )
    }
}

/// "Widget sağlığı" (mockup `st-health`): one sentence on top, the placed widgets and the shared
/// state, one main action, and the raw values for the widget spike tests under "Teknik bilgiler".
/// The main action follows the verdict: "Widget nasıl eklenir?" when no widget is placed,
/// otherwise "Widget'ları yenile". Pushed from "Ayarlar" (it has no NavigationStack of its own).
struct WidgetHealthView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showsTechnicalDetails = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                WidgetHealthCard(status: status, problem: health.planProblem, lastUpdate: health.planUpdatedAt)
                // With no widget listed the card above already says so.
                if !health.instances.isEmpty {
                    widgetsSection
                }
                stateSection
                actionsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            // Room above the tab bar for the last row.
            .padding(.bottom, 40)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Widget sağlığı")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await model.refreshHealth()
        }
        .task {
            await model.refreshHealth()
        }
    }

    private var health: WidgetHealthSnapshot {
        return model.health
    }

    private var status: WidgetHealthStatus {
        return WidgetHealthStatus(of: model)
    }

    // MARK: Sections

    private var widgetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Yerleştirilmiş widget'lar")
            SettingsGroup {
                ForEach(Array(health.instances.enumerated()), id: \.offset) { index, instance in
                    if index > 0 {
                        SettingsDivider()
                    }
                    HealthValueRow(title: name(of: instance), value: place(of: instance))
                }
            }
        }
    }

    private var stateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Durum")
            SettingsGroup {
                HealthValueRow(
                    title: "Veri paylaşımı",
                    value: health.appGroupAvailable ? "Açık" : "Kapalı",
                    tone: health.appGroupAvailable ? .good : .bad
                )
                SettingsDivider()
                HealthValueRow(title: "Sıradaki kelime sayısı", value: "\(health.queueSize)")
                SettingsDivider()
                HealthValueRow(title: "Son güncelleme", value: format(health.planUpdatedAt, seconds: false))
                SettingsDivider()
                HealthValueRow(
                    title: "Sonraki değişim",
                    value: health.nextChangeAt.map { $0.formatted(date: .omitted, time: .shortened) } ?? "yok"
                )
                SettingsDivider()
                HealthValueRow(title: "Uygulamaya iletilecek dokunuş", value: "\(health.pendingEventCount)")
            }
        }
    }

    /// The one filled button of the screen, then the technical details with the two narrower
    /// actions. No widget: the guide is the main action (refreshing would change nothing). Not
    /// sure (`unknown`): refresh first, the guide as a bordered capsule under it.
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if status == .notAdded {
                guideLink
                    .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            } else {
                refreshButton
                    .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
                Text("Sırayı yeniden yazar ve widget'lara haber verir. Görünen kelime değişmez.")
                    .settingsFootnote()
                if status == .unknown {
                    guideLink
                        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
                        .padding(.top, 4)
                }
            }
            technicalDetails
                .padding(.top, 8)
        }
    }

    private var refreshButton: some View {
        Button {
            model.refreshWidgetPlan()
            Task {
                await model.refreshHealth()
            }
        } label: {
            Label("Widget'ları yenile", systemImage: "arrow.triangle.2.circlepath")
        }
    }

    /// The same guide as "Ayarlar > Widget nasıl eklenir?" and the onboarding.
    private var guideLink: some View {
        NavigationLink {
            WidgetGuideScreen()
        } label: {
            Label("Widget nasıl eklenir?", systemImage: "plus.circle")
        }
    }

    private var technicalDetails: some View {
        DisclosureGroup(isExpanded: $showsTechnicalDetails) {
            VStack(alignment: .leading, spacing: 0) {
                TechnicalRow(title: "Widget listesi", value: widgetListDescription)
                TechnicalRow(title: "App Group", value: health.appGroupAvailable ? "Erişilebilir" : "Erişilemiyor")
                TechnicalRow(title: "Plan kimliği", value: health.planID.map { String($0.prefix(8)) } ?? "yok")
                TechnicalRow(title: "Plan güncellendi", value: format(health.planUpdatedAt, seconds: true))
                TechnicalRow(title: "Kuyruk boyutu", value: "\(health.queueSize)")
                TechnicalRow(title: "Widget imleci", value: health.cursorOffset.map { String($0) } ?? "yok")
                TechnicalRow(title: "Widget'ta bilinen", value: health.knownCount.map { String($0) } ?? "yok")
                TechnicalRow(title: "Bekleyen olay", value: "\(health.pendingEventCount)")
                TechnicalRow(title: "Son yenileme isteği", value: format(health.lastReloadRequestedAt, seconds: true))
                TechnicalRow(title: "Kaynak", value: sourceDescription)
                TechnicalRow(title: "Kart sayısı", value: "\(model.cardCount)")
                TechnicalRow(title: "İçerik sürümü", value: model.contentVersion ?? "yok")
                VStack(spacing: 8) {
                    Button("Yalnızca zaman çizelgelerini yenile") {
                        model.reloadWidgets()
                        Task {
                            await model.refreshHealth()
                        }
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
                    Button("Durumu yenile") {
                        Task {
                            await model.refreshHealth()
                        }
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
                }
                .padding(.top, 14)
            }
            .padding(.top, 4)
            .padding(.bottom, 12)
        } label: {
            Text("Teknik bilgiler")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
    }

    // MARK: Values

    /// "Kelime · küçük": the widget and its size in the words of the widget guide.
    private func name(of instance: WidgetInstance) -> String {
        // `WordWidget.kind` (the widget target is not linked into the app).
        let widget = instance.kind == "WordWidget" ? "Kelime" : instance.kind
        let size: String
        switch instance.family {
        case "systemSmall": size = "küçük"
        case "systemMedium": size = "orta"
        case "systemLarge": size = "büyük"
        case "accessoryRectangular": size = "dikdörtgen"
        case "accessoryInline": size = "tek satır"
        case "accessoryCircular": size = "yuvarlak"
        default: size = instance.family
        }
        return "\(widget) · \(size)"
    }

    private func place(of instance: WidgetInstance) -> String {
        if instance.family.hasPrefix("accessory") {
            return "Kilitli ekran"
        }
        if instance.family.hasPrefix("system") {
            return "Ana ekran"
        }
        return ""
    }

    /// "2 widget", or why an empty list proves nothing (ios/README point 21).
    private var widgetListDescription: String {
        if WidgetProbe.lastQueryFailed {
            return "alınamadı"
        }
        if health.instances.isEmpty && !WidgetProbe.emptyListIsReliable {
            return "boş (Debug/simülatör)"
        }
        return "\(health.instances.count) widget"
    }

    private var sourceDescription: String {
        switch model.contentSource {
        case .loading: return "Yükleniyor"
        case .database: return "content.sqlite"
        case .seed: return "seed_words.json (yedek)"
        case .empty: return "İçerik yok"
        }
    }

    private func format(_ date: Date?, seconds: Bool) -> String {
        guard let date = date else {
            return "yok"
        }
        return date.formatted(date: .abbreviated, time: seconds ? .standard : .shortened)
    }
}

/// The verdict on top (mockup `.hstat`): an icon in a filled circle, one sentence and what to do.
/// The sentence carries the meaning; the color only repeats it (rule 4). Red only for a placed
/// widget that gets no words; no widget and "not sure" stay calm on `surface`.
private struct WidgetHealthCard: View {
    let status: WidgetHealthStatus
    let problem: WidgetPlanProblem?
    let lastUpdate: Date?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3.weight(.bold))
                .foregroundStyle(symbolColor)
                .frame(width: 44, height: 44)
                .background(Circle().fill(circleColor))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: title)
                    .font(.body.weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(verbatim: detail)
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(panelColor, in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private var title: String {
        switch status {
        case .checking: return "Kontrol ediliyor"
        case .working: return "Her şey yolunda"
        case .notUpdating: return "Widget kelimeleri güncellemiyor"
        case .notAdded: return "Widget ekli değil"
        case .unknown: return "Widget listesi alınamadı"
        }
    }

    private var detail: String {
        switch status {
        case .checking:
            return "Kelimeler yükleniyor."
        case .working:
            return "Uygulama ve widget veri paylaşabiliyor. Kelimeler sırayla değişiyor."
        case .notUpdating:
            var parts: [String] = []
            if let reason = reason {
                parts.append(reason)
            }
            if let date = lastUpdate {
                parts.append("Son güncelleme: \(date.formatted(date: .abbreviated, time: .shortened)).")
            }
            parts.append("\"Widget'ları yenile\"ye dokun; düzelmezse widget'ı kaldırıp yeniden ekle.")
            return parts.joined(separator: " ")
        case .notAdded:
            return "Kelimeler hazır. Widget'ı kilitli ekrana ya da ana ekrana ekleyince kelimeler orada değişir."
        case .unknown:
            return "iPhone eklediğin widget'ları şu an bildirmiyor. Widget'taki kelime değişiyorsa her şey yolunda."
        }
    }

    private var reason: String? {
        switch problem {
        case .noSharedContainer?: return "Uygulama widget'la veri paylaşamıyor."
        case .noPlan?: return "Widget'ın kelime listesi henüz yazılmadı."
        case .emptyQueue?: return "Widget'ın kelime listesi boş."
        case nil: return nil
        }
    }

    private var symbol: String {
        switch status {
        case .checking: return "hourglass"
        case .working: return "checkmark"
        case .notUpdating: return "xmark"
        case .notAdded: return "plus"
        case .unknown: return "questionmark"
        }
    }

    private var circleColor: Color {
        switch status {
        case .working: return Theme.good
        case .notUpdating: return Theme.bad
        case .checking, .notAdded, .unknown: return Theme.surface2
        }
    }

    private var symbolColor: Color {
        switch status {
        case .working, .notUpdating: return Theme.surface
        case .checking, .notAdded, .unknown: return Theme.ink
        }
    }

    private var panelColor: Color {
        switch status {
        case .working: return Theme.goodTint
        case .notUpdating: return Theme.badTint
        case .checking, .notAdded, .unknown: return Theme.surface
        }
    }

    private var borderColor: Color {
        switch status {
        case .working: return Theme.good.opacity(0.35)
        case .notUpdating: return Theme.bad.opacity(0.35)
        case .checking, .notAdded, .unknown: return Theme.line
        }
    }
}

/// A title and a value, no chevron. `good` / `bad` color the value; the word says the same.
private struct HealthValueRow: View {
    enum Tone {
        case plain
        case good
        case bad
    }

    let title: String
    let value: String
    var tone: Tone = .plain

    var body: some View {
        SettingsRow(title, showsChevron: false) {
            Text(verbatim: value)
                .fontWeight(tone == .plain ? .regular : .semibold)
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }

    private var valueColor: Color {
        switch tone {
        case .plain: return Theme.ink2
        case .good: return Theme.good
        case .bad: return Theme.bad
        }
    }
}

/// One raw value under "Teknik bilgiler" (mockup `details.tech .r`).
private struct TechnicalRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(verbatim: title)
                    .foregroundStyle(Theme.ink)
                Spacer(minLength: 8)
                Text(verbatim: value)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.trailing)
            }
            .font(.footnote)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
            Rectangle()
                .fill(Theme.line)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}
