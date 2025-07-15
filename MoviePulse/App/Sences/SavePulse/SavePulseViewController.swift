import UIKit
import RxSwift
import RxCocoa

enum PulseGallerySectionType {
    case list
    case empty
}

class SavePulseViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: SavePulseNavigator
    private var viewModel: SavePulseViewModel
    private var items: [PulseResultInfo] = []
    
    private let getDataTrigger = PublishSubject<Void>()
    
    init(navigator: SavePulseNavigator, viewModel: SavePulseViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataTrigger.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }
    
    override func bindViewModel() {
        let input = SavePulseViewModel.Input(
            getDataTrigger: getDataTrigger.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.getDataEvent
            .driveNext { [weak self] items in
                guard let self else { return }
                self.items = items
                self.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: "Pulse Gallery"))
        topConstraint.constant = Constants.HEIGHT_NAV
        collectionView.configure(withCells: [SavePulseCell.self, EmptyCell.self], dataSource: self)
        configureCompositionalLayout()
    }
    
    override func actionBack() {
        navigator.popToViewController()
    }
}

extension SavePulseViewController {
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .list:
                return AppLayout.episodeSection(height: 144)
            case .empty:
                return AppLayout.fixedSection(height: 300)
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [PulseGallerySectionType] {
        var sections: [PulseGallerySectionType] = []
        
        if items.isEmpty {
            sections.append(.empty)
        } else {
            sections.append(.list)
        }
        
        return sections
    }
    
    private func showActionSheet() {
        let actionSheetVC = ActionSheetViewController()
        actionSheetVC.onDelete = {
            print("🗑 Delete tapped")
        }
        actionSheetVC.onShare = {
            print("🔗 Share tapped")
        }

        if let sheet = actionSheetVC.sheetPresentationController {
            sheet.detents = [.custom { context in
                let padding: CGFloat = 24 + 24 // top + bottom
                let titleHeight: CGFloat = 20
                let buttonHeight: CGFloat = 40 * 2 + 16 // 2 buttons + spacing
                return titleHeight + buttonHeight + padding
            }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        present(actionSheetVC, animated: true)
    }
}

extension SavePulseViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .list:
            return items.count
        case .empty:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .list:
            return pulseCell(collectionView, cellForItemAt: indexPath)
        case .empty:
            return emptyCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    func pulseCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> SavePulseCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavePulseCell.className, for: indexPath) as! SavePulseCell
        cell.onTapMoreAction = { [weak self] in
            self?.showActionSheet()
        }
        cell.bindData(items[indexPath.row])
        return cell
    }
    
    private func emptyCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> EmptyCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.className, for: indexPath) as! EmptyCell
        cell.onTapDiscover = {
            NotificationCenter.default.post(name: .switchToDiscoverTab, object: nil)
        }
        cell.bindData(title: "Nothing here", message: "Discover exciting movies and\nstart measuring your reactions!")
        return cell
    }
}
