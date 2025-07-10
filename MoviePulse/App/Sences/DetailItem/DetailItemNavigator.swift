import UIKit

protocol DetailItemNavigator: BaseNavigator {
    func gotoDetailItemViewController(infoDetailObject: InfoDetailObject)
    func gotoListItemViewController(sectionType: ListSectionType)
    func gotoImagesViewController(images: [BackdropObject], selectedIndex: Int)
    func gotoSeasonViewController(tvShowId: Int, seasons: [SeasonObject])
    func gotoTrailerViewController(trailers: [VideoInfo])
    func gotoSeasonDetailViewController(seasonInfo: SeasonInfo)
}

class DefaultDetailItemNavigator: DetailItemNavigator {
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
    
    func gotoSeasonViewController(tvShowId: Int, seasons: [SeasonObject]) {
        let navigator = DefaultSeasonNavigator(navigationController: navigationController)
        let viewModel = SeasonViewModel()
        let viewController = SeasonViewController(
            navigator: navigator,
            viewModel: viewModel,
            tvShowId: tvShowId,
            seasons: seasons
        )
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func gotoTrailerViewController(trailers: [VideoInfo]) {
        let navigator = DefaultTrailerNavigator(navigationController: navigationController)
        let viewController = TrailerViewController(navigator: navigator, trailers: trailers)
        navigationController.pushViewController(viewController, animated: true)
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

