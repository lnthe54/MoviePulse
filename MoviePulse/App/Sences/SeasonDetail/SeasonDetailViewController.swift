import UIKit
import Kingfisher

class SeasonDetailViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: SeasonDetailNavigator
    private var viewModel: SeasonDetailViewModel
    private var seasonInfo: SeasonInfo
    
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
    }
}
