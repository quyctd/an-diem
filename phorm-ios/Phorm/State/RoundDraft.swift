import Foundation
import Observation

enum KeypadKey: Equatable {
    case digit(Int)   // 0...9
    case sign
    case delete
    case next
}

/// Sheet-local round-entry state. Lives only as long as the round-entry sheet;
/// nothing persists until `materialize()` is handed to `SessionActions.appendRound`
/// / `.updateRound`.
@Observable
final class RoundDraft {
    let playerNames: [String]
    var entries: [Int?]
    var focusedIndex: Int?

    init(playerNames: [String], existing: [String: Int]? = nil) {
        self.playerNames = playerNames
        if let existing {
            self.entries = playerNames.map { existing[$0] }
        } else {
            self.entries = Array(repeating: nil, count: playerNames.count)
        }
        self.focusedIndex = playerNames.indices.first
    }

    // MARK: - Derived

    var liveSum: Int { entries.compactMap { $0 }.reduce(0, +) }

    var autoFillValue: Int? { AutoFill.suggestion(for: entries) }

    /// Row index that should display the italic-muted auto-fill hint.
    /// Returns nil when no hint should show (e.g., user is focused on the empty slot).
    var autoFillIndex: Int? {
        guard autoFillValue != nil,
              let blank = entries.firstIndex(where: { $0 == nil }) else { return nil }
        return blank == focusedIndex ? nil : blank
    }

    var isSumBalanced: Bool { liveSum == 0 }

    // MARK: - Keypad input

    func keypad(_ key: KeypadKey) {
        guard let i = focusedIndex else { return }
        switch key {
        case .digit(let d):
            let current = entries[i] ?? 0
            let sign = current < 0 ? -1 : 1
            let abs = Swift.abs(current)
            let next = abs * 10 + d
            entries[i] = sign * next
        case .sign:
            if let v = entries[i] { entries[i] = -v }
            else { entries[i] = 0 } // sign on empty sets up a negative
        case .delete:
            guard let v = entries[i] else { return }
            let abs = Swift.abs(v) / 10
            entries[i] = abs == 0 ? nil : (v < 0 ? -abs : abs)
        case .next:
            nextField()
        }
    }

    /// Jump focus to the next row, skipping the auto-fill row.
    func nextField() {
        guard let current = focusedIndex else {
            focusedIndex = playerNames.indices.first
            return
        }
        let count = playerNames.count
        var candidate = (current + 1) % count
        while candidate != current && candidate == autoFillIndex {
            candidate = (candidate + 1) % count
        }
        focusedIndex = candidate
    }

    // MARK: - Save

    /// Materialize entries into a `[playerName: value]` map.
    /// - Auto-fill value lands at `autoFillIndex` (if any).
    /// - Remaining `nil` entries become 0 (sparse rounds, PLAN.md §7).
    func materialize() -> [String: Int] {
        var result: [String: Int] = [:]
        let auto = autoFillValue
        let autoIdx = autoFillIndex
        for (i, name) in playerNames.enumerated() {
            if let v = entries[i] {
                result[name] = v
            } else if i == autoIdx, let auto {
                result[name] = auto
            } else {
                result[name] = 0
            }
        }
        return result
    }
}
