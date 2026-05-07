import SwiftUI
import SwiftData
import CoreLocation

enum BrowseSort: String, CaseIterable, Identifiable {
    case neighborhood
    case nearMe

    var id: String { rawValue }
    var label: String {
        switch self {
        case .neighborhood: "By neighborhood"
        case .nearMe:       "Near me"
        }
    }
    var systemImage: String {
        switch self {
        case .neighborhood: "map"
        case .nearMe:       "location"
        }
    }
}

struct BrowseView: View {
    @Environment(ContentStore.self) private var content
    @Query private var statuses: [POIStatus]
    @State private var search: String = ""
    @State private var sort: BrowseSort = .neighborhood
    @State private var location = LocationProvider()

    private var favorites: Set<String> { Set(statuses.filter(\.isFavorite).map(\.poiId)) }
    private var visited: Set<String> { Set(statuses.filter(\.isVisited).map(\.poiId)) }

    private var filteredPOIs: [POI] {
        content.pois.filter { poi in
            search.isEmpty
                || poi.name.localizedCaseInsensitiveContains(search)
                || poi.neighborhood.localizedCaseInsensitiveContains(search)
        }
    }

    private var grouped: [(String, [POI])] {
        let dict = Dictionary(grouping: filteredPOIs, by: \.neighborhood)
        return dict.sorted { $0.key < $1.key }
    }

    private var sortedByDistance: [POI] {
        guard let fix = location.lastFix else { return filteredPOIs }
        return filteredPOIs.sorted { lhs, rhs in
            let l = CLLocation(latitude: lhs.lat, longitude: lhs.lon).distance(from: fix)
            let r = CLLocation(latitude: rhs.lat, longitude: rhs.lon).distance(from: fix)
            return l < r
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if let err = content.loadError {
                    Section {
                        Text("Load error: \(err)").foregroundStyle(.red)
                    }
                }
                switch sort {
                case .neighborhood:
                    ForEach(grouped, id: \.0) { neighborhood, pois in
                        Section(neighborhood) {
                            ForEach(pois) { poi in
                                POIRow(
                                    poi: poi,
                                    isFavorite: favorites.contains(poi.id),
                                    isVisited: visited.contains(poi.id)
                                )
                            }
                        }
                    }
                case .nearMe:
                    Section(nearMeSectionHeader) {
                        ForEach(sortedByDistance) { poi in
                            POIRow(
                                poi: poi,
                                isFavorite: favorites.contains(poi.id),
                                isVisited: visited.contains(poi.id)
                            )
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Browse")
            .searchable(text: $search, prompt: "Search Paris")
            .navigationDestination(for: POI.self) { poi in
                POIDetailView(poi: poi)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $sort) {
                            ForEach(BrowseSort.allCases) { s in
                                Label(s.label, systemImage: s.systemImage).tag(s)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .onChange(of: sort) { _, new in
                if new == .nearMe {
                    location.requestIfNeeded()
                }
            }
            .overlay {
                if content.pois.isEmpty && content.loadError == nil {
                    ContentUnavailableView("No POIs loaded", systemImage: "tray")
                }
            }
        }
    }

    private var nearMeSectionHeader: String {
        switch location.authorization {
        case .denied, .restricted:
            return "Near me — location denied (showing default order)"
        default:
            return location.lastFix == nil
                ? "Near me — waiting for location…"
                : "Near me"
        }
    }
}
