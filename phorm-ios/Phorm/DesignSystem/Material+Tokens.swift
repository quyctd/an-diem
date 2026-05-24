import SwiftUI

/// DESIGN.md `materials:` mapped to SwiftUI's built-in Material values.
/// SwiftUI handles Reduce Transparency / Increase Contrast automatically.
enum PhormMaterial {
    /// Nav bar, autosuggest dropdown, secondary glass button — DESIGN.md `glass-regular-*`.
    static let glassRegular: Material = .regularMaterial

    /// Round-entry sheet, new-session sheet, import-confirm sheet, keypad container
    /// — DESIGN.md `glass-thick-sheet`. Sheets get this by default in iOS 17+.
    static let glassThickSheet: Material = .thickMaterial

    /// Floating overlays over rich content — DESIGN.md `glass-clear`.
    static let glassClear: Material = .ultraThinMaterial
}
