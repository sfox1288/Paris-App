import SwiftUI

struct POIRow: View {
    let poi: POI

    var body: some View {
        NavigationLink(value: poi) {
            HStack(spacing: 12) {
                Image(systemName: poi.category.systemImage)
                    .frame(width: 28)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(poi.name).font(.body)
                    Text(poi.category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
