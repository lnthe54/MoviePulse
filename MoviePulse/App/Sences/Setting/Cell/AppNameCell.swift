import UIKit

class AppNameCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var appNameLabel: UILabel!
    @IBOutlet private weak var appVersionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.backgroundColor = UIColor(hexString: "#E7D9FB")
        containerView.corner(4)
        
        appNameLabel.text = AppInfo.name
        appNameLabel.textColor = .blackColor
        appNameLabel.font = .outfitFont(ofSize: 16, weight: .semiBold)
        
        appVersionLabel.text = "V" + AppInfo.version
        appVersionLabel.textColor = UIColor(hexString: "#252934")
        appVersionLabel.font = .outfitFont(ofSize: 14, weight: .regular)
    }
}
