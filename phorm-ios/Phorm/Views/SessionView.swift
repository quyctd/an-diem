import SwiftUI
import SwiftData

struct SessionView: View {
    let session: Session
    @Environment(\.modelContext) private var context
    @State private var showRoundEntry = false
    @State private var editingRound: Round?
    @State private var showEndConfirm = false
    @State private var deletingRound: Round?

    private var sortedRounds: [Round] {
        (session.rounds ?? []).sorted { $0.index > $1.index }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    TotalsChipRow(session: session)
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(sortedRounds) { round in
                            RoundCard(round: round, playerOrder: session.playerNames)
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
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, 96) // FAB clearance
                }
            }
            .background(Color.canvas)

            fab
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                NavBarTitle(session: session)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ShareLink(item: (try? SessionShare.url(for: session)) ?? URL(string: "phorm://error")!) {
                        Label("Chia sẻ", systemImage: "square.and.arrow.up")
                    }
                    NavigationLink {
                        SummaryView(session: session)
                    } label: {
                        Label("Tổng kết", systemImage: "trophy")
                    }
                    Button {
                        showEndConfirm = true
                    } label: {
                        Label("Kết thúc", systemImage: "checkmark.seal")
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
        .alert("Kết thúc session?", isPresented: $showEndConfirm) {
            Button("Hủy", role: .cancel) {}
            Button("Kết thúc", role: .destructive) {
                try? SessionActions.endSession(session, in: context)
            }
        }
        .confirmationDialog(
            "Xóa ván \(deletingRound?.index ?? 0)?",
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
    }

    private var fab: some View {
        Button {
            showRoundEntry = true
        } label: {
            Text("+ Ván \((session.rounds ?? []).count + 1)")
                .font(.phormButton)
                .foregroundStyle(Color.onPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.phormPrimary)
                .continuousRounded(Radius.lg)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }
}

private struct NavBarTitle: View {
    let session: Session
    @State private var editing = false
    @State private var draft: String = ""

    var body: some View {
        Group {
            if editing {
                TextField("", text: $draft, onCommit: commit)
                    .font(.phormTitleSm)
                    .multilineTextAlignment(.center)
                    .onAppear { draft = session.name }
            } else {
                VStack(spacing: 0) {
                    Text(session.name)
                        .font(.phormTitleSm)
                        .foregroundStyle(Color.bodyText)
                    Text("\(session.playerNames.count) người · \((session.rounds ?? []).count) ván")
                        .font(.phormCaption)
                        .foregroundStyle(Color.phormMuted)
                }
                .onTapGesture { editing = true }
            }
        }
    }

    private func commit() {
        session.name = draft.trimmingCharacters(in: .whitespaces)
        editing = false
    }
}
