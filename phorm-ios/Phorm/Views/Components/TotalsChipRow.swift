import SwiftUI

struct TotalsChipRow: View {
    let session: Session

    private var ordered: [(name: String, total: Int)] {
        Totals.ranking(for: session)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("TỔNG")
                .font(.phormCaptionSection)
                .tracking(0.6).textCase(.uppercase)
                .foregroundStyle(Color.phormMuted)
                .padding(.horizontal, Spacing.md)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(ordered, id: \.name) { entry in
                        ScoreChip(playerName: entry.name, value: entry.total)
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
        .padding(.vertical, Spacing.sm)
        .background(Color.surfaceCard)
    }
}
