import UIKit

protocol OnboardingNavigator {
    
}

class DefaultOnboardingNavigator: OnboardingNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

