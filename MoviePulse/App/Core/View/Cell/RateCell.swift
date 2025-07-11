import UIKit

class RateCell: UICollectionViewCell {
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

    func bindData(rate: Int) {
        rateLabel.text = String(rate)
    }
}
