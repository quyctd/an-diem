import Foundation
import SwiftData

/// The single mutation surface for Session / Round / PlayerScore.
/// Views call into here; they do not insert / delete on `ModelContext` directly.
/// This is where the "one active session at a time" invariant lives.
enum SessionActions {
    /// Mark every currently-active session (archivedAt == nil) as archived = now.
    /// Idempotent: safe to call when no active session exists.
    /// Note: fetches all sessions and filters in-memory to avoid #Predicate crashes
    /// with optional Date on in-memory SwiftData stores (iOS 17).
    static func archiveActive(in context: ModelContext) throws {
        let all = try context.fetch(FetchDescriptor<Session>())
        let active = all.filter { $0.archivedAt == nil }
        for session in active {
            session.archivedAt = .now
        }
        try context.save()
    }

    /// Archive the current active session (if any) and create a new one.
    /// Returns the inserted, saved Session.
    @discardableResult
    static func createSession(
        name: String,
        playerNames: [String],
        in context: ModelContext
    ) throws -> Session {
        try archiveActive(in: context)
        let session = Session(name: name, playerNames: playerNames)
        context.insert(session)
        try context.save()
        return session
    }

    /// Append a new round to the session with the given scores.
    /// `scores` keys should match `session.playerNames`; absent keys → 0 (sparse).
    static func appendRound(
        scores: [String: Int],
        to session: Session,
        in context: ModelContext
    ) throws {
        let nextIndex = (session.rounds ?? []).count + 1
        let round = Round(index: nextIndex)
        round.session = session
        context.insert(round)
        for name in session.playerNames {
            let value = scores[name] ?? 0
            let ps = PlayerScore(playerName: name, value: value)
            ps.round = round
            context.insert(ps)
        }
        try context.save()
    }

    /// Replace a round's PlayerScore set with the given map. Keeps the round's
    /// `index` and `createdAt` intact.
    static func updateRound(
        _ round: Round,
        scores: [String: Int],
        in context: ModelContext
    ) throws {
        for existing in round.scores ?? [] {
            context.delete(existing)
        }
        let players = round.session?.playerNames ?? Array(scores.keys)
        for name in players {
            let value = scores[name] ?? 0
            let ps = PlayerScore(playerName: name, value: value)
            ps.round = round
            context.insert(ps)
        }
        try context.save()
    }

    /// Delete a round; cascade rule on `Round.scores` removes child PlayerScores.
    static func deleteRound(_ round: Round, in context: ModelContext) throws {
        context.delete(round)
        try context.save()
    }

    /// End an active session (manual "Kết thúc"). Just sets archivedAt.
    static func endSession(_ session: Session, in context: ModelContext) throws {
        session.archivedAt = .now
        try context.save()
    }

    /// Archive the current active session, then materialize an incoming DTO
    /// into a new active Session (with all rounds + scores rebuilt).
    /// Returns the inserted, saved Session.
    @discardableResult
    static func importSession(
        _ dto: SessionDTO,
        in context: ModelContext
    ) throws -> Session {
        try archiveActive(in: context)
        let session = Session(
            id: dto.id,
            name: dto.name,
            createdAt: dto.createdAt,
            archivedAt: nil,
            playerNames: dto.players
        )
        context.insert(session)
        for roundDTO in dto.rounds.sorted(by: { $0.index < $1.index }) {
            let round = Round(index: roundDTO.index, createdAt: roundDTO.createdAt)
            round.session = session
            context.insert(round)
            for name in dto.players {
                let value = roundDTO.scores[name] ?? 0
                let ps = PlayerScore(playerName: name, value: value)
                ps.round = round
                context.insert(ps)
            }
        }
        try context.save()
        return session
    }
}
