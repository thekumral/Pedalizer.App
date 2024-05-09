import UIKit
import FirebaseFirestoreInternal
import Firebase
// MARK: - User Struct

struct User {
    var name: String
    var phone: String
    var imageURL: String
    var mail: String
    init(name: String, phone: String, imageURL: String, mail: String) {
        self.name = name
        self.phone = phone
        self.imageURL = imageURL
        self.mail = mail
    }
}
// MARK: - ProfileViewController
class ProfileViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var changePassReTextField: UITextField!
    // MARK: - Properties
    var user: User?
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        applyTheme()
    }
    // MARK: - Fetch User Data
    func fetchUserData() {
        if let currentUser = Auth.auth().currentUser {
            mailLabel.text = currentUser.email
            let db = Firestore.firestore()
            db.collection("users").whereField("mail", isEqualTo: currentUser.email).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Firestore'dan kullanıcı bilgilerini alma hatası: \(error.localizedDescription)")
                    return
                }
                if let document = querySnapshot?.documents.first {
                    let data = document.data()
                    let user = User(
                        name: data["nameSurname"] as? String ?? "",
                        phone: data["phone"] as? String ?? "",
                        imageURL: data["imageURL"] as? String ?? "",
                        mail: data["mail"] as? String ?? ""
                    )
                    self.user = user
                    self.nameLabel.text = user.name
                    self.phoneLabel.text = user.phone
                    self.mailLabel.text = user.mail
                    self.loadImage(from: user.imageURL)
                }
            }
        }
    }
    // MARK: - Load Image
    func loadImage(from urlString: String) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
                        self.imageView.clipsToBounds = true
                    }
                }
            }.resume()
        }
    }
    // MARK: - Apply Theme
    func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = ThemeManager.shared.tertiaryColor.cgColor
    }
    // MARK: - Add Background Image

    func addBackgroundImage() {
        guard let imageURL = URL(string: "https://img.freepik.com/premium-vector/bicycle-green_54199-350.jpg?w=740") else {
            return
        }
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 400),
            backgroundImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05)
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
    // MARK: - Change Password Action
    @IBAction func changePassword(_ sender: Any) {
        if let newPassword = passwordTextField.text {
            Auth.auth().currentUser?.updatePassword(to: newPassword) { (error) in
                if let error = error {
                    print("Şifre güncelleme hatası: \(error.localizedDescription)")
                } else {
                    print("Şifre başarıyla güncellendi.")
                    self.passwordTextField.text = ""
                    self.changePassReTextField.text = ""
                    self.passwordTextField.isEnabled = false
                }
            }
        }
    }
    // MARK: - Logout Button Action
    @IBAction func logOutButtonClicked(_ sender: Any) {
        do {
              try Auth.auth().signOut()
                   if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                       navigationController?.pushViewController(loginVC, animated: true)
                   }
          } catch {
              print("Oturum kapatma hatası: \(error.localizedDescription)")
          }
    }
}
