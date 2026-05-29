import Foundation

/// Pure function for the round-entry auto-fill hint.
/// Per PLAN.md §7: suggestion appears only when exactly N-1 of N cells are filled.
enum AutoFill {
    /// Returns the value that would balance the round (negative of the current sum)
    /// iff exactly one entry is `nil`. Otherwise returns `nil` (no hint shown).
    static func suggestion(for entries: [Int?]) -> Int? {
        let filled = entries.compactMap { $0 }
        guard entries.count - filled.count == 1 else { return nil }
        return -filled.reduce(0, +)
    }
}
