import UIKit

protocol CategoryNavigator {
    func popViewController()
}

class DefaultCategoryNavigator: CategoryNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }
}

