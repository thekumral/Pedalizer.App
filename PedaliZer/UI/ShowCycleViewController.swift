import UIKit
import GoogleMaps
import FirebaseFirestore
import CoreLocation

class ShowCycleViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    // MARK: - Outlets
    @IBOutlet weak var GsMapView: GMSMapView!
    
    // MARK: - Properties
    let db = Firestore.firestore()
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        GsMapView.isMyLocationEnabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.zoomToUserLocation()
            self.fetchCycleShopsFromFirestore()
        }
    }
    // MARK: - Fetch Cycle Shops from Firestore
    func fetchCycleShopsFromFirestore() {
        guard let userLocation = userLocation else {
            return
        }
        db.collection("TurgutluCycleLocations").getDocuments { [self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching cycle shops: \(error.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("No cycle shops found.")
                return
            }
            for document in documents {
                if let latitude = document["Latitude"] as? Double,
                    let longitude = document["Longitude"] as? Double,
                    let name = document["Name"] as? String {
                    let cycleShopCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let distance = GMSGeometryDistance(userLocation, cycleShopCoordinate)
                    let marker = GMSMarker(position: cycleShopCoordinate)
                    marker.map = GsMapView
                    marker.title = name
                    marker.snippet = "Uzaklık: \(Int(distance)) metre"
                    marker.userData = ["destination": cycleShopCoordinate]
                    marker.icon = GMSMarker.markerImage(with: .green)
                    if let currentLocation = locationManager.location?.coordinate {
                        marker.map = GsMapView
                        drawRoute(from: currentLocation, to: cycleShopCoordinate)
                    }
                }
            }
        }
    }
    // MARK: - Draw Route on Map
    func drawRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let origin = "\(source.latitude),\(source.longitude)"
        let destination = "\(destination.latitude),\(destination.longitude)"
        let directionsAPI = "https://maps.googleapis.com/maps/api/directions/json?" +
            "origin=\(origin)&destination=\(destination)&mode=walking&key=AIzaSyAp2HQdQsKr0OgV5Jc_IP_3ALKrHeooUQc"

        guard let url = URL(string: directionsAPI) else {
            return
        }
        URLSession.shared.dataTask(with: url) { [self] (data, response, error) in
            guard let data = data, error == nil else {
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonDict = json as? [String: Any], let routes = jsonDict["routes"] as? [[String: Any]], let route = routes.first,
                    let overviewPolyline = route["overview_polyline"] as? [String: Any], let points = overviewPolyline["points"] as? String {
                    DispatchQueue.main.async {
                        let path = GMSMutablePath(fromEncodedPath: points)
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeColor = .green
                        polyline.strokeWidth = 2.0
                        polyline.map = self.GsMapView
                    }
                }
            } catch {
                print("Yol çizme işleminde hata oluştu: \(error.localizedDescription)")
            }
        }.resume()
    }
    // MARK: - Zoom to User Location
    func zoomToUserLocation() {
        if let location = userLocation {
            let camera = GMSCameraPosition.camera(withTarget: location, zoom: 14.0)
            GsMapView.animate(to: camera)
        }
    }
    // MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first?.coordinate {
            userLocation = location
            fetchCycleShopsFromFirestore()
        }
    }
}
