import UIKit
import RxSwift
import RxCocoa

class DiscoverViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: DiscoverNavigator
    private var viewModel: DiscoverViewModel
    private var tabType: ObjectType = .movie
    
    init(navigator: DiscoverNavigator, viewModel: DiscoverViewModel) {
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .showTabBar, object: nil)
    }
    
    override func bindViewModel() {
        let input = DiscoverViewModel.Input()
        let output = viewModel.transform(input: input)
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
        
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        configureCompositionalLayout()
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
//        getDataTrigger.onNext(tabType)
    }
    
    private func didToTVShowsTab() {
        tabType = .tv
        tvIndicatorView.isHidden = false
        tvShowLabel.textColor = .pimaryColor
        tvShowLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        
        movieIndicatorView.isHidden = true
        movieLabel.textColor = UIColor(hexString: "#697081")
        movieLabel.font = .outfitFont(ofSize: 14, weight: .light)
//        getDataTrigger.onNext(tabType)
    }
}
