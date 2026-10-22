import SwiftUI
import Learning
import Pronunciation

/// The developer parts of "Widget sağlığı": "Yerel ölçüm" and "Söyle tanılama" (which also stops
/// recording when off). Before the App Store release set `showsInRelease` to false: they then
/// exist only in Debug builds (`#if DEBUG`, Xcode). TestFlight builds are Release builds, so it
/// stays true while testing on the phone. The measurements themselves (`LocalMetricsRecorder`)
/// are always kept.
enum DiagnosticsSwitch {
    static let showsInRelease = true

    static var isOn: Bool {
        #if DEBUG
        return true
        #else
        return showsInRelease
        #endif
    }
}

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
    @ObservedObject private var sayDiagnostics = SayDiagnostics.shared
    @State private var showsTechnicalDetails = false
    @State private var showsMetrics = false
    @State private var showsSayDiagnostics = false

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
                if DiagnosticsSwitch.isOn {
                    VStack(alignment: .leading, spacing: 10) {
                        SettingsSectionHeader("Tanılama")
                        metricsSection
                        sayDiagnosticsSection
                    }
                }
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
                HealthValueRow(title: "Widget'ta bekleyen dokunuş", value: "\(health.pendingEventCount)")
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

    /// The card above changes in place, so VoiceOver hears the new verdict once the check is done.
    private var refreshButton: some View {
        Button {
            model.refreshWidgetPlan()
            Task {
                await model.refreshHealth()
                let verdict = WidgetHealthCard.title(of: WidgetHealthStatus(of: model))
                AccessibilityNotification.Announcement(AttributedString("Widget'lar yenilendi. " + verdict)).post()
            }
        } label: {
            Label("Widget'ları yenile", systemImage: "arrow.triangle.2.circlepath")
        }
    }

    /// The same guide as "Widget nasıl eklenir?" in Ayarlar and the onboarding.
    private var guideLink: some View {
        NavigationLink {
            WidgetGuideScreen(word: model.widgetGuideWord)
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
                TechnicalRow(title: "Kelime sayısı", value: "\(model.cardCount)")
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

    /// "Yerel ölçüm" (docs/tasarim/ogrenme_ilkeleri.md §2.13): the last 28 days on this phone and
    /// the first acceptance targets, in words ("tuttu" / "tutmadı"), not color alone.
    private var metricsSection: some View {
        DisclosureGroup(isExpanded: $showsMetrics) {
            let report = LocalMetricsRecorder.shared.report(dailyNewWords: model.dailyNewWords)
            VStack(alignment: .leading, spacing: 0) {
                TechnicalRow(title: "Çalışılan gün", value: "\(report.studyDays) / \(report.windowDays)")
                TechnicalRow(title: "Günlük soru (ortanca)", value: Self.number(report.medianDailyAnswers))
                TechnicalRow(title: "İlk denemede doğru", value: Self.share(report.firstTryCorrectRate, count: report.firstTryAnswers))
                TechnicalRow(title: "Soru başına süre", value: report.meanSecondsPerAnswer.map { Self.number($0) + " sn" } ?? "yok")
                TechnicalRow(title: "Tur süresi (ortanca)", value: report.medianRoundMinutes.map { Self.number($0) + " dk" } ?? "yok")
                TechnicalRow(title: "Kutular 1–5", value: Self.boxes(report.boxes))
                TechnicalRow(
                    title: "Hatırlatma açılma",
                    value: report.reminderOpenRate.map { Self.percent($0) + " (\(report.remindersOpened)/\(report.remindersFired))" } ?? "yok"
                )
                TechnicalRow(title: "Görmezden gelinen hatırlatma", value: "\(report.remindersIgnored)")
                Text("Kabul hedefleri")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .padding(.top, 14)
                    .padding(.bottom, 2)
                    .accessibilityAddTraits(.isHeader)
                ForEach(report.acceptance, id: \.goal) { check in
                    TechnicalRow(title: Self.title(of: check.goal), value: Self.verdict(of: check))
                }
                Text("Yalnız bu telefonda kalır, hiçbir yere gönderilmez. Hedefler ilk eşikler; ölçüldükçe ayarlanır.")
                    .settingsFootnote()
                    .padding(.top, 10)
            }
            .padding(.top, 4)
            .padding(.bottom, 12)
        } label: {
            Text("Yerel ölçüm")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
    }

    /// "Söyle tanılama": the last 20 Söyle takes (README "Söyle: bilinen belirsizlikler" 1 and 4),
    /// a short summary first. Never what was said.
    private var sayDiagnosticsSection: some View {
        DisclosureGroup(isExpanded: $showsSayDiagnostics) {
            let attempts = sayDiagnostics.attempts
            VStack(alignment: .leading, spacing: 0) {
                if attempts.isEmpty {
                    Text("Henüz deneme yok. Söyle sayfasında birkaç kez dene; son 20 deneme burada görünür.")
                        .settingsFootnote()
                        .padding(.vertical, 8)
                } else {
                    let confidences = attempts.compactMap(\.confidence)
                    TechnicalRow(title: "Motor", value: attempts[0].engine.rawValue)
                    TechnicalRow(title: "Güven değeri gelen", value: "\(confidences.count) / \(attempts.count)")
                    TechnicalRow(
                        title: "Güven aralığı",
                        value: confidences.isEmpty ? "yok" : Self.decimal(confidences.min() ?? 0) + " – " + Self.decimal(confidences.max() ?? 0)
                    )
                    TechnicalRow(title: "Aday sayısı (en çok)", value: "\(attempts.map(\.candidates).max() ?? 0)")
                    TechnicalRow(title: "\"Neredeyse\" güven sınırı", value: Self.decimal(PronunciationCheck.lowConfidence))
                    ForEach(attempts) { attempt in
                        SayAttemptRow(attempt: attempt)
                    }
                    Button("Listeyi temizle") {
                        sayDiagnostics.clear()
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
                    .padding(.top, 14)
                }
                Text("Yalnız bellekte, bu telefonda tutulur; uygulama kapanınca silinir. Söylediğin şey kaydedilmez.")
                    .settingsFootnote()
                    .padding(.top, 10)
            }
            .padding(.top, 4)
            .padding(.bottom, 12)
        } label: {
            Text("Söyle tanılama")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
    }

    // MARK: Measurement values

    private static func title(of goal: AcceptanceCheck.Goal) -> String {
        switch goal {
        case .dailyMinutes: return "Günlük süre (ortanca)"
        case .tapsPerNewWord: return "Yeni kelime başına dokunma"
        case .earlyEndRate: return "Bitir ile biten tur"
        case .knownCheckFailRate: return "Biliyorum, kontrolde bilinmedi"
        }
    }

    /// "8 dk · hedef en çok 7 · tutmadı", or how many samples are still missing.
    private static func verdict(of check: AcceptanceCheck) -> String {
        let value: String
        let limit: String
        switch check.goal {
        case .dailyMinutes:
            value = check.value.map { number($0) + " dk" } ?? "yok"
            limit = "en çok " + number(check.limit) + " dk"
        case .tapsPerNewWord:
            value = check.value.map { number($0) } ?? "yok"
            limit = "en çok " + number(check.limit)
        case .earlyEndRate:
            value = check.value.map { percent($0) } ?? "yok"
            limit = percent(check.limit) + " altı"
        case .knownCheckFailRate:
            value = check.value.map { percent($0) } ?? "yok"
            limit = "en çok " + percent(check.limit)
        }
        let status: String
        switch check.status {
        case .met: status = "✓ tuttu"
        case .missed: status = "✗ tutmadı"
        case .tooFewSamples: status = "az veri (\(check.samples))"
        }
        return "\(value) · hedef \(limit) · \(status)"
    }

    private static func boxes(_ counts: BoxCounts?) -> String {
        guard let counts else {
            return "yok"
        }
        let known = counts.graduated + counts.markedKnown
        return counts.boxes.map { String($0) }.joined(separator: " · ") + " · bilinen \(known)"
    }

    private static func share(_ rate: Double?, count: Int) -> String {
        guard let rate else {
            return "yok"
        }
        return percent(rate) + " (\(count) soru)"
    }

    /// Up to one decimal, in the phone's language ("7,5").
    private static func number(_ value: Double?) -> String {
        guard let value else {
            return "yok"
        }
        return value.formatted(.number.precision(.fractionLength(0...1)))
    }

    private static func decimal(_ value: Double) -> String {
        return value.formatted(.number.precision(.fractionLength(2)))
    }

    private static func percent(_ value: Double) -> String {
        return value.formatted(.percent.precision(.fractionLength(0)))
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
    /// The icon circle grows with the symbol's text style, so the symbol never leaves it.
    @ScaledMetric(relativeTo: .title3) private var circleSize: CGFloat = 44

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3.weight(.bold))
                .foregroundStyle(symbolColor)
                .frame(width: circleSize, height: circleSize)
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
        return WidgetHealthCard.title(of: status)
    }

    /// The card's first line; also what "Widget'ları yenile" announces.
    static func title(of status: WidgetHealthStatus) -> String {
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
            parts.append("Widget'ları yenile düğmesine dokun. Düzelmezse widget'ı kaldırıp yeniden ekle.")
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

/// One raw value under "Teknik bilgiler" (mockup `details.tech .r`). At accessibility sizes the
/// value goes under the title, so neither is squeezed into a narrow column.
private struct TechnicalRow: View {
    let title: String
    let value: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            content
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

    @ViewBuilder
    private var content: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: title)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(verbatim: value)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(verbatim: title)
                    .foregroundStyle(Theme.ink)
                Spacer(minLength: 8)
                Text(verbatim: value)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

/// One take under "Söyle tanılama": when, what was to be said (its length only) and the result,
/// then the numbers the recognizer gave.
private struct SayAttemptRow: View {
    let attempt: SayDiagnostics.Attempt

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: headline)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text(verbatim: details)
                    .font(.caption)
                    .foregroundStyle(Theme.ink2)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            Rectangle()
                .fill(Theme.line)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }

    /// "14:32:05 · tek kelime · Neredeyse"
    private var headline: String {
        let time = attempt.date.formatted(date: .omitted, time: .standard)
        let target = attempt.targetWords > 1 ? "\(attempt.targetWords) kelimelik hedef" : "tek kelime"
        return "\(time) · \(target) · \(outcome)"
    }

    /// "aday 3 · güven 0,82 · dinleme 2,1 sn · indirme 12,0 sn · hata kAFAssistantErrorDomain 1110"
    private var details: String {
        var parts = ["aday \(attempt.candidates)"]
        parts.append("güven " + (attempt.confidence.map { $0.formatted(.number.precision(.fractionLength(2))) } ?? "yok"))
        if let seconds = attempt.listeningSeconds {
            parts.append("dinleme " + seconds.formatted(.number.precision(.fractionLength(1))) + " sn")
        }
        if let seconds = attempt.modelDownloadSeconds {
            parts.append("indirme " + seconds.formatted(.number.precision(.fractionLength(1))) + " sn")
        }
        if let code = attempt.errorCode {
            parts.append("hata " + code)
        }
        return parts.joined(separator: " · ")
    }

    private var outcome: String {
        switch attempt.outcome {
        case .verdict(let verdict):
            switch verdict {
            case .correct: return "Doğru"
            case .almost: return "Neredeyse"
            case .tryAgain: return "Bir daha dene"
            case .notHeard: return "Duyulmadı"
            }
        case .failed(let problem):
            switch problem {
            case .microphoneDenied: return "Mikrofon izni yok"
            case .speechDenied: return "Tanıma izni yok"
            case .speechRestricted: return "Tanıma kısıtlı"
            case .modelUnavailable: return "Model yok"
            case .onDeviceUnavailable: return "Cihaz içi tanıma yok"
            case .audioFailed: return "Mikrofon başlamadı"
            case .recognitionFailed: return "Tanıma hatası"
            }
        case .cancelled:
            return "Yarıda kaldı"
        }
    }
}
