import UIKit

class TagCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        containerView.backgroundColor = UIColor(hexString: "#E7D9FB")
        
        nameLabel.font = .outfitFont(ofSize: 12, weight: .light)
        nameLabel.textColor = UIColor(hexString: "#8435F3")
    }

    func bindData(text: String) {
        nameLabel.text = text
    }
}
