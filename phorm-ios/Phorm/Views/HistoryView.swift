import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Session.createdAt, order: .reverse)])
    private var sessions: [Session]
    @State private var deletingSession: Session?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                if sessions.isEmpty {
                    Text("Chưa có session nào")
                        .font(.phormBodyMd)
                        .foregroundStyle(Color.phormMuted)
                        .padding(.top, Spacing.xxl)
                }
                ForEach(sessions) { session in
                    NavigationLink {
                        SummaryView(session: session)
                    } label: {
                        HistoryRow(session: session)
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
            .padding(Spacing.lg)
        }
        .background(Color.canvas)
        .navigationTitle("Lịch sử")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Xóa session \"\(deletingSession?.name ?? "")\"?",
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
}
