import RxSwift
import RxCocoa

class SettingViewModel: ViewModelType {
    
    func transform(input: Input) -> Output {
        return Output()
    }
}

extension SettingViewModel {
    struct Input {
        
    }
    
    struct Output {
        
    }
}

enum SettingType: CaseIterable {
    case feedback
    case share
    case gdpr
    case notification
    case ads
    
    var icon: String {
        switch self {
        case .feedback:
            return "ic_star"
        case .share:
            return "ic_share"
        case .gdpr:
            return "ic_gdpr"
        case .notification:
            return "ic_notification"
        case .ads:
            return ""
        }
    }
    
    var title: String {
        switch self {
        case .feedback:
            return "Feedback"
        case .share:
            return "Share the app"
        case .gdpr:
            return "GDPR permission"
        case .notification:
            return "Notification"
        case .ads:
            return ""
        }
    }
    
    var backgroundColor: String {
        switch self {
        case .feedback:
            return "#F85647"
        case .share:
            return "#50D4CD"
        case .gdpr:
            return "#FFAB36"
        case .notification:
            return "#79BE27"
        case .ads:
            return ""
        }
    }
}
