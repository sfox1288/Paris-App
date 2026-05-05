import SwiftUI

struct BrowseView: View {
    @Environment(ContentStore.self) private var content
    @State private var search: String = ""

    private var grouped: [(String, [POI])] {
        let filtered = content.pois.filter { poi in
            search.isEmpty
                || poi.name.localizedCaseInsensitiveContains(search)
                || poi.neighborhood.localizedCaseInsensitiveContains(search)
        }
        let dict = Dictionary(grouping: filtered, by: \.neighborhood)
        return dict.sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                if let err = content.loadError {
                    Section {
                        Text("Load error: \(err)").foregroundStyle(.red)
                    }
                }
                ForEach(grouped, id: \.0) { neighborhood, pois in
                    Section(neighborhood) {
                        ForEach(pois) { poi in
                            POIRow(poi: poi)
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
            .overlay {
                if content.pois.isEmpty && content.loadError == nil {
                    ContentUnavailableView("No POIs loaded", systemImage: "tray")
                }
            }
        }
    }
}
