import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Session.createdAt, order: .reverse)])
    private var sessions: [Session]
    @State private var deletingSession: Session?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerStrip
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.xs)
                    .padding(.bottom, Spacing.md)

                LacquerHairline()
                    .padding(.horizontal, Spacing.lg)

                if sessions.isEmpty {
                    emptyMessage
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.xxl)
                } else {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(Array(sessions.enumerated()), id: \.element.id) { idx, session in
                            NavigationLink {
                                SummaryView(session: session)
                            } label: {
                                HistoryRow(session: session)
                                    .opacity(fadeOpacity(for: idx))
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    deletingSession = session
                                } label: {
                                    Label("Xóa", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.xxl)

                    footerHint
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.xl)
                }
            }
        }
        .scrollIndicators(.hidden)
        .lacquerBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle("")
        .confirmationDialog(
            "Xóa phiên \"\(deletingSession?.name ?? "")\"?",
            isPresented: Binding(
                get: { deletingSession != nil },
                set: { if !$0 { deletingSession = nil } }
            ),
            presenting: deletingSession
        ) { session in
            Button("Xóa", role: .destructive) {
                context.delete(session)
                try? context.save()
            }
            Button("Hủy", role: .cancel) {}
        } message: { _ in
            Text("Không thể hoàn tác.")
        }
    }

    private var headerStrip: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                SectionLabel(text: "Lưu trữ")
                Text("Lịch sử phiên")
                    .font(.phormTitleLg)
                    .foregroundStyle(Color.phormCream)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                SectionLabel(text: "Phiên")
                Text("\(sessions.count)")
                    .font(.phormTitleLg)
                    .foregroundStyle(Color.phormCreamDim)
                    .monospacedDigit()
            }
        }
    }

    private var emptyMessage: some View {
        VStack(alignment: .center, spacing: Spacing.sm) {
            Text("Chưa có phiên nào trong sổ.")
                .font(.phormNameMd)
                .foregroundStyle(Color.phormCreamDim)
                .multilineTextAlignment(.center)
            Text("Mở ván đầu để bắt đầu ghi.")
                .font(.phormBodySm)
                .foregroundStyle(Color.phormCream.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var footerHint: some View {
        Text("Chạm để mở · giữ để xoá")
            .font(.phormCaptionSection)
            .tracking(1.6)
            .textCase(.uppercase)
            .foregroundStyle(Color.phormCreamDim)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    /// Older sessions fade in three steps — newest at full opacity, archive depth past row 6.
    private func fadeOpacity(for idx: Int) -> Double {
        switch idx {
        case 0...2:  return 1.0
        case 3...5:  return 0.85
        case 6...9:  return 0.65
        default:     return 0.5
        }
    }
}
