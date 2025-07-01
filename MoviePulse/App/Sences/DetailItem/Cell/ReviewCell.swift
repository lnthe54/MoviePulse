import UIKit

class ReviewCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var rateView: UIView!
    @IBOutlet private weak var rateLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(8)
        
        statusLabel.textColor = .blackColor
        statusLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        
        rateView.backgroundColor = .pimaryColor
        rateView.corner(rateView.frame.height / 2)
        rateLabel.textColor = .white
        rateLabel.font = .outfitFont(ofSize: 12)
        
        contentLabel.textColor = UIColor(hexString: "#2D3343")
        contentLabel.font = .outfitFont(ofSize: 14, weight: .light)
        contentLabel.numberOfLines = 4
        
        authorLabel.textColor = UIColor(hexString: "#697081")
        authorLabel.font = .outfitFont(ofSize: 12, weight: .light)
    }
    
    func bindData(review: ReviewObject) {
        statusLabel.text = getStatusVote(rate: review.authorDetails.rating ?? 0)
        rateLabel.text = String(review.authorDetails.rating ?? 0)
        contentLabel.text = review.content
        authorLabel.text = "by " + review.author
    }
    
    private func getStatusVote(rate: Int) -> String {
        switch rate {
        case 9...10:
            return "Excellent"
        case 8...9:
            return "Good"
        case 5...7:
            return "Average"
        default:
            return "Bad"
        }
    }
}
