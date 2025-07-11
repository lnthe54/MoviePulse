import UIKit

class CategoryCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.corner(4)
        categoryLabel.textColor = .blackColor
        categoryLabel.font = .outfitFont(ofSize: 14, weight: .medium)
    }

    func bindData(_ data: CategoryObject) {
        categoryLabel.text = data.name
    }
    
    func bindText(_ text: String) {
        categoryLabel.text = text
    }
}
