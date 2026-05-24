import SwiftUI

struct HistoryRow: View {
    let session: Session

    private var relativeTime: String {
        RelativeDateTimeFormatter().localizedString(
            for: session.createdAt, relativeTo: .now
        )
    }

    private var winner: (name: String, total: Int)? {
        Totals.ranking(for: session).first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(session.name)
                    .font(.phormTitleSm)
                    .foregroundStyle(Color.bodyText)
                Spacer()
                Text(relativeTime)
                    .font(.phormCaption)
                    .foregroundStyle(Color.phormMuted)
            }
            Text(session.playerNames.joined(separator: " · "))
                .font(.phormBodySm)
                .foregroundStyle(Color.phormMuted)
            HStack(spacing: Spacing.xs) {
                Text("\((session.rounds ?? []).count) ván")
                    .font(.phormCaption)
                    .foregroundStyle(Color.bodyText)
                    .padding(.horizontal, Spacing.xs + 2)
                    .padding(.vertical, 4)
                    .background(Color.surfaceElevated)
                    .continuousRounded(Radius.sm)
                if let w = winner, w.total > 0 {
                    Text("🥇 \(w.name) +\(w.total)")
                        .font(.phormCaption.weight(.semibold))
                        .foregroundStyle(Color.scorePositive)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.surfaceCard)
        .continuousRounded(Radius.lg)
    }
}
