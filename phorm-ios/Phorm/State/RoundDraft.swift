import Foundation
import Observation

enum KeypadKey: Equatable {
    case digit(Int)   // 0...9
    case sign
    case delete
    case next
}

/// User preference for sticky keypad sign — persists across sessions.
/// Default is `−`: in Phỏm/Sâm Lốc the host most often records losses, so
/// the cheaper-friction starting position is subtract.
enum SignModePreference {
    private static let key = "phorm.keypad.signMode"
    static func load() -> Int {
        let raw = UserDefaults.standard.integer(forKey: key)
        return raw == 0 ? -1 : raw
    }
    static func save(_ value: Int) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

/// Sheet-local round-entry state. Lives only as long as the round-entry sheet;
/// nothing persists until `materialize()` is handed to `SessionActions.appendRound`
/// / `.updateRound`.
@Observable
final class RoundDraft {
    let playerNames: [String]
    var entries: [Int?]
    var focusedIndex: Int?

    /// Sticky sign for keypad input — persists across rows AND across rounds via
    /// UserDefaults. `+1` or `-1`. Once the host taps `−`, every later round opens
    /// in subtract mode until they flip it back.
    var signMode: Int

    init(playerNames: [String], existing: [String: Int]? = nil) {
        self.playerNames = playerNames
        self.signMode = SignModePreference.load()
        if let existing {
            self.entries = playerNames.map { existing[$0] }
            // Open edit mode in whatever sign mode the first non-empty entry implies.
            // Avoids the surprise of editing a round full of negatives in `+` mode.
            if let firstSigned = entries.compactMap({ $0 }).first(where: { $0 != 0 }) {
                self.signMode = firstSigned < 0 ? -1 : 1
            }
        } else {
            self.entries = Array(repeating: nil, count: playerNames.count)
        }
        self.focusedIndex = playerNames.indices.first
    }

    // MARK: - Derived

    /// Live total = sum of typed entries + the auto-fill suggestion (if active).
    /// Mirrors `materialize()` so the validation row matches what actually saves.
    /// Without folding the auto-fill in, the host sees `Tổng: +7 ⚠` while the
    /// committed round is actually balanced — the bug this fixes.
    var liveSum: Int {
        let filled = entries.compactMap { $0 }.reduce(0, +)
        return filled + (autoFillValue ?? 0)
    }

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
            // Always apply the sticky signMode — append digit on top of the existing
            // magnitude. Means: typing into a cell that holds a value of opposite sign
            // (rare) flips it to match the current mode, which matches the highlighted
            // `+`/`−` button.
            let absVal = Swift.abs(entries[i] ?? 0)
            entries[i] = signMode * (absVal * 10 + d)
        case .sign:
            // Toggle the mode AND flip the current cell's sign so the visual matches.
            signMode = -signMode
            SignModePreference.save(signMode)
            if let v = entries[i], v != 0 {
                entries[i] = -v
            }
        case .delete:
            guard let v = entries[i] else { return }
            let abs = Swift.abs(v) / 10
            entries[i] = abs == 0 ? nil : signMode * abs
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
