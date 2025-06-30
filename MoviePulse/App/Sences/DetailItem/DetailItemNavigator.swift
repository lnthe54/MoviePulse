import UIKit

protocol DetailItemNavigator {
   func popViewController()
}

class DefaultDetailItemNavigator: DetailItemNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }
}

