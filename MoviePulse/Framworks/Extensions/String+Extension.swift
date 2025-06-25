import UIKit

extension String {
    func toDate(formatter: Date.StyleDate) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter.rawValue
        let date = dateFormatter.date(from: self)
        return date ?? Date()
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func removeSpecialChar() -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(.whitespaces)
        let filtered = self.unicodeScalars.filter { allowedCharacters.contains($0) }
        return String(String.UnicodeScalarView(filtered))
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Double {
    func toCurrencyFormat() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        let str = currencyFormatter.string(from: NSNumber(value: self)) ?? "0"
        return str
    }
}

extension Int {
    func getHourMin() -> (hour: Int, min: Int) {
        let hour: Int = self / 60
        let min: Int = self % 60
        return (hour, min)
    }
    
    func toHourMinute() -> String {
        let hours = self / 60
        let remainingMinutes = self % 60
        return String(format: "%02d:%02d:00", hours, remainingMinutes)
    }
}
