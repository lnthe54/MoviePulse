import UIKit
import MessageUI

enum SettingSectionType {
    case appInfo
    case list
}

class SettingViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: SettingNavigator
    private var viewModel: SettingViewModel
    private var settings: [SettingType] = []
    
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
        
        initSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .showTabBar, object: nil)
    }
    
    override func setupViews() {
        setupHeader(withType: .single(title: "Setting"))
        topConstraint.constant = Constants.HEIGHT_NAV
        
        collectionView.register(AppNameCell.nib(), forCellWithReuseIdentifier: AppNameCell.className)
        collectionView.register(SettingCell.nib(), forCellWithReuseIdentifier: SettingCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
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
    
    private func initSettings() {
        settings.append(.notification)
        
        settings.append(.support)
        
        settings.append(.share)
        
        settings.append(.gdpr)
        
        settings.append(.terms)
    }
    
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .appInfo:
                return AppLayout.fixedSection(height: 68)
            case .list:
                return AppLayout.fixedSection(height: 64)
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [SettingSectionType] {
        var sections: [SettingSectionType] = []
        
        sections.append(.appInfo)
        
        if settings.isNotEmpty {
            sections.append(.list)
        }
        
        return sections
    }
    
    private func appInfoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> AppNameCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppNameCell.className, for: indexPath) as! AppNameCell
        return cell
    }
    
    private func settingCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> SettingCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.className, for: indexPath) as! SettingCell
        cell.bindData(type: settings[indexPath.row])
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
        case .list:
            return settings.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .appInfo:
            return appInfoCell(collectionView, cellForItemAt: indexPath)
        case .list:
            return settingCell(collectionView, cellForItemAt: indexPath)
        }
    }
}

extension SettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if getSections()[indexPath.section] == .list {
            let type = settings[indexPath.row]
            switch type {
            case .support:
                tapToFeedback()
            case .share:
                showPopupShareApp()
            case .terms:
                navigator.gotoWebviewViewController(title: type.title, url: Constants.Config.URL_POLICY)
            default:
                break
            }
        }
    }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    private func tapToFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Constants.Config.EMAIL_FEEDBACK])
            mail.setSubject(Constants.Config.SUBJECT_CONTENT)
            mail.setMessageBody(Constants.Config.BODY_CONTENT, isHTML: false)
            
            present(mail, animated: true)
        } else if let emailUrl = Utils.createEmailUrl(
            to: Constants.Config.EMAIL_FEEDBACK,
            subject: Constants.Config.SUBJECT_CONTENT,
            body: Constants.Config.BODY_CONTENT
        ) {
            Utils.open(with: emailUrl)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
