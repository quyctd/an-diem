import SwiftUI

struct SummaryView: View {
    let session: Session

    private var ranking: [(name: String, total: Int)] { Totals.ranking(for: session) }

    private var winsByPlayer: [String: Int] {
        var wins: [String: Int] = [:]
        for round in session.rounds ?? [] {
            let scores = round.scores ?? []
            if let max = scores.map(\.value).max() {
                for s in scores where s.value == max && s.value > 0 {
                    wins[s.playerName, default: 0] += 1
                }
            }
        }
        return wins
    }

    private var durationStr: String {
        let interval = (session.archivedAt ?? .now).timeIntervalSince(session.createdAt)
        let h = Int(interval) / 3600
        let m = (Int(interval) % 3600) / 60
        return h > 0 ? "\(h)h \(m)p" : "\(m)p"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                VStack(spacing: 8) {
                    Text("🏆").font(.system(size: 32))
                    Text(session.name)
                        .font(.phormTitleLg)
                        .foregroundStyle(Color.bodyText)
                    Text("\((session.rounds ?? []).count) ván · \(session.playerNames.count) người · \(durationStr)")
                        .font(.phormBodySm)
                        .foregroundStyle(Color.phormMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .background(Color.surfaceCard)
                .continuousRounded(Radius.lg)

                ForEach(Array(ranking.enumerated()), id: \.offset) { i, entry in
                    RankingCard(
                        position: position(for: i, total: ranking.count),
                        name: entry.name,
                        total: entry.total,
                        wins: winsByPlayer[entry.name] ?? 0
                    )
                }

                if let url = try? SessionShare.url(for: session) {
                    ShareLink(item: url) {
                        Text("⤴ Chia sẻ session")
                            .font(.phormButton)
                            .foregroundStyle(Color.onPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.phormPrimary)
                            .continuousRounded(Radius.lg)
                    }
                    .padding(.top, Spacing.md)
                }
            }
            .padding(Spacing.lg)
        }
        .background(Color.canvas)
        .navigationTitle("Tổng kết")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func position(for index: Int, total: Int) -> RankingCard.Position {
        if index == 0 { return .first }
        if index == total - 1 && total >= 4 { return .last }
        return .mid(index + 1)
    }
}
