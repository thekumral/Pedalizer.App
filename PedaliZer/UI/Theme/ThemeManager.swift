import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    private init() {}
    // MARK: - Colours
    var primaryColor: UIColor {
        return UIColor(red: 250/255.0, green: 241/255.0, blue: 228/255.0, alpha: 1.0)
    }
    var secondaryColor: UIColor {
        return UIColor(red: 27/255.0, green: 107/255.0, blue: 147/255.0, alpha: 1.0)
    }
    var tertiaryColor: UIColor {
        return UIColor(red: 33/255.0, green: 51/255.0, blue: 99/255.0, alpha: 1.0)
    }
    var butonBackgrounSignIn: UIColor {
        return UIColor(red: 79/255.0, green: 192/255.0, blue: 208/255.0, alpha: 1.0)
    }
    var forthColor: UIColor {
        return UIColor(red: 23/255.0, green: 89/255.0, blue: 74/255.0, alpha: 1.0)
    }
    var backgroundColor: UIColor {
        return UIColor(red: 240/255.0, green: 235/255.0, blue: 206/255.0, alpha: 1.0)
    }
    var backgroundColorSignIN: UIColor {
        return UIColor(red: 223/255.0, green: 255/255.0, blue: 216/255.0, alpha: 1.0)
    }
    var lastColor: UIColor {
        return UIColor(red: 176/255.0, green: 166/255.0, blue: 149/255.0, alpha: 1.0)
    }
    var textColor: UIColor {
        return UIColor(red: 250/255.0, green: 241/255.0, blue: 228/255.0, alpha: 1.0)
    }
    // MARK: - Style
    func applyTextStyle(to label: UILabel) {
        label.textColor = textColor
    }
    func customizeTextField(_ textField: UITextField) {
        textField.backgroundColor = backgroundColor
        textField.textColor = tertiaryColor
        textField.layer.cornerRadius = 8
    }
}
