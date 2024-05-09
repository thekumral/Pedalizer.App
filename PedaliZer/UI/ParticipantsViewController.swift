import UIKit
import FirebaseFirestore
// MARK: - Etkinlik Struct
struct Etkinlik {
    let id: String
    let baslik: String
    let aciklama: String
    let tarih: String
    let konum: String
    let imageURL: String?
    let userName: String
    init(document: QueryDocumentSnapshot) {
        id = document.documentID
        let data = document.data()
        baslik = data["title"] as? String ?? ""
        aciklama = data["explanation"] as? String ?? ""
        tarih = data["date"] as? String ?? ""
        konum = data["location"] as? String ?? ""
        imageURL = data["imageURL"] as? String ?? ""
        userName = data["userNum"] as? String ?? ""
    }
}
// MARK: - ParticipantsViewController
class ParticipantsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Properties
    var etkinlikler: [Etkinlik] = []
    var db: Firestore!
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        fetchEtkinlikler()
        tableView.delegate = self
        tableView.dataSource = self
    }
    // MARK: - Fetch Etkinlikler
    func fetchEtkinlikler() {
        let etkinliklerCollection = db.collection("bycleEvents")
        etkinliklerCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Firestore'dan veri çekme hatası: \(error.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("Dökümanlar bulunamadı.")
                return
            }
            self.etkinlikler = documents.map { Etkinlik(document: $0) }
            self.tableView.reloadData()
        }
    }
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return etkinlikler.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EtkinlikCell", for: indexPath)
        let etkinlik = etkinlikler[indexPath.row]
        cell.textLabel?.text = etkinlik.baslik
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let etkinlik = etkinlikler[indexPath.row]
        showExplanationPopup(etkinlik: etkinlik)
    }
    // MARK: - Show Explanation Popup
    func showExplanationPopup(etkinlik: Etkinlik) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "participantsExplanationViewController") as? participantsExplanationViewController {
            popupVC.etkinlik = etkinlik
            present(popupVC, animated: true, completion: nil)
        }
    }
}

