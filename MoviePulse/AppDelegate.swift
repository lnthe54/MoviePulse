import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = getViewController()
        window?.overrideUserInterfaceStyle = .light
        window?.makeKeyAndVisible()
        
        return true
    }
}

extension AppDelegate {
    func getViewController() -> UIViewController {
        if UserDataDefault.shared.getIsFirstInstallApp() {
            // Onboarding
            let viewController = OnboardingViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.setNavigationBarHidden(true, animated: false)
            
            viewController.navigator = DefaultOnboardingNavigator(navigationController: navigationController)
            viewController.viewModel = OnboardingViewModel()
            return navigationController
        } else {
            // Home
            let viewController = MainViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.setNavigationBarHidden(true, animated: false)
            return navigationController
        }
    }
}
