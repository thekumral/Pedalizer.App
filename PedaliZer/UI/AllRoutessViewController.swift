import UIKit

class AllRoutessViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
        
        var directionsArray: [String] = []
        var distancesArray: [String] = []
        var durationsArray: [String] = []
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if !directionsArray.isEmpty {
                tableView.reloadData()
            }
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
           print("Directions: \(directionsArray)")
           print("Distances: \(distancesArray)")
           print("Durations: \(durationsArray)")
    }
    // MARK: - TableView Delegate & DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return directionsArray.count
       }
    // MARK: - Cell Identifier Configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = ""
        if indexPath.row == 0 {
            cellIdentifier = "firstCell"
        } else if indexPath.row == 1 {
            cellIdentifier = "secondCell"
        } else if indexPath.row == 2 {
            cellIdentifier = "thirdCell"
        } else if indexPath.row == 3 {
            cellIdentifier = "forthCell"
        } else if indexPath.row == 4 {
            cellIdentifier = "fifthCell"
        } else if indexPath.row == 5 {
            cellIdentifier = "sixCell"
        } else if indexPath.row == 6 {
            cellIdentifier = "sevenCell"
        } else if indexPath.row == 7 {
            cellIdentifier = "eightCell"
        } else if indexPath.row == 8 {
            cellIdentifier = "nineCell"
        } else {
        }
        // MARK: - Configure Cell Content
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let titleLabel = cell.textLabel {
            let distance = distancesArray.indices.contains(indexPath.row) ? distancesArray[indexPath.row] : ""
            let duration = durationsArray.indices.contains(indexPath.row) ? durationsArray[indexPath.row] : ""
            titleLabel.text = "Distance: \(distance), Duration: \(duration)"
        }
        if let detailLabel = cell.detailTextLabel {
            detailLabel.text = "Directions: \(directionsArray[indexPath.row])"
        }
        return cell
    }
}
