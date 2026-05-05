import SwiftUI
import UIKit

struct DirectionsButton: View {
    let lat: Double
    let lon: Double
    let label: String

    init(lat: Double, lon: Double, label: String = "Walking directions in Google Maps") {
        self.lat = lat
        self.lon = lon
        self.label = label
    }

    var body: some View {
        Button(action: openDirections) {
            Label(label, systemImage: "figure.walk")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private func openDirections() {
        let app = "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=walking"
        let web = "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lon)&travelmode=walking"
        if let url = URL(string: app), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: web) {
            UIApplication.shared.open(url)
        }
    }
}
