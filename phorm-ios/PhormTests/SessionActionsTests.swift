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
}
