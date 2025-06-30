import UIKit

class ImagesViewController: BaseViewController {

    // MARK: - Properties
    private var images: [BackdropObject]
    private var selectedIndex: Int
    
    init(images: [BackdropObject], selectedIndex: Int) {
        self.images = images
        self.selectedIndex = selectedIndex
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func setupViews() {
        collectionView.register(ImageDetailCell.nib(), forCellWithReuseIdentifier: ImageDetailCell.className)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        let selectedIndexPath = IndexPath(row: self.selectedIndex, section: 0)
        collectionView.scrollToItem(
            at: selectedIndexPath,
            at: .centeredHorizontally,
            animated: false
        )
    }
    
    @IBAction private func didToClose() {
        dismiss(animated: true)
    }
}

extension ImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageDetailCell.className, for: indexPath) as! ImageDetailCell
        cell.bindData(images[indexPath.row])
        return cell
    }
}

extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let heightPerItem: CGFloat = collectionView.frame.height
        let widthPerItem: CGFloat = collectionView.frame.width
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
