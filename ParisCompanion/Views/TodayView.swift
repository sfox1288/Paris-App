import SwiftUI

struct TodayView: View {
    @Environment(ContentStore.self) private var content

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Today",
                systemImage: "sun.max",
                description: Text("Today's plan will appear here in Phase 4.")
            )
            .navigationTitle("Today")
        }
    }
}
