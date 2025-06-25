import UIKit

extension Date {
    enum StyleDate: String {
        case dayMonthOfYear = "dd MMMM, yyyy"
        case dayFullMonthOfYear = "MMMM dd, yyyy"
        case monthSpaceYear = "MMM yyyy"
        case fullMonthSpaceYear = "MMMM yyyy"
        case dayAndDate = "EEE yyyy/MM/dd"
        case dateOnly = "yyyy/MM/dd"
        case hourOnly = "HH:mm a"
        case hourOnly12 = "h:mm a"
        case hourMinuteSecondFull = "HH:mm:ss a"
        case hourMinuteSecondFullEnglish = "hh:mm:ss a"
        case hourMinuteSecond = "HH:mm:ss"
        case dateAndHour = "yyyy/MM/dd HH:mm"
        case dateAndTime = "yyyy/MM/dd HH:mm:ss"
        case full = "EEE yyyy/MM/dd HH:mm"
        case fullTime = "EEE yyyy/MM/dd HH:mm:ss"
        case dayMonthYear = "dd/MM/yyyy"
        case dayMonthYearVN = "dd-MM-yyyy"
        case yearMonth = "yyyy-MM"
        case dateOnlyFromServer = "yyyy-MM-dd"
        case dateTime = "dd/MM/yyyy HH:mm"
        case dateTimeFromServer = "yyyy-MM-dd HH:mm:ss"
        case dateTimeFromServer2 = "dd-MM-yyyy HH:mm:ss"
        case dateHourMinuteServer = "yyyy-MM-dd HH:mm"
        case monthYear = "MM/yyyy"
        case timeOnly = "HH:mm"
        case ggFull = "yyyy-MM-dd'T'HH:mm:ssZ"
        case concurrenceEvent = "yyyyMMdd'T'HHmmssZ"
        case dateEnglish = "MMM dd, yyyy"
        case dateEnglishFull = "MMM dd, yyyy 'at' HH:mm:ss a"
        case dateVNFull = "dd MMM, yyyy 'lúc' HH:mm:ss a"
        case dateMonthDayVN = "dd MMM, yyyy"
        case dayMonthYearEnglish = "dd MMM yyyy"
        case yearMonthDay = "yyyyMMdd"
        case fullTimeFromServer = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case fullTimeFromNotification = "yyyy-MM-dd'T'HH:mm:ss XXX"
        case hourMinuteSecondsDate = "HH:mm:ss dd/MM/yyyy"
        case hourMinuteDate = "HH:mm dd/MM/yyyy"
        case monthSpaceDay = "MMM d"
        case fullDateTime = "dd/MM/yyyy HH:mm:ss"
        case dayOfMonth = "dd MMMM"
        case dayOfMonth2 = "dd MMM"
        case english = "MMM dd yyyy"
        case dayFullMonthNameYear = "dd MMMM yyyy"
        case yearOnly = "yyyy"
    }

    func toString(formatter: Date.StyleDate) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = formatter.rawValue
        dateFormatter.locale = .current
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    func toStringDefaultFomatter(formatter: Date.StyleDate) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter.rawValue
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
