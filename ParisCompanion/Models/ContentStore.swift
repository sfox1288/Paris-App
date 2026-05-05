import Foundation
import Observation

@Observable
final class ContentStore {
    var pois: [POI] = []
    var itinerary: [ItineraryDay] = []
    var loadError: String?

    private(set) var poisById: [String: POI] = [:]

    init() {
        load()
    }

    func load() {
        do {
            let loadedPois: [POI] = try Self.decode(from: "pois")
            let loadedItin: [ItineraryDay] = try Self.decode(from: "itinerary")
            pois = loadedPois.sorted { $0.name < $1.name }
            itinerary = loadedItin.sorted { $0.date < $1.date }
            poisById = Dictionary(uniqueKeysWithValues: pois.map { ($0.id, $0) })
        } catch {
            loadError = "\(error)"
            print("ContentStore load error: \(error)")
        }
    }

    func poi(id: String) -> POI? { poisById[id] }

    private static func decode<T: Decodable>(from name: String) throws -> T {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw NSError(
                domain: "ContentStore", code: 404,
                userInfo: [NSLocalizedDescriptionKey: "\(name).json not found in app bundle"]
            )
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
