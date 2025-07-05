import UIKit
import RxSwift
import RxCocoa
import RxGesture

protocol CategoryHorizontalCellDelegate: NSObjectProtocol {
    func didSeeAllCategories()
    func didSelectedCategory(_ category: CategoryObject)
}

class CategoryHorizontalCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var seeMoreView: UIView!
    @IBOutlet private weak var seeMoreLabel: UILabel!
    
    private enum Constant {
        static let maxDisplayItems: Int = 12
    }
    
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
        
        collectionView.register(CategoryCell.nib(), forCellWithReuseIdentifier: CategoryCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: AppLayout.categorySection(padding: 0, height: 44, isShowHeader: false)), animated: true)
        
        seeMoreView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.didSeeAllCategories()
            })
            .disposed(by: disposeBag)
        seeMoreView.backgroundColor = .clear
        seeMoreLabel.textColor = .white
        seeMoreLabel.text = "See more"
        seeMoreLabel.font = .outfitFont(ofSize: 14, weight: .regular)
    }
    
    func bindCategories(_ categories: [CategoryObject], withBackgroundColor bgColor: UIColor) {
        containerView.backgroundColor = bgColor
        self.categories = categories
        seeMoreView.isHidden = categories.count < Constant.maxDisplayItems
        collectionView.reloadData()
    }
}

extension CategoryHorizontalCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count > Constant.maxDisplayItems ? Constant.maxDisplayItems : categories.count
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
