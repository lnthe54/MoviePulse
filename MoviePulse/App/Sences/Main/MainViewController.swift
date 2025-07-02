import UIKit
import RxGesture

class MainViewController: BaseViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var tabbarView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var homeView: UIView!
    @IBOutlet private weak var homeIcon: UIImageView!
    @IBOutlet private weak var homeLineView: UIView!
    @IBOutlet private weak var discoverView: UIView!
    @IBOutlet private weak var discoverIcon: UIImageView!
    @IBOutlet private weak var discoverLineView: UIView!
    @IBOutlet private weak var settingView: UIView!
    @IBOutlet private weak var settingIcon: UIImageView!
    @IBOutlet private weak var settingLineView: UIView!
    
    // MARK: - Properties
    private var mainViewPager: MainViewPager!
    
    init() {
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideTabbar),
            name: .hideTabBar,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showTabbar),
            name: .showTabBar,
            object: nil
        )
        
        UserDataDefault.shared.setIsFirstInstallApp(true)
    }
    
    override func setupViews() {
        containerView.backgroundColor = UIColor(hexString: "#FAF7FE")
        setupMainViewPager()
        tabbarView.backgroundColor = .white
        
        homeView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                mainViewPager.moveToScreen(at: .home)
                handleTap(isActiveHome: true)
            })
            .disposed(by: disposeBag)
        
        discoverView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                mainViewPager.moveToScreen(at: .discover)
                handleTap(isActiveDiscover: true)
            })
            .disposed(by: disposeBag)
        
        settingView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                handleTap(isActiveSetting: true)
            })
            .disposed(by: disposeBag)
        
        handleTap(isActiveHome: true)
    }
    
    private func handleTap(isActiveHome: Bool = false,
                           isActiveDiscover: Bool = false,
                           isActiveSetting: Bool = false) {
        
        setTab(icon: homeIcon,
               activeImage: "ic_home_active",
               inactiveImage: "ic_home_inactive",
               lineView: homeLineView,
               isActive: isActiveHome)
        
        setTab(icon: discoverIcon,
               activeImage: "ic_discover_active",
               inactiveImage: "ic_discover_inactive",
               lineView: discoverLineView,
               isActive: isActiveDiscover)
        
        setTab(icon: settingIcon,
               activeImage: "ic_setting_active",
               inactiveImage: "ic_setting_inactive",
               lineView: settingLineView,
               isActive: isActiveSetting)
    }

    private func setTab(
        icon: UIImageView,
        activeImage: String,
        inactiveImage: String,
        lineView: UIView,
        isActive: Bool
    ) {
        icon.image = UIImage(named: isActive ? activeImage : inactiveImage)
        lineView.backgroundColor = isActive ? .pimaryColor : .clear
    }
    
    private func setupMainViewPager() {
        mainViewPager = MainViewPager()
        mainViewPager.view.frame = containerView.bounds
        addChild(mainViewPager)
        containerView.addSubview(mainViewPager.view)
        mainViewPager.didMove(toParent: self)
    }
}

extension MainViewController {
    @objc
    private func hideTabbar() {
        tabbarView.isHidden = true
    }
    
    @objc
    private func showTabbar() {
        tabbarView.isHidden = false
    }
}
