import UIKit
import Kingfisher
import RxSwift
import RxCocoa

enum DetailItemSectionType {
    case info
    case pulseTest
    case community
    case overview
    case photo
    case related
}

class DetailItemViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: DetailItemNavigator
    private var viewModel: DetailItemViewModel
    private var infoDetailObject: InfoDetailObject
    
    private let gotoDetailItemTrigger = PublishSubject<InfoObject>()
    
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
        navigator.popViewController()
    }
    
    override func bindViewModel() {
        let input = DetailItemViewModel.Input(
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
        
        output.gotoDetailItemEvent
            .driveNext { [weak self] infoDetailObject in
                self?.navigator.gotoDetailItemViewController(infoDetailObject: infoDetailObject)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: "", isShowShare: true))
        
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(infoDetailObject.posterPath ?? "", size: .w780)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        
        collectionView.register(TitleHeaderSection.nib(),
                                forSupplementaryViewOfKind: "Header",
                                withReuseIdentifier: TitleHeaderSection.className)
        collectionView.register(InfoDetailItemCell.nib(), forCellWithReuseIdentifier: InfoDetailItemCell.className)
        collectionView.register(ItemHorizontalCell.nib(), forCellWithReuseIdentifier: ItemHorizontalCell.className)
        collectionView.register(OverviewDetailItemCell.nib(), forCellWithReuseIdentifier: OverviewDetailItemCell.className)
        collectionView.register(ImageCell.nib(), forCellWithReuseIdentifier: ImageCell.className)
        collectionView.register(PulseTestCell.nib(), forCellWithReuseIdentifier: PulseTestCell.className)
        collectionView.register(CommunityCell.nib(), forCellWithReuseIdentifier: CommunityCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
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
                return AppLayout.fixedSection(height: 164)
            case .pulseTest:
                return AppLayout.fixedSection(height: 146)
            case .community:
                return AppLayout.fixedSection(height: 120)
            case .overview:
                return AppLayout.fixedSection(height: 300)
            case .photo:
                return AppLayout.gallerySection()
            case .related:
                return AppLayout.horizontalSection()
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [DetailItemSectionType] {
        var sections: [DetailItemSectionType] = []
        
        sections.append(.info)
        
        sections.append(.pulseTest)
        
        sections.append(.community)
        
        if infoDetailObject.overview?.isNotEmpty ?? false {
            sections.append(.overview)
        }
        
        if infoDetailObject.images.isNotEmpty {
            sections.append(.photo)
        }
        
        if infoDetailObject.recommendations.isNotEmpty {
            sections.append(.related)
        }
        
        return sections
    }
}

extension DetailItemViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .info, .pulseTest, .community, .overview:
            return 1
        case .photo:
            return infoDetailObject.images.count > Constant.maxDisplayItems ? Constant.maxDisplayItems : infoDetailObject.images.count
        case .related:
            return infoDetailObject.recommendations.count > Constant.maxDisplayItems ? Constant.maxDisplayItems : infoDetailObject.recommendations.count
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
        case .overview:
            return overViewCell(collectionView, cellForItemAt: indexPath)
        case .photo:
            return photoCell(collectionView, cellForItemAt: indexPath)
        case .related:
            return itemCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == "Header" {
            let sectionType = getSections()[indexPath.section]
            switch sectionType {
            case .related:
                return titleHeaderSection(
                    collectionView,
                    viewForSupplementaryElementOfKind: kind,
                    indexPath: indexPath,
                    title: infoDetailObject.type == .movie ? "Related movies" : "Related tv shows",
                    isShowSeeMore: infoDetailObject.recommendations.count > Constant.maxDisplayItems,
                    sectionType: sectionType
                )
            case .photo:
                return titleHeaderSection(
                    collectionView,
                    viewForSupplementaryElementOfKind: kind,
                    indexPath: indexPath,
                    title: "Gallery",
                    isShowSeeMore: false,
                    sectionType: sectionType
                )
            default:
                return UICollectionReusableView()
            }
        } else {
            return UICollectionReusableView()
        }
    }
    
    private func infoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> InfoDetailItemCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InfoDetailItemCell.className, for: indexPath) as! InfoDetailItemCell
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
        return cell
    }
    
    private func communityCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> CommunityCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunityCell.className, for: indexPath) as! CommunityCell
        return cell
    }
}

extension DetailItemViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .related:
            gotoDetailItemTrigger.onNext(infoDetailObject.recommendations[indexPath.row])
        case .photo:
            navigator.gotoImagesViewController(images: infoDetailObject.images, selectedIndex: indexPath.row)
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
        default: break
        }
    }
}
