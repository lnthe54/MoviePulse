import UIKit
import Kingfisher

class SavePulseCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var heartView: UIView!
    @IBOutlet private weak var heartLabel: UILabel!
    @IBOutlet private weak var tensionView: UIView!
    @IBOutlet private weak var tensionLabel: UILabel!
    
    var onTapMoreAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(4)
        
        posterImageView.corner(8)
        
        nameLabel.textColor = .blackColor
        nameLabel.font = .outfitFont(ofSize: 16, weight: .semiBold)
        
        timeLabel.textColor = UIColor(hexString: "#697081")
        timeLabel.font = .outfitFont(ofSize: 12, weight: .light)
        
        heartView.configSubView()
        heartLabel.configSubLabel("Heart rate")
        
        tensionView.configSubView()
        tensionLabel.configSubLabel("Tension rate")
    }
    
    @IBAction private func tapToMoreButton() {
        onTapMoreAction?()
    }
}
