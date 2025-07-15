import Foundation

struct PulseResultInfo: Codable {
    let id: Int
    
    let date: Date
    
    let bpm: Int
    
    let name: String
    
    let path: String
    
    let tension: Int
}

