import UIKit

protocol ListItemNavigator {
    func popViewController()
}

class DefaultListItemNavigator: ListItemNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }
}

