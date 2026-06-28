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
        .lacquerBackground(.phormSurfaceCinnabarDeep)
        .presentationBackground(Color.phormSurfaceCinnabarDeep)
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
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
                    .background(Circle().fill(Color.black.opacity(0.18)))
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
        case .new:     return "Đóng dấu vòng"
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
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(Color.phormCream.opacity(0.82))
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

    @ViewBuilder
    private func playerRow(idx: Int, name: String) -> some View {
        let isFocused = draft.focusedIndex == idx
        let isAuto = draft.autoFillIndex == idx
        HStack(spacing: Spacing.md) {
            // Seat seal — Hán numeral per player position. Gives a fixed glyph anchor
            // the host can verify before typing ("I'm entering for 叁, that's Linh").
            // Bright winner-gold when focused; muted default otherwise.
            Seal(
                glyph: SealGlyph.forRank(idx + 1),
                variant: isFocused ? .winner : .default,
                size: 30
            )
            Text(name)
                .font(.phormNameMd)
                .foregroundStyle(
                    isFocused ? Color.phormPrimary
                    : isAuto ? Color.phormCreamDim
                    : Color.phormCream
                )
            Spacer()
            cellView(idx: idx, isFocused: isFocused, isAuto: isAuto)
        }
        .contentShape(Rectangle())
        .onTapGesture { draft.focusedIndex = idx }
    }

    @ViewBuilder
    private func cellView(idx: Int, isFocused: Bool, isAuto: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 2) {
                cellValue(idx: idx, isFocused: isFocused, isAuto: isAuto)
                if isFocused {
                    BlinkingCaret()
                }
            }
            .frame(width: 110, alignment: .trailing)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(cellBackground(isFocused: isFocused, isAuto: isAuto))

            if isAuto {
                Seal(glyph: "封", variant: .winner, size: 22)
                    .offset(x: 8, y: -8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(height: 44)
    }

    @ViewBuilder
    private func cellValue(idx: Int, isFocused: Bool, isAuto: Bool) -> some View {
        if isAuto, let v = draft.autoFillValue {
            Text(ScoreFormat.signed(v))
                .font(.phormNumberScript)
                .foregroundStyle(ScoreFormat.color(for: v))
        } else if let v = draft.entries[idx] {
            // Typed value: sign-aware color (mint +, ochre −, cream 0). The same
            // color appears in the keypad's sign key — closing the loop between
            // mode you're in and what you see in the cell.
            Text(ScoreFormat.signed(v))
                .font(.phormNumberEntry)
                .foregroundStyle(ScoreFormat.color(for: v))
        } else if isFocused {
            // Empty placeholder on the focused row hints at the active sign mode.
            Text(draft.signMode < 0 ? "\u{2212}" : "+")
                .font(.phormNumberEntry)
                .foregroundStyle(modeColor.opacity(0.50))
        } else {
            Text("0")
                .font(.phormNumberEntry)
                .foregroundStyle(Color.phormCream.opacity(0.32))
        }
    }

    /// Current sign-mode accent color — mint for add, ochre for subtract. Drives
    /// the focused cell border, value text, placeholder hint, and keypad sign key.
    private var modeColor: Color {
        draft.signMode < 0 ? .scoreNegative : .scorePositive
    }

    @ViewBuilder
    private func cellBackground(isFocused: Bool, isAuto: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: 2, style: .continuous)
        ZStack {
            if isFocused {
                shape.fill(modeColor.opacity(0.14))
                shape.strokeBorder(modeColor, lineWidth: 1.5)
            } else if isAuto {
                shape.fill(Color.phormPrimary.opacity(0.06))
                shape.strokeBorder(Color.phormPrimaryActive, lineWidth: 1)
            } else {
                shape.fill(Color.black.opacity(0.18))
                shape.strokeBorder(Color.phormCream.opacity(0.30), lineWidth: 1)
            }
        }
    }

    // MARK: - Validation

    private var validationRow: some View {
        let sum = draft.liveSum
        let ok = sum == 0
        return HStack {
            SectionLabel(text: "Tổng")
            Spacer()
            Text(ok ? "0 · cân" : "\(ScoreFormat.signed(sum)) ⚠")
                .font(.phormNumberMd)
                .foregroundStyle(ok ? Color.scorePositive : Color.warning)
        }
        .padding(.top, Spacing.sm)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.phormCream.opacity(0.18))
                .frame(height: 1)
        }
    }

    // MARK: - Bottom dock (keypad + CTA)

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
            LinearGradient(
                colors: [.clear, .phormSurfaceCinnabarDeep.opacity(0.6), .phormSurfaceCinnabarDeep],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 380)
            .allowsHitTesting(false),
            alignment: .bottom
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
