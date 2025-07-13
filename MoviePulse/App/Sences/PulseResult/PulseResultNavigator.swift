import UIKit

protocol PulseResultNavigator: BaseNavigator {
    
}

class DefaultPulseResultNavigator: PulseResultNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
}

