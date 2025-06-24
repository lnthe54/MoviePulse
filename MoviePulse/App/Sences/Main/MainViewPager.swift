import UIKit

enum MainTabbarTag: Int {
    case home
    case discover
    case setting
}

class MainViewPager: UIPageViewController {

    // MARK: - Properties
    private var homeNavigationController: UINavigationController!
    private var discoverNavigationController: UINavigationController!
    private var settingNavigationController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewControllers()
    }
    
    // MARK: - Private functions
    private func setupViewControllers() {
        createHomeTab()
        createDiscoverTab()
        createSettingTab()
        
        setViewControllers([homeNavigationController], direction: .forward, animated: false)
    }
    
    func moveToScreen(at index: MainTabbarTag) {
        var selectedViewController: UIViewController!
        
        switch index {
        case .home:
            selectedViewController = homeNavigationController
            
        case .discover:
            selectedViewController = discoverNavigationController
            
        case .setting:
            selectedViewController = settingNavigationController
        }
        
        setViewControllers([selectedViewController], direction: .forward, animated: false)
    }
}

extension MainViewPager {
    func createHomeTab() {
        homeNavigationController = UINavigationController()
        let navigator = DefaultHomeNavigator(navigationController: homeNavigationController)
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(navigator: navigator, viewModel: viewModel)
        homeNavigationController.pushViewController(viewController, animated: true)
    }
    
    func createDiscoverTab() {
        discoverNavigationController = UINavigationController()
        let viewController = UIViewController()
        discoverNavigationController.pushViewController(viewController, animated: true)
    }
    
    func createSettingTab() {
        settingNavigationController = UINavigationController()
        let viewController = UIViewController()
        settingNavigationController.pushViewController(viewController, animated: true)
    }
}
