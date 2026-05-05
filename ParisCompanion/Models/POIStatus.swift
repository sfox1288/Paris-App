import Foundation
import SwiftData

@Model
final class POIStatus {
    @Attribute(.unique) var poiId: String
    var isFavorite: Bool
    var isVisited: Bool
    var updatedAt: Date

    init(poiId: String, isFavorite: Bool = false, isVisited: Bool = false) {
        self.poiId = poiId
        self.isFavorite = isFavorite
        self.isVisited = isVisited
        self.updatedAt = .now
    }
}
