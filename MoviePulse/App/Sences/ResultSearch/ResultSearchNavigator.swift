import UIKit

protocol ResultSearchNavigator {
    func popToRootView()
}

class DefaultResultSearchNavigator: ResultSearchNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToRootView() {
        navigationController.popToRootViewController(animated: true)
    }
}

