import UIKit

protocol PulseTestNavigator: BaseNavigator {
    
}

class DefaultPulseTestNavigator: PulseTestNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
}

