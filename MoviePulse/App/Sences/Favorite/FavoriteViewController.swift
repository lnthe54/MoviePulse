import UIKit
import RxSwift
import RxCocoa
import RxGesture

enum FavoriteSectionType {
    case list
    case empty
}

class FavoriteViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: FavoriteNavigator
    private var viewModel: FavoriteViewModel
    private var tabType: ObjectType = .movie
    private var items: [InfoObject] = []
    
    private let getDataTrigger = PublishSubject<ObjectType>()
    private let gotoDetailItemTrigger = PublishSubject<InfoObject>()
    
    init(navigator: FavoriteNavigator, viewModel: FavoriteViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData),
            name: .reloadFavoriteList,
            object: nil
        )
        getDataTrigger.onNext(.movie)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }
    
    override func bindViewModel() {
        let input = FavoriteViewModel.Input(
            getDataTrigger: getDataTrigger.asObservable(),
            gotoDetailItemTrigger: gotoDetailItemTrigger.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.getDataEvent
            .driveNext { [weak self] items in
                guard let self else { return }
                
                self.items = items.map { $0.transformToInfoObject() }
                
                let buttons: [RightContentType] = items.isEmpty ? [] : [.delete]
                setupHeader(withType: .detail(title: "Favorites", rightContents: buttons))
                
                collectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        output.gotoDetailItemEvent
            .driveNext { [weak self] infoDetailObject in
                self?.navigator.gotoDetailItemViewController(infoDetailObject: infoDetailObject)
            }
            .disposed(by: disposeBag)
        
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
    }
    
    override func setupViews() {
        topConstraint.constant = Constants.HEIGHT_NAV
        
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
        
        collectionView.register(ItemHorizontalCell.nib(), forCellWithReuseIdentifier: ItemHorizontalCell.className)
        collectionView.register(EmptyCell.nib(), forCellWithReuseIdentifier: EmptyCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        configureCompositionalLayout()
    }
    
    override func actionBack() {
        navigator.popToViewController()
    }
    
    override func actionDelete() {
        showDelPopup()
    }
}

extension FavoriteViewController {
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
            case .list:
                return AppLayout.itemsSection()
            case .empty:
                return AppLayout.fixedSection(height: 300)
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [FavoriteSectionType] {
        var sections: [FavoriteSectionType] = []
        
        if items.isEmpty {
            sections.append(.empty)
        } else {
            sections.append(.list)
        }
        
        return sections
    }
    
    private func showDelPopup() {
        let popupView = ComponentPopup(
            titleHeader: "Are you sure you want to delete all these item?",
            content: "Careful — once done, this can’t be changed.",
            leftValue: "No, cancel",
            rightValue: "Confirm"
        )
        
        popupView.onTapRightButton = { [weak self] in
            self?.handleDelFavorites()
        }
        popupView.modalPresentationStyle = .overFullScreen
        present(popupView, animated: false)
    }
    
    private func handleDelFavorites() {
        let filters = CodableManager.shared.getListFavorite().filter { $0.type != tabType }
        CodableManager.shared.saveListFarotie(filters)
        getDataTrigger.onNext(tabType)
    }
    
    @objc
    private func reloadData() {
        getDataTrigger.onNext((tabType))
    }
}

extension FavoriteViewController: UICollectionViewDataSource {
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
            return itemCell(collectionView, cellForItemAt: indexPath)
        case .empty:
            return emptyCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func itemCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> ItemHorizontalCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemHorizontalCell.className, for: indexPath) as! ItemHorizontalCell
        cell.bindData(items[indexPath.row])
        return cell
    }
    
    private func emptyCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> EmptyCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.className, for: indexPath) as! EmptyCell
        cell.onTapDiscover = {
            NotificationCenter.default.post(name: .switchToDiscoverTab, object: nil)
        }
        cell.bindData(title: "Nothing here", message: "Discover exciting movies and start measuring your reactions!")
        return cell
    }
}

extension FavoriteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .list:
            gotoDetailItemTrigger.onNext(items[indexPath.row])
        default: break
        }
    }
}
