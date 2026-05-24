import SwiftUI

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
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Ván \(round.index)")
                    .font(.phormCaption.weight(.semibold))
                    .foregroundStyle(Color.phormMuted)
                Spacer()
                Text(timestamp)
                    .font(.phormCaption)
                    .foregroundStyle(Color.phormMuted)
            }

            FlowLayout(spacing: Spacing.sm) {
                ForEach(playerOrder, id: \.self) { name in
                    HStack(spacing: 4) {
                        Text(name).font(.phormBodyMd).foregroundStyle(Color.phormMuted)
                        Text(format(scoreByName[name] ?? 0))
                            .font(.phormNumberMd)
                            .foregroundStyle(color(for: scoreByName[name] ?? 0))
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.surfaceCard)
        .continuousRounded(Radius.lg)
    }

    private func format(_ v: Int) -> String { v > 0 ? "+\(v)" : "\(v)" }
    private func color(for v: Int) -> Color {
        if v > 0 { return .scorePositive }
        if v < 0 { return .scoreNegative }
        return .bodyText
    }
}
