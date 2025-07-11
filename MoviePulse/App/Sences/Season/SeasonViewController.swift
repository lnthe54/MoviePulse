import UIKit
import RxSwift
import RxCocoa
import RxGesture

enum SeasonSectionType {
    case list
    case empty
}

class SeasonViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: SeasonNavigator
    private var viewModel: SeasonViewModel
    private var tvShowId: Int
    private var seasons: [SeasonObject]
    private var isSpecial: Bool = false
    private var filters: [SeasonObject] = []
    
    private let gotoDetailSeasonTrigger = PublishSubject<RequestSeasonDetail>()
    
    init(
        navigator: SeasonNavigator,
        viewModel: SeasonViewModel,
        tvShowId: Int,
        seasons: [SeasonObject]
    ) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.tvShowId = tvShowId
        self.seasons = seasons
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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }
    
    override func actionBack() {
        navigator.popToViewController()
    }
    
    override func bindViewModel() {
        let input = SeasonViewModel.Input(
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
        
        output.gotoDetailSeasonEvent
            .driveNext { [weak self] seasonInfo in
                self?.navigator.gotoSeasonDetailViewController(seasonInfo: seasonInfo)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        topConstraint.constant = Constants.HEIGHT_NAV
        
        setupHeader(withType: .detail(title: "All seasons"))
        
        searchView.backgroundColor = .white
        searchView.corner(8)
        
        searchTf.attributedPlaceholder = NSAttributedString(
            string: "Search any seasons...",
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
        
        filters = seasons
        let specials = filters.filter({ $0.name.lowercased() == "specials" })
        isSpecial = specials.isNotEmpty
        
        collectionView.configure(withCells: [SeasonCell.self, EmptyCell.self], delegate: self, dataSource: self)
        configureCompositionalLayout()
    }
}

extension SeasonViewController {
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .list:
                return AppLayout.episodeSection(height: 124)
            case .empty:
                return AppLayout.fixedSection(height: 300)
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [SeasonSectionType] {
        var sections: [SeasonSectionType] = []
        
        if filters.isEmpty {
            sections.append(.empty)
        } else {
            sections.append(.list)
        }
        
        return sections
    }
    
    private func handleSearch(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            filters = seasons
        } else {
            filters = seasons.filter { $0.name.lowercased().contains(text.lowercased()) }
        }
        
        collectionView.reloadData()
    }
}

extension SeasonViewController: UICollectionViewDataSource {
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
            return seasonCell(collectionView, cellForItemAt: indexPath)
        case .empty:
            return emptyCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func seasonCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> SeasonCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonCell.className, for: indexPath) as! SeasonCell
        cell.bindData(filters[indexPath.row])
        return cell
    }
    
    private func emptyCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> EmptyCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.className, for: indexPath) as! EmptyCell
        cell.bindData(title: "Nothing here", message: "Please try with another keyword", isHideButton: true)
        return cell
    }
}

extension SeasonViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .list:
            let selectedSeason = filters[indexPath.row]
            var value: Any!
            
            if selectedSeason.name.lowercased().contains("Specials".lowercased()) {
                value = "Specials"
            } else {
                value = isSpecial ? indexPath.row : (indexPath.row + 1)
            }
            
            let params = RequestSeasonDetail(idTVShow: tvShowId, index: value!)
            
            gotoDetailSeasonTrigger.onNext(params)
        default: break
        }
    }
}
