import GoogleMaps
import GooglePlaces
import UIKit
import CoreLocation

class DirectionsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var routeInfosLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var durationImageView: UIImageView!


    var directions: [String] = []
    var currentStepIndex: Int = 0
    var distances: [String] = []
    var durations: [String] = []
    var selectedRoute: String?
    var startCoordinate: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?
    var startPredictionDescription: String?
    var destinationPredictionDescription: String?
    var travelMode: String?
    var locationManager = CLLocationManager()
    var routeInfo: [String: Any]?
    var arrowMarker: GMSMarker?
    var deviceLocationMarker: GMSMarker?
    var steps: [[String: Any]]?
    var routeSteps: [String] = []
    var totalDistance: Double = 0.0


    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ROUTE IINFO", travelMode)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        applyTheme()
        startButton.isEnabled=true
        
        if let routeInfos = routeInfo,
            let startPrediction = routeInfos["startPrediction"] as? GMSAutocompletePrediction,
            let destinationPrediction = routeInfos["destinationPrediction"] as? GMSAutocompletePrediction,
            let mode = routeInfos["travelMode"] as? String {
            startPredictionDescription = startPrediction.description
            destinationPredictionDescription = destinationPrediction.description
            placeCoordinateAndShowDirections(startPrediction, destinationPrediction)
        } else {
            print("Hata: Gerekli değerler alınamadı.")
        }
    }
    // MARK: - Location Functions
    func placeCoordinateAndShowDirections(_ startPrediction: GMSAutocompletePrediction, _ destinationPrediction: GMSAutocompletePrediction) {
        let placesClient = GMSPlacesClient()
        let placeFields: GMSPlaceField = [.coordinate]
        let sessionToken = GMSAutocompleteSessionToken.init()
        placesClient.fetchPlace(fromPlaceID: startPrediction.placeID ?? "", placeFields: placeFields, sessionToken: sessionToken) { [weak self] (startPlace, startError) in
            guard let self = self else { return }
            if let startError = startError {
                print("Hata: \(startError.localizedDescription)")
                return
            }
            guard let startCoordinate = startPlace?.coordinate else {
                print("Hata: Başlangıç Koordinatlar alınamadı.")
                return
            }
            self.startCoordinate = startCoordinate
            self.addDeviceLocationMarker()
            placesClient.fetchPlace(fromPlaceID: destinationPrediction.placeID ?? "", placeFields: placeFields, sessionToken: sessionToken) { [weak self] (destinationPlace, destinationError) in
                guard let self = self else { return }
                if let destinationError = destinationError {
                    print("Hata: \(destinationError.localizedDescription)")
                    return
                }
                guard let destinationCoordinate = destinationPlace?.coordinate else {
                    print("Hata: Bitiş Koordinatlar alınamadı.")
                    return
                }
                DispatchQueue.main.async {
                    if let travelMode = self.travelMode {
                        self.showMapWithDirections(startCoordinate: startCoordinate, destinationCoordinate: destinationCoordinate, travelMode: travelMode)
                    } else {
                        print("Hata: travelMode nil değeri içeriyor.")
                    }
                }
            }
        }
    }
    // MARK: - Helper Functions
    func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        routeInfosLabel.layer.borderWidth = 1.0
        routeInfosLabel.layer.borderColor = ThemeManager.shared.tertiaryColor.cgColor
        routeInfosLabel.layer.cornerRadius = 30.0
       
    }
    func removeHTMLTags(from attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        let range = NSRange(location: 0, length: mutableAttributedString.length)
        
        mutableAttributedString.enumerateAttributes(in: range, options: []) { (attributes, range, _) in
            for (key, value) in attributes {
                if key == NSAttributedString.Key(rawValue: "NSOriginalFont") {
                    mutableAttributedString.removeAttribute(key, range: range)
                }
                if key == NSAttributedString.Key(rawValue: "NSLink") {
                    mutableAttributedString.removeAttribute(key, range: range)
                }
                if value is NSParagraphStyle {
                    mutableAttributedString.removeAttribute(key, range: range)
                }
            }
        }
        return mutableAttributedString
    }
    func showMapWithDirections(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, travelMode: String) {
        let latitudeDelta = abs(startCoordinate.latitude - destinationCoordinate.latitude) * 1.5
        let longitudeDelta = abs(startCoordinate.longitude - destinationCoordinate.longitude) * 1.5
        print("Başlangıç Koordinatları: \(startCoordinate.latitude), \(startCoordinate.longitude)")
        print("Bitiş Koordinatları: \(destinationCoordinate.latitude), \(destinationCoordinate.longitude)")
        let camera = GMSCameraPosition.camera(withLatitude: (startCoordinate.latitude + destinationCoordinate.latitude) / 2,
                                                  longitude: (startCoordinate.longitude + destinationCoordinate.longitude) / 2,
                                                  zoom: getZoomLevel(for: max(latitudeDelta, longitudeDelta)),
                                              bearing: GMSGeometryHeading(startCoordinate, destinationCoordinate),
                                              viewingAngle: 180.0)
            mapView.camera = camera
        mapView.isMyLocationEnabled = true 
        drawSelectedRoute(from: startCoordinate, to: destinationCoordinate, travelMode: travelMode)
        if let routeInfos = routeInfo,
                let legs = routeInfos["legs"] as? [[String: Any]],
                let steps = legs.first?["steps"] as? [[String: Any]] {
                let routeInstructions = createRouteInstructions(steps: steps)
                let cleanedText = removeHTMLTags(from: routeInstructions)
                self.startCoordinate = startCoordinate
                self.destinationCoordinate = destinationCoordinate
                self.steps = steps
                            }
    }
    func getGoogleMapsAPIKey() -> String? {
        return "AIzaSyAp2HQdQsKr0OgV5Jc_IP_3ALKrHeooUQc"
    }
    func showRouteStep(index: Int) {
        guard index >= 0, index < routeSteps.count else {
            print("Geçersiz adım indeksi.")
            return
        }
        let routeStepText = "\(index + 1). \(routeSteps[index])"
    }
    func drawSelectedRoute(from startCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D, travelMode: String) {
        guard let apiKey = getGoogleMapsAPIKey() else {
            print("API key is missing.")
            return
        }
        var directionsAPIURL = "https://maps.googleapis.com/maps/api/directions/json?"
        directionsAPIURL += "origin=\(startCoordinate.latitude),\(startCoordinate.longitude)"
        directionsAPIURL += "&destination=\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        directionsAPIURL += "&mode=\(travelMode)"
        directionsAPIURL += "&key=\(apiKey)"
        guard let url = URL(string: directionsAPIURL) else {
            print("Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            guard let data = data, error == nil else {
                print("Veri alınamadı veya bir hata oluştu: \(error?.localizedDescription ?? "Bilinmeyen Hata")")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let routes = json["routes"] as? [[String: Any]] {
                        if let firstRoute = routes.first {
                            if let legs = firstRoute["legs"] as? [[String: Any]] {
                                if let steps = legs.first?["steps"] as? [[String: Any]] {
                                    if let polyline = firstRoute["overview_polyline"] as? [String: Any],
                                        let points = polyline["points"] as? String {
                                        DispatchQueue.main.async {
                                            self.mapView.clear()
                                            let overviewPolyline = GMSPolyline(path: GMSPath(fromEncodedPath: points))
                                            overviewPolyline.strokeColor = .green
                                            overviewPolyline.strokeWidth = 5.0
                                            overviewPolyline.map = self.mapView
                                            self.steps = steps  // steps dizisini güncelle
                                            var travelModes: [String] = []
                                            var distances: [String] = []
                                            var durations: [String] = []
                                            for step in steps {
                                                if let travelMode = step["travel_mode"] as? String {
                                                    travelModes.append(travelMode)
                                                }
                                                if let distance = step["distance"] as? [String: Any], let distanceText = distance["text"] as? String {
                                                    distances.append(distanceText)
                                                        if let value = distance["value"] as? Double {
                                                            print(self.totalDistance,value)
                                                            self.totalDistance += value
                                                        }
                                                }
                                                if let duration = step["duration"] as? [String: Any], let durationText = duration["text"] as? String {
                                                    durations.append(durationText)
                                                }
                                            }
                                            if let firstDuration = durations.first {
                                                self.durationLabel.text = "Duration: \(firstDuration)"
                                            }
                                            if let firstDistance = distances.first {
                                                self.distanceLabel.text = "Distance: \(firstDistance)"
                                            }
                                            self.updateArrowMarkerRotation(steps: steps)
                                            if let nextStep = steps.first {
                                                if let nextPolyline = nextStep["polyline"] as? [String: Any],
                                                    let nextPoints = nextPolyline["points"] as? String {
                                                    let nextPolyline = GMSPolyline(path: GMSPath(fromEncodedPath: nextPoints))
                                                    nextPolyline.strokeColor = .red  // Paralel yol için farklı bir renk kullanabilirsiniz
                                                    nextPolyline.strokeWidth = 5.0
                                                    nextPolyline.map = self.mapView
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print("JSON ayrıştırma hatası: \(error.localizedDescription)")
            }
        }.resume()
    }
    func updateLabelWithDirections() {
            if let routeInfos = routeInfo,
               let legs = routeInfos["legs"] as? [[String: Any]],
               let firstLeg = legs.first,
               let steps = firstLeg["steps"] as? [[String: Any]] {
                if currentStepIndex < steps.count {
                    let step = steps[currentStepIndex]
                    if let htmlInstruction = step["html_instructions"] as? String {
                        let cleanedInstruction = removeHTMLTags(from: NSAttributedString(string: htmlInstruction))
                        DispatchQueue.main.async {
                            self.routeInfosLabel.attributedText = cleanedInstruction
                            self.routeInfosLabel.sizeToFit()
                        }
                    }
                    currentStepIndex += 1
                } 
            } else {
                print("Legs or steps is nil")
            }
        }
    func updateArrowMarkerRotation(steps: [[String: Any]]) {
        guard let arrowMarker = self.arrowMarker, let startCoordinate = self.startCoordinate, let destinationCoordinate = self.destinationCoordinate else {
            return
        }
        guard let lastStep = steps.last, let lastStepOrientation = lastStep["orientation"] as? Double else {
            return
        }
        let heading = GMSGeometryHeading(startCoordinate, destinationCoordinate)
        arrowMarker.rotation = heading + lastStepOrientation
    }
    func placeCoordinate(for prediction: GMSAutocompletePrediction) -> CLLocationCoordinate2D? {
        let placesClient = GMSPlacesClient()
        let placeFields: GMSPlaceField = [.coordinate]
        let sessionToken = GMSAutocompleteSessionToken.init()
        placesClient.fetchPlace(fromPlaceID: prediction.placeID ?? "", placeFields: placeFields, sessionToken: sessionToken) { (place, error) in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                return
            }
            guard let coordinate = place?.coordinate else {
                print("Hata: Koordinatlar alınamadı.")
                return
            }
            print("Bitiş Koordinatları: \(coordinate.latitude), \(coordinate.longitude)")
            if let startCoord = self.startCoordinate {
                self.drawSelectedRoute(from: startCoord, to: coordinate, travelMode: self.travelMode!)
            } else {
                print("Hata: Başlangıç koordinatları alınamadı.")
            }
        }
        return nil
    }
    func addDeviceLocationMarker(at coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)) {
        deviceLocationMarker?.map = nil
        let marker = GMSMarker(position: coordinate)
        if let deviceLocationImage = UIImage(named: "end") {
            let newSize = CGSize(width: 30, height: 30)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            deviceLocationImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            marker.icon = resizedImage
        }
        marker.map = mapView
        self.deviceLocationMarker = marker
    }
    func createRouteInstructions(steps: [[String: Any]]) -> NSAttributedString {
        var instructions = "<ol>"
        for step in steps {
            if let htmlInstruction = step["html_instructions"] as? String {
                let cleanedInstruction = htmlInstruction.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                instructions += "<li>\(cleanedInstruction)</li>"
            }
        }
        instructions += "</ol>"
        if let data = instructions.data(using: .utf8) {
            do {
                return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            } catch {
                print("HTML dönüşüm hatası: \(error.localizedDescription)")
            }
        }
        return NSAttributedString(string: "")
    }
    func getZoomLevel(for delta: CLLocationDegrees) -> Float {
        let zoomLevel = log2(360.0 * Double(mapView.frame.size.width / 256.0) / delta)
        return Float(max(10, min(zoomLevel, 18)))
    }
    // MARK: - IBActions
    @IBAction func showRatingScreen(_ sender: Any) {
           if let ratingVC = storyboard?.instantiateViewController(withIdentifier: "RatingViewController") as? RatingViewController {
               ratingVC.selectedRoute = selectedRoute
               ratingVC.startCoordinate = startCoordinate
               ratingVC.destinationCoordinate = destinationCoordinate
               ratingVC.startPredictionDescription = startPredictionDescription
               ratingVC.destinationPredictionDescription = destinationPredictionDescription
               ratingVC.travelMode = travelMode
               ratingVC.totalDistance = totalDistance
               print(self.totalDistance,"directionsViewController")
               navigationController?.pushViewController(ratingVC, animated: true)
           }
    }
    @IBAction func startButtonTapped(_ sender: Any) {
        nextStep()
        routeInfosLabel.isHidden=false
        distanceLabel.isHidden=false
        durationLabel.isHidden=false
        startButton.isEnabled=false
        durationImageView.isHidden = false
        clockImageView.isHidden = false
    }
    @IBAction func showNextStep(_ sender: Any) {
        nextStep()
    }
    
    func nextStep() {
        guard let steps = steps, currentStepIndex < steps.count else {
            showAlert(title: "Uyarı", message: "son yol tarifini görüyosunuz.")
            return
        }
        let step = steps[currentStepIndex]
        showStepOnLabel(step: step)
        if let startCoordinate = self.startCoordinate, let destinationCoordinate = self.destinationCoordinate {
            // Çizilen rotayı güncelle ve haritayı o rotaya odakla
            drawSelectedRoute(from: startCoordinate, to: destinationCoordinate, travelMode: travelMode!)
        }
        if let distance = step["distance"] as? [String: Any], let distanceText = distance["text"] as? String {
            distances.append(distanceText)
            self.distanceLabel.text = "Uzaklık \(distanceText)"
        }
        if let duration = step["duration"] as? [String: Any], let durationText = duration["text"] as? String {
            durations.append(durationText)
            self.durationLabel.text = "\(durationText)"
        }
        currentStepIndex += 1
    }
    func showStepOnLabel(step: [String: Any]) {
        guard let htmlInstruction = step["html_instructions"] as? String else {
            print("HTML instruction is nil.")
            return
        }
        let cleanedText = htmlInstruction.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines)
        DispatchQueue.main.async {
            self.routeInfosLabel.text = cleanedText
            self.routeInfosLabel.sizeToFit()
        }
    }
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
// MARK: - Extensison
extension DirectionsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last?.coordinate else { return }
        startCoordinate = currentLocation
        updateLabelWithDirections()
        if let routeInfos = routeInfo,
            let destinationPrediction    = routeInfos["destinationPrediction"] as? GMSAutocompletePrediction,
            let startPrediction = routeInfos["startPrediction"] as? GMSAutocompletePrediction {
            placeCoordinateAndShowDirections(startPrediction, destinationPrediction)
        }
        addDeviceLocationMarker(at: currentLocation)
    }
}
