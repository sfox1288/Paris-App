import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(ContentStore.self) private var content

    private var todayString: String {
        ItineraryDay.formatter.string(from: Date())
    }

    private var todayDay: ItineraryDay? {
        content.itinerary.first { $0.date == todayString }
    }

    private var nextDay: ItineraryDay? {
        content.itinerary.first { $0.date > todayString }
    }

    private var lastDay: ItineraryDay? {
        content.itinerary.last
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let day = todayDay {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(longFormatted(Date()))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        DayCard(day: day)
                    } else if let next = nextDay,
                              let nextDate = next.dateValue,
                              let days = daysBetween(Date(), nextDate) {
                        upcomingHeader(days: days, day: next)
                    } else if let last = lastDay,
                              let lastDate = last.dateValue,
                              lastDate < Date() {
                        completedHeader(lastTitle: last.title)
                    } else {
                        ContentUnavailableView(
                            "No itinerary loaded",
                            systemImage: "calendar"
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Today")
            .navigationDestination(for: POI.self) { POIDetailView(poi: $0) }
        }
    }

    @ViewBuilder
    private func upcomingHeader(days: Int, day: ItineraryDay) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "airplane.departure").font(.largeTitle)
            Text("Trip starts in \(days) day\(days == 1 ? "" : "s")")
                .font(.title2).bold()
            Text("First up: \(day.title)").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    @ViewBuilder
    private func completedHeader(lastTitle: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal").font(.largeTitle)
            Text("Trip complete").font(.title2).bold()
            Text("Last day: \(lastTitle)").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private func longFormatted(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeZone = TimeZone(identifier: "Europe/Paris")
        return f.string(from: d)
    }

    private func daysBetween(_ from: Date, _ to: Date) -> Int? {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Europe/Paris")!
        let start = cal.startOfDay(for: from)
        let end = cal.startOfDay(for: to)
        let comps = cal.dateComponents([.day], from: start, to: end)
        guard let days = comps.day else { return nil }
        return max(days, 1)
    }
}

struct DayCard: View {
    @Environment(ContentStore.self) private var content
    @Query(filter: #Predicate<POIStatus> { $0.isVisited }) private var visitedStatuses: [POIStatus]
    let day: ItineraryDay

    private var visitedCount: Int {
        let visitedIds = Set(visitedStatuses.map(\.poiId))
        return day.stops.filter { visitedIds.contains($0.poiId) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(day.title).font(.title2).bold()
                if let notes = day.notes, !notes.isEmpty {
                    Text(notes).font(.callout).foregroundStyle(.secondary)
                }
                if !day.stops.isEmpty {
                    Label("\(visitedCount) of \(day.stops.count) visited",
                          systemImage: visitedCount == day.stops.count ? "checkmark.circle.fill" : "circle.dashed")
                        .font(.caption)
                        .foregroundStyle(visitedCount == day.stops.count ? .green : .secondary)
                        .padding(.top, 2)
                }
            }
            ForEach(day.stops) { stop in
                if let poi = content.poi(id: stop.poiId) {
                    NavigationLink(value: poi) {
                        StopRow(stop: stop, poi: poi)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Missing POI: \(stop.poiId)")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}
