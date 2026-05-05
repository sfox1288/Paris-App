import SwiftUI

struct ItineraryView: View {
    @Environment(ContentStore.self) private var content

    var body: some View {
        NavigationStack {
            List(content.itinerary) { day in
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.title).font(.headline)
                    Text(day.date).font(.caption).foregroundStyle(.secondary)
                    Text("\(day.stops.count) stop(s)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Itinerary")
            .overlay {
                if content.itinerary.isEmpty {
                    ContentUnavailableView(
                        "No itinerary loaded",
                        systemImage: "calendar.badge.exclamationmark"
                    )
                }
            }
        }
    }
}
