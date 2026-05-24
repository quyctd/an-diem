import Testing
import Foundation
import SwiftData
@testable import Phorm

@MainActor
@Suite("SessionShare")
struct SessionShareTests {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Helper: build a session with N rounds × M players, each with simple zero-sum scores.
    static func makeSession(in ctx: ModelContext, players: [String], rounds: Int) -> Session {
        let s = Session(playerNames: players)
        ctx.insert(s)
        for i in 0..<rounds {
            let r = Round(index: i + 1)
            r.session = s
            ctx.insert(r)
            for (idx, name) in players.enumerated() {
                let v = idx == 0 ? -(players.count - 1) : 1
                let ps = PlayerScore(playerName: name, value: v)
                ps.round = r
                ctx.insert(ps)
            }
        }
        return s
    }

    @Test func urlHasPhormImportScheme() throws {
        let container = try Self.makeContainer()
        let s = Self.makeSession(in: container.mainContext, players: ["An", "Bình"], rounds: 1)
        let url = try SessionShare.url(for: s)
        #expect(url.scheme == "phorm")
        #expect(url.host == "import")
        let q = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "s" })?.value
        #expect(q != nil && !q!.isEmpty)
    }

    @Test func realisticSessionFitsUnderSixKB() throws {
        let container = try Self.makeContainer()
        let s = Self.makeSession(in: container.mainContext,
                                 players: ["An", "Bình", "Cường", "Dũng"],
                                 rounds: 20)
        let url = try SessionShare.url(for: s)
        #expect(url.absoluteString.utf8.count < 6_000)
    }

    @Test func encodeDecodeRoundtrip() throws {
        let container = try Self.makeContainer()
        let original = Self.makeSession(in: container.mainContext,
                                        players: ["An", "Bình", "Cường"],
                                        rounds: 3)
        let originalDTO = SessionDTO(from: original)
        let url = try SessionShare.url(for: original)

        let decoded = try SessionShare.decode(url)
        #expect(decoded == originalDTO)
    }

    @Test func roundtripPreservesVietnameseDiacritics() throws {
        let container = try Self.makeContainer()
        let s = Self.makeSession(in: container.mainContext,
                                 players: ["Đức", "Bằng", "Hưng", "Hoàng"],
                                 rounds: 1)
        let url = try SessionShare.url(for: s)
        let decoded = try SessionShare.decode(url)
        #expect(decoded.players == ["Đức", "Bằng", "Hưng", "Hoàng"])
    }

    @Test func invalidSchemeThrows() {
        let url = URL(string: "https://example.com/import?s=abc")!
        #expect(throws: SessionShare.ShareError.self) {
            try SessionShare.decode(url)
        }
    }

    @Test func missingQueryThrows() {
        let url = URL(string: "phorm://import")!
        #expect(throws: SessionShare.ShareError.self) {
            try SessionShare.decode(url)
        }
    }
}
