import UIKit

class SavePulseViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: SavePulseNavigator
    private var viewModel: SavePulseViewModel
    
    init(navigator: SavePulseNavigator, viewModel: SavePulseViewModel) {
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
    
    override func bindViewModel() {
        
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: "Pulse Gallery"))
        topConstraint.constant = Constants.HEIGHT_NAV
        collectionView.configure(withCells: [SavePulseCell.self], dataSource: self)
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: AppLayout.tableSection(height: 144)), animated: true)
    }
    
    override func actionBack() {
        navigator.popToViewController()
    }
}

extension SavePulseViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavePulseCell.className, for: indexPath) as! SavePulseCell
        
        return cell
    }
}
