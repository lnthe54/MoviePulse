import UIKit

protocol HomeNavigator {
    func gotoCategoryViewController(categories: [CategoryObject])
}

class DefaultHomeNavigator: HomeNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func gotoCategoryViewController(categories: [CategoryObject]) {
        let navigator = DefaultCategoryNavigator(navigationController: navigationController)
        let viewModel = CategoryViewModel()
        let viewController = CategoryViewController(navigator: navigator, viewModel: viewModel, categories: categories)
        navigationController.pushViewController(viewController, animated: true)
    }
}
