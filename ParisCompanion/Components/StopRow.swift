import SwiftUI

struct StopRow: View {
    let stop: ItineraryDay.Stop
    let poi: POI

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(stop.plannedTime ?? "—")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(poi.name).font(.headline)
                Text(poi.neighborhood).font(.caption).foregroundStyle(.secondary)
                if let note = stop.note, !note.isEmpty {
                    Text(note).font(.callout).padding(.top, 2)
                }
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
    }
}
