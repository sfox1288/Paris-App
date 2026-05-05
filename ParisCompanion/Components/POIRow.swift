import SwiftUI

struct POIRow: View {
    let poi: POI
    var isFavorite: Bool = false
    var isVisited: Bool = false

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
                Spacer(minLength: 8)
                if isFavorite {
                    Image(systemName: "heart.fill").foregroundStyle(.pink)
                }
                if isVisited {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                }
            }
        }
    }
}
