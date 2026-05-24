import Foundation
import SwiftData

@Model
final class Round {
    var id: UUID = UUID()
    var index: Int = 0
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \PlayerScore.round)
    var scores: [PlayerScore]? = []

    var session: Session?

    init(
        id: UUID = UUID(),
        index: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.index = index
        self.createdAt = createdAt
    }
}
