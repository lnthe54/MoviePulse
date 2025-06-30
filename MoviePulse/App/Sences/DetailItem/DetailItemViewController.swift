import UIKit
import Kingfisher

class DetailItemViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: DetailItemNavigator
    private var viewModel: DetailItemViewModel
    private var infoDetailObject: InfoDetailObject
    
    // MARK: - IBOutlets
    @IBOutlet private weak var posterImageView: UIImageView!
    
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
        let input = DetailItemViewModel.Input()
        let output = viewModel.transform(input: input)
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: ""))
        
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(infoDetailObject.posterPath ?? "", size: .w780)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
    }
}
