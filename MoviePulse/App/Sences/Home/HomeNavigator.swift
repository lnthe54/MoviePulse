import UIKit

protocol HomeNavigator {
    func gotoCategoryViewController(categories: [CategoryObject])
    func gotoListItemViewController(sectionType: ListSectionType)
    func gotoDetailItemViewController(infoDetailObject: InfoDetailObject)
    func gotoFavoriteViewController()
    func gotoSearchViewController()
}

class DefaultHomeNavigator: HomeNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func gotoCategoryViewController(categories: [CategoryObject]) {
        let navigator = DefaultCategoryNavigator(navigationController: navigationController)
        let viewModel = CategoryViewModel()
        let viewController = CategoryViewController(
            navigator: navigator,
            viewModel: viewModel,
            categories: categories,
            objectType: .movie
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
        
//        let viewController = PulseViewController()
//        navigationController.pushViewController(viewController, animated: true)
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
    
    func gotoFavoriteViewController() {
        let navigator = DefaultFavoriteNavigator(navigationController: navigationController)
        let viewModel = FavoriteViewModel(movieServices: MovieClient())
        let viewController = FavoriteViewController(navigator: navigator, viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func gotoSearchViewController() {
        let navigator = DefaultSearchNavigator(navigationController: navigationController)
        let viewModel = SearchViewModel()
        let viewController = SearchViewController(navigator: navigator, viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
