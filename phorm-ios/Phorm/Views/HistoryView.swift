import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Session.createdAt, order: .reverse)])
    private var sessions: [Session]

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
                            context.delete(session)
                            try? context.save()
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
    }
}
