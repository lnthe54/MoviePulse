import Foundation

class UserDataDefault {
    
    static let shared = UserDataDefault()
    
    private enum Keys: String {
        case isFirstInstall
    }
    
    func setIsFirstInstallApp(_ isFrist: Bool) {
        UserDefaults.standard.set(isFrist, forKey: Keys.isFirstInstall.rawValue)
    }
    
    func getIsFirstInstallApp() -> Bool {
        !UserDefaults.standard.bool(forKey: Keys.isFirstInstall.rawValue)
    }
}
