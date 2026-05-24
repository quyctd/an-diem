import SwiftUI

struct SumIndicator: View {
    let sum: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: isOk ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(isOk ? Color.scorePositive : Color.warning)
            Text("Tổng các ô")
                .font(.phormCaption)
                .foregroundStyle(Color.mutedStrong)
            Text(isOk ? "0 ✓" : "\(sum) ⚠")
                .font(.phormTitleSm)
                .foregroundStyle(isOk ? Color.scorePositive : Color.warning)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 10)
        .background(background)
        .continuousRounded(Radius.md)
    }

    private var isOk: Bool { sum == 0 }
    private var background: Color {
        isOk ? Color.scorePositiveTint : Color.warning.opacity(0.14)
    }
}
