import SwiftUI

struct POIDetailView: View {
    let poi: POI

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(poi.name).font(.largeTitle).bold()
                Text(poi.neighborhood).foregroundStyle(.secondary)
                Text("Detail view coming in Phase 2.")
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle(poi.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
