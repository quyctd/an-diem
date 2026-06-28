import SwiftUI

/// Tactile/playful warm palette — see DESIGN.md (tc-) and themes-preview.html.
/// Token NAMES are preserved from earlier palettes so existing view callsites keep
/// compiling; VALUES resolve to the tactile warm system (cream day / deep-warm night).
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
    /// Dark ink for legible numbers on color-filled chips (AA).
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

    // MARK: - Tactile depth (bevels, ridges, key faces — tc- mockup)
    /// Opaque card surface — tactile cards, summary rows, recent-strip container.
    static let cardSurface       = Color("SurfaceCard")
    /// Keypad digit/delete key face gradient stops + ridge.
    static let keyFaceTop        = Color("KeyFaceTop")
    static let keyFaceBottom     = Color("KeyFaceBottom")
    static let keyRidge          = Color("KeyRidge")
    /// Keypad sign key face + ridge + glyph ink.
    static let keySignFaceTop    = Color("KeySignFaceTop")
    static let keySignFaceBottom = Color("KeySignFaceBottom")
    static let keySignRidge      = Color("KeySignRidge")
    static let keySignInk        = Color("KeySignInk")
    /// Neutral coin face + bottom bevel.
    static let coinSeat          = Color("CoinSeat")
    static let coinSeatBevel     = Color("CoinSeatBevel")
    /// Neutral chip bottom bevel.
    static let chipNeutralBevel  = Color("ChipNeutralBevel")
    /// Soft drop-shadow ink for tactile cards (adaptive alpha).
    static let cardShadow        = Color("CardShadow")
    /// Fixed chip bottom-bevel inks (same across appearances — chip fills are fixed too).
    static let chipUpBevel       = Color(red: 0x0F/255, green: 0x8A/255, blue: 0x48/255) // #0F8A48
    static let chipDownBevel     = Color(red: 0xCC/255, green: 0x45/255, blue: 0x1C/255) // #CC451C
    /// Gold coin gradient stops (135°): FFD761 → F2B829 → C8920D.
    static let coinGoldStops: [Color] = [
        Color(red: 0xFF/255, green: 0xD7/255, blue: 0x61/255),
        Color(red: 0xF2/255, green: 0xB8/255, blue: 0x29/255),
        Color(red: 0xC8/255, green: 0x92/255, blue: 0x0D/255)
    ]
    /// Last-place (Bét) coin marker — fixed across appearances.
    static let lastMarkerFill    = Color(red: 0xF5/255, green: 0xE6/255, blue: 0xE0/255) // #F5E6E0
    static let lastMarkerInk     = Color(red: 0xC0/255, green: 0x40/255, blue: 0x18/255) // #C04018
    static let lastMarkerBevel   = Color(red: 0xD9/255, green: 0xBF/255, blue: 0xBA/255) // #D9BFBA
}
