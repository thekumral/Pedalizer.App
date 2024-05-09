import UIKit

class CustomTextField: UITextField {
    // MARK: - Text Field
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    private func setupTextField() {
        backgroundColor = ThemeManager.shared.backgroundColor
        textColor = ThemeManager.shared.textColor
        layer.cornerRadius = 12
        layer.borderWidth = 2
        layer.borderColor = ThemeManager.shared.secondaryColor.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.height))
        leftViewMode = .always
    }
}
