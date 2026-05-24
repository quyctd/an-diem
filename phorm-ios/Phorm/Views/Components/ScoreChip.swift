import SwiftUI

struct ScoreChip: View {
    let playerName: String
    let value: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text(playerName)
                .font(.phormCaption)
                .foregroundStyle(Color.mutedStrong)
            Text(formatted)
                .font(.phormNumberChip)
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 8)
        .background(background)
        .continuousRounded(Radius.md)
    }

    private var formatted: String {
        if value > 0 { return "+\(value)" }
        return "\(value)" // negatives already carry their sign
    }

    private var valueColor: Color {
        if value > 0 { return .scorePositive }
        if value < 0 { return .scoreNegative }
        return .bodyText
    }

    private var background: Color {
        if value > 0 { return .scorePositiveTint }
        if value < 0 { return .scoreNegativeTint }
        return .surfaceElevated
    }
}
