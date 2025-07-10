import UIKit

protocol SettingNavigator {
    
}

class DefaultSettingNavigator: SettingNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

