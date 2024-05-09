import FirebaseFirestore

struct PlaylistSpotify {
    var imageURL: String
    var qrCodeURL: String
    var title: String
    var duration: String
    var playlistLink: String
}

class PlaylistManagerSpotify {
    static let shared = PlaylistManagerSpotify()

    private init() {}

    func getAllPlaylists(completion: @escaping ([[PlaylistSpotify]]) -> Void) {
        let db = Firestore.firestore()
        var allPlaylists: [[PlaylistSpotify]] = []

        db.collection("SpotifyList").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting Spotify playlists: \(error.localizedDescription)")
                completion(allPlaylists)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()

                    if let imageURL = data["imageURL"] as? String,
                       let qrCodeURL = data["QrCode"] as? String,
                       let title = data["Title"] as? String,
                       let playlistLink = data["playlistLink"] as? String,
                       let duration = data["duration"] as? String {
                        let playlist = PlaylistSpotify(
                            imageURL: imageURL,
                            qrCodeURL: qrCodeURL,
                            title: title,
                            duration: duration,
                            playlistLink: playlistLink
                        )
                        allPlaylists.append([playlist])
                    }
                }

                completion(allPlaylists)
            }
        }
    }
}
