import UIKit

class PlaylistCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    // MARK: - Properties
    var allPlaylists: [[PlaylistSpotify]] = [] // İki boyutlu dizi kullanılıyor
    var currentIndex: Int = 0
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchAllPlaylists()
        applyTheme()
    }
    // MARK: - Theme and UI Methods
    func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
    }
    func updateUI() {
        guard allPlaylists.count > 0 && currentIndex < allPlaylists.count else {
            return
        }
        let currentPlaylistSet = allPlaylists[currentIndex]
        collectionView.reloadData()
    }
    // MARK: - CollectionView Configuration
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    // MARK: - Data Fetching and Update Methods
    func fetchAllPlaylists() {
        PlaylistManagerSpotify.shared.getAllPlaylists { [weak self] (allPlaylists) in
            guard let self = self else { return }
            if allPlaylists.isEmpty {
                print("Firestore'dan Spotify playlist bilgisi alınamadı.")
            } else {
                self.allPlaylists = allPlaylists
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.currentIndex = 0
                    self.updateUI()
                }
            }
        }
    }

    
    // MARK: - CollectionView Delegate and DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPlaylists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCollectionViewCell
        let playlistSet = allPlaylists[indexPath.item]
        collectionView.backgroundColor = ThemeManager.shared.backgroundColor
        let playlist = playlistSet.first ?? PlaylistSpotify(imageURL: "", qrCodeURL: "", title: "", duration: "" ,playlistLink: "")
        cell.configureCell(with: playlist)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 700, height: 700)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
