import UIKit

protocol SeasonDetailNavigator: BaseNavigator {
    
}

class DefaultSeasonDetailNavigator: SeasonDetailNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
}

