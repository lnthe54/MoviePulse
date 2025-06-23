import Foundation

extension NSObject {
    class var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
    }
}
