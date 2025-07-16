import UIKit
import Kingfisher

class SavePulseCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var heartView: UIView!
    @IBOutlet private weak var heartLabel: UILabel!
    @IBOutlet private weak var heartValueLabel: UILabel!
    @IBOutlet private weak var tensionView: UIView!
    @IBOutlet private weak var tensionLabel: UILabel!
    @IBOutlet private weak var tensionValueLabel: UILabel!
    @IBOutlet private weak var moreButton: UIButton!
    
    var onTapMoreAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(4)
        
        posterImageView.corner(8)
        
        nameLabel.textColor = .blackColor
        nameLabel.font = .outfitFont(ofSize: 16, weight: .semiBold)
        
        timeLabel.textColor = UIColor(hexString: "#697081")
        timeLabel.font = .outfitFont(ofSize: 12, weight: .light)
        
        heartView.configSubView()
        heartLabel.configSubLabel("Heart rate")
        heartValueLabel.textColor = UIColor(hexString: "#2D095D")
        heartValueLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
        
        tensionView.configSubView()
        tensionLabel.configSubLabel("Tension rate")
        tensionValueLabel.textColor = UIColor(hexString: "#2D095D")
        tensionValueLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
    }
    
    func bindData(_ data: PulseResultInfo, isHideMore: Bool = false) {
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(data.path, size: .w342)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        nameLabel.text = data.name
        let timeValue = data.date.toString(formatter: .dayMonthYear) ?? "Unknown date"
        timeLabel.text = "Recorded at \(timeValue)"
        heartValueLabel.text = "\(data.bpm) BPM"
        tensionValueLabel.text = "\(data.tension)%"
        moreButton.isHidden = isHideMore
    }
    
    @IBAction private func tapToMoreButton() {
        onTapMoreAction?()
    }
}
