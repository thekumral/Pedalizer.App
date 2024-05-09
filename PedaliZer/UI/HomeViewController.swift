import UIKit
import CoreLocation
import Alamofire
// MARK: - BottomNavbarDelegate Protocol
protocol BottomNavbarDelegate: AnyObject {
    func didSelectTabBarItem(_ index: Int)
}
// MARK: - CustomTabBar Class
class CustomTabBar: UITabBar {
    override func draw(_ rect: CGRect) {
        self.barTintColor = UIColor.red
    }
}
// MARK: - BottomNavbarViewController Class
class BottomNavbarViewController: UIViewController {
    weak var delegate: BottomNavbarDelegate?
    private let backgroundView: UIView = {
        let view = UIView()
        return view
    }()
    private let tabBar: UITabBar = {
        let tabBar = CustomTabBar()
        return tabBar
    }()
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundView)
        view.addSubview(tabBar)
        tabBar.delegate = self
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 110),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 110)
        ])
        let themeColor = ThemeManager.shared.forthColor
        backgroundView.backgroundColor = themeColor
        let shopItem = UITabBarItem(title: "Dükkanlar", image: UIImage(named: "shop")?.resized(to: CGSize(width: 44, height: 44)).withRenderingMode(.alwaysOriginal), tag: 0)
        let hospitalItem = UITabBarItem(title: "Hastane", image: UIImage(named: "hospital")?.resized(to: CGSize(width: 44, height: 44)).withRenderingMode(.alwaysOriginal), tag: 1)
        let createRouteItem = UITabBarItem(title: "Rota Oluştur", image: UIImage(named: "mapcreate")?.resized(to: CGSize(width: 44, height: 44)).withRenderingMode(.alwaysOriginal), tag: 2)
        let showRouteItem = UITabBarItem(title: "Rota Göster", image: UIImage(named: "road-map")?.resized(to: CGSize(width: 44, height: 44)).withRenderingMode(.alwaysOriginal), tag: 3)
        let eventsItem = UITabBarItem(title: "Etkinlikler", image: UIImage(named: "activity")?.resized(to: CGSize(width: 44, height: 44)).withRenderingMode(.alwaysOriginal), tag: 4)
        let profileItem = UITabBarItem(title: "Profilim", image: UIImage(named: "profile")?.resized(to: CGSize(width: 44, height: 44)).withRenderingMode(.alwaysOriginal), tag: 5)
        tabBar.setItems([shopItem, hospitalItem, createRouteItem, showRouteItem, eventsItem, profileItem], animated: false)
    }
}
// MARK: - UITabBarDelegate Extension
extension BottomNavbarViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        delegate?.didSelectTabBarItem(item.tag)
    }
}
// MARK: - HomeViewController Class
class HomeViewController: UIViewController, BottomNavbarDelegate {
    private let bottomNavbarVC = BottomNavbarViewController()
    private var locationManager: CLLocationManager!
    @IBOutlet weak var degreLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var windLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        showBottomNavbar()
        addBackgroundImage()
        bottomNavbarVC.delegate = self
        fetchWeatherForFixedLocation()
    }
    func fetchWeatherForFixedLocation() {
        let latitude: Double = 38.5
        let longitude: Double = 27.7
        let apiKey = "422885c11c35eada6a2d6efe45c04e5b"
        let apiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        if let url = URL(string: apiUrl) {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Hava durumu bilgileri alınamadı. Hata: \(error.localizedDescription)")
                    return
                }
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let weatherData = try decoder.decode(WeatherData.self, from: data)
                        let temperatureInCelsius = weatherData.main.temp - 273.15
                        DispatchQueue.main.async {
                            self.degreLabel.text = String(format: "%.0f°C", temperatureInCelsius)
                            self.windLabel.text = "\(weatherData.wind.speed) m/s"
                            if let icon = weatherData.weather.first?.icon {
                                self.loadWeatherIcon(icon: icon)
                            }
                        }
                    } catch {
                        print("JSON çevrim hatası: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
        }
    }
    struct WeatherData: Decodable {
        let main: Main
        let weather: [Weather]
        let wind: Wind
    }
    struct Main: Decodable {
        let temp: Double
    }
    struct Weather: Decodable {
        let description: String
        let icon: String
    }
    struct Wind: Decodable {
        let speed: Double
    }
    func loadWeatherIcon(icon: String) {
        let iconUrl = URL(string: "https://openweathermap.org/img/w/\(icon).png")
        URLSession.shared.dataTask(with: iconUrl!) { (data, response, error) in
            if let data = data, let weatherIcon = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.weatherIconImageView.image = weatherIcon
                }
            }
        }.resume()
    }
    func addBackgroundImage() {
        guard let imageURL = URL(string: "https://img.freepik.com/free-vector/flat-world-bicycle-day-background_23-2149395046.jpg?w=1060&t=st=1704372150~exp=1704372750~hmac=bc91a6edf87e4538f3cc739298dc7cc20d1ba0acc4d6ce047d9284143b29f757") else {
            return
        }
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 350),
            backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
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
    func applyTheme() {
        let themeColor = ThemeManager.shared.backgroundColor
        view.backgroundColor = themeColor
    }
    func showBottomNavbar() {
          addChild(bottomNavbarVC)
          view.addSubview(bottomNavbarVC.view)
          bottomNavbarVC.view.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
              bottomNavbarVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              bottomNavbarVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              bottomNavbarVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
              bottomNavbarVC.view.heightAnchor.constraint(equalToConstant: 100)
          ])
          bottomNavbarVC.didMove(toParent: self)
      }
    func didSelectTabBarItem(_ index: Int) {
        switch index {
        case 0:
            performSegue(withIdentifier: "goCycleView", sender: nil)
        case 1:
            performSegue(withIdentifier: "goHospitalView", sender: nil)
        case 2:
            performSegue(withIdentifier: "goRouteCreate", sender: nil)
        case 3:
            performSegue(withIdentifier: "goRouteShow", sender: nil)
        case 4:
            performSegue(withIdentifier: "toParticipants", sender: nil)
        case 5:
            performSegue(withIdentifier: "toProfile", sender: nil)
        default:
            break
        }
    }
    // MARK: - Action: Call Emergency Number
    @IBAction func callEmergencyNumber(_ sender: Any) {
        if let phoneURL = URL(string: "tel:112"), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
}
// MARK: - UIImage Extension
extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
