import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<Session> { $0.archivedAt == nil },
           sort: [SortDescriptor(\Session.createdAt, order: .reverse)])
    private var active: [Session]

    var body: some View {
        NavigationStack {
            if let session = active.first {
                SessionView(session: session)
            } else {
                EmptyHomeView()
            }
        }
    }
}
