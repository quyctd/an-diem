import Testing
import SwiftData
import Foundation
@testable import Phorm

@MainActor
@Suite("SessionActions")
struct SessionActionsTests {
    // Retains the container for the lifetime of the test suite.
    static var _container: ModelContainer?

    static func makeContext() throws -> ModelContext {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        let container = try ModelContainer(for: schema, configurations: [config])
        _container = container   // keep alive
        return container.mainContext
    }

    @Test func archiveActiveSetsArchivedAt() throws {
        let ctx = try Self.makeContext()
        let s = Session(playerNames: ["An"])
        ctx.insert(s)
        try ctx.save()
        #expect(s.archivedAt == nil)

        try SessionActions.archiveActive(in: ctx)
        #expect(s.archivedAt != nil)
    }

    @Test func createSessionArchivesPreviousActive() throws {
        let ctx = try Self.makeContext()
        let first = Session(name: "first", playerNames: ["An"])
        ctx.insert(first)
        try ctx.save()

        let second = try SessionActions.createSession(
            name: "second",
            playerNames: ["Bình", "Cường"],
            in: ctx
        )

        #expect(first.archivedAt != nil)
        #expect(second.archivedAt == nil)
        #expect(second.playerNames == ["Bình", "Cường"])
    }

    @Test func appendRoundIncrementsIndex() throws {
        let ctx = try Self.makeContext()
        let s = try SessionActions.createSession(
            name: "t", playerNames: ["An", "Bình"], in: ctx
        )

        try SessionActions.appendRound(scores: ["An": -3, "Bình": 3], to: s, in: ctx)
        try SessionActions.appendRound(scores: ["An": 2,  "Bình": -2], to: s, in: ctx)

        let rounds = (s.rounds ?? []).sorted { $0.index < $1.index }
        #expect(rounds.map(\.index) == [1, 2])
        #expect(rounds[0].scores?.count == 2)
    }

    @Test func deleteRoundCascadesPlayerScores() throws {
        let ctx = try Self.makeContext()
        let s = try SessionActions.createSession(
            name: "t", playerNames: ["An", "Bình"], in: ctx
        )
        try SessionActions.appendRound(scores: ["An": -3, "Bình": 3], to: s, in: ctx)
        let round = (s.rounds ?? []).first!

        try SessionActions.deleteRound(round, in: ctx)

        let remaining = try ctx.fetch(FetchDescriptor<PlayerScore>())
        #expect(remaining.isEmpty)
        #expect((s.rounds ?? []).isEmpty)
    }

    @Test func updateRoundReplacesScores() throws {
        let ctx = try Self.makeContext()
        let s = try SessionActions.createSession(
            name: "t", playerNames: ["An", "Bình"], in: ctx
        )
        try SessionActions.appendRound(scores: ["An": -3, "Bình": 3], to: s, in: ctx)
        let round = (s.rounds ?? []).first!

        try SessionActions.updateRound(round, scores: ["An": 5, "Bình": -5], in: ctx)

        let scores = Dictionary(
            uniqueKeysWithValues: (round.scores ?? []).map { ($0.playerName, $0.value) }
        )
        #expect(scores == ["An": 5, "Bình": -5])
    }
}
