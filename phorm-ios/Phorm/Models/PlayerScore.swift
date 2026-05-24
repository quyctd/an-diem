import Foundation
import SwiftData

@Model
final class PlayerScore {
    var playerName: String = ""
    var value: Int = 0
    var round: Round?

    init(playerName: String = "", value: Int = 0) {
        self.playerName = playerName
        self.value = value
    }
}
