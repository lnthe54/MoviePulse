import UIKit
import Kingfisher
import RxSwift
import RxCocoa

enum DetailItemSectionType {
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
        collectionView.register(ItemHorizontalCell.nib(), forCellWithReuseIdentifier: ItemHorizontalCell.className)
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
            case .related:
                return AppLayout.horizontalSection()
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [DetailItemSectionType] {
        var sections: [DetailItemSectionType] = []
        
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
        case .related:
            return infoDetailObject.recommendations.count > Constant.maxDisplayItems ? Constant.maxDisplayItems : infoDetailObject.recommendations.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
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
            default:
                return UICollectionReusableView()
            }
        } else {
            return UICollectionReusableView()
        }
    }
    
    private func itemCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> ItemHorizontalCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemHorizontalCell.className, for: indexPath) as! ItemHorizontalCell
        cell.bindData(infoDetailObject.recommendations[indexPath.row])
        return cell
    }
}

extension DetailItemViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .related:
            gotoDetailItemTrigger.onNext(infoDetailObject.recommendations[indexPath.row])
        }
    }
    
    override func didToSeeMore(sectionType: Any) {
        guard let sectionType = sectionType as? DetailItemSectionType else {
            return
        }
        
        switch sectionType {
        case .related:
            navigator.gotoListItemViewController(sectionType: .others(title: "Related movies", items: infoDetailObject.recommendations))
        }
    }
}
