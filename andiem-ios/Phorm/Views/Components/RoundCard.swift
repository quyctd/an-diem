import SwiftUI

/// Single-round detail card — tactile cream card with a Tết-red accent edge.
struct RoundCard: View {
    let round: Round
    let playerOrder: [String]

    private var timestamp: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: round.createdAt)
    }

    private var scoreByName: [String: Int] {
        Dictionary(
            uniqueKeysWithValues: (round.scores ?? []).map { ($0.playerName, $0.value) }
        )
    }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.phormPrimary)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Vòng \(round.index)")
                        .font(.phormCaptionSection)
                        .tracking(1.6)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.phormGoldBright)
                    Spacer()
                    Text(timestamp)
                        .font(.phormNumberSm)
                        .foregroundStyle(Color.phormCreamDim)
                }

                VStack(spacing: 6) {
                    ForEach(playerOrder, id: \.self) { name in
                        let value = scoreByName[name] ?? 0
                        HStack {
                            Text(name)
                                .font(.phormNameMd)
                                .foregroundStyle(Color.bodyText)
                            Spacer()
                            Text(ScoreFormat.signed(value))
                                .font(.phormNumberMd)
                                .foregroundStyle(ScoreFormat.color(for: value))
                        }
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
