import SwiftUI
import SwiftData

struct ImportConfirmView: View {
    let dto: SessionDTO
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    headerStrip
                    LacquerHairline()
                    detailBlock
                    Text("Phiên đang chơi của bạn sẽ tự đóng vào lịch sử trước khi mở phiên này.")
                        .font(.phormBodySm)
                        .foregroundStyle(Color.phormCream.opacity(0.6))
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xl)
            }
            .scrollIndicators(.hidden)

            cta
        }
        .lacquerBackground(.phormSurfaceOchre)
        .presentationBackground(Color.phormSurfaceOchre)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }

    private var headerStrip: some View {
        HStack(alignment: .top) {
            Seal(glyph: "印", variant: .winner, size: 36)
            VStack(alignment: .leading, spacing: 4) {
                SectionLabel(text: "Nhận phiên", tone: .gold)
                Text("Có ai vừa gửi")
                    .font(.phormTitleLg)
                    .italic()
                    .foregroundStyle(Color.phormCream)
            }
            Spacer()
        }
    }

    private var detailBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(dto.name)
                .font(.phormNameDisplay)
                .foregroundStyle(Color.phormCream)
                .lineLimit(2)
            Text(dto.players.joined(separator: " · "))
                .font(.phormNumberSm)
                .foregroundStyle(Color.phormCreamDim)
            HStack(spacing: Spacing.sm) {
                detailChip("\(dto.players.count) người")
                detailChip("\(dto.rounds.count) vòng")
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(Color.black.opacity(0.20))
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.phormCream.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

    private func detailChip(_ s: String) -> some View {
        Text(s)
            .font(.phormCaptionSection)
            .tracking(1.6)
            .textCase(.uppercase)
            .foregroundStyle(Color.phormGoldBright)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color.phormGoldBright.opacity(0.55), lineWidth: 1)
            )
    }

    private var cta: some View {
        VStack(spacing: Spacing.sm) {
            LacquerPrimaryButton(title: "Mở phiên này", action: confirm)
            Button {
                onDismiss(); dismiss()
            } label: {
                Text("Huỷ")
                    .font(.phormButton)
                    .tracking(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.phormCreamDim)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.sm)
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
