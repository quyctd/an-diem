import SwiftUI
import SwiftData

@main
struct PhormApp: App {
    let container: ModelContainer

    @State private var pendingImport: SessionDTO?

    init() {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .onOpenURL { url in
                    pendingImport = try? SessionShare.decode(url)
                }
                .sheet(item: $pendingImport) { dto in
                    ImportConfirmView(dto: dto, onDismiss: { pendingImport = nil })
                        .interactiveDismissDisabled()
                }
        }
        .modelContainer(container)
    }
}
