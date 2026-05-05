import SwiftUI

struct MapView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Map",
                systemImage: "map",
                description: Text("MapKit pin view in Phase 3.")
            )
            .navigationTitle("Map")
        }
    }
}
