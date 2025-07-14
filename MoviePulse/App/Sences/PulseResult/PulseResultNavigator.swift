import UIKit

protocol PulseResultNavigator: BaseNavigator {
    func popToRootViewController()
}

class DefaultPulseResultNavigator: PulseResultNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToRootViewController() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
}

