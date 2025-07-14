import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import RxGesture

class PulseResultViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: PulseResultNavigator
    private var viewModel: PulseResultViewModel
    private var pulseResult: PulseResultModel
    
    init(
        navigator: PulseResultNavigator,
        viewModel: PulseResultViewModel,
        pulseResult: PulseResultModel
    ) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.pulseResult = pulseResult
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var infoView: UIView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var tryAgainButton: UIButton!
    @IBOutlet private weak var discoverButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomView.round(corners: [.topLeft, .topRight], radius: 8)
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: "Pulse Test"))
        
        topConstraint.constant = Constants.HEIGHT_NAV
        
        infoView.backgroundColor = .white
        infoView.corner(8)
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.corner(8)
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(pulseResult.path, size: .w342)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        
        noteLabel.text = "You're measuring your heartbeat with"
        noteLabel.textColor = UIColor(hexString: "#252934")
        noteLabel.font = .outfitFont(ofSize: 14)
        noteLabel.numberOfLines = 0
        noteLabel.textAlignment = .center
        
        nameLabel.text = pulseResult.name
        nameLabel.textColor = .blackColor
        nameLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        
        tryAgainButton.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                
            })
            .disposed(by: disposeBag)
        tryAgainButton.backgroundColor = .pimaryColor
        tryAgainButton.corner(tryAgainButton.frame.height / 2)
        tryAgainButton.setTitle("Try again", for: .normal)
        tryAgainButton.setTitleColor(.white, for: .normal)
        tryAgainButton.titleLabel?.font = .outfitFont(ofSize: 14, weight: .semiBold)
        
        discoverButton.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                
            })
            .disposed(by: disposeBag)
        discoverButton.backgroundColor = UIColor(hexString: "#E7D9FB")
        discoverButton.corner(discoverButton.frame.height / 2)
        discoverButton.setTitle("Discover more", for: .normal)
        discoverButton.setTitleColor(.pimaryColor, for: .normal)
        discoverButton.titleLabel?.font = .outfitFont(ofSize: 14, weight: .semiBold)
    }
    
    override func bindViewModel() {
        
    }
    
    override func actionBack() {
        navigator.popToRootViewController()
    }
}
