import Foundation
import CoreLocation
import Observation

@Observable
final class LocationProvider: NSObject, CLLocationManagerDelegate {
    var lastFix: CLLocation?
    var authorization: CLAuthorizationStatus

    private let manager = CLLocationManager()

    override init() {
        self.authorization = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
    }

    func requestIfNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        if authorization == .authorizedWhenInUse || authorization == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let last = locations.last {
            lastFix = last
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silent — we degrade to default sort if no fix arrives.
    }
}
