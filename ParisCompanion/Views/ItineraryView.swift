import SwiftUI

struct ItineraryView: View {
    @Environment(ContentStore.self) private var content
    @State private var collapsed: Set<String> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(content.itinerary) { day in
                        DayDisclosure(day: day, expanded: binding(for: day.id))
                    }
                }
                .padding()
            }
            .navigationTitle("Itinerary")
            .navigationDestination(for: POI.self) { POIDetailView(poi: $0) }
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

    private func binding(for id: String) -> Binding<Bool> {
        Binding(
            get: { !collapsed.contains(id) },
            set: { isExpanded in
                if isExpanded { collapsed.remove(id) } else { collapsed.insert(id) }
            }
        )
    }
}

private struct DayDisclosure: View {
    @Environment(ContentStore.self) private var content
    let day: ItineraryDay
    @Binding var expanded: Bool

    private var displayDate: String {
        guard let d = day.dateValue else { return day.date }
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        f.timeZone = TimeZone(identifier: "Europe/Paris")
        return f.string(from: d)
    }

    var body: some View {
        DisclosureGroup(isExpanded: $expanded) {
            VStack(alignment: .leading, spacing: 8) {
                if let notes = day.notes, !notes.isEmpty {
                    Text(notes).font(.callout).foregroundStyle(.secondary)
                }
                ForEach(day.stops) { stop in
                    if let poi = content.poi(id: stop.poiId) {
                        NavigationLink(value: poi) {
                            StopRow(stop: stop, poi: poi)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Label("Missing POI: \(stop.poiId)", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(.top, 8)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(displayDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(day.title).font(.title3).bold()
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
