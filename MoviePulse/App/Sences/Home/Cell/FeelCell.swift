import UIKit

class FeelCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = .pimaryColor
        containerView.corner(8)
        
        titleLabel.text = "How are you feeling today?"
        titleLabel.textColor = .white
        titleLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        titleLabel.numberOfLines = 0
        
        contentLabel.text = "Select one keyword below..."
        contentLabel.textColor = .white
        contentLabel.font = .outfitFont(ofSize: 12)
        contentLabel.numberOfLines = 0
        
        collectionView.register(CategoryCell.nib(), forCellWithReuseIdentifier: CategoryCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: AppLayout.categorySection(isShowHeader: false)), animated: true)
    }
}

extension FeelCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.feels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.className, for: indexPath) as! CategoryCell
        cell.bindText(Constants.feels[indexPath.row])
        return cell
    }
}

extension FeelCell: UICollectionViewDelegate {
    
}

