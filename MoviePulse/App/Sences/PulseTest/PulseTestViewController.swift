import UIKit

class PulseTestViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: PulseTestNavigator
    private var viewModel: PulseTestViewModel
    
    init(navigator: PulseTestNavigator, viewModel: PulseTestViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }

    override func actionBack() {
        navigator.popToViewController()
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: "Pulse Test"))
        
        topConstraint.constant = Constants.HEIGHT_NAV
        
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
//        collectionView.delegate = self
//        collectionView.dataSource = self
    }
}
