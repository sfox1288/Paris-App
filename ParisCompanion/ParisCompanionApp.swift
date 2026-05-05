import SwiftUI
import SwiftData

@main
struct ParisCompanionApp: App {
    @State private var content = ContentStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(content)
        }
        .modelContainer(for: POIStatus.self)
    }
}

struct RootTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }
            ItineraryView()
                .tabItem { Label("Itinerary", systemImage: "calendar") }
            MapView()
                .tabItem { Label("Map", systemImage: "map") }
            BrowseView()
                .tabItem { Label("Browse", systemImage: "list.bullet") }
        }
    }
}
