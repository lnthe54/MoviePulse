import UIKit
import RxSwift
import RxCocoa

enum DiscoverSectionType {
    case popular
    case trending
    case onAir
    case topRate
    case category
}

class DiscoverViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: DiscoverNavigator
    private var viewModel: DiscoverViewModel
    private var tabType: ObjectType = .movie
    private var discoverData: DiscoverData = .init()
    private var topRates: [InfoObject] = []
    
    private let getDataTrigger = PublishSubject<ObjectType>()
    private let gotoDetailItemTrigger = PublishSubject<InfoObject>()
    
    init(navigator: DiscoverNavigator, viewModel: DiscoverViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum Constant {
        static let numberOfDisplay: Int = 10
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var movieView: UIView!
    @IBOutlet private weak var movieIndicatorView: UIView!
    @IBOutlet private weak var movieLabel: UILabel!
    @IBOutlet private weak var tvShowView: UIView!
    @IBOutlet private weak var tvIndicatorView: UIView!
    @IBOutlet private weak var tvShowLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataTrigger.onNext(.movie)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .showTabBar, object: nil)
    }
    
    override func actionSearch() {
        navigator.gotoSearchViewController()
    }
    
    override func bindViewModel() {
        let input = DiscoverViewModel.Input(
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
            .driveNext { [weak self] discoverData in
                guard let self else { return }
                
                topRates.removeAll()
                self.discoverData = discoverData
                
                if discoverData.topRates.count > Constant.numberOfDisplay {
                    topRates.insert(getSeeAllObject(), at: 0)
                    topRates.append(contentsOf: discoverData.topRates)
                }
                
                self.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        output.gotoDetailItemEvent
            .driveNext { [weak self] infoDetailObject in
                self?.navigator.gotoDetailItemViewController(infoDetailObject: infoDetailObject)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        topConstraint.constant = Constants.HEIGHT_NAV
        setupHeader(withType: .multi(title: "Discover"))
        
        movieView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.didToMoviesTab()
            })
            .disposed(by: disposeBag)
        movieLabel.text = "Movies"
        movieIndicatorView.backgroundColor = .pimaryColor
        movieIndicatorView.corner(2)
        
        tvShowView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.didToTVShowsTab()
        })
        .disposed(by: disposeBag)
        tvShowLabel.text = "TV Shows"
        tvIndicatorView.backgroundColor = .pimaryColor
        tvIndicatorView.corner(2)
        
        // Default
        didToMoviesTab()
        
        collectionView.configure(
            withCells: [ItemHorizontalCell.self, CategoryHorizontalCell.self, SeeAllCell.self],
            headers: [TitleHeaderSection.self],
            delegate: self,
            dataSource: self,
            contentInset: UIEdgeInsets(top: 0, left: 0, bottom: Constants.BOTTOM_TABBAR, right: 0)
        )
        configureCompositionalLayout()
    }
}

extension DiscoverViewController {
    private func didToMoviesTab() {
        tabType = .movie
        movieLabel.textColor = .pimaryColor
        movieLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        movieIndicatorView.isHidden = false
        
        tvShowLabel.textColor = UIColor(hexString: "#697081")
        tvShowLabel.font = .outfitFont(ofSize: 14, weight: .light)
        tvIndicatorView.isHidden = true
        getDataTrigger.onNext(tabType)
    }
    
    private func didToTVShowsTab() {
        tabType = .tv
        tvIndicatorView.isHidden = false
        tvShowLabel.textColor = .pimaryColor
        tvShowLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        
        movieIndicatorView.isHidden = true
        movieLabel.textColor = UIColor(hexString: "#697081")
        movieLabel.font = .outfitFont(ofSize: 14, weight: .light)
        getDataTrigger.onNext(tabType)
    }
    
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .popular, .trending, .onAir:
                return AppLayout.horizontalSection()
            case .topRate:
                return AppLayout.horizontalSection(isShowHeader: false)
            case .category:
                return AppLayout.fixedSection(height: 208)
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [DiscoverSectionType] {
        var sections: [DiscoverSectionType] = []
        
        if tabType == .tv && discoverData.categories.isNotEmpty {
            sections.append(.category)
        }
        
        if discoverData.populars.isNotEmpty {
            sections.append(.popular)
        }
        
        if discoverData.trendings.isNotEmpty {
            sections.append(.trending)
        }
        
        if discoverData.onAirs.isNotEmpty {
            sections.append(.onAir)
        }
        
        if topRates.count > 1 {
            sections.append(.topRate)
        }
        
        if tabType == .movie && discoverData.categories.isNotEmpty {
            sections.append(.category)
        }
        
        return sections
    }
    
    private func getSeeAllObject() -> InfoObject {
        let title: String = tabType == .movie ? "Top movies that raise your heart" : "Tension you can feel"
        let path: String = tabType == .movie ? "ic_see_all_movie" : "ic_see_all_tv"
        return .initSeeAllObject(title: title, path: path)
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
            case .popular:
                return ("Most popular movies", discoverData.populars)
            case .trending:
                return ("Trending TV shows", discoverData.trendings)
            case .onAir:
                return ("Shows On The Air", discoverData.onAirs)
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
            isShowSeeMore: items.count > Constant.numberOfDisplay,
            sectionType: sectionType
        )
    }
    
    private func itemHorizontalCell(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        bindItems items: [InfoObject]
    ) -> ItemHorizontalCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemHorizontalCell.className, for: indexPath) as! ItemHorizontalCell
        cell.bindData(items[indexPath.row])
        return cell
    }
    
    private func categoryHorizontalCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> CategoryHorizontalCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryHorizontalCell.className, for: indexPath) as! CategoryHorizontalCell
        cell.delegate = self
        cell.bindCategories(discoverData.categories, withBackgroundColor: tabType == .movie ? .pimaryColor : (UIColor(hexString: "#FF7300") ?? .clear))
        return cell
    }
    
    private func seeAllCell(
        _ collectionView: UICollectionView,
        cellForItemAtL indexPath: IndexPath,
        bindData data: InfoObject
    ) -> SeeAllCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllCell.className, for: indexPath) as! SeeAllCell
        cell.delegate = self
        cell.bindData(data)
        return cell
    }
}

extension DiscoverViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .popular:
            return discoverData.populars.count > Constant.numberOfDisplay ? Constant.numberOfDisplay : discoverData.populars.count
        case .trending:
            return discoverData.trendings.count > Constant.numberOfDisplay ? Constant.numberOfDisplay : discoverData.trendings.count
        case .onAir:
            return discoverData.onAirs.count > Constant.numberOfDisplay ? Constant.numberOfDisplay : discoverData.onAirs.count
        case .topRate:
            return topRates.count > Constant.numberOfDisplay ? Constant.numberOfDisplay : topRates.count
        case .category:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .popular:
            return itemHorizontalCell(collectionView, cellForItemAt: indexPath, bindItems: discoverData.populars)
        case .trending:
            return itemHorizontalCell(collectionView, cellForItemAt: indexPath, bindItems: discoverData.trendings)
        case .onAir:
            return itemHorizontalCell(collectionView, cellForItemAt: indexPath, bindItems: discoverData.onAirs)
        case .topRate:
            if topRates.count > Constant.numberOfDisplay
                && indexPath.row == 0
            {
                return seeAllCell(collectionView, cellForItemAtL: indexPath, bindData: topRates[0])
            } else {
                return itemHorizontalCell(collectionView, cellForItemAt: indexPath, bindItems: topRates)
            }
        case .category:
            return categoryHorizontalCell(collectionView, cellForItemAt: indexPath)
        }
    }
}

extension DiscoverViewController: UICollectionViewDelegate, CategoryHorizontalCellDelegate, SeeAllCellDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var infoObject: InfoObject?
        
        switch getSections()[indexPath.section] {
        case .popular:
            infoObject = discoverData.populars[indexPath.row]
        case .trending:
            infoObject = discoverData.trendings[indexPath.row]
        case .onAir:
            infoObject = discoverData.onAirs[indexPath.row]
        case .topRate:
            let info = topRates[indexPath.row]
            if info.id == 0 { break }
            infoObject = info
        default:
            break
        }
        
        if let infoObject {
            gotoDetailItemTrigger.onNext(infoObject)
        }
    }
    
    func didSeeAllCategories() {
        navigator.gotoCategoryViewController(categories: discoverData.categories, objectType: tabType)
    }
    
    func didSelectedCategory(_ category: CategoryObject) {
        navigator.gotoListItemViewController(sectionType: .category(category: category, objectType: tabType))
    }
    
    func didSeeAll() {
        navigator.gotoListItemViewController(sectionType: .topRate(objectType: tabType))
    }
}
