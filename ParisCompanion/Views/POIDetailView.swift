import SwiftUI
import SwiftData
import MapKit

struct POIDetailView: View {
    let poi: POI

    @Environment(\.modelContext) private var modelContext
    @Query private var statuses: [POIStatus]

    init(poi: POI) {
        self.poi = poi
        let id = poi.id
        _statuses = Query(filter: #Predicate<POIStatus> { $0.poiId == id })
    }

    private var status: POIStatus? { statuses.first }
    private var isFavorite: Bool { status?.isFavorite ?? false }
    private var isVisited: Bool { status?.isVisited ?? false }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero
                header
                toggles
                PracticalInfoBox(practical: poi.practical)
                DirectionsButton(lat: poi.lat, lon: poi.lon)
                rickStevesSection
                miniMap
                Text(poi.address)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(poi.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        LinearGradient(
            colors: [.blue.opacity(0.55), .purple.opacity(0.45)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .frame(height: 180)
        .overlay(
            Image(systemName: poi.category.systemImage)
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.9))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(poi.name).font(.title).bold()
            HStack(spacing: 6) {
                Image(systemName: poi.category.systemImage)
                Text(poi.category.displayName)
                Text("·")
                Text(poi.neighborhood)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var toggles: some View {
        HStack(spacing: 12) {
            Button { toggle(\.isFavorite) } label: {
                Label(isFavorite ? "Favorited" : "Favorite",
                      systemImage: isFavorite ? "heart.fill" : "heart")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(isFavorite ? .pink : .secondary)

            Button { toggle(\.isVisited) } label: {
                Label(isVisited ? "Visited" : "Mark visited",
                      systemImage: isVisited ? "checkmark.circle.fill" : "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(isVisited ? .green : .secondary)
        }
    }

    @ViewBuilder
    private var rickStevesSection: some View {
        let attributed = (try? AttributedString(
            markdown: poi.rickSteves,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(poi.rickSteves)

        VStack(alignment: .leading, spacing: 8) {
            Text("Rick Steves").font(.headline)
            Text(attributed)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var miniMap: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: poi.coordinate,
            latitudinalMeters: 600,
            longitudinalMeters: 600
        ))) {
            Marker(poi.name, systemImage: poi.category.systemImage, coordinate: poi.coordinate)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .allowsHitTesting(false)
    }

    private func toggle(_ kp: ReferenceWritableKeyPath<POIStatus, Bool>) {
        if let s = status {
            s[keyPath: kp].toggle()
            s.updatedAt = .now
        } else {
            let new = POIStatus(poiId: poi.id)
            new[keyPath: kp] = true
            modelContext.insert(new)
        }
        try? modelContext.save()
    }
}
