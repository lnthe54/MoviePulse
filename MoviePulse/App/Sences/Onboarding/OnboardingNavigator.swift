import UIKit

protocol OnboardingNavigator {
    func gotoMainViewController()
}

class DefaultOnboardingNavigator: OnboardingNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func gotoMainViewController() {
        let viewController = MainViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}

