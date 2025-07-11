import UIKit

class InfoSeasonDetailCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var releaseView: UIView!
    @IBOutlet private weak var releaseLabel: UILabel!
    @IBOutlet private weak var episodeView: UIView!
    @IBOutlet private weak var episodeLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        setupViews()
    }
    
    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(8)
        
        nameLabel.textColor = .blackColor
        nameLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        
        contentLabel.textColor = .blackColor
        contentLabel.font = .outfitFont(ofSize: 14)
        contentLabel.numberOfLines = 0
        
        releaseView.corner(releaseView.frame.height / 2)
        releaseView.backgroundColor = .blackColor
        releaseLabel.textColor = .white
        releaseLabel.font = .outfitFont(ofSize: 12, weight: .light)
        
        episodeView.corner(episodeView.frame.height / 2)
        episodeView.backgroundColor = UIColor(hexString: "#E7D9FB")
        episodeLabel.textColor = UIColor(hexString: "#8435F3")
        episodeLabel.font = .outfitFont(ofSize: 12, weight: .light)
    }

    func bindData(_ data: SeasonInfo) {
        nameLabel.text = data.name
        releaseLabel.text = data.releaseYear()
        episodeLabel.text = "\(data.episodes.count) episodes"
        if let overview = data.overview, overview.isNotEmpty {
            contentLabel.text = overview
            contentLabel.textAlignment = .justified
        } else {
            contentLabel.text = "N/a"
            contentLabel.textAlignment = .center
        }
    }
}
