import SwiftUI
import SwiftData
import UIKit

struct SummaryView: View {
    let session: Session

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showNewSession = false
    @State private var showStampFlow = false
    @State private var hasSkippedStamp = false
    @State private var shareCardImage: UIImage?
    @State private var showShareSheet = false

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

    /// Whether the session has a determined winner+loser (or just a single rank).
    /// Per spec E5: tied first or last disables Đóng dấu with explanatory caption.
    private var isRankTied: Bool {
        guard ranking.count >= 2 else { return false }
        // Tie at first or at last is the disqualifier.
        let first = ranking[0].total
        let second = ranking[1].total
        if first == second { return true }
        if ranking.count >= 3 {
            let last = ranking[ranking.count - 1].total
            let secondLast = ranking[ranking.count - 2].total
            if last == secondLast { return true }
        }
        return false
    }

    private var isStamped: Bool { session.coverPhoto != nil || session.winnerSealCoord != nil || session.loserCrossCoord != nil }
    private var showStampCallout: Bool { !hasSkippedStamp && !isStamped }
    private var showStampedCallout: Bool { isStamped }

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
                            .padding(.bottom, Spacing.lg)
                    }

                    if let last = ranking.last,
                       ranking.count >= 4,
                       last.name != ranking.first?.name {
                        lastPlaceBlock(name: last.name)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.bottom, Spacing.lg)
                    }

                    // Đóng dấu callout — between ranking and CTA.
                    if showStampedCallout {
                        stampedCallout
                            .padding(.horizontal, Spacing.lg)
                            .padding(.bottom, Spacing.lg)
                    } else if showStampCallout {
                        unstampedCallout
                            .padding(.horizontal, Spacing.lg)
                            .padding(.bottom, Spacing.lg)
                    }

                    Spacer().frame(height: 140) // CTA clearance
                }
            }
            .scrollIndicators(.hidden)

            cta
        }
        .lacquerBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle("")
        .sheet(isPresented: $showNewSession) {
            NewSessionView()
        }
        .fullScreenCover(isPresented: $showStampFlow) {
            StampEditorView(session: session)
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareCardImage {
                ShareSheet(image: shareCardImage)
                    .presentationBackground(Color.phormSurfaceCinnabar)
            }
        }
    }

    // MARK: - Header

    private var headerStrip: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "Phiên kết thúc", tone: .gold)
            Text(session.name)
                .font(.phormDisplayMd)
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
            SectionLabel(text: "Nhất bàn", tone: .gold)
            HStack(alignment: .center, spacing: Spacing.md) {
                Coin(text: "1", variant: .winner, size: 40)
                Text(name)
                    .font(.system(size: 40, weight: .bold, design: .default))
                    .foregroundStyle(Color.phormCream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer()
                ScoreChip(value: total, size: .large)
            }
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
                    ScoreChip(value: entry.total, size: .small)
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
                SectionLabel(text: "Bét bàn")
                Text(name)
                    .font(.phormNameMd)
                    .foregroundStyle(Color.phormCreamDim)
            }
            Spacer()
            Coin(text: "\(ranking.count)", variant: .last, size: 28)
        }
        .padding(.top, Spacing.lg)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.phormCream.opacity(0.18))
                .frame(height: 1)
        }
    }

    // MARK: - Đóng dấu callouts

    /// Dashed-gold callout shown when the session is unstamped and not skipped.
    /// Tied-rank case: same shape but disabled with explanatory caption.
    private var unstampedCallout: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            Coin(text: "1", variant: isRankTied ? .seat : .winner, size: 32)
                .opacity(isRankTied ? 0.55 : 1)
            VStack(alignment: .leading, spacing: 4) {
                SectionLabel(text: isRankTied ? "Chưa đóng dấu được" : "Chưa đóng dấu", tone: .gold)
                Text(isRankTied
                     ? "Hoà — chưa rõ ai nhất, ai bét"
                     : "Chụp ảnh nhóm — hoặc chọn ảnh có sẵn.")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundStyle(Color.phormCream.opacity(isRankTied ? 0.65 : 1))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color.phormPrimary.opacity(isRankTied ? 0.04 : 0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .stroke(
                    isRankTied ? Color.phormPrimaryDisabled : Color.phormPrimary,
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )
        )
    }

    /// Đã đóng dấu — photo thumbnail + label, tap to re-edit.
    private var stampedCallout: some View {
        Button {
            showStampFlow = true
        } label: {
            HStack(alignment: .center, spacing: Spacing.md) {
                if let thumb = ImageHelpers.image(from: session.coverPhoto) {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipped()
                        .overlay(
                            Rectangle()
                                .stroke(Color.phormPrimary, lineWidth: 1)
                        )
                } else {
                    // No-photo path: 印 ornament in place of thumbnail.
                    ZStack {
                        Rectangle().fill(Color.phormPrimary.opacity(0.12))
                        Text("印")
                            .font(.system(size: 24, weight: .heavy, design: .default))
                            .foregroundStyle(Color.phormPrimary)
                    }
                    .frame(width: 52, height: 52)
                    .overlay(Rectangle().stroke(Color.phormPrimary, lineWidth: 1))
                }
                VStack(alignment: .leading, spacing: 4) {
                    SectionLabel(text: "Đã đóng dấu", tone: .gold)
                    Text("Chạm để sửa hoặc chia sẻ lại")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundStyle(Color.phormCream)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.phormCreamDim)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.phormPrimary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color.phormPrimary, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA

    @ViewBuilder
    private var cta: some View {
        Group {
            if showStampCallout && !isRankTied {
                // F1: [Bỏ qua | Đóng dấu]
                HStack(spacing: Spacing.sm) {
                    LacquerOutlineButton(title: "Bỏ qua") {
                        hasSkippedStamp = true
                    }
                    LacquerPrimaryButton(title: "Đóng dấu") {
                        showStampFlow = true
                    }
                }
            } else {
                // Default / skipped / stamped / tied: [Chia sẻ | Phiên mới]
                HStack(spacing: Spacing.sm) {
                    LacquerOutlineButton(title: "Chia sẻ") {
                        renderAndShare()
                    }
                    LacquerPrimaryButton(title: "Phiên mới") {
                        showNewSession = true
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.sm)
        .background(
            LinearGradient(
                colors: [.clear, .phormSurfaceCinnabar.opacity(0.55), .phormSurfaceCinnabar.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 140)
            .allowsHitTesting(false),
            alignment: .bottom
        )
    }

    @MainActor
    private func renderAndShare() {
        guard let image = ShareCardView.render(session: session) else { return }
        shareCardImage = image
        showShareSheet = true
    }
}
