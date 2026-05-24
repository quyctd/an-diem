import SwiftUI

struct RoundEntryView: View {
    enum Mode {
        case new
        case edit(Round)
    }
    let session: Session
    let mode: Mode
    var body: some View { Text("RoundEntryView stub") }
}
