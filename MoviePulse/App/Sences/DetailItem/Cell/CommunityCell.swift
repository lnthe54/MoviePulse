import UIKit

class CommunityCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(8)
        
        titleLabel.text = "Compare with community"
        titleLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        titleLabel.textColor = .blackColor
        
        subContainerView.backgroundColor = UIColor(hexString: "#FAF7FE")
        subContainerView.corner(4)
    }
}
