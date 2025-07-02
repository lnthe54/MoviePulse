import UIKit
import RxSwift
import RxCocoa

enum HomeSectionType {
    case feel
    case start
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
        collectionView.register(TitleHeaderSection.nib(),
                                forSupplementaryViewOfKind: "Header",
                                withReuseIdentifier: TitleHeaderSection.className)
        collectionView.register(SingleCell.nib(), forCellWithReuseIdentifier: SingleCell.className)
        collectionView.register(ItemHorizontalCell.nib(), forCellWithReuseIdentifier: ItemHorizontalCell.className)
        collectionView.register(CategoryCell.nib(), forCellWithReuseIdentifier: CategoryCell.className)
        collectionView.register(PulseCell.nib(), forCellWithReuseIdentifier: PulseCell.className)
        collectionView.register(FeelCell.nib(), forCellWithReuseIdentifier: FeelCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.BOTTOM_TABBAR, right: 0)
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
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [HomeSectionType] {
        var sections: [HomeSectionType] = []
        
        sections.append(.feel)
        
        sections.append(.start)
        
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
        if kind == "Header" {
            let sectionType = getSections()[indexPath.section]
            switch sectionType {
            case .populars:
                return titleHeaderSection(
                    collectionView,
                    viewForSupplementaryElementOfKind: kind,
                    indexPath: indexPath,
                    title: "Movies that raise your heart",
                    isShowSeeMore: homeDataObject.movies.count > Constant.maxDisplayItems,
                    sectionType: sectionType
                )
            case .category:
                return titleHeaderSection(
                    collectionView,
                    viewForSupplementaryElementOfKind: kind,
                    indexPath: indexPath,
                    title: "Explore moives by genres",
                    isShowSeeMore: homeDataObject.categories.count > Constant.maxDisplayItems,
                    sectionType: sectionType
                )
            default:
                return UICollectionReusableView()
            }
        } else {
            return UICollectionReusableView()
        }
    }
    
    private func startPulseCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> PulseCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PulseCell.className, for: indexPath) as! PulseCell
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
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .feel, .start, .pulse, .favorite:
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
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .favorite:
            navigator.gotoFavoriteViewController()
        case .populars:
            gotoDetailItemTrigger.onNext(homeDataObject.movies[indexPath.row])
        case .category:
            navigator.gotoListItemViewController(sectionType: .category(categoryObject: homeDataObject.categories[indexPath.row]))
        default: break
        }
    }
    
    override func didToSeeMore(sectionType: Any) {
        guard let sectionType = sectionType as? HomeSectionType else {
            return
        }
        
        switch sectionType {
        case .populars:
            navigator.gotoListItemViewController(sectionType: .popular)
        case .category:
            navigator.gotoCategoryViewController(categories: homeDataObject.categories)
        default:
            break
        }
    }
}
