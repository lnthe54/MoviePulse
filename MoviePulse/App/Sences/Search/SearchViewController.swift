import UIKit
import RxSwift
import RxCocoa
import RxGesture

class SearchViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: SearchNavigator
    private var viewModel: SearchViewModel
    
    init(navigator: SearchNavigator, viewModel: SearchViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var backView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }
    
    override func setupViews() {
        backView.backgroundColor = UIColor(hexString: "#E7D9FB")
        backView.corner(4)
        backView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.navigator.popToViewController()
            })
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        
    }
}

extension SearchViewController {
    
}
