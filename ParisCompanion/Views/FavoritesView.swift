import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(ContentStore.self) private var content
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<POIStatus> { $0.isFavorite },
           sort: \POIStatus.updatedAt, order: .reverse) private var statuses: [POIStatus]

    private var favoritedPOIs: [POI] {
        statuses.compactMap { content.poi(id: $0.poiId) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favoritedPOIs.isEmpty {
                    ContentUnavailableView(
                        "No favorites yet",
                        systemImage: "heart",
                        description: Text("Tap the heart on a POI's detail page to save it here.")
                    )
                } else {
                    List {
                        ForEach(favoritedPOIs) { poi in
                            POIRow(poi: poi, isFavorite: true,
                                   isVisited: statuses.first(where: { $0.poiId == poi.id })?.isVisited ?? false)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        unfavorite(poi.id)
                                    } label: {
                                        Label("Unfavorite", systemImage: "heart.slash")
                                    }
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Favorites")
            .navigationDestination(for: POI.self) { POIDetailView(poi: $0) }
        }
    }

    private func unfavorite(_ poiId: String) {
        guard let s = statuses.first(where: { $0.poiId == poiId }) else { return }
        s.isFavorite = false
        s.updatedAt = .now
        try? modelContext.save()
    }
}
