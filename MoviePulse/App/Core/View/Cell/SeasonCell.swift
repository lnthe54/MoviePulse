import UIKit
import Kingfisher

class SeasonCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var seasonLabel: UILabel!
    @IBOutlet private weak var episodeLabel: UILabel!
    @IBOutlet private weak var overViewLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(8)
        
        posterImageView.corner(8)
        posterImageView.contentMode = .scaleAspectFill
        
        seasonLabel.textColor = .blackColor
        seasonLabel.font = .outfitFont(ofSize: 14, weight: .medium)

        episodeLabel.textColor = UIColor(hexString: "#697081")
        episodeLabel.font = .outfitFont(ofSize: 12, weight: .light)
        
        overViewLabel.textColor = UIColor(hexString: "#697081")
        overViewLabel.font = .outfitFont(ofSize: 14, weight: .regular)
        overViewLabel.numberOfLines = 3
    }
    
    func bindData(_ data: SeasonObject) {
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(data.posterPath ?? "", size: .w342)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        seasonLabel.text = data.name
        episodeLabel.text = "\(data.episodeCount) episodes"
        overViewLabel.text = data.overview.isEmpty ? "N/a" : data.overview
    }
}
