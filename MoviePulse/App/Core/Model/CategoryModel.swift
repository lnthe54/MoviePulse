import Foundation

struct CategoryContainer: Codable {
    let genres: [CategoryObject]
}

struct CategoryObject: Codable {
    let id: Int
    let name: String
    
    var hexColor: String {
        switch id {
        case 12, 28, 99, 10759:
            return "#79BE27" // Green
        case 16, 10752, 10768:
            return "#50D4CD" // Sky
        case 14, 35, 10767, 10770:
            return "#FFAB36" // Yellow
        case 27, 37, 53, 80, 9648:
            return "#944FEC" // Purple
        case 18, 10751, 10749, 10763:
            return "#F85647" // Red
        default:
            return "#2070D9"
        }
    }
}
