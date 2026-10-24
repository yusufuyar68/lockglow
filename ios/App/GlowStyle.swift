import SwiftUI

/// Names of the first design proposal, kept so the onboarding and the topic picker compile; they
/// now map onto the tokens of `Theme` (ios/Shared/LockglowTheme.swift) as in docs/tasarim/README.md
/// ("GlowStyle.swift eşlemesi"). New code uses `Theme` directly. App target only: the widget
/// extension and the snapshot bundle do not compile this file.
/// The old `glowTint` (the box behind the Turkish meaning) is gone: the meaning has no box, and
/// so are the unused `glow` and `onGlow` (the main button's fill and text: `Theme.primary` and
/// `Theme.onPrimary`, drawn by `PrimaryCapsuleButtonStyle`).
enum Palette {
    /// Selected items, step numbers, the onboarding's text buttons (`Theme.tint`). Never yellow.
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
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
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
    /// What VoiceOver says when `title` is a short form: "30 dakika" for "30 dk" (audit V12).
    /// Nil: `title` is read.
    var spokenTitle: String? = nil
}

/// Two to four always-visible options. While their titles fit on one row at the current text size
/// it is the standard iOS segmented control (HIG: standard controls; findings ayarlar-5,
/// sozluk-5): a `.segmented` `Picker` with its label hidden. The caller names the group
/// (`.accessibilityElement(children: .contain)` + `.accessibilityLabel`); XCUITest lists each
/// segment as a button with its title. At accessibility text sizes, or when the titles do not fit
/// side by side, the options stack as an iOS list of choices instead (the native control would cut
/// them with "…"): one 44 pt row each in a `surface` group with a `line` edge, a `tint` checkmark
/// on the selected row. A single border: the selected row has no box of its own (acilis-1).
/// A row sets the selection on every tap; the segmented control only when the segment changes.
struct SegmentButtons<Value: Hashable>: View {
    let options: [SegmentOption<Value>]
    @Binding var selection: Value
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            choiceList
        } else {
            ViewThatFits(in: .horizontal) {
                segmentedPicker
                choiceList
            }
        }
    }

    /// The system control. `spokenTitle` becomes the segment's VoiceOver label ("30 dakika" for
    /// "30 dk", audit V12).
    private var segmentedPicker: some View {
        Picker(selection: $selection) {
            ForEach(options, id: \.value) { option in
                Text(verbatim: option.title)
                    .accessibilityLabel(Text(verbatim: option.spokenTitle ?? option.title))
                    .tag(option.value)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    /// The stacked fallback: an iOS list of choices with hairlines between the rows.
    private var choiceList: some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous)
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                if index > 0 {
                    Rectangle()
                        .fill(Theme.line)
                        .frame(height: 1)
                        .padding(.leading, 16)
                        .accessibilityHidden(true)
                }
                choiceRow(option)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: shape)
        .clipShape(shape)
        .overlay(shape.strokeBorder(Theme.line, lineWidth: 1))
    }

    private func choiceRow(_ option: SegmentOption<Value>) -> some View {
        let isSelected = option.value == selection
        return Button {
            selection = option.value
        } label: {
            HStack(spacing: 12) {
                // Wraps instead of being cut with "…" at the largest text sizes.
                Text(verbatim: option.title)
                    .font(.body)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.tint)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: Theme.minHitSize, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: option.spokenTitle ?? option.title))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
