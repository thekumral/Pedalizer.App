import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        addBackgroundImage()
    }

    // MARK: - UI Functions
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    // MARK: - Functions
    func applyTheme() {
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = ThemeManager.shared.backgroundColorSignIN
        ThemeManager.shared.customizeTextField(emailTextField)
        ThemeManager.shared.customizeTextField(passwordTextField)
        passwordTextField.isSecureTextEntry = true
        let loginButton = UIButton()
        loginButton.setTitle("Giriş Yap", for: .normal)
        loginButton.backgroundColor = ThemeManager.shared.forthColor
        loginButton.setTitleColor(ThemeManager.shared.textColor, for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
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
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            backgroundImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3)
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
    // MARK: - Button Actions
    @IBAction func showPasswordButtonClicked(_ sender: Any) {
        passwordTextField.isSecureTextEntry.toggle()
    }
    @IBAction func loginButtonClicked(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showAlert(message: "Lütfen tüm alanları doldurun.")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                print("Hata:", error.localizedDescription)
                self.showAlert(message: "Giriş sırasında bir hata oluştu.")
            } else if let authResult = authResult {
                let displayName = authResult.user.displayName
                if displayName == nil {
                    let changeRequest = authResult.user.createProfileChangeRequest()
                    changeRequest.displayName = "Kullanıcı Adı"
                    changeRequest.commitChanges { [weak self] (error) in
                        guard let self = self else { return }
                        if let error = error {
                            print("Hata:", error.localizedDescription)
                        } else {
                            self.performSegue(withIdentifier: "toHome", sender: self)
                        }
                    }
                } else {
                    self.performSegue(withIdentifier: "toHome", sender: self)
                }
            }
        }
    }
    
    
    @IBAction func RegisterButtonClicked(_ sender: Any) {
        
    }
}
