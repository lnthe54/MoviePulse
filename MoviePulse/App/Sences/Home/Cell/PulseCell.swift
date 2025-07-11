import UIKit

class PulseCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    var onTapStart: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = UIColor(hexString: "#E7D9FB")
        containerView.corner(4)
        
        titleLabel.text = "No measurements yet"
        titleLabel.textColor = .blackColor
        titleLabel.textAlignment = .center
        titleLabel.font = .outfitFont(ofSize: 14)
        
        contentLabel.text = "Try it out and discover how you really feel about the movie"
        contentLabel.textColor = .blackColor
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        
        startButton.corner(startButton.frame.height / 2)
        startButton.backgroundColor = .pimaryColor
        startButton.setTitle("Start Now", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = .outfitFont(ofSize: 14, weight: .semiBold)
    }
    
    @IBAction private func didToStart() {
        onTapStart?()
    }
}
