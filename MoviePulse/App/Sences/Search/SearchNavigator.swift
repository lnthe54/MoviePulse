import UIKit

protocol SearchNavigator {
    func popToViewController()
    func gotoResultSearchViewController(key: String)
}

class DefaultSearchNavigator: SearchNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
    
    func gotoResultSearchViewController(key: String) {
        let navigator = DefaultResultSearchNavigator(navigationController: navigationController)
        let viewModel = ResultSearchViewModel()
        let viewController = ResultSearchViewController(
            navigator: navigator,
            viewModel: viewModel,
            key: key
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}

