import Foundation

struct PulseResultInfo: Codable {
    let id: Int
    
    let date: Date
    
    let bpmValues: [Int]
    
    let name: String
    
    let path: String
    
    let tension: Int
}

extension PulseResultInfo {
    func avgBPM() -> Int {
        return bpmValues.map { $0 }.reduce(0, +) / max(bpmValues.count, 1)
    }
}

