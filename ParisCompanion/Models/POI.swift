import Foundation
import CoreLocation

struct POI: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: Category
    let lat: Double
    let lon: Double
    let address: String
    let neighborhood: String
    let rickSteves: String
    let practical: Practical
    let photos: [String]
    let tags: [String]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    enum Category: String, Codable, CaseIterable, Hashable {
        case museum
        case landmark
        case church
        case neighborhood
        case restaurant
        case viewpoint

        var displayName: String {
            switch self {
            case .museum: "Museum"
            case .landmark: "Landmark"
            case .church: "Church"
            case .neighborhood: "Neighborhood"
            case .restaurant: "Restaurant"
            case .viewpoint: "Viewpoint"
            }
        }

        var systemImage: String {
            switch self {
            case .museum: "building.columns"
            case .landmark: "star"
            case .church: "building"
            case .neighborhood: "map"
            case .restaurant: "fork.knife"
            case .viewpoint: "binoculars"
            }
        }
    }

    struct Practical: Codable, Hashable {
        let hours: String?
        let cost: String?
        let duration: String?
        let reservation: String?
    }
}
