import UIKit

protocol DiscoverNavigator {
    func gotoDetailItemViewController(infoDetailObject: InfoDetailObject)
    func gotoListItemViewController(sectionType: ListSectionType)
    func gotoCategoryViewController(categories: [CategoryObject], objectType: ObjectType)
    func gotoSearchViewController()
}

class DefaultDiscoverNavigator: DiscoverNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
    
    func gotoListItemViewController(sectionType: ListSectionType) {
        let navigator = DefaultListItemNavigator(navigationController: navigationController)
        let viewModel = ListItemViewModel(movieServices: MovieClient(), tvShowServices: TVShowClient())
        let viewController = ListItemViewController(
            navigator: navigator,
            viewModel: viewModel,
            sectionType: sectionType
        )
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func gotoCategoryViewController(categories: [CategoryObject], objectType: ObjectType) {
        let navigator = DefaultCategoryNavigator(navigationController: navigationController)
        let viewModel = CategoryViewModel()
        let viewController = CategoryViewController(
            navigator: navigator,
            viewModel: viewModel,
            categories: categories,
            objectType: objectType
        )
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func gotoSearchViewController() {
        let navigator = DefaultSearchNavigator(navigationController: navigationController)
        let viewModel = SearchViewModel()
        let viewController = SearchViewController(navigator: navigator, viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

