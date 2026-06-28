import Testing
import Foundation
import SwiftData
@testable import Phorm

@MainActor
@Suite("ScreenshotSupport")
struct ScreenshotSupportTests {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: [config])
    }

    @Test func seedWithActiveSessionCreatesPopulatedLeaderboard() throws {
        let container = try Self.makeContainer()
        let ctx = container.mainContext
        ScreenshotSupport.seed(into: ctx, activeSession: true)

        let active = try ctx.fetch(FetchDescriptor<Session>(predicate: #Predicate { $0.archivedAt == nil }))
        #expect(active.count == 1)
        let s = active[0]
        #expect(s.playerNames == ["Quý", "Nam", "Linh", "Hoàng"])
        #expect((s.rounds ?? []).count == 6)

        // Deterministic leader is Quý, last is Hoàng.
        let ranking = Totals.ranking(for: s)
        #expect(ranking.first?.name == "Quý")
        #expect(ranking.last?.name == "Hoàng")

        // Archived sessions exist for History.
        let archived = try ctx.fetch(FetchDescriptor<Session>(predicate: #Predicate { $0.archivedAt != nil }))
        #expect(archived.count >= 3)
    }

    @Test func seedWithoutActiveSessionLeavesEmptyHome() throws {
        let container = try Self.makeContainer()
        let ctx = container.mainContext
        ScreenshotSupport.seed(into: ctx, activeSession: false)

        let active = try ctx.fetch(FetchDescriptor<Session>(predicate: #Predicate { $0.archivedAt == nil }))
        #expect(active.isEmpty)
        let archived = try ctx.fetch(FetchDescriptor<Session>(predicate: #Predicate { $0.archivedAt != nil }))
        #expect(archived.count >= 3)
    }
}
