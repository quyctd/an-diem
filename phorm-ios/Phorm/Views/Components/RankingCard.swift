import SwiftUI

struct RankingCard: View {
    enum Position { case first, mid(Int), last }
    let position: Position
    let name: String
    let total: Int
    let wins: Int

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(glyph)
                .font(.system(size: 28))
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.phormTitleSm)
                    .foregroundStyle(Color.bodyText)
                Text("\(wins) ván thắng")
                    .font(.phormBodySm)
                    .foregroundStyle(Color.phormMuted)
            }
            Spacer()
            Text(totalFormatted)
                .font(.phormNumberRanking)
                .foregroundStyle(totalColor)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Color.surfaceCard)
        .overlay(border)
        .continuousRounded(Radius.lg)
    }

    private var glyph: String {
        switch position {
        case .first:        return "🥇"
        case .mid(2):       return "🥈"
        case .mid(3):       return "🥉"
        case .mid(let n):   return "\(n)"
        case .last:         return "💀"
        }
    }

    private var totalFormatted: String { total > 0 ? "+\(total)" : "\(total)" }

    private var totalColor: Color {
        if total > 0 { return .scorePositive }
        if total < 0 { return .scoreNegative }
        return .bodyText
    }

    @ViewBuilder
    private var border: some View {
        switch position {
        case .first:
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .strokeBorder(Color.phormPrimary, lineWidth: 2)
        case .last:
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .strokeBorder(Color.scoreNegative, lineWidth: 2)
        case .mid:
            EmptyView()
        }
    }
}
