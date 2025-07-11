import UIKit

class EmptyCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var discoverButton: UIButton!
    
    var onTapDiscover: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        titleLabel.textColor = UIColor(hexString: "#252934")
        titleLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        contentLabel.textColor = UIColor(hexString: "#252934")
        contentLabel.font = .outfitFont(ofSize: 12, weight: .light)
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        
        discoverButton.backgroundColor = .pimaryColor
        discoverButton.corner(discoverButton.frame.height / 2)
        discoverButton.setTitle("Discover Movies", for: .normal)
        discoverButton.setTitleColor(.white, for: .normal)
        discoverButton.titleLabel?.font = .outfitFont(ofSize: 14, weight: .semiBold)
    }
    
    func bindData(title: String, message: String, isHideButton: Bool = false) {
        titleLabel.text = title
        contentLabel.text = message
        discoverButton.isHidden = isHideButton
    }
    
    @IBAction private func didToDiscover() {
        onTapDiscover?()
    }
}
