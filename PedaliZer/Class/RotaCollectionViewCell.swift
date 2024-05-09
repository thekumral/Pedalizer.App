import UIKit

class RotaCollectionViewCell: UICollectionViewCell {
    var cardView: CardView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCardView()
    }

    private func setupCardView() {
        cardView = CardView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        cardView.backgroundColor = ThemeManager.shared.backgroundColor
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }


    func configureCell(with rota: Rota) {
        cardView.configure(with: rota)
    }
}
