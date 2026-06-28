import SwiftUI

/// Hà Nội cũ palette — Vietnamese vernacular print register.
/// See DESIGN.md and themes-preview.html for the canonical visual.
/// Token NAMES are preserved from the prior trading-terminal palette so existing
/// view callsites keep compiling; VALUES are swapped to the new lacquer system.
extension Color {
    // MARK: - Brand accent (Tết-red + gold — adaptive asset catalog)
    /// Tết-red accent / focus ring / CTA (adaptive: same day+night).
    static let phormPrimary    = Color("BrandAccent")
    /// Pressed-state variant of gold.
    static let phormPrimaryActive   = Color(red: 0xA8/255, green: 0x84/255, blue: 0x38/255)   // #A88438
    /// Disabled CTA — desaturated gold-dim.
    static let phormPrimaryDisabled = Color(red: 0x5A/255, green: 0x44/255, blue: 0x23/255)   // #5A4423
    /// Cinnabar-deep ink for text on gold surfaces (6.76:1 on gold).
    static let onPrimary            = Color(red: 0x5A/255, green: 0x16/255, blue: 0x12/255)   // #5A1612

    /// Winner coin, special keys (adaptive asset catalog).
    static let phormGoldBright = Color("BrandGold")

    // MARK: - Score semantics (chip fills — adaptive asset catalog)
    /// Green chip fill — positive scores.
    static let scorePositive = Color("ChipUp")
    /// Coral chip fill — negative scores / warning.
    static let scoreNegative = Color("ChipDown")
    /// Soft warning (non-zero round total) — reuses ChipDown.
    static let warning       = Color("ChipDown")
    /// Secondary ink (adaptive).
    static let phormMuted    = Color("InkSecondary")

    // MARK: - Surfaces (adaptive asset catalog)
    /// Root surface — warm cream (day) / deep warm (night).
    static let phormSurfaceCinnabar     = Color("SurfaceRoot")
    /// Deepened cinnabar — dark-mode shift, button text ink, vignette.
    static let phormSurfaceCinnabarDeep = Color(red: 0x5A/255, green: 0x16/255, blue: 0x12/255)   // #5A1612
    /// Aged-wood ochre surface — alternate session color.
    static let phormSurfaceOchre        = Color(red: 0xA8/255, green: 0x75/255, blue: 0x4A/255)   // #A8754A
    /// Old-jade surface — alternate session color (cooler register).
    static let phormSurfaceJade         = Color(red: 0x3D/255, green: 0x6B/255, blue: 0x5C/255)   // #3D6B5C
    /// Oxblood — night-mode deepening of cinnabar.
    static let phormSurfaceOxblood      = Color(red: 0x5D/255, green: 0x1A/255, blue: 0x18/255)   // #5D1A18

    /// Card / tile surface — chips, active-row card, panels.
    static let surfaceTile     = Color("SurfaceTile")
    /// Neutral/zero chip fill.
    static let chipNeutral     = Color("ChipNeutral")
    /// Text on a color-filled chip (white).
    static let onChip          = Color("OnChip")

    // MARK: - Ink (paper-on-surface text family — adaptive asset catalog)
    /// Primary text on every surface (adaptive). 6.96:1 day, 4.5:1+ night.
    static let phormCream      = Color("InkPrimary")
    /// Secondary text, labels, dates (adaptive).
    static let phormCreamDim   = Color("InkSecondary")
    /// Decorative section divider (not contrast-critical).
    static let phormCreamStroke = Color.white.opacity(0.18)

    // MARK: - Adaptive (resolved from Assets.xcassets — updated to Hà Nội cũ)
    static let canvas             = Color("Canvas")
    static let surfaceCard        = Color("SurfaceCard")
    static let surfaceElevated    = Color("SurfaceElevated")
    static let surfaceSoft        = Color("SurfaceSoft")
    static let hairline           = Color("Hairline")
    static let bodyText           = Color("Body")
    static let mutedStrong        = Color("MutedStrong")
    static let focusRowTint       = Color("FocusRowTint")
    static let scorePositiveTint  = Color("ScorePositiveTint")
    static let scoreNegativeTint  = Color("ScoreNegativeTint")
}
