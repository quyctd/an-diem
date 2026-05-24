import Testing
import SwiftData
@testable import Phorm

@MainActor
@Suite("Totals")
struct TotalsTests {
    /// In-memory ModelContainer fixture — no CloudKit, no disk.
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    @Test func emptySessionReturnsAllZeros() throws {
        let container = try Self.makeContainer()
        let ctx = container.mainContext
        let session = Session(playerNames: ["An", "Bình", "Cường", "Dũng"])
        ctx.insert(session)

        let totals = Totals.cumulative(for: session)
        #expect(totals == ["An": 0, "Bình": 0, "Cường": 0, "Dũng": 0])
    }

    @Test func multiRoundSumsCorrectly() throws {
        let container = try Self.makeContainer()
        let ctx = container.mainContext
        let session = Session(playerNames: ["An", "Bình", "Cường"])
        ctx.insert(session)

        for (idx, scores) in [
            ["An": -5, "Bình": 2, "Cường": 3],
            ["An": 1,  "Bình": -4, "Cường": 3]
        ].enumerated() {
            let r = Round(index: idx + 1)
            r.session = session
            ctx.insert(r)
            for (name, v) in scores {
                let s = PlayerScore(playerName: name, value: v)
                s.round = r
                ctx.insert(s)
            }
        }

        let totals = Totals.cumulative(for: session)
        #expect(totals == ["An": -4, "Bình": -2, "Cường": 6])
    }

    @Test func rankingSortsDescendingWithTieBreakByName() throws {
        let container = try Self.makeContainer()
        let ctx = container.mainContext
        let session = Session(playerNames: ["Zebra", "Alpha", "Beta"])
        ctx.insert(session)
        let r = Round(index: 1)
        r.session = session
        ctx.insert(r)
        for (name, v) in [("Zebra", 5), ("Alpha", 5), ("Beta", -10)] {
            let s = PlayerScore(playerName: name, value: v)
            s.round = r
            ctx.insert(s)
        }

        let ranking = Totals.ranking(for: session)
        #expect(ranking.map(\.name) == ["Alpha", "Zebra", "Beta"])
        #expect(ranking.map(\.total) == [5, 5, -10])
    }
}
