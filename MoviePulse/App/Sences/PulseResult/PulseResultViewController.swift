import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import RxGesture

enum PulseResultScreenType {
    case detail(result: PulseResultInfo)
    case result(result: PulseResultInfo)
    
    var title: String {
        switch self {
        case .detail:
            return "Pulse Detail"
        case .result:
            return "Pulse Result"
        }
    }
}

class PulseResultViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: PulseResultNavigator
    private var viewModel: PulseResultViewModel
    private var screenType: PulseResultScreenType
    private var pulseResult: PulseResultInfo!
    private var isFavorite: Bool = false
    
    init(
        navigator: PulseResultNavigator,
        viewModel: PulseResultViewModel,
        screenType: PulseResultScreenType
    ) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.screenType = screenType
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
    @IBOutlet private weak var analysisView: UIView!
    @IBOutlet private weak var analysisLabel: UILabel!
    @IBOutlet private weak var emotionView: UIView!
    @IBOutlet private weak var emotionLabel: UILabel!
    @IBOutlet private weak var emotionValueLabel: UILabel!
    @IBOutlet private weak var energyView: UIView!
    @IBOutlet private weak var energyLabel: UILabel!
    @IBOutlet private weak var energyValueLabel: UILabel!
    @IBOutlet private weak var tenseView: UIView!
    @IBOutlet private weak var tenseLabel: UILabel!
    @IBOutlet private weak var tenseValueLabel: UILabel!
    @IBOutlet private weak var calmView: UIView!
    @IBOutlet private weak var calmLabel: UILabel!
    @IBOutlet private weak var calmValueLabel: UILabel!
    @IBOutlet private weak var heartView: UIView!
    @IBOutlet private weak var bpmValueLabel: UILabel!
    @IBOutlet private weak var bpmIndicatorView: BPMIndicatorView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var saveView: UIView!
    @IBOutlet private weak var saveImageView: UIImageView!
    
    lazy var defaultAttr: [NSAttributedString.Key: Any] = {
        return [
            .foregroundColor: UIColor.blackColor,
            .font: UIFont.outfitFont(ofSize: 44, weight: .semiBold)
        ]
    }()
    
    lazy var customAttr: [NSAttributedString.Key: Any] = {
        return [
            .foregroundColor: UIColor.blackColor,
            .font: UIFont.outfitFont(ofSize: 14, weight: .semiBold),
            .baselineOffset: 25
        ]
    }()
    
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
        setupHeader(withType: .detail(title: screenType.title, rightContents: [.share]))
        
        topConstraint.constant = Constants.HEIGHT_NAV
        
        saveView.corner(4)
        saveView.backgroundColor = UIColor(hexString: "#E7D9FB")
        view.bringSubviewToFront(saveView)
        saveView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.handleFavorite()
            })
            .disposed(by: disposeBag)
        
        infoView.backgroundColor = .white
        infoView.corner(8)
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.corner(8)
        
        noteLabel.text = "You're measuring your heartbeat with"
        noteLabel.textColor = UIColor(hexString: "#252934")
        noteLabel.font = .outfitFont(ofSize: 14)
        noteLabel.numberOfLines = 0
        noteLabel.textAlignment = .center
        
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
            .subscribe(onNext: { _ in
                NotificationCenter.default.post(name: .switchToDiscoverTab, object: nil)
            })
            .disposed(by: disposeBag)
        discoverButton.backgroundColor = UIColor(hexString: "#E7D9FB")
        discoverButton.corner(discoverButton.frame.height / 2)
        discoverButton.setTitle("Discover more", for: .normal)
        discoverButton.setTitleColor(.pimaryColor, for: .normal)
        discoverButton.titleLabel?.font = .outfitFont(ofSize: 14, weight: .semiBold)
        
        analysisView.corner(8)
        analysisLabel.text = "Emotion Analysis"
        analysisLabel.textColor = .blackColor
        analysisLabel.font = .outfitFont(ofSize: 16, weight: .semiBold)
        
        // Config subview
        emotionView.configSubView()
        emotionLabel.configSubLabel("Emotion")
        
        energyView.configSubView()
        energyLabel.configSubLabel("Energy")
        
        tenseView.configSubView()
        tenseLabel.configSubLabel("Tension")
        
        calmView.configSubView()
        calmLabel.configSubLabel("Calm")
        
        // Chart - Heart view
        heartView.backgroundColor = .white
        heartView.corner(8)
        
        infoLabel.textColor = .blackColor
        infoLabel.font = .outfitFont(ofSize: 14)
        
        switch screenType {
        case .detail(let result):
            pulseResult = result
        case .result(let result):
            pulseResult = updatePulseResultInfo(result: result)
        }
        
        bindData()
    }
    
    override func bindViewModel() {
        
    }
    
    override func actionBack() {
        navigator.popToRootViewController()
    }
}

extension PulseResultViewController {
    private func updatePulseResultInfo(result: PulseResultInfo) -> PulseResultInfo {
        let emotions = Utils.emotionPercentages(for: pulseResult.bpm)
        let tense = emotions["Tense"] ?? 0
        return PulseResultInfo(
            id: result.id,
            date: result.date,
            bpm: result.bpm,
            name: result.name,
            path: result.path,
            tension: tense
        )
    }
    
    private func bindData() {
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(pulseResult.path, size: .w342)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        nameLabel.text = pulseResult.name
        emotionValueLabel.configValueLabel(Utils.detectEmotion(from: pulseResult.bpm))
        energyValueLabel.configValueLabel(Utils.calculateEnergy(from: pulseResult.bpm))
        
        let emotions = Utils.emotionPercentages(for: pulseResult.bpm)
        let tense = emotions["Tense"] ?? 0
        let calm = emotions["Calm"] ?? 0
        tenseValueLabel.configValueLabel("\(tense)%")
        calmValueLabel.configValueLabel("\(calm)%")
        
        let bmpValue = NSMutableAttributedString(
            string: "\(pulseResult.bpm)",
            attributes: defaultAttr
        )
        
        let bpmUnit = NSAttributedString(
            string: " BPM",
            attributes: customAttr
        )
        bmpValue.append(bpmUnit)
        bpmValueLabel.attributedText = bmpValue
        bpmIndicatorView.bpm = CGFloat(pulseResult.bpm)
        
        infoLabel.text = Utils.getInfoMessage(from: pulseResult.bpm)
    }
    
    private func handleFavorite() {
        isFavorite = !isFavorite
        
        if isFavorite {
            showSuccessAlert(title: "Successful", message: "It’s now in your pulse gallery")
            saveImageView.image = UIImage(named: "ic_fav_active")
            addToFavorites()
        } else {
            saveImageView.image = UIImage(named: "ic_fav_inactive")
            removeToFavorites()
        }
    }
    
    private func addToFavorites() {
        var results = CodableManager.shared.getPulseResults()
        results.append(pulseResult)
        CodableManager.shared.savePulseResults(results)
    }
    
    private func removeToFavorites() {
        var results = CodableManager.shared.getPulseResults()
        let filters = results.filter { $0.id != pulseResult.id }
        results = filters

        CodableManager.shared.savePulseResults(results)
    }
}

extension UIView {
    func configSubView() {
        backgroundColor = UIColor(hexString: "#FAF7FE")
        corner(4)
    }
}

extension UILabel {
    func configSubLabel(_ value: String) {
        text = value
        textColor = UIColor(hexString: "#7017E8")
        font = .outfitFont(ofSize: 12, weight: .light)
    }
    
    func configValueLabel(_ value: String) {
        text = value
        textColor = UIColor(hexString: "#2D095D")
        font = .outfitFont(ofSize: 20, weight: .semiBold)
    }
}
