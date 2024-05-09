import Foundation

struct DirectionsResponse: Codable {
    let routes: [Route]
}

struct Route: Codable {
    let overviewPolyline: OverviewPolyline
}

struct OverviewPolyline: Codable {
    let points: String
}
