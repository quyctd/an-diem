import SwiftUI

/// Single-round detail card on the lacquer surface — gold left edge + dark tint.
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
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
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
                                .foregroundStyle(Color.phormCream.opacity(0.86))
                            Spacer()
                            Text(ScoreFormat.signed(value))
                                .font(.phormNumberMd)
                                .foregroundStyle(ScoreFormat.color(for: value))
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
        .background(Color.black.opacity(0.18))
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.phormCream.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}
