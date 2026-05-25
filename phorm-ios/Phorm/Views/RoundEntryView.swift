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

    init(session: Session, mode: Mode) {
        self.session = session
        self.mode = mode
        switch mode {
        case .new:
            _draft = State(initialValue: RoundDraft(playerNames: session.playerNames))
        case .edit(let round):
            let map = Dictionary(
                uniqueKeysWithValues: (round.scores ?? []).map { ($0.playerName, $0.value) }
            )
            _draft = State(initialValue: RoundDraft(playerNames: session.playerNames, existing: map))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            playerList
            Spacer(minLength: 0)
            SumIndicator(sum: draft.liveSum)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.sm)
            Keypad(
                onKey: { draft.keypad($0) },
                onSave: save,
                canSave: true
            )
        }
        .background(Color.canvas)
        .presentationBackground(Color.canvas)
        .confirmationDialog("Xóa ván này?", isPresented: $showDeleteConfirm) {
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

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.phormTitleSm)
                    .foregroundStyle(Color.phormMuted)
            }
            Spacer()
            Text(headerTitle)
                .font(.phormTitleSm)
                .foregroundStyle(Color.bodyText)
            Spacer()
            if case .edit(let round) = mode {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Text("Xóa").foregroundStyle(Color.scoreNegative)
                }
            } else {
                Color.clear.frame(width: 40)
            }
        }
        .padding(Spacing.md)
    }

    private var headerTitle: String {
        switch mode {
        case .new: return "Ván \((session.rounds ?? []).count + 1)"
        case .edit(let r): return "Sửa ván \(r.index)"
        }
    }

    private var playerList: some View {
        VStack(spacing: 0) {
            ForEach(Array(draft.playerNames.enumerated()), id: \.offset) { idx, name in
                row(idx: idx, name: name)
                if idx != draft.playerNames.count - 1 {
                    Divider().background(Color.hairline)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    @ViewBuilder
    private func row(idx: Int, name: String) -> some View {
        let isFocused = draft.focusedIndex == idx
        let isAuto = draft.autoFillIndex == idx
        HStack {
            Text(name)
                .font(.phormTitleSm)
                .foregroundStyle(Color.bodyText)
            Spacer()
            valueText(idx: idx, isFocused: isFocused, isAuto: isAuto)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.sm)
        .background(isFocused ? Color.focusRowTint : .clear)
        .overlay(alignment: .bottom) {
            if isFocused { Rectangle().fill(Color.phormPrimary).frame(height: 2) }
        }
        .contentShape(Rectangle())
        .onTapGesture { draft.focusedIndex = idx }
    }

    @ViewBuilder
    private func valueText(idx: Int, isFocused: Bool, isAuto: Bool) -> some View {
        if isAuto, let v = draft.autoFillValue {
            Text("\(formatted(v)) auto")
                .font(.phormNumberEntry)
                .foregroundStyle(Color.phormMuted)
                .italic()
        } else if let v = draft.entries[idx] {
            Text(formatted(v))
                .font(.phormNumberEntry)
                .foregroundStyle(isFocused ? Color.phormPrimary : Color.bodyText)
        } else {
            Text("0")
                .font(.phormNumberEntry)
                .foregroundStyle(Color.phormMuted)
        }
    }

    private func formatted(_ v: Int) -> String {
        v > 0 ? "+\(v)" : "\(v)"
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
