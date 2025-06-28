import UIKit

class SingleCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = UIColor(hexString: "#E7D9FB")
        containerView.corner(4)
        titleLabel.textColor = .pimaryColor
        titleLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
    }
    
    func bindData(forTitle title: String, icon: String) {
        titleLabel.text = title
        iconImageView.image = UIImage(named: icon)
    }
}
