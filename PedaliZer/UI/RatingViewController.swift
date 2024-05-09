import UIKit
import FirebaseFirestore
import CoreLocation
import GoogleMaps
import FirebaseAuth
import GooglePlaces

class RatingViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var imageUrlTextField: UITextField!
    @IBOutlet weak var routeStartsTextField: UITextField!
    @IBOutlet weak var routeTitle: UITextField?
    // MARK: - Properties
    var selectedRoute: String?
    var startCoordinate: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?
    var startPredictionDescription: String?
    var destinationPredictionDescription: String?
    var travelMode: String?
    var routeDistance: String?
    var routeEnds: String?
    var totalDistance: Double?
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        addBackgroundImage()
    }
    // MARK: - Theme and Styling
    func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColorSignIN
    }
    // MARK: - Submit Rating
    @IBAction func submitRating(_ sender: UIButton) {
        guard
            let comment = commentTextField.text, !comment.isEmpty,
            let imageUrl = imageUrlTextField.text, !imageUrl.isEmpty,
            let routeStartsText = routeStartsTextField.text, !routeStartsText.isEmpty,
            let routeStarts = Int(routeStartsText)
        else {
            showAlert(title: "Uyarı", message: "Lütfen tüm bilgileri girin.")
            return
        }
        guard let userEmail = Auth.auth().currentUser?.email else {
            showAlert(title: "Uyarı", message: "Kullanıcı email'i alınamadı.")
            return
        }
        saveRouteInfoToFirebase(comment: comment, imageUrl: imageUrl, routeStarts: routeStarts, userEmail: userEmail)
        navigationController?.popViewController(animated: true)
    }
    // MARK: - Save Route Info to Firebase
    func saveRouteInfoToFirebase(comment: String, imageUrl: String, routeStarts: Int, userEmail: String) {
        totalDistance = (totalDistance!)/2000
        let formattedDistance = String(format: "%.2f", totalDistance!)
        let distance = "\(formattedDistance) KM"
        let db = Firestore.firestore()
        let routesCollection = db.collection("Routes")
        routesCollection.addDocument(data: [
            "routeTitle": routeTitle?.text,
            "startLatitude": "\(startCoordinate?.latitude)",
            "startLongitude": "\(startCoordinate?.longitude)",
            "startLocation": extractPlaceName(from: startPredictionDescription) ?? "",
            "endLatitude": "\(destinationCoordinate?.latitude)",
            "endLongitude": "\(destinationCoordinate?.longitude)",
            "endLocation": extractPlaceName(from: destinationPredictionDescription) ?? "",
            "startsNum": routeStarts,
            "routeDistance": distance,
            "comment": comment,
            "imageURL": imageUrl,
            "userEmail": userEmail,
        ]) { (error) in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully!")
            }
        }
    }
    // MARK: - Background Image
    func addBackgroundImage() {
        guard let imageURL = URL(string: "https://img.freepik.com/free-photo/3d-render-customer-leave-feedback-phone-screen_107791-16393.jpg?w=740&t=st=1704733200~exp=1704733800~hmac=d38dd8ffb3d788de86e09e2464e4c4ae9f89e606b3be46f511ade0df5bdeae04") else {
            return
        }
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            backgroundImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4)
        ])
        view.sendSubviewToBack(backgroundImageView)
        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let data = data, let backgroundImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    backgroundImageView.image = backgroundImage
                }
            } else {
                print("Resim yüklenemedi. Hata: \(error?.localizedDescription ?? "Bilinmeyen Hata")")
            }
        }.resume()
    }
    // MARK: - Helper Function
    func extractPlaceName(from prediction: String?) -> String? {
        guard let prediction = prediction else { return nil }
        
        let components = prediction.components(separatedBy: ",")
        if components.count > 1 {
            return components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
    // MARK: - Alert
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
