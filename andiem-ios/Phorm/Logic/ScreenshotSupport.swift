#if DEBUG
import Foundation
import SwiftData

/// Screens the screenshot harness can launch directly into (PHORM_OPEN).
enum ScreenshotScreen: String {
    case leaderboard, roundEntry, summary, history, newSession, empty
}

/// DEBUG-only launch hooks for autonomous App Store screenshot capture.
/// Driven by `PHORM_SEED=demo` and `PHORM_OPEN=<screen>` launch env vars.
enum ScreenshotSupport {
    static var seedRequested: Bool {
        ProcessInfo.processInfo.environment["PHORM_SEED"] == "demo"
    }

    static var openTarget: ScreenshotScreen? {
        ProcessInfo.processInfo.environment["PHORM_OPEN"].flatMap(ScreenshotScreen.init)
    }

    /// Targets that should NOT have an active session (so EmptyHomeView shows).
    static var wantsEmptyHome: Bool {
        switch openTarget {
        case .empty, .newSession: return true
        default: return false
        }
    }

    /// Insert deterministic demo data. `activeSession` controls whether a current
    /// (unarchived) session exists — false routes the app to EmptyHomeView.
    static func seed(into context: ModelContext, activeSession: Bool) {
        let players = ["Quý", "Nam", "Linh", "Hoàng"]
        // Per-round scores: columns sum to 0 each round; Quý leads, Hoàng trails.
        let perRound: [[Int]] = [
            [ 4, -1, -1, -2],
            [-2,  6, -1, -3],
            [ 3, -1,  2, -4],
            [ 5, -2, -1, -2],
            [-1,  3,  1, -3],
            [ 2, -1, -2,  1],
        ]

        if activeSession {
            let s = Session(name: "Phỏm tối thứ Sáu", createdAt: .now, playerNames: players)
            context.insert(s)
            for (i, row) in perRound.enumerated() {
                let r = Round(index: i + 1)
                r.session = s
                context.insert(r)
                for (p, v) in zip(players, row) {
                    let ps = PlayerScore(playerName: p, value: v)
                    ps.round = r
                    context.insert(ps)
                }
            }
        }

        // Archived sessions for History — deterministic dates relative to a fixed anchor.
        let anchor = Date(timeIntervalSince1970: 1_716_000_000) // 2024-05-18, stable
        let archived: [(String, [String], Int)] = [
            ("Sâm Lốc nhà Hoàng", ["Quý", "Hoàng", "Mai"], 7),
            ("Cafe sau giờ làm",   ["Nam", "Linh", "Trang", "Quý"], 14),
            ("Sinh nhật Linh",     ["Linh", "Quý", "Nam", "Mai", "Trang"], 21),
            ("Tất niên xóm",       ["An", "Bình", "Cường", "Dũng"], 28),
        ]
        for (name, names, daysAgo) in archived {
            let created = anchor.addingTimeInterval(Double(-daysAgo) * 86_400)
            let s = Session(name: name, createdAt: created, archivedAt: created.addingTimeInterval(7200), playerNames: names)
            context.insert(s)
            let r = Round(index: 1)
            r.session = s
            context.insert(r)
            // simple closed round so totals render
            var vals = Array(repeating: -2, count: names.count)
            vals[0] = (names.count - 1) * 2
            for (p, v) in zip(names, vals) {
                let ps = PlayerScore(playerName: p, value: v)
                ps.round = r
                context.insert(ps)
            }
        }
        try? context.save()
    }
}
#endif
