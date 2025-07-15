import UIKit

protocol ListItemNavigator: BaseNavigator {
    func gotoDetailItemViewController(infoDetailObject: InfoDetailObject)
    func gotoPulseTestViewController(id: Int, posterPath: String, name: String)
}

class DefaultListItemNavigator: ListItemNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
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
    
    func gotoPulseTestViewController(id: Int, posterPath: String, name: String) {
        let navigator = DefaultPulseTestNavigator(navigationController: navigationController)
        let viewModel = PulseTestViewModel()
        let viewController = PulseTestViewController(
            navigator: navigator,
            viewModel: viewModel,
            id: id,
            posterPath: posterPath,
            name: name
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}

