import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet weak var rePasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nameSurnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var imageURL: UITextField!
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        addBackgroundImage()
    }
    // MARK: - Alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    // MARK: - Theme

    func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColorSignIN
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ThemeManager.shared.tertiaryColor,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: placeholderAttributes)
        nameSurnameTextField.attributedPlaceholder = NSAttributedString(string: "Name Surname", attributes: placeholderAttributes)
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "Phone", attributes: placeholderAttributes)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: placeholderAttributes)
        rePasswordTextField.attributedPlaceholder = NSAttributedString(string: "Re-enter Password", attributes: placeholderAttributes)
        imageURL.attributedPlaceholder = NSAttributedString(string: "imageURL", attributes: placeholderAttributes)
        let saveButton = UIButton()
        saveButton.setTitle("Kayıt Ol", for: .normal)
        saveButton.backgroundColor = ThemeManager.shared.forthColor
        saveButton.setTitleColor(ThemeManager.shared.textColor, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    // MARK: - Background Image
    func addBackgroundImage() {
        guard let imageURL = URL(string: "https://img.freepik.com/premium-vector/bicycle-green_54199-350.jpg?w=740") else {
            return
        }
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            backgroundImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1)
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
    // MARK: - Save Button Action
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let nameSurname = nameSurnameTextField.text,
              let email = emailTextField.text,
              let phone = phoneTextField.text,
              let password = passwordTextField.text,
              let rePassword = rePasswordTextField.text,
              let imageURL = imageURL.text,
              !nameSurname.isEmpty, !email.isEmpty, !phone.isEmpty, !password.isEmpty, !rePassword.isEmpty, !imageURL.isEmpty
        else {
            showAlert(message: "Lütfen tüm alanları doldurun.")
            return
        }
        guard password == rePassword else {
            showAlert(message: "Şifreler uyuşmuyor. Lütfen tekrar kontrol edin.")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Hata:", error.localizedDescription)
                self.showAlert(message: "Kayıt sırasında bir hata oluştu.")
            } else if let user = authResult?.user {
                print("Kullanıcı başarıyla kaydedildi.")
                let userData: [String: Any] = [
                    "nameSurname": nameSurname,
                    "mail": email,
                    "phone": phone,
                    "imageURL": imageURL
                ]
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(user.uid)
                userRef.setData(userData) { error in
                    if let error = error {
                        print("Kullanıcı profili kaydedilemedi: \(error.localizedDescription)")
                    } else {
                        print("Kullanıcı profili başarıyla kaydedildi.")
                    }
                }
            }
        }
    }
}
