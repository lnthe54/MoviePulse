import UIKit

class RateCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var rateView: UIView!
    @IBOutlet private weak var rateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rateView.backgroundColor = .pimaryColor
        rateView.corner(rateView.frame.height / 2)
        rateLabel.textColor = .white
        rateLabel.font = .outfitFont(ofSize: 12)
    }

    func bindData(text: String) {
        rateLabel.text = text
    }
}
