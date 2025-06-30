import UIKit

protocol HomeNavigator {
    func gotoCategoryViewController(categories: [CategoryObject])
    func gotoListItemViewController(sectionType: ListSectionType)
    func gotoDetailItemViewController(infoDetailObject: InfoDetailObject)
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
    
    func gotoListItemViewController(sectionType: ListSectionType) {
        let navigator = DefaultListItemNavigator(navigationController: navigationController)
        let viewModel = ListItemViewModel(movieServices: MovieClient())
        let viewController = ListItemViewController(
            navigator: navigator,
            viewModel: viewModel,
            sectionType: sectionType
        )
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func gotoDetailItemViewController(infoDetailObject: InfoDetailObject) {
        let navigator = DefaultDetailItemNavigator(navigationController: navigationController)
        let viewModel = DetailItemViewModel(movieServices: MovieClient())
        let viewController = DetailItemViewController(
            navigator: navigator,
            viewModel: viewModel,
            infoDetailObject: infoDetailObject
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}
