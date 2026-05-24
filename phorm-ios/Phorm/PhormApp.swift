import SwiftUI
import SwiftData

@main
struct PhormApp: App {
    let container: ModelContainer

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
            Text("Phorm — models loaded")
        }
        .modelContainer(container)
    }
}
