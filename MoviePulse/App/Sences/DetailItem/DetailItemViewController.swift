import UIKit
import Kingfisher
import RxSwift
import RxCocoa

enum DetailItemSectionType {
    case info
    case pulseTest
    case community
    case genres
    case overview
    case photo
    case related
    case review
    case season
}

class DetailItemViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: DetailItemNavigator
    private var viewModel: DetailItemViewModel
    private var infoDetailObject: InfoDetailObject
    private var reviews: [ReviewObject] = []
    private var isPosterHidden = false
    private var isSpecial: Bool = false
    
    private let gotoDetailItemTrigger = PublishSubject<InfoObject>()
    private let gotoDetailSeasonTrigger = PublishSubject<RequestSeasonDetail>()
    
    // MARK: - IBOutlets
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private enum Constant {
        static let maxDisplayItems: Int = 10
    }
    
    init(
        navigator: DetailItemNavigator,
        viewModel: DetailItemViewModel,
        infoDetailObject: InfoDetailObject
    ) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.infoDetailObject = infoDetailObject
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        posterImageView.round(corners: [.bottomLeft, .bottomRight], radius: 8)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }
    
    override func actionBack() {
        navigator.popToViewController()
    }
    
    override func bindViewModel() {
        let input = DetailItemViewModel.Input(
            gotoDetailItemTrigger: gotoDetailItemTrigger.asObservable(),
            gotoDetailSeasonTrigger: gotoDetailSeasonTrigger.asObservable()
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
        
        output.gotoDetailItemEvent
            .driveNext { [weak self] infoDetailObject in
                self?.navigator.gotoDetailItemViewController(infoDetailObject: infoDetailObject)
            }
            .disposed(by: disposeBag)
        
        output.gotoDetailSeasonEvent
            .driveNext { [weak self] seasonInfo in
                self?.navigator.gotoSeasonDetailViewController(seasonInfo: seasonInfo)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: "", rightContents: [.share]))
        
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(infoDetailObject.posterPath ?? "", size: .w780)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        
        let specials = infoDetailObject.seasons.filter({ $0.name.lowercased() == "specials" })
        isSpecial = specials.isNotEmpty
        
        reviews = infoDetailObject.reviews?.results ?? []
        
        collectionView.configure(
            withCells: [InfoDetailItemCell.self, ItemHorizontalCell.self, OverviewDetailItemCell.self, ImageCell.self, PulseTestCell.self, CommunityCell.self, GenresCell.self, ReviewCell.self, SeasonCell.self],
            headers: [TitleHeaderSection.self],
            delegate: self,
            dataSource: self,
            contentInset: UIEdgeInsets(top: posterImageView.frame.height - 120, left: 0, bottom: 0, right: 0)
        )
        configureCompositionalLayout()
    }
}

extension DetailItemViewController {
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .info:
                return AppLayout.fixedSection(height: 180)
            case .pulseTest:
                return AppLayout.fixedSection(height: 146)
            case .community:
                return AppLayout.fixedSection(height: 120)
            case .genres:
                return AppLayout.fixedSection(height: 112)
            case .overview:
                return AppLayout.fixedSection(height: 300)
            case .photo:
                return AppLayout.gallerySection()
            case .related:
                return AppLayout.horizontalSection()
            case .review:
                return AppLayout.horizontalSection(width: 258, height: 156)
            case .season:
                return AppLayout.horizontalSection(width: 320, height: 124)
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [DetailItemSectionType] {
        var sections: [DetailItemSectionType] = []
        
        sections.append(.info)
        
        sections.append(.pulseTest)
        
        sections.append(.community)
        
        if infoDetailObject.genres.isNotEmpty {
            sections.append(.genres)
        }
        
        if infoDetailObject.overview?.isNotEmpty ?? false {
            sections.append(.overview)
        }
        
        if infoDetailObject.images.isNotEmpty {
            sections.append(.photo)
        }
        
        if infoDetailObject.seasons.isNotEmpty {
            sections.append(.season)
        }
        
        if infoDetailObject.recommendations.isNotEmpty {
            sections.append(.related)
        }
        
        if reviews.isNotEmpty {
            sections.append(.review)
        }
        
        return sections
    }
    
    private func addToFavorites() {
        var favorites = CodableManager.shared.getListFavorite()
        favorites.append(infoDetailObject)
        CodableManager.shared.saveListFarotie(favorites)
    }
    
    private func removeToFavorites() {
        var favorites = CodableManager.shared.getListFavorite()
        let filters = favorites.filter { $0.id != infoDetailObject.id }
        favorites = filters
        
        CodableManager.shared.saveListFarotie(favorites)
    }
    
    func showSuccessAlert(title: String, message: String) {
        let alert = SuccessAlertView(title: title, message: message)
        alert.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alert)
        
        NSLayoutConstraint.activate([
            alert.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            alert.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alert.widthAnchor.constraint(equalToConstant: 179)
        ])
        
        alert.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            alert.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.3, animations: {
                    alert.alpha = 0
                }) { _ in
                    alert.removeFromSuperview()
                }
            }
        }
    }
}

extension DetailItemViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .info, .pulseTest, .community, .genres, .overview:
            return 1
        case .photo:
            return infoDetailObject.images.count > Constant.maxDisplayItems ? Constant.maxDisplayItems : infoDetailObject.images.count
        case .related:
            return infoDetailObject.recommendations.count > Constant.maxDisplayItems ? Constant.maxDisplayItems : infoDetailObject.recommendations.count
        case .review:
            return reviews.count > Constant.maxDisplayItems ? Constant.maxDisplayItems : reviews.count
        case .season:
            return infoDetailObject.seasons.count > Constant.maxDisplayItems ? Constant.maxDisplayItems : infoDetailObject.seasons.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .info:
            return infoCell(collectionView, cellForItemAt: indexPath)
        case .pulseTest:
            return pulseTestCell(collectionView, cellForItemAt: indexPath)
        case .community:
            return communityCell(collectionView, cellForItemAt: indexPath)
        case .genres:
            return genresCell(collectionView, cellForItemAt: indexPath)
        case .overview:
            return overViewCell(collectionView, cellForItemAt: indexPath)
        case .photo:
            return photoCell(collectionView, cellForItemAt: indexPath)
        case .related:
            return itemCell(collectionView, cellForItemAt: indexPath)
        case .review:
            return reviewCell(collectionView, cellForItemAt: indexPath)
        case .season:
            return seasonCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == "Header" else {
            return UICollectionReusableView()
        }

        let sectionType = getSections()[indexPath.section]
        
        let (title, items): (String, [Any]) = {
            switch sectionType {
            case .related:
                return (infoDetailObject.type == .movie ? "Related movies" : "Related tv shows", infoDetailObject.recommendations)
            case .photo:
                return ("Gallery", [])
            case .review:
                return ("Ratings & reviews", reviews)
            case .season:
                return ("List seasons", infoDetailObject.seasons)
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
    
    private func infoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> InfoDetailItemCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InfoDetailItemCell.className, for: indexPath) as! InfoDetailItemCell
        cell.onTapFavorite = { [weak self] isFavorite in
            guard let self else { return }
            
            if isFavorite {
                showSuccessAlert(title: "Nice choice!", message: "It’s now in your favorites")
            }
            isFavorite ? addToFavorites() : removeToFavorites()
            NotificationCenter.default.post(name: .reloadFavoriteList, object: nil)
        }
        
        cell.onTapWatch = { [weak self] in
            guard let self, let trailers = infoDetailObject.videos?.results else { return }
            navigator.gotoTrailerViewController(trailers: trailers)
        }
        
        cell.bindData(infoDetailObject)
        return cell
    }
    
    private func overViewCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> OverviewDetailItemCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverviewDetailItemCell.className, for: indexPath) as! OverviewDetailItemCell
        cell.bindData(overView: infoDetailObject.overview ?? "")
        return cell
    }
    
    private func photoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> ImageCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.className, for: indexPath) as! ImageCell
        cell.bindData(path: infoDetailObject.images[indexPath.row].filePath)
        return cell
    }
    
    private func itemCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> ItemHorizontalCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemHorizontalCell.className, for: indexPath) as! ItemHorizontalCell
        cell.bindData(infoDetailObject.recommendations[indexPath.row])
        return cell
    }
    
    private func pulseTestCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> PulseTestCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PulseTestCell.className, for: indexPath) as! PulseTestCell
        cell.onStartTest = { [weak self] in
            guard let self else { return }
            navigator.gotoPulseTestViewController(posterPath: infoDetailObject.posterPath ?? "", name: infoDetailObject.name)
        }
        return cell
    }
    
    private func communityCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> CommunityCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunityCell.className, for: indexPath) as! CommunityCell
        cell.bindData(genre: infoDetailObject.genres.first?.name ?? "", voteAvg: infoDetailObject.vote ?? 0.0)
        return cell
    }
    
    private func genresCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> GenresCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenresCell.className, for: indexPath) as! GenresCell
        cell.delegate = self
        cell.bindData(categories: infoDetailObject.genres)
        return cell
    }
    
    private func reviewCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> ReviewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.className, for: indexPath) as! ReviewCell
        cell.bindData(review: reviews[indexPath.row])
        return cell
    }
    
    private func seasonCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> SeasonCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonCell.className, for: indexPath) as! SeasonCell
        cell.bindData(infoDetailObject.seasons[indexPath.row])
        return cell
    }
}

extension DetailItemViewController: UICollectionViewDelegate, GenresCellDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .related:
            gotoDetailItemTrigger.onNext(infoDetailObject.recommendations[indexPath.row])
        case .photo:
            navigator.gotoImagesViewController(images: infoDetailObject.images, selectedIndex: indexPath.row)
        case .season:
            let selectedSeason = infoDetailObject.seasons[indexPath.row]
            var value: Any!
            
            if selectedSeason.name.lowercased().contains("Specials".lowercased()) {
                value = "Specials"
            } else {
                value = isSpecial ? indexPath.row : (indexPath.row + 1)
            }
            
            let params = RequestSeasonDetail(idTVShow: infoDetailObject.id, index: value!)
            gotoDetailSeasonTrigger.onNext(params)
            
        default: break
        }
    }
    
    override func didToSeeMore(sectionType: Any) {
        guard let sectionType = sectionType as? DetailItemSectionType else {
            return
        }
        
        switch sectionType {
        case .related:
            navigator.gotoListItemViewController(sectionType: .others(title: "Related movies", items: infoDetailObject.recommendations))
        case .season:
            navigator.gotoSeasonViewController(tvShowId: infoDetailObject.id, seasons: infoDetailObject.seasons)
        default: break
        }
    }
    
    func didSelectCategory(item: CategoryObject) {
        navigator.gotoListItemViewController(sectionType: .category(category: item, objectType: infoDetailObject.type))
    }
}

extension DetailItemViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let shouldHidePoster = scrollView.contentOffset.y > 0

        if shouldHidePoster != isPosterHidden {
            isPosterHidden = shouldHidePoster
            UIView.animate(withDuration: 0.25) {
                self.posterImageView.alpha = shouldHidePoster ? 0 : 1
            }
        }
    }
}
