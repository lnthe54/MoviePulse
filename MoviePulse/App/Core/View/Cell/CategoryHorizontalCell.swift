import UIKit
import RxSwift
import RxCocoa
import RxGesture

protocol CategoryHorizontalCellDelegate: NSObjectProtocol {
    func reloadCategories()
    func didSelectedCategory(_ category: CategoryObject)
}

class CategoryHorizontalCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var categories: [CategoryObject] = []

    weak var delegate: CategoryHorizontalCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        containerView.corner(8)
        
        titleLabel.text = "List Genres"
        titleLabel.textColor = .white
        titleLabel.font = .outfitFont(ofSize: 16, weight: .semiBold)
        
        collectionView.configure(withCells: [CategoryCell.self], delegate: self, dataSource: self)
        collectionView.isScrollEnabled = false
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: AppLayout.categorySection(padding: 0, height: 44, isShowHeader: false)), animated: true)
    }
    
    func bindCategories(_ categories: [CategoryObject], withBackgroundColor bgColor: UIColor) {
        containerView.backgroundColor = bgColor
        self.categories = categories
        collectionView.reloadData()
        
        collectionView.performBatchUpdates(nil) { [weak self] _ in
            guard let self = self else { return }

            let newHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
            if self.collectionViewHeightConstraint.constant != newHeight {
                self.collectionViewHeightConstraint.constant = newHeight
                self.layoutIfNeeded()
                self.delegate?.reloadCategories()
            }
        }
    }
}

extension CategoryHorizontalCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.className, for: indexPath) as! CategoryCell
        cell.bindData(categories[indexPath.row])
        return cell
    }
}

extension CategoryHorizontalCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectedCategory(categories[indexPath.row])
    }
}
