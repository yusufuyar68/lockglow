import SwiftUI
import UIKit

/// Colors of the design proposal (`docs/tasarim/README.md`, light / dark values of the mockup),
/// defined in code so the onboarding and the topic picker can use them before the asset
/// catalog has them. Amber fills only the one main button and the selected item; text on amber
/// is always `onGlow`, amber text and icons use `glowInk`.
enum Palette {
    /// Fill: the main button, the selected option.
    static let glow = dynamic(light: 0xFFB321, dark: 0xFFBD3F)
    /// Text and icons on a `glow` fill (white on amber is unreadable).
    static let onGlow = Color(uiColor: UIColor(rgb: 0x1B1200))
    /// Links, icons, step numbers.
    static let glowInk = dynamic(light: 0x955000, dark: 0xFFC862)
    /// Background of the Turkish meaning box and highlights.
    static let glowTint = dynamic(light: 0xFFF1D2, dark: 0xFFBD3F, darkAlpha: 0.14)
    /// Secondary text.
    static let ink2 = dynamic(light: 0x4F4A63, dark: 0xBDB7CF)
    static let background = dynamic(light: 0xF5F4F9, dark: 0x0C0A12)
    static let surface = dynamic(light: 0xFFFFFF, dark: 0x171420)
    /// Unselected choices.
    static let surface2 = dynamic(light: 0xEDEBF3, dark: 0x211D2D)
    static let line = dynamic(light: 0x15131F, dark: 0xFFFFFF, lightAlpha: 0.12, darkAlpha: 0.12)

    private static func dynamic(
        light: UInt32,
        dark: UInt32,
        lightAlpha: CGFloat = 1,
        darkAlpha: CGFloat = 1
    ) -> Color {
        return Color(uiColor: UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return UIColor(rgb: dark, alpha: darkAlpha)
            }
            return UIColor(rgb: light, alpha: lightAlpha)
        })
    }
}

private extension UIColor {
    convenience init(rgb: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: alpha
        )
    }
}

/// The one amber button of a screen (mockup `.btn-primary.btn-lg`): full width, 54 pt high.
struct GlowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GlowButtonBody(configuration: configuration)
    }
}

private struct GlowButtonBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(.headline)
            .multilineTextAlignment(.center)
            .foregroundStyle(Palette.onGlow)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(Palette.glow, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.45)
            .contentShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
    }
}

/// A row that can be chosen (mockup `.opt`): amber check when selected, at least 56 pt high.
/// Used for the level and topic choices.
struct ChoiceRow<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let label: () -> Content

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                label()
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Palette.glowInk : Palette.ink2)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(isSelected ? Palette.glowTint : Palette.surface, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .strokeBorder(isSelected ? Palette.glow : Palette.line, lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct SegmentOption<Value: Hashable>: Hashable {
    let value: Value
    let title: String
}

/// Two or three always-visible options (mockup `.seg`), selected one in amber. Stacks
/// vertically when the text does not fit side by side (largest text sizes).
struct SegmentButtons<Value: Hashable>: View {
    let options: [SegmentOption<Value>]
    @Binding var selection: Value

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 2) {
                buttons
            }
            VStack(spacing: 2) {
                buttons
            }
        }
        .padding(3)
        .background(Palette.surface2, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var buttons: some View {
        ForEach(options, id: \.value) { option in
            let isSelected = option.value == selection
            Button {
                selection = option.value
            } label: {
                Text(option.title)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                    .fixedSize()
                    .foregroundStyle(isSelected ? Palette.onGlow : Palette.ink2)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(isSelected ? Palette.glow : Color.clear)
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }
}
