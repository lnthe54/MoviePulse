import UIKit

class CommunityCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var avgView: UIView!
    @IBOutlet private weak var avgTitleLabel: UILabel!
    @IBOutlet private weak var avgValueLabel: UILabel!
    @IBOutlet private weak var tenseView: UIView!
    @IBOutlet private weak var tenseTitleLabel: UILabel!
    @IBOutlet private weak var tenseValueLabel: UILabel!
    @IBOutlet private weak var calmView: UIView!
    @IBOutlet private weak var calmTitleLabel: UILabel!
    @IBOutlet private weak var calmValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(8)
        
        titleLabel.text = "Compare with community"
        titleLabel.font = .outfitFont(ofSize: 16, weight: .semiBold)
        titleLabel.textColor = .blackColor
        
        // Avg view
        avgView.backgroundColor = UIColor(hexString: "#FAF7FE")
        avgView.corner(4)
        
        avgTitleLabel.text = "Avg Pulse of Viewers"
        avgTitleLabel.textColor = .pimaryColor
        avgTitleLabel.font = .outfitFont(ofSize: 12, weight: .light)
        
        avgValueLabel.textColor = UIColor(hexString: "#2D095D")
        avgValueLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
        
        // Tense view
        tenseView.backgroundColor = UIColor(hexString: "#FAF7FE")
        tenseView.corner(4)
        
        tenseTitleLabel.text = "felt Tense"
        tenseTitleLabel.textColor = .pimaryColor
        tenseTitleLabel.font = .outfitFont(ofSize: 12, weight: .light)
        
        tenseValueLabel.textColor = UIColor(hexString: "#2D095D")
        tenseValueLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
        
        // Calm view
        calmView.backgroundColor = UIColor(hexString: "#FAF7FE")
        calmView.corner(4)
        
        calmTitleLabel.text = "felt Calm"
        calmTitleLabel.textColor = .pimaryColor
        calmTitleLabel.font = .outfitFont(ofSize: 12, weight: .light)
        
        calmValueLabel.textColor = UIColor(hexString: "#2D095D")
        calmValueLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
    }
    
    func bindData(genre: String, voteAvg: Double) {
        let avgValue = Utils.getAvgPluse(withGenre: genre, voteAvg: voteAvg)
        avgValueLabel.text = "\(avgValue) BPM"
        
        let emotions = Utils.emotionPercentages(for: avgValue)
        let tense = emotions["Tense"] ?? 0
        let calm = emotions["Calm"] ?? 0
        
        tenseValueLabel.text = "\(tense)%"
        calmValueLabel.text = "\(calm)%"
    }
}
