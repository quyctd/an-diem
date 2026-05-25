import SwiftUI

/// Hà Nội cũ surfaces — lacquer drenched, NOT Liquid Glass.
/// See DESIGN.md and themes-preview.html for the canonical visual.
///
/// The prior Liquid Glass treatment is REPLACED by solid lacquer surfaces
/// overlaid with halftone + paper grain (rendered separately via a background
/// modifier; see `View+LacquerSurface.swift` once added).
///
/// These Material aliases are kept for any callsites that still pass a
/// `Material` value; they resolve to the thinnest variants so they let the
/// underlying lacquer color show through with minimal frosting. The end state
/// is to migrate callsites to the Color-based lacquer tokens and remove
/// `PhormMaterial` entirely.
enum PhormMaterial {
    /// DEPRECATED — was nav bar / autosuggest. Migrate to a solid cinnabar
    /// surface with a 1px cream-faint hairline.
    static let glassRegular: Material = .ultraThinMaterial

    /// DEPRECATED — was full-screen sheets. Migrate to a solid cinnabar-deep
    /// background for sheets so they read as a deeper lacquer plane, not
    /// frosted glass.
    static let glassThickSheet: Material = .ultraThinMaterial

    /// DEPRECATED — was floating overlay. Migrate to a cinnabar fill with
    /// black-12% darken overlay (matches the round-history chips in the
    /// preview).
    static let glassClear: Material = .ultraThinMaterial
}
