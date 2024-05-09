        import UIKit
        import GoogleMaps
        import GooglePlaces
        import CoreLocation
// MARK: - Custom UIView for displaying distance information
    class InfoBoxView: UIView {
        let distanceLabel: UILabel = {
            let label = UILabel()
            label.textColor = .green
            label.font = UIFont.boldSystemFont(ofSize: 8)
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()
        
        init(frame: CGRect, distance: Double, mode: String) {
            let newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: 130, height: 30)
               super.init(frame: newFrame)
               setupUI(distance: distance, mode: mode)
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupUI(distance: 0, mode: "")
        }
        // Initialize the InfoBoxView with a specific frame, distance, and travel mode
        private func setupUI(distance: Double, mode: String) {
            backgroundColor = ThemeManager.shared.tertiaryColor
            layer.cornerRadius = 14.0
            layer.borderWidth = 1.0
            addSubview(distanceLabel)
            var modeText: String
            if mode == "walking" {
                modeText = "Bisiklet"
            } else if mode == "driving" {
                modeText = "Araç"
            } else {
                modeText = mode
            }
            let formattedDistance = String(format: "%.2f", distance)
            distanceLabel.text = "\(modeText) Mesafe: \(formattedDistance) km"
            distanceLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                distanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                distanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                distanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                distanceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            ])
        }
    }
            // MARK: - Main ViewController class
        class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

            // MARK: - IBOutlets

            @IBOutlet weak var startLocationTextField: UITextField!
            @IBOutlet weak var endLocationTextField: UITextField!
            @IBOutlet weak var GsMapView: GMSMapView!

            // MARK: - Properties

            var infoBoxView: InfoBoxView?
            var locationManager = CLLocationManager()
            var sessionToken: GMSAutocompleteSessionToken?
            var places: [GMSAutocompletePrediction] = []
            var bikePath: GMSPolyline?
            var carPath: GMSPolyline?
            var bikePathCoordinates: String?
            var carPathCoordinates: String?
            var activeTextField: UITextField?
            var startPrediction: GMSAutocompletePrediction?
            var destinationPrediction: GMSAutocompletePrediction?
            var travelMode : String = ""

            // MARK: - View Lifecycle

            override func viewDidLoad() {
                super.viewDidLoad()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
                endLocationTextField.delegate = self
                startLocationTextField.delegate = self
                GsMapView.delegate = self
                applyTheme()
                sessionToken = GMSAutocompleteSessionToken.init()
            }
            override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                GsMapView.isMyLocationEnabled = true
            }
            // MARK: - Location Manager Delegate
            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                if let location = locations.first?.coordinate {
                    let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
                    GsMapView.animate(to: camera)
                }
            }
            // MARK: - Text Field Delegate
            func textFieldDidBeginEditing(_ textField: UITextField) {
                if textField == startLocationTextField || textField == endLocationTextField {
                       presentPlacePicker(forType: textField == startLocationTextField ? "start" : "end")
                       activeTextField = textField
                   }
            }
            // MARK: - Map Functions
            func showLocationOnMap(startPlace: GMSPlace, destinationPlace: GMSPlace) {
                let startMarker = GMSMarker()
                startMarker.position = startPlace.coordinate
                startMarker.title = startPlace.name
                startMarker.map = GsMapView
                let destinationMarker = GMSMarker()
                destinationMarker.position = destinationPlace.coordinate
                destinationMarker.title = destinationPlace.name
                destinationMarker.map = GsMapView
                let bounds = GMSCoordinateBounds(coordinate: startPlace.coordinate, coordinate: destinationPlace.coordinate)
                let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
                GsMapView.animate(with: update)
            }
            // MARK: - addInfoBox
            func addInfoBox(to polyline: GMSPolyline, with mode: String, color: UIColor) {
                guard let path = GMSPath(fromEncodedPath: polyline.path?.encodedPath() ?? "") else {
                    return
                }
                let middleIndex = path.count() / 2
                let middleCoordinate = path.coordinate(at: middleIndex)
                let infoBoxView = InfoBoxView(frame: CGRect(x: 0, y: 0, width: 200, height: 60), distance: calculateDistance(for: polyline), mode: mode)
                infoBoxView.distanceLabel.textColor = color
                let position = middleCoordinate
                let marker = GMSMarker(position: position)
                marker.iconView = infoBoxView
                marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
                marker.map = GsMapView
            }
            // MARK: -
            func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
                    if let infoBoxView = marker.userData as? InfoBoxView {
                        let position = marker.position
                        let infoBoxMarker = GMSMarker(position: position)
                        infoBoxMarker.iconView = infoBoxView
                        infoBoxMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
                        infoBoxMarker.map = GsMapView
                        marker.map = nil
                    }
                    return false
                }
            // MARK: - fetchPlaceInformation
            func fetchPlaceInformation(for startPrediction: GMSAutocompletePrediction, destinationPrediction: GMSAutocompletePrediction) {
                    let placesClient = GMSPlacesClient.shared()
                    placesClient.fetchPlace(fromPlaceID: startPrediction.placeID, placeFields: .coordinate, sessionToken: self.sessionToken) { [weak self] (startPlace, startError) in
                        guard let self = self, let startPlace = startPlace, startError == nil else {
                            print("Başlangıç noktası bilgileri alınamadı!")
                            return
                        }
                        placesClient.fetchPlace(fromPlaceID: destinationPrediction.placeID, placeFields: .coordinate, sessionToken: self.sessionToken) { [weak self] (destinationPlace, destinationError) in
                            guard let self = self, let destinationPlace = destinationPlace, destinationError == nil else {
                                print("Varış noktası bilgileri alınamadı")
                                return
                            }
                            self.places = [startPrediction, destinationPrediction]
                            self.showLocationOnMap(startPlace: startPlace, destinationPlace: destinationPlace)
                            let startCoordinate = startPlace.coordinate
                            let destinationCoordinate = destinationPlace.coordinate
                            self.drawRoutes(from: startCoordinate, to: destinationCoordinate, travelMode: "walking", color: UIColor.green)
                            self.drawRoutes(from: startCoordinate, to: destinationCoordinate, travelMode: "driving", color: UIColor.orange)
                            self.highlightIntersection()
                        }
                    }
                }
            // MARK: -
            func findPathIntersection(_ path1: GMSPath, path2: GMSPath) -> CLLocationCoordinate2D? {
                    for i in 0..<path1.count() {
                        for j in 0..<path2.count() {
                            if path1.coordinate(at: i).latitude == path2.coordinate(at: j).latitude &&
                                path1.coordinate(at: i).longitude == path2.coordinate(at: j).longitude {
                                return path1.coordinate(at: i)
                            }
                        }
                    }
                    return nil
                }
            // MARK: -
            func highlightIntersection() {
                guard let bikePath = bikePath, let carPath = carPath else {
                    return
                }
                let bikePathPath = GMSPath(fromEncodedPath: bikePathCoordinates ?? "")!
                let carPathPath = GMSPath(fromEncodedPath: carPathCoordinates ?? "")!
            }
            // MARK: -
            func addInfoWindow(to polyline: GMSPolyline, with infoText: String, at coordinate: CLLocationCoordinate2D, color: UIColor) {
                guard let path = GMSPath(fromEncodedPath: polyline.path?.encodedPath() ?? "") else {
                    return
                }
                let middleIndex = path.count() / 2
                let middleCoordinate = path.coordinate(at: middleIndex)
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
                label.text = infoText
                label.textColor = color
                label.textAlignment = .center
                let distanceMarker = GMSMarker(position: coordinate)
                distanceMarker.iconView = label
                distanceMarker.map = GsMapView
            }
            // MARK: -
            func drawRoutes(from startCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D, travelMode: String, color: UIColor) {
                let apiKey = "AIzaSyAp2HQdQsKr0OgV5Jc_IP_3ALKrHeooUQc"
                   var directionsAPIURL = "https://maps.googleapis.com/maps/api/directions/json?"
                   directionsAPIURL += "origin=\(startCoordinate.latitude),\(startCoordinate.longitude)"
                   directionsAPIURL += "&destination=\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
                   directionsAPIURL += "&mode=\(travelMode)"
                   directionsAPIURL += "&key=\(apiKey)"
                   guard let url = URL(string: directionsAPIURL) else {
                       print("Geçersiz URL")
                       return
                   }
                   URLSession.shared.dataTask(with: url) { (data, response, error) in
                       guard let data = data, error == nil else {
                           print("Veri alınamadı veya bir hata oluştu: \(error?.localizedDescription ?? "Bilinmeyen Hata")")
                           return
                       }
                       do {
                           let json = try JSONSerialization.jsonObject(with: data, options: [])
                           guard let jsonDict = json as? [String: Any],
                                 let routes = jsonDict["routes"] as? [[String: Any]],
                                 let firstRoute = routes.first,
                                 let overviewPolyline = firstRoute["overview_polyline"] as? [String: Any],
                                 let points = overviewPolyline["points"] as? String else {
                               print("JSON verisi uygun biçimde ayrıştırılamadı")
                               return
                           }
                           DispatchQueue.main.async {
                                   let polyline = GMSPolyline(path: GMSPath(fromEncodedPath: points))
                                   polyline.strokeColor = color
                                   polyline.strokeWidth = 5.0
                                   polyline.map = self.GsMapView
                                   if travelMode == "walking" {
                                       self.bikePath = polyline
                                       self.bikePathCoordinates = points
                                   } else if travelMode == "driving" {
                                       self.carPath = polyline
                                       self.carPathCoordinates = points
                                   }
                                   self.addInfoBox(to: polyline, with: travelMode, color: color)
                                   self.highlightIntersection()
                               }
                           } catch {
                           print("JSON ayrıştırma hatası: \(error.localizedDescription)")
                       }
                   }.resume()
            }
            // MARK: -
                func userDidSelectPlace(_ place: GMSPlace) {
                       let selectedPlaceName = place.name ?? "Bilinmeyen Yer"
                       if let activeTextField = activeTextField {
                           activeTextField.text = selectedPlaceName
                       }
                    guard (locationManager.location?.coordinate) != nil else {
                           print("Başlangıç koordinatı alınamadı.")
                           return
                       }
                       let marker = GMSMarker()
                       marker.position = place.coordinate
                       marker.title = place.name
                       marker.map = GsMapView
                    self.highlightIntersection()
                       let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
                       GsMapView.animate(to: camera)
                }
            // MARK: -
            func calculateDistance(for polyline: GMSPolyline) -> Double {
                guard let path = GMSPath(fromEncodedPath: polyline.path?.encodedPath() ?? "") else {
                    return 0.0
                }
                let length = GMSGeometryLength(path)
                return length / 1000.0
            }
            // MARK: -
            func addDistanceLabel(to polyline: GMSPolyline, with distanceText: String) {
                guard let path = GMSPath(fromEncodedPath: polyline.path?.encodedPath() ?? "") else {
                    return
                }
                let middleIndex = path.count() / 2
                let middleCoordinate = path.coordinate(at: middleIndex)
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
                label.text = distanceText
                label.textColor = polyline.strokeColor
                label.textAlignment = .center
                let distanceMarker = GMSMarker(position: middleCoordinate)
                distanceMarker.iconView = label
                distanceMarker.map = GsMapView
            }
            // MARK: -
            override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "toDirectionsView" {
                    if let directionsVC = segue.destination as? DirectionsViewController, let routeInfo = sender as? [String: Any] {
                        directionsVC.routeInfo = routeInfo
                        directionsVC.travelMode = travelMode
                        print("111111111",routeInfo["destinationPrediction"],routeInfo["travelMode"],"three",routeInfo["startPrediction"])
                    }
                }
            }
            // MARK: -
            func showDirectionsForSelectedRoute(travelMode: String) {
                guard let directionsVC = storyboard?.instantiateViewController(withIdentifier: "DirectionsViewController") as? DirectionsViewController else {
                        print("DirectionsViewController oluşturulamadı.")
                        return
                    }
                    directionsVC.selectedRoute = "Başlangıç: \(startPrediction!.description), Varış: \(destinationPrediction!.description), Mod: \(travelMode)"
                print(directionsVC.selectedRoute )
                    navigationController?.pushViewController(directionsVC, animated: true)
            }
            // MARK: -
            func presentPlacePicker(forType type: String) {
                let autocompleteController = GMSAutocompleteViewController()
                autocompleteController.delegate = self
                present(autocompleteController, animated: true, completion: nil)
            }// MARK: - Select Route Button Clicked Action
            
            @IBAction func SelectRouteButtonClicked(_ sender: Any) {
                guard let startPrediction = startPrediction, let destinationPrediction = destinationPrediction else {
                    print("Hata: Başlangıç ve varış noktalarını kontrol edin.")
                    return
                }
                var routeInfo: [String: Any] = [
                    "startPrediction": startPrediction,
                    "destinationPrediction": destinationPrediction,
                    "travelMode": "Bisiklet"
                ]
                let alertController = UIAlertController(title: "Önerilen Yollar", message: "Lütfen bir rota seçin", preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(title: "Bisiklet", style: .default) { _ in
                    self.travelMode = "walking"
                    self.performSegue(withIdentifier: "toDirectionsView", sender: routeInfo)
                })

                alertController.addAction(UIAlertAction(title: "Araçla", style: .default) { _ in
                    self.travelMode = "driving"
                    self.performSegue(withIdentifier: "toDirectionsView", sender: routeInfo)
                })
                alertController.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
            // MARK: -
            func applyTheme() {
                view.backgroundColor = ThemeManager.shared.backgroundColor
                ThemeManager.shared.customizeTextField(endLocationTextField)
                ThemeManager.shared.customizeTextField(startLocationTextField)
            }
            // MARK: -
            @IBAction func searchButtonClicked(_ sender: Any) {
                guard let startLocationName = startLocationTextField.text, !startLocationName.isEmpty,
                          let destinationLocationName = endLocationTextField.text, !destinationLocationName.isEmpty else {
                            print("Hata: Başlangıç ve varış noktalarını kontrol edin.")
                            return
                    }
                    let placesClient = GMSPlacesClient.shared()
                    placesClient.findAutocompletePredictions(fromQuery: startLocationName, filter: nil, sessionToken: sessionToken) { [weak self] (startResults, startError) in
                        guard let self = self, let startResults = startResults, startError == nil, let startPrediction = startResults.first else {
                            print("Başlangıç noktası bulunamadı!")
                            return
                        }
                        self.startPrediction = startPrediction
                        placesClient.findAutocompletePredictions(fromQuery: destinationLocationName, filter: nil, sessionToken: self.sessionToken) { [weak self] (destinationResults, destinationError) in
                            guard let self = self, let destinationResults = destinationResults, destinationError == nil, let destinationPrediction = destinationResults.first else {
                                print("Varış noktası bulunamadı")
                                return
                            }
                            self.destinationPrediction = destinationPrediction
                            self.fetchPlaceInformation(for: startPrediction, destinationPrediction: destinationPrediction)
                        }
                    }
            }
        }
// MARK: - Extension for GMSAutocompleteViewControllerDelegate
        extension ViewController: GMSAutocompleteViewControllerDelegate {
            func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
                       let selectedPlaceName = place.name ?? "Bilinmeyen Yer"
                       if let activeTextField = activeTextField {
                           activeTextField.text = selectedPlaceName
                       }
                       let marker = GMSMarker()
                       marker.position = place.coordinate
                       marker.title = place.name
                       marker.map = GsMapView
                let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
                    GsMapView.animate(to: camera)
                       dismiss(animated: true, completion: nil)
            }
            func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
                print("Error: \(error.localizedDescription)")
            } 
            func wasCancelled(_ viewController: GMSAutocompleteViewController) {
                dismiss(animated: true, completion: nil)
            }
        }
