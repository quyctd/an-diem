import SwiftUI

/// History list entry — tactile cream card with a Tết-red accent edge.
/// Matches `.h-card` in themes-preview.html (1D).
struct HistoryRow: View {
    let session: Session

    private var dateLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "dd.MM · EEEE"
        return f.string(from: session.createdAt)
    }

    private var winner: (name: String, total: Int)? {
        Totals.ranking(for: session).first
    }

    private var playersLine: String {
        session.playerNames.joined(separator: " · ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.phormPrimary)
                .frame(width: 3)

            HStack(alignment: .top, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateLabel)
                        .font(.phormCaptionSection)
                        .tracking(1.6)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.phormCreamDim)
                    Text(session.name)
                        .font(.phormNameMd)
                        .foregroundStyle(Color.bodyText)
                        .lineLimit(1)
                    Text(playersLine)
                        .font(.phormNumberSm)
                        .foregroundStyle(Color.phormCreamDim)
                        .lineLimit(1)
                }
                Spacer(minLength: Spacing.sm)
                VStack(alignment: .trailing, spacing: 2) {
                    SectionLabel(text: winner == nil ? "Chưa có" : "Vô địch")
                    if let w = winner {
                        Text(ScoreFormat.signed(w.total))
                            .font(.phormNumberRanking)
                            .foregroundStyle(w.total > 0 ? Color.phormPrimary : Color.bodyText)
                    } else {
                        Text("—")
                            .font(.phormNumberMd)
                            .foregroundStyle(Color.phormCreamDim)
                    }
                }
            }
            .padding(.vertical, Spacing.sm)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .tactileCard(radius: 14)
    }
}
