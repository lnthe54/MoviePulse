import UIKit
import Kingfisher

class TrailerCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var trailerLabel: UILabel!
    @IBOutlet private weak var publishedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(16)
        
        posterImageView.corner(12)
        posterImageView.backgroundColor = .lightGray
        posterImageView.image = UIImage(named: "ic_loading")
        
        trailerLabel.textColor = UIColor(hexString: "#060606")
        trailerLabel.font = .outfitFont(ofSize: 16, weight: .medium)
        trailerLabel.numberOfLines = 2
        
        publishedLabel.textColor = UIColor(hexString: "#525252")
        publishedLabel.font = .outfitFont(ofSize: 12)
    }
    
    func bindData(_ trailer: VideoInfo) {
        let thumbnailURL = URL(string: Constants.Network.THUMBNAIL_YOUTUBE_URL +
                               trailer.key +
                               Constants.Network.THUMBNAIL_MAX_YOUTUBE)
        posterImageView.kf.setImage(
            with: thumbnailURL,
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        trailerLabel.text = trailer.name
        publishedLabel.text = "Published: \(trailer.publishedDate)"
    }
}
