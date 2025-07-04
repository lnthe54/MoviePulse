import UIKit

protocol DetailItemNavigator {
   func popViewController()
    func gotoDetailItemViewController(infoDetailObject: InfoDetailObject)
    func gotoListItemViewController(sectionType: ListSectionType)
    func gotoImagesViewController(images: [BackdropObject], selectedIndex: Int)
}

class DefaultDetailItemNavigator: DetailItemNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
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
    
    func gotoImagesViewController(images: [BackdropObject], selectedIndex: Int) {
        let viewController = ImagesViewController(images: images, selectedIndex: selectedIndex)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: true)
    }
}

