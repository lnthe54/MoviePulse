import UIKit
import RxSwift
import RxCocoa

enum HomeSectionType {
    case feel
    case start
    case result
    case pulse
    case favorite
    case populars
    case category
}

class HomeViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: HomeNavigator
    private var viewModel: HomeViewModel
    private var homeDataObject: HomeDataObject = HomeDataObject(movies: [], categories: [])
    
    private let getDataTrigger = PublishSubject<Void>()
    private let gotoDetailItemTrigger = PublishSubject<InfoObject>()
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private enum Constant {
        static let maxDisplayItems: Int = 10
    }
    
    init(navigator: HomeNavigator, viewModel: HomeViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataTrigger.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .showTabBar, object: nil)
    }
    
    override func actionSearch() {
        navigator.gotoSearchViewController()
    }
    
    override func bindViewModel() {
        let input = HomeViewModel.Input(
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
            .driveNext { [weak self] homeDataObject in
                guard let self else { return }
                
                self.homeDataObject = homeDataObject
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
        view.backgroundColor = UIColor(hexString: "#FAF7FE")
        
        topConstraint.constant = Constants.HEIGHT_NAV
        setupHeader(withType: .multi(title: "Hello"))
        collectionView.configure(
            withCells: [
                SingleCell.self,
                ItemHorizontalCell.self,
                CategoryCell.self,
                PulseCell.self,
                FeelCell.self,
                SavePulseCell.self
            ],
            headers: [TitleHeaderSection.self],
            delegate: self,
            dataSource: self,
            contentInset: UIEdgeInsets(top: 0, left: 0, bottom: Constants.BOTTOM_TABBAR, right: 0)
        )
        configureCompositionalLayout()
    }
}

extension HomeViewController {
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .feel:
                return AppLayout.fixedSection(height: 188)
            case .start:
                return AppLayout.fixedSection(height: 270)
            case .pulse, .favorite:
                return AppLayout.fixedSection(height: 56)
            case .populars:
                return AppLayout.horizontalSection()
            case .category:
                return AppLayout.categorySection()
            case .result:
                return AppLayout.fixedSection(height: 144)
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [HomeSectionType] {
        var sections: [HomeSectionType] = []
        
        sections.append(.feel)
        
        if CodableManager.shared.getPulseResults().isEmpty {
            sections.append(.start)
        } else {
            sections.append(.result)
        }
        
        sections.append(.pulse)
        
        sections.append(.favorite)
        
        if homeDataObject.movies.isNotEmpty {
            sections.append(.populars)
        }
        
        if homeDataObject.categories.isNotEmpty{
            sections.append(.category)
        }
        
        return sections
    }
    
    private func getNumberOfRows<T>(list: [T]) -> Int {
        return min(list.count, Constant.maxDisplayItems)
    }
    
    // MARK: - Bind Cell
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == "Header" else {
            return UICollectionReusableView()
        }

        let sectionType = getSections()[indexPath.section]
        
        let (title, items): (String, [Any]) = {
            switch sectionType {
            case .populars:
                return ("Movies that raise your heart", homeDataObject.movies)
            case .category:
                return ("Explore moives by genres", homeDataObject.categories)
            default:
                return ("", [])
            }
        }()
        
        guard !title.isEmpty else { return UICollectionReusableView() }

        return titleHeaderSection(
            collectionView,
            viewForSupplementaryElementOfKind: kind,
            indexPath: indexPath,
            title: title,
            isShowSeeMore: items.count > Constant.maxDisplayItems,
            sectionType: sectionType
        )
    }
    
    private func startPulseCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> PulseCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PulseCell.className, for: indexPath) as! PulseCell
        cell.onTapStart = { [weak self] in
            self?.navigator.gotoListItemViewController(sectionType: .heart(isPulse: true))
        }
        return cell
    }
    
    private func singleCell(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        forTitle title: String,
        icon: String
    ) -> SingleCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleCell.className, for: indexPath) as! SingleCell
        cell.bindData(forTitle: title, icon: icon)
        return cell
    }
    
    private func itemHorizontalCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> ItemHorizontalCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemHorizontalCell.className, for: indexPath) as! ItemHorizontalCell
        cell.bindData(homeDataObject.movies[indexPath.row])
        return cell
    }
    
    private func categoryCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> CategoryCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.className, for: indexPath) as! CategoryCell
        cell.bindData(homeDataObject.categories[indexPath.row])
        return cell
    }
    
    private func feelCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> FeelCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeelCell.className, for: indexPath) as! FeelCell
        cell.delegate = self
        return cell
    }
    
    private func resultCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> SavePulseCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavePulseCell.className, for: indexPath) as! SavePulseCell
        if let firstItem = CodableManager.shared.getPulseResults().first {
            cell.bindData(firstItem, isHideMore: true)
        }
        return cell
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .feel, .start, .pulse, .favorite, .result:
            return 1
        case .populars:
            return getNumberOfRows(list: homeDataObject.movies)
        case .category:
            return getNumberOfRows(list: homeDataObject.categories)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .feel:
            return feelCell(collectionView, cellForItemAt: indexPath)
        case .start:
            return startPulseCell(collectionView, cellForItemAt: indexPath)
        case .pulse:
            return singleCell(
                collectionView,
                cellForItemAt: indexPath,
                forTitle: "Saved Pulse Gallery",
                icon: "ic_healtcare"
            )
        case .favorite:
            return singleCell(
                collectionView,
                cellForItemAt: indexPath,
                forTitle: "Favorite Movies",
                icon: "ic_favorite"
            )
        case .populars:
            return itemHorizontalCell(collectionView, cellForItemAt: indexPath)
        case .category:
            return categoryCell(collectionView, cellForItemAt: indexPath)
        case .result:
            return resultCell(collectionView, cellForItemAt: indexPath)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, FeelCellDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .favorite:
            navigator.gotoFavoriteViewController()
        case .populars:
            gotoDetailItemTrigger.onNext(homeDataObject.movies[indexPath.row])
        case .category:
            navigator.gotoListItemViewController(sectionType: .category(category: homeDataObject.categories[indexPath.row], objectType: .movie))
        case .pulse:
            navigator.gotoSavePulseViewController()
        case .result:
            if let firstItem = CodableManager.shared.getPulseResults().first {
                navigator.gotoPulseResultViewController(result: firstItem)
            }
        default: break
        }
    }
    
    override func didToSeeMore(sectionType: Any) {
        guard let sectionType = sectionType as? HomeSectionType else {
            return
        }
        
        switch sectionType {
        case .populars:
            navigator.gotoListItemViewController(sectionType: .heart())
        case .category:
            navigator.gotoCategoryViewController(categories: homeDataObject.categories)
        default:
            break
        }
    }
    
    func didSelectFeelType(_ feelType: EmotionType) {
        navigator.gotoListItemViewController(sectionType: .feel(type: feelType))
    }
}
