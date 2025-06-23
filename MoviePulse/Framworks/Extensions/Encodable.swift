import Foundation

extension Encodable {
    func asDictionary() -> [String: Any] {
        guard
            let data = try? JSONEncoder().encode(self),
            let json = try? JSONSerialization.jsonObject(with: data),
            let dict = json as? [String: Any]
        else {
            return [:]
        }

        return dict
    }
}
