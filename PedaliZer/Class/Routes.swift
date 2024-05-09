import FirebaseFirestore

struct Rota {
    var routeTitle: String
    var startLocation: String
    var endLocation: String
    var startlatitude: String
    var startlongitude: String
    var endlatitude: String
    var endlongitude: String
    var ImageURL: String
    var routeDistance: String
    var starsNum: Int
    var comment: String
    var userEmail: String
    
    init(routeTitle: String, startLocation: String, endLocation: String, startlatitude: String, startlongitude: String, endlatitude: String, endlongitude: String, ImageURL: String, routeDistance: String, starsNum: Int, comment: String, userEmail: String) {
        self.routeTitle = routeTitle
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startlatitude = startlatitude
        self.startlongitude = startlongitude
        self.endlatitude = endlatitude
        self.endlongitude = endlongitude
        self.ImageURL = ImageURL
        self.routeDistance = routeDistance
        self.starsNum = starsNum
        self.comment = comment
        self.userEmail = userEmail
    }
}

class RotaManager {
    static let shared = RotaManager()
    private let db = Firestore.firestore()

    func getAllRotas(completion: @escaping ([[Rota]]) -> Void) {
        var allRotas: [[Rota]] = []

        db.collection("Routes").getDocuments { (snapshot, error) in
            if let error = error {
                print("Firestore'dan veri çekme hatası: \(error.localizedDescription)")
                completion(allRotas)
                return
            }

            if let snapshot = snapshot {
                for document in snapshot.documents {
                    var rotas: [Rota] = []
                    let data = document.data()

                    // Check if data is not nil and is of the expected type
                    if let routeTitle = data["routeTitle"] as? String,
                       let startLocation = data["startLocation"] as? String,
                       let endLocation = data["endLocation"] as? String,
                       let startlatitude = data["startLatitude"] as? String,
                       let startlongitude = data["startLongitude"] as? String,
                       let endlatitude = data["endLatitude"] as? String,
                       let endlongitude = data["endLongitude"] as? String,
                       let imageURL = data["imageURL"] as? String,
                       let routeDistance = data["routeDistance"] as? String,
                       let starsNum = data["startsNum"] as? Int,
                       let comment = data["comment"] as? String,
                       let userEmail = data["userEmail"] as? String {
                        let rota = Rota(routeTitle: routeTitle, startLocation: startLocation, endLocation: endLocation, startlatitude: startlatitude, startlongitude: startlongitude, endlatitude: endlatitude, endlongitude: endlongitude, ImageURL: imageURL, routeDistance: routeDistance, starsNum: starsNum, comment: comment, userEmail: userEmail)
                        rotas.append(rota)
                        print("Read document: \(document.documentID)")
                    } else {
                        print("Belge uygun alanları içermiyor. Belge ID: \(document.documentID)")
                    }

                    allRotas.append(rotas)
                }
            }

            completion(allRotas)
        }
    }
}
