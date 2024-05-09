import UIKit

class ShowRoutesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    // MARK: - Properties
    var allRotas: [[Rota]] = []
    var currentIndex: Int = 0
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllRotas()
        configureCollectionView()
        updateUI()
        applyTheme()
    }
    // MARK: - Theme and UI Configuration
    func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        collectionView.backgroundColor = ThemeManager.shared.backgroundColor
    }
    // MARK: - CollectionView DataSource and Delegate
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    func fetchAllRotas() {
        RotaManager.shared.getAllRotas { [weak self] (rotas) in
            guard let self = self else { return }

            if rotas.isEmpty {
                print("Firestore'dan rota bilgisi alınamadı.")
            } else {
                self.allRotas = rotas
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.currentIndex = 0
                    self.updateUI()
                }
            }
        }
    }
    func updateUI() {
        backButton.isEnabled = currentIndex > 0
        nextButton.isEnabled = currentIndex < allRotas.count - 1
        guard allRotas.count > 0 && allRotas[currentIndex].count > 0 else {
            return
        }
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        let currentSubArray = allRotas[currentIndex]
        print("Showing allRotas[\(currentIndex)]")
        print(currentSubArray)
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard currentIndex < allRotas.count else {
            return 0
        }
        return allRotas[currentIndex].count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RotaCell", for: indexPath) as! RotaCollectionViewCell
        let rota = allRotas[currentIndex][indexPath.item]
        cell.configureCell(with: rota)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width - 32
        let cellHeight = collectionView.frame.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    // MARK: - Button Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        if currentIndex > 0 {
            currentIndex -= 1
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
            updateUI()
        }
    }
    @IBAction func nextButtonTapped(_ sender: Any) {
        if currentIndex < allRotas.count - 1 {
            currentIndex += 1
            updateUI()
        } else if currentIndex == allRotas.count - 1 && !allRotas[currentIndex].isEmpty {
            currentIndex = 0
            updateUI()
        }
    }
}
