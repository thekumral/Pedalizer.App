import UIKit
// MARK: - participantsExplanationViewController
class participantsExplanationViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var userNumbersLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    // MARK: - Properties
    var etkinlik: Etkinlik?
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        toDos()
    }
    // MARK: - Apply Theme
    func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColorSignIN
        imageView.layer.borderColor = ThemeManager.shared.tertiaryColor.cgColor
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        explanationLabel.layer.borderWidth = 2.0
        explanationLabel.layer.borderColor = ThemeManager.shared.tertiaryColor.cgColor
        explanationLabel.layer.cornerRadius = 30.0
        dateLabel.layer.borderWidth = 2.0
        dateLabel.layer.borderColor = ThemeManager.shared.tertiaryColor.cgColor
        dateLabel.layer.cornerRadius = 5.0
    }
    // MARK: - ToDos
    func toDos(){
        if let etkinlik = etkinlik {
            titleLabel.text = etkinlik.baslik
            explanationLabel.text = etkinlik.aciklama
            dateLabel.text = etkinlik.tarih
            locationLabel.text = etkinlik.konum
            userNumbersLabel.text = etkinlik.userName
            if let imageURLString = etkinlik.imageURL, let imageURL = URL(string: imageURLString) {
                downloadImage(from: imageURL)
            }
        }
    }
    // MARK: - Download Image
    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }.resume()
    }
}
