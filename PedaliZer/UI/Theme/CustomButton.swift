import UIKit

class CustomButton: UIButton {
    // MARK: - Custom Button
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    private func setupButton() {
        backgroundColor = ThemeManager.shared.backgroundColor
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        setTitleColor(ThemeManager.shared.textColor, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    @objc private func buttonPressed() {
        print("Button pressed!")
    }
}
