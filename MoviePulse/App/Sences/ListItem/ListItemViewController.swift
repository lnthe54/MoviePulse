import UIKit
import RxSwift
import RxCocoa

enum ListItemSectionType {
    case list
}

class ListItemViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: ListItemNavigator
    private var viewModel: ListItemViewModel
    private var sectionType: ListSectionType
    private var page: Int = 1
    private var items: [InfoObject] = []
    
    private let getDataTrigger = PublishSubject<ListParameters>()
    private let gotoDetailItemTrigger = PublishSubject<InfoObject>()
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    init(
        navigator: ListItemNavigator,
        viewModel: ListItemViewModel,
        sectionType: ListSectionType
    ) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.sectionType = sectionType
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataTrigger.onNext(ListParameters(sectionType: sectionType, page: page))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }
    
    override func bindViewModel() {
        let input = ListItemViewModel.Input(
            getDataTrigger: getDataTrigger.asObservable(),
            gotoDetailItemTrigger: gotoDetailItemTrigger.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.loadingEvent
            .driveNext { isLoading in
                if isLoading {
                    LoadingView.shared.startLoading()
                } else {
                    LoadingView.shared.endLoading()
                }
            }
            .disposed(by: disposeBag)
        
        output.errorEvent
            .driveNext { _ in
                // Do something
            }
            .disposed(by: disposeBag)
        
        output.getDataEvent
            .driveNext { [weak self] items in
                guard let self else { return }
                
                if page == 1 {
                    self.items.removeAll()
                }
                
                if items.isNotEmpty {
                    self.items.append(contentsOf: items)
                    page += 1
                }
                
                collectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        output.gotoDetailItemEvent
            .driveNext { [weak self] infoDetailObject in
                self?.navigator.gotoDetailItemViewController(infoDetailObject: infoDetailObject)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: sectionType.title))
        topConstraint.constant = Constants.HEIGHT_NAV
        
        collectionView.configure(withCells: [ItemHorizontalCell.self], delegate: self, dataSource: self)
        configureCompositionalLayout()
    }
    
    override func actionBack() {
        navigator.popToViewController()
    }
}

extension ListItemViewController {
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .list:
                return AppLayout.itemsSection()
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [ListItemSectionType] {
        var sections: [ListItemSectionType] = []
        
        sections.append(.list)
        
        return sections
    }
}

extension ListItemViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .list:
            return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .list:
            return itemCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func itemCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> ItemHorizontalCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemHorizontalCell.className, for: indexPath) as! ItemHorizontalCell
        cell.bindData(items[indexPath.row])
        return cell
    }
}

extension ListItemViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .list:
            if indexPath.row == items.count - 1 {
                getDataTrigger.onNext(ListParameters(sectionType: sectionType, page: page))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .list:
            switch sectionType {
            case .heart(let isPulse):
                if isPulse {
                    let item = items[indexPath.row]
                    navigator.gotoPulseTestViewController(id: item.id, posterPath: item.path ?? "", name: item.name ?? "")
                } else {
                    gotoDetailItemTrigger.onNext(items[indexPath.row])
                }
            default:
                gotoDetailItemTrigger.onNext(items[indexPath.row])
            }
        }
    }
}
