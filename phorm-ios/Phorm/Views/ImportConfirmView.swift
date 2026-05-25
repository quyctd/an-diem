import SwiftUI
import SwiftData

struct ImportConfirmView: View {
    let dto: SessionDTO
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.phormPrimary)
                        .frame(width: 80, height: 80)
                    Text("📥").font(.system(size: 36))
                }
                .padding(.top, Spacing.lg)
                Text("Nhận session")
                    .font(.phormTitleLg)
                    .foregroundStyle(Color.bodyText)
                Text("Ai đó gửi cho bạn 1 session qua AirDrop")
                    .font(.phormBodySm)
                    .foregroundStyle(Color.phormMuted)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(dto.name)
                    .font(.phormTitleSm)
                    .foregroundStyle(Color.bodyText)
                Text(dto.players.joined(separator: " · "))
                    .font(.phormBodySm)
                    .foregroundStyle(Color.phormMuted)
                HStack(spacing: Spacing.xs) {
                    chip("\(dto.players.count) người")
                    chip("\(dto.rounds.count) ván")
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceElevated)
            .continuousRounded(Radius.lg)

            Text("Session đang chơi của bạn sẽ tự lưu vào History trước khi mở session này.")
                .font(.phormCaption)
                .foregroundStyle(Color.phormMuted)
                .multilineTextAlignment(.center)

            VStack(spacing: Spacing.sm) {
                Button(action: confirm) {
                    Text("Mở session này")
                        .font(.phormButton)
                        .foregroundStyle(Color.onPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.phormPrimary)
                        .continuousRounded(Radius.lg)
                }
                Button("Hủy") {
                    onDismiss(); dismiss()
                }
                .foregroundStyle(Color.phormPrimary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.canvas)
        .presentationDetents([.medium, .large])
        .presentationBackground(Color.canvas)
    }

    private func chip(_ s: String) -> some View {
        Text(s)
            .font(.phormCaption)
            .foregroundStyle(Color.bodyText)
            .padding(.horizontal, Spacing.xs + 2)
            .padding(.vertical, 4)
            .background(Color.surfaceCard)
            .continuousRounded(Radius.sm)
    }

    private func confirm() {
        do {
            _ = try SessionActions.importSession(dto, in: context)
            onDismiss()
            dismiss()
        } catch {
            print("import failed: \(error)")
        }
    }
}
