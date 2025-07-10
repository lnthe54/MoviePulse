import UIKit
import Kingfisher

enum SeasonDetailSectionType {
    case search
    case episode
}

class SeasonDetailViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: SeasonDetailNavigator
    private var viewModel: SeasonDetailViewModel
    private var seasonInfo: SeasonInfo
    private var isPosterHidden = false
    private var filters: [EpisodeInfo] = []
    
    init(
        navigator: SeasonDetailNavigator,
        viewModel: SeasonDetailViewModel,
        seasonInfo: SeasonInfo
    ) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.seasonInfo = seasonInfo
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
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
    
    override func actionShare() {
        showPopupShareApp()
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: "", rightContents: [.share]))
        
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(seasonInfo.posterPath ?? "", size: .w780)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        
        filters = seasonInfo.episodes
        
        collectionView.register(SeasonCell.nib(), forCellWithReuseIdentifier: SeasonCell.className)
        collectionView.register(SearchCell.nib(), forCellWithReuseIdentifier: SearchCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: posterImageView.frame.height - 120, left: 0, bottom: 0, right: 0)
        configureCompositionalLayout()
    }
}

extension SeasonDetailViewController {
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .search:
                return AppLayout.fixedSection(height: 40)
            case .episode:
                return AppLayout.episodeSection(height: 124)
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [SeasonDetailSectionType] {
        var sections: [SeasonDetailSectionType] = []
        
        sections.append(.search)
        
        sections.append(.episode)
        
        return sections
    }
    
    private func handleSearch(_ key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            filters = seasonInfo.episodes
        } else {
            filters = seasonInfo.episodes.filter { $0.name.lowercased().contains(key.lowercased()) }
        }
        
        if let episodeSectionIndex = getSections().firstIndex(of: .episode) {
            let indexSet = IndexSet(integer: episodeSectionIndex)
            collectionView.reloadSections(indexSet)
        }
    }
}

extension SeasonDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .search:
            return 1
        case .episode:
            return filters.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .search:
            return searchCell(collectionView, cellForItemAt: indexPath)
        case .episode:
            return episodeCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func searchCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> SearchCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCell.className, for: indexPath) as! SearchCell
        cell.onSearching = { [weak self] key in
            self?.handleSearch(key)
        }
        return cell
    }
    
    private func episodeCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> SeasonCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonCell.className, for: indexPath) as! SeasonCell
        let episodeInfo = filters[indexPath.row]
        cell.bindData(
            withPosterPath: episodeInfo.stillPath ?? "",
            title: episodeInfo.name,
            subTitle: episodeInfo.releaseDate(),
            content: episodeInfo.overview ?? ""
        )
        return cell
    }
}

extension SeasonDetailViewController: UICollectionViewDelegate {
    
}

extension SeasonDetailViewController {
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
