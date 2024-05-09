import UIKit

class CardView: UIView {

    // MARK: - User Interface Elements
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let starsView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    let startLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let endLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        return imageView
    }()
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
      let commentLabel: UILabel = {
          let label = UILabel()
          label.font = UIFont.systemFont(ofSize: 14)
          label.textColor = .darkGray
          label.textAlignment = .center
          label.numberOfLines = 0
          label.lineBreakMode = .byWordWrapping
          label.translatesAutoresizingMaskIntoConstraints = false
          label.layer.borderWidth = 2
          label.layer.borderColor = ThemeManager.shared.tertiaryColor.cgColor
          label.layer.cornerRadius = 16 
          return label
      }()
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        addSubview(titleLabel)
        addSubview(startLabel)
        addSubview(endLabel)
        addSubview(distanceLabel)
        addSubview(imageView)
        addSubview(starsView)
        addSubview(usernameLabel)
        addSubview(commentLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            starsView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            starsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            starsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            startLabel.topAnchor.constraint(equalTo: starsView.bottomAnchor, constant: 8),
            startLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            startLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            endLabel.topAnchor.constraint(equalTo: startLabel.bottomAnchor, constant: 8),
            endLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            endLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            distanceLabel.topAnchor.constraint(equalTo: endLabel.bottomAnchor, constant: 8),
            distanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            distanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            imageView.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: usernameLabel.topAnchor, constant: -8),
            usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            usernameLabel.bottomAnchor.constraint(equalTo: commentLabel.topAnchor, constant: -8),
            commentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            commentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            commentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            commentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        for _ in 1...5 {
            let starView = UIImageView(image: UIImage(named: "starsss.png"))
            starView.tintColor = .yellow
            starView.contentMode = .scaleAspectFit
            starView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            starView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            starsView.addArrangedSubview(starView)
        }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateCard)))
    }
    // MARK: - Configure
    func configure(with rota: Rota) {
        titleLabel.text = rota.routeTitle
        startLabel.text = "Başlangıç: \(rota.startLocation)"
        endLabel.text = "Bitiş: \(rota.endLocation)"
        distanceLabel.text = "Mesafe: \(rota.routeDistance)"
        usernameLabel.text = "Kullanıcı: \(rota.userEmail)"
        commentLabel.text = rota.comment
        for (index, starView) in starsView.arrangedSubviews.enumerated() {
            if let starImageView = starView as? UIImageView {
                starImageView.isHidden = index >= rota.starsNum
            }
        }
        if let url = URL(string: rota.ImageURL) {
            // Resmi yüklemek için bir URLSession kullan
            URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard let self = self else { return }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        print("Resim başarıyla yüklendi.")
                    }
                } else {
                    print("Resim yüklenirken hata oluştu: \(error?.localizedDescription ?? "Bilinmeyen bir hata")")
                }
            }.resume()
        } else {
            print("Geçersiz resim URL: \(rota.ImageURL)")
        }
    }
    // MARK: - Gesture Recognizer
    @objc private func animateCard() {
        UIView.animate(withDuration: 0.5, animations: {
            self.frame.origin.y += 50
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}
