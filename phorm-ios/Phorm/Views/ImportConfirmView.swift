import SwiftUI

struct ImportConfirmView: View {
    let dto: SessionDTO
    let onDismiss: () -> Void
    var body: some View { Text("ImportConfirmView — \(dto.name)") }
}
