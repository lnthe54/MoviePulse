import UIKit

protocol GenresCellDelegate: NSObjectProtocol {
    func didSelectCategory(item: CategoryObject)
}

class GenresCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var categories: [CategoryObject] = []
    
    weak var delegate: GenresCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = .pimaryColor
        containerView.corner(8)
        
        titleLabel.text = "List Genres"
        titleLabel.textColor = .white
        titleLabel.font = .outfitFont(ofSize: 16, weight: .semiBold)
        
        collectionView.register(CategoryCell.nib(), forCellWithReuseIdentifier: CategoryCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: AppLayout.categoryHorizontalSection()), animated: true)
    }
    
    func bindData(categories: [CategoryObject]) {
        self.categories = categories
        
        collectionView.reloadData()
    }
}

extension GenresCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.className, for: indexPath) as! CategoryCell
        cell.bindData(categories[indexPath.row])
        return cell
    }
}

extension GenresCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCategory(item: categories[indexPath.row])
    }
}
