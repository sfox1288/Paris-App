import SwiftUI

struct PracticalInfoBox: View {
    let practical: POI.Practical

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            row("clock", "Hours", practical.hours)
            row("eurosign.circle", "Cost", practical.cost)
            row("hourglass", "Duration", practical.duration)
            row("ticket", "Reservation", practical.reservation)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func row(_ icon: String, _ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: icon).frame(width: 20)
                VStack(alignment: .leading) {
                    Text(label).font(.caption).foregroundStyle(.secondary)
                    Text(value)
                }
            }
        }
    }
}
