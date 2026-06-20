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

    // Đóng dấu — stamp fields. All optional; nil = not yet stamped.
    // EXIF-normalized JPEG, longest edge 1080px, ≤ ~500KB.
    var coverPhoto: Data?
    var winnerSealCoord: SealCoord?
    var loserCrossCoord: SealCoord?

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

/// Normalized photo-space coordinates for a face stamp.
/// (0,0) = photo top-left · (1,1) = photo bottom-right · independent of display crop.
struct SealCoord: Codable, Equatable {
    var x: Double
    var y: Double
}
