import UIKit

protocol TrailerNavigator {
    func popToViewController()
}

class DefaultTrailerNavigator: TrailerNavigator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
}

