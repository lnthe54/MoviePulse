import UIKit

class OnboardingViewController: BaseViewController {

    // MARK: - Properties
    var navigator: OnboardingNavigator!
    var viewModel: OnboardingViewModel!
    
    init() {
        super.init(nibName: Self.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindViewModel() {
        let input = OnboardingViewModel.Input()
        let output = viewModel.transform(input: input)
    }
    
    override func setupViews() {
    }
}
