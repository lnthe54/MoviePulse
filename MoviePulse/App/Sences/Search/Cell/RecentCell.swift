import UIKit

class RecentCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var recentLabel: UILabel!
    
    var didToRemove: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(8)
        
        recentLabel.textColor = .blackColor
        recentLabel.font = .outfitFont(ofSize: 14, weight: .medium)
    }
    
    func bindData(with key: String) {
        recentLabel.text = key
    }
    
    @IBAction func actionRemove() {
        didToRemove?(recentLabel.text ?? "")
    }
}
