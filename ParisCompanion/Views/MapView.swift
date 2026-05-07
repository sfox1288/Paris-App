import SwiftUI
import MapKit

struct MapView: View {
    @Environment(ContentStore.self) private var content
    @State private var selectedCategories: Set<POI.Category> = Set(POI.Category.allCases)
    @State private var selectedPOI: POI?

    private static let parisCenter = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)

    private var visiblePOIs: [POI] {
        content.pois.filter { selectedCategories.contains($0.category) }
    }

    var body: some View {
        NavigationStack {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: Self.parisCenter,
                latitudinalMeters: 7000,
                longitudinalMeters: 7000
            ))) {
                ForEach(visiblePOIs) { poi in
                    Annotation(poi.name, coordinate: poi.coordinate) {
                        Button {
                            selectedPOI = poi
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 34, height: 34)
                                    .shadow(radius: 1.5)
                                Image(systemName: poi.category.systemImage)
                                    .foregroundStyle(.tint)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top, spacing: 0) {
                CategoryFilterBar(selected: $selectedCategories)
                    .background(.ultraThinMaterial)
            }
            .sheet(item: $selectedPOI) { poi in
                MapPOISheet(poi: poi)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

private struct CategoryFilterBar: View {
    @Binding var selected: Set<POI.Category>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(POI.Category.allCases, id: \.self) { cat in
                    let on = selected.contains(cat)
                    Button {
                        if on { selected.remove(cat) } else { selected.insert(cat) }
                    } label: {
                        Label(cat.displayName, systemImage: cat.systemImage)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(on ? Color.accentColor.opacity(0.18) : Color(.tertiarySystemFill))
                            .foregroundStyle(on ? Color.accentColor : Color.primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(cat.displayName)
                    .accessibilityValue(on ? "showing" : "hidden")
                    .accessibilityHint("Toggles \(cat.displayName.lowercased()) pins")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

private struct MapPOISheet: View {
    let poi: POI

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(poi.name).font(.title2).bold()
                        HStack(spacing: 6) {
                            Image(systemName: poi.category.systemImage)
                            Text(poi.category.displayName)
                            Text("·")
                            Text(poi.neighborhood)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    PracticalInfoBox(practical: poi.practical)

                    NavigationLink(value: poi) {
                        Label("Open Detail", systemImage: "info.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    DirectionsButton(lat: poi.lat, lon: poi.lon)
                }
                .padding()
            }
            .navigationDestination(for: POI.self) { POIDetailView(poi: $0) }
        }
    }
}
