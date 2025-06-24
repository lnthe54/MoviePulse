import UIKit

extension UIFont {
    
    private static func fontDefault(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: fontSize)!
    }
    
    static func outfitFont(ofSize size: CGFloat, weight: OutfitWeight = .regular) -> UIFont {
        return UIFont(name: weight.fontName, size: size) ?? fontDefault(fontSize: size)
    }
}

enum OutfitWeight {
    case regular
    case semiBold
    case medium
    case light
    
    var fontName: String {
        switch self {
        case .regular:
            return "Outfit-Regular"
        case .semiBold:
            return "Outfit-SemiBold"
        case .medium:
            return "Outfit-Medium"
        case .light:
            return "Outfit-Light"
        }
    }
}
