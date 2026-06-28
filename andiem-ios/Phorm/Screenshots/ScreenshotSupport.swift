import SwiftUI
import SwiftData

/// Marketing-screenshot harness. Activated only when the app is launched with the
/// `SCREENSHOT=1` environment variable (set by `tools/screenshots/capture.sh`),
/// so it has zero effect on a normally-launched build.
///
/// When active the app:
///   - swaps the CloudKit store for an in-memory store seeded with a curated,
///     story-shaped session (clear leader, clear last place → both seals show),
///   - skips the splash flourish,
///   - routes the root straight to one screen (`SCREEN=session|summary|roundEntry`)
///     so each App Store panel is captured by a plain `simctl io screenshot` —
///     no UI driving required.
enum ScreenshotMode {
    static var isActive: Bool {
        let env = ProcessInfo.processInfo.environment
        return env["SCREENSHOT"] == "1"
            || ProcessInfo.processInfo.arguments.contains("--screenshot")
    }

    enum Screen: String {
        case session     // live scoreboard — the hero shot
        case summary     // Tổng kết — champion + ấn vàng + tem cuối bàn
        case roundEntry  // keypad mid-entry with the 封 auto-fill seal
        case newSession  // Khai phiên — reuse-group + add-players flow
        case history     // Lịch sử — the lacquered scorebook of past sessions
    }

    static var screen: Screen {
        let raw = ProcessInfo.processInfo.environment["SCREEN"] ?? "session"
        return Screen(rawValue: raw) ?? .session
    }

    // MARK: - Curated data

    static let players = ["Hùng", "Lan", "Minh", "Tú"]
    static let sessionName = "Phỏm tối thứ Bảy"

    /// 9 rounds × 4 players, columns aligned to `players`.
    /// Hand-tuned so cumulative totals tell a story:
    ///   Hùng +50 (dẫn) · Lan −3 · Minh −6 · Tú −41 (tem cuối bàn).
    /// The leader is clearly ahead (no "sát nút"), the last seat is clearly
    /// negative (≥4 players, total ≤0) — so the winner's ấn vàng and the
    /// last-place × both render.
    static let roundScores: [[Int]] = [
        [ 6, -2,  1,  -5],
        [-3,  5, -1,  -1],
        [12, -8,  3,  -7],
        [ 4,  2, -3,  -3],
        [ 9, -4,  6, -11],
        [-2,  7, -2,  -3],
        [ 8, -1, -5,  -2],
        [ 5,  4, -6,  -3],
        [11, -6,  1,  -6],
    ]

    /// Pre-filled keypad draft for the `roundEntry` shot — 3 of 4 cells typed so
    /// the 4th auto-fills as −(sum), surfacing the 封 seal (the signature feature).
    /// Hùng +12, Lan −5, Minh −4 → Tú auto −3, live total balanced ("0 · cân").
    static let roundEntryPrefill: [String: Int] = ["Hùng": 12, "Lan": -5, "Minh": -4]

    /// Past sessions seeded behind the hero — they populate the `history` list
    /// (the "lacquered scorebook a friend group keeps") and the "Nhóm vừa rồi"
    /// reuse block on `newSession`. Varied group sizes + names so the list reads
    /// like a real archive. `rounds` rows align to `players`.
    struct SeedSpec {
        let name: String
        let players: [String]
        let daysAgo: Double
        let rounds: [[Int]]
    }

    static let historySpecs: [SeedSpec] = [
        SeedSpec(name: "Chung cư tối qua", players: ["Hùng", "Lan", "Minh", "Tú"], daysAgo: 1,
                 rounds: [[10, -4, -3, -3], [7, 2, -5, -4], [12, -6, -2, -4]]),
        SeedSpec(name: "Cà phê Chủ Nhật", players: ["Anh", "Bích", "Cường"], daysAgo: 3,
                 rounds: [[8, -5, -3], [6, -2, -4], [9, -7, -2]]),
        SeedSpec(name: "Giao thừa", players: ["Hùng", "Lan", "Minh", "Tú", "Phúc"], daysAgo: 8,
                 rounds: [[6, -1, -2, -4, 1], [8, -3, -2, -5, 2], [5, 2, -4, -6, 3]]),
        SeedSpec(name: "Lương về", players: ["Minh", "Tú", "Đạt"], daysAgo: 14,
                 rounds: [[9, -5, -4], [7, -3, -4], [6, -2, -4]]),
        SeedSpec(name: "Nhà Sơn", players: ["Hùng", "Lan", "Sơn", "Tú"], daysAgo: 21,
                 rounds: [[4, -2, 5, -7], [6, -3, 3, -6], [8, -4, 2, -6]]),
        SeedSpec(name: "Tất niên xóm", players: ["Hùng", "Lan", "Minh", "Tú", "Phúc", "Quân"], daysAgo: 30,
                 rounds: [[5, -2, -1, -3, 2, -1], [7, -3, -2, -4, 3, -1], [6, -1, -3, -5, 2, 1]]),
    ]

    // MARK: - Container

    static func makeContainer() -> ModelContainer {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            seed(into: ModelContext(container))
            return container
        } catch {
            fatalError("Screenshot ModelContainer init failed: \(error)")
        }
    }

    private static func seed(into context: ModelContext) {
        // Hero session — newest, so it sorts first and drives session/summary/
        // roundEntry/newSession. Archived only for the Tổng kết shot.
        let heroCreated = Date.now.addingTimeInterval(-2.5 * 3600) // → "2g 30p"
        insert(
            name: sessionName,
            players: players,
            createdAt: heroCreated,
            archivedAt: screen == .summary ? .now : nil,
            rounds: roundScores,
            into: context
        )

        // Past sessions — fill the Lịch sử list and the reuse-group affordance.
        for spec in historySpecs {
            let created = Date.now.addingTimeInterval(-spec.daysAgo * 86_400)
            insert(
                name: spec.name,
                players: spec.players,
                createdAt: created,
                archivedAt: created.addingTimeInterval(2 * 3600),
                rounds: spec.rounds,
                into: context
            )
        }

        try? context.save()
    }

    private static func insert(
        name: String,
        players: [String],
        createdAt: Date,
        archivedAt: Date?,
        rounds: [[Int]],
        into context: ModelContext
    ) {
        let session = Session(
            name: name,
            createdAt: createdAt,
            archivedAt: archivedAt,
            playerNames: players
        )
        context.insert(session)
        for (i, row) in rounds.enumerated() {
            let round = Round(index: i + 1, createdAt: createdAt.addingTimeInterval(Double(i) * 600))
            round.session = session
            context.insert(round)
            for (p, playerName) in players.enumerated() where p < row.count {
                let ps = PlayerScore(playerName: playerName, value: row[p])
                ps.round = round
                context.insert(ps)
            }
        }
    }
}

/// Root view used only in screenshot mode. Picks one screen and renders it
/// inside a `NavigationStack` so toolbars and titles match the real app.
struct ScreenshotRoot: View {
    @Query(sort: \Session.createdAt, order: .reverse) private var sessions: [Session]

    var body: some View {
        Group {
            if let session = sessions.first {
                switch ScreenshotMode.screen {
                case .session:
                    NavigationStack { SessionView(session: session) }
                case .summary:
                    NavigationStack { SummaryView(session: session) }
                case .roundEntry:
                    NavigationStack {
                        SessionView(session: session)
                            .sheet(isPresented: .constant(true)) {
                                RoundEntryView(
                                    session: session,
                                    mode: .new,
                                    prefill: ScreenshotMode.roundEntryPrefill
                                )
                            }
                    }
                case .newSession:
                    NavigationStack { NewSessionView() }
                case .history:
                    NavigationStack { HistoryView() }
                }
            } else {
                Color.phormSurfaceCinnabar.ignoresSafeArea()
            }
        }
        .preferredColorScheme(.dark)
        .tint(.phormPrimary)
    }
}
