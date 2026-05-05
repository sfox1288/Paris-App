import Foundation

struct ItineraryDay: Identifiable, Codable, Hashable {
    var id: String { date }
    let date: String   // ISO yyyy-MM-dd, Europe/Paris
    let title: String
    let notes: String?
    let stops: [Stop]

    var dateValue: Date? {
        ItineraryDay.formatter.date(from: date)
    }

    static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Europe/Paris")
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    struct Stop: Identifiable, Codable, Hashable {
        var id: String { poiId + (plannedTime ?? "") }
        let poiId: String
        let plannedTime: String?
        let note: String?
    }
}
