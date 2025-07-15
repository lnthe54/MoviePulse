import UIKit

protocol PulseTestNavigator: BaseNavigator {
    func gotoPulseResultViewController(result: PulseResultInfo)
}

class DefaultPulseTestNavigator: PulseTestNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
    
    func gotoPulseResultViewController(result: PulseResultInfo) {
        let navigator = DefaultPulseResultNavigator(navigationController: navigationController)
        let viewModel = PulseResultViewModel()
        let viewController = PulseResultViewController(
            navigator: navigator,
            viewModel: viewModel,
            pulseResult: result
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}

