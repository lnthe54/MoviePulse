import UIKit
import RxSwift
import RxCocoa

class OnboardingViewController: BaseViewController {

    // MARK: - Properties
    var navigator: OnboardingNavigator!
    var viewModel: OnboardingViewModel!
    private var currentIndex: Int = 0
    private var onboardings: [OnboardingInfo] = []
    private let getDataTrigger = PublishSubject<Void>()
    
    // MARK: - IBOutlets
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var skipButton: UIButton!
    @IBOutlet private weak var onboardingView1: UIView!
    @IBOutlet private weak var onboardingView2: UIView!
    @IBOutlet private weak var onboardingView3: UIView!
    
    init() {
        super.init(nibName: Self.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataTrigger.onNext(())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backgroundView.round(corners: [.bottomLeft, .bottomRight], radius: 12)
    }
    
    override func bindViewModel() {
        let input = OnboardingViewModel.Input(
            getDataTrigger: getDataTrigger.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.getDataEvent
            .driveNext { [weak self] onboardings in
                guard let self else { return }
                self.onboardings = onboardings
                self.bindOnboardingView()
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        view.backgroundColor = UIColor(hexString: "#FAF7FE")
        backgroundView.backgroundColor = .pimaryColor
        
        containerView.corner(12)
        
        titleLabel.textColor = .blackColor
        titleLabel.font = .outfitFont(ofSize: 14, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        contentLabel.textColor = .blackColor
        contentLabel.font = .outfitFont(ofSize: 24, weight: .semiBold)
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        
        continueButton.backgroundColor = .pimaryColor
        continueButton.corner(continueButton.frame.height / 2)
        continueButton.setTitle("Continues", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = .outfitFont(ofSize: 16, weight: .semiBold)
        continueButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                
                if currentIndex >= (onboardings.count - 1) {
                    navigator.gotoMainViewController()
                    return
                }
                currentIndex += 1
                bindOnboardingView()
            }
            .disposed(by: disposeBag)
        
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.pimaryColor, for: .normal)
        skipButton.titleLabel?.font = .outfitFont(ofSize: 16, weight: .semiBold)
        skipButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                navigator.gotoMainViewController()
            }
            .disposed(by: disposeBag)
        
        onboardingView1.backgroundColor = .systemGray5
        onboardingView2.backgroundColor = .systemGray5
        onboardingView3.backgroundColor = .systemGray5
    }
    
    // MARK: - Private functions
    private func bindOnboardingView() {
        titleLabel.text = onboardings[currentIndex].title
        contentLabel.text = onboardings[currentIndex].content
        backgroundImageView.image = UIImage(named: "onboarding_\(onboardings[currentIndex].id)")
        let buttonTitle: String = currentIndex == (onboardings.count - 1) ? "Start" : "Continues"
        continueButton.setTitle(buttonTitle, for: .normal)
        selectedIndicator()
    }
    
    private func selectedIndicator() {
        switch currentIndex {
        case 0:
            onboardingView1.backgroundColor = .pimaryColor
            onboardingView2.backgroundColor = .systemGray5
            onboardingView3.backgroundColor = .systemGray5
        case 1:
            onboardingView2.backgroundColor = .pimaryColor
            onboardingView1.backgroundColor = .systemGray5
            onboardingView3.backgroundColor = .systemGray5
        case 2:
            onboardingView3.backgroundColor = .pimaryColor
            onboardingView1.backgroundColor = .systemGray5
            onboardingView2.backgroundColor = .systemGray5
        default: break
        }
    }
}
