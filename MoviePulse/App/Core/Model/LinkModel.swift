import Foundation

// MARK: - LinkContainer
struct LinkContainer: Codable {
    let time: Int?
    let data: [LinkModel]?
}

// MARK: - Datum
struct LinkModel: Codable {
    let website: String?
    let links: [String]?
}

struct WatchModel {
    var path: String?
    var data: [LinkModel]?
}
