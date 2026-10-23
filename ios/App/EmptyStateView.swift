import SwiftUI

/// A calm empty screen or list (mockup `.empty`, the look of `WordListEmptyState`): a monochrome
/// illustration in a soft circle, a title, an optional sentence and optional buttons. No yellow
/// (rule 1: yellow is only the word's band), no red, no count and no blame (ogrenme_ilkeleri
/// 2.10): it says what will appear here and, at most, the one step that fills it.
///
///     EmptyStateView("Henüz kendi kelimen yok", illustration: .cards,
///                    message: Text("Eklediğin kelimeler burada görünür.")) {
///         Button("Kelime ekle") { showsAddForm = true }
///             .buttonStyle(PrimaryCapsuleButtonStyle())
///     }
///
///     EmptyStateView("Bu konuda kelime yok", illustration: .symbol("square.stack.3d.up.slash"))
///
/// - The message and the tip are `Text`, so parts can be bold (`WordListEmptyState.message`).
///   The tip is a hint after a light bulb ("Türkçe harfleri yazmasan da bulur").
/// - Buttons are capsules (rule 2); they are at most 360 pt wide. Pass no closure for none: a
///   closure whose buttons are all hidden (`if`) still keeps their 10 pt top margin.
/// - The illustration is hidden from VoiceOver; the title is a header.
/// - Same sizes as `WordListEmptyState`, so it can replace it.
/// - At the largest text sizes it is taller than a short screen: put it in a ScrollView or a
///   List row there.
struct EmptyStateView<Actions: View>: View {
    let title: String
    let illustration: EmptyStateIllustration
    let message: Text?
    let tip: Text?
    let actions: Actions
    @ScaledMetric(relativeTo: .title2) private var circleSize: CGFloat = 76

    init(
        _ title: String,
        illustration: EmptyStateIllustration,
        message: Text? = nil,
        tip: Text? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.illustration = illustration
        self.message = message
        self.tip = tip
        self.actions = actions()
    }

    var body: some View {
        let circle = min(circleSize, 120)
        VStack(spacing: 10) {
            EmptyStateArt(illustration: illustration, size: circle)
                .accessibilityHidden(true)
                .padding(.bottom, 6)
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            if let message = message {
                message
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .lineSpacing(2)
            }
            if let tip = tip {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Image(systemName: "lightbulb")
                        .accessibilityHidden(true)
                    tip
                }
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
                .padding(.top, 8)
            }
            if Actions.self != EmptyView.self {
                VStack(spacing: 10) {
                    actions
                }
                .frame(maxWidth: 360)
                .padding(.top, 10)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 28)
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity)
    }
}

extension EmptyStateView where Actions == EmptyView {
    /// Without buttons.
    init(_ title: String, illustration: EmptyStateIllustration, message: Text? = nil, tip: Text? = nil) {
        self.init(title, illustration: illustration, message: message, tip: tip) {
            EmptyView()
        }
    }
}

/// What an empty state shows above its title: ink2 on a `surface2` circle, never yellow.
enum EmptyStateIllustration {
    /// One SF Symbol.
    case symbol(String)
    /// An SF Symbol with a small second one on a dark disc at its lower right.
    case symbolWithBadge(String, badge: String)
    /// Three word cards, the front one with an empty band and a line: no words here yet.
    case cards

    /// No words in a list yet (your own words, known words).
    static let noWords = EmptyStateIllustration.cards
    /// A search found nothing.
    static let noResults = EmptyStateIllustration.symbol("magnifyingglass")
    /// The words could not be loaded ("Uygulamayı kapatıp yeniden aç"): a calm "try again", no
    /// exclamation mark (ogrenme_ilkeleri: nothing that startles).
    static let loadFailed = EmptyStateIllustration.symbolWithBadge("tray", badge: "arrow.clockwise")
    /// Nothing left to do for now (no answer is waiting).
    static let allDone = EmptyStateIllustration.symbol("checkmark")
}

/// The circle with its symbols or drawing, `size` points wide.
private struct EmptyStateArt: View {
    let illustration: EmptyStateIllustration
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.surface2)
            switch illustration {
            case .symbol(let name):
                symbol(name)
            case let .symbolWithBadge(name, badge):
                symbol(name)
                badgeDisc(badge)
                    .offset(x: size * 0.2, y: size * 0.2)
            case .cards:
                EmptyCardsDrawing(size: size * 0.62)
            }
        }
        .foregroundStyle(Theme.ink2)
        .symbolRenderingMode(.monochrome)
        .frame(width: size, height: size)
    }

    private func symbol(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: size * 0.45))
    }

    /// The badge's symbol is cut out of an ink2 disc; a ring in the circle's own colour keeps it
    /// apart from the symbol underneath.
    private func badgeDisc(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: size * 0.15, weight: .bold))
            .foregroundStyle(Theme.surface2)
            .frame(width: size * 0.3, height: size * 0.3)
            .background(Theme.ink2, in: Circle())
            .padding(size * 0.035)
            .background(Theme.surface2, in: Circle())
    }
}

/// Three word cards fanned out; the front card holds the band's outline (no word on it yet) and a
/// line for its meaning. One stroke colour (the foreground style), cards filled with `surface2`
/// so the ones behind are hidden.
private struct EmptyCardsDrawing: View {
    let size: CGFloat

    var body: some View {
        let line = max(1.5, size * 0.04)
        ZStack {
            card(line: line)
                .rotationEffect(.degrees(-12))
                .offset(x: -size * 0.12, y: size * 0.03)
            card(line: line)
                .rotationEffect(.degrees(9))
                .offset(x: size * 0.12, y: -size * 0.01)
            card(line: line)
                .overlay {
                    VStack(spacing: size * 0.09) {
                        PhosphorBandShape(slant: size * 0.045)
                            .stroke(style: StrokeStyle(lineWidth: line, lineJoin: .round))
                            .frame(width: size * 0.36, height: size * 0.12)
                        Capsule()
                            .frame(width: size * 0.24, height: line)
                    }
                    .offset(y: -size * 0.02)
                }
        }
        .frame(width: size, height: size)
    }

    private func card(line: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.09, style: .continuous)
        return shape
            .fill(Theme.surface2)
            .overlay(shape.strokeBorder(lineWidth: line))
            .frame(width: size * 0.56, height: size * 0.76)
    }
}

#Preview("Boş durumlar") {
    ScrollView {
        VStack(spacing: 0) {
            EmptyStateView(
                "Henüz kendi kelimen yok",
                illustration: .noWords,
                message: Text("Eklediğin kelimeler burada görünür.")
            ) {
                Button("Kelime ekle") {}
                    .buttonStyle(PrimaryCapsuleButtonStyle())
            }
            EmptyStateView(
                "Kelimeler yüklenemedi",
                illustration: .loadFailed,
                message: Text("Uygulamayı kapatıp yeniden aç.")
            )
            EmptyStateView("Bu konuda kelime yok", illustration: .symbol("square.stack.3d.up.slash"))
        }
    }
    .background(Theme.bg)
}

#Preview("Gece, büyük yazı") {
    ScrollView {
        EmptyStateView(
            "Şimdilik bu kadar",
            illustration: .allDone,
            message: Text("Sıradaki kelimeler yarın gelir.")
        )
    }
    .background(Theme.bg)
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility2)
}
