import UIKit

class SettingViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: SettingNavigator
    private var viewModel: SettingViewModel
    
    init(navigator: SettingNavigator, viewModel: SettingViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupViews() {
        
    }
    
    override func bindViewModel() {
        
    }
}
