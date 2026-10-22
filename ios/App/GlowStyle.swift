import SwiftUI

/// Names of the first design proposal, kept so the onboarding and the topic picker compile; they
/// now map onto the tokens of `Theme` (ios/Shared/LockglowTheme.swift) as in docs/tasarim/README.md
/// ("GlowStyle.swift eşlemesi"). New code uses `Theme` directly. App target only: the widget
/// extension and the snapshot bundle do not compile this file.
/// The old `glowTint` (the box behind the Turkish meaning) is gone: the meaning has no box.
enum Palette {
    /// Fill of the one main button: ink by day, a faint ink tint at night (`Theme.primary`;
    /// `PrimaryCapsuleButtonStyle`, which `GlowButtonStyle` uses, adds the night edge and bold
    /// text). Progress and selection use `glowInk` (`Theme.tint`). Neither is ever yellow.
    static let glow = Theme.primary
    /// Text and icons on a `glow` fill (`Theme.onPrimary`): white by day, ink at night.
    static let onGlow = Theme.onPrimary
    /// Selected items, step numbers, the onboarding's text buttons (`Theme.tint`).
    static let glowInk = Theme.tint
    /// Secondary text.
    static let ink2 = Theme.ink2
    static let background = Theme.bg
    static let surface = Theme.surface
    /// Unselected choices.
    static let surface2 = Theme.surface2
    static let line = Theme.line
}

/// The one main button of a screen (mockup `.btn-primary.btn-lg`): a full-width 54 pt capsule.
struct GlowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PrimaryCapsuleButtonStyle(fullWidth: true, minHeight: 54)
            .makeBody(configuration: configuration)
    }
}

/// A row that can be chosen (mockup `.choice`), at least 56 pt high: a `surface` row with a
/// `lineStrong` border; selected, a 2 pt `tint` border and a `tint` check (never yellow).
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
                    .foregroundStyle(isSelected ? Theme.tint : Theme.ink3)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 10)
            .padding(.leading, 16)
            .padding(.trailing, 14)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(Theme.surface, in: rowShape)
            .overlay(
                rowShape
                    .strokeBorder(isSelected ? Theme.tint : Theme.lineStrong, lineWidth: isSelected ? 2 : 1.5)
            )
            .contentShape(rowShape)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var rowShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
    }
}

struct SegmentOption<Value: Hashable>: Hashable {
    let value: Value
    let title: String
}

/// Two or three always-visible options (mockup `.seg`) in a `surface2` well with a 1 pt
/// `lineStrong` edge (the gray well alone is 1.1-1.4:1 against the page, audit K1). The selected
/// one is a `surface` segment with ink text and a 1.5 pt `tint` inner border (a white fill with
/// the old white-on-amber text would be unreadable). Stacks vertically when the text does not fit
/// side by side (largest text sizes).
struct SegmentButtons<Value: Hashable>: View {
    let options: [SegmentOption<Value>]
    @Binding var selection: Value
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityShowButtonShapes) private var showsButtonShapes

    var body: some View {
        let well = RoundedRectangle(cornerRadius: 16, style: .continuous)
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 2) {
                buttons
            }
            VStack(spacing: 2) {
                buttons
            }
        }
        .padding(3)
        .background(Theme.surface2, in: well)
        .overlay {
            well.strokeBorder(
                Theme.lineStrong,
                lineWidth: contrast == .increased || showsButtonShapes ? 1.5 : 1
            )
        }
    }

    private var buttons: some View {
        ForEach(options, id: \.value) { option in
            let isSelected = option.value == selection
            Button {
                selection = option.value
            } label: {
                Text(option.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .fixedSize()
                    .foregroundStyle(isSelected ? Theme.ink : Theme.ink2)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background {
                        if isSelected {
                            selectedSegment
                        }
                    }
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }

    private var selectedSegment: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.segment, style: .continuous)
            .fill(Theme.surface)
            .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.16), radius: 1.5, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.segment, style: .continuous)
                    .strokeBorder(Theme.tint, lineWidth: 1.5)
            )
    }
}
