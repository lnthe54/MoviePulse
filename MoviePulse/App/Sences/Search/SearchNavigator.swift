import UIKit

protocol SearchNavigator {
    func popToViewController()
}

class DefaultSearchNavigator: SearchNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
}

