import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ResultSearchViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: ResultSearchNavigator
    private var viewModel: ResultSearchViewModel
    private var key: String
    
    // MARK: - IBOutlets
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchTf: UITextField!
    
    init(
        navigator: ResultSearchNavigator,
        viewModel: ResultSearchViewModel,
        key: String
    ) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.key = key
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }
    
    override func bindViewModel() {
        
    }
    
    override func setupViews() {
        backView.backgroundColor = UIColor(hexString: "#E7D9FB")
        backView.corner(4)
        backView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.navigator.popToRootView()
            })
            .disposed(by: disposeBag)
        
        searchView.backgroundColor = .white
        searchView.corner(8)
        
        searchTf.text = key
        searchTf.textColor = .blackColor
        searchTf.tintColor = .pimaryColor
        searchTf.returnKeyType = .search
    }
}
