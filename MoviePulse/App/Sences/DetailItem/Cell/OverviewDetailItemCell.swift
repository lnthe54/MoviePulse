import UIKit

class OverviewDetailItemCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentLabel.textColor = .blackColor
        contentLabel.font = .outfitFont(ofSize: 14)
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .justified
    }

    func bindData(overView: String) {
        contentLabel.text = overView
    }
}
