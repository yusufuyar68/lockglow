import SwiftUI

// The phosphor band's colors as an environment value (LockglowTheme.swift, "Phosphor band"). The
// app never sets it, so its band stays phosphor yellow; a Home Screen widget sets the accent the
// person chose in "Widget'ı Düzenle" (`WidgetAccent`, ios/Widgets/WidgetConfigurationOptions.swift).
// Only full color uses these colors: tinted, vibrant and Lock Screen widgets draw a thin line in
// the word's own color whatever the accent. Compiled into the app, the widget extension and the
// widget snapshot bundle (ios/Shared) because the band is.

/// The band's three colors: behind the letters by day, under them at night, and the night glow.
struct PhosphorBandColors {
    let light: Color
    let dark: Color
    let glow: Color

    /// The brand's phosphor yellow (`Theme.bandLight`, `bandDark`, `bandGlow`).
    static let phosphor = PhosphorBandColors(light: Theme.bandLight, dark: Theme.bandDark, glow: Theme.bandGlow)

    init(light: Color, dark: Color, glow: Color) {
        self.light = light
        self.dark = dark
        self.glow = glow
    }

    /// A band from two sRGB values; the glow is the night color at the opacity of `Theme.bandGlow`
    /// (18 %, ogrenme_ilkeleri.md: at most 15-20 %).
    init(day: UInt32, night: UInt32) {
        self.init(
            light: PhosphorBandColors.color(day, opacity: 1),
            dark: PhosphorBandColors.color(night, opacity: 1),
            glow: PhosphorBandColors.color(night, opacity: 0.18)
        )
    }

    private static func color(_ hex: UInt32, opacity: Double) -> Color {
        return Color(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

private struct PhosphorBandColorsKey: EnvironmentKey {
    static let defaultValue = PhosphorBandColors.phosphor
}

extension EnvironmentValues {
    /// The colors `phosphorBand()` draws with; phosphor yellow unless a widget chose another accent.
    var phosphorBandColors: PhosphorBandColors {
        get { self[PhosphorBandColorsKey.self] }
        set { self[PhosphorBandColorsKey.self] = newValue }
    }
}
