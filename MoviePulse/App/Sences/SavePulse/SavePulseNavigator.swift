import UIKit

protocol SavePulseNavigator: BaseNavigator {
    
}

class DefaultSavePulseNavigator: SavePulseNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
}
