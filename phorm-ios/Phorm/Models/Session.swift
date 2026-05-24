import Foundation
import SwiftData

@Model
final class Session {
    var id: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date.now
    var archivedAt: Date?
    var playerNames: [String] = []

    @Relationship(deleteRule: .cascade, inverse: \Round.session)
    var rounds: [Round]? = []

    init(
        id: UUID = UUID(),
        name: String = "",
        createdAt: Date = .now,
        archivedAt: Date? = nil,
        playerNames: [String] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.archivedAt = archivedAt
        self.playerNames = playerNames
    }
}
