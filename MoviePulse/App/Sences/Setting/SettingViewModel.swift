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
    case notification
    case support
    case share
    case gdpr
    case terms
    
    var icon: String {
        switch self {
        case .notification:
            return "ic_notification"
        case .support:
            return "ic_support"
        case .share:
            return "ic_share"
        case .gdpr:
            return "ic_gdpr"
        case .terms:
            return "ic_terms"
        }
    }
    
    var title: String {
        switch self {
        case .notification:
            return "Notification"
        case .support:
            return "Contact support"
        case .share:
            return "Share our app"
        case .gdpr:
            return "GDPR permission"
        case .terms:
            return "Terms of Service"
        }
    }
}
