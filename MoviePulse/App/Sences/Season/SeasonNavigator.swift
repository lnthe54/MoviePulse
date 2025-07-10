import UIKit

protocol SeasonNavigator: BaseNavigator {
    func gotoSeasonDetailViewController(seasonInfo: SeasonInfo)
}

class DefaultSeasonNavigator: SeasonNavigator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func popToViewController() {
        navigationController.popViewController(animated: true)
    }
    
    func gotoSeasonDetailViewController(seasonInfo: SeasonInfo) {
        let navigator = DefaultSeasonDetailNavigator(navigationController: navigationController)
        let viewModel = SeasonDetailViewModel()
        let viewController = SeasonDetailViewController(
            navigator: navigator,
            viewModel: viewModel,
            seasonInfo: seasonInfo
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}

