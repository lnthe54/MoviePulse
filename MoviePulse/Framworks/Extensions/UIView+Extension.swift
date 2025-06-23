import UIKit

extension UIView {
    func corner(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func setBorder(withColor color: UIColor, width: CGFloat) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}
