import UIKit

extension Array {
    public var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Array where Element: Hashable {
    func pickUniqueInValue(_ n: Int) -> [Element] {
        let set: Set<Element> = Set(self)
        guard set.count >= n else {
            fatalError("The array has to have at least \(n) unique values")
        }
        guard n >= 0 else {
            fatalError("The number of elements to be picked must be positive")
        }

        return Array(set.prefix(upTo: set.index(set.startIndex, offsetBy: n)))
    }
}

extension Array {
    func randomList(count: Int) -> [Element] {
        return Array(self.shuffled().prefix(count))
    }
    
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
