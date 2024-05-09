import UIKit

@IBDesignable
public class StarRatingControl: UIStackView {
    
    // MARK: - Properties
    private var starCount: Int = 5
    public private(set) var rating: Int = 0 {
        didSet {
            updateStars()
        }
    }
    
    private var starImageViews: [UIImageView] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
    }
    
    // MARK: - Initialization
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStars()
    }
    
    // MARK: - Private Methods
    private func setupStars() {
        for _ in 0..<starCount {
            let starImageView = UIImageView()
            starImageView.image = UIImage(named: "star_empty")
            starImageView.contentMode = .scaleAspectFit
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageViews.append(starImageView)
            addArrangedSubview(starImageView)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(starTapped))
            starImageView.addGestureRecognizer(tapGestureRecognizer)
            starImageView.isUserInteractionEnabled = true
        }
        updateStars()
    }
    @objc private func starTapped(sender: UITapGestureRecognizer) {
        guard let selectedStarIndex = starImageViews.firstIndex(of: sender.view as! UIImageView) else {
            return
        }
        rating = selectedStarIndex + 1
    }
    private func updateStars() {
        for (index, starImageView) in starImageViews.enumerated() {
            let imageName = index < rating ? "star_filled" : "star_empty"
            starImageView.image = UIImage(named: imageName)
        }
    }
}
