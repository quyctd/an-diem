import SwiftUI
import SwiftData

struct SessionView: View {
    let session: Session
    @Environment(\.modelContext) private var context
    @State private var showRoundEntry = false
    @State private var editingRound: Round?
    @State private var showEndConfirm = false
    @State private var deletingRound: Round?
    @State private var editingName = false
    @State private var nameDraft = ""
    @State private var showSummaryRoute = false
    @State private var showHistoryRoute = false

    private var sortedRounds: [Round] {
        (session.rounds ?? []).sorted { $0.index > $1.index }
    }

    private var ranking: [(name: String, total: Int)] {
        Totals.ranking(for: session)
    }

    /// Last 6 rounds' leader-score progression — the "Sáu vòng vừa qua" strip.
    /// Shows the current leader's per-round score across the most recent six rounds,
    /// chronologically ascending (oldest → newest left-to-right).
    private var recentLeaderStrip: [Int] {
        guard let leader = ranking.first?.name else { return [] }
        let chronological = (session.rounds ?? []).sorted { $0.index < $1.index }
        let slice = chronological.suffix(6)
        return slice.map { round in
            (round.scores ?? []).first(where: { $0.playerName == leader })?.value ?? 0
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    headerStrip
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.xs)
                        .padding(.bottom, Spacing.md)

                    LacquerHairline()
                        .padding(.horizontal, Spacing.lg)

                    leaderboardRows
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                        .padding(.bottom, Spacing.xl)

                    if !recentLeaderStrip.isEmpty {
                        recentStrip
                            .padding(.horizontal, Spacing.lg)
                            .padding(.bottom, Spacing.xl)
                    }

                    if !sortedRounds.isEmpty {
                        roundDetailsSection
                            .padding(.horizontal, Spacing.lg)
                            .padding(.bottom, 120) // CTA clearance
                    } else {
                        Spacer().frame(height: 120)
                    }
                }
            }
            .scrollIndicators(.hidden)

            cta
        }
        .lacquerBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: (try? SessionShare.url(for: session)) ?? URL(string: "phorm://error")!) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color.phormPrimary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    NavigationLink {
                        SummaryView(session: session)
                    } label: {
                        Label("Tổng kết", systemImage: "trophy")
                    }
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Label("Lịch sử", systemImage: "clock.arrow.circlepath")
                    }
                    Button {
                        showEndConfirm = true
                    } label: {
                        Label("Kết thúc phiên", systemImage: "checkmark.seal")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.phormPrimary)
                }
            }
        }
        .sheet(isPresented: $showRoundEntry) {
            RoundEntryView(session: session, mode: .new)
        }
        .sheet(item: $editingRound) { round in
            RoundEntryView(session: session, mode: .edit(round))
        }
        .alert("Kết thúc phiên?", isPresented: $showEndConfirm) {
            Button("Hủy", role: .cancel) {}
            Button("Kết thúc", role: .destructive) {
                try? SessionActions.endSession(session, in: context)
            }
        }
        .confirmationDialog(
            "Xóa vòng \(deletingRound?.index ?? 0)?",
            isPresented: Binding(
                get: { deletingRound != nil },
                set: { if !$0 { deletingRound = nil } }
            ),
            presenting: deletingRound
        ) { round in
            Button("Xóa", role: .destructive) {
                try? SessionActions.deleteRound(round, in: context)
            }
            Button("Hủy", role: .cancel) {}
        } message: { _ in
            Text("Không thể hoàn tác.")
        }
        .navigationDestination(isPresented: $showSummaryRoute) {
            SummaryView(session: session)
        }
        .navigationDestination(isPresented: $showHistoryRoute) {
            HistoryView()
        }
        #if DEBUG
        .onAppear {
            switch ScreenshotSupport.openTarget {
            case .roundEntry: showRoundEntry = true
            case .summary:    showSummaryRoute = true
            case .history:    showHistoryRoute = true
            default:          break
            }
        }
        #endif
    }

    // MARK: - Header

    private var headerStrip: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                SectionLabel(text: "Phiên đang chơi")
                Group {
                    if editingName {
                        TextField("Tên phiên", text: $nameDraft, onCommit: commitName)
                            .font(.phormTitleLg)
                            .foregroundStyle(Color.phormCream)
                            .submitLabel(.done)
                    } else {
                        Text(session.name)
                            .font(.phormTitleLg)
                            .foregroundStyle(Color.phormCream)
                            .onTapGesture {
                                nameDraft = session.name
                                editingName = true
                            }
                    }
                }
            }
            Spacer(minLength: Spacing.md)
            VStack(alignment: .trailing, spacing: 6) {
                SectionLabel(text: "Vòng")
                Text(String(format: "%02d", (session.rounds ?? []).count))
                    .font(.phormTitleLg)
                    .foregroundStyle(Color.phormCream)
                    .monospacedDigit()
            }
        }
    }

    private func commitName() {
        let trimmed = nameDraft.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { session.name = trimmed }
        editingName = false
    }

    // MARK: - Leaderboard

    private var leaderboardRows: some View {
        VStack(spacing: Spacing.lg) {
            ForEach(Array(ranking.enumerated()), id: \.element.name) { idx, entry in
                leaderboardRow(rank: idx + 1, entry: entry, totalPlayers: ranking.count)
            }
        }
    }

    @ViewBuilder
    private func leaderboardRow(rank: Int, entry: (name: String, total: Int), totalPlayers: Int) -> some View {
        HStack(spacing: Spacing.md) {
            Coin(
                text: SealGlyph.forRank(rank),
                variant: coinVariant(rank: rank, total: entry.total, totalPlayers: totalPlayers)
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.phormNameDisplay)
                    .foregroundStyle(Color.phormCream)
                SectionLabel(text: subtitle(rank: rank, total: entry.total, totalPlayers: totalPlayers))
            }
            Spacer(minLength: Spacing.sm)
            Text(ScoreFormat.signed(entry.total))
                .font(.phormNumberRanking)
                .foregroundStyle(ScoreFormat.color(for: entry.total))
        }
    }

    private func sealVariant(rank: Int, total: Int, totalPlayers: Int) -> Seal.Variant {
        if rank == 1 && total > 0 { return .winner }
        if rank == totalPlayers && totalPlayers >= 4 && total <= 0 { return .last }
        return .default
    }

    private func coinVariant(rank: Int, total: Int, totalPlayers: Int) -> Coin.Variant {
        if rank == 1 && total > 0 { return .winner }
        if rank == totalPlayers && totalPlayers >= 4 && total <= 0 { return .last }
        return .seat
    }

    private func subtitle(rank: Int, total: Int, totalPlayers: Int) -> String {
        guard !ranking.isEmpty else { return "" }
        if rank == 1 { return "Đang dẫn" }
        if rank == 2 && total > ranking[0].total - 5 { return "Sát nút" }
        if rank == totalPlayers { return "Đi sau" }
        return "—"
    }

    // MARK: - Recent strip

    private var recentStrip: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: stripLabel)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                spacing: 8
            ) {
                ForEach(Array(recentLeaderStrip.enumerated()), id: \.offset) { _, value in
                    Text(ScoreFormat.signed(value))
                        .font(.phormNumberSm)
                        .foregroundStyle(ScoreFormat.color(for: value))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(Color.black.opacity(0.18))
                        )
                }
            }
        }
    }

    private var stripLabel: String {
        let n = recentLeaderStrip.count
        guard let leader = ranking.first?.name, n > 0 else { return "" }
        return "\(numberWord(n)) vòng · \(leader)"
    }

    private func numberWord(_ n: Int) -> String {
        switch n {
        case 1: return "Một"
        case 2: return "Hai"
        case 3: return "Ba"
        case 4: return "Bốn"
        case 5: return "Năm"
        case 6: return "Sáu"
        default: return "\(n)"
        }
    }

    // MARK: - Round details (scroll past leaderboard to see / edit)

    private var roundDetailsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text("Từng vòng")
                    .font(.phormNameMd)
                    .foregroundStyle(Color.phormCream)
                Spacer()
                Text("chạm để sửa")
                    .font(.system(size: 12, weight: .regular, design: .serif).italic())
                    .foregroundStyle(Color.phormCreamDim)
            }
            VStack(spacing: Spacing.sm) {
                ForEach(sortedRounds) { round in
                    RoundCard(round: round, playerOrder: session.playerNames)
                        .contentShape(Rectangle())
                        .onTapGesture { editingRound = round }
                        .contextMenu {
                            Button(role: .destructive) {
                                deletingRound = round
                            } label: {
                                Label("Xóa", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    // MARK: - CTA

    private var cta: some View {
        LacquerPrimaryButton(
            title: "+ Vòng \((session.rounds ?? []).count + 1)"
        ) {
            showRoundEntry = true
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.sm)
        .background(
            LinearGradient(
                colors: [.clear, .phormSurfaceCinnabarDeep.opacity(0.55), .phormSurfaceCinnabarDeep.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 140)
            .allowsHitTesting(false),
            alignment: .bottom
        )
    }
}
