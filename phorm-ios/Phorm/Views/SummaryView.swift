import SwiftUI

struct SummaryView: View {
    let session: Session

    @Environment(\.dismiss) private var dismiss
    @State private var showNewSession = false

    private var ranking: [(name: String, total: Int)] { Totals.ranking(for: session) }

    private var durationStr: String {
        let interval = (session.archivedAt ?? .now).timeIntervalSince(session.createdAt)
        let h = Int(interval) / 3600
        let m = (Int(interval) % 3600) / 60
        return h > 0 ? "\(h)g \(m)p" : "\(m)p"
    }

    private var dateStr: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "dd.MM"
        return f.string(from: session.archivedAt ?? session.createdAt)
    }

    private var metaLine: String {
        "\((session.rounds ?? []).count) vòng · \(durationStr) · \(dateStr)"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerStrip
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.xs)
                        .padding(.bottom, Spacing.md)

                    LacquerThickRule()
                        .padding(.horizontal, Spacing.lg)

                    if let champ = ranking.first {
                        championBlock(name: champ.name, total: champ.total)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.xl)
                            .padding(.bottom, Spacing.lg)
                    }

                    if ranking.count > 1 {
                        runnersBlock
                            .padding(.horizontal, Spacing.lg)
                            .padding(.bottom, Spacing.xl)
                    }

                    if let last = ranking.last,
                       ranking.count >= 4,
                       last.name != ranking.first?.name {
                        lastPlaceBlock(name: last.name)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.bottom, Spacing.xxl)
                    }

                    Spacer().frame(height: 120) // CTA clearance
                }
            }
            .scrollIndicators(.hidden)

            cta
        }
        .lacquerBackground(.phormSurfaceOxblood)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle("")
        .sheet(isPresented: $showNewSession) {
            NewSessionView()
                .preferredColorScheme(.dark)
        }
    }

    // MARK: - Header

    private var headerStrip: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "Phiên kết thúc", tone: .gold)
            Text(session.name)
                .font(.phormDisplayMd)
                .italic()
                .foregroundStyle(Color.phormCream)
                .lineLimit(2)
            Text(metaLine)
                .font(.phormCaptionSection)
                .tracking(1.6)
                .textCase(.uppercase)
                .foregroundStyle(Color.phormCreamDim)
        }
    }

    // MARK: - Champion

    @ViewBuilder
    private func championBlock(name: String, total: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionLabel(text: "Vô địch ván", tone: .gold)
            HStack(alignment: .lastTextBaseline) {
                Text(name)
                    .font(.system(size: 40, weight: .bold, design: .serif).italic())
                    .foregroundStyle(Color.phormCream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer()
                Text(ScoreFormat.signed(total))
                    .font(.phormNumberHero)
                    .foregroundStyle(Color.phormPrimary)
            }

            // ấn vàng tablet
            HStack(spacing: Spacing.sm) {
                Seal(glyph: "壹", variant: .winner, size: 26)
                Text("壹 · ấn vàng")
                    .font(.phormCaptionSection)
                    .tracking(1.8)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.phormGoldBright)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.black.opacity(0.22))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(Color.phormPrimary.opacity(0.55), lineWidth: 1)
            )
        }
    }

    // MARK: - Runners

    private var runnersBlock: some View {
        let runners = Array(ranking.dropFirst())
        let lastQualifies = ranking.count >= 4
        return VStack(spacing: Spacing.md) {
            ForEach(Array(runners.enumerated()), id: \.element.name) { idx, entry in
                let rank = idx + 2
                let isLastSeat = lastQualifies && rank == ranking.count
                HStack(alignment: .lastTextBaseline) {
                    Text(String(format: "%02d", rank))
                        .font(.phormNumberSm)
                        .foregroundStyle(Color.phormCreamDim)
                    Text(entry.name)
                        .font(.phormNameDisplay)
                        .foregroundStyle(Color.phormCream)
                    Spacer()
                    Text(ScoreFormat.signed(entry.total))
                        .font(.phormNumberEntry)
                        .foregroundStyle(ScoreFormat.color(for: entry.total))
                }
                .opacity(isLastSeat ? 0.78 : 1.0)
            }
        }
    }

    // MARK: - Last place

    @ViewBuilder
    private func lastPlaceBlock(name: String) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                SectionLabel(text: "Tem cuối bàn")
                Text(name)
                    .font(.phormNameMd)
                    .foregroundStyle(Color.phormCreamDim)
            }
            Spacer()
            Seal(glyph: "×", variant: .last, size: 28)
        }
        .padding(.top, Spacing.lg)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.phormCream.opacity(0.18))
                .frame(height: 1)
        }
    }

    // MARK: - CTA

    private var cta: some View {
        HStack(spacing: Spacing.sm) {
            if let url = try? SessionShare.url(for: session) {
                ShareLink(item: url) {
                    Text("Chia sẻ")
                        .font(.phormButton)
                        .tracking(2.0)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.phormPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .stroke(Color.phormPrimary, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            LacquerPrimaryButton(title: "Phiên mới") {
                showNewSession = true
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.sm)
        .background(
            LinearGradient(
                colors: [.clear, .phormSurfaceCinnabarDeep.opacity(0.55), .phormSurfaceCinnabarDeep.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 140)
            .allowsHitTesting(false),
            alignment: .bottom
        )
    }
}
