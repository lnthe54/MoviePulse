import UIKit

class CategoryCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryLabel.textColor = .blackColor
        categoryLabel.font = .outfitFont(ofSize: 14, weight: .medium)
    }

    func bindData(_ data: CategoryObject) {
        categoryLabel.text = data.name
    }
}
