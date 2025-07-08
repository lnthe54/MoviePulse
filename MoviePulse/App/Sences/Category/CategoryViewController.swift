import UIKit

class CategoryViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: CategoryNavigator
    private var viewModel: CategoryViewModel
    private var categories: [CategoryObject]
    private var objectType: ObjectType
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    init(
        navigator: CategoryNavigator,
        viewModel: CategoryViewModel,
        categories: [CategoryObject],
        objectType: ObjectType
    ) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.categories = categories
        self.objectType = objectType
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
    
    override func setupViews() {
        setupHeader(withType: .detail(title: "All genres"))
        topConstraint.constant = Constants.HEIGHT_NAV
        
        collectionView.register(CategoryCell.nib(), forCellWithReuseIdentifier: CategoryCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(
            UICollectionViewCompositionalLayout(section: AppLayout.categorySection(isShowHeader: false)),
            animated: true
        )
    }
    
    override func actionBack() {
        navigator.popToViewController()
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.className, for: indexPath) as! CategoryCell
        cell.bindData(categories[indexPath.row])
        return cell
    }
}

extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigator.gotoListItemViewController(sectionType: .category(category: categories[indexPath.row], objectType: objectType))
    }
}
