import UIKit

protocol HomeNavigator {
    
}

class DefaultHomeNavigator: HomeNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
