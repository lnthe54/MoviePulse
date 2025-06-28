import UIKit
import Kingfisher

class ItemHorizontalCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var rateView: UIView!
    @IBOutlet private weak var rateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        posterImageView.corner(8)
        posterImageView.contentMode = .scaleAspectFill
        nameLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        nameLabel.textColor = .blackColor
        rateView.backgroundColor = .pimaryColor
        rateView.corner(rateView.frame.height / 2)
        rateLabel.textColor = .white
        rateLabel.font = .outfitFont(ofSize: 12)
    }
    
    func bindData(_ infoObject: InfoObject) {
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(infoObject.path ?? "", size: .w342)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        nameLabel.text = infoObject.name
        rateLabel.text = String(Int(infoObject.vote ?? 0.0))
    }
}
