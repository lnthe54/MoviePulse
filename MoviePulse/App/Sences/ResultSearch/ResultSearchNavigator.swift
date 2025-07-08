import UIKit

protocol ResultSearchNavigator {
    func popToRootView()
    func gotoDetailItemViewController(infoDetailObject: InfoDetailObject)
}

class DefaultResultSearchNavigator: ResultSearchNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToRootView() {
        navigationController.popToRootViewController(animated: true)
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

