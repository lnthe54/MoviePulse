import UIKit

enum SettingSectionType {
    case appInfo
}

class SettingViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: SettingNavigator
    private var viewModel: SettingViewModel
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    init(navigator: SettingNavigator, viewModel: SettingViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadView),
            name: .permisstionNotificationChange,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .showTabBar, object: nil)
    }
    
    override func setupViews() {
        setupHeader(withType: .multi(title: "Setting"))
        topConstraint.constant = Constants.HEIGHT_NAV
        
        collectionView.register(AppNameCell.nib(), forCellWithReuseIdentifier: AppNameCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.BOTTOM_TABBAR, right: 0)
        configureCompositionalLayout()
    }
}

extension SettingViewController {
    @objc func handleWillEnterForeground() {
        NotificationManager.shared.syncNotification()
    }
    
    @objc
    private func reloadView() {
        collectionView.reloadData()
    }
    
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .appInfo:
                return AppLayout.fixedSection(height: 68)
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [SettingSectionType] {
        var sections: [SettingSectionType] = []
        
        sections.append(.appInfo)
        
        return sections
    }
    
    private func appInfoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> AppNameCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppNameCell.className, for: indexPath) as! AppNameCell
        return cell
    }
}

extension SettingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .appInfo:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .appInfo:
            return appInfoCell(collectionView, cellForItemAt: indexPath)
        }
    }
}
