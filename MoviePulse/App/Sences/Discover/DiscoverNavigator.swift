import UIKit

protocol DiscoverNavigator {
    
}

class DefaultDiscoverNavigator: DiscoverNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

