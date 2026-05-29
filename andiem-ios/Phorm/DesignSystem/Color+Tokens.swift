import SwiftUI

/// Hà Nội cũ palette — Vietnamese vernacular print register.
/// See DESIGN.md and themes-preview.html for the canonical visual.
/// Token NAMES are preserved from the prior trading-terminal palette so existing
/// view callsites keep compiling; VALUES are swapped to the new lacquer system.
extension Color {
    // MARK: - Brand accent (gold-leaf, replaces signal yellow)
    /// Gold leaf — primary CTA fill, focus borders, winner seal background.
    /// Contrast on cinnabar: 4.27:1 — use for display sizes ≥18px only.
    static let phormPrimary         = Color(red: 0xD9/255, green: 0xB2/255, blue: 0x5A/255)   // #D9B25A
    /// Pressed-state variant of gold.
    static let phormPrimaryActive   = Color(red: 0xA8/255, green: 0x84/255, blue: 0x38/255)   // #A88438
    /// Disabled CTA — desaturated gold-dim.
    static let phormPrimaryDisabled = Color(red: 0x5A/255, green: 0x44/255, blue: 0x23/255)   // #5A4423
    /// Cinnabar-deep ink for text on gold surfaces (6.76:1 on gold).
    static let onPrimary            = Color(red: 0x5A/255, green: 0x16/255, blue: 0x12/255)   // #5A1612

    /// Brighter gold for small labels — 5.10:1 on cinnabar, passes AA Normal.
    static let phormGoldBright      = Color(red: 0xE8/255, green: 0xC5/255, blue: 0x70/255)   // #E8C570

    // MARK: - Score semantics (mint up, ochre down — text color only)
    /// Mint — positive scores. 5.81:1 on cinnabar.
    static let scorePositive = Color(red: 0xB6/255, green: 0xE0/255, blue: 0xC2/255)   // #B6E0C2
    /// Ochre — negative scores. 4.02:1 on cinnabar — Large only (≥18px display).
    static let scoreNegative = Color(red: 0xE6/255, green: 0xA6/255, blue: 0x65/255)   // #E6A665
    /// Soft warning (non-zero round total) — reuses ochre.
    static let warning       = Color(red: 0xE6/255, green: 0xA6/255, blue: 0x65/255)   // #E6A665
    /// Cream-dim used as neutral muted across surfaces. 4.94:1 on cinnabar.
    static let phormMuted    = Color(red: 0xD6/255, green: 0xC4/255, blue: 0xA0/255)   // #D6C4A0

    // MARK: - Lacquer surfaces (drenched — one per session, no neutral canvas)
    /// Default lacquer surface — Tết cinnabar. The canonical surface.
    static let phormSurfaceCinnabar     = Color(red: 0x8C/255, green: 0x2A/255, blue: 0x22/255)   // #8C2A22
    /// Deepened cinnabar — dark-mode shift, button text ink, vignette.
    static let phormSurfaceCinnabarDeep = Color(red: 0x5A/255, green: 0x16/255, blue: 0x12/255)   // #5A1612
    /// Aged-wood ochre surface — alternate session color.
    static let phormSurfaceOchre        = Color(red: 0xA8/255, green: 0x75/255, blue: 0x4A/255)   // #A8754A
    /// Old-jade surface — alternate session color (cooler register).
    static let phormSurfaceJade         = Color(red: 0x3D/255, green: 0x6B/255, blue: 0x5C/255)   // #3D6B5C
    /// Oxblood — night-mode deepening of cinnabar.
    static let phormSurfaceOxblood      = Color(red: 0x5D/255, green: 0x1A/255, blue: 0x18/255)   // #5D1A18

    // MARK: - Cream ink (paper-on-lacquer text family)
    /// Primary text on every lacquer surface. 6.96:1 on cinnabar.
    static let phormCream      = Color(red: 0xF3/255, green: 0xE8/255, blue: 0xD2/255)   // #F3E8D2
    /// Secondary text, labels, dates. 4.94:1 on cinnabar.
    static let phormCreamDim   = Color(red: 0xD6/255, green: 0xC4/255, blue: 0xA0/255)   // #D6C4A0
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
