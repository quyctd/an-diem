import SwiftUI
import SwiftData

struct RoundEntryView: View {
    enum Mode {
        case new
        case edit(Round)
    }

    let session: Session
    let mode: Mode

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var draft: RoundDraft
    @State private var showDeleteConfirm = false

    init(session: Session, mode: Mode, prefill: [String: Int]? = nil) {
        self.session = session
        self.mode = mode
        switch mode {
        case .new:
            _draft = State(initialValue: RoundDraft(playerNames: session.playerNames, existing: prefill))
        case .edit(let round):
            let map = Dictionary(
                uniqueKeysWithValues: (round.scores ?? []).map { ($0.playerName, $0.value) }
            )
            _draft = State(initialValue: RoundDraft(playerNames: session.playerNames, existing: map))
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerStrip
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)

                    titleBlock
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)

                    playerCells
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.xl)

                    validationRow
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)

                    Spacer().frame(height: 360) // keypad + CTA clearance
                }
            }
            .scrollIndicators(.hidden)

            bottomDock
        }
        .appBackground(.phormSurfaceCinnabar)
        .presentationBackground(Color.phormSurfaceCinnabar)
        .presentationDragIndicator(.visible)
        .confirmationDialog("Xóa vòng này?", isPresented: $showDeleteConfirm) {
            if case .edit(let round) = mode {
                Button("Xóa", role: .destructive) {
                    try? SessionActions.deleteRound(round, in: context)
                    dismiss()
                }
            }
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Không thể hoàn tác.")
        }
    }

    // MARK: - Header

    private var headerStrip: some View {
        HStack(alignment: .center) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.phormCreamDim)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.surfaceTile))
                    .overlay(Circle().strokeBorder(Color.hairline, lineWidth: 1))
            }
            Spacer()
            SectionLabel(text: headerLabel)
            Spacer()
            Group {
                if case .edit = mode {
                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.scoreNegative)
                            .frame(width: 32, height: 32)
                    }
                } else {
                    Color.clear.frame(width: 32, height: 32)
                }
            }
        }
    }

    private var headerLabel: String {
        switch mode {
        case .new:     return "Ghi vòng"
        case .edit:    return "Sửa vòng"
        }
    }

    // MARK: - Title block

    private var titleBlock: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(roundDisplayTitle)
                    .font(.phormDisplayMd)
                    .foregroundStyle(Color.phormPrimary)
                Text("điểm ai bao nhiêu?")
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .foregroundStyle(Color.phormCreamDim)
            }
            Spacer()
            Text(String(format: "%02d", roundIndex))
                .font(.phormNumberMd)
                .foregroundStyle(Color.phormCreamDim)
        }
    }

    private var roundIndex: Int {
        switch mode {
        case .new:           return (session.rounds ?? []).count + 1
        case .edit(let r):   return r.index
        }
    }

    private var roundDisplayTitle: String {
        "Vòng \(vietnameseNumeral(roundIndex))"
    }

    private func vietnameseNumeral(_ n: Int) -> String {
        let units = ["không","một","hai","ba","bốn","năm","sáu","bảy","tám","chín"]
        if n < 10 { return units[n] }
        if n < 20 {
            let u = n - 10
            return u == 0 ? "mười" : "mười \(units[u])"
        }
        if n < 100 {
            let t = n / 10, u = n % 10
            return u == 0 ? "\(units[t]) mươi" : "\(units[t]) mươi \(units[u])"
        }
        return "\(n)"
    }

    // MARK: - Player cells

    private var playerCells: some View {
        VStack(spacing: Spacing.md) {
            ForEach(Array(draft.playerNames.enumerated()), id: \.offset) { idx, name in
                playerRow(idx: idx, name: name)
            }
        }
    }

    /// One player row: Coin seat token + name + ScoreChip.
    ///
    /// Visual hierarchy:
    ///   • Focused row  — surfaceTile card + shadow + .large chip (isFocused border) + .winner coin.
    ///   • Auto-fill row — gold tint throughout; whole row at 0.72 opacity (single quieted treatment).
    ///   • Inactive rows — .seat coin + .small chip; whole row dimmed to 42%.
    ///
    /// The chip value fed to ScoreChip:
    ///   • Auto-fill row  → draft.autoFillValue  (app-computed, not host-typed)
    ///   • All other rows → draft.entries[idx]   (nil = empty = chip shows "0")
    @ViewBuilder
    private func playerRow(idx: Int, name: String) -> some View {
        let isFocused    = draft.focusedIndex == idx
        let isAuto       = draft.autoFillIndex == idx
        let chipValue:   Int?             = isAuto ? draft.autoFillValue : draft.entries[idx]
        let chipSize:    ScoreChip.Size   = isFocused ? .large : .small
        let coinVariant: Coin.Variant     = isFocused ? .active : (isAuto ? .winner : .seat)
        // Show pending sign hint when focused on an empty non-auto cell.
        let showSignHint = isFocused && !isAuto && draft.entries[idx] == nil

        HStack(spacing: Spacing.md) {
            // Seat coin — gold winner token for focused/auto rows; neutral for inactive.
            Coin(text: SealGlyph.forRank(idx + 1), variant: coinVariant, size: 30)

            // Player name — primary tint for focused, gold for auto-fill, cream otherwise.
            Text(name)
                .font(.phormNameMd)
                .foregroundStyle(
                    isFocused ? Color.phormPrimary
                    : isAuto  ? Color.phormGoldBright
                    : Color.bodyText
                )

            Spacer()

            // Score chip + sign placeholder hint + blinking caret (caret only when focused).
            HStack(spacing: 6) {
                ScoreChip(value: chipValue, size: chipSize, isFocused: isFocused)
                    .overlay(alignment: .center) {
                        if showSignHint {
                            Text(draft.signMode < 0 ? "\u{2212}" : "+")
                                .font(.phormNumberMd)
                                .foregroundStyle(draft.signMode < 0 ? Color.scoreNegative : Color.scorePositive)
                                .opacity(0.5)
                        }
                    }
                if isFocused {
                    BlinkingCaret()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        // Focused row: elevated tactile card.
        .modifier(FocusCard(active: isFocused))
        .contentShape(Rectangle())
        .onTapGesture { draft.focusedIndex = idx }
        // Row opacity: focused = full, auto = 0.72 (single quieted row), inactive = 0.42.
        .opacity(isFocused ? 1.0 : isAuto ? 0.72 : 0.42)
        .animation(.easeInOut(duration: 0.18), value: isFocused)
        .animation(.easeInOut(duration: 0.18), value: isAuto)
    }

    // MARK: - Validation pill (Tổng)

    /// Rounded Capsule pill summarising the round total.
    /// Balanced (sum = 0): chipUp-tinted "0 · cân".
    /// Unbalanced: chipDown-tinted "<signed> ⚠".
    private var validationRow: some View {
        let sum = draft.liveSum
        let ok  = sum == 0
        return HStack {
            Spacer()
            StatusPill(
                text: ok ? "Tổng: 0 · cân ✓" : "Tổng: \(ScoreFormat.signed(sum)) ⚠",
                style: ok ? .ok : .warn
            )
            Spacer()
        }
    }

    // MARK: - Bottom dock (keypad + CTA)

    /// Flat surface with a light cream hairline at the top — no heavy gradient.
    private var bottomDock: some View {
        VStack(spacing: Spacing.sm) {
            Keypad(
                onKey: { draft.keypad($0) },
                onSave: save,
                canSave: true,
                sign: draft.signMode
            )
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.sm)
        .background(
            Color.phormSurfaceCinnabar
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.hairline)
                        .frame(height: 1)
                }
        )
    }

    private func save() {
        let scores = draft.materialize()
        do {
            switch mode {
            case .new:
                try SessionActions.appendRound(scores: scores, to: session, in: context)
            case .edit(let round):
                try SessionActions.updateRound(round, scores: scores, in: context)
            }
            dismiss()
        } catch {
            print("save round failed: \(error)")
        }
    }
}

/// Elevated tactile card behind the focused player row (no card when inactive).
private struct FocusCard: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View {
        if active {
            content.tactileCard(radius: 14, elevated: true)
        } else {
            content
        }
    }
}

/// Caret that blinks at 1Hz — keypad input cursor in the focused cell.
private struct BlinkingCaret: View {
    @State private var visible = true
    var body: some View {
        Rectangle()
            .fill(Color.phormPrimary)
            .frame(width: 2, height: 22)
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(.linear(duration: 0.6).repeatForever(autoreverses: true)) {
                    visible.toggle()
                }
            }
    }
}
