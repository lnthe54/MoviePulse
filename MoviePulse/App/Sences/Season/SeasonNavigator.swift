import UIKit

protocol SeasonNavigator: BaseNavigator {
    
}

class DefaultSeasonNavigator: SeasonNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
}

