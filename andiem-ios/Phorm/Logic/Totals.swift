import Foundation

enum Totals {
    /// Cumulative score per player across all rounds in the session.
    /// Players present in `session.playerNames` but absent from a round's
    /// `PlayerScore` set contribute 0 (sparse rounds — PLAN.md §7).
    static func cumulative(for session: Session) -> [String: Int] {
        var result: [String: Int] = Dictionary(
            uniqueKeysWithValues: session.playerNames.map { ($0, 0) }
        )
        for round in session.rounds ?? [] {
            for score in round.scores ?? [] {
                result[score.playerName, default: 0] += score.value
            }
        }
        return result
    }

    /// `(name, total)` sorted descending by `total`. Ties broken by `name`
    /// ascending for stable ordering across renders.
    static func ranking(for session: Session) -> [(name: String, total: Int)] {
        cumulative(for: session)
            .map { (name: $0.key, total: $0.value) }
            .sorted { lhs, rhs in
                if lhs.total != rhs.total { return lhs.total > rhs.total }
                return lhs.name < rhs.name
            }
    }
}
