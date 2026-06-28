import SwiftUI
import SwiftData

@main
struct PhormApp: App {
    let container: ModelContainer

    @State private var pendingImport: SessionDTO?
    #if DEBUG
    @State private var showSplash = !ScreenshotSupport.seedRequested
    #else
    @State private var showSplash = true
    #endif

    init() {
        if ScreenshotMode.isActive {
            container = ScreenshotMode.makeContainer()
            return
        }
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        #if DEBUG
        if ScreenshotSupport.seedRequested {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            do {
                let c = try ModelContainer(for: schema, configurations: [config])
                ScreenshotSupport.seed(into: c.mainContext, activeSession: !ScreenshotSupport.wantsEmptyHome)
                container = c
                return
            } catch {
                fatalError("Screenshot seed container failed: \(error)")
            }
        }
        #endif
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
            if ScreenshotMode.isActive {
                ScreenshotRoot()
                    .modelContainer(container)
            } else {
                normalRoot
            }
        }
    }

    private var normalRoot: some View {
        ZStack {
            HomeView()
                .preferredColorScheme(.dark)
                .tint(.phormPrimary)
                .onOpenURL { url in
                    pendingImport = try? SessionShare.decode(url)
                }
                .sheet(item: $pendingImport) { dto in
                    ImportConfirmView(dto: dto, onDismiss: { pendingImport = nil })
                        .interactiveDismissDisabled()
                        .preferredColorScheme(.dark)
                }

            if showSplash {
                SplashView(isVisible: $showSplash)
                    .preferredColorScheme(.dark)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .modelContainer(container)
    }
}
