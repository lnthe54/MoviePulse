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
    private var filters: [PulseResultInfo] = []
    
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
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchTf: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData),
            name: .reloadPulseResults,
            object: nil
        )
        
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
                self.filters = items
                self.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: "Pulse Gallery"))
        topConstraint.constant = Constants.HEIGHT_NAV
        
        searchView.backgroundColor = .white
        searchView.corner(8)
        
        searchTf.attributedPlaceholder = NSAttributedString(
            string: "Search...",
            attributes: [
                .foregroundColor: UIColor(hexString: "#697081") ?? .clear
            ]
        )
        
        searchTf.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(onNext: { [weak self] text in
                self?.handleSearch(text: text)
            })
            .disposed(by: disposeBag)
        
        searchTf.textColor = .blackColor
        searchTf.tintColor = .pimaryColor
        searchTf.returnKeyType = .search
        
        collectionView.configure(withCells: [SavePulseCell.self, EmptyCell.self], delegate: self, dataSource: self)
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
        
        if filters.isEmpty {
            sections.append(.empty)
        } else {
            sections.append(.list)
        }
        
        return sections
    }
    
    private func showActionSheet(id: Int) {
        let actionSheetVC = ActionSheetViewController()
        actionSheetVC.onDelete = {
            self.showDelPopup(id: id)
        }
        actionSheetVC.onShare = {
            self.showPopupShareApp()
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
    
    private func handleSearch(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            filters = items
        } else {
            filters = items.filter { $0.name.lowercased().contains(text.lowercased()) }
        }
        
        collectionView.reloadData()
    }
    
    private func showDelPopup(id: Int) {
        let popupView = ComponentPopup(
            titleHeader: "Are you sure you want to delete all these item?",
            content: "Careful — once done, this can’t be changed.",
            leftValue: "No, cancel",
            rightValue: "Confirm"
        )
        
        popupView.onTapRightButton = { [weak self] in
            self?.handleRemoveItem(id: id)
        }
        
        popupView.modalPresentationStyle = .overFullScreen
        present(popupView, animated: false)
    }
    
    private func handleRemoveItem(id: Int) {
        var results = CodableManager.shared.getPulseResults()
        let filters = results.filter { $0.id != id }
        results = filters

        CodableManager.shared.savePulseResults(results)
        
        getDataTrigger.onNext(())
    }
    
    @objc
    private func reloadData() {
        getDataTrigger.onNext(())
    }
}

extension SavePulseViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .list:
            return filters.count
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
            guard let self else { return }
            self.showActionSheet(id: self.filters[indexPath.row].id)
        }
        cell.bindData(filters[indexPath.row])
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

extension SavePulseViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .list:
            navigator.gotoPulseResultViewController(result: filters[indexPath.row])
        default: break
        }
    }
}
