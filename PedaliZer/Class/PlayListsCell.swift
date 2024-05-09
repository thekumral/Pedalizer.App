import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var qrCodeImageView: UIImageView!
    var titleLabel: UILabel!
    var durationLabel: UILabel!

    var playlistLink: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        qrCodeImageView.image = nil
        titleLabel.text = nil
        durationLabel.text = nil
        playlistLink = nil
    }

    private func setupUI() {
        // ImageView
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)

        // QR Code ImageView
        qrCodeImageView = UIImageView()
        qrCodeImageView.contentMode = .scaleAspectFit
        addSubview(qrCodeImageView)

        // Title Label
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        addSubview(titleLabel)

        // Duration Label
        durationLabel = UILabel()
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.textColor = .gray
        addSubview(durationLabel)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                imageView.addGestureRecognizer(tapGesture)
                imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),

            qrCodeImageView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            qrCodeImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 180),
            qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: qrCodeImageView.topAnchor),
               titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
               titleLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -8),

               durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
               durationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
               durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])

    }
    @objc private func imageTapped() {
            if let playlistLink = URL(string: playlistLink ?? "") {
                UIApplication.shared.open(playlistLink)
            }
        }
    func configureCell(with playlist: PlaylistSpotify) {
            if let imageURL = URL(string: playlist.imageURL) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: imageURL) {
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: data)
                        }
                    }
                }
            }

            if let qrCodeURL = URL(string: playlist.qrCodeURL) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: qrCodeURL) {
                        DispatchQueue.main.async {
                            self.qrCodeImageView.image = UIImage(data: data)
                        }
                    }
                }
            }

                titleLabel.text = playlist.title
               durationLabel.text = playlist.duration
               playlistLink = playlist.playlistLink
    }
}
