import UIKit

protocol PulseResultNavigator: BaseNavigator {
    func popToRootViewController()
    func gotoPulseTestViewController(result: PulseResultInfo)
}

class DefaultPulseResultNavigator: PulseResultNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToRootViewController() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
    
    func gotoPulseTestViewController(result: PulseResultInfo) {
        let navigator = DefaultPulseTestNavigator(navigationController: navigationController)
        let viewModel = PulseTestViewModel()
        let viewController = PulseTestViewController(
            navigator: navigator,
            viewModel: viewModel,
            id: result.id,
            posterPath: result.path,
            name: result.name
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}

