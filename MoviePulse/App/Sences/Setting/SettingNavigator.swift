import UIKit

protocol SettingNavigator {
    func gotoWebviewViewController(title: String, url: String)
}

class DefaultSettingNavigator: SettingNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func gotoWebviewViewController(title: String, url: String) {
        let viewController = WebViewViewController(title: title, url: url)
        navigationController.pushViewController(viewController, animated: true)
    }
}

