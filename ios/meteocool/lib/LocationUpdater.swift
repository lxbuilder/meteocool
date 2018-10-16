import UIKit
import CoreLocation

class LocationUpdater: NSObject, CLLocationManagerDelegate {
    let locationManager: CLLocationManager
    let deviceID: String = UIDevice.current.identifierForVendor!.uuidString

    override init() {
        locationManager = CLLocationManager()
        super.init()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("Location: No access")
            case .authorizedWhenInUse:
                print("Location: WhenInUse")
            case .authorizedAlways:
                print("Location: Always")
                startSignificantChangeLocationUpdates()
            }
        } else {
            print("Location services are not enabled")
        }
    }

    func startSignificantChangeLocationUpdates() {
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.startMonitoringSignificantLocationChanges()
    }

    func startBackgroundLocationUpdates() {
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.activityType = CLActivityType.other
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.postLocation(location:location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("CLLocationManager ERR: \(error)")
    }

    func postLocation(location: CLLocation) {
        let locationDict = [
            "lat": location.coordinate.latitude as Double,
            "lon": location.coordinate.longitude as Double,
            "accuracy": location.horizontalAccuracy as Double,
            "source" : "ios",
            "token" : deviceID,
            ] as [String : Any]

        guard let request = NetworkHelper.createJSONPostRequest(dst: "post_location", dictionary: locationDict) else {
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = NetworkHelper.checkResponse(data: data, response: response, error: error) else {
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                if let errorMessage = json?["error"] as? String {
                    print("ERROR: \(errorMessage)")
                }
            }
        }
        task.resume()
    }
}